"""
Views for orders app
"""
from rest_framework import generics, permissions, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.db import transaction
from django.utils import timezone
from .models import Order, OrderItem
from .serializers import (
    OrderSerializer, OrderListSerializer, OrderCreateSerializer,
    OrderStatusUpdateSerializer
)
from canteen.models import Canteen, MenuItem
from accounts.permissions import IsManager, IsManagerOrAdmin, IsCustomer


class OrderListView(generics.ListAPIView):
    """List orders for the current user"""
    serializer_class = OrderListSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        queryset = Order.objects.filter(user=user)
        
        # Filter by status if provided
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        return queryset


class OrderDetailView(generics.RetrieveAPIView):
    """Get order details"""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.role == 'admin':
            return Order.objects.all()
        if user.role == 'manager' and user.managed_canteen:
            return Order.objects.filter(canteen=user.managed_canteen)
        return Order.objects.filter(user=user)


class OrderCreateView(generics.CreateAPIView):
    """Create a new order"""
    serializer_class = OrderCreateSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        data = serializer.validated_data
        canteen = Canteen.objects.get(pk=data['canteen_id'])
        
        # Create order
        order = Order.objects.create(
            user=request.user,
            canteen=canteen,
            special_instructions=data.get('special_instructions', '')
        )
        
        # Create order items
        for item_data in data['items']:
            try:
                menu_item = MenuItem.objects.get(
                    pk=item_data['menu_item_id'],
                    canteen=canteen,
                    is_active=True,
                    is_available=True
                )
                OrderItem.objects.create(
                    order=order,
                    menu_item=menu_item,
                    item_name=menu_item.name,
                    item_price=menu_item.price,
                    quantity=item_data['quantity'],
                    special_instructions=item_data.get('special_instructions', '')
                )
            except MenuItem.DoesNotExist:
                # Rollback transaction
                raise ValueError(f"Menu item {item_data['menu_item_id']} not available")
        
        # Calculate totals
        order.calculate_totals()
        
        response_serializer = OrderSerializer(order)
        return Response({
            'success': True,
            'message': 'Order created successfully',
            'order': response_serializer.data
        }, status=status.HTTP_201_CREATED)


# Manager views
class ManagerOrderListView(generics.ListAPIView):
    """List orders for manager's canteen"""
    serializer_class = OrderListSerializer
    permission_classes = [permissions.IsAuthenticated, IsManagerOrAdmin]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.role == 'admin':
            queryset = Order.objects.all()
        elif user.managed_canteen:
            queryset = Order.objects.filter(canteen=user.managed_canteen)
        else:
            queryset = Order.objects.none()
        
        # Filter by status
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        # Filter by date
        date_filter = self.request.query_params.get('date')
        if date_filter:
            queryset = queryset.filter(created_at__date=date_filter)
        
        return queryset


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated, IsManagerOrAdmin])
def update_order_status(request, order_id):
    """Update order status (Manager only)"""
    serializer = OrderStatusUpdateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    
    try:
        user = request.user
        if user.is_superuser or user.role == 'admin':
            order = Order.objects.get(order_id=order_id)
        elif user.managed_canteen:
            order = Order.objects.get(order_id=order_id, canteen=user.managed_canteen)
        else:
            return Response(
                {'error': 'You do not have permission to update this order'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        new_status = serializer.validated_data['status']
        old_status = order.status
        
        order.status = new_status
        
        # Update timestamps based on status change
        if new_status == Order.Status.CONFIRMED:
            order.confirmed_at = timezone.now()
        elif new_status == Order.Status.COMPLETED:
            order.completed_at = timezone.now()
        
        order.save()
        
        return Response({
            'success': True,
            'message': f'Order status updated from {old_status} to {new_status}',
            'order': OrderSerializer(order).data
        })
    
    except Order.DoesNotExist:
        return Response(
            {'error': 'Order not found'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def cancel_order(request, order_id):
    """Cancel an order (Customer or Manager)"""
    try:
        user = request.user
        if user.is_superuser or user.role == 'admin':
            order = Order.objects.get(order_id=order_id)
        elif user.role == 'manager' and user.managed_canteen:
            order = Order.objects.get(order_id=order_id, canteen=user.managed_canteen)
        else:
            order = Order.objects.get(order_id=order_id, user=user)
        
        # Can only cancel pending or paid orders
        if order.status not in [Order.Status.PENDING, Order.Status.PAID]:
            return Response(
                {'error': 'Cannot cancel order in current status'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        order.status = Order.Status.CANCELLED
        order.save()
        
        return Response({
            'success': True,
            'message': 'Order cancelled successfully',
            'order': OrderSerializer(order).data
        })
    
    except Order.DoesNotExist:
        return Response(
            {'error': 'Order not found'},
            status=status.HTTP_404_NOT_FOUND
        )
