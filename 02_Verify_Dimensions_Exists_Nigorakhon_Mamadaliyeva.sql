-- Step 2. Create dimension tables if none are available.
-- As all required dimensions were created & loaded in my previous task "Data modeling for DWH".
-- In this task I reuse them and verify they exist and are populated.

WITH needed(tbl) AS (
  VALUES
   ('dimdate'), ('dimcustomer'), ('dimproduct'),
   ('dimemployee'), ('dimcategory'), ('dimshipper'), ('dimsupplier')
)
SELECT 'Step 2: dimensions' AS step, n.tbl AS object,
       CASE WHEN t.table_name IS NULL THEN 'MISSING' ELSE 'OK' END AS status
FROM needed n
LEFT JOIN information_schema.tables t
  ON t.table_schema='dwh' AND t.table_name=n.tbl
ORDER BY n.tbl;

-- Quick row counts to know that they are populated:
SELECT 'dwh.dimdate' AS table, COUNT(*) AS rows FROM dwh.dimdate
UNION ALL SELECT 'dwh.dimcustomer', COUNT(*) FROM dwh.dimcustomer
UNION ALL SELECT 'dwh.dimproduct', COUNT(*) FROM dwh.dimproduct
UNION ALL SELECT 'dwh.dimemployee', COUNT(*) FROM dwh.dimemployee
UNION ALL SELECT 'dwh.dimcategory', COUNT(*) FROM dwh.dimcategory
UNION ALL SELECT 'dwh.dimshipper', COUNT(*) FROM dwh.dimshipper
UNION ALL SELECT 'dwh.dimsupplier', COUNT(*) FROM dwh.dimsupplier;

--output:

"table"	"rows"
"dwh.dimdate"	84
"dwh.dimcustomer"	20
"dwh.dimproduct"	22
"dwh.dimemployee"	20
"dwh.dimcategory"	10
"dwh.dimshipper"	10
"dwh.dimsupplier"	10
