DROP TABLE IF EXISTS raw.orders;
CREATE TABLE raw.orders (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

DROP TABLE IF EXISTS raw.order_items;
CREATE TABLE raw.order_items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2)
);

DROP TABLE IF EXISTS raw.order_payments;
CREATE TABLE raw.order_payments (
    order_id TEXT,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC(12,2)
);

DROP TABLE IF EXISTS raw.customers;
CREATE TABLE raw.customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

DROP TABLE IF EXISTS raw.products;
CREATE TABLE raw.products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght NUMERIC,
    product_description_lenght NUMERIC,
    product_photos_qty NUMERIC,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

DROP TABLE IF EXISTS raw.product_category_translation;
CREATE TABLE raw.product_category_translation (
    product_category_name TEXT,
    product_category_name_english TEXT
);