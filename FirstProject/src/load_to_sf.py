import os
import sys 
import time

current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)

# Add parent directory to system path
if parent_dir not in sys.path:
    sys.path.insert(0,parent_dir)

# Set environment variables for local Spark execution (User's paths)
os.environ['JAVA_HOME'] = "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
os.environ['SPARK_HOME'] = "/opt/homebrew/opt/apache-spark/libexec"
# ---------------------------------------------------------------------------------

# Import the necessary client class from the module
from connections.sf_connection import SnowflakeClient
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType 


if __name__ == "__main__":
    
    # --- 1. SNOWFLAKE CONFIGURATION ---
    
    ACCOUNT = 'TEMTDWR-EY78543'
    USER = 'CHINNUNEELA'
    PASSWORD = 'Yashwanth14181418'
    WAREHOUSE = 'COMPUTE_WH'
    DATABASE = 'TEST_DB'
    SCHEMA ='TEST_SCHEMA'
    SNOWFLAKE_TABLE = "SPARK_TEST_DATA"
    
    try:
    
        spark = SparkSession.builder.appName("SnowflakeSparkDemo") \
            .config("spark.jars.packages", "net.snowflake:spark-snowflake_2.12:2.11.0") \
            .getOrCreate()
        print("\nSpark Session successfully initialized.")
        
        # --- 3. CREATE SPARK DATAFRAME ---
        spark_data = [
            ("Alpha", 100),
            ("Beta", 200),
            ("Gamma", 300)
        ]
        spark_schema = StructType([
            StructField("ITEM_NAME", StringType(), True),
            StructField("VALUE", IntegerType(), True)
        ])
        
        spark_df = spark.createDataFrame(data=spark_data, schema=spark_schema)
        print("\nSpark DataFrame created:")
        spark_df.printSchema()
        spark_df.show()

        # --- 4. INITIALIZE SNOWFLAKE CLIENT & CONNECT ---
        client = SnowflakeClient(ACCOUNT, USER, PASSWORD, WAREHOUSE, DATABASE, SCHEMA)
        client.connect()
        
        if client.conn:
            # --- 5. WRITE SPARK DATAFRAME TO SNOWFLAKE ---
            client.write_spark_df_to_table(
                table_name=SNOWFLAKE_TABLE,
                sp_df=spark_df,
                mode="overwrite"
            )
            
            # Wait a few seconds for the Spark job to finish writing
            time.sleep(5) 

            # --- 6. READ DATA BACK FROM SNOWFLAKE (using Python Connector) ---
            print(f"\n--- Reading data back from {SNOWFLAKE_TABLE} via Python Connector ---")
            retrieved_data = client.read_data_from_table(SNOWFLAKE_TABLE)
            
            if retrieved_data:
                print(f"Successfully retrieved {len(retrieved_data)} rows:")
                for row in retrieved_data:
                    print(row)
            else:
                print("Failed to retrieve data or table is empty.")

            # --- 7. CLEANUP ---
            print(f"\nDropping table {SNOWFLAKE_TABLE}.")
            client.execute_query(f"DROP TABLE IF EXISTS {SNOWFLAKE_TABLE}")
            
        client.close()
        spark.stop()
        print("\nCleanup complete. Spark session stopped.")

    except Exception as e:
        print(f"\nAn UNEXPECTED error occurred during the execution (check environment variables and connector package version): {e}", file=sys.stderr)
