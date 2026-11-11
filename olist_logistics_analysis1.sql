-- OLIST BRAZILIAN E-COMMERCE LOGISTICS ANALYSIS
-- MySQL 8.0+. Source: nine Olist CSV files from the Brazilian E-Commerce Public Dataset.
-- Import each CSV into its matching table after running the CREATE TABLE section.
CREATE DATABASE IF NOT EXISTS olist_logistics;
USE olist_logistics;

CREATE TABLE IF NOT EXISTS customers (customer_id VARCHAR(40) PRIMARY KEY, customer_unique_id VARCHAR(40), customer_zip_code_prefix VARCHAR(10), customer_city VARCHAR(120), customer_state CHAR(2));
CREATE TABLE IF NOT EXISTS geolocation (geolocation_zip_code_prefix VARCHAR(10), geolocation_lat DECIMAL(10,7), geolocation_lng DECIMAL(10,7), geolocation_city VARCHAR(120), geolocation_state CHAR(2), INDEX idx_geo_zip(geolocation_zip_code_prefix));
CREATE TABLE IF NOT EXISTS order_items (order_id VARCHAR(40), order_item_id INT, product_id VARCHAR(40), seller_id VARCHAR(40), shipping_limit_date DATETIME, price DECIMAL(12,2), freight_value DECIMAL(12,2), INDEX idx_items_order(order_id), INDEX idx_items_product(product_id), INDEX idx_items_seller(seller_id));
CREATE TABLE IF NOT EXISTS order_payments (order_id VARCHAR(40), payment_sequential INT, payment_type VARCHAR(40), payment_installments INT, payment_value DECIMAL(12,2), INDEX idx_payments_order(order_id));
CREATE TABLE IF NOT EXISTS order_reviews (review_id VARCHAR(40), order_id VARCHAR(40), review_score INT, review_comment_title TEXT, review_comment_message TEXT, review_creation_date DATETIME, review_answer_timestamp DATETIME, INDEX idx_reviews_order(order_id));
CREATE TABLE IF NOT EXISTS orders (order_id VARCHAR(40) PRIMARY KEY, customer_id VARCHAR(40), order_status VARCHAR(30), order_purchase_timestamp DATETIME, order_approved_at DATETIME NULL, order_delivered_carrier_date DATETIME NULL, order_delivered_customer_date DATETIME NULL, order_estimated_delivery_date DATETIME, INDEX idx_orders_customer(customer_id), INDEX idx_orders_status(order_status), INDEX idx_orders_purchase(order_purchase_timestamp));
CREATE TABLE IF NOT EXISTS products (product_id VARCHAR(40) PRIMARY KEY, product_category_name VARCHAR(120), product_name_lenght INT NULL, product_description_lenght INT NULL, product_photos_qty INT NULL, product_weight_g INT NULL, product_length_cm INT NULL, product_height_cm INT NULL, product_width_cm INT NULL);
CREATE TABLE IF NOT EXISTS sellers (seller_id VARCHAR(40) PRIMARY KEY, seller_zip_code_prefix VARCHAR(10), seller_city VARCHAR(120), seller_state CHAR(2));
CREATE TABLE IF NOT EXISTS product_category_translation (product_category_name VARCHAR(120), product_category_name_english VARCHAR(120));

-- Q1. Dataset size and order status distribution
SELECT COUNT(*) AS total_orders FROM orders;
SELECT order_status, COUNT(*) AS order_count FROM orders GROUP BY order_status ORDER BY order_count DESC;
-- Q2. Data quality: null delivery/approval timestamps
SELECT SUM(order_delivered_customer_date IS NULL) AS missing_customer_delivery, SUM(order_delivered_carrier_date IS NULL) AS missing_carrier_handoff, SUM(order_approved_at IS NULL) AS missing_approval FROM orders;
-- Q3. Customer-region join
SELECT o.order_id,o.order_status,c.customer_city,c.customer_state FROM orders o JOIN customers c ON c.customer_id=o.customer_id LIMIT 100;
-- Q4. Items, products and sellers join
SELECT oi.order_id,oi.order_item_id,COALESCE(t.product_category_name_english,p.product_category_name) AS category,s.seller_city,s.seller_state,oi.price,oi.freight_value FROM order_items oi LEFT JOIN products p ON p.product_id=oi.product_id LEFT JOIN sellers s ON s.seller_id=oi.seller_id LEFT JOIN product_category_translation t ON t.product_category_name=p.product_category_name LIMIT 100;
-- Q5. Payment totals by order (payment table can contain multiple rows per order)
SELECT order_id,SUM(payment_value) AS total_payment_value FROM order_payments GROUP BY order_id LIMIT 100;
-- Q6. On-time/early delivery rate; only eligible delivered orders included
WITH d AS (SELECT order_id,DATE(order_delivered_customer_date) actual_date,DATE(order_estimated_delivery_date) promised_date FROM orders WHERE order_status='delivered' AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL)
SELECT COUNT(*) eligible_delivered_orders,SUM(actual_date<=promised_date) on_time_early_orders,SUM(actual_date>promised_date) late_orders,ROUND(100.0*SUM(actual_date<=promised_date)/NULLIF(COUNT(*),0),2) on_time_early_rate_pct FROM d;
-- Q7. Average delivery duration in days
SELECT ROUND(AVG(TIMESTAMPDIFF(SECOND,order_purchase_timestamp,order_delivered_customer_date))/86400,2) avg_delivery_duration_days FROM orders WHERE order_status='delivered' AND order_purchase_timestamp IS NOT NULL AND order_delivered_customer_date IS NOT NULL;
-- Q8. Average delay in days (negative means early)
SELECT ROUND(AVG(DATEDIFF(DATE(order_delivered_customer_date),DATE(order_estimated_delivery_date))),2) avg_delay_days FROM orders WHERE order_status='delivered' AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL;
-- Q9. Regional performance; minimum 30 eligible deliveries per state
SELECT c.customer_state,COUNT(*) eligible_delivered_orders,ROUND(100.0*AVG(DATE(o.order_delivered_customer_date)<=DATE(o.order_estimated_delivery_date)),2) on_time_early_rate_pct,ROUND(AVG(DATEDIFF(DATE(o.order_delivered_customer_date),DATE(o.order_estimated_delivery_date))),2) avg_delay_days FROM orders o JOIN customers c ON c.customer_id=o.customer_id WHERE o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL GROUP BY c.customer_state HAVING COUNT(*)>=30 ORDER BY on_time_early_rate_pct;
-- Q10. Average review score by delivery result
SELECT CASE WHEN DATE(o.order_delivered_customer_date)>DATE(o.order_estimated_delivery_date) THEN 'Late' ELSE 'On time / Early' END delivery_result,COUNT(DISTINCT o.order_id) reviewed_orders,ROUND(AVG(r.review_score),2) average_review_score FROM orders o JOIN order_reviews r ON r.order_id=o.order_id WHERE o.order_status='delivered' AND o.order_delivered_customer_date IS NOT NULL AND o.order_estimated_delivery_date IS NOT NULL GROUP BY delivery_result;
-- Q11. Cancellation rate
SELECT COUNT(*) total_orders,SUM(order_status='canceled') canceled_orders,ROUND(100.0*SUM(order_status='canceled')/NULLIF(COUNT(*),0),2) cancellation_rate_pct FROM orders;
-- Q12. Top 20 product categories by number of order items
SELECT COALESCE(t.product_category_name_english,p.product_category_name,'Unknown') category,COUNT(*) item_count,ROUND(SUM(oi.price),2) item_price_total,ROUND(SUM(oi.freight_value),2) freight_total FROM order_items oi LEFT JOIN products p ON p.product_id=oi.product_id LEFT JOIN product_category_translation t ON t.product_category_name=p.product_category_name GROUP BY category ORDER BY item_count DESC LIMIT 20;
-- Q13. Weekday delivery volume and late rate
SELECT DAYNAME(order_purchase_timestamp) purchase_weekday,COUNT(*) delivered_orders,ROUND(100.0*AVG(DATE(order_delivered_customer_date)>DATE(order_estimated_delivery_date)),2) late_rate_pct FROM orders WHERE order_status='delivered' AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL GROUP BY DAYOFWEEK(order_purchase_timestamp),DAYNAME(order_purchase_timestamp) ORDER BY DAYOFWEEK(order_purchase_timestamp);
-- Data note: geolocation has duplicate ZIP-prefix rows; aggregate/deduplicate before joining to avoid row multiplication.
