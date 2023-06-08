/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
Select *
From CovidProject..CovidDeaths
Where continent is not null
order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths 
Where continent is not null
--orders data by the 1st and 2nd columns (Location, date)
order by 1,2


-- Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your Country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
Where continent is not null

order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population has been infected by Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectionPercentage
From CovidProject..CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectionPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by location, population
order by PopulationInfectionPercentage desc


-- GROUPING THINGS BY CONTINENT


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as float)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing Continents with the highest death count per Population

Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths 
where new_cases != 0 AND new_deaths != 0 
AND continent is not null
Group by date
order by 1,2


-- Showing Global deaths and death percentage per Global total
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths 
where new_cases != 0 AND new_deaths != 0 
AND continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(float, vax.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths death
Join CovidProject..CovidVaccination vax
	On death.location = vax.location
	and death.date = vax.date
where death.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(float, vax.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths death
Join CovidProject..CovidVaccination vax
	On death.location = vax.location
	and death.date = vax.date
where death.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVax



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(float, vax.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths death
Join CovidProject..CovidVaccination vax
	On death.location = vax.location
	and death.date = vax.date
where death.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(CONVERT(float, vax.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths death
Join CovidProject..CovidVaccination vax
	On death.location = vax.location
	and death.date = vax.date
where death.continent is not null


Create View HighestDeath as
Select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
