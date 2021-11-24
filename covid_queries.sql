-- 0. Check the imported data

SELECT 
FROM Portfolio_Project..covid_deaths_update

SELECT *
FROM Portfolio_Project..covid_vaccinations_update

-- 1. Total Cases vs Population (By Date)
--    What % of the population has been infected with Covid-19 

SELECT 
  location,
  date,
  population,
  total_cases,
  total_deaths,
  ROUND(((total_cases / population) * 100), 2) AS percentage_population_infected
FROM Portfolio_Project..covid_deaths_update
--WHERE location LIKE '%Ireland%'
ORDER BY location, date

-- 2. Total Cases vs Total Deaths (By Date)
--    What % of people infected with Covid-19 have passed away

SELECT 
  location,
  date,
  total_cases,
  total_deaths,
  ROUND(((total_deaths / total_cases) * 100), 2) AS death_percentage
FROM Portfolio_Project..covid_deaths_update
--WHERE location LIKE '%Spain%'
ORDER BY location, date

-- 3. Highest Infection Rates (in Total)
--    What countries have the highest infection rates compared to their population

SELECT 
  location,
  population,
  MAX(total_cases) AS total_cases,
  ROUND(MAX(total_cases) / population * 100, 2) AS percentage_population_infected
FROM Portfolio_Project..covid_deaths_update
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_population_infected DESC

-- 4. Highest Death Counts
--    What countries have the highest death counts compared to their population

SELECT
  location,
  population,
  MAX(CAST(total_deaths AS INT)) AS total_deaths,
  ROUND(MAX(CAST(total_deaths AS INT)) / population * 100 , 3) AS percentage_population_deceased
FROM Portfolio_Project..covid_deaths_update
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_population_deceased DESC

-- 4.1 Highest Case Fatality Rates
--     What % of people infected passed away
SELECT
  location,
  population,
  MAX(total_cases) AS total_cases,
  MAX(CAST(total_deaths AS INT)) AS total_deaths,
  ROUND(MAX(CAST(total_deaths AS INT)) / MAX(total_cases) * 100 , 2) AS case_fatality
FROM Portfolio_Project..covid_deaths_update
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY case_fatality DESC

-- 5. Breakdown by Continent

-- 5.1 Continents with the Highest Number of Cases

SELECT
  continent,
  SUM(CAST(new_cases AS INT)) AS total_cases
FROM Portfolio_Project..covid_deaths_update
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC

-- 5.2 Continents with Highest Infection Rates

SElECT
  location,
  population,
  MAX(CAST(total_cases AS INT)) AS total_cases,
  ROUND(MAX(CAST(total_cases AS INT)) / population * 100, 2) AS percentage_population_infected
FROM Portfolio_Project..covid_deaths_update
WHERE 
  continent IS NULL 
  AND location IN ('South America', 'North America', 'Europe', 'Oceania', 'Africa', 'Asia')
GROUP BY location, population
ORDER BY percentage_population_infected DESC

-- 5.3 Continents with the Highest Death Counts

SELECT
  continent,
  SUM(CAST(new_deaths AS INT)) AS total_deaths
FROM Portfolio_Project..covid_deaths_update
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC

-- 5.4 Continents with Highest Death Rates

SElECT
  location,
  population,
  MAX(CAST(total_deaths AS INT)) AS total_deaths,
  ROUND(MAX(CAST(total_deaths AS INT)) / population * 100, 2) AS percentage_population_deceased
FROM Portfolio_Project..covid_deaths_update
WHERE 
  continent IS NULL 
  AND location IN ('South America', 'North America', 'Europe', 'Oceania', 'Africa', 'Asia')
GROUP BY location, population
ORDER BY percentage_population_deceased DESC

-- 6. Global Numbers

-- 6.1 Total Global Cases, Deaths and Recoveries 
--     Total number of cases, deaths and Recoveries, as well as case fatality, worldwide and by continent

SELECT  
 location,
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths AS INT)) AS total_deaths,
  SUM(new_cases) - SUM(CAST(new_deaths AS INT)) AS total_recovered,
  ROUND((SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100, 2) AS case_fatality
FROM Portfolio_Project..covid_deaths_update
WHERE location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania', 'World')
GROUP BY location

-- 6.2 Covid Totals by Location
--    What are the total cases, total deaths and total recoveries by Location (Country)

SELECT
  continent,
  location,
  population,
  MAX(total_cases) AS total_cases,
  MAX(CAST(total_deaths AS INT)) AS total_deaths,
  MAX(total_cases) - MAX(CAST(total_deaths AS INT)) AS total_recoveries
FROM Portfolio_Project..covid_deaths_update
WHERE continent IS NOT NULL
GROUP BY continent, location, population

-- 7. Vaccinations

-- 7.1 Rolling Count 
--     Shows a rolling count of the new vaccinations administered by day for each country

SElECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_rolling_count
FROM Portfolio_Project..covid_deaths_update AS dea
  JOIN Portfolio_Project..covid_vaccinations_update AS vac 
	ON dea.location =vac.location AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
-- AND dea.location LIKE '%Ireland%'
ORDER BY dea.location, dea.date

-- 7.2 Vaccination Percentages by Day
--     Shows how much of the population of each country has at least 1 dose, only has 1 dose or is fully vaccinated (By day)
--     Are new people getting vaccinated? is the percentage of partially vaccinated (one dose) going up? 
SElECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  ROUND((CAST(vac.people_vaccinated AS BIGINT) / dea.population) * 100, 2) AS percentage_at_least_one_dose,
  ROUND(((CAST(vac.people_vaccinated AS BIGINT) - CAST(vac.people_fully_vaccinated AS BIGINT)) / dea.population) * 100, 2) AS percentage_one_dose,
  ROUND((vac.people_fully_vaccinated / dea.population) * 100, 2) AS percentage_fully_vaccinated
FROM Portfolio_Project..covid_deaths_update AS dea
  JOIN Portfolio_Project..covid_vaccinations_update AS vac 
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- AND dea.location LIKE '%United States%'
ORDER BY dea.location, dea.date	

-- 7.3 Total Vaccination Percentages by Country
--     Total % population vaccinated (at least 1 dose), partially vaccinated (1 dose) and fully vaccinated by Country. 

-- STEP 1: Creating a temporary table with the vaccination percentages by date
SElECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  ROUND((CAST(vac.people_vaccinated AS BIGINT) / dea.population) * 100, 2) AS percentage_at_least_one_dose,
  ROUND(((CAST(vac.people_vaccinated AS BIGINT) - CAST(vac.people_fully_vaccinated AS BIGINT)) / dea.population) * 100, 2) AS percentage_one_dose,
  ROUND((vac.people_fully_vaccinated / dea.population) * 100, 2) AS percentage_fully_vaccinated
INTO #daily_vaccination_percentages
FROM Portfolio_Project..covid_deaths_update AS dea
  JOIN Portfolio_Project..covid_vaccinations_update AS vac 
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date	

-- STEP 2: Creating a second temporary table with the latest (max) vaccination percentages
--         Max of vaccinated (at least 1 dose) and fully vaccinated.
--         As these percentages can only go up, the max will equal the latest figures. 
SELECT
  location,
  population,
  MAX(percentage_at_least_one_dose) AS percentage_at_least_one_dose,
  MAX(percentage_fully_vaccinated) AS percentage_fully_vaccinated
INTO #max_vaccination_percentages
FROM #daily_vaccination_percentages
WHERE percentage_fully_vaccinated IS NOT NULL
GROUP BY location, population
ORDER BY percentage_fully_vaccinated DESC

-- STEP 3: Joining both tables as to obtain the up to date percentage of the population with only one dose
--         As this percentage can go up and down depending on the new number of new people getting vaccinated, 
--         the up to date figure will be the one that equals the MAX % of vaccinated and fully vaccinated. 

SELECT 
  DISTINCT mvp.location,
  mvp.population,
  mvp.percentage_at_least_one_dose,
  dvp.percentage_one_dose,
  mvp.percentage_fully_vaccinated
FROM #daily_vaccination_percentages AS dvp
  JOIN #max_vaccination_percentages AS mvp
	ON dvp.percentage_at_least_one_dose = mvp.percentage_at_least_one_dose AND dvp.percentage_fully_vaccinated = mvp. percentage_fully_vaccinated
ORDER BY mvp.percentage_fully_vaccinated DESC

-- 7.4 Vaccination Global Numbers
--     Total doses administered, as well as the total % population vaccinated (at least 1 dose), partially vaccinated (1 dose) and fully vaccinated Worldwide and by Continent. 

-- STEP 1: Creating a temporary table with the doses administered and vaccination percentages by date for the locations we need

SElECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.total_vaccinations,
  ROUND(CAST(vac.people_vaccinated AS BIGINT) / dea.population *100, 2) AS percentage_at_least_one_dose,
  ROUND((CAST(vac.people_vaccinated AS BIGINT) - CAST(vac.people_fully_vaccinated AS BIGINT)) / dea.population *100, 2) AS percentage_one_dose,
  ROUND(vac.people_fully_vaccinated / dea.population * 100, 2) AS percentage_fully_vaccinated
INTO #daily_vaccination_percentages_globe
FROM Portfolio_Project..covid_deaths_update AS dea
  JOIN Portfolio_Project..covid_vaccinations_update AS vac 
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania', 'World')
ORDER BY dea.location, dea.date	

-- STEP 2: Creating a second temporary table with the latest (max) doses administered and vaccination percentages

SELECT
  location,
  population,
  MAX(CAST(TOTAL_vaccinations AS BIGINT)) AS doses_administered,
  MAX(percentage_at_least_one_dose) AS percentage_at_least_one_dose,
  MAX(percentage_fully_vaccinated) AS percentage_fully_vaccinated
INTO #max_vaccination_percentages_globe
FROM #daily_vaccination_percentages_globe
WHERE percentage_fully_vaccinated IS NOT NULL
GROUP BY location, population
ORDER BY percentage_fully_vaccinated DESC

--STEP 3: -- Joining both tables as to obtain the up to date percentage of the population with only one dose

SELECT 
  DISTINCT mvpg.location,
  mvpg.population,
  mvpg.doses_administered,
  mvpg.percentage_at_least_one_dose,
  dvpg.percentage_one_dose,
  mvpg.percentage_fully_vaccinated
FROM #daily_vaccination_percentages_globe AS dvpg
  JOIN #max_vaccination_percentages_globe AS mvpg
	ON dvpg.percentage_at_least_one_dose = mvpg.percentage_at_least_one_dose AND dvpg.percentage_fully_vaccinated = mvpg. percentage_fully_vaccinated
ORDER BY mvpg.percentage_fully_vaccinated DESC

