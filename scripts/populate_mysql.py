import sys
import mysql.connector
from mysql.connector import Error
from faker import Faker

# Database connection details from arguments
db_host, db_user, db_password, db_name = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

def check_table_exists(cursor, table_name):
    cursor.execute(f"SHOW TABLES LIKE '{table_name}';")
    return cursor.fetchone() is not None

def create_table(cursor, table_name):
    cursor.execute(f"CREATE TABLE {table_name} (email VARCHAR(255) NOT NULL);")

def insert_emails(cursor, table_name, num_emails):
    fake = Faker()
    for _ in range(num_emails):
        email = fake.email()
        cursor.execute(f"INSERT INTO {table_name} (email) VALUES ('{email}');")

try:
    # Connect to the database
    connection = mysql.connector.connect(host=db_host, user=db_user, password=db_password, database=db_name)
    cursor = connection.cursor()

    if not check_table_exists(cursor, 'emails'):
        create_table(cursor, 'emails')
        insert_emails(cursor, 'emails', 1000)
        connection.commit()
    else:
        print("Table 'emails' already exists.")
        raise Exception("Table 'emails' already exists.")

except Error as e:
    print(f"Error: {e}")
    raise Exception(f"Error: {e}")
finally:
    if connection.is_connected():
        cursor.close()
        connection.close()