# 🚀 Spark Submit Jobs - Index

## 📂 Project Overview

Welcome to the **Spark Submit Jobs** collection! This folder contains production-ready PySpark jobs demonstrating various Spark operations and comprehensive `spark-submit` configurations.

---

## 📑 Quick Navigation

### 🎯 PySpark Jobs (Ready to Run!)

| # | Job Name | File | Status | Description |
|---|----------|------|--------|-------------|
| 1 | **Word Count Analysis** | [`word_count_job.py`](word_count_job.py) | ✅ Tested | Text processing & word frequency analysis |
| 2 | **Sales Data Analysis** | [`sales_analysis_job.py`](sales_analysis_job.py) | ✅ Tested | Business analytics with window functions |
| 3 | **ETL Pipeline** | [`etl_pipeline_job.py`](etl_pipeline_job.py) | ✅ Tested | Complete ETL with data quality checks |

### 📚 Documentation Files

| File | Purpose | What's Inside |
|------|---------|---------------|
| [`README.md`](README.md) | **Main Documentation** | Complete guide with job descriptions, spark-submit parameters, use cases, and best practices |
| [`SUMMARY.md`](SUMMARY.md) | **Quick Reference** | Execution status, quick start guide, learning outcomes, and troubleshooting |
| [`SPARK_SUBMIT_CHEATSHEET.md`](SPARK_SUBMIT_CHEATSHEET.md) | **Parameter Reference** | Comprehensive tables of all spark-submit parameters and Spark configurations |
| `INDEX.md` | **This File** | Navigation and quick access to all resources |

### 🛠️ Utility Scripts

| File | Purpose | How to Use |
|------|---------|------------|
| [`run_all_jobs.sh`](run_all_jobs.sh) | Run all jobs sequentially | `./run_all_jobs.sh` |

---

## 🚀 Quick Start (3 Steps)

### Step 1: Activate Environment
```bash
cd /Users/mukesh/Desktop/Trainings/nodeB/dataeng/Feb_2026/Spark_Submit
source ../../../venv/bin/activate
export SPARK_HOME=/Applications/spark
```

### Step 2: Run a Job
```bash
# Choose one:
spark-submit word_count_job.py
spark-submit sales_analysis_job.py
spark-submit etl_pipeline_job.py
```

### Step 3: View Results
Check the console output for:
- 📊 Data analysis results
- 📈 Statistics and metrics
- ✅ Job completion status

---

## 🎓 What You'll Learn

### From Job 1 (Word Count)
- ✅ Basic DataFrame operations
- ✅ Text processing functions
- ✅ Aggregations and sorting
- ✅ Local mode execution

### From Job 2 (Sales Analysis)
- ✅ Window functions (rank, row_number)
- ✅ Date/time operations
- ✅ Complex aggregations
- ✅ Performance tuning with shuffle partitions

### From Job 3 (ETL Pipeline)
- ✅ Complete ETL workflow
- ✅ Data quality validation
- ✅ Conditional transformations
- ✅ Production-ready patterns
- ✅ Adaptive Query Execution

---

## 📊 Spark-Submit Parameter Categories

| Category | Key Parameters | Documentation |
|----------|----------------|---------------|
| **Cluster** | `--master`, `--deploy-mode` | [Cheatsheet](SPARK_SUBMIT_CHEATSHEET.md#cluster--deployment) |
| **Resources** | `--driver-memory`, `--executor-memory`, `--num-executors` | [Cheatsheet](SPARK_SUBMIT_CHEATSHEET.md#resource-allocation) |
| **Performance** | `--conf spark.sql.shuffle.partitions`, AQE configs | [Cheatsheet](SPARK_SUBMIT_CHEATSHEET.md#performance-tuning) |
| **Dependencies** | `--packages`, `--py-files`, `--jars` | [Cheatsheet](SPARK_SUBMIT_CHEATSHEET.md#dependencies) |
| **Monitoring** | `--conf spark.eventLog.enabled`, `--conf spark.ui.port` | [Cheatsheet](SPARK_SUBMIT_CHEATSHEET.md#event-logging--history) |

---

## 🎯 Common Commands

### Development
```bash
spark-submit --master 'local[*]' --driver-memory 2g word_count_job.py
```

### With Optimization
```bash
spark-submit \
  --master 'local[*]' \
  --driver-memory 4g \
  --conf spark.sql.shuffle.partitions=50 \
  --conf spark.sql.adaptive.enabled=true \
  sales_analysis_job.py
```

### Production-like
```bash
spark-submit \
  --master 'local[*]' \
  --driver-memory 4g \
  --conf spark.sql.adaptive.enabled=true \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.eventLog.enabled=true \
  etl_pipeline_job.py
```

---

## 📈 Job Execution Summary

All jobs have been successfully tested with the following configuration:

| Metric | Value |
|--------|-------|
| **Execution Mode** | Local[*] (all available cores) |
| **Driver Memory** | 2-4 GB |
| **Python Version** | 3.13.8 |
| **Spark Version** | 3.x |
| **Environment** | Virtual environment (venv) |
| **Status** | ✅ All jobs completed successfully |

---

## 🔍 Monitoring & Debugging

### Spark UI (While Running)
```
http://localhost:4040
```
**Features**: Jobs, Stages, Storage, Environment, Executors, SQL

### History Server (After Completion)
```bash
$SPARK_HOME/sbin/start-history-server.sh
# Then visit: http://localhost:18080
```

---

## 📖 Recommended Reading Order

1. **Start Here**: [`SUMMARY.md`](SUMMARY.md) - Get overview and quick start
2. **Deep Dive**: [`README.md`](README.md) - Understand concepts and best practices
3. **Reference**: [`SPARK_SUBMIT_CHEATSHEET.md`](SPARK_SUBMIT_CHEATSHEET.md) - Look up parameters
4. **Practice**: Run the jobs and experiment with parameters

---

## 🎯 Next Steps

1. ✅ **Run the Jobs**: Execute all three jobs to see them in action
2. 📝 **Modify Code**: Add your own transformations and logic
3. 🔧 **Tune Parameters**: Experiment with different spark-submit configurations
4. 📊 **Monitor**: Use Spark UI to understand execution patterns
5. 🚀 **Scale Up**: Try with larger datasets and more complex operations

---

## 💡 Pro Tips

- 💾 **Start Small**: Test with `local[*]` before moving to cluster
- 📊 **Monitor Always**: Keep Spark UI open while jobs run
- 🎛️ **Tune Partitions**: Adjust based on your data size
- ⚡ **Enable AQE**: Adaptive Query Execution auto-optimizes
- 📝 **Log Events**: Essential for debugging production jobs
- 🔄 **Iterate**: Run, monitor, tune, repeat

---

## 📞 Need Help?

- **Troubleshooting**: See [SUMMARY.md - Troubleshooting](SUMMARY.md#-troubleshooting)
- **Parameter Reference**: See [SPARK_SUBMIT_CHEATSHEET.md](SPARK_SUBMIT_CHEATSHEET.md)
- **Best Practices**: See [README.md - Best Practices](README.md#-best-practices)

---

## 📊 File Statistics

```
Total Files: 7
├── Python Jobs: 3 (word_count_job.py, sales_analysis_job.py, etl_pipeline_job.py)
├── Documentation: 4 (README.md, SUMMARY.md, SPARK_SUBMIT_CHEATSHEET.md, INDEX.md)
└── Scripts: 1 (run_all_jobs.sh)

Total Size: ~52 KB
Lines of Code: ~500+ (Python jobs)
Documentation: ~1000+ lines
```

---

**Created**: February 2026  
**Status**: Production Ready ✅  
**Last Tested**: February 5, 2026  
**Environment**: PySpark 3.x, Python 3.13.8, macOS

---

## 🌟 Features Demonstrated

✅ DataFrame Operations  
✅ Text Processing  
✅ Aggregations & GroupBy  
✅ Window Functions  
✅ Date/Time Operations  
✅ Data Quality Validation  
✅ ETL Patterns  
✅ Performance Tuning  
✅ Adaptive Query Execution  
✅ Comprehensive Logging  
✅ Production Best Practices  

---

**Happy Sparking! 🚀**
