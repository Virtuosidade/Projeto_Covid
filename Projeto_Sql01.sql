select * 
from Project1..Coviddeaths
where continent is not null
order by 3, 4

--- select * 
---from Project1..CovidVaccinations
--- order by 3, 4

--- Filtrando risco de morte por contrair Covid no Brasil
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Project1..Coviddeaths
where continent is not null
and location like 'Brazil'
order by 1, 2

--- Número total de casos vs população
select location, date, total_cases, new_cases, Population, total_deaths, (total_cases/Population) * 100 as PopulationPercentage
from Project1..CovidDeaths
where continent is not null
and location like 'Brazil'
order by 1, 2

--- Total de infecções

select location, population, MAX(total_cases) AS MaxCountInfections, 
MAX((total_cases/Population)) * 100 as PctPopulationInfected
from Project1..CovidDeaths
--where location like 'Brazil'
where continent is not null
Group by location, population
order by PctPopulationInfected desc

--Total de Mortes
select location, MAX(cast(total_deaths as bigint)) as TotalDeaths
from Project1..CovidDeaths
--where location like 'Brazil'
where continent is not null
Group by location
order by TotalDeaths desc

-- Números mundiais

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project1..CovidDeaths
--Where location like 'Brazil'
where continent is not null 
--Group By date
order by 1,2


-- População total x vacinação total
-- Porcentagem da população que recebeu pelomenos uma dose

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Usando CTE para calcular na Partition By da consulta anterior

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Usando a tabela Temp para calcular a Partition By da consulta anterior

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Criando view para armazenar os dados para futuras visualizações

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated