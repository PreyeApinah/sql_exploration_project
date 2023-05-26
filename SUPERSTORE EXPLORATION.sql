-- top 3 most ordered products
SELECT TOP 3 product_name,
COUNT(product_id) AS ordercount 
FROM SuperStoreSDB.dbo.orders
GROUP BY product_name
ORDER BY 2 DESC

--least 5 performing products in terms of quantity sold
SELECT TOP 5 product_name,
SUM(Quantity) QuantitySold
FROM SuperStoreSDB.dbo.orders
GROUP BY Product_Name
ORDER BY 2 

--city with highest number of orders sold
SELECT TOP 1 city,product_name,COUNT(Order_ID) OrderCount
FROM SuperStoreSDB.dbo.orders
GROUP BY Product_Name,city
ORDER BY 3 DESC

--most ordered produts by city
WITH product_city_order AS 
(SELECT product_name, city, COUNT(product_id) AS ordercount 
FROM SuperStoreSDB.dbo.orders
GROUP BY city,Product_Name)

SELECT product_name,city,max(ordercount)
FROM product_city_order
GROUP BY city,product_name
ORDER BY 3 DESC


-- customer with highest number of recuuring orders
SELECT TOP 1 customer_name,
COUNT(Order_ID) reccurringorders
FROM SuperStoreSDB.dbo.orders
GROUP BY Customer_Name
ORDER BY 2 DESC 


--top 3 most patronizing customers
SELECT TOP 3 customer_name,
COUNT(Order_ID) reccurringorders
FROM SuperStoreSDB.dbo.orders
GROUP BY Customer_Name
ORDER BY 2 DESC


--which segment generated most profit
SELECT TOP 1 segment, 
ROUND(SUM(profit),0)
FROM SuperStoreSDB.dbo.orders
GROUP BY Segment
ORDER BY 2 DESC


--average days to ship from day order
SELECT AVG(DAY(Ship_Date)-DAY(order_date)) AS daystoshipping
FROM SuperStoreSDB.dbo.orders 

--maximum days to shipping
SELECT MAX(DAY(Ship_Date)-DAY(order_date)) AS daystoshipping
FROM SuperStoreSDB.dbo.orders 



-- how many orders that were shipped same day as order date
SELECT COUNT(order_id) AS samedayshippingcount
FROM SuperStoreSDB.dbo.orders 
 WHERE ship_Date  = order_date

--category generating highest sales in dollars
SELECT TOP 1 category,
CONCAT('$', ROUND(SUM(sales),0)) AS categorysales
FROM SuperStoreSDB.dbo.orders
GROUP BY Category
ORDER BY 2 DESC

--category with highest profit
SELECT TOP 1 category,
ROUND(SUM(profit),0) AS categorysales
FROM SuperStoreSDB.dbo.orders
GROUP BY Category
ORDER BY 2 DESC


--product with highest sales of all time
 WITH Total_Sales AS
                 (SELECT product_name, 
                 ROUND(SUM(sales),0) AS totalsales
                 FROM SuperStoreSDB.dbo.orders
                GROUP BY product_name)
SELECT  TOP 1 product_name,
MAX(totalsales) Max_total_sales
FROM Total_Sales
GROUP BY product_name
ORDER BY 2 DESC

--product with highest profit of all time
 WITH product_profit AS 
					(SELECT product_name, 
					ROUND(SUM(profit),0) totalprofit
					FROM SuperStoreSDB.dbo.orders
					GROUP BY product_name
					)
SELECT TOP 1 product_name, 
MAX(totalprofit) max_profit 
FROM product_profit
GROUP BY product_name
ORDER BY 2  DESC

--products with most returned orders
SELECT TOP 1 o.product_name,
COUNT(r.order_id)
FROM SuperStoreSDB.dbo.orders o
JOIN SuperStoreSDB.dbo.returns r
ON o.Order_ID = r.order_id
WHERE r.returned LIKE '%yes%'
GROUP BY o.product_name 
ORDER BY 2 DESC

--customers and number of orders by newest date
WITH newest_orders AS
                 (SELECT order_date,customer_name,
				 product_name,
                 RANK() OVER ( PARTITION BY customer_name ORDER BY order_date DESC) dayrank
                 FROM SuperStoreSDB.dbo.orders)
SELECT order_date,
customer_name,
COUNT(product_name) AS product_order_count
FROM newest_orders
WHERE dayrank = 1
GROUP BY order_date,customer_name
ORDER BY 1 DESC


-- top 3 highest grossing products within each category in 2015 as million dollars
WITH total_sales_2015 AS (
        SELECT category,product_name,
		CONCAT( '$', ROUND(SUM(sales),0), 'MILLION') AS totalsales
        FROM SuperStoreSDB.dbo.orders 
        WHERE YEAR(order_date) = '2015'
        GROUP BY category,Product_Name),
        totalsales AS( 
		SELECT *,
		RANK() OVER ( 
        PARTITION BY category 
       ORDER BY totalsales DESC) AS ranking
        FROM total_sales_2015)
SELECT category,
Product_Name,
totalsales
FROM totalsales
WHERE ranking <= 2
ORDER BY category,ranking DESC


