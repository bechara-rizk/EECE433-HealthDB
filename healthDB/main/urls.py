from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('api/', views.api, name='api'),
    path('api/home/', views.apihome, name='apihome'),
    path('alltables/', views.alltables, name='alltables'),
]