-- ============================================================
-- BI Developer Portfolio
-- Day 4: HAVING
-- Author: Yomna
-- Database: Chinook (MySQL)
-- ============================================================

-- 1. Countries with total revenue above 40.
-- HAVING filters after aggregation; WHERE cannot reference SUM().
SELECT
    BillingCountry,
    SUM(Total) AS total_revenue
FROM chinook.invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 40
ORDER BY total_revenue DESC;

-- 2. Top 5 countries by revenue, applying the revenue threshold first.
SELECT
    BillingCountry,
    SUM(Total) AS total_revenue
FROM chinook.invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 40
ORDER BY total_revenue DESC
LIMIT 5;

-- 3. WHERE + HAVING together: WHERE drops invoices <= 5 before grouping,
-- HAVING then drops countries whose remaining revenue is <= 20.
SELECT
    BillingCountry,
    COUNT(*)   AS invoices_over_5,
    SUM(Total) AS revenue_over_5
FROM chinook.invoice
WHERE Total > 5
GROUP BY BillingCountry
HAVING SUM(Total) > 20
ORDER BY revenue_over_5 DESC;


