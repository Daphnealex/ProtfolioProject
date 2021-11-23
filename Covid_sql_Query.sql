SELECT*
from CovidDeaths
where continent is not null
order by 3,4

SELECT *
from CovidVaccination
order by 1,2 

SELECT location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null

-- Death percentage in india

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths 
where location = 'india' and continent is not null
order by location, date

-- Percentage of Covid cases with respect to population

SELECT location, date, population, total_cases,  (total_cases/population)*100 as cases_percentage
from CovidDeaths 
where location = 'india' and continent is not null
order by location, date

-- Highest cases based on country 

SELECT location, population, max(total_cases)as Highest_count,  max((total_cases/population))*100 as Total_Covid_percentage
from CovidDeaths 
where continent is not null
group by location, population
order by Total_Covid_percentage desc

-- Highest death case based on country

SELECT location, max(cast(total_deaths as int))as Death_count
from CovidDeaths 
where continent is not null
group by location
order by Death_count desc


-- Highest death rate by continent

SELECT continent, max(cast(total_deaths as int))as Death_count
from  CovidDeaths
where continent is not null
group by continent
order by Death_count desc



SELECT location, max(cast(total_deaths as int))as Death_count
from  CovidDeaths
where continent is null
group by location
order by Death_count desc

-- Total cases by date

select date, sum(new_cases)
from CovidDeaths
where continent is null
group by date
order by date

-- Total cases and total death with respect to date

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths
from CovidDeaths
where continent is null
group by date
order by date



-- Total cases, total death and death percentage with respect to date

select date, sum(new_cases)as Total_cases, sum(cast(new_deaths as int))as Total_deaths,
sum(cast(new_deaths as int ))/sum(new_cases)*100 as Deathpercent
from CovidDeaths
where continent is null
group by date
order by date

--overall global cases

select sum(new_cases)as Total_cases, sum(cast(new_deaths as int))as Total_deaths, 
sum(cast(new_deaths as int ))/sum(new_cases)*100 as Deathpercent
from CovidDeaths
where continent is not null

-- joining CovidDeaths and CovidVaccination

select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by location, date

 
 -- rolling people vaccination

select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations, 
sum(convert(real, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by location, date


 --Find the Percentage of people Vaccinated

 --using CTE

with PopVsVac (continent, location,  date, population, new_vaccinations,rollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (rollingPeopleVaccinated/population)*100 as PercentageOfPeopleVaccinated
From PopVsVac

-- TEMP TABLE

drop table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
( continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccination numeric,  rollingPeopleVaccinated numeric)

INSERT INTO PercentPopulationVaccinated
select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations, 
sum(convert(real, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
order by location, date

Select *, (rollingPeopleVaccinated/population)*100 as PercentageOfPeopleVaccinated
From PercentPopulationVaccinated

--views for visualization

create view PercentofPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(convert(real, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated 
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from PercentofPopulationVaccinated


