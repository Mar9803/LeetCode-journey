WITH daily_Table AS (
    SELECT visited_on, SUM(amount) AS sumDay_amount
    FROM Customer
    GROUP BY visited_on
),
Calculated_table AS (
SELECT visited_on,
SUM(sumDay_amount) OVER(
    ORDER BY visited_on
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
) AS amount,
ROUND(AVG(sumDay_amount) OVER ( 
    ORDER BY visited_on
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS average_amount,
    ROW_NUMBER() OVER(ORDER BY visited_on) AS riga_num 
FROM daily_Table
)
SELECT visited_on, amount, average_amount
FROM Calculated_table
WHERE riga_num >= 7;

