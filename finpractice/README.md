## FinPractice: SQL Practice Log

Practice sets on a synthetic fintech database (`FinPractice`, SQL Server / T-SQL). Each set covers one day of the 90-day plan. Questions are written as stakeholder tickets with an expected result for validation. All data is randomly generated.

---

### Set 1 (Day 1): SELECT, DISTINCT and Computed Columns

10 questions on basic selection, de-duplication and column expressions.

**Techniques**
- `SELECT DISTINCT` on a single column and on column pairs (applies to the combination, not each column)
- Column aliases and computed columns (`principal * interest_rate / 100`)
- String concatenation with `+` and `CONCAT`; `+` returns NULL if any operand is NULL, `CONCAT` does not
- `UPPER` for text normalization
- `CAST(ROUND(...) AS DECIMAL(12,2))` to control the output scale of arithmetic results
- `NULLIF` to guard against divide-by-zero in production data
- Validation queries (`COUNT(DISTINCT ...)`, `COUNT(*)`) to confirm row counts

**Business use cases**
- Customer city list for email localization
- Display label generation for a branch locator
- Yearly interest per loan for treasury reporting
- Account type and status combinations in the book (risk view)
- Merchant category and country coverage
- Uppercase customer names for a KYC mailing
- Monthly principal portion per loan for planning
- Support-facing account summary line
- Branch footprint by country and city

**Source:** [set01_select_distinct.sql](set01_select_distinct.sql)

---

### Set 2 (Day 2): Filtering, Sorting and Paging

10 questions on row filtering and ordering, plus 5 review questions from Day 1.

**Techniques**
- `WHERE` with `AND` / `OR` and explicit parentheses (`AND` binds tighter than `OR`)
- `IN`, `BETWEEN` (inclusive bounds), `<>`
- `LIKE` with prefix (`'A%'`) and suffix (`'%Hassan'`) patterns
- `ORDER BY` with tie-breakers for deterministic output
- `TOP (n)` with ordered ties
- `OFFSET ... FETCH NEXT` for pagination (page N skips `(N - 1) x page_size` rows)
- Matching filter values to the stored case (`'Web'`, `'Completed'`)
- Review: `DISTINCT` on pairs, computed columns, `CONCAT`, `LOWER`

**Business use cases**
- Regional campaign targeting by city
- Audit sampling of mid-sized non-failed transactions
- Fraud review of the largest completed transactions
- Name-based customer segmentation
- Paged customer review screen ordered by signup date
- Risk list of non-active Savings and Business accounts
- Digital channel review (Mobile / Web, completed, above a threshold)
- Merchant filtering by country and category
- Collections list of unpaid loans by term and interest rate
- Monthly interest per loan and merchant app labels (review)

**Source:** [set02_filtering.sql](set02_filtering.sql)

---

### Set 3 (Day 3): Aggregations and Grouping

10 aggregation questions plus 5 review questions from Day 2.

**Techniques**
- Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `COUNT(DISTINCT ...)`
- `GROUP BY` on single and multiple columns (`account_type` + `status`)
- `WHERE` vs `HAVING`: row filtering before grouping, group filtering after
- Explicit `CAST(... AS DECIMAL)` on `ROUND(AVG(...))` and `ROUND(SUM(...))` to control output scale
- Deterministic ordering with tie-breakers in `ORDER BY`
- Review: `BETWEEN`, `TOP`, `IN` / `NOT IN`, `OFFSET-FETCH`, `SELECT DISTINCT` on column pairs

**Business use cases**
- Channel performance: completed transaction count, total and average amount per channel
- Transaction KPI snapshot: volume, active accounts, largest and average ticket
- Account book segmentation by type and status, with a minimum group size
- Customer concentration by city
- Loan pricing: average interest rate per product
- Credit risk: defaulted loan exposure per product
- Payment failure monitoring by transaction type
- Merchant coverage on purchase transactions
- Loan application decision mix and average requested amount
- Premium segment footprint and earliest signup

**Source:** [set03_aggregations.sql](set03_aggregations.sql)

---

### Progress

| Set | Plan day | Topics | File |
|-----|----------|--------|------|
| 1 | Day 1 | SELECT, DISTINCT, UPPER, CONCAT, computed columns | [set01_select_distinct.sql](set01_select_distinct.sql) |
| 2 | Day 2 (+ Day 1 review) | WHERE, AND/OR, IN, BETWEEN, LIKE, ORDER BY with tie-breakers, TOP, OFFSET-FETCH | [set02_filtering.sql](set02_filtering.sql) |
| 3 | Day 3 (+ Day 2 review) | COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT), GROUP BY, HAVING | [set03_aggregations.sql](set03_aggregations.sql) |
