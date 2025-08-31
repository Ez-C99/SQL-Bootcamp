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

SET search_path TO mydatabase, sales, public;

/* No join */
SELECT * FROM customers;
SELECT * FROM orders;

/* INNER JOIN */
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers c
JOIN orders o ON c.id = o.customer_id;

/* LEFT JOIN */
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;

/* RIGHT JOIN */
SELECT c.id, c.first_name, o.order_id, o.customer_id, o.sales
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

/* RIGHT via LEFT */
SELECT c.id, c.first_name, o.order_id, o.sales
FROM orders o
LEFT JOIN customers c ON c.id = o.customer_id;

/* FULL JOIN */
SELECT c.id, c.first_name, o.order_id, o.customer_id, o.sales
FROM customers c
FULL JOIN orders o ON c.id = o.customer_id;

/* LEFT ANTI (no orders) */
SELECT c.*
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NULL;

/* RIGHT ANTI (orders without customers) */
SELECT o.*
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id
WHERE c.id IS NULL;

/* INNER via LEFT + filter */
SELECT c.*, o.*
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NOT NULL;

/* FULL ANTI */
SELECT c.id, c.first_name, o.order_id, o.customer_id, o.sales
FROM customers c
FULL JOIN orders o ON c.id = o.customer_id
WHERE o.customer_id IS NULL OR c.id IS NULL;

/* CROSS JOIN */
SELECT * FROM customers CROSS JOIN orders;

/* 4-table join in the sales schema */
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
LEFT JOIN sales.customers  c ON o.customerid    = c.customerid
LEFT JOIN sales.products   p ON o.productid     = p.productid
LEFT JOIN sales.employees  e ON o.salespersonid = e.employeeid;
