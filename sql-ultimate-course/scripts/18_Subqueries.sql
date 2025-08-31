/* ==============================================================================
   SQL Subquery Functions
-------------------------------------------------------------------------------
   This script demonstrates various subquery techniques in SQL.
   It covers result types, subqueries in the FROM clause, in SELECT, in JOIN clauses,
   with comparison operators, IN, ANY, correlated subqueries, and EXISTS.
   
   Table of Contents:
     1. SUBQUERY - RESULT TYPES
     2. SUBQUERY - FROM CLAUSE
     3. SUBQUERY - SELECT
     4. SUBQUERY - JOIN CLAUSE
     5. SUBQUERY - COMPARISON OPERATORS 
     6. SUBQUERY - IN OPERATOR
     7. SUBQUERY - ANY OPERATOR
     8. SUBQUERY - CORRELATED 
     9. SUBQUERY - EXISTS OPERATOR
===============================================================================
*/

SET search_path TO mydatabase, sales, public;

/* Result types */
SELECT AVG(Sales) FROM Sales.Orders;                 -- scalar
SELECT CustomerID FROM Sales.Orders;                 -- rowset
SELECT OrderID, OrderDate FROM Sales.Orders;         -- table

/* FROM-clause subqueries */
SELECT *
FROM (
  SELECT ProductID, Price, AVG(Price) OVER () AS AvgPrice
  FROM Sales.Products
) t
WHERE Price > AvgPrice;

SELECT *, RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
FROM (
  SELECT CustomerID, SUM(Sales) AS TotalSales
  FROM Sales.Orders
  GROUP BY CustomerID
) t;

/* SELECT-list subquery */
SELECT ProductID, Product, Price,
       (SELECT COUNT(*) FROM Sales.Orders) AS TotalOrders
FROM Sales.Products;

/* JOIN with subquery */
SELECT c.*, t.TotalSales
FROM Sales.Customers AS c
LEFT JOIN (
  SELECT CustomerID, SUM(Sales) AS TotalSales
  FROM Sales.Orders
  GROUP BY CustomerID
) t ON c.CustomerID = t.CustomerID;

SELECT c.*, o.TotalOrders
FROM Sales.Customers AS c
LEFT JOIN (
  SELECT CustomerID, COUNT(*) AS TotalOrders
  FROM Sales.Orders
  GROUP BY CustomerID
) o ON c.CustomerID = o.CustomerID;

/* Comparison operators */
SELECT ProductID, Price,
       (SELECT AVG(Price) FROM Sales.Products) AS AvgPrice
FROM Sales.Products
WHERE Price > (SELECT AVG(Price) FROM Sales.Products);

/* IN / NOT IN */
SELECT * FROM Sales.Orders
WHERE CustomerID IN (
  SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany'
);

SELECT * FROM Sales.Orders
WHERE CustomerID NOT IN (
  SELECT CustomerID FROM Sales.Customers WHERE Country = 'Germany'
);

/* ANY */
SELECT EmployeeID, FirstName, Salary
FROM Sales.Employees
WHERE Gender = 'F'
  AND Salary > ANY (SELECT Salary FROM Sales.Employees WHERE Gender = 'M');

/* Correlated subquery */
SELECT c.*,
       (SELECT COUNT(*) FROM Sales.Orders o WHERE o.CustomerID = c.CustomerID) AS TotalSales
FROM Sales.Customers c;

/* EXISTS / NOT EXISTS */
SELECT * FROM Sales.Orders o
WHERE EXISTS (
  SELECT 1 FROM Sales.Customers c
  WHERE c.Country = 'Germany' AND o.CustomerID = c.CustomerID
);

SELECT * FROM Sales.Orders o
WHERE NOT EXISTS (
  SELECT 1 FROM Sales.Customers c
  WHERE c.Country = 'Germany' AND o.CustomerID = c.CustomerID
);
