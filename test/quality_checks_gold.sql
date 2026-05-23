/*
-- ==========================================================================
Qulality Check
-- =========================================================================
Script Purpose 
 This script performs quality checks to validate the integrity, consistency,
 and accuracy of the Gold layer. These checks ensure:
- uniqueness of the surrogate keys in the dimension table
- Referential integrity between fact and dimension tables
- Validation of the relationship  in the model for analytical purposes

Usage Notes
- Run these checks after data loading silver layer
- Investigate and resolve any discrepancies found during the checks
-- =========================================================================
*/
-- ==========================================================================
-- checking 'gold.dim_customers'
-- ==========================================================================
-- check for the uniqueness of product key in the gold.dim_customers
-- Expections: No Results
SELECT
customer_key,
COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT (*) > 1 

-- ==========================================================================
-- checking 'gold.product_key'
-- ==========================================================================
-- check for the uniqueness of product key in the gold.product_key
-- Expections: No Results

SELECT 
    pr.prd_key,
    COUNT(pr.prd_key) AS total_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ==========================================================================
-- checking 'gold.fact_sales'
-- =========================================================================
-- check for the uniqueness of product key in the gold.fact_sales
-- Expections: No Results

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

