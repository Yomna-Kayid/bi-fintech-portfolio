-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 4 (Day 4 topics): IS NULL, COUNT(*) vs COUNT(col),
-- COALESCE, ISNULL, NULLIF, CAST, INFORMATION_SCHEMA, DECIMAL precision
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- Practice questions written as stakeholder tickets (requesters are fictional).
-- "-- Expected:" confirms the result after the solution.
-- Part 1: Day 4 topics. Part 2: review of Day 3.
-- ============================================================

USE FinPractice;
GO

/* ------------------------------------------------------------
   PART 1 - NULL handling and data types
   ------------------------------------------------------------ */

-- Q1  (Requester: Marketing)
-- Ask: number of customers with no email on file, and the lowest customer_id among them.
-- Note: NULL is tested with IS NULL; "= NULL" never matches.
SELECT
    COUNT(*)         AS n_no_email,
    MIN(customer_id) AS first_customer_id
FROM dbo.customers
WHERE email IS NULL;
-- Expected: 26 customers; lowest customer_id 9.


-- Q2  (Requester: Data Governance)
-- Ask: percentage of customers with no phone number, 2 decimals.
-- Note: COUNT(*) counts all rows, COUNT(phone) skips NULLs, so the difference is the missing count.
-- 100.0 forces decimal division; 100 would truncate to integer arithmetic.
SELECT
    CAST(ROUND(100.0 * (COUNT(*) - COUNT(phone)) / COUNT(*), 2) AS DECIMAL(5,2)) AS pct_missing_phone
FROM dbo.customers;
-- Expected: 8.67.


-- Q3  (Requester: Customer Support)
-- Ask: one contact value per customer: email, else phone, else the text 'none'.
-- Note: COALESCE returns the first non-NULL argument and accepts any number of arguments.
SELECT
    customer_id,
    COALESCE(email, phone, 'none') AS contact
FROM dbo.customers
ORDER BY customer_id;
-- Expected: 150 rows; customer_id 3 hassan.zaki3@mail.com; last row dina.badr150@mail.com.


-- Q4  (Requester: Risk)
-- Ask: number of accounts open on 2024-06-30 (opened on or before, not closed by then).
-- Note: closed_date > '2024-06-30' alone would drop accounts that were never closed (NULL).
-- ISNULL maps NULL to a far-future date so open accounts pass the comparison.
SELECT
    COUNT(*) AS n
FROM dbo.accounts
WHERE opened_date <= '2024-06-30'
  AND ISNULL(closed_date, '9999-12-31') > '2024-06-30';
-- Expected: 179.


-- Q5  (Requester: Treasury)
-- Ask: average balance of accounts that hold money (zero balances ignored), 2 decimals.
-- Note: NULLIF(balance, 0) turns zeros into NULL and AVG skips NULLs.
-- Check: result is higher than SELECT AVG(balance) FROM accounts (13597.22).
SELECT
    CAST(ROUND(AVG(NULLIF(balance, 0)), 2) AS DECIMAL(12,2)) AS avg_nonzero_balance
FROM dbo.accounts;
-- Expected: 15863.42.


-- Q6  (Requester: Fraud)
-- Ask: transactions with no merchant, and how many transaction types that group covers.
SELECT
    COUNT(*)                 AS n,
    COUNT(DISTINCT txn_type) AS n_types
FROM dbo.transactions
WHERE merchant_id IS NULL;
-- Expected: 1342 transactions; 4 types.


-- Q7  (Requester: Compliance)
-- Ask: customers with neither email nor phone, and the lowest customer_id among them.
-- Note: both conditions use IS NULL joined with AND.
SELECT
    COUNT(*)         AS n_unreachable,
    MIN(customer_id) AS first_customer_id
FROM dbo.customers
WHERE email IS NULL
  AND phone IS NULL;
-- Expected: 4 customers; lowest customer_id 27.


-- Q8  (Requester: Collections)
-- Ask: loan applications still waiting for a decision date, and their total requested amount.
SELECT
    COUNT(app_id) AS n,
    CAST(ROUND(SUM(requested_amount), 2) AS DECIMAL(14,2)) AS total_requested
FROM dbo.loan_applications
WHERE decision_date IS NULL;
-- Expected: 35 applications; total requested 1567760.56.


-- Q9  (Requester: Audit)
-- Ask: data type and numeric precision of transactions.amount, and the declared
-- maximum length of customers.full_name, read from the catalog.
-- Note: INFORMATION_SCHEMA.COLUMNS exposes DATA_TYPE, NUMERIC_PRECISION and
-- CHARACTER_MAXIMUM_LENGTH. Money columns are DECIMAL, not FLOAT, to avoid rounding drift.
SELECT
    (SELECT DATA_TYPE
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = 'transactions' AND COLUMN_NAME = 'amount')            AS data_type,
    (SELECT NUMERIC_PRECISION
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = 'transactions' AND COLUMN_NAME = 'amount')            AS numeric_precision,
    (SELECT CHARACTER_MAXIMUM_LENGTH
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = 'customers' AND COLUMN_NAME = 'full_name')            AS max_len;
-- Expected: decimal; precision 12; max length 60.


-- Q10  (Requester: Finance)
-- Ask: sum of completed Purchase amounts after dropping the cents from each amount.
-- Note: CAST from DECIMAL to INT truncates, it does not round. Each value is converted
-- before SUM, which differs from CAST(SUM(amount) AS INT).
SELECT
    SUM(CAST(amount AS INT)) AS whole_units
FROM dbo.transactions
WHERE txn_type = 'Purchase'
  AND status = 'Completed';
-- Expected: 419787.


/* ------------------------------------------------------------
   PART 2 - Review of Day 3
   ------------------------------------------------------------ */

-- Q11  (Requester: Regional Sales Lead)
-- Ask: scorecard of Active accounts per account type: count, total and average balance,
-- highest total first.
-- Note: GROUP BY already returns one row per type, so DISTINCT is not needed.
-- Check: SUM(total_balance) equals SELECT SUM(balance) FROM accounts WHERE status = 'Active'.
SELECT
    account_type,
    COUNT(*) AS n_accounts,
    CAST(ROUND(SUM(balance), 2) AS DECIMAL(14,2)) AS total_balance,
    CAST(ROUND(AVG(balance), 2) AS DECIMAL(12,2)) AS avg_balance
FROM dbo.accounts
WHERE status = 'Active'
GROUP BY account_type
ORDER BY total_balance DESC;
-- Expected: 3 rows; top type Checking; total_balance 973842.14; avg_balance 14982.19.


-- Q12  (Requester: Operations)
-- Ask: channels with more than 500 completed transactions, biggest first.
-- Note: tie-breaker on channel keeps the order deterministic.
SELECT
    channel,
    COUNT(txn_id) AS n
FROM dbo.transactions
WHERE status = 'Completed'
GROUP BY channel
HAVING COUNT(txn_id) > 500
ORDER BY n DESC, channel ASC;
-- Expected: 2 rows; top channel Mobile with 1134 transactions.


-- Q13  (Requester: Collections)
-- Ask: Defaulted or Active loans with a term of 24 to 48 months (inclusive) and
-- principal above 10000, largest principal first, ties by loan_id.
SELECT
    loan_id,
    principal,
    term_months,
    status
FROM dbo.loans
WHERE status IN ('Defaulted', 'Active')
  AND term_months BETWEEN 24 AND 48
  AND principal > 10000
ORDER BY principal DESC, loan_id ASC;
-- Expected: 37 rows; first loan_id 7090; last 7021.


-- Q14  (Requester: Finance)
-- Ask: net amount after a 1.5% fee (amount * 0.985, 2 decimals) for completed transactions above 1000.
SELECT
    txn_id,
    CAST(ROUND(amount * 0.985, 2) AS DECIMAL(12,2)) AS net_amount
FROM dbo.transactions
WHERE status = 'Completed'
  AND amount > 1000
ORDER BY txn_id;
-- Expected: 626 rows; first net_amount 1053.92; last 1029.98.


-- Q15  (Requester: Head of Lending)
-- Ask: one-row lending summary: loans, distinct borrowers, largest principal, average interest rate.
-- Note: COUNT(DISTINCT customer_id) counts borrowers, not loans.
SELECT
    COUNT(loan_id)                 AS loans,
    COUNT(DISTINCT customer_id)    AS borrowers,
    MAX(principal)                 AS largest_principal,
    CAST(ROUND(AVG(interest_rate), 2) AS DECIMAL(5,2)) AS avg_rate
FROM dbo.loans;
-- Expected: 140 loans; 101 borrowers; largest principal 365440.70; average rate 9.54.
