# 🚀 Quick Start Guide - How to Run the Jobs

## ⚠️ CRITICAL: You MUST Use 'source' Command!

The setup script **MUST** be sourced (not executed) to set environment variables in your current shell.

### ❌ **WRONG** (This won't work!)
```bash
./setup_spark_env.sh          # ❌ Variables won't persist!
```

### ✅ **CORRECT** (Use this!)
```bash
source ../../../setup_spark_env.sh     # ✅ Variables will persist!
```

---

## 🔧 Method 1: Use the Global Setup Script (Recommended)

```bash
# Navigate to the Spark_Submit folder
cd /Users/mukesh/Desktop/Trainings/nodeB/dataeng/Feb_2026/Spark_Submit

# ⚠️  IMPORTANT: Use 'source', NOT './'
# Source the GLOBAL setup script from nodeB root
source ../../../setup_spark_env.sh

# Now you can run any job
spark-submit word_count_job.py
spark-submit sales_analysis_job.py
spark-submit etl_pipeline_job.py
```

---

## 🔧 Method 2: Manual Setup

If you prefer to set up manually, run these commands:

```bash
# 1. Activate virtual environment
source ../../../venv/bin/activate

# 2. Set SPARK_HOME
export SPARK_HOME=/Applications/spark

# 3. Set PYSPARK_PYTHON
export PYSPARK_PYTHON=$(which python)

# 4. Now run your job
spark-submit sales_analysis_job.py
```

---

## 🎯 Running Individual Jobs

### Job 1: Word Count Analysis
```bash
source setup_env.sh
spark-submit word_count_job.py
```

### Job 2: Sales Data Analysis
```bash
source setup_env.sh
spark-submit --master 'local[*]' --driver-memory 2g sales_analysis_job.py
```

### Job 3: ETL Pipeline
```bash
source setup_env.sh
spark-submit --master 'local[*]' --driver-memory 2g --conf spark.sql.adaptive.enabled=true etl_pipeline_job.py
```

---

## 🔄 Running All Jobs

```bash
source setup_env.sh
./run_all_jobs.sh
```

---

## ❌ Common Issues & Solutions

### Issue 1: "No such file or directory: spark-class"
**Error:**
```
/Applications/spark/spark-3.4.0-bin-hadoop3/bin/spark-class: No such file or directory
```

**Solution:**
```bash
export SPARK_HOME=/Applications/spark
```

### Issue 2: Python Serialization Error (RecursionError)
**Error:**
```
RecursionError: Stack overflow in comparison
```

**Solution:**
```bash
# Use the venv's Python
source ../../../venv/bin/activate
export PYSPARK_PYTHON=$(which python)
```

### Issue 3: Job Fails to Start
**Solution:**
Make sure you've sourced the setup script:
```bash
source setup_env.sh
```

---

## 📊 Expected Output

When a job runs successfully, you should see:

1. **Spark Initialization Logs** (INFO messages)
2. **Job Execution Progress** (stages, tasks)
3. **Data Output** (tables with results)
4. **Success Message**: `✅ Job Completed Successfully!`
5. **Spark Shutdown Logs**

---

## 🌐 Monitoring Jobs

While a job is running, you can monitor it at:
```
http://localhost:4040
```

This shows:
- Job progress
- Stage details
- Task execution
- Memory usage
- SQL queries

---

## 💡 Pro Tips

1. **Always source setup_env.sh first** - This sets all required environment variables
2. **Keep Spark UI open** - Monitor at http://localhost:4040 while jobs run
3. **Start simple** - Run without extra parameters first, then add configurations
4. **Check logs** - Look for ERROR or WARN messages if something fails
5. **Use venv** - Always activate the virtual environment for compatibility

---

## 📝 Complete Example Session

```bash
# 1. Navigate to folder
cd /Users/mukesh/Desktop/Trainings/nodeB/dataeng/Feb_2026/Spark_Submit

# 2. Setup environment
source setup_env.sh

# 3. Run a job
spark-submit word_count_job.py

# 4. Run with custom configuration
spark-submit \
  --master 'local[*]' \
  --driver-memory 4g \
  --conf spark.sql.shuffle.partitions=50 \
  sales_analysis_job.py

# 5. Run all jobs
./run_all_jobs.sh
```

---

## 🎓 What Each Command Does

| Command | Purpose |
|---------|---------|
| `source setup_env.sh` | Sets up Spark environment variables |
| `spark-submit job.py` | Runs a PySpark job |
| `--master 'local[*]'` | Use all available CPU cores |
| `--driver-memory 2g` | Allocate 2GB to driver |
| `--conf KEY=VALUE` | Set Spark configuration |

---

## ✅ Verification

To verify your environment is set up correctly:

```bash
source setup_env.sh
spark-submit --version
```

You should see Spark version information without errors.

---

**Remember**: Always run `source setup_env.sh` before running spark-submit! 🚀
