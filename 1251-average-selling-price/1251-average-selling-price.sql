WITH calculation AS(
SELECT p.product_id, ROUND(SUM(p.price*u.units)/SUM(units),2) AS average_price
FROM Prices as p
LEFT JOIN UnitsSold as u
	ON p.product_id = u.product_id
    AND (purchase_date >= start_date AND  purchase_date <= end_date)
GROUP BY product_id
)
SELECT product_id,
CASE WHEN average_price IS null THEN 0 ELSE average_price END AS average_price
FROM calculation