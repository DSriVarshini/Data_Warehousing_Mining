
-- =====================================================
-- DATA WAREHOUSING AND MINING (25AD2203E)
-- PRACTICAL 1: CALCULATE TOTAL SALES REVENUE
-- DATABASE: ShoppingDB
-- DBMS: PostgreSQL
-- =====================================================

-- IMPORTANT:
-- Connect to ShoppingDB before executing this script.
-- Do not execute CREATE DATABASE here.

-- =====================================================
-- STEP 1: CREATE CUSTOMERS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS Customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    email VARCHAR(100)
);

-- =====================================================
-- STEP 2: CREATE PRODUCTS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS Products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50)
);

-- =====================================================
-- STEP 3: CREATE ORDERS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES Customers(customer_id),
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL
);

-- =====================================================
-- STEP 4: RESET OLD CUSTOMER AND ORDER RECORDS
-- This ensures a clean and correct Practical 1 run.
-- Products are not deleted.
-- =====================================================

TRUNCATE TABLE Orders, Customers
RESTART IDENTITY CASCADE;

-- =====================================================
-- STEP 5: INSERT CUSTOMER RECORDS
-- =====================================================

INSERT INTO Customers
(customer_name, city, email)
VALUES
('Rahul', 'Hyderabad', 'rahul@gmail.com'),
('Priya', 'Vijayawada', 'priya@gmail.com'),
('Amit', 'Bangalore', 'amit@gmail.com');

-- =====================================================
-- STEP 6: INSERT PRODUCT RECORDS
-- =====================================================

INSERT INTO Products
(product_name, price, category)
SELECT v.product_name, v.price, v.category
FROM (VALUES
    ('Laptop', 55000, 'Electronics'),
    ('Mobile', 20000, 'Electronics'),
    ('Headphones', 2000, 'Accessories'),
    ('Keyboard', 1500, 'Accessories'),
    ('Monitor', 12000, 'Electronics')
) AS v(product_name, price, category)
WHERE NOT EXISTS (
    SELECT 1
    FROM Products p
    WHERE p.product_name = v.product_name
);

-- =====================================================
-- STEP 7: INSERT SAMPLE ORDER RECORDS
-- =====================================================

INSERT INTO Orders
(customer_id, order_date, total_amount)
VALUES
(1, '2026-01-10', 57000),
(2, '2026-01-12', 20000),
(3, '2026-02-05', 21500),
(1, '2026-02-10', 12000),
(2, '2026-02-15', 55000);

-- =====================================================
-- STEP 8: DISPLAY TABLE RECORDS
-- =====================================================

SELECT * FROM Customers ORDER BY customer_id;

SELECT * FROM Products ORDER BY product_id;

SELECT * FROM Orders ORDER BY order_id;

-- =====================================================
-- STEP 9: OLTP TRANSACTION - COMMIT
-- Insert a new order and permanently save it.
-- =====================================================

BEGIN;

INSERT INTO Orders
(customer_id, order_date, total_amount)
VALUES
(1, CURRENT_DATE, 55000);

COMMIT;

-- =====================================================
-- STEP 10: VERIFY COMMIT
-- =====================================================

SELECT * FROM Orders ORDER BY order_id;

-- =====================================================
-- STEP 11: OLTP TRANSACTION - ROLLBACK
-- Temporarily update an order and cancel the change.
-- =====================================================

BEGIN;

UPDATE Orders
SET total_amount = 100
WHERE order_id = 1;

ROLLBACK;

-- =====================================================
-- STEP 12: VERIFY ROLLBACK
-- Original order amount should remain 57000.
-- =====================================================

SELECT * FROM Orders
WHERE order_id = 1;

-- =====================================================
-- STEP 13: OLAP - CALCULATE TOTAL SALES REVENUE
-- =====================================================

SELECT
    SUM(total_amount) AS Total_Revenue
FROM Orders;

-- =====================================================
-- STEP 14: FINAL VERIFICATION
-- =====================================================

SELECT
    COUNT(*) AS Total_Orders,
    SUM(total_amount) AS Total_Revenue
FROM Orders;

-- =====================================================
-- END OF PRACTICAL 1
-- =====================================================
