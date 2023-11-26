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
    path('viewdep/', views.viewdep, name='viewdep'),
    path('viewemp/', views.viewemp, name='viewemp'),
    path('viewbro/', views.viewbro, name='viewbro'),
    path('viewcus/', views.viewcus, name='viewcus'),
    path('viewdoc/', views.viewdoc, name='viewdoc'),
    path('viewhos/', views.viewhos, name='viewhos'),
    path('viewlab/', views.viewlab, name='viewlab'),
    path('viewins/', views.viewins, name='viewins'),
]