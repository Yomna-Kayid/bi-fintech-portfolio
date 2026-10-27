/* ============================================================
   Day 7 - Week 1 review (SQL fundamentals)
   Author   : Yomna
   Database : Chinook (v1.4.5, SQL Server / T-SQL)
   Topics   : SELECT, WHERE, ORDER BY, TOP, aggregates, GROUP BY, HAVING,
              INNER / LEFT / RIGHT / FULL JOIN, anti-joins, WHERE vs ON,
              join fan-out

   How to read this file:
   - Practice questions written as stakeholder tickets (requesters are fictional).
   - "-- Check:" runs before the solution: validate your number.
   - "-- Expected:" runs after the solution: confirm the number.
   - Where the ticket is ambiguous, an "-- Assumption:" line is added.
   - Never SELECT * in a final answer.
   ============================================================ */

USE Chinook;
GO


/* ------------------------------------------------------------
   SECTION A - Retrieval and filtering  [Easy]
   ------------------------------------------------------------ */

-- Q1  (Requester: Marketing)
-- We are localizing our email campaigns. Which countries do our customers
-- live in? One row per country, alphabetical, no repeats.
-- Check: does the row count match SELECT COUNT(DISTINCT Country) FROM Customer?

-- My solution:
SELECT DISTINCT Country
FROM dbo.Customer
ORDER BY Country ASC;

-- Expected: 24 rows.

-- Check:
SELECT COUNT(DISTINCT Country) AS DistinctCountryCount
FROM dbo.Customer;


-- Q2  (Requester: Customer Success)
-- We are piloting a new onboarding flow with customers in the USA, Canada
-- and Brazil who use a Gmail address. Send me a list: one column with the
-- full name, plus country and email. Group them by country, then name.

-- My solution:
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    c.Country,
    c.Email
FROM dbo.Customer AS c
WHERE c.Country IN ('USA', 'Canada', 'Brazil')
  AND c.Email LIKE '%@gmail.com'
ORDER BY c.Country ASC, FullName ASC;

-- Expected: 5 rows.


-- Q3  (Requester: Content Licensing)
-- We are reviewing long-form tracks. Of the tracks whose name starts with
-- "A" and that run longer than 5 minutes, give me the 10 longest.
-- Show the track name and the length in minutes, rounded to 2 decimals.
-- Assumption: "longer than 5 minutes" = strictly greater than 300000 ms.
-- TrackId is a deterministic tie-breaker if durations match.

-- My solution:
SELECT TOP (10)
    t.Name AS TrackName,
    ROUND(t.Milliseconds / 60000.0, 2) AS LengthMinutes
FROM dbo.Track AS t
WHERE t.Name LIKE 'A%'
  AND t.Milliseconds > 5 * 60 * 1000
ORDER BY t.Milliseconds DESC, t.TrackId ASC;

-- Expected: 52 tracks qualify; TOP 10 keeps the longest.


-- Q4  (Requester: Finance)
-- For an audit sample I need mid-sized invoices (total from 5 to 10,
-- both ends included) billed to any country except the USA and Canada.
-- Highest total first. The list must come out in the same order every
-- time it is run, even when totals tie.

-- My solution:
SELECT
    i.InvoiceId,
    i.BillingCountry,
    i.Total
FROM dbo.Invoice AS i
WHERE i.Total BETWEEN 5 AND 10
  AND i.BillingCountry NOT IN ('USA', 'Canada')
ORDER BY i.Total DESC, i.InvoiceId ASC;

-- Expected: 74 rows.


-- Q5  (Requester: Product Analytics, for the catalog health dashboard)
-- One row, four numbers: how many tracks we have, how many different genres
-- are represented, the longest track, and the average track length
-- (both lengths in minutes, 2 decimals).
-- Note: AVG on Milliseconds * 1.0 avoids integer truncation.

-- My solution:
SELECT
    COUNT(t.TrackId)                       AS TotalTracks,
    COUNT(DISTINCT t.GenreId)              AS DistinctGenres,
    ROUND(MAX(t.Milliseconds) / 60000.0, 2) AS LongestTrackMinutes,
    ROUND(AVG(t.Milliseconds * 1.0) / 60000.0, 2) AS AverageTrackMinutes
FROM dbo.Track AS t;

-- Expected: 3503 tracks, 25 genres, longest 88.12 min, average 6.56 min.


/* ------------------------------------------------------------
   SECTION B - Aggregation  [Medium]
   ------------------------------------------------------------ */

-- Q6  (Requester: Regional Sales Lead)
-- I need a country scorecard for the board deck: for each billing country
-- show how many invoices there were, total revenue and the average invoice
-- value (2 decimals). Best-performing country on top.
-- The BI tool reads your column names directly, so name them cleanly.
-- Check: does the sum of revenue equal SELECT SUM(Total) FROM Invoice?

-- My solution:
SELECT
    i.BillingCountry,
    COUNT(i.InvoiceId)          AS InvoiceCount,
    SUM(i.Total)                AS TotalRevenue,
    ROUND(AVG(i.Total), 2)      AS AverageInvoiceValue
FROM dbo.Invoice AS i
GROUP BY i.BillingCountry
ORDER BY TotalRevenue DESC;

-- Expected: 24 rows.

-- Check:
SELECT SUM(Total) AS GrandRevenue FROM dbo.Invoice;


-- Q7  (Requester: Content Licensing)
-- Which are our five biggest albums by track count? Only consider albums
-- with more than 20 tracks. Show the album, how many tracks it has and the
-- average track length in minutes. You may only use the Track table;
-- say in a comment what you would add if the album title were needed.
-- Assumption: "biggest" = highest track count. Tie-breaker: AlbumId.
-- If album title were needed, I would INNER JOIN dbo.Album ON AlbumId.

-- My solution:
SELECT TOP (5)
    t.AlbumId,
    COUNT(*)                          AS TrackCount,
    ROUND(AVG(t.Milliseconds / 60000.0), 2) AS AvgTrackLengthMinutes
FROM dbo.Track AS t
GROUP BY t.AlbumId
HAVING COUNT(*) > 20
ORDER BY TrackCount DESC, t.AlbumId ASC;

-- Expected: first row AlbumId 141 with 57 tracks.


-- Q8  (Code review)
-- A junior analyst opened a pull request with these two queries. Both fail.
-- Tell them why in one sentence each and send back a fixed version.
--
--   (a) SELECT BillingCountry, Total
--       FROM Invoice
--       GROUP BY BillingCountry;
--
--   (b) SELECT BillingCountry, SUM(Total)
--       FROM Invoice
--       WHERE SUM(Total) > 40
--       GROUP BY BillingCountry;

-- Review comment on (a):
-- Total is neither in the GROUP BY nor inside an aggregate, so SQL Server
-- cannot decide which Total to return for each country.

-- Fixed (a):
SELECT
    i.BillingCountry,
    SUM(i.Total) AS TotalRevenue
FROM dbo.Invoice AS i
GROUP BY i.BillingCountry;

-- Review comment on (b):
-- Aggregates are not allowed in WHERE (which filters rows before grouping);
-- the group-level filter must be HAVING.

-- Fixed (b):
SELECT
    i.BillingCountry,
    SUM(i.Total) AS TotalRevenue
FROM dbo.Invoice AS i
GROUP BY i.BillingCountry
HAVING SUM(i.Total) > 40;


-- Q9  (Requester: Finance Controller)
-- Report revenue per country counting only "significant" invoices (total
-- above 5), and show only countries whose revenue under that rule is above 40.
-- A colleague says: "just drop the invoice filter, the countries will be
-- the same anyway." Is that true? Run both versions, compare, and tell me
-- in two sentences what changed and why.

-- My solution (significant invoices only):
SELECT
    i.BillingCountry,
    SUM(i.Total) AS TotalRevenue
FROM dbo.Invoice AS i
WHERE i.Total > 5
GROUP BY i.BillingCountry
HAVING SUM(i.Total) > 40;

-- Expected: 9 countries.

-- My solution (all invoices):
SELECT
    i.BillingCountry,
    SUM(i.Total) AS TotalRevenue
FROM dbo.Invoice AS i
GROUP BY i.BillingCountry
HAVING SUM(i.Total) > 40;

-- Expected: 15 countries.

-- Explanation:
-- Without the WHERE filter, invoices of 5 or less are counted, so every
-- country's revenue goes up. Six countries (Chile, Ireland, Hungary,
-- Austria, Finland, Netherlands) only cross 40 because of those small
-- invoices, so they appear only in the second result.


/* ------------------------------------------------------------
   SECTION C - Joining tables  [Medium]
   ------------------------------------------------------------ */

-- Q10  (Requester: Content Licensing)
-- For the licensing review I need the 10 longest tracks in the catalog with
-- the album title, the artist and the length in minutes.
-- Chain: Track -> Album -> Artist.

-- My solution:
SELECT TOP (10)
    t.Name                   AS TrackName,
    al.Title                 AS AlbumTitle,
    a.Name                   AS ArtistName,
    t.Milliseconds / 60000.0 AS LengthMinutes
FROM dbo.Track AS t
INNER JOIN dbo.Album  AS al ON t.AlbumId  = al.AlbumId
INNER JOIN dbo.Artist AS a  ON al.ArtistId = a.ArtistId
ORDER BY t.Milliseconds DESC;

-- Expected: first row 'Occupation / Precipice', Battlestar Galactica, ~88.12 min.


-- Q11  (Requester: Merchandising)
-- Which 5 genres sell the most units? If two genres are tied for fifth
-- place, I want both of them in the list. Units = total quantity sold.
-- Chain: Genre -> Track -> InvoiceLine.
-- Assumption: strictly top 5; if a tie at 5th is expected, use
-- DENSE_RANK (window function, Day 10) — not allowed today, so note it.

-- My solution:
SELECT TOP (5)
    g.Name             AS GenreName,
    SUM(il.Quantity)   AS TotalSoldUnits
FROM dbo.Genre AS g
INNER JOIN dbo.Track       AS t  ON g.GenreId = t.GenreId
INNER JOIN dbo.InvoiceLine AS il ON t.TrackId = il.TrackId
GROUP BY g.Name
ORDER BY TotalSoldUnits DESC;

-- Expected: Rock 835 first.

-- Note: to include ties at 5th place, DENSE_RANK() OVER (ORDER BY SUM(...) DESC)
-- is the correct tool; that arrives on Day 10.


-- Q12  (Requester: Label Relations)
-- We are preparing royalty conversations. List the top 5 artists by revenue
-- (revenue = unit price x quantity on the invoice lines).
-- Check: does the revenue of ALL artists add up to the revenue of ALL
-- invoice lines?
-- Chain: Artist -> Album -> Track -> InvoiceLine.

-- My solution:
SELECT TOP (5)
    a.Name                            AS ArtistName,
    SUM(il.UnitPrice * il.Quantity)   AS Revenue
FROM dbo.Artist AS a
INNER JOIN dbo.Album       AS al ON a.ArtistId = al.ArtistId
INNER JOIN dbo.Track       AS t  ON al.AlbumId = t.AlbumId
INNER JOIN dbo.InvoiceLine AS il ON t.TrackId  = il.TrackId
GROUP BY a.Name
ORDER BY Revenue DESC;

-- Expected: Iron Maiden 138.60 first.

-- Check: revenue of ALL artists should equal SUM(UnitPrice * Quantity)
-- across ALL invoice lines.
SELECT SUM(il.UnitPrice * il.Quantity) AS AllLineRevenue
FROM dbo.InvoiceLine AS il;


-- Q13  (Requester: Support Operations)
-- Build the sheet we hand to the support team: every customer with their
-- country and the name of the support rep assigned to them. Columns should be
-- CustomerName and SupportRepName. Sort by support rep, then customer.
-- Check: the sheet must have exactly one row per customer.
-- Assumption: LEFT JOIN keeps customers whose SupportRepId is NULL.

-- My solution:
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    c.Country,
    CONCAT(e.FirstName, ' ', e.LastName) AS SupportRepName
FROM dbo.Customer AS c
LEFT JOIN dbo.Employee AS e
    ON c.SupportRepId = e.EmployeeId
ORDER BY SupportRepName, CustomerName;

-- Expected: 59 rows (one per customer).

-- Check:
SELECT COUNT(*) AS CustomerCount FROM dbo.Customer;   -- must be 59


/* ------------------------------------------------------------
   SECTION D - Missing data and outer joins  [Medium / Hard]
   ------------------------------------------------------------ */

-- Q14  (Requester: Catalog Manager)
-- We are considering retiring tracks that have never been bought.
--   (a) How many such tracks are there?
--   (b) Give me the first 10 alphabetically, with album title and artist.
--   Context: the album feed is sometimes late, so a track can arrive with
--   no album. Make sure such tracks would NOT silently disappear from your
--   list, and say which join you used and why.

-- My solution (a):
SELECT COUNT(t.TrackId) AS UnsoldTracks
FROM dbo.Track AS t
LEFT JOIN dbo.InvoiceLine AS il
    ON t.TrackId = il.TrackId
WHERE il.InvoiceId IS NULL;

-- Expected: 1519.

-- My solution (b):
SELECT TOP (10)
    t.Name  AS TrackName,
    al.Title AS AlbumTitle,
    a.Name   AS ArtistName
FROM dbo.Track AS t
LEFT JOIN dbo.InvoiceLine AS il ON t.TrackId  = il.TrackId
LEFT JOIN dbo.Album       AS al ON t.AlbumId  = al.AlbumId
LEFT JOIN dbo.Artist      AS a  ON al.ArtistId = a.ArtistId
WHERE il.InvoiceId IS NULL
ORDER BY t.Name ASC;

-- Join choice and reason:
-- Used LEFT JOIN to Album and Artist. INNER JOIN would silently drop a
-- track whose AlbumId is NULL (the album feed is late per the ticket).
-- LEFT JOIN keeps every unsold track in the result regardless of whether
-- its album row exists yet.


-- Q15  (Requester: Head of Sales)
-- Workload report for every employee in the company, including people who
-- have no customers yet: number of customers, and the total revenue from
-- those customers' invoices. Show 0, not blank, when there is nothing.
-- Check: the revenue column must add up to SELECT SUM(Total) FROM Invoice.
-- Then explain why your customer count would be wrong without DISTINCT.

-- My solution:
SELECT
    e.EmployeeId,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    COUNT(DISTINCT c.CustomerId)         AS CustomerCount,
    COALESCE(SUM(i.Total), 0)            AS TotalRevenue
FROM dbo.Employee AS e
LEFT JOIN dbo.Customer AS c ON c.SupportRepId = e.EmployeeId
LEFT JOIN dbo.Invoice  AS i ON i.CustomerId   = c.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY TotalRevenue DESC, e.EmployeeId;

-- Expected: 8 rows; Jane Peacock 21 / 833.04, Margaret Park 20 / 775.40,
-- Steve Johnson 18 / 720.16, the other five employees 0 / 0.

-- Why DISTINCT:
-- After joining Invoice, each customer repeats once per invoice (Jane
-- Peacock: 21 customers but 146 rows), so COUNT(c.CustomerId) without
-- DISTINCT would return 146. SUM(i.Total) is safe because each row
-- carries a different invoice. COALESCE handles SUM over only NULLs
-- (returns NULL -> shown as 0).

-- Check: grand revenue must match.
SELECT SUM(Total) AS GrandRevenue FROM dbo.Invoice;   -- 2328.60


-- Q16  (Whiteboard question, no database)
-- Table C holds 5 customers (unique key). Table T holds 8 support tickets;
-- every ticket belongs to a customer in C, and 2 customers have never
-- opened a ticket. How many rows come back from:
--   C INNER JOIN T on the customer key = ?
--   C LEFT  JOIN T = ?
--   C RIGHT JOIN T = ?
--   C FULL  JOIN T = ?
-- In the FULL JOIN result, how many rows have NULLs on the ticket side?
-- On the customer side? 

-- My answers:
-- C INNER JOIN T = 8   (every ticket matches a customer)
-- C LEFT  JOIN T = 10  (8 matches + 2 unmatched customers)
-- C RIGHT JOIN T = 8   (every ticket matches)
-- C FULL  JOIN T = 10  (8 matches + 2 unmatched customers; no unmatched tickets)
-- FULL JOIN NULLs on the ticket side: 2 rows (the unmatched customers)
-- FULL JOIN NULLs on the customer side: 0 rows (all tickets match)


-- Q17  (Requester: Retention Analyst)
-- I want every customer, with their invoices above 15 if they have any.
-- A teammate wrote both queries below and got different results.
--
--   (a) SELECT c.CustomerId, c.LastName, i.InvoiceId
--       FROM Customer c
--       LEFT JOIN Invoice i
--              ON i.CustomerId = c.CustomerId AND i.Total > 15;
--
--   (b) SELECT c.CustomerId, c.LastName, i.InvoiceId
--       FROM Customer c
--       LEFT JOIN Invoice i ON i.CustomerId = c.CustomerId
--       WHERE i.Total > 15;
--
-- Which one answers my question? Prove it with row counts and distinct
-- customer counts. Then rerun both with 10 instead of 15 and explain why
-- the difference shrinks or disappears with this data.

-- My answer and verification queries:
-- (a) answers the question: condition in ON keeps customers with no
-- qualifying invoice (NULL-padded). (b) behaves like INNER JOIN because
-- WHERE runs after the join and removes the NULL-padded rows.

-- (a) with 15:
SELECT
    COUNT(*)                     AS [RowCount],
    COUNT(DISTINCT c.CustomerId) AS DistinctCustomers,
    SUM(CASE WHEN i.InvoiceId IS NULL THEN 1 ELSE 0 END) AS RowsWithoutInvoice
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
   AND i.Total > 15;

-- Expected: 59 rows, 59 distinct customers, 48 rows without invoice.

-- (b) with 15:
SELECT
    COUNT(*)                     AS [RowCount],
    COUNT(DISTINCT c.CustomerId) AS DistinctCustomers
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
WHERE i.Total > 15;

-- Expected: 11 rows, 11 distinct customers.

-- Bonus with 10: every customer has at least one invoice above 10, so (a) has no
-- NULL-padded rows and the difference disappears.

-- (a) with 10. Expected: 64 rows, 59 distinct customers.
SELECT
    COUNT(*)                     AS [RowCount],
    COUNT(DISTINCT c.CustomerId) AS DistinctCustomers
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
   AND i.Total > 10;

-- (b) with 10. Expected: 64 rows, 59 distinct customers.
SELECT
    COUNT(*)                     AS [RowCount],
    COUNT(DISTINCT c.CustomerId) AS DistinctCustomers
FROM dbo.Customer AS c
LEFT JOIN dbo.Invoice AS i
    ON i.CustomerId = c.CustomerId
WHERE i.Total > 10;

-- Q18  (Requester: Content Operations)
-- How many albums does each artist have? Include artists with no albums,
-- fewest albums first. A colleague's version used COUNT(*) and the dashboard
-- shows 1 album for artists that have none. Reproduce the bug, then fix it.

-- Buggy version:
SELECT
    a.Name   AS ArtistName,
    COUNT(*) AS Total
FROM dbo.Artist AS a
LEFT JOIN dbo.Album AS al ON a.ArtistId = al.ArtistId
GROUP BY a.ArtistId, a.Name
ORDER BY Total ASC, ArtistName;

-- Fixed version:
SELECT
    a.Name            AS ArtistName,
    COUNT(al.AlbumId) AS TotalAlbums
FROM dbo.Artist AS a
LEFT JOIN dbo.Album AS al ON a.ArtistId = al.ArtistId
GROUP BY a.ArtistId, a.Name
ORDER BY TotalAlbums ASC, ArtistName;

-- Explanation:
-- COUNT(*) counts the NULL-padded row from the LEFT JOIN, so an artist with
-- no albums gets 1 instead of 0. COUNT(al.AlbumId) ignores NULLs and
-- correctly returns 0. 71 artists have no albums.


/* ------------------------------------------------------------
   SECTION E - Interview-style  [Hard]
   ------------------------------------------------------------ */

-- Q19  (Requester: Finance, urgent)
-- The "Revenue per customer" dashboard total does not match the ledger
-- (SELECT SUM(Total) FROM Invoice). Its query is:
--
--   SELECT c.CustomerId, c.LastName, SUM(i.Total) AS Revenue
--   FROM Customer c
--   JOIN Invoice i      ON i.CustomerId = c.CustomerId
--   JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
--   GROUP BY c.CustomerId, c.LastName;
--
-- Find out why it is wrong, by how much, and fix it.
-- Prove the fix by matching the grand total to the ledger.

-- Diagnosis:
-- After joining InvoiceLine, each invoice repeats once per line (2240 lines
-- for 412 invoices), so SUM(i.Total) adds the same invoice total many times.
-- The grand total becomes 20848.62 instead of 2328.60.

-- Wrong grand total:
SELECT SUM(x.Revenue) AS WrongGrandTotal
FROM (
    SELECT c.CustomerId, c.LastName, SUM(i.Total) AS Revenue
    FROM dbo.Customer AS c
    JOIN dbo.Invoice AS i      ON i.CustomerId = c.CustomerId
    JOIN dbo.InvoiceLine AS il ON il.InvoiceId = i.InvoiceId
    GROUP BY c.CustomerId, c.LastName
) AS x;

-- Fixed query (sum at line level, where each row is counted once):
SELECT
    c.CustomerId,
    c.LastName,
    SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM dbo.Customer AS c
JOIN dbo.Invoice AS i      ON i.CustomerId = c.CustomerId
JOIN dbo.InvoiceLine AS il ON il.InvoiceId = i.InvoiceId
GROUP BY c.CustomerId, c.LastName;

-- Reconciliation query:
SELECT SUM(Total) AS LedgerTotal FROM dbo.Invoice;                 -- 2328.60
SELECT SUM(il.UnitPrice * il.Quantity) AS LineTotal
FROM dbo.InvoiceLine AS il;                                        -- 2328.60


-- Q20  (Code review of a legacy report)
-- Rewrite the legacy query below the way you would write it in a team
-- codebase (explicit joins, aliases, only the columns we need: customer
-- name, InvoiceId, TrackId, UnitPrice, Quantity).
-- Then give two concrete risks of the old style.
--
--   SELECT * FROM Customer, Invoice, InvoiceLine
--   WHERE Customer.CustomerId = Invoice.CustomerId
--     AND Invoice.InvoiceId   = InvoiceLine.InvoiceId
--     AND Country = 'USA';

-- My solution:
SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    i.InvoiceId,
    il.TrackId,
    il.UnitPrice,
    il.Quantity
FROM dbo.Customer AS c
INNER JOIN dbo.Invoice     AS i  ON c.CustomerId = i.CustomerId
INNER JOIN dbo.InvoiceLine AS il ON i.InvoiceId  = il.InvoiceId
WHERE c.Country = 'USA';

-- Expected: 494 rows.

-- Two risks:
-- 1. A forgotten join condition in WHERE raises no error and silently
--    returns a Cartesian product (every row of one table paired with every
--    row of the others).
-- 2. Join conditions and row filters are mixed in the same WHERE clause,
--    which makes the query hard to read and review, and the join type
--    cannot be stated explicitly.
