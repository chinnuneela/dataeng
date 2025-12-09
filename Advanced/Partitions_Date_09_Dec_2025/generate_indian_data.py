"""
Author : Mukesh Date : 07-Dec-2025
Library Requirements: Dbldatagen
---------------------------------------
Generate 5GB of Indian Citizen Data using PySpark and dbldatagen
Data includes: Aadhar Number, State, Name, and other demographic fields
"""

from pyspark.sql import SparkSession
import dbldatagen as dg
from pyspark.sql.types import StringType, IntegerType, DateType, FloatType
import random

def generate_indian_citizen_data(output_path="indian_citizens_data", target_size_gb=5):
    """
    Generate Indian citizen data with realistic fields.
    
    Arguments:
        output_path: Path to save the generated data
        target_size_gb: Target size in GB (default: 5)
    """
    
    # Add Java options for Java 11 compatibility
    import os
    java_opts = "--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/jdk.internal.ref=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
    os.environ['PYSPARK_SUBMIT_ARGS'] = f'--driver-java-options "{java_opts}" pyspark-shell'
    
    # Initialize Spark Session
    spark = SparkSession.builder \
        .appName("IndianCitizenDataGenerator") \
        .config("spark.sql.shuffle.partitions", "200") \
        .config("spark.driver.memory", "4g") \
        .config("spark.executor.memory", "4g") \
        .config("spark.driver.extraJavaOptions", java_opts) \
        .config("spark.executor.extraJavaOptions", java_opts) \
        .getOrCreate()
    
    # Calculate number of rows needed (assuming ~100 bytes per row)
    num_rows = int((target_size_gb * 1024 * 1024 * 1024) / 100)
    
    print(f"Generating {num_rows:,} rows (~{target_size_gb}GB of data)...")
    print(f"Output path: {output_path}")
    
    # Indian states and their populations (for realistic distribution)
     
    
    states_distribution = """
    case 
        when rand() < 0.177 then 'Uttar Pradesh'
        when rand() < 0.320 then 'Maharashtra'
        when rand() < 0.430 then 'Bihar'
        when rand() < 0.520 then 'West Bengal'
        when rand() < 0.600 then 'Madhya Pradesh'
        when rand() < 0.670 then 'Tamil Nadu'
        when rand() < 0.730 then 'Rajasthan'
        when rand() < 0.785 then 'Karnataka'
        when rand() < 0.835 then 'Gujarat'
        when rand() < 0.880 then 'Andhra Pradesh'
        when rand() < 0.915 then 'Odisha'
        when rand() < 0.945 then 'Telangana'
        when rand() < 0.970 then 'Kerala'
        when rand() < 0.985 then 'Jharkhand'
        when rand() < 0.993 then 'Assam'
        when rand() < 0.997 then 'Punjab'
        else 'Other'
    end
    """
    
    # Common Indian first names
    first_names = ['Mukesh','Yashwanth','Amit', 'Priya', 'Rahul', 'Sneha', 'Rajesh', 'Anjali', 'Vikram', 'Pooja', 
                   'Suresh', 'Kavita', 'Arjun', 'Deepika', 'Ravi', 'Neha', 'Karan', 'Divya',
                   'Sanjay', 'Meera', 'Anil', 'Shreya', 'Manoj', 'Isha', 'Nitin', 'Ritu','Srinivas']
    
    # Common Indian last names
    last_names = ['Sharma','Suyal', 'Verma', 'Kumar', 'Singh', 'Patel', 'Reddy', 'Nair', 'Iyer',
                  'Gupta', 'Joshi', 'Rao', 'Desai', 'Kulkarni', 'Menon', 'Agarwal', 'Chopra',
                  'Malhotra', 'Kapoor', 'Mehta', 'Shah', 'Banerjee', 'Chatterjee', 'Das', 'Pillai']
    
    first_name_expr = "array(" + ",".join([f"'{name}'" for name in first_names]) + ")[cast(rand() * {0} as int)]".format(len(first_names))
    last_name_expr = "array(" + ",".join([f"'{name}'" for name in last_names]) + ")[cast(rand() * {0} as int)]".format(len(last_names))
    
    print("******************************",first_name_expr)
    print("******************************",last_name_expr)


    # Create data specification
    dataspec = (
        dg.DataGenerator(spark, name="indian_citizens", rows=num_rows, partitions=100)
        
        # Aadhar Number (12 digits, unique)
        .withColumn(
            "aadhar_number",
            StringType(),
            expr="concat(cast(cast(rand() * 9000 + 1000 as int) as string), " +
                 "cast(cast(rand() * 10000000 as int) as string))",
            uniqueValues=num_rows
        )
        
        # Name (First + Last)
        .withColumn(
            "first_name",
            StringType(),
            expr=first_name_expr
        )
        
        .withColumn(
            "last_name",
            StringType(),
            expr=last_name_expr
        )
        
        # State (distributed by population)
        .withColumn(
            "state",
            StringType(),
            expr=states_distribution
        )
        
        # Age (18-90)
        .withColumn(
            "age",
            IntegerType(),
            expr="cast(rand() * 72 + 18 as int)"
        )
        
        # Gender
        .withColumn(
            "gender",
            StringType(),
            expr="case when rand() < 0.51 then 'Male' else 'Female' end"
        )
        
        # City (generic for now)
        .withColumn(
            "city",
            StringType(),
            expr="concat('City_', cast(cast(rand() * 1000 as int) as string))"
        )
        
        # Pincode (6 digits)
        .withColumn(
            "pincode",
            StringType(),
            expr="concat(cast(cast(rand() * 900000 + 100000 as int) as string))"
        )
        
        # Mobile Number (10 digits starting with 6-9)
        .withColumn(
            "mobile_number",
            StringType(),
            expr="concat(cast(cast(rand() * 4 + 6 as int) as string), " +
                 "cast(cast(rand() * 1000000000 as int) as string))"
        )
        
        # Email
        .withColumn(
            "email",
            StringType(),
            expr="concat(lower(first_name), '.', lower(last_name), '@email.com')"
        )
        
        # Date of Birth (derived from age)
        .withColumn(
            "date_of_birth",
            DateType(),
            expr="date_sub(current_date(), age * 365 + cast(rand() * 365 as int))"
        )
        
        # Occupation
        .withColumn(
            "occupation",
            StringType(),
            expr="case " +
                 "when rand() < 0.15 then 'Software Engineer' " +
                 "when rand() < 0.25 then 'Teacher' " +
                 "when rand() < 0.35 then 'Doctor' " +
                 "when rand() < 0.45 then 'Business Owner' " +
                 "when rand() < 0.55 then 'Government Employee' " +
                 "when rand() < 0.65 then 'Farmer' " +
                 "when rand() < 0.75 then 'Student' " +
                 "when rand() < 0.85 then 'Homemaker' " +
                 "else 'Other' end"
        )
        
        # Annual Income (in INR)
        .withColumn(
            "annual_income",
            IntegerType(),
            expr="cast(rand() * 2000000 + 100000 as int)"
        )
        
        # Registration Date (last 10 years)
        .withColumn(
            "registration_date",
            DateType(),
            expr="date_sub(current_date(), cast(rand() * 3650 as int))"
        )
    )
    
    # Build the dataframe
    print("Building data specification...")
    df = dataspec.build()
    
    print("At this point, the data is generated and stored in a Spark DataFrame.")

    # Import functions module
    from pyspark.sql import functions as F
    
    # Add full name column
    df = df.withColumn("full_name", 
                       F.concat_ws(" ", df.first_name, df.last_name))
    
    # Show sample data
    print("\n" + "="*80)
    print("SAMPLE DATA:")
    print("="*80)
    df.select("aadhar_number", "full_name", "state", "age", "gender", "city", "occupation").show(20, truncate=False)
    
    # Show statistics
    print("\n" + "="*80)
    print("DATA STATISTICS:")
    print("="*80)

    
    # Synthetic data 

    print("\nState Distribution:")
    df.groupBy("state").count().orderBy("count", ascending=False).show(30)
    
    print("\nGender Distribution:")
    df.groupBy("gender").count().show()
    
    print("\nOccupation Distribution:")
    df.groupBy("occupation").count().orderBy("count", ascending=False).show()
    

    
    # Write to parquet format
    print(f"\nWriting data to {output_path}...")
    df.write.mode("overwrite").parquet(output_path)
    
    print("\n" + "="*80)
    print("DATA GENERATION COMPLETE!")
    print("="*80)
    print(f"Data written to: {output_path}")
    print(f"Total rows: {num_rows:,}")
    print(f"Format: Parquet")
    
    spark.stop()
    print("\nSpark session stopped.")


if __name__ == "__main__":
    import sys
    
    output_path = sys.argv[1] if len(sys.argv) > 1 else "indian_citizens_data"
    target_size_gb = float(sys.argv[2]) if len(sys.argv) > 2 else 5
    
    print("="*80)
    print("INDIAN CITIZEN DATA GENERATOR")
    print("="*80)
    print(f"Target Size: {target_size_gb} GB")
    print(f"Output Path: {output_path}")
    print("="*80 + "\n")
    
    generate_indian_citizen_data(output_path, target_size_gb)
