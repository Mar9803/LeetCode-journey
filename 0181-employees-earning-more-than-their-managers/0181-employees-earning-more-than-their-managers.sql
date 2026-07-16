SELECT A.name as Employee
FROM Employee A, Employee B
WHERE A.managerId = B.Id and A.salary > B.salary;