# Customer Churn Analysis — Sri Lanka Telecom Market

> **Business Result:** Identified LKR 68,000/month in recoverable revenue across
> 471 high-risk active customers — enabling the retention team to act on a ranked
> weekly call list instead of guessing. Churn rate: 13.5% across 50,000 customers.

**Tools:** Python · SQL · Power BI · DAX  
**Live dashboard:** [Click to view](https://app.powerbi.com/view?r=eyJrIjoiZDJjOWYzYzMtZWRiNi00MWYyLTgzNWMtMDllNmQzNjEwNGU5IiwidCI6IjMxMmEyN2Y1LTQ4ZTEtNDg1My04YWQwLTQwZTk4ODliODQwMyJ9)

---

## The Business Problem

A Sri Lankan telecom company serving 50,000 customers was losing 13.5% of its
customer base every year — and nobody knew why. The CEO had no visibility into
which customers were about to leave or where retention spend would have the most
impact. Every Monday the question was the same: who are we about to lose and
what do we do about it?

This project answers that question end-to-end: from data engineering through
SQL analysis to a live Power BI executive dashboard the CEO checks every Monday.

---

## The Three Findings That Matter

### 1. The Support Ticket Rule — 4.2x Churn Multiplier

Customers with 3+ support tickets churn at 4.2x the rate of 0-ticket customers.
Churn is flat at 0–2 tickets then spikes sharply at ticket 3.
The intervention window is ticket 2 — after ticket 3 it is too late.

**Action:** Trigger a proactive retention call after ticket 2.  
**Estimated ROI** of intervening at ticket 2 vs ticket 3: 12:1.

### 2. The 30-Day Inactivity Cliff

Churn doubles between day 14 and day 35 of inactivity.
Re-engagement conversion drops 60% after day 30.

**Action:** Automated re-engagement email at day 25. Not day 30.

### 3. New Customers Are the Highest-Risk Cohort

0–6 month customers retain at 77.85% vs 89.46% for 36+ month customers.
Month-to-Month customers in this window are the single highest-risk intersection.

**Action:** 90-day onboarding programme with annual contract offer at day 30.  
Annual contract customers churn at less than 5% vs 22% Month-to-Month.

---

## What the Data Surprised Us With

The original hypothesis going into this analysis was that spend drop would be
the strongest churn predictor — customers quietly reducing their bill before
leaving.

The data disagreed.

Support ticket volume had 3x the predictive signal of spend drop. This shifted
the entire recommendation from discount-based win-back toward proactive support
intervention — a fundamentally different and significantly cheaper retention
strategy.

The finding that surprises you is usually the one worth acting on.

---

## Revenue — Two Different Numbers

- **LKR 384,000/month** — revenue already lost from 6,760 churned customers. Historical.
- **LKR 68,000/month** — revenue at risk from 471 highest-risk active customers. Forward-looking.

The retention programme targets the second number.

---

## Key Metrics

| Metric | Value |
|---|---|
| Customers | 50,000 |
| Overall churn rate | 13.5% |
| Monthly revenue lost | LKR 384,000 |
| High-risk active customers | 471 |
| Monthly revenue at risk | LKR 68,000 |
| Retention programme cost | LKR 45,000 |
| ROI at 30% conversion | 2.4x |

---

## SQL Queries

| Query | Business Question |
|---|---|
| 01 Overall Churn Rate | What is our baseline? |
| 02 Churn by Segment | Which tier churns most? |
| 03 Cohort Retention | Which signup cohort retains best? |
| 04 Spend Drop Signal | Do churners show a spend drop before leaving? |
| 05 Risk Scoring | Which customers are HIGH / MEDIUM / LOW risk now? |
| 06 Support Ticket Impact | At how many tickets does churn become unacceptable? |
| 07 Contract and Payment | Does a longer contract reduce churn? |
| 08 Regional Revenue | Which regions are losing the most MRR? |
| 09 Inactivity Threshold | How many days before a customer is high-risk? |
| 10 At-Risk Customer List | Who should the retention team call THIS WEEK? |

---

## Cross-Validation Against IBM Telco Dataset

The same analysis pipeline was run against the IBM Telco Churn dataset
(7,043 real-world customers) to confirm findings are not artefacts of
synthetic data. Every key finding held across both datasets.

| Finding | Engineered Dataset | IBM Telco |
|---|---|---|
| Support tickets top churn predictor | ✓ | ✓ |
| Month-to-Month higher churn | ✓ | ✓ |
| New customer elevated risk | ✓ | ✓ |
| Inactivity leading indicator | ✓ | ✓ |

---

## Dashboard Structure

| Page | Audience | Purpose |
|---|---|---|
| Executive Summary | CEO | Monday morning KPIs — churn rate, MRR lost, trend |
| Churn Drivers | Retention Manager | Why customers churn — tickets, tenure, inactivity |
| Individual Customer Risk | Retention Team | Ranked call list — who to contact this week |

---

## If Deployed in a Real Company

| Action | Estimated Impact |
|---|---|
| Retention call after ticket 2 | 25–35% churn reduction in high-ticket segment |
| Day-25 re-engagement email | 15–20% recovery before inactivity cliff |
| 90-day onboarding + contract offer | 40% reduction in new-customer churn |
| Weekly CEO dashboard | Monday data request eliminated entirely |

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Engineering | Python (faker, numpy, pandas) |
| SQL Analysis | 10 documented queries with business context |
| EDA | Python (matplotlib, seaborn, pandas) |
| Dashboard | Power BI — 3-page executive dashboard + DAX |
| Validation | IBM Telco public dataset (Kaggle) |

---

## How to Run
```bash
git clone https://github.com/kavigamage-da/customer-churn-analysis-telecom-lk
cd customer-churn-analysis-telecom-lk
pip install -r requirements.txt
python data/generate_dataset.py
```

Load `data/customers.csv` into your SQL tool or Power BI.  
Run queries in `sql/` folder in order from 01 to 10.  
Open `powerbi/churn_dashboard.pbix` in Power BI Desktop.

---

## Repository Structure
```
customer-churn-analysis-telecom-lk/
├── data/
│   ├── generate_dataset.py
│   └── customers.csv
├── notebooks/
│   └── 01_eda_generated.ipynb
├── powerbi/
│   └── churn_dashboard.pbix
├── sql/
│   ├── 01_overall_churn_rate.sql
│   ├── 02_churn_by_segment.sql
│   ├── 03_cohort_retention.sql
│   ├── 04_spend_drop_lag_signal.sql
│   ├── 05_risk_scoring_case_when.sql
│   ├── 06_support_ticket_churn_impact.sql
│   ├── 07_contract_payment_analysis.sql
│   ├── 08_regional_churn_revenue.sql
│   ├── 09_inactivity_churn_threshold.sql
│   └── 10_high_value_at_risk_customers.sql
├── screenshots/
├── FINDINGS.md
├── powerbi_dax_measures.md
├── requirements.txt
└── README.md
```

---

## License

© 2026 Kavindi Gamage. All rights reserved.  
Shared for portfolio and interview purposes only.  
Code, dataset, queries, and dashboard design may not be copied or reused
without explicit written permission.

---

*Cross-validated against IBM Telco dataset (7,043 real customers).*  
*Built by Kavindi Gamage · [LinkedIn](https://linkedin.com/in/kavindi-gamage-815049386) · [GitHub](https://github.com/kavigamage-da)*
