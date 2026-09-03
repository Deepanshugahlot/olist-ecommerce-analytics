CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
SELECT *
FROM customers
LIMIT 10;

SELECT COUNT(*) AS total_customers
FROM customers;

Select count(*) as null_values from customers
where customer_id is null;

Select count(distinct(customer_id)) as total_values from customers;

Select customer_id, count(*) as duplicates from customers
group by customer_id
having duplicates > 1
order by duplicates desc;

SELECT customer_unique_id,
       COUNT(*) AS duplicates
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY duplicates DESC;

SELECT
    COUNT(CASE WHEN customer_id IS NULL THEN 1 END) AS customer_id_nulls,
    COUNT(CASE WHEN customer_unique_id IS NULL THEN 1 END) AS customer_unique_id_nulls,
    COUNT(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 END) AS zip_code_nulls,
    COUNT(CASE WHEN customer_city IS NULL THEN 1 END) AS city_nulls,
    COUNT(CASE WHEN customer_state IS NULL THEN 1 END) AS state_nulls
FROM customers;

Select count(distinct customer_state) as diff_states from customers;

Select customer_state, count(*) as total_customers from customers
group by customer_state
order by total_customers desc
limit 1;

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);