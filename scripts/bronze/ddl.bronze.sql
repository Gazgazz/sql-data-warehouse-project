/*
=========================================================================
DDL Script: Create database and schemas
=========================================================================
Script Purpose:
    This script creates a new database named 'datawarehouse' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver' and 'gold'.
Warning:
    Running this script will drop the entire 'Datawarehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

-- Drop the 'Datawarehouse' database if it exists
DROP DATABASE IF EXISTS Datawarehouse;

-- Create the 'Datawarehouse' database
CREATE DATABASE Datawarehouse;

-- Switch to the 'Datawarehouse' database
USE Datawarehouse;

-- Create schemas (in MySQL, schemas = separate databases, so we use naming convention)
CREATE SCHEMA bronze1;
CREATE SCHEMA silver1;
CREATE SCHEMA gold1;

DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
cstd_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(10),
cst_gndr nvarchar(50),
cst_create_date date
);

DROP TABLE IF EXISTS bronze.crm_prdt_info;
CREATE TABLE bronze.crm_prdt_info(
prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost nvarchar(50),
prd_line nvarchar(10),
prd_start_dt datetime,
prd_end_dte datetime
);

DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id nvarchar(50),
sls_order_dt nvarchar(50),
sls_ship_dt nvarchar(10),
sls_due_dt datetime,
sls_sales int(50),
sls_quantity int (20),
sls_price int (50)
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
cid nvarchar(50),
bdate DATE,
gen nvarchar (10)
);

DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
cid nvarchar(50),
cntry nvarchar (50)
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
id nvarchar(50),
cat nvarchar (50),
subcat nvarchar (50),
maintenance nvarchar (50)
);































