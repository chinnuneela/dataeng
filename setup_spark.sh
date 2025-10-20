#!/bin/bash
set -e

echo "🔥 Activating Spark + Snowflake setup for your clean venv..."

# ------------------------------
# 🐍 STEP 1 — Use existing Python venv
# ------------------------------
VENV_DIR=".venv"
if [ ! -d "$VENV_DIR" ]; then
  echo "⚠️ Virtual environment not found. Please create one first."
  exit 1
fi

source "$VENV_DIR/bin/activate"
echo "✅ Activated venv: $VENV_DIR"

# ------------------------------
# 📦 STEP 2 — Upgrade pip & wheel
# ------------------------------
echo "📦 Upgrading pip and build tools..."
pip install --upgrade pip setuptools wheel

# ------------------------------
# ⚙️ STEP 3 — Install PySpark 3.4.1 and compatible PyArrow
# ------------------------------
echo "📦 Installing PySpark 3.4.1 and PyArrow 16.1.0..."
pip install "pyspark==3.4.1" "pyarrow==16.1.0" pandas

# ------------------------------
# 🧩 STEP 4 — Download Snowflake JARs
# ------------------------------
mkdir -p jars
cd jars
echo "📥 Downloading Snowflake Spark Connector and JDBC driver..."
curl -O https://repo1.maven.org/maven2/net/snowflake/spark-snowflake_2.12/3.1.3/spark-snowflake_2.12-3.1.3.jar
curl -O https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.16.1/snowflake-jdbc-3.16.1.jar
cd ..

true <<'COMMENT'
# ------------------------------
# 🧱 STEP 5 — Create Snowflake Connector class
# ------------------------------
cat <<'PYCODE' > snowflake_connector.py
from pyspark.sql import SparkSession, DataFrame

class SnowflakeConnector:
    def __init__(self, sfOptions: dict, spark: SparkSession = None):
        self.sfOptions = sfOptions
        self.spark = spark or self._create_spark_session()

    def _create_spark_session(self):
        jars = (
            "jars/spark-snowflake_2.12-3.1.3.jar,"
            "jars/snowflake-jdbc-3.16.1.jar"
        )
        spark = SparkSession.builder \
            .appName("SnowflakeConnectorApp") \
            .master("local[*]") \
            .config("spark.jars", jars) \
            .getOrCreate()
        return spark

    def read_from_sf(self, table_name: str) -> DataFrame:
        return self.spark.read.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("dbtable", table_name) \
            .load()

    def write_spark_df_to_sf(self, df: DataFrame, table_name: str, mode: str = "overwrite"):
        df.write.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("dbtable", table_name) \
            .mode(mode) \
            .save()

    def execute_query(self, query: str) -> DataFrame:
        return self.spark.read.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("query", query) \
            .load()

    def stop(self):
        self.spark.stop()
PYCODE

# ------------------------------
# 🧪 STEP 6 — Create test script
# ------------------------------
cat <<'PYCODE' > test_snowflake_connector.py
from snowflake_connector import SnowflakeConnector
from pyspark.sql import Row

sfOptions = {
    "sfURL": "TEMTDWR-EY78543.snowflakecomputing.com",
    "sfDatabase": "TEST_DB",
    "sfSchema": "TEST_SCHEMA",
    "sfWarehouse": "COMPUTE_WH",
    "sfRole": "ACCOUNTADMIN",
    "sfUser": "CHINNUNEELA",
    "sfPassword": "Yashwanth14181418"
}

sf = SnowflakeConnector(sfOptions)

data = [Row(id=i, name=f"Name_{i}") for i in range(1, 6)]
df = sf.spark.createDataFrame(data)
df.show()

sf.write_spark_df_to_sf(df, "TEST_TABLE")
result_df = sf.read_from_sf("TEST_TABLE")
result_df.show()

sf.stop()
PYCODE

# ------------------------------
# ✅ DONE
# ------------------------------
echo ""
echo "✅ Spark + Snowflake setup complete!"
echo "👉 Run test: source $VENV_DIR/bin/activate && python test_snowflake_connector.py"
COMMENT