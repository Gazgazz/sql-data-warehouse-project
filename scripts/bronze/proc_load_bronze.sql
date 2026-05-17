
/*
===============================================================
Stored Procedure: Load Bronze Layer
===============================================================
Script Purpose
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions
    - Truncates the bronze table before loading data
    - Uses the LOAD DATA LOCAL INFILE command to load data from CSV files using MySQL

===============================================================
DELIMITER $$

CREATE PROCEDURE bronze_stored_proceduress()
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
            'BRONZE LAYER LOAD FAILED | ',
            'Error Code: ', error_code, ' | ',
            'Error Message: ', error_message
        ) AS message;

    END;

    -- ============================================
    -- START TIMER
    -- ============================================

    SET start_time = NOW();

    -- ============================================
    -- LOAD CRM CUSTOMER INFO
    -- ============================================

    SET @sql1 = "
    LOAD DATA LOCAL INFILE 'C:/Users/gazel/OneDrive/Desktop/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
    INTO TABLE bronze.crm_cust_info
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    ";

    PREPARE stmt1 FROM @sql1;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    -- ============================================
    -- LOAD CRM PRODUCT INFO
    -- ============================================

    SET @sql2 = "
    LOAD DATA LOCAL INFILE 'C:/Users/gazel/OneDrive/Desktop/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
    INTO TABLE bronze.crm_prdt_info
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    ";

    PREPARE stmt2 FROM @sql2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    -- ============================================
    -- LOAD CRM SALES DETAILS
    -- ============================================

    SET @sql3 = "
    LOAD DATA LOCAL INFILE 'C:/Users/gazel/OneDrive/Desktop/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
    INTO TABLE bronze.crm_sales_details
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    ";

    PREPARE stmt3 FROM @sql3;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;

    -- ============================================
    -- LOAD ERP CUSTOMER TABLE
    -- ============================================

    SET @sql4 = "
    LOAD DATA LOCAL INFILE 'C:/Users/gazel/OneDrive/Desktop/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
    INTO TABLE bronze.erp_cust_az12
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    ";

    PREPARE stmt4 FROM @sql4;
    EXECUTE stmt4;
    DEALLOCATE PREPARE stmt4;

    -- ============================================
    -- LOAD ERP LOCATION TABLE
    -- ============================================

    SET @sql5 = "
    LOAD DATA LOCAL INFILE 'C:/Users/gazel/OneDrive/Desktop/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
    INTO TABLE bronze.erp_loc_a101
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    ";

    PREPARE stmt5 FROM @sql5;
    EXECUTE stmt5;
    DEALLOCATE PREPARE stmt5;

    -- ============================================
    -- LOAD ERP PRODUCT CATEGORY TABLE
    -- ============================================

    SET @sql6 = "
    LOAD DATA LOCAL INFILE 'C:/Users/gazel/OneDrive/Desktop/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
    INTO TABLE bronze.erp_px_cat_g1v2
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    ";

    PREPARE stmt6 FROM @sql6;
    EXECUTE stmt6;
    DEALLOCATE PREPARE stmt6;

    -- ============================================
    -- END TIMER
    -- ============================================

    SET end_time = NOW();

    SET duration_seconds =
        TIMESTAMPDIFF(SECOND, start_time, end_time);

    -- ============================================
    -- FINAL SINGLE MESSAGE
    -- ============================================

    SELECT CONCAT(
        '================================================== | ',
        'BRONZE LAYER LOAD COMPLETED SUCCESSFULLY | ',
        'CRM Tables Loaded: crm_cust_in fo, crm_prdt_info, crm_sales_details | ',
        'ERP Tables Loaded: erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2 | ',
        'Total Duration: ', duration_seconds, ' seconds | ',
        'Completed At: ', end_time
    ) AS message;

END $$

DELIMITER ;

CALL bronze_stored_proceduress();
CALL bronze_stored_procedures();

SET GLOBAL local_infile = 1;
