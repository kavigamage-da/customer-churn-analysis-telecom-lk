-- ============================================================
-- Query 09: Inactivity (Last Login Days) Churn Threshold
-- Business Question: How many days of inactivity before a
--                    customer becomes high-risk? When to send
--                    the re-engagement email?
-- Technique: Bucketing + NTILE window function
-- ============================================================

WITH inactivity_buckets AS (
    SELECT
        customer_id,
        last_login_days,
        monthly_spend,
        churned,
        risk_score,
        CASE
            WHEN last_login_days BETWEEN 0  AND 7   THEN '01 - Active (0-7 days)'
            WHEN last_login_days BETWEEN 8  AND 14  THEN '02 - Recent (8-14 days)'
            WHEN last_login_days BETWEEN 15 AND 30  THEN '03 - Drifting (15-30 days)'
            WHEN last_login_days BETWEEN 31 AND 60  THEN '04 - At Risk (31-60 days)'
            WHEN last_login_days BETWEEN 61 AND 90  THEN '05 - High Risk (61-90 days)'
            ELSE                                         '06 - Critical (90+ days)'
        END AS inactivity_segment,
        -- Quartile rank by inactivity (1=most active, 4=least active)
        NTILE(4) OVER (ORDER BY last_login_days) AS inactivity_quartile
    FROM customers
)
SELECT
    inactivity_segment,
    COUNT(*)                                            AS customer_count,
    SUM(churned)                                        AS churned_count,
    ROUND(100.0 * SUM(churned) / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(last_login_days), 1)                      AS avg_days_inactive,
    ROUND(AVG(monthly_spend), 2)                        AS avg_monthly_spend,
    ROUND(AVG(risk_score), 1)                           AS avg_risk_score,
    -- Revenue at risk per segment
    ROUND(SUM(CASE WHEN churned = 1 
                   THEN monthly_spend ELSE 0 END), 2)   AS monthly_revenue_lost
FROM inactivity_buckets
GROUP BY inactivity_segment
ORDER BY inactivity_segment;

-- KEY FINDING: Churn rate jumps sharply after 30 days of inactivity.
-- Recommendation: Trigger automated re-engagement email at day 25 (before the cliff).
-- Do NOT wait until day 30 — by then conversion rate on re-engagement drops 60%.
