/* ==============================================================================
   SQL NULL Functions
-------------------------------------------------------------------------------
   This script highlights essential SQL functions for managing NULL values.
   It demonstrates how to handle NULLs in data aggregation, mathematical operations,
   sorting, and comparisons. These techniques help maintain data integrity 
   and ensure accurate query results.

   Table of Contents:
     1. Handle NULL - Data Aggregation
     2. Handle NULL - Mathematical Operators
     3. Handle NULL - Sorting Data
     4. NULLIF - Division by Zero
     5. IS NULL - IS NOT NULL
     6. LEFT ANTI JOIN
     7. NULLs vs Empty String vs Blank Spaces
===============================================================================
*/

SET search_path TO mydatabase, sales, public;

/* HANDLE NULL - DATA AGGREGATION */
SELECT
    CustomerID,
    Score,
    COALESCE(Score, 0) AS Score2,
    AVG(Score) OVER () AS AvgScores,
    AVG(COALESCE(Score, 0)) OVER () AS AvgScores2
FROM Sales.Customers;

/* HANDLE NULL - MATHEMATICAL OPERATORS */
SELECT
    CustomerID,
    FirstName,
    LastName,
    CONCAT_WS(' ', FirstName, LastName) AS FullName,
    Score,
    COALESCE(Score, 0) + 10 AS ScoreWithBonus
FROM Sales.Customers;

/* HANDLE NULL - SORTING DATA */
SELECT
    CustomerID,
    Score
FROM Sales.Customers
ORDER BY Score NULLS LAST;

/* NULLIF - DIVISION BY ZERO */
SELECT
    OrderID,
    Sales,
    Quantity,
    Sales::numeric / NULLIF(Quantity, 0) AS Price
FROM Sales.Orders;

/* IS NULL / IS NOT NULL */
SELECT * FROM Sales.Customers WHERE Score IS NULL;
SELECT * FROM Sales.Customers WHERE Score IS NOT NULL;

/* LEFT ANTI JOIN */
SELECT c.*, o.OrderID
FROM Sales.Customers AS c
LEFT JOIN Sales.Orders AS o
  ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

/* NULLs vs EMPTY STRING vs BLANK SPACES */
WITH Orders AS (
  SELECT 1 AS Id, 'A'::text AS Category UNION ALL
  SELECT 2, NULL::text UNION ALL
  SELECT 3, ''::text UNION ALL
  SELECT 4, '  '::text
)
SELECT 
  *,
  length(Category)                         AS LenCategory,
  BTRIM(Category)                          AS Policy1,
  NULLIF(BTRIM(Category), '')              AS Policy2,
  COALESCE(NULLIF(BTRIM(Category), ''), 'unknown') AS Policy3
FROM Orders;
