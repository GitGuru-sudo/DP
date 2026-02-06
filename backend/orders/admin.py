"""
Admin configuration for orders app
"""
from django.contrib import admin
from django.utils.html import format_html
from .models import Order, OrderItem


class OrderItemInline(admin.TabularInline):
    """Inline admin for order items"""
    model = OrderItem
    extra = 0
    readonly_fields = ['menu_item', 'item_name', 'item_price', 'quantity', 'total_price']
    
    def total_price(self, obj):
        return f'₹{obj.total_price}'


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    """Admin for Order model"""
    
    list_display = [
        'order_id', 'user', 'canteen', 'total_display', 
        'status_display', 'qr_status', 'created_at'
    ]
    list_filter = ['status', 'canteen', 'qr_code_used', 'created_at']
    search_fields = ['order_id', 'user__email', 'user__name']
    readonly_fields = [
        'order_id', 'subtotal', 'tax', 'total_amount',
        'created_at', 'updated_at', 'paid_at', 'confirmed_at', 
        'completed_at', 'qr_code_used_at'
    ]
    inlines = [OrderItemInline]
    date_hierarchy = 'created_at'
    
    fieldsets = (
        ('Order Info', {'fields': ('order_id', 'user', 'canteen', 'status')}),
        ('Amounts', {'fields': ('subtotal', 'tax', 'total_amount')}),
        ('Instructions', {'fields': ('special_instructions',)}),
        ('QR Code', {'fields': ('qr_code_used', 'qr_code_used_at')}),
        ('Timestamps', {'fields': ('created_at', 'updated_at', 'paid_at', 'confirmed_at', 'completed_at')}),
    )
    
    def total_display(self, obj):
        return f'₹{obj.total_amount}'
    total_display.short_description = 'Total'
    
    def status_display(self, obj):
        colors = {
            'pending': 'orange',
            'paid': 'blue',
            'confirmed': 'green',
            'preparing': 'purple',
            'ready': 'teal',
            'completed': 'gray',
            'cancelled': 'red'
        }
        color = colors.get(obj.status, 'gray')
        return format_html(
            '<span style="color: {}; font-weight: bold;">{}</span>',
            color,
            obj.get_status_display()
        )
    status_display.short_description = 'Status'
    
    def qr_status(self, obj):
        if obj.qr_code_used:
            return format_html('<span style="color: green;">✓ Used</span>')
        return format_html('<span style="color: orange;">○ Pending</span>')
    qr_status.short_description = 'QR'


@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    """Admin for OrderItem model"""
    
    list_display = ['order', 'item_name', 'quantity', 'item_price', 'total_display']
    list_filter = ['order__canteen', 'created_at']
    search_fields = ['order__order_id', 'item_name']
    
    def total_display(self, obj):
        return f'₹{obj.total_price}'
    total_display.short_description = 'Total'
