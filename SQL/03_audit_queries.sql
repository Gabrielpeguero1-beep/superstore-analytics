-- =============================================
-- AUDITORÍA DE DATOS - Staging Superstore
-- =============================================

-- 1. Verificar total de filas cargadas
SELECT COUNT(*) AS TotalFilas FROM Staging_Superstore;

-- 2. Detectar nulos o vacíos en columnas críticas
SELECT
    SUM(CASE WHEN Order_ID     IS NULL OR Order_ID     = '' THEN 1 ELSE 0 END) AS Nulos_OrderID,
    SUM(CASE WHEN Customer_ID  IS NULL OR Customer_ID  = '' THEN 1 ELSE 0 END) AS Nulos_CustomerID,
    SUM(CASE WHEN Product_ID   IS NULL OR Product_ID   = '' THEN 1 ELSE 0 END) AS Nulos_ProductID,
    SUM(CASE WHEN Sales        IS NULL OR Sales        = '' THEN 1 ELSE 0 END) AS Nulos_Sales,
    SUM(CASE WHEN Postal_Code  IS NULL OR Postal_Code  = '' THEN 1 ELSE 0 END) AS Nulos_PostalCode
FROM Staging_Superstore;

-- 3. Detectar duplicados en OrderID + ProductID
SELECT 
    Order_ID, 
    Product_ID, 
    COUNT(*) AS Repeticiones
FROM Staging_Superstore
GROUP BY Order_ID, Product_ID
HAVING COUNT(*) > 1
ORDER BY Repeticiones DESC;

-- 4. Validar valores categóricos
SELECT DISTINCT Segment, COUNT(*) AS Frecuencia
FROM Staging_Superstore
GROUP BY Segment
ORDER BY Frecuencia DESC;

SELECT DISTINCT Region, COUNT(*) AS Frecuencia
FROM Staging_Superstore
GROUP BY Region
ORDER BY Frecuencia DESC;

SELECT DISTINCT Category, COUNT(*) AS Frecuencia
FROM Staging_Superstore
GROUP BY Category
ORDER BY Frecuencia DESC;

SELECT DISTINCT Ship_Mode, COUNT(*) AS Frecuencia
FROM Staging_Superstore
GROUP BY Ship_Mode
ORDER BY Frecuencia DESC;

-- 5. Validar que Sales, Profit y Quantity sean numéricos
SELECT COUNT(*) AS Valores_No_Numericos
FROM Staging_Superstore
WHERE ISNUMERIC(Sales)    = 0
   OR ISNUMERIC(Profit)   = 0
   OR ISNUMERIC(Quantity) = 0;

-- 6. Validar coherencia de fechas
SELECT COUNT(*) AS Fechas_Incoherentes
FROM Staging_Superstore
WHERE CAST(Ship_Date AS DATE) < CAST(Order_Date AS DATE);

-- 7. Detectar Product_IDs con múltiples nombres
SELECT Product_ID, COUNT(DISTINCT Product_Name) AS NombresDistintos
FROM Staging_Superstore
GROUP BY Product_ID
HAVING COUNT(DISTINCT Product_NAME) > 1
ORDER BY NombresDistintos DESC;

-- 8. Verificar conteos finales de tablas definitivas
SELECT 'Customers'    AS Tabla, COUNT(*) AS Filas FROM Customers    UNION ALL
SELECT 'Geography'    AS Tabla, COUNT(*) AS Filas FROM Geography     UNION ALL
SELECT 'Products'     AS Tabla, COUNT(*) AS Filas FROM Products      UNION ALL
SELECT 'Orders'       AS Tabla, COUNT(*) AS Filas FROM Orders        UNION ALL
SELECT 'OrderDetails' AS Tabla, COUNT(*) AS Filas FROM OrderDetails;