from pyspark.sql import SparkSession
import findspark
import sys,os
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)

# Add parent directory to system path
if parent_dir not in sys.path:
    sys.path.insert(0,parent_dir)

# Set environment variables for local Spark execution (User's paths)
os.environ['JAVA_HOME'] = "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
os.environ['SPARK_HOME'] = "/opt/homebrew/opt/apache-spark/libexec"

os.environ['SPARK_HOME'] = "/Users/mukesh/Desktop/Trainings/nodeB/venv/bin/pyspark"

#spark_home = "/opt/homebrew/opt/apache-spark/libexec"
#findspark.init(spark_home)

data = [1,2,3,4]

spark = SparkSession.builder \
      .appName("parallelizeexample") \
      .getOrCreate()

sc = spark.sparkContext
rdd = sc.parallelize(data)

print("RDD contents:", \
      rdd.collect())

spark.stop()

"""
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
export SPARK_HOME="/opt/homebrew/opt/apache-spark/libexec"
export PATH="$SPARK_HOME/bin:$PATH"
"""
