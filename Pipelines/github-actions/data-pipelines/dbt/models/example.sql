{{ config(
    materialized='incremental',
    unique_key='customer_id',
    on_schema_change='fail',
    pre_hook="{{ log('Starting customer analytics transformation', info=true) }}",
    post_hook=[
        "{{ log('Customer analytics transformation completed', info=true) }}",
        "ANALYZE TABLE {{ this }} COMPUTE STATISTICS"
    ],
    tags=['analytics', 'customer', 'daily'],
    meta={
        'owner': 'data-team',
        'description': 'Customer analytics with comprehensive metrics and segmentation',
        'refresh_frequency': 'daily',
        'data_classification': 'internal'
    }
) }}

/*
    Customer Analytics Model
    
    This model creates comprehensive customer analytics including:
    - Transaction behavior and patterns
    - Customer lifetime value (CLV) calculations  
    - Segmentation and scoring
    - Risk and churn indicators
    - Geographic and temporal analysis
    
    Dependencies:
    - raw_customers: Customer master data
    - raw_transactions: Transaction history
    - raw_products: Product catalog
    
    Business Logic:
    - Calculates rolling metrics over multiple time windows
    - Implements RFM analysis for customer segmentation
    - Computes predictive indicators for churn and value
    - Handles data quality issues with robust error handling
*/

WITH customer_base AS (
    SELECT 
        customer_id,
        email,
        first_name,
        last_name,
        registration_date,
        country,
        age,
        CASE 
            WHEN age < 25 THEN 'Gen Z'
            WHEN age < 40 THEN 'Millennial' 
            WHEN age < 55 THEN 'Gen X'
            WHEN age < 75 THEN 'Baby Boomer'
            ELSE 'Silent Generation'
        END AS generation,
        CASE
            WHEN age BETWEEN 18 AND 24 THEN 'Young Adult'
            WHEN age BETWEEN 25 AND 34 THEN 'Adult'
            WHEN age BETWEEN 35 AND 49 THEN 'Middle Age'
            WHEN age BETWEEN 50 AND 64 THEN 'Pre-Senior'
            ELSE 'Senior'
        END AS age_group,
        CURRENT_DATE() - registration_date AS days_since_registration,
        -- Data quality flags
        CASE WHEN email LIKE '%@%' THEN 1 ELSE 0 END AS email_valid,
        CASE WHEN age BETWEEN 13 AND 120 THEN 1 ELSE 0 END AS age_valid
    FROM {{ ref('raw_customers') }}
    WHERE customer_id IS NOT NULL
        AND registration_date IS NOT NULL
        {% if is_incremental() %}
            -- Only process new or updated customers in incremental runs
            AND (registration_date >= (SELECT MAX(last_transaction_date) FROM {{ this }})
                 OR customer_id IN (
                     SELECT DISTINCT customer_id 
                     FROM {{ ref('raw_transactions') }}
                     WHERE transaction_date >= (SELECT MAX(last_transaction_date) FROM {{ this }})
                 ))
        {% endif %}
),

transaction_metrics AS (
    SELECT 
        t.customer_id,
        -- Transaction counts and amounts
        COUNT(*) AS total_transactions,
        COUNT(CASE WHEN t.status = 'completed' THEN 1 END) AS completed_transactions,
        COUNT(CASE WHEN t.status = 'failed' THEN 1 END) AS failed_transactions,
        COUNT(CASE WHEN t.status = 'cancelled' THEN 1 END) AS cancelled_transactions,
        
        SUM(CASE WHEN t.status = 'completed' THEN t.amount ELSE 0 END) AS total_amount,
        AVG(CASE WHEN t.status = 'completed' THEN t.amount ELSE NULL END) AS avg_transaction_amount,
        MIN(CASE WHEN t.status = 'completed' THEN t.amount ELSE NULL END) AS min_transaction_amount,
        MAX(CASE WHEN t.status = 'completed' THEN t.amount ELSE NULL END) AS max_transaction_amount,
        STDDEV(CASE WHEN t.status = 'completed' THEN t.amount ELSE NULL END) AS stddev_transaction_amount,
        
        -- Temporal analysis
        MIN(t.transaction_date) AS first_transaction_date,
        MAX(t.transaction_date) AS last_transaction_date,
        CURRENT_DATE() - MAX(t.transaction_date) AS days_since_last_transaction,
        MAX(t.transaction_date) - MIN(t.transaction_date) AS customer_lifetime_days,
        
        -- Frequency analysis
        COUNT(DISTINCT DATE_TRUNC('month', t.transaction_date)) AS active_months,
        COUNT(DISTINCT t.merchant_id) AS unique_merchants,
        COUNT(DISTINCT t.product_category) AS unique_categories,
        
        -- Recent activity (last 30, 90, 365 days)
        COUNT(CASE WHEN t.transaction_date >= CURRENT_DATE() - INTERVAL '30 days' 
              AND t.status = 'completed' THEN 1 END) AS transactions_last_30d,
        COUNT(CASE WHEN t.transaction_date >= CURRENT_DATE() - INTERVAL '90 days' 
              AND t.status = 'completed' THEN 1 END) AS transactions_last_90d,
        COUNT(CASE WHEN t.transaction_date >= CURRENT_DATE() - INTERVAL '365 days' 
              AND t.status = 'completed' THEN 1 END) AS transactions_last_365d,
        
        SUM(CASE WHEN t.transaction_date >= CURRENT_DATE() - INTERVAL '30 days' 
            AND t.status = 'completed' THEN t.amount ELSE 0 END) AS amount_last_30d,
        SUM(CASE WHEN t.transaction_date >= CURRENT_DATE() - INTERVAL '90 days' 
            AND t.status = 'completed' THEN t.amount ELSE 0 END) AS amount_last_90d,
        SUM(CASE WHEN t.transaction_date >= CURRENT_DATE() - INTERVAL '365 days' 
            AND t.status = 'completed' THEN t.amount ELSE 0 END) AS amount_last_365d,
        
        -- Payment method preferences
        MODE() WITHIN GROUP (ORDER BY t.payment_method) AS preferred_payment_method,
        COUNT(DISTINCT t.payment_method) AS payment_methods_used,
        
        -- Geographic analysis
        COUNT(DISTINCT t.transaction_country) AS countries_transacted,
        MODE() WITHIN GROUP (ORDER BY t.transaction_country) AS most_common_country,
        
        -- Time-based patterns
        AVG(EXTRACT(HOUR FROM t.transaction_timestamp)) AS avg_transaction_hour,
        COUNT(CASE WHEN EXTRACT(DOW FROM t.transaction_date) IN (0,6) THEN 1 END) AS weekend_transactions,
        
        -- Behavioral indicators
        SUM(CASE WHEN t.amount > 1000 THEN 1 ELSE 0 END) AS high_value_transactions,
        AVG(CASE WHEN LAG(t.transaction_date) OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date) IS NOT NULL
             THEN t.transaction_date - LAG(t.transaction_date) OVER (PARTITION BY t.customer_id ORDER BY t.transaction_date)
             ELSE NULL END) AS avg_days_between_transactions
             
    FROM {{ ref('raw_transactions') }} t
    WHERE t.customer_id IS NOT NULL
        AND t.transaction_date IS NOT NULL
        {% if is_incremental() %}
            -- Only process transactions for customers being updated
            AND t.customer_id IN (SELECT customer_id FROM customer_base)
        {% endif %}
    GROUP BY t.customer_id
),

-- RFM Analysis (Recency, Frequency, Monetary)
rfm_analysis AS (
    SELECT 
        customer_id,
        days_since_last_transaction AS recency,
        total_transactions AS frequency,
        total_amount AS monetary,
        
        -- Calculate RFM scores (1-5, where 5 is best)
        CASE 
            WHEN days_since_last_transaction <= 30 THEN 5
            WHEN days_since_last_transaction <= 90 THEN 4
            WHEN days_since_last_transaction <= 180 THEN 3
            WHEN days_since_last_transaction <= 365 THEN 2
            ELSE 1
        END AS recency_score,
        
        CASE 
            WHEN total_transactions >= 50 THEN 5
            WHEN total_transactions >= 20 THEN 4
            WHEN total_transactions >= 10 THEN 3
            WHEN total_transactions >= 5 THEN 2
            ELSE 1
        END AS frequency_score,
        
        CASE 
            WHEN total_amount >= 10000 THEN 5
            WHEN total_amount >= 5000 THEN 4
            WHEN total_amount >= 1000 THEN 3
            WHEN total_amount >= 500 THEN 2
            ELSE 1
        END AS monetary_score
        
    FROM transaction_metrics
),

-- Customer Lifetime Value (CLV) Calculation
clv_calculation AS (
    SELECT 
        tm.customer_id,
        -- Historic CLV
        tm.total_amount AS historic_clv,
        
        -- Predicted CLV using simplified model
        CASE 
            WHEN tm.customer_lifetime_days > 0 THEN 
                (tm.total_amount / NULLIF(tm.customer_lifetime_days, 0)) * 365 * 2  -- Assume 2 more years
            ELSE tm.avg_transaction_amount * 12  -- Fallback for new customers
        END AS predicted_clv,
        
        -- Customer value segments
        CASE 
            WHEN tm.total_amount >= 10000 THEN 'VIP'
            WHEN tm.total_amount >= 5000 THEN 'High Value'
            WHEN tm.total_amount >= 1000 THEN 'Medium Value'
            WHEN tm.total_amount >= 100 THEN 'Low Value'
            ELSE 'New Customer'
        END AS value_segment,
        
        -- Activity-based segments
        CASE 
            WHEN tm.transactions_last_30d > 0 THEN 'Active'
            WHEN tm.transactions_last_90d > 0 THEN 'Lapsed'
            WHEN tm.transactions_last_365d > 0 THEN 'Inactive'
            ELSE 'Dormant'
        END AS activity_segment
        
    FROM transaction_metrics tm
),

-- Churn Risk Scoring
churn_risk AS (
    SELECT 
        customer_id,
        CASE 
            WHEN days_since_last_transaction > 365 THEN 'High Risk'
            WHEN days_since_last_transaction > 180 THEN 'Medium Risk'  
            WHEN days_since_last_transaction > 90 THEN 'Low Risk'
            ELSE 'Active'
        END AS churn_risk_category,
        
        -- Churn score (0-100, higher = more likely to churn)
        GREATEST(0, LEAST(100, 
            (days_since_last_transaction * 0.2) +
            (CASE WHEN failed_transactions > completed_transactions * 0.1 THEN 20 ELSE 0 END) +
            (CASE WHEN transactions_last_90d = 0 AND total_transactions > 5 THEN 30 ELSE 0 END) +
            (CASE WHEN avg_days_between_transactions > 60 THEN 15 ELSE 0 END)
        )) AS churn_score
        
    FROM transaction_metrics
),

-- Final aggregation with all metrics
final_metrics AS (
    SELECT 
        cb.customer_id,
        cb.email,
        cb.first_name,
        cb.last_name,
        cb.registration_date,
        cb.country,
        cb.age,
        cb.generation,
        cb.age_group,
        cb.days_since_registration,
        cb.email_valid,
        cb.age_valid,
        
        -- Transaction metrics
        COALESCE(tm.total_transactions, 0) AS total_transactions,
        COALESCE(tm.completed_transactions, 0) AS completed_transactions,
        COALESCE(tm.failed_transactions, 0) AS failed_transactions,
        COALESCE(tm.cancelled_transactions, 0) AS cancelled_transactions,
        COALESCE(tm.total_amount, 0) AS total_amount,
        tm.avg_transaction_amount,
        tm.min_transaction_amount,
        tm.max_transaction_amount,
        tm.stddev_transaction_amount,
        tm.first_transaction_date,
        tm.last_transaction_date,
        COALESCE(tm.days_since_last_transaction, 9999) AS days_since_last_transaction,
        COALESCE(tm.customer_lifetime_days, 0) AS customer_lifetime_days,
        COALESCE(tm.active_months, 0) AS active_months,
        COALESCE(tm.unique_merchants, 0) AS unique_merchants,
        COALESCE(tm.unique_categories, 0) AS unique_categories,
        
        -- Recent activity
        COALESCE(tm.transactions_last_30d, 0) AS transactions_last_30d,
        COALESCE(tm.transactions_last_90d, 0) AS transactions_last_90d,
        COALESCE(tm.transactions_last_365d, 0) AS transactions_last_365d,
        COALESCE(tm.amount_last_30d, 0) AS amount_last_30d,
        COALESCE(tm.amount_last_90d, 0) AS amount_last_90d,
        COALESCE(tm.amount_last_365d, 0) AS amount_last_365d,
        
        -- Preferences and patterns
        tm.preferred_payment_method,
        COALESCE(tm.payment_methods_used, 0) AS payment_methods_used,
        COALESCE(tm.countries_transacted, 0) AS countries_transacted,
        tm.most_common_country,
        tm.avg_transaction_hour,
        COALESCE(tm.weekend_transactions, 0) AS weekend_transactions,
        COALESCE(tm.high_value_transactions, 0) AS high_value_transactions,
        tm.avg_days_between_transactions,
        
        -- RFM scores
        COALESCE(rfm.recency_score, 1) AS recency_score,
        COALESCE(rfm.frequency_score, 1) AS frequency_score,
        COALESCE(rfm.monetary_score, 1) AS monetary_score,
        COALESCE(rfm.recency_score, 1) + COALESCE(rfm.frequency_score, 1) + COALESCE(rfm.monetary_score, 1) AS rfm_total_score,
        
        -- CLV and segments
        COALESCE(clv.historic_clv, 0) AS historic_clv,
        COALESCE(clv.predicted_clv, 0) AS predicted_clv,
        COALESCE(clv.value_segment, 'Unknown') AS value_segment,
        COALESCE(clv.activity_segment, 'Unknown') AS activity_segment,
        
        -- Churn risk
        COALESCE(cr.churn_risk_category, 'Unknown') AS churn_risk_category,
        COALESCE(cr.churn_score, 50) AS churn_score,
        
        -- Quality and health indicators
        CASE 
            WHEN tm.total_transactions > 0 
            THEN ROUND(tm.completed_transactions * 100.0 / tm.total_transactions, 2)
            ELSE NULL 
        END AS success_rate,
        
        CASE 
            WHEN tm.customer_lifetime_days > 0
            THEN ROUND(tm.total_transactions * 1.0 / NULLIF(tm.customer_lifetime_days, 0), 4)
            ELSE NULL
        END AS transaction_frequency_per_day,
        
        -- Comprehensive customer health score (0-100)
        GREATEST(0, LEAST(100,
            (COALESCE(rfm.recency_score, 1) * 10) +
            (COALESCE(rfm.frequency_score, 1) * 8) + 
            (COALESCE(rfm.monetary_score, 1) * 12) +
            (CASE WHEN cb.email_valid = 1 AND cb.age_valid = 1 THEN 10 ELSE 0 END) +
            (CASE WHEN tm.total_transactions > 5 THEN 10 ELSE tm.total_transactions * 2 END) -
            (COALESCE(cr.churn_score, 0) * 0.3)
        )) AS customer_health_score,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS last_updated,
        '{{ invocation_id }}' AS dbt_run_id,
        '{{ var("pipeline_version", "1.0") }}' AS pipeline_version
        
    FROM customer_base cb
    LEFT JOIN transaction_metrics tm ON cb.customer_id = tm.customer_id
    LEFT JOIN rfm_analysis rfm ON cb.customer_id = rfm.customer_id
    LEFT JOIN clv_calculation clv ON cb.customer_id = clv.customer_id
    LEFT JOIN churn_risk cr ON cb.customer_id = cr.customer_id
)

SELECT * FROM final_metrics

-- Data quality tests will be run automatically by dbt
{% if execute %}
    {% set row_count_query %}
        SELECT COUNT(*) as row_count FROM ({{ sql }}) as subquery
    {% endset %}
    
    {% set results = run_query(row_count_query) %}
    {% if results %}
        {% set row_count = results.columns[0].values()[0] %}
        {{ log("Customer analytics model will produce " ~ row_count ~ " rows", info=true) }}
    {% endif %}
{% endif %}