/* ==============================================================================
   SQL Data Manipulation Language (DML)
-------------------------------------------------------------------------------
   This guide covers the essential DML commands used for inserting, updating, 
   and deleting data in database tables.

   Table of Contents:
     1. INSERT - Adding Data to Tables
     2. UPDATE - Modifying Existing Data
     3. DELETE - Removing Data from Tables
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* INSERT (good) */
INSERT INTO customers (id, first_name, country, score) VALUES
  (6, 'Anna', 'USA', NULL),
  (7, 'Sam', NULL, 100);

/* (Demo only) The following would error in Postgres – left commented:
-- INSERT INTO customers (id, first_name, country, score) VALUES (8, 'Max', 'USA', NULL);
-- INSERT INTO customers (id, first_name, country, score) VALUES ('Max', 9, 'Max', NULL);
*/

INSERT INTO customers (id, first_name, country, score) VALUES (8, 'Max', 'USA', 368);
INSERT INTO customers VALUES (9, 'Andreas', 'Germany', NULL);
INSERT INTO customers (id, first_name) VALUES (10, 'Sahra');

/* INSERT … SELECT */
-- Ensure persons exists (see 02_ DDL)
INSERT INTO persons (id, person_name, birth_date, phone)
SELECT id, first_name, NULL::date, 'Unknown'
FROM customers;

/* UPDATE */
UPDATE customers SET score = 0 WHERE id = 6;
UPDATE customers SET score = 0, country = 'UK' WHERE id = 10;
UPDATE customers SET score = 0 WHERE score IS NULL;

SELECT * FROM customers WHERE score IS NULL;

/* DELETE */
SELECT * FROM customers WHERE id > 5;
DELETE FROM customers WHERE id > 5;

DELETE FROM persons;
TRUNCATE TABLE persons;
