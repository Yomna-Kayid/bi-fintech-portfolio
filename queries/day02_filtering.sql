-- ============================================================
-- BI Developer Portfolio
-- Day 2: WHERE, LIKE, AND/OR, BETWEEN, ORDER BY, TOP, OFFSET-FETCH
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- ============================================================

USE Chinook;
GO

-- 1. Filter customers by exact country match.
SELECT *
FROM dbo.Customer
WHERE Country = 'India';

-- 2. Albums whose title starts with 'A' (prefix match).
SELECT *
FROM dbo.Album
WHERE Title LIKE 'A%';

-- 3. Artists whose name starts with 'A'.
SELECT *
FROM dbo.Artist
WHERE Name LIKE 'A%';

-- 4. Artists with 'The' anywhere in the name.
-- Substring match: also hits words like 'Other'. Case sensitivity depends on
-- the database collation (default is case-insensitive).
SELECT *
FROM dbo.Artist
WHERE Name LIKE '%The%';

-- 5. Artists whose name ends with 's' (suffix match).
SELECT *
FROM dbo.Artist
WHERE Name LIKE '%s';

-- 6. OR: customers from the USA or Canada.
SELECT CustomerId, FirstName, LastName, Country
FROM dbo.Customer
WHERE Country = 'USA'
   OR Country = 'Canada';

-- 7. AND: customers in the USA located in California.
SELECT CustomerId, FirstName, LastName, City, State
FROM dbo.Customer
WHERE Country = 'USA'
  AND State = 'CA';

-- 8. TOP: five highest-value invoices.
-- InvoiceId as tiebreaker keeps the order deterministic when totals are equal.
SELECT TOP 5 InvoiceId, CustomerId, InvoiceDate, BillingCountry, Total
FROM dbo.Invoice
ORDER BY Total DESC, InvoiceId;

-- 9. Pagination: second page (rows 6-10) of the same ranking.
-- OFFSET...FETCH is the T-SQL equivalent of LIMIT/OFFSET and requires ORDER BY.
SELECT InvoiceId, CustomerId, InvoiceDate, BillingCountry, Total
FROM dbo.Invoice
ORDER BY Total DESC, InvoiceId
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

-- 10. Tracks at a specific price point.
SELECT TrackId, Name, UnitPrice
FROM dbo.Track
WHERE UnitPrice = 1.99;

-- 11. Invoices with a total greater than 5.
SELECT *
FROM dbo.Invoice
WHERE Total > 5;

-- 12. Invoices between 5 and 10 (BETWEEN is inclusive on both ends).
SELECT *
FROM dbo.Invoice
WHERE Total BETWEEN 5 AND 10;

-- 13. Customers sorted by country, A to Z.
SELECT *
FROM dbo.Customer
ORDER BY Country ASC;

-- ============================================================
-- Preview: first JOIN (formal coverage on Day 5)
-- ============================================================

-- 14. Join album to artist on ArtistId; filter artists starting with 'A'.
SELECT
    ar.Name  AS ArtistName,
    al.Title AS AlbumTitle
FROM dbo.Album AS al
INNER JOIN dbo.Artist AS ar
    ON al.ArtistId = ar.ArtistId
WHERE ar.Name LIKE 'A%'
ORDER BY ar.Name, al.Title;
