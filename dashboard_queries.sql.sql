USE DATABASE ECOM_FRAUD_DETECTION;
USE SCHEMA FRAUD_ANALYTICS;

-----------------------------------------------------
-- KPI 1 : Total Orders
-----------------------------------------------------
SELECT COUNT(*) AS Total_Orders
FROM ORDERS;

-----------------------------------------------------
-- KPI 2 : Total Returns
-----------------------------------------------------
SELECT COUNT(*) AS Total_Returns
FROM RETURNS_TABLE;

-----------------------------------------------------
-- KPI 3 : Return Rate %
-----------------------------------------------------
SELECT
ROUND(
COUNT(r.RETURN_ID)*100.0/
COUNT(DISTINCT o.ORDER_ID)
,2) AS Return_Rate
FROM ORDERS o
LEFT JOIN RETURNS_TABLE r
ON o.ORDER_ID=r.ORDER_ID;

-----------------------------------------------------
-- KPI 4 : Total Return Value
-----------------------------------------------------
SELECT
ROUND(SUM(o.TOTAL_AMOUNT),2) AS Total_Return_Value
FROM RETURNS_TABLE r
JOIN ORDERS o
ON r.ORDER_ID=o.ORDER_ID;

-----------------------------------------------------
-- KPI 5 : Average Return Value
-----------------------------------------------------
SELECT
ROUND(AVG(o.TOTAL_AMOUNT),2) AS Avg_Return_Value
FROM RETURNS_TABLE r
JOIN ORDERS o
ON r.ORDER_ID=o.ORDER_ID;

-----------------------------------------------------
-- KPI 6 : Average Days to Return
-----------------------------------------------------
SELECT
ROUND(
AVG(DATEDIFF('day',
o.ORDER_DELIVERED_DATE,
r.RETURN_DATE))
,2) AS Avg_Days_To_Return
FROM RETURNS_TABLE r
JOIN ORDERS o
ON r.ORDER_ID=o.ORDER_ID;

-----------------------------------------------------
-- Category Wise Fraud Loss
-----------------------------------------------------
SELECT
p.CATEGORY,
ROUND(SUM(o.TOTAL_AMOUNT),2) AS Fraud_Loss
FROM RETURNS_TABLE r
JOIN ORDERS o
ON r.ORDER_ID=o.ORDER_ID
JOIN PRODUCTS p
ON o.PRODUCT_ID=p.PRODUCT_ID
GROUP BY p.CATEGORY
ORDER BY Fraud_Loss DESC;

-----------------------------------------------------
-- Returns by State
-----------------------------------------------------
SELECT
c.STATE,
COUNT(*) AS Returns
FROM RETURNS_TABLE r
JOIN ORDERS o
ON r.ORDER_ID=o.ORDER_ID
JOIN CUSTOMERS c
ON o.CUSTOMER_ID=c.CUSTOMER_ID
GROUP BY c.STATE
ORDER BY Returns DESC;

-----------------------------------------------------
-- Days To Return
-----------------------------------------------------
SELECT
DATEDIFF(
'day',
o.ORDER_DELIVERED_DATE,
r.RETURN_DATE
) AS DaysToReturn,
COUNT(*) AS Returns
FROM RETURNS_TABLE r
JOIN ORDERS o
ON r.ORDER_ID=o.ORDER_ID
GROUP BY DaysToReturn
ORDER BY DaysToReturn;

-----------------------------------------------------
-- Potential Fraud Customers
-----------------------------------------------------
SELECT

c.CUSTOMER_ID,
c.FIRST_NAME,

ROUND(
COUNT(r.RETURN_ID)*100.0/
COUNT(o.ORDER_ID)
,2) AS Return_Rate,

ROUND(
AVG(o.TOTAL_AMOUNT),2) AS Avg_Return_Value,

ROUND(
AVG(
DATEDIFF(
'day',
o.ORDER_DELIVERED_DATE,
r.RETURN_DATE
)
),2) AS Avg_Days_To_Return

FROM CUSTOMERS c

JOIN ORDERS o
ON c.CUSTOMER_ID=o.CUSTOMER_ID

LEFT JOIN RETURNS_TABLE r
ON o.ORDER_ID=r.ORDER_ID

GROUP BY
c.CUSTOMER_ID,
c.FIRST_NAME

HAVING COUNT(r.RETURN_ID)>=3

ORDER BY Return_Rate DESC;