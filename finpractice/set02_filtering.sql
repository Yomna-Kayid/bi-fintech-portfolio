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
-- Ask: customers living in Cairo or Giza for a regional campaign, by customer_id.
SELECT
    customer_id
FROM dbo.customers
WHERE city IN ('Cairo', 'Giza')
ORDER BY customer_id ASC;
-- Expected: 35 rows; first customer_id 1; last 141.


-- Q2  (Requester: Finance)
-- Ask: non-failed transactions with amount 100 to 200 (inclusive), highest first,
-- with a stable order when amounts tie.
-- Note: BETWEEN includes both bounds. Amounts repeat in this range,
-- so txn_id is added as a tie-breaker to make the order deterministic.
SELECT
    txn_id
FROM dbo.transactions
WHERE amount BETWEEN 100 AND 200
  AND status <> 'Failed'
ORDER BY amount DESC, txn_id ASC;
-- Expected: 277 rows; first txn_id 50705; last 50408.


-- Q3  (Requester: Fraud)
-- Ask: 5 largest completed transactions; smaller txn_id wins ties.
SELECT TOP (5)
    txn_id,
    amount
FROM dbo.transactions
WHERE status = 'Completed'
ORDER BY amount DESC, txn_id ASC;
-- Expected: 5 rows; first txn_id 51385; last amount 4925.18.


-- Q4  (Requester: Marketing)
-- Ask: customers whose full name starts with "A", and the first one by customer_id.
-- Note: without ORDER BY the "first" row is not guaranteed, so customer_id is sorted explicitly.
SELECT
    customer_id,
    full_name
FROM dbo.customers
WHERE full_name LIKE 'A%'
ORDER BY customer_id;
-- Expected: 15 rows; first customer_id 21.


-- Q5  (Requester: Compliance)
-- Ask: page 3 of the customer review screen (15 rows per page),
-- ordered by signup_date then customer_id.
-- Note: page 3 skips (3 - 1) * 15 = 30 rows. OFFSET requires ORDER BY.
SELECT
    customer_id,
    signup_date
FROM dbo.customers
ORDER BY signup_date ASC, customer_id ASC
OFFSET 30 ROWS
FETCH NEXT 15 ROWS ONLY;
-- Expected: 15 rows; first customer_id 77; last 83.


-- Q6  (Requester: Risk)
-- Ask: non-active accounts of type Savings or Business, by account_id.
-- Note: AND binds tighter than OR, so the type conditions need their own parentheses.
SELECT
    account_id
FROM dbo.accounts
WHERE status <> 'Active'
  AND (account_type = 'Savings' OR account_type = 'Business')
ORDER BY account_id;
-- Expected: 21 rows; first account_id 1008; last 1189.


-- Q7  (Requester: Operations)
-- Ask: completed Purchase/Transfer transactions on Mobile/Web above 2000,
-- highest amount first, ties by txn_id.
-- Note: filter values match the stored case ('Web', not 'web').
SELECT
    txn_id
FROM dbo.transactions
WHERE status = 'Completed'
  AND txn_type IN ('Purchase', 'Transfer')
  AND channel IN ('Mobile', 'Web')
  AND amount > 2000
ORDER BY amount DESC, txn_id ASC;
-- Expected: 89 rows; first txn_id 52401; last 51431.


-- Q8  (Requester: Treasury)
-- Ask: merchants in the UAE or KSA outside the Fuel category, alphabetical.
SELECT
    merchant_id,
    merchant_name
FROM dbo.merchants
WHERE country IN ('UAE', 'KSA')
  AND category <> 'Fuel'
ORDER BY merchant_name ASC;
-- Expected: 13 rows; first Al Shifa Pharmacy; last WellLife Clinic.


-- Q9  (Requester: Collections)
-- Ask: unpaid loans with a 12 or 24 month term and interest rate 8 to 12 (inclusive),
-- largest principal first, ties by loan_id.
SELECT
    loan_id
FROM dbo.loans
WHERE term_months IN (12, 24)
  AND interest_rate BETWEEN 8 AND 12
  AND status <> 'Paid'
ORDER BY principal DESC, loan_id ASC;
-- Expected: 11 rows; first loan_id 7129; last 7066.


-- Q10  (Requester: Customer Support)
-- Ask: customers whose name ends with Hassan or Mansour and who do not live in Cairo.
-- Note: parentheses keep the OR on the name patterns from swallowing the city condition.
SELECT
    customer_id
FROM dbo.customers
WHERE (full_name LIKE '%Hassan' OR full_name LIKE '%Mansour')
  AND city <> 'Cairo'
ORDER BY customer_id;
-- Expected: 12 rows; first customer_id 2; last 127.


/* ------------------------------------------------------------
   PART 2 - Review of Day 1
   ------------------------------------------------------------ */

-- Q11  (Requester: Branch Network)
-- Ask: distinct branch cities for field visit planning, alphabetical.
SELECT DISTINCT
    city
FROM dbo.branches
ORDER BY city ASC;
-- Expected: 8 cities; last Riyadh.


-- Q12  (Requester: Treasury)
-- Ask: monthly interest per loan = principal * interest_rate / 1200, rounded to 2 decimals.
-- Note: interest_rate is a yearly percentage: /100 for the rate, /12 for months.
SELECT
    loan_id,
    CAST(ROUND(principal * interest_rate / 1200, 2) AS DECIMAL(12,2)) AS monthly_interest
FROM dbo.loans
ORDER BY loan_id;
-- Expected: 140 rows; 3rd row 11.48; last row 4.56.


-- Q13  (Requester: Partnerships)
-- Ask: merchant label in the format "category / merchant_name", ordered by merchant_id.
SELECT
    merchant_id,
    CONCAT(category, ' / ', merchant_name) AS label
FROM dbo.merchants
ORDER BY merchant_id;
-- Expected: 30 rows; merchant_id 7 Electronics / Circuit Point; last row Entertainment / PlayZone.


-- Q14  (Requester: Credit Risk)
-- Ask: loan product / status combinations that exist.
-- Note: DISTINCT applies to the pair, not to each column.
SELECT DISTINCT
    product,
    status
FROM dbo.loans
ORDER BY product, status;
-- Expected: 12 combinations; first product Auto; last status Paid.


-- Q15  (Requester: Compliance)
-- Ask: lower-case customer names as name_lower for the mailing.
SELECT
    customer_id,
    LOWER(full_name) AS name_lower,
    city
FROM dbo.customers
ORDER BY customer_id;
-- Expected: 150 rows; customer_id 30 youssef fawzy; last row city Abu Dhabi.
