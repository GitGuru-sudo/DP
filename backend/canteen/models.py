"""
Models for canteen app
"""
from django.db import models
from django.utils import timezone


class Canteen(models.Model):
    """Canteen model - represents a canteen location"""
    
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=255, blank=True)
    image = models.ImageField(upload_to='canteens/', blank=True, null=True)
    
    # Operating hours
    opening_time = models.TimeField(default='08:00')
    closing_time = models.TimeField(default='20:00')
    
    # UPI details for payment
    upi_id = models.CharField(max_length=255, blank=True)
    upi_name = models.CharField(max_length=255, blank=True)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['name']
    
    def __str__(self):
        return self.name
    
    @property
    def is_open(self):
        """Check if canteen is currently open"""
        now = timezone.localtime().time()
        return self.opening_time <= now <= self.closing_time


class Category(models.Model):
    """Menu category model"""
    
    canteen = models.ForeignKey(
        Canteen,
        on_delete=models.CASCADE,
        related_name='categories'
    )
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to='categories/', blank=True, null=True)
    display_order = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        verbose_name_plural = 'Categories'
        ordering = ['display_order', 'name']
        unique_together = ['canteen', 'name']
    
    def __str__(self):
        return f"{self.name} ({self.canteen.name})"


class MenuItem(models.Model):
    """Menu item model"""
    
    class FoodType(models.TextChoices):
        VEG = 'veg', 'Vegetarian'
        NON_VEG = 'non_veg', 'Non-Vegetarian'
        EGG = 'egg', 'Contains Egg'
    
    canteen = models.ForeignKey(
        Canteen,
        on_delete=models.CASCADE,
        related_name='menu_items'
    )
    category = models.ForeignKey(
        Category,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='items'
    )
    
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image = models.ImageField(upload_to='menu_items/', blank=True, null=True)
    
    food_type = models.CharField(
        max_length=10,
        choices=FoodType.choices,
        default=FoodType.VEG
    )
    
    # Availability
    is_available = models.BooleanField(default=True)
    is_active = models.BooleanField(default=True)
    
    # Preparation time in minutes
    prep_time = models.PositiveIntegerField(default=10)
    
    # Display order
    display_order = models.PositiveIntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['display_order', 'name']
    
    def __str__(self):
        return f"{self.name} - ₹{self.price}"
