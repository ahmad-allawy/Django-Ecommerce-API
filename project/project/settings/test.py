from .base import *

SECRET_KEY = "test-only-key"
DEBUG = True

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

PAYMOB_API_KEY = ""
PAYMOB_IFRAME_ID = ""
PAYMOB_INTEGRATION_ID = ""
PAYMOB_HMAC_SECRET = ""
PAYMOB_CALLBACK_SECRET = ""