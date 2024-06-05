--Query 1: Showing the First Wins of Drivers on the Current(2023) Grid 

/*
In this approach, I used the `ROW_NUMBER()` function to rank each driver's race wins by year.
This ranking process was done within a CTE (Common Table Expression). Then, I filtered out the current 
drivers based on specific criteria. After that, I joined the drivers table with the ranked drivers table,
applying a filter to extract relevant drivers from the drivers table. By using a `LEFT JOIN`, I ensured that
all initial drivers are included in the final results, even if they don't have any wins.*/


WITH RankedWins AS (
    SELECT 
        d.driverId,
        d.forename, 
        d.surname, 
        d.number, 
        r.name AS race_name, 
        r.year, 
        ROW_NUMBER() OVER (PARTITION BY d.driverId ORDER BY r.year) AS rn --Ranking wins based on drivers
    FROM F1_Project.dbo.drivers$ d
    JOIN F1_Project.dbo.results$ res ON d.driverID = res.driverId
    JOIN F1_Project.dbo.races$ r ON res.raceId = r.raceId
    WHERE d.forename IN ('Max', 'Sergio', 'Charles', 'Carlos', 'Oscar', 'Lando', 'Lewis', 'George', 'Fernando', 'Lance', 'Daniel', 'Yuki', 'Nico', 'Guanyu', 'Valtteri', 'Alexander', 'Logan', 'Esteban', 'Pierre')
    AND d.number IN (33, 27, 81, 10, 11, 77, 22, 23, 55, 16, 3, 31, 14, 63, 24, 18, 4, 44, 2)
    AND res.position = 1
)
SELECT 
    d.forename, 
    d.surname, 
    d.number, 
    rw.race_name, 
    rw.year AS yearofwin
FROM F1_Project.dbo.drivers$ d
LEFT JOIN RankedWins rw ON d.driverId = rw.driverId AND rw.rn = 1
WHERE d.forename IN ('Max', 'Sergio', 'Charles', 'Carlos', 'Oscar', 'Lando', 'Lewis', 'George', 'Fernando', 'Lance', 'Daniel', 'Yuki', 'Nico', 'Guanyu', 'Valtteri', 'Alexander', 'Logan', 'Esteban', 'Pierre')
AND d.number IN (33, 27, 81, 10, 11, 77, 22, 23, 55, 16, 3, 31, 14, 63, 24, 18, 4, 44, 2)
;




