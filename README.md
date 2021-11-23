# Covid-19 Data Exploration Project
This is my first SQL and Power BI Project

#### 💡 Inspiration 
- While searching for ideas for portfolio projects I found Alex Freberg's [Data Analyst Portfolio Porject Series](https://www.youtube.com/watch?v=qfyynHBFOsM), which I decided to follow whilst making it my own. 

---

#### ✍🏼 The Objective
- Exploring Covid-19 worldwide data.

#### 📈 The Dataset 
- Complete Covid-19 dataset (28th January 2020 to 13th November 2021) from [Our World in Data](https://ourworldindata.org/covid-deaths). 

#### 💻 Tools Used
- Data Exploration = Microsoft SQL Server
- Dashboard = Microsoft Power BI

---
### Table of Contents
  - [SQL Data Exploration](#sql-data-exploration)
    - [Downloading, Modifying and Importing Data](#downloading-modifying-and-importing-data) 
    - [SQL Server Queries](#sql-server-queries)
      - [Covid Status by Location](#-covid-status-by-location)
      - [Covid Status by Continent](#-covid-status-by-continent)
      - [Global Numbers](#-global-numbers)
      - [Vaccinations](#-vaccinations)

---
# SQL Data Exploration

## Downloading, Modifying and Importing Data
- After downloading the dataset from [Our World in Data](https://ourworldindata.org/covid-deaths) we use Excel to split it into 2 xlxs files:
  - One containing all the covid cases and death data:
  
    ![image](https://user-images.githubusercontent.com/94410139/142781218-41229a5e-7200-41f8-b0a6-e7edcc8f183c.png)

  - The other containing vaccination data: 
  
    ![image](https://user-images.githubusercontent.com/94410139/142781313-ce367372-475c-4417-850e-740db09c478b.png)

- Once that is done we import both files into Microsoft SQL Server. 

## SQL Server Queries

  ```sql
  -- View Imported Data
  
  SELECT *
  FROM Portfolio_Project..covid_deaths_update
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142781865-d8b29e15-4239-4b20-aa44-325c309827d6.png)
 
  ```sql
  SELECT *
  FROM Portfolio_Project..covid_vaccinations_update
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142781938-46d505b5-e2bc-4955-9185-a19e9111c5ff.png)

### 🔷 Covid Status by Location

  ```sql
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
  -- WHERE location LIKE '%Ireland%'
  ORDER BY location, date
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142910858-bf968b70-b337-480c-b775-0d12c37d193f.png) 
  
  ```sql
  -- 2. Total Cases vs Total Deaths (By Date)
  --    What % of people infected with Covid-19 have passed away

  SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND(((total_deaths / total_cases) * 100), 2) AS death_percentage
  FROM Portfolio_Project..covid_deaths_update
  -- WHERE location LIKE '%Spain%'
  ORDER BY location, date
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142910765-4fb390ca-012b-417b-bc29-4c456ee89a3e.png)
  
  ```sql
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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142910484-585ffd72-0465-4af4-86ff-2293a1e7ae4f.png)
 
  ```sql
  -- 4. Highest Death Counts (In Total)
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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142910366-9ec3c64a-3ccb-411d-9014-32605289067d.png)
  
  ```sql
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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142911445-8f03ce10-f494-41e4-b403-acb42b69a660.png)
  
### 🔷 Covid Status by Continent

  ```sql
  -- 5.1 Continents with the Highest Number of Cases

  SELECT
    continent,
    SUM(CAST(new_cases AS INT)) AS total_cases
  FROM Portfolio_Project..covid_deaths_update
  WHERE continent IS NOT NULL
  GROUP BY continent
  ORDER BY total_cases DESC
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142912901-2c3e2820-0a30-433e-9e82-d2057ae687d8.png)
  
  ```sql
  -- 5.2 Continents with Highest Infection Rates
  --     Continents in order of % of population that has gotten infected 
  
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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142918154-7d3bc2fd-d46f-463c-8e6e-330cf7928448.png)

  ```sql
  -- 5.3 Continents with the Highest Death Counts
  
  SELECT
    continent,
    SUM(CAST(new_deaths AS INT)) AS total_deaths
  FROM Portfolio_Project..covid_deaths_update
  WHERE continent IS NOT NULL
  GROUP BY continent
  ORDER BY total_deaths DESC
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142918269-3f606e20-d49e-4132-aa9d-03507dc0a1d1.png)
  
  ```sql
  -- 5.4 Continents with Highest Death Rates
  --     Continents in order of % of population that has passed away 

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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142918487-7d7e2596-db33-4435-8cb0-1c8863fb5c9a.png)

### 🔷 Global Numbers

  ```sql
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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142920569-1ea4cec0-5136-4c77-991d-dd138437bee4.png)

### 🔶 Vaccinations

  ```sql
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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/142950128-07a38b95-34b4-48c9-96ff-256dec02d8e2.png)
  
  ```sql
  -- 7.3 Vaccination Percentages by Day
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
  WHERE 
    dea.continent IS NOT NULL
  -- AND dea.location LIKE '%United States%'
  ORDER BY dea.location, dea.date	
  ```
  ![image](https://user-images.githubusercontent.com/94410139/143029604-c11cc56f-027e-4caa-aa12-002b7431c932.png)
  
  ```sql
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
  ```
  ![image](https://user-images.githubusercontent.com/94410139/143032233-439e37ca-c99c-42d2-b2cf-0a383de910fc.png)

