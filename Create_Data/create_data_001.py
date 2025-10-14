import os
from pyspark.sql import SparkSession
import dbldatagen as dg

# Configuration
NUM_ROWS = 10000
OUTPUT_PATH = "/Users/mukesh/Desktop/TEST_AGAIN/Data/output_parquet"

COLUMNS = [
    {"name": "cust_id", "type": "integer", "min": 1, "max": 10000},
    {"name": "category", "type": "choice", "values": ["A", "B", "C", "D"]},
    {"name": "amount", "type": "float", "min": 10.0, "max": 1000.0},
    {"name": "description", "type": "string"},  # simple string
]

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("TestDataGenerator") \
    .master("local[*]") \
    .getOrCreate()
print(f"✅ SparkSession created (version: {spark.version})")

# Create DataGenerator with a custom seed column to avoid conflicts
data_gen = dg.DataGenerator(
    spark,
    name="TestDataGen",
    rows=NUM_ROWS,
    partitions=5,
    seedColumnName="_seed_id"  # avoids conflict with 'cust_id'
)

# Add columns
for col in COLUMNS:
    col_name = col["name"]
    col_type = col["type"]

    if col_type == "integer":
        data_gen = data_gen.withColumn(col_name, "integer", minValue=col["min"], maxValue=col["max"])
    elif col_type == "float":
        data_gen = data_gen.withColumn(col_name, "float", minValue=col["min"], maxValue=col["max"])
    elif col_type == "string":
        data_gen = data_gen.withColumn(col_name, "string")
    elif col_type == "choice":
        data_gen = data_gen.withColumn(col_name, "string", values=col["values"])
    else:
        raise ValueError(f"Unsupported column type: {col_type}")

# Build DataFrame
df = data_gen.build()
print("✅ Test DataFrame generated:")
df.show(10, truncate=False)

# Write to Parquet
os.makedirs(OUTPUT_PATH, exist_ok=True)
df.write.mode("overwrite").parquet(OUTPUT_PATH)
print(f"✅ Data written to Parquet at: {OUTPUT_PATH}")

# Stop Spark session
spark.stop()
print("🛑 Spark session stopped.")
