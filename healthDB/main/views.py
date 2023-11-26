from django.shortcuts import render
from django.http import JsonResponse
from .dbrequests import sendQuery, callFunction, callProcedure
import re
from json import loads
import datetime

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

def newemployee(request):
    ssns=sendQuery("SELECT ssn FROM employee_table;")
    ssns=[ssn[0] for ssn in ssns]
    departments=sendQuery("SELECT name FROM department;")
    departments=[department[0] for department in departments]

    context=dict()
    context['ssns']=ssns
    context['departments']=departments

    if request.method == 'GET':

        return render(request, 'main/new_employee.html', context)

    if request.method == 'POST':
        ssn=request.POST.get('ssn')
        first_name=request.POST.get('first_name')
        last_name=request.POST.get('last_name')
        phone=request.POST.get('phone')
        extension=request.POST.get('ext')
        date_hired=request.POST.get('date_hired')
        address=request.POST.get('address')
        salary=request.POST.get('salary')
        dob=request.POST.get('dob')
        su_ssn=request.POST.get('su_ssn')
        d_name=request.POST.get('dep')

        # check that all values are filled
        if not ssn or not first_name or not last_name or not phone or not date_hired or not address or not salary or not dob or not su_ssn or not d_name:
            context['error']='All fields must be filled'
            return render(request, 'main/new_employee.html', context)
        
        # check that ssn is unique and a number and not negative
        try:
            ssn=int(ssn)
            if ssn<0 or ssn in ssns:
                raise Exception()
        except:
            context['error']='SSN must be a unique positive number'
            return render(request, 'main/new_employee.html', context)
        
        # check that su_ssn is valid and a number or null
        try:
            if su_ssn=='Null':
                pass
            else:
                su_ssn=int(su_ssn)
                if su_ssn not in ssns:
                    raise Exception()
        except:
            context['error']='Supervisor SSN must be a valid number or null'
            return render(request, 'main/new_employee.html', context)
        
        # check that d_name is valid
        if d_name not in departments:
            context['error']='Department does not exist'
            return render(request, 'main/new_employee.html', context)
        
        # check that salary is a number and not negative
        try:
            salary=int(salary)
            if salary<0:
                raise Exception()
        except:
            context['error']='Salary must be a positive number'
            return render(request, 'main/new_employee.html', context)
        
        # check that extension is a number and not negative or null
        try:
            if not extension:
                extension='Null'
            else:
                extension=int(extension)
                if extension<0:
                    raise Exception()
        except:
            context['error']='Extension must be a positive number or null'
            return render(request, 'main/new_employee.html', context)
        
        # check that phone is a number and not negative
        try:
            phone=int(phone)
            if phone<0:
                raise Exception()
        except:
            context['error']='Phone must be a positive number'
            return render(request, 'main/new_employee.html', context)
        
        # regex to check format of date (YYYY-MM-DD)
        date_regex=re.compile(r'^\d{4}-\d{2}-\d{2}$')
        if not date_regex.match(date_hired):
            context['error']='Date hired must be in the format YYYY-MM-DD'
            return render(request, 'main/new_employee.html', context)
        
        if not date_regex.match(dob):
            context['error']='Date of birth must be in the format YYYY-MM-DD'
            return render(request, 'main/new_employee.html', context)
        
        # insert into database
        sendQuery(f"INSERT INTO employee_table (ssn, first_name, last_name, phone, extension, date_hired, address, salary, dob, su_ssn, d_name) VALUES ({ssn}, '{first_name}', '{last_name}', {phone}, {extension}, '{date_hired}', '{address}', {salary}, '{dob}', {su_ssn}, '{d_name}');")
        context['success']='Employee added successfully'
        return render(request, 'main/new_employee.html', context)

def newbroker(request):
    phones=sendQuery("SELECT phone FROM broker_table;")
    phones=[phone[0] for phone in phones]

    context=dict()

    if request.method == 'GET':

        return render(request, 'main/new_broker.html', context)

    if request.method == 'POST':
        phone=request.POST.get('phone')
        start_date=request.POST.get('start_date')
        address=request.POST.get('address')
        commission=request.POST.get('commission')
        name=request.POST.get('name')

        # check that all values are filled
        if not phone or not start_date or not address or not commission or not name:
            context['error']='All fields must be filled'
            return render(request, 'main/new_broker.html', context)
        
        # check that phone is unique and a number and not negative
        try:
            phone=int(phone)
            if phone<0 or phone in phones:
                raise Exception()
        except:
            context['error']='Phone must be a unique positive number'
            return render(request, 'main/new_broker.html', context)
        
        # check that commission is a number and not negative
        try:
            commission=int(commission)
            if commission<=0 or commission>=20:
                raise Exception()
        except:
            context['error']='Commission must be a positive number between 0 and 20 (exclusive)'
            return render(request, 'main/new_broker.html', context)
        
        # regex to check format of date (YYYY-MM-DD)
        date_regex=re.compile(r'^\d{4}-\d{2}-\d{2}$')
        if not date_regex.match(start_date):
            context['error']='Start date must be in the format YYYY-MM-DD'
            return render(request, 'main/new_broker.html', context)
        
        # insert into database
        sendQuery(f"INSERT INTO broker_table (phone, start_date, address, commission, name) VALUES ({phone}, '{start_date}', '{address}', {commission}, '{name}');")
        context['success']='Broker added successfully'
        return render(request, 'main/new_broker.html', context)
    
def newcustomer(request):
    ssns=sendQuery("SELECT ssn FROM customer_table;")
    ssns=[ssn[0] for ssn in ssns]
    brokers=sendQuery("SELECT phone FROM broker_table;")
    brokers=[broker[0] for broker in brokers]
    employees=sendQuery("SELECT ssn FROM employee_table WHERE d_name='Customer Service';")
    employees=[employee[0] for employee in employees]

    context=dict()
    context['brokers']=brokers
    context['employees']=employees

    if request.method == 'GET':

        return render(request, 'main/new_customer.html', context)

    if request.method == 'POST':
        ssn=request.POST.get('ssn')
        first_name=request.POST.get('first_name')
        last_name=request.POST.get('last_name')
        phone=request.POST.get('phone')
        dob=request.POST.get('dob')
        address=request.POST.get('address')
        b_phone=request.POST.get('broker')
        e_ssn=request.POST.get('essn')
        date_of_assignment=request.POST.get('assignment')

        # check that all values are filled
        if not ssn or not first_name or not last_name or not phone or not dob or not address or not e_ssn or not date_of_assignment:
            context['error']='All fields must be filled'
            return render(request, 'main/new_customer.html', context)
        
        # check that ssn is unique and a number and not negative
        try:
            ssn=int(ssn)
            if ssn<0 or ssn in ssns:
                raise Exception()
        except:
            context['error']='SSN must be a unique positive number'
            return render(request, 'main/new_customer.html', context)
        
        # check that b_phone is valid and a number
        try:
            if b_phone=='Null':
                pass
            else:
                b_phone=int(b_phone)
                if b_phone<0:
                    raise Exception()
        except:
            context['error']='Broker phone must be a valid broker\'s phone number'
            return render(request, 'main/new_customer.html', context)
        
        # check that e_ssn is valid and a number
        try:
            e_ssn=int(e_ssn)
            if e_ssn not in employees:
                raise Exception()
        except:
            context['error']='Employee SSN must be a valid number'
            return render(request, 'main/new_customer.html', context)
        
        # check that phone is a number and not negative
        try:
            phone=int(phone)
            if phone<0:
                raise Exception()
        except:
            context['error']='Phone must be a positive number'
            return render(request, 'main/new_customer.html', context)
        
        # regex to check format of date (YYYY-MM-DD)
        date_regex=re.compile(r'^\d{4}-\d{2}-\d{2}$')
        if not date_regex.match(dob):
            context['error']='Date of birth must be in the format YYYY-MM-DD'
            return render(request, 'main/new_customer.html', context)
        
        if not date_regex.match(date_of_assignment):
            context['error']='Date of assignment must be in the format YYYY-MM-DD'
            return render(request, 'main/new_customer.html', context)
        
        # insert into database
        sendQuery(f"INSERT INTO customer_table (ssn, first_name, last_name, phone, dob, address, b_phone, e_ssn, date_of_assignment) VALUES ({ssn}, '{first_name}', '{last_name}', {phone}, '{dob}', '{address}', {b_phone}, {e_ssn}, '{date_of_assignment}');")
        context['success']='Customer added successfully'
        return render(request, 'main/new_customer.html', context)
    
def newfamilymember(request):
    ssns=sendQuery("SELECT ssn FROM customer_table;")
    ssns=[ssn[0] for ssn in ssns]

    context=dict()

    if request.method == 'GET':
        context['ssns']=ssns
        return render(request, 'main/new_fam_member.html', context)

    if request.method == 'POST':
        c_ssn=request.POST.get('cssn')
        first_name=request.POST.get('first_name')
        last_name=request.POST.get('last_name')
        dob=request.POST.get('dob')
        relation=request.POST.get('relation')

        # check that all values are filled
        if not c_ssn or not first_name or not last_name or not dob or not relation:
            context['error']='All fields must be filled'
            return render(request, 'main/new_fam_member.html', context)
        
        # check that c_ssn is valid and a number
        try:
            c_ssn=int(c_ssn)
            if c_ssn not in ssns:
                raise Exception()
        except:
            context['error']='Customer SSN must be a valid number'
            return render(request, 'main/new_fam_member.html', context)
        
        # regex to check format of date (YYYY-MM-DD)
        date_regex=re.compile(r'^\d{4}-\d{2}-\d{2}$')
        if not date_regex.match(dob):
            context['error']='Date of birth must be in the format YYYY-MM-DD'
            return render(request, 'main/new_fam_member.html', context)
        
        # insert into database
        sendQuery(f"INSERT INTO family_member_table (c_ssn, first_name, last_name, dob, relation) VALUES ({c_ssn}, '{first_name}', '{last_name}', '{dob}', '{relation}');")
        context['success']='Family member added successfully'
        return render(request, 'main/new_fam_member.html', context)
    
def newdoctor(request):
    phones=sendQuery("SELECT phone FROM doctor_table;")
    phones=[phone[0] for phone in phones]
    hospitals=sendQuery("SELECT id,name FROM hospital;")
    hospitalids=[hospital[0] for hospital in hospitals]

    context=dict()
    context['hospitals']=hospitals

    if request.method == 'GET':

        return render(request, 'main/new_doctor.html', context)

    if request.method == 'POST':
        phone=request.POST.get('phone')
        specialization=request.POST.get('spec')
        first_name=request.POST.get('first_name')
        last_name=request.POST.get('last_name')
        work_start=request.POST.get('workstart')
        nb_of_malpractices=request.POST.get('malp')
        h_id=request.POST.get('hospital')

        # check that all values are filled
        if not phone or not specialization or not first_name or not last_name or not work_start or not nb_of_malpractices or not h_id:
            context['error']='All fields must be filled'
            return render(request, 'main/new_doctor.html', context)
        
        # check that phone is unique and a number and not negative
        try:
            phone=int(phone)
            if phone<0 or phone in phones:
                raise Exception()
        except:
            context['error']='Phone must be a unique positive number'
            return render(request, 'main/new_doctor.html', context)
        
        # check that nb_of_malpractices is a number and not negative
        try:
            nb_of_malpractices=int(nb_of_malpractices)
            if nb_of_malpractices<0:
                raise Exception()
        except:
            context['error']='Number of malpractices must be a positive number'
            return render(request, 'main/new_doctor.html', context)
        
        # regex to check format of date (YYYY-MM-DD)
        date_regex=re.compile(r'^\d{4}-\d{2}-\d{2}$')
        if not date_regex.match(work_start):
            context['error']='Work start must be in the format YYYY-MM-DD'
            return render(request, 'main/new_doctor.html', context)
        
        # check that h_id is valid and a number
        try:
            h_id=int(h_id)
            if h_id not in hospitalids:
                raise Exception()
        except:
            context['error']='Hospital ID must be a valid number'
            return render(request, 'main/new_doctor.html', context)
        
        # insert into database
        sendQuery(f"INSERT INTO doctor_table (phone, specialization, first_name, last_name, work_start, nb_of_malpractices) VALUES ({phone}, '{specialization}', '{first_name}', '{last_name}', '{work_start}', {nb_of_malpractices});")
        sendQuery(f"INSERT INTO works_in (d_phone, h_id) VALUES ({phone}, {h_id});")
        context['success']='Doctor added successfully'
        return render(request, 'main/new_doctor.html', context)
    
def viewdep(request):
    if request.method == 'GET':
        context=dict()
        departments=sendQuery("SELECT name FROM department;")
        context['departments']=[department[0] for department in departments]
        return render(request, 'main/viewdep.html', context)
    
    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        department=body['dep']
        # print(department)
        info=sendQuery(f"SELECT name, extension, floor_number, nb_of_employees, manager_ssn FROM department WHERE name='{department}';")
        # print(info)
        name=info[0][0]
        extension=info[0][1]
        floor_number=info[0][2]
        nb_of_employees=info[0][3]
        manager_ssn=info[0][4]
        context['name']=name
        context['extension']=extension
        context['floor_number']=floor_number
        context['nb_of_employees']=nb_of_employees
        context['manager_ssn']=manager_ssn

        managername=sendQuery(f"SELECT first_name, last_name FROM employee_table WHERE ssn={manager_ssn};")
        managername=managername[0][0]+' '+managername[0][1]
        context['managername']=managername

        employees=sendQuery(f"SELECT ssn, first_name, last_name FROM employee_table WHERE d_name='{department}';")
        context['employees']=employees
        
        return JsonResponse(context)

def viewemp(request):
    if request.method == 'GET':
        context=dict()
        employees=sendQuery("SELECT ssn, first_name, last_name FROM employee_table;")
        context['employees']=[employee[1]+' '+employee[2]+', '+str(employee[0]) for employee in employees]
        return render(request, 'main/viewemp.html', context)
    
    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        employee=body['emp']
        try:
            employeessn=int(employee.split(', ')[1])
        except:
            employeessn=-1
        # print(employeessn)
        info=sendQuery(f"SELECT ssn, first_name, last_name, phone, extension, date_hired, address, salary, dob, su_ssn, d_name FROM employee_table WHERE ssn={employeessn};")
        ssn=info[0][0]
        first_name=info[0][1]
        last_name=info[0][2]
        phone=info[0][3]
        extension=info[0][4]
        date_hired=info[0][5]
        address=info[0][6]
        salary=info[0][7]
        dob=info[0][8]
        su_ssn=info[0][9]
        d_name=info[0][10]
        context['ssn']=ssn
        context['first_name']=first_name
        context['last_name']=last_name
        context['phone']=phone
        context['extension']=extension
        context['date_hired']=datetime.datetime.strftime(date_hired, "%B %d, %Y")
        context['address']=address
        context['salary']=salary
        context['dob']=datetime.datetime.strftime(dob, "%B %d, %Y")
        context['su_ssn']=su_ssn
        context['d_name']=d_name


        if su_ssn:
            supname=sendQuery(f"SELECT first_name, last_name FROM employee_table WHERE ssn={su_ssn};")
            supname=supname[0][0]+' '+supname[0][1]
            context['supname']=supname
        
        return JsonResponse(context)


def viewbro(request):
    if request.method == 'GET':
        context=dict()
        brokers=sendQuery("SELECT phone, name FROM broker_table;")
        context['brokers']=[broker[1]+', '+str(broker[0]) for broker in brokers]
        return render(request, 'main/viewbro.html', context)
    
    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        broker=body['bro']
        try:
            brokerphone=int(broker.split(', ')[1])
        except:
            brokerphone=-1
        # print(brokerphone)
        info=sendQuery(f"SELECT phone, start_date, end_date, address, commission, name, nb_of_customers_brought FROM broker WHERE phone={brokerphone};")
        phone=info[0][0]
        start_date=info[0][1]
        end_date=info[0][2]
        address=info[0][3]
        commission=info[0][4]
        name=info[0][5]
        nb_of_customers_brought=info[0][6]
        context['phone']=phone
        context['start_date']=datetime.datetime.strftime(start_date, "%B %d, %Y")
        if end_date:
            context['end_date']=datetime.datetime.strftime(end_date, "%B %d, %Y")        
        context['address']=address
        context['commission']=commission
        context['name']=name
        context['nb_of_customers_brought']=nb_of_customers_brought
        customers=sendQuery(f"SELECT ssn, first_name, last_name FROM customer_table WHERE b_phone={phone};")
        context['customers']=[customer[1]+' '+customer[2]+', '+str(customer[0]) for customer in customers]

        return JsonResponse(context)

def viewcus(request):
    if request.method == 'GET':
        context=dict()
        customers=sendQuery("SELECT ssn, first_name, last_name FROM customer_table;")
        context['customers']=[customer[1]+' '+customer[2]+', '+str(customer[0]) for customer in customers]
        return render(request, 'main/viewcus.html', context)
    
    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        customer=body['cus']
        try:
            customerssn=int(customer.split(', ')[1])
        except:
            customerssn=-1
        # print(customerssn)
        info=sendQuery(f"SELECT ssn, first_name, last_name, phone, dob, address, b_phone, e_ssn, date_of_assignment FROM customer_table WHERE ssn={customerssn};")
        ssn=info[0][0]
        first_name=info[0][1]
        last_name=info[0][2]
        phone=info[0][3]
        dob=info[0][4]
        address=info[0][5]
        b_phone=info[0][6]
        e_ssn=info[0][7]
        date_of_assignment=info[0][8]
        context['ssn']=ssn
        context['first_name']=first_name
        context['last_name']=last_name
        context['phone']=phone
        context['dob']=datetime.datetime.strftime(dob, "%B %d, %Y")
        context['age']=sendQuery(f"SELECT age from customer WHERE ssn={ssn};")[0][0]
        context['address']=address
        context['b_phone']=b_phone
        context['e_ssn']=e_ssn
        context['date_of_assignment']=datetime.datetime.strftime(date_of_assignment, "%B %d, %Y")

        if b_phone:
            brokername=sendQuery(f"SELECT name FROM broker_table WHERE phone={b_phone};")
            brokername=brokername[0][0]
            context['brokername']=brokername

        employee=sendQuery(f"SELECT first_name, last_name, ssn FROM employee_table WHERE ssn={e_ssn};")
        employee=employee[0][0]+' '+employee[0][1]+' '+str(employee[0][2])
        context['employee']=employee

        familymembers=sendQuery(f"SELECT first_name, last_name, age, relation FROM family_member WHERE c_ssn={ssn};")
        context['familymembers']=familymembers

        return JsonResponse(context)

def viewdoc(request):
    if request.method == 'GET':
        context=dict()
        doctors=sendQuery("SELECT phone, first_name, last_name FROM doctor_table;")
        context['doctors']=[doctor[1]+' '+doctor[2]+', '+str(doctor[0]) for doctor in doctors]
        return render(request, 'main/viewdoc.html', context)
    
    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        doctor=body['doc']
        try:
            doctorphone=int(doctor.split(', ')[1])
        except:
            doctorphone=-1
        # print(doctorphone)
        info=sendQuery(f"SELECT phone, specialization, first_name, last_name, years_worked, nb_of_malpractices FROM doctor WHERE phone={doctorphone};")
        phone=info[0][0]
        specialization=info[0][1]
        first_name=info[0][2]
        last_name=info[0][3]
        years_worked=info[0][4]
        nb_of_malpractices=info[0][5]
        context['phone']=phone
        context['specialization']=specialization
        context['first_name']=first_name
        context['last_name']=last_name
        context['years_worked']=years_worked
        context['nb_of_malpractices']=nb_of_malpractices

        context['operations']=sendQuery(f"SELECT COUNT(*) FROM operates_on WHERE d_phone={phone};")[0][0]

        operations=sendQuery(f"""SELECT d.phone AS "Doctor phone nb", d.first_name||' '||d.last_name AS "Doctor name",
COALESCE(h.name,'N/A') AS "Hospital name", COUNT(o.*) AS "Nb of operations"
FROM doctor_table d
LEFT JOIN operates_on o ON d.phone = o.d_phone
LEFT JOIN hospital h ON o.h_id = h.id
WHERE d.phone={phone}
GROUP BY "Doctor phone nb", "Doctor name", "Hospital name"
ORDER BY "Nb of operations" DESC;""")
        hospitals=[operation[2] for operation in operations]
        numberofoperations=[operation[3] for operation in operations]
        context['hospitals']=hospitals
        context['numberofoperations']=numberofoperations

        return JsonResponse(context)


def viewhos(request):
    if request.method == 'GET':
        context=dict()
        hospitals=sendQuery("SELECT id, name FROM hospital;")
        context['hospitals']=[hospital[1]+', '+str(hospital[0]) for hospital in hospitals]
        return render(request, 'main/viewhos.html', context)
    
    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        hospital=body['hos']
        try:
            hospitalid=int(hospital.split(', ')[1])
        except:
            hospitalid=-1
        # print(hospitalid)
        info=sendQuery(f"SELECT id, phone, name, representative, location FROM hospital WHERE id={hospitalid};")
        id=info[0][0]
        phone=info[0][1]
        name=info[0][2]
        representative=info[0][3]
        location=info[0][4]
        context['id']=id
        context['phone']=phone
        context['name']=name
        context['representative']=representative
        context['location']=location

        coverage=sendQuery(f"""SELECT h.id AS "Hospital ID", h.name AS "Hospital name",
COUNT(DISTINCT i.name) AS "Number of plans"
FROM hospital h
JOIN covers c ON h.id = c.h_id
JOIN insurance_plan i ON c.plan_identifier = i.id
WHERE h.id={id}
GROUP BY h.id, h.name
ORDER BY "Number of plans" DESC, "Hospital name";""")[0][2]
        context['coverage']=coverage

        return JsonResponse(context)
        

def viewlab(request):
    if request.method == 'GET':
        context=dict()
        labs=sendQuery("SELECT id, name FROM lab;")
        context['labs']=[lab[1]+', '+str(lab[0]) for lab in labs]
        return render(request, 'main/viewlab.html', context)
    
    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        lab=body['lab']
        try:
            labid=int(lab.split(', ')[1])
        except:
            labid=-1
        # print(labid)
        info=sendQuery(f"SELECT id, name, representative, phone FROM lab WHERE id={labid};")
        id=info[0][0]
        name=info[0][1]
        representative=info[0][2]
        phone=info[0][3]
        context['id']=id
        context['name']=name
        context['representative']=representative
        context['phone']=phone
        locations=sendQuery(f"SELECT location FROM lab_location WHERE lab_id={id};")
        context['locations']=[location[0] for location in locations]
        plans=sendQuery(f"SELECT DISTINCT plan_identifier FROM accepts WHERE lab_id={id} ORDER BY plan_identifier;")
        context['plans']=[plan[0] for plan in plans]

        return JsonResponse(context)

def viewins(request):
    if request.method == 'GET':
        context=dict()
        plans=sendQuery("SELECT DISTINCT name FROM insurance_plan;")
        context['plans']=[plan[0] for plan in plans]
        return render(request, 'main/viewins.html', context)

    if request.method == 'POST':
        context=dict()
        body=request.body.decode('utf-8')
        body=loads(body)
        plan=body['ins']
        # print(plan)
        info=sendQuery(f"SELECT id, type, name, description, price, start_age, end_age, percentage_paid, time_limit, financial_limit FROM insurance_plan WHERE name='{plan}';")
        context['name']=info[0][2]
        context['type']=info[0][1]
        context['description']=info[0][3]
        plans=[[entry[0], entry[4], entry[5], entry[6], entry[7], entry[8], entry[9]] for entry in info]
        context['plans']=plans
        return JsonResponse(context)

def inscus(request):
    pass

def recpay(request):
    pass

def recope(request):
    pass

def reclab(request):
    pass
