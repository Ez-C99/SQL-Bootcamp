SET client_min_messages = WARNING;

-- ======================================================
-- Schema: mydatabase
-- ======================================================
DROP TABLE IF EXISTS mydatabase.orders;
DROP TABLE IF EXISTS mydatabase.customers;

CREATE TABLE mydatabase.customers (
    id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    country VARCHAR(50),
    score INT
);

INSERT INTO mydatabase.customers (id, first_name, country, score) VALUES
    (1, 'Maria', 'Germany', 350),
    (2, ' John', 'USA', 900),    -- note: leading space kept intentionally
    (3, 'Georg', 'UK', 750),
    (4, 'Martin', 'Germany', 500),
    (5, 'Peter', 'USA', 0);

CREATE TABLE mydatabase.orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    sales INT
    -- No FK on purpose (course has an orphan row below)
);

INSERT INTO mydatabase.orders (order_id, customer_id, order_date, sales) VALUES
    (1001, 1, '2021-01-11', 35),
    (1002, 2, '2021-04-05', 15),
    (1003, 3, '2021-06-18', 20),
    (1004, 6, '2021-08-31', 10); -- orphan: no customer_id=6
