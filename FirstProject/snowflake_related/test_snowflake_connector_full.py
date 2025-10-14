from snowflake_connector import SnowflakeConnector
from pyspark.sql import Row
from pyspark.sql import SparkSession
import os

# ----------------------------
# CONFIGURATION
# ----------------------------
sfOptions = {
    "sfURL": "TEMTDWR-EY78543.snowflakecomputing.com",
    "sfDatabase": "TEST_DB",
    "sfSchema": "TEST_SCHEMA",
    "sfWarehouse": "COMPUTE_WH",
    "sfRole": "ACCOUNTADMIN",
    "sfUser": "CHINNUNEELA",
    "sfPassword": "Yashwanth14181418"
}

# Initialize connector
sf = SnowflakeConnector(sfOptions)
spark = sf.spark

# ----------------------------
# TEST CASE 1: Create a sample DataFrame and write it to Snowflake
# ----------------------------
print("\n=== TEST CASE 1: WRITE & READ BACK DATAFRAME ===")
data = [Row(id=i, name=f"Name_{i}") for i in range(1, 6)]
df = spark.createDataFrame(data)
df.show()

sf.write_spark_df_to_sf(df, "TEST_TABLE_PERM", mode="overwrite")
read_df = sf.read_from_sf("TEST_TABLE_PERM")
read_df.show()

# Validate data
assert read_df.count() == df.count(), "❌ Row count mismatch!"
print("✅ DataFrame written and read successfully from Snowflake.\n")

# ----------------------------
# TEST CASE 2: Append more data to same table
# ----------------------------
print("\n=== TEST CASE 2: APPEND MODE TEST ===")
more_data = [Row(id=i, name=f"New_Name_{i}") for i in range(6, 8)]
df_append = spark.createDataFrame(more_data)
sf.write_spark_df_to_sf(df_append, "TEST_TABLE_PERM", mode="append")

appended = sf.read_from_sf("TEST_TABLE_PERM")
appended.show()
print(f"✅ Append successful, total rows now: {appended.count()}\n")

# ----------------------------
# TEST CASE 3: Create TRANSIENT table
# ----------------------------
print("\n=== TEST CASE 3: CREATE TRANSIENT TABLE ===")
sf.execute_query("""
    CREATE OR REPLACE TRANSIENT TABLE TEST_TABLE_TRANSIENT (
        id INT, name STRING
    )
""")
sf.write_spark_df_to_sf(df, "TEST_TABLE_TRANSIENT", mode="overwrite")
print("✅ Transient table created and data written.\n")

# ----------------------------
# TEST CASE 4: Write CSV file to Snowflake
# ----------------------------
print("\n=== TEST CASE 4: WRITE TO SNOWFLAKE FROM FILE ===")
temp_csv = "sample_snowflake.csv"
df.toPandas().to_csv(temp_csv, index=False)

sf.write_to_table_from_file(temp_csv, "TEST_TABLE_FROM_FILE", file_format="csv", header=True)

print("✅ File uploaded to Snowflake as a table.\n")
os.remove(temp_csv)

# ----------------------------
# TEST CASE 5: Execute a SQL query directly
# ----------------------------
print("\n=== TEST CASE 5: EXECUTE SQL QUERY ===")
query_result = sf.execute_query("SELECT COUNT(*) AS total_rows FROM TEST_TABLE_PERM")
print(f"✅ Query executed successfully. Result: {query_result}\n")

# ----------------------------
# TEST CASE 6: Read filtered data using SQL
# ----------------------------
print("\n=== TEST CASE 6: READ USING CUSTOM QUERY ===")
filtered_df = spark.read \
    .format("snowflake") \
    .options(**sf.sfOptions) \
    .option("query", "SELECT * FROM TEST_TABLE_PERM WHERE id < 3") \
    .load()

filtered_df.show()
print("✅ Custom query read test passed.\n")

# ----------------------------
# CLEANUP
# ----------------------------
print("\n=== CLEANUP ===")
sf.execute_query("DROP TABLE IF EXISTS TEST_TABLE_PERM")
sf.execute_query("DROP TABLE IF EXISTS TEST_TABLE_TRANSIENT")
sf.execute_query("DROP TABLE IF EXISTS TEST_TABLE_FROM_FILE")
print("✅ Cleanup complete. All test tables dropped.\n")

sf.stop()
print("✅ All Snowflake tests completed successfully!")
