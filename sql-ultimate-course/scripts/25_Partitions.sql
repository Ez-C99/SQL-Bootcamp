/* ==============================================================================
   SQL Partitioning
-------------------------------------------------------------------------------
   This script demonstrates SQL Server partitioning features. It covers the
   creation of partition functions, filegroups, data files, partition schemes,
   partitioned tables, and verification queries. It also shows how to compare
   execution plans between partitioned and non-partitioned tables.

   Table of Contents:
     1. Create a Partition Function
     2. Create Filegroups
     3. Create Data Files
     4. Create Partition Scheme
     5. Create the Partitioned Table
     6. Insert Data Into the Partitioned Table
     7. Verify Partitioning and Compare Execution Plans
=================================================================================
*/

SET search_path TO sales, mydatabase, public;

/* ==============================================================================
   Declarative partitioning (PostgreSQL)
   - Replace SQL Server partition functions/schemes/filegroups with PG partitions
============================================================================== */

-- Clean up
DO $$
BEGIN
  IF to_regclass('sales.orders_partitioned') IS NOT NULL THEN
    EXECUTE 'DROP TABLE sales.orders_partitioned CASCADE';
  END IF;
END$$;

-- Parent table
CREATE TABLE sales.orders_partitioned (
  orderid   INT,
  orderdate DATE,
  sales     INT
) PARTITION BY RANGE (orderdate);

-- Yearly partitions
CREATE TABLE sales.orders_p_2023 PARTITION OF sales.orders_partitioned
  FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE sales.orders_p_2024 PARTITION OF sales.orders_partitioned
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE sales.orders_p_2025 PARTITION OF sales.orders_partitioned
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE sales.orders_p_2026 PARTITION OF sales.orders_partitioned
  FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Inserts
INSERT INTO sales.orders_partitioned VALUES
  (1, '2023-05-15', 100),
  (2, '2024-07-20',  50),
  (3, '2025-12-31',  20),
  (4, '2026-01-01', 100);

-- Verify: which partition got each row?
SELECT orderid, orderdate, sales, tableoid::regclass AS stored_in
FROM sales.orders_partitioned
ORDER BY orderid;

-- Non-partitioned copy for plan comparisons
DROP TABLE IF EXISTS sales.orders_nopartition;
CREATE TABLE sales.orders_nopartition AS
SELECT * FROM sales.orders_partitioned;

-- Example predicate pruning
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM sales.orders_partitioned
WHERE orderdate IN ('2026-01-01'::date, '2025-12-31'::date);
