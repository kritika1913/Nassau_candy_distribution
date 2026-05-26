-- =========================================================
-- PROJECT:
-- Factory-to-Customer Shipping Route Efficiency Analysis
-- Nassau Candy Distributor
-- =========================================================



 -- =========================================================
 -- STEP 1 : CREATE DATABASE
 -- =========================================================

CREATE DATABASE IF NOT EXISTS nassau_shipping;

USE nassau_shipping;

-- =========================================================
-- STEP 2 : CREATE MAIN TABLE
-- =========================================================

 CREATE TABLE  shipments (
`Row ID` INT,
     `Order ID` VARCHAR(50),
     order_date VARCHAR(20),
     shipping_date VARCHAR(20),
     `Ship Mode` VARCHAR(50),
     `Customer ID` VARCHAR(50),
     `Country/Region` VARCHAR(100),
     City VARCHAR(100),
     `State/province` VARCHAR(100),
     `Postal Code` VARCHAR(20),
     Division VARCHAR(100),
     Region VARCHAR(100),
     `Product ID` VARCHAR(50),
   `Product Name` VARCHAR(255),
     Sales DECIMAL(10,2),
     Units INT,
     gross_profit DECIMAL(10,2),
     Cost DECIMAL(10,2)
 );


-- =========================================================
-- STEP 3 : VERIFY IMPORTED DATA
-- =========================================================

SELECT *
FROM shipments
LIMIT 10;


-- =========================================================
-- STEP 4 : TOTAL RECORD COUNT
-- =========================================================

SELECT
COUNT(*) AS total_rows
FROM shipments;



-- =========================================================
-- STEP 5 : VALIDATE DATE FORMATS
-- =========================================================

SELECT

order_date,
shipping_date,
STR_TO_DATE(order_date,'%d-%m-%Y') AS formatted_order_date,
STR_TO_DATE(shipping_date,'%d-%m-%Y') AS formatted_shipping_date
FROM shipments
LIMIT 20;

-- =========================================================
-- STEP 6 : CHECK INVALID SHIPPING LEAD TIMES
-- =========================================================

SELECT *
FROM shipments
WHERE DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
) < 0;

-- =========================================================
-- STEP 7 : CHECK MISSING SHIPMENT RECORDS
-- =========================================================

SELECT *
FROM shipments
WHERE shipping_date IS NULL
OR order_date IS NULL;

-- =========================================================
-- KPI 1 : SHIPPING LEAD TIME
-- =========================================================

SELECT
`Order ID`,
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
) AS shipping_lead_time
FROM shipments;

-- =========================================================
-- KPI 2 : AVERAGE LEAD TIME
-- =========================================================

SELECT
ROUND(
AVG(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
),2
) AS average_lead_time
FROM shipments;

-- =========================================================
-- KPI 3 : ROUTE VOLUME
-- =========================================================

SELECT
Region,
COUNT(`Order ID`) AS route_volume
FROM shipments
GROUP BY Region
ORDER BY route_volume DESC;

-- =========================================================
-- KPI 4 : DELAY FREQUENCY
-- Threshold = 5 Days
-- =========================================================

SELECT
ROUND(
100.0 *
SUM(
CASE
WHEN DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
) > 5
THEN 1
ELSE 0
END
)
/
COUNT(*)
,2
) AS delay_frequency_percentage
FROM shipments;

-- =========================================================
-- KPI 5 : ROUTE EFFICIENCY SCORE
-- Formula = 100 - Average Lead Time
-- =========================================================

SELECT
Region,
ROUND(
100 -
AVG(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
)
,2
) AS route_efficiency_score
FROM shipments
GROUP BY Region
ORDER BY route_efficiency_score DESC;

-- =========================================================
-- REGION-WISE SALES ANALYSIS
-- =========================================================

SELECT
Region,
ROUND(SUM(Sales),2) AS total_sales
FROM shipments
GROUP BY Region
ORDER BY total_sales DESC;

-- =========================================================
-- REGION-WISE PROFIT ANALYSIS
-- =========================================================

SELECT
Region,
ROUND(SUM(gross_profit),2) AS total_profit
FROM shipments
GROUP BY Region
ORDER BY total_profit DESC;

-- =========================================================
-- SHIP MODE PERFORMANCE ANALYSIS
-- =========================================================

SELECT
`Ship Mode`,
COUNT(*) AS total_orders,
ROUND(
AVG(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
)
,2
) AS avg_shipping_days,
ROUND(AVG(Cost),2) AS avg_cost
FROM shipments
GROUP BY `Ship Mode`;


-- =========================================================
-- TOP 10 MOST EFFICIENT ROUTES
-- =========================================================

SELECT

Division,
Region,
ROUND(
AVG(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
)
,2
) AS avg_lead_time
FROM shipments
GROUP BY Division, Region
ORDER BY avg_lead_time ASC
LIMIT 10;

-- =========================================================
-- TOP 10 LEAST EFFICIENT ROUTES
-- =========================================================

SELECT
Division,
Region,
ROUND(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
)
,2
) AS avg_lead_time
FROM shipments
GROUP BY Division, Region
ORDER BY avg_lead_time DESC
LIMIT 10;

-- =========================================================
-- LEAD TIME VARIABILITY ANALYSIS
-- =========================================================

SELECT
Division,
Region,
ROUND(
STDDEV(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
)
,2
) AS lead_time_variability
FROM shipments
GROUP BY Division, Region;

-- =========================================================
-- GEOGRAPHIC BOTTLENECK ANALYSIS
-- =========================================================

SELECT
Region,
COUNT(*) AS shipment_volume,
ROUND(
AVG(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
)
,2
) AS avg_lead_time
FROM shipments
GROUP BY Region
ORDER BY avg_lead_time DESC;


-- =========================================================
-- STATE-LEVEL CONGESTION ANALYSIS
-- =========================================================

SELECT
`State/province`,
COUNT(*) AS shipment_volume,
ROUND(
AVG(
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
)
)
,2
) AS avg_lead_time
FROM shipments
GROUP BY `State/province`
ORDER BY avg_lead_time DESC;


-- =========================================================
-- TOP 10 PRODUCTS BY SALES
-- =========================================================

SELECT
`Product Name`,
ROUND(SUM(Sales),2) AS total_sales
FROM shipments
GROUP BY `Product Name`
ORDER BY total_sales DESC
LIMIT 10;


-- =========================================================
-- MONTHLY SALES TREND
-- =========================================================

SELECT
MONTH(
STR_TO_DATE(order_date,'%d-%m-%Y')
) AS month_number,
ROUND(SUM(Sales),2) AS monthly_sales
FROM shipments
GROUP BY month_number
ORDER BY month_number;

-- =========================================================
-- MASTER VIEW FOR POWER BI & STREAMLIT
-- =========================================================

CREATE VIEW logistics_dashboard AS
SELECT
`Order ID` AS order_id,
Division,
Region,
`State/province`,
`Ship Mode`,
Sales,
Cost,
gross_profit,
DATEDIFF(
    STR_TO_DATE(shipping_date,'%d-%m-%Y'),
    STR_TO_DATE(order_date,'%d-%m-%Y')
) AS shipping_lead_time
FROM shipments;

-- =========================================================
-- VERIFY VIEW
-- =========================================================

SELECT *
FROM logistics_dashboard
LIMIT 20;