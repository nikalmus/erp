import os
from dotenv import load_dotenv

import psycopg2

load_dotenv()

def connect():
    if(os.environ['DEBUG']):
        connection = psycopg2.connect(os.environ['DATABASE_URL'])
    elif(os.environ['MINI_ERP_URL']):
        connection = psycopg2.connect(os.environ['MINI_ERP_URL'])
    return connection