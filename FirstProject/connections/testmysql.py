import mysql.connector
from mysql.connector import Error
import datetime

try:
    connection = mysql.connector.connect(
        host = "127.0.0.1",
        user='root',
        password='Yashwanth14181418!',
        database='demo_warehouse'
    )

    if connection.is_connected():
        print("You're connected to database: ")


except Error as e:
    print(f"Error while connecting to MySQL : {e}")

connection.close()  