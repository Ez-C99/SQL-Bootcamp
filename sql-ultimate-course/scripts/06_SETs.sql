/* ==============================================================================
   SQL SET Operations
-------------------------------------------------------------------------------
   SQL set operations enable you to combine results from multiple queries
   into a single result set. This script demonstrates the rules and usage of
   set operations, including UNION, UNION ALL, EXCEPT, and INTERSECT.
   
   Table of Contents:
     1. SQL Operation Rules
     2. UNION
     3. UNION ALL
     4. EXCEPT
     5. INTERSECT
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* RULES (examples that would error are commented) */

-- Data types should match across branches of set ops
-- SELECT FirstName, LastName, Country FROM sales.customers
-- UNION
-- SELECT FirstName, LastName FROM sales.employees; -- (column count mismatch)

/* Column order must match */
-- SELECT LastName, CustomerID FROM sales.customers
-- UNION
-- SELECT EmployeeID, LastName FROM sales.employees;

/* Column aliases come from the first SELECT */
SELECT CustomerID AS id, LastName AS last_name FROM sales.customers
UNION
SELECT EmployeeID, LastName FROM sales.employees;

/* Ensure correct columns */
SELECT FirstName, LastName FROM sales.customers
UNION
SELECT FirstName, LastName FROM sales.employees;

/* TASK 1: UNION */
SELECT FirstName, LastName FROM sales.customers
UNION
SELECT FirstName, LastName FROM sales.employees;

/* TASK 2: UNION ALL */
SELECT FirstName, LastName FROM sales.customers
UNION ALL
SELECT FirstName, LastName FROM sales.employees;

/* TASK 3: EXCEPT (employees not customers) */
SELECT FirstName, LastName FROM sales.employees
EXCEPT
SELECT FirstName, LastName FROM sales.customers;

/* TASK 4: INTERSECT (employees also customers) */
SELECT FirstName, LastName FROM sales.employees
INTERSECT
SELECT FirstName, LastName FROM sales.customers;

/* TASK 5: UNION Orders + OrdersArchive */
SELECT
  'Orders' AS source_table, orderid, productid, customerid, salespersonid,
  orderdate, shipdate, orderstatus, shipaddress, billaddress,
  quantity, sales, creationtime
FROM sales.orders
UNION
SELECT
  'OrdersArchive' AS source_table, orderid, productid, customerid, salespersonid,
  orderdate, shipdate, orderstatus, shipaddress, billaddress,
  quantity, sales, creationtime
FROM sales.ordersarchive
ORDER BY orderid;
