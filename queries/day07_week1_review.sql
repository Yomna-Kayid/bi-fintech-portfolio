-- ============================================================
-- BI Developer Portfolio
-- Day 7: Week 1 review (SQL fundamentals)
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- Topics: SELECT, WHERE, ORDER BY, TOP, aggregates, GROUP BY, HAVING,
--         INNER / LEFT / RIGHT / FULL JOIN, anti-joins, WHERE vs ON, join fan-out
-- ============================================================

USE Chinook;
GO

-- ------------------------------------------------------------
-- Section A: SELECT / WHERE / ORDER BY
-- ------------------------------------------------------------

-- Q1. Distinct customer countries, A to Z.
-- Expected: 24 rows.
SELECT DISTINCT Country
FROM dbo.Customer
ORDER BY Country ASC;

-- Q2. Customers from USA, Canada or Brazil with a Gmail address.
-- Expected: 5 rows.
SELECT
    CONCAT(FirstName, ' ', LastName) AS FullName,
    Country,
    Email
FROM dbo.Customer
WHERE Country IN ('USA', 'Canada', 'Brazil')
  AND Email LIKE '%@gmail.com'
ORDER BY Country, FullName;

-- Q3. Ten longest tracks starting with 'A' and longer than 5 minutes.
-- Dividing by 60000.0 (not 60000) avoids integer division.
-- 52 tracks qualify; TOP 10 keeps the longest.
SELECT TOP 10
    Name,
    Milliseconds / 60000.0 AS minutes
FROM dbo.Track
WHERE Name LIKE 'A%'
  AND Milliseconds > 300000
ORDER BY Milliseconds DESC;

-- Q4. Non-USA, non-Canada invoices between 5 and 10, highest first.
-- InvoiceId breaks ties between equal totals.
-- Expected: 74 rows.
SELECT
    InvoiceId,
    BillingCountry,
    Total
FROM dbo.Invoice
WHERE BillingCountry NOT IN ('USA', 'Canada')
  AND Total BETWEEN 5 AND 10
ORDER BY Total DESC, InvoiceId ASC;

-- Q5. Track table profile in one query.
-- AVG on Milliseconds * 1.0 avoids integer truncation.
-- Expected: 3503 tracks, 25 genres, longest 5286953 ms, average 393599.21 ms.
SELECT
    COUNT(TrackId)           AS TotalTracks,
    COUNT(DISTINCT GenreId)  AS GenreCount,
    MAX(Milliseconds)        AS LongestDuration,
    AVG(Milliseconds * 1.0)  AS AverageDuration
FROM dbo.Track;

-- ------------------------------------------------------------
-- Section B: GROUP BY / HAVING
-- ------------------------------------------------------------

-- Q6. Invoices, revenue and average invoice value per billing country.
-- Expected: 24 rows.
SELECT
    BillingCountry,
    COUNT(InvoiceId)     AS InvoiceCount,
    SUM(Total)           AS TotalRevenue,
    ROUND(AVG(Total), 2) AS AverageInvoiceValue
FROM dbo.Invoice
GROUP BY BillingCountry
ORDER BY TotalRevenue DESC;

-- Q7. Albums with more than 20 tracks: track count and average length in minutes.
-- HAVING filters albums after the count. Expected: first row AlbumId 141, 57 tracks.
SELECT TOP 5
    AlbumId,
    COUNT(*)                     AS TrackCount,
    AVG(Milliseconds / 60000.0)  AS AvgTrackLengthMinutes
FROM dbo.Track
GROUP BY AlbumId
HAVING COUNT(*) > 20
ORDER BY TrackCount DESC;

-- Q8. Debug two failing queries.
-- (a) fails: Total is neither in GROUP BY nor inside an aggregate, so SQL Server cannot
--     decide which Total to return for each country.
-- Fixed (a):
SELECT
    BillingCountry,
    SUM(Total) AS TotalRevenue
FROM dbo.Invoice
GROUP BY BillingCountry;

-- (b) fails: aggregates are not allowed in WHERE, which filters rows before grouping.
--     HAVING filters groups after aggregation.
-- Fixed (b):
SELECT
    BillingCountry,
    SUM(Total) AS TotalRevenue
FROM dbo.Invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 40;

-- Q9. WHERE before grouping vs no row filter.
-- With the invoice filter: 9 countries pass the 40 threshold.
SELECT
    BillingCountry,
    SUM(Total) AS TotalRevenue
FROM dbo.Invoice
WHERE Total > 5
GROUP BY BillingCountry
HAVING SUM(Total) > 40;

-- Without the invoice filter: 15 countries pass.
SELECT
    BillingCountry,
    SUM(Total) AS TotalRevenue
FROM dbo.Invoice
GROUP BY BillingCountry
HAVING SUM(Total) > 40;

-- Explanation: without the WHERE filter, invoices of 5 or less are counted, so every
-- country's revenue goes up. Six countries (Chile, Ireland, Hungary, Austria, Finland,
-- Netherlands) only cross 40 because of those small invoices, so they appear only in the
-- second result.

-- ------------------------------------------------------------
-- Section C: INNER JOIN and multi-table joins
-- ------------------------------------------------------------

-- Q10. Ten longest tracks with album, artist and length in minutes.
-- Chain: Track -> Album -> Artist.
-- Expected: first row 'Occupation / Precipice', Battlestar Galactica, about 88.12 minutes.
SELECT TOP 10
    t.Name                  AS TrackName,
    al.Title                AS AlbumTitle,
    a.Name                  AS ArtistName,
    t.Milliseconds / 60000.0 AS LengthMinutes
FROM dbo.Track AS t
INNER JOIN dbo.Album AS al
    ON t.AlbumId = al.AlbumId
INNER JOIN dbo.Artist AS a
    ON al.ArtistId = a.ArtistId
ORDER BY t.Milliseconds DESC;

-- Q11. Top 5 genres by units sold.
-- Chain: Genre -> Track -> InvoiceLine. Expected: Rock 835 first.
SELECT TOP 5
    g.Name         AS GenreName,
    SUM(il.Quantity) AS TotalSoldUnits
FROM dbo.Genre AS g
INNER JOIN dbo.Track AS t
    ON g.GenreId = t.GenreId
INNER JOIN dbo.InvoiceLine AS il
    ON t.TrackId = il.TrackId
GROUP BY g.Name
ORDER BY TotalSoldUnits DESC;

-- Q12. Top 5 artists by revenue.
-- Chain: Artist -> Album -> Track -> InvoiceLine. Expected: Iron Maiden 138.60 first.
SELECT TOP 5
    a.Name                          AS ArtistName,
    SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM dbo.Artist AS a
INNER JOIN dbo.Album AS al
    ON a.ArtistId = al.ArtistId
INNER JOIN dbo.Track AS t
    ON al.AlbumId = t.AlbumId
INNER JOIN dbo.InvoiceLine AS il
    ON t.TrackId = il.TrackId
GROUP BY a.Name
ORDER BY Revenue DESC;

-- Q13. Customers with their support rep.
-- LEFT JOIN keeps customers that have no support rep. Expected: 59 rows.
SELECT
    CONCAT(e.FirstName, ' ', e.LastName) AS SupportRepName,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    c.Country
FROM dbo.Customer AS c
LEFT JOIN dbo.Employee AS e
    ON c.SupportRepId = e.EmployeeId
ORDER BY SupportRepName, CustomerName;

-- ------------------------------------------------------------
-- Section D: OUTER JOINs and NULLs
-- ------------------------------------------------------------

-- Q14 (a). Tracks that were never sold (anti-join).
-- Expected: 1519.
SELECT COUNT(t.TrackId) AS UnsoldTracks
FROM dbo.Track AS t
LEFT JOIN dbo.InvoiceLine AS il
    ON t.TrackId = il.TrackId
WHERE il.InvoiceId IS NULL;

-- Q14 (b). First 10 unsold tracks alphabetically, with album title.
-- LEFT JOIN to Album is the safe choice: a track without an album stays in the result.
-- INNER JOIN would drop it. In this dataset every track has an album, so both match.
SELECT TOP 10
    t.Name  AS TrackName,
    al.Title AS AlbumTitle
FROM dbo.Track AS t
LEFT JOIN dbo.InvoiceLine AS il
    ON t.TrackId = il.TrackId
LEFT JOIN dbo.Album AS al
    ON t.AlbumId = al.AlbumId
WHERE il.InvoiceId IS NULL
ORDER BY t.Name ASC;

-- Q15. Customers and revenue per employee, including employees with no customers.
-- Expected: 8 rows; Jane Peacock 21 customers / 833.04, Margaret Park 20 / 775.40,
-- Steve Johnson 18 / 720.16, the other five employees 0 / 0.
SELECT
    e.EmployeeId,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(DISTINCT c.CustomerId)         AS CustomerCount,
    COALESCE(SUM(i.Total), 0)            AS TotalRevenue
FROM dbo.Employee AS e
LEFT JOIN dbo.Customer AS c
    ON c.SupportRepId = e.EmployeeId
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY TotalRevenue DESC, e.EmployeeId;

-- Why DISTINCT: after joining Invoice, each customer repeats once per invoice
-- (Jane Peacock: 21 customers but 146 rows), so COUNT(c.CustomerId) would return 146.
-- SUM(i.Total) is safe because each row carries a different invoice.
-- COALESCE: SUM over only NULLs returns NULL, so it is replaced with 0.

-- Q16. A (5 rows, unique key) and B (8 rows, every B key exists in A, 2 A rows unmatched).
-- A INNER JOIN B = 8
-- A LEFT  JOIN B = 10   (8 matches + 2 unmatched A rows)
-- A RIGHT JOIN B = 8    (all B rows match)
-- A FULL  JOIN B = 10
-- In the FULL JOIN: 2 rows have NULLs on the B side (the unmatched A rows),
-- 0 rows have NULLs on the A side.

-- Q17. WHERE vs ON in a LEFT JOIN.
-- Prediction: (a), with the condition in ON, keeps customers that have no invoice above 15.
-- In (b) the WHERE filter runs after the join and removes the NULL-padded rows,
-- so the LEFT JOIN behaves like an INNER JOIN.

-- (a) Condition in ON, threshold 15. Expected: 59 rows, 59 customers (48 with a NULL InvoiceId).
SELECT
    COUNT(*)                     AS [RowCount],
    COUNT(DISTINCT c.CustomerId) AS DistinctCustomers,
    SUM(CASE WHEN i.InvoiceId IS NULL THEN 1 ELSE 0 END) AS RowsWithoutInvoice
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
   AND i.Total > 15;

-- (b) Condition in WHERE, threshold 15. Expected: 11 rows, 11 customers.
SELECT
    COUNT(*)                     AS [RowCount],
    COUNT(DISTINCT c.CustomerId) AS DistinctCustomers
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
WHERE i.Total > 15;

-- Bonus: same two queries with 10. Expected: both return 64 rows and 59 customers.
-- Every customer has at least one invoice above 10, so (a) has no NULL-padded rows
-- and the difference disappears.
SELECT COUNT(*) AS [RowCount], COUNT(DISTINCT c.CustomerId) AS DistinctCustomers
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
   AND i.Total > 10;

SELECT COUNT(*) AS [RowCount], COUNT(DISTINCT c.CustomerId) AS DistinctCustomers
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
WHERE i.Total > 10;

-- Q18. Albums per artist, two versions.
-- Correct: COUNT(al.AlbumId) ignores the NULL from the LEFT JOIN, so an artist with
-- no albums gets 0.
SELECT
    a.Name AS ArtistName,
    COUNT(al.AlbumId) AS TotalAlbums
FROM dbo.Artist AS a
LEFT JOIN dbo.Album AS al
    ON a.ArtistId = al.ArtistId
GROUP BY a.ArtistId, a.Name
ORDER BY TotalAlbums ASC, ArtistName;

-- Wrong: COUNT(*) counts the NULL-padded row, so the same artists get 1 instead of 0.
SELECT
    a.Name AS ArtistName,
    COUNT(*) AS Total
FROM dbo.Artist AS a
LEFT JOIN dbo.Album AS al
    ON a.ArtistId = al.ArtistId
GROUP BY a.ArtistId, a.Name
ORDER BY Total ASC, ArtistName;

-- 71 artists have no albums.

-- ------------------------------------------------------------
-- Section E: Interview-style questions
-- ------------------------------------------------------------

-- Q19 (a). Revenue per customer from Customer and Invoice.
-- Grand total = 2328.60, equal to SELECT SUM(Total) FROM dbo.Invoice.
SELECT
    c.CustomerId,
    SUM(i.Total) AS Total
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId;

-- Q19 (b). Same query after joining InvoiceLine: WRONG.
-- Each invoice repeats once per line (2240 lines for 412 invoices), so SUM(i.Total)
-- adds the same invoice total many times. Grand total becomes 20848.62.
SELECT
    c.CustomerId,
    SUM(i.Total) AS Total
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
LEFT JOIN dbo.InvoiceLine AS il
    ON il.InvoiceId = i.InvoiceId
GROUP BY c.CustomerId;

-- Fixed (b): sum at line level, where each row is counted once.
SELECT
    c.CustomerId,
    SUM(il.UnitPrice * il.Quantity) AS Total
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
LEFT JOIN dbo.InvoiceLine AS il
    ON il.InvoiceId = i.InvoiceId
GROUP BY c.CustomerId;

-- Check: grand totals. Expected: both 2328.60.
SELECT SUM(Total) AS InvoiceTotal
FROM dbo.Invoice;

SELECT SUM(x.Total) AS FixedTotal
FROM (
    SELECT
        c.CustomerId,
        SUM(il.UnitPrice * il.Quantity) AS Total
    FROM dbo.Customer AS c
    LEFT JOIN dbo.Invoice AS i
        ON c.CustomerId = i.CustomerId
    LEFT JOIN dbo.InvoiceLine AS il
        ON il.InvoiceId = i.InvoiceId
    GROUP BY c.CustomerId
) AS x;

-- Q20. Professional rewrite: explicit JOINs, aliases, only the needed columns.
-- Expected: 494 rows.
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    i.InvoiceId,
    il.TrackId,
    il.UnitPrice,
    il.Quantity
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice AS i
    ON c.CustomerId = i.CustomerId
INNER JOIN dbo.InvoiceLine AS il
    ON i.InvoiceId = il.InvoiceId
WHERE c.Country = 'USA';

-- Two risks of the comma-join style:
-- 1. A forgotten join condition in WHERE raises no error and silently returns a
--    Cartesian product (every row of one table paired with every row of the others).
-- 2. Join conditions and row filters are mixed in the same WHERE clause, which makes the
--    query hard to read and review, and the join type cannot be stated explicitly.
