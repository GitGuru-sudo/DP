"""
Serializers for accounts app
"""
from rest_framework import serializers
from .models import User


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model"""
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'name', 'phone', 'profile_picture',
            'role', 'is_active', 'date_joined'
        ]
        read_only_fields = ['id', 'email', 'date_joined']


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for user profile updates"""
    
    class Meta:
        model = User
        fields = ['name', 'phone', 'profile_picture']


class ManagerSerializer(serializers.ModelSerializer):
    """Serializer for canteen managers (admin view)"""
    managed_canteen_name = serializers.CharField(
        source='managed_canteen.name', 
        read_only=True
    )
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'name', 'phone', 'profile_picture',
            'role', 'managed_canteen', 'managed_canteen_name',
            'is_active', 'date_joined'
        ]
        read_only_fields = ['id', 'date_joined']
