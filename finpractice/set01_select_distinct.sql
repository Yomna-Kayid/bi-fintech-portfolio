-- ============================================================
-- BI Developer Portfolio
-- FinPractice: Set 1 (Day 1 topics)
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL), created by finpractice/FinPractice.sql
-- Tables: branches, customers, accounts, merchants, transactions, loans, loan_applications
-- All data is randomly generated; no real customer data.
-- ============================================================

USE FinPractice;
GO

-- ------------------------------------------------------------
-- Set 1 (Day 1 topics): SELECT, DISTINCT, aliases, computed columns
-- ------------------------------------------------------------

-- 1. All columns and all rows of branches.
-- Expected: 8 rows.
SELECT *
FROM dbo.branches;

-- 2. Only the columns needed from customers.
-- Expected: 150 rows.
SELECT customer_id, full_name, city
FROM dbo.customers;

-- 3. Distinct cities with customers.
-- Expected: 8 rows.
SELECT DISTINCT city
FROM dbo.customers;

-- 4. Distinct combinations of account type and status.
-- DISTINCT applies to the column pair, not to each column separately.
-- Expected: 8 rows (3 types x 3 statuses, minus Business/Frozen, which does not occur).
SELECT DISTINCT account_type, status
FROM dbo.accounts;

-- 5. Distinct merchant categories.
-- Expected: 9 rows.
SELECT DISTINCT category
FROM dbo.merchants;

-- 6. Merchant name converted to upper case with UPPER.
-- Expected for merchant_id = 7: CIRCUIT POINT.
SELECT
    merchant_id,
    merchant_name,
    UPPER(merchant_name) AS shop_upper
FROM dbo.merchants;

-- 7. Branch label built from name and city.
-- CONCAT treats NULL as an empty string; the + operator returns NULL if any part is NULL.
-- Equivalent with +: branch_name + ' - ' + city
-- Expected for branch_id = 4: Dubai Marina - Dubai.
SELECT
    branch_id,
    CONCAT(branch_name, ' - ', city) AS label
FROM dbo.branches;

-- 8. Distinct merchant countries.
-- Expected: 5 rows.
SELECT DISTINCT country
FROM dbo.merchants;

-- 9. Computed column: yearly interest amount per loan.
-- DECIMAL arithmetic keeps extra decimal places (1456.72354100 for loan 7001);
-- wrap in ROUND(..., 2) for reporting (1456.72).
-- Expected for loan_id = 7001: 1456.72354100.
SELECT
    loan_id,
    principal,
    interest_rate,
    principal * interest_rate / 100 AS yearly_interest
FROM dbo.loans;

-- 10. Distinct account types.
-- Expected: 3 rows (Savings, Checking, Business).
SELECT DISTINCT account_type
FROM dbo.accounts;
