DROP TABLE IF EXISTS mart.fact_sales CASCADE;
CREATE TABLE mart.fact_sales AS
SELECT
    ROW_NUMBER() OVER (ORDER BY sb.order_id, sb.order_item_id) AS sales_key,
    sb.order_id,
    sb.order_item_id,
    TO_CHAR(sb.order_date, 'YYYYMMDD')::int AS date_key,
    dp.product_key,
    dc.customer_key,
    dr.region_key,
    ds.segment_key,
    1 AS quantity,
    sb.price AS unit_price,
    sb.freight_value,
    sb.gross_revenue,
    sb.estimated_cost,
    sb.profit,
    sb.margin_pct,
    sb.order_status
FROM staging.sales_base sb
LEFT JOIN mart.dim_product dp
    ON sb.product_id = dp.product_id
LEFT JOIN mart.dim_customer dc
    ON sb.customer_id = dc.customer_id
LEFT JOIN mart.dim_region dr
    ON sb.customer_state = dr.customer_state
   AND sb.customer_city = dr.customer_city
LEFT JOIN mart.dim_segment ds
    ON dc.customer_segment = ds.segment_name
WHERE sb.order_date IS NOT NULL;

ALTER TABLE mart.fact_sales ADD PRIMARY KEY (sales_key);