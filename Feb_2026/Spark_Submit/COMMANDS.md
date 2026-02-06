# 📋 COPY-PASTE COMMANDS

## ⚠️ IMPORTANT: Use 'source', NOT './'!

**Setup Script Location**: `../../../setup_spark_env.sh` (in nodeB root)

---

## 🎯 Option 1: Run Jobs Manually (Step by Step)

### Step 1: Setup Environment
```bash
source ../../../setup_spark_env.sh
```

### Step 2: Run a Job
```bash
# Choose one:
spark-submit word_count_job.py
spark-submit sales_analysis_job.py
spark-submit etl_pipeline_job.py
```

---

## 🎯 Option 2: One-Line Commands (Easiest!)

### Run Sales Analysis Job
```bash
source ../../../setup_spark_env.sh && spark-submit sales_analysis_job.py
```

### Run Word Count Job
```bash
source ../../../setup_spark_env.sh && spark-submit word_count_job.py
```

### Run ETL Pipeline Job
```bash
source ../../../setup_spark_env.sh && spark-submit etl_pipeline_job.py
```

---

## 🎯 Option 3: Use Pre-made Scripts

### Run Sales Job
```bash
./run_sales_job.sh
```

### Run All Jobs
```bash
./run_all_jobs.sh
```

---

## ❌ Common Mistake

**DON'T DO THIS:**
```bash
./setup_spark_env.sh          # ❌ WRONG! Variables won't persist
spark-submit job.py           # ❌ Will fail
```

**DO THIS INSTEAD:**
```bash
source ../../../setup_spark_env.sh     # ✅ CORRECT! Variables will persist
spark-submit job.py                    # ✅ Will work
```

---

## 🔍 Why?

- `./setup_spark_env.sh` runs in a **subshell** → variables are lost when it exits
- `source setup_spark_env.sh` runs in **current shell** → variables persist

**Note**: The setup script is now located in the nodeB root directory (`../../../setup_spark_env.sh`)

---

## 📝 Complete Example

```bash
# 1. Navigate to folder
cd /Users/mukesh/Desktop/Trainings/nodeB/dataeng/Feb_2026/Spark_Submit

# 2. Source the setup script from nodeB root (IMPORTANT!)
source ../../../setup_spark_env.sh

# 3. Run your job
spark-submit sales_analysis_job.py

# 4. Run another job (environment still set)
spark-submit word_count_job.py
```

---

## ✅ Verify Environment

After sourcing, check if it worked:
```bash
echo $SPARK_HOME
# Should show: /Applications/spark

echo $PYSPARK_PYTHON
# Should show: /Users/mukesh/Desktop/Trainings/nodeB/venv/bin/python
```

---

**Remember: Always use `source setup_env.sh`, never `./setup_env.sh`!** 🚀
