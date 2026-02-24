-- =============================================
-- LIMPIEZA DE DATOS - Staging Superstore
-- =============================================

-- ---------------------------------------------
-- PASO 1: Verificar duplicados antes de limpiar
-- ---------------------------------------------
WITH Duplicados AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Order_ID, Product_ID
            ORDER BY Row_ID
        ) AS NumFila
    FROM Staging_Superstore
)
SELECT * FROM Duplicados WHERE NumFila > 1;
-- Resultado esperado: 8 filas duplicadas


-- ---------------------------------------------
-- PASO 2: Eliminar filas duplicadas exactas
-- Criterio: conservar la fila con menor Row_ID
-- ---------------------------------------------
WITH Duplicados AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY Order_ID, Product_ID
            ORDER BY Row_ID
        ) AS NumFila
    FROM Staging_Superstore
)
DELETE FROM Duplicados WHERE NumFila > 1;

-- Verificar que quedaron 9,986 filas
SELECT COUNT(*) AS TotalFilas FROM Staging_Superstore;



-- ---------------------------------------------
-- PASO 3: Identificar Product_IDs con múltiples 
-- nombres distintos
-- Resultado: 32 Product_IDs afectados
-- ---------------------------------------------
SELECT 
    Product_ID, 
    COUNT(DISTINCT Product_Name) AS NombresDistintos
FROM Staging_Superstore
GROUP BY Product_ID
HAVING COUNT(DISTINCT Product_Name) > 1
ORDER BY NombresDistintos DESC;


-- ---------------------------------------------
-- PASO 4: Inspeccionar un caso específico
-- para entender la naturaleza del problema
-- ---------------------------------------------
SELECT 
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    COUNT(*) AS Frecuencia
FROM Staging_Superstore
WHERE Product_ID = 'FUR-BO-10002213'
GROUP BY Product_ID, Product_Name, Category, Sub_Category;

-- HALLAZGO: El mismo Product_ID tiene asignados
-- nombres de productos completamente diferentes.
-- Decisión: conservar el nombre con mayor frecuencia
-- de aparición como registro canónico.

-- ---------------------------------------------
-- PASO 5: Validar la solución antes de insertar
-- Ver qué nombre quedaría seleccionado por cada ID
-- ---------------------------------------------
SELECT Product_ID, Product_Name, Category, SubCategory
FROM (
    SELECT 
        Product_ID, Product_Name, Category,
        Sub_Category AS SubCategory,
        COUNT(*) AS Frecuencia,
        ROW_NUMBER() OVER (
            PARTITION BY Product_ID
            ORDER BY COUNT(*) DESC
        ) AS NumFila
    FROM Staging_Superstore
    GROUP BY Product_ID, Product_Name, Category, Sub_Category
) AS Ranked
WHERE NumFila = 1
ORDER BY Product_ID;

-- ---------------------------------------------
-- NOTA: La resolución definitiva de Product_IDs
-- duplicados se aplica directamente en el INSERT
-- del archivo 05_populate_tables.sql
-- ---------------------------------------------