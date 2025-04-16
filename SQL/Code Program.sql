/*
This Query is for analyzing Brazil E-commerce Data by Olist
- Sales, Profit, and Quantity
- Product Category
- Payment Method
- Hourly Activity
- Geographical Sales Profit
- RMF
*/

-- SETTINGS --
SET SQL_SAFE_UPDATES = 1;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
CREATE DATABASE brazil_market;
SHOW DATABASES;
USE brazil_market;

-- INPUT CSV FILE TO TABLE --
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(50),
    customer_state VARCHAR(2)
);

CREATE TABLE geolocations (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(2)
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    review_answer_timestamp DATETIME NULL,
    PRIMARY KEY (review_id, order_id)
);

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME NULL,
    order_delivered_carrier_date DATETIME NULL,
    order_delivered_customer_date DATETIME NULL,
    order_estimated_delivery_date DATETIME NOT NULL
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(255),
    product_name_lenght INT DEFAULT NULL,
    product_description_lenght INT DEFAULT NULL,
    product_photos_qty INT DEFAULT NULL,
    product_weight_g INT DEFAULT NULL,
    product_length_cm INT DEFAULT NULL,
    product_height_cm INT DEFAULT NULL,
    product_width_cm INT DEFAULT NULL
);

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(50),
    seller_state VARCHAR(2)
);

CREATE TABLE product_translation (
    product_category_name VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(50)
);

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_geolocation_dataset.csv'
INTO TABLE geolocations
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, @order_purchase_timestamp, 
 @order_approved_at, @order_delivered_carrier_date, 
 @order_delivered_customer_date, @order_estimated_delivery_date)
SET order_purchase_timestamp = STR_TO_DATE(NULLIF(@order_purchase_timestamp, ''), '%Y-%m-%d %H:%i:%s'),
    order_approved_at = STR_TO_DATE(NULLIF(@order_approved_at, ''), '%Y-%m-%d %H:%i:%s'),
    order_delivered_carrier_date = STR_TO_DATE(NULLIF(@order_delivered_carrier_date, ''), '%Y-%m-%d %H:%i:%s'),
    order_delivered_customer_date = STR_TO_DATE(NULLIF(@order_delivered_customer_date, ''), '%Y-%m-%d %H:%i:%s'),
    order_estimated_delivery_date = STR_TO_DATE(NULLIF(@order_estimated_delivery_date, ''), '%Y-%m-%d %H:%i:%s');

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_category_name, 
 @product_name_lenght, @product_description_lenght, @product_photos_qty,
 @product_weight_g, @product_length_cm, @product_height_cm, @product_width_cm)
SET product_name_lenght = NULLIF(@product_name_lenght, ''),
    product_description_lenght = NULLIF(@product_description_lenght, ''),
    product_photos_qty = NULLIF(@product_photos_qty, ''),
    product_weight_g = NULLIF(@product_weight_g, ''),
    product_length_cm = NULLIF(@product_length_cm, ''),
    product_height_cm = NULLIF(@product_height_cm, ''),
    product_width_cm = NULLIF(@product_width_cm, '');

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'D:/KERJA KERJA KERJA/Kerja/BELAJAR/SQL Brazil/product_category_name_translation.csv'
INTO TABLE product_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- CORE DATA --
-- Sales, Profit, and Quantity --
CREATE TABLE Sales_and_Profit AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS order_date,
    SUM(it.price) AS Profit, 
    (SUM(it.price) + SUM(it.freight_value)) AS Sales
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_date;

CREATE TABLE Sales_Quantity AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS order_date,
    COUNT(it.order_item_id) AS total_quantity
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_date;

-- Product Category --
CREATE TABLE Product_Category AS
SELECT
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS tanggal,
    pr.product_category_name,
    CONCAT(
        UPPER(LEFT(REPLACE(COALESCE(tr.product_category_name_english, 'Unknown'), '_', ' '), 1)),
        LOWER(SUBSTRING(REPLACE(COALESCE(tr.product_category_name_english, 'Unknown'), '_', ' '), 2))
    ) AS product_category_name_englishh,
    COUNT(*) AS jumlah
FROM orders od
JOIN order_items it USING (order_id)
JOIN products pr USING (product_id)
LEFT JOIN product_translation tr USING (product_category_name)
WHERE od.order_status = 'delivered'
GROUP BY tanggal, pr.product_category_name, product_category_name_englishh
ORDER BY tanggal ASC, jumlah DESC;

-- Payment Method --
CREATE TABLE Payment_Method AS
SELECT
    DATE(od.order_purchase_timestamp) AS order_date,
    pa.payment_type,
    COUNT(DISTINCT od.order_id) AS order_count,
    COUNT(*) AS payment_count
FROM orders od
JOIN order_payments pa ON od.order_id = pa.order_id
GROUP BY DATE(od.order_purchase_timestamp), pa.payment_type
ORDER BY order_date, payment_type;

-- Hourly Activity --
CREATE TABLE sales_waktu_jamhari;
SELECT 
    DATE(order_purchase_timestamp) AS order_date,
    HOUR(order_purchase_timestamp) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY order_date, order_hour
ORDER BY order_date ASC, total_orders DESC;

-- Geographical Sales Profit --
CREATE TEMPORARY TABLE temp_order AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS order_date,
    od.customer_id,
    SUM(it.price) + SUM(it.freight_value) AS total_sales,
    SUM(it.price) AS total_profit
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_date, od.customer_id;

CREATE TEMPORARY TABLE temp_cus AS
SELECT
    t.order_date,
    t.customer_id,
    t.total_sales,
    t.total_profit,
    cus.customer_zip_code_prefix
FROM temp_order t
JOIN customers cus USING (customer_id)
ORDER BY order_date ASC;

CREATE INDEX idx_temp_cus_zip ON temp_cus(customer_zip_code_prefix);
CREATE INDEX idx_geolocation_zip ON geolocations(geolocation_zip_code_prefix);
CREATE INDEX idx_temp_cus_date ON temp_cus(order_date);

CREATE TABLE Geographical_Sales_Profit AS
SELECT
    te.order_date,
    te.customer_id,
    te.customer_zip_code_prefix,
    ge.geolocation_lat,
    ge.geolocation_lng,
    ge.geolocation_city,
    ge.geolocation_state,
    te.total_profit,
    te.total_sales,
    'BRAZIL' AS country
FROM temp_cus te
STRAIGHT_JOIN geolocations ge ON ge.geolocation_zip_code_prefix = te.customer_zip_code_prefix;

-- RMF --
CREATE TABLE RMF AS
WITH RFM_Base AS (
    SELECT 
        c.customer_id,
        DATEDIFF(CURRENT_DATE, MAX(o.order_purchase_timestamp)) AS recency,  
        COUNT(DISTINCT o.order_id) AS frequency,  
        SUM(oi.price) AS monetary  
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
),
RFM_Scoring AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency ASC) AS R_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS F_score,  
        NTILE(5) OVER (ORDER BY monetary DESC) AS M_score  
    FROM RFM_Base
),
RFM_Final AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        R_score,
        F_score,
        M_score,
        CONCAT(R_score, F_score, M_score) AS RFM_Score,
        CASE 
            WHEN CONCAT(R_score, F_score, M_score) = '555' THEN 'Champions'
            WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4 THEN 'Loyal Customers'
            WHEN R_score >= 4 AND M_score >= 4 THEN 'Potential Loyalists'
            WHEN R_score >= 4 THEN 'Recent Customers'
            WHEN F_score >= 4 THEN 'Frequent Buyers'
            WHEN M_score >= 4 THEN 'Big Spenders'
            WHEN R_score <= 2 AND F_score <= 2 AND M_score <= 2 THEN 'Lost Customers'
            ELSE 'Others'
        END AS Customer_Segment
    FROM RFM_Scoring
)
SELECT 
    Customer_Segment,
    COUNT(customer_id) AS total_customers,
    CAST(AVG(recency) AS DECIMAL(10,2)) AS avg_recency,
    CAST(AVG(frequency) AS DECIMAL(10,2)) AS avg_frequency,
    CAST(AVG(monetary) AS DECIMAL(12,2)) AS avg_monetary
FROM RFM_Final
GROUP BY Customer_Segment
ORDER BY 
    CASE Customer_Segment
        WHEN 'Champions' THEN 1
        WHEN 'Loyal Customers' THEN 2
        WHEN 'Potential Loyalists' THEN 3
        WHEN 'Recent Customers' THEN 4
        WHEN 'Frequent Buyers' THEN 5
        WHEN 'Big Spenders' THEN 6
        WHEN 'Lost Customers' THEN 7
        ELSE 8
    END;

CREATE TABLE sales_RMF_with_ID_percustomer AS
WITH RFM_Base AS (
    SELECT 
        c.customer_id,
        c.customer_unique_id,
        DATEDIFF(CURRENT_DATE, MAX(o.order_purchase_timestamp)) AS recency,  
        COUNT(DISTINCT o.order_id) AS frequency,  
        SUM(oi.price) AS monetary  
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_unique_id
),
RFM_Scoring AS (
    SELECT 
        customer_id,
        customer_unique_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency ASC) AS R_score,  
        NTILE(5) OVER (ORDER BY frequency DESC) AS F_score,  
        NTILE(5) OVER (ORDER BY monetary DESC) AS M_score  
    FROM RFM_Base
),
RFM_Final AS (
    SELECT 
        customer_id,
        customer_unique_id,
        recency,
        frequency,
        monetary,
        R_score,
        F_score,
        M_score,
        CONCAT(R_score, F_score, M_score) AS RFM_Score,
        CASE 
            WHEN CONCAT(R_score, F_score, M_score) = '555' THEN 'Champions'
            WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4 THEN 'Loyal Customers'
            WHEN R_score >= 4 AND M_score >= 4 THEN 'Potential Loyalists'
            WHEN R_score >= 4 THEN 'Recent Customers'
            WHEN F_score >= 4 THEN 'Frequent Buyers'
            WHEN M_score >= 4 THEN 'Big Spenders'
            WHEN R_score <= 2 AND F_score <= 2 AND M_score <= 2 THEN 'Lost Customers'
            ELSE 'Others'
        END AS Customer_Segment
    FROM RFM_Scoring
)

SELECT 
    customer_id,
    customer_unique_id,
    Customer_Segment,
    recency,
    frequency,
    monetary,
    RFM_Score
FROM RFM_Final
ORDER BY 
    CASE Customer_Segment
        WHEN 'Champions' THEN 1
        WHEN 'Loyal Customers' THEN 2
        WHEN 'Potential Loyalists' THEN 3
        ELSE 4
    END,
    monetary DESC;










-- UNUSED DATA --
-- PROFIT (GROSS AND NET) --
CREATE TABLE sales_net_gross_total AS
SELECT 
    SUM(it.price) AS NET, 
    (SUM(it.price) + SUM(it.freight_value)) AS Gross
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered';

CREATE TABLE sales_net_gross_perhari AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS order_date,
    SUM(it.price) AS NET, 
    (SUM(it.price) + SUM(it.freight_value)) AS Gross
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_date;

CREATE TABLE sales_net_gross_perbulan AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m') AS order_month,
    SUM(it.price) AS NET, 
    (SUM(it.price) + SUM(it.freight_value)) AS Gross
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_month;

CREATE TABLE sales_net_gross_pertahun AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y') AS order_year,
    SUM(it.price) AS NET, 
    (SUM(it.price) + SUM(it.freight_value)) AS Gross
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_year;

-- NUMBER OF TRANSACTIONS  --
CREATE TABLE sales_jmltransaksi_total AS
SELECT 
    COUNT(*) AS Jml_Transaksi
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered';

CREATE TABLE sales_jmltransaksi_perhari AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS order_date,
    COUNT(*) AS Jml_Transaksi
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_date;

CREATE TABLE sales_jmltransaksi_perbulan AS
SELECT
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS Jml_Transaksi
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_month;

CREATE TABLE sales_jmltransaksi_pertahun AS
SELECT
    DATE_FORMAT(od.order_purchase_timestamp, '%Y') AS order_year,
    COUNT(*) AS Jml_Transaksi
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_year;

-- AVERAGE ORDER VALUE --
CREATE TABLE sales_aov_total AS
SELECT 
	CAST(SUM(it.price) / COUNT(DISTINCT it.order_id) AS DECIMAL(12,2)) AS Average_Order_Value_NET,
    CAST(SUM(it.price + it.freight_value) / COUNT(DISTINCT order_id) AS DECIMAL(12,2)) AS Average_Order_Value_GROSS
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered';

CREATE TABLE sales_aov_perhari AS
SELECT 
	DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS order_date,
    CAST(SUM(it.price) / COUNT(DISTINCT it.order_id) AS DECIMAL(12,2)) AS Average_Order_Value_NET,
    CAST(SUM(it.price + it.freight_value) / COUNT(DISTINCT order_id) AS DECIMAL(12,2)) AS Average_Order_Value_GROSS
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_date;

CREATE TABLE sales_aov_perbulan AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m') AS order_month,
    CAST(SUM(it.price) / COUNT(DISTINCT it.order_id) AS DECIMAL(12,2)) AS Average_Order_Value_NET,
    CAST(SUM(it.price + it.freight_value) / COUNT(DISTINCT order_id) AS DECIMAL(12,2)) AS Average_Order_Value_GROSS
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_month;

CREATE TABLE sales_aov_pertahun AS
SELECT 
    DATE_FORMAT(od.order_purchase_timestamp, '%Y') AS order_year,
    CAST(SUM(it.price) / COUNT(DISTINCT it.order_id) AS DECIMAL(12,2)) AS Average_Order_Value_NET,
    CAST(SUM(it.price + it.freight_value) / COUNT(DISTINCT order_id) AS DECIMAL(12,2)) AS Average_Order_Value_GROSS
FROM orders od
JOIN order_items it USING (order_id)
WHERE od.order_status = 'delivered'
GROUP BY order_year;

-- BEST SELLING PRODUCTS --
CREATE TABLE sales_produk_terbaik_total AS
SELECT
    pr.product_category_name,
    COALESCE(tr.product_category_name_english, 'Unknown') AS product_category_name_englishh,
    COUNT(*) AS jumlah
FROM orders od
JOIN order_items it USING (order_id)
JOIN products pr USING (product_id)
LEFT JOIN product_translation tr USING (product_category_name)
WHERE od.order_status = 'delivered'
GROUP BY tr.product_category_name, product_category_name_englishh
ORDER BY jumlah DESC
LIMIT 10;

CREATE TABLE sales_produk_terbaik_perhari AS
SELECT
    DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m-%d') AS tanggal,
    pr.product_category_name,
    CONCAT(
        UPPER(LEFT(REPLACE(COALESCE(tr.product_category_name_english, 'Unknown'), '_', ' '), 1)),
        LOWER(SUBSTRING(REPLACE(COALESCE(tr.product_category_name_english, 'Unknown'), '_', ' '), 2))
    ) AS product_category_name_englishh,
    COUNT(*) AS jumlah
FROM orders od
JOIN order_items it USING (order_id)
JOIN products pr USING (product_id)
LEFT JOIN product_translation tr USING (product_category_name)
WHERE od.order_status = 'delivered'
GROUP BY tanggal, pr.product_category_name, product_category_name_englishh
ORDER BY tanggal ASC, jumlah DESC;


CREATE TABLE sales_produk_terbaik_perbulan AS
SELECT
	DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m') AS bulan,
    pr.product_category_name,
    COALESCE(tr.product_category_name_english, 'Unknown') AS product_category_name_englishh,
    COUNT(*) AS jumlah
FROM orders od
JOIN order_items it USING (order_id)
JOIN products pr USING (product_id)
LEFT JOIN product_translation tr USING (product_category_name)
WHERE od.order_status = 'delivered'
GROUP BY bulan, pr.product_category_name, product_category_name_englishh
ORDER BY bulan ASC, jumlah DESC;

CREATE TABLE sales_produk_terbaik_pertahun AS
SELECT
	DATE_FORMAT(od.order_purchase_timestamp, '%Y') AS tahun,
    pr.product_category_name,
    COALESCE(tr.product_category_name_english, 'Unknown') AS product_category_name_englishh,
    COUNT(*) AS jumlah
FROM orders od
JOIN order_items it USING (order_id)
JOIN products pr USING (product_id)
LEFT JOIN product_translation tr USING (product_category_name)
WHERE od.order_status = 'delivered'
GROUP BY tahun, pr.product_category_name, product_category_name_englishh
ORDER BY tahun ASC, jumlah DESC;

-- AVERAGE NUMBER OF ITEMS PER-TRANSACTION --
CREATE TABLE sales_avg_item_total (
    avg_item_per_transaksi_desimal DECIMAL(10,2),
    avg_item_per_transaksi_bulat INT
);
INSERT INTO sales_avg_item_total
SELECT 
    ROUND(AVG(jumlah_item), 2) AS avg_item_per_transaksi_desimal, -- Hasil dengan 2 desimal
    ROUND(AVG(jumlah_item)) AS avg_item_per_transaksi_bulat -- Hasil bilangan bulat
FROM (
    SELECT 
        od.order_id, 
        COUNT(it.product_id) AS jumlah_item
    FROM orders od
    JOIN order_items it USING (order_id)
    WHERE od.order_status = 'delivered'
    GROUP BY od.order_id
) subquery;

CREATE TABLE sales_avg_item_perhari (
    tanggal DATE,
    avg_item_per_transaksi_desimal DECIMAL(10,2),
    avg_item_per_transaksi_bulat INT
);
INSERT INTO sales_avg_item_perhari
SELECT 
    tanggal,
    ROUND(AVG(jumlah_item), 2) AS avg_item_per_transaksi_desimal, -- Hasil dengan 2 desimal
    ROUND(AVG(jumlah_item)) AS avg_item_per_transaksi_bulat -- Hasil bilangan bulat
FROM (
    SELECT 
        DATE(od.order_purchase_timestamp) AS tanggal, -- Ambil tanggal transaksi dalam format DATE
        od.order_id, 
        COUNT(it.product_id) AS jumlah_item
    FROM orders od
    JOIN order_items it USING (order_id)
    WHERE od.order_status = 'delivered'
    GROUP BY od.order_id, tanggal
) subquery
GROUP BY tanggal
ORDER BY tanggal ASC;

CREATE TABLE sales_avg_item_perbulan (
    tanggal VARCHAR(7),
    avg_item_per_transaksi_desimal DECIMAL(10,2),
    avg_item_per_transaksi_bulat INT
);
INSERT INTO sales_avg_item_perbulan
SELECT 
    bulan,
    ROUND(AVG(jumlah_item), 2) AS avg_item_per_transaksi_desimal, -- Hasil dengan 2 desimal
    ROUND(AVG(jumlah_item)) AS avg_item_per_transaksi_bulat -- Hasil bilangan bulat
FROM (
    SELECT 
        DATE_FORMAT(od.order_purchase_timestamp, '%Y-%m') AS bulan, -- Ambil bulan transaksi
        od.order_id, 
        COUNT(it.product_id) AS jumlah_item
    FROM orders od
    JOIN order_items it USING (order_id)
    WHERE od.order_status = 'delivered'
    GROUP BY od.order_id, bulan
) subquery
GROUP BY bulan
ORDER BY bulan ASC;

CREATE TABLE sales_avg_item_pertahun (
    tanggal VARCHAR(4),
    avg_item_per_transaksi_desimal DECIMAL(10,2),
    avg_item_per_transaksi_bulat INT
);
INSERT INTO sales_avg_item_pertahun
SELECT 
    tahun,
    ROUND(AVG(jumlah_item), 2) AS avg_item_per_transaksi_desimal, -- Hasil dengan 2 desimal
    ROUND(AVG(jumlah_item)) AS avg_item_per_transaksi_bulat -- Hasil bilangan bulat
FROM (
    SELECT 
        DATE_FORMAT(od.order_purchase_timestamp, '%Y') AS tahun, -- Ambil bulan transaksi
        od.order_id, 
        COUNT(it.product_id) AS jumlah_item
    FROM orders od
    JOIN order_items it USING (order_id)
    WHERE od.order_status = 'delivered'
    GROUP BY od.order_id, tahun
) subquery
GROUP BY tahun
ORDER BY tahun ASC;

-- Unique Customers --
CREATE TABLE sales_unique_customer_total AS
SELECT COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers;

CREATE TABLE sales_unique_customer_perbulan AS
SELECT 
    YEAR(o.order_purchase_timestamp) AS year,
    MONTH(o.order_purchase_timestamp) AS month,
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
ORDER BY year, month;

CREATE TABLE sales_uniqe_customer_pertahun AS
SELECT 
    YEAR(o.order_purchase_timestamp) AS year,
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY year;

CREATE TABLE sales_unique_customer_perkota AS
SELECT 
	customer_city, COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers
GROUP BY customer_city
ORDER BY total_unique_customers DESC;

CREATE TABLE sales_uniqe_customer_perstate AS
SELECT customer_state, COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers
GROUP BY customer_state
ORDER BY total_unique_customers DESC;

-- OLD VS NEW CUSTOMERS --
WITH first_order AS (
    SELECT
        c.customer_unique_id, 
        MIN(YEAR(o.order_purchase_timestamp)) AS first_order_year
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT 
    YEAR(o.order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT CASE WHEN fo.first_order_year = YEAR(o.order_purchase_timestamp) 
        THEN c.customer_unique_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN fo.first_order_year < YEAR(o.order_purchase_timestamp) 
        THEN c.customer_unique_id END) AS old_customers
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN first_order fo ON c.customer_unique_id = fo.customer_unique_id
GROUP BY order_year
ORDER BY order_year;

WITH first_order AS (
    SELECT 
        c.customer_unique_id, 
        MIN(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) AS first_order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT CASE WHEN fo.first_order_month = DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') 
        THEN c.customer_unique_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN fo.first_order_month < DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') 
        THEN c.customer_unique_id END) AS old_customers
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN first_order fo ON c.customer_unique_id = fo.customer_unique_id
GROUP BY order_month
ORDER BY order_month;

-- PURCHASE FREQUENCY --
CREATE TABLE sales_purchasef_total AS
SELECT 
    c.customer_unique_id,
    COUNT(o.order_id) AS purchase_frequency
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY purchase_frequency DESC;

CREATE TABLE sales_purchasef_perbulan AS
SELECT 
    c.customer_unique_id,
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(o.order_id) AS purchase_frequency
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id, order_month
ORDER BY order_month, purchase_frequency DESC;

CREATE TABLE sales_purchasef_pertahun AS
SELECT 
    c.customer_unique_id,
    YEAR(o.order_purchase_timestamp) AS order_year,
    COUNT(o.order_id) AS purchase_frequency
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id, order_year
ORDER BY order_year, purchase_frequency DESC;

-- SALES PERLOCATION --
CREATE TABLE sales_perwilayah_total;
SELECT
    c.customer_city AS city,
    COUNT(DISTINCT o.order_id) AS total_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = "delivered"
GROUP BY c.customer_city
ORDER BY total_order DESC;

CREATE TABLE sales_perwilayah_perbulan
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    c.customer_city AS city,
    COUNT(DISTINCT o.order_id) AS total_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = "delivered"
GROUP BY order_year, order_month, c.customer_city
ORDER BY order_year ASC, order_month ASC, total_order DESC;

CREATE TABLE sales_perwilayah_pertahun
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    c.customer_city AS city,
    COUNT(DISTINCT o.order_id) AS total_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = "delivered"
GROUP BY order_year, c.customer_city
ORDER BY order_year ASC, total_order DESC;

-- BEST PURCHASE METHOD --
CREATE TABLE sales_bestmethod_total AS
SELECT 
    payment_type, 
    COUNT(order_id) AS total_transactions, 
    SUM(payment_value) AS total_revenue
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC, total_transactions DESC;

CREATE TABLE sales_bestmethod_perbulan AS
SELECT 
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    p.payment_type, 
    COUNT(p.order_id) AS total_transactions, 
    SUM(p.payment_value) AS total_revenue
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY order_year, order_month, p.payment_type
ORDER BY order_year DESC, order_month DESC, total_revenue DESC;

CREATE TABLE sales_bestmethod_pertahun AS
SELECT 
    YEAR(o.order_purchase_timestamp) AS order_year,
    p.payment_type, 
    COUNT(p.order_id) AS total_transactions, 
    SUM(p.payment_value) AS total_revenue
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY order_year, p.payment_type
ORDER BY order_year DESC, total_revenue DESC;

-- TRENT PRODUCTS --
CREATE TABLE sales_trent_all AS
SELECT 
    YEAR(o.order_purchase_timestamp) AS order_year, 
    MONTH(o.order_purchase_timestamp) AS order_month, 
    p.product_category_name AS product_category,
    COUNT(oi.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY order_year, order_month, product_category
ORDER BY order_year ASC, order_month ASC, total_orders DESC;

CREATE TABLE sales_trent_perbulan AS
WITH MonthlyTopProduct AS (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS order_year, 
        MONTH(o.order_purchase_timestamp) AS order_month, 
        oi.product_id, 
        COUNT(oi.order_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp) 
            ORDER BY COUNT(oi.order_id) DESC
        ) AS rank
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_year, order_month, oi.product_id
)
SELECT 
    m.order_year, 
    m.order_month, 
    p.product_category_name AS product_name, 
    m.total_orders
FROM MonthlyTopProduct m
JOIN products p ON m.product_id = p.product_id
WHERE m.rank = 1
ORDER BY m.order_year, m.order_month;

-- TIME --
CREATE TABLE sales_waktu_bestjam;
SELECT 
    HOUR(order_purchase_timestamp) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY order_hour;

CREATE TABLE sales_waktu_bestjamhari
WITH daily_peak AS (
    SELECT 
        DATE(order_purchase_timestamp) AS order_date,
        HOUR(order_purchase_timestamp) AS order_hour,
        COUNT(order_id) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY DATE(order_purchase_timestamp) ORDER BY COUNT(order_id) DESC) AS rank
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY order_date, order_hour
)
SELECT order_date, order_hour, total_orders
FROM daily_peak
WHERE rank = 1
ORDER BY order_date;