-- ============================================================
-- Creating the Database for the ecommerce analysis
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_analysis;
USE ecommerce_analysis;

-- ------------------------------------------------------------
-- CUSTOMERS TABLE 
-- ------------------------------------------------------------
DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers (
    CustomerID      BIGINT PRIMARY KEY,
    CustomerAge     INT,
    CustomerGender  VARCHAR(10)
);

-- ------------------------------------------------------------
-- ORDERS TABLE 
-- ------------------------------------------------------------
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    OrderID           BIGINT PRIMARY KEY,
    OrderDate         DATE,
    DeliveryDate      DATE,
    CustomerID        BIGINT,
    Location          VARCHAR(50),
    Zone              VARCHAR(20),
    DeliveryType      VARCHAR(30),
    ProductCategory   VARCHAR(50),
    SubCategory       VARCHAR(50),
    Product           VARCHAR(255),
    UnitPrice         DECIMAL(10,2),
    ShippingFee       DECIMAL(10,2),
    OrderQuantity     INT,
    SalePrice         DECIMAL(10,2),
    Status            VARCHAR(20),
    Reason            VARCHAR(255),
    Rating            INT,
    CONSTRAINT fk_customer
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- ------------------------------------------------------------
-- VERIFYING THE LOAD
-- ------------------------------------------------------------

SELECT * FROM Customers;
SELECT COUNT(*) AS CustomerRowCount FROM Customers;

SELECT * FROM Orders;
SELECT COUNT(*) AS OrderRowCount FROM Orders;          

-- -------------------------------------------------------------
-- 14. Identify the top 5 most valuable customers using a composite score that combines three key metrics
-- Total Revenue (50%), Order Frequency (30%) and Average Order Value (20%)
-- -------------------------------------------------------------

SELECT 
	CustomerID,
    SUM(SalePrice) AS TotalRevenue,
    COUNT(CustomerID) AS Order_Frequency,
    AVG(SalePrice) AS Average_Order_Value,
    (
		(SUM(SalePrice) * 0.5) + 
        (Count(CustomerID) * 0.3) +
        (AVG(SalePrice) * 0.2)
	) AS Composite_Score
    FROM Orders
    GROUP BY CustomerID
    ORDER BY Composite_Score DESC
    LIMIT 5;
    
-- -------------------------------------------------------------
-- 15. Calculate the month-over-month growth rate in total revenue across the entire dataset. (SQL)
-- -------------------------------------------------------------

WITH MonthlyRevenue AS (
    SELECT 
		DATE_FORMAT(OrderDate, '%Y-%m') AS Order_month,
		SUM(SalePrice) AS TotalRevenue
	FROM Orders
	GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
),
PreviousMonth AS (
	SELECT 
		Order_month,
        TotalRevenue,
        LAG(TotalRevenue) OVER(ORDER BY Order_month) AS PrevMonthRevenue
	FROM MonthlyRevenue
)
SELECT 
	Order_month,
    TotalRevenue,
    PrevMonthRevenue,
    ROUND(
		(TotalRevenue - PrevMonthRevenue) * 100 / NULLIF(PrevMonthRevenue, 0),
        2
	) AS MOM_Growth_Percent
FROM PreviousMonth
ORDER BY Order_month;

-- -------------------------------------------------------------
-- 16. Calculate the rolling 3-month average revenue for each product category. (SQL)
-- -------------------------------------------------------------

WITH Category_Revenue AS (
	SELECT 
		ProductCategory,
        DATE_FORMAT(OrderDate, '%Y-%m') AS Order_Month,
        SUM(SalePrice) AS Monthly_Revenue
	FROM Orders
    WHERE ProductCategory <> ""
    GROUP BY ProductCategory,
        DATE_FORMAT(OrderDate, '%Y-%m')
)
SELECT 
	ProductCategory,
    Order_Month,
    Monthly_Revenue,
    ROUND(
		AVG(Monthly_Revenue) OVER(
			PARTITION BY ProductCategory
            ORDER BY Order_MOnth
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
	) AS Rolling_3_Month_Avg
FROM Category_Revenue
ORDER BY ProductCategory, Order_Month;

-- -------------------------------------------------------------
-- 17. Update the orders table to apply a 15% discount on the `Sale Price` 
-- 		for orders placed by customers who have made at least 10 orders. (SQL)
-- -------------------------------------------------------------

UPDATE Orders o
JOIN (
	SELECT 
		CustomerID,
        COUNT(OrderID) AS Order_Count
	FROM Orders
    GROUP BY CustomerID
    HAVING COUNT(OrderID) >= 10
) AS FC
	ON o.CustomerID = FC.CustomerID
SET o.SalePrice = 0.85 * o.SalePrice; 

-- -------------------------------------------------------------
-- 18. Calculate the average number of days between consecutive orders for 
-- 		customers who have placed at least five orders. (SQL)
-- -------------------------------------------------------------

WITH OrderGap AS (
	SELECT 
		CustomerID,
		OrderID,
        OrderDate,
        LAG(OrderDate) OVER(
			PARTITION BY CustomerID
            ORDER BY OrderDate
		) AS PreviousOrderDate
	FROM Orders
),
CustomerCount AS (
	SELECT 
		CustomerID,
        COUNT(OrderID) AS Total_Orders
	FROM Orders
    GROUP BY CustomerID
    HAVING COUNT(OrderID) >= 5
)
SELECT 
	o.CustomerID,
    AVG(DATEDIFF(o.OrderDate, o.PreviousOrderDate)) AS Avg_days
FROM OrderGap o 
INNER JOIN CustomerCount c 
	ON o.CustomerID = c.CustomerID
WHERE o.PreviousOrderDAte IS NOT NULL 
GROUP BY o.CustomerID
ORDER BY Avg_days;

-- -------------------------------------------------------------
-- 19. Identify customers who have generated revenue that is more than 30% higher than the average revenue per customer. (SQL)
-- -------------------------------------------------------------

WITH CustomerRevenue AS (
	SELECT 
		CustomerID,
        SUM(SalePrice) AS TotalRevenue
	FROM Orders
    GROUP BY CustomerID
),
Avg_Revenue AS (
	SELECT AVG(TotalRevenue) AS Avg_Revenue_per_Customer
    FROM CustomerRevenue
)
SELECT 
	c.CustomerID,
    c.TotalRevenue,
    a.Avg_Revenue_per_Customer,
    ROUND(
		(c.TotalRevenue - a.Avg_Revenue_per_Customer) * 100 /
			a.Avg_Revenue_per_Customer,
		2
	) AS Percent_Above_AVG
FROM CustomerRevenue c 
CROSS JOIN Avg_Revenue a
WHERE c.TotalRevenue > a.Avg_Revenue_per_Customer * 1.30
ORDER BY c.TotalRevenue DESC;

-- -------------------------------------------------------------
-- 20. Determine the top 3 product categories that have shown the highest 
-- 		increase in sales over the past year compared to the previous year. (SQL)
-- -------------------------------------------------------------

WITH YearlyRevenue AS (
	SELECT 
		ProductCategory,
        YEAR(OrderDate) AS OrderYear,
        SUM(SalePrice) AS TotalRevenue
	FROM Orders
    WHERE YEAR(OrderDate) IN (2020,2019)
    GROUP BY ProductCategory, YEAR(OrderDate)
),
Revenue AS (
	SELECT 
		ProductCategory,
        SUM(CASE WHEN OrderYear = 2020 THEN TotalRevenue ELSE 0 END) AS Year_2020_Revenue,
        SUM(CASE WHEN OrderYear = 2019 THEN TotalRevenue ELSE 0 END) AS Year_2019_Revenue
	FROM YearlyRevenue
    GROUP BY ProductCategory
)
SELECT 
	ProductCategory,
    Year_2020_Revenue,
    Year_2019_Revenue,
    ROUND((Year_2020_Revenue - Year_2019_Revenue), 2) AS IncreasedRevenue,
    ROUND((Year_2020_Revenue - Year_2019_Revenue) *100 / 
		NULLIF(Year_2019_Revenue,0), 2
	) AS Growth_Percent
FROM Revenue
ORDER BY IncreasedRevenue DESC
LIMIT 3;