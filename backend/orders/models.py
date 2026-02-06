"""
Models for orders app
"""
from django.db import models
from django.conf import settings
from django.utils import timezone
from canteen.models import Canteen, MenuItem
import uuid


class Order(models.Model):
    """Order model"""
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'Pending Payment'
        PAID = 'paid', 'Paid'
        CONFIRMED = 'confirmed', 'Confirmed'
        PREPARING = 'preparing', 'Preparing'
        READY = 'ready', 'Ready for Pickup'
        COMPLETED = 'completed', 'Completed'
        CANCELLED = 'cancelled', 'Cancelled'
    
    # Unique order ID
    order_id = models.CharField(max_length=50, unique=True, editable=False)
    
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='orders'
    )
    canteen = models.ForeignKey(
        Canteen,
        on_delete=models.CASCADE,
        related_name='orders'
    )
    
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING
    )
    
    # Order amounts
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    # Special instructions
    special_instructions = models.TextField(blank=True)
    
    # QR Code tracking
    qr_code_used = models.BooleanField(default=False)
    qr_code_used_at = models.DateTimeField(null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def save(self, *args, **kwargs):
        if not self.order_id:
            self.order_id = self.generate_order_id()
        super().save(*args, **kwargs)
    
    def generate_order_id(self):
        """Generate a unique order ID"""
        timestamp = timezone.now().strftime('%Y%m%d%H%M')
        unique = uuid.uuid4().hex[:6].upper()
        return f'DP{timestamp}{unique}'
    
    def __str__(self):
        return f"Order {self.order_id} - {self.user.email}"
    
    def calculate_totals(self):
        """Calculate order totals from items"""
        self.subtotal = sum(item.total_price for item in self.items.all())
        self.tax = self.subtotal * 0  # No tax for now, can be configured
        self.total_amount = self.subtotal + self.tax
        self.save()
    
    def mark_as_paid(self):
        """Mark order as paid"""
        self.status = self.Status.PAID
        self.paid_at = timezone.now()
        self.save()
    
    def confirm_order(self):
        """Confirm the order"""
        self.status = self.Status.CONFIRMED
        self.confirmed_at = timezone.now()
        self.save()
    
    def mark_qr_used(self):
        """Mark QR code as used"""
        self.qr_code_used = True
        self.qr_code_used_at = timezone.now()
        self.save()


class OrderItem(models.Model):
    """Order item model"""
    
    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name='items'
    )
    menu_item = models.ForeignKey(
        MenuItem,
        on_delete=models.SET_NULL,
        null=True
    )
    
    # Store item details at time of order
    item_name = models.CharField(max_length=255)
    item_price = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.PositiveIntegerField(default=1)
    
    # Special instructions for this item
    special_instructions = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['created_at']
    
    def __str__(self):
        return f"{self.quantity}x {self.item_name}"
    
    @property
    def total_price(self):
        return self.item_price * self.quantity
    
    def save(self, *args, **kwargs):
        # Store item details from menu item
        if self.menu_item and not self.item_name:
            self.item_name = self.menu_item.name
            self.item_price = self.menu_item.price
        super().save(*args, **kwargs)
