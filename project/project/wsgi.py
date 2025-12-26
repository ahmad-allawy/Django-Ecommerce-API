import os
from django.core.wsgi import get_wsgi_application

# Use dev.py for development, prod.py for production
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "project.settings.dev")

application = get_wsgi_application()


# export DJANGO_SETTINGS_MODULE=project.project.settings.dev