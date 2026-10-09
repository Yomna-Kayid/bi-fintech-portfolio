# BI Developer Portfolio — Fintech

90-day plan to move from financial analysis into BI development in fintech. This repository holds the SQL, Power BI, ETL and Python work produced along the way, committed daily.

## Focus
- SQL: joins, window functions, CTEs, views, stored procedures
- Data warehousing: star schema, SCD Type 2, ETL design
- Power BI: data modeling, DAX, Power Query (M), RLS, performance tuning
- Python: pandas cleaning and database load scripts
- Fintech reporting: transaction analysis, lending KPIs, KYC metrics

## Repository Structure
```
queries/     SQL practice, one file per day
notes/       Concept notes (WHERE vs HAVING, OLTP vs OLAP, ...)
diagrams/    Data models and ETL diagrams
scripts/     Python automation scripts
backlog/     Example BI tickets
portfolio/   End-to-end projects
```

## Tech Stack
- Database: MySQL (Chinook sample database)
- Version control: Git, GitHub
- Planned: Power BI, Python (pandas), Power Query M

## Data Source
Chinook sample database. The `invoice` and `invoice_line` tables are used as a stand-in for transaction data until fintech datasets are introduced in later weeks.

## Progress

### Week 1 — SQL Foundations

| Day | Topic | Business use | File |
|-----|-------|--------------|------|
| 1 | SELECT, FROM, aliases, CONCAT | Basic customer data retrieval | [day01_select_basics.sql](queries/day01_select_basics.sql) |
| 2 | WHERE, LIKE, AND/OR, BETWEEN, ORDER BY, LIMIT; JOIN preview | Invoice filtering by value range, top-N invoices | [day02_filtering.sql](queries/day02_filtering.sql) |
| 3 | COUNT, SUM, AVG, MIN, MAX, GROUP BY | Revenue by country, average invoice value per customer | [day03_aggregations.sql](queries/day03_aggregations.sql) |
| 4 | HAVING, WHERE vs HAVING | Revenue-threshold filtering per country, top-N markets | [day04_having.sql](queries/day04_having.sql), [where_vs_having.md](notes/where_vs_having.md) |
| 5 | INNER JOIN, table aliases, joins with aggregation | Customer lifetime spend, purchase frequency, yearly invoice extracts | [day05_inner_join.sql](queries/day05_inner_join.sql) |
| 6 | Multi-table INNER JOIN, LEFT/RIGHT JOIN, anti-joins, FULL JOIN emulation in MySQL | Line-item purchase history, units per customer, employee workload including zero-load staff, orphan record detection | [day06_multi_join.sql](queries/day06_multi_join.sql) |

Remaining in Week 1:
- [ ] Day 7: review and exercises

## Contact
- LinkedIn: [www.linkedin.com/in/yomna-kayid-746a783ba]
- Email: [yomnakayid775@gmail.com]
