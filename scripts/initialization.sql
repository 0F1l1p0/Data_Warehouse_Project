/*
======================================================
SCHEMA AND DATABASE CREATION
======================================================

	The purpose of the script is to create a new database named 'Datawarehouse' after it checks the system if it already
exists. Additionally, this scrip sets up three schemas according to the medallion architecture. The schemas are named after
the 3 appropriate layers in the architecture, GOLD , SILVER and BRONZE
	
	Additionally if you have a database that already has the name 'DataWarehouse' it will drop it.
*/

USE master;

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	--This part is only useful if the database is in a shared enviorment
	ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	--You can also use this only IF you're the only one using the database
	DROP DATABASE DataWarehouse
END

GO
--DataWarehouse Database Creation

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

--Schema Creation
GO
CREATE SCHEMA Bronze

GO
CREATE SCHEMA Silver

GO
CREATE SCHEMA Gold

