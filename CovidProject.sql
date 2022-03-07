Select *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Slovakia'
AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
--Where location = 'Slovakia'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
--Where location = 'Slovakia'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY InfectionRate DESC


-- Showing Countries with Highest Death Count per Popuplation

Select location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location = 'Slovakia'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let`s break things down by continent
--This is right
Select location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location = 'Slovakia'
WHERE continent IS NULL AND location NOT LIKE '%income'
GROUP BY location
ORDER BY TotalDeathCount DESC

--This was used in the tutorial

Select continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location = 'Slovakia'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

Select  date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

Select  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, CAST(dea.location AS NVARCHAR(30)), CAST(dea.date AS DATE), dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY CAST(dea.location AS NVARCHAR(30)) ORDER BY CAST(dea.location AS NVARCHAR(30)), 
CAST(dea.date AS DATE)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, CAST(dea.location AS NVARCHAR(30)), CAST(dea.date AS DATE), dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY CAST(dea.location AS NVARCHAR(30)) ORDER BY CAST(dea.location AS NVARCHAR(30)), 
CAST(dea.date AS DATE)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated  -- If we want to make any changes in this query in the future
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(30),
Location nvarchar(30),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, CAST(dea.location AS NVARCHAR(30)), CAST(dea.date AS DATE), dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY CAST(dea.location AS NVARCHAR(30)) ORDER BY CAST(dea.location AS NVARCHAR(30)), 
CAST(dea.date AS DATE)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select dea.continent, CAST(dea.location AS NVARCHAR(30)) As Location, CAST(dea.date AS DATE) AS Date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY CAST(dea.location AS NVARCHAR(30)) ORDER BY CAST(dea.location AS NVARCHAR(30)), 
CAST(dea.date AS DATE)) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
