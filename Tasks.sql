--- Basic SQL Tasks ---
--- Task 1. List all customers from New Tracy.
SELECT * FROM Customers
WHERE Location = 'New Tracy';
--- Task 2. Insert a new product.
INSERT INTO products(ProductID, Name, Category, Price, SupplierID, StockQuantity) VALUES
(501, 'LightningCard', 'Electronics', 450.70, 75, 420);
--- Task 3. Update the stock quantity of a product.
BEGIN TRANSACTION;
UPDATE products SET StockQuantity = 421 WHERE ProductID = 501;
ROLLBACK TRANSACTION;
--- Task 4. Delete a customer record.
BEGIN TRANSACTION;
DELETE FROM Customers WHERE CustomerID = 36;
ROLLBACK TRANSACTION;


--- Intermediate SQL Tasks ---
--- Task 5. Find the average price of all products in the 'Electronics' category
SELECT AVG(Price) AS AveragePrice
FROM Products
WHERE Category = 'Electronics';

--- Task 6. List the top 5 most expensive products in each category.
--- Intermediate SQL Tasks ---
SELECT ProductID, Name, Category, Price
FROM Products p1
WHERE (
    SELECT COUNT(DISTINCT p2.Price)
    FROM Products p2
    WHERE p2.Category = p1.Category AND p2.Price >= p1.Price
) <= 5
   OR p1.Price = (
       SELECT MAX(p3.Price)
       FROM Products p3
       WHERE p3.Category = p1.Category
   )
ORDER BY Category, Price DESC;

--- Task 7. Find the total number of orders placed in 2023.
SELECT COUNT(*) AS TotalOrders
FROM Orders
WHERE YEAR(OrderDate) = 2023;


--- Advanced Data Manipulation Tasks ---
--- Task 8. Change the category of all products with less than 20 in stock to 'Clearance'.
UPDATE Products
SET Category = 'Clearance'
WHERE StockQuantity < 20;
SELECT * FROM Products WHERE Category = 'Clearance';
--- Task 9. Find customers who have placed more than 3 orders.
SELECT * FROM Customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM Orders
    GROUP BY CustomerID
    HAVING COUNT(*) > 3
);

--- Advanced SQL Concepts and Joins Tasks ---
--- Task 10. List all products that have never been ordered.
SELECT p.ProductID, p.Name, p.Category, p.Price
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
WHERE od.ProductID IS NULL;

--- Task 11. Find the total sales amount for each customer.
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(od.Quantity * od.UnitPrice) AS TotalSalesAmount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.Name;

--- Task 12. Identify products supplied by more than one supplier.
SELECT
    ProductID,
    Name AS ProductName,
    COUNT(DISTINCT SupplierID) AS NumSuppliers
FROM Products
GROUP BY ProductID, Name
HAVING COUNT(DISTINCT SupplierID) > 1;
--- Task 13. List all customers who ordered a specific product (e.g., ProductID = 100).
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    o.OrderID,
    o.OrderDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE od.ProductID = 100;
--- Task 14. Find the top 3 most popular product categories based on the number of orders.
SELECT TOP 3
    p.Category,
    COUNT(o.OrderID) AS NumOrders
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY p.Category
ORDER BY NumOrders DESC;

--- Task 15. Calculate the monthly sales totals for the current year, broken down by product category.
SELECT
    p.Category,
    MONTH(o.OrderDate) AS Month,
    YEAR(o.OrderDate) AS Year,
    SUM(od.Quantity * od.UnitPrice) AS MonthlySalesTotal
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = YEAR(GETDATE()) -- Assuming SQL Server syntax for current date
GROUP BY p.Category, MONTH(o.OrderDate), YEAR(o.OrderDate)
ORDER BY p.Category, YEAR(o.OrderDate), MONTH(o.OrderDate);

--- Task 16. Identify customers who have only ordered products from one specific category (e.g., 'Electronics').
SELECT c.CustomerID, c.Name 
FROM customers c 
JOIN orders o ON c.customerid = o.customerid 
JOIN OrderDetails od ON o.orderid = od.orderid 
JOIN products p ON od.ProductId = p.productid 
GROUP BY c.customerid, c.Name 
HAVING COUNT(DISTINCT p.category)= 1;

--- Task 17. List the average, minimum, and maximum prices of products ordered by each customer, along with the total number of orders.
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    AVG(od.UnitPrice) AS AveragePrice,
    MIN(od.UnitPrice) AS MinPrice,
    MAX(od.UnitPrice) AS MaxPrice,
    COUNT(DISTINCT o.OrderID) AS TotalOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.Name
ORDER BY c.CustomerID;

--- Task 18. Find all products that have a price above the average price of products in their category.
SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.Category,
    p.Price
FROM Products p
WHERE p.Price > (
    SELECT AVG(Price)
    FROM Products
    WHERE Category = p.Category
);
--- Task 19. Determine the total sales (quantity * unit price) for each supplier.
SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY s.SupplierID, s.Name
ORDER BY s.SupplierID;

--- Task 20. Identify the most recent order date for each customer.
SELECT CustomerID, MAX(OrderDate) RecentOrderDate
FROM Orders 
GROUP BY CustomerID
--- Task 21. Find customers who have placed orders totaling more than $5000 but have not made any orders in the last 6 months.
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(od.Quantity * od.UnitPrice) AS TotalOrderAmount,
    MAX(o.OrderDate) AS MostRecentOrderDate
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID, c.Name
HAVING SUM(od.Quantity * od.UnitPrice) > 5000
    AND MAX(o.OrderDate) IS NULL OR MAX(o.OrderDate) < DATEADD(MONTH, -6, GETDATE());
--- Task 22. List all products that were never sold and are supplied by more than or equal to one supplier.
SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.Category,
    p.Price
FROM Products p
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
WHERE od.ProductID IS NULL
    AND p.ProductID IN (
        SELECT ProductID
        FROM Products
        GROUP BY ProductID
        HAVING COUNT(DISTINCT SupplierID) >= 1
    );
--- Task 23. Identify monthly sales totals.
SELECT
    MONTH(o.OrderDate) AS Month,
    YEAR(o.OrderDate) AS Year,
    SUM(od.Quantity * od.UnitPrice) AS MonthlySalesTotal
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY Year, Month;
--- Task 24. Determine popular product categories in different locations which have more than 1 order.
SELECT
    c.Location,
    p.Category,
    COUNT(DISTINCT o.OrderID) AS NumOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.Location, p.Category
HAVING COUNT(DISTINCT o.OrderID) > 1;

--- Task 25. Evaluate suppliers based on product demand and stock levels.
SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT od.OrderID) AS NumOrders,
    SUM(od.Quantity) AS TotalDemand,
    SUM(p.StockQuantity) AS TotalStock
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY s.SupplierID, s.Name
ORDER BY TotalDemand DESC, TotalStock DESC;