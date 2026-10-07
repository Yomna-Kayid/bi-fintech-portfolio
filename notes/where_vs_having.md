# WHERE vs HAVING

Both filter rows, but at different stages of query execution.

| | WHERE | HAVING |
|---|---|---|
| Runs | Before GROUP BY | After GROUP BY |
| Filters | Individual rows | Aggregated groups |
| Aggregates (SUM, COUNT, AVG) | Not allowed | Allowed |

## Execution order
FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT

## Example
```sql
SELECT BillingCountry, SUM(Total) AS revenue
FROM chinook.invoice
WHERE Total > 5               -- row-level: drop small invoices
GROUP BY BillingCountry
HAVING SUM(Total) > 20;       -- group-level: drop low-revenue countries
```

## Rule of thumb
If the condition uses a raw column, put it in WHERE (cheaper, fewer rows to group).
If it uses an aggregate result, it must go in HAVING.
