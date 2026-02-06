"""
AES Encryption utilities for QR codes
"""
import json
import base64
from datetime import datetime, timedelta
from django.conf import settings
from django.utils import timezone
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import hashlib


class QREncryption:
    """AES encryption for QR code data"""
    
    BLOCK_SIZE = 16
    
    def __init__(self):
        # Get key from settings and ensure it's 32 bytes for AES-256
        key = settings.AES_SECRET_KEY
        if isinstance(key, str):
            key = key.encode('utf-8')
        # Hash the key to ensure consistent 32 bytes
        self.key = hashlib.sha256(key).digest()
    
    def encrypt(self, data: dict) -> str:
        """
        Encrypt data dictionary to base64 encoded string
        """
        try:
            # Convert dict to JSON string
            json_data = json.dumps(data, default=str)
            
            # Create cipher with random IV
            cipher = AES.new(self.key, AES.MODE_CBC)
            
            # Pad and encrypt
            padded_data = pad(json_data.encode('utf-8'), self.BLOCK_SIZE)
            encrypted = cipher.encrypt(padded_data)
            
            # Combine IV + encrypted data and encode to base64
            combined = cipher.iv + encrypted
            return base64.b64encode(combined).decode('utf-8')
        except Exception as e:
            raise ValueError(f"Encryption failed: {str(e)}")
    
    def decrypt(self, encrypted_data: str) -> dict:
        """
        Decrypt base64 encoded string back to dictionary
        """
        try:
            # Decode from base64
            combined = base64.b64decode(encrypted_data)
            
            # Extract IV (first 16 bytes) and encrypted data
            iv = combined[:self.BLOCK_SIZE]
            encrypted = combined[self.BLOCK_SIZE:]
            
            # Create cipher and decrypt
            cipher = AES.new(self.key, AES.MODE_CBC, iv)
            decrypted = unpad(cipher.decrypt(encrypted), self.BLOCK_SIZE)
            
            # Parse JSON
            return json.loads(decrypted.decode('utf-8'))
        except Exception as e:
            raise ValueError(f"Decryption failed: {str(e)}")


def generate_qr_data(order) -> dict:
    """
    Generate QR code data for an order
    """
    expiry_minutes = settings.QR_EXPIRY_MINUTES
    expires_at = timezone.now() + timedelta(minutes=expiry_minutes)
    
    data = {
        'order_id': order.order_id,
        'user_id': order.user.id,
        'canteen_id': order.canteen.id,
        'amount': str(order.total_amount),
        'timestamp': timezone.now().isoformat(),
        'expires_at': expires_at.isoformat(),
    }
    
    return data, expires_at


def create_encrypted_qr(order) -> tuple:
    """
    Create encrypted QR data for an order
    Returns: (encrypted_data, expires_at)
    """
    data, expires_at = generate_qr_data(order)
    encryption = QREncryption()
    encrypted_data = encryption.encrypt(data)
    return encrypted_data, expires_at


def verify_qr_data(encrypted_data: str, manager_canteen_id: int = None) -> dict:
    """
    Verify and decrypt QR code data
    Returns verification result with status and data
    """
    from orders.models import Order
    
    try:
        # Decrypt the data
        encryption = QREncryption()
        data = encryption.decrypt(encrypted_data)
        
        # Check expiry
        expires_at = datetime.fromisoformat(data['expires_at'])
        if timezone.is_naive(expires_at):
            expires_at = timezone.make_aware(expires_at)
        
        if timezone.now() > expires_at:
            return {
                'valid': False,
                'error': 'QR code has expired',
                'code': 'expired'
            }
        
        # Get the order
        try:
            order = Order.objects.get(order_id=data['order_id'])
        except Order.DoesNotExist:
            return {
                'valid': False,
                'error': 'Order not found',
                'code': 'not_found'
            }
        
        # Check if order belongs to manager's canteen
        if manager_canteen_id and order.canteen.id != manager_canteen_id:
            return {
                'valid': False,
                'error': 'Order does not belong to your canteen',
                'code': 'wrong_canteen'
            }
        
        # Check payment status
        if order.status == Order.Status.PENDING:
            return {
                'valid': False,
                'error': 'Payment not completed',
                'code': 'unpaid'
            }
        
        # Check if QR already used
        if order.qr_code_used:
            return {
                'valid': False,
                'error': 'QR code already used',
                'code': 'already_used',
                'used_at': order.qr_code_used_at.isoformat() if order.qr_code_used_at else None
            }
        
        # Check order status
        if order.status in [Order.Status.COMPLETED, Order.Status.CANCELLED]:
            return {
                'valid': False,
                'error': f'Order is {order.get_status_display()}',
                'code': 'invalid_status'
            }
        
        # All checks passed
        return {
            'valid': True,
            'order': order,
            'data': data
        }
    
    except ValueError as e:
        return {
            'valid': False,
            'error': str(e),
            'code': 'decryption_failed'
        }
    except Exception as e:
        return {
            'valid': False,
            'error': f'Verification failed: {str(e)}',
            'code': 'error'
        }
