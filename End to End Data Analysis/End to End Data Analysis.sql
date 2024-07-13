-- Create New DataBase
CREATE DATABASE EDA;

-- Use DataBase
Use EDA;

SELECT * 
FROM df_orders

DROP TABLE df_orders

CREATE TABLE df_orders (
	   [order_id] int primary key
      ,[order_date] date
      ,[ship_mode] varchar(20)
      ,[segment] varchar(20)
      ,[country] varchar(20)
      ,[city] varchar(20)
      ,[state] varchar(20)
      ,[postal_code] varchar(20)
      ,[region] varchar(20)
      ,[category] varchar(20)
      ,[sub_category] varchar(20)
      ,[product_id] varchar(50)
	  ,[quantity] int
      ,[discount] decimal (7,2)
      ,[sale_price] decimal (7,2) 
      ,[profit] decimal (7,2))

SELECT * FROM df_orders

-- Five top 10 highest revenue genarating products:
Select TOP 10 product_id,SUM(sale_price) as sales
FROM df_orders
GROUP By product_id
ORDER BY sales DESC

-- Five top 5 highest selling products in each region:
WITH cte as (
Select region, product_id,SUM(sale_price) as sales
FROM df_orders
GROUP By region,product_id)
SELECT * FROM (
SELECT *	
, ROW_NUMBER() OVER(PARTITION By region ORDER BY sales DESC) as rn
FROM cte) A
WHERE rn<=5

-- Find month over growth comparision for 2022 and 2023 sales eg: jan 2002 vs jan 2023
WITH cte as (
SELECT YEAR(order_date) as order_year,MONTH(order_date) as order_month,
SUM (sale_price) as sales
FROM df_orders
GROUP BY YEAR(order_date),MONTH(order_date)
)
SELECT order_month,
SUM (CASE WHEN order_year=2022 Then sales else 0 end) as sales_2022,
SUM (CASE WHEN order_year=2023 Then sales else 0 end) as sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month 

-- For each category which month had highest sales
WITH cte as (
SELECT category,FORMAT(order_date,'yyyyMM') as order_year_month,
SUM (sale_price) as sales
FROM df_orders
GROUP BY category,FORMAT(order_date,'yyyyMM')
)
SELECT *
FROM (
SELECT *, ROW_NUMBER () OVER (PARTITION BY category ORDER BY sales DESC) as rn
FROM cte ) a
WHERE rn=1

-- Which sub category had highest growth by profit in 2023 compare to 2022

WITH cte as (
SELECT sub_category, YEAR(order_date) as order_year,
SUM (sale_price) as sales
FROM df_orders
GROUP BY sub_category, YEAR(order_date)
),
cte2 as (
SELECT sub_category,
SUM (CASE WHEN order_year=2022 Then sales else 0 end) as sales_2022,
SUM (CASE WHEN order_year=2023 Then sales else 0 end) as sales_2023
FROM cte
GROUP BY sub_category)

SELECT Top 1 * ,
(sales_2023-sales_2022)*100/sales_2022
FROM cte2
ORDER BY (sales_2023-sales_2022)*100/sales_2022 DESC