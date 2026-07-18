WITH step0 AS(
SELECT 
customer_id,
MIN(d.order_date) AS min_order_date
FROM Delivery as d
GROUP BY d.customer_id
),
step1 AS(
SELECT 
SUM(CASE WHEN d1.order_date = step0.min_order_date then 1 else 0 END) AS first_order, 
SUM(CASE WHEN d1.order_date = d1.customer_pref_delivery_date then 1 else 0 END) AS immediate
FROM Delivery as d1 
INNER JOIN step0
	 ON d1.customer_id = step0.customer_id
     AND d1.order_date = step0.min_order_date
GROUP BY d1.customer_id
)
SELECT   ROUND(SUM(step1.immediate)/SUM(step1.first_order)*100,2) AS immediate_percentage
FROM step1