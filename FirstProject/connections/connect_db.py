import mysql.connector
from  mysql.connector import Error 
from abc import ABC , abstractmethod

# Creating abstract class 
class connection(ABC):

    @abstractmethod
    def create_connection(self):
        pass

    @abstractmethod
    def fetch_query(self):
        pass


class ConnectDB(connection):
    
    def __init__(self,host,user,password,database):
        print("Initialising the varicable")
        self.connection = None 
        self.config = {
                  'host' : host,     
                  'user' : user,
                  'password' : password,
                  'database':database
                }
        print("initialisation done , creating the connection now ..")


    
    def create_connection(self):
        
        try:
            if self.connection is None:
                mysql.connector.connect(**self.config) 
                if self.connection.is_connected():
                    print("Connection Established")
            else:
                return self.connection
                    
        except Error as e:
            print(f"Some error while connecting to MySql : {e}")

    
    def fetch_query(self,query): 

        if self.connection is None or  not self.connection.is_connected():
            print("The connection not exists , trying to create the connnection ..")
            self.create_connection()

        try:    
            curr = self.connection.cursor(dictionary=True)
            curr.execute(query)
            result = curr.fetchall()
            curr.close()
            return result 
        except Error as e:
            print(f"Error while fetching the data : {e}")
            return None 

    def insert_query(self,query,data=None):
        
        if self.connection is None or  not self.connection.is_connected():
            print("The connection not exists , trying to create the connnection ..")
            self.connection = self.create_connection()
            if self.connection is None:
                print("Error! cannot create the db connection ")
                return
            else:
                print("Connection created successfully ")
        
        curr = self.connection.cursor()
        
        try:
            if data:
                curr.execute(query,data)
            else:
                curr.execute(query)

            self.connection.commit()
            
           
        except Exception as e:
            print(f"some error while executing the Insert query : {e}")
            return 


    def close_connection(self):
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("The db connection is now closed ") 



# -----------------------------------------------------------------------------------------------
import time
import datetime 
host = "Yashwanths-Mac-mini.local"
#host = "127.0.0.1"
user = "root"
password = "Yashwanth14181418!"
database = "demo_warehouse"

db = ConnectDB(host=host,
               password=password,
               user=user,
               database=database
            )

#currentime = datetime.time()

query = "insert into demo_warehouse.employee_src values(106, 'Mukesh', 'HR', 5000, '2025-10-21')"

db.insert_query(query)

'''
query2 = "insert into practice-db.config (id,time) values(1,currentime)"
db.insert_query(query2)

query = "select * from practice-db.emp limit 10"
result = db.fetch_query(query)
print(result)





db2 = ConnectDB(host=host,
               password=password,
               user=user,
               database=database
            )


query = "select * from test_db.emp limit 10"
result = db.fetch_query(query)
print(result)


query = "select * from test_db.emp limit 10"
result = db2.fetch_query(query)
print(result)


time = time.now()
query2 = "insert into test_db.config (id,time) values(1,time)"
db.insert_query(query2)

# 1. Create a new sns topic 
# 2. subscription to your email 
# 3. lambda function code , push the message to sns topic 


 

'''
db.close_connection()