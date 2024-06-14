--Query 1: Showing the First Wins of Drivers on the Current(2023) Grid 

/* In this approach, I used the ROW_NUMBER() function to rank each driver's race wins by year.
This ranking process was done within a CTE (Common Table Expression). Then, I filtered out the current 
drivers based on specific criteria. After that, I joined the drivers table with the ranked drivers table,
applying a filter to extract relevant drivers from the drivers table. By using a LEFT JOIN, I ensured that
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
    where CONCAT(d.forename,' ',d.surname) IN 
('Lewis Hamilton', 'Fernando Alonso', 'Pierre Gasly', 'Nico Hülkenberg', 'Sergio Pérez', 'Daniel Ricciardo', 'Valtteri Bottas', 'Kevin Magnussen', 'Max Verstappen', 'Carlos Sainz', 'Esteban Ocon', 'Lance Stroll', 'Charles Leclerc', 'Lando Norris', 'George Russell', 'Alexander Albon', 'Yuki Tsunoda', 'Guanyu Zhou', 'Oscar Piastri', 'Logan Sargeant')


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



----------------------------------------------------------------------------------------------------------------------

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



----------------------------------------------------------------------------------------------------------------------

--Query 3:List of all the Drivers and their Teams

/*Since the drivers and constructors tables do not have any common columns to connect directly, 
I used another table that shares a common column with both to establish the connection. One problem
I faced here was that the Drivers change their teams throughout their career. Hence I needed to fix a year 
to display the driver and their team for that current year.*/

select distinct d.forename,d.surname,c.name as team 
from F1_Project.dbo.drivers$ d
join F1_Project.dbo.results$ r on d.driverId = r.driverId
join F1_Project.dbo.constructors$ c on c.constructorId = r.constructorId
join F1_Project.dbo.races$ ra on r.raceId = ra.raceId 
where CONCAT(d.forename,' ',d.surname) IN 
('Lewis Hamilton', 'Fernando Alonso', 'Pierre Gasly', 'Nico Hülkenberg', 'Sergio Pérez', 'Daniel Ricciardo', 'Valtteri Bottas', 'Kevin Magnussen', 'Max Verstappen', 'Carlos Sainz', 'Esteban Ocon', 'Lance Stroll', 'Charles Leclerc', 'Lando Norris', 'George Russell', 'Alexander Albon', 'Yuki Tsunoda', 'Guanyu Zhou', 'Oscar Piastri', 'Logan Sargeant')
AND ra.year = 2023
order by c.name



----------------------------------------------------------------------------------------------------------------------

--Query 4: Constructors and Drivers having the same nationality

select distinct d.forename,d.surname,d.nationality ,c.name as team, c.nationality as TeamNationality
from F1_Project.dbo.drivers$ d
join F1_Project.dbo.results$ r on d.driverId = r.driverId
join F1_Project.dbo.constructors$ c on c.constructorId = r.constructorId
join F1_Project.dbo.races$ ra on r.raceId = ra.raceId 
where d.nationality = c.nationality
order by c.name



----------------------------------------------------------------------------------------------------------------------

--Query 5: All Circuits with max Constructors win i.e Which team won the most races at different circuits

/*For this query, I divided the data processing into three steps. First, I calculated the total wins 
for each constructor at each circuit, including the count of wins. Then, I created a separate query to 
determine the maximum number of wins for each circuit, resulting in a table with circuit IDs and their 
corresponding maximum wins. Finally, I combined these results to identify the constructor with the most 
wins at each circuit by joining the tables on circuit ID and the maximum wins. */

WITH CircuitWins AS (
SELECT c.circuitId,c.name, c.location, con.name AS constructor_name, COUNT(re.position) AS Wins
FROM F1_Project.dbo.circuits$ c
JOIN F1_Project.dbo.races$ r ON c.circuitId = r.circuitId
JOIN F1_Project.dbo.results$ re ON r.raceId = re.raceId
JOIN F1_Project.dbo.constructors$ con ON con.constructorId = re.constructorId
WHERE re.position = 1
GROUP BY c.circuitId, c.name, c.location, con.name
),
MaxWins as(
SELECT circuitId, MAX(Wins) AS MaxWins
FROM CircuitWins
GROUP BY circuitId
)
SELECT cw.circuitId, cw.name, cw.location, cw.Wins, cw.constructor_name
FROM CircuitWins cw
JOIN MaxWins mw ON cw.circuitId = mw.circuitId AND cw.Wins = mw.MaxWins
ORDER BY cw.circuitId;



----------------------------------------------------------------------------------------------------------------------

--Query 6: Top 5 Circuits Having Most Races

/*Simple Query showing top 5 circuits where most races are held from the beginning of Formula One*/

select top 5 name, count(circuitId) as MaxRacesAcrossGlobe
from  F1_Project.dbo.races$
group by name
order by MaxRacesAcrossGlobe desc



----------------------------------------------------------------------------------------------------------------------

--Query 7: Average position of each Driver in whichever race they finished and Constructor for a Particular year.

/* Here I have created two CTEs, the first one gets the races of 2022 and the second one gets the driver and driver positions using the two tables of driver and driver_standings. Then next in the main query I joined both to get the drivers, their positions in the race year that I filtered. Then I used COALESCE to replace NULL with 20th position so that the average comes out to be more accurate. And used the AVG function to find the average position of the drivers who raced in 2022 season.*/

with selected_races as(

select raceId
from F1_Project.dbo.races$
where year = 2022),

driver_pos as(
select a.raceId,a.driverId, CONCAT(c.forename, ' ', c.surname) AS fullname, a.position
from F1_Project.dbo.results$ a
join F1_Project.dbo.driver_standings$ b
on a.driverId = b.driverId
join F1_Project.dbo.drivers$ c on a.driverId = c.driverId)

select x.fullname, ROUND(AVG(COALESCE(x.position,20)),1) as avgr
from driver_pos x join selected_races y on x.raceId = y.raceId
group by x.fullname
order by avg_pos


/*Same approach as earlier one for constructors as well.*/

with selected_races2 as(

select raceId
from F1_Project.dbo.races$
where year = 2022),

constructor_pos as(

select a. raceId , a.constructorId,a.position
from F1_Project.dbo.constructor_standings$ a
)
select z.name, ROUND(AVG(COALESCE(x.position,2)),1) as avg_pos
from constructor_pos x 
join selected_races2 y  on x.raceId = y.raceId
join F1_Project.dbo.constructors$ z on x.constructorId = z.constructorId
group by z.name
order by avg_pos



----------------------------------------------------------------------------------------------------------------------

--Query 8: Fastest laps in all races from year 2021-2023

/* A slightly tricky query wherein I had to spend a lot of time. In the fast_laps CTE, the query identifies the fastest lap for each race by joining the lap times with the minimum lap times calculated per race. The ROW_NUMBER() function ranks the laps within each race, ensuring only the fastest lap is highlighted. The problem here is that lap time precision is not provided. Hence the laptimes are similar for lot of drivers. In the second CTE, races within a specific year range are selected. In the main query, these two CTEs are joined with the drivers table, and only the fastest laps (ranked as 1) are displayed.  */



WITH fast_laps AS (
    SELECT lt.raceId, lt.time AS fast_lap, lt.driverId,
           ROW_NUMBER() OVER (PARTITION BY lt.raceId ORDER BY lt.time) AS lap_rank
    FROM F1_Project.dbo.lap_times$ lt
    JOIN (
        SELECT raceId, MIN(time) AS min_time
        FROM F1_Project.dbo.lap_times$
        GROUP BY raceId
    ) AS min_lap 
	ON lt.raceId = min_lap.raceId AND lt.time = min_lap.min_time
),

select_races AS (
    SELECT raceId, name, year
    FROM F1_Project.dbo.races$ 
    WHERE year BETWEEN 2021 AND 2023
)

SELECT b.name, b.year, CONVERT(VARCHAR(12), fast_lap, 114) as fastest_lap , CONCAT(c.forename, ' ', c.surname) AS fullname
FROM fast_laps a 
JOIN select_races b ON a.raceId = b.raceId
JOIN F1_Project.dbo.drivers$ c ON a.driverId = c.driverId
WHERE a.lap_rank = 1
ORDER BY b.year;



----------------------------------------------------------------------------------------------------------------------

--Query 9: Top 5 drivers with most Podium Finishes

/*I executed a straightforward query linking the drivers to the result table to retrieve their positions and names. Then, I applied a filter to only include positions 1 through 3, representing podium finishes, sorted them, and narrowed down the list to the top 5 performers. */

select top 5 r.driverId, CONCAT(d.forename,' ',d.surname) as fullname, count(r.position) as podiums
from F1_Project.dbo.results$ r
join F1_Project.dbo.drivers$ d on r.driverId = d.driverId
where position between 1 and 3
group by r.driverId, CONCAT(d.forename,' ',d.surname)
order by podiums desc



----------------------------------------------------------------------------------------------------------------------

--Query 10 Listing All the races where a driver finished within a certain range. 

/* A query where I used CTEs to create CONCAT of first name and last name for a driver so that it is easier to find him. Next I join three tables using their respective primary keys and added the filter of position and driver.

*/

with drivers as(

select d.driverId, CONCAT(d.forename, ' ' ,d.surname) as fullname
from F1_Project.dbo.drivers$ d

)
select b.name, COALESCE (a.position,20) as position, b.year
from F1_Project.dbo.results$ a
join F1_Project.dbo.races$ b 
on a.raceId = b.raceId
join drivers c
on a.driverId = c.driverId
where c.fullname = 'Lewis Hamilton'
and a.position between 1 and 10 



----------------------------------------------------------------------------------------------------------------------

--Query 11: Identifying Races of a particular year where Pole Position did not win

/*I started by filtering out races and drivers who secured the pole position but didn't win (position 1). After that, joined this filtered dataset with the races and drivers to include their names, using raceId and driverId.*/

with new_res as(
select x.raceId, driverId,position as race_pos,grid as starting_pos
from F1_Project.dbo.results$ x
join F1_Project.dbo.races$ y on x.raceId = y.raceId
where grid = 1 and position !=grid
and y.year =2022
)
select distinct b.name, b.year, CONCAT(c.forename, ' ' ,c.surname) as pole_sitter
from new_res a
join F1_Project.dbo.races$ b on a.raceId = b.raceId
join F1_Project.dbo.drivers$ c on a.driverId = c.driverId




select * from PoleSittersNotWinners_2022




----------------------------------------------------------------------------------------------------------------------

--Query 12: Find drivers with most fastst lap in a single Race (Silverstone or British GP)

/*A view was created to list all drivers with the fastest lap times along with the names of the races where they achieved these times. This view was then joined with the races and drivers tables to filter and display specific races.*/

CREATE VIEW fast_laps as
SELECT raceId, driverId, lap, time
FROM (
    SELECT raceId, 
           driverId, 
           lap, 
           time,
           ROW_NUMBER() OVER (PARTITION BY raceId ORDER BY time) AS rank1
    FROM F1_Project.dbo.lap_times$
) AS ranked_laps
WHERE rank1 = 1


SELECT CONCAT(c.forename, ' ', c.surname) AS driver, COUNT(b.name) AS race_count
FROM fast_laps AS a
JOIN F1_Project.dbo.races$ b ON a.raceId = b.raceId
JOIN F1_Project.dbo.drivers$ c ON a.driverId = c.driverId
where b.name = 'British Grand Prix'
GROUP BY CONCAT(c.forename, ' ', c.surname)
ORDER BY race_count DESC;



----------------------------------------------------------------------------------------------------------------------

--Query 13: Identifying Races with the Highest Number of Issues and Associating them with Race Details.

/*Utilizing a view named 'newraces', the query aggregates race information including race IDs, names, years, and associated status IDs along with the count of issues encountered during each race. By leveraging this view and employing ranking functions, the query identifies races with the highest count of issues. Subsequently, it presents a refined dataset showcasing race names, years, issue counts, and their corresponding statuses. This approach allows for the identification and analysis of races marked by significant issues, offering valuable insights into their characteristics. */

WITH newraces AS (
    SELECT a.raceId, b.name, b.year, c.statusId, COUNT(c.statusId) AS Issues
    FROM F1_Project.dbo.results$ a
    JOIN F1_Project.dbo.races$ b ON a.raceId = b.raceId
    JOIN F1_Project.dbo.status$ c ON c.statusId = a.statusId
    WHERE a.statusId != 1
    GROUP BY a.raceId, b.name, b.year, c.statusId
)
SELECT name, year, Issues, status
FROM (
    SELECT name, year, Issues, 
           RANK() OVER (PARTITION BY name ORDER BY Issues DESC) AS Max_issues, statusId
    FROM newraces
) ranked_races
JOIN F1_Project.dbo.status$ c ON ranked_races.statusId = c.statusId 
WHERE Max_issues = 1
ORDER BY Issues desc;


