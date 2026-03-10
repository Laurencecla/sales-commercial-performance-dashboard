# Data Dictionary

This document describes the tables and fields used in the analytics warehouse.

---

# Fact Table

## fact_sales

Grain: one row per order item.

| Column | Description |
|------|------|
| sales_key | Surrogate key |
| order_id | Unique order identifier |
| order_item_id | Item within order |
| date_key | Foreign key to dim_date |
| product_key | Foreign key to dim_product |
| customer_key | Foreign key to dim_customer |
| region_key | Foreign key to dim_region |
| segment_key | Foreign key to dim_segment |
| quantity | Number of items purchased |
| unit_price | Price per item |
| freight_value | Shipping cost |
| gross_revenue | Revenue generated |
| estimated_cost | Estimated product cost |
| profit | Profit calculation |
| margin_pct | Profit margin |
| order_status | Order delivery status |

---

# Dimension Tables

## dim_date

| Column | Description |
|------|------|
| date_key | Surrogate date key |
| full_date | Calendar date |
| year | Year |
| quarter | Quarter |
| month | Month |
| month_name | Month name |

---

## dim_product

| Column | Description |
|------|------|
| product_key | Surrogate key |
| product_id | Source product identifier |
| category | Product category |
| weight_class | Light / Medium / Heavy |
| listing_quality | Listing quality classification |

---

## dim_customer

| Column | Description |
|------|------|
| customer_key | Surrogate key |
| customer_id | Source customer identifier |
| customer_unique_id | Unique customer identifier |
| customer_city | Customer city |
| customer_state | Customer state |
| total_revenue | Lifetime revenue |
| total_orders | Number of orders |

---

## dim_region

| Column | Description |
|------|------|
| region_key | Surrogate key |
| city | Customer city |
| state | Customer state |

---

## dim_segment

| Column | Description |
|------|------|
| segment_key | Surrogate key |
| segment_name | Customer segment |