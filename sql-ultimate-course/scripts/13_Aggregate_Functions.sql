/* ============================================================================== 
   SQL Aggregate Functions
-------------------------------------------------------------------------------
   This document provides an overview of SQL aggregate functions, which allow 
   performing calculations on multiple rows of data to generate summary results.

   Table of Contents:
     1. Basic Aggregate Functions
        - COUNT
        - SUM
        - AVG
        - MAX
        - MIN
     2. Grouped Aggregations
        - GROUP BY
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* BASIC AGGREGATES */
SELECT COUNT(*) AS total_customers FROM customers;
SELECT SUM(sales) AS total_sales FROM orders;
SELECT AVG(sales) AS avg_sales FROM orders;
SELECT MAX(score) AS max_score FROM customers;
SELECT MIN(score) AS min_score FROM customers;

/* GROUPED AGGREGATIONS */
SELECT
  customer_id,
  COUNT(*) AS total_orders,
  SUM(sales) AS total_sales,
  AVG(sales) AS avg_sales,
  MAX(sales) AS highest_sales,
  MIN(sales) AS lowest_sales
FROM orders
GROUP BY customer_id;
