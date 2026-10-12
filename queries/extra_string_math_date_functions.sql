-- ============================================================
-- BI Developer Portfolio
-- Extra practice: string functions, UNION, arithmetic, date functions
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- Date functions are revisited formally on Day 13.
-- ============================================================

USE Chinook;
GO

-- ------------------------------------------------------------
-- Part 1: LEFT, RIGHT, UPPER, LOWER, REPLACE, LEN
-- ------------------------------------------------------------

-- 1. Replace characters and measure length.
-- REPLACE case sensitivity follows the collation (default is case-insensitive).
SELECT
    FirstName,
    REPLACE(FirstName, 'a', '*') AS name_masked,
    LEN(FirstName)               AS name_length
FROM dbo.Customer;

-- 2. Slice from both ends and change case.
SELECT
    FirstName,
    LEFT(FirstName, 3)  AS first_3,
    RIGHT(FirstName, 3) AS last_3,
    UPPER(FirstName)    AS name_upper,
    LOWER(FirstName)    AS name_lower
FROM dbo.Customer;

-- 3. LEFT for initials.
SELECT
    CustomerId,
    CONCAT(LEFT(FirstName, 1), LEFT(LastName, 1)) AS initials
FROM dbo.Customer;

-- 4. RIGHT for masking: keep only the last 4 characters of the phone number.
SELECT
    CustomerId,
    Phone,
    CONCAT('****', RIGHT(Phone, 4)) AS phone_masked
FROM dbo.Customer
WHERE Phone IS NOT NULL;

-- 5. Nested REPLACE: strip spaces, dashes and parentheses from phone numbers.
-- Each REPLACE removes one character type, so they are chained.
SELECT
    Phone,
    REPLACE(REPLACE(REPLACE(REPLACE(Phone, ' ', ''), '-', ''), '(', ''), ')', '') AS phone_normalized
FROM dbo.Customer
WHERE Phone IS NOT NULL;

-- ------------------------------------------------------------
-- Part 2: LTRIM, RTRIM, TRIM
-- Chinook values are already clean, so messy input is built with VALUES.
-- ------------------------------------------------------------

-- 6. Remove leading and trailing spaces.
-- LEN ignores trailing spaces, DATALENGTH counts them. Brackets make spaces visible.
SELECT
    CONCAT('[', raw_name, ']')         AS raw_visible,
    LEN(raw_name)                      AS len_chars,
    DATALENGTH(raw_name)               AS len_bytes,
    CONCAT('[', LTRIM(raw_name), ']')  AS left_trimmed,
    CONCAT('[', RTRIM(raw_name), ']')  AS right_trimmed,
    CONCAT('[', TRIM(raw_name), ']')   AS both_trimmed
FROM (VALUES
    ('  Ahmed Ali'),
    ('Sara Hassan   '),
    ('  Omar Khaled  '),
    ('Mona Adel')
) AS t(raw_name);

-- 7. TRIM with specific characters (SQL Server 2017+).
-- Removes the character only from the start and end, not from the middle.
SELECT
    code,
    TRIM('#' FROM code) AS code_clean
FROM (VALUES
    ('##TX-1042##'),
    ('#TX-1043'),
    ('TX-1044##')
) AS t(code);

-- 8. Why trimming matters before comparing or joining values.
-- Expected: leading space -> 'no match'; trailing spaces -> 'match'
-- (SQL Server ignores trailing spaces in = comparisons).
SELECT
    CASE WHEN '  Brazil' = 'Brazil' THEN 'match' ELSE 'no match' END AS leading_space_check,
    CASE WHEN 'Brazil  ' = 'Brazil' THEN 'match' ELSE 'no match' END AS trailing_space_check;

-- ------------------------------------------------------------
-- Part 3: SUBSTRING and CHARINDEX
-- ------------------------------------------------------------

-- 9. SUBSTRING(string, start, length): positions start at 1, not 0.
-- Start 0 uses up one position of the length, so (Phone, 0, 4) returns only 3 characters.
SELECT
    FirstName,
    LEFT(FirstName, 4)      AS first_4,
    RIGHT(FirstName, 4)     AS last_4,
    SUBSTRING(FirstName, 3, 2) AS chars_3_to_4,
    Phone,
    SUBSTRING(Phone, 0, 4)  AS phone_start_0,
    SUBSTRING(Phone, 1, 3)  AS phone_start_1
FROM dbo.Customer;

-- 10. Country code of a phone number.
-- Codes differ in length (+1, +55, +420), so a fixed-length slice is unreliable.
-- Take everything before the first space. Appending ' ' guarantees CHARINDEX finds one;
-- NULL phone numbers stay NULL.
SELECT
    Phone,
    LEFT(Phone, CHARINDEX(' ', Phone + ' ') - 1) AS country_code
FROM dbo.Customer;

-- 11. Email domain: everything after the '@'.
SELECT
    Email,
    SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS email_domain
FROM dbo.Customer;

-- 12. Customers per email domain.
SELECT
    SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS email_domain,
    COUNT(*) AS customers
FROM dbo.Customer
GROUP BY SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email))
ORDER BY customers DESC;

-- ------------------------------------------------------------
-- Part 4: UNION and UNION ALL
-- Rules: same number of columns, compatible data types, column names come from
-- the first query, and ORDER BY goes once at the end.
-- ------------------------------------------------------------

-- 13. UNION: unique first names across customers and employees (duplicates removed).
SELECT FirstName FROM dbo.Customer
UNION
SELECT FirstName FROM dbo.Employee
ORDER BY FirstName;

-- 14. UNION ALL: same lists, duplicates kept.
SELECT FirstName FROM dbo.Customer
UNION ALL
SELECT FirstName FROM dbo.Employee
ORDER BY FirstName;

-- 15. Compare row counts.
-- union_all_rows = customer count + employee count; union_rows is lower
-- because repeated first names are collapsed.
SELECT
    (SELECT COUNT(*) FROM (
        SELECT FirstName FROM dbo.Customer
        UNION ALL
        SELECT FirstName FROM dbo.Employee) AS u) AS union_all_rows,
    (SELECT COUNT(*) FROM (
        SELECT FirstName FROM dbo.Customer
        UNION
        SELECT FirstName FROM dbo.Employee) AS u) AS union_rows;

-- 16. UNION ALL with a source label: one list of all people.
-- UNION removes duplicates by sorting/comparing the whole result (slower).
-- Use UNION ALL when duplicates are impossible or wanted.
SELECT 'Customer' AS person_type, FirstName, LastName, Country
FROM dbo.Customer
UNION ALL
SELECT 'Employee', FirstName, LastName, Country
FROM dbo.Employee
ORDER BY person_type, LastName;

-- ------------------------------------------------------------
-- Part 5: Arithmetic and date functions
-- ------------------------------------------------------------

-- 17. Arithmetic on a numeric column.
SELECT
    Total,
    Total + 10 AS total_plus_10,
    Total * 2  AS total_doubled
FROM dbo.Invoice;

-- 18. Current date and its parts.
-- YEAR(x) is shorthand for DATEPART(YEAR, x).
SELECT
    GETDATE()                 AS system_datetime,
    YEAR(GETDATE())           AS system_year,
    MONTH(GETDATE())          AS system_month,
    DATEPART(YEAR, GETDATE()) AS system_year_datepart;

-- 19. DATEADD: shift a date back one year (year-over-year comparison base).
SELECT
    InvoiceDate,
    DATEADD(YEAR, -1, InvoiceDate) AS same_date_prev_year
FROM dbo.Invoice;

-- 20. DATEADD + DATEDIFF: payment due date and months since the invoice.
-- DATEDIFF counts month boundaries crossed, not full elapsed months:
-- DATEDIFF(MONTH, '2026-01-31', '2026-02-01') returns 1.
SELECT
    InvoiceDate,
    DATEADD(DAY, 3, InvoiceDate)            AS due_date,
    DATEDIFF(MONTH, InvoiceDate, GETDATE()) AS months_since_invoice
FROM dbo.Invoice;
