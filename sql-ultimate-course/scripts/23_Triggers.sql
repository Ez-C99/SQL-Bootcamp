/* ==============================================================================
   SQL Triggers
-------------------------------------------------------------------------------
   This script demonstrates the creation of a logging table, a trigger, and
   an insert operation into the Sales.Employees table that fires the trigger.
   The trigger logs details of newly added employees into the Sales.EmployeeLogs table.
=================================================================================
*/

SET search_path TO sales, mydatabase, public;

/* ==============================================================================
   Employee insert logger (PostgreSQL)
   - T-SQL: IDENTITY, GETDATE(), INSERTED, GO
   - PG:    GENERATED ALWAYS AS IDENTITY, CURRENT_DATE/now(), NEW, plpgsql trigger
============================================================================== */

-- Log table
DROP TABLE IF EXISTS sales.employeelogs;
CREATE TABLE sales.employeelogs (
  logid       BIGSERIAL PRIMARY KEY,
  employeeid  INT NOT NULL,
  logmessage  VARCHAR(255),
  logdate     DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Trigger function
CREATE OR REPLACE FUNCTION sales.fn_log_employee_insert()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO sales.employeelogs (employeeid, logmessage, logdate)
  VALUES (NEW.employeeid,
          'New Employee Added = ' || NEW.employeeid::text,
          CURRENT_DATE);
  RETURN NEW;
END
$$;

-- Trigger on Sales.Employees
DROP TRIGGER IF EXISTS trg_after_insert_employee ON sales.employees;
CREATE TRIGGER trg_after_insert_employee
AFTER INSERT ON sales.employees
FOR EACH ROW
EXECUTE FUNCTION sales.fn_log_employee_insert();

-- Demo insert
INSERT INTO sales.employees (employeeid, firstname, lastname, department, birthdate, gender, salary, managerid)
VALUES (6, 'Maria', 'Doe', 'HR', '1988-01-12', 'F', 80000, 3);

-- Check logs
SELECT * FROM sales.employeelogs ORDER BY logid DESC;
