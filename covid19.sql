select* 
from project..CovidDeaths

--selecting initial data
select location, date, total_cases, new_cases, total_deaths, population
from project..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from project..CovidDeaths
where location like '%states%'
order by 1,2

--total cases vs population
--Shows the percentage of the population that contracted covid
select location, date, population, total_cases, (total_cases/population)*100 as Cases_Percentage
from project..CovidDeaths
where location like '%states%'
order by 1,2

--countries with highest percentage of cases compared wih population
select location, population, MAX( total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from project..CovidDeaths
group by location,population
order by PercentagePopulationInfected desc

--countries with highest death count
select location, MAX(CAST( total_deaths as int)) as HighestDeathCount
from project..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

--Continents with highest death count
select location, MAX(CAST( total_deaths as int)) as HighestDeathCount
from project..CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc

--Highest infection and deth counts of countries broken down by continents
select location,continent,MAX(total_cases) as HighestInfectionCount, MAX(CAST( total_deaths as int)) as HighestDeathCount
from project..CovidDeaths
where continent is not null
group by location,continent
order by continent, HighestDeathCount desc

--Global numbers broken down by the day
select date, SUM(new_cases) as total_cases, SUM(CAST( new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from project..CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc

--Joining both tables into one
select*
from project..CovidDeaths dea
join project..CovidVaccines vac
   on dea.location=vac.location
   and dea.date=vac.date

--Total cases vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, dea.new_cases as cases_per_day, vac.new_vaccinations as vaccines_per_day
from project..CovidDeaths dea
join project..CovidVaccines vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Total population vs vaccinations
--Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated --(rolling additon)
from project..CovidDeaths dea
join project..CovidVaccines vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3


--CTE to perform calculations in previous query
with pop_vac (continent, location,date, population, new_vaccinations, total_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated --(rolling additon)
from project..CovidDeaths dea
join project..CovidVaccines vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
)
select*, (total_people_vaccinated/population)*100
from pop_vac

--Creating a temp table
DROP table if exists #PopulationVaccinatedPercentage
create table #PopulationVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_people_vaccinated numeric
)
insert into #PopulationVaccinatedPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated --(rolling additon)
from project..CovidDeaths dea
join project..CovidVaccines vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
   select*, (total_people_vaccinated/population)*100 as percentVaccinated
   from #PopulationVaccinatedPercentage

--creating a view

CREATE VIEW total_people_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as total_people_vaccinated --(rolling additon)
from project..CovidDeaths dea
join project..CovidVaccines vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null