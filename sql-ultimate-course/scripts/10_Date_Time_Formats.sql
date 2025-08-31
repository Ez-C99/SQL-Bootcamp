/* ==============================================================================
   SQL Date & Time Functions
-------------------------------------------------------------------------------
   This script shows all possible date parts, number formats, and 
   culture-specific styles available in SQL Server.
   
   Table of Contents:
     1. Number Format Specifiers
     2. Date Format Specifiers
     3. All Date Parts
     4. All Culture Formats
===============================================================================
*/

-- In PostgreSQL, use to_char(...) for formatting dates/numbers.

SELECT
  to_char(now(), 'YYYY-MM-DD')    AS iso_date,
  to_char(now(), 'Mon DD, YYYY')  AS nice_date,
  to_char(now(), 'HH24:MI:SS')    AS time_24h,
  to_char(now(), 'Dy, Mon DD')    AS day_mon,
  to_char(now(), 'FMDay')         AS day_full_trimmed,
  to_char(now(), '"Q"Q YYYY')     AS quarter_year;

-- Date parts (extract)
SELECT
  extract(year FROM now())   AS year_dp,
  extract(month FROM now())  AS month_dp,
  extract(day FROM now())    AS day_dp,
  extract(week FROM now())   AS week_dp,
  extract(quarter FROM now()) AS quarter_dp;

-- Number formatting with to_char
SELECT
  1234.56::numeric                                AS original,
  to_char(1234.56::numeric, 'FM9,999.00')         AS us_style,
  to_char(1234.56::numeric, 'FM999G999D00')       AS locale_aware,
  to_char(1234.0::numeric,  'FM9,999.00')         AS forced_decimals;

-- Month name formatting
SELECT
  to_char(d::date, 'YYYY-MM-DD') AS day,
  to_char(d::date, 'Mon')        AS mon_abbrev,
  to_char(d::date, 'Month')      AS mon_full
FROM generate_series(date '2025-01-01', date '2025-01-07', interval '1 day') AS g(d);
