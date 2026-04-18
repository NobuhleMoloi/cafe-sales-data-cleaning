-- ================================================================================
-- DATA CLEANING - CAFE SALES
-- ================================================================================

-- 1. DATA STAGING
-- Create a working copy to preserve raw data

CREATE TABLE cafe_sales_staging
LIKE dirty_cafe_sales;

INSERT INTO cafe_sales_staging
SELECT *
FROM dirty_cafe_sales;

-- ================================================================================
-- 2. COLUMN STANDARDISATION
-- Rename columns for consistency
-- ================================================================================

ALTER TABLE cafe_sales_staging
RENAME COLUMN `Transaction ID` TO transaction_id,
RENAME COLUMN Item TO item,
RENAME COLUMN Quantity TO quantity,
RENAME COLUMN `Price Per Unit` TO price_per_unit,
RENAME COLUMN `Total Spent` TO total_spent,
RENAME COLUMN `Payment Method` TO payment_method,
RENAME COLUMN Location TO location,
RENAME COLUMN `Transaction Date` TO transaction_date;

-- Check staging table in order
SELECT *
FROM cafe_sales_staging;

-- ================================================================================
-- 3. DATA PROFILING
-- Check for duplicate transactions
-- ================================================================================

SELECT transaction_id, COUNT(*) AS orders
FROM cafe_sales_staging
GROUP BY transaction_id
HAVING orders > 1;

-- ================================================================================
-- 4. ITEM CLEANING & IMPUTATION
-- ================================================================================

-- Standardise invalid values
UPDATE cafe_sales_staging
SET item = NULL
WHERE item = '' OR item IN ('ERROR', 'UNKNOWN');

-- Check missing values before
SELECT COUNT(*) AS null_items_before
FROM cafe_sales_staging
WHERE item IS NULL;

-- Impute using safe price-to-item mapping
WITH price_item_map AS (
    SELECT price_per_unit, MIN(item) AS item
    FROM cafe_sales_staging
    WHERE item IS NOT NULL
    GROUP BY price_per_unit
    HAVING COUNT(DISTINCT item) = 1
)
UPDATE cafe_sales_staging t1
JOIN price_item_map t2
ON t1.price_per_unit = t2.price_per_unit
SET t1.item = t2.item
WHERE t1.item IS NULL;

-- Note: Prices with multiple associated items are excluded to prevent incorrect imputation

-- Check remaining NULLs
SELECT COUNT(*) AS null_items_after
FROM cafe_sales_staging
WHERE item IS NULL;

-- ================================================================================
-- 5. NUMERIC DATA CLEANING
-- ================================================================================

-- Recalculate total_spent where invalid
UPDATE cafe_sales_staging
SET total_spent = quantity * price_per_unit
WHERE total_spent = '' 
   OR total_spent IN ('ERROR', 'UNKNOWN');

-- ================================================================================
-- 6. CATEGORICAL STANDARDISATION
-- ================================================================================

-- Standardise payment_method
UPDATE cafe_sales_staging
SET payment_method = 'Unknown'
WHERE payment_method = '' 
   OR payment_method IN ('ERROR', 'UNKNOWN');
   
-- Check Unknown categories
SELECT payment_method, COUNT(*) 
FROM cafe_sales_staging
GROUP BY payment_method
ORDER BY 2 DESC; -- Unknown values are the highest

-- Standardise location
UPDATE cafe_sales_staging
SET location = 'Unknown'
WHERE location = '' 
   OR location IN ('ERROR', 'UNKNOWN');
   
-- Check Unknown categories
SELECT location, COUNT(*) 
FROM cafe_sales_staging
GROUP BY location
ORDER BY 2 DESC; -- unknown values are the highest

-- ================================================================================
-- 7. DATE CLEANING
-- ================================================================================

-- Remove invalid values
UPDATE cafe_sales_staging
SET transaction_date = NULL
WHERE transaction_date = '' 
   OR transaction_date IN ('ERROR', 'UNKNOWN');

-- Convert to DATE format
UPDATE cafe_sales_staging
SET transaction_date = STR_TO_DATE(transaction_date, '%Y-%m-%d');

-- Check Unknown categories
SELECT COUNT(*)
FROM cafe_sales_staging
WHERE transaction_date IS NULL;

-- ================================================================================
-- 8. DATA TYPE CONVERSION
-- ================================================================================

ALTER TABLE cafe_sales_staging
MODIFY COLUMN transaction_date DATE,
MODIFY COLUMN price_per_unit DECIMAL(5,2),
MODIFY COLUMN total_spent DECIMAL(7,2);

-- ================================================================================
-- 9. VALIDATION
-- ================================================================================

SELECT *
FROM cafe_sales_staging;

-- ================================================================================
-- DATA QUALITY NOTE & RECOMMENDATION
-- ================================================================================

-- A high frequency of 'Unknown' values in categorical fields (payment_method, location)
-- and a significant number of NULL values in transaction_date indicate inconsistencies
-- in data capture at the point of sale.

-- Recommendation:
-- Implement input validation controls within POS systems to restrict invalid entries,
-- and provide staff training focused on accurate and consistent transaction recording.