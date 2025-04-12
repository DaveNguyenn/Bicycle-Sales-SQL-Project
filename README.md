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

