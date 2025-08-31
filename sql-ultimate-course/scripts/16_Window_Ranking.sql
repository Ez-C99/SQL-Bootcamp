/* ==============================================================================
   SQL Window Ranking Functions
-------------------------------------------------------------------------------
   These functions allow you to rank and order rows within a result set 
   without the need for complex joins or subqueries. They enable you to assign 
   unique or non-unique rankings, group rows into buckets, and analyze data 
   distributions on ordered data.

   Table of Contents:
     1. ROW_NUMBER
     2. RANK
     3. DENSE_RANK
     4. NTILE
     5. CUME_DIST
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

SELECT OrderID, ProductID, Sales,
       ROW_NUMBER() OVER (ORDER BY Sales DESC)     AS SalesRank_Row,
       RANK()       OVER (ORDER BY Sales DESC)     AS SalesRank_Rank,
       DENSE_RANK() OVER (ORDER BY Sales DESC)     AS SalesRank_Dense
FROM Sales.Orders;

SELECT *
FROM (
  SELECT OrderID, ProductID, Sales,
         ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY Sales DESC) AS RankByProduct
  FROM Sales.Orders
) t
WHERE RankByProduct = 1;

SELECT *
FROM (
  SELECT CustomerID, SUM(Sales) AS TotalSales,
         ROW_NUMBER() OVER (ORDER BY SUM(Sales)) AS RankCustomers
  FROM Sales.Orders
  GROUP BY CustomerID
) t
WHERE RankCustomers <= 2;

SELECT ROW_NUMBER() OVER (ORDER BY OrderID, OrderDate) AS UniqueID, *
FROM Sales.OrdersArchive;

SELECT *
FROM (
  SELECT ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY CreationTime DESC) AS rn, *
  FROM Sales.OrdersArchive
) t
WHERE rn = 1;

SELECT OrderID, Sales,
       NTILE(1) OVER (ORDER BY Sales)                         AS OneBucket,
       NTILE(2) OVER (ORDER BY Sales)                         AS TwoBuckets,
       NTILE(3) OVER (ORDER BY Sales)                         AS ThreeBuckets,
       NTILE(4) OVER (ORDER BY Sales)                         AS FourBuckets,
       NTILE(2) OVER (PARTITION BY ProductID ORDER BY Sales)  AS TwoBucketByProducts
FROM Sales.Orders;

SELECT OrderID, Sales, Buckets,
       CASE WHEN Buckets = 1 THEN 'High'
            WHEN Buckets = 2 THEN 'Medium'
            WHEN Buckets = 3 THEN 'Low'
       END AS SalesSegmentations
FROM (
  SELECT OrderID, Sales,
         NTILE(3) OVER (ORDER BY Sales DESC) AS Buckets
  FROM Sales.Orders
) t;

SELECT NTILE(5) OVER (ORDER BY OrderID) AS Buckets, *
FROM Sales.Orders;

SELECT Product, Price, DistRank,
       CONCAT((DistRank * 100)::int, '%') AS DistRankPerc
FROM (
  SELECT Product, Price,
         CUME_DIST() OVER (ORDER BY Price DESC) AS DistRank
  FROM Sales.Products
) t
WHERE DistRank <= 0.4;
