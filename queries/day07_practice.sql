-- ============================================================
-- BI Developer Portfolio
-- Day 7: Mixed practice (LeetCode, StrataScratch)
-- Author: Yomna
-- Source: external practice problems, not on the Chinook database.
-- Solutions use standard SQL and also run on T-SQL.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Combine Two Tables (LeetCode, Easy)
-- Report first name, last name, city and state of each person;
-- NULL when the person has no address.
-- LEFT JOIN keeps every person even without a matching Address row.
-- ------------------------------------------------------------
SELECT
    p.firstName,
    p.lastName,
    a.city,
    a.state
FROM Person AS p
LEFT JOIN Address AS a
    ON p.personId = a.personId;

-- ------------------------------------------------------------
-- 2. Employees Earning More Than Their Managers (LeetCode, Easy)
-- Self join: the same table is read twice, once as employee (e)
-- and once as manager (m), matched on e.managerId = m.id.
-- INNER JOIN drops employees with no manager (managerId IS NULL).
-- ------------------------------------------------------------
SELECT e.name AS Employee
FROM Employee AS e
INNER JOIN Employee AS m
    ON e.managerId = m.id
WHERE e.salary > m.salary;

-- ------------------------------------------------------------
-- 3. Not Boring Movies (LeetCode, Easy)
-- Odd id and description other than 'boring', highest rating first.
-- id % 2 = 1 tests for odd numbers.
-- Note: <> excludes rows where description is NULL, because NULL <> 'boring'
-- is unknown, not true.
-- ------------------------------------------------------------
SELECT *
FROM Cinema
WHERE id % 2 = 1
  AND description <> 'boring'
ORDER BY rating DESC;

-- ------------------------------------------------------------
-- 4. Find Customer Referee (LeetCode, Easy)
-- Customers not referred by customer 2, including customers with no referee.
-- referee_id <> 2 alone would drop every NULL row, so NULL needs its own condition.
-- Equivalent: WHERE COALESCE(referee_id, 0) <> 2
-- ------------------------------------------------------------
SELECT name
FROM Customer
WHERE referee_id <> 2
   OR referee_id IS NULL;

-- ------------------------------------------------------------
-- 5. Finding Updated Records (StrataScratch, Easy, ID 10299)
-- Current salary per employee = highest salary among that employee's records.
-- Derived table finds MAX(salary) per id, then joins back to recover the full row.
-- Limitation: if two records of one employee share the maximum salary, both
-- rows are returned. The problem asks for one.
-- ------------------------------------------------------------
SELECT
    e.id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary
FROM ms_employee_salary AS e
INNER JOIN (
    SELECT
        id,
        MAX(salary) AS max_salary
    FROM ms_employee_salary
    GROUP BY id
) AS m
    ON e.id = m.id
   AND e.salary = m.max_salary
ORDER BY e.id ASC;

-- Alternative to revisit on Day 10 (window functions), one row per employee even with ties:
-- SELECT id, first_name, last_name, department_id, salary
-- FROM (
--     SELECT *,
--            ROW_NUMBER() OVER (PARTITION BY id ORDER BY salary DESC) AS rn
--     FROM ms_employee_salary
-- ) AS ranked
-- WHERE rn = 1
-- ORDER BY id ASC;
