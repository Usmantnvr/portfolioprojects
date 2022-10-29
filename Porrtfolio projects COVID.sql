SELECT *
FROM [Portfolio project I].[dbo].[COVID deaths]
ORDER BY 3,4



SELECT *
FROM [Portfolio project I].[dbo].[COVID vaccines]

--Select data that we will be using

SELECT location,date,total_cases,new_cases,total_deaths,population
from [Portfolio project I].[dbo].[COVID deaths]
ORDER BY 1,2

--Looking at total cases vs total deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_rate
from [Portfolio project I].[dbo].[COVID deaths]
ORDER BY 1,2 DESC

--Looking at total cases vs total deaths in Pakistan
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_rate_percentage
from [Portfolio project I].[dbo].[COVID deaths]
WHERE location LIKE '%Pakistan%'
ORDER BY 1,2 DESC

--Looking at total cases vs population in Pakistan 
SELECT location,date,total_cases,population,(total_cases/population)*100 AS population_percentage
from [Portfolio project I].[dbo].[COVID deaths]
WHERE location LIKE '%Pakistan%'
ORDER BY 1,2 

--Looking at Highest infection count vs population in Pakistan 
SELECT location,population,MAX(total_cases) AS Highest_infection_count,MAX((total_cases/population))*100 AS population_percentage
FROM [Portfolio project I].[dbo].[COVID deaths]
GROUP BY location,population
ORDER BY population_percentage DESC

--Countries with highhest death count

SELECT location,MAX(CAST(total_deaths AS INT)) AS Highest_infection_count
FROM [Portfolio project I].[dbo].[COVID deaths]
WHERE continent is not null
GROUP BY location
ORDER BY Highest_infection_count DESC

--Countries with highest death count by continent
SELECT continent,MAX(CAST(total_deaths AS INT)) AS Highest_infection_count
FROM [Portfolio project I].[dbo].[COVID deaths]
--WHERE continent is not null
GROUP BY continent
ORDER BY Highest_infection_count DESC

SELECT location,MAX(CAST(total_deaths AS INT)) AS Highest_infection_count
FROM [Portfolio project I].[dbo].[COVID deaths]
WHERE continent is  null
GROUP BY location
ORDER BY Highest_infection_count DESC

--Showing continents with the highest death counts per population
SELECT continent,population,MAX(CAST(total_deaths AS INT)) AS Highest_infection_count,MAX(CAST(total_deaths AS INT)/population)*100 AS DeathCountsPerPopulation
FROM [Portfolio project I].[dbo].[COVID deaths]
GROUP BY continent,population
ORDER BY DeathCountsPerPopulation DESC

--Global numbers
SELECT date, SUM(total_cases) AS Total_cases,SUM(Cast(total_deaths AS INT))as Total_deaths,SUM(CAST(total_deaths AS INT))/SUM(total_cases)*100 as Death_percentage
FROM [Portfolio project I].[dbo].[COVID deaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS Total_cases,SUM(Cast(new_deaths AS INT))as Total_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as Death_percentage
FROM [Portfolio project I].[dbo].[COVID deaths]
WHERE continent is not null
--GROUP BY total_deaths
ORDER BY 1,2


-Joining table

SELECT *
FROM [Portfolio project I]..[COVID deaths] dea
JOIN [Portfolio project I]..[COVID Vaccines] Vac
ON dea.location=vac.location
AND dea.date=vac.date

--Looking at total population vs Vaccianations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM [Portfolio project I]..[COVID deaths] dea
JOIN [Portfolio project I]..[COVID Vaccines] Vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
WHERE 
ORDER BY 2,3

SELECT *
FROM [Portfolio project I]..[COVID Vaccines]



SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  
AS Rollingpeoplevaccinated
FROM [Portfolio project I]..[COVID deaths] dea
JOIN [Portfolio project I]..[COVID Vaccines] Vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--With CTE:
With PopvsVac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  
FROM [Portfolio project I]..[COVID deaths] dea
JOIN [Portfolio project I]..[COVID Vaccines] Vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

)
SELECT *, (Rollingpeoplevaccinated/population)*100 as PeopleVaccinated
FROM PopvsVac

--Creating Temp Table
DROP TABLE IF EXISTS #temp_Populationversusvaccination 
CREATE TABLE #temp_Populationversusvaccination 
(
Continent nvarchar (255), 
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO #temp_Populationversusvaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date)  
FROM [Portfolio project I]..[COVID deaths] dea
JOIN [Portfolio project I]..[COVID Vaccines] Vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *
FROM #temp_Populationversusvaccination


--Create views for visualization

DROP  VIEW IF EXISTS Populationversusvaccination
CREATE VIEW Populationversusvaccination AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) Rollingpeoplevaccinated 
FROM [Portfolio project I]..[COVID deaths] dea
JOIN [Portfolio project I]..[COVID Vaccines] Vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null 


