/*


*/

--=================================================
--Gold.dim_customers
--=================================================
IF OBJECT_ID ('Gold.dim_customers','U') IS NOT NULL
	DROP VIEW Gold.dim_customers  
GO
CREATE VIEW Gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr --crm is the main table for gender info
		 ELSE ISNULL(ca.gen,'N/A')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci 
LEFT JOIN silver.erp_cust_az12 ca
ON	ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON	ci.cst_key = la.cid

--=================================================
--Gold.dim_products
--=================================================
  
IF OBJECT_ID ('Gold.dim_products','U') IS NOT NULL
	DROP VIEW Gold.dim_products  
GO
CREATE VIEW Gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_key) AS product_key,
	pr.prd_id AS product_id, 
	pr.prd_key AS product_number, 
	pr.prd_nm AS product_name,
	pr.cat_id AS category_id, 
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pr.prd_cost AS product_cost, 
	pr.prd_line AS product_line, 
	pr.prd_start_dt AS start_date
FROM Silver.crm_prd_info pr 
LEFT JOIN Silver.erp_px_cat_g1v2 pc 
ON pr.cat_id=pc.id
WHERE prd_end_dt IS NULL --To filter out historical data

--=================================================
--Gold.fact_sales
--=================================================
    
IF OBJECT_ID ('Gold.fact_sales','U') IS NOT NULL
	DROP VIEW Gold.fact_sales
GO
CREATE VIEW gold.fact_sales AS
SELECT 
  sl.sls_ord_num AS order_number, 
  pr.product_key, 
  cu.customer_id, 
  sl.sls_order_dt AS order_date, 
  sl.sls_ship_dt AS shipping_date, 
  sl.sls_due_dt AS due_date, 
  sl.sls_sales AS sales_amount, 
  sl.sls_quantity AS quantity, 
  sl.sls_price
FROM silver.crm_sales_details sl
LEFT JOIN gold.dim_products pr
ON sl.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON 
sl.sls_cust_id=cu.customer_id
