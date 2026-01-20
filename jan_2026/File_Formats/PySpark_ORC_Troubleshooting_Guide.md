# PySpark ORC Notebook Troubleshooting Guide

**Date:** 2026-01-18  
**Environment:** macOS (Apple Silicon), Homebrew installations  
**Issue:** Jupyter notebook cells not executing (hanging) when initializing PySpark

---

## Problem Symptoms

1. **Notebook cells hanging indefinitely** during PySpark initialization
2. **KeyboardInterrupt errors** when manually stopping the execution
3. SparkSession `.getOrCreate()` never completing
4. No visible error messages, just indefinite waiting

**Error observed in notebook:**
```
Initializing PySpark...
(hangs here indefinitely)
KeyboardInterrupt during: spark = SparkSession.builder ... .getOrCreate()
```

---

## Environment Details

### Installation Paths
```bash
# Spark Installation
/opt/homebrew/Cellar/apache-spark/4.1.1/
/opt/homebrew/opt/apache-spark -> ../Cellar/apache-spark/4.1.1

# Key Discovery: Actual Spark Python libraries are in:
/opt/homebrew/opt/apache-spark/libexec/

# Java Installation
/opt/homebrew/Cellar/openjdk@17/17.0.16/libexec/openjdk.jdk/Contents/Home
/opt/homebrew/opt/openjdk@17 -> ../Cellar/openjdk@17/17.0.16

# Python Virtual Environment
/Users/mukesh/Desktop/Trainings/nodeB/dataeng/jan_2026/.venv/
Python 3.14.0 (experimental version)
```

### Installed Packages
```bash
pyspark==4.1.1
pandas==2.3.3
pyarrow==22.0.0
numpy==2.4.1
findspark==2.0.1 (added during troubleshooting)
```

---

## Diagnostic Steps Taken

### Step 1: Verify Spark and Java Installations
```bash
# Check Spark installation
ls -d /opt/homebrew/Cellar/apache-spark/4.1.1

# Check Java installation
ls -d /opt/homebrew/Cellar/openjdk@17/17.0.16/libexec/openjdk.jdk/Contents/Home

# Verify Java version
/opt/homebrew/Cellar/openjdk@17/17.0.16/libexec/openjdk.jdk/Contents/Home/bin/java -version
# Output: openjdk version "17.0.16"
```

✅ **Result:** Both Spark and Java were correctly installed.

---

### Step 2: Test Python Environment
```bash
# Check Python version
/Users/mukesh/Desktop/Trainings/nodeB/dataeng/jan_2026/.venv/bin/python3 --version
# Output: Python 3.14.0

# Check PySpark installation
/Users/mukesh/Desktop/Trainings/nodeB/dataeng/jan_2026/.venv/bin/pip show pyspark
# Output: Version: 4.1.1
```

⚠️ **Finding:** Python 3.14.0 is a very new/experimental version and may have compatibility issues.

---

### Step 3: Test Spark Initialization Standalone
Created test script to isolate the issue:

```python
# test_spark.py
import os
import sys
from pyspark.sql import SparkSession

os.environ['SPARK_HOME'] = '/opt/homebrew/Cellar/apache-spark/4.1.1'
os.environ['JAVA_HOME'] = '/opt/homebrew/Cellar/openjdk@17/17.0.16/libexec/openjdk.jdk/Contents/Home'
os.environ['PYSPARK_PYTHON'] = sys.executable

spark = SparkSession.builder.appName("Test").getOrCreate()
print(f"Version: {spark.version}")
spark.stop()
```

❌ **Result:** Script hung indefinitely at `.getOrCreate()` with no output.

---

### Step 4: Investigate SPARK_HOME Path Issue

```bash
# Check what's inside Homebrew Spark installation
ls -F /opt/homebrew/Cellar/apache-spark/4.1.1
# Output:
# INSTALL_RECEIPT.json    bin/
# LICENSE                 libexec/
# NOTICE                  sbom.spdx.json
# README.md

# Key discovery: The actual Spark distribution is inside libexec!
ls -F /opt/homebrew/Cellar/apache-spark/4.1.1/libexec/
# Contains: bin/, conf/, python/, jars/, etc.

# Check for py4j library (required by PySpark)
ls /opt/homebrew/Cellar/apache-spark/4.1.1/libexec/python/lib/
# Output:
# PY4J_LICENSE.txt
# py4j-0.10.9.9-src.zip  ← This is required!
# pyspark.zip
```

🔍 **Root Cause Found:** 
- SPARK_HOME was set to `/opt/homebrew/Cellar/apache-spark/4.1.1`
- But the actual Python libraries are in `/opt/homebrew/Cellar/apache-spark/4.1.1/libexec/`
- PySpark couldn't find the `py4j` library, causing silent hang

---

### Step 5: Test with findspark

```bash
# Install findspark
/Users/mukesh/Desktop/Trainings/nodeB/dataeng/jan_2026/.venv/bin/pip install findspark

# Test with correct path
python3 -c "import findspark; findspark.init('/opt/homebrew/opt/apache-spark/libexec'); print('Success')"
# Output: Success ✓
```

✅ **Finding:** `findspark` can correctly locate Spark when given the `libexec` path.

---

### Step 6: Test Missing Master Configuration

Created test with explicit master setting:

```python
# test_spark_v2.py
spark = SparkSession.builder \
    .master("local[*]") \  # ← Added this
    .appName("TestV2") \
    .getOrCreate()
```

✅ **Result:** Adding `.master("local[*]")` prevents Spark from waiting for a cluster manager.

---

### Step 7: Check Homebrew Wrapper Scripts

```bash
# Inspect Homebrew's wrapper script
cat /opt/homebrew/opt/apache-spark/bin/find-spark-home
# Output shows:
# JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home}"

# Also check spark-submit wrapper
head -n 20 /opt/homebrew/opt/apache-spark/bin/spark-submit
# Output:
# #!/bin/bash
# JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home}"
```

⚠️ **Finding:** Homebrew's wrapper scripts default to Java 21, but we want Java 17 for better compatibility.

---

## Root Causes Identified

### Primary Issues:

1. **Incorrect SPARK_HOME Path**
   - **Symptom:** Silent hang during SparkSession initialization
   - **Cause:** SPARK_HOME pointed to `/opt/homebrew/Cellar/apache-spark/4.1.1` instead of the `libexec` subdirectory
   - **Why it matters:** PySpark looks for `python/lib/py4j-*.zip` under SPARK_HOME, which only exists in the `libexec` directory

2. **Missing Master Configuration**
   - **Symptom:** Spark waiting indefinitely for cluster manager
   - **Cause:** No `.master()` configuration in SparkSession builder
   - **Why it matters:** Without explicit master, Spark may try to connect to non-existent cluster manager

3. **Missing findspark Library**
   - **Symptom:** PYTHONPATH not correctly set for PySpark libraries
   - **Cause:** `findspark` not installed in virtual environment
   - **Why it matters:** `findspark` automatically configures sys.path and environment variables for PySpark

### Secondary Issues:

4. **Python 3.14 Compatibility**
   - **Risk:** Python 3.14 is experimental and may have serialization issues with PySpark
   - **Recommendation:** Use Python 3.12 for production workloads

---

## Solutions Applied

### Fix 1: Update SPARK_HOME to libexec Directory

**Before:**
```python
os.environ['SPARK_HOME'] = '/opt/homebrew/Cellar/apache-spark/4.1.1'
```

**After:**
```python
os.environ['SPARK_HOME'] = '/opt/homebrew/opt/apache-spark/libexec'
```

✅ **Impact:** PySpark can now find required libraries (py4j, pyspark modules)

---

### Fix 2: Add findspark Initialization

**Added:**
```python
try:
    import findspark
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "findspark"])
    import findspark

# Initialize findspark with correct SPARK_HOME
findspark.init(os.environ['SPARK_HOME'])
```

✅ **Impact:** Automatically sets up PYTHONPATH and environment variables

---

### Fix 3: Add Explicit Master Configuration

**Before:**
```python
spark = SparkSession.builder \
    .appName("ORC_Format_Demo") \
    .config("spark.sql.orc.enabled", "true") \
    .getOrCreate()
```

**After:**
```python
spark = SparkSession.builder \
    .master("local[*]") \  # ← Added
    .appName("ORC_Format_Demo") \
    .config("spark.sql.orc.enabled", "true") \
    .getOrCreate()
```

✅ **Impact:** Spark runs in local mode without waiting for external cluster manager

---

### Fix 4: Use Stable Java Home Path

**Updated:**
```python
os.environ['JAVA_HOME'] = '/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home'
```

✅ **Impact:** Uses Java 17 (more stable than Java 21 for Spark 4.1.1)

---

## Complete Fixed Initialization Code

```python
# Set environment variables for PySpark
import os
import sys
try:
    import findspark
except ImportError:
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "findspark"])
    import findspark

# Set Spark and Java homes using standard Homebrew paths
# For Spark 4.1.1 on Apple Silicon, the real home is in libexec
os.environ['SPARK_HOME'] = '/opt/homebrew/opt/apache-spark/libexec'
os.environ['JAVA_HOME'] = '/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home'
os.environ['PYSPARK_PYTHON'] = sys.executable

# Initialize findspark
findspark.init(os.environ['SPARK_HOME'])

# Suppress verbose logging
import logging
logging.basicConfig(level=logging.ERROR)

# Import required libraries
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DoubleType, BooleanType, TimestampType
import pyspark.sql.functions as F
from datetime import datetime, timedelta
import pandas as pd

print("Initializing PySpark...")

# Initialize SparkSession with master("local[*]") to prevent hanging
spark = SparkSession.builder \
    .master("local[*]") \
    .appName("ORC_Format_Demo") \
    .config("spark.sql.orc.enabled", "true") \
    .config("spark.driver.memory", "1g") \
    .config("spark.executor.memory", "1g") \
    .config("spark.sql.shuffle.partitions", "4") \
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")

print("✓ SparkSession initialized successfully!")
print(f"Spark version: {spark.version}")
print("✓ ORC format support enabled")
print("✓ All operations will use PySpark")
```

---

## Verification Steps

### 1. Test Spark Initialization
```bash
cd /Users/mukesh/Desktop/Trainings/nodeB/dataeng/jan_2026/File_Formats
/Users/mukesh/Desktop/Trainings/nodeB/dataeng/jan_2026/.venv/bin/python3 -c "
import os, sys
os.environ['SPARK_HOME'] = '/opt/homebrew/opt/apache-spark/libexec'
os.environ['JAVA_HOME'] = '/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home'
import findspark
findspark.init(os.environ['SPARK_HOME'])
from pyspark.sql import SparkSession
spark = SparkSession.builder.master('local[*]').getOrCreate()
print(f'✓ Spark {spark.version} initialized successfully')
spark.stop()
"
```

Expected output:
```
✓ Spark 4.1.1 initialized successfully
```

### 2. Test ORC File Reading
```python
from pyspark.sql import SparkSession
import os

os.environ['SPARK_HOME'] = '/opt/homebrew/opt/apache-spark/libexec'
spark = SparkSession.builder.master("local[*]").getOrCreate()

# Test reading existing ORC file
df = spark.read.format("orc").load("/path/to/employees.orc")
df.show()
spark.stop()
```

---

## Best Practices for Future Reference

### 1. Homebrew Spark Installation Paths
When using Homebrew on macOS:
- **Never use** `/opt/homebrew/Cellar/apache-spark/X.X.X` as SPARK_HOME
- **Always use** `/opt/homebrew/opt/apache-spark/libexec` as SPARK_HOME
- **Reason:** The actual Spark distribution is in the `libexec` subdirectory

### 2. Always Specify Master in Local Development
```python
# ✓ GOOD - Explicit local master
spark = SparkSession.builder.master("local[*]").getOrCreate()

# ✗ BAD - No master specified (may hang)
spark = SparkSession.builder.getOrCreate()
```

### 3. Use findspark for Reliable Setup
```python
import findspark
findspark.init('/opt/homebrew/opt/apache-spark/libexec')
```
This automatically handles PYTHONPATH and environment variable setup.

### 4. Python Version Compatibility
- **Recommended:** Python 3.10, 3.11, or 3.12
- **Experimental:** Python 3.13+ (may have serialization issues)
- **Check compatibility:** Before upgrading Python, verify PySpark support

### 5. Required Environment Variables
```bash
export SPARK_HOME=/opt/homebrew/opt/apache-spark/libexec
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PYSPARK_PYTHON=/path/to/your/venv/bin/python3
```

### 6. Minimal Spark Configuration for Notebooks
```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName("MyNotebook") \
    .config("spark.driver.memory", "1g") \
    .config("spark.sql.shuffle.partitions", "4") \
    .getOrCreate()
```

### 7. Set Log Level to Reduce Noise
```python
spark.sparkContext.setLogLevel("ERROR")
```

---

## Common Troubleshooting Commands

### Check if Spark is accessible
```bash
export SPARK_HOME=/opt/homebrew/opt/apache-spark/libexec
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
$SPARK_HOME/bin/pyspark --version
```

### Verify py4j is accessible
```bash
ls $SPARK_HOME/python/lib/py4j-*.zip
# Should output: /opt/homebrew/opt/apache-spark/libexec/python/lib/py4j-0.10.9.9-src.zip
```

### Test findspark location
```bash
python3 -c "import findspark; findspark.init('/opt/homebrew/opt/apache-spark/libexec'); print('✓ Success')"
```

### Check Java is working
```bash
$JAVA_HOME/bin/java -version
```

### Verify PySpark installation
```bash
python3 -c "import pyspark; print(pyspark.__version__)"
```

---

## Known Issues & Workarounds

### Issue 1: "Unable to find py4j" Error
**Error Message:**
```
Exception: Unable to find py4j in /opt/homebrew/opt/apache-spark/python, your SPARK_HOME may not be configured correctly
```

**Cause:** SPARK_HOME doesn't include `/libexec`

**Fix:**
```python
os.environ['SPARK_HOME'] = '/opt/homebrew/opt/apache-spark/libexec'
```

---

### Issue 2: RecursionError with Python 3.14
**Error Message:**
```
RecursionError: maximum recursion depth exceeded during pickling
```

**Cause:** Python 3.14 compatibility issues with PySpark serialization

**Fix:** Use Python 3.12:
```bash
python3.12 -m venv .venv_312
source .venv_312/bin/activate
pip install pyspark findspark pandas pyarrow
```

---

### Issue 3: Jupyter Kernel Dies During Spark Initialization
**Symptom:** Kernel crashes with no error message

**Possible Causes:**
1. Insufficient memory
2. Java version incompatibility
3. Missing JAVA_HOME

**Fix:**
```python
# Reduce memory requirements
spark = SparkSession.builder \
    .master("local[2]") \  # Limit to 2 cores instead of all
    .config("spark.driver.memory", "512m") \  # Reduce memory
    .getOrCreate()
```

---

### Issue 4: Homebrew Java Wrapper Scripts
Homebrew's Spark wrapper scripts may default to Java 21. Override this:

```bash
# Check wrapper default
head -2 /opt/homebrew/opt/apache-spark/bin/spark-submit

# Always set JAVA_HOME explicitly in Python
os.environ['JAVA_HOME'] = '/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home'
```

---

## Quick Reference Checklist

Before running PySpark notebooks:

- [ ] Verify SPARK_HOME points to `libexec`: `/opt/homebrew/opt/apache-spark/libexec`
- [ ] Verify JAVA_HOME is set to Java 17
- [ ] Install `findspark` in your virtual environment
- [ ] Add `.master("local[*]")` to SparkSession builder
- [ ] Set log level to ERROR to reduce output noise
- [ ] Use Python 3.12 or earlier for stability
- [ ] Test initialization with a simple script before running notebooks

---

## Additional Resources

### Official Documentation
- [PySpark Installation Guide](https://spark.apache.org/docs/latest/api/python/getting_started/install.html)
- [Spark Configuration](https://spark.apache.org/docs/latest/configuration.html)
- [findspark Documentation](https://github.com/minrk/findspark)

### Homebrew Spark Notes
- Homebrew installs Spark in a non-standard structure
- Always use symlinks in `/opt/homebrew/opt/` for stability
- The `libexec` directory contains the actual Spark distribution

---

## Document History

| Date       | Version | Changes                                      |
|------------|---------|----------------------------------------------|
| 2026-01-18 | 1.0     | Initial troubleshooting guide created        |

---

**Created by:** Antigravity AI Assistant  
**For:** PySpark ORC Notebook Troubleshooting Reference
