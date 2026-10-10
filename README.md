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
Chinook sample database (SQL Server version). The `Invoice` and `InvoiceLine` tables are used as a stand-in for transaction data until fintech datasets are introduced in later weeks.

## Progress

### Week 1 — T-SQL Foundations

| Day | Topic | Business use | File |
|-----|-------|--------------|------|
| 1 | SELECT, DISTINCT, aliases, computed columns | Basic customer data retrieval, market list | [day01_select.sql](queries/day01_select.sql) |
| 2 | WHERE, LIKE, AND/OR, BETWEEN, ORDER BY, TOP, OFFSET-FETCH | Invoice filtering by value range, top-N and paginated invoice lists | [day02_filtering.sql](queries/day02_filtering.sql) |
| 3 | COUNT, SUM, AVG, GROUP BY, HAVING, WHERE vs HAVING | Revenue by country, revenue-threshold filtering, top-N markets | [day03_aggregations.sql](queries/day03_aggregations.sql), [where_vs_having.md](notes/where_vs_having.md) |
| 5 | INNER JOIN, table aliases, joins with aggregation | Customer lifetime spend, purchase frequency, yearly invoice extracts | [day05_inner_join.sql](queries/day05_inner_join.sql) |
| 6 | Multi-table joins, LEFT/RIGHT/FULL OUTER JOIN, anti-joins | Line-item purchase history, employee workload including zero-load staff, orphan record detection | [day06_multi_join.sql](queries/day06_multi_join.sql) |

Remaining in Week 1:
- [ ] Day 4: SQL Server data types, NULL handling (COALESCE, ISNULL, NULLIF, CAST/TRY_CAST)
- [ ] Day 7: review and exercises

## Contact
- LinkedIn: [www.linkedin.com/in/yomna-kayid-746a783ba]
- Email: [yomnakayid775@gmail.com]
