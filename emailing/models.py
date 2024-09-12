from django.db import models

# Create your models here.


from django.contrib import admin
from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models
from uuid import uuid4
from api.validators import validate_file_size
from datetime import datetime, timedelta
from django.utils import timezone

class Email(models.Model):
    STATUS_PENDING = 'P'
    STATUS_COMPLETE = 'C'
    STATUS_FAILED = 'F'
    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending'),
        (STATUS_COMPLETE, 'Complete'),
        (STATUS_FAILED, 'Failed')
    ]
    recipient = models.JSONField(default=list, null=False)
    template_name = models.CharField(max_length=255)
    context = models.JSONField(default=dict, blank=True)
    status = models.CharField(max_length=1, choices=STATUS_CHOICES, default=STATUS_PENDING)
    error = models.TextField(null=True, blank=True)
    sent = models.DateTimeField(null=True, blank=True)

