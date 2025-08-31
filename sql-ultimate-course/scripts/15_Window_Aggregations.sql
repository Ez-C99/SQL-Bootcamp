/* ==============================================================================
   SQL Window Aggregate Functions
-------------------------------------------------------------------------------
   These functions allow you to perform aggregate calculations over a set 
   of rows without the need for complex subqueries. They enable you to compute 
   counts, sums, averages, minimums, and maximums while still retaining access 
   to individual row details.

   Table of Contents:
    1. COUNT
    2. SUM
    3. AVG
    4. MAX / MIN
    5. ROLLING SUM & AVERAGE Use Case
===============================================================================
*/

SET search_path TO mydatabase, sales, public;

/* COUNT */
SELECT OrderID, OrderDate, CustomerID,
       COUNT(*) OVER() AS TotalOrders,
       COUNT(*) OVER(PARTITION BY CustomerID) AS OrdersByCustomers
FROM Sales.Orders;

SELECT *,
       COUNT(*)  OVER () AS TotalCustomersStar,
       COUNT(1)  OVER () AS TotalCustomersOne,
       COUNT(Score)   OVER () AS TotalScores,
       COUNT(Country) OVER () AS TotalCountries
FROM Sales.Customers;

/* Duplicates in OrdersArchive (by OrderID) */
SELECT *
FROM (
  SELECT *, COUNT(*) OVER(PARTITION BY OrderID) AS CheckDuplicates
  FROM Sales.OrdersArchive
) t
WHERE CheckDuplicates > 1;

/* SUM */
SELECT OrderID, OrderDate, Sales, ProductID,
       SUM(Sales) OVER () AS TotalSales,
       SUM(Sales) OVER (PARTITION BY ProductID) AS SalesByProduct
FROM Sales.Orders;

SELECT OrderID, ProductID, Sales,
       SUM(Sales) OVER () AS TotalSales,
       ROUND( (Sales::numeric / NULLIF(SUM(Sales) OVER (),0)) * 100, 2) AS PercentageOfTotal
FROM Sales.Orders;

/* AVG */
SELECT OrderID, OrderDate, Sales, ProductID,
       AVG(Sales) OVER () AS AvgSales,
       AVG(Sales) OVER (PARTITION BY ProductID) AS AvgSalesByProduct
FROM Sales.Orders;

SELECT CustomerID, LastName, Score,
       COALESCE(Score, 0) AS CustomerScore,
       AVG(Score) OVER () AS AvgScore,
       AVG(COALESCE(Score, 0)) OVER () AS AvgScoreWithoutNull
FROM Sales.Customers;

SELECT *
FROM (
  SELECT OrderID, ProductID, Sales,
         AVG(Sales) OVER () AS Avg_Sales
  FROM Sales.Orders
) t
WHERE Sales > Avg_Sales;

/* MIN / MAX windows */
SELECT MIN(Sales) AS MinSales, MAX(Sales) AS MaxSales FROM Sales.Orders;

SELECT OrderID, ProductID, OrderDate, Sales,
       MIN(Sales) OVER () AS LowestSales,
       MIN(Sales) OVER (PARTITION BY ProductID) AS LowestSalesByProduct
FROM Sales.Orders;

SELECT *
FROM (
  SELECT *, MAX(Salary) OVER() AS HighestSalary
  FROM Sales.Employees
) t
WHERE Salary = HighestSalary;

SELECT OrderID, OrderDate, ProductID, Sales,
       MAX(Sales) OVER () AS HighestSales,
       MIN(Sales) OVER () AS LowestSales,
       Sales - MIN(Sales) OVER ()        AS DeviationFromMin,
       MAX(Sales) OVER () - Sales        AS DeviationFromMax
FROM Sales.Orders;

/* Rolling averages */
SELECT OrderID, ProductID, OrderDate, Sales,
       AVG(Sales) OVER (PARTITION BY ProductID) AS AvgByProduct,
       AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate) AS MovingAvg
FROM Sales.Orders;

SELECT OrderID, ProductID, OrderDate, Sales,
       AVG(Sales) OVER (PARTITION BY ProductID ORDER BY OrderDate
                        ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS RollingAvg
FROM Sales.Orders;
