/* ==============================================================================
   SQL Window Value Functions
-------------------------------------------------------------------------------
   These functions let you reference and compare values from other rows 
   in a result set without complex joins or subqueries, enabling advanced 
   analysis on ordered data.

   Table of Contents:
     1. LEAD
     2. LAG
     3. FIRST_VALUE
     4. LAST_VALUE
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* MoM % change in sales (aggregate first, then LAG) */
WITH monthly AS (
  SELECT date_trunc('month', OrderDate)::date AS order_month,
         SUM(Sales) AS month_sales
  FROM Sales.Orders
  GROUP BY 1
)
SELECT
  order_month,
  month_sales AS current_month_sales,
  LAG(month_sales) OVER (ORDER BY order_month) AS previous_month_sales,
  (month_sales - LAG(month_sales) OVER (ORDER BY order_month)) AS momo_change,
  ROUND(
    ( (month_sales - LAG(month_sales) OVER (ORDER BY order_month))
      / NULLIF(LAG(month_sales) OVER (ORDER BY order_month), 0)::numeric ) * 100
  , 1) AS momo_perc
FROM monthly
ORDER BY order_month;

/* Customer loyalty: average days between orders */
WITH per_order AS (
  SELECT
    CustomerID,
    OrderDate AS current_order,
    LEAD(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS next_order
  FROM Sales.Orders
)
SELECT
  CustomerID,
  AVG(EXTRACT(DAY FROM (next_order - current_order))) AS AvgDays,
  RANK() OVER (ORDER BY COALESCE(AVG(EXTRACT(DAY FROM (next_order - current_order))), 999999)) AS RankAvg
FROM per_order
GROUP BY CustomerID;

/* FIRST_VALUE / LAST_VALUE */
SELECT
  OrderID,
  ProductID,
  Sales,
  FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) AS LowestSales,
  LAST_VALUE(Sales)  OVER (PARTITION BY ProductID ORDER BY Sales
                           ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS HighestSales,
  Sales - FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales) AS SalesDifference
FROM Sales.Orders;
