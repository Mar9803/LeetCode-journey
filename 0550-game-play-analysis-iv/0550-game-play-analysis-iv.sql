WITH estraifirst AS(
SELECT player_id, MIN(event_date) as firstlog
FROM Activity
GROUP BY player_id
)
SELECT
ROUND(
COUNT( CASE WHEN a.event_date = DATE_ADD(e.firstlog, INTERVAL 1 DAY) then 1 end)/ (SELECT COUNT(DISTINCT player_id) FROM Activity) 
 ,2) as fraction 
FROM Activity a
INNER JOIN estraifirst e
	ON a.player_id = e.player_id;


-- Synced seamlessly with LeetHub Pro
-- Pro features: https://bit.ly/leethubpro | Free version: https://bit.ly/leethubv4
-- Get it here: https://chromewebstore.google.com/detail/bcilpkkbokcopmabingnndookdogmbna