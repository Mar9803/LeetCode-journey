WITH Confronto AS (
    SELECT num,
           -- Guarda 1 riga indietro
           LAG(num, 1) OVER (ORDER BY id) AS prev1,
           -- Guarda 2 righe indietro
           LAG(num, 2) OVER (ORDER BY id) AS prev2
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM Confronto
WHERE num = prev1 AND num = prev2;