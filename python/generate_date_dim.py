import pandas as pd
from db import get_engine

START_DATE = "2016-01-01"
END_DATE = "2018-12-31"

def build_date_dim():
    dates = pd.date_range(start=START_DATE, end=END_DATE, freq="D")
    df = pd.DataFrame({"full_date": dates})
    df["date_key"] = df["full_date"].dt.strftime("%Y%m%d").astype(int)
    df["day"] = df["full_date"].dt.day
    df["day_name"] = df["full_date"].dt.day_name()
    df["week_number"] = df["full_date"].dt.isocalendar().week.astype(int)
    df["month_number"] = df["full_date"].dt.month
    df["month_name"] = df["full_date"].dt.month_name()
    df["quarter"] = "Q" + df["full_date"].dt.quarter.astype(str)
    df["year"] = df["full_date"].dt.year
    df["year_month"] = df["full_date"].dt.strftime("%Y-%m")
    return df

def main():
    engine = get_engine()
    df = build_date_dim()
    df.to_sql("dim_date", engine, schema="mart", if_exists="replace", index=False)
    print(f"Loaded {len(df):,} rows into mart.dim_date")

if __name__ == "__main__":
    main()