# FinPractice

Practice sets on a synthetic fintech database. Each set follows the topics of one day in the 90-day plan and is solved on this data instead of Chinook. All values are randomly generated; no real customer data.

## Setup
Run [FinPractice.sql](FinPractice.sql) in SSMS. It drops and recreates the `FinPractice` database, so it can be re-run to reset the data.

## Tables
branches, customers, accounts, merchants, transactions, loans, loan_applications

## Sets

| Set | Plan day | Topics | File |
|-----|----------|--------|------|
| 1 | Day 1 | SELECT, DISTINCT, UPPER, CONCAT, computed columns | [set01_select_distinct.sql](set01_select_distinct.sql) |
| 2 | Day 2 | WHERE, AND/OR, IN, BETWEEN, LIKE, TOP, OFFSET-FETCH, <> | [set02_filtering.sql](set02_filtering.sql) |
| 3 | Day 3 | COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT), GROUP BY, HAVING | [set03_aggregations.sql](set03_aggregations.sql) |
| 4 | Day 4 | IS NULL, COUNT(*) vs COUNT(col), COALESCE, ISNULL, NULLIF, CAST vs TRY_CAST, DECIMAL precision | [set04_nulls_types.sql](set04_nulls_types.sql) |
| 5 | Day 5 | INNER JOIN, aliases, join + WHERE, join + GROUP BY, COUNT(DISTINCT) after a join | [set05_inner_join.sql](set05_inner_join.sql) |
| 6 | Day 6 | LEFT JOIN, anti-joins, filter in ON vs WHERE, 3-4 table joins, FULL OUTER JOIN | [set06_outer_joins.sql](set06_outer_joins.sql) |
