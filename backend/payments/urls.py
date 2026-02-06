"""
URL patterns for payments app
"""
from django.urls import path
from . import views

app_name = 'payments'

urlpatterns = [
    # Customer endpoints
    path('', views.PaymentListView.as_view(), name='payment-list'),
    path('<str:payment_id>/', views.PaymentDetailView.as_view(), name='payment-detail'),
    path('initiate/', views.initiate_payment, name='initiate'),
    path('confirm/', views.confirm_payment, name='confirm'),
    path('qr/<str:order_id>/', views.get_order_qr, name='order-qr'),
    
    # Manager endpoints
    path('verify-qr/', views.verify_qr, name='verify-qr'),
    path('confirm-qr/', views.confirm_qr_scan, name='confirm-qr'),
]
