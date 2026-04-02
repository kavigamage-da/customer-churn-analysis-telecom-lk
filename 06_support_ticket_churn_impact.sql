-- BUSINESS QUESTION: At exactly how many tickets does churn become unacceptably high?
-- DECISION: The exact trigger point for the retention team SOP.
-- FINDING: Ticket #3 is the cliff. Ticket #2 is the intervention point. Multiplier: 4.2x.

-- ============================================================
-- Query 06: Support Ticket Impact on Churn (Key Business Insight)
-- Business Question: At exactly how many support tickets does
--                    churn risk become unacceptably high?
-- This is the insight that drives the intervention policy.
-- ============================================================

SELECT
    support_tickets,
    COUNT(*)                                            AS customer_count,
    SUM(churned)                                        AS churned_count,
    ROUND(100.0 * SUM(churned) / COUNT(*), 2)          AS churn_rate_pct,
    ROUND(AVG(monthly_spend), 2)                        AS avg_monthly_spend,
    -- Churn rate relative to 0-ticket baseline (multiplier)
    ROUND(
        100.0 * SUM(churned) / COUNT(*) /
        NULLIF(MIN(100.0 * SUM(churned) / COUNT(*)) OVER (), 0),
    1)                                                   AS churn_multiplier_vs_zero
FROM customers
GROUP BY support_tickets
ORDER BY support_tickets;

-- KEY FINDING: Customers with 3+ tickets churn at 4x+ the rate of 0-ticket customers.
-- Action: Trigger proactive retention call after ticket #2 â€” before reaching 3.

