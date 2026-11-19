# FinPractice

Practice sets on a synthetic fintech database. Each set follows the topics of one day in the 90-day plan and is solved on this data. Questions are written as stakeholder tickets (requesters are fictional), each with an expected result. All values are randomly generated; no real customer data.

## Setup
Run [FinPractice.sql](FinPractice.sql) in SSMS. It drops and recreates the `FinPractice` database, so it can be re-run to reset the data.

## Tables
branches, customers, accounts, merchants, transactions, loans, loan_applications

## Sets

| Set | Plan day | Topics | File |
|-----|----------|--------|------|
| 1 | Day 1 | SELECT, DISTINCT, UPPER, CONCAT, computed columns | [set01_select_distinct.sql](set01_select_distinct.sql) |
| 2 | Day 2 (+ Day 1 review) | WHERE, AND/OR, IN, BETWEEN, LIKE, ORDER BY with tie-breakers, TOP, OFFSET-FETCH | [set02_filtering.sql](set02_filtering.sql) |
| 3 | Day 3 (+ Day 2 review) | COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT), GROUP BY, HAVING | [set03_aggregations.sql](set03_aggregations.sql) |
| 4 | Day 4 (+ Day 3 review) | IS NULL, COUNT(*) vs COUNT(col), COALESCE, ISNULL, NULLIF, CAST, INFORMATION_SCHEMA, DECIMAL precision | [set04_nulls_types.sql](set04_nulls_types.sql) |
---

## Set 1 (Day 1): SELECT, DISTINCT and Computed Columns

Solved on the `FinPractice` database (SQL Server / T-SQL). 10 questions written as stakeholder tickets.

**Techniques**
- `SELECT DISTINCT` on single columns and on column pairs
- Column aliases and computed columns
- `UPPER` for case normalization
- String concatenation with `+` vs `CONCAT` and the NULL behavior of each
- `CAST(ROUND(...) AS DECIMAL(12,2))` to control the scale of computed amounts
- `NULLIF` as a divide-by-zero guard (noted for production data)
- Row-count validation queries against `COUNT(DISTINCT ...)` and `COUNT(*)`

**Business use cases**
- Customer city list for campaign localization (Marketing)
- Branch display labels for a branch locator (Product Analytics)
- Yearly interest and monthly principal per loan (Finance, Treasury)
- Account type / status combinations for risk review (Risk)
- Merchant category and country coverage (Merchant Operations, Partnerships)
- Normalized customer names for KYC mailings (Compliance)
- Account summary lines for agents (Customer Support)
- Branch footprint by country and city (Branch Network)

**Source:** [set01_select_distinct.sql](set01_select_distinct.sql)

---

## Set 2 (Day 2): Filtering, Sorting and Paging

Solved on the `FinPractice` database (SQL Server / T-SQL). 10 filtering questions plus 5 review questions from Day 1, written as stakeholder tickets.

**Techniques**
- `WHERE` with `AND` / `OR` and explicit parentheses to control operator precedence
- `IN`, `BETWEEN` (inclusive bounds), `<>` and `LIKE` with leading and trailing wildcards
- `ORDER BY` with tie-breakers (`txn_id`, `customer_id`) for deterministic output
- `TOP (n)` with a tie-breaker
- `OFFSET ... FETCH NEXT` for pagination (page 3 of 15 rows = `OFFSET 30`)
- Matching filter values to the stored case (`'Web'`, not `'web'`)
- Review: `SELECT DISTINCT` on column pairs, `CONCAT`, `LOWER`, `CAST(ROUND(...) AS DECIMAL(12,2))`

**Business use cases**
- Regional campaign targeting by city (Customer Support)
- Audit sampling of mid-sized, non-failed transactions (Finance)
- Largest completed transactions for fraud review (Fraud)
- Paged customer review screen (Compliance)
- Non-active Savings and Business accounts (Risk)
- Mobile and Web purchases and transfers above 2000 (Operations)
- Merchant lists by country and category (Treasury)
- Unpaid loans by term and interest rate (Collections)
- Customer lookup by name pattern (Customer Support)
- Monthly loan interest and merchant app labels (review)

**Source:** [set02_filtering.sql](set02_filtering.sql)

---

## Set 3 (Day 3): Aggregations and Grouping

Solved on the `FinPractice` database (SQL Server / T-SQL). 10 aggregation questions plus 5 review questions from Day 2, written as stakeholder tickets.

**Techniques**
- Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `COUNT(DISTINCT ...)`
- `GROUP BY` on single and multiple columns (`account_type` + `status`)
- `WHERE` vs `HAVING`: row filtering before grouping, group filtering after
- `ORDER BY` on an aggregate alias, with tie-breakers for deterministic output
- Explicit `CAST(... AS DECIMAL)` on `ROUND(AVG(...))` and `ROUND(SUM(...))` to control output scale
- Review: `BETWEEN`, `TOP`, `SELECT DISTINCT` on column pairs, `IN` / `NOT IN`, `OFFSET-FETCH` with a unique last sort key

**Business use cases**
- Channel scorecard: completed transaction count, total and average amount per channel (Regional Sales Lead)
- Transaction health KPIs: volume, active accounts, largest and average ticket (Product Analytics)
- Account book concentration by type and status with a minimum group size (Risk)
- Customer concentration by city for local events (Marketing)
- Average interest rate per loan product (Treasury)
- Defaulted loan exposure per product (Collections)
- Failed transaction counts by transaction type (Fraud)
- Merchant activity on completed purchases (Operations)
- Loan application funnel by decision (Head of Lending)
- Premium segment footprint and earliest signup (Growth)


**Source:** [set03_aggregations.sql](set03_aggregations.sql)

## Set 4 (Day 4): NULL Handling and Data Types

Solved on the `FinPractice` database (SQL Server / T-SQL). 10 NULL and data type questions plus 5 review questions from Day 3, written as stakeholder tickets.

**Techniques**
- `IS NULL` / `IS NOT NULL` filtering, including combined conditions with `AND`
- `COUNT(*)` vs `COUNT(column)`: counting rows vs counting non-NULL values
- Decimal division (`100.0 * ...`) to avoid integer truncation in percentages
- `COALESCE` with multiple fallbacks and `ISNULL` as a NULL-safe default in date comparisons
- `NULLIF` to exclude zeros from `AVG`
- `CAST` from `DECIMAL` to `INT` (truncates, no rounding), applied per row before `SUM`
- `INFORMATION_SCHEMA.COLUMNS` to read data type, numeric precision and max length
- Review: `GROUP BY` with `HAVING`, `IN`, `BETWEEN`, computed columns, `COUNT(DISTINCT ...)` summaries

**Business use cases**
- Email coverage gap for the campaign tool (Marketing)
- Share of customers missing a phone number (Data Governance)
- Single contact value per customer with fallback order (Customer Support)
- Point-in-time count of open accounts on a reporting date (Risk)
- Average balance of funded accounts (Treasury)
- Transactions without a merchant (Fraud)
- Customers unreachable by email or phone (Compliance)
- Loan applications pending a decision, with requested amount (Collections)
- Column data type and precision check from the catalog (Audit)
- Whole-unit purchase totals (Finance)
- Review: Active account scorecard, channel volume threshold, loan filtering, net amount after fee, lending KPI row

**Source:** [set04_nulls_types.sql](set04_nulls_types.sql)


