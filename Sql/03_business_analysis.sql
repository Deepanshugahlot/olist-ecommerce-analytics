SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_sellers
FROM sellers;

-- ==========================================
-- OVERVIEW KPIs
-- ==========================================

-- Total Sales Revenue

-- KPI 1 : Total Sales Revenue

SELECT
    ROUND(SUM(price), 2) AS total_sales_revenue
FROM order_items;

-- KPI 2 : Total Product Sold

SELECT COUNT(product_id) AS total_product_sold
FROM order_items;

-- KPI 3 : Average Order Value (AOV)

SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM
(
    SELECT
        order_id,
        SUM(price + freight_value) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_summary;

-- ==========================================
-- PRODUCT ANALYSIS
-- ==========================================

-- KPI 1: Top 10 Product Categories by Revenue

Select pcn.product_category_name_english, sum(ot.price) as revenue from order_items ot
join products p 
on p.product_id = ot.product_id
join product_category_name_translation pcn
on pcn.product_category_name = p.product_category_name
group by pcn.product_category_name_english
order by revenue desc
limit 10;

-- KPI 2: Top 10 Best Selling Products

select product_id, count(product_id) as units_sold from order_items
group by product_id
order by units_sold desc
limit 10;

-- KPI 3: Top 10 Product Categories by Units Sold

select pcn.product_category_name_english, count(ot.product_id) as units_sold from order_items ot
join products p 
on ot.product_id = p.product_id
join product_category_name_translation pcn
on p.product_category_name = pcn.product_category_name
group by pcn.product_category_name_english
order by units_sold desc
limit 10;

-- KPI 4: Top 10 Product Categories by Average Selling Price

select pcn.product_category_name_english, round(avg(ot.price),2) as avg_selling_price from order_items ot
join products p 
on ot.product_id = p.product_id
join product_category_name_translation pcn
on p.product_category_name = pcn.product_category_name
group by pcn.product_category_name_english
order by avg_selling_price desc
limit 10;

-- KPI 5: Top 10 Product Categories by Freight Cost

select pcn.product_category_name_english, round(sum(freight_value),2) as freight_cost from order_items ot
join products p 
on ot.product_id = p.product_id
join product_category_name_translation pcn
on p.product_category_name = pcn.product_category_name
group by pcn.product_category_name_english
order by freight_cost desc
limit 10;

-- KPI 6: Category Revenue Contribution (%)

SELECT 
	pcn.product_category_name_english, 
    SUM(ot.price) AS total_revenue, 
    ROUND(SUM(ot.price)/(SELECT SUM(price) FROM order_items)*100, 2) AS revenue_contribution_pct
FROM order_items ot
JOIN products p 
ON ot.product_id = p.product_id
JOIN product_category_name_translation pcn
ON p.product_category_name = pcn.product_category_name
GROUP BY pcn.product_category_name_english
ORDER BY revenue_contribution_pct DESC;

-- KPI 7: Average Number of Products per Order

SELECT ROUND(COUNT(product_id)/COUNT(DISTINCT order_id), 2) AS average_products_per_order FROM order_items;

-- KPI 8: Products Never Sold

SELECT p.product_id FROM products p 
LEFT JOIN order_items ot
ON p.product_id = ot.product_id
GROUP BY p.product_id
HAVING COUNT(ot.product_id) = 0;

-- KPI 9: Top 10 Most Expensive Products Sold

SELECT ot.product_id, pcn.product_category_name_english, MAX(ot.price) AS highest_selling_price FROM order_items ot
JOIN products p 
ON p.product_id = ot.product_id
JOIN product_category_name_translation pcn
ON pcn.product_category_name = p.product_category_name
GROUP BY ot.product_id, pcn.product_category_name_english
ORDER BY highest_selling_price DESC
LIMIT 10;

-- KPI 10: Top 10 Categories by Average Freight Percentage

WITH cte AS(
	SELECT *, freight_value/price*100 AS freight_pct FROM order_items
)
SELECT pcn.product_category_name_english, ROUND(AVG(c.freight_pct), 2) AS avg_freight_pct FROM cte c
JOIN products p 
ON p.product_id = c.product_id
JOIN product_category_name_translation pcn
ON pcn.product_category_name = p.product_category_name
GROUP BY pcn.product_category_name_english
ORDER BY avg_freight_pct DESC
LIMIT 10;

-- KPI 11: Product Price Distribution

SELECT 
	CASE WHEN price <= 50 THEN '0-50'
		 WHEN price > 50 AND price <= 100 THEN '50-100'
         WHEN price > 100 AND price <= 200 THEN '100-200'
         WHEN price > 200 AND price <= 500 THEN '200-500'
		 ELSE '500+'
    END AS price_range,
    COUNT(DISTINCT product_id) AS products
FROM order_items
GROUP BY price_range;

-- KPI 12: Products Sold Only Once

SELECT ot.product_id, pcn.product_category_name_english, COUNT(*) AS times_sold FROM order_items ot
JOIN products p 
ON p.product_id = ot.product_id
JOIN product_category_name_translation pcn
ON pcn.product_category_name = p.product_category_name
GROUP BY ot.product_id, pcn.product_category_name_english
HAVING COUNT(*) = 1;

-- KPI 13: Products Purchased by Only One Customer

SELECT ot.product_id, pcn.product_category_name_english AS category ,COUNT(DISTINCT o.customer_id) AS unique_customer FROM orders o
JOIN order_items ot
ON o.order_id = ot.order_id
JOIN products p 
ON p.product_id = ot.product_id
JOIN product_category_name_translation pcn
ON pcn.product_category_name = p.product_category_name
GROUP BY ot.product_id, pcn.product_category_name_english
HAVING unique_customer = 1;

-- KPI 14: Top 10 Products by Repeat Purchase Rate

WITH customer_product AS (
    SELECT
        ot.product_id,
        pcn.product_category_name_english AS category,
        o.customer_id,
        COUNT(*) AS purchase_count
    FROM orders o
    JOIN order_items ot
        ON o.order_id = ot.order_id
    JOIN products p
        ON p.product_id = ot.product_id
    JOIN product_category_name_translation pcn
        ON pcn.product_category_name = p.product_category_name
    GROUP BY
        ot.product_id,
        pcn.product_category_name_english,
        o.customer_id
)
SELECT
    product_id,
    category,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS repeat_purchase_rate
FROM customer_product
GROUP BY
    product_id,
    category
ORDER BY repeat_purchase_rate DESC
LIMIT 10;

-- KPI 15: Frequently Bought Together Products

SELECT o1.product_id, o2.product_id, COUNT(*) AS times_brought_together FROM order_items o1
JOIN order_items o2
ON o1.order_id = o2.order_id
AND o1.product_id < o2.product_id
GROUP BY o1.product_id, o2.product_id
ORDER BY times_brought_together DESC
LIMIT 10;

-- KPI 16: Revenue Concentration (Pareto Analysis)

WITH cte AS(
	SELECT product_id, 
		   SUM(price) AS revenue
	FROM order_items 
    GROUP BY product_id
)
SELECT *,
	   SUM(revenue) OVER(ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue, 
       ROUND(100*SUM(revenue) OVER(ORDER BY revenue DESC)/SUM(revenue) OVER(), 2) AS cumulative_pct 
FROM cte
ORDER BY revenue DESC;

-- ==========================================
-- CUSTOMER ANALYSIS
-- ==========================================

-- KPI 1: Top 10 Customers by Revenue

SELECT o.customer_id, SUM(ot.price) AS revenue FROM orders o
JOIN order_items ot
ON o.order_id = ot.order_id
GROUP BY o.customer_id
ORDER BY revenue DESC
LIMIT 10;

-- KPI 2: Top 10 Customers by Number of Orders

SELECT c.customer_unique_id, COUNT(o.order_id) AS total_orders FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;

-- KPI 3: Average Order Value (AOV) per Customer

WITH cte AS(
	SELECT c.customer_unique_id, o.order_id, SUM(ot.price) AS order_value FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	JOIN order_items ot
	ON o.order_id = ot.order_id
	GROUP BY c.customer_unique_id, o.order_id
)
SELECT
    customer_unique_id,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM cte
GROUP BY customer_unique_id
ORDER BY average_order_value DESC;

-- KPI 4: Customer Lifetime Value (CLV)

SELECT c.customer_unique_id, SUM(ot.price) AS lifetime_value FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items ot
ON o.order_id = ot.order_id
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC;

-- KPI 5: Customer Recency

SELECT c.customer_unique_id, 
	   MAX(order_purchase_timestamp) AS last_purchase_date,
       DATEDIFF((SELECT MAX(order_purchase_timestamp) FROM orders), MAX(order_purchase_timestamp)) AS recency_days
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY recency_days;

-- KPI 6: Customer Purchase Frequency

WITH cte AS(
	SELECT c.customer_unique_id,
		   o.order_purchase_timestamp, 
           LAG(o.order_purchase_timestamp) 
			OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS prev_purchase
	FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    
)
SELECT customer_unique_id, ROUND(AVG(DATEDIFF(order_purchase_timestamp, prev_purchase)), 2) AS avg_days_between_orders FROM cte
GROUP BY customer_unique_id
HAVING COUNT(prev_purchase) > 0
ORDER BY avg_days_between_orders;

-- KPI 8: Customer Lifetime (First Purchase → Last Purchase)

WITH cte AS(
    SELECT c.customer_unique_id,
		   MIN(o.order_purchase_timestamp) AS first_purchase,
		   MAX(o.order_purchase_timestamp) AS last_purchase
	FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT *, DATEDIFF(last_purchase, first_purchase) AS customer_lifetime_days FROM cte
ORDER BY customer_lifetime_days DESC;

-- KPI 9: Customer RFM Analysis (Recency, Frequency, Monetary)

WITH cte AS(
	SELECT c.customer_unique_id, 
	   MAX(order_purchase_timestamp) AS last_purchase_date,
       DATEDIFF((SELECT MAX(order_purchase_timestamp) FROM orders), MAX(order_purchase_timestamp)) AS recency_days
	FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	GROUP BY c.customer_unique_id
),
cte2 AS(
	SELECT c.customer_unique_id, COUNT(o.order_id) AS total_orders FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	GROUP BY c.customer_unique_id
),
cte3 AS(
	SELECT c.customer_unique_id, SUM(ot.price) AS revenue FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
    JOIN order_items ot
    ON o.order_id = ot.order_id
	GROUP BY c.customer_unique_id
)
SELECT c1.customer_unique_id, 
	   c1.recency_days AS recency, 
       c2.total_orders AS frequecy, 
       c3.revenue AS monetary 
FROM cte c1
JOIN cte2 c2
ON c1.customer_unique_id = c2.customer_unique_id
JOIN cte3 c3
ON c2.customer_unique_id = c3.customer_unique_id;

-- KPI 10: RFM Scoring (Final Customer KPI)

WITH cte AS(
	SELECT c.customer_unique_id, 
	   MAX(order_purchase_timestamp) AS last_purchase_date,
       DATEDIFF((SELECT MAX(order_purchase_timestamp) FROM orders), MAX(order_purchase_timestamp)) AS recency_days
	FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	GROUP BY c.customer_unique_id
),
cte2 AS(
	SELECT c.customer_unique_id, COUNT(o.order_id) AS total_orders FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	GROUP BY c.customer_unique_id
),
cte3 AS(
	SELECT c.customer_unique_id, SUM(ot.price) AS revenue FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
    JOIN order_items ot
    ON o.order_id = ot.order_id
	GROUP BY c.customer_unique_id
),
rfm AS(
	SELECT c1.customer_unique_id, 
		   c1.recency_days AS recency, 
		   c2.total_orders AS frequency, 
		   c3.revenue AS monetary 
	FROM cte c1
	JOIN cte2 c2
	ON c1.customer_unique_id = c2.customer_unique_id
	JOIN cte3 c3
	ON c2.customer_unique_id = c3.customer_unique_id
),
rfm_score AS(
	SELECT *, 
		   NTILE(5) OVER(ORDER BY recency DESC) AS R,
           NTILE(5) OVER(ORDER BY frequency ASC) AS F,
           NTILE(5) OVER(ORDER BY monetary ASC) AS M
	FROM rfm
)
SELECT *,
	CASE
		WHEN R >= 4 AND F >= 4 AND M >= 4
			THEN 'Champions'
		WHEN R >= 3 AND F >= 4
			THEN 'Loyal Customers'
		WHEN R >= 4 AND F BETWEEN 2 AND 3
			THEN 'Potential Loyalists'
		WHEN R = 5 AND F = 1
			THEN 'New Customers'
		WHEN R <= 2 AND F >= 3
			THEN 'At Risk'
		WHEN R = 1 AND F = 1
			THEN 'Lost Customers'
		WHEN M >= 4
			THEN 'Big Spenders'
		ELSE 'Others'
	END AS segment
FROM rfm_score;

-- ==========================================
-- SALES ANALYSIS
-- ==========================================

-- KPI 1: Monthly Revenue Trend

SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue FROM orders o
JOIN order_items ot 
ON o.order_id = ot.order_id
GROUP BY months
ORDER BY months;

-- KPI 2: Month-over-Month (MoM) Revenue Growth

WITH cte AS(
	SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue FROM orders o
	JOIN order_items ot 
	ON o.order_id = ot.order_id
	GROUP BY months
),
cte2 AS(
	SELECT *, LAG(revenue) OVER(ORDER BY months) AS prev_revenue FROM cte
)
SELECT *, ROUND((revenue-prev_revenue)/prev_revenue*100, 2) AS growth_pct FROM cte2
ORDER BY months;

-- KPI 3: Rolling 3-Month Average Revenue

WITH cte AS(
	SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue FROM orders o
	JOIN order_items ot 
	ON o.order_id = ot.order_id
	GROUP BY months
)
SELECT *, ROUND(AVG(revenue) OVER(ORDER BY months ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3M_avg FROM cte
ORDER BY months;

-- KPI 4: Quarter-over-Quarter (QoQ) Revenue Growth

WITH cte AS(
SELECT YEAR(o.order_purchase_timestamp) AS years, QUARTER(o.order_purchase_timestamp) AS quarters, SUM(ot.price) AS revenue FROM orders o
JOIN order_items ot 
ON o.order_id = ot.order_id
GROUP BY years, quarters
),
cte2 AS(
	SELECT years, quarters, CONCAT(years, '-Q', quarters) AS y_quarters, revenue, LAG(revenue) OVER(ORDER BY years, quarters) AS prev_q FROM cte
)
SELECT y_quarters, revenue, ROUND((revenue-prev_q)/prev_q*100, 2) AS growth_per_quarter FROM cte2
ORDER BY y_quarters;

-- KPI 5: Best & Worst Sales Month

WITH cte AS(
	SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue FROM orders o
	JOIN order_items ot 
	ON o.order_id = ot.order_id
	GROUP BY months
),
cte2 AS(
	SELECT *,
		   RANK() OVER(ORDER BY revenue DESC) AS highest_rank,
		   RANK() OVER(ORDER BY revenue ASC)  AS lowest_rank	
    FROM cte
)
SELECT months, revenue,
	   CASE
        WHEN highest_rank = 1 THEN 'Best Sales Month'
        WHEN lowest_rank = 1 THEN 'Worst Sales Month'
	   END AS month_type
FROM cte2
WHERE highest_rank = 1
   OR lowest_rank = 1;
   
-- KPI 6: Revenue by State

SELECT c.customer_state AS state, SUM(ot.price) AS revenue FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
JOIN order_items ot
ON o.order_id = ot.order_id
GROUP BY state
ORDER BY revenue DESC;

-- KPI 7: Revenue by City (Top 10)

SELECT c.customer_state AS state, c.customer_city AS city, SUM(ot.price) AS revenue FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
JOIN order_items ot
ON o.order_id = ot.order_id
GROUP BY c.customer_state, c.customer_city
ORDER BY revenue DESC
LIMIT 10;

-- KPI 8: Weekday vs Weekend Revenue

SELECT CASE
			WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1, 7) THEN 'Weekends'
            ELSE 'Weekdays'
		END AS day_type,
        SUM(ot.price) AS revenue
FROM orders o
JOIN order_items ot
ON o.order_id = ot.order_id
GROUP BY day_type;

-- KPI 9: Average Order Value (AOV) by Month

WITH cte AS(
	SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue, COUNT(DISTINCT o.order_id) AS orders FROM orders o
	JOIN order_items ot 
	ON o.order_id = ot.order_id
	GROUP BY months
)
SELECT *, ROUND(revenue/orders, 2) AS AOV FROM cte
ORDER BY months;

-- KPI 10: Cumulative Revenue (Running Total)

WITH cte AS(
	SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue FROM orders o
	JOIN order_items ot 
	ON o.order_id = ot.order_id
	GROUP BY months
)
SELECT *, SUM(revenue) OVER(ORDER BY months) AS cumulative_revenue FROM cte
ORDER BY months;

-- KPI 11: Monthly Order Trend

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS months, COUNT(DISTINCT order_id) AS total_orders FROM orders 
GROUP BY months
ORDER BY months;

-- KPI 12: Average Daily Revenue

SELECT ROUND(SUM(ot.price)/COUNT(DISTINCT DATE(o.order_purchase_timestamp)), 2) AS avg_daily_revenue FROM orders o
JOIN order_items ot
ON o.order_id = ot.order_id;

-- KPI 13: Average Monthly Revenue

SELECT ROUND(SUM(ot.price)/COUNT(DISTINCT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')), 2) AS avg_monthly_revenue FROM orders o
JOIN order_items ot
ON o.order_id = ot.order_id;

-- KPI 14: Revenue Contribution by Year

WITH cte AS(
	SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y') AS years, SUM(ot.price) AS revenue FROM orders o
	JOIN order_items ot
	ON o.order_id = ot.order_id
    GROUP BY years
)
SELECT years, revenue, ROUND(revenue/SUM(revenue) OVER()*100, 2) AS contribution FROM cte
ORDER BY years;

-- KPI 15: Year-over-Year (YoY) Revenue Growth

WITH cte AS(
	SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y') AS years, SUM(ot.price) AS revenue FROM orders o
	JOIN order_items ot 
	ON o.order_id = ot.order_id
	GROUP BY years
),
cte2 AS(
	SELECT *, LAG(revenue) OVER(ORDER BY years) AS prev_revenue FROM cte
)
SELECT *, ROUND((revenue-prev_revenue)/NULLIF(prev_revenue, 0)*100, 2) AS growth_pct FROM cte2
ORDER BY years;

-- ==========================================
-- SELLER ANALYSIS
-- ==========================================

-- Top 10 Sellers by Revenue

SELECT seller_id, SUM(price) AS revenue FROM order_items
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;

-- KPI 2: Top 10 Sellers by Orders

SELECT seller_id, COUNT(DISTINCT order_id) AS total_orders FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

-- KPI 3: Average Revenue per Seller

WITH cte AS(
	SELECT seller_id, SUM(price) AS revenue, COUNT(DISTINCT order_id) AS orders FROM order_items
    GROUP BY seller_id
)
SELECT *, ROUND(revenue/orders, 2) AS avg_revenue_per_order FROM cte;

-- KPI 4: Seller Product Diversity

SELECT seller_id, COUNT(DISTINCT product_id) AS unique_products FROM order_items
GROUP BY seller_id;

-- KPI 5: Average Products per Order (Seller-wise)

SELECT seller_id, ROUND(COUNT(product_id)/COUNT(DISTINCT order_id), 2) AS avg_products_per_order FROM order_items
GROUP BY seller_id;

-- KPI 6: Seller Revenue Contribution (%)

WITH cte AS(
	SELECT seller_id, SUM(price) AS revenue FROM order_items
    GROUP BY seller_id
)
SELECT *, ROUND(revenue/SUM(revenue) OVER()*100, 2) AS contribution FROM cte;

-- KPI 7: Seller Monthly Revenue Trend

SELECT ot.seller_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue FROM order_items ot
JOIN orders o
ON ot.order_id = o.order_id
GROUP BY ot.seller_id, months
ORDER BY ot.seller_id, months;

-- KPI 8: Top Seller in Each State

WITH cte AS(
	SELECT s.seller_id, s.seller_state, SUM(ot.price) AS revenue FROM sellers s
    JOIN order_items ot
    ON s.seller_id = ot.seller_id
    GROUP BY s.seller_id, s.seller_state
),
cte2 AS(
	SELECT *, RANK() OVER(PARTITION BY seller_state ORDER BY revenue DESC) AS rn FROM cte
)
SELECT seller_state, seller_id, revenue FROM cte2
WHERE rn = 1;

-- KPI 9: Monthly Top Seller

WITH cte AS(
	SELECT ot.seller_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS months, SUM(ot.price) AS revenue FROM order_items ot
    JOIN orders o 
    ON ot.order_id = o.order_id
    GROUP BY ot.seller_id, months
),
cte2 AS(
	SELECT *, RANK() OVER(PARTITION BY months ORDER BY revenue DESC) AS rn FROM cte
)
SELECT months, seller_id, revenue FROM cte2
WHERE rn = 1;

-- ==========================================
-- DELIVERY ANALYSIS
-- ==========================================

-- KPI 1: Average Delivery Time

WITH cte AS(
	SELECT order_id, DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS days_for_delivery FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT ROUND(AVG(days_for_delivery), 2) AS average_delivery_days FROM cte;

-- KPI 2: Late Delivery Rate

WITH cte AS(
	SELECT order_id, DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) AS days_diff FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT ROUND(COUNT(CASE WHEN days_diff < 0 THEN 1 END)/COUNT(order_id)*100, 2) AS late_delivery_rate FROM cte;

-- KPI 3: Early Delivery Rate

WITH cte AS(
	SELECT order_id, DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) AS days_diff FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT ROUND(COUNT(CASE WHEN days_diff > 0 THEN 1 END)/COUNT(order_id)*100, 2) AS early_delivery_rate FROM cte;

-- KPI 4: On-Time Delivery Rate

WITH cte AS(
	SELECT order_id, DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) AS days_diff FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT ROUND(COUNT(CASE WHEN days_diff = 0 THEN 1 END)/COUNT(order_id)*100, 2) AS on_time_delivery_rate FROM cte;

-- KPI 5: Average Delay Days (Late Orders Only)

WITH cte AS (
    SELECT
        DATEDIFF(order_estimated_delivery_date,
                 order_delivered_customer_date) AS days_diff
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT
    ROUND(AVG(ABS(days_diff)), 2) AS avg_delay_days
FROM cte
WHERE days_diff < 0;

-- KPI 6: Average Early Delivery Days

WITH cte AS (
    SELECT
        DATEDIFF(order_estimated_delivery_date,
                 order_delivered_customer_date) AS days_diff
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT
    ROUND(AVG(ABS(days_diff)), 2) AS avg_early_days
FROM cte
WHERE days_diff > 0;

-- KPI 7: Monthly Average Delivery Time

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS months, 
	   ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY months
ORDER BY months;

-- KPI 8: Average Delivery Time by State

SELECT c.customer_state AS state, 
	   ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY state;

-- KPI 9: Delivery Performance by Seller State

SELECT s.seller_state, 
	   ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders o
JOIN order_items ot
ON o.order_id = ot.order_id
JOIN sellers s
ON ot.seller_id = s.seller_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_state;

-- KPI 10: Late Delivery Rate by Seller

WITH cte AS(
	SELECT DISTINCT s.seller_id, o.order_id,
	   DATEDIFF(o.order_estimated_delivery_date , o.order_delivered_customer_date) AS days_diff
	FROM orders o
	JOIN order_items ot
	ON o.order_id = ot.order_id
	JOIN sellers s
	ON ot.seller_id = s.seller_id
	WHERE o.order_delivered_customer_date IS NOT NULL
)
SELECT seller_id, 
	   ROUND(COUNT(CASE WHEN days_diff < 0 THEN 1 END)/COUNT(order_id)*100, 2) AS late_delivery_rate
FROM cte
GROUP BY seller_id;

-- KPI 11: Average Delivery Time by Seller

SELECT s.seller_id, 
	   ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders o
JOIN order_items ot
ON o.order_id = ot.order_id
JOIN sellers s
ON ot.seller_id = s.seller_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_id;

-- KPI 12: Seller Late Delivery Ranking

WITH cte AS(
	SELECT DISTINCT s.seller_id, o.order_id,
	   DATEDIFF(o.order_estimated_delivery_date , o.order_delivered_customer_date) AS days_diff
	FROM orders o
	JOIN order_items ot
	ON o.order_id = ot.order_id
	JOIN sellers s
	ON ot.seller_id = s.seller_id
	WHERE o.order_delivered_customer_date IS NOT NULL
),
cte2 AS(
SELECT seller_id, 
	   ROUND(COUNT(CASE WHEN days_diff < 0 THEN 1 END)/COUNT(order_id)*100, 2) AS late_delivery_rate
FROM cte
GROUP BY seller_id
)
SELECT RANK() OVER(ORDER BY late_delivery_rate DESC) AS rnk, seller_id, late_delivery_rate FROM cte2;

-- KPI 13: Delivery Time by Product Category

SELECT pcn.product_category_name_english,
	   ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders o 
JOIN order_items ot
ON o.order_id = ot.order_id
JOIN products p 
ON ot.product_id = p.product_id
JOIN product_category_name_translation pcn
ON p.product_category_name = pcn.product_category_name
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY pcn.product_category_name_english;

-- KPI 14: Late Delivery Rate by Product Category

WITH cte AS(
	SELECT DISTINCT pcn.product_category_name_english, o.order_id,
	   DATEDIFF(o.order_estimated_delivery_date , o.order_delivered_customer_date) AS days_diff
	FROM orders o 
	JOIN order_items ot
	ON o.order_id = ot.order_id
	JOIN products p 
	ON ot.product_id = p.product_id
	JOIN product_category_name_translation pcn
	ON p.product_category_name = pcn.product_category_name
	WHERE o.order_delivered_customer_date IS NOT NULL
)
SELECT product_category_name_english, 
	   ROUND(COUNT(CASE WHEN days_diff < 0 THEN 1 END)/COUNT(order_id)*100, 2) AS late_delivery_rate
FROM cte
GROUP BY product_category_name_english;

-- KPI 15: Most Delayed Product Categories

WITH cte AS (
    SELECT
		pcn.product_category_name_english,
        DATEDIFF(o.order_estimated_delivery_date,
                 o.order_delivered_customer_date) AS days_diff
    FROM orders o 
	JOIN order_items ot
	ON o.order_id = ot.order_id
	JOIN products p 
	ON ot.product_id = p.product_id
	JOIN product_category_name_translation pcn
	ON p.product_category_name = pcn.product_category_name
    WHERE o.order_delivered_customer_date IS NOT NULL
)
SELECT
	product_category_name_english,
    ROUND(AVG(ABS(days_diff)), 2) AS avg_delay_days
FROM cte
WHERE days_diff < 0
GROUP BY product_category_name_english
ORDER BY avg_delay_days DESC
LIMIT 10;