"""
PySpark Job 3: ETL Pipeline with Data Quality Checks
This job demonstrates a complete ETL pipeline including data extraction,
transformation, quality checks, and loading operations.
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, when, lit, current_timestamp, sha2, concat_ws,
    regexp_replace, trim, upper, lower, to_date, datediff,
    count, sum as spark_sum, avg, stddev, min as spark_min, max as spark_max
)
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, DateType
import sys

def main():
    # Initialize Spark Session with additional configurations
    spark = SparkSession.builder \
        .appName("ETL_Pipeline_DataQuality") \
        .config("spark.sql.legacy.timeParserPolicy", "LEGACY") \
        .getOrCreate()
    
    print("=" * 80)
    print("Starting ETL Pipeline with Data Quality Checks")
    print("=" * 80)
    
    # ============================================================================
    # EXTRACT: Create sample customer data with quality issues
    # ============================================================================
    print("\n📥 EXTRACT Phase: Loading Raw Data")
    
    raw_data = [
        (1, "John Doe", "john.doe@email.com", "2023-01-15", 5000.50, "New York", "NY"),
        (2, "  Jane Smith  ", "jane.smith@email.com", "2023-02-20", 7500.75, "Los Angeles", "CA"),
        (3, "Bob Johnson", "bob.johnson@invalid", "2023-03-10", -100.00, "Chicago", "IL"),  # Invalid email, negative amount
        (4, "Alice Brown", "alice.brown@email.com", "2023-04-05", 12000.00, "Houston", "TX"),
        (5, "", "no.name@email.com", "2023-05-15", 3000.00, "Phoenix", "AZ"),  # Missing name
        (6, "Charlie Wilson", "charlie.wilson@email.com", "invalid-date", 8500.00, "Philadelphia", "PA"),  # Invalid date
        (7, "Diana Prince", "diana.prince@email.com", "2023-07-20", 15000.00, "San Antonio", "TX"),
        (8, "Eve Davis", "eve.davis@email.com", "2023-08-25", None, "San Diego", "CA"),  # Missing amount
        (9, "Frank Miller", "frank.miller@email.com", "2023-09-30", 6000.00, None, None),  # Missing location
        (10, "Grace Lee", "grace.lee@email.com", "2023-10-15", 9500.00, "Dallas", "TX"),
    ]
    
    schema = StructType([
        StructField("customer_id", IntegerType(), True),
        StructField("name", StringType(), True),
        StructField("email", StringType(), True),
        StructField("registration_date", StringType(), True),
        StructField("total_purchases", DoubleType(), True),
        StructField("city", StringType(), True),
        StructField("state", StringType(), True)
    ])
    
    raw_df = spark.createDataFrame(raw_data, schema)
    
    print(f"\n📊 Raw Data Count: {raw_df.count()} records")
    raw_df.show(truncate=False)
    
    # ============================================================================
    # TRANSFORM: Data Cleaning and Enrichment
    # ============================================================================
    print("\n🔧 TRANSFORM Phase: Cleaning and Enriching Data")
    
    # Step 1: Clean and standardize text fields
    cleaned_df = raw_df.withColumn("name", trim(col("name"))) \
                       .withColumn("email", lower(trim(col("email")))) \
                       .withColumn("city", trim(col("city"))) \
                       .withColumn("state", upper(trim(col("state"))))
    
    # Step 2: Add data quality flags
    quality_df = cleaned_df.withColumn(
        "has_valid_name",
        when(col("name").isNotNull() & (col("name") != ""), lit(True)).otherwise(lit(False))
    ).withColumn(
        "has_valid_email",
        when(col("email").rlike("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"), lit(True)).otherwise(lit(False))
    ).withColumn(
        "has_valid_amount",
        when((col("total_purchases").isNotNull()) & (col("total_purchases") >= 0), lit(True)).otherwise(lit(False))
    ).withColumn(
        "has_valid_location",
        when(col("city").isNotNull() & col("state").isNotNull(), lit(True)).otherwise(lit(False))
    )
    
    # Step 3: Convert date and add derived fields
    transformed_df = quality_df.withColumn(
        "registration_date_parsed",
        to_date(col("registration_date"), "yyyy-MM-dd")
    ).withColumn(
        "has_valid_date",
        when(col("registration_date_parsed").isNotNull(), lit(True)).otherwise(lit(False))
    ).withColumn(
        "days_since_registration",
        datediff(current_timestamp(), col("registration_date_parsed"))
    ).withColumn(
        "customer_tier",
        when(col("total_purchases") >= 10000, lit("Gold"))
        .when(col("total_purchases") >= 5000, lit("Silver"))
        .otherwise(lit("Bronze"))
    ).withColumn(
        "processed_timestamp",
        current_timestamp()
    )
    
    # Step 4: Add overall quality flag
    final_df = transformed_df.withColumn(
        "is_valid_record",
        when(
            col("has_valid_name") & 
            col("has_valid_email") & 
            col("has_valid_amount") & 
            col("has_valid_location") & 
            col("has_valid_date"),
            lit(True)
        ).otherwise(lit(False))
    )
    
    print("\n📊 Transformed Data:")
    final_df.select(
        "customer_id", "name", "email", "registration_date_parsed",
        "total_purchases", "customer_tier", "is_valid_record"
    ).show(truncate=False)
    
    # ============================================================================
    # DATA QUALITY CHECKS
    # ============================================================================
    print("\n🔍 DATA QUALITY CHECKS:")
    
    # Overall quality metrics
    quality_metrics = final_df.agg(
        count("*").alias("total_records"),
        spark_sum(when(col("is_valid_record"), 1).otherwise(0)).alias("valid_records"),
        spark_sum(when(~col("has_valid_name"), 1).otherwise(0)).alias("invalid_names"),
        spark_sum(when(~col("has_valid_email"), 1).otherwise(0)).alias("invalid_emails"),
        spark_sum(when(~col("has_valid_amount"), 1).otherwise(0)).alias("invalid_amounts"),
        spark_sum(when(~col("has_valid_location"), 1).otherwise(0)).alias("invalid_locations"),
        spark_sum(when(~col("has_valid_date"), 1).otherwise(0)).alias("invalid_dates")
    )
    
    print("\n📈 Quality Metrics:")
    quality_metrics.show(truncate=False)
    
    # Field-level statistics
    print("\n📊 Purchase Amount Statistics:")
    final_df.filter(col("has_valid_amount")).agg(
        spark_min("total_purchases").alias("min_purchase"),
        spark_max("total_purchases").alias("max_purchase"),
        avg("total_purchases").alias("avg_purchase"),
        stddev("total_purchases").alias("stddev_purchase")
    ).show(truncate=False)
    
    # Customer tier distribution
    print("\n🏆 Customer Tier Distribution:")
    final_df.filter(col("is_valid_record")).groupBy("customer_tier") \
        .agg(count("*").alias("count")) \
        .orderBy(col("count").desc()) \
        .show(truncate=False)
    
    # State-wise distribution
    print("\n🗺️ State-wise Customer Distribution:")
    final_df.filter(col("has_valid_location")).groupBy("state") \
        .agg(
            count("*").alias("customer_count"),
            spark_sum("total_purchases").alias("total_revenue")
        ) \
        .orderBy(col("total_revenue").desc()) \
        .show(truncate=False)
    
    # ============================================================================
    # LOAD: Separate valid and invalid records
    # ============================================================================
    print("\n💾 LOAD Phase: Separating Valid and Invalid Records")
    
    valid_records = final_df.filter(col("is_valid_record"))
    invalid_records = final_df.filter(~col("is_valid_record"))
    
    print(f"\n✅ Valid Records: {valid_records.count()}")
    print(f"❌ Invalid Records: {invalid_records.count()}")
    
    print("\n❌ Invalid Records Details:")
    invalid_records.select(
        "customer_id", "name", "email", "total_purchases",
        "has_valid_name", "has_valid_email", "has_valid_amount",
        "has_valid_location", "has_valid_date"
    ).show(truncate=False)
    
    print("\n✅ Job Completed Successfully!")
    print("=" * 80)
    
    spark.stop()

if __name__ == "__main__":
    main()

"""
SPARK-SUBMIT COMMANDS:

1. Basic Execution:
   spark-submit etl_pipeline_job.py

2. With Memory Configuration for Large Datasets:
   spark-submit \
     --master local[*] \
     --driver-memory 4g \
     --executor-memory 4g \
     etl_pipeline_job.py

3. With Broadcast Join Threshold (for joins):
   spark-submit \
     --master local[*] \
     --conf spark.sql.autoBroadcastJoinThreshold=10485760 \
     etl_pipeline_job.py

4. With Adaptive Query Execution (AQE):
   spark-submit \
     --master local[*] \
     --conf spark.sql.adaptive.enabled=true \
     --conf spark.sql.adaptive.coalescePartitions.enabled=true \
     --conf spark.sql.adaptive.skewJoin.enabled=true \
     etl_pipeline_job.py

5. With Compression Configuration:
   spark-submit \
     --master local[*] \
     --conf spark.sql.parquet.compression.codec=snappy \
     --conf spark.sql.orc.compression.codec=zlib \
     etl_pipeline_job.py

6. With Partition Configuration:
   spark-submit \
     --master local[*] \
     --conf spark.sql.shuffle.partitions=100 \
     --conf spark.default.parallelism=100 \
     etl_pipeline_job.py

7. For YARN with Resource Allocation:
   spark-submit \
     --master yarn \
     --deploy-mode cluster \
     --driver-memory 8g \
     --executor-memory 8g \
     --num-executors 10 \
     --executor-cores 4 \
     --conf spark.yarn.maxAppAttempts=2 \
     etl_pipeline_job.py

8. With External Dependencies (if needed):
   spark-submit \
     --master local[*] \
     --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0 \
     --jars /path/to/custom.jar \
     etl_pipeline_job.py

9. With Environment Variables:
   spark-submit \
     --master local[*] \
     --conf "spark.executorEnv.DATA_PATH=/data/input" \
     --conf "spark.executorEnv.OUTPUT_PATH=/data/output" \
     etl_pipeline_job.py

10. Complete ETL Production Configuration:
    spark-submit \
      --master local[*] \
      --name "ETL Pipeline - Data Quality" \
      --driver-memory 8g \
      --executor-memory 8g \
      --executor-cores 4 \
      --conf spark.sql.adaptive.enabled=true \
      --conf spark.sql.adaptive.coalescePartitions.enabled=true \
      --conf spark.sql.shuffle.partitions=200 \
      --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
      --conf spark.sql.parquet.compression.codec=snappy \
      --conf spark.eventLog.enabled=true \
      --conf spark.eventLog.dir=/tmp/spark-events \
      --conf spark.ui.port=4040 \
      etl_pipeline_job.py

11. With Monitoring and Metrics:
    spark-submit \
      --master local[*] \
      --conf spark.metrics.conf=/path/to/metrics.properties \
      --conf spark.sql.streaming.metricsEnabled=true \
      etl_pipeline_job.py

12. With Speculative Execution (for handling stragglers):
    spark-submit \
      --master local[*] \
      --conf spark.speculation=true \
      --conf spark.speculation.multiplier=1.5 \
      --conf spark.speculation.quantile=0.75 \
      etl_pipeline_job.py
"""
