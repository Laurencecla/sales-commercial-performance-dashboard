# Architecture Overview

This project implements a simplified analytics pipeline used in modern Business Intelligence environments.

The architecture demonstrates how raw transactional data can be ingested, transformed into a data warehouse, and delivered to a BI reporting tool.

---

## Data Pipeline

The analytics workflow follows the pipeline below:

Kaggle Dataset (CSV files)
        ↓
Python Data Ingestion
        ↓
PostgreSQL Data Warehouse (Docker)
        ↓
SQL Transformations
        ↓
Star Schema Data Model
        ↓
Power BI Semantic Model
        ↓
Commercial Performance Dashboard

---

## Pipeline Components

### Data Source

The data source is the **Olist Brazilian E-Commerce Dataset** available on Kaggle.

It contains transactional marketplace data including:

- orders
- order items
- payments
- customers
- products
- category translations

---

### Python Ingestion Layer

Python scripts are used to load the raw CSV files into the PostgreSQL database.

Scripts:


python/ingest_olist.py
python/generate_date_dim.py


Responsibilities:

- load CSV data
- insert records into raw schema tables
- generate a date dimension table

---

### PostgreSQL Data Warehouse

The data warehouse runs locally using Docker.

The warehouse follows a three-layer architecture:


raw
staging
mart


---

### Raw Layer

Stores direct ingestions of the original datasets.

Tables include:

- raw.orders
- raw.order_items
- raw.order_payments
- raw.customers
- raw.products
- raw.product_category_translation

---

### Staging Layer

Applies data cleaning and transformation logic.

Key transformations:

- join order tables
- standardise column names
- derive revenue metrics
- calculate estimated costs
- enrich product attributes

---

### Mart Layer

The mart layer contains the **analytics-ready dimensional model** used by Power BI.

This layer is optimised for analytical queries.

---

### Star Schema

Fact Table:


mart.fact_sales


Grain:


one row per order item


Dimension Tables:


mart.dim_date
mart.dim_product
mart.dim_customer
mart.dim_region
mart.dim_segment


---

### Power BI Layer

Power BI connects directly to the mart schema.

The semantic model creates relationships between the fact and dimension tables to support flexible slicing and filtering.

Dashboard pages include:

- Executive Summary
- Product Performance
- Regional Sales Analysis
- Customer Segmentation

---

## Infrastructure

This project uses containerisation to simulate a production-style analytics environment.

Docker is used to run PostgreSQL locally.


docker-compose.yml


This ensures the warehouse environment can be rebuilt consistently.

---

## Rebuild Script

The project includes a full rebuild script:


rebuild_olist_warehouse.ps1


This script:

- resets the Docker database
- loads source data
- builds transformation layers
- creates the star schema
- runs data quality checks

This allows the warehouse to be rebuilt from scratch in a reproducible way.