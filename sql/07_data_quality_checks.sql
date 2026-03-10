-- duplicate order lines
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS cnt
FROM mart.fact_sales
GROUP BY 1,2
HAVING COUNT(*) > 1;

-- null foreign keys
SELECT *
FROM mart.fact_sales
WHERE date_key IS NULL
   OR product_key IS NULL
   OR customer_key IS NULL
   OR region_key IS NULL
   OR segment_key IS NULL;

-- extreme margin anomalies
SELECT *
FROM mart.fact_sales
WHERE margin_pct > 90
   OR margin_pct < -50;

-- unknown category checks
SELECT *
FROM mart.dim_product
WHERE category = 'Unknown';

-- missing customer geography
SELECT *
FROM mart.dim_customer
WHERE customer_state IS NULL
   OR customer_city IS NULL;