# Bicycle Sales and Supply Chain Analytics using SQL

## Overview
This project involves a comprehensive analysis of bicycle sales data using PostgreSQL.
The goal of this project is to perform an in-depth Exploratory Data Analysis (EDA) on the provided dataset to:
1.	Understand customer demographics.
2.	Analyze sales trends over time.
3.	Evaluate product performance to identify top-performing products and categories.
4.	Providing a consolidated report for quick reference and decision-making.

## Dataset
The analysis is conducted on a relational database consisting of three tables:
1.	dim_customers - Contains information about customers, including demographic details such as country, gender, marital status, and birthdate.
2.	dim_products - Stores details about products, including product category, cost, and product line.
3.	fact_sales - Captures transaction data, linking products and customers through their keys, and includes information such as order dates, shipping dates, sales amounts, and quantities.

## Data Schema
```sql
DROP TABLE IF EXISTS dim_customers;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS fact_sales;

--Create dim_customers Table
CREATE TABLE dim_customers(
	customer_key int,
	customer_id int,
	customer_number VARCHAR(50),
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	country VARCHAR(50),
	marital_status VARCHAR(50),
	gender VARCHAR(50),
	birthdate date,
	create_date date
);

--Create dim_products Table
CREATE TABLE dim_products(
	product_key int ,
	product_id int ,
	product_number VARCHAR(50) ,
	product_name VARCHAR(50) ,
	category_id VARCHAR(50) ,
	category VARCHAR(50) ,
	subcategory VARCHAR(50) ,
	maintenance VARCHAR(50) ,
	cost int,
	product_line VARCHAR(50),
	start_date date 
);

-- Create fact_sales Table
CREATE TABLE fact_sales(
	order_number varchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity int,
	price int 
);

-- Assign Primary Key to dim_customers
ALTER TABLE dim_customers
ADD CONSTRAINT pk_customer_key PRIMARY KEY (customer_key);

-- Assign Primary Key to dim_products
ALTER TABLE dim_products
ADD CONSTRAINT pk_product_key PRIMARY KEY (product_key);

-- Assign Primary Key to fact_sales
ALTER TABLE fact_sales
ADD CONSTRAINT pk_order_number PRIMARY KEY (order_number);

-- Add Foreign Key to fact_sales linking to dim_customers
ALTER TABLE fact_sales
ADD CONSTRAINT fk_customer_key
FOREIGN KEY (customer_key)
REFERENCES dim_customers(customer_key);

-- Add Foreign Key to fact_sales linking to dim_products
ALTER TABLE fact_sales
ADD CONSTRAINT fk_product_key
FOREIGN KEY (product_key)
REFERENCES dim_products(product_key);
```
## Database Exploration
Purpose:
	To explore the structure of the database.
	Inspect columns and metadata for specific tables.

## 1. Retrieve a list of all tables in the public schema
```sql
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'public';
```
## 2. Retrieve all columns for a table (Example: fact_sales)
```sql
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';
```
## 3. Combine total rows for each table into a single view
```sql
SELECT 'dim_customers' AS table_name, COUNT(*) AS row_count FROM dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM dim_products
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;
```
## 4. Check duplicate rows in dim_customers
```sql
SELECT customer_key, COUNT(*) AS duplicate_count
FROM dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
```
## 5. Check NULL values in critical columns
```sql
SELECT *
FROM dim_products
WHERE start_date IS NULL;
```
## 6. Count distinct customers
```sql
SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM dim_customers;
```
## 7. Total customers by gender with percentage distribution
```sql
SELECT gender,
       COUNT(customer_key) AS total_customers,
       ROUND(COUNT(customer_key)::NUMERIC / SUM(COUNT(customer_key)) OVER () * 100, 2) AS percentage_distribution
FROM dim_customers
WHERE gender <> 'n/a'
GROUP BY gender
ORDER BY total_customers DESC;
```
## Dimensions Exploration
Purpose:
	Explore the structure of dimension tables.

## 1. List unique countries
```sql
SELECT DISTINCT country 
FROM dim_customers
ORDER BY country;
```
## 2. List unique categories, subcategories, and products
```sql
SELECT DISTINCT category, 
                subcategory, 
                product_name 
FROM dim_products
ORDER BY category, subcategory, product_name;
```
## 3. Total products by category and subcategory
```sql
SELECT category, subcategory,
       COUNT(product_key) AS total_products
FROM dim_products
GROUP BY category, subcategory
ORDER BY total_products DESC;
```
## 4. Total revenue generated for each category and subcategory
```sql
SELECT p.category, p.subcategory,
       COALESCE(SUM(f.sales_amount), 0) AS total_revenue
FROM dim_products p
LEFT JOIN fact_sales f
    ON p.product_key = f.product_key
GROUP BY p.category, p.subcategory
ORDER BY total_revenue DESC;
```

## Date Range Exploration
Purpose:
	Determine temporal boundaries of key data points.

## 1. First and last order date, total duration in months
```sql
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    (DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12 + 
     DATE_PART('month', AGE(MAX(order_date), MIN(order_date)))) AS order_range_months
FROM fact_sales;
```
## 2. Youngest and oldest customer by birthdate
```sql
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATE_PART('year', AGE(CURRENT_DATE, MIN(birthdate))) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATE_PART('year', AGE(CURRENT_DATE, MAX(birthdate))) AS youngest_age
FROM dim_customers;
```
## 3. Records within specific intervals (e.g., last 15 years)
```sql
SELECT *
FROM fact_sales
WHERE order_date >= CURRENT_DATE - INTERVAL '15 years';
```
## 4. Detect seasonal patterns
```sql
SELECT EXTRACT(MONTH FROM order_date) AS month,
       COUNT(*) AS monthly_orders
FROM fact_sales
GROUP BY month
ORDER BY month;
```

## Measures Exploration (Key Metrics)
Purpose:
	Calculate aggregated metrics for business insights.

## 1. Total Sales
```sql
SELECT SUM(sales_amount) AS total_sales 
FROM fact_sales;
```
## 2. Total items sold
```sql
SELECT SUM(quantity) AS total_quantity 
FROM fact_sales;
```
## 3. Average selling price
```sql
SELECT AVG(price) AS avg_price 
FROM fact_sales;
```
## 4. Total number of orders
```sql
SELECT COUNT(DISTINCT order_number) AS total_orders 
FROM fact_sales;
```
## 5. Total number of products
```sql
SELECT COUNT(DISTINCT product_key) AS total_products 
FROM dim_products;
```
## 6. Total customers with orders
```sql
SELECT COUNT(DISTINCT customer_key) AS total_customers_with_orders 
FROM fact_sales;
```
## 7. Average Shipping Duration
```sql
SELECT AVG(shipping_date - order_date) AS avg_shipping_duration
FROM fact_sales;
```
## 8. Business metrics view
```sql
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

-- View business metrics
SELECT * FROM business_metrics;
```

## Customer Demographics
Distribution of Customers by Country, Gender, Marital Status, and Age Group
## 1. Distribution by Country
```sql
SELECT country, 
       COUNT(customer_key) AS total_customers
FROM dim_customers
GROUP BY country
ORDER BY total_customers DESC;
```
## 2. Distribution by Gender
```sql
SELECT gender, 
       COUNT(customer_key) AS total_customers,
       ROUND(COUNT(customer_key)::NUMERIC / SUM(COUNT(customer_key)) OVER () * 100, 2) AS percentage_distribution
FROM dim_customers
WHERE gender <> 'n/a'
GROUP BY gender
ORDER BY total_customers DESC;
```
## 3. Distribution by Age Group (Example: 20-30, 31-40)
```sql
SELECT CASE 
           WHEN AGE(birthdate)::TEXT BETWEEN '20 years' AND '30 years' THEN '20-30'
           WHEN AGE(birthdate)::TEXT BETWEEN '31 years' AND '40 years' THEN '31-40'
           ELSE '40+'
       END AS age_group,
       COUNT(customer_key) AS total_customers
FROM dim_customers
GROUP BY age_group
ORDER BY total_customers DESC;
```

## Monthly Sales Trends
```sql
SELECT EXTRACT(YEAR FROM order_date) AS year, 
       EXTRACT(MONTH FROM order_date) AS month,
       SUM(sales_amount) AS total_sales
FROM fact_sales
GROUP BY year, month
ORDER BY year, month;
```
## Product Performance
## 1. Top-Performing Products by Revenue
```sql
SELECT p.product_name,
       p.category,
       SUM(f.sales_amount) AS total_revenue,
       SUM(f.quantity) AS total_quantity
FROM fact_sales f
JOIN dim_products p 
    ON f.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC;
```
## 2. Profitability Analysis (Revenue vs Cost)
```sql
SELECT p.product_name,
       SUM(f.sales_amount) - (SUM(f.quantity) * p.cost) AS profit_margin
FROM fact_sales f
JOIN dim_products p 
    ON f.product_key = p.product_key
GROUP BY p.product_name, p.cost
ORDER BY profit_margin DESC;
```
## Findings and Conclusion
**Findings**
1. Customer Demographics:
	Majority of customers are from the United States (50%) with balanced gender distribution (male: 50.58%, female: 49.42%).
	Customers aged 40+ dominate, making up 97% of the demographic.
2. Sales Trends:
	Peak sales in 2013 (16.3M) with strong performance in June and December.
	Significant drop in 2014 (45.6K), indicating potential operational or market challenges.
3. Product Performance & Profit Analysis
	Road Bikes lead with 14.5M revenue, followed by Mountain Bikes.
	Top-performing accessory: Tires and Tubes (244K revenue, 17K units).
	Clothing: Jerseys are the most popular item.
	Mountain-200 series is the most profitable, with margins exceeding 597K.
	Road-150 series also contributes significantly to profitability.
4. Business Metrics:
	Total revenue: 29.3M, total orders: 27.6K, and average shipping duration: 7 days.

**Conclusions & Recommendations**
	Focus marketing on the 40+ demographic, emphasizing lifestyle and comfort features.
	Target June and December for promotions due to seasonal demand.
	Expand popular product lines (Mountain-200, Road Bikes) while optimizing profits across categories.
	Investigate reasons behind the 2014 sales drop and explore supply chain improvements.
	Optimize shipping to improve efficiency and customer satisfaction.
