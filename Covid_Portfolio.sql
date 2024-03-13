select *
from Covid_Portfolio..CovidDeaths
where continent is not null
order by 3,4 Desc


--select *
--from Covid_Portfolio..CovidVaccination
--order by 3,4


--select the data I will be Using


select Location, date, total_cases, new_cases, total_deaths, population
from Covid_Portfolio..CovidDeaths
order by 1,2


---I will be looking at Total Cases vs Total Deaths
---Shows the likelihood of dying if you contract covid

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_Portfolio..CovidDeaths
where location like '%Nigeria%'
and continent is not null
order by 1,2


---I will look at the Total Cases Vs the Population
---shows the total percentage of the population that got covid

select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from Covid_Portfolio..CovidDeaths
--where location like '%Nigeria%'
order by 1,2


---Looking at countries with the highest infection rate compared to its population

select Location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/population)) *100 as PercentagePopulationInfected
from Covid_Portfolio..CovidDeaths
--where location like '%Nigeria%'
Group by location, population
order by PercentagePopulationInfected Desc


---Showing countries with the Highest Death Count per Population


select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid_Portfolio..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by location
order by TotalDeathCount Desc


----BREAKING THINGS DOWN BY CONTINENT

---Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Covid_Portfolio..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount Desc


----Global Numbers by date

select  date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from Covid_Portfolio..CovidDeaths
---where location like '%Nigeria%'
where continent is not null
Group by date
order by 1,2

---Total Global numbers

select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from Covid_Portfolio..CovidDeaths
---where location like '%Nigeria%'
where continent is not null
---Group by date
order by 1,2



---Looking at Total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as CummulativeTotalVaccination
---, (CummulativeTotalVaccination/population)*100
from Covid_Portfolio..CovidDeaths dea
join Covid_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



--- Use CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, CummulativeTotalVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as CummulativeTotalVaccination
---, (CummulativeTotalVaccination/population)*100
from Covid_Portfolio..CovidDeaths dea
join Covid_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 1,2,3
)
select *, (CummulativeTotalVaccination/Population)*100 as PercentageCummulativeVaccinated
from PopvsVac



----TEMP Table

DROP Table if exists #PercentageCummulativeVaccinated
Create Table #PercentageCummulativeVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
CummulativeTotalVaccination numeric,
)

insert into #PercentageCummulativeVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as CummulativeTotalVaccination
---, (CummulativeTotalVaccination/population)*100
from Covid_Portfolio..CovidDeaths dea
join Covid_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
---where dea.continent is not null
---order by 1,2,3 
select *, (CummulativeTotalVaccination/Population)*100 as PercentageCummulativeVaccinated
from #PercentageCummulativeVaccinated



----Creating view to store Data for visualization 


create view PercentageCummulativeVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.Date) as CummulativeTotalVaccination
---, (CummulativeTotalVaccination/population)*100
from Covid_Portfolio..CovidDeaths dea
join Covid_Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 1,2,3 


select *
from PercentageCummulativeVaccinated