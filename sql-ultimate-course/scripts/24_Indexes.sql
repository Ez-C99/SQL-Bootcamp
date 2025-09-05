/* ==============================================================================
   SQL Indexing
-------------------------------------------------------------------------------
   This script demonstrates various index types in SQL Server including clustered,
   non-clustered, columnstore, unique, and filtered indexes. It provides examples 
   of creating a heap table, applying different index types, and testing their 
   usage with sample queries.

   Table of Contents:
	   Index Types:
			 - Clustered and Non-Clustered Indexes
			 - Leftmost Prefix Rule Explanation
			 - Columnstore Indexes
			 - Unique Indexes
			 - Filtered Indexes
		Index Monitoring:
			 - Monitor Index Usage
			 - Monitor Missing Indexes
			 - Monitor Duplicate Indexes
			 - Update Statistics
			 - Fragmentations
=================================================================================
*/

SET search_path TO sales, mydatabase, public;

/* ==============================================================================
   PostgreSQL indexing demo
   - No "clustered vs nonclustered" in PG; PK/UNIQUE create btree indexes
   - We’ll demo btree, unique, composite, partial, expression, and monitoring
   - Columnstore does not exist natively → use BRIN or external extensions
============================================================================== */

-- Working copy (heap by default)
DROP TABLE IF EXISTS sales.dbcustomers;
CREATE TABLE sales.dbcustomers AS TABLE sales.customers;

-- Lookups by PK key (dbcustomers has no PK yet)
CREATE UNIQUE INDEX idx_dbcustomers_customerid ON sales.dbcustomers (customerid);

-- Lookup by LastName and FirstName
CREATE INDEX idx_dbcustomers_lastname  ON sales.dbcustomers (lastname);
CREATE INDEX idx_dbcustomers_firstname ON sales.dbcustomers (firstname);

-- Composite index: (country, score) to illustrate leftmost-prefix usage
CREATE INDEX idx_dbcustomers_country_score ON sales.dbcustomers (country, score);

-- Queries
SELECT * FROM sales.dbcustomers WHERE customerid = 1;
SELECT * FROM sales.dbcustomers WHERE lastname = 'Brown';
SELECT * FROM sales.dbcustomers WHERE country = 'USA' AND score > 500;
SELECT * FROM sales.dbcustomers WHERE score > 500 AND country = 'USA'; -- may not use composite efficiently

-- UNIQUE index examples
-- (Product names in your seed are unique; this should succeed)
DROP INDEX IF EXISTS idx_products_product;
CREATE UNIQUE INDEX idx_products_product ON sales.products (product);

-- This one may fail if category has duplicates — run to see behaviour
-- DROP INDEX IF EXISTS idx_products_category;
-- CREATE UNIQUE INDEX idx_products_category ON sales.products (category);

-- Partial (filtered) index
DROP INDEX IF EXISTS idx_customers_country_us;
CREATE INDEX idx_customers_country_us ON sales.customers (country)
WHERE country = 'USA';

-- Expression index for case-insensitive search
DROP INDEX IF EXISTS idx_customers_lastname_lower;
CREATE INDEX idx_customers_lastname_lower ON sales.customers ((lower(lastname)));

-- Columnstore analogue: BRIN on large, append-only date column
-- (best on big tables; harmless demo here)
DROP INDEX IF EXISTS idx_orders_brin_orderdate;
CREATE INDEX idx_orders_brin_orderdate ON sales.orders
USING brin (orderdate);

-- ---------------------------------------------------------------------------
-- Monitoring / catalog views
-- ---------------------------------------------------------------------------
-- List indexes on a table
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname='sales' AND tablename IN ('dbcustomers','customers','orders')
ORDER BY tablename, indexname;

-- Usage stats (reset on server restart)
SELECT
  c.relname AS table_name,
  i.relname AS index_name,
  s.idx_scan, s.idx_tup_read, s.idx_tup_fetch
FROM pg_stat_user_indexes s
JOIN pg_class i ON i.oid = s.indexrelid
JOIN pg_class c ON c.oid = s.relid
WHERE c.relnamespace = 'sales'::regnamespace
ORDER BY (s.idx_scan + s.idx_tup_read) DESC NULLS LAST;

-- Duplicate index finder (rough)
SELECT
  c.relname AS table_name,
  array_agg(i.relname ORDER BY i.relname) AS indexes
FROM pg_index x
JOIN pg_class c ON c.oid = x.indrelid
JOIN pg_class i ON i.oid = x.indexrelid
WHERE c.relnamespace = 'sales'::regnamespace
GROUP BY c.relname
HAVING COUNT(*) <> COUNT(DISTINCT x.indkey);  -- simplistic heuristic

-- Maintenance
ANALYZE sales.dbcustomers;
-- REINDEX (use sparingly; locks table)
-- REINDEX TABLE sales.dbcustomers;
