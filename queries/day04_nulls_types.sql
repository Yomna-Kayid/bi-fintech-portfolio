-- ============================================================
-- BI Developer Portfolio
-- Day 4: Data types and NULL handling
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- ============================================================

USE Chinook;
GO

-- ------------------------------------------------------------
-- Setup: practice table
-- Money columns use DECIMAL(18,2), not FLOAT (see query 1).
-- amount_text holds amounts as text to practice TRY_CAST.
-- ------------------------------------------------------------
DROP TABLE IF EXISTS dbo.practice_loans;
GO

CREATE TABLE dbo.practice_loans (
    loan_id        INT           NOT NULL PRIMARY KEY,
    customer_name  VARCHAR(50)   NOT NULL,
    loan_amount    DECIMAL(18,2) NULL,
    interest_rate  DECIMAL(5,2)  NULL,
    term_months    INT           NULL,
    status         VARCHAR(20)   NULL,
    approved_date  DATE          NULL,
    amount_text    VARCHAR(20)   NULL
);
GO

INSERT INTO dbo.practice_loans
    (loan_id, customer_name, loan_amount, interest_rate, term_months, status, approved_date, amount_text)
VALUES
    (1,  'Ahmed Ali',      15000.00, 12.50, 12,   'Approved', '2026-01-10', '15000.00'),
    (2,  'Sara Hassan',     8000.50, NULL,  24,   'Approved', '2026-01-15', '8000.50'),
    (3,  'Omar Khaled',     NULL,    10.00, NULL, 'Pending',  NULL,         'N/A'),
    (4,  'Mona Adel',      22000.00,  9.75, 36,   'Rejected', NULL,         '22000'),
    (5,  'Youssef Samir',   5000.00, 11.00, 0,    NULL,       '2026-02-01', '5000.00'),
    (6,  'Laila Nabil',     NULL,    NULL,  12,   'Pending',  NULL,         ''),
    (7,  'Karim Fathy',    12500.75, 13.25, 24,   'Approved', '2026-02-10', '12,500.75'),
    (8,  'Hana Mostafa',   30000.00,  8.50, 60,   'Approved', '2026-02-20', '30000.00'),
    (9,  'Tarek Salem',     NULL,    NULL,  NULL, NULL,       NULL,         NULL),
    (10, 'Dina Fouad',      9500.00, 12.00, 12,   'Rejected', NULL,         '9500.00');
GO

-- 1. DECIMAL vs FLOAT: FLOAT is approximate, so exact equality can fail.
-- Expected: float -> 'not equal', decimal -> 'equal'.
SELECT
    CASE WHEN CAST(0.1 AS FLOAT) + CAST(0.2 AS FLOAT) = CAST(0.3 AS FLOAT)
         THEN 'equal' ELSE 'not equal' END AS float_check,
    CASE WHEN CAST(0.1 AS DECIMAL(18,2)) + CAST(0.2 AS DECIMAL(18,2)) = CAST(0.3 AS DECIMAL(18,2))
         THEN 'equal' ELSE 'not equal' END AS decimal_check;

-- 2. NULL is not a value: "= NULL" never matches, use IS NULL.
-- Expected: first query returns 0 rows, second returns the NULL-amount loans.
SELECT * FROM dbo.practice_loans WHERE loan_amount = NULL;
SELECT * FROM dbo.practice_loans WHERE loan_amount IS NULL;

-- 3. COALESCE: first non-NULL value in a list (ANSI standard, any number of arguments).
SELECT
    loan_id,
    loan_amount,
    COALESCE(loan_amount, 0)           AS loan_amount_or_zero,
    COALESCE(status, 'Unknown')        AS status_clean,
    COALESCE(approved_date, '1900-01-01') AS approved_date_or_default
FROM dbo.practice_loans;

-- 4. ISNULL: T-SQL version, exactly two arguments.
-- The result takes the data type of the first argument; COALESCE follows type precedence.
SELECT
    loan_id,
    ISNULL(interest_rate, 0) AS interest_rate_or_zero,
    ISNULL(status, 'Unknown') AS status_clean
FROM dbo.practice_loans;

-- 5. NULLIF: returns NULL when both values are equal.
-- Use 1: turn empty text into NULL. Use 2: avoid divide-by-zero (x / NULLIF(y, 0)).
SELECT
    loan_id,
    amount_text,
    NULLIF(amount_text, '') AS amount_text_clean,
    loan_amount,
    term_months,
    loan_amount / NULLIF(term_months, 0) AS monthly_installment
FROM dbo.practice_loans;

-- 6. TRY_CAST: returns NULL instead of an error when conversion fails.
-- CAST on the same column would stop the whole query at 'N/A'.
-- Rows 3 ('N/A'), 6 ('') and 7 ('12,500.75') are not valid DECIMAL input and should come back NULL.
SELECT
    loan_id,
    amount_text,
    TRY_CAST(amount_text AS DECIMAL(18,2)) AS amount_converted
FROM dbo.practice_loans;

-- 7. Combined: clean text amount, convert safely, replace NULL with 0.
SELECT
    loan_id,
    amount_text,
    COALESCE(TRY_CAST(NULLIF(amount_text, '') AS DECIMAL(18,2)), 0) AS amount_clean
FROM dbo.practice_loans;

-- 8. Aggregates ignore NULL: count and average change depending on how NULL is treated.
-- COUNT(*) counts rows; COUNT(loan_amount) skips NULLs.
-- AVG(loan_amount) skips NULLs; AVG(COALESCE(...)) treats them as 0 and lowers the average.
SELECT
    COUNT(*)                          AS total_rows,
    COUNT(loan_amount)                AS rows_with_amount,
    AVG(loan_amount)                  AS avg_ignoring_nulls,
    AVG(COALESCE(loan_amount, 0))     AS avg_nulls_as_zero
FROM dbo.practice_loans;
