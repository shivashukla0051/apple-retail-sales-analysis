
Use apple_retail;
SELECT * FROM category;

SELECT * FROM products;

SELECT * FROM stores;

SELECT * FROM sales;

SELECT * FROM warranty;
-- EDA
SELECT DISTINCT repair_status
FROM warranty;

SELECT COUNT(*)
FROM sales;
-- IMPROVING QUERY PERFORMANCE
-- et-64 ms 
-- pt- 0.15ms
explain analyze
select * from sales
where product_id='P-44'
explain analyze 
select * from sales
where store_id='ST-31';
CREATE INDEX idx_sales_store      ON sales(store_id);
CREATE INDEX idx_sales_product    ON sales(product_id);
CREATE INDEX idx_sales_date       ON sales(sale_date);
CREATE INDEX idx_warranty_sale    ON warranty(sale_id);
CREATE INDEX idx_warranty_status  ON warranty(repair_status);
CREATE INDEX idx_products_cat     ON products(category_id);
-- Business problems
-- 1 Find the number of stores in each country
select * from store;
Select country,count(store_id)from stores group by country;
-- 2. Calculate the total number of units sold by each store.
select * from sales;
select sum(quantity)as total_sold,store_id from sales group by store_id;
-- 3. Identify how many sales occurred in December 2023.
SELECT COUNT(*)
FROM sales
WHERE sale_date BETWEEN '2023-12-01' AND '2023-12-31';
-- 4. Determine how many stores have never had a warranty claim filed.
select count(*) from stores where store_id not in (select distinct store_id  from sales s right join warranty w on s.sale_id=w.sale_id);
-- 5. Calculate the percentage of warranty claims marked as "Warranty Void".
select 
count( claim_id)/
(select count(*) from warranty)*100
from warranty where repair_status='Warranty Void';
-- 6. Identify which store had the highest total units sold in the last year.
SELECT 
    s.store_id, st.store_name, SUM(quantity) AS total_units
FROM
    sales s
        JOIN
    stores st ON s.store_id = st.store_id
WHERE
    s.sale_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY s.store_id , st.store_name
ORDER BY total_units DESC
LIMIT 1;
-- 7. Count the number of unique products sold in the last year.
select count(Distinct product_id) as u_pro from sales WHERE
    sale_date BETWEEN '2022-01-01' AND '2022-12-31';
-- 8. Find the average price of products in each category.
select c.category_name, avg(price),c.category_id from category c join products p on c.category_id=p.category_id group by category_id order by avg(price) desc;
-- 9. How many warranty claims were filed in 2020?
select count(*) from warranty where claim_date between '2020-01-01' and '2020-12-31';
 -- 10. For each store, identify the best-selling day based on highest quantity sold.
with daily_sales as ( select s.sale_date, s. store_id, sum(quantity)as total_qty from sales s  group by sale_date,store_id )
select sale_date,store_id,total_qty from (
select sale_date,store_id,total_qty, row_number() over(partition by store_id order by total_qty desc) as rn from daily_sales)t where rn=1;
 -- 11.Identify the least selling product in each country for each year based on total units sold.
 -- with yearly_sales as( select s.product_id, s.sale_date, st.country, s.sum(quantity) as total_units from sales s join stores st on s.store_id=st.store_id  group by total_units,country)
--  select sale_date,store_id,total_units,country from(
--  select sale_date,store_id,total_units,row_number() over(partition by  year(sale_date) order by total_units desc) as rn from yearly_sales)t where rn=min(rn);
with product_rank as(
select st.country, year(s.sale_date) as year ,sum(s.quantity) as total_qty_sold,p.product_name,
rank() over(partition by st.country order by sum(s.quantity) ) as rank_num
from 
sales s
join stores st on s.store_id=st.store_id 
join products p on
s.product_id= p.product_id
group by st.country, year(s.sale_date),p.product_name
 )
select * from product_rank where rank_num=1
-- 12. Calculate how many warranty claims were filed within 180 days of a product sale.
select count(claim_id)
from 
 warranty w
 join sales s on
s.sale_id=w.sale_id
where datediff(w.claim_date,s.sale_date)<=180 ;
-- 13.Determine how many warranty claims were filed for products launched in the last two years.
select count(*)
from 
warranty w  join sales s on 
w.sale_id=s.sale_id
join products p on 
s.product_id=p.product_id
where datediff((select max(sale_date) from sales),p.launch_date)<730;
-- 14. List the months in the last three years where sales exceeded 5,000 units in the USA.
select year(sale_date)as sale_year,
month(sale_date) as sale_month,
sum(s.quantity) as total_units
from sales s 
join stores st on
s.store_id = st.store_id       
where st.country='USA'
AND datediff('2023-03-31',sale_date)<=1095
group by 
year(s.sale_date),
month(s.sale_date)
having sum(s.quantity)>5000
order by 
sale_year,
sale_month;
-- 15. Identify the product category with the most warranty claims filed in the last two years.
select c.category_id, count(w.claim_id) as total_claims, category_name
from sales s 
join warranty w on 
s.sale_id=w.sale_id
join products p on
s.product_id=p.product_id
join category c on
p.category_id=c.category_id
where datediff('2023-03-31',w.claim_date)<=730
group by category_id
order by total_claims desc
 limit 1;
 -- 16. Determine the percentage chance of receiving warranty claims after each purchase for each country.
select count(distinct s.sale_id),count(distinct w.claim_id),st.country,
(count(distinct w.claim_id)*100/ count(distinct s.sale_id))as percen_rank
from sales s 
left join warranty w on
s.sale_id=w.sale_id
join stores st on 
s.store_id=st.store_id
group by st.country
order by percen_rank desc;
-- 17.Analyze the year-by-year growth ratio for each store.
with growth as (
select store_id,sum(quantity) as total_sales,year(sale_date)as sale_year,
lag(sum(quantity)) over(partition by store_id order by  year(sale_date))as prev_sales
from sales
group by store_id, sale_year
order by store_id,sale_year)
select * ,
((prev_sales-total_sales) *100/total_sales) as growth
from growth;
-- 18. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
select count(claim_id),price,
case 
when p.price<500 then 'BUDGET'
WHEN 500<P.PRICE<1500 THEN 'MID RANGE'
WHEN 1500<P.PRICE<10000 THEN 'EXPENSIVE'
END AS PRICE_SEGMENT
from sales s 
join products p on
s.product_id=p.product_id
join warranty w on
s.sale_id=w.sale_id
where datediff('2023-03-31',s.sale_date)<=1825

group by price
-- 19.Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.

select count(w.claim_id),sum((case when w.repair_status='Paid Repaired' then 1 else 0 end)*100.0)/count(w.claim_id)as repair_percentage,s.store_id
from sales s 
join stores st on 
s.store_id=st.store_id
join warranty w on 
s.sale_id=w.sale_id
group by s.store_id
order by repair_percentage desc limit 1 ;
-- 20.Write a query to calculate the monthly running total of sales for each store over
--  the past four years and compare trends during this period.
with tempcte as(
select store_id,year(sale_date)as sale_year,month(sale_date)as sale_month,sum(quantity) as monthly_sales
from sales s 
where datediff('2023-03-31',sale_date)<=1460
group by store_id,month(sale_date),year(sale_date)
)
select store_id,sale_year,sale_month,
sum(monthly_sales) over(partition by store_id order by sale_year,sale_month)as running_total
from tempcte
order by store_id,sale_year,sale_month;
-- 21.Analyze product sales trends over time, segmented into key periods:
 -- from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
 select product_name, sum(s.quantity)as total_sales,
 case 
 when datediff(s.sale_date,p.launch_date) between 0 and 180 then'0-6 months'
 when datediff(s.sale_date,p.launch_date) between 180 and 365 then'6-12 months'
 when datediff(s.sale_date,p.launch_date) between 365 and 548 then'12-18 months'
 when datediff(s.sale_date,p.launch_date)>548 then'beyond 18 months'
 end as  period
 from sales s 
 join products p on
 s.product_id=p.product_id
 group by product_name,period
 order by product_name,period








 
    
    





