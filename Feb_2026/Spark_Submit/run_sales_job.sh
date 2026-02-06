#!/bin/bash
# Quick runner for sales analysis job
# This sources the global environment setup and runs the job in one command

source ../../../setup_spark_env.sh && spark-submit --master 'local[*]' --driver-memory 2g sales_analysis_job.py
