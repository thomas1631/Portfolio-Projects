/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * 
FROM coviddeaths.coviddeaths;
Where continent is not null
Order by 3, 4

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
From coviddeaths.coviddeaths
Where continent is not null
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From coviddeaths.coviddeaths
Where location like'%states'
and continent is not null
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulatopnInfested
From coviddeaths.coviddeaths
Where location like'%states'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCounty, MAX(total_cases/population)*100 as PercentPopulatopnInfested
From coviddeaths.coviddeaths
Group by Location,Population
order by PercentPopulatopnInfested desc

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CONVERT(Total_deaths, UNSIGNED)) AS TotalDeathCount
From coviddeaths.coviddeaths
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CONVERT(Total_deaths, UNSIGNED)) AS TotalDeathCount
From coviddeaths.coviddeaths
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT
  SUM(new_cases) AS total_cases,
  SUM(CONVERT(new_deaths, SIGNED)) AS total_deaths,
  SUM(CONVERT(new_deaths,SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
  CovidDeaths.CovidDeaths
WHERE
  continent IS NOT NULL
ORDER BY
 1, 2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths.CovidDeaths dea
JOIN coviddeaths.CovidVaccinations vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;



-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
  FROM
    coviddeaths.CovidDeaths dea
  JOIN
    coviddeaths.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
  Continent VARCHAR(255),
  Location VARCHAR(255),
  Date DATE,
  Population DECIMAL,
  New_vaccinations DECIMAL,
  RollingPeopleVaccinated DECIMAL
);

INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations)
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations
FROM
  coviddeaths.CovidDeaths dea
JOIN
  coviddeaths.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
  NOT vac.new_vaccinations REGEXP '^[0-9]+$';

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths.CovidDeaths dea
JOIN coviddeaths.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


