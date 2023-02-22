--Select *
--From [Portfolio Project]..[CovidDeaths]
--order by 3,4

----Select *
----From [Portfolio Project]..[CovidVaccinations]
----order by 3,4

------Select data that we are going to use


Select Location, Date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..[CovidDeaths]
order by 1,2



-- looking at total cases vs total deaths


Select Location, Date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..[CovidDeaths]
where location like '%states%'
order by 1,2



-- looking at total cases vs total population
--Shows what % of puplation got Covid


Select Location, Date,  population, total_cases, (total_cases/population)*100 as PercentPopultionInfected
From [Portfolio Project]..[CovidDeaths]
where location like '%states%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopultionInfected
From [Portfolio Project]..[CovidDeaths]
--where location like '%states%'
Group By Location, population
order by PercentPopultionInfected desc

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[CovidDeaths]
--where location like '%states%'
Group By Location
order by TotalDeathCount desc



-- Break Things Down by Continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..[CovidDeaths]
--where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc


--Showing continents with hightest death counts


-- Global Numbers

Select  Date, sum(new_cases)as total_cases, Sum (cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..[CovidDeaths]
--where location like '%states%'
where continent is not null
group By date
order by 1,2


Select sum(new_cases)as total_cases, Sum (cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..[CovidDeaths]
--where location like '%states%'
where continent is not null
--group By date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (convert (bigint, vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE Common Table Expression

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinations/Population)*100 as PerecentofPopulationVaccinated
From PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- Create View to store for later visualizations

Use [Portfolio Project]
GO
Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
