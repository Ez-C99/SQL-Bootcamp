/* ==============================================================================
   SQL Views
-------------------------------------------------------------------------------
   This script demonstrates various view use cases in SQL Server.
   It includes examples for creating, dropping, and modifying views, hiding
   query complexity, and implementing data security by controlling data access.

   Table of Contents:
     1. Create, Drop, Modify View
     2. USE CASE - HIDE COMPLEXITY
     3. USE CASE - DATA SECURITY
===============================================================================
*/

/* ==============================================================================
   CREATE, DROP, MODIFY VIEW
===============================================================================*/

/* TASK:
   Create a view that summarizes monthly sales by aggregating:
     - OrderMonth (truncated to month)
     - TotalSales, TotalOrders, and TotalQuantities.
*/

SET search_path TO mydatabase, sales, public;

/* Create / replace a monthly summary view (PostgreSQL) */
DROP VIEW IF EXISTS Sales.V_Monthly_Summary;
CREATE VIEW Sales.V_Monthly_Summary AS
SELECT 
  date_trunc('month', OrderDate)::date AS OrderMonth,
  SUM(Sales)   AS TotalSales,
  COUNT(OrderID) AS TotalOrders,
  SUM(Quantity)  AS TotalQuantities
FROM Sales.Orders
GROUP BY date_trunc('month', OrderDate);

-- Query the view
SELECT * FROM Sales.V_Monthly_Summary;

-- Modify (example): remove TotalQuantities
CREATE OR REPLACE VIEW Sales.V_Monthly_Summary AS
SELECT 
  date_trunc('month', OrderDate)::date AS OrderMonth,
  SUM(Sales)   AS TotalSales,
  COUNT(OrderID) AS TotalOrders
FROM Sales.Orders
GROUP BY date_trunc('month', OrderDate);

/* Hide complexity: joined order details */
DROP VIEW IF EXISTS Sales.V_Order_Details;
CREATE VIEW Sales.V_Order_Details AS
SELECT 
  o.OrderID,
  o.OrderDate,
  p.Product,
  p.Category,
  CONCAT_WS(' ', COALESCE(c.FirstName, ''), COALESCE(c.LastName, '')) AS CustomerName,
  c.Country AS CustomerCountry,
  CONCAT_WS(' ', COALESCE(e.FirstName, ''), COALESCE(e.LastName, '')) AS SalesName,
  e.Department,
  o.Sales,
  o.Quantity
FROM Sales.Orders o
LEFT JOIN Sales.Products  p ON p.ProductID = o.ProductID
LEFT JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
LEFT JOIN Sales.Employees e ON e.EmployeeID = o.SalesPersonID;

/* Data security: EU-only view (exclude USA) */
DROP VIEW IF EXISTS Sales.V_Order_Details_EU;
CREATE VIEW Sales.V_Order_Details_EU AS
SELECT 
  o.OrderID,
  o.OrderDate,
  p.Product,
  p.Category,
  CONCAT_WS(' ', COALESCE(c.FirstName, ''), COALESCE(c.LastName, '')) AS CustomerName,
  c.Country AS CustomerCountry,
  CONCAT_WS(' ', COALESCE(e.FirstName, ''), COALESCE(e.LastName, '')) AS SalesName,
  e.Department,
  o.Sales,
  o.Quantity
FROM Sales.Orders o
LEFT JOIN Sales.Products  p ON p.ProductID = o.ProductID
LEFT JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
LEFT JOIN Sales.Employees e ON e.EmployeeID = o.SalesPersonID
WHERE c.Country <> 'USA';
