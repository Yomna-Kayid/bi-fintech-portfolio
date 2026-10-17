# BI Developer Portfolio — Fintech

90-day plan to move from financial analysis into BI development in fintech. This repository holds the T-SQL, Power BI, ETL, dbt and Python work produced along the way, committed daily.

## Focus
- T-SQL on SQL Server: joins, window functions, CTEs, views, stored procedures
- Data warehousing: star schema, SCD Type 2, ETL design
- Power BI: data modeling, DAX, Power Query (M), RLS, performance tuning
- dbt and Python: transformation models, pandas cleaning and load scripts
- Fintech reporting: transaction analysis, lending KPIs, KYC metrics

## Repository Structure
```
queries/     T-SQL practice, one file per day
notes/       Concept notes (WHERE vs HAVING, OLTP vs OLAP, ...)
finpractice/ Practice sets on a synthetic fintech database
diagrams/    Data models and ETL diagrams
scripts/     Python automation scripts
dbt/         dbt project (staging and mart models)
backlog/     Example BI tickets
portfolio/   End-to-end projects
```

## Tech Stack
- Database: SQL Server Express, SSMS (T-SQL)
- Version control: Git, GitHub
- Planned: Power BI, dbt Core, Python (pandas), Power Query M

## Data Source
- Chinook sample database (SQL Server version). The `Invoice` and `InvoiceLine` tables are used as a stand-in for transaction data until fintech datasets are introduced in later weeks.
- FinPractice: a synthetic fintech database (branches, customers, accounts, merchants, transactions, loans, loan applications). All values are randomly generated. Practice sets and the setup script are in [finpractice/](finpractice/).

## Progress

### Week 1 — T-SQL Foundations

| Day | Topic | Business use | File |
|-----|-------|--------------|------|
| 1 | SELECT, DISTINCT, aliases, computed columns | Basic customer data retrieval, market list | [day01_select.sql](queries/day01_select.sql) |
| 2 | WHERE, LIKE, AND/OR, BETWEEN, ORDER BY, TOP, OFFSET-FETCH | Invoice filtering by value range, top-N and paginated invoice lists | [day02_filtering.sql](queries/day02_filtering.sql) |
| 3 | COUNT, SUM, AVG, GROUP BY, HAVING, WHERE vs HAVING | Revenue by country, revenue-threshold filtering, top-N markets | [day03_aggregations.sql](queries/day03_aggregations.sql), [where_vs_having.md](notes/where_vs_having.md) |
| 4 | DECIMAL vs FLOAT, NULL handling (IS NULL, COALESCE, ISNULL, NULLIF), safe conversion with TRY_CAST | Data quality checks on loan data: NULL-aware averages, cleaning text amounts | [day04_nulls_types.sql](queries/day04_nulls_types.sql), [sql-server-data-types.md](notes/sql-server-data-types.md) |
| 5 | INNER JOIN, table aliases, joins with aggregation | Customer lifetime spend, purchase frequency, yearly invoice extracts | [day05_inner_join.sql](queries/day05_inner_join.sql) |
| 6 | Multi-table joins, LEFT/RIGHT/FULL OUTER JOIN, anti-joins | Line-item purchase history, employee workload including zero-load staff, orphan record detection | [day06_multi_join.sql](queries/day06_multi_join.sql) |
| 7 | Mixed practice: LEFT JOIN, self join, NULL-safe filtering, latest record per entity (MAX per group) | Records with no match, hierarchy comparison, current-value lookup from versioned records | [day07_practice.sql](queries/day07_practice.sql) |

### Extra practice

| Topic | File |
|-------|------|
| String functions (LEFT, RIGHT, SUBSTRING, CHARINDEX, REPLACE, LTRIM/RTRIM/TRIM), UNION vs UNION ALL, arithmetic, date functions (DATEADD, DATEDIFF, GETDATE) | [extra_string_math_date_functions.sql](queries/extra_string_math_date_functions.sql) |

### Week 1 summary
- Queried the Chinook database in T-SQL: filtering, sorting, pagination, aggregation, joins across up to four tables.
- Handled NULLs explicitly (IS NULL, COALESCE, NULLIF, TRY_CAST) and checked how they change aggregates.
- Solved external practice problems on LeetCode and StrataScratch.
- Lookups worth remembering: `HAVING` runs after `GROUP BY`; `COUNT(*)` on a LEFT JOIN counts the NULL-padded row; `SUBSTRING` positions start at 1; `<> value` drops NULL rows.

### Next: Week 2
Subqueries, CTEs, window functions (ROW_NUMBER, RANK, LAG/LEAD), CASE, date functions.

## Contact
- LinkedIn: [www.linkedin.com/in/yomna-kayid-746a783ba]
- Email: [yomnakayid775@gmail.com]
