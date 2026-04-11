
==================================================
STORED PROCEDURE SCRIPT


==================================================



CREATE OR ALTER PROCEDURE bronze.load_bronze_schema AS
BEGIN
	BEGIN TRY

		--Table value to show which table may have failed
		DECLARE @Table nvarchar

		--StartTime to show the start of the bulk insert for a table
		DECLARE @StartTime datetime

		--EndTime to show the end of the bulk insert for a table
		DECLARE @EndTime datetime

		--StartBronzeTime to show the start of the load for the entire batch
		DECLARE @StartBronzeTime datetime

		--EndBronzeTime to show the end of the load for the entire batch
		DECLARE @EndBronzeTime datetime

			--CRM SOURCES
			PRINT '======================================================================'
			PRINT 'Loading Bronze Layer Schema'
			PRINT '======================================================================'

			SET @StartBronzeTime=GETDATE()

			PRINT '======================================================================'
			PRINT 'Loading CRM Tables'
			PRINT '======================================================================'

			SET @Table='crm_cust_info'

			SET @StartTime=GETDATE()

			PRINT '===>Truncating Table: crm_cust_info'
			
			TRUNCATE TABLE bronze.crm_cust_info

			PRINT '===>Inserting Into Table: crm_cust_info'

			BULK INSERT bronze.crm_cust_info
			FROM 'D:\Downloads\DataWarehouse\source_crm\cust_info.csv'
			WITH(
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK
			)
			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			SET @Table='crm_prd_info'

			SET @StartTime=GETDATE()

			PRINT '===>Truncating Table: crm_prd_info'

			TRUNCATE TABLE bronze.crm_prd_info

			PRINT '===>Inserting Into Table: crm_prd_info'

			BULK INSERT bronze.crm_prd_info
			FROM 'D:\Downloads\DataWarehouse\source_crm\prd_info.csv'
			WITH(
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK
			)
			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			SET @Table='crm_sales_details'

			SET @StartTime=GETDATE()

			PRINT '===>Truncating Table: crm_sales_details'

			TRUNCATE TABLE bronze.crm_sales_details

			PRINT '===>Inserting Into Table: crm_sales_details'

			BULK INSERT bronze.crm_sales_details
			FROM 'D:\Downloads\DataWarehouse\source_crm\sales_details.csv'
			WITH(
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK
			)

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'
			--ERP SOURCES
	
			PRINT '======================================================================'
			PRINT 'Loading CRM Tables'
			PRINT '======================================================================'

			SET @Table='erp_cust_az12'

			SET @StartTime=GETDATE()

			PRINT '===>Truncating Table: erp_cust_az12'

			TRUNCATE TABLE bronze.erp_cust_az12

			PRINT '===>Inserting Into Table: erp_cust_az12'

			BULK INSERT bronze.erp_cust_az12
			FROM 'D:\Downloads\DataWarehouse\source_erp\cust_az12.csv'
			WITH(
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK
				)
			
			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			SET @Table='erp_loc_a101'

			SET @StartTime=GETDATE()

			PRINT '===>Truncating Table: erp_loc_a101'

			TRUNCATE TABLE bronze.erp_loc_a101

			PRINT '===>Inserting Into Table: erp_loc_a101'

			BULK INSERT bronze.erp_loc_a101
			FROM 'D:\Downloads\DataWarehouse\source_erp\loc_a101.csv'
			WITH(
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK
				)
			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			SET @Table='erp_px_cat_g1v2'

			SET @StartTime=GETDATE()

			PRINT '===>Truncating Table: erp_px_cat_g1v2'

			TRUNCATE TABLE bronze.erp_px_cat_g1v2

			PRINT '===>Inserting Into Table: erp_px_cat_g1v2'

			BULK INSERT bronze.erp_px_cat_g1v2
			FROM 'D:\Downloads\DataWarehouse\source_erp\px_cat_g1v2.csv'
			WITH(
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK
				)

			SET @EndTime=GETDATE()

			PRINT '>>> Load Duration: ' + CAST(DATEDIFF(SECOND, @StartTime, @EndTime) AS nvarchar) + ' seconds'
			PRINT '----------------'

			SET @EndBronzeTime=GETDATE()

			PRINT '======================================================================'
			PRINT 'Bronze Layer Load Duration : ' + CAST(DATEDIFF(SECOND,@StartBronzeTime,@EndBronzeTime) AS nvarchar) + 'seconds'
			PRINT '======================================================================'
	END TRY
	BEGIN CATCH
		PRINT '========================================='
		PRINT 'ERROR OCCURED DURING BRONZE LAYER'
		PRINT 'Error Message ' +ERROR_MESSAGE();
		PRINT 'Error Message ' +CAST(ERROR_NUMBER() as nvarchar)
		PRINT 'Error occured for table: ' +@Table+ '!'
		PRINT '========================================='
	END CATCH
END
