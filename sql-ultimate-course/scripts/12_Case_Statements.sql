/* ==============================================================================
   SQL CASE Statement
-------------------------------------------------------------------------------
   This script demonstrates various use cases of the SQL CASE statement, including
   data categorization, mapping, quick form syntax, handling nulls, and conditional 
   aggregation.
   
   Table of Contents:
     1. Categorize Data
     2. Mapping
     3. Quick Form of Case Statement
     4. Handling Nulls
     5. Conditional Aggregation
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* Categorise Data */
SELECT
  Category,
  SUM(Sales) AS TotalSales
FROM (
  SELECT
    OrderID,
    Sales,
    CASE
      WHEN Sales > 50 THEN 'High'
      WHEN Sales > 20 THEN 'Medium'
      ELSE 'Low'
    END AS Category
  FROM Sales.Orders
) t
GROUP BY Category
ORDER BY TotalSales DESC;

/* Mapping */
SELECT
  CustomerID, FirstName, LastName, Country,
  CASE 
    WHEN Country = 'Germany' THEN 'DE'
    WHEN Country = 'USA'     THEN 'US'
    ELSE 'n/a'
  END AS CountryAbbr
FROM Sales.Customers;

/* Quick form + standard form */
SELECT
  CustomerID, FirstName, LastName, Country,
  CASE 
    WHEN Country = 'Germany' THEN 'DE'
    WHEN Country = 'USA'     THEN 'US'
    ELSE 'n/a'
  END AS CountryAbbr,
  CASE Country
    WHEN 'Germany' THEN 'DE'
    WHEN 'USA'     THEN 'US'
    ELSE 'n/a'
  END AS CountryAbbr2
FROM Sales.Customers;

/* Handling NULLs with CASE and AVG */
SELECT
  CustomerID, LastName, Score,
  CASE WHEN Score IS NULL THEN 0 ELSE Score END AS ScoreClean,
  AVG(CASE WHEN Score IS NULL THEN 0 ELSE Score END) OVER () AS AvgCustomerClean,
  AVG(Score) OVER () AS AvgCustomer
FROM Sales.Customers;

/* Conditional aggregation */
SELECT
  CustomerID,
  SUM(CASE WHEN Sales > 30 THEN 1 ELSE 0 END) AS TotalOrdersHighSales,
  COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY CustomerID;
