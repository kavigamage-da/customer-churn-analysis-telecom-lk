-- BUSINESS QUESTION: Which customers are HIGH / MEDIUM / LOW risk right now?
-- DECISION: Retention team daily workflow prioritisation.
-- FINDING: Support Issues is the #1 driver among HIGH risk customers.

-- ============================================================
-- Query 05: CASE WHEN Churn Risk Scoring & Segmentation
-- Business Question: Which customers are HIGH / MEDIUM / LOW
--                    churn risk right now?
-- Technique: Multi-condition CASE WHEN risk scoring
-- Used in: Individual Customer Risk page â€” risk segment table
-- ============================================================

WITH risk_segments AS (
    SELECT
        customer_id,
        product_tier,
        contract_type,
        region,
        monthly_spend,
        support_tickets,
        last_login_days,
        tenure_months,
        risk_score,
        churned,
        -- Rule-based risk tier using CASE WHEN
        CASE
            WHEN risk_score >= 60                          THEN 'HIGH'
            WHEN risk_score BETWEEN 35 AND 59              THEN 'MEDIUM'
            ELSE                                                'LOW'
        END AS risk_tier,
        -- Primary churn driver (top reason for this customer)
        CASE
            WHEN support_tickets >= 3                      THEN 'Support Issues'
            WHEN last_login_days > 30                      THEN 'Inactivity'
            WHEN tenure_months < 6                         THEN 'New Customer'
            WHEN contract_type = 'Month-to-Month'          THEN 'No Contract Lock-in'
            ELSE                                                'Low Spend'
        END AS primary_churn_driver
    FROM customers
)
SELECT
    risk_tier,
    primary_churn_driver,
    COUNT(*)                                            AS customer_count,
    SUM(churned)                                        AS actual_churned,
    ROUND(100.0 * SUM(churned) / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(monthly_spend), 2)                        AS avg_monthly_spend,
    -- Monthly revenue at risk for HIGH risk customers
    ROUND(SUM(CASE WHEN risk_tier = 'HIGH' 
                   THEN monthly_spend ELSE 0 END), 2)   AS revenue_at_risk
FROM risk_segments
GROUP BY risk_tier, primary_churn_driver
ORDER BY 
    CASE risk_tier WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END,
    customer_count DESC;

-- Expected insight: 'Support Issues' is the #1 driver among HIGH risk customers.
-- Recommendation: Proactive support outreach after ticket #2 (before #3 is raised).

