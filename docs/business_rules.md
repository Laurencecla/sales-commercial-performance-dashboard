# Business Rules

This document defines the business logic used to transform raw transactional data into analytical metrics.

---

## Revenue Calculation

Revenue is calculated as:

Revenue = unit_price × quantity

Freight charges are stored separately to allow analysis of product revenue versus shipping costs.

---

## Estimated Product Cost

The dataset does not include cost data.

To enable profit analysis, an estimated cost model was applied.

Estimated Cost = unit_price × 0.70

This assumes a 30% margin baseline for simulation purposes.

---

## Profit Calculation

Profit is calculated as:

Profit = Revenue − Estimated Cost

---

## Margin Percentage

Margin is calculated as:

Margin % = Profit / Revenue

---

## Customer Segmentation

Customers are grouped into three segments based on total revenue generated.

Segment thresholds:

| Segment | Revenue Range |
|------|------|
| Low Value | < 100 |
| Mid Value | 100 – 500 |
| High Value | > 500 |

These segments allow comparison of purchasing behaviour and revenue contribution.

---

## Weight Classification

Products are classified into weight groups based on their weight in grams.

| Weight Range | Class |
|------|------|
| < 500g | Light |
| 500g – 2000g | Medium |
| > 2000g | Heavy |

This supports analysis of logistics cost and product characteristics.

---

## Listing Quality

Products are classified into listing quality groups based on available metadata.

Criteria include:

- product name length
- description length
- number of product photos

Categories:

- Basic Listing
- Rich Listing

This allows analysis of how product listing quality affects sales performance.