-- ================================================================
-- 			DATA CLEANING
-- Goal: 	Apply fixes to raw_staging based on findings from 
-- 			data_profiling. Each fix below is tied to a specific 
-- 			finding.
-- ================================================================
--
-- FINDINGS SUMMARY (showing only columns that need adjustment + Table-level fix)
--
-- [Table-level] : Full-duplicate rows found 
--   			ACTION: Deduplicate — keep one instance per unique row.
--
-- [order_date] : 4 distinct date formats present: YYYY-MM-DD, DD-Mon-YYYY, DD.MM.YYYY, YYYYMMDD.
--   			ACTION: Standardize to a single DATE-compatible format.
--
-- [ship_mode] : Set NULL values to Unknown
--
-- [segment] : Typographical errors and extra whitespace found in values.
--   			ACTION: Trim to remove whitespace; standardize casing, correct typos. 
--
-- [category] : Extra whitespace found in one value.
--   			ACTION: TRIM() to remove whitespace
--
-- [sales] : 19.04% of values missing (NULL or empty).
--   			ACTION: Investigate if value can be derived, then decide on action.
--
-- [quantity] : Some values appear abnormally inflated 
--   			ACTION: Investigate flagged high values before taking action.
--
-- [profit] : Some extreme negative values found.
--   			ACTION: Investigate if legitimate high-loss transactions
-- 				or data errors
-- ================================================================
-- Duplication of raw_staging for data cleaning proper (to preserve raw data)
CREATE TABLE `raw_staging_new` (
  `row_id` text,
  `order_id` text,
  `order_date` text,
  `ship_date` text,
  `ship_mode` text,
  `customer_id` text,
  `customer_name` text,
  `segment` text,
  `country_or_region` text,
  `city` text,
  `state_or_province` text,
  `postal_code` text,
  `region` text,
  `product_id` text,
  `category` text,
  `sub_category` text,
  `product_name` text,
  `sales` text,
  `quantity` text,
  `discount` text,
  `profit` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copying of data into new table
INSERT INTO raw_staging_new
SELECT * FROM raw_staging;

-- Verifying
SELECT *
FROM raw_staging_new;
-- ================================================================
-- 
-- CLEANING PROPER
--
-- [Table-level] : Deduplicate — keep one instance per unique row.
WITH instances AS (
    SELECT
        row_id, order_id, order_date, ship_date, ship_mode,
        customer_id, customer_name, segment, country_or_region,
        city, state_or_province, postal_code, region,
        product_id, category, sub_category, product_name,
        sales, quantity, discount, profit,
        ROW_NUMBER() OVER (
            PARTITION BY row_id, order_id, order_date, ship_date, ship_mode,
                         customer_id, customer_name, segment, country_or_region,
                         city, state_or_province, postal_code, region,
                         product_id, category, sub_category, product_name,
                         sales, quantity, discount, profit
            ORDER BY row_id
        ) AS rn
    FROM raw_staging_new
)
DELETE FROM raw_staging_new
WHERE row_id IN (SELECT row_id FROM instances WHERE rn > 1);

-- [order_date] :  Standardize to a single DATE-compatible format.
UPDATE raw_staging_new
SET order_date =
	CASE
		WHEN order_date LIKE '____-__-__%' THEN STR_TO_DATE(SUBSTRING(order_date,1,10), '%Y-%m-%d')
        WHEN order_date LIKE '__-___-____' THEN STR_TO_DATE(order_date, '%d-%b-%Y')
        WHEN order_date LIKE '__.__.____' THEN STR_TO_DATE(order_date, '%d.%m.%Y')
        WHEN order_date LIKE '________' THEN STR_TO_DATE(order_date, '%Y%m%d')
    END
WHERE 
    order_date LIKE '____-__-__%' OR
    order_date LIKE '__-___-____' OR
    order_date LIKE '__.__.____' OR
    order_date LIKE '________';

-- [ship_mode] : Set NULL/empty values to Unknown
UPDATE raw_staging_new
SET ship_mode = 'Unknown'
WHERE ship_mode IS NULL OR ship_mode = '';

-- [segment] : Remove whitespace; standardize casing, correct typos
UPDATE raw_staging_new
SET segment =
	CASE
		WHEN segment LIKE '%Co%sum%' THEN 'Consumer'
        WHEN segment LIKE 'Home%' THEN 'Home Office'
        WHEN segment LIKE 'Corp%' THEN 'Corporate'
    END;
    
-- [category] : TRIM() to remove whitespace
UPDATE raw_staging_new
SET category = TRIM(category);

-- DECISION on [Sales]:
-- Remove rows with missing Sales values because they cannot be reliably reconstructed and sales is a primary metric.
DELETE FROM raw_staging_new
WHERE sales = '';

-- DECISION on [Quantity]:
-- Retain unusually high Quantity values because they may represent legitimate bulk purchases, while removing only rows with missing values.
DELETE FROM raw_staging_new
WHERE quantity = '';

UPDATE raw_staging_new
SET quantity = SUBSTRING(quantity, 1, LENGTH(quantity)-2);

-- DECISION on [Discount]:
-- Correct the invalid Discount value of 5.5 to 0.55, assuming it is a decimal-entry error.
UPDATE raw_staging_new
SET discount = '0.55'
WHERE discount = '5.5';

-- DECISION on [Profit]:
-- Remove rows with missing Profit values and retain negative Profit values, as losses are valid business outcomes.
UPDATE raw_staging_new
SET profit = REPLACE(profit, '\r', '')
WHERE profit LIKE '%\r%';

DELETE FROM raw_staging_new
WHERE profit IS NULL OR profit = '';



















