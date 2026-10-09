-- ============================================================
-- BI Developer Portfolio
-- Day 6: Multi-table joins, LEFT / RIGHT / FULL JOIN
-- Author: Yomna
-- Database: Chinook (MySQL)
-- Join chain: customer -> invoice -> invoiceline -> track
-- ============================================================

-- ------------------------------------------------------------
-- Part 1: Multi-table INNER JOIN
-- ------------------------------------------------------------

-- 1. Line-level detail: customer, invoice, unit price, quantity.
-- Keys: customer.CustomerId = invoice.CustomerId,
--       invoice.InvoiceId   = invoiceline.InvoiceId
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    i.InvoiceId,
    il.UnitPrice,
    il.Quantity
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
INNER JOIN chinook.invoiceline AS il
    ON i.InvoiceId = il.InvoiceId;

-- 2. Total tracks purchased per customer.
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    SUM(il.Quantity) AS total_tracks_purchased
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
INNER JOIN chinook.invoiceline AS il
    ON i.InvoiceId = il.InvoiceId
GROUP BY c.CustomerId, c.FirstName, c.LastName;

-- 3. Four-table join: quantity purchased per customer per track.
-- Extra key: invoiceline.TrackId = track.TrackId
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    t.Name AS TrackName,
    SUM(il.Quantity) AS quantity_purchased
FROM chinook.customer AS c
INNER JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
INNER JOIN chinook.invoiceline AS il
    ON i.InvoiceId = il.InvoiceId
INNER JOIN chinook.track AS t
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
FROM chinook.customer AS c
LEFT JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId;

-- 5. Anti-join: customers with no invoices.
-- Rows with no match carry NULL in the right table's columns.
-- Expected on standard Chinook: 0 rows (every customer has invoices).
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName
FROM chinook.customer AS c
LEFT JOIN chinook.invoice AS i
    ON c.CustomerId = i.CustomerId
WHERE i.InvoiceId IS NULL;

-- 6. Customers handled per employee, including employees with 0.
-- COUNT(c.CustomerId) ignores NULLs, so unmatched employees return 0.
-- COUNT(*) would return 1 for them, because the NULL-padded row still counts.
SELECT
    e.EmployeeId,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(c.CustomerId) AS customer_count
FROM chinook.employee AS e
LEFT JOIN chinook.customer AS c
    ON c.SupportRepId = e.EmployeeId
GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 7. Artists with no albums (LEFT JOIN anti-join).
SELECT
    a.ArtistId,
    a.Name
FROM chinook.artist AS a
LEFT JOIN chinook.album AS al
    ON al.ArtistId = a.ArtistId
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
FROM chinook.employee AS e
INNER JOIN chinook.customer AS c
    ON c.SupportRepId = e.EmployeeId
GROUP BY e.EmployeeId, e.FirstName, e.LastName;

-- 9. Query 7 rewritten with RIGHT JOIN (table order flipped).
-- Same rows as query 7: A LEFT JOIN B equals B RIGHT JOIN A.
SELECT
    a.ArtistId,
    a.Name
FROM chinook.album AS al
RIGHT JOIN chinook.artist AS a
    ON al.ArtistId = a.ArtistId
WHERE al.AlbumId IS NULL;

-- 10. FULL JOIN emulation: employees and customers.
-- MySQL has no FULL JOIN, so combine LEFT JOIN and RIGHT JOIN with UNION.
-- UNION removes the matched rows that both halves return.
-- Result: only the employee side has unmatched rows (employees with no customers,
-- customer columns NULL); every customer has a support rep.
SELECT
    e.EmployeeId, e.FirstName AS emp_name,
    c.CustomerId, c.FirstName AS cust_name
FROM chinook.employee AS e
LEFT JOIN chinook.customer AS c
    ON c.SupportRepId = e.EmployeeId
UNION
SELECT
    e.EmployeeId, e.FirstName AS emp_name,
    c.CustomerId, c.FirstName AS cust_name
FROM chinook.employee AS e
RIGHT JOIN chinook.customer AS c
    ON c.SupportRepId = e.EmployeeId;
