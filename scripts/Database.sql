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


