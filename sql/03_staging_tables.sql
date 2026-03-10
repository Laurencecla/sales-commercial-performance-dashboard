DROP TABLE IF EXISTS staging.orders_clean;
CREATE TABLE staging.orders_clean AS
SELECT
    order_id,
    customer_id,
    LOWER(TRIM(order_status)) AS order_status,
    order_purchase_timestamp::timestamp AS order_purchase_ts,
    order_approved_at::timestamp AS order_approved_ts,
    order_delivered_carrier_date::timestamp AS delivered_carrier_ts,
    order_delivered_customer_date::timestamp AS delivered_customer_ts,
    order_estimated_delivery_date::timestamp AS estimated_delivery_ts,
    CAST(order_purchase_timestamp AS date) AS order_date
FROM raw.orders
WHERE order_id IS NOT NULL
  AND customer_id IS NOT NULL;


DROP TABLE IF EXISTS staging.order_items_clean;
CREATE TABLE staging.order_items_clean AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date::timestamp AS shipping_limit_ts,
    COALESCE(price, 0)::numeric(12,2) AS price,
    COALESCE(freight_value, 0)::numeric(12,2) AS freight_value
FROM raw.order_items
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL;


DROP TABLE IF EXISTS staging.order_payments_clean;
CREATE TABLE staging.order_payments_clean AS
SELECT
    order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    COALESCE(payment_installments, 0) AS payment_installments,
    COALESCE(payment_value, 0)::numeric(12,2) AS payment_value
FROM raw.order_payments
WHERE order_id IS NOT NULL;


DROP TABLE IF EXISTS staging.customers_clean;
CREATE TABLE staging.customers_clean AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    INITCAP(TRIM(customer_city)) AS customer_city,
    UPPER(TRIM(customer_state)) AS customer_state
FROM raw.customers
WHERE customer_id IS NOT NULL;


DROP TABLE IF EXISTS staging.products_clean;
CREATE TABLE staging.products_clean AS
SELECT
    p.product_id,
    p.product_category_name,
    COALESCE(t.product_category_name_english, 'Unknown') AS product_category_name_english,
    COALESCE(p.product_name_lenght, 0) AS product_name_length,
    COALESCE(p.product_description_lenght, 0) AS product_description_length,
    COALESCE(p.product_photos_qty, 0) AS product_photos_qty,
    COALESCE(p.product_weight_g, 0) AS product_weight_g,
    COALESCE(p.product_length_cm, 0) AS product_length_cm,
    COALESCE(p.product_height_cm, 0) AS product_height_cm,
    COALESCE(p.product_width_cm, 0) AS product_width_cm
FROM raw.products p
LEFT JOIN raw.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_id IS NOT NULL;


DROP TABLE IF EXISTS staging.sales_base;
CREATE TABLE staging.sales_base AS
SELECT
    oi.order_id,
    oi.order_item_id,
    o.order_date,
    o.order_status,
    o.customer_id,
    oi.product_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    pc.product_category_name_english AS product_category,

    oi.price,
    oi.freight_value,

    -- Commercial logic:
    -- Use product price as reporting revenue for profit / margin analysis.
    -- Keep freight separately for analysis, but do not treat it as profit-generating revenue.
    oi.price AS gross_revenue,

    -- Estimated cost assumption: 65% of product price
    ROUND((oi.price * 0.65)::numeric, 2) AS estimated_cost,

    -- Profit based on product revenue only
    ROUND((oi.price - (oi.price * 0.65))::numeric, 2) AS profit,

    -- Margin % based on product revenue only
    CASE
        WHEN oi.price = 0 THEN 0
        ELSE ROUND(
            (((oi.price - (oi.price * 0.65)) / oi.price) * 100)::numeric,
            2
        )
    END AS margin_pct

FROM staging.order_items_clean oi
INNER JOIN staging.orders_clean o
    ON oi.order_id = o.order_id
LEFT JOIN staging.customers_clean c
    ON o.customer_id = c.customer_id
LEFT JOIN staging.products_clean pc
    ON oi.product_id = pc.product_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');