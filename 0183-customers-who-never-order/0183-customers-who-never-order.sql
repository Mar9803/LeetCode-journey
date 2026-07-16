SELECT  C.name AS Customers
FROM Customers as C
LEFT JOIN Orders AS O
	ON C.id = O.customerId
WHERE customerId IS NULL
