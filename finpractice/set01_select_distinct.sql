-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 1 (Day 1 topics): SELECT, DISTINCT, aliases,
-- computed columns, string concatenation
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- Practice questions written as stakeholder tickets (requesters are fictional).
-- "-- Check:" validates the number; "-- Expected:" confirms it after the solution.
-- ============================================================

USE FinPractice;
GO

-- Q1  (Requester: Marketing)
-- We are localizing our email campaigns. Which cities do our customers
-- live in? One row per city, alphabetical, no repeats.
-- Check: does the row count match SELECT COUNT(DISTINCT city) FROM customers?

-- My solution:
SELECT DISTINCT city
FROM dbo.customers
ORDER BY city ASC;

-- Expected: 8 rows; last city alphabetically: Riyadh.

-- Check:
SELECT COUNT(DISTINCT city) AS DistinctCityCount
FROM dbo.customers;


-- Q2  (Requester: Product Analytics)
-- For the branch locator we need a display label per branch: the branch
-- name, then ' - ' (a dash with a space on each side), then the city,
-- e.g. Cairo Downtown - Cairo. Return branch_id and the label (call it
-- label), ordered by branch_id.

-- My solution:
-- branch_name and city are NOT NULL, so + is safe here; with a nullable column
-- the + operator would return NULL for the whole label, while CONCAT would not.
SELECT
    branch_id,
    branch_name + ' - ' + city AS label
FROM dbo.branches
ORDER BY branch_id;

-- Expected: 8 rows; branch_id 4: Dubai Marina - Dubai; last row: Doha West Bay - Doha.


-- Q3  (Requester: Finance)
-- Treasury wants the yearly interest per loan: principal x interest_rate / 100,
-- rounded to 2 decimals and called yearly_interest. Return loan_id, principal,
-- interest_rate and yearly_interest, ordered by loan_id.
-- Check: does the row count match SELECT COUNT(*) FROM loans?

-- My solution:
-- DECIMAL arithmetic keeps extra decimal places and ROUND keeps the original scale,
-- so CAST to DECIMAL(12,2) gives a clean two-decimal value.
SELECT
    loan_id,
    principal,
    interest_rate,
    CAST(ROUND(principal * interest_rate / 100, 2) AS DECIMAL(12,2)) AS yearly_interest
FROM dbo.loans
ORDER BY loan_id;

-- Expected: 140 rows; first row 1456.72; last row 54.75.

-- Check:
SELECT COUNT(*) AS LoanCount
FROM dbo.loans;


-- Q4  (Requester: Risk)
-- Which combinations of account type and account status exist in our book?
-- One row per combination, ordered by type and then status.

-- My solution:
-- DISTINCT applies to the (account_type, status) pair, not to each column separately.
SELECT DISTINCT
    account_type,
    status
FROM dbo.accounts
ORDER BY account_type, status;

-- Expected: 8 combinations; first row: Business / Active.


-- Q5  (Requester: Merchant Operations)
-- List the merchant categories we work with: one row per category,
-- alphabetical, no repeats.

-- My solution:
SELECT DISTINCT category
FROM dbo.merchants
ORDER BY category ASC;

-- Expected: 9 categories; first: Dining; last: Utilities.


-- Q6  (Requester: Compliance)
-- For the KYC mailing we need each customer's name in capital letters under
-- the column name name_upper. Return customer_id, name_upper and city,
-- ordered by customer_id.

-- My solution:
SELECT
    customer_id,
    UPPER(full_name) AS name_upper,
    city
FROM dbo.customers
ORDER BY customer_id;

-- Expected: 150 rows; customer_id 25: REEM KAMEL; last row city: Abu Dhabi.


-- Q7  (Requester: Treasury)
-- Planning needs the monthly principal portion of every loan: principal divided
-- by term_months, rounded to 2 decimals, named monthly_principal. Return loan_id
-- and monthly_principal, ordered by loan_id.

-- My solution:
-- term_months has no zeros in this table. In production data, dividing by
-- NULLIF(term_months, 0) would protect against a divide-by-zero error.
SELECT
    loan_id,
    CAST(ROUND(principal / term_months, 2) AS DECIMAL(12,2)) AS monthly_principal
FROM dbo.loans
ORDER BY loan_id;

-- Expected: 140 rows; 5th loan: 164.38; last row: 269.18.


-- Q8  (Requester: Partnerships)
-- In which countries are our merchants located? One row per country,
-- alphabetical, no repeats.

-- My solution:
SELECT DISTINCT country
FROM dbo.merchants
ORDER BY country ASC;

-- Expected: 5 countries; first: Egypt; last: USA.


-- Q9  (Requester: Customer Support)
-- Support agents want a one-line summary per account like Account 1001
-- (Checking): the word Account, a space, the account id, a space, then the
-- account type in brackets. Name it summary and order by account_id.

-- My solution:
SELECT
    CONCAT('Account ', account_id, ' (', account_type, ')') AS summary
FROM dbo.accounts
ORDER BY account_id;

-- Expected: 196 rows; first: Account 1001 (Savings); last: Account 1196 (Savings).


-- Q10  (Requester: Branch Network)
-- Give me the branch footprint: one row per country and city where we have a
-- branch, ordered by country and then city.

-- My solution:
SELECT DISTINCT
    country,
    city
FROM dbo.branches
ORDER BY country, city;

-- Expected: 8 rows; first city: Alexandria; last country: UAE.
