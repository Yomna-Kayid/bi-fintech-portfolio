-- ============================================================
-- BI Developer Portfolio
-- Day 3: Aggregate functions, GROUP BY, HAVING
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- ============================================================

USE Chinook;
GO

-- 1. Count all invoices.
SELECT COUNT(*) AS total_invoices
FROM dbo.Invoice;

-- 2. Overall revenue profile: total, average, min and max invoice value.
SELECT
    SUM(Total) AS total_revenue,
    AVG(Total) AS avg_invoice_value,
    MIN(Total) AS min_invoice,
    MAX(Total) AS max_invoice
FROM dbo.Invoice;

-- 3. Revenue by Country: total revenue per billing country, highest first.
SELECT
    BillingCountry,
    SUM(Total) AS total_revenue
FROM dbo.Invoice
GROUP BY BillingCountry
ORDER BY total_revenue DESC;

-- 4. Average invoice value per customer; top 10 customers by average.
SELECT TOP 10
    CustomerId,
    AVG(Total) AS avg_invoice_value
FROM dbo.Invoice
GROUP BY CustomerId
ORDER BY avg_invoice_value DESC;

-- ------------------------------------------------------------
-- HAVING
-- ------------------------------------------------------------

-- 5. Countries with total revenue above 40.
-- HAVING filters after aggregation; WHERE cannot reference SUM().
-- The threshold is 40 rather than 1000: no country in Chinook reaches 1000.
SELECT
    BillingCountry,
    SUM(Total) AS total_revenue
FROM dbo.Invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 40
ORDER BY total_revenue DESC;

-- 6. Top 5 countries by revenue, applying the revenue threshold first.
SELECT TOP 5
    BillingCountry,
    SUM(Total) AS total_revenue
FROM dbo.Invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 40
ORDER BY total_revenue DESC;

-- 7. WHERE + HAVING together: WHERE drops invoices <= 5 before grouping,
-- HAVING then drops countries whose remaining revenue is <= 20.
SELECT
    BillingCountry,
    COUNT(*)   AS invoices_over_5,
    SUM(Total) AS revenue_over_5
FROM dbo.Invoice
WHERE Total > 5
GROUP BY BillingCountry
HAVING SUM(Total) > 20
ORDER BY revenue_over_5 DESC;
