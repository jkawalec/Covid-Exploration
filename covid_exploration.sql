
-- Looked at the overall Data

Select *
From [portfolio project]..['covid deaths$']
Order by 3,4

-- Selected the data that we started with

Select Location, date, total_deaths, total_cases, population
from [portfolio project]..['covid deaths$']
Order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the likelihood  of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [portfolio project]..['covid deaths$']
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as Percentpopulationinfected
from [portfolio project]..['covid deaths$']
Where location like '%states%'
Order by 1,2

--Countries with the highest infection rates

Select Location,max(total_cases) as highinfectioncount, max((total_cases/population))*100 as Percentpopulationinfected
From [portfolio project]..['covid deaths$']
Group By population, location
Order by Percentpopulationinfected desc

-- Continents with the Highest Death Count per Population
-- Also includes entire World and other grouped Locations Death Count

Select Location,max(cast(total_deaths as int)) as totaldeathcount
From [portfolio project]..['covid deaths$']
Where continent is null
Group By location
Order by totaldeathcount desc

-- Countries with the Highest Death Count per Population

Select location ,max(cast(total_deaths as int)) as totaldeathcount
From [portfolio project]..['covid deaths$']
Where continent is not null
and location not in ('World','European Union', 'International')
Group By location
Order by totaldeathcount desc

--Continents with the highest death counts per Population

Select continent,max(cast(total_deaths as int)) as totaldeathcount
From [portfolio project]..['covid deaths$']
Where continent is not null
Group By continent
Order by totaldeathcount desc


--Global Numbers

Select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From [portfolio project]..['covid deaths$']
Where continent is not null
--Group By date
Order by 1,2

-- Total Population vs Vaccinations
-- Shows the percentage of the Population that has received at least one Covid Vaccine

Select dea.continent, dea.location, population, dea.date, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by 
dea.location order by dea.location, dea.date) as rollingvaccinations
from [portfolio project]..['covid vaccinations$'] vac
join [portfolio project]..['covid deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

-- Using a CTE to perform Calculation on Partition By in previous query

With Popvsvac (continent, location, date, population, New_Vaccinations,rollingvaccinations)
as
(
Select dea.continent, dea.location, population, dea.date, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by 
dea.location order by dea.location, dea.date) as rollingvaccinations
from [portfolio project]..['covid vaccinations$'] vac
join [portfolio project]..['covid deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *
From Popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date date,
Population numeric,
New_vaccinations numeric,
rollingvaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by 
dea.location order by dea.location, dea.date) as rollingvaccinations
from [portfolio project]..['covid vaccinations$'] vac
join [portfolio project]..['covid deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (rollingvaccinations/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPolulationVaccinated as
Select dea.continent, dea.location, dea.date, population, new_vaccinations, sum(convert(int,vac.new_vaccinations)) OVER (Partition by 
dea.location order by dea.location, dea.date) as rollingvaccinations
from [portfolio project]..['covid vaccinations$'] vac
join [portfolio project]..['covid deaths$'] dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select location, population, date, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
from [portfolio project]..['covid deaths$']
Group by location, population,date
order by percentpopulationinfected desc