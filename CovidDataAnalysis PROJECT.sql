select *
FROM PortfolioProject..CovidDeath
where continent is not null
order by 3,4

select *
FROM PortfolioProject..CovidVaccinations
order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

-- looking at TotalCases vs TotalDeaths

select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%Nigeria%'
order by 1,2

--TotalCases relative to population in Nigeria

select Location, date, population, total_cases, (total_cases/population )*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%Nigeria%'
order by 1,2

-- looking at Countires with the Highest Infection Rate during Period
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population ))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Highest Death count per Population

select Location,	MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%Nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc

--Analyis by Continent (NIGERIA)
select continent,	MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%Nigeria%'
where continent is not null
group by continent 
order by TotalDeathCount desc


--Global statistics
select  sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null
--group by date
order by 1,2


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

Select *
From PopvsVac


--CREATING TSV (Temporary Storage View)
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location,
dea.Date) as RollingPeopleVaccinated

FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
from PercentPopulationVaccinated