"""
Views for accounts app
"""
from rest_framework import generics, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import User
from .serializers import UserSerializer, UserProfileSerializer, ManagerSerializer
from .permissions import IsAdmin


class AuthVerifyView(APIView):
    """Verify Firebase authentication and return user details"""
    
    def get(self, request):
        """Get current user details"""
        serializer = UserSerializer(request.user)
        return Response({
            'success': True,
            'user': serializer.data
        })
    
    def post(self, request):
        """
        Verify Firebase token and create/update user
        This endpoint is called after Firebase authentication
        """
        serializer = UserSerializer(request.user)
        return Response({
            'success': True,
            'message': 'Authentication successful',
            'user': serializer.data
        })


class UserProfileView(generics.RetrieveUpdateAPIView):
    """Get and update user profile"""
    serializer_class = UserProfileSerializer
    
    def get_object(self):
        return self.request.user


class ManagerListCreateView(generics.ListCreateAPIView):
    """List and create canteen managers (Admin only)"""
    serializer_class = ManagerSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    
    def get_queryset(self):
        return User.objects.filter(role=User.Role.MANAGER)
    
    def perform_create(self, serializer):
        serializer.save(role=User.Role.MANAGER)


class ManagerDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Retrieve, update, delete canteen managers (Admin only)"""
    serializer_class = ManagerSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin]
    
    def get_queryset(self):
        return User.objects.filter(role=User.Role.MANAGER)


@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def logout_view(request):
    """
    Logout endpoint - mainly for record keeping
    Actual logout is handled by Firebase on the client
    """
    return Response({
        'success': True,
        'message': 'Logged out successfully'
    })
