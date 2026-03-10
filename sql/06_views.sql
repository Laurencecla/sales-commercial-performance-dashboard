DROP VIEW IF EXISTS mart.vw_sales_monthly;
CREATE VIEW mart.vw_sales_monthly AS
SELECT
    d.year,
    d.month_number,
    d.month_name,
    d.year_month,
    SUM(f.gross_revenue) AS revenue,
    SUM(f.profit) AS profit,
    AVG(f.margin_pct) AS avg_margin_pct,
    COUNT(DISTINCT f.order_id) AS orders,
    SUM(f.quantity) AS units_sold
FROM mart.fact_sales f
JOIN mart.dim_date d
    ON f.date_key = d.date_key
GROUP BY 1,2,3,4;

DROP VIEW IF EXISTS mart.vw_category_performance;
CREATE VIEW mart.vw_category_performance AS
SELECT
    p.category,
    SUM(f.gross_revenue) AS revenue,
    SUM(f.profit) AS profit,
    AVG(f.margin_pct) AS avg_margin_pct,
    COUNT(DISTINCT f.order_id) AS orders
FROM mart.fact_sales f
JOIN mart.dim_product p
    ON f.product_key = p.product_key
GROUP BY 1;

DROP VIEW IF EXISTS mart.vw_state_performance;
CREATE VIEW mart.vw_state_performance AS
SELECT
    r.customer_state,
    SUM(f.gross_revenue) AS revenue,
    SUM(f.profit) AS profit,
    AVG(f.margin_pct) AS avg_margin_pct,
    COUNT(DISTINCT f.order_id) AS orders
FROM mart.fact_sales f
JOIN mart.dim_region r
    ON f.region_key = r.region_key
GROUP BY 1;

DROP VIEW IF EXISTS mart.vw_customer_segment_performance;
CREATE VIEW mart.vw_customer_segment_performance AS
SELECT
    s.segment_name,
    SUM(f.gross_revenue) AS revenue,
    SUM(f.profit) AS profit,
    COUNT(DISTINCT f.order_id) AS orders,
    ROUND(SUM(f.gross_revenue) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS avg_order_value
FROM mart.fact_sales f
JOIN mart.dim_segment s
    ON f.segment_key = s.segment_key
GROUP BY 1;