-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 2 (Day 2 topics): WHERE, AND/OR, IN, BETWEEN, LIKE,
-- TOP, OFFSET-FETCH, <>
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- Note: SELECT * is used for exploration; reporting queries should name columns.
-- ============================================================

USE FinPractice;
GO

-- 1. Customers in Cairo.
-- Expected: 19 rows.
SELECT *
FROM dbo.customers
WHERE city = 'Cairo';

-- 2. Transactions above 2000.
-- Expected: 386 rows.
SELECT *
FROM dbo.transactions
WHERE amount > 2000;

-- 3. AND: active savings accounts (both conditions must hold).
-- Expected: 59 rows.
SELECT *
FROM dbo.accounts
WHERE status = 'Active'
  AND account_type = 'Savings';

-- 4. OR: customers in the Premium or Student segment.
-- Expected: 48 rows.
SELECT *
FROM dbo.customers
WHERE segment = 'Premium'
   OR segment = 'Student';

-- 4b. Same result with IN, shorter when there are several values.
SELECT *
FROM dbo.customers
WHERE segment IN ('Premium', 'Student');

-- 5. IN: customers in Dubai, Riyadh or Doha.
-- Expected: 69 rows.
SELECT *
FROM dbo.customers
WHERE city IN ('Dubai', 'Riyadh', 'Doha');

-- 6. BETWEEN: transactions from 100 to 200.
-- BETWEEN includes both bounds; avoid it on date/time columns for that reason.
-- Expected: 298 rows.
SELECT *
FROM dbo.transactions
WHERE amount BETWEEN 100 AND 200;

-- 7. LIKE prefix: names starting with 'A'.
-- Expected: 15 rows.
SELECT *
FROM dbo.customers
WHERE full_name LIKE 'A%';

-- 8. LIKE suffix: names ending with 'Hassan'.
-- Expected: 7 rows.
SELECT *
FROM dbo.customers
WHERE full_name LIKE '%Hassan';

-- 9. TOP: five highest transactions.
-- txn_id as tiebreaker keeps the ranking deterministic when amounts tie.
-- Expected: first row txn_id = 51385; fifth row amount = 4925.18.
SELECT TOP 5 txn_id, amount
FROM dbo.transactions
ORDER BY amount DESC, txn_id ASC;

-- 10. OFFSET-FETCH: skip the first 10 customers by signup date, return the next 5.
-- OFFSET requires ORDER BY. customer_id breaks ties between equal signup dates.
-- Expected: first row customer_id = 25.
SELECT customer_id, signup_date
FROM dbo.customers
ORDER BY signup_date ASC, customer_id
OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY;

-- 11. <>: accounts that are not Active (Closed or Frozen).
-- status has no NULLs in this table; with NULLs, <> would drop them.
-- Expected: 49 rows.
SELECT *
FROM dbo.accounts
WHERE status <> 'Active';
