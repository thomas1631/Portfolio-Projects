/*
Covid 19 Data Exploration (MySQL WorkBench)
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select *
From CovidDeaths
Where continent is not null 
order by 3,4;

-- Select Data that we are going to be starting with
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
WHERE continent IS NOT NULL AND continent != ''
order by 1,2;

-- Total Cases vs Total Deaths (in the US)
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
and continent IS NOT NULL AND continent != ''
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in the US
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%states%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
SELECT 
    Location,
    MAX(CAST(Total_deaths AS SIGNED)) AS TotalDeathCount
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL 
    AND continent != ''
GROUP BY 
    Location
ORDER BY 
    TotalDeathCount DESC;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as SIGNED)) AS TotalDeathCount
From coviddeaths
WHERE continent is not null AND continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, 
       SUM(cast(new_deaths as SIGNED)) as total_deaths, 
       SUM(cast(new_deaths as SIGNED))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 (SELECT SUM(CONVERT(new_vaccinations, SIGNED))
     FROM CovidDeaths.CovidVaccinations 
     WHERE location = dea.location
     AND date <= dea.date
    ) AS RollingPeopleVaccinated
FROM CovidDeaths.CovidDeaths dea
JOIN CovidDeaths.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent != '' -- Specify table alias for continent
ORDER BY 2, 3;

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        CovidDeaths.CovidDeaths dea
    JOIN 
        CovidDeaths.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL 
)
SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS PercentagePopulationVaccinated
FROM 
    PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM 
        CovidDeaths.CovidDeaths dea
    JOIN 
        CovidDeaths.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
);

SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100 AS PercentagePopulationVaccinated
FROM 
    PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeaths.CovidDeaths dea
JOIN 
    CovidDeaths.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

