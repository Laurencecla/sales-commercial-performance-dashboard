-- total revenue, profit, margin
SELECT
    ROUND(SUM(gross_revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(gross_revenue), 0)) * 100, 2) AS margin_pct
FROM mart.fact_sales;

-- monthly sales trend
SELECT *
FROM mart.vw_sales_monthly
ORDER BY year, month_number;

-- top 10 categories by revenue
SELECT *
FROM mart.vw_category_performance
ORDER BY revenue DESC
LIMIT 10;

-- top states by revenue
SELECT *
FROM mart.vw_state_performance
ORDER BY revenue DESC
LIMIT 10;

-- customer segment performance
SELECT *
FROM mart.vw_customer_segment_performance
ORDER BY revenue DESC;