OLIST SQL PROJECT - SUBMISSION PACKAGE

CONTENTS
1. olist_logistics_analysis.sql - MySQL 8.0+ CREATE TABLE statements and 13 analysis queries.
2. Olist_SQL_Project_Report.docx - project report with findings calculated from the supplied nine CSV source files.
3. data_audit_and_kpis.xlsx - file audit, KPI summary, regional performance, review comparison and top product categories.
4. delivered_orders_kpi.csv - one row per eligible delivered order with delivery duration and delay.

DATASET
The analysis uses the nine original Olist CSV files: customers, geolocation, order_items, order_payments, order_reviews, orders, products, sellers and product_category_name_translation. Keep the original dataset ZIP as backup.

TO RUN THE SQL
1. Install/start MySQL Server 8.0 and open MySQL Workbench.
2. Open olist_logistics_analysis.sql and execute the CREATE DATABASE and CREATE TABLE statements.
3. Import each original CSV into its matching table. The table names are: customers, geolocation, order_items, order_payments, order_reviews, orders, products, sellers, product_category_translation.
4. Run the analysis queries in the SQL file.

IMPORTANT ACCURACY NOTE
The report's numerical findings were calculated directly from the supplied CSV data using Python/pandas. The SQL script is provided for MySQL 8.0+ but has not been executed on the user's local MySQL server. Do not describe it as live-executed unless you run it in MySQL and verify the results.
