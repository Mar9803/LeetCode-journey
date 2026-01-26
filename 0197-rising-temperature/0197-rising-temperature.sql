SELECT T1.id
FROM Weather AS T1 JOIN Weather AS T2 ON T1.recordDate =T2.recordDate + INTERVAL 1 DAY
WHERE T1.temperature > T2.temperature
