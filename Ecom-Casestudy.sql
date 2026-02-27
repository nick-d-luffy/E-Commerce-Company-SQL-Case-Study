create database ecommerce;

use ecommerce;

-- describe the tables

describe customers;
describe order_details;
describe orders;
describe products;

-- return top 3 locations 

select location, count(*) as number_Of_Customers from customers
group by location
order by number_Of_customers desc
limit 3;

-- Csutomer segment by order

select * from orders;

select NumberOfOrders, count(*) as CustomerCount from
(select customer_Id, count(*) as NumberOfOrders from orders
group by customer_Id) as t
group by NumberOfOrders
order by numberoforders;

-- Identify products where the average purchase quantity per order is 2 
-- but with a high total revenue, suggesting premium product trends.

select * from order_details;

select Product_Id, avg(quantity) as AvgQuantity, sum(quantity * price_per_unit) as TotalRevenue
from order_details
group by product_Id
having AvgQuantity =2
order by TotalRevenue desc;


-- For each product category, calculate the unique number of customers purchasing from it. 
-- This will help understand which categories have wider appeal across the customer base.

select * from products;
select * from order_details;
select* from orders;

select a.category, count(distinct c.customer_id) as unique_customers from products a
inner join order_details b
on a.product_id = b.product_Id
inner join orders c
on b.order_id = c.order_Id
group by a.category
order by unique_customers desc;

-- Cte

with customer_category as 
(select a.category, c.customer_id from products a
inner join order_details b
on a.product_id = b.product_id
inner join orders c
on b.order_id = c.order_Id)
select category, count(distinct customer_id) as unique_customers from customer_category
group by category
order by unique_customers desc;

-- Analyze the month-on-month percentage change in total sales to identify growth trends.

select * from orders;

update orders
set order_date = str_to_date(order_date,'%Y-%m-%d');

alter table orders
modify column order_date date;

describe orders;

select Month, TotalSales, concat(round((totalsales-previousmonth)/previousmonth *100,2),'%') 
as PercentChange from
(select date_format(order_date,'%Y-%m') as Month, sum(total_amount) as TotalSales,
lag(sum(total_amount)) over(order by date_format(order_date,'%Y-%m')) as Previousmonth from orders
group by date_format(order_date,'%Y-%m')) as t
order by month;

-- Examine how the average order value changes month-on-month. Insights can guide pricing and promotional 
-- strategies to enhance order value.

select * from orders;

select Month, AvgAmount, round((AvgAmount-prev_month),2) as ChangeinValue from
(select date_format(order_date, '%Y-%m') as Month, round(avg(total_amount),2) as AvgAmount,
lag(avg(total_amount)) over(order by date_format(order_date, '%Y-%m')) as prev_month from orders
group by date_format(order_date, '%Y-%m')) as t
order by changeinvalue desc;

-- Based on sales data, identify products with the fastest turnover rates, 
-- suggesting high demand and the need for frequent restocking.

select * from order_details;

select product_id, count(*) as SalesFrequency from order_details
group by product_Id
order by SalesFrequency desc
limit 5;

-- List products purchased by less than 40% of the customer base, indicating potential mismatches
-- between inventory and customer interest.

select * from products;
select * from orders;
select * from order_details;
select * from customers;

select a.product_id, a.name, count(distinct c.customer_id) as UniqueCustomerCount
from products a
inner join order_details b
on a.product_Id = b.product_id 
inner join orders c
on b.order_id = c.order_id
inner join customers d
on c.customer_id = d.customer_id
group by a.product_id, a.name
having uniquecustomercount <(select count(*) from customers)*0.40;

-- Evaluate the month-on-month growth rate in the customer base to 
-- understand the effectiveness of marketing campaigns and market expansion efforts.

select * from orders;

with total_customers as
(select customer_id, min(order_date) as PurchaseMonth from orders
group by customer_id)
select date_format(purchasemonth,'%Y-%m') as FirstPurchaseMonth, count(*) as TotalNewCsutomers from total_customers
group by date_format(purchasemonth,'%Y-%m')
order by FirstPurchaseMonth;

-- Identify the months with the highest sales volume, 
-- aiding in planning for stock levels, marketing efforts, and staffing in 
-- anticipation of peak demand periods

select date_format(order_date, '%Y-%m') as Month, sum(total_amount) as TotalSales from orders
group by date_format(order_date, '%Y-%m')
order by totalsales desc
limit 3;











