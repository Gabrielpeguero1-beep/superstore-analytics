CREATE TABLE Staging_Superstore (
    RowID        VARCHAR(20),
    OrderID      VARCHAR(20),
    OrderDate    VARCHAR(20),   -- lo dejamos texto por ahora, lo convertiremos después
    ShipDate     VARCHAR(20),
    ShipMode     VARCHAR(50),
    CustomerID   VARCHAR(20),
    CustomerName VARCHAR(100),
    Segment      VARCHAR(50),
    Country      VARCHAR(50),
    City         VARCHAR(100),
    State        VARCHAR(100),
    PostalCode   VARCHAR(20),
    Region       VARCHAR(50),
    ProductID    VARCHAR(20),
    Category     VARCHAR(50),
    SubCategory  VARCHAR(50),
    ProductName  VARCHAR(255),
    Sales        VARCHAR(20),
    Quantity     VARCHAR(10),
    Discount     VARCHAR(10),
    Profit       VARCHAR(20)
);