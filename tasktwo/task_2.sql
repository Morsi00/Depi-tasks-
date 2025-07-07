use store
go 


--1:List all products with list price greater than 1000

select product_name, list_price from production.products

where list_price > 1000
order by list_price

--2:Get customers from "CA" or "NY" states

select  customer_id ,first_name,state from sales.customers

 where state in('ca','ny')

 --3:Retrieve all orders placed in 2023

 select order_id,order_date from sales.orders

 where  order_date between '2023-1-1' and '2023-12-31'
 order by order_date

--4:Show customers whose emails end with @gmail.com

select customer_id, email from sales.customers
where email like '%@gmail%'

--5:Show all inactive staff

select staff_id, active from sales.staffs
where active = 1

--6:List top 5 most expensive products

select top 5 product_id,list_price  from production.products
order by  list_price desc

--7:Show latest 10 orders sorted by date
select top 10 order_id ,order_date from sales.orders

order by order_date asc

--8:Retrieve the first 3 customers alphabetically by last name

select top 3 customer_id,last_name from sales.customers
order by last_name

--9:Find customers who did not provide a phone number
select  customer_id,phone from sales.customers

where phone is NULL

--10:Show all staff who have a manager assigned
select staff_id ,manager_id from sales.staffs
where manager_id is not null

--11:Count number of products in each category

select category_id,COUNT(*) as number_products
from production.products
group by category_id
order by category_id

--12:Count number of customers in each state
select state,COUNT(*) as number_state
from sales.customers
group by state
order by state

--13:Get average list price of products per brand

select brand_id ,AVG(list_price) as averge_list_price
from production.products
group by brand_id

--14:Show number of orders per staff
select staff_id ,count(*) as number_orderes
from sales.orders
group by staff_id

--15:Find customers who made more than 2 orders
select customer_id, count(*)as  order_count
from sales.orders
group by customer_id
Having count(*)>2

--16:Products priced between 500 and 1500
select product_id,list_price  from production.products
where list_price between '500'and '1500'
order by list_price 

--17:Customers in cities starting with "S"
select customer_id,city from sales.customers
where city like 's%'

--18:Orders with order_status either 2 or 4
select order_id,order_status  from sales.orders
where order_status in (2,4)

--19:Products from category_id IN (1, 2, 3)
select product_id,category_id from production.products
where category_id in (1,2,3)

--20:Staff working in store_id = 1 OR without phone number
select staff_id,store_id,phone from sales.staffs
where store_id=1 or  phone IS NULL
