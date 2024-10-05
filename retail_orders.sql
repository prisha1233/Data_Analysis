SELECT * FROM master.retail_orders;

##find top 10 highest reveue generating products 
### in order to write query i need perform some data exploration task 
## if product id unique or not 
## if yes, then i can sort sale price in descending order and return 1st 10 rows
## if not, then i need aggregrate data by products id, then i can sort sale price in descending order and return 1st 10 rows
select count( distinct product_id)
from master. retail_orders; 
### product_id not unique. 
select product_id, round(sum(sale_price*quantity),2) as sale
from master.retail_orders
group by product_id
order by sale desc
limit 10
;


##find top 5 highest selling products in each region
with cte1 as (
select region, product_id, sum(quantity) as total_sale, 
row_number() over (partition by region order by sum(quantity) desc) as record_number
from master.retail_orders
group by region, product_id
order by region, total_sale desc )
select region, product_id,total_sale as top_5_highest_selling_Products
from cte1
where record_number <= 5;


##find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with sales_2022 as (
select (DATE_FORMAT(order_date,'%m')) as t_date, round(SUM(sale_price),2) as total_sale_2022
from master.retail_orders
where order_date <= '2022-12-31'and order_date >= '2022-01-01'
group by t_date),
sales_2023 as (
select (DATE_FORMAT(order_date,'%m')) as t_date,round(SUM(sale_price*quantity),2)as total_sale_2023
from master.retail_orders
where order_date <= '2023-12-31' and order_date >= '2023-01-01'
group by t_date)
select s1.t_date, total_sale_2022, total_sale_2023
from  sales_2022 s1 
				inner join sales_2023 s2 on s1.t_date = s2.t_date
order by s1.t_date
;

##for each category which month had highest sales 
with cte1 as (
select category, date_format(order_date, '%M') as monthnum, round(sum(sale_price*quantity),2) as total_sale
from master.retail_orders
group by category, monthnum
order by category, total_sale desc),
cte2 as (
select *, 
rank() over (partition by category order by total_sale desc) as category_sale_rank
from cte1)
select category, monthnum, total_sale
from cte2
where category_sale_rank = 1
; 

##which sub category had highest growth by profit in 2023 compare to 2022
with profit_sub_category_2022 as (
select  sub_category, round(SUM(profit*quantity),2) as total_profit_2022
from master.retail_orders
where order_date <= '2022-12-31'and order_date >= '2022-01-01'
group by sub_category),
profit_sub_category_2023 as (
select sub_category,round(SUM(profit*quantity),2)as total_profit_2023
from master.retail_orders
where order_date <= '2023-12-31' and order_date >= '2023-01-01'
group by sub_category),
cte3 as (
select c1.sub_category, total_profit_2022, total_profit_2023, total_profit_2023-total_profit_2022 as difference
from  profit_sub_category_2022 c1 inner join profit_sub_category_2023 c2 on c1.sub_category = c2.sub_category
where  total_profit_2023 >  total_profit_2022
order by difference desc
)
select sub_category, difference as highest_profit_2023_by_sub_category
from cte3
limit 1
;