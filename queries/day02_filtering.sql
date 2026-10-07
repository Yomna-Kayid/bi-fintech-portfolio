-- ============================================================
-- BI Developer Portfolio
-- Day 2: WHERE, LIKE, AND/OR, ORDER BY, LIMIT
-- Author: Yomna
-- Database: Chinook (MySQL)
-- ============================================================

-- 1. Filter customers by exact country match.
SELECT *
FROM chinook.customer
WHERE Country = 'India';

-- 2. Albums whose title starts with 'A' (prefix match).
SELECT *
FROM chinook.album
WHERE Title LIKE 'A%';

-- 3. Artists whose name starts with 'A'.
SELECT *
FROM chinook.artist
WHERE Name LIKE 'A%';

-- 4. Artists with 'The' anywhere in the name.
-- Substring match: also hits words like 'Other'. MySQL LIKE is case-insensitive by default collation.
SELECT *
FROM chinook.artist
WHERE Name LIKE '%The%';

-- 5. Artists whose name ends with 's' (suffix match).
SELECT *
FROM chinook.artist
WHERE Name LIKE '%s';

-- 6. OR: customers from the USA or Canada.
SELECT CustomerId, FirstName, LastName, Country
FROM chinook.customer
WHERE Country = 'USA'
   OR Country = 'Canada';

-- 7. AND: customers in the USA located in California.
SELECT CustomerId, FirstName, LastName, City, State
FROM chinook.customer
WHERE Country = 'USA'
  AND State = 'CA';

-- 8. ORDER BY + LIMIT: five highest-value invoices.
SELECT InvoiceId, CustomerId, InvoiceDate, BillingCountry, Total
FROM chinook.invoice
ORDER BY Total DESC
LIMIT 5;

-- 9. Invoices with a total greater than 5.
SELECT *
FROM chinook.invoice
WHERE Total > 5;

-- 10. Invoices between 5 and 10 (BETWEEN is inclusive on both ends).
SELECT *
FROM chinook.invoice
WHERE Total BETWEEN 5 AND 10;

-- 11. Customers sorted by country, A to Z.
SELECT *
FROM chinook.customer
ORDER BY Country ASC;

-- ============================================================
-- Preview: first JOIN (formal coverage on Day 5)
-- ============================================================

-- 12. Join album to artist on ArtistId; filter artists starting with 'A'.
SELECT
    artist.Name  AS ArtistName,
    album.Title  AS AlbumTitle
FROM chinook.album
JOIN chinook.artist
    ON album.ArtistId = artist.ArtistId
WHERE artist.Name LIKE 'A%'
ORDER BY artist.Name, album.Title;