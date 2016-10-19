from .common import *

DEBUG = False

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'postgres',
        'USER': 'postgres',
        'PASSWORD': 'postgres',
        'HOST': 'db',
        'PORT': '5432',
    }
}

MEDIA_ROOT = '/media'
STATIC_ROOT = '/static'
MEDIA_URL = '/media/'
STATIC_URL = '/static/'
