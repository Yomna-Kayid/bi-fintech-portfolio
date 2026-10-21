-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 5 (Day 5 topics): INNER JOIN, table aliases,
-- joins with filtering, aggregation and sorting
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- Join keys: accounts.customer_id -> customers.customer_id,
--            transactions.merchant_id -> merchants.merchant_id,
--            customers.branch_id -> branches.branch_id,
--            loans / loan_applications.customer_id -> customers.customer_id
-- ============================================================

USE FinPractice;
GO

-- 1. Accounts with the customer name.
-- Expected: 196 rows (every account has a customer).
SELECT
    a.account_id,
    c.full_name
FROM dbo.accounts AS a
INNER JOIN dbo.customers AS c
    ON a.customer_id = c.customer_id;

-- 2. Transactions with their merchant.
-- Transactions with a NULL merchant_id (deposits, transfers, fees) are dropped,
-- because NULL never matches a key: 3000 - 1342 = 1658.
-- Expected: 1658 rows.
SELECT
    t.txn_id,
    t.amount,
    m.merchant_name
FROM dbo.transactions AS t
INNER JOIN dbo.merchants AS m
    ON t.merchant_id = m.merchant_id;

-- 3. Branch of customer 1.
-- Expected: Giza Plaza.
SELECT
    c.customer_id,
    b.branch_name
FROM dbo.customers AS c
INNER JOIN dbo.branches AS b
    ON c.branch_id = b.branch_id
WHERE c.customer_id = 1;

-- 4. Accounts of customers living in Dubai.
-- Expected: 36 rows.
SELECT
    a.account_id,
    a.account_type,
    a.balance,
    c.full_name
FROM dbo.accounts AS a
INNER JOIN dbo.customers AS c
    ON a.customer_id = c.customer_id
WHERE c.city = 'Dubai';

-- 5. Loans held by Premium customers.
-- Expected: 29.
SELECT COUNT(*) AS n
FROM dbo.loans AS l
INNER JOIN dbo.customers AS c
    ON l.customer_id = c.customer_id
WHERE c.segment = 'Premium';

-- 6. Completed transactions at Travel merchants.
-- Filter values match the stored case ('Completed', 'Travel').
-- Expected: 132.
SELECT COUNT(*) AS n
FROM dbo.transactions AS t
INNER JOIN dbo.merchants AS m
    ON t.merchant_id = m.merchant_id
WHERE t.status = 'Completed'
  AND m.category = 'Travel';

-- 7. Completed spend per merchant category, highest first.
-- GROUP BY already returns one row per category, so DISTINCT is not needed.
-- Expected: Groceries, 63315.99.
SELECT
    m.category,
    SUM(t.amount) AS total
FROM dbo.transactions AS t
INNER JOIN dbo.merchants AS m
    ON t.merchant_id = m.merchant_id
WHERE t.status = 'Completed'
GROUP BY m.category
ORDER BY total DESC;

-- 8. Account balances with owner name, highest first.
-- Columns are prefixed with the table alias; account_id breaks ties.
-- Expected: first row Ali Rashid, 59870.75.
SELECT
    c.full_name,
    a.balance
FROM dbo.accounts AS a
INNER JOIN dbo.customers AS c
    ON a.customer_id = c.customer_id
ORDER BY a.balance DESC, a.account_id;

-- 9. Approved loan applications from Cairo customers.
-- Expected: 16.
SELECT COUNT(*) AS n
FROM dbo.loan_applications AS la
INNER JOIN dbo.customers AS c
    ON la.customer_id = c.customer_id
WHERE la.decision = 'Approved'
  AND c.city = 'Cairo';

-- 10. Distinct customers with at least one loan.
-- After the join a customer repeats once per loan, so COUNT(DISTINCT) is required.
-- Expected: 101.
SELECT COUNT(DISTINCT c.customer_id) AS n
FROM dbo.customers AS c
INNER JOIN dbo.loans AS l
    ON c.customer_id = l.customer_id;

-- 11. Frozen accounts per customer city.
-- Expected: first row Riyadh, 5.
SELECT
    c.city,
    COUNT(*) AS n
FROM dbo.accounts AS a
INNER JOIN dbo.customers AS c
    ON a.customer_id = c.customer_id
WHERE a.status = 'Frozen'
GROUP BY c.city
ORDER BY n DESC, c.city;
