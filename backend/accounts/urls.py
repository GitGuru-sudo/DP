"""
URL patterns for accounts app
"""
from django.urls import path
from . import views

app_name = 'accounts'

urlpatterns = [
    path('verify/', views.AuthVerifyView.as_view(), name='verify'),
    path('profile/', views.UserProfileView.as_view(), name='profile'),
    path('logout/', views.logout_view, name='logout'),
    path('managers/', views.ManagerListCreateView.as_view(), name='manager-list'),
    path('managers/<int:pk>/', views.ManagerDetailView.as_view(), name='manager-detail'),
]
