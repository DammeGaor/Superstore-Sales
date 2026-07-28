-- ================================================================
-- 			DATA PROFILING
-- Goal: 	Explore raw_staging column-by-column to identify missing 
-- 			values, formatting inconsistencies, and data quality issues 
-- 			before any cleaning decisions are made. Findings here directly 
-- 			inform the cleaning logic in the next process.
--
-- 		Standard checklist applied per column (unless noted otherwise):
--   		1. Check for NULL / empty / whitespace-only values
--   		2. Check DISTINCT values for formatting inconsistencies, 
--      	typos, casing issues, or unexpected categories
--   		3. Flag anything requiring special handling (documented inline 
--      	as a NOTE comment)
-- ================================================================

-- Overall view of the table
SELECT *
FROM raw_staging;

-- Full-duplicate row check (all columns matched)
-- NOTE: Multiple full-row duplicates found which confirms these are 
-- true duplicates, not just repeated row_id values with different data
SELECT
    row_id, order_id, order_date, ship_date, ship_mode,
    customer_id, customer_name, segment, country_or_region,
    city, state_or_province, postal_code, region,
    product_id, category, sub_category, product_name,
    sales, quantity, discount, profit,
    COUNT(*) AS occurrences
FROM raw_staging
GROUP BY
    row_id, order_id, order_date, ship_date, ship_mode,
    customer_id, customer_name, segment, country_or_region,
    city, state_or_province, postal_code, region,
    product_id, category, sub_category, product_name,
    sales, quantity, discount, profit
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- row_id / order_id
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Missing value check (NULL or empty string)
-- These are identifier columns, so any result here is a bigger red 
-- flag than a missing value elsewhere
SELECT row_id, order_id
FROM raw_staging
WHERE 
    row_id IS NULL OR order_id IS NULL OR
    row_id = '' OR order_id = ''
ORDER BY 1 DESC;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- order_date
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Missing value check
SELECT DISTINCT order_date
FROM raw_staging
WHERE order_date IS NULL OR order_date = '';

-- Full distinct value dump to visually scan for formatting issues
-- NOTE: Multiple date formats present in this column
SELECT DISTINCT order_date
FROM raw_staging;

-- Isolate exactly which formats exist by excluding known patterns
-- NOTE: Zero rows returned = every value matched one of these 4 
-- patterns, confirming there are exactly 4 formats to handle:
--   YYYY-MM-DD (____-__-__%), DD-Mon-YYYY (__-___-____), 
--   DD.MM.YYYY (__.__.____), YYYYMMDD (________)
SELECT DISTINCT order_date
FROM raw_staging
WHERE 
    order_date NOT LIKE '____-__-__%' AND
    order_date NOT LIKE '__-___-____' AND
    order_date NOT LIKE '__.__.____' AND
    order_date NOT LIKE '________'
;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ship_date
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Missing/blank check via sort order; empty strings and whitespace-only values sort near the top 
SELECT DISTINCT ship_date
FROM raw_staging
ORDER BY 1;

-- Formatting check using string length. Multiple unexpected 
-- lengths would indicate mixed formats (same issue as order_date)
SELECT DISTINCT LENGTH(ship_date) AS char_count
FROM raw_staging
GROUP BY char_count;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ship_mode
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check — categorical column, expect a small fixed set
SELECT DISTINCT ship_mode
FROM raw_staging;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- customer_id
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Format check — expected pattern is 2 characters, dash, then 
-- remaining ID (e.g., 'AB-12345'); flags anything that differs
SELECT customer_id
FROM raw_staging
WHERE customer_id NOT LIKE '__-%';


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- customer_name
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check, sorted to surface NULLs/blanks at the top 
-- and reveal any casing or whitespace inconsistencies
SELECT DISTINCT customer_name
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- segment
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
-- NOTE: Typographical errors and extra whitespace found in values
SELECT DISTINCT segment
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- country_or_region
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT country_or_region
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- city
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT city
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- state_or_province
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT state_or_province
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- postal_code
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT postal_code
FROM raw_staging
ORDER BY 1 DESC;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- region
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT region
FROM raw_staging
ORDER BY 1 DESC;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- product_id
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT product_id
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- category
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
-- NOTE: Extra whitespace found in at least one category value
SELECT DISTINCT category
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- sub_category
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT sub_category
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- product_name
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT product_name
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- sales
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Missing value count + percentage of total rows
-- NOTE: 19.04% of sales values are missing which is a significant gap. 
-- Since this is a financial fact, this will need careful handling
-- in cleaning 
SELECT
    COUNT(CASE WHEN sales IS NULL OR sales = '' THEN 1 END) AS total_null,
    COUNT(*) AS total_rows,
    ROUND(COUNT(CASE WHEN sales IS NULL OR sales = '' THEN 1 END) / COUNT(*) * 100, 2) AS pct_null
FROM raw_staging;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- quantity
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
-- NOTE: Some quantities appear abnormally inflated, worth 
-- investigating as possible data entry errors or outliers
SELECT DISTINCT quantity						
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- discount
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
SELECT DISTINCT discount						
FROM raw_staging
ORDER BY 1;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- profit
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Distinct value check
-- NOTE: Some extreme negative profit values found which need 
-- confirming whether they are legitimate high-loss transactions 
-- or data entry errors before deciding how to treat them
SELECT DISTINCT profit						
FROM raw_staging
ORDER BY 1;