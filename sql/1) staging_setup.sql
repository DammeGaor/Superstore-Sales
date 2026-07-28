-- ===============================================
-- 			STAGING SETUP
-- Goal: 	To create a staging table, import values
-- 			from the CSV, and verify imported values. 
-- ===============================================

-- This query creates the staging table and explicitly
-- sets all columns to type TEXT to avoid data loss and
-- avoid inconsisten formatting. This is done so we have
-- complete control in cleaning and managing the data.
CREATE TABLE raw_staging (
	row_id			TEXT,
    order_id		TEXT,
    order_date		TEXT,
    ship_date		TEXT,
    ship_mode		TEXT,
    customer_id		TEXT,
    customer_name	TEXT,
    segment			TEXT,
    country_or_region	TEXT,
    city			TEXT,
    state_or_province	TEXT,
    postal_code		TEXT,
    region			TEXT,
    product_id		TEXT,
    category		TEXT,
    sub_category	TEXT,
    product_name	TEXT,
    sales			TEXT,
    quantity		TEXT,
    discount		TEXT,
    profit			TEXT
);

-- Importing the raw CSV values into the staging table.
LOAD DATA LOCAL INFILE 'C:/Users/Dam/Desktop/RoadToDataAnalyst/SQL/Superstore Sales/data/raw/sales_superstore_raw.csv'
INTO TABLE raw_staging
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Visual check to confirm that data is loaded and
-- matched to the correct column
SELECT *
FROM raw_staging
LIMIT 100;

-- Row count check to confirm matching count with the actual CSV
-- Actual values: CSV (10704) = raw_staging(10703)
-- (minus 1 count for the CSV to account for headers)
SELECT COUNT(*) as row_count
FROM raw_staging;