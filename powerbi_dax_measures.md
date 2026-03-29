# DAX Measures — Customer Churn Dashboard
# Copy these into Power BI Desktop > New Measure

# ── PAGE 1: Executive Summary ──────────────────────────────────────────────────

Total Customers = COUNTROWS(customers)

Total Churned = CALCULATE(COUNTROWS(customers), customers[churned] = 1)

Churn Rate % = 
DIVIDE(
    CALCULATE(COUNTROWS(customers), customers[churned] = 1),
    COUNTROWS(customers),
    0
) * 100

Monthly Revenue Lost = 
CALCULATE(
    SUM(customers[monthly_spend]),
    customers[churned] = 1
)

Total MRR = SUM(customers[monthly_spend])

MRR Retention Rate % = 
DIVIDE(
    CALCULATE(SUM(customers[monthly_spend]), customers[churned] = 0),
    SUM(customers[monthly_spend]),
    0
) * 100


# ── PAGE 2: Segment Drilldown ──────────────────────────────────────────────────

Avg Tenure Churned = 
CALCULATE(
    AVERAGE(customers[tenure_months]),
    customers[churned] = 1
)

Avg Tenure Retained = 
CALCULATE(
    AVERAGE(customers[tenure_months]),
    customers[churned] = 0
)

Tenure Difference = [Avg Tenure Retained] - [Avg Tenure Churned]

Churn Rate by Tier = 
DIVIDE(
    CALCULATE(COUNTROWS(customers), customers[churned] = 1),
    COUNTROWS(customers),
    0
) * 100

High Risk Customer Count = 
CALCULATE(
    COUNTROWS(customers),
    customers[risk_score] >= 60,
    customers[churned] = 0
)

Revenue at Risk = 
CALCULATE(
    SUM(customers[monthly_spend]),
    customers[risk_score] >= 60,
    customers[churned] = 0
)


# ── PAGE 3: Individual Customer Risk ──────────────────────────────────────────

Avg Risk Score = AVERAGE(customers[risk_score])

Avg Risk Score HIGH = 
CALCULATE(
    AVERAGE(customers[risk_score]),
    customers[risk_score] >= 60
)

Support Ticket Churn Rate = 
DIVIDE(
    CALCULATE(COUNTROWS(customers), customers[churned] = 1, customers[support_tickets] >= 3),
    CALCULATE(COUNTROWS(customers), customers[support_tickets] >= 3),
    0
) * 100

Inactive Customer Count = 
CALCULATE(
    COUNTROWS(customers),
    customers[last_login_days] > 30,
    customers[churned] = 0
)

Monthly Trend = 
CALCULATE(
    [Churn Rate %],
    DATEADD(customers[signup_date], -1, MONTH)
)

# ── CONDITIONAL FORMATTING (use in Power BI as measure) ───────────────────────

Risk Color = 
SWITCH(
    TRUE(),
    SELECTEDVALUE(customers[risk_score]) >= 60, "#E24B4A",   -- Red: HIGH
    SELECTEDVALUE(customers[risk_score]) >= 35, "#EF9F27",   -- Amber: MEDIUM
    "#639922"                                                  -- Green: LOW
)
