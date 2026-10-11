# SQL Server data types and NULL handling

## Data types used for financial data
| Type | Use | Note |
|------|-----|------|
| INT | IDs, counts | Whole numbers only |
| DECIMAL(p,s) | Money, rates | Exact. DECIMAL(18,2) = 18 digits, 2 after the point |
| FLOAT | Scientific values | Approximate; avoid for money (0.1 + 0.2 <> 0.3) |
| VARCHAR / NVARCHAR | Text | NVARCHAR stores Unicode (Arabic, etc.) |
| DATE / DATETIME2 | Dates | DATE has no time part |

## NULL handling
| Function | Behavior |
|----------|----------|
| `IS NULL` | Only way to test for NULL; `= NULL` never matches |
| `COALESCE(a, b, ...)` | First non-NULL value; ANSI standard |
| `ISNULL(a, b)` | Two arguments; result type follows the first |
| `NULLIF(a, b)` | NULL when a = b; used for `x / NULLIF(y, 0)` |
| `TRY_CAST(x AS type)` | NULL instead of an error when conversion fails |
Note: `TRY_CAST` to DECIMAL rejects thousands separators ('12,500.75' returns NULL). Strip them first: `TRY_CAST(REPLACE(col, ',', '') AS DECIMAL(18,2))`.

## Why it matters in reporting
Aggregates (COUNT(col), AVG, SUM) skip NULLs. Replacing NULL with 0 before averaging changes the result, so the choice has to match the business definition of the metric.
