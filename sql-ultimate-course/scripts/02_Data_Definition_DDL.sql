/* ==============================================================================
   SQL Data Definition Language (DDL)
-------------------------------------------------------------------------------
   This guide covers the essential DDL commands used for defining and managing
   database structures, including creating, modifying, and deleting tables.

   Table of Contents:
     1. CREATE - Creating Tables
     2. ALTER - Modifying Table Structure
     3. DROP - Removing Tables
=================================================================================
*/

SET search_path TO mydatabase, sales, public;

/* CREATE */
CREATE TABLE IF NOT EXISTS persons (
  id INT NOT NULL,
  person_name VARCHAR(50) NOT NULL,
  birth_date DATE,
  phone VARCHAR(15) NOT NULL,
  CONSTRAINT pk_persons PRIMARY KEY (id)
);

/* ALTER */
ALTER TABLE persons ADD COLUMN IF NOT EXISTS email VARCHAR(50) NOT NULL;
ALTER TABLE persons DROP COLUMN IF EXISTS phone;

/* DROP */
DROP TABLE IF EXISTS persons;
