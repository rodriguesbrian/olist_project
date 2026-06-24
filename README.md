# The Hidden Cost of Delays
### Analysis of 96,461 Olist orders · 2016–2018


---


## About the Project


Most analyses of the Olist dataset calculate the correlation between days of delay and rating — and that’s as far as they go.


This project goes deeper: it identifies **where, when and for whom** delays actually take their toll — and discovers that the problem isn’t always where it seems to be.


---


## Analytical Questions


The project is structured around four questions of increasing depth:


| # | Question | What distinguishes |
|---|---|---|
| 1 | Is the delay symmetrical? | Analysis by product category and order value |
| 2 | Is there a breakpoint in the rating? | Threshold, no linear correlation |
| 3 | Geography as a structural factor | Slow logistics vs. unrealistic delivery promises |
| 4 | The salesperson as a hidden variable | Variance within the same logistics corridor |


---


## Key Findings

**Analysis 1 — Delays do not affect all contexts equally**
The window during which categories differ is narrow: only during the first 5 days of delay. After 6 days, all categories converge to the same level of dissatisfaction (average review ~1.6–1.8). The `premium` tier (>R$1,048) reaches 87% with a rating of 1 in the `late_critical` category — the most extreme result of the analysis.

**Analysis 2 — There is a threshold, not a gradual decline**
The relationship between delay and dissatisfaction is not linear — it is a threshold. Up to 5 days’ delay, the customer still distinguishes between categories. From the **6th day** onwards, the rating drops abruptly from ~3.7 to ~1.8 and stabilises indefinitely. Reducing a delay from 8 to 6 days does not solve the problem — reducing it from 6 to 5 days can make all the difference.

**Analysis 3 — The logistical problem is structural, not one of expectations**
No region is delayed on average — Olist calibrates delivery times in proportion to the logistical reality of each area. The real problem is the absolute delivery time: the North takes more than twice as long as the South-East (22.54 vs 10.69 days). The North-East faces a double disadvantage: long delivery times and a disproportionately tight safety margin (a ratio of 0.62×, compared to 1.08× in the South-East) — making it the priority region for intervention.

**Analysis 4 — The salesperson is the hidden variable**
In the MG→RJ corridor (64 salespeople, 998 orders), the range between the best and worst salesperson is **48 days** of `avg_delta`. The difference is statistically robust (Kruskal-Wallis H=163.26, p<0.0001; Mann-Whitney p=0.0022 for the extreme pair). The distance and the carrier are identical for all — what separates the extremes is the seller’s internal process.


---


## Technical Stack

| tool | use |
|---|---|
| Python · Pandas | data cleaning, transformation and statistical analysis |
| DuckDB / SQL | multi-table consolidation (joins between 5+ tables) |
| Scipy | statistical tests (Kruskal-Wallis, Mann-Whitney) |
| Matplotlib · Seaborn | exploratory visualisations |
| Power BI | executive dashboard (6 slides) |


---


## Project Structure

```
olist-hidden-cost-delay/
│
├── data/
│ ├── raw/ # Original CSV files from Kaggle
│ └── processed/ # Datasets exported to Power BI
│
├── notebooks/
│ └── analysis.ipynb # Main notebook containing the entire analysis
│
├── queries/
│ ├── q1_delay_category_value.sql # Consolidation for Analysis 1
│ └── q3_geography.sql # Consolidation for Analyses 3 and 4
│
├── dashboard/ # Power BI file (.pbix)
└── README.md
```


---


## Methodological Decisions

**Delay threshold (day 6)**
Defined empirically based on the `delta_days` × `review_score` analysis — not set a priori. The choice was based on the sharp drop in the average score (from ~2.2 to ~1.8) and the jump in the proportion of score 1 (from 55% to 69%) at exactly this point.

**`delay_status` classification**
```
early → delta_days < 0
on_time → delta_days = 0
late → 1 to 5 days (progressive deterioration)
late_critical → 6 to 30 days (score collapse)
late_extreme → > 30 days (reduced volume — treat with caution)
```

**`value_tier`**
Defined by quartiles of `order_value` (Q1=R$61.84, Q2=R$105.28, Q3=R$176.16), with the P99 isolated as the `premium` tier (>R$1,048). The four base tiers have balanced volumes (~24k orders each).

**Seller filter (Analysis 4)**
Only seller-corridor pairs with ≥5 orders in the specific corridor are included, in corridors with ≥2 valid sellers. Result: 3,580 pairs, 100 corridors, 1,181 distinct sellers.

**SQL vs Pandas**
SQL (DuckDB) used exclusively for multi-table consolidation (joins, aggregations, deduplication of reviews and payments). Statistics, segmentation and visualisation handled in Python/Pandas — division of responsibilities explicitly stated and documented in the notebook.


---


## Statistical Tests

All observed patterns were statistically validated before being included in the conclusions:

| analysis | test | result |
|---|---|---|
| Category × `delay_status` | Mann-Whitney + Bonferroni | `health_beauty` vs `toys` significant (p=0.02) |
| `value_tier` × `delay_status` | Kruskal-Wallis + Mann-Whitney | `late_critical`: `premium` tier distinct (p<0.05); `late`: not significant (p=0.41) |
| Delivery time by region | Kruskal-Wallis + Mann-Whitney | All regions significantly different (p<0.0001) |
| Sellers in the MG→RJ corridor | Kruskal-Wallis + Mann-Whitney | H=163.26, p<0.0001; extreme pair p=0.0022 |


---


## Dataset

**Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle

**Period:** 2016 to 2018

**Tables used:** `orders`, `order_items`, `order_reviews`, `order_payments`, `products`, `product_category_name_translation`, `sellers`, `customers`, `geolocation`

**Orders analysed:** 96,461 confirmed deliveries (`order_status = 'delivered'`)


---


## Author

**Brian Rodrigues**
Data Analyst · Porto, Portugal

[![LinkedIn](https://img.shields.io/badge/LinkedIn-rodriguesbrian-0077B5?style=flat&logo=linkedin)](https://linkedin.com/in/rodriguesbrian)
[![GitHub](https://img.shields.io/badge/GitHub-rodriguesbrian-181717?style=flat&logo=github)](https://github.com/rodriguesbrian)