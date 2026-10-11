-- ============================================================
-- BI Developer Portfolio
-- Extra practice: string, arithmetic and date functions
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- Date functions are revisited formally on Day 13.
-- ============================================================

USE Chinook;
GO

-- 1. String: replace characters and measure length.
-- REPLACE case sensitivity follows the collation (default is case-insensitive).
SELECT
    FirstName,
    REPLACE(FirstName, 'a', '*') AS name_masked,
    LEN(FirstName)               AS name_length
FROM dbo.Customer;

-- 2. String: slice from both ends and change case.
SELECT
    FirstName,
    LEFT(FirstName, 3)  AS first_3,
    RIGHT(FirstName, 3) AS last_3,
    UPPER(FirstName)    AS name_upper,
    LOWER(FirstName)    AS name_lower
FROM dbo.Customer;

-- 3. Arithmetic on a numeric column.
SELECT
    Total,
    Total + 10 AS total_plus_10,
    Total * 2  AS total_doubled
FROM dbo.Invoice;

-- 4. Current date and its parts.
-- YEAR(x) is shorthand for DATEPART(YEAR, x).
SELECT
    GETDATE()                 AS system_datetime,
    YEAR(GETDATE())           AS system_year,
    MONTH(GETDATE())          AS system_month,
    DATEPART(YEAR, GETDATE()) AS system_year_datepart;

-- 5. DATEADD: shift a date back one year (year-over-year comparison base).
SELECT
    InvoiceDate,
    DATEADD(YEAR, -1, InvoiceDate) AS same_date_prev_year
FROM dbo.Invoice;

-- 6. DATEADD + DATEDIFF: payment due date and months since the invoice.
-- DATEDIFF counts month boundaries crossed, not full elapsed months:
-- DATEDIFF(MONTH, '2026-01-31', '2026-02-01') returns 1.
SELECT
    InvoiceDate,
    DATEADD(DAY, 3, InvoiceDate)              AS due_date,
    DATEDIFF(MONTH, InvoiceDate, GETDATE())   AS months_since_invoice
FROM dbo.Invoice;
