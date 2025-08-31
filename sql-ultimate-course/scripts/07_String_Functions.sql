/* ============================================================================== 
   SQL String Functions
-------------------------------------------------------------------------------
   This document provides an overview of SQL string functions, which allow 
   manipulation, transformation, and extraction of text data efficiently.

   Table of Contents:
     1. Manipulations
        - CONCAT
        - LOWER
        - UPPER
	- TRIM
	- REPLACE
     2. Calculation
        - LEN
     3. Substring Extraction
        - LEFT
        - RIGHT
        - SUBSTRING
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* CONCAT */
SELECT CONCAT(first_name, '-', country) AS full_info FROM customers;

/* LOWER / UPPER */
SELECT LOWER(first_name) AS lower_case_name FROM customers;
SELECT UPPER(first_name) AS upper_case_name FROM customers;

/* TRIM + LENGTH */
SELECT 
  first_name,
  length(first_name)                AS len_name,
  length(trim(first_name))          AS len_trim_name,
  length(first_name) - length(trim(first_name)) AS flag
FROM customers
WHERE length(first_name) <> length(trim(first_name));

/* REPLACE */
SELECT '123-456-7890' AS phone, REPLACE('123-456-7890', '-', '/') AS clean_phone;
SELECT 'report.txt' AS old_filename, REPLACE('report.txt', '.txt', '.csv') AS new_filename;

/* LENGTH */
SELECT first_name, length(first_name) AS name_length FROM customers;

/* LEFT / RIGHT */
SELECT first_name, left(trim(first_name), 2) AS first_2_chars FROM customers;
SELECT first_name, right(first_name, 2)      AS last_2_chars  FROM customers;

/* SUBSTRING (use substr in PG) */
SELECT first_name, substr(trim(first_name), 2, length(first_name)) AS trimmed_name
FROM customers;

/* Nesting */
SELECT first_name, UPPER(LOWER(first_name)) AS nesting FROM customers;
