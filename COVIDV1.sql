--Select *
--From CovidVaccinations

SELECT location, continent
FROM CovidDeaths
WHERE continent is null


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths




-- Total cases v. total Deaths
-- Percentage of likelihood of dying if you contract covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
Where location like '%states%'





-- Total cases v. Population
-- Percentage of population that got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM CovidDeaths
Where location like '%states%'


-- Countries w highest infection rates compare to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
GROUP BY location, population
--GROUP BY population, location
ORDER BY PercentagePopulationInfected DESC


-- Countries highest Death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Continents highest Death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global counts

--
SELECT date, SUM(new_cases)as GlobalCasesPerDay
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date DESC

--View for global count
CREATE VIEW GlobalCasesPerDay as
SELECT date, SUM(new_cases)as GlobalCasesPerDay
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date



-- Global Death percentage by date
SELECT date, SUM(new_cases)as GlobalCasesPerDay, SUM(cast(new_deaths as int))as GlobalDeathsPerDay, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date 

-- Global Death percentage total
SELECT SUM(new_cases)as GlobalCasesPerDay, SUM(cast(new_deaths as int))as GlobalDeathsPerDay, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
--GROUP BY date
--ORDER BY date 


-- Joining both tables & total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
Order by vac.new_vaccinations DESC

 

-- 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order by vac.new_vaccinations DESC
Order By 2,3

--Using CTE
WITH PopulationVsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order by vac.new_vaccinations DESC
--Order By 2,3
)

SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopulationVsVac



--Using TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order by vac.new_vaccinations DESC
--Order By 2,3
SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated





--CREATING VIEW to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--Order by vac.new_vaccinations DESC
--Order By 2,3
