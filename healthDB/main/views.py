from django.shortcuts import render
from django.http import JsonResponse

# Create your views here.
def index(request):
    
    return render(request, 'main/index.html')

def api(request):
    if request.method == 'GET':
        return JsonResponse({'request':'get'})
    else:
        return JsonResponse({'request':request.method})