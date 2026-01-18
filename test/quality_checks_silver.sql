****************************************************
**DATA CLEANING AND CHECKING FOR NULL OR DUPLICATES IN P_KEY
--
select *from bronze.crm_customer_info; 

select cst_id,count(*) from silver.crm_customer_info group by cst_id
having count(*)>1 or cst_id is null ;

select *from bronze.crm_customer_info where cst_id=29466;


--**FINDIN DUPLICATES IN PRIMPARY KEY AND INSERTIN INTO SILVER LAYER ***************
--*********findind duplicates from brozne and finding nulls,spaces clearing by all them trim and case func()
--and inserting this data into silver layer*****---------------------

	select *from silver.crm_customer_info where cst_gndr = 'n/a';
	
	--****CHEKING FOR UNWANTED SPACES IN NAMES FF
	
  select cst_firstname,cst_lastname from silver.crm_customer_info
	where cst_firstname !=trim(cst_firstname) or 
	cst_lastname!=trim(cst_lastname) ;
	
	select distinct(cst_marital_status) from silver.crm_customer_info;
	select distinct(cst_gndr) from silver.crm_customer_info;
	
	
	/* *****************************************************************************************************
	-------------------------------------------------------
	**CRM_PRODUCT_TABLE ***** FINDING DUPLICATES NULLS AND INSETING INTO SILVER 
	------------------------------------------------------ */
	

	
	--CHEKING DUPLICATE P_KEY VALES I.E prd_id 
	select prd_id,count(*) from silver.crm_prd_info group by prd_id
	having count(*)>1 or prd_id is null;
	
	select prd_key,count(*) from bronze.crm_prd_info group by prd_key
	having count(*)>1 or prd_key is null;
	
	select prd_cost from silver.crm_prd_info
	where prd_cost<0 or prd_cost is null;
	
	select distinct(prd_line) from  silver.crm_prd_info;
	
	select *from silver.crm_prd_info where prd_nm !=trim(prd_nm)
	
	
	select * from silver.crm_prd_info 
	where prd_start_dt<prd_end_dt;
	
	select prd_cost from bronze.crm_prd_info  where prd_cost<0 or prd_cost is null; 
		/*-----------------------------------------------------
	------------------------------------------------------
	*************INSERTING DATA INTO SILVER LAYER**********
	______________________________________________________
	--------------------------------------------------------*/
select * from bronze.erp_cust_a2z where cid like '%AW00011000%';
	
	select cid,count(*) from bronze.erp_cust_a2z 
	group by cid having count(*)>1;
	
	select * from silver.crm_customer_info;
	
	select * from bronze.erp_cust_a2z where cid like 'AW%'
	
	

	
	--select distinct(gen) from silver.erp_cust_a2z
	--select *from silver.erp_cust_a2z where bdate<'1930-01-01' or bdate>current_timestamp
	
	/*-----------------------------------------------------------------
	********ERP_LOC101____TABLE****************
	_________________________________________________________________*/
	
	
;
	
	select *from bronze.erp_loca101;
	select * from silver.crm_customer_info;
	
	select cid,count(*) from bronze.erp_loca101
	group by cid having count(*)=1
	
	select *from bronze.erp_loca101 where cid like 'AW%'
	
	
	
	select distinct(cntry) from silver.erp_loca101 order by cntry asc
	
	select * from silver.erp_loca101
	
	/*  ------------------------------------------------------
		********ERP_PX_CAT_GV12 TABLE************
	________________________________________________________
	*/
	

	
	
	select *from bronze.erp_px_cat_gv12
	select *from silver.crm_prd_info
	
	select id,count(*) from bronze.erp_px_cat_gv12
	group by id order by id
	
	select *from bronze.erp_px_cat_gv12
	
	select subcat from bronze.erp_px_cat_gv12 where maintenance!=trim(maintenance)
	select distinct(subcat) from bronze.erp_px_cat_gv12
	select distinct(maintenance) from bronze.erp_px_cat_gv12
	
	--INSERING DATA INTO SILVER LAYER FROMbronze.erp_px_cat_gv12 TABLE 
	
