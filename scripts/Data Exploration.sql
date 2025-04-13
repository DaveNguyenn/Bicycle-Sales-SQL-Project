/* Database Exploration
-------------------------------------------------------------------------------------------------
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.
*/

-- Retrieve a list of all tables in the database
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve all columns for a table (Example: fact_sales)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';

-- Retrieve total rows and columns in each table
SELECT 'dim_customers' AS table_name, COUNT(*) AS row_count FROM dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM dim_products
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;

-- Check duplicate rows
SELECT customer_key, customer_id, customer_number, first_name, last_name, country, marital_status, gender, birthdate, create_date,
       COUNT(*) AS duplicate
FROM dim_customers
GROUP BY customer_key, customer_id, customer_number, first_name, last_name, country, marital_status, gender, birthdate, create_date
HAVING COUNT(*) > 1;

-- Check NULL values
SELECT *
FROM dim_products
WHERE start_date IS NULL;

-- Count of customer 
SELECT COUNT(DISTINCT customer_key) AS total_customer
FROM dim_customers;

-- Find total customers by gender with percentage distribution
SELECT 
    gender,
    COUNT(customer_key) AS total_customers,
    ROUND(COUNT(customer_key)::NUMERIC / SUM(COUNT(customer_key)) OVER () * 100, 2) AS percentage_distribution
FROM dim_customers
WHERE gender <> 'n/a'
GROUP BY gender
ORDER BY total_customers DESC;

/*
Dimensions Exploration
-------------------------------------------------------------------------------------------------
Purpose:
    - To explore the structure of dimension tables.
SQL Function Used: DISTINCT, ORDER BY
*/

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT country 
FROM dim_customers
ORDER BY country;

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT category, 
  		        subcategory, 
                product_name 
FROM dim_products
ORDER BY category, subcategory, product_name;

-- Find total products by category, subcategory
SELECT category, subcategory,
       COUNT(product_key) AS total_products
FROM dim_products
GROUP BY category, subcategory
ORDER BY total_products DESC;

-- What is the total revenue generated for each category?
SELECT p.category, p.subcategory,
       SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category, p.subcategory
ORDER BY total_revenue DESC;

/*
Date Range Exploration 
-------------------------------------------------------------------------------------------------
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of data.
SQL Function Used: MIN(), MAX(), DATE_PART(), AGE()
*/

-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    (DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12 + 
     DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))) AS order_range_months
FROM fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
    MIN(birthdate) AS oldest_birthdate,
	DATE_PART('year', AGE(CURRENT_DATE, MIN(birthdate))) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATE_PART('year', AGE(CURRENT_DATE, MAX(birthdate))) AS youngest_age
FROM dim_customers;

-- What is the range (earliest and latest dates) of timestamps?
SELECT MIN(order_date) AS earliest_order_date, MAX(order_date) AS latest_order_date
FROM fact_sales;

-- How many records fall within specific intervals
SELECT *
FROM fact_sales
WHERE order_date >= CURRENT_DATE - INTERVAL '15 years';

-- Seasonal patterns in the data
SELECT EXTRACT(YEAR FROM order_date) AS year,
       EXTRACT(MONTH FROM order_date) AS month,
       COUNT(*) AS orders
FROM fact_sales
GROUP BY year, month
ORDER BY year, month;

/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.
	- To create a summary view for overview purposes.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
	- CREATE VIEW
===============================================================================
*/

-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM fact_sales

-- Find the average selling price
SELECT AVG(price) AS avg_price FROM fact_sales

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders FROM fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_orders FROM fact_sales;

-- Find the total number of products
SELECT COUNT(product_name) AS total_products FROM dim_products;

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM fact_sales;

-- Generate a Report that shows all key metrics of the business via CREATE VIEW
CREATE OR REPLACE VIEW business_metrics AS
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM dim_customers
UNION ALL 
SELECT 'Avg. Shipping Duration', AVG(shipping_date - order_date) FROM fact_sales;

-- Call the data from the business_metrics VIEW
SELECT * FROM business_metrics;
