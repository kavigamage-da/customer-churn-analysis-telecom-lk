-- ============================================================
-- Query 01: Overall Churn Rate & Key Summary Metrics
-- Business Question: What is our current churn rate and how
--                    does it break down at the top level?
-- Used in: Executive Summary page of Power BI dashboard
-- ============================================================

SELECT
    COUNT(*)                                                        AS total_customers,
    SUM(churned)                                                    AS total_churned,
    COUNT(*) - SUM(churned)                                         AS total_retained,
    ROUND(100.0 * SUM(churned) / COUNT(*), 2)                      AS churn_rate_pct,
    ROUND(AVG(monthly_spend), 2)                                    AS avg_monthly_spend,
    ROUND(AVG(CASE WHEN churned = 1 THEN monthly_spend END), 2)    AS avg_spend_churned,
    ROUND(AVG(CASE WHEN churned = 0 THEN monthly_spend END), 2)    AS avg_spend_retained,
    ROUND(AVG(tenure_months), 1)                                    AS avg_tenure_months,
    ROUND(AVG(CASE WHEN churned = 1 THEN tenure_months END), 1)    AS avg_tenure_churned,
    ROUND(AVG(CASE WHEN churned = 0 THEN tenure_months END), 1)    AS avg_tenure_retained
FROM customers;

-- Expected insight: Churned customers have lower avg spend and shorter tenure.
-- This confirms churn is concentrated in newer, lower-value customers.
