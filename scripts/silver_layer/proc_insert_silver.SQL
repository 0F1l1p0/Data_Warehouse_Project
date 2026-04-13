/*
==================================================
STORED PROCEDURE SCRIPT

This script creates a stored procedure that loads data into the silver schema from
the bronze schema.

What is being done within the procedure itself:
	-Its performing the standard ETL(Extract, Transform, Load) process from the bronze schema
	tables into the silver schema tables
	-Truncates Silver tables
	-Inserts transformed and cleaned data from the bronze layer to the silver layer
Additionally the procedure does not accept any paramaters or return any values,
other than printed information for each table like the time it took to fill each one 
and the time it took to execute the entire procedure.

USE
	EXEC bronze.load_bronze_schema

==================================================
*/
CREATE OR ALTER PROCEDURE Silver.load_silver_schema AS
BEGIN
	BEGIN TRY
		
		--Table value to show which table may have failed
		DECLARE @Table nvarchar

		--StartTime to show the start of the bulk insert for a table
		DECLARE @StartTime datetime

		--EndTime to show the end of the bulk insert for a table
		DECLARE @EndTime datetime

		--StartSilverTime to show the start of the load for the entire batch
		DECLARE @StartSilverTime datetime

		--EndSilverTime to show the end of the load for the entire batch
		DECLARE @EndSilverTime datetime
			
			--CRM SOURCES
			PRINT '======================================================================'
			PRINT 'Loading Silver Layer Schema'
			PRINT '======================================================================'

			SET @StartSilverTime=GETDATE()

			PRINT '======================================================================'
			PRINT 'Loading CRM Tables'
			PRINT '======================================================================'

			PRINT '===>Truncating Table: silver.crm_cust_info'

			TRUNCATE TABLE Silver.crm_cust_info

			PRINT '===>Inserting into Table: silver.crm_cust_info'

			SET @Table='crm_cust_info'

			SET @StartTime=GETDATE()

			INSERT INTO Silver.crm_cust_info (
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date
				)
			SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) as cst_firstname, --Removnig unneeded empty spaces
			TRIM(cst_lastname) as cst_lastname,  --Removnig unneeded empty spaces

			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 ELSE 'N/A'
			END AS cst_marital_status, --Making the marital status values into readable values

			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'N/A'
			END AS cst_gndr, --Making the gender values into readable values
			cst_create_date
			FROM
			(
			SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM Bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
			) t 
			WHERE flag_last = 1 --Selecting the customer with the most recent order date and avoiding duplicates

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'


			PRINT '===>Truncating Table: Silver.crm_prd_info'

			TRUNCATE TABLE Silver.crm_prd_info

			PRINT '===>Inserting into Table: Silver.crm_prd_info'

			SET @Table='crm_prd_info'

			SET @StartTime=GETDATE()

			INSERT INTO Silver.crm_prd_info(
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
			)
			SELECT prd_id,
				  REPLACE(SUBSTRING(prd_key,1, 5),'-','_') AS cat_id, --Extracting the cattegory ID
				  SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key, --Extracting the product key
				  prd_nm,
				  ISNULL(prd_cost,0) as prd_cost,

				  CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
					   WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
					   WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
					   WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
					   ELSE 'N/A'  
				  END AS prd_line,--Change the single letter values to descriptive ones

				  CAST(prd_start_dt as date) as prd_start_dt,

				  CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 as date) as prd_end_dt
			FROM Bronze.crm_prd_info

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'


			PRINT '===>Truncating Table: Silver.crm_sales_details'

			TRUNCATE TABLE Silver.crm_sales_details

			PRINT '===>Inserting into Table: Silver.crm_sales_details'

			SET @Table='crm_sales_details'

			SET @StartTime=GETDATE()

			INSERT INTO Silver.crm_sales_details(
			sls_ord_num, 
			sls_prd_key, 
			sls_cust_id, 
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)
			SELECT 
			sls_ord_num, 
			sls_prd_key, 
			sls_cust_id, 

			CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS varchar) AS date)
			END AS sls_order_dt, --Checking for invalid data

			CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS varchar) AS date)
			END AS sls_ship_dt, --Checking for invalid data

			CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS varchar) AS date)
			END AS sls_due_dt,  --Checking for invalid data

			CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_quantity*ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, --Calculating sales if original value is missing or not correct

			sls_quantity, 

			CASE WHEN sls_price IS NULL or sls_price<=0
					THEN sls_sales / NULLIF(sls_quantity,0)
				ELSE sls_price --Deriving the price if the original value is invalid
			END AS sls_price
			FROM Bronze.crm_sales_details

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			PRINT '======================================================================'
			PRINT 'Loading ERP Tables'
			PRINT '======================================================================'

			PRINT '===>Truncating Table: Silver.erp_cust_az12'

			TRUNCATE TABLE Silver.erp_cust_az12

			PRINT '===>Inserting into Table: Silver.erp_cust_az12'

			SET @Table='erp_cust_az1'

			SET @StartTime=GETDATE()

			INSERT INTO Silver.erp_cust_az12(cid, bdate, gen)
			SELECT  
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				 ELSE cid --Removed the unneeded prefix 'NAS'
			END as cid,

			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END as bdate, --Set birthdays bigger than the current date to NULL

			CASE WHEN UPPER(TRIM(gen)) LIKE 'F' THEN 'Female'
				 WHEN UPPER(TRIM(gen)) LIKE 'FEMALE' THEN 'Female'
				 WHEN UPPER(TRIM(gen)) LIKE 'M' THEN 'Male'
				 WHEN UPPER(TRIM(gen)) LIKE 'MALE' THEN 'Male'
				 ELSE 'N/A' 
			END AS gen	 --Normalized gen values to handle unkown cases
			FROM Bronze.erp_cust_az12

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			PRINT '===>Truncating Table: Silver.erp_loc_a101'

			TRUNCATE TABLE Silver.erp_loc_a101

			PRINT '===>Inserting into Table: Silver.erp_loc_a101'

			SET @Table='erp_loc_a101'

			SET @StartTime=GETDATE()

			INSERT INTO Silver.erp_loc_a101 (cid,cntry)
			(
			SELECT
			REPLACE(cid,'-','') cid,
			CASE WHEN UPPER(TRIM(cntry))= 'DE' THEN 'Germany'
				 WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
				 WHEN UPPER(TRIM(cntry))='' OR cntry IS NULL THEN 'N/A'
				 ELSE Trim(cntry) --Normalizing country codes and handling blank ones
			END AS cntry
			FROM Bronze.erp_loc_a101
			)

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			PRINT '===>Truncating Table: Silver.erp_px_cat_g1v2'

			TRUNCATE TABLE Silver.erp_px_cat_g1v2

			PRINT '===>Inserting into Table: Silver.erp_px_cat_g1v2'

			SET @Table='erp_px_cat_g1v2'

			SET @StartTime=GETDATE()

			INSERT INTO Silver.erp_px_cat_g1v2
			(id,cat,subcat,maintenance)
			SELECT 
			id, --No change needed due to the prd_id already being in the right format in order to be joined later on
			cat, 
			subcat, 
			maintenance
			FROM Bronze.erp_px_cat_g1v2

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			SET @EndSilverTime=GETDATE()

			PRINT '======================================================================'
			PRINT 'Silver Layer Load Duration : ' + CAST(DATEDIFF(SECOND,@StartSilverTime,@EndSilverTime) AS nvarchar) + 'seconds'
			PRINT '======================================================================'

	END TRY
	BEGIN CATCH
		PRINT '========================================='
		PRINT 'ERROR OCCURED DURING SILVER LAYER'
		PRINT 'Error Message ' +ERROR_MESSAGE();
		PRINT 'Error Message ' +CAST(ERROR_NUMBER() as nvarchar)
		PRINT 'Error occured for table: ' +@Table+ '!'
		PRINT '========================================='
	END CATCH
END
