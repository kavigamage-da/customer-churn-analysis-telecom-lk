-- ============================================================
-- Query 03: Cohort Retention Analysis (Window Functions)
-- Business Question: Which signup cohort (by tenure group)
--                    retains customers best over time?
-- Technique: CTE + CASE WHEN bucketing + window aggregation
-- Used in: Segment Drilldown page — Cohort Retention table
-- ============================================================

WITH cohort_buckets AS (
    SELECT
        customer_id,
        churned,
        monthly_spend,
        -- Bucket customers into cohorts by how long they've been with us
        CASE
            WHEN tenure_months BETWEEN 1  AND 6  THEN '01 - 0-6 months'
            WHEN tenure_months BETWEEN 7  AND 12 THEN '02 - 7-12 months'
            WHEN tenure_months BETWEEN 13 AND 24 THEN '03 - 13-24 months'
            WHEN tenure_months BETWEEN 25 AND 36 THEN '04 - 25-36 months'
            ELSE                                       '05 - 36+ months'
        END AS tenure_cohort
    FROM customers
),
cohort_stats AS (
    SELECT
        tenure_cohort,
        COUNT(*)                                            AS cohort_size,
        SUM(churned)                                        AS churned_count,
        COUNT(*) - SUM(churned)                             AS retained_count,
        ROUND(100.0 * SUM(churned) / COUNT(*), 2)          AS churn_rate_pct,
        ROUND(100.0 * (COUNT(*) - SUM(churned)) / COUNT(*), 2) AS retention_rate_pct,
        ROUND(AVG(monthly_spend), 2)                        AS avg_monthly_spend
    FROM cohort_buckets
    GROUP BY tenure_cohort
)
SELECT
    tenure_cohort,
    cohort_size,
    churned_count,
    retained_count,
    churn_rate_pct,
    retention_rate_pct,
    avg_monthly_spend,
    -- Running total of retained customers (window function)
    SUM(retained_count) OVER (ORDER BY tenure_cohort) AS cumulative_retained
FROM cohort_stats
ORDER BY tenure_cohort;

-- Expected insight: 0-6 month cohort has highest churn — first 6 months are critical.
-- Recommendation: Onboarding intervention program for months 1-3.
