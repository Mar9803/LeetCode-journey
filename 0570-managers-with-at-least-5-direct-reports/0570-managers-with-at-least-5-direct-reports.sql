WITH find_manager AS(
SELECT COUNT(*) AS cont, managerId
FROM Employee
GROUP BY managerId
HAVING COUNT(*) >= 5
)
SELECT name
FROM Employee
WHERE id IN (SELECT managerId FROM find_manager)