"""
PySpark Job 2: Sales Data Analysis
This job demonstrates DataFrame operations, aggregations, window functions,
and data analysis on sales data.
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum, avg, count, round, max, min, year, month
from pyspark.sql.window import Window
from pyspark.sql.functions import row_number, rank, dense_rank
import sys

def main():
    # Initialize Spark Session
    spark = SparkSession.builder \
        .appName("SalesDataAnalysis") \
        .getOrCreate()
    
    print("=" * 80)
    print("Starting Sales Data Analysis Job")
    print("=" * 80)
    
    # Create sample sales data
    sales_data = [
        (1, "2024-01-15", "Electronics", "Laptop", 1200.00, 2),
        (2, "2024-01-20", "Electronics", "Mouse", 25.00, 5),
        (3, "2024-02-10", "Clothing", "Shirt", 45.00, 3),
        (4, "2024-02-15", "Electronics", "Keyboard", 75.00, 4),
        (5, "2024-03-05", "Clothing", "Jeans", 60.00, 2),
        (6, "2024-03-10", "Electronics", "Monitor", 300.00, 1),
        (7, "2024-03-20", "Books", "Python Guide", 50.00, 10),
        (8, "2024-04-01", "Electronics", "Laptop", 1200.00, 1),
        (9, "2024-04-15", "Clothing", "Shoes", 80.00, 2),
        (10, "2024-05-10", "Books", "Data Science", 65.00, 5),
        (11, "2024-05-20", "Electronics", "Tablet", 450.00, 3),
        (12, "2024-06-05", "Clothing", "Jacket", 120.00, 1),
    ]
    
    columns = ["order_id", "order_date", "category", "product", "price", "quantity"]
    
    # Create DataFrame
    df = spark.createDataFrame(sales_data, columns)
    
    # Convert order_date to date type
    df = df.withColumn("order_date", col("order_date").cast("date"))
    
    # Calculate total amount
    df = df.withColumn("total_amount", round(col("price") * col("quantity"), 2))
    
    print("\n📊 Sales Data:")
    df.show(truncate=False)
    
    # Analysis 1: Sales by Category
    print("\n💰 Total Sales by Category:")
    category_sales = df.groupBy("category") \
        .agg(
            sum("total_amount").alias("total_sales"),
            count("order_id").alias("num_orders"),
            avg("total_amount").alias("avg_order_value")
        ) \
        .orderBy(col("total_sales").desc())
    
    category_sales.show(truncate=False)
    
    # Analysis 2: Top Products by Revenue
    print("\n🏆 Top 5 Products by Revenue:")
    product_sales = df.groupBy("product") \
        .agg(
            sum("total_amount").alias("total_revenue"),
            sum("quantity").alias("total_quantity")
        ) \
        .orderBy(col("total_revenue").desc()) \
        .limit(5)
    
    product_sales.show(truncate=False)
    
    # Analysis 3: Monthly Sales Trend
    print("\n📈 Monthly Sales Trend:")
    df_with_month = df.withColumn("year", year("order_date")) \
                      .withColumn("month", month("order_date"))
    
    monthly_sales = df_with_month.groupBy("year", "month") \
        .agg(sum("total_amount").alias("monthly_revenue")) \
        .orderBy("year", "month")
    
    monthly_sales.show(truncate=False)
    
    # Analysis 4: Window Function - Rank Products by Category
    print("\n🎯 Product Ranking within Each Category:")
    window_spec = Window.partitionBy("category").orderBy(col("total_amount").desc())
    
    ranked_df = df.withColumn("rank", rank().over(window_spec)) \
                  .select("category", "product", "total_amount", "rank") \
                  .orderBy("category", "rank")
    
    ranked_df.show(20, truncate=False)
    
    # Overall Statistics
    print("\n📊 Overall Statistics:")
    stats = df.agg(
        sum("total_amount").alias("total_revenue"),
        count("order_id").alias("total_orders"),
        avg("total_amount").alias("avg_order_value"),
        max("total_amount").alias("max_order_value"),
        min("total_amount").alias("min_order_value")
    )
    stats.show(truncate=False)
    
    print("\n✅ Job Completed Successfully!")
    print("=" * 80)
    
    spark.stop()

if __name__ == "__main__":
    main()

"""
SPARK-SUBMIT COMMANDS:

1. Basic Execution:
   spark-submit sales_analysis_job.py

2. With Memory and Core Configuration:
   spark-submit \
     --master 'local[*]' \
     --driver-memory 4g \
     --executor-memory 4g \
     sales_analysis_job.py

3. With Dynamic Allocation (for cluster):
   spark-submit \
     --master 'local[*]' \
     --conf spark.dynamicAllocation.enabled=true \
     --conf spark.dynamicAllocation.minExecutors=1 \
     --conf spark.dynamicAllocation.maxExecutors=5 \
     sales_analysis_job.py

4. With Shuffle Partitions Optimization:
   spark-submit \
     --master local[*] \
     --conf spark.sql.shuffle.partitions=20 \
     --conf spark.sql.adaptive.enabled=true \
     --conf spark.sql.adaptive.coalescePartitions.enabled=true \
     sales_analysis_job.py

5. With Logging Configuration:
   spark-submit \
     --master local[*] \
     --driver-memory 2g \
     --conf spark.driver.extraJavaOptions="-Dlog4j.configuration=file:log4j.properties" \
     sales_analysis_job.py

6. For YARN with Queue Specification:
   spark-submit \
     --master yarn \
     --deploy-mode cluster \
     --queue production \
     --driver-memory 4g \
     --executor-memory 4g \
     --num-executors 5 \
     --executor-cores 4 \
     sales_analysis_job.py

7. With Spark UI Port Configuration:
   spark-submit \
     --master local[*] \
     --conf spark.ui.port=4050 \
     sales_analysis_job.py

8. With Kryo Serialization (Performance):
   spark-submit \
     --master local[*] \
     --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
     --conf spark.kryo.registrationRequired=false \
     sales_analysis_job.py

9. With Event Log for History Server:
   spark-submit \
     --master local[*] \
     --conf spark.eventLog.enabled=true \
     --conf spark.eventLog.dir=/tmp/spark-events \
     sales_analysis_job.py

10. Complete Production Configuration:
    spark-submit \
      --master local[*] \
      --name "Sales Data Analysis - Production" \
      --driver-memory 4g \
      --executor-memory 4g \
      --executor-cores 4 \
      --conf spark.sql.shuffle.partitions=50 \
      --conf spark.sql.adaptive.enabled=true \
      --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
      --conf spark.eventLog.enabled=true \
      --conf spark.eventLog.dir=/tmp/spark-events \
      sales_analysis_job.py
"""
