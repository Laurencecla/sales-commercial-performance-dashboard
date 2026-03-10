DROP TABLE IF EXISTS mart.dim_product CASCADE;
DROP TABLE IF EXISTS mart.dim_customer CASCADE;
DROP TABLE IF EXISTS mart.dim_region CASCADE;
DROP TABLE IF EXISTS mart.dim_segment CASCADE;
CREATE TABLE mart.dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    product_category_name_english AS category,
    CASE
        WHEN product_weight_g < 500 THEN 'Light'
        WHEN product_weight_g < 2000 THEN 'Medium'
        ELSE 'Heavy'
    END AS weight_class,
    CASE
        WHEN product_photos_qty >= 3 THEN 'Rich Listing'
        ELSE 'Basic Listing'
    END AS listing_quality
FROM (
    SELECT DISTINCT
        product_id,
        product_category_name_english,
        product_weight_g,
        product_photos_qty
    FROM staging.products_clean
) p;

ALTER TABLE mart.dim_product ADD PRIMARY KEY (product_key);

DROP TABLE IF EXISTS mart.dim_customer;
CREATE TABLE mart.dim_customer AS
WITH customer_sales AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_city,
        customer_state,
        SUM(gross_revenue) AS total_revenue,
        COUNT(DISTINCT order_id) AS total_orders
    FROM staging.sales_base
    GROUP BY 1,2,3,4
)
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    total_revenue,
    total_orders,
    CASE
        WHEN total_revenue >= 1000 THEN 'High Value'
        WHEN total_revenue >= 300 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_sales;

ALTER TABLE mart.dim_customer ADD PRIMARY KEY (customer_key);

DROP TABLE IF EXISTS mart.dim_region;
CREATE TABLE mart.dim_region AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_state, customer_city) AS region_key,
    customer_state,
    customer_city,
    'Brazil' AS country
FROM (
    SELECT DISTINCT
        customer_state,
        customer_city
    FROM staging.customers_clean
    WHERE customer_state IS NOT NULL
      AND customer_city IS NOT NULL
) r;

ALTER TABLE mart.dim_region ADD PRIMARY KEY (region_key);

DROP TABLE IF EXISTS mart.dim_segment;
CREATE TABLE mart.dim_segment AS
SELECT
    ROW_NUMBER() OVER (ORDER BY segment_name) AS segment_key,
    segment_name
FROM (
    SELECT DISTINCT
        customer_segment AS segment_name
    FROM mart.dim_customer
    WHERE customer_segment IS NOT NULL
) s;

ALTER TABLE mart.dim_segment ADD PRIMARY KEY (segment_key);