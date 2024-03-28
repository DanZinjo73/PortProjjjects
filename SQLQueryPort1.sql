SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data That we're going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Ukraine

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ukraine%'
ORDER BY 1,2

-- Looking  at total cases vs population

SELECT location, date, total_cases, population, (CAST(total_cases AS float)/CAST(population AS float))*100 AS DiseasePercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
ORDER BY 1,2

--Looking at countries with Highest Infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectCount, (MAX(total_cases)/population)*100 AS DiseasePercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
GROUP by population, location
ORDER BY DiseasePercentage desc

--Showing Countries with Highest death count per population

SELECT location, population, MAX(total_deaths) as HighestDeathCount, (MAX(total_deaths)/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
WHERE continent is not NULL
GROUP by population, location
ORDER BY DeathPercentage desc


SELECT location, population, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
WHERE continent is not NULL
GROUP by population, location
ORDER BY HighestDeathCount desc

--Let's break things down by continent??

SELECT continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY HighestDeathCount desc

-- Showing continents with highest deaths count

SELECT location, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY HighestDeathCount desc


--Global numbers

SELECT date, SUM(CAST(new_cases_smoothed as float)), SUM(CAST(new_deaths_smoothed as float)), SUM(CAST(new_deaths_smoothed as float))/SUM(CAST(new_cases_smoothed as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states'
WHERE continent is not NULL
GROUP by date
ORDER BY 1, 2

--SELECT date, location, SUM(CAST(new_cases as int)), SUM(CAST(new_deaths as int))
--FROM PortfolioProject..CovidDeaths
------WHERE location LIKE '%states'
--WHERE continent is not NULL
--GROUP by location, date
--ORDER BY 1, 2 desc

--Looking at total population vs vaccinations

--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location 
--ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, --(RollingPeopleVaccinated/population)*100
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

WITH CTE_RollingPeopleVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM CTE_RollingPeopleVaccinated

--GROUP BY location

--SELECT *
--FROM CTE_RollingPeopleVaccinated
----GROUP BY location

--Temp table

DROP TABLE IF EXISTS #PercentPopulationsVaccinated
CREATE TABLE #PercentPopulationsVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationsVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationsVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM [PortfolioProject].[dbo].PercentPopulationVaccinated

