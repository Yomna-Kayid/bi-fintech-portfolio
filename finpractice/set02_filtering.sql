-- ============================================================
-- BI Developer Portfolio
-- FinPractice Set 2 (Day 2 topics): WHERE, AND/OR, IN, BETWEEN, LIKE,
-- ORDER BY with tie-breakers, TOP, OFFSET-FETCH
-- Author: Yomna
-- Database: FinPractice (SQL Server / T-SQL)
-- Practice questions written as stakeholder tickets (requesters are fictional).
-- "-- Expected:" confirms the result after the solution.
-- Part 1: Day 2 topics. Part 2: review of Day 1.
-- ============================================================

USE FinPractice;
GO

/* ------------------------------------------------------------
   PART 1 - Filtering, sorting and paging
   ------------------------------------------------------------ */

-- Q1  (Requester: Customer Support)
-- A regional campaign targets customers who live in Cairo or Giza.
-- List them ordered by customer_id (lowest first).

-- My solution:
SELECT customer_id
FROM dbo.customers
WHERE city IN ('Cairo', 'Giza')
ORDER BY customer_id ASC;

-- Expected: 35 rows; first customer_id 1; last 141.


-- Q2  (Requester: Finance)
-- For an audit sample I need mid-sized transactions (amount from 100 to 200,
-- both ends included) that did not fail. Highest amount first. The list must
-- come out in the same order every time, even when amounts tie.

-- My solution:
-- BETWEEN includes both bounds. Four amounts repeat in this range, so txn_id
-- is added as a tie-breaker to make the order deterministic.
SELECT txn_id
FROM dbo.transactions
WHERE amount BETWEEN 100 AND 200
  AND status <> 'Failed'
ORDER BY amount DESC, txn_id ASC;

-- Expected: 277 rows; first txn_id 50705; last 50408.


-- Q3  (Requester: Fraud)
-- Show me the 5 largest completed transactions (by amount). If two amounts tie,
-- the smaller txn_id comes first. Return txn_id and amount.

-- My solution:
SELECT TOP (5)
    txn_id,
    amount
FROM dbo.transactions
WHERE status = 'Completed'
ORDER BY amount DESC, txn_id ASC;

-- Expected: 5 rows; first txn_id 51385; last amount 4925.18.


-- Q4  (Requester: Marketing)
-- We want to greet customers whose full name starts with the letter A.
-- How many are there, and what is the first one by customer_id?

-- My solution:
-- Without ORDER BY the "first" row is not guaranteed, so customer_id is sorted explicitly.
SELECT
    customer_id,
    full_name
FROM dbo.customers
WHERE full_name LIKE 'A%'
ORDER BY customer_id;

-- Expected: 15 rows; first customer_id 21.


-- Q5  (Requester: Compliance)
-- The customer review screen shows 15 customers per page, ordered by
-- signup_date (oldest first) and then customer_id. Return page 3 (rows 31 to 45)
-- with customer_id and signup_date.

-- My solution:
-- Page 3 skips (3 - 1) x 15 = 30 rows. OFFSET requires ORDER BY.
SELECT
    customer_id,
    signup_date
FROM dbo.customers
ORDER BY signup_date ASC, customer_id
OFFSET 30 ROWS
FETCH NEXT 15 ROWS ONLY;

-- Expected: 15 rows; first customer_id 77; last 83.


-- Q6  (Requester: Risk)
-- List accounts that are not Active and are of type Savings or Business.
-- Order by account_id.

-- My solution:
-- Parentheses matter: AND binds tighter than OR, so the type conditions need their own group.
SELECT account_id
FROM dbo.accounts
WHERE status <> 'Active'
  AND (account_type = 'Savings' OR account_type = 'Business')
ORDER BY account_id;

-- Expected: 21 rows; first account_id 1008; last 1189.


-- Q7  (Requester: Operations)
-- Digital channels review: completed Purchase or Transfer transactions made on
-- Mobile or Web with an amount above 2000. Highest amount first, ties by txn_id.

-- My solution:
-- Filter values match the stored case ('Web', not 'web').
SELECT txn_id
FROM dbo.transactions
WHERE status = 'Completed'
  AND txn_type IN ('Purchase', 'Transfer')
  AND channel IN ('Mobile', 'Web')
  AND amount > 2000
ORDER BY amount DESC, txn_id;

-- Expected: 89 rows; first txn_id 52401; last 51431.


-- Q8  (Requester: Treasury)
-- Which merchants operate in the UAE or KSA and are not in the Fuel category?
-- Alphabetical by merchant name.

-- My solution:
SELECT
    merchant_id,
    merchant_name
FROM dbo.merchants
WHERE country IN ('UAE', 'KSA')
  AND category <> 'Fuel'
ORDER BY merchant_name ASC;

-- Expected: 13 rows; first Al Shifa Pharmacy; last WellLife Clinic.


-- Q9  (Requester: Collections)
-- Loans that were issued with a term of 12 or 24 months, an interest rate between
-- 8 and 12 (both included) and are not yet Paid. Largest principal first, ties by loan_id.

-- My solution:
SELECT loan_id
FROM dbo.loans
WHERE term_months IN (12, 24)
  AND interest_rate BETWEEN 8 AND 12
  AND status <> 'Paid'
ORDER BY principal DESC, loan_id;

-- Expected: 11 rows; first loan_id 7129; last 7066.


-- Q10  (Requester: Customer Support)
-- Find customers whose full name ends with Hassan or Mansour and who do not live
-- in Cairo. Order by customer_id.

-- My solution:
-- Parentheses keep the OR on the names from swallowing the city condition.
SELECT customer_id
FROM dbo.customers
WHERE (full_name LIKE '%Hassan' OR full_name LIKE '%Mansour')
  AND city <> 'Cairo'
ORDER BY customer_id;

-- Expected: 12 rows; first customer_id 2; last 127.


/* ------------------------------------------------------------
   PART 2 - Review of Day 1
   ------------------------------------------------------------ */

-- Q11  (Requester: Branch Network)
-- Our field team plans visits by city. Which cities have a branch?
-- One row per city, alphabetical, no repeats.

-- My solution:
SELECT DISTINCT city
FROM dbo.branches
ORDER BY city ASC;

-- Expected: 8 cities; last alphabetically: Riyadh.


-- Q12  (Requester: Treasury)
-- Treasury also wants the monthly interest per loan: principal x interest_rate / 1200,
-- rounded to 2 decimals as monthly_interest. Return loan_id and monthly_interest,
-- ordered by loan_id.

-- My solution:
-- interest_rate is a yearly percentage: divide by 100 for the rate and by 12 for months.
SELECT
    loan_id,
    CAST(ROUND(principal * interest_rate / 1200, 2) AS DECIMAL(12,2)) AS monthly_interest
FROM dbo.loans
ORDER BY loan_id;

-- Expected: 140 rows; 3rd row 11.48; last row 4.56.


-- Q13  (Requester: Partnerships)
-- For the merchant app we need a label per merchant: category, then ' / ' (slash
-- with a space on each side), then the merchant name, e.g. Dining / Urban Bites.
-- Return merchant_id and label, ordered by merchant_id.

-- My solution:
SELECT
    merchant_id,
    CONCAT(category, ' / ', merchant_name) AS label
FROM dbo.merchants
ORDER BY merchant_id;

-- Expected: 30 rows; merchant_id 7: Electronics / Circuit Point; last row: Entertainment / PlayZone.


-- Q14  (Requester: Credit Risk)
-- Which combinations of loan product and loan status exist? One row per
-- combination, ordered by product and then status.

-- My solution:
SELECT DISTINCT
    product,
    status
FROM dbo.loans
ORDER BY product, status;

-- Expected: 12 combinations; first product Auto; last status Paid.


-- Q15  (Requester: Compliance)
-- For the mailing we need each customer's name in lower case as name_lower.
-- Return customer_id, name_lower and city, ordered by customer_id.

-- My solution:
SELECT
    customer_id,
    LOWER(full_name) AS name_lower,
    city
FROM dbo.customers
ORDER BY customer_id;

-- Expected: 150 rows; customer_id 30: youssef fawzy; last row city: Abu Dhabi.
