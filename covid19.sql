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