-- ============================================================
-- BI Developer Portfolio
-- Day 5: INNER JOIN
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- Main join key: Customer.CustomerId = Invoice.CustomerId
-- (one customer -> many invoices)
-- ============================================================

USE Chinook;
GO

-- 1. Customer name with every invoice id and total.
SELECT
    c.FirstName,
    c.LastName,
    i.InvoiceId,
    i.Total
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId;

-- 2. Same as 1, Brazilian customers only, highest invoice first.
SELECT
    c.FirstName,
    c.LastName,
    c.Country,
    i.InvoiceId,
    i.Total
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
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
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
WHERE i.Total > 10;

-- 4. Table aliases and a single full-name column via CONCAT.
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    i.Total
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId;

-- 5. Invoices issued in 2021, with customer name.
-- Half-open date range instead of BETWEEN: BETWEEN '2021-01-01' AND '2021-12-31'
-- would drop invoices stamped after 00:00:00 on the last day.
SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    i.InvoiceDate,
    i.Total
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
WHERE i.InvoiceDate >= '2021-01-01'
  AND i.InvoiceDate <  '2022-01-01';

-- 6. Total spend per customer; top 5 spenders.
SELECT TOP 5
    c.CustomerId,
    c.FirstName,
    c.LastName,
    SUM(i.Total) AS total_spent
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY total_spent DESC;

-- 7. Customers with more than 6 invoices.
-- Aggregate repeated in HAVING: T-SQL does not allow a SELECT alias there.
SELECT
    c.CustomerId,
    c.FirstName,
    c.LastName,
    COUNT(i.InvoiceId) AS invoice_count
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING COUNT(i.InvoiceId) > 6;

-- 8. Invoice with its line items.
-- Key: Invoice.InvoiceId = InvoiceLine.InvoiceId (one invoice -> many lines)
SELECT
    i.InvoiceId,
    il.TrackId,
    il.UnitPrice,
    il.Quantity
FROM dbo.Invoice AS i
INNER JOIN dbo.InvoiceLine AS il
    ON i.InvoiceId = il.InvoiceId;

-- 9. Track with its album and artist.
-- Keys: Track.AlbumId = Album.AlbumId, Album.ArtistId = Artist.ArtistId
-- INNER JOIN drops tracks without an album (AlbumId IS NULL), if any exist.
SELECT
    t.Name  AS TrackName,
    al.Title AS AlbumTitle,
    ar.Name AS ArtistName
FROM dbo.Track AS t
INNER JOIN dbo.Album AS al
    ON t.AlbumId = al.AlbumId
INNER JOIN dbo.Artist AS ar
    ON al.ArtistId = ar.ArtistId;
