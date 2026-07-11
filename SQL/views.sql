USE DATABASE ECOM_FRAUD_DETECTION;
USE SCHEMA FRAUD_ANALYTICS;

-- =====================================================
-- VIEW 1 : CATEGORY ANALYSIS
-- =====================================================

CREATE OR REPLACE VIEW VW_CATEGORY_ANALYSIS AS
SELECT
    p.CATEGORY,
    COUNT(r.RETURN_ID) AS TOTAL_RETURNS,
    SUM(o.TOTAL_AMOUNT) AS RETURN_VALUE,
    SUM(o.TOTAL_AMOUNT * 0.05) AS FRAUD_LOSS
FROM PRODUCTS p
JOIN ORDERS o
    ON p.PRODUCT_ID = o.PRODUCT_ID
LEFT JOIN RETURNS_TABLE r
    ON o.ORDER_ID = r.ORDER_ID
GROUP BY p.CATEGORY;

-- =====================================================
-- VIEW 2 : CUSTOMER ANALYSIS
-- =====================================================

CREATE OR REPLACE VIEW VW_CUSTOMER_ANALYSIS AS
SELECT
    c.CUSTOMER_ID,
    c.FIRST_NAME,
    COUNT(r.RETURN_ID) AS TOTAL_RETURNS,
    ROUND(COUNT(r.RETURN_ID) * 100.0 / COUNT(o.ORDER_ID),2) AS RETURN_RATE,
    AVG(o.TOTAL_AMOUNT) AS AVG_RETURN_VALUE,
    AVG(DATEDIFF('day',o.ORDER_DELIVERED_DATE,r.RETURN_DATE)) AS AVG_DAYS_TO_RETURN
FROM CUSTOMERS c
JOIN ORDERS o
    ON c.CUSTOMER_ID=o.CUSTOMER_ID
LEFT JOIN RETURNS_TABLE r
    ON o.ORDER_ID=r.ORDER_ID
GROUP BY
    c.CUSTOMER_ID,
    c.FIRST_NAME;

-- =====================================================
-- VIEW 3 : STATE ANALYSIS
-- =====================================================

CREATE OR REPLACE VIEW VW_STATE_ANALYSIS AS
SELECT
    c.STATE,
    COUNT(r.RETURN_ID) AS TOTAL_RETURNS,
    SUM(o.TOTAL_AMOUNT) AS RETURN_VALUE
FROM CUSTOMERS c
JOIN ORDERS o
    ON c.CUSTOMER_ID=o.CUSTOMER_ID
LEFT JOIN RETURNS_TABLE r
    ON o.ORDER_ID=r.ORDER_ID
GROUP BY c.STATE;

-- =====================================================
-- VIEW 4 : RETURN TIME ANALYSIS
-- =====================================================

CREATE OR REPLACE VIEW VW_RETURN_TIME AS
SELECT
    DATEDIFF(
        'day',
        o.ORDER_DELIVERED_DATE,
        r.RETURN_DATE
    ) AS DAYS_TO_RETURN,
    COUNT(*) AS RETURNS
FROM RETURNS_TABLE r
JOIN ORDERS o
    ON r.ORDER_ID=o.ORDER_ID
GROUP BY DAYS_TO_RETURN
ORDER BY DAYS_TO_RETURN;

-- =====================================================
-- VIEW 5 : EXECUTIVE KPI SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW VW_KPI_SUMMARY AS
SELECT

    (SELECT COUNT(*) FROM ORDERS) AS TOTAL_ORDERS,

    (SELECT COUNT(*) FROM RETURNS_TABLE) AS TOTAL_RETURNS,

    (
        SELECT ROUND(
            COUNT(*)*100.0/
            (SELECT COUNT(*) FROM ORDERS),
        2)
        FROM RETURNS_TABLE
    ) AS RETURN_RATE,

    (
        SELECT AVG(
            DATEDIFF(
                'day',
                o.ORDER_DELIVERED_DATE,
                r.RETURN_DATE
            )
        )
        FROM RETURNS_TABLE r
        JOIN ORDERS o
            ON r.ORDER_ID=o.ORDER_ID
    ) AS AVG_DAYS_TO_RETURN,

    (
        SELECT AVG(o.TOTAL_AMOUNT)
        FROM RETURNS_TABLE r
        JOIN ORDERS o
            ON r.ORDER_ID=o.ORDER_ID
    ) AS AVG_RETURN_VALUE,

    (
        SELECT SUM(o.TOTAL_AMOUNT)
        FROM RETURNS_TABLE r
        JOIN ORDERS o
            ON r.ORDER_ID=o.ORDER_ID
    ) AS TOTAL_RETURN_VALUE,

    (
        SELECT SUM(o.TOTAL_AMOUNT*0.05)
        FROM RETURNS_TABLE r
        JOIN ORDERS o
            ON r.ORDER_ID=o.ORDER_ID
    ) AS TOTAL_FRAUD_LOSS;
