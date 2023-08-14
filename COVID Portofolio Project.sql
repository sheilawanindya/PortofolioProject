SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--order by 3,4

-- Select Data That We Are Going To Be Using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Death 
-- Show likelihood of Dying If You Contract Covid in a Country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%indonesia%'
ORDER BY 1,2

-- Looking at the Total Cases VS Population
-- Shows What percentage of Population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCountry, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortofolioPtoject..CovidDeaths
--WHERE location LIKE '%state%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count / Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioPtoject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- SHOWING CONTINENT WITH HIGHEST DEATH COUT / POPULATION

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioPtoject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS Total_Death, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioPtoject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- WITHOUT DATE
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS Total_Death, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioPtoject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



SELECT * 
FROM PortofolioPtoject..CovidDeaths dea
JOIN PortofolioPtoject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATION 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortofolioPtoject..CovidDeaths dea
JOIN PortofolioPtoject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--ROLLING NEW VAC COUNT , (CONVERT = CAST)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioPtoject..CovidDeaths dea
JOIN PortofolioPtoject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- TOTAL POPULATION VS VACCINATED, USING CTE
--COMMAND (RollingPeopleVaccinated/population)*100 won't work since rollingpeople table has just been created. hence the CTE.

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioPtoject..CovidDeaths dea
JOIN PortofolioPtoject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioPtoject..CovidDeaths dea
JOIN PortofolioPtoject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- ALTERATING DATA / DROP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioPtoject..CovidDeaths dea
JOIN PortofolioPtoject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioPtoject..CovidDeaths dea
JOIN PortofolioPtoject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated