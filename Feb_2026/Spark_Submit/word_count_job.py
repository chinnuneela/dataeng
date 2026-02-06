"""
PySpark Job 1: Word Count Analysis
This job demonstrates basic PySpark operations including text processing,
transformations, and aggregations.
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, split, col, lower, regexp_replace, count, desc
import sys

def main():
    # Initialize Spark Session
    spark = SparkSession.builder \
        .appName("WordCountAnalysis") \
        .getOrCreate()
    
    print("=" * 80)
    print("Starting Word Count Analysis Job")
    print("=" * 80)
    
    # Create sample data
    sample_text = [
        ("Apache Spark is a unified analytics engine for large-scale data processing.",),
        ("Spark provides high-level APIs in Java, Scala, Python and R.",),
        ("PySpark is the Python API for Apache Spark.",),
        ("Spark runs on Hadoop, Apache Mesos, Kubernetes, standalone, or in the cloud.",),
        ("Spark can access diverse data sources including HDFS, Cassandra, HBase, and S3.",)
    ]
    
    # Create DataFrame
    df = spark.createDataFrame(sample_text, ["text"])
    
    print("\n📄 Original Text Data:")
    df.show(truncate=False)
    
    # Word count analysis
    words_df = df.select(
        explode(split(lower(regexp_replace(col("text"), "[^a-zA-Z\\s]", "")), "\\s+")).alias("word")
    ).filter(col("word") != "")
    
    word_count_df = words_df.groupBy("word") \
        .agg(count("*").alias("count")) \
        .orderBy(desc("count"))
    
    print("\n📊 Word Count Results:")
    word_count_df.show(20, truncate=False)
    
    # Statistics
    total_words = words_df.count()
    unique_words = word_count_df.count()
    
    print(f"\n📈 Statistics:")
    print(f"   Total Words: {total_words}")
    print(f"   Unique Words: {unique_words}")
    
    # Top 5 most frequent words
    print("\n🏆 Top 5 Most Frequent Words:")
    word_count_df.limit(5).show(truncate=False)
    
    print("\n✅ Job Completed Successfully!")
    print("=" * 80)
    
    spark.stop()

if __name__ == "__main__":
    main()

"""
SPARK-SUBMIT COMMANDS:

1. Basic Local Mode (Default):
   spark-submit word_count_job.py

2. Local Mode with Specific Cores:
   spark-submit --master local[4] word_count_job.py

3. Local Mode with All Available Cores:
   spark-submit --master local[*] word_count_job.py

4. With Driver Memory Configuration:
   spark-submit \
     --master local[*] \
     --driver-memory 2g \
     word_count_job.py

5. With Executor Configuration (for cluster mode):
   spark-submit \
     --master local[*] \
     --driver-memory 2g \
     --executor-memory 2g \
     --executor-cores 2 \
     word_count_job.py

6. With Application Name and Verbose Output:
   spark-submit \
     --master local[*] \
     --name "Word Count Analysis" \
     --driver-memory 2g \
     --verbose \
     word_count_job.py

7. With Spark Configuration Properties:
   spark-submit \
     --master local[*] \
     --conf spark.sql.shuffle.partitions=10 \
     --conf spark.default.parallelism=8 \
     word_count_job.py

8. For YARN Cluster (if available):
   spark-submit \
     --master yarn \
     --deploy-mode cluster \
     --driver-memory 2g \
     --executor-memory 2g \
     --executor-cores 2 \
     --num-executors 3 \
     word_count_job.py

9. For Standalone Cluster (if available):
   spark-submit \
     --master spark://master-host:7077 \
     --deploy-mode client \
     --driver-memory 2g \
     --executor-memory 2g \
     --total-executor-cores 8 \
     word_count_job.py

10. With Python Dependencies (if needed):
    spark-submit \
      --master local[*] \
      --py-files dependencies.zip \
      word_count_job.py
"""
