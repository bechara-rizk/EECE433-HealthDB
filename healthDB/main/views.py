from django.shortcuts import render
from django.http import JsonResponse
from .dbrequests import sendQuery, callFunction, callProcedure

# Create your views here.
def index(request):
    
    return render(request, 'main/index.html')

def api(request):
    if request.method == 'GET':
        return JsonResponse({'request':'get'})
    else:
        return JsonResponse({'request':request.method})
    
def apihome(request):
    if request.method == 'GET':
        response=dict()

        customers=sendQuery("SELECT COUNT(ssn) FROM customer_table;")
        response['customers']=customers[0][0]

        employees=sendQuery("SELECT COUNT(ssn) FROM employee_table;")
        response['employees']=employees[0][0]

        doctors=sendQuery("SELECT COUNT(phone) FROM doctor_table;")
        response['doctors']=doctors[0][0]

        hospitals=sendQuery("SELECT COUNT(id) FROM hospital;")
        response['hospitals']=hospitals[0][0]

        labs=sendQuery("SELECT COUNT(id) FROM lab;")
        response['labs']=labs[0][0]

        departments=sendQuery("SELECT COUNT(name) FROM department;")
        response['departments']=departments[0][0]

        plans=sendQuery("SELECT count(distinct name) FROM insurance_plan;")
        response['plans']=plans[0][0]

        return JsonResponse(response)
    
    return JsonResponse(dict())


def alltables(request):
    context=dict()


    
    return render(request, 'main/all_tables.html', context)