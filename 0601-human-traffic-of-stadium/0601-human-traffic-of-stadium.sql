WITH DatiIniziali AS (
    SELECT id, 
           visit_date,
           people,
           LAG(id, 1) OVER(ORDER BY id) AS prev_id_1,
           LAG(id, 2) OVER(ORDER BY id) AS prev_id_2,
           LAG(people, 1) OVER(ORDER BY id) AS prev_people_1,
           LAG(people, 2) OVER(ORDER BY id) AS prev_people_2,
           LEAD(id, 1) OVER(ORDER BY id) AS next_id_1,
           LEAD(id, 2) OVER(ORDER BY id) AS next_id_2,
           LEAD(people, 1) OVER(ORDER BY id) AS next_people_1,
           LEAD(people, 2) OVER(ORDER BY id) AS next_people_2
    FROM Stadium
)
SELECT id, visit_date, people
FROM DatiIniziali
WHERE 
    -- SCENARIO A: Primo di tre
    (
        people >= 100 
        AND next_people_1 >= 100 
        AND next_people_2 >= 100
        AND next_id_1 - id = 1 
        AND next_id_2 - id = 2
    )
    OR 
    -- SCENARIO B: In mezzo a tre
    (
        prev_people_1 >= 100 
        AND people >= 100 
        AND next_people_1 >= 100
        AND id - prev_id_1 = 1 
        AND next_id_1 - id = 1
    )
    OR 
    -- SCENARIO C: Ultimo di tre
    (
        prev_people_2 >= 100 
        AND prev_people_1 >= 100
        AND people >= 100 
        AND id - prev_id_1 = 1 
        AND prev_id_1 - prev_id_2 = 1
    )
ORDER BY visit_date;