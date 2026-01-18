/* --------------------------------------------------
    QUALITY CHECKS
  ---------------------------------------------------
SCRIPT PURPOSE:
  This script perfoms quality checks to validate the integrity,consistency and accuracy of gold layer.
   --uniqueness of surogate keys
   --refrential integrity b/w fact and dimesnion tables
   -- validation of relationships in the data model 
we are here validating the data and checking if any nulls are there in the final step after creating views even
*/
--CHECKING FOR DUPLICATE KEYS IF ANY 
select ci.cst_id,count(*)
from silver.crm_customer_info as ci
left join silver.erp_cust_a2z as ca 
ON ci.cst_key=ca.cid
left join silver.erp_loca101 lo
on ci.cst_key=lo.cid 
group by  ci.cst_id having count(*)>1;

--CHECK DATA INTEGRATION (WE HAVE 2 GENDER FROM 2 TABLES ..)
select distinct  ci.cst_gndr,ca.gen,
case when  ci.cst_gndr != 'n/a' then ci.cst_gndr
else coalesce(ca.gen,'n/a')
end as new_gen

from silver.crm_customer_info as ci
left join silver.erp_cust_a2z as ca 
ON ci.cst_key=ca.cid
left join silver.erp_loca101 lo
on ci.cst_key=lo.cid 
order by 1,2

--detecting any males,females are not available for customers 
select distinct 
case when  ci.cst_gndr != 'n/a' then ci.cst_gndr
else coalesce(ca.gen,'n/a')
end as new_gen
from silver.crm_customer_info as ci
left join silver.erp_cust_a2z as ca 
ON ci.cst_key=ca.cid
left join silver.erp_loca101 lo
on ci.cst_key=lo.cid 


------------------
-----------------------
--NOW CHECK FROM GOLD LAYER (ALL DUPLICTAES,ANY NULL,SPACES )

select * from gold.dim_customers;

select distinct gender from gold.dim_customers;


------------------------------
----------------------------
****CREATING FACT TABLE...*******  

/*JOINING FACT AND DIMESION TABLE WITH SUURGOGATE KEYS THAT
WE HAVE CREATED IN THE DIM TABLES*/

select * from silver.crm_sales_details;
------------------------------------------
*************************************************
--BUILDING THE FACT TABLES OF SALES DETIALS
*************************************************

select * from gold.fact_sales
where customer_key is null

select *from gold.dim_customers
select * from gold.dim_products
alter  view gold.dim_prdouct rename  to dim_products


 --CHECKING IF ANY NULL VALES ON GOLD LAYER 

--FOREIGN KEY INTEGRITY

 select * from gold.fact_sales as f
 left join gold.dim_customers as c
 ON c.customer_key=f.customer_key
 left join gold.dim_products as p
 on p.product_key=f.product_key 
 where p.product_key is null



