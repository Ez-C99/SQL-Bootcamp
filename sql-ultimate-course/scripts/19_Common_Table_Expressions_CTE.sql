/* ==============================================================================
   SQL Common Table Expressions (CTEs)
-------------------------------------------------------------------------------
   This script demonstrates the use of Common Table Expressions (CTEs) in SQL Server.
   It includes examples of non-recursive CTEs for data aggregation and segmentation,
   as well as recursive CTEs for generating sequences and building hierarchical data.

   Table of Contents:
     1. NON-RECURSIVE CTE
     2. RECURSIVE CTE | GENERATE SEQUENCE
     3. RECURSIVE CTE | BUILD HIERARCHY
===============================================================================
*/

SET search_path TO mydatabase, sales, public;

/* NON-RECURSIVE CTEs */
WITH CTE_Total_Sales AS (
  SELECT CustomerID, SUM(Sales) AS TotalSales
  FROM Sales.Orders
  GROUP BY CustomerID
),
CTE_Last_Order AS (
  SELECT CustomerID, MAX(OrderDate) AS Last_Order
  FROM Sales.Orders
  GROUP BY CustomerID
),
CTE_Customer_Rank AS (
  SELECT CustomerID, TotalSales,
         RANK() OVER (ORDER BY TotalSales DESC) AS CustomerRank
  FROM CTE_Total_Sales
),
CTE_Customer_Segments AS (
  SELECT CustomerID, TotalSales,
         CASE WHEN TotalSales > 100 THEN 'High'
              WHEN TotalSales > 80  THEN 'Medium'
              ELSE 'Low' END AS CustomerSegments
  FROM CTE_Total_Sales
)
SELECT
  c.CustomerID, c.FirstName, c.LastName,
  cts.TotalSales, clo.Last_Order, ccr.CustomerRank, ccs.CustomerSegments
FROM Sales.Customers c
LEFT JOIN CTE_Total_Sales     cts ON cts.CustomerID = c.CustomerID
LEFT JOIN CTE_Last_Order      clo ON clo.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Rank   ccr ON ccr.CustomerID = c.CustomerID
LEFT JOIN CTE_Customer_Segments ccs ON ccs.CustomerID = c.CustomerID;

/* RECURSIVE CTE | GENERATE SEQUENCE 1..20 */
WITH RECURSIVE Series AS (
  SELECT 1 AS MyNumber
  UNION ALL
  SELECT MyNumber + 1 FROM Series WHERE MyNumber < 20
)
SELECT * FROM Series;

/* RECURSIVE CTE | GENERATE SEQUENCE 1..1000 */
WITH RECURSIVE Series AS (
  SELECT 1 AS MyNumber
  UNION ALL
  SELECT MyNumber + 1 FROM Series WHERE MyNumber < 1000
)
SELECT * FROM Series;

/* RECURSIVE CTE | BUILD HIERARCHY */
WITH RECURSIVE CTE_Emp_Hierarchy AS (
  SELECT EmployeeID, FirstName, ManagerID, 1 AS Level
  FROM Sales.Employees
  WHERE ManagerID IS NULL
  UNION ALL
  SELECT e.EmployeeID, e.FirstName, e.ManagerID, ceh.Level + 1
  FROM Sales.Employees e
  JOIN CTE_Emp_Hierarchy ceh ON e.ManagerID = ceh.EmployeeID
)
SELECT * FROM CTE_Emp_Hierarchy;
