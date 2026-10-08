-- ============================================================
-- BI Developer Portfolio
-- Day 5: INNER JOIN
-- Author: Yomna
-- Database: Chinook (MySQL)
-- Join key used throughout: customer.CustomerId = invoice.CustomerId
-- (one customer -> many invoices)
-- ============================================================

-- 1. Customer name with every invoice id and total.
SELECT
    c.FirstName,
    c.LastName,
    i.InvoiceId,
    i.Total
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId;

-- 2. Same as 1, Brazilian customers only, highest invoice first.
SELECT
    c.FirstName,
    c.LastName,
    c.Country,
    i.InvoiceId,
    i.Total
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
WHERE c.Country = 'Brazil'
ORDER BY i.Total DESC;

-- 3. Invoices above 10 with invoice date and billing country.
SELECT
    c.FirstName,
    c.LastName,
    i.InvoiceDate,
    i.BillingCountry,
    i.Total
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
WHERE i.Total > 10;

-- 4. Table aliases and a single full-name column via CONCAT.
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    i.Total
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId;

-- 5. Invoices issued in 2021, with customer name.
-- Half-open date range instead of BETWEEN: BETWEEN '2021-01-01' AND '2021-12-31'
-- would drop invoices stamped after 00:00:00 on the last day.
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    i.InvoiceDate,
    i.Total
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
WHERE i.InvoiceDate >= '2021-01-01'
  AND i.InvoiceDate <  '2022-01-01';

-- 6. Total spend per customer; top 5 spenders.
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    SUM(i.Total) AS total_spent
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY total_spent DESC
LIMIT 5;

-- 7. Customers with more than 6 invoices.
-- Aggregate repeated in HAVING (alias in HAVING is MySQL-only, fails on SQL Server/PostgreSQL).
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    COUNT(i.InvoiceId) AS invoice_count
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING COUNT(i.InvoiceId) > 6;
