-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 6 (Day 6 topics): LEFT JOIN, anti-joins, multi-table joins,
-- FULL OUTER JOIN
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- ============================================================

USE FinPractice;
GO

-- 1. Anti-join: customers with no account.
-- LEFT JOIN keeps every customer; unmatched rows have NULL in the accounts key.
-- Expected: 9 rows.
SELECT
    c.customer_id,
    c.full_name
FROM dbo.customers AS c
LEFT JOIN dbo.accounts AS a
    ON a.customer_id = c.customer_id
WHERE a.account_id IS NULL;

-- 2. Anti-join: customers with no loan.
-- Expected: 49 rows.
SELECT
    c.customer_id,
    c.full_name
FROM dbo.customers AS c
LEFT JOIN dbo.loans AS l
    ON l.customer_id = c.customer_id
WHERE l.loan_id IS NULL;

-- 3. Row count of an unfiltered LEFT JOIN.
-- A customer with two accounts appears twice; a customer with none appears once with NULLs.
-- Expected: 205.
SELECT COUNT(*) AS n
FROM dbo.customers AS c
LEFT JOIN dbo.accounts AS a
    ON a.customer_id = c.customer_id;

-- 4. Three-table join: completed transactions of Doha customers.
-- INNER JOIN is enough: the WHERE filter on customers would turn a LEFT JOIN
-- into an INNER JOIN anyway.
-- Expected: 304.
SELECT COUNT(*) AS n
FROM dbo.transactions AS t
INNER JOIN dbo.accounts AS a
    ON t.account_id = a.account_id
INNER JOIN dbo.customers AS c
    ON a.customer_id = c.customer_id
WHERE c.city = 'Doha'
  AND t.status = 'Completed';

-- 5. Four-table join: completed purchase volume per branch country.
-- Chain: transactions -> accounts -> customers -> branches.
-- Expected: first row Egypt, 141336.77.
SELECT
    b.country,
    SUM(t.amount) AS total
FROM dbo.transactions AS t
INNER JOIN dbo.accounts AS a
    ON t.account_id = a.account_id
INNER JOIN dbo.customers AS c
    ON a.customer_id = c.customer_id
INNER JOIN dbo.branches AS b
    ON c.branch_id = b.branch_id
WHERE t.txn_type = 'Purchase'
  AND t.status = 'Completed'
GROUP BY b.country
ORDER BY total DESC;

-- 6. Anti-join with extra conditions: merchants with no Pending transaction above 600.
-- The conditions on transactions go in ON, not WHERE. In WHERE they would remove the
-- NULL-padded rows and turn the LEFT JOIN into an INNER JOIN.
-- Expected: 18 rows.
SELECT
    m.merchant_id,
    m.merchant_name
FROM dbo.merchants AS m
LEFT JOIN dbo.transactions AS t
    ON t.merchant_id = m.merchant_id
   AND t.status = 'Pending'
   AND t.amount > 600
WHERE t.txn_id IS NULL;

-- 7. Customers per branch, including branches with none.
-- COUNT(c.customer_id) counts matched rows only; COUNT(*) would return 1 for an empty branch.
-- Expected: first row Alexandria Corniche, 13.
SELECT
    b.branch_name,
    COUNT(c.customer_id) AS n
FROM dbo.branches AS b
LEFT JOIN dbo.customers AS c
    ON c.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY n, b.branch_name;

-- 8. FULL OUTER JOIN: customers and loans.
-- Keeps unmatched rows from both sides: 140 loan rows + 49 customers without a loan.
-- No loan lacks a customer (foreign key), so only the customer side has unmatched rows.
-- Expected: 189.
SELECT COUNT(*) AS n
FROM dbo.customers AS c
FULL OUTER JOIN dbo.loans AS l
    ON l.customer_id = c.customer_id;

-- 9. Customers who applied for a loan but hold no loan.
-- DISTINCT is needed because a customer can have several applications.
-- Expected: 43.
SELECT COUNT(DISTINCT la.customer_id) AS n
FROM dbo.loan_applications AS la
LEFT JOIN dbo.loans AS l
    ON l.customer_id = la.customer_id
WHERE l.loan_id IS NULL;

-- 10. Accounts with no Failed transaction.
-- The Failed condition is in ON; in WHERE it would return the wrong set.
-- Expected: 78.
SELECT COUNT(*) AS n
FROM dbo.accounts AS a
LEFT JOIN dbo.transactions AS t
    ON t.account_id = a.account_id
   AND t.status = 'Failed'
WHERE t.txn_id IS NULL;
