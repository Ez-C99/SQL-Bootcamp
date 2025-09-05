/* ==============================================================================
   SQL SELECT Query
-------------------------------------------------------------------------------
   This guide covers various SELECT query techniques used for retrieving, 
   filtering, sorting, and aggregating data efficiently.

   Table of Contents:
     1. SELECT ALL COLUMNS
     2. SELECT SPECIFIC COLUMNS
     3. WHERE CLAUSE
     4. ORDER BY
     5. GROUP BY
     6. HAVING
     7. DISTINCT
     8. TOP
     9. Combining Queries
	 10. COOL STUFF - Additional SQL Features
=================================================================================
*/

/* ==============================================================================
   COMMENTS
=============================================================================== */

-- This is a single-line comment.

/* This
   is
   a multiple-line
   comment
*/

SET search_path TO mydatabase, sales, public;

/* SELECT ALL COLUMNS */
SELECT * FROM customers;
SELECT * FROM orders;

/* SELECT SPECIFIC COLUMNS */
SELECT first_name, country, score FROM customers;

/* WHERE */
SELECT * FROM customers WHERE score != 0; -- not equal to zero
SELECT * FROM customers WHERE country = 'Germany';
SELECT first_name, country FROM customers WHERE country = 'Germany';

/* ORDER BY */
SELECT * FROM customers ORDER BY score DESC;
SELECT * FROM customers ORDER BY score ASC;
SELECT * FROM customers ORDER BY country ASC;
SELECT * FROM customers ORDER BY country ASC, score DESC;

SELECT first_name, country, score
FROM customers
WHERE score <> 0
ORDER BY score DESC;

/* GROUP BY */
SELECT country, SUM(score) AS total_score
FROM customers
GROUP BY country;

-- (Invalid example in original left commented)
-- SELECT country, first_name, SUM(score) FROM customers GROUP BY country;

-- GROUP BY RULE: All SELECT columns must appear in the GROUP BY clause or be used in an aggregate function

-- Exercise: Total score and total customers per country
SELECT country, SUM(score) AS total_score, COUNT(id) AS total_customers
FROM customers
GROUP BY country

/* HAVING */
SELECT country, AVG(score) AS avg_score
FROM customers
GROUP BY country
HAVING AVG(score) > 430;

SELECT country, AVG(score) AS avg_score
FROM customers
WHERE score <> 0
GROUP BY country
HAVING AVG(score) > 430;

/* DISTINCT */
SELECT DISTINCT country FROM customers;

/* TOP -> LIMIT */
SELECT * FROM customers LIMIT 3;
SELECT * FROM customers ORDER BY score DESC LIMIT 3;
SELECT * FROM customers ORDER BY score ASC LIMIT 2;

SELECT * FROM orders ORDER BY order_date DESC LIMIT 2;

/* ALL TOGETHER */
SELECT country, AVG(score) AS avg_score
FROM customers
WHERE score <> 0
GROUP BY country
HAVING AVG(score) > 430
ORDER BY AVG(score) DESC;

/* Multiple statements allowed */
SELECT * FROM customers;
SELECT * FROM orders;

/* Selecting constants */
SELECT 123 AS static_number;
SELECT 'Hello' AS static_string;
SELECT id, first_name, 'New Customer' AS customer_type FROM customers;
