"""
Views for payments app
"""
from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.utils import timezone
from django.db import transaction
import urllib.parse
from .models import Payment, QRCode
from .serializers import (
    PaymentSerializer, PaymentInitiateSerializer, PaymentConfirmSerializer,
    QRCodeSerializer, QRVerifySerializer, UPIIntentSerializer
)
from .encryption import create_encrypted_qr, verify_qr_data
from orders.models import Order
from orders.serializers import OrderSerializer
from accounts.permissions import IsManagerOrAdmin


class PaymentListView(generics.ListAPIView):
    """List payments for current user"""
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Payment.objects.filter(user=self.request.user)


class PaymentDetailView(generics.RetrieveAPIView):
    """Get payment details"""
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]
    lookup_field = 'payment_id'
    
    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.role == 'admin':
            return Payment.objects.all()
        return Payment.objects.filter(user=user)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def initiate_payment(request):
    """
    Initiate payment for an order
    Returns UPI intent URL for payment
    """
    serializer = PaymentInitiateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    order_id = serializer.validated_data['order_id']
    method = serializer.validated_data['method']
    
    try:
        order = Order.objects.get(order_id=order_id, user=request.user)
    except Order.DoesNotExist:
        return Response(
            {'error': 'Order not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Check if order is already paid
    if order.status != Order.Status.PENDING:
        return Response(
            {'error': 'Order is not pending payment'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Check if payment already exists
    payment, created = Payment.objects.get_or_create(
        order=order,
        defaults={
            'user': request.user,
            'amount': order.total_amount,
            'method': method,
        }
    )
    
    if not created:
        # Update existing payment
        payment.amount = order.total_amount
        payment.method = method
        payment.save()
    
    # Generate UPI intent URL
    canteen = order.canteen
    upi_id = canteen.upi_id or 'dpcanteen@upi'
    payee_name = canteen.upi_name or canteen.name
    amount = str(order.total_amount)
    transaction_note = f'DP Canteen Order {order.order_id}'
    
    # Create UPI intent URL
    upi_params = {
        'pa': upi_id,
        'pn': payee_name,
        'am': amount,
        'cu': 'INR',
        'tn': transaction_note,
        'tr': order.order_id,  # Transaction reference
    }
    upi_intent_url = 'upi://pay?' + urllib.parse.urlencode(upi_params)
    
    return Response({
        'success': True,
        'payment': PaymentSerializer(payment).data,
        'upi_intent': {
            'order_id': order.order_id,
            'upi_id': upi_id,
            'payee_name': payee_name,
            'amount': amount,
            'transaction_note': transaction_note,
            'upi_intent_url': upi_intent_url,
        }
    })


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
@transaction.atomic
def confirm_payment(request):
    """
    Confirm payment after UPI transaction
    Generates QR code on successful payment
    """
    serializer = PaymentConfirmSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    order_id = serializer.validated_data['order_id']
    transaction_id = serializer.validated_data['transaction_id']
    payment_status = serializer.validated_data['status']
    
    try:
        order = Order.objects.get(order_id=order_id, user=request.user)
    except Order.DoesNotExist:
        return Response(
            {'error': 'Order not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    try:
        payment = Payment.objects.get(order=order)
    except Payment.DoesNotExist:
        return Response(
            {'error': 'Payment not initiated'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if payment_status == 'success':
        # Update payment
        payment.status = Payment.Status.SUCCESS
        payment.upi_transaction_id = transaction_id
        payment.completed_at = timezone.now()
        payment.save()
        
        # Update order
        order.mark_as_paid()
        
        # Generate QR code
        encrypted_data, expires_at = create_encrypted_qr(order)
        
        qr_code, _ = QRCode.objects.update_or_create(
            order=order,
            defaults={
                'encrypted_data': encrypted_data,
                'expires_at': expires_at,
            }
        )
        
        return Response({
            'success': True,
            'message': 'Payment confirmed successfully',
            'payment': PaymentSerializer(payment).data,
            'qr_code': {
                'data': encrypted_data,
                'expires_at': expires_at.isoformat(),
            },
            'order': OrderSerializer(order).data,
        })
    else:
        # Payment failed
        payment.status = Payment.Status.FAILED
        payment.save()
        
        return Response({
            'success': False,
            'message': 'Payment failed',
            'payment': PaymentSerializer(payment).data,
        })


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def get_order_qr(request, order_id):
    """
    Get QR code for a paid order
    Regenerates if expired
    """
    try:
        order = Order.objects.get(order_id=order_id, user=request.user)
    except Order.DoesNotExist:
        return Response(
            {'error': 'Order not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Check if order is paid
    if order.status == Order.Status.PENDING:
        return Response(
            {'error': 'Order not paid yet'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Check if QR already used
    if order.qr_code_used:
        return Response({
            'success': False,
            'error': 'QR code already used',
            'used_at': order.qr_code_used_at.isoformat() if order.qr_code_used_at else None,
        })
    
    # Get or regenerate QR code
    try:
        qr_code = order.qr_code
        
        # Regenerate if expired
        if qr_code.is_expired:
            encrypted_data, expires_at = create_encrypted_qr(order)
            qr_code.encrypted_data = encrypted_data
            qr_code.expires_at = expires_at
            qr_code.save()
    except QRCode.DoesNotExist:
        # Generate new QR code
        encrypted_data, expires_at = create_encrypted_qr(order)
        qr_code = QRCode.objects.create(
            order=order,
            encrypted_data=encrypted_data,
            expires_at=expires_at,
        )
    
    return Response({
        'success': True,
        'qr_code': {
            'data': qr_code.encrypted_data,
            'expires_at': qr_code.expires_at.isoformat(),
            'is_expired': qr_code.is_expired,
        },
        'order': OrderSerializer(order).data,
    })


# Manager endpoints
@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated, IsManagerOrAdmin])
@transaction.atomic
def verify_qr(request):
    """
    Verify scanned QR code (Manager only)
    """
    serializer = QRVerifySerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    qr_data = serializer.validated_data['qr_data']
    user = request.user
    
    # Get manager's canteen ID
    manager_canteen_id = None
    if user.role == 'manager' and user.managed_canteen:
        manager_canteen_id = user.managed_canteen.id
    
    # Verify QR data
    result = verify_qr_data(qr_data, manager_canteen_id)
    
    if not result['valid']:
        return Response({
            'success': False,
            'valid': False,
            'error': result['error'],
            'code': result.get('code'),
        }, status=status.HTTP_400_BAD_REQUEST)
    
    order = result['order']
    
    return Response({
        'success': True,
        'valid': True,
        'order': OrderSerializer(order).data,
        'message': 'QR code verified successfully',
    })


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated, IsManagerOrAdmin])
@transaction.atomic
def confirm_qr_scan(request):
    """
    Confirm QR scan and mark order (Manager only)
    This marks the QR as used and confirms the order
    """
    serializer = QRVerifySerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    qr_data = serializer.validated_data['qr_data']
    user = request.user
    
    # Get manager's canteen ID
    manager_canteen_id = None
    if user.role == 'manager' and user.managed_canteen:
        manager_canteen_id = user.managed_canteen.id
    
    # Verify QR data
    result = verify_qr_data(qr_data, manager_canteen_id)
    
    if not result['valid']:
        return Response({
            'success': False,
            'error': result['error'],
            'code': result.get('code'),
        }, status=status.HTTP_400_BAD_REQUEST)
    
    order = result['order']
    
    # Mark QR as used
    order.mark_qr_used()
    
    # Update QR code record
    try:
        qr_code = order.qr_code
        qr_code.is_used = True
        qr_code.used_at = timezone.now()
        qr_code.used_by = user
        qr_code.save()
    except QRCode.DoesNotExist:
        pass
    
    # Confirm the order
    order.confirm_order()
    
    return Response({
        'success': True,
        'message': 'Order confirmed successfully',
        'order': OrderSerializer(order).data,
    })
