-- =============================================
-- POBLACIÓN DE TABLAS DEFINITIVAS
-- SuperstoreDB
-- Ejecutar en este orden estricto por FKs
-- =============================================

-- ---------------------------------------------
-- PASO 0: Limpiar tablas en orden inverso
-- (ejecutar solo si necesitas repoblar desde cero)
-- ---------------------------------------------
ALTER TABLE OrderDetails DROP CONSTRAINT FK_Det_Product;
TRUNCATE TABLE OrderDetails;
TRUNCATE TABLE Orders;
TRUNCATE TABLE Products;
TRUNCATE TABLE Geography;
TRUNCATE TABLE Customers;
ALTER TABLE OrderDetails
ADD CONSTRAINT FK_Det_Product
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);

-- ---------------------------------------------
-- PASO 1: Customers
-- ---------------------------------------------
INSERT INTO Customers (CustomerID, CustomerName, Segment)
SELECT DISTINCT 
    Customer_ID, 
    Customer_Name, 
    Segment
FROM Staging_Superstore;

SELECT COUNT(*) AS TotalCustomers FROM Customers;
-- Esperado: 793

-- ---------------------------------------------
-- PASO 2: Geography
-- ---------------------------------------------
INSERT INTO Geography (City, State, Region, Country, PostalCode)
SELECT DISTINCT 
    City, 
    State, 
    Region, 
    Country, 
    Postal_Code
FROM Staging_Superstore;

SELECT COUNT(*) AS TotalGeography FROM Geography;
-- Esperado: 632

-- ---------------------------------------------
-- PASO 3: Products
-- Usa ROW_NUMBER() para resolver los 32 Product_IDs
-- con nombres inconsistentes. Criterio: mayor frecuencia.
-- ---------------------------------------------
INSERT INTO Products (ProductID, ProductName, Category, SubCategory)
SELECT Product_ID, Product_Name, Category, SubCategory
FROM (
    SELECT 
        Product_ID, Product_Name, Category,
        Sub_Category AS SubCategory,
        ROW_NUMBER() OVER (
            PARTITION BY Product_ID
            ORDER BY COUNT(*) DESC
        ) AS NumFila
    FROM Staging_Superstore
    GROUP BY Product_ID, Product_Name, Category, Sub_Category
) AS Ranked
WHERE NumFila = 1;

SELECT COUNT(*) AS TotalProducts FROM Products;
-- Esperado: 1,862

-- ---------------------------------------------
-- PASO 4: Orders
-- Requiere JOIN con Geography para obtener GeoID
-- ---------------------------------------------
INSERT INTO Orders (OrderID, OrderDate, ShipDate, ShipMode, CustomerID, GeoID)
SELECT DISTINCT
    s.Order_ID,
    CAST(s.Order_Date AS DATE),
    CAST(s.Ship_Date  AS DATE),
    s.Ship_Mode,
    s.Customer_ID,
    g.GeoID
FROM Staging_Superstore s
INNER JOIN Geography g 
    ON  s.City        = g.City
    AND s.State       = g.State
    AND s.Postal_Code = g.PostalCode;

SELECT COUNT(*) AS TotalOrders FROM Orders;
-- Esperado: 5,009

-- ---------------------------------------------
-- PASO 5: OrderDetails
-- ---------------------------------------------
INSERT INTO OrderDetails (OrderID, ProductID, Sales, Quantity, Discount, Profit)
SELECT
    Order_ID,
    Product_ID,
    CAST(Sales    AS DECIMAL(10,2)),
    CAST(Quantity AS INT),
    CAST(Discount AS DECIMAL(5,4)),
    CAST(Profit   AS DECIMAL(10,2))
FROM Staging_Superstore;

SELECT COUNT(*) AS TotalOrderDetails FROM OrderDetails;
-- Esperado: 9,986

-- ---------------------------------------------
-- VERIFICACIÓN FINAL
-- ---------------------------------------------
SELECT 'Customers'    AS Tabla, COUNT(*) AS Filas FROM Customers    UNION ALL
SELECT 'Geography'    AS Tabla, COUNT(*) AS Filas FROM Geography     UNION ALL
SELECT 'Products'     AS Tabla, COUNT(*) AS Filas FROM Products      UNION ALL
SELECT 'Orders'       AS Tabla, COUNT(*) AS Filas FROM Orders        UNION ALL
SELECT 'OrderDetails' AS Tabla, COUNT(*) AS Filas FROM OrderDetails;
```
