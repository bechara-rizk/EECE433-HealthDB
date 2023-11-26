from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('api/', views.api, name='api'),
    path('api/home/', views.apihome, name='apihome'),
    path('alltables/', views.alltables, name='alltables'),
    path('newemployee/', views.newemployee, name='newemployee'),
    path('newbroker/', views.newbroker, name='newbroker'),
    path('newcustomer/', views.newcustomer, name='newcustomer'),
    path('newfamilymember/', views.newfamilymember, name='newfamilymember'),
    path('newdoctor/', views.newdoctor, name='newdoctor'),
]