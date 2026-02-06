"""
Custom User Model for DP Canteen
"""
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


class UserManager(BaseUserManager):
    """Custom user manager"""
    
    def create_user(self, email, password=None, **extra_fields):
        """Create and save a regular user"""
        if not email:
            raise ValueError('Users must have an email address')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        if password:
            user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, email, password=None, **extra_fields):
        """Create and save a superuser"""
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('role', User.Role.ADMIN)
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
        
        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Custom User model with role-based access"""
    
    class Role(models.TextChoices):
        CUSTOMER = 'customer', 'Customer'
        MANAGER = 'manager', 'Canteen Manager'
        ADMIN = 'admin', 'Admin'
    
    email = models.EmailField(unique=True)
    firebase_uid = models.CharField(max_length=128, unique=True, null=True, blank=True)
    name = models.CharField(max_length=255, blank=True)
    phone = models.CharField(max_length=15, blank=True)
    profile_picture = models.URLField(max_length=500, blank=True)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.CUSTOMER)
    
    # For canteen managers - link to their canteen
    managed_canteen = models.ForeignKey(
        'canteen.Canteen',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='managers'
    )
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(default=timezone.now)
    last_login = models.DateTimeField(null=True, blank=True)
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []
    
    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['-date_joined']
    
    def __str__(self):
        return self.email
    
    @property
    def is_customer(self):
        return self.role == self.Role.CUSTOMER
    
    @property
    def is_manager(self):
        return self.role == self.Role.MANAGER
    
    @property
    def is_admin_user(self):
        return self.role == self.Role.ADMIN
