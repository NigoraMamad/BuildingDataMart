-- Step 4. Populate the fact tables for each data mart (Suppliers, Products, Customers).
-- as dwh.factsales is already populated in the previous task, i will load dwh.factproductsales, dwh.factcustomersales, dwh.factsupplierpurchases


-- check what columns i have in dwh.factsales
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'dwh' AND table_name = 'factsales'
ORDER BY ordinal_position;

--output:
"column_name"
"salesid"
"dateid"
"customerid"
"productid"
"employeeid"
"categoryid"
"shipperid"
"supplierid"
"quantitysold"
"unitprice"
"discount"
"totalamount"
"taxamount"

-- Normalize sales amount to reuse
CREATE OR REPLACE TEMP VIEW fs_norm AS
SELECT
  fs.salesid,
  fs.dateid,
  fs.customerid,
  fs.productid,
  fs.employeeid,
  fs.categoryid,
  fs.shipperid,
  fs.supplierid,
  fs.quantitysold,
  fs.unitprice,
  fs.discount,
  COALESCE(
    fs.totalamount,
    (fs.quantitysold * fs.unitprice * (1 - fs.discount))::numeric
  ) AS lineamount
FROM dwh.factsales fs;


-- Clear target mart tables first to avoid duplicate loads
TRUNCATE TABLE dwh.factproductsales, dwh.factcustomersales, dwh.factsupplierpurchases RESTART IDENTITY;

-- products data mart load
-- Grain: (dateid, productid)
-- Columns: quantitysold (sum), totalsales (sum of amount)

INSERT INTO dwh.factproductsales (dateid, productid, quantitysold, totalsales)
SELECT
  dateid,
  productid,
  SUM(quantitysold) AS quantitysold,
  SUM(lineamount)   AS totalsales
FROM fs_norm
GROUP BY dateid, productid;

-- customers data mart load
-- Grain: (dateid, customerid)
-- numberoftransactions: distinct salesid (order-line count proxy)

INSERT INTO dwh.factcustomersales (dateid, customerid, totalamount, totalquantity, numberoftransactions)
SELECT
  dateid,
  customerid,
  SUM(lineamount)        AS totalamount,
  SUM(quantitysold)      AS totalquantity,
  COUNT(DISTINCT salesid) AS numberoftransactions
FROM fs_norm
GROUP BY dateid, customerid;

-- suppliers data mart load
-- Grain: (supplierid, purchasedate)
-- purchasedate is resolved from dateid via dwh.dimdate(date)

INSERT INTO dwh.factsupplierpurchases (supplierid, purchasedate, totalpurchaseamount, numberofproducts)
SELECT
  fn.supplierid,
  d."Date" AS purchasedate,
  SUM(fn.lineamount)       AS totalpurchaseamount,
  COUNT(DISTINCT fn.productid) AS numberofproducts
FROM fs_norm fn
JOIN dwh.dimdate d ON d.dateid = fn.dateid
GROUP BY fn.supplierid, d."Date";

--  verify that tables got rows after load
SELECT 'factproductsales' AS table, COUNT(*) AS rows FROM dwh.factproductsales
UNION ALL SELECT 'factcustomersales', COUNT(*) FROM dwh.factcustomersales
UNION ALL SELECT 'factsupplierpurchases', COUNT(*) FROM dwh.factsupplierpurchases;

-- output:
"table"	"rows"
"factproductsales"	20
"factcustomersales"	10
"factsupplierpurchases"	13

