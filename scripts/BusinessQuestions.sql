/*Business Questions & Analysis*/

-- 1. Distribution by Country
SELECT country, 
       COUNT(customer_key) AS total_customers
FROM dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- 2. Distribution by Gender
SELECT gender, 
       COUNT(customer_key) AS total_customers,
       ROUND(COUNT(customer_key)::NUMERIC / SUM(COUNT(customer_key)) OVER () * 100, 2) AS percentage_distribution
FROM dim_customers
WHERE gender <> 'n/a'
GROUP BY gender
ORDER BY total_customers DESC;

-- 3. Distribution by Age Group (Example: 20-30, 31-40)
SELECT CASE 
           WHEN AGE(birthdate)::TEXT BETWEEN '20 years' AND '30 years' THEN '20-30'
           WHEN AGE(birthdate)::TEXT BETWEEN '31 years' AND '40 years' THEN '31-40'
           ELSE '40+'
       END AS age_group,
       COUNT(customer_key) AS total_customers
FROM dim_customers
GROUP BY age_group
ORDER BY total_customers DESC;

-- Monthly Sales Trends
SELECT EXTRACT(YEAR FROM order_date) AS year, 
       EXTRACT(MONTH FROM order_date) AS month,
       SUM(sales_amount) AS total_sales
FROM fact_sales
GROUP BY year, month
ORDER BY year, month;

-- Product Performance
-- 1. Top-Performing Products by Revenue
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

-- 2. Profitability Analysis (Revenue vs Cost)
SELECT p.product_name,
       SUM(f.sales_amount) - (SUM(f.quantity) * p.cost) AS profit_margin
FROM fact_sales f
JOIN dim_products p 
    ON f.product_key = p.product_key
GROUP BY p.product_name, p.cost
ORDER BY profit_margin DESC;