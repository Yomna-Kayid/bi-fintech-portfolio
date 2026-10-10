-- ============================================================
-- BI Developer Portfolio
-- Day 1: SELECT basics
-- Author: Yomna
-- Database: Chinook (SQL Server / T-SQL)
-- ============================================================

USE Chinook;
GO

-- 1. Return all columns from the Customer table.
SELECT *
FROM dbo.Customer;

-- 2. Select only the columns needed instead of SELECT *.
SELECT FirstName, LastName, Country
FROM dbo.Customer;

-- 3. Remove duplicates: list of countries with at least one customer.
SELECT DISTINCT Country
FROM dbo.Customer;

-- 4. Rename output columns with aliases.
SELECT
    FirstName AS first_name,
    LastName  AS last_name
FROM dbo.Customer;

-- 5. Derived column: full name built with CONCAT.
SELECT
    CONCAT(FirstName, ' ', LastName) AS FullName,
    Country
FROM dbo.Customer;
