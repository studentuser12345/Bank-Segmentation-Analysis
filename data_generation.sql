-- Insert 200 realistic Nigerian customers
INSERT INTO customers (name, gender, dob, signup_date, city)
SELECT
    CONCAT(
        ELT(FLOOR(1 + RAND() * 20),
            'Chinedu', 'Aisha', 'Tunde', 'Ngozi', 'Bola',
            'Obinna', 'Fatima', 'Yakubu', 'Emeka', 'Zainab',
            'Ifeanyi', 'Uche', 'Abubakar', 'Lilian', 'Segun',
            'Halima', 'Adesuwa', 'Kehinde', 'Mercy', 'Emmanuel'
        ),
        ' ',
        ELT(FLOOR(1 + RAND() * 20),
            'Okonkwo', 'Balogun', 'Adegoke', 'Nwachukwu', 'Danjuma',
            'Adelaja', 'Ibrahim', 'Umeh', 'Ogunleye', 'Abiola',
            'Mohammed', 'Eze', 'Lawal', 'Obi', 'Ahmed',
            'Onyeka', 'Nwabueze', 'Ajibade', 'Suleman', 'Johnson'
        )
    ),

    -- Random gender
    IF(RAND() < 0.5, 'M', 'F'),

    -- Random date of birth between 1970 and 1997
    DATE_ADD(
        '1970-01-01',
        INTERVAL FLOOR(RAND() * 10000) DAY
    ),

    -- Random signup date within last 3 years
    DATE_SUB(
        CURDATE(),
        INTERVAL FLOOR(RAND() * 1095) DAY
    ),

    -- Random city
    ELT(FLOOR(1 + RAND() * 12),
        'Lagos',
        'Abuja',
        'Port Harcourt',
        'Enugu',
        'Kano',
        'Ibadan',
        'Jos',
        'Abeokuta',
        'Calabar',
        'Owerri',
        'Benin City',
        'Kaduna'
    )

FROM (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
    UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
) numbers1
CROSS JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10
) numbers2;



SELECT COUNT(*) AS total_customers
FROM customers;

SELECT *
FROM customers;



-- Insert 1 or 2 accounts per customer
INSERT INTO accounts
    (customer_id, account_number, account_type, open_date, balance)
SELECT
    c.customer_id,

    -- Random 10-digit account number
    LPAD(
        FLOOR(RAND() * 10000000000),
        10,
        '0'
    ) AS account_number,

    -- Random account type
    ELT(
        FLOOR(1 + RAND() * 3),
        'savings',
        'current',
        'loan'
    ) AS account_type,

    -- Account opened within 90 days after signup
    DATE_ADD(
        c.signup_date,
        INTERVAL FLOOR(RAND() * 90) DAY
    ) AS open_date,

    -- Random balance between 1,000 and 500,000
    ROUND(
        1000 + RAND() * 499000,
        2
    ) AS balance

FROM customers c
WHERE RAND() < 0.75;


SELECT COUNT(*) AS total_accounts
FROM accounts;

SELECT *
FROM accounts;


-- Insert 1000 randomized transactions

INSERT INTO transactions
    (account_id, transaction_type, amount, transaction_date, description)

SELECT
    account_id,
    transaction_type,
    amount,
    transaction_date,
    description

FROM (

    SELECT
        a.account_id,

        -- Random credit/debit
        IF(RAND() < 0.5, 'debit', 'credit') AS transaction_type,

        -- Random amount between 500 and 250,000
        ROUND(
            500 + RAND() * 249500,
            2
        ) AS amount,

        -- Random transaction date within past 2 years
        DATE_SUB(
            NOW(),
            INTERVAL FLOOR(RAND() * 730) DAY
        ) AS transaction_date,

        -- Random description
        IF(
            RAND() < 0.5,

            -- Credit descriptions
            ELT(
                FLOOR(1 + RAND() * 11),
                'Salary credited',
                'Bank transfer from GTBank',
                'Credit alert from Zenith',
                'Reversal of failed transaction',
                'Loan disbursement',
                'Wallet top-up',
                'Refund from vendor',
                'POS reversal',
                'Received from customer',
                'Online payment received',
                'Cash deposit'
            ),

            -- Debit descriptions
            ELT(
                FLOOR(1 + RAND() * 11),
                'POS payment at Shoprite',
                'MTN Airtime recharge',
                'Fuel purchase at Mobil',
                'Electricity bill payment',
                'Loan EMI debit',
                'House rent payment',
                'Online purchase at Jumia',
                'Cash withdrawal from ATM',
                'Subscription payment',
                'Insurance premium debit',
                'Bank transfer to Fidelity Bank'
            )
        ) AS description

    FROM accounts a

    CROSS JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
        UNION ALL SELECT 10
    ) transaction_numbers

) AS transaction_data

ORDER BY RAND()
LIMIT 1000;

SELECT *
FROM transactions;
SELECT 
    transaction_type, 
    COUNT(*) 
FROM transactions 
GROUP BY transaction_type;
SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type
SELECT
    description,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY description
ORDER BY transaction_count DESC;
SELECT
    COUNT(*) AS total_transactions
FROM transactions;