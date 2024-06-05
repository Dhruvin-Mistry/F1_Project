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
WHERE d.forename IN ('Max', 'Sergio', 'Charles', 'Carlos', 'Oscar', 'Lando', 'Lewis', 'George', 'Fernando', 'Lance', 'Daniel', 'Yuki', 'Nico','Kevin', 'Guanyu', 'Valtteri', 'Alexander', 'Logan', 'Esteban', 'Pierre')
AND d.number IN (33, 27, 81, 10, 11, 77, 22, 23, 55, 16, 3, 31, 14, 63, 24, 18, 4, 44, 2,20)
;


--Query 2: Ferrari's three Most Successful Circuit


/* A simple Query wheren I combined 4 tables using their respective Primary keys. It is important to 
figure the tables that are necessary for your required query and connect them. Then I finally grouped them by 
Race name and Circuit name and filtered out the team which I required. Ordered it in descending and limited it by
using TOP clause since LIMIT is not available in MS SQL*/


select TOP 3 c.name, r.name, (count(res.position)) as Wins from F1_Project.dbo.circuits$ c
join F1_Project.dbo.races$ r
on c.circuitId = r.circuitId
join F1_Project.dbo.results$ res
on r.raceId  = res.raceId
join F1_Project.dbo.constructors$ con
on res.constructorId = con.constructorId
where con.name = 'Ferrari' and res.position = 1
group by c.name,r.name
order by Wins desc

--Query 3:List of all the Drivers and their Teams

/*Since the drivers and constructors tables do not have any common columns to connect directly, 
I used another table that shares a common column with both to establish the connection. One problem
I faced here was that the Drivers change their teams throughout their career. Hence I needed to fix a year 
to display the driver and their team for that current year.*/

select distinct d.forename,d.surname,c.name
from F1_Project.dbo.drivers$ d
join F1_Project.dbo.results$ r on d.driverId = r.driverId
join F1_Project.dbo.constructors$ c on c.constructorId = r.constructorId
join F1_Project.dbo.races$ ra on r.raceId = ra.raceId 
WHERE d.forename IN ('Max', 'Sergio', 'Charles', 'Carlos', 'Oscar', 'Lando', 'Lewis', 'George', 'Fernando', 'Lance', 'Daniel', 'Yuki', 'Nico','Kevin', 'Guanyu', 'Valtteri', 'Alexander', 'Logan', 'Esteban', 'Pierre')
AND d.number IN (33, 27, 81, 10, 11, 77, 22, 23, 55, 16, 3, 31, 14, 63, 24, 18, 4, 44, 2,20)
AND ra.year = 2023
order by c.name
