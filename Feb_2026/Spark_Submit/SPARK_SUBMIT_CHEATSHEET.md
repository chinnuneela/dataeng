# Spark-Submit Parameters Cheat Sheet

## 📋 Complete Parameter Reference

### Cluster & Deployment

| Parameter | Values | Description | Example |
|-----------|--------|-------------|---------|
| `--master` | `local`, `local[N]`, `local[*]`, `yarn`, `spark://HOST:PORT`, `k8s://HOST:PORT` | Cluster manager to connect to | `--master local[4]` |
| `--deploy-mode` | `client`, `cluster` | Where to run the driver | `--deploy-mode cluster` |
| `--name` | String | Application name shown in UI | `--name "My Spark Job"` |
| `--queue` | String | YARN queue name | `--queue production` |

### Resource Allocation

| Parameter | Format | Description | Recommended | Example |
|-----------|--------|-------------|-------------|---------|
| `--driver-memory` | `Ng` or `Nm` | Memory for driver | 2g-8g | `--driver-memory 4g` |
| `--executor-memory` | `Ng` or `Nm` | Memory per executor | 4g-16g | `--executor-memory 8g` |
| `--driver-cores` | Integer | Cores for driver (cluster mode) | 2-4 | `--driver-cores 2` |
| `--executor-cores` | Integer | Cores per executor | 4-5 | `--executor-cores 4` |
| `--num-executors` | Integer | Number of executors (YARN/K8s) | Varies | `--num-executors 10` |
| `--total-executor-cores` | Integer | Total cores (standalone/Mesos) | Varies | `--total-executor-cores 20` |

### Memory Overhead

| Parameter | Format | Description | Recommended | Example |
|-----------|--------|-------------|-------------|---------|
| `--driver-memory-overhead` | `Ng` or `Nm` | Off-heap memory for driver | 10% of driver memory | `--driver-memory-overhead 512m` |
| `--executor-memory-overhead` | `Ng` or `Nm` | Off-heap memory per executor | 10% of executor memory | `--executor-memory-overhead 1g` |

### Dependencies

| Parameter | Format | Description | Example |
|-----------|--------|-------------|---------|
| `--jars` | Comma-separated paths | Additional JARs to distribute | `--jars /path/to/lib.jar,/path/to/lib2.jar` |
| `--packages` | Maven coordinates | Maven packages to include | `--packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0` |
| `--repositories` | URLs | Additional Maven repositories | `--repositories https://repo.maven.apache.org/maven2` |
| `--py-files` | Comma-separated paths | Python files to distribute | `--py-files utils.py,helpers.zip` |
| `--files` | Comma-separated paths | Files to distribute to executors | `--files config.json,data.csv` |
| `--archives` | Comma-separated paths | Archives to distribute | `--archives mylib.zip#lib` |

### Spark Configuration

| Parameter | Format | Description | Example |
|-----------|--------|-------------|---------|
| `--conf` | `KEY=VALUE` | Arbitrary Spark configuration | `--conf spark.sql.shuffle.partitions=200` |
| `--properties-file` | Path | Properties file to load | `--properties-file spark.conf` |
| `--driver-java-options` | JVM options | JVM options for driver | `--driver-java-options "-Xms2g -Xmx4g"` |
| `--driver-library-path` | Path | Library path for driver | `--driver-library-path /usr/lib` |
| `--driver-class-path` | Path | Classpath for driver | `--driver-class-path /path/to/jars/*` |
| `--executor-java-options` | JVM options | JVM options for executors | Not recommended, use --conf instead |

### Output & Logging

| Parameter | Values | Description | Example |
|-----------|--------|-------------|---------|
| `--verbose` | Flag | Print debug information | `--verbose` |
| `--supervise` | Flag | Restart driver on failure (standalone/Mesos) | `--supervise` |

---

## 🎯 Key Spark Configurations (--conf)

### Performance Tuning

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.sql.shuffle.partitions` | 200 | Partitions for shuffle operations | 50-200 for small data, 200-2000 for large |
| `spark.default.parallelism` | # of cores | Default parallelism for RDDs | 2-3x number of cores |
| `spark.sql.files.maxPartitionBytes` | 128 MB | Max bytes per partition when reading | 128 MB - 1 GB |
| `spark.sql.adaptive.enabled` | true (3.2+) | Enable Adaptive Query Execution | `true` |
| `spark.sql.adaptive.coalescePartitions.enabled` | true | Coalesce partitions after shuffle | `true` |
| `spark.sql.adaptive.skewJoin.enabled` | true | Handle skewed joins | `true` |
| `spark.sql.autoBroadcastJoinThreshold` | 10 MB | Max size for broadcast joins | 10 MB - 100 MB |

### Memory Management

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.memory.fraction` | 0.6 | Fraction of heap for execution/storage | 0.6 - 0.8 |
| `spark.memory.storageFraction` | 0.5 | Fraction of memory for storage | 0.3 - 0.5 |
| `spark.memory.offHeap.enabled` | false | Enable off-heap memory | `true` for large datasets |
| `spark.memory.offHeap.size` | 0 | Off-heap memory size | Varies |

### Serialization

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.serializer` | Java | Serializer class | `org.apache.spark.serializer.KryoSerializer` |
| `spark.kryo.registrationRequired` | false | Require Kryo registration | `false` |
| `spark.kryoserializer.buffer.max` | 64 MB | Max Kryo buffer size | 64 MB - 256 MB |

### Compression

| Configuration | Default | Description | Options |
|---------------|---------|-------------|---------|
| `spark.sql.parquet.compression.codec` | snappy | Parquet compression | `snappy`, `gzip`, `lzo`, `zstd` |
| `spark.sql.orc.compression.codec` | snappy | ORC compression | `snappy`, `zlib`, `lzo`, `zstd` |
| `spark.rdd.compress` | false | Compress RDD partitions | `true` for large RDDs |
| `spark.io.compression.codec` | lz4 | Compression codec | `lz4`, `snappy`, `zstd` |

### Dynamic Allocation

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.dynamicAllocation.enabled` | false | Enable dynamic allocation | `true` for shared clusters |
| `spark.dynamicAllocation.minExecutors` | 0 | Minimum executors | 1-3 |
| `spark.dynamicAllocation.maxExecutors` | infinity | Maximum executors | Based on cluster size |
| `spark.dynamicAllocation.initialExecutors` | minExecutors | Initial executors | 3-5 |
| `spark.dynamicAllocation.executorIdleTimeout` | 60s | Idle timeout before removal | 60s - 300s |

### Shuffle & I/O

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.shuffle.service.enabled` | false | Enable external shuffle service | `true` with dynamic allocation |
| `spark.shuffle.compress` | true | Compress shuffle output | `true` |
| `spark.shuffle.spill.compress` | true | Compress spilled data | `true` |
| `spark.io.compression.lz4.blockSize` | 32 KB | LZ4 block size | 32 KB - 128 KB |

### Speculation

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.speculation` | false | Enable speculative execution | `true` for heterogeneous clusters |
| `spark.speculation.multiplier` | 1.5 | Task time multiplier for speculation | 1.5 - 3.0 |
| `spark.speculation.quantile` | 0.75 | Quantile for speculation | 0.75 - 0.9 |

### Event Logging & History

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.eventLog.enabled` | false | Enable event logging | `true` for production |
| `spark.eventLog.dir` | file:///tmp/spark-events | Event log directory | HDFS path for clusters |
| `spark.eventLog.compress` | false | Compress event logs | `true` |
| `spark.history.fs.logDirectory` | file:///tmp/spark-events | History server log directory | Same as eventLog.dir |

### UI & Monitoring

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.ui.port` | 4040 | Spark UI port | 4040-4050 |
| `spark.ui.retainedJobs` | 1000 | Jobs to retain in UI | 100-1000 |
| `spark.ui.retainedStages` | 1000 | Stages to retain in UI | 100-1000 |
| `spark.sql.ui.retainedExecutions` | 1000 | SQL executions to retain | 100-1000 |

### Network & Timeout

| Configuration | Default | Description | Recommended |
|---------------|---------|-------------|-------------|
| `spark.network.timeout` | 120s | Network timeout | 120s - 600s |
| `spark.executor.heartbeatInterval` | 10s | Heartbeat interval | 10s - 30s |
| `spark.rpc.message.maxSize` | 128 MB | Max RPC message size | 128 MB - 512 MB |

---

## 🔥 Common Configuration Patterns

### 1. Development (Local)
```bash
spark-submit \
  --master local[*] \
  --driver-memory 2g \
  --conf spark.sql.shuffle.partitions=10 \
  job.py
```

### 2. Testing (Local with Optimization)
```bash
spark-submit \
  --master local[*] \
  --driver-memory 4g \
  --conf spark.sql.shuffle.partitions=50 \
  --conf spark.sql.adaptive.enabled=true \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  job.py
```

### 3. Production (YARN Cluster)
```bash
spark-submit \
  --master yarn \
  --deploy-mode cluster \
  --driver-memory 8g \
  --executor-memory 16g \
  --num-executors 20 \
  --executor-cores 4 \
  --conf spark.sql.shuffle.partitions=500 \
  --conf spark.sql.adaptive.enabled=true \
  --conf spark.sql.adaptive.coalescePartitions.enabled=true \
  --conf spark.sql.adaptive.skewJoin.enabled=true \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.dynamicAllocation.enabled=true \
  --conf spark.dynamicAllocation.minExecutors=5 \
  --conf spark.dynamicAllocation.maxExecutors=50 \
  --conf spark.shuffle.service.enabled=true \
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=hdfs:///spark-logs \
  job.py
```

### 4. Memory-Intensive Job
```bash
spark-submit \
  --master local[*] \
  --driver-memory 16g \
  --executor-memory 32g \
  --conf spark.memory.fraction=0.8 \
  --conf spark.memory.storageFraction=0.3 \
  --conf spark.memory.offHeap.enabled=true \
  --conf spark.memory.offHeap.size=10g \
  job.py
```

### 5. With External Dependencies
```bash
spark-submit \
  --master local[*] \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0,\
org.postgresql:postgresql:42.6.0 \
  --py-files utils.zip,helpers.py \
  --files config.json \
  job.py
```

---

## 💡 Pro Tips

1. **Start Small**: Begin with `local[*]` and small memory, scale up as needed
2. **Monitor First**: Always check Spark UI to understand bottlenecks
3. **Tune Partitions**: Adjust `spark.sql.shuffle.partitions` based on data size
4. **Enable AQE**: Adaptive Query Execution can auto-optimize many things
5. **Use Kryo**: Almost always faster than Java serialization
6. **Log Events**: Essential for debugging completed jobs
7. **Watch Memory**: Leave 10-20% overhead for off-heap operations
8. **Broadcast Wisely**: Increase threshold for larger dimension tables
9. **Compress Data**: Reduces I/O, especially for shuffles
10. **Test Locally**: Validate logic locally before cluster deployment

---

**Last Updated**: February 2026  
**Spark Version**: 3.x  
**Reference**: [Official Spark Configuration Guide](https://spark.apache.org/docs/latest/configuration.html)
