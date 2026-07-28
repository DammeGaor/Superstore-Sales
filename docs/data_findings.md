# Data Quality Findings — Superstore Sales Dataset

## Overview

This dataset contains order-level retail transaction records covering order/ship dates, customer and product details, and financial metrics (sales, quantity, discount, profit).

- **Dataset Source:** [Superstore Sales](https://www.kaggle.com/datasets/franciscozc/superstore-sales-eda-outliers-and-data-cleaning)
- **Raw row count:** 10,703
- **Import method:** `LOAD DATA LOCAL INFILE` into a TEXT-typed staging table (`raw_staging`), to preserve raw values as imported and type coercion.
- **Tool:** MySQL (staging → profiling → cleaning → final)

---

## Process

1. **Staging setup** — raw CSV imported as-is into `raw_staging`, all columns as `TEXT`.
2. **Data profiling** — each column checked for missing values, format inconsistencies, and anomalies *before* any cleaning was applied.
3. **Cleaning & imputation** — fixes are applied on a copy (`raw_staging_new`), preserving `raw_staging` as untouched raw data.
4. **Final table creation** — cleaned data cast into a properly typed table, `sales_superstore_clean`.

---

## Issues Identified & Decisions

### Table-level: Full-duplicate rows
**Finding:** Multiple rows were found to be exact duplicates across all columns which are confirmed as true duplicates.
**Decision:** Deleted using `ROW_NUMBER()` partitioned across every column, keeping one instance of each unique row.

### order_date: Inconsistent formatting
**Finding:** Four distinct date formats were present in the raw data:
| Format | Example | Pattern used to detect |
|---|---|---|
| `YYYY-MM-DD` | `2023-01-04 00:00:00` | `____-__-__%` |
| `DD-Mon-YYYY` | `04-Jan-2023` | `__-___-____` |
| `DD.MM.YYYY` | `03.01.2023` | `__.__.____` |
| `YYYYMMDD` | `20230106` | `________` |

**Decision:** Standardized all four formats to a single `DATE`-compatible value using `STR_TO_DATE()` inside a `CASE` expression, matched by pattern. Verified no rows fell outside these four patterns before finalizing.

### ship_mode: Missing values
**Finding:** Some rows had NULL or empty `ship_mode` values.
**Decision:** Filled with an explicit `'Unknown'` placeholder rather than guessing a specific shipping method, since there was no reliable pattern to infer the correct value from.

### segment: Typos and inconsistent formatting
**Finding:** `segment` contained typographical errors and extra whitespace across values.
**Decision:** Standardized via pattern matching (`LIKE` on partial matches) to consolidate typo variants.

### category: Extra whitespace
**Finding:** One `category` value contained leading whitespace.
**Decision:** Applied `TRIM()` to remove whitespace across the column.

### sales: Missing values
**Finding:** 19.04% of `sales` values were missing (NULL or empty).
**Decision:** Rows with missing `sales` were removed. Since `sales` is a primary financial metric in this dataset, estimating a value would distort future analysis. Deriving the value from other fields was considered but not pursued, since a reliable per-unit price could not be confidently derived for every row.
**Impact:** ~19% of the original dataset was removed at this step.

### quantity: Abnormally high values and missing values
**Finding:** Some `quantity` values appeared inflated compared to typical order sizes. Also, some rows had missing `quantity`.
**Decision:** Rows with missing `quantity` were removed but unusually high quantity values were retained because they may represent legitimate bulk purchases, and there was no evidence they were data entry errors.

### discount: Out-of-range value
**Finding:** One discount value of `5.5` was found.
**Decision:** Corrected `5.5` to `0.55`, assuming a decimal-entry error.

### profit: Extreme negative values + hidden carriage-return characters
**Finding 1:** Some extreme negative profit values were found. Negative profit is a possibility so this was not treated as an error by default.
**Decision:** Negative profit values were retained as valid data.

---

## Columns Profiled with No Issues Found

The following columns were also checked but required no cleaning: `row_id`, `order_id`, `ship_date`, `customer_id`, `customer_name`, `country_or_region`, `city`, `state_or_province`, `postal_code`, `region`, `product_id`, `sub_category`, `product_name`.

---

## Known Limitations

- **~19% row loss from sales/profit removal.** Removing rows with missing `sales` or `profit` shrank the dataset. This was a choice to protect data integrity over completeness, but it does mean the cleaned table is not fully representative of 100% of original orders which is worth noting for anyone using this dataset .
- **Discount correction (5.5 → 0.55) was based on a single plausible error pattern**, not a confirmed source-of-truth. It's a reasonable, documented judgment call, not a certainty.

---

## Tools Used
MySQL 8.0 only.
