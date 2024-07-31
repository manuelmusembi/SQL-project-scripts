
select * 
from PortfolioProject ..[CovidDeaths ]

--select * 
--from PortfolioProject ..CovidVaccinations


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject ..[CovidDeaths ]
order  by 1,2

-- Total_cases vs Total_deaths
-- shows likelihood of dying if you contract covid in Kenya
select Location, date, total_cases, total_deaths, 
 (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))* 100 AS DeathPercentage
from PortfolioProject ..[CovidDeaths ]
where Location like '%kenya%'
order  by 1,2



--Looking at the Total Cases vs Population
--shows what percentage of population got covid

select Location, date, total_cases, population, 
 (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))* 100 as PercentPopulationInfected
from PortfolioProject ..[CovidDeaths ]
--where Location like '%kenya%'
order  by 1,2



-- Looking at countries with the Highest Infection Rate compared to population

select Location,MAX( total_cases) as HighestInfectionCount, population, 
 MAX((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))* 100 as PercentPopulationInfected
from PortfolioProject ..[CovidDeaths ]
--where Location like '%kenya%'
group by Location, population
order  by PercentPopulationInfected desc


--Countries with the Highest Death Count Per Population

select Location, MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject ..[CovidDeaths ]
where continent is not null
group by Location
order  by TotalDeathCount desc


-- Continents with the Highest Death Count per Population


select continent, SUM(cast(new_deaths as int))as TotalDeathCount
from PortfolioProject ..[CovidDeaths ]
where continent is not null
group by continent
order  by TotalDeathCount desc



-- GLOBAL NUMBERS

select date, SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
 SUM(cast(new_deaths as float))/ SUM(cast(new_cases as float))* 100 AS DeathPercentage
from PortfolioProject ..[CovidDeaths ]
where continent is not null
group by date
order  by 1,2


-- TOTAL POPULATION VS VACCINATION

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population) * 100
from PortfolioProject..[CovidDeaths ] dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date =vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
  select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
  as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population) * 100
from PortfolioProject..[CovidDeaths ] dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date =vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--	TEMP TABLE

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
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
  as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population) * 100
from PortfolioProject..[CovidDeaths ] dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date =vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- make changes to the temp table, remove the where clause

DROP table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
  as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population) * 100
from PortfolioProject..[CovidDeaths ] dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date =vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- CREATE A VIEW TO STORE DATA
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date)
  as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population) * 100
from PortfolioProject..[CovidDeaths ] dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date =vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated

