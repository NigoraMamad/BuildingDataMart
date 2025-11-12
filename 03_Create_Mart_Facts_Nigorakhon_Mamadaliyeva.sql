-- Step 3. Create suitable fact tables for each mart.

-- Suppliers mart
CREATE TABLE IF NOT EXISTS dwh.FactSupplierPurchases (
  PurchaseID SERIAL PRIMARY KEY,
  SupplierID INT REFERENCES dwh.DimSupplier(SupplierID),
  PurchaseDate DATE NOT NULL,
  TotalPurchaseAmount NUMERIC(12,2),
  NumberOfProducts INT
);

-- Products mart
CREATE TABLE IF NOT EXISTS dwh.FactProductSales (
  FactProductSalesID SERIAL PRIMARY KEY,
  DateID INT REFERENCES dwh.DimDate(DateID),
  ProductID INT REFERENCES dwh.DimProduct(ProductID),
  QuantitySold INT,
  TotalSales NUMERIC(12,2)
);

-- Customers mart
CREATE TABLE IF NOT EXISTS dwh.FactCustomerSales (
  FactCustomerSalesID SERIAL PRIMARY KEY,
  DateID INT REFERENCES dwh.DimDate(DateID),
  CustomerID VARCHAR(10) REFERENCES dwh.DimCustomer(CustomerID),
  TotalAmount NUMERIC(12,2),
  TotalQuantity INT,
  NumberOfTransactions INT
);

-- Helpful indexes for query performance
CREATE INDEX IF NOT EXISTS idx_fsp_supplier ON dwh.FactSupplierPurchases(SupplierID);
CREATE INDEX IF NOT EXISTS idx_fsp_date     ON dwh.FactSupplierPurchases(PurchaseDate);
CREATE INDEX IF NOT EXISTS idx_fps_date     ON dwh.FactProductSales(DateID);
CREATE INDEX IF NOT EXISTS idx_fps_product  ON dwh.FactProductSales(ProductID);
CREATE INDEX IF NOT EXISTS idx_fcs_date     ON dwh.FactCustomerSales(DateID);
CREATE INDEX IF NOT EXISTS idx_fcs_customer ON dwh.FactCustomerSales(CustomerID);
