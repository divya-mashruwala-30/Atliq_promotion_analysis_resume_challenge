
select * from fact_events_new
select * from dim_products
select * from dim_stores
select * from dim_campaigns
alter table fact_events_new modify event_id varchar(10)
alter table fact_events_new modify store_id varchar(10)
alter table fact_events_new modify campaign_id varchar(20)
alter table fact_events_new modify product_code varchar(10)
alter table fact_events_new modify base_price int
alter table fact_events_new modify promo_type varchar(50)
alter table fact_events_new modify quantity_sold_before_promo int
alter table fact_events_new modify quantity_sold_after_promo int

-----------------------------------------------------------------------------------------------------------

-- Question 1 :- List of products which have base price greater than 500 & have promo feature of BOGOF.

select distinct f.product_code,product_name
from fact_events_new f join dim_products p
on f.product_code = p.product_code 
where (base_price > 500) and (promo_type='BOGOF')

-- Question 2 :- generate a report that provides the number of stores in each city. Allowing us to identify the number of stores presence in each city. The order wil be in descending order as per the store counts.

select city, count(*) as Total_stores from dim_stores
group by city
order by Total_stores desc

select * from fact_events_final
-- Question 3:- Generate a report with campaign , its total revenue before and after the promo.

select c.campaign_name, 
concat(round(sum(base_price*quantity_sold_before_promo)/1000000,2),' ','M')  as total_revenue_before_promo,
concat(round(sum(promotion_price*quantity_sold_after_promo_final)/1000000,2),' ','M')  as total_revenue_after_promo
from fact_events_final f join dim_campaigns c
on f.campaign_id = c.campaign_id
group by c.campaign_name

-- Question 4:-Generate a report to calculate incremental sold quantity percentage (ISU%) per each category during diwali campaign.

with category_revenue as (select p.category, sum(f.quantity_sold_before_promo) as total_quantity_before_promo, 
sum(f.quantity_sold_after_promo_final) as total_quantity_after_promo
from fact_events_final f join dim_campaigns c
on f.campaign_id = c.campaign_id
join dim_products p
on f.product_code = p.product_code
where c.campaign_name='Diwali'
group by p.category),
category_revenue_isu as (
select *, (round((total_quantity_after_promo - total_quantity_before_promo) * 100/ total_quantity_before_promo,2)) as ISU_percentage
from category_revenue),
category_revenue_isu_rnk as (
select *, dense_rank() over (order by ISU_percentage desc ) as rnk
from category_revenue_isu)
select category,ISU_percentage,rnk from category_revenue_isu_rnk


-- Question 5:- Generate a report with top 5 products, ranked by incremental revenue %. Report should have product name ,category & IR%.
with IR_percentage_by_product as (select distinct product_name,category,
round((sum(total_revenue_after_promo) - sum(total_revenue_before_promo))*100/sum(total_revenue_before_promo),2) as IR_percentage
from fact_events_final_with_revenue f join dim_products p
on f.product_code = p.product_code
group by product_name,category),
IR_percentage_by_product_rnk as (
select product_name, category, IR_percentage, dense_rank() over(order by IR_percentage desc) as rnk
from IR_percentage_by_product),
IR_percentage_top_5 as (
select * from IR_percentage_by_product_rnk
where rnk<=5)
select * from IR_percentage_top_5











