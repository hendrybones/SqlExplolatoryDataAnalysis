select * 
from SqlDataAnalysis..CovidDeaths
where continent is not null
order by 1,2

SELECT location, date,total_cases,new_cases,total_deaths,population
From SqlDataAnalysis..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
--- likelihood of death if you get covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 as Deathpercentage
From SqlDataAnalysis..CovidDeaths
where location like '%kenya%'
order by 1,2


--- looking at total cases vs population
--- shows percentage of population with covid
SELECT location,date,population,total_cases,(total_cases/population)* 100 as PopulationInfectedpercentage
From SqlDataAnalysis..CovidDeaths
---where location like '%kenya%'
order by 1,2

---looking at countries with highest Infection Rate compared to population
SELECT location,population,Max(total_cases) as HighestInfectionCount,Max((total_cases/population))* 100 as
PopulationInfectedpercentage
From SqlDataAnalysis..CovidDeaths
---where location like '%kenya%'
Group by location,population
order by PopulationInfectedpercentage desc


--show the countries with the highest death count of the population
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount
From SqlDataAnalysis..CovidDeaths
---where location like '%kenya%'
where continent is not null
Group by location
order by TotalDeathCount desc

---Group our data by continent
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount
From SqlDataAnalysis..CovidDeaths
---where location like '%kenya%'
where continent is null
Group by location
order by TotalDeathCount desc

-- showing continents with the highest death count per population
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount
From SqlDataAnalysis..CovidDeaths
---where location like '%kenya%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Global NUMBERS
SELECT date,SUM(new_cases) as total_Cases,SUM(cast(new_deaths as int)) as total_Death,SUM(cast(new_deaths as int ))/SUM
(new_cases)*100 as Deathpercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM SqlDataAnalysis..CovidDeaths
--where location like '%states%' a
where continent is not null
Group By date
order by 1,2


-- looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinationated
From SqlDataAnalysis..CovidDeaths dea
join SqlDataAnalysis..Covid19Vaccinations vac
     on dea.location=vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinationated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinationated
From SqlDataAnalysis..CovidDeaths dea
join SqlDataAnalysis..Covid19Vaccinations vac
     on dea.location=vac.location 
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinationated/population)*100
From PopvsVac

---TEMP TAble
Drop table if exists #percentPopulationVaccinate
Create Table #percentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinationated numeric
)
Insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinationated
From SqlDataAnalysis..CovidDeaths dea
join SqlDataAnalysis..Covid19Vaccinations vac
     on dea.location=vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

select *(RollingPeopleVaccinationated/population)*100
From #percentPopulationVaccinated

-- creating view to store data for later visualization
--Drop view if exists percentPopulationVaccinated
Create View percentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinationated
From SqlDataAnalysis..CovidDeaths dea
join SqlDataAnalysis..Covid19Vaccinations vac
     on dea.location=vac.location 
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

select * from percentPopulationVaccinated;