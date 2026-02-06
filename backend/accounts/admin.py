"""
Admin configuration for accounts app
"""
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Custom admin for User model"""
    
    list_display = ['email', 'name', 'role', 'managed_canteen', 'is_active', 'date_joined']
    list_filter = ['role', 'is_active', 'is_staff', 'date_joined']
    search_fields = ['email', 'name', 'phone']
    ordering = ['-date_joined']
    
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('name', 'phone', 'profile_picture', 'firebase_uid')}),
        ('Role & Canteen', {'fields': ('role', 'managed_canteen')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'name', 'role', 'is_active', 'is_staff'),
        }),
    )
    
    readonly_fields = ['date_joined', 'last_login']


# Customize admin site
admin.site.site_header = 'DP Canteen Administration'
admin.site.site_title = 'DP Canteen Admin'
admin.site.index_title = 'Welcome to DP Canteen Admin Panel'
