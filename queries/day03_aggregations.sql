-- ============================================================
-- BI Developer Portfolio
-- Day 3: Aggregate functions and GROUP BY
-- Author: Yomna
-- Database: Chinook (MySQL)
-- ============================================================

-- 1. Count all invoices.
SELECT COUNT(*) AS total_invoices
FROM chinook.invoice;

-- 2. Overall revenue profile: total, average, min and max invoice value.
SELECT
    SUM(Total) AS total_revenue,
    AVG(Total) AS avg_invoice_value,
    MIN(Total) AS min_invoice,
    MAX(Total) AS max_invoice
FROM chinook.invoice;

-- 3. Revenue by Country: total revenue per billing country, highest first.
SELECT
    BillingCountry,
    SUM(Total) AS total_revenue
FROM chinook.invoice
GROUP BY BillingCountry
ORDER BY total_revenue DESC;

-- 4. Average invoice value per customer; top 10 customers by average.
SELECT
    CustomerId,
    AVG(Total) AS avg_invoice_value
FROM chinook.invoice
GROUP BY CustomerId
ORDER BY avg_invoice_value DESC
LIMIT 10;