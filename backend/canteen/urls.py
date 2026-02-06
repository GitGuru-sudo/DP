"""
URL patterns for canteen app
"""
from django.urls import path
from . import views

app_name = 'canteen'

urlpatterns = [
    # Public endpoints
    path('', views.CanteenListView.as_view(), name='canteen-list'),
    path('<int:pk>/', views.CanteenDetailView.as_view(), name='canteen-detail'),
    path('<int:canteen_id>/categories/', views.CategoryListView.as_view(), name='category-list'),
    path('categories/<int:pk>/', views.CategoryDetailView.as_view(), name='category-detail'),
    path('<int:canteen_id>/menu/', views.MenuItemListView.as_view(), name='menu-list'),
    path('menu/<int:pk>/', views.MenuItemDetailView.as_view(), name='menu-detail'),
    
    # Manager endpoints
    path('menu/<int:pk>/update/', views.ManagerMenuItemUpdateView.as_view(), name='menu-update'),
    path('menu/<int:pk>/toggle/', views.toggle_item_availability, name='menu-toggle'),
]
