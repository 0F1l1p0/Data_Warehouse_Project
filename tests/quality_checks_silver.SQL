/*
=======================================
QUALITY CHECKS
=======================================
The purpose of this script is to check the consistency integrity and accuracy of 
the silver and bronze schema tables.
  Tasks include:
-Checking for nulls or duplicates
-Unwanted spaces in strings
-Consistency within the data
-Invalid date ranges and invalide date orders
-Consistency between related tables
*/

--Testing crm_cust_info--


SELECT 
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 or cst_id IS NULL

--Finding duplicates regarding the ID

SELECT
*
FROM
(
SELECT 
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM Bronze.crm_cust_info
) t 
WHERE flag_last >1

--Checking for unwanted Spaces
SELECT cst_firstname
FROM Bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
--15 values

SELECT cst_lastname
FROM Bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)
--17 values

SELECT cst_gndr
FROM Bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)
--0 values

SELECT cst_key
FROM Bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key)
--0 values

--Checking for Consistency
SELECT DISTINCT cst_gndr
FROM Bronze.crm_cust_info

--Checking for Consistency
SELECT DISTINCT cst_marital_status
FROM Bronze.crm_cust_info


--Testing crm_prd_info--


--Checking for duplicates
SELECT 
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 or prd_id IS NULL

--Checking for unneeded empty spaces
SELECT 
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm !=TRIM(prd_nm)

--Checking for nulls
SELECT 
prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Checking for consistency
SELECT DISTINCT 
prd_line 
FROM silver.crm_prd_info

--Checking for Invalide Order dates
SELECT 
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 as prd_end_dt_test
FROM
silver.crm_prd_info
WHERE prd_key='AC-HE-HL-U509-R' OR prd_key='AC-HE-HL-U509'


--Testing crm_sales_details--

SELECT 
NULLIF(sls_order_dt,0) 
FROM Bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt >20400101
OR sls_order_dt <19000101

SELECT 
sls_sales,
sls_quantity,
sls_price
FROM Silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales<=0 OR sls_quantity<=0 OR sls_price <=0
ORDER BY sls_sales,sls_quantity,sls_price

--Testing erp_cust_az12

SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE()

-- Data consistency
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12

--Testing erp_loc_a101

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry

--Testing erp_px_cat_g1v2

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance)


-- Data Standardization & Consistency
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2
