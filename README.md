# Superstore Sales – SQL Data Cleaning Project

This is a SQL-only project where I took a messy Superstore sales CSV (from Kaggle) and cleaned it up in MySQL, start to finish from raw import, profiling, cleaning, to a final typed table ready for analysis.

I kept this project scoped to just SQL on purpose for now. No Python, no Excel, no BI tool. I'm still early in learning data analytics and wanted to get comfortable doing the whole pipeline in raw SQL before adding other tools on top.

## Why this project

Most tutorial datasets are already clean, so you never actually practice the part of the job that takes the most time in real work. I wanted a project that actually shows that process, not just a final polished table.

## What's messy about this dataset

- Duplicate rows
- 4 different date formats in the same column
- Missing values in Sales, Profit, Quantity, and Ship Mode
- Typos and inconsistent casing in Segment
- Extra whitespace in a few text columns
- A discount value that was clearly off by a decimal point

Full breakdown of everything I found and how I decided to handle it is in [`docs/data_findings.md`](docs/data_findings.md).

## Process

1. **Staging setup** – import the raw CSV into MySQL with every column as TEXT.
2. **Data profiling** – go column by column and look at what's there to be fixed.
3. **Cleaning** – fix what needs fixing, using a copy of the staging table (so the original import is untouched).
4. **Final table** – cast everything into proper types and insert in a clean, analysis-ready table.

## Files

```
data/
├── clean/
    ├── superstore_sales_cleaned.csv
├── raw/
    ├── superstore_sales_raw.csv
sql/
├── 01_staging_setup.sql
├── 02_data_profiling.sql
├── 03_data_cleaning.sql
└── 04_final_table_creation.sql
docs/
└── data_quality_findings.md
```

Run them in order, each one builds on the last.

## Tools

MySQL 8.0.

## Dataset

[Superstore Sales](https://www.kaggle.com/datasets/franciscozc/superstore-sales-eda-outliers-and-data-cleaning)
