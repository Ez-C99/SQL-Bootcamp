/* ==============================================================================
   SQL Temporary Tables
-------------------------------------------------------------------------------
   This script provides a generic example of data migration using a temporary
   table. 
=================================================================================
*/

SET search_path TO sales, mydatabase, public;

/* ==============================================================================
   Temporary table flow (PostgreSQL)
   - T-SQL: SELECT ... INTO #Orders ; DELETE ; SELECT INTO Sales.OrdersTest
   - PG:    CREATE TEMP TABLE orders_tmp AS ... ; DELETE ; CREATE TABLE AS ...
============================================================================== */

-- Safety: start clean if you re-run
DROP TABLE IF EXISTS sales.orderstest;

-- Step 1: Create temporary table from Sales.Orders
CREATE TEMP TABLE orders_tmp AS
SELECT * FROM sales.orders;

-- Step 2: Clean temp data
DELETE FROM orders_tmp
WHERE orderstatus = 'Delivered';

-- Step 3: Load cleaned data into a permanent table
CREATE TABLE sales.orderstest AS
SELECT * FROM orders_tmp;
