"""
Custom permissions for DP Canteen
"""
from rest_framework import permissions


class IsAdmin(permissions.BasePermission):
    """Permission check for admin users"""
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            (request.user.role == 'admin' or request.user.is_superuser)
        )


class IsManager(permissions.BasePermission):
    """Permission check for canteen managers"""
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == 'manager'
        )


class IsCustomer(permissions.BasePermission):
    """Permission check for customers"""
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role == 'customer'
        )


class IsManagerOrAdmin(permissions.BasePermission):
    """Permission check for managers or admins"""
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            (request.user.role in ['manager', 'admin'] or request.user.is_superuser)
        )


class IsOwnerOrAdmin(permissions.BasePermission):
    """Permission check for object owner or admin"""
    
    def has_object_permission(self, request, view, obj):
        if request.user.is_superuser or request.user.role == 'admin':
            return True
        return obj.user == request.user
