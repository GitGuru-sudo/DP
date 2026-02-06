"""
WSGI config for DP Canteen project.
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dp_canteen.settings')

application = get_wsgi_application()
