--Step 1. Ensure that the staging tables created in the "Data modeling for DWH" lesson are in place. If not, you must create them.
--These tables will be used to load the initial data, and the star schema will be organized around a fact table and related dimension tables.

-- Verifies all required staging tables exist , as i have created those tables in "Data modeling for DWH" task.

WITH needed(tbl) AS (
  VALUES
   ('staging_orders'),
   ('staging_order_details'),
   ('staging_products'),
   ('staging_categories'),
   ('staging_suppliers'),
   ('staging_customers'),
   ('staging_employees'),
   ('staging_shippers')
)
SELECT n.tbl,
       CASE WHEN t.table_name IS NULL THEN 'MISSING' ELSE 'OK' END AS status
FROM needed n
LEFT JOIN information_schema.tables t
  ON t.table_schema='stg' AND t.table_name=n.tbl
ORDER BY n.tbl;


-- output: 
"tbl"	"status"
"staging_categories"	"OK"
"staging_customers"	"OK"
"staging_employees"	"OK"
"staging_order_details"	"OK"
"staging_orders"	"OK"
"staging_products"	"OK"
"staging_shippers"	"OK"
"staging_suppliers"	"OK"