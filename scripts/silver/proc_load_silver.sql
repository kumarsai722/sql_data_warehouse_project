
/*===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    create procedure silver()
     language plpgsql
      as $$
      begin
      --bodu of preocdure
      end;
       $$;


    call Silver.load_silver();
========
------------------------------------------------------------------------
***********************************************************************
--creating silver layer by removing all duplicates,nulls 

*******************************************************************
----------------------------------------------------------------------   */

CREATE or replace PROCEDURE silver.load_silver()
language plpgsql
as $$ 
begin 

	RAISE NOTICE '-------------------------------------------';
	RAISE NOTICE'LOADING INTO SILVER LAYER';
	RAISE NOTICE '-------------------------------------------';

	RAISE NOTICE 'TRUNCATING TABLE:silver.crm_customer_info';
	TRUNCATE TABLE silver.crm_customer_info;
	RAISE NOTICE 'INSERTING DATA INTO :silver.crm_customer_info';
	
	INSERT INTO silver.crm_customer_info(cst_id,cst_key,
	cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
	select cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
	case when trim(upper(cst_marital_status)) ='M' then 'Married'
		when trim(upper(cst_marital_status)) ='S' then 'Single'
		else 'n/a'
	end as cst_marital_status,
	case when trim(upper(cst_gndr)) ='M' then 'Male'
		when trim(upper(cst_gndr)) ='F' then 'Female'
		else 'n/a'
	end as cst_gndr,
	cst_create_date
	from (select *,
	row_number() over(partition by cst_id order by cst_create_date desc)as flag_last
	from bronze.crm_customer_info where cst_id is not null)t
	where t.flag_last=1;
	
	
	/*select *from silver.crm_customer_info where cst_gndr = 'n/a';
	
	--****CHEKING FOR UNWANTED SPACES IN NAMES FF
	select cst_firstname,cst_lastname from silver.crm_customer_info
	where cst_firstname !=trim(cst_firstname) or 
	cst_lastname!=trim(cst_lastname) ;
	
	select distinct(cst_marital_status) from silver.crm_customer_info;
	select distinct(cst_gndr) from silver.crm_customer_info;
	*/
	
	/* *****************************************************************************************************
	-------------------------------------------------------
	**CRM_PRODUCT_TABLE ***** FINDING DUPLICATES NULLS AND INSETING INTO SILVER 
	------------------------------------------------------ */
	
	RAISE NOTICE 'TRUNCATING TABLE:silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	RAISE NOTICE 'INSERTING DATA INTO :silver.crm_prd_info';
	--select * from bronze.crm_prd_info;
	
	
	--CHEKING DUPLICATE P_KEY VALES I.E prd_id 
	/*select prd_id,count(*) from silver.crm_prd_info group by prd_id
	having count(*)>1 or prd_id is null;
	
	select prd_key,count(*) from bronze.crm_prd_info group by prd_key
	having count(*)>1 or prd_key is null;
	
	select prd_cost from silver.crm_prd_info
	where prd_cost<0 or prd_cost is null;
	
	select distinct(prd_line) from  silver.crm_prd_info;
	
	select *from silver.crm_prd_info where prd_nm !=trim(prd_nm)
	
	
	select * from silver.crm_prd_info 
	where prd_start_dt<prd_end_dt;
	
	select prd_cost from bronze.crm_prd_info  where prd_cost<0 or prd_cost is null; */
	
	/*-----------------------------------------------------
	------------------------------------------------------
	*************INSERTING DATA INTO SILVER LAYER**********
	______________________________________________________
	--------------------------------------------------------*/
	INSERT INTO silver.crm_prd_info(
	prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt
	)
	select 
	prd_id,
	replace(substring(prd_key,1,5),'-','_')as cat_id,
	substring(prd_key from 7 for length(prd_key)) as prd_key,
	prd_nm,
	coalesce(prd_cost,0)as prd_cost,
	
	case when upper(trim(prd_line))='M' then 'Mountain'
		when upper(trim(prd_line))='S' then 'Other Sales'
		when upper(trim(prd_line))='R' then 'Road'
		when upper(trim(prd_line))='T' then 'Touring'
		else 'n/a'
	end as prd_line,
	 prd_start_dt,
	lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)-1 as prd_end_dt
	from bronze.crm_prd_info;
	
	
	--select *from silver.crm_prd_info
	
	--select * from bronze.crm_sales_details;
	
	/*--------------------------------------------------
	*****crm_sales_details*********
	______________________________________*/
	
	RAISE NOTICE 'TRUNCATING TABLE:silver:crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	RAISE NOTICE 'silver.crm_sales_details';
	--select *from bronze.crm_sales_details;
	
	
	INSERT INTO silver.crm_sales_details(sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price)
	select sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	case when sls_order_dt=0 or length(sls_order_dt::text)!=8 then null
		else
		TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
		end AS sls_order_dt,
	case when sls_ship_dt =0 or length(sls_ship_dt::text)!=8 then null
		else 
		TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
		end AS sls_ship_dt,
	
	case when sls_due_dt=0 or length(sls_due_dt::text)!=8 then null
		else
		TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
	end AS sls_due_dt,
	case when sls_sales is null or sls_sales <=0 or sls_sales !=sls_quantity*abs(sls_price)
		then sls_quantity*abs(sls_price)
		else sls_sales
		end as sls_sales,
	sls_quantity,
	case when sls_price is null or sls_price<=0 then sls_price/coalesce(sls_quantity,0)
	else sls_price
	end as sls_price
	from bronze.crm_sales_details;
	
	/*select * from silver.crm_sales_details;
	
	select distinct(sls_cust_id) from bronze.crm_sales_details;*/
	
	
	/*----------------------------------------------------
		   ******ERP_CUST_A2Z TABLAE ********
	_____________________________________________________*/
	
	
	RAISE NOTICE 'TRUNCATING TABLE:silver.erp_cust_a2z';
	TRUNCATE TABLE silver.erp_cust_a2z;
	RAISE NOTICE 'silver.erp_cust_a2z';
	
	
	/*select * from bronze.erp_cust_a2z where cid like '%AW00011000%';
	
	select cid,count(*) from bronze.erp_cust_a2z 
	group by cid having count(*)>1;
	
	select * from silver.crm_customer_info;
	
	select * from bronze.erp_cust_a2z where cid like 'AW%'*/
	
	
	--INSERTING INTO THE SILVER LAYER 
	INSERT INTO silver.erp_cust_a2z
	select 
	case when cid like 'NAS%' then substring(cid,4,length(cid))
		else cid
	end as cid,
	
	case when bdate >current_timestamp then null
		else bdate 
	end as b_date,
	case when upper(trim(gen)) in ('M','MALE') THEN 'Male'
		when upper(trim(gen)) in ('F','FEMALE') THEN 'Female'
		ELSE 'n/a'
	end as gen_new
	from bronze.erp_cust_a2z ;
	
	--select distinct(gen) from silver.erp_cust_a2z
	--select *from silver.erp_cust_a2z where bdate<'1930-01-01' or bdate>current_timestamp
	
	/*-----------------------------------------------------------------
	********ERP_LOC101____TABLE****************
	_________________________________________________________________*/
	
	
	RAISE NOTICE 'TRUNCATING TABLE:silver.erp_loca101';
	TRUNCATE TABLE silver.erp_loca101;
	RAISE NOTICE 'silver.erp_loca101';
	
	/*select *from bronze.erp_loca101;
	select * from silver.crm_customer_info;
	
	select cid,count(*) from bronze.erp_loca101
	group by cid having count(*)=1
	
	select *from bronze.erp_loca101 where cid like 'AW%'
	*/
	
	INSERT INTO silver.erp_loca101(cid,cntry)
	select
	case when cid like 'AW%' then replace(cid,'-','')
	else cid
	end as cid,
	case when trim(cntry) ='DE' then 'Germany'
		when trim(cntry) in('US','USA') then 'United States'
		when trim(cntry)='' or cntry is null then 'n/a'
		else trim(cntry)
	end as cntry
	from bronze.erp_loca101;
	
	
	--select distinct(cntry) from silver.erp_loca101 order by cntry asc
	
	--select * from silver.erp_loca101
	
	/*  ------------------------------------------------------
		********ERP_PX_CAT_GV12 TABLE************
	________________________________________________________
	*/
	
	RAISE NOTICE 'TRUNCATING TABLE:silver.erp_px_cat_gv12';
	TRUNCATE TABLE silver.erp_px_cat_gv12;
	RAISE NOTICE 'silver.erp_px_cat_gv12';
	
	
	/*select *from bronze.erp_px_cat_gv12
	select *from silver.crm_prd_info
	
	select id,count(*) from bronze.erp_px_cat_gv12
	group by id order by id
	
	select *from bronze.erp_px_cat_gv12
	
	select subcat from bronze.erp_px_cat_gv12 where maintenance!=trim(maintenance)
	select distinct(subcat) from bronze.erp_px_cat_gv12
	select distinct(maintenance) from bronze.erp_px_cat_gv12*/
	
	--INSERING DATA INTO SILVER LAYER FROMbronze.erp_px_cat_gv12 TABLE 
	
	INSERT INTO silver.erp_px_cat_gv12
	select id,
	cat,
	subcat,
	maintenance 
	from  bronze.erp_px_cat_gv12;
	
	RAISE NOTICE'-------------------------------';
	RAISE NOTICE'LOADING OF SILVER LAYER COMPLTED';
	RAISE NOTICE'-------------------------------';
	RAISE INFO 'PROCEDURE CREATED :silver.load_silver';
	
	--select * from silver.erp_px_cat_gv12
end
$$;

call silver.load_silver();    


