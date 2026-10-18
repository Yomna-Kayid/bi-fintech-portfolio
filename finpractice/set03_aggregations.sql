-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 3 (Day 3 topics): aggregate functions, GROUP BY, HAVING
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- ============================================================

USE FinPractice;
GO

-- 1. Count all transactions.
-- Expected: 3000.
SELECT COUNT(*) AS n
FROM dbo.transactions;

-- 2. Total completed purchase amount.
-- Expected: 420529.49.
SELECT SUM(amount) AS total
FROM dbo.transactions
WHERE txn_type = 'Purchase'
  AND status = 'Completed';

-- 3. Average balance of active accounts, rounded for reporting.
-- Without ROUND the result is 15875.3522.
-- Expected: 15875.35.
SELECT ROUND(AVG(balance), 2) AS avg_balance
FROM dbo.accounts
WHERE status = 'Active';

-- 4. Smallest and largest purchase.
-- Expected: min 5.00, max 799.16.
SELECT
    MIN(amount) AS min_amt,
    MAX(amount) AS max_amt
FROM dbo.transactions
WHERE txn_type = 'Purchase';

-- 5. Number of distinct customer cities.
-- Expected: 8.
SELECT COUNT(DISTINCT city) AS n_cities
FROM dbo.customers;

-- 6. Customers per city, largest first. city breaks ties (Giza and Abu Dhabi both have 16).
-- Expected: Dubai, 31.
SELECT
    city,
    COUNT(*) AS n
FROM dbo.customers
GROUP BY city
ORDER BY n DESC, city;

-- 7. Completed transaction volume per channel.
-- WHERE filters rows before grouping.
-- Expected: Mobile, 773360.28.
SELECT
    channel,
    SUM(amount) AS total
FROM dbo.transactions
WHERE status = 'Completed'
GROUP BY channel
ORDER BY total DESC;

-- 8. HAVING: cities with more than 16 customers.
-- HAVING filters groups after aggregation.
-- Expected: 5 rows (Dubai, Doha, Cairo, Riyadh, Jeddah).
SELECT
    city,
    COUNT(*) AS n
FROM dbo.customers
GROUP BY city
HAVING COUNT(*) > 16
ORDER BY n DESC, city;

-- 9. Transaction types with total amount above 500000.
-- Expected: 2 rows (Deposit, Transfer).
SELECT
    txn_type,
    SUM(amount) AS total
FROM dbo.transactions
GROUP BY txn_type
HAVING SUM(amount) > 500000
ORDER BY total DESC;

-- 10. GROUP BY two columns: accounts per type and status combination.
-- Expected: 8 rows; first row Checking / Active, n = 65.
SELECT
    account_type,
    status,
    COUNT(*) AS n
FROM dbo.accounts
GROUP BY account_type, status
ORDER BY n DESC, account_type, status;

-- 11. Average loan interest rate per product, rounded for reporting.
-- Without ROUND the top value is 12.917592.
-- Expected: Personal, 12.92.
SELECT
    product,
    ROUND(AVG(interest_rate), 2) AS avg_rate
FROM dbo.loans
GROUP BY product
ORDER BY avg_rate DESC;
