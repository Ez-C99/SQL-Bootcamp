/* ==============================================================================
   SQL Date & Time Functions
-------------------------------------------------------------------------------
   This script demonstrates various date and time functions in SQL.
   It covers functions such as GETDATE, DATETRUNC, DATENAME, DATEPART,
   YEAR, MONTH, DAY, EOMONTH, FORMAT, CONVERT, CAST, DATEADD, DATEDIFF,
   and ISDATE.
   
   Table of Contents:
     1. GETDATE | Date Values
     2. Date Part Extractions (DATETRUNC, DATENAME, DATEPART, YEAR, MONTH, DAY)
     3. DATETRUNC
     4. EOMONTH
     5. Date Parts
     6. FORMAT
     7. CONVERT
     8. CAST
     9. DATEADD / DATEDIFF
    10. ISDATE
===============================================================================
*/

SET search_path TO mydatabase, sales, public;

/* TASK 1: GETDATE -> now() */
SELECT orderid, creationtime, DATE '2025-08-20' AS hardcoded, now() AS today
FROM sales.orders;

/* TASK 2: date_trunc / to_char / extract */
SELECT
  orderid,
  creationtime,
  date_trunc('year',   creationtime) AS year_dt,
  date_trunc('day',    creationtime) AS day_dt,
  date_trunc('minute', creationtime) AS minute_dt,
  to_char(creationtime, 'Month')     AS month_dn,
  to_char(creationtime, 'Dy')        AS weekday_dn,
  to_char(creationtime, 'DD')        AS day_dn,
  to_char(creationtime, 'YYYY')      AS year_dn,
  extract(year   FROM creationtime)  AS year_dp,
  extract(month  FROM creationtime)  AS month_dp,
  extract(day    FROM creationtime)  AS day_dp,
  extract(hour   FROM creationtime)  AS hour_dp,
  extract(quarter FROM creationtime) AS quarter_dp,
  extract(week    FROM creationtime) AS week_dp
FROM sales.orders;

/* TASK 3: Aggregate by year */
SELECT date_trunc('year', creationtime) AS creation_year, COUNT(*) AS ordercount
FROM sales.orders
GROUP BY 1;

/* TASK 4: EOMONTH equivalent */
SELECT orderid,
       creationtime,
       /* last day of month */
       (date_trunc('month', creationtime)::date + INTERVAL '1 month' - INTERVAL '1 day')::date AS end_of_month
FROM sales.orders;

/* TASK 5/6/7/8: counts by parts */
SELECT extract(year FROM orderdate) AS orderyear, COUNT(*) AS totalorders
FROM sales.orders
GROUP BY 1;

SELECT extract(month FROM orderdate) AS ordermonth, COUNT(*) AS totalorders
FROM sales.orders
GROUP BY 1;

SELECT to_char(orderdate, 'Month') AS ordermonth, COUNT(*) AS totalorders
FROM sales.orders
GROUP BY 1;

SELECT * FROM sales.orders WHERE extract(month FROM orderdate) = 2;

/* TASK 9/10/11: formatting -> to_char */
SELECT orderid,
       creationtime,
       to_char(creationtime, 'MM-DD-YYYY') AS usa_format,
       to_char(creationtime, 'DD-MM-YYYY') AS euro_format,
       to_char(creationtime, 'DD')         AS dd,
       to_char(creationtime, 'Dy')         AS ddd,
       to_char(creationtime, 'Day')        AS dddd,
       to_char(creationtime, 'Mon')        AS mon,
       to_char(creationtime, 'Month')      AS month
FROM sales.orders;

SELECT orderid,
       creationtime,
       'Day ' || to_char(creationtime, 'Dy Mon') ||
       ' Q' || to_char(creationtime, 'Q') || ' ' ||
       to_char(creationtime, 'YYYY HH12:MI:SS AM') AS customformat
FROM sales.orders;

SELECT to_char(creationtime, 'Mon YY') AS orderdate, COUNT(*) AS totalorders
FROM sales.orders
GROUP BY 1;

/* TASK 12: CONVERT equivalents */
SELECT
  CAST('123' AS INT)                       AS string_to_int,
  DATE '2025-08-20'                        AS string_to_date,
  creationtime,
  CAST(creationtime AS DATE)               AS datetime_to_date,
  to_char(creationtime, 'YYYY-MM-DD"T"HH24:MI:SS') AS iso_like
FROM sales.orders;

/* TASK 13: CAST */
SELECT
  CAST('123' AS INT)           AS string_to_int,
  CAST(123 AS VARCHAR)         AS int_to_string,
  CAST('2025-08-20' AS DATE)   AS string_to_date,
  CAST('2025-08-20' AS TIMESTAMP) AS string_to_timestamp,
  creationtime,
  CAST(creationtime AS DATE)   AS datetime_to_date
FROM sales.orders;

/* TASK 14: DATEADD / DATEDIFF analogs */
SELECT orderid,
       orderdate,
       orderdate - INTERVAL '10 days' AS ten_days_before,
       orderdate + INTERVAL '3 months' AS three_months_later,
       orderdate + INTERVAL '2 years'  AS two_years_later
FROM sales.orders;

/* TASK 15: Age in years */
SELECT employeeid, birthdate,
       EXTRACT(YEAR FROM age(now(), birthdate))::int AS age_years
FROM sales.employees;

/* TASK 16: Avg ship duration (days) */
SELECT extract(month FROM orderdate) AS ordermonth,
       AVG(EXTRACT(day FROM (shipdate - orderdate))) AS avgship_days
FROM sales.orders
GROUP BY 1;

/* TASK 17: Gap between orders */
SELECT orderid,
       orderdate AS currentorderdate,
       LAG(orderdate) OVER (ORDER BY orderdate) AS previousorderdate,
       EXTRACT(DAY FROM (orderdate - LAG(orderdate) OVER (ORDER BY orderdate))) AS nr_of_days
FROM sales.orders;

/* TASK 18: ISDATE-ish validation via regex */
WITH t(orderdate) AS (
  SELECT '2025-08-20' UNION ALL
  SELECT '2025-08-21' UNION ALL
  SELECT '2025-08-23' UNION ALL
  SELECT '2025-08'
)
SELECT orderdate,
       (orderdate ~ '^\d{4}-\d{2}-\d{2}$') AS isvaliddate,
       CASE WHEN orderdate ~ '^\d{4}-\d{2}-\d{2}$' THEN orderdate::date
            ELSE DATE '9999-01-01'
       END AS neworderdate
FROM t;
