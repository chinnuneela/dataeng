import mysql.connector
from mysql.connector import Error 
from abc import ABC, abstractmethod
import datetime 
import time
import random
import os
import glob

# --- PySpark Imports (Required for actual Spark operations) ---
from pyspark.sql import SparkSession
from pyspark.sql import DataFrame as SparkDataFrame
from pyspark.sql.types import StructType, StructField, IntegerType, StringType

# --- Abstract Base Class (Connection Contract) ---
class Connection(ABC):
    """Abstract Base Class defining the contract for a database connection."""

    @abstractmethod
    def create_connection(self):
        """Attempts to establish or verify the database connection."""
        pass

    @abstractmethod
    def fetch_query(self, query):
        """Executes a SELECT query and returns results."""
        pass


# --- Concrete Implementation ---
class ConnectDB(Connection):
    """Concrete implementation for connecting to and interacting with MySQL.
    
    Includes standard MySQL Connector methods and Spark JDBC integration methods.
    """
    
    def __init__(self, host, user, password, database):
        print("Initialising the database configuration...")
        self.connection = None 
        self.config = {
                  'host' : host,     
                  'user' : user,
                  'password' : password,
                  'database': database
                }
        
    def create_connection(self):
        """Attempts to establish connection if one does not exist or is closed."""
        if self.connection is None or not self.connection.is_connected():
            try:
                self.connection = mysql.connector.connect(**self.config) 
                if self.connection.is_connected():
                    print("Standard MySQL Connection Established.")
                    return True
                else:
                    return False
            except Error as e:
                print(f"Connection Error: {e}")
                self.connection = None 
                return False
        return True

    # --- Helper for Spark JDBC ---
    def get_jdbc_url_and_props(self):
        """Constructs the JDBC URL and properties dictionary for Spark."""
        # Note: The database name is included in the URL for Spark JDBC
        jdbc_url = (f"jdbc:mysql://{self.config['host']}/"
                    f"{self.config['database']}")
        jdbc_properties = {
            "user": self.config['user'],
            "password": self.config['password'],
            # The driver must be available in the Spark classpath
            "driver": "com.mysql.cj.jdbc.Driver" 
        }
        return jdbc_url, jdbc_properties

    # -----------------------------------------------------------
    # 1. READ from MySQL and return Spark DataFrame
    # -----------------------------------------------------------
    def read_mysql_table_to_spark_df(self, spark: SparkSession, table_name: str, query: str = None) -> SparkDataFrame:
        """
        Reads data from a MySQL table or query into a Spark DataFrame using JDBC.
        """
        jdbc_url, jdbc_properties = self.get_jdbc_url_and_props()
        
        # Determine whether to read the whole table or use a subquery
        dbtable = table_name
        if query:
            # If a query is provided, use it as a subquery (required format for Spark)
            dbtable = f"({query}) AS custom_query_alias"
            print(f"\n--- Spark Read: Using Custom Query ---")
        else:
            print(f"\n--- Spark Read: Reading Entire Table '{table_name}' ---")

        try:
            # Actual Spark read operation
            df = spark.read.jdbc(
                url=jdbc_url,
                table=dbtable,
                properties=jdbc_properties
            )
            print(f"Successfully read MySQL data into Spark DataFrame. Schema:")
            df.printSchema()
            return df
        except Exception as e:
            print(f"Error reading Spark DataFrame via JDBC: {e}")
            # Return an empty DataFrame on failure
            return spark.createDataFrame([], schema=StructType([])) 

    # -----------------------------------------------------------
    # 2. Write Spark DataFrame to a table (create if not exists)
    # -----------------------------------------------------------
    def write_spark_data_to_mysql(self, df: SparkDataFrame, table_name: str, save_mode: str = "append"):
        """
        Writes a Spark DataFrame to a MySQL table using JDBC.
        
        The requirement "if table don't exists first create the table" is handled by
        setting save_mode to "append" or "overwrite". Spark's JDBC writer automatically 
        issues a CREATE TABLE statement if the table is missing in these modes.
        
        Args:
            df (SparkDataFrame): The DataFrame to write.
            table_name (str): The name of the target MySQL table.
            save_mode (str): The save mode ("append", "overwrite", "errorifexists", "ignore").
        """
        save_mode = save_mode.lower()
        if save_mode not in ["append", "overwrite", "errorifexists", "ignore"]:
            print(f"Invalid save_mode: {save_mode}. Defaulting to 'append'.")
            save_mode = "append"

        try:
            jdbc_url, jdbc_properties = self.get_jdbc_url_and_props()
            
            print(f"\n--- Spark Write: Writing to '{table_name}' in '{save_mode}' mode ---")
            
            # Actual Spark write operation
            df.write.jdbc(
                url=jdbc_url,
                table=table_name,
                mode=save_mode, 
                properties=jdbc_properties
            )
            print(f"Successfully wrote Spark DataFrame to MySQL table '{table_name}'.")
            return True
        except Exception as e:
            print(f"Error writing Spark DataFrame via JDBC: {e}")
            return False

    # --- Minimal Helper Methods for Demo Setup ---

    def execute_query(self, query, data=None, commit=True):
        """Executes a generic SQL query (CREATE, DROP, etc.)."""
        if not self.create_connection():
            return False

        curr = None
        try:
            curr = self.connection.cursor()
            if data:
                curr.execute(query, data)
            else:
                curr.execute(query)

            if commit:
                self.connection.commit()
                print(f"Standard Query executed successfully. Rows affected: {curr.rowcount}")
            return True
            
        except Error as e:
            print(f"Error executing standard query: {e}")
            if self.connection and self.connection.is_connected():
                self.connection.rollback()
            return False
        finally:
            if curr:
                curr.close()

    def create_table(self, table_name, schema):
        """Creates a table using the standard MySQL connector."""
        query = f"CREATE TABLE IF NOT EXISTS {table_name} ({schema})"
        print(f"Attempting to create table '{table_name}' using standard connector...")
        return self.execute_query(query)
    
    def drop_table(self, table_name):
        """Drops a specified table."""
        query = f"DROP TABLE IF EXISTS {table_name}"
        print(f"Attempting to drop table '{table_name}'...")
        return self.execute_query(query)

    def close_connection(self):
        """Closes the standard MySQL connection safely."""
        if self.connection and self.connection.is_connected():
            self.connection.close()
            self.connection = None
            print("The standard db connection is now closed.") 

    def fetch_query(self, query): 
        """Implementation of abstract method - only used for testing/local checks."""
        if not self.create_connection():
            return None
        # ... (rest of fetch_query implementation) ...
        return None # Placeholder

# -----------------------------------------------------------------------------------------------
# --- EXAMPLE SPARK ETL USAGE ---
# -----------------------------------------------------------------------------------------------

def example_spark_etl_run():
    """
    Demonstrates the use of the new Spark integration methods.
    
    NOTE: YOU MUST START YOUR SPARK SESSION WITH THE MYSQL JDBC DRIVER.
    Example command to run this script (assuming you have the jar file):
    $ spark-submit --driver-class-path /path/to/mysql-connector-java.jar spark_db_etl.py
    """
    
    # --- Configuration (UPDATE THESE WITH YOUR ACTUAL CREDENTIALS) ---
    HOST = "127.0.0.1"
    USER = "root"
    PASSWORD = "Paridhi@2019#"  
    DATABASE = "dw_poc"
    SOURCE_TABLE = "source_data"
    TARGET_TABLE = "processed_results"

    # 1. Initialize Spark Session
    print("-" * 50)
    print("1. INITIALIZING SPARK SESSION")
    print("-" * 50)

    # Try to locate a MySQL JDBC driver JAR in the repository (common location: ./jars/)
    def find_mysql_connector_jar(search_root: str):
        """Search recursively for a MySQL connector JAR and return the first match or None."""
        patterns = [
            'mysql-connector*.jar',
            '*mysql*connector*.jar',
            'mysql-connector-java-*.jar'
        ]
        for pat in patterns:
            matches = glob.glob(os.path.join(search_root, '**', pat), recursive=True)
            if matches:
                # return the first match
                return matches[0]
        return None

    try:
        # Determine repository root (directory containing this script)
        repo_root = os.path.abspath(os.path.dirname(__file__))
        mysql_jar = find_mysql_connector_jar(repo_root)
        if mysql_jar:
            print(f"Found MySQL JDBC driver jar: {mysql_jar}")
            # Add jar to Spark configuration so driver class is available to both driver and executors
            spark = (
                SparkSession.builder.appName("SparkMySQLJDBCDemo")
                .config("spark.jars", mysql_jar)
                .config("spark.driver.extraClassPath", mysql_jar)
                .getOrCreate()
            )
        else:
            print("No MySQL JDBC driver jar found in the workspace. If you see a ClassNotFoundException for com.mysql.cj.jdbc.Driver,")
            print("please download the MySQL Connector/J jar and place it in a 'jars/' folder or pass it via spark-submit --jars or --driver-class-path.")
            spark = SparkSession.builder.appName("SparkMySQLJDBCDemo").getOrCreate()
    except Exception as e:
        print(f"!!! CRITICAL ERROR: Could not initialize SparkSession. PySpark or dependencies missing. {e}")
        return

    # 2. Initialize Database Connection Handler
    db = ConnectDB(host=HOST, password=PASSWORD, user=USER, database=DATABASE)

    # 3. Setup: Create and Populate Source Table (using standard connector)
    print("-" * 50)
    print("3. SETUP: CREATING AND POPULATING SOURCE TABLE")
    print("-" * 50)
    db.drop_table(SOURCE_TABLE) 
    source_schema = (
        "id INT, "
        "name VARCHAR(50), "
        "amount INT"
    )
    db.create_table(SOURCE_TABLE, source_schema)

    # Insert some initial data
    insert_template = f"INSERT INTO {SOURCE_TABLE} (id, name, amount) VALUES (%s, %s, %s)"
    db.execute_query(insert_template, (1, "ProductA", 100))
    db.execute_query(insert_template, (2, "ProductB", 250))
    db.execute_query(insert_template, (3, "ProductC", 50))


    # 4. Read from MySQL to Spark DataFrame (Function 1)
    print("-" * 50)
    print("4. EXECUTE: READING DATA INTO SPARK DF")
    print("-" * 50)
    
    # Read only specific data using a custom query
    read_query = f"SELECT id, name, amount FROM {SOURCE_TABLE} WHERE amount >= 100"
    source_df = db.read_mysql_table_to_spark_df(spark, SOURCE_TABLE, query=read_query)
    
    if source_df.count() > 0:
        print(f"Data read from MySQL (Count: {source_df.count()}):")
        source_df.show()
    else:
        print("Failed to read data or data set is empty.")
        db.close_connection()
        spark.stop()
        return

    
    # 5. Transformation (Example: Add a calculated column)
    print("-" * 50)
    print("5. TRANSFORMATION: CALCULATING TAX")
    print("-" * 50)
    from pyspark.sql.functions import col
    processed_df = source_df.withColumn("tax_amount", col("amount") * 0.10)
    processed_df.show()


    # 6. Write Spark DataFrame to MySQL (Function 2 - Creates table if not exists)
    print("-" * 50)
    print("6. EXECUTE: WRITING SPARK DF TO NEW MYSQL TABLE")
    print("-" * 50)
    
    # Drop the target table first to force Spark to create it in the write step
    db.drop_table(TARGET_TABLE) 
    
    # This call uses mode='append'. Since the table does not exist, Spark will 
    # use the processed_df's schema to automatically CREATE the TARGET_TABLE first.
    db.write_spark_data_to_mysql(processed_df, TARGET_TABLE, save_mode="append")


    # 7. Cleanup
    print("-" * 50)
    print("7. CLEANUP")
    print("-" * 50)
    db.drop_table(SOURCE_TABLE)
    db.drop_table(TARGET_TABLE)
    db.close_connection()
    spark.stop()
    print("Spark Session stopped. ETL demonstration complete.")


if __name__ == "__main__":
    example_spark_etl_run()
