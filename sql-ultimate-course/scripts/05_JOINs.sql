/* ==============================================================================
   SQL Joins 
-------------------------------------------------------------------------------
   This document provides an overview of SQL joins, which allow combining data
   from multiple tables to retrieve meaningful insights.

   Table of Contents:
     1. Basic Joins
        - INNER JOIN
        - LEFT JOIN
        - RIGHT JOIN
        - FULL JOIN
     2. Advanced Joins
        - LEFT ANTI JOIN
        - RIGHT ANTI JOIN
        - ALTERNATIVE INNER JOIN
        - FULL ANTI JOIN
        - CROSS JOIN
     3. Multiple Table Joins (4 Tables)
=================================================================================
*/

/* 
Purposes of Joins:
- Data (re)combinations
- Data enrichment (getting extra data)
- Existence checks and filtering (against reference or lookup table)
*/

SET search_path TO mydatabase, sales, public;

/* No join */
-- All data from both tables without any join
SELECT * FROM customers;
SELECT * FROM orders;

-- Explore both tables before attempting joins

/* INNER JOIN */
-- Everything in both tables
SELECT c.id, c.first_name, o.order_id, o.sales -- columns to display from each table
FROM customers c -- give the tables their join identifiers
JOIN orders o ON c.id = o.customer_id; -- not specifying join is automatic inner join

/* LEFT JOIN */
-- Left table and what's in both tables
-- Query customers, matching those who have made orders
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
ORDER BY c.id ASC;

/* RIGHT JOIN */
-- Query orders, including those without matching customers
SELECT c.id, c.first_name, o.order_id, o.customer_id, o.sales
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

/* RIGHT via LEFT */
-- Same result as above query but switching tables means opposite join (unconventional)
SELECT c.id, c.first_name, o.order_id, o.sales
FROM orders o
LEFT JOIN customers c ON c.id = o.customer_id;

/* FULL JOIN */
-- All data from both tables
SELECT c.id, c.first_name, o.order_id, o.customer_id, o.sales
FROM customers c
FULL JOIN orders o ON c.id = o.customer_id;

/* LEFT ANTI (no orders) */
-- Records from left table that have no match on the right
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NULL; -- creates the anti

/* RIGHT ANTI (orders without customers) */
-- Records on the right that have no match on the left
SELECT o.*
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id
WHERE c.id IS NULL; -- creates the anti

/* INNER via LEFT + filter */
SELECT c.*, o.*
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NOT NULL;

/* FULL ANTI */
-- Record that don't match in each table
-- Query below is customers without orders and orders without customers
SELECT c.id, c.first_name, o.order_id, o.customer_id, o.sales
FROM customers c
FULL JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NULL OR c.id IS NULL;

/* Get all customers with their orders, but only for customers who
   placed an order. INNER JOIN use not allowed

   Transaltion: all customers who placed and order and their order
*/
SELECT *
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NOT NULL -- Extra condition since this isn't INNER

/* CROSS JOIN */
-- Combine every row in left and right tables
SELECT * FROM customers CROSS JOIN orders;

/*
Summary
-------
- INNER JOIN = only matching records

- LEFT JOIN = All rows on one side and matching
- FULL JOIN = All rows from both sides

- LEFT ANTI JOIN = only unmatching from one side
- FULL ANTI JOIN = unmatching from both sides
*/

/* 4-table join in the sales schema */
-- List of orders with related customer, product and employee details
-- Display order ID, customer name, product name, sales, price, sales person's name
SELECT 
  o.orderid        AS order_id,
  o.sales,
  c.firstname      AS customer_firstname,
  c.lastname       AS customer_lastname,
  p.product        AS product_name,
  p.price,
  e.firstname      AS employee_firstname,
  e.lastname       AS employee_lastname
FROM sales.orders     o
-- Join on all primary and foreign keys to orders table, according to ER diagram
LEFT JOIN sales.customers  c ON o.customerid    = c.customerid
LEFT JOIN sales.products   p ON o.productid     = p.productid
LEFT JOIN sales.employees  e ON o.salespersonid = e.employeeid;
