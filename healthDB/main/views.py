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

    # employee_table
    employees=sendQuery("SELECT ssn, first_name, last_name, phone, extension, date_hired, address, salary, dob, su_ssn, d_name FROM employee_table;")
    context['employees']=employees
    context['employeesTitles']=['SSN', 'First Name', 'Last Name', 'Phone', 'Extension', 'Date Hired', 'Address', 'Salary', 'Date of Birth', 'Supervisor SSN', 'Department Name']

    # department_table
    departements=sendQuery("SELECT name, extension, floor_number, manager_ssn FROM department;")
    context['departments']=departements
    context['departmentsTitles']=['Name', 'Extension', 'Floor Number', 'Manager SSN']

    # broker_table
    brokers=sendQuery("SELECT phone, start_date, end_date, address, commission, name FROM broker_table;")
    context['brokers']=brokers
    context['brokersTitles']=['Phone', 'Start Date', 'End Date', 'Address', 'Commission', 'Name']

    # customer_table
    customers=sendQuery("SELECT ssn, first_name, last_name, phone, dob, address, b_phone, e_ssn, date_of_assignment FROM customer_table;")
    context['customers']=customers
    context['customersTitles']=['SSN', 'First Name', 'Last Name', 'Phone', 'Date of Birth', 'Address', 'Broker Phone', 'Employee SSN', 'Date of Assignment']

    # family_member_table
    family_members=sendQuery("SELECT c_ssn, first_name, last_name, dob, relation FROM family_member_table;")
    context['family_members']=family_members
    context['family_membersTitles']=['Customer SSN', 'First Name', 'Last Name', 'Date of Birth', 'Relation']

    # lab
    labs=sendQuery("SELECT id, name, representative, phone FROM lab;")
    context['labs']=labs
    context['labsTitles']=['ID', 'Name', 'Representative', 'Phone']

    # hospital
    hospitals=sendQuery("SELECT id, phone, name, representative, location FROM hospital;")
    context['hospitals']=hospitals
    context['hospitalsTitles']=['ID', 'Phone', 'Name', 'Representative', 'Location']

    # insurance_plan
    plans=sendQuery("SELECT id, type, name, description, price, start_age, end_age, percentage_paid, time_limit, financial_limit FROM insurance_plan;")
    context['plans']=plans
    context['plansTitles']=['ID', 'Type', 'Name', 'Description', 'Price', 'Start Age', 'End Age', 'Percentage Paid', 'Time Limit', 'Financial Limit']

    # doctor_table
    doctors=sendQuery("SELECT phone, specialization, first_name, last_name, work_start, nb_of_malpractices FROM doctor_table;")
    context['doctors']=doctors
    context['doctorsTitles']=['Phone', 'Specialization', 'First Name', 'Last Name', 'Work Start', 'Number of Malpractices']

    # bill
    bills=sendQuery("SELECT id, total_amount, date, days_to_pay FROM bill;")
    context['bills']=bills
    context['billsTitles']=['ID', 'Total Amount', 'Date', 'Days to Pay']

    # pays
    pays=sendQuery("SELECT c_ssn, b_id, date, amount_paid FROM pays;")
    context['pays']=pays
    context['paysTitles']=['Customer SSN', 'Bill ID', 'Date', 'Amount Paid']

    # insures
    insures=sendQuery("SELECT plan_identifier, c_ssn, nb_of_plans, date_activated, billed FROM insures;")
    context['insures']=insures
    context['insuresTitles']=['Plan Identifier', 'Customer SSN', 'Number of Plans', 'Date Activated', 'Billed']

    # covers
    covers=sendQuery("SELECT plan_identifier, h_id FROM covers;")
    context['covers']=covers
    context['coversTitles']=['Plan Identifier', 'Hospital ID']

    # works_in
    works_in=sendQuery("SELECT d_phone, h_id FROM works_in;")
    context['works_in']=works_in
    context['works_inTitles']=['Doctor Phone', 'Hospital ID']

    # accepts
    accepts=sendQuery("SELECT plan_identifier, lab_id FROM accepts;")
    context['accepts']=accepts
    context['acceptsTitles']=['Plan Identifier', 'Lab ID']

    # tests
    tests=sendQuery("SELECT c_ssn, lab_id, description, price, date FROM tests;")
    context['tests']=tests
    context['testsTitles']=['Customer SSN', 'Lab ID', 'Description', 'Price', 'Date']

    # lab_location
    lab_locations=sendQuery("SELECT lab_id, location FROM lab_location;")
    context['lab_locations']=lab_locations
    context['lab_locationsTitles']=['Lab ID', 'Location']

    # customer_diseases
    customer_diseases=sendQuery("SELECT c_ssn, chronic_disease FROM customer_diseases;")
    context['customer_diseases']=customer_diseases
    context['customer_diseasesTitles']=['Customer SSN', 'Chronic Disease']

    # customer_exclusions
    customer_exclusions=sendQuery("SELECT c_ssn, exclusion FROM customer_exclusions;")
    context['customer_exclusions']=customer_exclusions
    context['customer_exclusionsTitles']=['Customer SSN', 'Exclusion']

    # f_member_diseases
    f_member_diseases=sendQuery("SELECT c_ssn, f_first_name, f_last_name, chronic_disease FROM f_member_diseases;")
    context['f_member_diseases']=f_member_diseases
    context['f_member_diseasesTitles']=['Customer SSN', 'First Name', 'Last Name', 'Chronic Disease']

    # operates_on
    operates_on=sendQuery("SELECT d_phone, h_id, c_ssn, date, description, price FROM operates_on;")
    context['operates_on']=operates_on
    context['operates_onTitles']=['Doctor Phone', 'Hospital ID', 'Customer SSN', 'Date', 'Description', 'Price']
    
    return render(request, 'main/all_tables.html', context)