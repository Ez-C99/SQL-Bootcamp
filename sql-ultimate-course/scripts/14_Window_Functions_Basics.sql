/* ==============================================================================
   SQL Window Functions
-------------------------------------------------------------------------------
   SQL window functions enable advanced calculations across sets of rows 
   related to the current row without resorting to complex subqueries or joins.
   This script demonstrates the fundamentals and key clauses of window functions,
   including the OVER, PARTITION, ORDER, and FRAME clauses, as well as common rules 
   and a GROUP BY use case.

   Table of Contents:
     1. SQL Window Basics
     2. SQL Window OVER Clause
     3. SQL Window PARTITION Clause
     4. SQL Window ORDER Clause
     5. SQL Window FRAME Clause
     6. SQL Window Rules
     7. SQL Window with GROUP BY
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* Basics */
SELECT SUM(Sales) AS Total_Sales FROM Sales.Orders;

SELECT ProductID, SUM(Sales) AS Total_Sales
FROM Sales.Orders
GROUP BY ProductID;

/* OVER */
SELECT OrderID, OrderDate, ProductID, Sales,
       SUM(Sales) OVER () AS Total_Sales
FROM Sales.Orders;

/* PARTITION */
SELECT OrderID, OrderDate, ProductID, Sales,
       SUM(Sales) OVER () AS Total_Sales,
       SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product
FROM Sales.Orders;

SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
       SUM(Sales) OVER () AS Total_Sales,
       SUM(Sales) OVER (PARTITION BY ProductID) AS Sales_By_Product,
       SUM(Sales) OVER (PARTITION BY ProductID, OrderStatus) AS Sales_By_Product_Status
FROM Sales.Orders;

/* ORDER (ranking) */
SELECT OrderID, OrderDate, Sales,
       RANK() OVER (ORDER BY Sales DESC) AS Rank_Sales
FROM Sales.Orders;

/* FRAMEs */
SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
       SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
                        ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS Total_Sales
FROM Sales.Orders;

SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
       SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
                        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Total_Sales
FROM Sales.Orders;

SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
       SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
                        ROWS 2 PRECEDING) AS Total_Sales
FROM Sales.Orders;

SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
       SUM(Sales) OVER (PARTITION BY OrderStatus ORDER BY OrderDate
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Total_Sales
FROM Sales.Orders;

/* RULES (invalid examples kept as comments) */
-- Invalid in WHERE: use a subquery instead
-- SELECT ..., SUM(Sales) OVER (PARTITION BY OrderStatus) FROM Sales.Orders
-- WHERE SUM(Sales) OVER (PARTITION BY OrderStatus) > 100;

-- Correct pattern:
SELECT *
FROM (
  SELECT OrderID, OrderDate, ProductID, OrderStatus, Sales,
         SUM(Sales) OVER (PARTITION BY OrderStatus) AS Total_Sales_By_Status
  FROM Sales.Orders
) s
WHERE Total_Sales_By_Status > 100;

-- Invalid: nested window functions
-- SELECT SUM(SUM(Sales) OVER (...)) OVER (...) FROM Sales.Orders;
