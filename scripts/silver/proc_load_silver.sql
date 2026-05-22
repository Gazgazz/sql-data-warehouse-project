

/*
=========================================================================
Stored Procedure : Load Silver Layer
Script Purpose:
    The stored procedure carries out the ETL process, populating the silver tables with cleansed data transformed
    from the bronze layer in preparation for the gold layer for analysis
    Actions
    - Truncated silver tables
    - Inserted transformed and cleansed data from bronze to silver tables
    
    Parameters
		This stored procedure does not accept any parameters or retun any values
        ddl script were inputted for good understanding
	
    Usage example
		CALL silver.load_layer();
=========================================================================
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS silver.load_layer;

CREATE PROCEDURE silver.load_layer()
BEGIN 

    -- ============================================
    -- VARIABLES
    -- ============================================

    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration_seconds INT;
    DECLARE error_message TEXT;
    DECLARE error_code INT;

    -- ============================================
    -- ERROR HANDLER
    -- ============================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            error_message = MESSAGE_TEXT,
            error_code = MYSQL_ERRNO;

        SELECT CONCAT(
            '================================================== | ',
            'SILVER LAYER LOAD FAILED | ',
            'Error Code: ', error_code, ' | ',
            'Error Message: ', error_message
        ) AS message;
    END;

    -- ============================================
    -- START TIMER
    -- ============================================

    SET start_time = NOW();

    /*
    ============================================================================================
    -- inserting cleaned result of silver.crm_cust_info from bronze table in the silver layer
    ============================================================================================
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

    INSERT INTO silver.crm_cust_info
    (
        cstd_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT 
        cstd_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname)  AS cst_lastname,
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'married'
             WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'single'
             ELSE 'unknown'
        END AS cst_marital_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
             WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
             ELSE 'unknown'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT  
            *,
            ROW_NUMBER() OVER (PARTITION BY cstd_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
    ) t 
    WHERE flag_last = 1;

    SELECT * FROM silver.crm_cust_info;

    /*
    ============================================================================================
    -- inserting cleaned result of silver.crm_prd_info from bronze table in the silver layer
    ============================================================================================
    */

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

    INSERT INTO silver.crm_prd_info(
        prd_id,
        prd_key,
        cat_id,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dte
    )
    SELECT 
        prd_id,
        SUBSTRING(prd_key, 7, LENGTH(prd_key))          AS prd_key,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')     AS cat_id,
        prd_nm,
        COALESCE(NULLIF(TRIM(prd_cost), ''), 0)          AS prd_cost,
        CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'medium'
             WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'regular'
             WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'small'
             WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'tall'
             ELSE 'unknown'
        END AS prd_line,
        prd_start_dt,
        DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS prd_end_dte
    FROM bronze.crm_prd_info;

    SELECT * FROM silver.crm_prd_info;

    /*
    ============================================================================================
    -- inserting cleaned result of silver.crm_sales_details from bronze table in the silver layer
    ============================================================================================
    */

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

    INSERT INTO silver.crm_sales_details
    (
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
        DATE_FORMAT(CASE 
            WHEN sls_order_dt = 0 THEN NULL
            WHEN LENGTH(sls_order_dt) != 8 THEN NULL
            ELSE sls_order_dt
        END, '%Y-%m-%d') AS sls_order_dt,
        DATE_FORMAT(CASE 
            WHEN sls_ship_dt = 0 THEN NULL
            WHEN LENGTH(sls_ship_dt) != 8 THEN NULL
            ELSE sls_ship_dt
        END, '%Y-%m-%d') AS sls_ship_dt,
        DATE_FORMAT(sls_due_dt, '%Y-%m-%d') AS sls_due_dt,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / sls_quantity
            ELSE sls_price
        END AS sls_price,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales
    FROM bronze.crm_sales_details;

    SELECT * FROM silver.crm_sales_details;

    /*
    ============================================================================================
    -- inserting cleaned result of silver.erp_cust_az12 from bronze table in the silver layer
    ============================================================================================
    */

    DROP TABLE IF EXISTS silver.erp_cust_az12;
    CREATE TABLE silver.erp_cust_az12(
        cid             nvarchar(50),
        bdate           DATE,
        gen             nvarchar(10),
        dwh_create_date datetime default NOW()
    );

    INSERT INTO silver.erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    SELECT  
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
             ELSE cid
        END AS cid,
        CASE WHEN bdate > NOW() THEN NULL
             ELSE bdate
        END AS bdate,
        CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
             WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
             ELSE 'unknown'
        END AS gen
    FROM bronze.erp_cust_az12;

    SELECT * FROM silver.erp_cust_az12;

    /*
    ============================================================================================
    -- inserting cleaned result of silver.erp_loc_a101 from bronze table in the silver layer
    ============================================================================================
    */

    DROP TABLE IF EXISTS silver.erp_loc_a101;
    CREATE TABLE silver.erp_loc_a101(
        cid             nvarchar(50),
        cntry           nvarchar(50),
        dwh_create_date datetime default NOW()
    );

    INSERT INTO silver.erp_loc_a101
    (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid, '-', '')   AS cid,
        CASE WHEN TRIM(cntry) = 'DE'            THEN 'Germany'
             WHEN TRIM(cntry) IN ('US', 'USA')  THEN 'United States'
             WHEN TRIM(cntry) = '' 
               OR cntry IS NULL                 THEN 'unknown'
             ELSE TRIM(cntry)
        END AS cntry
    FROM bronze.erp_loc_a101;

    SELECT * FROM silver.erp_loc_a101;

    /*
    ============================================================================================
    -- inserting cleaned result of silver.erp_px_cat_g1v2 from bronze table in the silver layer
    ============================================================================================
    */

    DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
    CREATE TABLE silver.erp_px_cat_g1v2(
        id              nvarchar(50),
        cat             nvarchar(50),
        subcat          nvarchar(50),
        maintenance     nvarchar(50),
        dwh_create_date datetime default NOW()
    );

    INSERT INTO silver.erp_px_cat_g1v2
    (id, cat, subcat, maintenance)
    SELECT 
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;

    SELECT * FROM silver.erp_px_cat_g1v2;

    -- ============================================
    -- END TIMER
    -- ============================================

    SET end_time = NOW();
    SET duration_seconds = TIMESTAMPDIFF(SECOND, start_time, end_time);

    -- ============================================
    -- FINAL SUCCESS MESSAGE
    -- ============================================

    SELECT CONCAT(
        '= | ',
        'SILVER LAYER LOAD COMPLETED SUCCESSFULLY | ',
        'CRM Tables Loaded: crm_cust_info, crm_prd_info, crm_sales_details | ',
        'ERP Tables Loaded: erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2 | ',
        'Total Duration: ', duration_seconds, ' seconds | ',
        'Completed At: ', end_time
    ) AS message;

END $$

DELIMITER ;

CALL silver.load_layer();

