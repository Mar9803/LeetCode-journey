WITH extract AS (
    SELECT e1.id, e1.name AS name, COUNT(e2.id) as cont  -- Conta gli ID dei sottoposti
    FROM Employee e1
    INNER JOIN Employee e2
        ON e1.id = e2.managerId
    GROUP BY e1.id, e1.name
    HAVING cont >= 5
)
SELECT name
FROM extract;