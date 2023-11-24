import psycopg2

def sendQuery(query):
    connection=psycopg2.connect(
        host="localhost",
        database="lab4",
        user="postgres",
        password="redacted",
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
