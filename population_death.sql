use portpolio_world
go

-- FIRST TO SHOW ALL TABLES
select * from ['annual-number-of-deaths-by-caus']
select * from ['number-of-deaths-by-age-group$']
select * from ['population-and-demography$']
select * from ['population-density$']

-- TO SEE THE CURRENT POPULATION IN EACH COUNTRY
select [Country name], max (Population) as 'current_population'
from ['population-and-demography$']
group by [Country name]
order by [Country name] 

-- TO SEE THE POPULATION IN EACH COUNTRY AT YEAR 2019
select [Country name], Population as '2019_population'
from ['population-and-demography$']
WHERE YEAR = 2019
order by [Country name] 

-- TO SEE THE TOTAL SUM OF DEATH IN EACH COUNTRY IN 2019
SELECT Entity, ([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) AS Total_Death 
FROM ['number-of-deaths-by-age-group$']
WHERE YEAR = 2019


-- SHOWING THE CONTINENT WITH THE HIGEST DEATH COUNT
SELECT Entity, ([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) AS Total_Death 
FROM ['number-of-deaths-by-age-group$']
WHERE YEAR = 2019
ORDER BY Total_Death DESC

-- now I want to see only countries and not regions
/*
select distinct Entity , Code
from ['number-of-deaths-by-age-group$']
*/
SELECT Entity, ([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) AS Total_Death 
FROM ['number-of-deaths-by-age-group$']
WHERE YEAR = 2019
	and code is not null
	and Entity != 'world'
ORDER BY Total_Death DESC


-- I want to see in which country the Death percentage is highest
/* select * from ['number-of-deaths-by-age-group$']
 select * from ['population-and-demography$']
 */


select [country name],Population,([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) AS Total_Death 
, (([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) / Population) * 100 as Death_percentage
from ['population-and-demography$']  population_life
 join ['number-of-deaths-by-age-group$'] population_death
on population_life.[Country name] = population_death.Entity
WHERE population_life.YEAR = 2019
	and population_death.Year = 2019
	and population_death.code is not null
	and population_death.Entity != 'world'
order by Death_percentage desc

-- better way is using a CTE
with TotalDeath ([country name],Population,Total_Death)
as 
(
select [country name],Population,([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) AS Total_Death 
from ['population-and-demography$']  population_life
 join ['number-of-deaths-by-age-group$'] population_death
on population_life.[Country name] = population_death.Entity
WHERE population_life.YEAR = 2019
	and population_death.Year = 2019
	and population_death.code is not null
	and population_death.Entity != 'world'
)
select *, (Total_Death / Population)*100 as Death_percentage
from TotalDeath


-- now I want to see the population density in compared to to the death percentage. 
create view density_death as
  select [country name],Population,([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) AS Total_Death ,
  (([Deaths - All causes - Sex: Both - Age: 15-49 years (Number)]+ [Deaths - All causes - Sex: Both - Age: 50-69 years (Number)]+[Deaths - All causes - Sex: Both - Age: 5-14 years (Number)]+[Deaths - All causes - Sex: Both - Age: 70+ years (Number)]+[Deaths - All causes - Sex: Both - Age: Under 5 (Number)]) / Population)*100 as Death_percentage
from ['population-and-demography$']  population_life
 join ['number-of-deaths-by-age-group$'] population_death
on population_life.[Country name] = population_death.Entity
JOIN ['population-density$'] PD
 on population_life.[country name] = PD.Entity
WHERE population_life.YEAR = 2019
	and population_death.Year = 2019
	and population_death.code is not null
	and population_death.Entity != 'world'
	and pd.Year = 2019
 ---order by population_density
 
 select * from density_death