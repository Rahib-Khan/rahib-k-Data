

select location, date, total_cases, new_cases, total_deaths, population 
from Covid_Deaths 
order by 1,2;

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from Covid_Deaths 
where location = 'United States' 
order by 1,2;

select location, date, total_cases, population, (total_cases/population)*100 as POP_Percent 
from Covid_Deaths 
where location = 'United states' 
order by 1,2;

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationInfectedPercent 
from Covid_Deaths 
group by location, population 
order by PopulationInfectedPercent desc;

-- Country highest deaths
select location, Max(total_deaths) as TotalDeathCount 
from Covid_Deaths 
where continent <> ''
group by location 
order by totalDeathCount desc;


-- continent number
select location as continent, Max(total_deaths) as TotalDeathCount 
from Covid_Deaths 
where location in (select continent from Covid_Deaths) 
group by location 
order by totalDeathCount desc;


-- Global number
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from Covid_Deaths 
where location = 'WORLD' 
order by 1,2;




-- total vaccination vs population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Deaths as dea
Join COVID_VACS as vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent <> ''
order by 2,3;

-- use cte
with PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Deaths as dea
Join COVID_VACS as vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent <> ''
-- order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac;


-- Temp Table
Drop table if exists PercentPopulatedVaccinated;
create temporary table PercentPopulatedVaccinated(
continent varchar(50),
location varchar(100),
date date, 
population int, 
new_vaccinations int, 
RollingPeopleVaccinated float
);

insert into PercentPopulatedVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Deaths as dea
Join COVID_VACS as vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent <> ''
order by 2,3;

select *, (rollingpeoplevaccinated/population)*100
from PercentPopulatedVaccinated;


-- creating view for visulizations
create view PercentPopulatedVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Deaths as dea
Join COVID_VACS as vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent <> ''
order by 2,3;

