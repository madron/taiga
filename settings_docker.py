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

MEDIA_ROOT = '/files/media'
STATIC_ROOT = '/files/static'
MEDIA_URL = '/media/'
STATIC_URL = '/static/'

from .local import *
