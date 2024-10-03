SELECT * FROM coffee_shop_sales;

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE; 

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;


ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;


-- -------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------TOTAL SALES ANALYSIS-----------------------------------------------------------

-- CALCULATE THE TOTAL SALES FOR EACH RESPECTIVE MONTH 

SELECT SUM(unit_price * transaction_qty) AS Total_Sales
FROM coffee_shop_sales
WHERE 
MONTH(transaction_date) = 2;

-- DETERMINE THE MONTH-ON-MONTH INCREASE OR DECREASE IN SALES

SELECT 
	MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1 ) -- MONTH SALES DIFFERENCE 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty),1) -- DIVISION BY PREVIOUS MONTH SALES
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- PERCENTAGE
    
FROM 
	coffee_shop_sales

WHERE 
	MONTH(transaction_date) IN (4,5) -- FOR MONTHS OF APRIL(PM) AND MAY(CM)
    
GROUP BY 
	MONTH(transaction_date)
ORDER BY 
	MONTH(transaction_date);


-- -------------------------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------TOTAL ORDER ANALYSIS-------------------------------------------------------------

-- CALCULATE THE TOTAL NUMBER OF ORDERS FOR EACH RESPECTIVE MONTH

SELECT COUNT(transaction_id) AS Total_Orders
FROM coffee_shop_sales
WHERE 
MONTH(transaction_date) = 3;


-- DETERMINE THE MONTH-ON-MONTH INCREASE OR DECREASE IN THE NUMBER OF ORDERS 

SELECT 
	MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
    
FROM coffee_shop_sales

WHERE
	MONTH(transaction_date) IN (4,5) 

GROUP BY 
	MONTH(transaction_date)
    
ORDER BY 
	MONTH(transaction_date);

-- -------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------TOTAL QUANTITY SOLD------------------------------------------------------------

-- CALCULATE THE TOTAL QUANTITY SOLD FOR EACH RESPECTIVE MONTH

SELECT SUM(transaction_qty) AS Total_Quantity_sold
FROM coffee_shop_sales
WHERE 
MONTH(transaction_date) = 5;

-- DETERMINE THE MONTH-ON-MONTH INCREASE OR DECREASE IN THE TOTAL QUANTITY SOLD

SELECT 
	MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_id)) AS total_orders,
    (SUM(transaction_id) - LAG(SUM(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
    
FROM coffee_shop_sales

WHERE
	MONTH(transaction_date) IN (4,5) 

GROUP BY 
	MONTH(transaction_date)
    
ORDER BY 
	MONTH(transaction_date);


-- -------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------CHARTS REQUIREMENTS---------------------------------------------------------------

SELECT 
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_Sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1), 'K') AS Total_Qty_Sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS Total_Orders
FROM coffee_shop_sales
WHERE
	transaction_date = '2023-05-18';


-- SALES ANALYSIS BY WEEKDAYS AND WEEKENDS

SELECT 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_Sales
FROM coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5
GROUP BY
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END;


-- VISUALIZE SALES DATA FROM DIFFERENT STORE LOCATIONS

SELECT 
	store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;


-- DISPLAY DAILY SALES FOR THE SELECTED MONTH WITH A LINE CHART

SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000,1), 'K') AS Avg_Sales
FROM
	(
    SELECT SUM(unit_price * transaction_qty) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY transaction_date
    ) AS Internal_query;

SELECT 
	DAY(transaction_date) AS day_of_month,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);



SELECT 
	day_of_month,
    CASE
		WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
		ELSE 'Equal to Average'
	END AS sales_satus,
    total_sales
FROM (
	SELECT
		DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
	FROM 
		coffee_shop_sales
	WHERE MONTH(transaction_date) = 5
    GROUP BY 
		DAY(transaction_date)
) AS sales_data
ORDER BY day_of_month;


-- SALES ANALYSIS BY PRODUCT CATEGORY
SELECT 
	product_category,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 2), 'K')  AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

SELECT 
	product_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 2), 'K')  AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'Coffee'
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;


SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 2), 'K')  AS Total_Sales,
    SUM(transaction_qty) AS Total_qty_sold,
    COUNT(*) AS Total_Orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 
AND DAYOFWEEK(transaction_date) = 1
AND HOUR(transaction_time) = 14;


SELECT 
	HOUR(transaction_time),
    SUM(unit_price * transaction_qty) AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time) ASC;
		

SELECT
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
		WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Firday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
		ELSE 'Sunday'
	END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5
GROUP BY 
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
		WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Firday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
		ELSE 'Sunday'
	END;






