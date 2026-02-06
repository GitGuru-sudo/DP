"""
Serializers for canteen app
"""
from rest_framework import serializers
from .models import Canteen, Category, MenuItem


class MenuItemSerializer(serializers.ModelSerializer):
    """Serializer for MenuItem model"""
    
    category_name = serializers.CharField(source='category.name', read_only=True)
    
    class Meta:
        model = MenuItem
        fields = [
            'id', 'canteen', 'category', 'category_name', 'name', 
            'description', 'price', 'image', 'food_type', 
            'is_available', 'is_active', 'prep_time', 'display_order'
        ]
        read_only_fields = ['id']


class CategorySerializer(serializers.ModelSerializer):
    """Serializer for Category model"""
    
    items = MenuItemSerializer(many=True, read_only=True)
    items_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Category
        fields = [
            'id', 'canteen', 'name', 'description', 'image',
            'display_order', 'is_active', 'items', 'items_count'
        ]
        read_only_fields = ['id']
    
    def get_items_count(self, obj):
        return obj.items.filter(is_active=True, is_available=True).count()


class CategoryListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for category list"""
    
    items_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Category
        fields = ['id', 'name', 'description', 'image', 'display_order', 'items_count']
    
    def get_items_count(self, obj):
        return obj.items.filter(is_active=True, is_available=True).count()


class CanteenSerializer(serializers.ModelSerializer):
    """Serializer for Canteen model"""
    
    categories = CategoryListSerializer(many=True, read_only=True)
    is_open = serializers.BooleanField(read_only=True)
    
    class Meta:
        model = Canteen
        fields = [
            'id', 'name', 'description', 'location', 'image',
            'opening_time', 'closing_time', 'upi_id', 'upi_name',
            'is_active', 'is_open', 'categories'
        ]
        read_only_fields = ['id']


class CanteenListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for canteen list"""
    
    is_open = serializers.BooleanField(read_only=True)
    menu_items_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Canteen
        fields = [
            'id', 'name', 'description', 'location', 'image',
            'opening_time', 'closing_time', 'is_active', 'is_open',
            'menu_items_count'
        ]
    
    def get_menu_items_count(self, obj):
        return obj.menu_items.filter(is_active=True, is_available=True).count()
