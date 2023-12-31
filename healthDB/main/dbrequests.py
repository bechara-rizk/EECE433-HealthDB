import psycopg2

passwd="redacted"

def sendQuery(query):
    global passwd
    connection=psycopg2.connect(
        host="localhost",
        database="healthdb",
        user="postgres",
        password=passwd,
        port="5432"
    )
    cursor=connection.cursor()
    cursor.execute(query)
    connection.commit()
    try:
        results=cursor.fetchall()
    except:
        results=False
    cursor.close()
    connection.close()
    return results

def callFunction(functionName, *args):
    global passwd
    connection=psycopg2.connect(
        host="localhost",
        database="healthdb",
        user="postgres",
        password=passwd,
        port="5432"
    )
    cursor=connection.cursor()
    cursor.callproc(functionName, args)
    connection.commit()
    try:
        results=cursor.fetchall()
    except:
        results=False
    notice=connection.notices
    if len(notice)>0 and 'error' in notice[-1].lower():
        notice=notice[-2]
    else:
        notice=False
    cursor.close()
    connection.close()
    return results, notice

def callProcedure(procedureName, *args):
    global passwd
    connection=psycopg2.connect(
        host="localhost",
        database="healthdb",
        user="postgres",
        password=passwd,
        port="5432"
    )
    cursor=connection.cursor()
    args=', '.join(args)
    cursor.execute(f"CALL {procedureName}({args});")
    connection.commit()
    cursor.close()
    connection.close()
    return False