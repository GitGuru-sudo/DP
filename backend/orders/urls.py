"""
URL patterns for orders app
"""
from django.urls import path
from . import views

app_name = 'orders'

urlpatterns = [
    # Customer endpoints
    path('', views.OrderListView.as_view(), name='order-list'),
    path('create/', views.OrderCreateView.as_view(), name='order-create'),
    path('<str:order_id>/', views.OrderDetailView.as_view(), name='order-detail'),
    path('<str:order_id>/cancel/', views.cancel_order, name='order-cancel'),
    
    # Manager endpoints
    path('manager/list/', views.ManagerOrderListView.as_view(), name='manager-order-list'),
    path('manager/<str:order_id>/status/', views.update_order_status, name='order-status-update'),
]
