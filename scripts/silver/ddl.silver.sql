/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/



**************************************************
----------------------------------------------
----------------------------------------------
---------BUILDING THE SILVER LAYER -----------
*****************************************************
1)crm_customer table
DROP TABLE IF EXISTS silver.crm_customer_info;

CREATE TABLE silver.crm_customer_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
	dwh_create_date timestamp default current_timestamp
);

select *from silver.crm_customer_info;
------------------------------------------------------
------------------------------------------------------
-- 2) PRODUCT TABLE

DROP TABLE IF EXISTS silver.crm_prd_info;
RAISE NOTICE 'dropping table: silver.crm_prd_info';

CREATE TABLE silver.crm_prd_info (
    prd_id INT,
	cat_id varchar(40),
    prd_key VARCHAR(40),
    prd_nm VARCHAR(40),
    prd_cost INT,
    prd_line VARCHAR(40),
    prd_start_dt DATE,
    prd_end_dt DATE,
	dwh_create_date timestamp default current_timestamp

);

--------------------------------------------------------
--------------------------------------------------------
-- 3) SALES TABLE

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(40),
    sls_prd_key VARCHAR(40),
    sls_cust_id INT,
    sls_order_dt date ,
    sls_ship_dt date,
    sls_due_dt date,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
	dwh_create_date timestamp default current_timestamp

);

----------------------------------------------------------
----------------------------------------------------------
-- 4) ERP CUSTOMER

DROP TABLE IF EXISTS silver.erp_cust_a2z;

CREATE TABLE silver.erp_cust_a2z (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(40),
	dwh_create_date timestamp default current_timestamp

);

----------------------------------------------------------
----------------------------------------------------------
-- 5) ERP LOCATION

DROP TABLE IF EXISTS silver.erp_loca101;

CREATE TABLE silver.erp_loca101 (
    cid VARCHAR(40),
    cntry VARCHAR(40),
	dwh_create_date timestamp default current_timestamp

);

----------------------------------------------------------
----------------------------------------------------------
-- 6) ERP PRODUCT CATEGORY

DROP TABLE IF EXISTS silver.erp_px_cat_gv12;

CREATE TABLE silver.erp_px_cat_gv12 (
    id VARCHAR(40),
    cat VARCHAR(40),
    subcat VARCHAR(40),
    maintenance VARCHAR(40),
	dwh_create_date timestamp default current_timestamp

);
