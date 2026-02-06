"""
Management command to create default admin user
"""
from django.core.management.base import BaseCommand
from accounts.models import User


class Command(BaseCommand):
    help = 'Create default admin user for DP Canteen'

    def add_arguments(self, parser):
        parser.add_argument(
            '--email',
            type=str,
            default='admin@123',
            help='Admin email address'
        )
        parser.add_argument(
            '--password',
            type=str,
            default='admin@password',
            help='Admin password'
        )
        parser.add_argument(
            '--name',
            type=str,
            default='Admin User',
            help='Admin name'
        )

    def handle(self, *args, **options):
        email = options['email']
        password = options['password']
        name = options['name']

        # Check if user already exists
        if User.objects.filter(email=email).exists():
            self.stdout.write(
                self.style.WARNING(f'Admin user with email "{email}" already exists.')
            )
            
            # Update password if needed
            user = User.objects.get(email=email)
            user.set_password(password)
            user.is_staff = True
            user.is_superuser = True
            user.is_active = True
            user.role = User.Role.ADMIN
            user.save()
            
            self.stdout.write(
                self.style.SUCCESS(f'Updated password for admin user "{email}"')
            )
            return

        # Create the admin user
        user = User.objects.create_superuser(
            email=email,
            password=password,
            name=name,
        )

        self.stdout.write(
            self.style.SUCCESS(f'Successfully created admin user:')
        )
        self.stdout.write(f'  Email: {email}')
        self.stdout.write(f'  Password: {password}')
        self.stdout.write(f'  Name: {name}')
        self.stdout.write(f'  Role: Admin')
