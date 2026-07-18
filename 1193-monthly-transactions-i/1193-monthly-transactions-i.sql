SELECT DATE_FORMAT(trans_date, '%Y-%m') as month, t.country, 
COUNT(*) as trans_count, 
SUM(CASE WHEN state = "approved" then 1 ELSE 0 END) AS approved_count, 
SUM(amount) as trans_total_amount,
SUM(CASE WHEN state = "approved" then amount ELSE 0 END) AS approved_total_amount
FROM Transactions as t
GROUP BY month, country