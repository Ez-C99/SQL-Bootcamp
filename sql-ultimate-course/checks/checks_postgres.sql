-- Show server version (handy sanity)
SELECT version();

-- 1) All user tables
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type='BASE TABLE' AND table_schema NOT IN ('pg_catalog','information_schema')
ORDER BY 1,2;

-- 2) Tables missing PRIMARY KEYs
SELECT t.table_schema, t.table_name
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints c
  ON c.table_schema=t.table_schema
 AND c.table_name=t.table_name
 AND c.constraint_type='PRIMARY KEY'
WHERE t.table_type='BASE TABLE'
  AND t.table_schema NOT IN ('pg_catalog','information_schema')
  AND c.table_name IS NULL
ORDER BY 1,2;

-- 3) Manual orphan checks (no FKs defined on purpose)
-- mydatabase.orders -> mydatabase.customers
SELECT 'mydatabase.orders' AS rel, o.customer_id
FROM mydatabase.orders o
LEFT JOIN mydatabase.customers c ON c.id = o.customer_id
WHERE c.id IS NULL;

-- sales.orders -> sales.customers
SELECT 'sales.orders' AS rel, o.customerid
FROM sales.orders o
LEFT JOIN sales.customers c ON c.customerid = o.customerid
WHERE c.customerid IS NULL;

-- sales.orders -> sales.products
SELECT 'sales.orders' AS rel, o.productid
FROM sales.orders o
LEFT JOIN sales.products p ON p.productid = o.productid
WHERE p.productid IS NULL;

-- sales.orders -> sales.employees (salesperson)
SELECT 'sales.orders' AS rel, o.salespersonid
FROM sales.orders o
LEFT JOIN sales.employees e ON e.employeeid = o.salespersonid
WHERE e.employeeid IS NULL;

-- 4) Duplicates in "id-like" columns (common gotcha in exercises)
WITH id_cols AS (
  SELECT table_schema, table_name, column_name
  FROM information_schema.columns
  WHERE table_schema NOT IN ('pg_catalog','information_schema')
    AND column_name ~* '(^id$|_id$|^.*id$)'
)
SELECT table_schema, table_name, column_name, val, cnt
FROM (
  SELECT c.table_schema, c.table_name, c.column_name,
         (format('%I.%I', c.table_schema, c.table_name))::regclass AS reg,
         NULL::text AS val, 0::bigint AS cnt
  FROM id_cols c
) s
JOIN LATERAL (
  SELECT (t.val)::text AS val, COUNT(*) AS cnt
  FROM (
    SELECT (jsonb_each_text(to_jsonb(r))).value AS val
    FROM (SELECT * FROM s.reg) r
  ) t
  GROUP BY t.val
  HAVING COUNT(*) > 1
) d ON TRUE
ORDER BY table_schema, table_name, column_name;

-- 5) Row counts (top 20)
SELECT relnamespace::regnamespace AS schema,
       relname AS table,
       n_live_tup AS approx_rows
FROM pg_class
WHERE relkind='r'
ORDER BY n_live_tup DESC
LIMIT 20;

-- 6) “Course quirks” spotlight (for quick visibility in your console)
SELECT 'Leading space in mydatabase.customers.first_name for id=2' AS note
WHERE EXISTS (SELECT 1 FROM mydatabase.customers WHERE id=2 AND first_name LIKE ' %');

SELECT 'Zero-quantity rows present in sales.orders' AS note
WHERE EXISTS (SELECT 1 FROM sales.orders WHERE quantity = 0);
