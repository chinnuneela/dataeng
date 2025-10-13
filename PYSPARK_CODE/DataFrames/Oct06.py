from pyspark.sql import SparkSession 

spark = SparkSession.builder.appName("Oct06").getOrCreate()

print(spark)