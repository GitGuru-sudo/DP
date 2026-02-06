"""
Admin configuration for canteen app
"""
from django.contrib import admin
from django.utils.html import format_html
from .models import Canteen, Category, MenuItem


class CategoryInline(admin.TabularInline):
    """Inline admin for categories"""
    model = Category
    extra = 1
    fields = ['name', 'display_order', 'is_active']


class MenuItemInline(admin.TabularInline):
    """Inline admin for menu items"""
    model = MenuItem
    extra = 1
    fields = ['name', 'category', 'price', 'food_type', 'is_available', 'is_active']


@admin.register(Canteen)
class CanteenAdmin(admin.ModelAdmin):
    """Admin for Canteen model"""
    
    list_display = ['name', 'location', 'opening_time', 'closing_time', 'is_open_display', 'is_active']
    list_filter = ['is_active']
    search_fields = ['name', 'location']
    inlines = [CategoryInline]
    
    fieldsets = (
        (None, {'fields': ('name', 'description', 'location', 'image')}),
        ('Operating Hours', {'fields': ('opening_time', 'closing_time')}),
        ('UPI Payment Details', {'fields': ('upi_id', 'upi_name')}),
        ('Status', {'fields': ('is_active',)}),
    )
    
    def is_open_display(self, obj):
        if obj.is_open:
            return format_html('<span style="color: green;">✓ Open</span>')
        return format_html('<span style="color: red;">✗ Closed</span>')
    is_open_display.short_description = 'Status'


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    """Admin for Category model"""
    
    list_display = ['name', 'canteen', 'items_count', 'display_order', 'is_active']
    list_filter = ['canteen', 'is_active']
    search_fields = ['name']
    ordering = ['canteen', 'display_order']
    inlines = [MenuItemInline]
    
    def items_count(self, obj):
        return obj.items.count()
    items_count.short_description = 'Items'


@admin.register(MenuItem)
class MenuItemAdmin(admin.ModelAdmin):
    """Admin for MenuItem model"""
    
    list_display = [
        'name', 'canteen', 'category', 'price_display', 
        'food_type_display', 'prep_time', 'is_available', 'is_active'
    ]
    list_filter = ['canteen', 'category', 'food_type', 'is_available', 'is_active']
    search_fields = ['name', 'description']
    ordering = ['canteen', 'category', 'display_order']
    list_editable = ['is_available', 'is_active']
    
    fieldsets = (
        (None, {'fields': ('canteen', 'category', 'name', 'description', 'image')}),
        ('Pricing & Details', {'fields': ('price', 'food_type', 'prep_time')}),
        ('Display', {'fields': ('display_order',)}),
        ('Availability', {'fields': ('is_available', 'is_active')}),
    )
    
    def price_display(self, obj):
        return f'₹{obj.price}'
    price_display.short_description = 'Price'
    
    def food_type_display(self, obj):
        colors = {
            'veg': 'green',
            'non_veg': 'red',
            'egg': 'orange'
        }
        color = colors.get(obj.food_type, 'gray')
        return format_html(
            '<span style="color: {};">●</span> {}',
            color,
            obj.get_food_type_display()
        )
    food_type_display.short_description = 'Food Type'
