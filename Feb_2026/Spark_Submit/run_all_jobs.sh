#!/bin/bash

# Spark Submit Jobs Runner
# This script demonstrates running all PySpark jobs with different configurations

echo "🔧 Setting up Spark environment..."

# Source the global setup script from nodeB root
source ../../../setup_spark_env.sh

echo ""

echo "================================================================================"
echo "                    SPARK SUBMIT JOBS DEMONSTRATION"
echo "================================================================================"
echo ""

# Job 1: Word Count Analysis
echo "🚀 Running Job 1: Word Count Analysis"
echo "   Configuration: local[*], 2g driver memory"
echo "--------------------------------------------------------------------------------"
spark-submit \
  --master 'local[*]' \
  --driver-memory 2g \
  word_count_job.py

echo ""
echo "✅ Job 1 Completed!"
echo ""
sleep 2

# Job 2: Sales Analysis
echo "🚀 Running Job 2: Sales Data Analysis"
echo "   Configuration: local[*], 2g driver memory, 20 shuffle partitions"
echo "--------------------------------------------------------------------------------"
spark-submit \
  --master 'local[*]' \
  --driver-memory 2g \
  --conf spark.sql.shuffle.partitions=20 \
  --conf spark.sql.adaptive.enabled=true \
  sales_analysis_job.py

echo ""
echo "✅ Job 2 Completed!"
echo ""
sleep 2

# Job 3: ETL Pipeline
echo "🚀 Running Job 3: ETL Pipeline with Data Quality"
echo "   Configuration: local[*], 2g driver memory, adaptive execution enabled"
echo "--------------------------------------------------------------------------------"
spark-submit \
  --master 'local[*]' \
  --driver-memory 2g \
  --conf spark.sql.adaptive.enabled=true \
  --conf spark.sql.adaptive.coalescePartitions.enabled=true \
  etl_pipeline_job.py

echo ""
echo "✅ Job 3 Completed!"
echo ""

echo "================================================================================"
echo "                    ALL JOBS COMPLETED SUCCESSFULLY!"
echo "================================================================================"
echo ""
echo "📊 Summary:"
echo "   - Job 1: Word Count Analysis ✅"
echo "   - Job 2: Sales Data Analysis ✅"
echo "   - Job 3: ETL Pipeline with Data Quality ✅"
echo ""
echo "💡 Tip: Check the Spark UI at http://localhost:4040 while jobs are running"
echo "         to monitor execution details, stages, and tasks."
echo ""
