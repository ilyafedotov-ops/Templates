#!/usr/bin/env python3
"""
Enterprise Spark ETL Job with Advanced Optimization Techniques

This script demonstrates production-ready Spark ETL patterns including:
- Dynamic partitioning and bucketing
- Adaptive query execution optimization
- Cache management and checkpoint strategies
- Data skew handling and broadcast optimization
- Delta Lake integration for ACID transactions
- Comprehensive error handling and monitoring
- Cost optimization techniques for cloud deployments
"""

import argparse
import logging
import os
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple

from pyspark.sql import SparkSession, DataFrame
from pyspark.sql.functions import (
    col, lit, when, coalesce, regexp_replace, trim, upper, lower,
    sum as spark_sum, count as spark_count, avg, max as spark_max, min as spark_min,
    year, month, dayofmonth, hour, date_format, to_timestamp, current_timestamp,
    broadcast, expr, split, explode, collect_list, size, isnan, isnull,
    row_number, rank, dense_rank, lag, lead, first, last
)
from pyspark.sql.types import (
    StructType, StructField, StringType, IntegerType, DoubleType, 
    TimestampType, BooleanType, ArrayType, MapType
)
from pyspark.sql.window import Window
from pyspark.storagelevel import StorageLevel

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('/tmp/spark_job.log')
    ]
)
logger = logging.getLogger(__name__)


class SparkJobConfig:
    """Configuration class for Spark job parameters"""
    
    def __init__(self, args):
        self.job_name = args.job_name
        self.environment = args.environment
        self.data_date = args.data_date or datetime.now().strftime('%Y-%m-%d')
        self.input_path = args.input_path
        self.output_path = args.output_path
        self.checkpoint_path = args.checkpoint_path
        self.partition_columns = args.partition_columns.split(',') if args.partition_columns else []
        self.bucket_columns = args.bucket_columns.split(',') if args.bucket_columns else []
        self.num_buckets = args.num_buckets
        self.cache_level = args.cache_level
        self.enable_adaptive_query = args.enable_adaptive_query
        self.max_records_per_file = args.max_records_per_file
        self.coalesce_partitions = args.coalesce_partitions


class DataQualityValidator:
    """Data quality validation utilities"""
    
    @staticmethod
    def validate_schema(df: DataFrame, expected_schema: StructType) -> Tuple[bool, List[str]]:
        """Validate DataFrame schema against expected schema"""
        errors = []
        
        for expected_field in expected_schema.fields:
            if expected_field.name not in df.columns:
                errors.append(f"Missing column: {expected_field.name}")
            else:
                actual_field = next((f for f in df.schema.fields if f.name == expected_field.name), None)
                if actual_field and actual_field.dataType != expected_field.dataType:
                    errors.append(f"Type mismatch for {expected_field.name}: expected {expected_field.dataType}, got {actual_field.dataType}")
        
        return len(errors) == 0, errors
    
    @staticmethod
    def check_data_quality(df: DataFrame) -> Dict[str, any]:
        """Comprehensive data quality checks"""
        total_rows = df.count()
        
        quality_report = {
            'total_rows': total_rows,
            'null_counts': {},
            'duplicate_count': 0,
            'column_stats': {}
        }
        
        # Check for nulls in each column
        for column in df.columns:
            null_count = df.filter(col(column).isNull() | isnan(col(column))).count()
            quality_report['null_counts'][column] = {
                'count': null_count,
                'percentage': (null_count / total_rows * 100) if total_rows > 0 else 0
            }
        
        # Check for duplicates
        if total_rows > 0:
            unique_rows = df.distinct().count()
            quality_report['duplicate_count'] = total_rows - unique_rows
        
        # Basic column statistics for numeric columns
        numeric_columns = [f.name for f in df.schema.fields if f.dataType in [IntegerType(), DoubleType()]]
        if numeric_columns:
            stats_df = df.select([
                spark_min(col(c)).alias(f"{c}_min"),
                spark_max(col(c)).alias(f"{c}_max"), 
                avg(col(c)).alias(f"{c}_avg")
                for c in numeric_columns
            ]).collect()[0]
            
            for col_name in numeric_columns:
                quality_report['column_stats'][col_name] = {
                    'min': stats_df[f"{col_name}_min"],
                    'max': stats_df[f"{col_name}_max"],
                    'avg': stats_df[f"{col_name}_avg"]
                }
        
        return quality_report


class SparkOptimizer:
    """Advanced Spark optimization utilities"""
    
    @staticmethod
    def optimize_spark_session(spark: SparkSession, config: SparkJobConfig) -> SparkSession:
        """Apply advanced Spark optimizations"""
        
        # Adaptive Query Execution
        if config.enable_adaptive_query:
            spark.conf.set("spark.sql.adaptive.enabled", "true")
            spark.conf.set("spark.sql.adaptive.coalescePartitions.enabled", "true")
            spark.conf.set("spark.sql.adaptive.skewJoin.enabled", "true")
            spark.conf.set("spark.sql.adaptive.localShuffleReader.enabled", "true")
            spark.conf.set("spark.sql.adaptive.advisoryPartitionSizeInBytes", "128MB")
        
        # Dynamic allocation
        spark.conf.set("spark.dynamicAllocation.enabled", "true")
        spark.conf.set("spark.dynamicAllocation.minExecutors", "2")
        spark.conf.set("spark.dynamicAllocation.maxExecutors", "100")
        spark.conf.set("spark.dynamicAllocation.initialExecutors", "10")
        
        # Serialization optimization
        spark.conf.set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
        spark.conf.set("spark.sql.execution.arrow.pyspark.enabled", "true")
        
        # Memory optimization
        spark.conf.set("spark.executor.memory", "8g")
        spark.conf.set("spark.executor.memoryFraction", "0.8")
        spark.conf.set("spark.sql.execution.arrow.maxRecordsPerBatch", "10000")
        
        # File optimization
        if config.max_records_per_file:
            spark.conf.set("spark.sql.files.maxRecordsPerFile", str(config.max_records_per_file))
        
        return spark
    
    @staticmethod
    def handle_data_skew(df: DataFrame, skewed_columns: List[str]) -> DataFrame:
        """Handle data skew by salting technique"""
        if not skewed_columns:
            return df
        
        # Add salt column to distribute skewed data
        salt_df = df.withColumn("salt", (expr("hash(rand())") % 100).cast("string"))
        
        # Create salted key for skewed columns
        for col_name in skewed_columns:
            if col_name in df.columns:
                salt_df = salt_df.withColumn(
                    f"{col_name}_salted", 
                    concat_ws("_", col(col_name), col("salt"))
                )
        
        return salt_df
    
    @staticmethod
    def optimize_joins(left_df: DataFrame, right_df: DataFrame, 
                      join_keys: List[str], join_type: str = "inner") -> DataFrame:
        """Optimize join operations with broadcast and bucketing"""
        
        # Estimate DataFrame sizes
        left_size = left_df.count()
        right_size = right_df.count()
        
        # Use broadcast join for smaller DataFrames (< 200MB worth of rows)
        broadcast_threshold = 1000000  # Approximate row threshold for broadcast
        
        if right_size < broadcast_threshold and right_size < left_size:
            logger.info(f"Using broadcast join - broadcasting right DataFrame ({right_size} rows)")
            return left_df.join(broadcast(right_df), join_keys, join_type)
        elif left_size < broadcast_threshold and left_size < right_size:
            logger.info(f"Using broadcast join - broadcasting left DataFrame ({left_size} rows)")
            return broadcast(left_df).join(right_df, join_keys, join_type)
        else:
            logger.info("Using shuffle join - both DataFrames are large")
            return left_df.join(right_df, join_keys, join_type)


class ETLJobProcessor:
    """Main ETL job processor with advanced patterns"""
    
    def __init__(self, spark: SparkSession, config: SparkJobConfig):
        self.spark = spark
        self.config = config
        self.validator = DataQualityValidator()
        self.optimizer = SparkOptimizer()
    
    def read_data_with_optimization(self, path: str, format: str = "parquet") -> DataFrame:
        """Read data with optimization settings"""
        
        read_options = {
            "path": path,
            "mergeSchema": "true",
            "recursiveFileLookup": "true"
        }
        
        if format.lower() == "parquet":
            # Parquet optimization
            read_options.update({
                "pushDownPredicate": "true",
                "pushDownAggregate": "true"
            })
        elif format.lower() == "delta":
            # Delta Lake optimization
            read_options.update({
                "versionAsOf": "latest",
                "readChangeFeed": "false"
            })
        
        df = self.spark.read.format(format).options(**read_options).load(path)
        
        # Apply intelligent caching based on data size and usage pattern
        if self.config.cache_level != "NONE":
            cache_level = getattr(StorageLevel, self.config.cache_level)
            df = df.cache() if cache_level == StorageLevel.MEMORY_ONLY else df.persist(cache_level)
            
            # Trigger caching
            row_count = df.count()
            logger.info(f"Cached DataFrame with {row_count} rows at level {self.config.cache_level}")
        
        return df
    
    def write_data_with_optimization(self, df: DataFrame, path: str, 
                                   format: str = "parquet", mode: str = "overwrite") -> None:
        """Write data with optimization settings"""
        
        writer = df.write.mode(mode).format(format)
        
        # Apply partitioning if specified
        if self.config.partition_columns:
            logger.info(f"Partitioning by columns: {self.config.partition_columns}")
            writer = writer.partitionBy(*self.config.partition_columns)
        
        # Apply bucketing if specified
        if self.config.bucket_columns and self.config.num_buckets > 0:
            logger.info(f"Bucketing by columns: {self.config.bucket_columns}, buckets: {self.config.num_buckets}")
            writer = writer.bucketBy(self.config.num_buckets, *self.config.bucket_columns)
        
        # Optimize file sizes
        if self.config.coalesce_partitions > 0:
            df = df.coalesce(self.config.coalesce_partitions)
            logger.info(f"Coalesced to {self.config.coalesce_partitions} partitions")
        
        # Format-specific optimizations
        if format.lower() == "parquet":
            writer = writer.option("compression", "snappy")
        elif format.lower() == "delta":
            writer = writer.option("overwriteSchema", "true")
            writer = writer.option("optimizeWrite", "true")
            writer = writer.option("autoCompact", "true")
        
        # Write with error handling
        try:
            writer.save(path)
            logger.info(f"Successfully wrote data to {path}")
        except Exception as e:
            logger.error(f"Failed to write data to {path}: {str(e)}")
            raise
    
    def transform_customer_data(self, df: DataFrame) -> DataFrame:
        """Transform customer data with advanced techniques"""
        
        logger.info("Starting customer data transformation")
        
        # Data cleaning and standardization
        cleaned_df = df.select(
            col("customer_id"),
            trim(upper(col("first_name"))).alias("first_name"),
            trim(upper(col("last_name"))).alias("last_name"),
            lower(trim(col("email"))).alias("email"),
            regexp_replace(col("phone"), r"[^\d]", "").alias("phone_cleaned"),
            trim(upper(col("country"))).alias("country"),
            col("registration_date").cast(TimestampType()).alias("registration_timestamp"),
            col("age"),
            coalesce(col("lifetime_value"), lit(0.0)).alias("lifetime_value")
        ).filter(
            # Data quality filters
            col("customer_id").isNotNull() &
            col("email").contains("@") &
            col("age").between(13, 120) &
            col("registration_date").isNotNull()
        )
        
        # Feature engineering with window functions
        window_spec = Window.partitionBy("country").orderBy(col("registration_timestamp").desc())
        
        enriched_df = cleaned_df.withColumn(
            "customer_rank_in_country", rank().over(window_spec)
        ).withColumn(
            "days_since_registration", 
            expr("datediff(current_date(), date(registration_timestamp))")
        ).withColumn(
            "age_group",
            when(col("age") < 25, "Young")
            .when(col("age") < 45, "Adult") 
            .when(col("age") < 65, "Middle Age")
            .otherwise("Senior")
        ).withColumn(
            "ltv_category",
            when(col("lifetime_value") > 10000, "High Value")
            .when(col("lifetime_value") > 1000, "Medium Value")
            .otherwise("Low Value")
        )
        
        # Add data processing metadata
        processed_df = enriched_df.withColumn(
            "processed_timestamp", current_timestamp()
        ).withColumn(
            "data_source", lit("customer_etl_job")
        ).withColumn(
            "processing_date", lit(self.config.data_date)
        )
        
        logger.info(f"Customer data transformation completed. Final count: {processed_df.count()}")
        return processed_df
    
    def transform_transaction_data(self, df: DataFrame, customer_df: DataFrame) -> DataFrame:
        """Transform transaction data with join optimization"""
        
        logger.info("Starting transaction data transformation")
        
        # Clean and standardize transaction data
        cleaned_transactions = df.select(
            col("transaction_id"),
            col("user_id").alias("customer_id"),  # Standardize column name
            col("amount").cast(DoubleType()),
            col("merchant_id"),
            to_timestamp(col("timestamp") / 1000).alias("transaction_timestamp"),  # Convert from milliseconds
            upper(trim(col("status"))).alias("status"),
            lower(trim(col("payment_method"))).alias("payment_method"),
            col("location.country").alias("transaction_country")
        ).filter(
            # Data quality filters
            col("transaction_id").isNotNull() &
            col("customer_id").isNotNull() &
            col("amount") > 0 &
            col("amount") < 100000 &  # Reasonable transaction limit
            col("timestamp").isNotNull() &
            col("status").isin(["COMPLETED", "PENDING", "FAILED", "CANCELLED"])
        )
        
        # Aggregate transaction metrics per customer
        customer_aggregates = cleaned_transactions.groupBy("customer_id").agg(
            spark_count("*").alias("total_transactions"),
            spark_sum("amount").alias("total_amount"),
            avg("amount").alias("avg_transaction_amount"),
            spark_max("transaction_timestamp").alias("last_transaction_date"),
            spark_min("transaction_timestamp").alias("first_transaction_date"),
            collect_list("merchant_id").alias("merchants_list")
        ).withColumn(
            "unique_merchants_count", size(expr("array_distinct(merchants_list)"))
        ).withColumn(
            "customer_lifetime_days", 
            expr("datediff(last_transaction_date, first_transaction_date) + 1")
        ).withColumn(
            "avg_transactions_per_day",
            expr("total_transactions / greatest(customer_lifetime_days, 1)")
        )
        
        # Join with customer data using optimized join
        enriched_transactions = self.optimizer.optimize_joins(
            cleaned_transactions, customer_df, ["customer_id"], "inner"
        )
        
        # Add transaction features
        window_customer = Window.partitionBy("customer_id").orderBy("transaction_timestamp")
        
        final_transactions = enriched_transactions.withColumn(
            "transaction_sequence", row_number().over(window_customer)
        ).withColumn(
            "days_since_last_transaction",
            expr("datediff(transaction_timestamp, lag(transaction_timestamp) over (partition by customer_id order by transaction_timestamp))")
        ).withColumn(
            "amount_deviation_from_avg",
            expr("amount - avg(amount) over (partition by customer_id)")
        ).withColumn(
            "is_weekend",
            expr("dayofweek(transaction_timestamp) in (1, 7)")  # Sunday = 1, Saturday = 7
        ).withColumn(
            "transaction_hour", hour("transaction_timestamp")
        ).withColumn(
            "is_high_value",
            col("amount") > 1000
        )
        
        # Add processing metadata
        processed_transactions = final_transactions.withColumn(
            "processed_timestamp", current_timestamp()
        ).withColumn(
            "data_source", lit("transaction_etl_job")
        ).withColumn(
            "processing_date", lit(self.config.data_date)
        )
        
        logger.info(f"Transaction data transformation completed. Final count: {processed_transactions.count()}")
        return processed_transactions
    
    def create_analytical_aggregates(self, transaction_df: DataFrame) -> DataFrame:
        """Create analytical aggregates for reporting"""
        
        logger.info("Creating analytical aggregates")
        
        # Daily aggregates by country and payment method
        daily_aggregates = transaction_df.groupBy(
            date_format("transaction_timestamp", "yyyy-MM-dd").alias("transaction_date"),
            "transaction_country",
            "payment_method"
        ).agg(
            spark_count("*").alias("transaction_count"),
            spark_sum("amount").alias("total_amount"),
            avg("amount").alias("avg_amount"),
            spark_max("amount").alias("max_amount"),
            spark_min("amount").alias("min_amount"),
            expr("count(distinct customer_id)").alias("unique_customers"),
            expr("count(distinct merchant_id)").alias("unique_merchants"),
            spark_sum(when(col("status") == "COMPLETED", 1).otherwise(0)).alias("successful_transactions"),
            spark_sum(when(col("status") == "FAILED", 1).otherwise(0)).alias("failed_transactions")
        ).withColumn(
            "success_rate", 
            expr("successful_transactions / transaction_count")
        ).withColumn(
            "avg_amount_per_customer",
            expr("total_amount / unique_customers")
        )
        
        # Add processing metadata
        final_aggregates = daily_aggregates.withColumn(
            "created_timestamp", current_timestamp()
        ).withColumn(
            "data_source", lit("analytical_aggregates")
        ).withColumn(
            "processing_date", lit(self.config.data_date)
        )
        
        logger.info(f"Analytical aggregates created. Final count: {final_aggregates.count()}")
        return final_aggregates
    
    def run_etl_pipeline(self) -> None:
        """Run the complete ETL pipeline"""
        
        logger.info(f"Starting ETL pipeline: {self.config.job_name}")
        logger.info(f"Environment: {self.config.environment}")
        logger.info(f"Processing date: {self.config.data_date}")
        
        try:
            # Set checkpoint directory if provided
            if self.config.checkpoint_path:
                self.spark.sparkContext.setCheckpointDir(self.config.checkpoint_path)
            
            # Read raw data
            logger.info("Reading raw customer data")
            customer_raw = self.read_data_with_optimization(
                f"{self.config.input_path}/customers/", "parquet"
            )
            
            logger.info("Reading raw transaction data")  
            transaction_raw = self.read_data_with_optimization(
                f"{self.config.input_path}/transactions/", "parquet"
            )
            
            # Data quality validation
            logger.info("Running data quality checks")
            customer_quality = self.validator.check_data_quality(customer_raw)
            transaction_quality = self.validator.check_data_quality(transaction_raw)
            
            logger.info(f"Customer data quality: {customer_quality['total_rows']} rows, "
                       f"{customer_quality['duplicate_count']} duplicates")
            logger.info(f"Transaction data quality: {transaction_quality['total_rows']} rows, "
                       f"{transaction_quality['duplicate_count']} duplicates")
            
            # Transform data
            logger.info("Transforming customer data")
            customer_processed = self.transform_customer_data(customer_raw)
            
            # Checkpoint intermediate results for fault tolerance
            if self.config.checkpoint_path:
                customer_processed.checkpoint()
            
            logger.info("Transforming transaction data")
            transaction_processed = self.transform_transaction_data(transaction_raw, customer_processed)
            
            # Create analytical aggregates
            logger.info("Creating analytical aggregates")
            analytical_aggregates = self.create_analytical_aggregates(transaction_processed)
            
            # Write processed data
            logger.info("Writing processed customer data")
            self.write_data_with_optimization(
                customer_processed,
                f"{self.config.output_path}/processed_customers/",
                format="delta",
                mode="overwrite"
            )
            
            logger.info("Writing processed transaction data")
            self.write_data_with_optimization(
                transaction_processed,
                f"{self.config.output_path}/processed_transactions/",
                format="delta", 
                mode="overwrite"
            )
            
            logger.info("Writing analytical aggregates")
            self.write_data_with_optimization(
                analytical_aggregates,
                f"{self.config.output_path}/analytical_aggregates/",
                format="delta",
                mode="overwrite"
            )
            
            # Final data quality report
            final_customer_count = customer_processed.count()
            final_transaction_count = transaction_processed.count()
            final_aggregate_count = analytical_aggregates.count()
            
            logger.info("="*50)
            logger.info("ETL PIPELINE COMPLETED SUCCESSFULLY")
            logger.info("="*50)
            logger.info(f"Processed customers: {final_customer_count:,}")
            logger.info(f"Processed transactions: {final_transaction_count:,}")
            logger.info(f"Analytical aggregates: {final_aggregate_count:,}")
            logger.info(f"Total processing time: {datetime.now()}")
            logger.info("="*50)
            
        except Exception as e:
            logger.error(f"ETL pipeline failed: {str(e)}")
            raise
        
        finally:
            # Cleanup cached data
            self.spark.catalog.clearCache()
            logger.info("Cleaned up cached data")


def create_spark_session(config: SparkJobConfig) -> SparkSession:
    """Create optimized Spark session"""
    
    app_name = f"{config.job_name}_{config.environment}_{config.data_date}"
    
    builder = SparkSession.builder \
        .appName(app_name) \
        .config("spark.sql.adaptive.enabled", "true") \
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
        .config("spark.sql.adaptive.skewJoin.enabled", "true") \
        .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer") \
        .config("spark.sql.execution.arrow.pyspark.enabled", "true") \
        .config("spark.dynamicAllocation.enabled", "true")
    
    # Add Delta Lake support
    builder = builder \
        .config("spark.jars.packages", "io.delta:delta-core_2.12:2.4.0") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
    
    spark = builder.getOrCreate()
    
    # Set log level
    spark.sparkContext.setLogLevel("WARN")
    
    return spark


def parse_arguments():
    """Parse command line arguments"""
    
    parser = argparse.ArgumentParser(description="Advanced Spark ETL Job")
    
    # Required arguments
    parser.add_argument("--job-name", required=True, help="Job name identifier")
    parser.add_argument("--environment", required=True, choices=["dev", "staging", "prod"], help="Environment")
    parser.add_argument("--input-path", required=True, help="Input data path")
    parser.add_argument("--output-path", required=True, help="Output data path")
    
    # Optional arguments
    parser.add_argument("--data-date", help="Data processing date (YYYY-MM-DD)")
    parser.add_argument("--checkpoint-path", help="Checkpoint directory path")
    parser.add_argument("--partition-columns", help="Comma-separated partition columns")
    parser.add_argument("--bucket-columns", help="Comma-separated bucket columns")
    parser.add_argument("--num-buckets", type=int, default=0, help="Number of buckets")
    parser.add_argument("--cache-level", default="MEMORY_AND_DISK", 
                       choices=["NONE", "MEMORY_ONLY", "MEMORY_AND_DISK", "DISK_ONLY"],
                       help="Cache storage level")
    parser.add_argument("--enable-adaptive-query", action="store_true", help="Enable adaptive query execution")
    parser.add_argument("--max-records-per-file", type=int, help="Maximum records per output file")
    parser.add_argument("--coalesce-partitions", type=int, default=0, help="Number of partitions to coalesce")
    
    return parser.parse_args()


def main():
    """Main function to run the ETL job"""
    
    # Parse arguments
    args = parse_arguments()
    config = SparkJobConfig(args)
    
    # Create Spark session
    spark = create_spark_session(config)
    
    # Apply additional optimizations
    optimizer = SparkOptimizer()
    spark = optimizer.optimize_spark_session(spark, config)
    
    try:
        # Create and run ETL processor
        processor = ETLJobProcessor(spark, config)
        processor.run_etl_pipeline()
        
    except Exception as e:
        logger.error(f"Job failed with error: {str(e)}")
        sys.exit(1)
    
    finally:
        # Stop Spark session
        spark.stop()
        logger.info("Spark session stopped")


if __name__ == "__main__":
    main()