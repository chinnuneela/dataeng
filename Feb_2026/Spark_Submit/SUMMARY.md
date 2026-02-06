# Spark Submit Jobs - Summary & Quick Reference

## 📁 Project Structure

```
dataeng/Feb_2026/Spark_Submit/
├── word_count_job.py          # Job 1: Text processing and word frequency
├── sales_analysis_job.py      # Job 2: Business analytics with window functions
├── etl_pipeline_job.py        # Job 3: Complete ETL with data quality checks
├── run_all_jobs.sh            # Script to run all jobs sequentially
├── README.md                  # Comprehensive documentation
└── SUMMARY.md                 # This file
```

## ✅ Jobs Created & Tested

### Job 1: Word Count Analysis (`word_count_job.py`)
**Status**: ✅ Successfully Executed

**What it does**:
- Processes text data and counts word frequencies
- Demonstrates basic PySpark transformations (split, explode, groupBy)
- Shows text cleaning with regex and lowercase conversion

**Key Concepts**:
- DataFrame operations
- String functions
- Aggregations
- Sorting and filtering

**Run Command**:
```bash
spark-submit --master 'local[*]' --driver-memory 2g word_count_job.py
```

---

### Job 2: Sales Data Analysis (`sales_analysis_job.py`)
**Status**: ✅ Successfully Executed

**What it does**:
- Analyzes sales data across categories, products, and time periods
- Implements window functions for ranking
- Calculates customer tiers based on purchase amounts
- Generates monthly sales trends

**Key Concepts**:
- Window functions (rank, row_number)
- Date operations (year, month, datediff)
- Complex aggregations
- Multi-level grouping

**Run Command**:
```bash
spark-submit \
  --master 'local[*]' \
  --driver-memory 2g \
  --conf spark.sql.shuffle.partitions=20 \
  sales_analysis_job.py
```

---

### Job 3: ETL Pipeline with Data Quality (`etl_pipeline_job.py`)
**Status**: ✅ Successfully Executed

**What it does**:
- Complete ETL workflow: Extract → Transform → Load
- Data cleaning and standardization
- Comprehensive data quality validation
- Separates valid and invalid records
- Generates quality metrics and statistics

**Key Concepts**:
- Data validation patterns
- Quality flags and derived fields
- Conditional transformations (when/otherwise)
- Data profiling and statistics
- Production ETL patterns

**Run Command**:
```bash
spark-submit \
  --master 'local[*]' \
  --driver-memory 2g \
  --conf spark.sql.adaptive.enabled=true \
  etl_pipeline_job.py
```

---

## 🚀 Quick Start Guide

### 1. Setup Environment
```bash
# Navigate to the folder
cd dataeng/Feb_2026/Spark_Submit

# Activate virtual environment
source ../../../venv/bin/activate

# Set SPARK_HOME (if not already set)
export SPARK_HOME=/Applications/spark
```

### 2. Run Individual Jobs
```bash
# Job 1
spark-submit word_count_job.py

# Job 2
spark-submit sales_analysis_job.py

# Job 3
spark-submit etl_pipeline_job.py
```

### 3. Run All Jobs at Once
```bash
./run_all_jobs.sh
```

---

## 📊 Spark-Submit Parameter Categories

### 1. **Master & Deploy Mode**
```bash
--master local[*]              # Local mode with all cores
--master yarn                  # YARN cluster
--deploy-mode client           # Driver on client (default)
--deploy-mode cluster          # Driver on cluster
```

### 2. **Memory Configuration**
```bash
--driver-memory 4g             # Driver memory
--executor-memory 4g           # Executor memory
--driver-memory-overhead 512m  # Additional driver memory
--executor-memory-overhead 1g  # Additional executor memory
```

### 3. **Executor Configuration**
```bash
--num-executors 5              # Number of executors
--executor-cores 4             # Cores per executor
--total-executor-cores 20      # Total cores (standalone)
```

### 4. **Performance Tuning**
```bash
--conf spark.sql.shuffle.partitions=200              # Shuffle partitions
--conf spark.default.parallelism=100                 # Default parallelism
--conf spark.sql.adaptive.enabled=true               # Adaptive Query Execution
--conf spark.sql.autoBroadcastJoinThreshold=10485760 # Broadcast threshold
```

### 5. **Serialization & Compression**
```bash
--conf spark.serializer=org.apache.spark.serializer.KryoSerializer
--conf spark.sql.parquet.compression.codec=snappy
--conf spark.sql.orc.compression.codec=zlib
```

### 6. **Monitoring & Logging**
```bash
--conf spark.eventLog.enabled=true
--conf spark.eventLog.dir=/tmp/spark-events
--conf spark.ui.port=4040
```

---

## 🎯 Common Use Cases

### Development & Testing
```bash
spark-submit \
  --master local[*] \
  --driver-memory 2g \
  your_job.py
```

### Performance Testing
```bash
spark-submit \
  --master local[*] \
  --driver-memory 4g \
  --conf spark.sql.shuffle.partitions=50 \
  --conf spark.sql.adaptive.enabled=true \
  your_job.py
```

### Production (YARN)
```bash
spark-submit \
  --master yarn \
  --deploy-mode cluster \
  --driver-memory 8g \
  --executor-memory 8g \
  --num-executors 10 \
  --executor-cores 4 \
  --conf spark.sql.adaptive.enabled=true \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  your_job.py
```

---

## 💡 Best Practices Demonstrated

1. **✅ Proper SparkSession Management**
   - All jobs properly initialize and stop SparkSession
   - Application names set for easy identification

2. **✅ Efficient Data Processing**
   - Use of built-in functions over UDFs
   - Proper use of caching where beneficial
   - Optimized transformations

3. **✅ Data Quality**
   - Validation flags for data quality
   - Separation of valid/invalid records
   - Quality metrics and statistics

4. **✅ Code Organization**
   - Clear structure with main() function
   - Comprehensive comments
   - Spark-submit examples in comments

5. **✅ Production Readiness**
   - Error handling considerations
   - Logging and monitoring
   - Configurable parameters

---

## 🔍 Monitoring Jobs

### Spark UI
While a job is running, access the Spark UI at:
```
http://localhost:4040
```

**What to monitor**:
- **Jobs Tab**: Overall job progress
- **Stages Tab**: Stage-level execution details
- **Storage Tab**: Cached RDDs/DataFrames
- **Environment Tab**: Configuration settings
- **Executors Tab**: Executor resource usage
- **SQL Tab**: Query execution plans

### History Server
For completed jobs:
```bash
# Start history server
$SPARK_HOME/sbin/start-history-server.sh

# Access at: http://localhost:18080
```

---

## 📚 Learning Outcomes

After working with these jobs, you should understand:

1. **Basic PySpark Operations**
   - DataFrame creation and transformations
   - Built-in functions (split, explode, lower, etc.)
   - Aggregations and grouping

2. **Advanced Concepts**
   - Window functions for ranking and analytics
   - Date/time operations
   - Conditional logic (when/otherwise)
   - Data quality patterns

3. **Spark-Submit Mastery**
   - Different execution modes
   - Memory and resource configuration
   - Performance tuning parameters
   - Monitoring and debugging

4. **Production Patterns**
   - ETL workflow design
   - Data validation strategies
   - Quality metrics generation
   - Separation of concerns

---

## 🎓 Next Steps

1. **Experiment with Parameters**
   - Try different memory configurations
   - Adjust shuffle partitions
   - Enable/disable adaptive execution

2. **Modify the Jobs**
   - Add more complex transformations
   - Implement joins between datasets
   - Add data writing to files/databases

3. **Scale Up**
   - Generate larger datasets
   - Test with different cluster configurations
   - Implement partitioning and bucketing

4. **Add More Features**
   - Command-line arguments for configuration
   - External configuration files
   - Integration with data sources (HDFS, S3, databases)

---

## 📞 Troubleshooting

### Issue: Out of Memory
```bash
# Increase driver/executor memory
--driver-memory 8g --executor-memory 8g
```

### Issue: Slow Shuffles
```bash
# Reduce shuffle partitions or enable AQE
--conf spark.sql.shuffle.partitions=50
--conf spark.sql.adaptive.enabled=true
```

### Issue: Task Failures
```bash
# Enable speculation and increase retries
--conf spark.speculation=true
--conf spark.task.maxFailures=4
```

---

**Created**: February 2026  
**Status**: All jobs tested and working ✅  
**Environment**: PySpark 3.x, Python 3.13.8  
**Execution Mode**: Local[*] with 2-4GB driver memory
