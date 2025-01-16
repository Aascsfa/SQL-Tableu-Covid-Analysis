-- Exploration of COVID-19 Data

-- 1. Basic Exploration
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Death.`coviddeaths_1(coviddeaths)`
ORDER BY date;

-- 2. Case vs. Deaths Analysis
-- Calculates the likelihood of dying if you contract COVID-19 in the United States.
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM Covid_Death.`coviddeaths_1(coviddeaths)`
WHERE location = 'United States'
ORDER BY date;

-- 3. Total Cases vs. Population Impact
-- Analyzes the percentage of the population impacted by COVID-19 in the United States.
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS impact_percentage
FROM Covid_Death.`coviddeaths_1(coviddeaths)`
WHERE location = 'United States'
ORDER BY date;

-- 4. Countries with the Highest Infection Rate
SELECT location, population, MAX(total_cases) AS max_total_cases, ROUND(MAX((total_cases / population) * 100), 2) AS impact_percentage
FROM Covid_Death.`coviddeaths_1(coviddeaths)`
GROUP BY location, population
ORDER BY impact_percentage DESC;

-- 5. Countries with the Highest Death Count
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM Covid_Death.`coviddeaths_1(coviddeaths)`
 GROUP BY location
ORDER BY TotalDeathCount DESC;

-- 6. Continent-wise Deaths
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM Covid_Death.`coviddeaths_1(coviddeaths)`
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 7. Global Impact Analysis
SELECT date, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_new_deaths, (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM Covid_Death.`coviddeaths_1(coviddeaths)`
GROUP BY date
ORDER BY date DESC;

-- 8. Rolling Vaccination Analysis
SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations,
    SUM(CAST(c.new_vaccinations AS SIGNED)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM Covid_Death.`coviddeaths_1(coviddeaths)` d
JOIN Covid_Death.covidvaccin c ON d.location = c.location AND d.date = c.date
ORDER BY d.location, d.date;

-- 9. Population vs. Vaccination Analysis Using CTE
WITH PopvsVac AS (
    SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations,
        SUM(CAST(c.new_vaccinations AS SIGNED)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
    FROM Covid_Death.`coviddeaths_1(coviddeaths)` d
    JOIN Covid_Death.covidvaccin c ON d.location = c.location AND d.date = c.date
)
SELECT *, (rolling_vaccinated / population) * 100 AS vac_percentage FROM PopvsVac;

-- 10. Create a View for Population vs. Vaccination Analysis
USE Covid_Death;

CREATE VIEW PercentPop AS
SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations,
    SUM(CAST(c.new_vaccinations AS SIGNED)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinated
FROM Covid_Death.`coviddeaths_1(coviddeaths)` d
JOIN Covid_Death.covidvaccin c ON d.location = c.location AND d.date = c.date;

-- Query the View
SELECT * FROM Covid_Death.PercentPop;
