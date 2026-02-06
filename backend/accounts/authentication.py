"""
Firebase Authentication for Django REST Framework
"""
import firebase_admin
from firebase_admin import auth, credentials
from django.conf import settings
from rest_framework import authentication, exceptions
from .models import User
import os


# Initialize Firebase Admin SDK
def initialize_firebase():
    """Initialize Firebase Admin SDK if not already initialized"""
    if not firebase_admin._apps:
        try:
            cred_path = settings.FIREBASE_CONFIG_PATH
            if os.path.exists(cred_path):
                cred = credentials.Certificate(str(cred_path))
                firebase_admin.initialize_app(cred)
            else:
                # Use environment variable for production
                firebase_admin.initialize_app()
        except Exception as e:
            print(f"Firebase initialization error: {e}")


class FirebaseAuthentication(authentication.BaseAuthentication):
    """
    Firebase ID Token authentication for DRF
    """
    
    def authenticate(self, request):
        """
        Authenticate the request and return a tuple of (user, token) or None.
        """
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        
        if not auth_header:
            return None
        
        # Check for Bearer token
        parts = auth_header.split()
        if parts[0].lower() != 'bearer' or len(parts) != 2:
            return None
        
        id_token = parts[1]
        
        try:
            # Initialize Firebase if needed
            initialize_firebase()
            
            # Verify the Firebase ID token
            decoded_token = auth.verify_id_token(id_token)
            firebase_uid = decoded_token['uid']
            email = decoded_token.get('email', '')
            name = decoded_token.get('name', '')
            picture = decoded_token.get('picture', '')
            
            # Get or create user
            user, created = User.objects.get_or_create(
                firebase_uid=firebase_uid,
                defaults={
                    'email': email,
                    'name': name,
                    'profile_picture': picture,
                }
            )
            
            # Update user info if changed
            if not created:
                updated = False
                if email and user.email != email:
                    user.email = email
                    updated = True
                if name and user.name != name:
                    user.name = name
                    updated = True
                if picture and user.profile_picture != picture:
                    user.profile_picture = picture
                    updated = True
                if updated:
                    user.save()
            
            return (user, decoded_token)
            
        except auth.ExpiredIdTokenError:
            raise exceptions.AuthenticationFailed('Firebase token has expired')
        except auth.InvalidIdTokenError:
            raise exceptions.AuthenticationFailed('Invalid Firebase token')
        except auth.RevokedIdTokenError:
            raise exceptions.AuthenticationFailed('Firebase token has been revoked')
        except Exception as e:
            raise exceptions.AuthenticationFailed(f'Authentication failed: {str(e)}')
    
    def authenticate_header(self, request):
        return 'Bearer'
