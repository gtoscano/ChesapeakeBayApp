import os 
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'cast.settings')

celery = Celery('cast')
celery.config_from_object('django.conf:settings', namespace='celery')
celery.autodiscover_tasks()
