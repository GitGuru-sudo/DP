# DP Canteen Backend

Django REST API backend for the DP Canteen mobile application.

## Features

- Firebase Authentication verification
- Menu management
- Order management
- UPI payment processing
- AES-encrypted QR codes for order verification
- Role-based access control (Customer, Manager, Admin)

## Setup

### Prerequisites

- Python 3.10+
- PostgreSQL (for production)

### Installation

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Copy environment file:
```bash
cp .env.example .env
```

4. Edit `.env` with your configuration

5. Add Firebase Admin SDK credentials:
   - Download from Firebase Console
   - Save as `firebase-adminsdk.json` in the backend directory

6. Run migrations:
```bash
python manage.py migrate
```

7. Create admin user:
```bash
python manage.py create_admin
```

8. Run development server:
```bash
python manage.py runserver
```

## API Endpoints

### Authentication
- `POST /api/auth/verify/` - Verify Firebase token
- `GET /api/auth/profile/` - Get user profile
- `PUT /api/auth/profile/` - Update user profile

### Canteen
- `GET /api/canteen/` - List all canteens
- `GET /api/canteen/<id>/` - Get canteen details
- `GET /api/canteen/<id>/menu/` - Get canteen menu
- `GET /api/canteen/<id>/categories/` - Get menu categories

### Orders
- `GET /api/orders/` - List user orders
- `POST /api/orders/create/` - Create new order
- `GET /api/orders/<order_id>/` - Get order details
- `POST /api/orders/<order_id>/cancel/` - Cancel order

### Payments
- `POST /api/payments/initiate/` - Initiate UPI payment
- `POST /api/payments/confirm/` - Confirm payment
- `GET /api/payments/qr/<order_id>/` - Get order QR code

### Manager Endpoints
- `GET /api/orders/manager/list/` - List canteen orders
- `POST /api/orders/manager/<order_id>/status/` - Update order status
- `POST /api/payments/verify-qr/` - Verify scanned QR
- `POST /api/payments/confirm-qr/` - Confirm QR and order

## Deployment

### Render / Railway

1. Connect your GitHub repository
2. Set environment variables:
   - `DATABASE_URL` (PostgreSQL connection string)
   - `DJANGO_SECRET_KEY`
   - `AES_SECRET_KEY`
   - `DEBUG=False`
   - `ALLOWED_HOSTS`

3. Add Firebase Admin SDK as a secret file or use environment variable

## Admin Panel

Access the admin panel at `/admin/` with credentials:
- Email: admin@123
- Password: admin@password

## Security

- QR codes are AES-256 encrypted
- QR codes expire after 5 minutes (configurable)
- One-time QR usage
- Role-based access control
- Firebase token verification
