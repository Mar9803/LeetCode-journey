# Write your MySQL query statement below
SELECT *
From Cinema
where description != 'boring' and id %2 !=0
order by rating desc
