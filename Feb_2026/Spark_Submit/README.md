# Spark Submit Jobs - Feb 2026

This folder contains PySpark jobs demonstrating various Spark operations and comprehensive `spark-submit` configurations.

## 📁 Jobs Overview

### 1. **word_count_job.py** - Word Count Analysis
- **Purpose**: Basic text processing and word frequency analysis
- **Concepts**: Text transformations, aggregations, explode, split
- **Use Case**: Log analysis, text mining, basic NLP

### 2. **sales_analysis_job.py** - Sales Data Analysis
- **Purpose**: Business analytics on sales data
- **Concepts**: DataFrame operations, aggregations, window functions, ranking
- **Use Case**: Business intelligence, sales reporting, trend analysis

### 3. **etl_pipeline_job.py** - ETL Pipeline with Data Quality
- **Purpose**: Complete ETL workflow with data validation
- **Concepts**: Data cleaning, quality checks, validation flags, derived fields
- **Use Case**: Data warehousing, data quality management, production ETL

## 🚀 Running the Jobs

### Prerequisites
```bash
# Activate virtual environment
source venv/bin/activate

# Verify Spark installation
spark-submit --version
```

### Quick Start
```bash
# Navigate to the folder
cd dataeng/Feb_2026/Spark_Submit

# Run any job
spark-submit word_count_job.py
spark-submit sales_analysis_job.py
spark-submit etl_pipeline_job.py
```

## 📚 Spark-Submit Parameters Guide

### Master Configuration
| Parameter | Description | Example |
|-----------|-------------|---------|
| `--master local` | Run on single core | `--master local` |
| `--master local[4]` | Run with 4 cores | `--master local[4]` |
| `--master local[*]` | Use all available cores | `--master local[*]` |
| `--master yarn` | Run on YARN cluster | `--master yarn` |
| `--master spark://HOST:PORT` | Run on Standalone cluster | `--master spark://master:7077` |

### Deploy Mode
| Parameter | Description | When to Use |
|-----------|-------------|-------------|
| `--deploy-mode client` | Driver runs on client machine | Development, debugging |
| `--deploy-mode cluster` | Driver runs on cluster | Production, long-running jobs |

### Memory Configuration
| Parameter | Description | Recommended |
|-----------|-------------|-------------|
| `--driver-memory 2g` | Memory for driver | 2g-8g for most jobs |
| `--executor-memory 4g` | Memory per executor | 4g-16g based on data size |
| `--driver-memory-overhead 512m` | Additional driver memory | 10% of driver memory |
| `--executor-memory-overhead 1g` | Additional executor memory | 10% of executor memory |

### Executor Configuration
| Parameter | Description | Best Practice |
|-----------|-------------|---------------|
| `--num-executors 5` | Number of executors | Based on cluster size |
| `--executor-cores 4` | Cores per executor | 4-5 cores optimal |
| `--total-executor-cores 20` | Total cores (standalone) | For standalone mode |

### Application Configuration
| Parameter | Description | Example |
|-----------|-------------|---------|
| `--name "Job Name"` | Application name in UI | `--name "ETL Pipeline"` |
| `--queue production` | YARN queue | `--queue default` |
| `--conf KEY=VALUE` | Spark configuration | `--conf spark.sql.shuffle.partitions=200` |

### Important Spark Configurations

#### Performance Tuning
```bash
# Shuffle partitions (default: 200)
--conf spark.sql.shuffle.partitions=100

# Default parallelism
--conf spark.default.parallelism=100

# Adaptive Query Execution (Spark 3.0+)
--conf spark.sql.adaptive.enabled=true
--conf spark.sql.adaptive.coalescePartitions.enabled=true
--conf spark.sql.adaptive.skewJoin.enabled=true

# Broadcast join threshold (10MB default)
--conf spark.sql.autoBroadcastJoinThreshold=10485760
```

#### Serialization
```bash
# Use Kryo serializer (faster than Java)
--conf spark.serializer=org.apache.spark.serializer.KryoSerializer
--conf spark.kryo.registrationRequired=false
```

#### Compression
```bash
# Parquet compression
--conf spark.sql.parquet.compression.codec=snappy

# ORC compression
--conf spark.sql.orc.compression.codec=zlib

# RDD compression
--conf spark.rdd.compress=true
```

#### Dynamic Allocation
```bash
--conf spark.dynamicAllocation.enabled=true
--conf spark.dynamicAllocation.minExecutors=1
--conf spark.dynamicAllocation.maxExecutors=10
--conf spark.dynamicAllocation.initialExecutors=3
```

#### Event Logging & Monitoring
```bash
# Enable event logging
--conf spark.eventLog.enabled=true
--conf spark.eventLog.dir=/tmp/spark-events

# Spark UI port
--conf spark.ui.port=4040

# History server
--conf spark.history.fs.logDirectory=/tmp/spark-events
```

#### Speculation (Handle Slow Tasks)
```bash
--conf spark.speculation=true
--conf spark.speculation.multiplier=1.5
--conf spark.speculation.quantile=0.75
```

### Dependencies Management
```bash
# Python files
--py-files dependencies.zip,utils.py

# JAR files
--jars /path/to/custom.jar

# Maven packages
--packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0

# Repositories
--repositories https://repo.maven.apache.org/maven2
```

### Environment Variables
```bash
# Set executor environment variables
--conf "spark.executorEnv.VAR_NAME=value"

# Set driver environment variables
--conf "spark.yarn.appMasterEnv.VAR_NAME=value"
```

## 🎯 Common Use Cases

### 1. Development (Local Mode)
```bash
spark-submit \
  --master local[*] \
  --driver-memory 2g \
  word_count_job.py
```

### 2. Testing with Optimization
```bash
spark-submit \
  --master local[*] \
  --driver-memory 4g \
  --conf spark.sql.shuffle.partitions=50 \
  --conf spark.sql.adaptive.enabled=true \
  sales_analysis_job.py
```

### 3. Production (YARN Cluster)
```bash
spark-submit \
  --master yarn \
  --deploy-mode cluster \
  --name "ETL Pipeline Production" \
  --driver-memory 8g \
  --executor-memory 8g \
  --num-executors 10 \
  --executor-cores 4 \
  --conf spark.sql.adaptive.enabled=true \
  --conf spark.sql.shuffle.partitions=200 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=hdfs:///spark-logs \
  etl_pipeline_job.py
```

### 4. With External Dependencies
```bash
spark-submit \
  --master local[*] \
  --packages org.apache.spark:spark-avro_2.12:3.5.0 \
  --py-files utils.zip \
  --files config.json \
  etl_pipeline_job.py
```

### 5. Memory-Intensive Job
```bash
spark-submit \
  --master local[*] \
  --driver-memory 16g \
  --executor-memory 16g \
  --conf spark.memory.fraction=0.8 \
  --conf spark.memory.storageFraction=0.3 \
  etl_pipeline_job.py
```

## 📊 Monitoring Jobs

### Spark UI
- **URL**: http://localhost:4040 (default)
- **Features**: 
  - Jobs, Stages, Tasks
  - Storage, Environment
  - Executors, SQL queries

### Accessing Spark UI
```bash
# Custom port
spark-submit --conf spark.ui.port=4050 word_count_job.py

# Then visit: http://localhost:4050
```

### History Server (for completed jobs)
```bash
# Start history server
$SPARK_HOME/sbin/start-history-server.sh

# Visit: http://localhost:18080
```

## 🔧 Troubleshooting

### Out of Memory Errors
```bash
# Increase driver/executor memory
--driver-memory 8g --executor-memory 8g

# Increase memory overhead
--conf spark.executor.memoryOverhead=2g
```

### Slow Shuffles
```bash
# Reduce shuffle partitions
--conf spark.sql.shuffle.partitions=50

# Enable adaptive execution
--conf spark.sql.adaptive.enabled=true
```

### Task Failures
```bash
# Enable speculation
--conf spark.speculation=true

# Increase task retries
--conf spark.task.maxFailures=4
```

## 📝 Best Practices

1. **Start Small**: Test with `local[*]` before cluster deployment
2. **Monitor Resources**: Use Spark UI to identify bottlenecks
3. **Optimize Partitions**: Balance between too few (large tasks) and too many (overhead)
4. **Use Adaptive Execution**: Enable AQE for automatic optimization
5. **Choose Right Serializer**: Kryo is faster than Java serialization
6. **Enable Event Logging**: Essential for debugging completed jobs
7. **Set Appropriate Memory**: Leave room for OS and other processes
8. **Use Compression**: Reduces I/O and storage costs

## 🎓 Learning Resources

- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Spark Configuration Guide](https://spark.apache.org/docs/latest/configuration.html)
- [Spark Tuning Guide](https://spark.apache.org/docs/latest/tuning.html)
- [Spark SQL Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)

---

**Created**: February 2026  
**Author**: Data Engineering Training  
**Purpose**: Educational demonstration of PySpark and spark-submit configurations
