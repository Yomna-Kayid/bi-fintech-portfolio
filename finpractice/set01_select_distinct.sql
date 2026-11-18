-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 1 (Day 1 topics): SELECT, DISTINCT, aliases,
-- computed columns, string concatenation
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- "-- Expected:" confirms the result after the solution.
-- ============================================================

USE FinPractice;
GO

-- Q1: Distinct customer cities for campaign localization, alphabetical.
-- Validation query below compares the row count with COUNT(DISTINCT city).
SELECT DISTINCT
    city
FROM dbo.customers
ORDER BY city ASC;
-- Expected: 8 rows; last city Riyadh.

SELECT COUNT(DISTINCT city) AS DistinctCityCount
FROM dbo.customers;


-- Q2: Display label per branch in the format "branch_name - city".
-- branch_name and city are NOT NULL, so + is safe here. On a nullable column
-- + returns NULL for the whole label, while CONCAT treats NULL as an empty string.
SELECT
    branch_id,
    branch_name + ' - ' + city AS label
FROM dbo.branches
ORDER BY branch_id;
-- Expected: 8 rows; branch_id 4 Dubai Marina - Dubai; last row Doha West Bay - Doha.


-- Q3: Yearly interest per loan: principal * interest_rate / 100.
-- Decimal arithmetic adds extra decimal places and ROUND keeps the wider scale,
-- so the result is cast to DECIMAL(12,2).
SELECT
    loan_id,
    principal,
    interest_rate,
    CAST(ROUND(principal * interest_rate / 100, 2) AS DECIMAL(12,2)) AS yearly_interest
FROM dbo.loans
ORDER BY loan_id;
-- Expected: 140 rows; first row 1456.72; last row 54.75.

SELECT COUNT(*) AS LoanCount
FROM dbo.loans;


-- Q4: Account type / status combinations in the book.
-- DISTINCT applies to the (account_type, status) pair, not to each column separately.
SELECT DISTINCT
    account_type,
    status
FROM dbo.accounts
ORDER BY account_type, status;
-- Expected: 8 combinations; first row Business / Active.


-- Q5: Distinct merchant categories, alphabetical.
SELECT DISTINCT
    category
FROM dbo.merchants
ORDER BY category ASC;
-- Expected: 9 categories; first Dining; last Utilities.


-- Q6: Upper-case customer names for the KYC mailing.
SELECT
    customer_id,
    UPPER(full_name) AS name_upper,
    city
FROM dbo.customers
ORDER BY customer_id;
-- Expected: 150 rows; customer_id 25 REEM KAMEL; last row city Abu Dhabi.


-- Q7: Monthly principal portion per loan: principal / term_months.
-- term_months has no zeros in this table. On production data,
-- dividing by NULLIF(term_months, 0) avoids a divide-by-zero error.
SELECT
    loan_id,
    CAST(ROUND(principal / term_months, 2) AS DECIMAL(12,2)) AS monthly_principal
FROM dbo.loans
ORDER BY loan_id;
-- Expected: 140 rows; 5th loan 164.38; last row 269.18.


-- Q8: Distinct merchant countries, alphabetical.
SELECT DISTINCT
    country
FROM dbo.merchants
ORDER BY country ASC;
-- Expected: 5 countries; first Egypt; last USA.


-- Q9: One-line account summary in the format "Account <id> (<type>)".
-- CONCAT converts account_id to text implicitly, so no CAST is needed.
SELECT
    CONCAT('Account ', account_id, ' (', account_type, ')') AS summary
FROM dbo.accounts
ORDER BY account_id;
-- Expected: 196 rows; first Account 1001 (Savings); last Account 1196 (Savings).


-- Q10: Branch footprint: distinct country / city pairs.
SELECT DISTINCT
    country,
    city
FROM dbo.branches
ORDER BY country, city;
-- Expected: 8 rows; first city Alexandria; last country UAE.
