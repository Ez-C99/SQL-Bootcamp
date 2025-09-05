/* ==============================================================================
   SQL AI Prompts for SQL
-------------------------------------------------------------------------------
   This script contains a series of prompts designed to help both SQL developers 
   and anyone interested in learning SQL improve their skills in writing, 
   optimizing, and understanding SQL queries. The prompts cover a variety of 
   topics, including solving SQL tasks, enhancing query readability, performance 
   optimization, debugging, and interview/exam preparation. Each section provides 
   clear instructions and sample code to facilitate self-learning and practical 
   application in real-world scenarios.

   Table of Contents:
     1. Solve an SQL Task
     2. Improve the Readability
     3. Optimize the Performance Query
     4. Optimize Execution Plan
     5. Debugging
     6. Explain the Result
     7. Styling & Formatting
     8. Documentations & Comments
     9. Improve Database DDL
    10. Generate Test Dataset
    11. Create SQL Course
    12. Understand SQL Concept
    13. Comparing SQL Concepts
    14. SQL Questions with Options
    15. Prepare for a SQL Interview
    16. Prepare for a SQL Exam
=================================================================================
*/

SET search_path TO sales, mydatabase, public;

/* Only the embedded sample queries below were adapted for Postgres syntax.
   Prompts/instructions remain as-is. */

-- 2) Improve the Readability (sample query made PG-friendly)
WITH cte_total_sales_by_customer AS (
  SELECT
    c.customerid,
    (c.firstname || ' ' || COALESCE(c.lastname,'')) AS fullname,
    SUM(o.sales) AS totalsales
  FROM  sales.customers c
  JOIN  sales.orders    o ON o.customerid = c.customerid
  GROUP BY c.customerid, c.firstname, c.lastname
),
cte_highest_order_product AS (
  SELECT
    o.customerid,
    p.product,
    ROW_NUMBER() OVER (PARTITION BY o.customerid ORDER BY o.sales DESC) AS rn
  FROM sales.orders o
  JOIN sales.products p ON p.productid = o.productid
),
cte_highest_category AS (
  SELECT
    o.customerid,
    p.category,
    ROW_NUMBER() OVER (PARTITION BY o.customerid ORDER BY SUM(o.sales) DESC) AS rn
  FROM sales.orders o
  JOIN sales.products p ON p.productid = o.productid
  GROUP BY o.customerid, p.category
),
cte_last_order_date AS (
  SELECT customerid, MAX(orderdate) AS lastorderdate
  FROM  sales.orders
  GROUP BY customerid
),
cte_total_discounts_by_customer AS (
  -- 10% of quantity*price (demo)
  SELECT o.customerid, SUM(o.quantity * p.price * 0.1) AS totaldiscounts
  FROM sales.orders o
  JOIN sales.products p ON p.productid = o.productid
  GROUP BY o.customerid
)
SELECT
  ts.customerid,
  ts.fullname,
  ts.totalsales,
  hop.product  AS highestorderproduct,
  hc.category  AS highestcategory,
  lod.lastorderdate,
  td.totaldiscounts
FROM cte_total_sales_by_customer ts
LEFT JOIN LATERAL (SELECT customerid, product FROM cte_highest_order_product WHERE rn=1 AND customerid=ts.customerid) hop ON TRUE
LEFT JOIN LATERAL (SELECT customerid, category FROM cte_highest_category WHERE rn=1 AND customerid=ts.customerid) hc ON TRUE
LEFT JOIN cte_last_order_date          lod ON lod.customerid = ts.customerid
LEFT JOIN cte_total_discounts_by_customer td ON td.customerid = ts.customerid
WHERE ts.totalsales > 0
ORDER BY ts.totalsales DESC;

-- 3) Optimize the Performance Query (PG rewrite of the slow example)
-- Original used LOWER(...), YEAR(...), many ORs, and a correlated subquery.
WITH usa_customers AS (
  SELECT customerid FROM sales.customers WHERE country LIKE '%USA%'
),
delivered_orders AS (
  SELECT orderid, customerid
  FROM sales.orders
  WHERE orderstatus = 'Delivered'
     OR (orderdate >= DATE '2025-01-01' AND orderdate < DATE '2026-01-01')
     OR customerid IN (1,2,3)
     OR customerid IN (SELECT customerid FROM usa_customers)
)
SELECT
  o.orderid,
  o.customerid,
  c.firstname AS customerfirstname,
  cnt.ordercount
FROM sales.orders o
LEFT JOIN sales.customers c ON c.customerid = o.customerid
LEFT JOIN (
  SELECT customerid, COUNT(*) AS ordercount
  FROM sales.orders
  GROUP BY customerid
) cnt ON cnt.customerid = c.customerid
WHERE o.orderid IN (SELECT orderid FROM delivered_orders);

-- 5) Debugging example (GROUP BY vs window aggregate)
-- The original error (SQL Server) comes from mixing GROUP BY with a windowed ORDER BY on O.Sales.
-- A correct PG pattern:
SELECT
  c.customerid,
  c.country,
  SUM(o.sales) AS totalsales,
  RANK() OVER (PARTITION BY c.country ORDER BY SUM(o.sales) OVER (PARTITION BY c.customerid)) AS rankincountry
FROM sales.customers c
LEFT JOIN sales.orders o ON o.customerid = c.customerid
GROUP BY c.customerid, c.country;

/* ===========================================================================
   9. Improve Database DDL
============================================================================== 
The following SQL Server DDL Script has to be optimized.
Do the following:
	- Naming: Check the consistency of table/column names, prefixes, standards.
	- Data Types: Ensure data types are appropriate and optimized.
	- Integrity: Verify the integrity of primary keys and foreign keys.	
	- Indexes: Check that indexes are sufficient and avoid redundancy.
	- Normalization: Ensure proper normalization and avoid redundancy.

==============================================================================
   10. Generate Test Dataset
==============================================================================

I need dataset for testing the following SQL Server DDL 
Do the following:
	- Generate test dataset as Insert statements.
	- Dataset should be realstic.
	- Keep the dataset small.	
	- Ensure all primary/foreign key relationships are valid (use matching IDs).
	- Dont introduce any Null values.

==============================================================================
   11. Create SQL Course
============================================================================== 

Create a comprehensive SQL course with a detailed roadmap and agenda.
Do the following:
	- Start with SQL fundamentals and advance to complex topics.
	- Make it beginner-friendly.
	- Include topics relevant to data analytics.	
	- Focus on real-world data analytics use cases and scenarios.

==============================================================================
   12. Understand SQL Concept
==============================================================================

I want detailed explanation about SQL Window Functions.
Do the following:
	- Explain what Window Functions are.
	- Give an analogy.
	- Describe why we need them and when to use them.	
	- Explain the syntax.
	- Provide simple examples.
	- List the top 3 use cases.

==============================================================================
   13. Comparing SQL Concepts
============================================================================== 

I want to understand the differences between SQL Windows and GROUP BY.
Do the following:
	- Explain the key differences between the two concepts.
	- Describe when to use each concept, with examples.
	- Provide the pros and cons of each concept.	
	- Summarize the comparison in a clear side-by-side table.

==============================================================================
   14. SQL Questions with Options
==============================================================================

Act as an SQL trainer and help me practice SQL Window Functions.
Do the following:
	- Make it interactive Practicing, you provide task and give solution.
	- Provide a sample dataset.
	- Give SQL tasks that gradually increase in difficulty.	
	- Act as an SQL Server and show the results of my queries.
	- Review my queries, provide feedback, and suggest improvements.

==============================================================================
   15. Prepare for a SQL Interview
==============================================================================

Act as Interviewer and prepare me for a SQL interview.
Do the following:
	- Ask common SQL interview questions.
	- Make it interactive Practicing, you provide question and give answer.
	- Gradually progress to advanced topics.
	- Evaluate my answer and give me a feedback.	

==============================================================================
   16. Prepare for a SQL Exam
==============================================================================

Prepare me for a SQL exam
Do the following:
	- Ask common SQL interview questions.
	- Make it interactive Practicing, you provide question and give answer.
	- Gradually progress to advanced topics.
	- Evaluate my answer and give me a feedback.