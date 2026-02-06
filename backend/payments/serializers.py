"""
Serializers for payments app
"""
from rest_framework import serializers
from .models import Payment, QRCode
from orders.serializers import OrderSerializer


class PaymentSerializer(serializers.ModelSerializer):
    """Serializer for Payment model"""
    
    order_id = serializers.CharField(source='order.order_id', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    method_display = serializers.CharField(source='get_method_display', read_only=True)
    
    class Meta:
        model = Payment
        fields = [
            'id', 'payment_id', 'order', 'order_id', 'amount',
            'status', 'status_display', 'method', 'method_display',
            'upi_transaction_id', 'created_at', 'completed_at'
        ]
        read_only_fields = ['id', 'payment_id', 'created_at', 'completed_at']


class PaymentInitiateSerializer(serializers.Serializer):
    """Serializer for initiating payment"""
    
    order_id = serializers.CharField()
    method = serializers.ChoiceField(
        choices=Payment.Method.choices,
        default=Payment.Method.UPI
    )


class PaymentConfirmSerializer(serializers.Serializer):
    """Serializer for confirming payment"""
    
    order_id = serializers.CharField()
    transaction_id = serializers.CharField()
    status = serializers.ChoiceField(
        choices=[('success', 'Success'), ('failed', 'Failed')],
        default='success'
    )


class QRCodeSerializer(serializers.ModelSerializer):
    """Serializer for QR Code model"""
    
    order_id = serializers.CharField(source='order.order_id', read_only=True)
    is_expired = serializers.BooleanField(read_only=True)
    
    class Meta:
        model = QRCode
        fields = [
            'id', 'order', 'order_id', 'encrypted_data',
            'is_used', 'used_at', 'expires_at', 'is_expired', 'created_at'
        ]
        read_only_fields = ['id', 'encrypted_data', 'created_at']


class QRVerifySerializer(serializers.Serializer):
    """Serializer for QR verification request"""
    
    qr_data = serializers.CharField()


class QRVerifyResponseSerializer(serializers.Serializer):
    """Serializer for QR verification response"""
    
    valid = serializers.BooleanField()
    error = serializers.CharField(required=False)
    code = serializers.CharField(required=False)
    order = OrderSerializer(required=False)


class UPIIntentSerializer(serializers.Serializer):
    """Serializer for UPI intent data"""
    
    order_id = serializers.CharField()
    upi_id = serializers.CharField()
    payee_name = serializers.CharField()
    amount = serializers.DecimalField(max_digits=10, decimal_places=2)
    transaction_note = serializers.CharField()
    upi_intent_url = serializers.CharField()
