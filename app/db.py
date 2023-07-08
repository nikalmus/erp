import psycopg2

def connect():
    connection = psycopg2.connect(
        host='localhost',
        port='5432',
        dbname='erp',
        user='postgres',
        password='postgres'
    )
    return connection