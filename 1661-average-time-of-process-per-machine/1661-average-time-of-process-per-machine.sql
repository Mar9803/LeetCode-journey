WITH split_time AS (
    SELECT *, 
           LAG(timestamp) OVER(PARTITION BY machine_id, process_id ORDER BY timestamp) AS previus_time
    FROM Activity
)
SELECT 
    machine_id,
    ROUND(AVG(timestamp - previus_time), 3) AS processing_time
FROM split_time
WHERE activity_type = 'end'
GROUP BY machine_id;