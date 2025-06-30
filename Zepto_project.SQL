create database zepto;

drop table if exists zepto_v2;

CREATE TABLE zepto_v2 (
    sku_id INT IDENTITY(1,1) PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discountPercent DECIMAL(5,2),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(8,2),
    weightInGms INT,
    outOfStock BIT,
    quantity INT
);
use zepto;

Select * from [dbo].[zepto_v2]
-- add column SKU_id
alter table zepto_v2
add sku_id INT IDENTITY(1,1) PRIMARY KEY
--total_rows
select count(1) from zepto_v2

--Null values

SELECT * FROM zepto_v2
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

----Data Explore

--Different category

Select distinct(Category) from zepto_v2 order by Category 

--check stack vs outof stack

Select outOfStock,count(sku_id) from zepto_v2
group by outOfStock


--the product present multiple time and amount greater than 1000

Select name,count(*) as total_count,sum(discountedSellingPrice) as amount from zepto_v2 
group by name having count(*) >1 and sum(discountedSellingPrice)  >1000 order by total_count desc

--data cleaning


--find the mrp column any value 0
select * from zepto_v2 where mrp=0


delete from zepto_v2 where mrp=0
--convert paise to Rupees

update zepto_v2
set mrp=mrp/100.0,discountedSellingPrice=discountedSellingPrice/100.0;

Select mrp,discountedSellingPrice from zepto_v2

-- forgot run multiple time update query casuse mrp every product 0
IF OBJECT_ID('dbo.zepto_v2', 'U') IS NOT NULL
BEGIN
    TRUNCATE TABLE dbo.zepto_v2;
END
-- prevent the data use TCL

BEGIN TRANSACTION;

UPDATE zepto_v2
SET 
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

COMMIT;

-------------------------------------------------------------------------------------

----data analysis


-- Q1. Find the top 10 best-value products based on the discount percentage.

select  distinct name,mrp,discountPercent from zepto_v2 order by discountPercent Desc 

--Q2.What are the Products with High MRP but Out of Stock

select distinct name,mrp from zepto_v2 
where outOfStock = 1 and mrp >300
order by mrp desc


--Q3.Calculate Estimated Revenue for each category
Select Category,sum(discountedSellingPrice*availableQuantity) as Total_Revenue from zepto_v2
group by Category
order by Total_Revenue


-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.

select distinct name,mrp,discountPercent from zepto_v2 where mrp >500 and discountPercent <10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.

	select top 5 Category,avg(discountPercent) as avg_discount from zepto_v2
	group by Category
	order by avg_discount


-- Q6. Find the price per gram for products above 100g and sort by best value.


SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto_v2
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--Q7.Group the products into categories like Low, Medium, Bulk.

SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto_v2;



--Q8.What is the Total Inventory Weight Per Category 

SELECT 
    category,
    SUM(CAST(weightInGms AS BIGINT) * CAST(availableQuantity AS BIGINT)) AS total_weight
FROM zepto_v2
GROUP BY category
ORDER BY total_weight;
