/* ============================================================================== 
   SQL Filtering Data
-------------------------------------------------------------------------------
   This document provides an overview of SQL filtering techniques using WHERE 
   and various operators for precise data retrieval.

   Table of Contents:
     1. Comparison Operators
        - =, <>, >, >=, <, <=
     2. Logical Operators
        - AND, OR, NOT
     3. Range Filtering
        - BETWEEN
     4. Set Filtering
        - IN
     5. Pattern Matching
        - LIKE
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* COMPARISON */
SELECT * FROM customers WHERE country = 'Germany';
SELECT * FROM customers WHERE country <> 'Germany';
SELECT * FROM customers WHERE score > 500;
SELECT * FROM customers WHERE score >= 500;
SELECT * FROM customers WHERE score < 500;
SELECT * FROM customers WHERE score <= 500;

/* LOGICAL */
SELECT * FROM customers WHERE country = 'USA' AND score > 500;
SELECT * FROM customers WHERE country = 'USA' OR score > 500;
SELECT * FROM customers WHERE NOT (score < 500);

/* BETWEEN */
SELECT * FROM customers WHERE score BETWEEN 100 AND 500;
SELECT * FROM customers WHERE score >= 100 AND score <= 500;

/* IN */
SELECT * FROM customers WHERE country IN ('Germany', 'USA');

/* LIKE */
SELECT * FROM customers WHERE first_name LIKE 'M%';
SELECT * FROM customers WHERE first_name LIKE '%n';
SELECT * FROM customers WHERE first_name LIKE '%r%';
SELECT * FROM customers WHERE first_name LIKE '__r%';
