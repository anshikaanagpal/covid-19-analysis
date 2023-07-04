select* 
from project..CovidDeaths

--selecting initial data
select location, date, total_cases, new_cases, total_deaths, population
from project..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2
