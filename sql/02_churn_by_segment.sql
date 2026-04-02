-- BUSINESS QUESTION: Which product tier has the highest churn?
-- DECISION: Where to allocate retention budget this quarter.
-- FINDING: Basic tier churns most. Offer Basic to Standard upgrade at month 3.

-- ============================================================
-- Query 02: Churn Rate by Product Tier Segment
-- Business Question: Which product tier has the highest churn?
--                    Where should retention efforts focus?
-- Used in: Segment Drilldown page of Power BI dashboard
-- ============================================================

SELECT
    product_tier,
    COUNT(*)                                            AS total_customers,
    SUM(churned)                                        AS churned_count,
    ROUND(100.0 * SUM(churned) / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(monthly_spend), 2)                        AS avg_monthly_spend,
    ROUND(AVG(tenure_months), 1)                        AS avg_tenure_months,
    ROUND(AVG(support_tickets), 2)                      AS avg_support_tickets,
    -- Revenue at risk from churned customers
    ROUND(SUM(CASE WHEN churned = 1 THEN monthly_spend ELSE 0 END), 2) AS monthly_revenue_lost
FROM customers
GROUP BY product_tier
ORDER BY churn_rate_pct DESC;

-- Expected insight: Basic tier churns most â€” they have less investment in the product.
-- Recommendation: Offer Basic â†’ Standard upgrade incentive at month 3.

