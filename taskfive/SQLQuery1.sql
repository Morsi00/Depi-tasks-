 /*Session 5 - Assignment
Assignment





8.Create a multi-CTE query for category analysis:

CTE 1: Calculate total revenue per category
CTE 2: Calculate average order value per category
Main query: Combine both CTEs
Use CASE to rate performance: >$50000 = "Excellent", >$20000 = "Good", else = "Needs Improvement"
9.Use CTEs to analyze monthly sales trends:

CTE 1: Calculate monthly sales totals
CTE 2: Add previous month comparison
Show growth percentage
10.Create a query that ranks products within each category:

Use ROW_NUMBER() to rank by price (highest first)
Use RANK() to handle ties
Use DENSE_RANK() for continuous ranking
Only show top 3 products per category
11.Rank customers by their total spending:

Calculate total spending per customer
Use RANK() for customer ranking
Use NTILE(5) to divide into 5 spending groups
Use CASE for tiers: 1="VIP", 2="Gold", 3="Silver", 4="Bronze", 5="Standard"
12.Create a comprehensive store performance ranking:

Rank stores by total revenue
Rank stores by number of orders
Use PERCENT_RANK() to show percentile performance
13.Create a PIVOT table showing product counts by category and brand:

Rows: Categories
Columns: Top 4 brands (Electra, Haro, Trek, Surly)
Values: Count of products
14.Create a PIVOT showing monthly sales revenue by store:

Rows: Store names
Columns: Months (Jan through Dec)
Values: Total revenue
Add a total column
15.PIVOT order statuses across stores:

Rows: Store names
Columns: Order statuses (Pending, Processing, Completed, Rejected)
Values: Count of orders
16.Create a PIVOT comparing sales across years:

Rows: Brand names
Columns: Years (2016, 2017, 2018)
Values: Total revenue
Include percentage growth calculations
17.Use UNION to combine different product availability statuses:

Query 1: In-stock products (quantity > 0)
Query 2: Out-of-stock products (quantity = 0 or NULL)
Query 3: Discontinued products (not in stocks table)
18.Use INTERSECT to find loyal customers:

Find customers who bought in both 2017 AND 2018
Show their purchase patterns
19.Use multiple set operators to analyze product distribution:

INTERSECT: Products available in all 3 stores
EXCEPT: Products available in store 1 but not in store 2
UNION: Combine above results with different labels
20.Complex set operations for customer retention:

Find customers who bought in 2016 but not in 2017 (lost customers)
Find customers who bought in 2017 but not in 2016 (new customers)
Find customers who bought in both years (retained customers)
Use UNION ALL to combine all three groups*/





use store
go 


/*1.Write a query that classifies all products into price categories:

Products under $300: "Economy"
Products $300-$999: "Standard"
Products $1000-$2499: "Premium"
Products $2500 and above: "Luxury"*/

select product_name,list_price,
case 
when list_price < 300 then 'Economy'
when list_price >= 300.000 and list_price <=999.999 then 'Standard'
when list_price >= 1000.00 and list_price <=2499.999 then 'Premium'
when list_price >= 2500  then 'Luxury'
end as list 
from production.products
order by list

--2_______________________________________________________
/*2.Create a query that shows order processing information with user-friendly status descriptions:

Status 1: "Order Received"
Status 2: "In Preparation"
Status 3: "Order Cancelled"
Status 4: "Order Delivered"
Also add a priority level:

Orders with status 1 older than 5 days: "URGENT"
Orders with status 2 older than 3 days: "HIGH"
All other orders: "NORMAL"*/


Select order_id,order_status ,
case 
when order_status = 1 then 'Order Received' 
when order_status = 2 then 'In Preparation' 
when order_status = 3 then 'Order Cancelled' 
when order_status = 4 then 'Order Delivered' 
 else 'no'
 end  as type_order
 ,
 case 
when order_status = 1 and DATEDIFF(DAY,order_date,GETDATE())>5  then 'urgent ' 
when order_status = 2 and DATEDIFF(DAY,order_date,GETDATE())>5  then 'HIGH'
else 'NULL'
end 
from sales.orders



/*3.Write a query that categorizes staff based on the number of orders they've handled:

0 orders: "New Staff"
1-10 orders: "Junior Staff"
11-25 orders: "Senior Staff"
26+ orders: "Expert Staff"*/



WITH count_table
AS
(
select staff_id,count (staff_id) as count 
from sales.orders
group by staff_id
)

select t.count ,t.staff_id  

,
case 
when  t.count =0 then 'New Staff'
when  t.count between 1 and 10 then 'Junior Staff'
when  t.count between 11 and 25 then 'Senior Staff'
when  t.count > 25 then 'Expert Staff'
end 

from count_table T

/*4.Create a query that handles missing customer contact information:

Use ISNULL to replace missing phone numbers with "Phone Not Available"
Use COALESCE to create a preferred_contact field (phone first, then email, then "No Contact Method")
Show complete customer information*/

select phone,email 
, ISNULL(phone,'Phone Not Available') as phone 
, coalesce(phone ,email,'No Contact Method')as preferred_contact
from sales.customers

/*5.Write a query that safely calculates price per unit in stock:

Use NULLIF to prevent division by zero when quantity is 0
Use ISNULL to show 0 when no stock exists
Include stock status using CASE WHEN
Only show products from store_id = 1*/


SELECT 
  p.product_id,
  p.product_name,
  s.store_id,
  s.quantity,
  p.list_price,
  
  -- حساب السعر لكل وحدة بشكل آمن
  ISNULL(p.list_price / NULLIF(s.quantity, 0), 0) AS price_per_unit,

  -- حالة المخزون
  CASE 
    WHEN s.quantity = 0 THEN 'Out of Stock'
    WHEN s.quantity <= 10 THEN 'Low Stock'
    ELSE 'In Stock'
  END AS stock_status

FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.store_id = 1;

/*6.Create a query that formats complete addresses safely:

Use COALESCE for each address component
Create a formatted_address field that combines all components
Handle missing ZIP codes gracefully*/
 Select * from sales.customers

 select zip_code,state,city,street , 
 coalesce(zip_code,' ')+',' +   coalesce(state,' ') +',' +  coalesce(city,' ')+ ',' + coalesce(street,' ') as formatted_address
 from sales.customers

 
/*
7- Use a CTE to find customers who have spent more than $1,500 total:

Create a CTE that calculates total spending per customer
Join with customer information
Show customer details and spending
Order by total_spent descending
*/

with total_spending as (
select o.customer_id , sum(oi.list_price) as "total_price" from sales.orders o join sales.order_items oi on o.order_id= oi.order_id
group by o.customer_id

)

select * from total_spending ts join sales.customers c on  ts.customer_id =c.customer_id
where ts.total_price >1500
order by ts.total_price desc


  /*
  8-Create a multi-CTE query for category analysis:

CTE 1: Calculate total revenue per category
CTE 2: Calculate average order value per category
Main query: Combine both CTEs
Use CASE to rate performance: >$50000 = "Excellent", >$20000 = "Good", else = "Needs Improvement"
*/
with calc_total_rev as (
select p.category_id,    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue from sales.order_items oi join production.products  p on oi.product_id = p.product_id
group by p.category_id
)
,average_order AS (
select p.category_id,    avg(oi.list_price) AS avg_price from sales.order_items oi join production.products  p on oi.product_id = p.product_id
group by p.category_id
)
select ctr.category_id ,ao.avg_price, ctr.total_revenue,
case 
when  ctr.total_revenue > 50000 then 'Excellent'
when ctr.total_revenue> 20000 then 'Good'
else 'Needs Improvement'
end as rate
from calc_total_rev ctr join average_order ao on ctr.category_id =ao.category_id

/*
9.Use CTEs to analyze monthly sales trends:

CTE 1: Calculate monthly sales totals
CTE 2: Add previous month comparison
Show growth percentage
*/

with monthly_sales_totals as(
select  year(o.order_date)as "years",MONTH(o.order_date) months,sum(oi.list_price) prisces ,month (dateadd(month,-1,o.order_date)) as newmonth
from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
group by year(order_date),MONTH(order_date) ,nullif(month (dateadd(month,-1,o.order_date)),0)
order by year(order_date),MONTH(order_date)
),prev_month as (
select nullif(month-1,0) , prisce from monthly_sales_totals
)
select * from prev_month


/*order by year(order_date),MONTH(order_date)*/

/*10.Create a query that ranks products within each category:

Use ROW_NUMBER() to rank by price (highest first)
Use RANK() to handle ties
Use DENSE_RANK() for continuous ranking
Only show top 3 products per category
*/

with rank_product as(
select  c.category_name,p.list_price,ROW_NUMBER() over (PARTITION BY p.category_id order by p.list_price) AS row_num ,
rank() over (partition by p.category_id order by p.list_price) as row_rank_num,
DENSE_RANK() over(partition by p.category_id order by p.list_price) as row_denseRanck
from production.products p join production.categories c on p.category_id= c.category_id
)
select * from rank_product rp where rp.row_num<=3 
/*
11.Rank customers by their total spending:

Calculate total spending per customer
Use RANK() for customer ranking
Use NTILE(5) to divide into 5 spending groups
Use CASE for tiers: 1="VIP", 2="Gold", 3="Silver", 4="Bronze", 5="Standard"
*/
with calc_total as(
select customer_id,sum(list_price) as prices,
rank() over(order by sum(list_price) desc) as ranks,
NTILE(5) over(order by sum(list_price) desc)as tiers 
from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
group by customer_id)
select *,
case tiers
when 1 then 'VIP'
when 2 then 'Gold'
when 3 then 'Silver'
when 4 then 'Bronze'
when 5 then 'Standard'
end as ran
from calc_total

/*
12.Create a comprehensive store performance ranking:

Rank stores by total revenue
Rank stores by number of orders
Use PERCENT_RANK() to show percentile performance
*/
with total_reve as
(
select o.store_id,sum (oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
from sales.orders o join sales.order_items oi on o.order_id=oi.order_id
group by o.store_id
), number_of_orders as
(
select store_id,COUNT(*) as numOfOrder from sales.orders
group by store_id
)
select tr.store_id,tr.total_revenue, o.numOfOrder,
rank() over(order by tr.total_revenue desc)as rankone,
rank() over(order by o.numOfOrder desc) as ranktwo
from total_reve tr join number_of_orders o on tr.store_id= o.store_id

/*
13.Create a PIVOT table showing product counts by category and brand:

Rows: Categories
Columns: Top 4 brands (Electra, Haro, Trek, Surly)
Values: Count of products
*/
select* from
(
SELECT 
        c.category_name,
        b.brand_name,
        p.product_id
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE b.brand_name IN ('Ralph Lauren', 'Hugo Boss', 'Calvin Klein', 'Nike')
    )t
    pivot(
    count(product_id)
    for brand_name in ([Ralph Lauren],[Hugo Boss],[Calvin Klein],[Nike])
    )   as PivotTable

    select * from production.categories










/*





20.Complex set operations for customer retention:

Find customers who bought in 2016 but not in 2017 (lost customers)
Find customers who bought in 2017 but not in 2016 (new customers)
Find customers who bought in both years (retained customers)
Use UNION ALL to combine all three groups
← All Courses
Back to Lecture →*/




/*
14.Create a PIVOT showing monthly sales revenue by store:

Rows: Store names
Columns: Months (Jan through Dec)
Values: Total revenue
Add a total column
*/
WITH monthly_revenue AS (
  SELECT 
    o.store_id,
    DATENAME(MONTH, o.order_date) AS month_name,
    SUM(oi.quantity * oi.list_price) AS revenue
  FROM sales.orders o
  JOIN sales.order_items oi ON o.order_id = oi.order_id
  GROUP BY o.store_id, DATENAME(MONTH, o.order_date)


  with mon_rev 
  as
  (
  select store_id ,MONTH(order_date)as month ,SUM(oi.quantity * oi.list_price) AS revenue
  from sales.order_items oi join sales.orders o
  on oi.order_id =o.order_id
  group by o.store_id,  MONTH(order_date)
  )

  select *
  from(
  select store_id ,month,revenue
  from mon_rev )as row_date
  
  PIVOT ( 
  sum ( revenue)
  for month IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12] )
 ) AS pivot_table;

 /*15.PIVOT order statuses across stores:

Rows: Store names
Columns: Order statuses (Pending, Processing, Completed, Rejected)
Values: Count of orders*/

select *  from (select  o.store_id ,o.order_status, o.order_id from 
sales.orders o

) t

pivot (
count (order_id)
for order_status in ([ 1 ],[ 2 ],[ 3 ],[ 4 ])
) as pivote

/*
16.Create a PIVOT comparing sales across years:

Rows: Brand names
Columns: Years (2016, 2017, 2018)
Values: Total revenue
Include percentage growth calculations*/

with years_rev 
  as
  (
  select   o.order_id,brand_id, YEAR(o.order_date) as years , oi.quantity * oi.list_price *(1-oi.discount) AS revenue
  from sales.order_items oi 
  join production.products p  on p.brand_id=oi.product_id
  join sales.orders o on o.order_id =oi.order_id
  
  )

  select *
  from(
  select brand_id  , years ,revenue
  from years_rev  )as row_date
  
  PIVOT ( 
  sum ( revenue)
  for years IN ( [2022],[2023],[2024] )
 ) AS pivot_table;

 /*17.Use UNION to combine different product availability statuses:

Query 1: In-stock products (quantity > 0)
Query 2: Out-of-stock products (quantity = 0 or NULL)
Query 3: Discontinued products (not in stocks table)*/


select 
    p.product_id,
    p.product_name,
    'in stock' as availability_status
from production.products p
join production.stocks s on p.product_id = s.product_id
where s.quantity > 0

union

select 
    p.product_id,
    p.product_name,
    'out of stock' as availability_status
from production.products p
join production.stocks s on p.product_id = s.product_id
where s.quantity = 0 or s.quantity is null

union

select 
    p.product_id,
    p.product_name,
    'discontinued' as availability_status
from production.products p
where p.product_id not in (
    select product_id from production.stocks
)


/*18.Use INTERSECT to find loyal customers:

Find customers who bought in both 2017 AND 2018
Show their purchase patterns*/

select customer_id from sales.orders
where YEAR(order_date) =2022
intersect 

select customer_id from sales.orders
where YEAR(order_date) =2023









/*
19.Use multiple set operators to analyze product distribution:


*/

--INTERSECT: Products available in all 3 stores
select  product_id from production.stocks
where store_id = 1 AND quantity > 0

INTERSECT

select  product_id from production.stocks
where store_id = 2 AND quantity > 0

INTERSECT

select  product_id from production.stocks
where store_id = 3 AND quantity > 0

--EXCEPT: Products available in store 1 but not in store 2
select  product_id from production.stocks
where store_id = 1 AND quantity > 0

EXCEPT

select  product_id from production.stocks
where store_id = 2 AND quantity > 0

/*--20  Complex set operations for customer retention:

--Find customers who bought in 2016 but not in 2017 (lost customers)
Find customers who bought in 2017 but not in 2016 (new customers)
Find customers who bought in both years (retained customers)
Use UNION ALL to combine all three groups*/
select 
    c.customer_id, 
    c.first_name + ' ' + c.last_name as customer_name,
    'lost' as status
from sales.customers c
where c.customer_id in (
    select customer_id from sales.orders where year(order_date) = 2016
    except
    select customer_id from sales.orders where year(order_date) = 2017
)

union all

select 
    c.customer_id, 
    c.first_name + ' ' + c.last_name as customer_name,
    'new' as status
from sales.customers c
where c.customer_id in (
    select customer_id from sales.orders where year(order_date) = 2017
    except
    select customer_id from sales.orders where year(order_date) = 2016
)

union all

select 
    c.customer_id, 
    c.first_name + ' ' + c.last_name as customer_name,
    'retained' as status
from sales.customers c
where c.customer_id in (
    select customer_id from sales.orders where year(order_date) = 2016
    intersect
    select customer_id from sales.orders where year(order_date) = 2017
)
