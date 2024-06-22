SELECT * from CoronaVirusDataset;

-- Add a new column named 'dates' to the table 'CoronaVirusDataset'
ALTER TABLE CoronaVirusDataset ADD dates DATE;

-- Update the 'dates' column by converting the 'date' column to the DATE data type
UPDATE CoronaVirusDataset 
SET dates = CONVERT(DATE, SUBSTRING(date, 7, 4) + '-' + SUBSTRING(date, 4, 2) + '-' + SUBSTRING(date, 1, 2));

-- Drop the old 'date' column
ALTER TABLE CoronaVirusDataset DROP COLUMN date;

-- Rename the 'dates' column to 'date'
EXEC sp_rename 'CoronaVirusDataset.dates', 'date', 'COLUMN';


-- Q1. Write a code to check NULL values
SELECT * FROM CoronaVirusDataset
WHERE Province IS NULL OR [country/region] IS NULL OR latitude IS NULL OR longitude IS NULL  OR date IS NULL 
OR confirmed IS NULL  OR deaths IS NULL  OR recovered IS NULL  ;

--Q2. If NULL values are present, update them with zeros for all columns.
UPDATE CoronaVirusDataset
SET Province = COALESCE(Province, '0'),
    [country/region] = COALESCE([country/region], '0'),
    latitude = COALESCE(latitude, 0),
    longitude = COALESCE(longitude, 0),
    date = COALESCE(date, '0'), 
    confirmed = COALESCE(confirmed, 0),
    deaths = COALESCE(deaths, 0),
    recovered = COALESCE(recovered, 0)
WHERE Province IS NULL OR [country/region] IS NULL OR latitude IS NULL OR longitude IS NULL 
    OR date IS NULL OR confirmed IS NULL OR deaths IS NULL OR recovered IS NULL;
    
 -- Q3. check total number of rows
 SELECT COUNT(*)  Total_Rows FROM CoronaVirusDataset
 
 -- Q4. Check what is start_date and end_date
SELECT MIN(date) AS start_date,max(date) as end_date
FROM CoronaVirusDataset;


-- Q5. Number of month present in dataset
SELECT count(DISTINCT month(date)) as num_month
from CoronaVirusDataset;

-- Q6. Find monthly average for confirmed, deaths, recovered
SELECT FORMAT(Date,'yyyy-MM') as month,
    AVG(confirmed) as avg_confirmed, 
    AVG(deaths) as avg_deaths, 
    AVG(recovered) as avg_recovered
FROM CoronaVirusDataset
GROUP BY FORMAT(Date,'yyyy-MM')
ORDER BY month;

-- Q7. Find most frequent value for confirmed, deaths, recovered each month 
WITH MonthlyCounts AS (
    SELECT 
        YEAR(date) AS year,MONTH(date) AS month,confirmed,deaths,recovered,
        COUNT(*) AS count_cases,
        ROW_NUMBER() OVER (PARTITION BY YEAR(date), MONTH(date) ORDER BY COUNT(*) DESC) AS rn
    FROM  CoronaVirusDataset
    GROUP BY  YEAR(date), MONTH(date), confirmed, deaths, recovered
)
SELECT  year, month,confirmed,deaths, recovered
FROM MonthlyCounts
WHERE 
    rn = 1
ORDER BY 
    year, month;
    
    
    
 -- Q8. Find minimum values for confirmed, deaths, recovered per year
SELECT 
    YEAR(date) AS Years,
    MIN(confirmed) AS min_confirmed,
    MIN(deaths) AS min_deaths,
    MIN(recovered) AS min_recovered
FROM 
    CoronaVirusDataset
GROUP BY 
    YEAR(date);
    
    
-- Q9. Find maximum values of confirmed, deaths, recovered per year
select year(date) AS Years,
       max(confirmed) max_confirmed,
       max(deaths) max_deaths,
       max(recovered) max_recovered
FROM CoronaVirusDataset
GROUP by year(date)
order by 1;

-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT month(date) AS month, year(date) as year,
       sum(confirmed) as total_confirmed,
       sum(deaths) as total_deaths,
       sum(recovered) as total_recovered
FROM CoronaVirusDataset
GROUP BY month(date) , year(date)
order by 2,1;


-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
       SUM(confirmed) AS total_confirmed,
       AVG(confirmed) AS avg_confirmed,
       VAR(confirmed) AS variance_confirmed_cases,
       STDEV(confirmed) AS stdev_confirmed_cases
FROM CoronaVirusDataset;

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT year(date) as year,
	   month(date) AS month,
       SUM(deaths) AS total_deaths,
       SUM(confirmed) AS total_confirmed,
       AVG(deaths) AS avg_deaths,
       VAR(deaths) AS variance_death,
       STDEV(deaths) AS stdev_death_cases
FROM CoronaVirusDataset
GROUP BY month(date),year(date)
order by 1,2;

-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT year(date) as year,
	   month(date) AS month,
       SUM(recovered) AS total_recovered,
       SUM(confirmed) AS total_confirmed,
       AVG(recovered) AS avg_recovered,
      VAR(recovered) AS variance_recovered_cases,
      STDEV(recovered) AS stdev_recovered_cases
FROM CoronaVirusDataset
GROUP BY month(date),year(date)
order by 1,2;

-- Q14. Find Country having highest number of the Confirmed case
select [country/region], sum(confirmed) as total_confirmed
from CoronaVirusDataset
GROUP By [country/region]
HAVING sum(confirmed) = (
  select max(total_confirmed) 
  from (
		SELECT sum(confirmed) as total_confirmed
		FROM CoronaVirusDataset
		GROUP By [country/region]) temp
);

-- Q15. Find Country having lowest number of the death case
select [country/region], sum(deaths) as total_deaths
from CoronaVirusDataset
GROUP By [country/region]
HAVING sum(deaths) = (
  select min(total_deaths) 
  from (
		SELECT sum(deaths) as total_deaths
		FROM CoronaVirusDataset
		GROUP By [country/region]) temp
);

-- Q16. Find top 5 countries having highest recovered case
SELECT TOP 5 [country/region], SUM(recovered) as Total_recovered
FROM CoronaVirusDataset
GROUP BY [country/region]
ORDER BY Total_recovered DESC;





    
    
    










