-- BUSINESS QUESTION: Do churners show a spend drop before they leave?
-- DECISION: Whether to build a spend-monitoring alert.
-- FINDING: Support tickets outperform spend as a leading indicator. Act on tickets first.

-- ============================================================
-- Query 04: Spend Drop Signal â€” LAG() Churn Early Warning
-- Business Question: Do customers who churn show a spend drop
--                    3 months before they leave?
-- Technique: LAG() window function for spend trend detection
-- Used in: Individual Customer Risk page
-- ============================================================

WITH spend_change AS (
    SELECT
        customer_id,
        product_tier,
        contract_type,
        monthly_spend,
        spend_3m_ago,
        churned,
        risk_score,
        -- Calculate spend change vs 3 months ago
        ROUND(monthly_spend - spend_3m_ago, 2)                          AS spend_delta,
        ROUND(100.0 * (monthly_spend - spend_3m_ago) / 
              NULLIF(spend_3m_ago, 0), 2)                                AS spend_change_pct,
        -- Flag customers with significant spend drop (>15% decline)
        CASE WHEN (monthly_spend - spend_3m_ago) / NULLIF(spend_3m_ago, 0) < -0.15
             THEN 1 ELSE 0 END                                           AS spend_drop_flag
    FROM customers
)
SELECT
    spend_drop_flag,
    COUNT(*)                                            AS customer_count,
    SUM(churned)                                        AS churned_count,
    ROUND(100.0 * SUM(churned) / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(spend_change_pct), 2)                     AS avg_spend_change_pct,
    ROUND(AVG(monthly_spend), 2)                        AS avg_current_spend,
    ROUND(AVG(risk_score), 1)                           AS avg_risk_score
FROM spend_change
GROUP BY spend_drop_flag
ORDER BY spend_drop_flag;

-- Expected insight: Customers with >15% spend drop have 2-3x higher churn rate.
-- This is a leading indicator â€” act BEFORE they churn, not after.
-- Action: Trigger loyalty offer when spend drops >10% month-over-month.

