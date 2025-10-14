from pyspark.sql import SparkSession, DataFrame
import snowflake.connector


class SnowflakeConnector:
    def __init__(self, sfOptions: dict, spark: SparkSession = None):
        self.sfOptions = sfOptions
        self.spark = spark or self._create_spark_session()

    # -------------------------------------------------------------------------
    # 1️⃣ Create Spark Session with required Snowflake JARs
    # -------------------------------------------------------------------------
    def _create_spark_session(self):
        print("🔧 Creating SparkSession with Snowflake JARs...")
        jars = (
            "jars/spark-snowflake_2.12-3.1.3.jar,"
            "jars/snowflake-jdbc-3.16.1.jar"
        )
        spark = SparkSession.builder \
            .appName("SnowflakeConnectorApp") \
            .master("local[*]") \
            .config("spark.jars", jars) \
            .getOrCreate()
        print("✅ SparkSession created (version:", spark.version, ")")
        return spark

    # -------------------------------------------------------------------------
    # 2️⃣ Read from Snowflake table
    # -------------------------------------------------------------------------
    def read_from_sf(self, table_name: str) -> DataFrame:
        print(f"📥 Reading table: {table_name}")
        df = self.spark.read.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("dbtable", table_name) \
            .load()
        print(f"✅ Loaded {df.count()} rows.")
        return df

    # -------------------------------------------------------------------------
    # 3️⃣ Write Spark DataFrame to Snowflake (overwrite)
    # -------------------------------------------------------------------------
    def write_spark_df_to_sf(self, df: DataFrame, table_name: str, mode: str = "overwrite"):
        print(f"📤 Writing DataFrame to Snowflake table: {table_name} (mode={mode})")
        df.write.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("dbtable", table_name) \
            .mode(mode) \
            .save()
        print("✅ Write complete!")

    # -------------------------------------------------------------------------
    # 3a️⃣ Append Spark DataFrame to Snowflake table
    # -------------------------------------------------------------------------
    def append_spark_df_to_sf(self, df: DataFrame, table_name: str):
        """Append DataFrame to an existing Snowflake table"""
        print(f"📤 Appending DataFrame to Snowflake table: {table_name}")
        self.write_spark_df_to_sf(df, table_name, mode="append")

    # -------------------------------------------------------------------------
    # 4️⃣ Execute SQL query (DDL/DML) on Snowflake
    # -------------------------------------------------------------------------
    def execute_query(self, query: str):
        print(f"⚙️ Executing query:\n{query}\n")
        try:
            conn = snowflake.connector.connect(
                user=self.sfOptions["sfUser"],
                password=self.sfOptions["sfPassword"],
                account=self.sfOptions["sfURL"].split('.')[0],
                warehouse=self.sfOptions.get("sfWarehouse"),
                database=self.sfOptions.get("sfDatabase"),
                schema=self.sfOptions.get("sfSchema"),
                role=self.sfOptions.get("sfRole")
            )
            cursor = conn.cursor()
            cursor.execute(query)

            try:
                result = cursor.fetchall()  # SELECT returns results
            except snowflake.connector.errors.ProgrammingError:
                result = None

            cursor.close()
            conn.close()
            return result

        except Exception as e:
            print(f"❌ Query failed: {e}")
            raise

    # -------------------------------------------------------------------------
    # 4a️⃣ Execute SELECT query and return Spark DataFrame
    # -------------------------------------------------------------------------
    def read_query_as_df(self, query: str) -> DataFrame:
        """Execute SELECT query and return result as Spark DataFrame"""
        print(f"📥 Executing query and returning DataFrame:\n{query}")
        df = self.spark.read.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("query", query) \
            .load()
        print(f"✅ Query returned {df.count()} rows")
        return df

    # -------------------------------------------------------------------------
    # 5️⃣ Load CSV or JSON file and write to Snowflake
    # -------------------------------------------------------------------------
    def write_to_table_from_file(self, file_path: str, table_name: str, file_format: str = "csv", header: bool = True, mode: str = "overwrite"):
        print(f"📂 Loading file: {file_path}")
        if file_format.lower() == "csv":
            df = self.spark.read.option("header", header).csv(file_path)
        elif file_format.lower() == "json":
            df = self.spark.read.json(file_path)
        else:
            raise ValueError("Unsupported file format. Use 'csv' or 'json'.")
        print(f"✅ File loaded with {df.count()} rows. Writing to Snowflake table {table_name}...")
        self.write_spark_df_to_sf(df, table_name, mode=mode)
        print(f"✅ Successfully written {file_path} → {table_name} in Snowflake.")

    # -------------------------------------------------------------------------
    # 6️⃣ Load Parquet file and write to Snowflake
    # -------------------------------------------------------------------------
    def write_parquet_to_sf(self, parquet_path: str, table_name: str, mode: str = "overwrite"):
        print(f"📂 Loading Parquet file: {parquet_path}")
        df = self.spark.read.parquet(parquet_path)
        print(f"✅ Parquet file loaded with {df.count()} rows. Writing to Snowflake table {table_name}...")
        self.write_spark_df_to_sf(df, table_name, mode=mode)
        print(f"✅ Successfully written {parquet_path} → {table_name} in Snowflake.")

    # -------------------------------------------------------------------------
    # 7️⃣ Stop Spark session
    # -------------------------------------------------------------------------
    def stop(self):
        print("🛑 Stopping Spark session...")
        self.spark.stop()
