-- BUSINESS QUESTION: Which regions are losing the most revenue to churn?
-- DECISION: Regional retention budget allocation.
-- FINDING: Western Province loses most MRR in absolute terms.

-- ============================================================
-- Query 08: Regional Churn Analysis with Revenue Impact
-- Business Question: Which regions are losing the most revenue
--                    to churn? Where to prioritise field sales?
-- Technique: CTEs + revenue loss quantification
-- ============================================================

WITH regional_stats AS (
    SELECT
        region,
        COUNT(*)                                                AS total_customers,
        SUM(churned)                                            AS churned_count,
        ROUND(100.0 * SUM(churned) / COUNT(*), 2)              AS churn_rate_pct,
        -- Monthly recurring revenue (MRR) metrics
        ROUND(SUM(monthly_spend), 2)                            AS total_mrr,
        ROUND(SUM(CASE WHEN churned = 0 THEN monthly_spend ELSE 0 END), 2) AS retained_mrr,
        ROUND(SUM(CASE WHEN churned = 1 THEN monthly_spend ELSE 0 END), 2) AS lost_mrr,
        ROUND(AVG(support_tickets), 2)                          AS avg_support_tickets,
        ROUND(AVG(risk_score), 1)                               AS avg_risk_score
    FROM customers
    GROUP BY region
)
SELECT
    region,
    total_customers,
    churned_count,
    churn_rate_pct,
    total_mrr,
    lost_mrr,
    ROUND(100.0 * lost_mrr / NULLIF(total_mrr, 0), 2)          AS pct_mrr_lost,
    avg_support_tickets,
    avg_risk_score,
    -- Rank regions by MRR lost (highest priority for intervention)
    RANK() OVER (ORDER BY lost_mrr DESC)                         AS intervention_priority
FROM regional_stats
ORDER BY lost_mrr DESC;

-- Expected insight: Western Province loses the most MRR in absolute terms (largest customer base).
-- But Northern/Eastern may have higher churn RATES â€” different problem, different solution.

