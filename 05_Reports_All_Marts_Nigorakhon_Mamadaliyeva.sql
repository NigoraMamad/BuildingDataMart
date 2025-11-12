-- Step 5. Query the data marts to deliver actionable insights for Suppliers, Products, and Customers.

-- suppliers mart reports

-- 1) Supplier performance scorecard
SELECT
  s.companyname,
  COUNT(sp.purchaseid)                AS total_orders,
  SUM(sp.totalpurchaseamount)         AS total_purchase_value,
  AVG(sp.numberofproducts)            AS avg_products_per_order
FROM dwh.factsupplierpurchases sp
JOIN dwh.dimsupplier s ON s.supplierid = sp.supplierid
GROUP BY s.companyname
ORDER BY total_orders DESC, total_purchase_value DESC;

--output:
"companyname"	"total_orders"	"total_purchase_value"	"avg_products_per_order"
"Pavlova, Ltd."	2	3521.15	1.5000000000000000
"Grandma Kelly's Homestead"	2	1199.90	1.5000000000000000
"Mayumi's"	2	1157.40	1.5000000000000000
"New Orleans Cajun Delights"	2	980.25	1.00000000000000000000
"Exotic Liquids"	2	890.90	1.5000000000000000
"Specialty Biscuits, Ltd."	1	3294.95	2.0000000000000000
"Cooperativa de Quesos 'Las Cabras'"	1	1304.95	2.0000000000000000
"Tokyo Traders"	1	639.90	2.0000000000000000

-- 2) Supplier spending by Year / Month
SELECT
  s.companyname,
  EXTRACT(YEAR  FROM sp.purchasedate) AS year,
  EXTRACT(MONTH FROM sp.purchasedate) AS month,
  SUM(sp.totalpurchaseamount)         AS total_spend
FROM dwh.factsupplierpurchases sp
JOIN dwh.dimsupplier s ON s.supplierid = sp.supplierid
GROUP BY s.companyname, year, month
ORDER BY total_spend DESC;

-- output:
"companyname"	"year"	"month"	"total_spend"
"Pavlova, Ltd."	2012	8	3521.15
"Specialty Biscuits, Ltd."	2012	8	3294.95
"Cooperativa de Quesos 'Las Cabras'"	2012	8	1304.95
"Grandma Kelly's Homestead"	2012	8	1199.90
"Mayumi's"	2012	8	1157.40
"New Orleans Cajun Delights"	2012	8	980.25
"Exotic Liquids"	2012	7	690.95
"Tokyo Traders"	2012	8	639.90
"Exotic Liquids"	2012	8	199.95

-- 3) Top-5 suppliers by total spend
SELECT
  s.companyname,
  SUM(sp.totalpurchaseamount) AS total_spend
FROM dwh.factsupplierpurchases sp
JOIN dwh.dimsupplier s ON s.supplierid = sp.supplierid
GROUP BY s.companyname
ORDER BY total_spend DESC
LIMIT 5;

-- output: 
"companyname"	"total_spend"
"Pavlova, Ltd."	3521.15
"Specialty Biscuits, Ltd."	3294.95
"Cooperativa de Quesos 'Las Cabras'"	1304.95
"Grandma Kelly's Homestead"	1199.90
"Mayumi's"	1157.40

-- products mart reports

-- 4) Top-selling products by revenue
SELECT
  p.productname,
  SUM(fps.quantitysold) AS total_quantity_sold,
  SUM(fps.totalsales)   AS total_revenue
FROM dwh.factproductsales fps
JOIN dwh.dimproduct p ON p.productid = fps.productid
GROUP BY p.productname
ORDER BY total_revenue DESC
LIMIT 10;

-- output:

"productname"	"total_quantity_sold"	"total_revenue"
"Sir Rodney's Marmalade"	35	2834.95
"Carnarvon Tigers"	40	2500.00
"Queso Cabrales"	35	734.95
"Tofu"	30	697.50
"Chef Anton's Cajun Seasoning"	30	660.00
"Alice Mutton"	15	584.90
"Queso Manchego La Pastora"	15	570.00
"Grandma's Boysenberry Spread"	20	499.95
"Mishi Kobe Niku"	5	485.00
"Chang"	25	475.00

-- 5) Sales trends by category per Year/Month
SELECT
  c.categoryname,
  d."Year",
  d."Month",
  SUM(fps.quantitysold) AS total_qty,
  SUM(fps.totalsales)   AS total_revenue
FROM dwh.factproductsales fps
JOIN dwh.dimproduct  p ON p.productid  = fps.productid
JOIN dwh.dimcategory c ON c.categoryid = p.categoryid
JOIN dwh.dimdate     d ON d.dateid     = fps.dateid
GROUP BY c.categoryname, d."Year", d."Month"
ORDER BY d."Year", d."Month", total_revenue DESC;

-- output:
"categoryname"	"Year"	"Month"	"total_qty"	"total_revenue"
"Beverages"	2012	7	37	690.95
"Confections"	2012	8	110	3731.20
"Seafood"	2012	8	70	2804.85
"Condiments"	2012	8	115	2390.05
"Dairy Products"	2012	8	50	1304.95
"Meat/Poultry"	2012	8	20	1069.90
"Produce"	2012	8	40	997.50

-- 6) Inventory valuation snapshot 
SELECT
  p.productid,
  p.productname,
  p.unitsinstock,
  p.unitprice,
  (p.unitsinstock * p.unitprice) AS inventory_value
FROM dwh.dimproduct p
ORDER BY inventory_value DESC;

-- output(partially)
"productid"	"productname"	"unitsinstock"	"unitprice"	"inventory_value"
12	"Queso Manchego La Pastora"	86	38.00	3268.00
20	"Sir Rodney's Marmalade"	40	81.00	3240.00
6	"Grandma's Boysenberry Spread"	120	25.00	3000.00
9	"Mishi Kobe Niku"	29	97.00	2813.00
18	"Carnarvon Tigers"	42	62.50	2625.00
4	"Chef Anton's Cajun Seasoning"	53	22.00	1166.00
10	"Ikura"	31	31.00	961.00
14	"Tofu"	35	23.25	813.75
1	"Chai"	39	18.00	702.00
11	"Queso Cabrales"	28	22.00	616.00
15	"Genen Shouyu"	39	15.50	604.50
16	"Pavlova"	29	17.45	506.05
7	"Uncle Bob's Organic Dried Pears"	15	30.00	450.00
2	"Chang"	17	19.00	323.00
8	"Northwoods Cranberry Sauce"	6	40.00	240.00
19	"Teatime Chocolate Biscuits"	25	9.20	230.00
13	"Konbu"	24	6.00	144.00
3	"Aniseed Syrup"	13	10.00	130.00
21	"AppleJuice"	20	5.50	110.00
22	"AppleJuice"	20	5.50	110.00
17	"Alice Mutton"	0	39.00	0.00
5	"Chef Anton's Gumbo Mix"	0	21.35	0.00

-- customers mart reports

-- 7) Customer sales overview
SELECT
  c.companyname,
  SUM(fcs.totalamount)          AS total_spent,
  SUM(fcs.totalquantity)        AS total_items,
  SUM(fcs.numberoftransactions) AS transactions
FROM dwh.factcustomersales fcs
JOIN dwh.dimcustomer c ON c.customerid = fcs.customerid
GROUP BY c.companyname
ORDER BY total_spent DESC;

--output:
"companyname"	"total_spent"	"total_items"	"transactions"
"B's Beverages"	3294.95	85	2
"Bottom-Dollar Markets"	3084.90	55	2
"Blondesddsl père et fils"	1304.95	50	2
"Ana Trujillo Emparedados y helados"	859.95	50	2
"Bólido Comidas preparadas"	847.45	55	2
"Antonio Moreno Taquería"	820.20	35	2
"Bon app'"	746.20	45	2
"Around the Horn"	699.95	20	2
"Alfreds Futterkiste"	690.95	37	2
"Berglunds snabbköp"	639.90	10	2

-- 8) Top customers by total spend
SELECT
  c.companyname,
  SUM(fcs.totalamount) AS total_spent
FROM dwh.factcustomersales fcs
JOIN dwh.dimcustomer c ON c.customerid = fcs.customerid
GROUP BY c.companyname
ORDER BY total_spent DESC
LIMIT 10;

-- output:
"companyname"	"total_spent"
"B's Beverages"	3294.95
"Bottom-Dollar Markets"	3084.90
"Blondesddsl père et fils"	1304.95
"Ana Trujillo Emparedados y helados"	859.95
"Bólido Comidas preparadas"	847.45
"Antonio Moreno Taquería"	820.20
"Bon app'"	746.20
"Around the Horn"	699.95
"Alfreds Futterkiste"	690.95
"Berglunds snabbköp"	639.90

-- 9) Customers by region 
SELECT
  COALESCE(c.region, '(Unknown)') AS region,
  COUNT(DISTINCT c.customerid)    AS customers,
  SUM(fcs.totalamount)            AS region_spend
FROM dwh.factcustomersales fcs
JOIN dwh.dimcustomer c ON c.customerid = fcs.customerid
GROUP BY COALESCE(c.region, '(Unknown)')
ORDER BY customers DESC;

-- output:
"region"	"customers"	"region_spend"
"(Unknown)"	10	12989.40

-- TREND / HEALTH CHECKS

-- 10) Monthly revenue (Products mart)
WITH monthly AS (
  SELECT d."Year", d."Month", SUM(fps.totalsales) AS total_sales
  FROM dwh.factproductsales fps
  JOIN dwh.dimdate d ON d.dateid = fps.dateid
  GROUP BY d."Year", d."Month"
)
SELECT
  m."Year",
  m."Month",
  m.total_sales,
  LAG(m.total_sales) OVER (ORDER BY m."Year", m."Month") AS prev_month_sales,
  ROUND(
    (m.total_sales - LAG(m.total_sales) OVER (ORDER BY m."Year", m."Month"))
    / NULLIF(LAG(m.total_sales) OVER (ORDER BY m."Year", m."Month"), 0),
    4
  ) AS growth_rate
FROM monthly m
ORDER BY m."Year", m."Month";

-- output:

"Year"	"Month"	"total_sales"	"prev_month_sales"	"growth_rate"
2012	7	1371.15		
2012	8	24266.95	1371.15	16.6982

-- 11) Sanity check: totals across marts should reconcile (approximately equal)
-- (a) FactSales baseline
SELECT
  SUM(COALESCE(fs.totalamount, fs.quantitysold * fs.unitprice * (1 - fs.discount))) AS fs_total
FROM dwh.factsales fs;

-- output: 

"fs_total"
12989.40

-- (b) Products mart total
SELECT SUM(totalsales) AS products_total FROM dwh.factproductsales;

-- output: 

"products_total"
12989.40

-- (c) Customers mart total
SELECT SUM(totalamount) AS customers_total FROM dwh.factcustomersales;

-- output: 

"customers_total"
12989.40

-- (d) Suppliers mart total
SELECT SUM(totalpurchaseamount) AS suppliers_total FROM dwh.factsupplierpurchases;

-- output: 

"suppliers_total"
12989.40
