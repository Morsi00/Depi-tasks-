use store
go 

-- 1. Count the total number of products in the database.

select count(product_id) as 'total number of products' from production.products

-- 2. Find the average, minimum, and maximum price of all products.

select 
AVG(list_price) as average ,
MIN(list_price) as 'min price ',
MAX(list_price) as 'max price '
from production.products

--3. Count how many products are in each category.

select category_id ,count (*) from production.products
group by category_id

--4. Find the total number of orders for each store.
select store_id ,count(*) from [sales].[orders]
group by store_id

--5. Show customer first names in UPPERCASE and last names in lowercase for the first 10 customers.
 select top 10 UPPER(first_name)+ ' ' + LOWER(last_name) as name 
 from sales.customers

--6. Get the length of each product name. Show product name and its length for the first 10 products.
select top 10 product_name, LEN(product_name) from [production].[products]


--7. Format customer phone numbers to show only the area code (first 3 digits) for customers 1-15.
select customer_id, phone, left(phone,3) as 'area code'
from [sales].[customers]
where customer_id between 1 and 15 

--8. Show the current date and extract the year and month from order dates for orders 1-10.

select GETDATE(),order_date,YEAR(order_date), MONTH(order_date) 
from [sales].[orders]

--9. Join products with their categories. Show product name and category name for first 10 products.
select top 10  product_name, category_name  
from production.products P  inner join production.categories c
on P.category_id=c.category_id

--10. Join customers with their orders. Show customer name and order date for first 10 orders.

select top 10 c.first_name, o.order_date
from sales.customers c inner join sales.orders o
on o.customer_id =c.customer_id

--11. Show all products with their brand names, even if some products don't have brands. Include product name, brand name (show 'No Brand' if null).
 select p.product_name ,B.brand_name 
 from production.products P  left join production.brands B
 on B.brand_id=P.brand_id
--12. Find products that cost more than the average product price. Show product name and price.
select product_name ,list_price from production.products
where list_price > (
select AVG(list_price) 
from production.products)

--13. Find customers who have placed at least one order. Use a subquery with IN. Show customer_id and customer_name.

select customer_id , first_name + ' ' +last_name as name 
from sales.customers
where customer_id in (
select customer_id  
from sales.orders 

group by customer_id
having COUNT(*) >0

)

--14. For each customer, show their name and total number of orders using a subquery in the SELECT clause.
SELECT
    c.first_name + ' ' + c.last_name as customer_name,
    (SELECT count(*) FROM sales.orders o WHERE o.customer_id = c.customer_id
   ) as order_count
FROM sales.customers c 



--15. Create a simple view called easy_product_list that shows product name, category name, and price. Then write a query to select all products from this view where price > 100.
Create view easy_product_list
as (
select p.product_name ,c.category_name , p.list_price from production.products p inner join  production.categories c
on p.category_id=c.category_id
)
select * from easy_product_list
where list_price > 100.

--16. Create a view called customer_info that shows customer ID, full name (first + last), email, and city and state combined. Then use this view to find all customers from California (CA).
create view customer_info 
as
(
select customer_id ,first_name +' ' + last_name as fullname , email ,city + ' '+ state as address
from  sales.customers 
)
select * from customer_info
where address like '%ca'

--17. Find all products that cost between $50 and $200. Show product name and price, ordered by price from lowest to highest.
select product_name ,list_price  from production.products
where list_price between 50 and 200
order by list_price

--18. Count how many customers live in each state. Show state and customer count, ordered by count from highest to lowest.
select  state ,count(*) as  'customer count' 
from sales.customers
group by state
order by 'customer count' desc

--19. Find the most expensive product in each category. Show category name, product name, and price.
SELECT 
  c.category_name,
  p.product_name,
  p.list_price
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
WHERE p.list_price = (
  SELECT MAX(p2.list_price)
  FROM production.products p2
  WHERE p2.category_id = p.category_id
);

SELECT 
tablemax.category_id,  c.category_name,
  p.product_name,
  p.list_price
FROM 
(select p.category_id,MAX(p.list_price)as maxprice
from production.products p
group by p.category_id)  as tablemax
JOIN production.categories c ON c.category_id = tablemax.category_id
join production.products p on p.category_id  =tablemax.category_id
  AND p.list_price = tablemax.maxprice

--20. Show all stores and their cities, including the total number of orders from each store. Show store name, city, and order count 
SELECT 
  s.store_name,
  s.city,
  COUNT(o.order_id) AS order_count
FROM sales.stores s
LEFT JOIN sales.orders o ON s.store_id = o.store_id
GROUP BY s.store_name, s.city;
