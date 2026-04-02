"""
generate_dataset.py
-------------------
Generates a realistic 50,000-row customer churn dataset
for the E-Commerce / Telecom Customer Churn Analysis project.

Usage:
    python generate_dataset.py
Output:
    data/customers.csv
"""

import pandas as pd
import numpy as np
from faker import Faker
import os, random

fake = Faker()
np.random.seed(42)
random.seed(42)

N = 50_000

# ── Base features ──────────────────────────────────────────────────────────────
customer_ids   = [f"CUST{str(i).zfill(6)}" for i in range(1, N + 1)]
ages           = np.random.randint(18, 72, N)
tenure_months  = np.random.randint(1, 72, N)
product_tiers  = np.random.choice(["Basic", "Standard", "Premium"], N, p=[0.4, 0.4, 0.2])
monthly_spend  = np.where(
    product_tiers == "Basic",    np.random.normal(25,  8,  N).clip(5, 60),
    np.where(
    product_tiers == "Standard", np.random.normal(65,  15, N).clip(30, 120),
                                 np.random.normal(130, 25, N).clip(80, 220)
    )
).round(2)

support_tickets = np.random.negative_binomial(1, 0.5, N).clip(0, 12)
last_login_days = np.random.exponential(20, N).clip(0, 180).astype(int)
region          = np.random.choice(["Western", "Central", "Southern", "Northern", "Eastern"], N,
                                   p=[0.40, 0.20, 0.20, 0.10, 0.10])
contract_type   = np.random.choice(["Month-to-Month", "One Year", "Two Year"], N, p=[0.55, 0.30, 0.15])
payment_method  = np.random.choice(["Credit Card", "Bank Transfer", "Cash", "Online Wallet"], N,
                                   p=[0.35, 0.30, 0.20, 0.15])

# ── Spend drop (3 months before churn signal) ──────────────────────────────────
spend_3m_ago    = (monthly_spend * np.random.uniform(0.6, 1.1, N)).round(2)

# ── Churn logic (realistic drivers) ────────────────────────────────────────────
churn_prob = (
    0.05                                              # base rate
    + 0.20 * (support_tickets >= 3)                  # 3+ tickets → big driver
    + 0.15 * (last_login_days > 30)                  # inactive
    + 0.10 * (contract_type == "Month-to-Month")     # no lock-in
    + 0.08 * (tenure_months < 6)                     # new customers
    - 0.08 * (product_tiers == "Premium")            # premium stickier
    - 0.05 * (tenure_months > 36)                    # loyal customers
    + 0.12 * ((monthly_spend - spend_3m_ago) / (monthly_spend + 1) < -0.15)  # spend drop
)
churn_prob = churn_prob.clip(0.02, 0.90)
churned    = np.random.binomial(1, churn_prob, N)

# ── Risk score (for Power BI) ──────────────────────────────────────────────────
risk_score = (churn_prob * 100).round(1)

# ── Signup date ────────────────────────────────────────────────────────────────
base_date    = pd.Timestamp("2023-01-01")
signup_dates = [base_date - pd.DateOffset(months=int(t)) for t in tenure_months]

# ── Assemble DataFrame ─────────────────────────────────────────────────────────
df = pd.DataFrame({
    "customer_id":     customer_ids,
    "signup_date":     [d.strftime("%Y-%m-%d") for d in signup_dates],
    "age":             ages,
    "region":          region,
    "product_tier":    product_tiers,
    "contract_type":   contract_type,
    "payment_method":  payment_method,
    "tenure_months":   tenure_months,
    "monthly_spend":   monthly_spend,
    "spend_3m_ago":    spend_3m_ago,
    "support_tickets": support_tickets,
    "last_login_days": last_login_days,
    "risk_score":      risk_score,
    "churned":         churned,
})

os.makedirs("data", exist_ok=True)
df.to_csv("data/customers.csv", index=False)

print(f"Dataset generated: {N:,} rows")
print(f"Churn rate: {churned.mean():.1%}")
print(f"Columns: {list(df.columns)}")
print(f"Saved to: data/customers.csv")
