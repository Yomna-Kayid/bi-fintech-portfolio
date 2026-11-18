-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 3 (Day 3 topics): COUNT, SUM, AVG, MIN, MAX,
-- COUNT(DISTINCT), GROUP BY, HAVING
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- Part 1: Day 3 topics. Part 2: review of Day 2.
-- "-- Expected:" confirms the result after the solution.
-- ============================================================

USE FinPractice;
GO

/* ------------------------------------------------------------
   PART 1 - Aggregations
   ------------------------------------------------------------ */

-- Q1: Completed transactions per channel: volume, total and average amount.
-- Status filter uses the stored case ('Completed'). AVG result is cast to DECIMAL(12,2).
SELECT
    channel,
    COUNT(txn_id) AS txn_count,
    SUM(amount)   AS total_amount,
    CAST(ROUND(AVG(amount), 2) AS DECIMAL(12,2)) AS avg_amount
FROM dbo.transactions
WHERE status = 'Completed'
GROUP BY channel
ORDER BY total_amount DESC;
-- Expected: 4 rows; top channel Mobile; total_amount 773360.28; avg_amount 681.98.


-- Q2: Single-row summary of all completed transactions.
-- COUNT(DISTINCT account_id) counts active accounts, not rows.
SELECT
    COUNT(txn_id)                  AS total_transactions,
    COUNT(DISTINCT account_id)     AS total_accounts,
    MAX(amount)                    AS largest_amount,
    CAST(ROUND(AVG(amount), 2) AS DECIMAL(12,2)) AS avg_amount
FROM dbo.transactions
WHERE status = 'Completed';
-- Expected: 2675 transactions; 196 accounts; largest 4988.60; average 797.82.


-- Q3: Balance totals per account type and status, keeping only groups with more than 10 accounts.
-- HAVING filters on the aggregate; WHERE cannot.
SELECT
    account_type,
    status,
    COUNT(*) AS n_accounts,
    CAST(ROUND(SUM(balance), 2) AS DECIMAL(14,2)) AS total_balance
FROM dbo.accounts
GROUP BY account_type, status
HAVING COUNT(*) > 10
ORDER BY total_balance DESC;
-- Expected: 5 rows; first row Checking / Active; total_balance 973842.14.


-- Q4: Cities with more than 16 customers.
-- Tie-breaker on city keeps the order deterministic.
SELECT
    city,
    COUNT(*) AS n_customers
FROM dbo.customers
GROUP BY city
HAVING COUNT(*) > 16
ORDER BY n_customers DESC, city ASC;
-- Expected: 5 cities; top city Dubai with 31 customers.


-- Q5: Average interest rate per loan product.
-- ROUND on AVG keeps the source scale, so CAST to DECIMAL(5,2) removes trailing zeros.
SELECT
    product,
    CAST(ROUND(AVG(interest_rate), 2) AS DECIMAL(5,2)) AS average_rate
FROM dbo.loans
GROUP BY product
ORDER BY average_rate DESC;
-- Expected: 4 products; top product Personal; average_rate 12.92.


-- Q6: Defaulted loan exposure per product, products with at least 5 defaulted loans only.
-- WHERE filters rows before grouping, HAVING filters groups after.
SELECT
    product,
    COUNT(loan_id) AS n_loans,
    CAST(ROUND(SUM(principal), 2) AS DECIMAL(14,2)) AS total_principal
FROM dbo.loans
WHERE status = 'Defaulted'
GROUP BY product
HAVING COUNT(loan_id) >= 5
ORDER BY total_principal DESC;
-- Expected: 3 rows; top product Auto; total_principal 253235.14.


-- Q7: Failed transactions per transaction type.
-- GROUP BY already returns one row per type, so DISTINCT is not needed.
SELECT
    txn_type,
    COUNT(txn_id) AS failed_txn
FROM dbo.transactions
WHERE status = 'Failed'
GROUP BY txn_type
ORDER BY failed_txn DESC, txn_type ASC;
-- Expected: 5 rows; top type Purchase with 88 failures.


-- Q8: Amount range and merchant coverage for completed purchases.
SELECT
    MIN(amount)                AS smallest_amount,
    MAX(amount)                AS largest_amount,
    COUNT(DISTINCT merchant_id) AS merchant_n
FROM dbo.transactions
WHERE status = 'Completed'
  AND txn_type = 'Purchase';
-- Expected: smallest 5.00; largest 799.16; 30 merchants.


-- Q9: Loan application volume and average requested amount per decision.
SELECT
    decision,
    COUNT(app_id) AS app_n,
    CAST(ROUND(AVG(requested_amount), 2) AS DECIMAL(14,2)) AS avg_req_amount
FROM dbo.loan_applications
GROUP BY decision
ORDER BY decision ASC;
-- Expected: 3 rows; Approved avg 37209.13; Rejected avg 35995.06.


-- Q10: Geographic spread and earliest signup of Premium customers.
-- Aggregates without GROUP BY return a single row.
SELECT
    COUNT(DISTINCT city) AS n_cities,
    MIN(signup_date)     AS earliest_signup
FROM dbo.customers
WHERE segment = 'Premium';
-- Expected: 7 cities; earliest signup 2021-01-20.


/* ------------------------------------------------------------
   PART 2 - Review of Day 2
   ------------------------------------------------------------ */

-- Q11: Accounts with a balance between 5000 and 10000 (bounds included), highest balance first.
SELECT
    account_id,
    balance
FROM dbo.accounts
WHERE balance BETWEEN 5000 AND 10000
ORDER BY balance DESC;
-- Expected: 32 rows; first account_id 1173; last 1124.


-- Q12: Top 7 completed deposits by amount; txn_id breaks ties.
SELECT TOP (7)
    txn_id,
    amount
FROM dbo.transactions
WHERE status = 'Completed'
  AND txn_type = 'Deposit'
ORDER BY amount DESC, txn_id ASC;
-- Expected: 7 rows; first txn_id 51385; 7th amount 4895.63.


-- Q13: Distinct transaction type / channel combinations.
-- DISTINCT applies to the pair, not to each column.
SELECT DISTINCT
    txn_type,
    channel
FROM dbo.transactions
ORDER BY txn_type ASC, channel ASC;
-- Expected: 16 combinations; first channel ATM; last txn_type Withdrawal.


-- Q14: Egypt and Qatar merchants outside the Utilities and Fuel categories.
SELECT merchant_name
FROM dbo.merchants
WHERE country IN ('Egypt', 'Qatar')
  AND category NOT IN ('Utilities', 'Fuel')
ORDER BY merchant_name ASC;
-- Expected: 9 rows; first merchant Cairo Threads.


-- Q15: Accounts paged by opened_date, rows 21 to 40 (page 2 of 20).
-- OFFSET requires ORDER BY. customer_id is not unique per account,
-- so ties on opened_date + customer_id are possible; account_id would be a safer last key.
SELECT
    account_id,
    opened_date
FROM dbo.accounts
ORDER BY opened_date ASC, customer_id
OFFSET 20 ROWS
FETCH NEXT 20 ROWS ONLY;
-- Expected: 20 rows; first account_id 1162; last 1138.
