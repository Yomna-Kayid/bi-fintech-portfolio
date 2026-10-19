-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 4 (Day 4 topics): NULL handling, COALESCE, ISNULL, NULLIF,
-- CAST / TRY_CAST, data types
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- ============================================================

USE FinPractice;
GO

-- 1. Customers without an email.
-- "= NULL" never matches (comparison with NULL is UNKNOWN); IS NULL is required.
-- Expected: 26 rows.
SELECT *
FROM dbo.customers
WHERE email IS NULL;

-- 2. Customers with a phone number.
-- Expected: 137 rows.
SELECT *
FROM dbo.customers
WHERE phone IS NOT NULL;

-- 3. Missing emails as COUNT(*) minus COUNT(email).
-- COUNT(column) skips NULLs; COUNT(*) counts every row.
-- Expected: 26.
SELECT COUNT(*) - COUNT(email) AS missing_email
FROM dbo.customers;

-- 4. Distinct phone values with NULL mapped to a placeholder.
-- All NULLs collapse into one 'none' value: 137 distinct numbers + 'none'.
-- Expected: 138.
SELECT COUNT(DISTINCT COALESCE(phone, 'none')) AS n
FROM dbo.customers;

-- 5. Transactions without a merchant (deposits, transfers, fees and similar).
-- Expected: 1342.
SELECT COUNT(*) AS n
FROM dbo.transactions
WHERE merchant_id IS NULL;

-- 6. Accounts still open, or closed after 2024-06-30.
-- ISNULL replaces a missing closed_date with a far-future date so open accounts
-- pass the filter. The result takes the type of the first argument (DATE).
-- Expected: 179 rows (168 open + 11 closed after the cutoff).
SELECT *
FROM dbo.accounts
WHERE ISNULL(closed_date, '2099-12-31') > '2024-06-30';

-- 7. Average balance excluding zero balances.
-- NULLIF(balance, 0) returns NULL for zeros, and AVG skips NULLs.
-- A plain AVG(balance) is 13597.22 because 28 accounts have a zero balance.
-- Expected: 15863.42.
SELECT ROUND(AVG(NULLIF(balance, 0)), 2) AS avg_nonzero
FROM dbo.accounts;

-- 8. CAST from DECIMAL to INT truncates the decimals.
-- The true purchase total is 471234.46, so about 825 is lost over 3000 rows.
-- Expected: 470409.
SELECT SUM(CAST(amount AS INT)) AS total_int
FROM dbo.transactions
WHERE txn_type = 'Purchase';

-- 9. TRY_CAST returns NULL when conversion fails.
-- CAST('12A' AS INT) would stop with a conversion error instead.
-- Expected: NULL.
SELECT TRY_CAST('12A' AS INT) AS result;

-- 10. Data type of transactions.amount.
-- Money is stored as DECIMAL, not FLOAT, to avoid rounding errors.
-- Expected: decimal.
SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'transactions'
  AND COLUMN_NAME = 'amount';

-- 11. Precision and scale of transactions.amount.
-- DECIMAL(12,2): up to 12 digits in total, 2 after the decimal point.
-- Expected: NUMERIC_PRECISION = 12, NUMERIC_SCALE = 2.
SELECT NUMERIC_PRECISION, NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'transactions'
  AND COLUMN_NAME = 'amount';
