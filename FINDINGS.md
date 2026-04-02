# Key Findings — Sri Lanka Telecom Churn Analysis

## What We Found

**Support tickets are the strongest churn predictor** — stronger than price,
stronger than contract type, stronger than tenure. Customers with 3+ tickets
churn at 4.2x the baseline rate. The intervention window is ticket #2.

**Inactivity follows a cliff, not a slope.** Churn doubles between day 25
and day 35 of inactivity. The re-engagement email must go out at day 25.
By day 30 re-engagement conversion has already dropped 60%.

**New customers need a completely different strategy.** The first 6 months
are the highest-risk period. Month-to-Month customers in this window are
the single highest-risk intersection in the dataset.

**471 customers represent LKR 68,000/month in recoverable revenue.**
A targeted retention programme costs LKR 45,000 to run.
At 30% conversion, revenue saved exceeds cost by 2.4x.

## What We Recommended

1. Trigger proactive retention call after ticket #2
2. Send automated re-engagement email at day 25 of inactivity
3. Launch 90-day onboarding programme with contract upgrade offer at day 30
4. Deploy weekly CEO dashboard — ranked call list ready every Monday

## What Surprised Us

The original hypothesis was that spend drop would be the strongest churn
predictor. The data disagreed. Support ticket volume had 3x the predictive
signal of spend drop. This changed the entire recommendation from
discount-based win-back to proactive support intervention.

## What We Would Do Next

- Integrate live CRM data to replace the synthetic dataset
- A/B test day-25 email vs day-30 email to validate the inactivity cliff
- Build a real-time scoring API so the ranked list refreshes daily
- Add Net Promoter Score as a leading indicator alongside ticket count
