# A simple shell script to automate the creation of virtual environment , installing spark & compatible snowflake-connectors 
# This will also create a testfile , which need to be tested after this .
# After this script ran , activate the venv , install if any further missing dependencies like pandas etc 
# Author - Mukesh Chandra Suyal 

#!/bin/bash
set -e

echo "🚀 Starting Spark + Snowflake environment setup..."
ARCH=$(uname -m)

# ------------------------------
# 🧰 STEP 1 — Homebrew & CMake
# ------------------------------
if ! command -v brew &>/dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🛠 Ensuring CMake and Xcode CLI tools are installed..."
brew install cmake || true
xcode-select --install 2>/dev/null || true

# ------------------------------
# 🐍 STEP 2 — Python 3.12 (not 3.13)
# ------------------------------
PYTHON_BIN=$(command -v python3.12 || true)

if [ -z "$PYTHON_BIN" ]; then
  echo "🐍 Installing Python 3.12 (for Spark compatibility)..."
  brew install python@3.12
  PYTHON_BIN=$(brew --prefix python@3.12)/bin/python3.12
fi

echo "✅ Using Python: $PYTHON_BIN"

# ------------------------------
# 🌱 STEP 3 — Create virtual environment
# ------------------------------
VENV_DIR="spark_sf_env"
rm -rf "$VENV_DIR"
echo "📦 Creating new virtual environment: $VENV_DIR"
$PYTHON_BIN -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# ------------------------------
# 📦 STEP 4 — Upgrade pip & wheel
# ------------------------------
echo "📦 Upgrading pip and build tools..."
pip install --upgrade pip setuptools wheel

# ------------------------------
# ⚙️ STEP 5 — Install PySpark & PyArrow
# ------------------------------
echo "📦 Installing PySpark 3.4.1 and compatible PyArrow..."

# On ARM Macs, use prebuilt PyArrow wheels from conda-forge if needed
if [[ "$ARCH" == "arm64" ]]; then
  echo "🍎 Apple Silicon detected (ARM64) — installing ARM-compatible PyArrow..."
  pip install "pyspark==3.4.1" "pyarrow==16.1.0"
else
  pip install "pyspark==3.4.1" "pyarrow<17"
fi

# ------------------------------
# 🧩 STEP 6 — Download Snowflake JARs
# ------------------------------
mkdir -p jars
cd jars
echo "📥 Downloading Snowflake Spark Connector and JDBC driver..."
curl -O https://repo1.maven.org/maven2/net/snowflake/spark-snowflake_2.12/3.1.3/spark-snowflake_2.12-3.1.3.jar
curl -O https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.16.1/snowflake-jdbc-3.16.1.jar
cd ..

# ------------------------------
# 🧱 STEP 7 — Create Snowflake Connector class
# ------------------------------
cat <<'PYCODE' > snowflake_connector.py
from pyspark.sql import SparkSession, DataFrame

class SnowflakeConnector:
    def __init__(self, sfOptions: dict, spark: SparkSession = None):
        self.sfOptions = sfOptions
        self.spark = spark or self._create_spark_session()

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

    def read_from_sf(self, table_name: str) -> DataFrame:
        print(f"📥 Reading table: {table_name}")
        df = self.spark.read.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("dbtable", table_name) \
            .load()
        print(f"✅ Loaded {df.count()} rows.")
        return df

    def write_spark_df_to_sf(self, df: DataFrame, table_name: str, mode: str = "overwrite"):
        print(f"📤 Writing DataFrame to Snowflake table: {table_name}")
        df.write.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("dbtable", table_name) \
            .mode(mode) \
            .save()
        print("✅ Write complete!")

    def execute_query(self, query: str) -> DataFrame:
        print(f"⚙️ Executing query:\n{query}")
        df = self.spark.read.format("net.snowflake.spark.snowflake") \
            .options(**self.sfOptions) \
            .option("query", query) \
            .load()
        print(f"✅ Query returned {df.count()} rows.")
        return df

    def stop(self):
        print("🛑 Stopping Spark session...")
        self.spark.stop()
PYCODE

# ------------------------------
# 🧪 STEP 8 — Create test script
# ------------------------------
cat <<'PYCODE' > test_snowflake_connector.py
from snowflake_connector import SnowflakeConnector
from pyspark.sql import Row

# Replace with your actual Snowflake credentials
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

# Create sample DataFrame
data = [Row(id=i, name=f"Name_{i}") for i in range(1, 6)]
df = sf.spark.createDataFrame(data)
df.show()

# Write to Snowflake
sf.write_spark_df_to_sf(df, "TEST_TABLE")

# Read back
result_df = sf.read_from_sf("TEST_TABLE")
result_df.show()

sf.stop()
PYCODE

# ------------------------------
# ✅ DONE
# ------------------------------
echo ""
echo "✅ Spark + Snowflake setup complete!"
echo "👉 Activate environment: source $VENV_DIR/bin/activate"
echo "👉 Run test: python test_snowflake_connector.py"
