

/*
=========================================================================
DDL Script : Create silver tables
Script Purpose:
    This script creates a new tables in the silver layer for cleaned data for 
    subsequent transformation
=========================================================================
*/

    DROP TABLE IF EXISTS silver.crm_cust_info;
    CREATE TABLE silver.crm_cust_info(
        cstd_id             int,
        cst_key             nvarchar(50),
        cst_firstname       nvarchar(50),
        cst_lastname        nvarchar(50),
        cst_marital_status  nvarchar(10),
        cst_gndr            nvarchar(50),
        cst_create_date     date
    );

    DROP TABLE IF EXISTS silver.crm_prd_info;
    CREATE TABLE silver.crm_prd_info(
        prd_id          int,
        prd_key         nvarchar(50),
        cat_id          nvarchar(50),
        prd_nm          nvarchar(50),
        prd_cost        nvarchar(50),
        prd_line        nvarchar(10),
        prd_start_dt    date,
        prd_end_dte     date,
        dwh_create_date datetime default NOW()
    );

    DROP TABLE IF EXISTS silver.crm_sales_details;
    CREATE TABLE silver.crm_sales_details(
        sls_ord_num     nvarchar(50),
        sls_prd_key     nvarchar(50),
        sls_cust_id     nvarchar(50),
        sls_order_dt    date,
        sls_ship_dt     date,
        sls_due_dt      date,
        sls_sales       int,
        sls_quantity    int,
        sls_price       int,
        dwh_create_date datetime default NOW()
    );
    DROP TABLE IF EXISTS silver.erp_cust_az12;
    CREATE TABLE silver.erp_cust_az12(
        cid             nvarchar(50),
        bdate           DATE,
        gen             nvarchar(10),
        dwh_create_date datetime default NOW()
    );
    
    DROP TABLE IF EXISTS silver.erp_loc_a101;
    CREATE TABLE silver.erp_loc_a101(
        cid             nvarchar(50),
        cntry           nvarchar(50),
        dwh_create_date datetime default NOW()
    );

    DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
    CREATE TABLE silver.erp_px_cat_g1v2(
        id              nvarchar(50),
        cat             nvarchar(50),
        subcat          nvarchar(50),
        maintenance     nvarchar(50),
        dwh_create_date datetime default NOW()
    );



