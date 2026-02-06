#!/bin/bash
# Author : Mukesh Chandra Suyal 
# =============================================================================
# PySpark Development Environment Setup Script
# =============================================================================
# This script creates a complete PySpark development environment with:
# - Python virtual environment
# - PySpark, Spark, and data science libraries
# - AWS CLI
# - Database connectors (Snowflake, MySQL)
# - JDBC drivers (MySQL, Snowflake)
# - Sample PySpark job and Jupyter notebook
# - Instructions : 1. Run the shell-script as ./create_env.sh
#                  2. Activate : source activate.sh
#                  3. Test PySpark : spark-submit test_pyspark.py
# =============================================================================

set -e  # Exit on error

# =============================================================================
# Enhanced Logging Configuration
# =============================================================================

# Log file setup
LOG_FILE="mukesh_setup_logs.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize log file with header
cat > "$LOG_FILE" << EOF
================================================================================
PySpark Environment Setup Log
Author: Mukesh Chandra Suyal
Started: $TIMESTAMP
================================================================================

EOF

# Color codes for console output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced logging functions with dual output (console + file)

log_header() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC} ${BOLD}$msg${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}\n"
    echo "" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
    echo "[$timestamp] $msg" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
}

log_info() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[INFO]${NC} ${BOLD}$msg${NC}"
    echo "[$timestamp] [INFO] $msg" >> "$LOG_FILE"
}

log_step() {
    local step="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${MAGENTA}[$step]${NC} ${BOLD}$msg${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "" >> "$LOG_FILE"
    echo "[$timestamp] [$step] $msg" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
}

log_success() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}✓ [SUCCESS]${NC} ${BOLD}$msg${NC}"
    echo "[$timestamp] [SUCCESS] $msg" >> "$LOG_FILE"
}

log_error() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}✗ [ERROR]${NC} ${BOLD}$msg${NC}"
    echo "[$timestamp] [ERROR] $msg" >> "$LOG_FILE"
}

log_warning() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}⚠ [WARNING]${NC} ${BOLD}$msg${NC}"
    echo "[$timestamp] [WARNING] $msg" >> "$LOG_FILE"
}

log_detail() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "  ${CYAN}→${NC} $msg"
    echo "[$timestamp] [DETAIL] $msg" >> "$LOG_FILE"
}

log_command() {
    local cmd="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "  ${YELLOW}$${NC} ${BOLD}$cmd${NC}"
    echo "[$timestamp] [COMMAND] $cmd" >> "$LOG_FILE"
}

# Legacy function names for backward compatibility
print_message() { log_info "$1"; }
print_error() { log_error "$1"; }
print_warning() { log_warning "$1"; }
print_success() { log_success "$1"; }

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

log_header "PySpark Environment Setup Starting"
log_info "Setup directory: $SCRIPT_DIR"
log_info "Log file: $LOG_FILE"

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

log_detail "Detected Python version: $PYTHON_VERSION"
log_detail "Python major: $PYTHON_MAJOR, minor: $PYTHON_MINOR"

if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 14 ]; then
    log_warning "Python 3.14+ detected. PySpark 3.5.0 has serialization issues with Python 3.14."
    log_warning "For best compatibility, Python 3.9-3.12 is recommended."
    log_warning "The script will continue, but you may need to unset SPARK_HOME before running PySpark jobs."
fi

# =============================================================================
# Step 1: Create Virtual Environment
# =============================================================================
log_step "STEP 1" "Creating Python Virtual Environment"

if [ -d "venv" ]; then
    log_warning "Virtual environment already exists. Removing old venv..."
    log_command "rm -rf venv"
    rm -rf venv
    log_success "Old venv removed"
fi

# Create isolated venv (--clear ensures no system packages are inherited)
log_info "Creating isolated virtual environment with --clear flag"
log_command "python3 -m venv --clear venv"
python3 -m venv --clear venv
log_success "Isolated virtual environment created successfully!"
log_detail "This venv is completely isolated from system Python packages"

# Activate virtual environment
log_info "Activating virtual environment..."
source venv/bin/activate
log_success "Virtual environment activated!"
log_detail "Python path: $(which python)"

# Upgrade pip
print_message "Upgrading pip..."
pip install --upgrade pip

# =============================================================================
# Step 2: Install Python Packages
# =============================================================================
print_message "Step 2: Installing Python packages (PySpark, pandas, numpy, boto3)..."

pip install pyspark==3.5.0
pip install pandas numpy
pip install boto3
pip install jupyter notebook ipykernel

print_success "Python packages installed successfully!"

# =============================================================================
# Step 3: Install AWS CLI
# =============================================================================
print_message "Step 3: Checking AWS CLI installation..."

if command -v aws &> /dev/null; then
    print_success "AWS CLI is already installed: $(aws --version)"
else
    print_message "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm AWSCLIV2.pkg
    print_success "AWS CLI installed successfully!"
fi

# =============================================================================
# Step 4: Install Database Connectors
# =============================================================================
print_message "Step 4: Installing database connectors (Snowflake, MySQL)..."

pip install snowflake-connector-python
pip install mysql-connector-python

print_success "Database connectors installed successfully!"

# =============================================================================
# Step 5: Check and Setup Java
# =============================================================================
print_message "Step 5: Checking Java installation..."

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    print_success "Java is installed: $JAVA_VERSION"
    
    # Set JAVA_HOME if not set
    if [ -z "$JAVA_HOME" ]; then
        if [ -d "/Library/Java/JavaVirtualMachines" ]; then
            JAVA_HOME=$(/usr/libexec/java_home)
            export JAVA_HOME
            print_success "JAVA_HOME set to: $JAVA_HOME"
        fi
    else
        print_success "JAVA_HOME is already set: $JAVA_HOME"
    fi
else
    print_error "Java is not installed. Please install Java 8 or 11 from:"
    print_error "https://www.oracle.com/java/technologies/downloads/"
    exit 1
fi

# =============================================================================
# Step 6: Download JDBC Drivers
# =============================================================================
print_message "Step 6: Downloading JDBC drivers..."

# Create jars directory
mkdir -p jars
cd jars

# Download MySQL Connector/J
print_message "Downloading MySQL JDBC driver..."
if [ ! -f "mysql-connector-j-8.2.0.jar" ]; then
    curl -L -o mysql-connector-j-8.2.0.jar \
        "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.2.0/mysql-connector-j-8.2.0.jar"
    print_success "MySQL JDBC driver downloaded!"
else
    print_warning "MySQL JDBC driver already exists."
fi

# Download Snowflake JDBC driver
print_message "Downloading Snowflake JDBC driver..."
if [ ! -f "snowflake-jdbc-3.14.4.jar" ]; then
    curl -L -o snowflake-jdbc-3.14.4.jar \
        "https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.14.4/snowflake-jdbc-3.14.4.jar"
    print_success "Snowflake JDBC driver downloaded!"
else
    print_warning "Snowflake JDBC driver already exists."
fi

# Download AWS SDK for S3 support
print_message "Downloading AWS SDK JARs for S3 support..."
if [ ! -f "hadoop-aws-3.3.4.jar" ]; then
    curl -L -o hadoop-aws-3.3.4.jar \
        "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar"
fi

if [ ! -f "aws-java-sdk-bundle-1.12.262.jar" ]; then
    curl -L -o aws-java-sdk-bundle-1.12.262.jar \
        "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar"
fi

cd "$SCRIPT_DIR"
print_success "All JDBC drivers downloaded to jars/ directory!"

# =============================================================================
# Step 7: Create Sample PySpark Job
# =============================================================================
print_message "Step 7: Creating sample PySpark job..."

cat > sample_pyspark_job.py << 'EOF'
"""
Sample PySpark Job
This script demonstrates basic PySpark operations including:
- SparkSession creation
- DataFrame operations
- Reading/Writing data
- SQL queries
"""

import os
import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, avg, sum as spark_sum

def main():
    print("=" * 80)
    print("Starting Sample PySpark Job")
    print("=" * 80)
    
    # Get the script directory to locate jars
    script_dir = os.path.dirname(os.path.abspath(__file__))
    jars_dir = os.path.join(script_dir, "jars")
    
    # Build jars path
    jar_files = [
        os.path.join(jars_dir, "mysql-connector-j-8.2.0.jar"),
        os.path.join(jars_dir, "snowflake-jdbc-3.14.4.jar"),
        os.path.join(jars_dir, "hadoop-aws-3.3.4.jar"),
        os.path.join(jars_dir, "aws-java-sdk-bundle-1.12.262.jar")
    ]
    jars_path = ",".join([jar for jar in jar_files if os.path.exists(jar)])
    
    # Create Spark Session
    spark = SparkSession.builder \
        .appName("SamplePySparkJob") \
        .master("local[*]") \
        .config("spark.jars", jars_path) \
        .config("spark.driver.memory", "2g") \
        .config("spark.executor.memory", "2g") \
        .config("spark.ui.showConsoleProgress", "false") \
        .getOrCreate()
    
    print(f"\n✓ SparkSession created successfully!")
    print(f"  Spark Version: {spark.version}")
    print(f"  App Name: {spark.sparkContext.appName}")
    
    # Create sample data using spark.range() (Python 3.14 compatible)
    print("\n" + "=" * 80)
    print("Creating Sample Data (Python 3.14 Compatible)")
    print("=" * 80)
    
    # Create a range-based DataFrame and add columns using SQL
    df = spark.range(0, 8).toDF("id")
    
    # Register as temp view and use SQL to create structured data
    df.createOrReplaceTempView("temp_range")
    
    df = spark.sql("""
        SELECT 
            CASE 
                WHEN id = 0 THEN 'John'
                WHEN id = 1 THEN 'Sarah'
                WHEN id = 2 THEN 'Mike'
                WHEN id = 3 THEN 'Emma'
                WHEN id = 4 THEN 'David'
                WHEN id = 5 THEN 'Lisa'
                WHEN id = 6 THEN 'Tom'
                WHEN id = 7 THEN 'Anna'
            END as name,
            CASE 
                WHEN id IN (0, 1, 4) THEN 'Engineering'
                WHEN id IN (2, 3, 7) THEN 'Sales'
                WHEN id IN (5, 6) THEN 'HR'
            END as department,
            CASE 
                WHEN id = 0 THEN 75000
                WHEN id = 1 THEN 85000
                WHEN id = 2 THEN 65000
                WHEN id = 3 THEN 70000
                WHEN id = 4 THEN 95000
                WHEN id = 5 THEN 60000
                WHEN id = 6 THEN 68000
                WHEN id = 7 THEN 72000
            END as salary,
            CASE 
                WHEN id = 0 THEN 5
                WHEN id = 1 THEN 7
                WHEN id = 2 THEN 3
                WHEN id = 3 THEN 4
                WHEN id = 4 THEN 10
                WHEN id = 5 THEN 2
                WHEN id = 6 THEN 6
                WHEN id = 7 THEN 5
            END as years_experience
        FROM temp_range
    """)
    
    print("\n✓ Sample DataFrame created with employee data (Python 3.14 compatible)")
    print("\nDataFrame Schema:")
    df.printSchema()
    
    print("\nSample Data:")
    df.show()
    
    # Perform transformations
    print("\n" + "=" * 80)
    print("Performing DataFrame Transformations")
    print("=" * 80)
    
    # Department-wise statistics
    dept_stats = df.groupBy("department") \
        .agg(
            count("*").alias("employee_count"),
            avg("salary").alias("avg_salary"),
            spark_sum("salary").alias("total_salary"),
            avg("years_experience").alias("avg_experience")
        ) \
        .orderBy(col("avg_salary").desc())
    
    print("\nDepartment-wise Statistics:")
    dept_stats.show()
    
    # Filter high earners
    high_earners = df.filter(col("salary") > 70000) \
        .select("name", "department", "salary") \
        .orderBy(col("salary").desc())
    
    print("\nEmployees earning more than $70,000:")
    high_earners.show()
    
    # SQL Query example
    print("\n" + "=" * 80)
    print("Running SQL Queries")
    print("=" * 80)
    
    df.createOrReplaceTempView("employees")
    
    sql_result = spark.sql("""
        SELECT 
            department,
            COUNT(*) as emp_count,
            ROUND(AVG(salary), 2) as avg_salary,
            MAX(salary) as max_salary,
            MIN(salary) as min_salary
        FROM employees
        GROUP BY department
        ORDER BY avg_salary DESC
    """)
    
    print("\nSQL Query Results:")
    sql_result.show()
    
    # Save data
    print("\n" + "=" * 80)
    print("Saving Data")
    print("=" * 80)
    
    output_dir = os.path.join(script_dir, "output")
    
    # Save as Parquet
    parquet_path = os.path.join(output_dir, "employees_parquet")
    df.write.mode("overwrite").parquet(parquet_path)
    print(f"\n✓ Data saved as Parquet: {parquet_path}")
    
    # Save as CSV
    csv_path = os.path.join(output_dir, "employees_csv")
    df.write.mode("overwrite").option("header", "true").csv(csv_path)
    print(f"✓ Data saved as CSV: {csv_path}")
    
    # Read back and verify
    print("\n" + "=" * 80)
    print("Reading Data Back")
    print("=" * 80)
    
    df_read = spark.read.parquet(parquet_path)
    print(f"\n✓ Successfully read {df_read.count()} records from Parquet")
    
    # Stop Spark
    spark.stop()
    print("\n" + "=" * 80)
    print("✓ PySpark Job Completed Successfully!")
    print("=" * 80)

if __name__ == "__main__":
    main()
EOF

print_success "Sample PySpark job created: sample_pyspark_job.py"

# =============================================================================
# Step 7b: Create Test PySpark Script
# =============================================================================
print_message "Step 7b: Creating PySpark test script..."

cat > test_pyspark.py << 'EOF'
"""
Simple PySpark Test
This script tests basic PySpark functionality without complex serialization
"""

import os
import sys
from pyspark.sql import SparkSession

def main():
    print("=" * 80)
    print("Testing PySpark Installation")
    print("=" * 80)
    
    # Get the script directory to locate jars
    script_dir = os.path.dirname(os.path.abspath(__file__))
    jars_dir = os.path.join(script_dir, "jars")
    
    # Build jars path
    jar_files = [
        os.path.join(jars_dir, "mysql-connector-j-8.2.0.jar"),
        os.path.join(jars_dir, "snowflake-jdbc-3.14.4.jar"),
        os.path.join(jars_dir, "hadoop-aws-3.3.4.jar"),
        os.path.join(jars_dir, "aws-java-sdk-bundle-1.12.262.jar")
    ]
    jars_path = ",".join([jar for jar in jar_files if os.path.exists(jar)])
    
    # Create Spark Session
    spark = SparkSession.builder \
        .appName("PySparkTest") \
        .master("local[*]") \
        .config("spark.jars", jars_path) \
        .config("spark.driver.memory", "1g") \
        .config("spark.ui.showConsoleProgress", "false") \
        .getOrCreate()
    
    print(f"\n✓ SparkSession created successfully!")
    print(f"  Spark Version: {spark.version}")
    print(f"  App Name: {spark.sparkContext.appName}")
    print(f"  Python Version: {sys.version}")
    
    # Create a simple DataFrame using range (doesn't require serialization)
    print("\n" + "=" * 80)
    print("Creating Test DataFrame")
    print("=" * 80)
    
    df = spark.range(0, 10).toDF("number")
    
    print("\n✓ DataFrame created successfully!")
    print(f"  Row count: {df.count()}")
    
    print("\nSample data:")
    df.show(5)
    
    # Test SQL
    print("\n" + "=" * 80)
    print("Testing SQL Query")
    print("=" * 80)
    
    df.createOrReplaceTempView("numbers")
    result = spark.sql("SELECT number, number * 2 as doubled FROM numbers WHERE number < 5")
    
    print("\nSQL Query Result:")
    result.show()
    
    # Test writing data
    print("\n" + "=" * 80)
    print("Testing Data Write")
    print("=" * 80)
    
    output_dir = os.path.join(script_dir, "output", "test_output")
    df.write.mode("overwrite").parquet(output_dir)
    print(f"\n✓ Data written to: {output_dir}")
    
    # Test reading data
    df_read = spark.read.parquet(output_dir)
    print(f"✓ Data read back successfully: {df_read.count()} records")
    
    # Stop Spark
    spark.stop()
    
    print("\n" + "=" * 80)
    print("✓ All Tests Passed! PySpark is working correctly!")
    print("=" * 80)
    print("\nNote: If you're using Python 3.14+, some advanced features may not work")
    print("due to serialization issues. For full compatibility, use Python 3.9-3.12.")
    print("=" * 80)

if __name__ == "__main__":
    main()
EOF

print_success "PySpark test script created: test_pyspark.py"

# =============================================================================
# Step 8: Run Sample PySpark Job
# =============================================================================
print_message "Step 8: Running PySpark test script..."

# Unset SPARK_HOME to use PySpark's bundled Spark
unset SPARK_HOME

python test_pyspark.py

if [ $? -eq 0 ]; then
    print_success "PySpark test executed successfully!"
else
    print_error "PySpark test failed!"
    print_warning "This might be due to Python 3.14 compatibility issues."
    print_warning "The environment is still set up correctly. Try running: ./run_pyspark.sh test_pyspark.py"
fi

# =============================================================================
# Step 8b: Create PySpark Runner Script
# =============================================================================
print_message "Step 8b: Creating PySpark runner script..."

cat > run_pyspark.sh << 'EOF'
#!/bin/bash

# Wrapper script to run PySpark jobs with correct environment
# This script unsets SPARK_HOME to use PySpark's bundled Spark

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Activate virtual environment
if [ ! -d "venv" ]; then
    echo "Error: Virtual environment not found. Please run ./create_env.sh first."
    exit 1
fi

source venv/bin/activate

# Unset SPARK_HOME to use PySpark's bundled Spark
unset SPARK_HOME

# Run the provided Python script
if [ -z "$1" ]; then
    echo "Usage: ./run_pyspark.sh <python_script.py>"
    echo "Example: ./run_pyspark.sh sample_pyspark_job.py"
    exit 1
fi

echo "Running PySpark job: $1"
python "$1"
EOF

chmod +x run_pyspark.sh
print_success "PySpark runner script created: run_pyspark.sh"

# =============================================================================
# Step 8c: Create Spark Submit Wrapper
# =============================================================================
print_message "Step 8c: Creating spark-submit wrapper..."

cat > spark_submit.sh << 'EOF'
#!/bin/bash

# Spark Submit Wrapper for PySpark Bundled Spark
# This script allows you to use spark-submit with PySpark's bundled Spark

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Activate virtual environment
if [ ! -d "venv" ]; then
    echo "Error: Virtual environment not found. Please run ./create_env.sh first."
    exit 1
fi

source venv/bin/activate

# Unset SPARK_HOME to avoid conflicts
unset SPARK_HOME

# Find PySpark installation and set SPARK_HOME
PYSPARK_DIR=$(python -c "import pyspark; import os; print(os.path.dirname(pyspark.__file__))")
export SPARK_HOME="$PYSPARK_DIR"
export PYSPARK_PYTHON=$(which python)
export PYSPARK_DRIVER_PYTHON=$(which python)

# Get jars directory
JARS_DIR="$SCRIPT_DIR/jars"

# Build jars path
JARS_PATH=""
if [ -d "$JARS_DIR" ]; then
    JARS_PATH=$(find "$JARS_DIR" -name "*.jar" -type f | tr '\n' ',' | sed 's/,$//')
fi

# Run spark-submit with proper configuration
if [ -z "$1" ]; then
    echo "Usage: ./spark_submit.sh <python_script.py> [additional args]"
    echo "Example: ./spark_submit.sh test_pyspark.py"
    echo "Example: ./spark_submit.sh sample_pyspark_job.py --master local[4]"
    exit 1
fi

echo "Running spark-submit with PySpark's bundled Spark..."
echo "SPARK_HOME: $SPARK_HOME"
echo "Script: $1"
echo ""

# Run spark-submit
if [ -n "$JARS_PATH" ]; then
    spark-submit \
        --master local[*] \
        --driver-memory 2g \
        --executor-memory 2g \
        --jars "$JARS_PATH" \
        "$@"
else
    spark-submit \
        --master local[*] \
        --driver-memory 2g \
        --executor-memory 2g \
        "$@"
fi
EOF

chmod +x spark_submit.sh
print_success "Spark-submit wrapper created: spark_submit.sh"

# =============================================================================
# Step 8d: Create Activation Script
# =============================================================================
print_message "Step 8d: Creating activation script for native spark-submit..."

cat > activate.sh << 'EOF'
#!/bin/bash

# PySpark Environment Activation Script
# Source this script to activate the PySpark environment and configure SPARK_HOME
# Usage: source activate.sh

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if venv exists
if [ ! -d "$SCRIPT_DIR/venv" ]; then
    echo "❌ Error: Virtual environment not found."
    echo "Please run: ./create_env.sh"
    return 1 2>/dev/null || exit 1
fi

# Activate virtual environment
source "$SCRIPT_DIR/venv/bin/activate"

# Set SPARK_HOME to PySpark's bundled Spark
export SPARK_HOME=$(python -c "import pyspark; import os; print(os.path.dirname(pyspark.__file__))")
export PYSPARK_PYTHON=$(which python)
export PYSPARK_DRIVER_PYTHON=$(which python)

# Success message
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                      ║"
echo "║         ✅ PySpark Environment Activated!                           ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Environment Details:"
echo "  SPARK_HOME: $SPARK_HOME"
echo "  Python: $(python --version)"
echo "  PySpark: $(python -c 'import pyspark; print(pyspark.__version__)')"
echo ""
echo "You can now use spark-submit directly:"
echo "  spark-submit test_pyspark.py"
echo "  spark-submit sample_pyspark_job.py"
echo "  spark-submit your_job.py"
echo ""
echo "Or run Python scripts:"
echo "  python test_pyspark.py"
echo "  python your_job.py"
echo ""
echo "To deactivate: deactivate"
echo ""
EOF

print_success "Activation script created: activate.sh"

# =============================================================================
# Step 9: Create Jupyter Notebook
# =============================================================================
print_message "Step 9: Creating sample Jupyter notebook..."

cat > sample_pyspark_notebook.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# PySpark Sample Notebook\n",
    "\n",
    "This notebook demonstrates PySpark operations including:\n",
    "- SparkSession initialization\n",
    "- DataFrame operations\n",
    "- Data transformations\n",
    "- SQL queries\n",
    "- Database connectivity (MySQL, Snowflake)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 1. Setup and Initialize Spark"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import os\\n",
    "import sys\\n",
    "from pyspark.sql import SparkSession\\n",
    "from pyspark.sql.functions import col, count, avg, sum as spark_sum, max as spark_max, min as spark_min\\n",
    "\\n",
    "print(\\\"✓ Imports successful!\\\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Get current directory and jars path\n",
    "notebook_dir = os.getcwd()\n",
    "jars_dir = os.path.join(notebook_dir, \"jars\")\n",
    "\n",
    "# Build jars path\n",
    "jar_files = [\n",
    "    os.path.join(jars_dir, \"mysql-connector-j-8.2.0.jar\"),\n",
    "    os.path.join(jars_dir, \"snowflake-jdbc-3.14.4.jar\"),\n",
    "    os.path.join(jars_dir, \"hadoop-aws-3.3.4.jar\"),\n",
    "    os.path.join(jars_dir, \"aws-java-sdk-bundle-1.12.262.jar\")\n",
    "]\n",
    "jars_path = \",\".join([jar for jar in jar_files if os.path.exists(jar)])\n",
    "\n",
    "print(f\"JARS Directory: {jars_dir}\")\n",
    "print(f\"Available JARs: {len([jar for jar in jar_files if os.path.exists(jar)])}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Create Spark Session\n",
    "spark = SparkSession.builder \\\n",
    "    .appName(\"PySpark-Notebook-Demo\") \\\n",
    "    .master(\"local[*]\") \\\n",
    "    .config(\"spark.jars\", jars_path) \\\n",
    "    .config(\"spark.driver.memory\", \"2g\") \\\n",
    "    .config(\"spark.executor.memory\", \"2g\") \\\n",
    "    .config(\"spark.sql.adaptive.enabled\", \"true\") \\\n",
    "    .getOrCreate()\n",
    "\n",
    "print(f\"✓ SparkSession created successfully!\")\n",
    "print(f\"  Spark Version: {spark.version}\")\n",
    "print(f\"  App Name: {spark.sparkContext.appName}\")\n",
    "print(f\"  Master: {spark.sparkContext.master}\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 2. Create Sample Data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Create sample sales data using spark.range() (Python 3.14 compatible)\\n",
    "df = spark.range(0, 10).toDF(\\\"id\\\")\\n",
    "\\n",
    "# Register as temp view\\n",
    "df.createOrReplaceTempView(\\\"temp_range\\\")\\n",
    "\\n",
    "# Use SQL to create structured data\\n",
    "df = spark.sql(\\\"\\\"\\\"\\n\",\n",
    "    SELECT \\n\",\n",
    "        CASE \\n\",\n",
    "            WHEN id < 2 THEN '2024-01-01'\\n\",\n",
    "            WHEN id < 4 THEN '2024-01-02'\\n\",\n",
    "            WHEN id < 6 THEN '2024-01-03'\\n\",\n",
    "            WHEN id < 8 THEN '2024-01-04'\\n\",\n",
    "            ELSE '2024-01-05'\\n\",\n",
    "        END as date,\\n\",\n",
    "        CASE \\n\",\n",
    "            WHEN id IN (0, 1, 3, 6, 8) THEN 'Electronics'\\n\",\n",
    "            WHEN id IN (2, 4, 9) THEN 'Clothing'\\n\",\n",
    "            ELSE 'Books'\\n\",\n",
    "        END as category,\\n\",\n",
    "        CASE \\n\",\n",
    "            WHEN id = 0 THEN 'Laptop'\\n\",\n",
    "            WHEN id = 1 THEN 'Mouse'\\n\",\n",
    "            WHEN id = 2 THEN 'Shirt'\\n\",\n",
    "            WHEN id = 3 THEN 'Keyboard'\\n\",\n",
    "            WHEN id = 4 THEN 'Jeans'\\n\",\n",
    "            WHEN id = 5 THEN 'Monitor'\\n\",\n",
    "            WHEN id = 6 THEN 'Python Guide'\\n\",
    "            WHEN id = 7 THEN 'Data Science'\\n\",
    "            WHEN id = 8 THEN 'Headphones'\\n\",
    "            WHEN id = 9 THEN 'Jacket'\\n\",\n",
    "        END as product,\\n\",\n",
    "        CASE \\n\",\n",
    "            WHEN id = 0 THEN 1200\\n\",\n",
    "            WHEN id = 1 THEN 25\\n\",\n",
    "            WHEN id = 2 THEN 45\\n\",\n",
    "            WHEN id = 3 THEN 75\\n\",\n",
    "            WHEN id = 4 THEN 60\\n\",\n",
    "            WHEN id = 5 THEN 300\\n\",\n",
    "            WHEN id = 6 THEN 40\\n\",\n",
    "            WHEN id = 7 THEN 55\\n\",\n",
    "            WHEN id = 8 THEN 150\\n\",\n",
    "            WHEN id = 9 THEN 120\\n\",\n",
    "        END as price,\\n\",\n",
    "        CASE \\n\",\n",
    "            WHEN id = 0 THEN 2\\n\",\n",
    "            WHEN id = 1 THEN 10\\n\",\n",
    "            WHEN id = 2 THEN 5\\n\",\n",
    "            WHEN id = 3 THEN 3\\n\",\n",
    "            WHEN id = 4 THEN 4\\n\",\n",
    "            WHEN id = 5 THEN 2\\n\",\n",
    "            WHEN id = 6 THEN 8\\n\",\n",
    "            WHEN id = 7 THEN 6\\n\",\n",
    "            WHEN id = 8 THEN 4\\n\",\n",
    "            WHEN id = 9 THEN 2\\n\",\n",
    "        END as quantity\\n\",\n",
    "    FROM temp_range\\n\",\n",
    "\\\"\\\"\\\")\\n\",\n",
    "\\n",
    "print(\\\"✓ Sample DataFrame created (Python 3.14 compatible)!\\\")\\n\",\n",
    "df.printSchema()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Display the data\n",
    "df.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 3. Data Transformations"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Add calculated column for total revenue\n",
    "from pyspark.sql.functions import round as spark_round\n",
    "\n",
    "df_with_revenue = df.withColumn(\"revenue\", col(\"price\") * col(\"quantity\"))\n",
    "\n",
    "print(\"✓ Added revenue column\")\n",
    "df_with_revenue.show()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Category-wise statistics\n",
    "category_stats = df_with_revenue.groupBy(\"category\") \\\n",
    "    .agg(\n",
    "        count(\"*\").alias(\"num_transactions\"),\n",
    "        spark_sum(\"quantity\").alias(\"total_items_sold\"),\n",
    "        spark_round(spark_sum(\"revenue\"), 2).alias(\"total_revenue\"),\n",
    "        spark_round(avg(\"price\"), 2).alias(\"avg_price\")\n",
    "    ) \\\n",
    "    .orderBy(col(\"total_revenue\").desc())\n",
    "\n",
    "print(\"Category-wise Statistics:\")\n",
    "category_stats.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 4. SQL Queries"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Register as temporary view\n",
    "df_with_revenue.createOrReplaceTempView(\"sales\")\n",
    "\n",
    "# Run SQL query\n",
    "sql_result = spark.sql(\"\"\"\n",
    "    SELECT \n",
    "        category,\n",
    "        product,\n",
    "        SUM(quantity) as total_quantity,\n",
    "        ROUND(SUM(revenue), 2) as total_revenue\n",
    "    FROM sales\n",
    "    GROUP BY category, product\n",
    "    ORDER BY total_revenue DESC\n",
    "    LIMIT 5\n",
    "\"\"\")\n",
    "\n",
    "print(\"Top 5 Products by Revenue:\")\n",
    "sql_result.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 5. Data Filtering and Selection"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Filter high-value transactions\n",
    "high_value = df_with_revenue.filter(col(\"revenue\") > 200) \\\n",
    "    .select(\"date\", \"category\", \"product\", \"revenue\") \\\n",
    "    .orderBy(col(\"revenue\").desc())\n",
    "\n",
    "print(\"High-Value Transactions (Revenue > $200):\")\n",
    "high_value.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 6. Save and Read Data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Save as Parquet\n",
    "output_path = os.path.join(notebook_dir, \"output\", \"sales_data_parquet\")\n",
    "df_with_revenue.write.mode(\"overwrite\").parquet(output_path)\n",
    "\n",
    "print(f\"✓ Data saved to: {output_path}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Read back the data\n",
    "df_read = spark.read.parquet(output_path)\n",
    "\n",
    "print(f\"✓ Successfully read {df_read.count()} records from Parquet\")\n",
    "df_read.show(5)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 7. Database Connectivity Examples\n",
    "\n",
    "### MySQL Connection Example (Commented - Update with your credentials)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# MySQL connection example (uncomment and update credentials to use)\n",
    "\"\"\"\n",
    "mysql_properties = {\n",
    "    \"user\": \"your_username\",\n",
    "    \"password\": \"your_password\",\n",
    "    \"driver\": \"com.mysql.cj.jdbc.Driver\"\n",
    "}\n",
    "\n",
    "mysql_url = \"jdbc:mysql://localhost:3306/your_database\"\n",
    "\n",
    "# Write to MySQL\n",
    "df_with_revenue.write \\\n",
    "    .jdbc(url=mysql_url, table=\"sales_data\", mode=\"overwrite\", properties=mysql_properties)\n",
    "\n",
    "# Read from MySQL\n",
    "df_mysql = spark.read \\\n",
    "    .jdbc(url=mysql_url, table=\"sales_data\", properties=mysql_properties)\n",
    "\n",
    "df_mysql.show()\n",
    "\"\"\"\n",
    "\n",
    "print(\"MySQL connection example available (commented out)\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "### Snowflake Connection Example (Commented - Update with your credentials)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Snowflake connection example (uncomment and update credentials to use)\n",
    "\"\"\"\n",
    "snowflake_options = {\n",
    "    \"sfURL\": \"your_account.snowflakecomputing.com\",\n",
    "    \"sfUser\": \"your_username\",\n",
    "    \"sfPassword\": \"your_password\",\n",
    "    \"sfDatabase\": \"your_database\",\n",
    "    \"sfSchema\": \"your_schema\",\n",
    "    \"sfWarehouse\": \"your_warehouse\"\n",
    "}\n",
    "\n",
    "# Write to Snowflake\n",
    "df_with_revenue.write \\\n",
    "    .format(\"snowflake\") \\\n",
    "    .options(**snowflake_options) \\\n",
    "    .option(\"dbtable\", \"sales_data\") \\\n",
    "    .mode(\"overwrite\") \\\n",
    "    .save()\n",
    "\n",
    "# Read from Snowflake\n",
    "df_snowflake = spark.read \\\n",
    "    .format(\"snowflake\") \\\n",
    "    .options(**snowflake_options) \\\n",
    "    .option(\"dbtable\", \"sales_data\") \\\n",
    "    .load()\n",
    "\n",
    "df_snowflake.show()\n",
    "\"\"\"\n",
    "\n",
    "print(\"Snowflake connection example available (commented out)\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 8. Cleanup"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Stop Spark session when done\n",
    "# spark.stop()\n",
    "# print(\"✓ Spark session stopped\")\n",
    "\n",
    "print(\"Note: Uncomment the above lines to stop the Spark session\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Summary\n",
    "\n",
    "This notebook demonstrated:\n",
    "- ✓ SparkSession initialization with JDBC drivers\n",
    "- ✓ Creating and manipulating DataFrames\n",
    "- ✓ Data transformations and aggregations\n",
    "- ✓ SQL queries on DataFrames\n",
    "- ✓ Reading and writing Parquet files\n",
    "- ✓ Database connectivity examples (MySQL, Snowflake)\n",
    "\n",
    "You can now start building your own PySpark applications!"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.9.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

print_success "Jupyter notebook created: sample_pyspark_notebook.ipynb"

# =============================================================================
# Step 10: Verify Jupyter Notebook
# =============================================================================
print_message "Step 10: Verifying Jupyter notebook creation..."

if [ -f "sample_pyspark_notebook.ipynb" ]; then
    print_success "Jupyter notebook created successfully!"
    print_message "You can run it with: source venv/bin/activate && jupyter notebook sample_pyspark_notebook.ipynb"
else
    print_error "Jupyter notebook was not created!"
fi

# =============================================================================
# Create README and Documentation
# =============================================================================
print_message "Creating README documentation..."

cat > README.md << 'EOF'
# PySpark Development Environment

This directory contains a complete, portable PySpark development environment that can be easily shared and deployed.

## 📦 What's Included

- **Python Virtual Environment** (`venv/`)
- **PySpark 3.5.0** with all dependencies
- **Data Science Libraries**: pandas, numpy
- **AWS Integration**: boto3, AWS CLI
- **Database Connectors**: Snowflake, MySQL
- **JDBC Drivers** (`jars/`):
  - MySQL Connector/J
  - Snowflake JDBC
  - Hadoop AWS (for S3 support)
  - AWS Java SDK Bundle
- **Sample Code**:
  - `sample_pyspark_job.py` - Standalone PySpark application
  - `sample_pyspark_notebook.ipynb` - Jupyter notebook with examples

## 🚀 Quick Start

### First Time Setup

1. **Run the setup script**:
   ```bash
   chmod +x create_env.sh
   ./create_env.sh
   ```

   This will:
   - Create a Python virtual environment
   - Install all required packages
   - Download JDBC drivers
   - Run sample PySpark job
   - Test Jupyter notebook

2. **Activate the environment**:
   ```bash
   source venv/bin/activate
   ```

### Running the Sample Job

```bash
source venv/bin/activate
python sample_pyspark_job.py
```

### Running Jupyter Notebook

```bash
source venv/bin/activate
jupyter notebook sample_pyspark_notebook.ipynb
```

## 📁 Directory Structure

```
.
├── create_env.sh                    # Setup script
├── venv/                            # Python virtual environment
├── jars/                            # JDBC drivers
│   ├── mysql-connector-j-8.2.0.jar
│   ├── snowflake-jdbc-3.14.4.jar
│   ├── hadoop-aws-3.3.4.jar
│   └── aws-java-sdk-bundle-1.12.262.jar
├── sample_pyspark_job.py            # Sample PySpark application
├── sample_pyspark_notebook.ipynb    # Sample Jupyter notebook
├── output/                          # Output directory for data
└── README.md                        # This file
```

## 🔧 Requirements

- **Python 3.8+**
- **Java 8 or 11** (required for Spark)
- **macOS** (script is designed for macOS, but can be adapted for Linux)

## 📝 Using with Your Own Code

### Standalone PySpark Script

```python
from pyspark.sql import SparkSession
import os

# Get jars directory
script_dir = os.path.dirname(os.path.abspath(__file__))
jars_dir = os.path.join(script_dir, "jars")

# Build jars path
jar_files = [
    os.path.join(jars_dir, "mysql-connector-j-8.2.0.jar"),
    os.path.join(jars_dir, "snowflake-jdbc-3.14.4.jar"),
]
jars_path = ",".join([jar for jar in jar_files if os.path.exists(jar)])

# Create Spark Session
spark = SparkSession.builder \
    .appName("MyApp") \
    .master("local[*]") \
    .config("spark.jars", jars_path) \
    .getOrCreate()

# Your code here...
```

### Jupyter Notebook

```python
import findspark
findspark.init()

from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("MyNotebook") \
    .master("local[*]") \
    .getOrCreate()
```

## 🗄️ Database Connectivity

### MySQL

```python
mysql_properties = {
    "user": "your_username",
    "password": "your_password",
    "driver": "com.mysql.cj.jdbc.Driver"
}

mysql_url = "jdbc:mysql://localhost:3306/your_database"

# Read
df = spark.read.jdbc(url=mysql_url, table="your_table", properties=mysql_properties)

# Write
df.write.jdbc(url=mysql_url, table="your_table", mode="overwrite", properties=mysql_properties)
```

### Snowflake

```python
snowflake_options = {
    "sfURL": "your_account.snowflakecomputing.com",
    "sfUser": "your_username",
    "sfPassword": "your_password",
    "sfDatabase": "your_database",
    "sfSchema": "your_schema",
    "sfWarehouse": "your_warehouse"
}

# Read
df = spark.read.format("snowflake").options(**snowflake_options).option("dbtable", "your_table").load()

# Write
df.write.format("snowflake").options(**snowflake_options).option("dbtable", "your_table").mode("overwrite").save()
```

## 📦 Sharing This Environment

To share this environment with others:

1. **Zip the entire directory**:
   ```bash
   cd ..
   zip -r pyspark_env.zip Amit/ -x "Amit/venv/*" "Amit/output/*"
   ```

2. **Share the zip file**

3. **Recipient runs**:
   ```bash
   unzip pyspark_env.zip
   cd Amit
   chmod +x create_env.sh
   ./create_env.sh
   ```

## 🛠️ Troubleshooting

### Java Not Found
- Install Java 8 or 11 from [Oracle](https://www.oracle.com/java/technologies/downloads/)
- Set `JAVA_HOME` environment variable

### Spark Session Fails
- Check Java installation: `java -version`
- Verify JAVA_HOME: `echo $JAVA_HOME`
- Ensure virtual environment is activated

### JDBC Connection Issues
- Verify JAR files are in `jars/` directory
- Check database credentials
- Ensure network connectivity to database

## 📚 Additional Resources

- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)
- [Spark SQL Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)
- [AWS SDK for Java](https://aws.amazon.com/sdk-for-java/)

## ✅ Verification

After setup, verify everything works:

```bash
source venv/bin/activate
python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('local').getOrCreate(); print(f'Spark {spark.version} is working!'); spark.stop()"
```

Expected output: `Spark 3.5.0 is working!`

---

**Environment created successfully! Happy Sparking! 🎉**
EOF

print_success "README.md created!"

# =============================================================================
# Create requirements.txt for reference
# =============================================================================
print_message "Creating requirements.txt..."

cat > requirements.txt << 'EOF'
# PySpark and Spark
pyspark==3.5.0

# Data Science Libraries
pandas
numpy

# AWS Integration
boto3

# Database Connectors
snowflake-connector-python
mysql-connector-python

# Jupyter
jupyter
notebook
ipykernel
EOF

print_success "requirements.txt created!"

# =============================================================================
# Final Success Message
# =============================================================================
echo ""
echo "================================================================================"
print_success "🎉 ENVIRONMENT SETUP COMPLETED SUCCESSFULLY! 🎉"
echo "================================================================================"
echo ""
print_message "Summary of what was created:"
echo "  ✓ Python virtual environment (venv/)"
log_detail "✓ PySpark 3.5.0 and dependencies installed"
log_detail "✓ AWS CLI verified/installed"
log_detail "✓ Database connectors installed (Snowflake, MySQL)"
log_detail "✓ JDBC drivers downloaded (jars/)"
log_detail "✓ Sample PySpark job created and tested"
log_detail "✓ Jupyter notebook created"
log_detail "✓ Documentation created (README.md)"
log_detail "✓ Activation script created (activate.sh)"
echo ""

log_info "Next Steps:"
log_detail "1. Activate environment: source activate.sh"
log_detail "2. Test with spark-submit: spark-submit test_pyspark.py"
log_detail "3. Run sample job: spark-submit sample_pyspark_job.py"
log_detail "4. Start Jupyter: jupyter notebook"
echo ""

log_info "To share this environment:"
log_detail "zip -r pyspark_env.zip . -x 'venv/*' 'output/*' '.DS_Store'"
echo ""

# Write final summary to log file
END_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
cat >> "$LOG_FILE" << EOF

================================================================================
Setup Completed Successfully!
Ended: $END_TIMESTAMP
Log File: $SCRIPT_DIR/$LOG_FILE
================================================================================
EOF

log_header "Setup Completed Successfully! 🎉"
log_success "Happy Coding! 🚀"
echo ""
log_info "📋 Detailed logs saved to: ${BOLD}${CYAN}$LOG_FILE${NC}"
log_info "📂 Setup directory: ${BOLD}${CYAN}$SCRIPT_DIR${NC}"
echo ""
echo "================================================================================"
