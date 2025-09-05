/* ==============================================================================
   30x SQL Performance Tips
-------------------------------------------------------------------------------
   This section demonstrates best practices for fetching data, filtering,
   joins, UNION, aggregations, subqueries/CTE, DDL, and indexing.
   It covers techniques such as selecting only necessary columns,
   proper filtering methods, explicit joins, avoiding redundant logic,
   and efficient indexing strategies.
   
   Table of Contents:
     1. FETCHING DATA
     2. FILTERING
     3. JOINS
     4. UNION
     5. AGGREGATIONS
     6. SUBQUERIES, CTE
     7. DDL
     8. INDEXING
===============================================================================
*/

SET search_path TO sales, mydatabase, public;

-- ###############################################################
-- #                        FETCHING DATA                        #
-- ###############################################################

-- Tip 1: Select only what you need
-- Bad
SELECT * FROM sales.customers;
-- Good
SELECT customerid, firstname, lastname FROM sales.customers;

-- Tip 2: Avoid unnecessary DISTINCT/ORDER BY
-- Bad
SELECT DISTINCT firstname FROM sales.customers ORDER BY firstname;
-- Good
SELECT firstname FROM sales.customers;

-- Tip 3: Limit for exploration
-- Bad
SELECT orderid, sales FROM sales.orders;
-- Good
SELECT orderid, sales FROM sales.orders ORDER BY orderid LIMIT 10;

-- ###########################################################
-- #                        FILTERING                        #
-- ###########################################################

-- Tip 4: Index on frequent filters
CREATE INDEX IF NOT EXISTS idx_orders_orderstatus ON sales.orders(orderstatus);
SELECT * FROM sales.orders WHERE orderstatus = 'Delivered';

-- Tip 5: Don’t wrap columns in functions in WHERE
-- Bad
SELECT * FROM sales.orders WHERE lower(orderstatus) = 'delivered';
-- Good
SELECT * FROM sales.orders WHERE orderstatus = 'Delivered';

-- Bad
SELECT * FROM sales.customers WHERE substring(firstname FROM 1 FOR 1) = 'A';
-- Good
SELECT * FROM sales.customers WHERE firstname LIKE 'A%';

-- Bad
SELECT * FROM sales.orders WHERE EXTRACT(YEAR FROM orderdate) = 2025;
-- Good
SELECT * FROM sales.orders
WHERE orderdate >= DATE '2025-01-01' AND orderdate < DATE '2026-01-01';

-- Tip 6: Avoid leading wildcards
-- Bad
SELECT * FROM sales.customers WHERE lastname LIKE '%Gold%';
-- Good
SELECT * FROM sales.customers WHERE lastname LIKE 'Gold%';
-- (or create index on lower(lastname) and search lower(...))

-- Tip 7: IN instead of many ORs
-- Bad
SELECT * FROM sales.orders WHERE customerid = 1 OR customerid = 2 OR customerid = 3;
-- Good
SELECT * FROM sales.orders WHERE customerid IN (1,2,3);

-- #######################################################
-- #                        JOINS                        #
-- #######################################################

-- Tip 8: Prefer INNER JOIN when appropriate
SELECT c.firstname, o.orderid
FROM sales.customers c
JOIN sales.orders o ON o.customerid = c.customerid;

-- Tip 9: Use explicit ANSI joins
-- Bad (implicit)
SELECT o.orderid, c.firstname
FROM sales.customers c, sales.orders o
WHERE c.customerid = o.customerid;
-- Good
SELECT o.orderid, c.firstname
FROM sales.customers c
JOIN sales.orders o ON o.customerid = c.customerid;

-- Tip 10: Index join keys
CREATE INDEX IF NOT EXISTS ix_orders_customerid ON sales.orders(customerid);

-- Tip 11: Filter early for big tables
SELECT c.firstname, o.orderid
FROM sales.customers c
JOIN (SELECT orderid, customerid FROM sales.orders WHERE orderstatus='Delivered') o
  ON o.customerid = c.customerid;

-- Tip 12: Pre-aggregate before join for big tables
SELECT c.customerid, c.firstname, o.ordercount
FROM sales.customers c
JOIN (
  SELECT customerid, COUNT(orderid) AS ordercount
  FROM sales.orders
  GROUP BY customerid
) o ON o.customerid = c.customerid;

-- Tip 13: UNION vs OR across two join patterns
SELECT o.orderid, c.firstname
FROM sales.customers c
JOIN sales.orders o ON c.customerid = o.customerid
UNION
SELECT o.orderid, c.firstname
FROM sales.customers c
JOIN sales.orders o ON c.customerid = o.salespersonid;

-- (No optimizer hints in stock Postgres; inspect with EXPLAIN/ANALYZE)

-- ################################################################
-- #                           UNION                              #
-- ################################################################

-- Tip 15: Use UNION ALL if duplicates ok
-- Bad
SELECT customerid FROM sales.orders
UNION
SELECT customerid FROM sales.ordersarchive;
-- Good
SELECT customerid FROM sales.orders
UNION ALL
SELECT customerid FROM sales.ordersarchive;

-- Tip 16: UNION ALL + DISTINCT if dedupe needed
SELECT DISTINCT customerid
FROM (
  SELECT customerid FROM sales.orders
  UNION ALL
  SELECT customerid FROM sales.ordersarchive
) t;

-- ##########################################################
-- #                     AGGREGATIONS                       #
-- ##########################################################

-- Tip 17: For big time-series, consider BRIN or matviews
CREATE INDEX IF NOT EXISTS idx_orders_brin_orderdate ON sales.orders USING brin(orderdate);

-- Tip 18: Pre-aggregate for reporting (materialized view)
DROP MATERIALIZED VIEW IF EXISTS sales.sales_summary;
CREATE MATERIALIZED VIEW sales.sales_summary AS
SELECT date_trunc('month', orderdate)::date AS order_month,
       SUM(sales) AS total_sales
FROM sales.orders
GROUP BY 1;

SELECT * FROM sales.sales_summary ORDER BY order_month;

-- ##############################################################
-- #                       SUBQUERIES, CTE                      #
-- ##############################################################

-- Tip 19: JOIN vs EXISTS vs IN
SELECT o.orderid, o.sales
FROM sales.orders o
WHERE EXISTS (
  SELECT 1 FROM sales.customers c
  WHERE c.customerid = o.customerid AND c.country = 'USA'
);

-- Tip 20: Avoid redundant logic with window agg
SELECT employeeid, firstname,
       CASE WHEN salary > AVG(salary) OVER () THEN 'Above Average'
            WHEN salary < AVG(salary) OVER () THEN 'Below Average'
            ELSE 'Average' END AS status
FROM sales.employees;

-- ##############################################################
-- #                             DDL                            #
-- ##############################################################
-- Bad practice (types/constraints)
DROP TABLE IF EXISTS public.customersinfo_bad;
CREATE TABLE public.customersinfo_bad (
    customerid INT,
    firstname  TEXT,
    lastname   TEXT,
    country    TEXT,
    totalpurchases DOUBLE PRECISION,
    score      TEXT,
    birthdate  TEXT,
    employeeid INT
);

-- Better practice
DROP TABLE IF EXISTS public.customersinfo_good;
CREATE TABLE public.customersinfo_good (
    customerid INT PRIMARY KEY,
    firstname  VARCHAR(50) NOT NULL,
    lastname   VARCHAR(50) NOT NULL,
    country    VARCHAR(50) NOT NULL,
    totalpurchases NUMERIC(12,2),
    score      INT,
    birthdate  DATE,
    employeeid INT REFERENCES sales.employees(employeeid)
);
CREATE INDEX IF NOT EXISTS ix_customersinfo_good_employeeid ON public.customersinfo_good(employeeid);

-- ##############################################################
-- #                        INDEXING                            #
-- ##############################################################
-- Tip 26/27/28/29/30: review, drop unused, analyze, reindex, partition + BRIN
ANALYZE;
-- REINDEX TABLE sales.orders;           -- if necessary
-- Partition big tables + BRIN as shown in 25_Partitions.sql
