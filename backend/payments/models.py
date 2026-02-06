"""
Models for payments app
"""
from django.db import models
from django.conf import settings
from orders.models import Order
import uuid


class Payment(models.Model):
    """Payment model"""
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'Pending'
        SUCCESS = 'success', 'Success'
        FAILED = 'failed', 'Failed'
        REFUNDED = 'refunded', 'Refunded'
    
    class Method(models.TextChoices):
        UPI = 'upi', 'UPI'
        CASH = 'cash', 'Cash'
        OTHER = 'other', 'Other'
    
    # Unique payment ID
    payment_id = models.CharField(max_length=50, unique=True, editable=False)
    
    order = models.OneToOneField(
        Order,
        on_delete=models.CASCADE,
        related_name='payment'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='payments'
    )
    
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING
    )
    method = models.CharField(
        max_length=20,
        choices=Method.choices,
        default=Method.UPI
    )
    
    # UPI transaction details
    upi_transaction_id = models.CharField(max_length=255, blank=True)
    upi_response = models.JSONField(default=dict, blank=True)
    
    # For future payment gateway integration
    gateway_order_id = models.CharField(max_length=255, blank=True)
    gateway_payment_id = models.CharField(max_length=255, blank=True)
    gateway_signature = models.CharField(max_length=255, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def save(self, *args, **kwargs):
        if not self.payment_id:
            self.payment_id = f'PAY{uuid.uuid4().hex[:12].upper()}'
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"Payment {self.payment_id} - ₹{self.amount}"


class QRCode(models.Model):
    """QR Code model for order verification"""
    
    order = models.OneToOneField(
        Order,
        on_delete=models.CASCADE,
        related_name='qr_code'
    )
    
    # Encrypted QR data
    encrypted_data = models.TextField()
    
    # Tracking
    is_used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    used_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='scanned_qr_codes'
    )
    
    # Expiry
    expires_at = models.DateTimeField()
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'QR Code'
        verbose_name_plural = 'QR Codes'
    
    def __str__(self):
        return f"QR for Order {self.order.order_id}"
    
    @property
    def is_expired(self):
        from django.utils import timezone
        return timezone.now() > self.expires_at
