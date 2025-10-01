import snowflake.connector
import pandas as pd

class SnowflakeClient:
    def __init__(self,account,user,password,warehouse,database,schema):
        self.account = account
        self.user = user 
        self.password = password 
        self.warehouse = warehouse 
        self.database = database 
        self.schema = schema 
        

    def connect(self):
        self.conn = snowflake.connector.connect(
                     account = self.account,
                     user = self.user,
                     password = self.password,
                     warehouse = self.warehouse,
                     database = self.database,
                     schema = self.schema    
                ) 

    def close(self):
        if self.conn: 
            self.conn.close()

    def execute_query(self,query,params=None): 
        with self.conn.cursor() as cur:
            cur.execute(query,params)
            try:
                return cur.fetchall()
            except:
                 return None 
            
    def read_data_from_table(self,table_name):
        query = f"select * from {table_name}"
        with self.conn.cursor() as cur:
            cur.execute(query)
            return cur.fetchall()
            #return cur.fetch_pandas_all()

    def write_to_table(self,table_name,pd_df):
        pass 

    def write_to_table(self,table_name,sp_df):
        pass 

    def create_table(self,table_name,columns):
        pass

         






# main class

user='CHINNUNEELA'
password='Yashwanth14181418'
account='TEMTDWR-EY78543'
database='TEST_DB'
schema='TEST_SCHEMA'
warehouse='COMPUTE_WH'

sf = SnowflakeClient(account,user,password,warehouse,database,schema)

sf.connect()

result = sf.execute_query("select count(*) from first_table")
print("RESULT : ",result )

result2 = sf.read_data_from_table("first_table")
print("RESULT2",result2)

#result3 = sf.execute_query("create table sept24 (id int , name varchar)")
#print("RESULT : ",result3 )

#WH = sf.execute_query('USE WAREHOUSE XSMALL')
#print("RESULT : ",WH )

insert = sf.execute_query("insert into sept24 values (1,'mukesh')")
print("INSERT" ,insert)


result5 = sf.execute_query("select * from sept24")
print("RESULT5 : ",result5 )