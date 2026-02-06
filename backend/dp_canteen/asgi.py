"""
ASGI config for DP Canteen project.
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dp_canteen.settings')

application = get_asgi_application()
