/* ==============================================================================
   SQL Stored Procedures
-------------------------------------------------------------------------------
   This script shows how to work with stored procedures in SQL Server,
   starting from basic implementations and advancing to more sophisticated
   techniques.

   Table of Contents:
     1. Basics (Creation and Execution)
     2. Parameters
     3. Multiple Queries
     4. Variables
     5. Control Flow with IF/ELSE
     6. Error Handling with TRY/CATCH
=================================================================================
*/

SET search_path TO sales, mydatabase, public;

-- In Postgres, you’ll typically use FUNCTIONS (returning rows) for this use case.
-- We provide:
--   1) get_customer_summary(country) → totals from Customers
--   2) get_customer_orders_summary(country) → totals from Orders (joined to country)
--   3) get_customer_summary_clean(country) → fixes NULL scores, logs via RAISE NOTICE
--   4) get_customer_summary_safe(country) → shows TRY/CATCH using EXCEPTION

-- 1) Basics (parameters + return table)
CREATE OR REPLACE FUNCTION sales.get_customer_summary(_country text DEFAULT 'USA')
RETURNS TABLE(totalcustomers int, avgscore numeric)
LANGUAGE sql AS $$
  SELECT COUNT(*)::int, AVG(score)::numeric
  FROM sales.customers
  WHERE country = _country;
$$;

-- 2) Multiple “reports” → separate function that returns orders totals
CREATE OR REPLACE FUNCTION sales.get_customer_orders_summary(_country text DEFAULT 'USA')
RETURNS TABLE(totalorders int, totalsales int)
LANGUAGE sql AS $$
  SELECT COUNT(o.orderid)::int,
         COALESCE(SUM(o.sales),0)::int
  FROM sales.orders o
  JOIN sales.customers c ON c.customerid = o.customerid
  WHERE c.country = _country;
$$;

-- 3) Variables + control flow (UPDATE then return summary)
CREATE OR REPLACE FUNCTION sales.get_customer_summary_clean(_country text DEFAULT 'USA')
RETURNS TABLE(totalcustomers int, avgscore numeric)
LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM sales.customers WHERE score IS NULL AND country = _country) THEN
    RAISE NOTICE 'Updating NULL scores to 0 for country %', _country;
    UPDATE sales.customers SET score = 0
    WHERE score IS NULL AND country = _country;
  ELSE
    RAISE NOTICE 'No NULL scores found for country %', _country;
  END IF;

  RETURN QUERY
  SELECT COUNT(*)::int, AVG(score)::numeric
  FROM sales.customers
  WHERE country = _country;
END
$$;

-- 4) Error handling with EXCEPTION
CREATE OR REPLACE FUNCTION sales.get_customer_summary_safe(_country text DEFAULT 'USA')
RETURNS TABLE(totalorders int, totalsales int)
LANGUAGE plpgsql AS $$
DECLARE
  _boom int;
BEGIN
  BEGIN
    -- Intentional error to demonstrate EXCEPTION (division by zero)
    _boom := 1/0;
  EXCEPTION WHEN division_by_zero THEN
    RAISE NOTICE 'An error occurred: division by zero (demo)';
  END;

  RETURN QUERY
  SELECT COUNT(o.orderid)::int, COALESCE(SUM(o.sales),0)::int
  FROM sales.orders o
  JOIN sales.customers c ON c.customerid = o.customerid
  WHERE c.country = _country;
END
$$;

-- Example calls:
-- SELECT * FROM sales.get_customer_summary('Germany');
-- SELECT * FROM sales.get_customer_orders_summary('USA');
-- SELECT * FROM sales.get_customer_summary_clean('USA');
-- SELECT * FROM sales.get_customer_summary_safe('Germany');
