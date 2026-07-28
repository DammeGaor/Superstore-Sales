-- ================================================================
-- 			FINAL TABLE CREATION
-- Goal: 	Create a final table with correct data types and migrate
-- 			the clean data into the new table
-- ================================================================

-- This query creates the table with correct data types.
CREATE TABLE sales_superstore_clean (
    row_id              INT,
    order_id            VARCHAR(20),
    order_date          DATE,
    ship_date           DATE,
    ship_mode           VARCHAR(50),
    customer_id         VARCHAR(20),
    customer_name       VARCHAR(100),
    segment             VARCHAR(50),
    country_or_region   VARCHAR(100),
    city                VARCHAR(100),
    state_or_province   VARCHAR(100),
    postal_code         VARCHAR(10),   
    region              VARCHAR(50),
    product_id          VARCHAR(30),
    category            VARCHAR(50),
    sub_category        VARCHAR(50),
    product_name        VARCHAR(255),
    sales               DECIMAL(10,2),
    quantity            INT,
    discount            DECIMAL(5,2),
    profit              DECIMAL(10,2)
);

-- Inserting the data into the new table
INSERT INTO sales_superstore_clean
SELECT
    CAST(row_id AS SIGNED),
    order_id,
    order_date,        
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country_or_region,
    city,
    state_or_province,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    CAST(NULLIF(sales, '') AS DECIMAL(10,2)),
    CAST(NULLIF(quantity, '') AS SIGNED),
    CAST(NULLIF(discount, '') AS DECIMAL(5,2)),
    CAST(NULLIF(profit, '') AS DECIMAL(10,2))
FROM raw_staging_new;

-- Checks and verification
SELECT *
FROM sales_superstore_clean;