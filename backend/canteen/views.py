"""
Views for canteen app
"""
from rest_framework import generics, permissions, status, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Canteen, Category, MenuItem
from .serializers import (
    CanteenSerializer, CanteenListSerializer,
    CategorySerializer, CategoryListSerializer,
    MenuItemSerializer
)
from accounts.permissions import IsAdmin, IsManagerOrAdmin


class CanteenListView(generics.ListAPIView):
    """List all active canteens"""
    serializer_class = CanteenListSerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        return Canteen.objects.filter(is_active=True)


class CanteenDetailView(generics.RetrieveAPIView):
    """Get canteen details"""
    serializer_class = CanteenSerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        return Canteen.objects.filter(is_active=True)


class CategoryListView(generics.ListAPIView):
    """List categories for a canteen"""
    serializer_class = CategoryListSerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        canteen_id = self.kwargs.get('canteen_id')
        return Category.objects.filter(
            canteen_id=canteen_id,
            is_active=True
        )


class CategoryDetailView(generics.RetrieveAPIView):
    """Get category with its menu items"""
    serializer_class = CategorySerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        return Category.objects.filter(is_active=True)


class MenuItemListView(generics.ListAPIView):
    """List menu items for a canteen"""
    serializer_class = MenuItemSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['price', 'name', 'display_order']
    
    def get_queryset(self):
        canteen_id = self.kwargs.get('canteen_id')
        queryset = MenuItem.objects.filter(
            canteen_id=canteen_id,
            is_active=True,
            is_available=True
        )
        
        # Filter by category if provided
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        
        # Filter by food type if provided
        food_type = self.request.query_params.get('food_type')
        if food_type:
            queryset = queryset.filter(food_type=food_type)
        
        return queryset


class MenuItemDetailView(generics.RetrieveAPIView):
    """Get menu item details"""
    serializer_class = MenuItemSerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        return MenuItem.objects.filter(is_active=True)


# Manager views for updating menu items
class ManagerMenuItemUpdateView(generics.UpdateAPIView):
    """Update menu item availability (Manager only)"""
    serializer_class = MenuItemSerializer
    permission_classes = [permissions.IsAuthenticated, IsManagerOrAdmin]
    
    def get_queryset(self):
        user = self.request.user
        if user.is_superuser or user.role == 'admin':
            return MenuItem.objects.all()
        # Managers can only update their canteen's items
        if user.managed_canteen:
            return MenuItem.objects.filter(canteen=user.managed_canteen)
        return MenuItem.objects.none()


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated, IsManagerOrAdmin])
def toggle_item_availability(request, pk):
    """Toggle menu item availability"""
    try:
        user = request.user
        if user.is_superuser or user.role == 'admin':
            item = MenuItem.objects.get(pk=pk)
        elif user.managed_canteen:
            item = MenuItem.objects.get(pk=pk, canteen=user.managed_canteen)
        else:
            return Response(
                {'error': 'You do not have permission to update this item'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        item.is_available = not item.is_available
        item.save()
        
        return Response({
            'success': True,
            'message': f'Item {"enabled" if item.is_available else "disabled"} successfully',
            'is_available': item.is_available
        })
    except MenuItem.DoesNotExist:
        return Response(
            {'error': 'Menu item not found'},
            status=status.HTTP_404_NOT_FOUND
        )
