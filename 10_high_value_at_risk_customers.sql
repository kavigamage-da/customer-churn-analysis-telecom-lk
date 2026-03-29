-- ============================================================
-- Query 10: High-Value At-Risk Customer Identification
-- Business Question: Which specific customers should the
--                    retention team call THIS WEEK?
--                    Prioritised by revenue impact.
-- Technique: Multi-CTE pipeline + composite risk ranking
-- This is the actionable output the CEO dashboard uses.
-- ============================================================

WITH risk_flags AS (
    SELECT
        customer_id,
        product_tier,
        contract_type,
        region,
        monthly_spend,
        tenure_months,
        support_tickets,
        last_login_days,
        risk_score,
        churned,
        -- Individual risk flags
        CASE WHEN support_tickets >= 3   THEN 1 ELSE 0 END AS flag_high_tickets,
        CASE WHEN last_login_days > 30   THEN 1 ELSE 0 END AS flag_inactive,
        CASE WHEN risk_score >= 60       THEN 1 ELSE 0 END AS flag_high_risk_score,
        CASE WHEN tenure_months < 6      THEN 1 ELSE 0 END AS flag_new_customer,
        CASE WHEN contract_type = 'Month-to-Month' THEN 1 ELSE 0 END AS flag_no_contract
    FROM customers
),
composite_score AS (
    SELECT
        *,
        -- Composite risk score: sum of weighted flags
        (flag_high_tickets  * 3 +
         flag_inactive       * 2 +
         flag_high_risk_score* 2 +
         flag_new_customer   * 1 +
         flag_no_contract    * 1)                           AS composite_risk,
        -- Revenue tier for prioritisation
        CASE
            WHEN monthly_spend >= 100 THEN 'High Value'
            WHEN monthly_spend >= 50  THEN 'Mid Value'
            ELSE                           'Low Value'
        END AS revenue_tier
    FROM risk_flags
),
prioritised AS (
    SELECT
        *,
        -- Final priority rank: high revenue + high risk first
        ROW_NUMBER() OVER (
            ORDER BY 
                CASE revenue_tier WHEN 'High Value' THEN 1
                                  WHEN 'Mid Value'  THEN 2
                                  ELSE 3 END,
                composite_risk DESC,
                monthly_spend DESC
        ) AS retention_priority_rank
    FROM composite_score
    WHERE composite_risk >= 3          -- Only genuinely at-risk
      AND churned = 0                  -- Still active customers
)
SELECT
    retention_priority_rank,
    customer_id,
    product_tier,
    revenue_tier,
    region,
    contract_type,
    monthly_spend,
    tenure_months,
    support_tickets,
    last_login_days,
    risk_score,
    composite_risk,
    -- Human-readable action recommendation
    CASE
        WHEN flag_high_tickets = 1 AND flag_inactive = 1
            THEN 'URGENT: Call now — support issues + inactive'
        WHEN flag_high_tickets = 1
            THEN 'CALL: Resolve support tickets proactively'
        WHEN flag_inactive = 1
            THEN 'EMAIL: Re-engagement campaign immediately'
        WHEN flag_new_customer = 1
            THEN 'ONBOARD: Schedule success check-in call'
        ELSE
            'MONITOR: Watch for further risk signals'
    END AS recommended_action
FROM prioritised
WHERE retention_priority_rank <= 500   -- Top 500 customers to act on this week
ORDER BY retention_priority_rank;

-- THIS IS THE MONEY QUERY.
-- This is what the CEO sees on Monday morning — a ranked list of customers
-- the retention team must call before Friday.
-- Estimated monthly revenue saved if top 100 retained: SUM(monthly_spend) for rows 1-100.
