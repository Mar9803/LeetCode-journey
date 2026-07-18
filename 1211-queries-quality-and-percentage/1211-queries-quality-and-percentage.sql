SELECT 
q.query_name,ROUND(SUM(q.rating/q.position)/COUNT(q.query_name),2) as quality,
 ROUND((COUNT(CASE WHEN q.rating <3 then 1 end))/(COUNT(query_name))*100,2) as poor_query_percentage
FROM Queries AS q
GROUP BY  q.query_name