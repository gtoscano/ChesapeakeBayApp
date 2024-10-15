from django.urls import path, include

from .views import CreateEmailGroup, EmailGroupView, ListEmailGroups, UpdateEmailGroup, DeleteEmailGroup
from .views import CreateEmailTemplate, EmailTemplateView, ListEmailTemplates, UpdateEmailTemplate, DeleteEmailTemplate
from .views import CreateEmailMassive, EmailMassiveView, ListEmailMassives, UpdateEmailMassive, DeleteEmailMassive, DryRunEmailMassive
from .views import CreateEmailMassive, EmailMassiveView, ListEmailMassives, UpdateEmailMassive, DeleteEmailMassive, DryRunEmailMassive
from .views import CreateEmailInstant, EmailInstantView, ListEmailInstants, UpdateEmailInstant, DeleteEmailInstant, DryRunEmailInstant
from .views import CreateEmailGroups

urlpatterns = [
    path('create-groups/', CreateEmailGroups.as_view(), name='create-groups'),
    path('list-email-groups/', ListEmailGroups.as_view(), name='list_email_groups'),
    path('create-email-group/', CreateEmailGroup.as_view(), name='create_email_group'),
    path('update-email-group/<slug:slug>/', UpdateEmailGroup.as_view(), name='update_email_group'),
    path('delete-email-group/<slug:slug>/', DeleteEmailGroup.as_view(), name='delete_email_group'),
    path('email-groups/<slug:slug>/', EmailGroupView.as_view(), name='email_group'),
    path('list-email-templates/', ListEmailTemplates.as_view(), name='list_email_templates'),
    path('create-email-template/', CreateEmailTemplate.as_view(), name='create_email_template'),
    path('update-email-template/<slug:slug>/', UpdateEmailTemplate.as_view(), name='update_email_template'),
    path('delete-email-template/<slug:slug>/', DeleteEmailTemplate.as_view(), name='delete_email_template'),
    path('email-templates/<slug:slug>/', EmailTemplateView.as_view(), name='email_template'),

    path('list-email-massives/', ListEmailMassives.as_view(), name='list_email_massives'),
    path('create-email-massive/', CreateEmailMassive.as_view(), name='create_email_massive'),
    path('disabled-update-email-massive/<slug:slug>/', UpdateEmailMassive.as_view(), name='disabled_update_email_massive'),
    path('update-email-massive/<slug:slug>/', UpdateEmailMassive.as_view(), name='update_email_massive'),
    path('delete-email-massive/<slug:slug>/', DeleteEmailMassive.as_view(), name='delete_email_massive'),
    path('email-massives/<slug:slug>/', EmailMassiveView.as_view(), name='email_massive'),
    path('dry-run-email-massives/<slug:slug>/', DryRunEmailMassive.as_view(), name='dry_run_email_massive'),

    path('list-email-instants/', ListEmailInstants.as_view(), name='list_email_instants'),
    path('create-email-instant/', CreateEmailInstant.as_view(), name='create_email_instant'),
    path('disabled-update-email-instant/<int:pk>/', UpdateEmailInstant.as_view(), name='disabled_update_email_instant'),
    path('update-email-instant/<int:pk>/', UpdateEmailInstant.as_view(), name='update_email_instant'),
    path('delete-email-instant/<int:pk>/', DeleteEmailInstant.as_view(), name='delete_email_instant'),
    path('email-instants/<int:pk>/', EmailInstantView.as_view(), name='email_instant'),
    path('dry-run-email-instants/<int:pk>/', DryRunEmailInstant.as_view(), name='dry_run_email_instant'),
]
