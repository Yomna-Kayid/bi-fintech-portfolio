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
