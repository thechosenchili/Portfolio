
-- The following are the usual queries against a financial dataset
-- Find out the operating margin for April 2025
SELECT
SUM("amount") AS "operating_margin"
FROM "income_statement"
WHERE "year" = 2025 AND "month" = 4
AND ("GL_L2" = 'Operating Revenues'
OR "GL_L2" = 'Cost of Goods Sold')
;


-- Find out the highest expense (per GL account) in April 2025
SELECT
"GL_L1",
ABS(SUM("amount")) AS "amount"
FROM "income_statement"
WHERE "year" = 2025 AND "month" = 4
AND "GL_L3" = 'Expense'
GROUP BY "GL_L1"
ORDER BY "amount" DESC
LIMIT 1
;


-- Compare the countries net income for 2024
SELECT
"country",
SUM("amount") AS "2024_net_income"
FROM "income_statement"
WHERE "year" = 2024
GROUP BY "country"
;


-- Compare the current year's financial performance against the prior year (until April)
SELECT
"year",
SUM("amount") AS "net_income",
CASE WHEN
    LAG(SUM("amount"), 1, 0) OVER(ORDER BY "year") = 0
    THEN 0
    ELSE SUM("amount") - LAG(SUM("amount"), 1, 0) OVER(ORDER BY "year")
END AS "variance"
FROM "income_statement"
WHERE "month" <= 4
GROUP BY "year"
;


-- Compute the company's asset to debt ratio for April 2025
SELECT
"GL_L3",
SUM("amount") AS "amount"
FROM "balance_sheet"
WHERE "GL_L3" = 'Assets'
OR "GL_L3" = 'Liabilities'
AND "year" <= 2025
GROUP BY "GL_L3"

UNION

SELECT
"Asset to Debt",
(SELECT CAST(SUM("amount") AS REAL) FROM "balance_sheet" WHERE "GL_L3" = 'Assets') /
(SELECT CAST(SUM("amount") AS REAL) FROM "balance_sheet" WHERE "GL_L3" = 'Liabilities') AS "Amount"
;

