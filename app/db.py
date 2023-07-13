import os
from dotenv import load_dotenv

import psycopg2

load_dotenv()

def connect():
    connection = psycopg2.connect(os.environ['MINI_ERP_URL'])
    return connection