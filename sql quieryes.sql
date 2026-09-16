/* ============================================================
   DATA QUERYING FOR FINANCIAL INSIGHTS
   MYSQL WORKBENCH VERSION
   ============================================================ */


/* ============================================================
   1. TOTAL SPEND PER CUSTOMER
   ============================================================ */

SELECT 
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_spent
FROM customers c
JOIN accounts a 
    ON c.customer_id = a.customer_id
JOIN transactions t 
    ON a.account_id = t.account_id
WHERE t.transaction_type = 'debit'
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;


/* ============================================================
   2. SALARY TREND ANALYSIS
   ============================================================ */

SELECT 
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,
    SUM(t.amount) AS total_salary_credited
FROM transactions t
WHERE t.transaction_type = 'credit'
  AND LOWER(t.description) LIKE '%salary credited%'
  AND t.transaction_date >= NOW() - INTERVAL 12 MONTH
GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')
ORDER BY month;


/* ============================================================
   3. MOST ACTIVE ACCOUNTS BY NUMBER OF TRANSACTIONS
   ============================================================ */

SELECT 
    t.account_id,
    c.name,
    COUNT(*) AS transaction_count
FROM transactions t
JOIN accounts a 
    ON t.account_id = a.account_id
JOIN customers c 
    ON a.customer_id = c.customer_id
GROUP BY t.account_id, c.name
ORDER BY transaction_count DESC
LIMIT 10;


/* ============================================================
   4. MOST ACTIVE ACCOUNTS BY VOLUME
   ============================================================ */

SELECT 
    t.account_id,
    c.name,
    a.account_number,

    COUNT(*) AS transaction_count,

    SUM(t.amount) AS total_transaction,

    ROUND(AVG(t.amount), 2) AS avg_transaction_size,

    SUM(
        CASE 
            WHEN t.transaction_type = 'debit' 
            THEN 1 
            ELSE 0 
        END
    ) AS debit_count,

    SUM(
        CASE 
            WHEN t.transaction_type = 'credit' 
            THEN 1 
            ELSE 0 
        END
    ) AS credit_count,

    SUM(
        CASE 
            WHEN t.transaction_type = 'debit' 
            THEN t.amount 
            ELSE 0 
        END
    ) AS total_debit_volume,

    SUM(
        CASE 
            WHEN t.transaction_type = 'credit' 
            THEN t.amount 
            ELSE 0 
        END
    ) AS total_credit_volume

FROM transactions t

JOIN accounts a 
    ON t.account_id = a.account_id

JOIN customers c 
    ON a.customer_id = c.customer_id

GROUP BY 
    t.account_id,
    c.name,
    a.account_number

ORDER BY transaction_count DESC

LIMIT 10;


/* ============================================================
   5. MONTHLY TRANSACTION BREAKDOWN
   ============================================================ */

SELECT 
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS month,

    COUNT(*) AS total_transactions,

    SUM(
        CASE 
            WHEN t.transaction_type = 'debit' 
            THEN 1 
            ELSE 0 
        END
    ) AS debit_count,

    SUM(
        CASE 
            WHEN t.transaction_type = 'credit' 
            THEN 1 
            ELSE 0 
        END
    ) AS credit_count,

    SUM(
        CASE 
            WHEN t.transaction_type = 'debit' 
            THEN t.amount 
            ELSE 0 
        END
    ) AS total_debit_volume,

    SUM(
        CASE 
            WHEN t.transaction_type = 'credit' 
            THEN t.amount 
            ELSE 0 
        END
    ) AS total_credit_volume,

    SUM(t.amount) AS total_transaction_volume,

    ROUND(AVG(t.amount), 2) AS avg_transaction_size

FROM transactions t

GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')

ORDER BY month;


/* ============================================================
   6. YEARLY TRANSACTION BREAKDOWN
   ============================================================ */

SELECT 
    YEAR(t.transaction_date) AS year,

    COUNT(*) AS total_transactions,

    SUM(
        CASE 
            WHEN t.transaction_type = 'debit' 
            THEN 1 
            ELSE 0 
        END
    ) AS debit_count,

    SUM(
        CASE 
            WHEN t.transaction_type = 'credit' 
            THEN 1 
            ELSE 0 
        END
    ) AS credit_count,

    SUM(
        CASE 
            WHEN t.transaction_type = 'debit' 
            THEN t.amount 
            ELSE 0 
        END
    ) AS total_debit_volume,

    SUM(
        CASE 
            WHEN t.transaction_type = 'credit' 
            THEN t.amount 
            ELSE 0 
        END
    ) AS total_credit_volume,

    SUM(t.amount) AS total_transaction_volume,

    ROUND(AVG(t.amount), 2) AS avg_transaction_size

FROM transactions t

GROUP BY YEAR(t.transaction_date)

ORDER BY year;


/* ============================================================
   7. TOP 20 HIGH-VALUE CUSTOMERS
   BY TOTAL CREDIT AMOUNT
   ============================================================ */

SELECT 
    c.customer_id,
    c.name,
    c.gender,
    c.city,

    COUNT(t.transaction_id) AS credit_transaction_count,

    SUM(t.amount) AS total_credits

FROM transactions t

JOIN accounts a 
    ON t.account_id = a.account_id

JOIN customers c 
    ON a.customer_id = c.customer_id

WHERE t.transaction_type = 'credit'

GROUP BY 
    c.customer_id,
    c.name,
    c.gender,
    c.city

ORDER BY total_credits DESC

LIMIT 20;


/* ============================================================
   8. DORMANT ACCOUNTS
   CUSTOMERS INACTIVE IN LAST 12 MONTHS
   ============================================================ */

SELECT
    c.customer_id,
    c.name,
    c.gender,
    c.city,

    MAX(t.transaction_date) AS last_transaction_date

FROM customers c

JOIN accounts a 
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t 
    ON a.account_id = t.account_id

GROUP BY 
    c.customer_id,
    c.name,
    c.gender,
    c.city

HAVING 
    MAX(t.transaction_date) IS NULL
    OR MAX(t.transaction_date) < CURRENT_DATE - INTERVAL 12 MONTH

ORDER BY last_transaction_date;


/* ============================================================
   9. SINGLE PRODUCT CUSTOMERS
   CUSTOMERS WITH ONLY ONE ACCOUNT
   ============================================================ */

SELECT 
    c.customer_id,
    c.name,

    MAX(a.account_type) AS account_type,

    COUNT(a.account_id) AS total_accounts

FROM customers c

JOIN accounts a 
    ON c.customer_id = a.customer_id

GROUP BY 
    c.customer_id,
    c.name

HAVING COUNT(a.account_id) = 1;


/* ============================================================
   10. MOST USED TRANSACTION SERVICES
   ============================================================ */

SELECT 
    description,

    COUNT(*) AS transaction_count,

    SUM(amount) AS total_amount

FROM transactions

GROUP BY description

ORDER BY transaction_count DESC;


/* ============================================================
   11. CITY-WISE PERFORMANCE
   ============================================================ */

SELECT 
    c.city,

    COUNT(DISTINCT c.customer_id) AS total_customers,

    COUNT(t.transaction_id) AS total_transaction,

    COALESCE(SUM(t.amount), 0) AS total_transaction_amount,

    ROUND(AVG(t.amount), 2) AS avg_transaction_amount

FROM customers c

LEFT JOIN accounts a 
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t 
    ON a.account_id = t.account_id

GROUP BY c.city

ORDER BY total_transaction DESC;


/* ============================================================
   12. ENGAGEMENT BY REGION
   ACTIVE / DORMANT ACCOUNTS & CUSTOMERS
   ============================================================ */

SELECT 
    c.city,

    COUNT(DISTINCT c.customer_id) AS total_customers,

    COUNT(DISTINCT a.account_id) AS total_accounts,

    COUNT(
        DISTINCT CASE 
            WHEN t.transaction_date >= CURRENT_DATE - INTERVAL 12 MONTH
            THEN a.account_id
        END
    ) AS active_accounts,

    COUNT(
        DISTINCT CASE 
            WHEN t.transaction_date < CURRENT_DATE - INTERVAL 12 MONTH
            THEN a.account_id
        END
    ) AS dormant_accounts

FROM customers c

LEFT JOIN accounts a 
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t 
    ON a.account_id = t.account_id

GROUP BY c.city

ORDER BY total_customers DESC;


/* ============================================================
   13. HIGHEST SPENDER BY CITY
   ============================================================ */

WITH customer_spending AS (

    SELECT 
        c.customer_id,
        c.name,
        c.city,

        SUM(t.amount) AS total_spent

    FROM customers c

    JOIN accounts a 
        ON c.customer_id = a.customer_id

    JOIN transactions t 
        ON a.account_id = t.account_id

    WHERE t.transaction_type = 'debit'

    GROUP BY 
        c.customer_id,
        c.name,
        c.city
),

ranked_customers AS (

    SELECT
        city,
        name,
        total_spent,

        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY total_spent DESC
        ) AS rank_no

    FROM customer_spending
)

SELECT
    city,
    name,
    total_spent

FROM ranked_customers

WHERE rank_no = 1

ORDER BY city;