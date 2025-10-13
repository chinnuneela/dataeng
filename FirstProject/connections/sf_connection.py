import snowflake.connector
import sys 
from typing import List, Dict, Any

# NOTE: We avoid importing PySpark components here to keep the module general.
# The Spark DataFrame (sp_df) is expected to be passed to write_spark_df_to_table.

class SnowflakeClient:
    """
    A client for connecting to and interacting with Snowflake, supporting 
    both direct connection and DataFrame bulk loading (Pandas and Spark).
    """
    def __init__(self, account, user, password, warehouse, database, schema):
        self.account = account
        self.user = user 
        self.password = password 
        self.warehouse = warehouse 
        self.database = database 
        self.schema = schema 
        self.conn = None

    def connect(self):
        """Establishes the connection to Snowflake."""
        try:
            self.conn = snowflake.connector.connect(
                         account = self.account,
                         user = self.user,
                         password = self.password,
                         warehouse = self.warehouse,
                         database = self.database,
                         schema = self.schema    
                    )
            print("Snowflake connection successful.")
        except Exception as e:
            print(f"Snowflake connection failed: {e}", file=sys.stderr)
            self.conn = None


    def close(self):
        """Closes the Snowflake connection."""
        if self.conn: 
            self.conn.close()
            print("Snowflake connection closed.")

    def execute_query(self, query: str, params: tuple = None) -> List[tuple] | None: 
        """
        Executes a SQL query and returns results if available, 
        committing DML/DDL operations.
        """
        if not self.conn:
            print("Error: Connection not established. Cannot execute query.", file=sys.stderr)
            return None
            
        with self.conn.cursor() as cur:
            try:
                cur.execute(query, params)
                # Ensure DML/DDL like DROP TABLE is committed
                if not self.conn.autocommit:
                    self.conn.commit()
                
                # Try to fetch results, if it's a SELECT query
                try:
                    return cur.fetchall()
                except snowflake.connector.errors.ProgrammingError:
                    return None # No results to fetch (e.g., INSERT, UPDATE, DDL)
            except Exception as e:
                print(f"Error executing query: {query}. Error: {e}", file=sys.stderr)
                return None
            
    def read_data_from_table(self, table_name: str) -> List[Dict[str, Any]] | None:
        """Reads all data from a specified table and returns as a list of dicts."""
        if not self.conn:
            print("Error: Connection not established. Cannot read data.", file=sys.stderr)
            return None
            
        query = f"SELECT * FROM {table_name}"
        with self.conn.cursor() as cur:
            cur.execute(query)
            # Fetch column names
            columns = [col[0] for col in cur.description]
            # Fetch data and return as a list of dictionaries
            data = cur.fetchall()
            return [dict(zip(columns, row)) for row in data]
            
    
    # -----------------------------------------------------
    # Spark DataFrame Loader
    # -----------------------------------------------------
    def write_spark_df_to_table(self, table_name: str, sp_df, mode: str = "append"):
        """
        Writes a Spark DataFrame to a Snowflake table using the Spark-Snowflake Connector.

        :param table_name: The name of the Snowflake table.
        :param sp_df: The Spark DataFrame to be written.
        :param mode: Save mode (e.g., 'append', 'overwrite').
        """
        try:
            # Connection properties passed to the Spark Connector
            sfOptions = {
                # sfURL needs to be your full account identifier, which is what 
                # you pass in self.account
                "sfURL": self.account, 
                "sfUser": self.user,
                "sfPassword": self.password,
                "sfWarehouse": self.warehouse,
                "sfDatabase": self.database,
                "sfSchema": self.schema,
                "dbtable": table_name.upper()
            }
            
            print(f"\n--- Starting Spark DF write to table: {table_name}, mode: {mode.lower()} ---")
            
            # --- This is the PySpark write operation using the connector ---
            sp_df.write \
                 .format("snowflake") \
                 .options(**sfOptions) \
                 .mode(mode.lower()) \
                 .save()
            # ---------------------------------------------------------------

            print(f"Spark DataFrame write to {table_name} successful (operation initiated).")

        except Exception as e:
            error_message = f"Error during Spark DataFrame loading. Ensure the 'snowflake' format is available (JAR file required). Error: {e}"
            print(error_message, file=sys.stderr)



# Example Usage 


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