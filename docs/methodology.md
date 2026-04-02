\# Methodology — Sri Lanka Telecom Churn Analysis



\## Why We Built This Dataset



No public dataset exists calibrated to Sri Lankan telecom market conditions.

Rather than use a generic Western dataset and produce findings irrelevant to

the local market, we engineered a 50,000-row dataset using realistic statistical

distributions calibrated to Sri Lankan telecom benchmarks.



\## How the Dataset Was Built



| Feature | Distribution Used | Reason |

|---|---|---|

| Support tickets | Negative binomial | Overdispersed count data — most customers have 0, few have many |

| Login inactivity | Exponential decay | Usage drop-off follows decay pattern not uniform distribution |

| Monthly spend | Tier-correlated normal | Spend clusters around tier price points with natural variance |

| Churn probability | Weighted combination | Seven independent risk factors combined, not random assignment |



Churn was not randomly assigned. Each customer received a churn probability

score based on a weighted combination of support tickets, inactivity, tenure,

contract type, spend trend, product tier, and payment method — reflecting how

churn actually works in a real telecom business.



\## Cross-Validation Approach



Every key finding was validated against the IBM Telco Churn dataset

(7,043 real customers, Kaggle). A finding was only included in the final

analysis if it held across both datasets. This confirms findings reflect

real, generalisable churn patterns — not artefacts of the synthetic data.



\## Why SQL Was Used Alongside Python



Python handles the statistical analysis and visualisation.

SQL handles the business queries — the questions a retention manager or

CEO would actually ask on a Monday morning. Keeping these separate mirrors

how analytics works in a real company: data engineering in Python,

business reporting in SQL, executive visibility in Power BI.



\## Assumptions and Limitations



\- Dataset is synthetic — reflects realistic distributions but not real customer records

\- Churn probability model is weighted by domain knowledge, not trained on historical outcomes

\- Revenue figures are modelled from tier-based spend distributions

\- Intervention ROI estimates (12:1, 2.4x) are directional, not audited figures



\## What We Would Do Next



\- Integrate live CRM data to replace the synthetic dataset

\- A/B test day-25 vs day-30 re-engagement email to validate the inactivity cliff

\- Build a real-time risk scoring API so the ranked list refreshes daily

\- Add Net Promoter Score as a leading indicator alongside ticket count

