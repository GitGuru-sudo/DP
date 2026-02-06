"""
Admin configuration for payments app
"""
from django.contrib import admin
from django.utils.html import format_html
from .models import Payment, QRCode


@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    """Admin for Payment model"""
    
    list_display = [
        'payment_id', 'order', 'user', 'amount_display',
        'status_display', 'method', 'created_at'
    ]
    list_filter = ['status', 'method', 'created_at']
    search_fields = ['payment_id', 'order__order_id', 'user__email', 'upi_transaction_id']
    readonly_fields = ['payment_id', 'created_at', 'updated_at', 'completed_at']
    date_hierarchy = 'created_at'
    
    fieldsets = (
        ('Payment Info', {'fields': ('payment_id', 'order', 'user', 'amount', 'status', 'method')}),
        ('UPI Details', {'fields': ('upi_transaction_id', 'upi_response')}),
        ('Gateway Details', {'fields': ('gateway_order_id', 'gateway_payment_id', 'gateway_signature')}),
        ('Timestamps', {'fields': ('created_at', 'updated_at', 'completed_at')}),
    )
    
    def amount_display(self, obj):
        return f'₹{obj.amount}'
    amount_display.short_description = 'Amount'
    
    def status_display(self, obj):
        colors = {
            'pending': 'orange',
            'success': 'green',
            'failed': 'red',
            'refunded': 'blue'
        }
        color = colors.get(obj.status, 'gray')
        return format_html(
            '<span style="color: {}; font-weight: bold;">{}</span>',
            color,
            obj.get_status_display()
        )
    status_display.short_description = 'Status'


@admin.register(QRCode)
class QRCodeAdmin(admin.ModelAdmin):
    """Admin for QRCode model"""
    
    list_display = ['order', 'qr_status', 'expires_at', 'is_expired_display', 'used_by', 'created_at']
    list_filter = ['is_used', 'created_at']
    search_fields = ['order__order_id']
    readonly_fields = ['encrypted_data', 'created_at', 'used_at']
    
    def qr_status(self, obj):
        if obj.is_used:
            return format_html('<span style="color: green;">✓ Used</span>')
        if obj.is_expired:
            return format_html('<span style="color: red;">✗ Expired</span>')
        return format_html('<span style="color: blue;">○ Active</span>')
    qr_status.short_description = 'Status'
    
    def is_expired_display(self, obj):
        if obj.is_expired:
            return format_html('<span style="color: red;">Yes</span>')
        return format_html('<span style="color: green;">No</span>')
    is_expired_display.short_description = 'Expired'
