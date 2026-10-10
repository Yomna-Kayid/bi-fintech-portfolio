-- ============================================================
-- BI Developer Portfolio
-- Day 6: Multi-table joins, LEFT / RIGHT / FULL JOIN
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- Join chain: Customer -> Invoice -> InvoiceLine -> Track
-- ============================================================

USE Chinook;
GO

-- ------------------------------------------------------------
-- Part 1: Multi-table INNER JOIN
-- ------------------------------------------------------------

-- 1. Line-level detail: customer, invoice, unit price, quantity.
-- Keys: Customer.CustomerId = Invoice.CustomerId,
--       Invoice.InvoiceId   = InvoiceLine.InvoiceId
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    i.InvoiceId,
    il.UnitPrice,
    il.Quantity
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
INNER JOIN dbo.InvoiceLine AS il
    ON i.InvoiceId = il.InvoiceId;

-- 2. Total tracks purchased per customer.
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    SUM(il.Quantity) AS total_tracks_purchased
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
INNER JOIN dbo.InvoiceLine AS il
    ON i.InvoiceId = il.InvoiceId
GROUP BY c.CustomerId, c.FirstName, c.LastName;

-- 3. Four-table join: quantity purchased per customer per track.
-- Extra key: InvoiceLine.TrackId = Track.TrackId
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    t.Name AS TrackName,
    SUM(il.Quantity) AS quantity_purchased
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
INNER JOIN dbo.InvoiceLine AS il
    ON i.InvoiceId = il.InvoiceId
INNER JOIN dbo.Track AS t
    ON il.TrackId = t.TrackId
GROUP BY c.CustomerId, c.FirstName, c.LastName, t.Name;

-- ------------------------------------------------------------
-- Part 2: LEFT JOIN
-- ------------------------------------------------------------

-- 4. All customers with their invoices.
-- LEFT JOIN keeps every customer even if no invoice matches.
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    i.InvoiceId,
    i.Total
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId;

-- 5. Anti-join: customers with no invoices.
-- Rows with no match carry NULL in the right table's columns.
-- Expected on standard Chinook: 0 rows (every customer has invoices).
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;

-- 6. Customers handled per employee, including employees with 0.
-- COUNT(c.CustomerId) ignores NULLs, so unmatched employees return 0.
-- COUNT(*) would return 1 for them, because the NULL-padded row still counts.
SELECT
    e.EmployeeId,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(c.CustomerId) AS customer_count
FROM dbo.Employee AS e
LEFT JOIN dbo.Customer AS c
    ON c.SupportRepId = e.EmployeeId
GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 7. Artists with no albums (LEFT JOIN anti-join).
SELECT
    ar.ArtistId,
    ar.Name
FROM dbo.Artist AS ar
LEFT JOIN dbo.Album AS al
    ON al.ArtistId = ar.ArtistId
WHERE al.AlbumId IS NULL;

-- ------------------------------------------------------------
-- Part 3: INNER vs LEFT, RIGHT JOIN, FULL JOIN
-- ------------------------------------------------------------

-- 8. Same as query 6 with INNER JOIN.
-- Returns 3 rows (employees who support customers); query 6 returns 8,
-- because LEFT JOIN also keeps the 5 employees with 0 customers.
SELECT
    e.EmployeeId,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(c.CustomerId) AS customer_count
FROM dbo.Employee AS e
INNER JOIN dbo.Customer AS c
    ON c.SupportRepId = e.EmployeeId
GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 9. Query 7 rewritten with RIGHT JOIN (table order flipped).
-- Same rows as query 7: A LEFT JOIN B equals B RIGHT JOIN A.
SELECT
    ar.ArtistId,
    ar.Name
FROM dbo.Album AS al
RIGHT JOIN dbo.Artist AS ar
    ON al.ArtistId = ar.ArtistId
WHERE al.AlbumId IS NULL;

-- 10. FULL OUTER JOIN: employees and customers.
-- Keeps unmatched rows from both sides. Only the employee side has unmatched
-- rows here (employees with no customers, customer columns NULL); every
-- customer has a support rep.
-- MySQL has no FULL JOIN and needs LEFT JOIN ... UNION ... RIGHT JOIN instead.
SELECT
    e.EmployeeId, e.FirstName AS emp_name,
    c.CustomerId, c.FirstName AS cust_name
FROM dbo.Employee AS e
FULL OUTER JOIN dbo.Customer AS c
    ON c.SupportRepId = e.EmployeeId;
