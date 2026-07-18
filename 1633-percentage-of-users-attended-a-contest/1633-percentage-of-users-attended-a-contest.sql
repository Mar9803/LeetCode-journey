SELECT r.contest_id, ROUND((COUNT(r.user_id)/(SELECT COUNT(*) FROM Users))*100,2) AS percentage 
FROM  Users as u
Inner JOIN Register as r
    ON r.user_id = u.user_id
GROUP BY (r.contest_id)
ORDER BY percentage DESC, contest_id ASC;
