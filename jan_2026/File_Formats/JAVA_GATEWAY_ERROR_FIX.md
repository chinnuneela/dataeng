# Fix: "Java gateway process exited before sending its port number"

**Error:** `PySparkRuntimeError: [JAVA_GATEWAY_EXITED] Java gateway process exited before sending its port number`

---

## Common Causes & Solutions

### ✅ Solution 1: Restart Jupyter Kernel (Most Common)

**Symptom:** Error appears when running a second notebook while another notebook has an active Spark session.

**Why it happens:** Only **one SparkSession can be active per Python process/kernel**. Jupyter notebooks share the same kernel, so if:
- You ran `ORC.ipynb` and it created a SparkSession
- Then you try to run `Avro.ipynb` in the same kernel
- The second attempt to create a SparkSession will fail

**Solution:**
1. **Restart the Jupyter kernel:**
   - In Jupyter: `Kernel` → `Restart Kernel`
   - Or: Click the ⟳ icon in the toolbar
2. Run the notebook again from the beginning

---

### ✅ Solution 2: Reuse Existing Session

The updated `Avro.ipynb` now automatically checks for existing sessions:

```python
# Check if Spark session already exists
spark = SparkSession.getActiveSession()
if spark is not None:
    print("⚠️  Reusing existing SparkSession")
    # Use the existing session
else:
    # Create new session
    spark = SparkSession.builder...getOrCreate()
```

**What this means:**
- If a session exists, it will reuse it
- If not, it will create a new one
- No more conflicts!

---

### ✅ Solution 3: Stop Previous Session

If you want to create a fresh session without restarting the kernel:

```python
# Stop existing session
try:
    existing = SparkSession.getActiveSession()
    if existing:
        existing.stop()
        print("✓ Stopped previous session")
except:
    pass

# Create new session
spark = SparkSession.builder...getOrCreate()
```

---

## Other Possible Causes

### 🔧 Cause 2: Port Conflict

**Symptom:** Error mentions port 4040 is already in use.

**Solution:** The notebook now uses a different port:
```python
.config("spark.ui.port", "4042")
```

**Check running Spark instances:**
```bash
ps aux | grep spark | grep -v grep
```

**Kill if needed:**
```bash
pkill -f "org.apache.spark.deploy.SparkSubmit"
```

---

### 🔧 Cause 3: Java Not Found

**Symptom:** Error mentions Java or JAVA_HOME.

**Verify Java:**
```bash
$JAVA_HOME/bin/java -version
```

**Expected output:**
```
openjdk version "17.0.16"
```

**If not working:**
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
```

---

### 🔧 Cause 4: Spark Package Download Failed

**Symptom:** Error when downloading `spark-avro` package.

**What's happening:**
- First run downloads `org.apache.spark:spark-avro_2.12:4.1.1` (~5MB)
- If download fails, Java gateway crashes

**Solution:**
1. **Check internet connection**
2. **Wait longer** - package download can take 30-60 seconds
3. **Check Maven repository:**
   ```bash
   curl -I https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.12/4.1.1/
   ```
4. **Use pre-downloaded package** (if offline):
   ```python
   .config("spark.jars", "/path/to/spark-avro_2.12-4.1.1.jar")
   # Instead of spark.jars.packages
   ```

**Where packages are cached:**
```bash
ls -la ~/.ivy2/cache/org.apache.spark/spark-avro_2.12/
```

---

### 🔧 Cause 5: Memory Issues

**Symptom:** Java crashes silently.

**Solution:** Reduce memory requirements:
```python
spark = SparkSession.builder \
    .config("spark.driver.memory", "512m") \  # Reduced from 1g
    .config("spark.executor.memory", "512m") \
    .getOrCreate()
```

---

### 🔧 Cause 6: Incompatible Java Version

**Symptom:** Error mentions Java modules or --add-opens.

**Check Spark's default Java:**
```bash
head -2 /opt/homebrew/opt/apache-spark/bin/spark-submit
```

**If it defaults to Java 21:**
```bash
# Homebrew wrappers may default to Java 21
# Ensure JAVA_HOME is set BEFORE starting Jupyter
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
```

---

## Diagnostic Steps

### Step 1: Test Java
```bash
/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home/bin/java -version
```

### Step 2: Test Spark (without Avro)
```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local[*]").getOrCreate()
print(spark.version)
spark.stop()
```

### Step 3: Test Spark (with Avro)
```python
spark = SparkSession.builder \
    .master("local[*]") \
    .config("spark.jars.packages", "org.apache.spark:spark-avro_2.12:4.1.1") \
    .getOrCreate()
print(spark.version)
spark.stop()
```

### Step 4: Check Active Sessions
```python
active = SparkSession.getActiveSession()
if active:
    print(f"Active session: {active.sparkContext.appName}")
else:
    print("No active session")
```

---

## Quick Fixes Checklist

Before running `Avro.ipynb`:

- [ ] **Restart Jupyter kernel** if you ran other notebooks
- [ ] **Check internet connection** (for first run - package download)
- [ ] **Verify Java 17** is set as JAVA_HOME
- [ ] **Wait 30-60 seconds** on first run (package download)
- [ ] **Check no other Spark processes** are running
- [ ] **Reduce memory** if on low-RAM system (< 8GB)

---

## Prevention: Best Practices

### 1. One Notebook at a Time
Run only one PySpark notebook per Jupyter kernel. If switching notebooks:
- Restart kernel first, OR
- Reuse the existing session

### 2. Explicit Session Management
```python
# At the end of your notebook, stop the session
spark.stop()
```

### 3. Use SparkSession.getActiveSession()
Always check for existing sessions before creating new ones.

### 4. Set Unique Ports
If running multiple Jupyter instances:
```python
.config("spark.ui.port", "4042")  # Notebook 1
.config("spark.ui.port", "4043")  # Notebook 2
```

### 5. Cache Downloaded Packages
Packages are cached in `~/.ivy2/cache/` after first download. Subsequent runs are instant.

---

## Still Having Issues?

### Get Detailed Error Information

Add this at the top of your notebook:
```python
import logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

### Check Spark Logs
```bash
# Check most recent Spark logs
ls -lt /tmp/spark-*
tail -100 /tmp/spark-*/executor-*.log
```

### Verify Environment
```python
import os
print("SPARK_HOME:", os.environ.get('SPARK_HOME'))
print("JAVA_HOME:", os.environ.get('JAVA_HOME'))
print("PYSPARK_PYTHON:", os.environ.get('PYSPARK_PYTHON'))
```

---

## Summary

**Most common cause:** Multiple Spark sessions in same kernel.

**Quick fix:** Restart Jupyter kernel before running notebook.

**Updated notebooks** now automatically:
- Check for existing sessions
- Reuse if available
- Use different ports to avoid conflicts
- Provide clear error messages

---

**Last Updated:** 2026-01-18  
**Related:** See `PySpark_ORC_Troubleshooting_Guide.md` for general PySpark setup issues.
