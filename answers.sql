-- ========================================
-- Question 1: Achieving 1NF (First Normal Form)
-- ========================================

-- Step 1: Create the original table with multi-value products
CREATE TABLE ProductDetail_Original (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Insert the original data
INSERT INTO ProductDetail_Original VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 2: Transform to 1NF by separating products into individual rows
-- This query creates a normalized table where each row represents one product per order

CREATE TABLE ProductDetail_1NF AS
SELECT 
    OrderID,
    CustomerName,
    'Laptop' AS Product
FROM ProductDetail_Original 
WHERE Products LIKE '%Laptop%'

UNION ALL

SELECT 
    OrderID,
    CustomerName,
    'Mouse' AS Product
FROM ProductDetail_Original 
WHERE Products LIKE '%Mouse%'

UNION ALL

SELECT 
    OrderID,
    CustomerName,
    'Tablet' AS Product
FROM ProductDetail_Original 
WHERE Products LIKE '%Tablet%'

UNION ALL

SELECT 
    OrderID,
    CustomerName,
    'Keyboard' AS Product
FROM ProductDetail_Original 
WHERE Products LIKE '%Keyboard%'

UNION ALL

SELECT 
    OrderID,
    CustomerName,
    'Phone' AS Product
FROM ProductDetail_Original 
WHERE Products LIKE '%Phone%';

-- Alternative approach using string functions (MySQL/PostgreSQL specific)
-- This is a more dynamic approach but syntax varies by database system

/*
-- For MySQL:
CREATE TABLE ProductDetail_1NF AS
SELECT 
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', numbers.n), ',', -1)) AS Product
FROM ProductDetail_Original
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
    SELECT 4 UNION ALL SELECT 5
) numbers 
ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= numbers.n - 1;
*/

-- ========================================
-- Question 2: Achieving 2NF (Second Normal Form)
-- ========================================

-- Step 1: Create the 1NF table from Question 2 data
CREATE TABLE OrderDetails_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(50),
    Quantity INT
);

-- Insert the given data
INSERT INTO OrderDetails_1NF VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Step 2: Transform to 2NF by separating tables to remove partial dependencies

-- Create Orders table (removes partial dependency of CustomerName on OrderID)
CREATE TABLE Orders_2NF AS
SELECT DISTINCT 
    OrderID,
    CustomerName
FROM OrderDetails_1NF;

-- Create OrderProducts table (contains only columns that depend on the full composite key)
CREATE TABLE OrderProducts_2NF AS
SELECT 
    OrderID,
    Product,
    Quantity
FROM OrderDetails_1NF;

-- Verification: Query to reconstruct the original data using JOINs
SELECT 
    op.OrderID,
    o.CustomerName,
    op.Product,
    op.Quantity
FROM OrderProducts_2NF op
JOIN Orders_2NF o ON op.OrderID = o.OrderID
ORDER BY op.OrderID, op.Product;

-- ========================================
-- SUMMARY QUERIES
-- ========================================

-- View 1NF Results:
SELECT * FROM ProductDetail_1NF ORDER BY OrderID, Product;

-- View 2NF Results:
SELECT 'Orders Table (2NF)' as TableName;
SELECT * FROM Orders_2NF ORDER BY OrderID;

SELECT 'OrderProducts Table (2NF)' as TableName;
SELECT * FROM OrderProducts_2NF ORDER BY OrderID, Product;
