from pathlib import Path
import pandas as pd
from sqlalchemy import text
from db import get_engine

RAW_DIR = Path("data/raw")

FILES = {
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "customers": "olist_customers_dataset.csv",
    "products": "olist_products_dataset.csv",
    "product_category_translation": "product_category_name_translation.csv",
}

DATE_COLUMNS = {
    "orders": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "order_items": ["shipping_limit_date"],
}

def standardise_columns(df: pd.DataFrame) -> pd.DataFrame:
    df.columns = (
        df.columns.str.strip()
        .str.lower()
        .str.replace(" ", "_", regex=False)
    )
    return df

def read_csv_file(file_path: Path, table_name: str) -> pd.DataFrame:
    df = pd.read_csv(file_path)
    df = standardise_columns(df)

    for col in DATE_COLUMNS.get(table_name, []):
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors="coerce")

    return df

def load_table(df: pd.DataFrame, table_name: str):
    engine = get_engine()
    with engine.begin() as conn:
        conn.execute(text(f"TRUNCATE TABLE raw.{table_name};"))
    df.to_sql(table_name, engine, schema="raw", if_exists="append", index=False, method="multi", chunksize=5000)

def main():
    for table_name, filename in FILES.items():
        file_path = RAW_DIR / filename
        print(f"Loading {filename} into raw.{table_name}")
        df = read_csv_file(file_path, table_name)
        load_table(df, table_name)
        print(f"Loaded {len(df):,} rows into raw.{table_name}")

if __name__ == "__main__":
    main()