select * from orders;

-- Number of repeated customer --
select CustomerID, Count(OrderID) as Numberofcustomer from orders
group by CustomerID
having Count(OrderID) > 1;

SELECT COUNT(*) AS RepeatCustomerCount
FROM (	select CustomerID, Count(OrderID) as Numberofcustomer from orders
group by CustomerID
having Count(OrderID) > 1
) AS repeat_customers;

-- Repeat vs One-time Customer Revenue Comparison--
SELECT 
    CASE WHEN order_count > 1 THEN 'Repeat' ELSE 'One-time' END AS CustomerType,
    SUM(total_revenue) AS TotalRevenue,
    COUNT(*) AS NumberOfCustomers
FROM (
    SELECT CustomerID, COUNT(OrderID) AS order_count, SUM(FinalAmount) AS total_revenue
    FROM orders
    GROUP BY CustomerID
) AS customer_summary
GROUP BY CustomerType;

-- Category-wise true revenue and order count --
SELECT p.Category,
SUM(oi.LineTotal / o.OrderValue * o.FinalAmount) AS TrueRevenue,
COUNT(DISTINCT oi.OrderID) AS NumberOfOrders
FROM order_items oi
INNER JOIN products p ON oi.ProductID = p.ProductID
INNER JOIN orders o ON oi.OrderID = o.OrderID
GROUP BY p.Category
ORDER BY TrueRevenue DESC;

-- Warehouse delivery performance --
SELECT WarehouseID, AVG(DeliveryTimeMinutes) AS AvgDeliveryTime
FROM orders
GROUP BY WarehouseID
ORDER BY AvgDeliveryTime DESC;

-- Return & Cancellation Rate by Product Category ---
SELECT
    p.Category,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN o.Status = 'Returned' THEN 1 ELSE 0 END) AS ReturnedOrders,
    SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
    ROUND(SUM(CASE WHEN o.Status = 'Returned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ReturnRatePercent,
    ROUND(SUM(CASE WHEN o.Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CancelRatePercent
FROM orders o
INNER JOIN order_items oi ON o.OrderID = oi.OrderID
INNER JOIN products p ON oi.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY ReturnRatePercent DESC;

-- Payment Method vs Cancellation Rate --
SELECT 
    PaymentMethod,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
    ROUND(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS CancelRatePercent
FROM orders
GROUP BY PaymentMethod
ORDER BY CancelRatePercent DESC;

-- Delivery Time vs Customer Rating --
SELECT 
    CASE 
        WHEN DeliveryTimeMinutes < 15 THEN 'Fast'
        WHEN DeliveryTimeMinutes BETWEEN 15 AND 20 THEN 'Medium'
        ELSE 'Slow'
    END AS DeliverySpeed,
    COUNT(*) AS TotalOrders,
    ROUND(AVG(Rating), 2) AS AvgRating
FROM orders
GROUP BY DeliverySpeed
ORDER BY AvgRating DESC;

-- Revenue by City or Warehouse Location --
SELECT 
    w.City,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.FinalAmount) AS TotalRevenue
FROM orders o
INNER JOIN warehouses w ON o.WarehouseID = w.WarehouseID
GROUP BY w.City
ORDER BY TotalRevenue DESC;

-- Warehouse Order Coverage Check --
SELECT 
    w.WarehouseID,
    w.City,
    COUNT(o.OrderID) AS TotalOrders
FROM warehouses w
LEFT JOIN orders o ON w.WarehouseID = o.WarehouseID
GROUP BY w.WarehouseID, w.City
ORDER BY TotalOrders ASC;