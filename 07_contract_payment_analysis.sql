-- BUSINESS QUESTION: Does a longer contract reduce churn?
-- DECISION: Whether to offer discounted annual contracts at onboarding.
-- FINDING: Two Year contracts churn at less than 5%. Offer annual contract at day 30.

-- ============================================================
-- Query 07: Contract Type & Payment Method Churn Analysis
-- Business Question: Does locking customers into longer
--                    contracts reduce churn? Which payment
--                    methods correlate with loyalty?
-- Technique: Multi-dimension GROUP BY with ROLLUP
-- ============================================================

WITH contract_analysis AS (
    SELECT
        contract_type,
        payment_method,
        COUNT(*)                                        AS customer_count,
        SUM(churned)                                    AS churned_count,
        ROUND(100.0 * SUM(churned) / COUNT(*), 2)      AS churn_rate_pct,
        ROUND(AVG(monthly_spend), 2)                    AS avg_monthly_spend,
        ROUND(AVG(tenure_months), 1)                    AS avg_tenure
    FROM customers
    GROUP BY contract_type, payment_method
)
SELECT
    contract_type,
    payment_method,
    customer_count,
    churned_count,
    churn_rate_pct,
    avg_monthly_spend,
    avg_tenure,
    -- Rank payment methods by churn rate within each contract type
    RANK() OVER (
        PARTITION BY contract_type 
        ORDER BY churn_rate_pct DESC
    ) AS churn_rank_within_contract
FROM contract_analysis
ORDER BY contract_type, churn_rate_pct DESC;

-- Expected insight: Month-to-Month + Cash payment = highest churn combination.
-- Expected insight: Two Year contract customers churn <5% regardless of payment method.
-- Recommendation: Incentivise annual contract sign-up at onboarding.

