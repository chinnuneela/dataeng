from pyspark.sql import SparkSession

data = [1,2,3,4]

spark = SparkSession.builder.appName("parallelizeexample").getOrCreate()

sc = spark.sparkContext
rdd = sc.parallelize(data)

print("RDD contents:", rdd.collect())

spark.stop()



