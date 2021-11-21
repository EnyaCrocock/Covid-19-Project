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

### Covid Status by Location
  ```sql
  -- 1. Total Cases vs Total Deaths (By Date)
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
  ![image](https://user-images.githubusercontent.com/94410139/142782262-6ec5b4ef-585b-4908-aa9e-1c4c7693a19a.png)

  ```sql
  -- 2. Total Cases vs Population (By Date)
  --    What % of the population has been infected with Covid-19 

  SELECT 
    location,
    date,
    population,
    total_cases,
    total_deaths,
    ROUND(((total_cases / population) * 100), 2) AS percentage_population_infected
  FROM Portfolio_Project..covid_deaths_update
  -- WHERE location LIKE '%Spain%'
  ORDER BY location, date
  ```
