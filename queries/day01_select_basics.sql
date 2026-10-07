-- ============================================================
-- BI Developer Portfolio
-- Day 1: SELECT basics
-- Author: Yomna
-- Database: Chinook (MySQL)
-- ============================================================

-- 1. Return all columns from the customer table.
SELECT *
FROM chinook.customer;

-- 2. Select only the columns needed instead of SELECT *.
SELECT FirstName, LastName, Country
FROM chinook.customer;

-- 3. Rename output columns with aliases.
SELECT
    FirstName AS first,
    LastName  AS last
FROM chinook.customer;

-- 4. Build a derived column (full name) with CONCAT.
SELECT
    CONCAT(FirstName, ' ', LastName) AS FullName,
    Country
FROM chinook.customer;