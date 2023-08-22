SELECT TOP(1000) *
FROM COVIDVaccination
WHERE continent IS NOT NULL
ORDER BY 3,4 DESC;

SELECT TOP(1000) *
FROM CovidDeaths
ORDER BY 3,4 DESC;


SELECT location, date, total_cases, new_cases, Total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths

SELECT location, date, total_cases AS TotalCases, total_deaths AS TotalDeaths, ((CAST(total_deaths AS real)/CAST(total_cases AS real))*100 ) AS DeathRatePerCases
FROM CovidDeaths
WHERE date LIKE '2023-08-01' AND continent IS NOT NULL
ORDER BY 5 DESC

--IN THE 1ST AUGUST 2023 YEMEN HAS THE HIGHEST DEATH RATE PER CASES OF 18% FROM A TOTAL OF 11945 CASES
--Morocco has a fatality rate of only 1,28% in Aug, 2023

SELECT location, date, total_cases AS TotalCases, total_deaths AS TotalDeaths, ((CAST(total_deaths AS real)/CAST(total_cases AS real))*100 ) AS DeathRatePerCases
FROM CovidDeaths
WHERE date LIKE '2023-08-01' AND location = 'Morocco' AND continent IS NOT NULL
ORDER BY 5 DESC;

--Looking at total cases vs population
--Infection Rate on the total population
--The infection rate in Morocco was around 3.4% on August 1, 2023.
SELECT location, population, MAX(CAST(total_cases AS INT)) AS TotalCases, (MAX((CAST(total_cases AS real)/CAST(Population AS real))*100 )) AS InfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
--HAVING location = 'Morocco'
ORDER BY 4 DESC

-- Showing countries with highest Death count per population
--Morocco has a mortality count of 16297 Person in Aug,2023
--US has the highest number of deaths count
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--HAVING location = 'Morocco'
ORDER BY 2 DESC

---Deaths count per continent

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
--HAVING location = 'Morocco'
ORDER BY 2 DESC

--GLOBAL NUMBERS
--It shows the number of new cases and new deaths globally each day
SELECT date, 
SUM(CAST(new_cases AS INT)) AS RunningTotalOfCases,
SUM(CAST(new_Deaths AS INT)) AS RunningTotalOfDeaths, 
--SUM(SUM(new_deaths)/SUM(new_cases))
(SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100) AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1 DESC;

--Total cases and deaths in the world

SELECT  SUM(CAST(new_cases AS INT)) AS RunningTotalOfCases,
SUM(CAST(new_Deaths AS INT)) AS TotalOfDeaths, 
--SUM(SUM(new_deaths)/SUM(new_cases))
(SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100) AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1 DESC;

--Joining the two tables

SELECT * 
FROM CovidDeaths dea
JOIN COVIDVaccination vac
ON dea.location = vac.location AND dea.date=vac.date

SELECT CAST(new_vaccinations AS INT) FROM COVIDVaccination

-- Total vaccinated population

SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(NULLIF(CAST(vac.new_vaccinations AS NUMERIC),0))
		OVER (PARTITION BY dea.location ORDER BY dea.date) AS TotalVaccinated
FROM CovidDeaths dea
	JOIN COVIDVaccination vac
		ON dea.location = vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- use CTE to calcute the ratio of the running total of the vaccinated population on the total population

WITH PopVsVac (Continent, location,date, population, new_vaccination, TotalVaccinated)
AS
(SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(NULLIF(CAST(vac.new_vaccinations AS NUMERIC),0))
		OVER (PARTITION BY dea.location ORDER BY dea.date) AS TotalVaccinated
FROM CovidDeaths dea
	JOIN COVIDVaccination vac
		ON dea.location = vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL)
--ORDER BY 2,3)
SELECT *, (TotalVaccinated/population)*100 AS VaccinationRatio
FROM PopVsVac


-- Creating a view

CREATE VIEW DailyRunningTotal AS
SELECT date, 
SUM(CAST(new_cases AS INT)) AS RunningTotalOfCases,
SUM(CAST(new_Deaths AS INT)) AS RunningTotalOfDeaths, 
--SUM(SUM(new_deaths)/SUM(new_cases))
(SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100) AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date

--Create view for total death count per country

CREATE VIEW TotalDeathCountPerCountry AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--HAVING location = 'Morocco'

CREATE VIEW GlobalInfectionRate AS
SELECT location, population, MAX(CAST(total_cases AS INT)) AS TotalCases, (MAX((CAST(total_cases AS real)/CAST(Population AS real))*100 )) AS InfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
--HAVING location = 'Morocco'
--ORDER BY 4 DESC