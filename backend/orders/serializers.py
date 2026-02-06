"""
Serializers for orders app
"""
from rest_framework import serializers
from .models import Order, OrderItem
from canteen.models import MenuItem


class OrderItemSerializer(serializers.ModelSerializer):
    """Serializer for OrderItem model"""
    
    total_price = serializers.DecimalField(
        max_digits=10, 
        decimal_places=2, 
        read_only=True
    )
    
    class Meta:
        model = OrderItem
        fields = [
            'id', 'menu_item', 'item_name', 'item_price',
            'quantity', 'special_instructions', 'total_price'
        ]
        read_only_fields = ['id', 'item_name', 'item_price']


class OrderItemCreateSerializer(serializers.Serializer):
    """Serializer for creating order items"""
    
    menu_item_id = serializers.IntegerField()
    quantity = serializers.IntegerField(min_value=1, default=1)
    special_instructions = serializers.CharField(required=False, allow_blank=True)


class OrderSerializer(serializers.ModelSerializer):
    """Serializer for Order model"""
    
    items = OrderItemSerializer(many=True, read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    user_name = serializers.CharField(source='user.name', read_only=True)
    canteen_name = serializers.CharField(source='canteen.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = Order
        fields = [
            'id', 'order_id', 'user', 'user_email', 'user_name',
            'canteen', 'canteen_name', 'status', 'status_display',
            'subtotal', 'tax', 'total_amount', 'special_instructions',
            'qr_code_used', 'items', 'created_at', 'updated_at',
            'paid_at', 'confirmed_at', 'completed_at'
        ]
        read_only_fields = [
            'id', 'order_id', 'user', 'subtotal', 'tax', 'total_amount',
            'qr_code_used', 'created_at', 'updated_at', 'paid_at',
            'confirmed_at', 'completed_at'
        ]


class OrderListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for order list"""
    
    canteen_name = serializers.CharField(source='canteen.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    items_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Order
        fields = [
            'id', 'order_id', 'canteen_name', 'status', 'status_display',
            'total_amount', 'items_count', 'created_at'
        ]
    
    def get_items_count(self, obj):
        return obj.items.count()


class OrderCreateSerializer(serializers.Serializer):
    """Serializer for creating orders"""
    
    canteen_id = serializers.IntegerField()
    items = OrderItemCreateSerializer(many=True)
    special_instructions = serializers.CharField(required=False, allow_blank=True)
    
    def validate_items(self, value):
        if not value:
            raise serializers.ValidationError("At least one item is required")
        return value
    
    def validate_canteen_id(self, value):
        from canteen.models import Canteen
        try:
            canteen = Canteen.objects.get(pk=value, is_active=True)
        except Canteen.DoesNotExist:
            raise serializers.ValidationError("Invalid canteen")
        return value


class OrderStatusUpdateSerializer(serializers.Serializer):
    """Serializer for updating order status"""
    
    status = serializers.ChoiceField(choices=Order.Status.choices)
