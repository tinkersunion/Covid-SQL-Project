SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid-19 (by country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Looking at Total Cases Vs Population
-- Show's what percentage of population contracted covid-19

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Contracted_Pop_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Contracted_Pop_Percentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY Contracted_Pop_Percentage DESC

-- Looking at Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as INT)) AS Total_Death_Count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Let's break things down by continent

SELECT location, MAX(CAST(total_deaths as INT)) AS Total_Death_Count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as INT)) AS Total_Death_Count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- GLOBAL NUMBERS BY DATE

SELECT date, SUM(new_cases) AS Global_New_Cases, SUM(CAST(new_deaths AS INT)) AS Global_New_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Global_Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS SUM (AS OF MARCH 21ST 2022)

SELECT SUM(new_cases) AS Global_New_Cases, SUM(CAST(new_deaths AS INT)) AS Global_New_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Global_Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS d
JOIN PortfolioProject.dbo.CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3

-- Using a CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)

AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS d
JOIN PortfolioProject.dbo.CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS percent_pop_vaccinated
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS d
JOIN PortfolioProject.dbo.CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS percent_pop_vaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization

CREATE View PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS d
JOIN PortfolioProject.dbo.CovidVaccinations AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null