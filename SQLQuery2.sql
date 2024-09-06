SELECT *
FROM Covid_EDA.dbo.[covid-data(deaths)]
Where continent is not NULL
order by 3,4


--SELECT *
--FROM [covid-data(vaccinations)]
--order by 3,4

--Select Data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
From Covid_EDA.dbo.[covid-data(deaths)]
Where continent is not NULL
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in India
Select Location,date,total_cases,total_deaths,(total_deaths/NULLIF(total_cases,0))*100 as DeathPercentage
From Covid_EDA.dbo.[covid-data(deaths)]
Where location like '%india%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location,date,total_cases,population,(total_cases/NULLIF(population,0))*100 as PopulationInfectedPercentage
From Covid_EDA.dbo.[covid-data(deaths)]
Where location like '%india%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/NULLIF(population,0)))*100 as MaxPopulationInfectedPercentage
From Covid_EDA.dbo.[covid-data(deaths)]
Where continent is not NULL
Group by location,population
order by MaxPopulationInfectedPercentage desc

--Countries with highest death count per population
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid_EDA.dbo.[covid-data(deaths)]
Where continent is not NULL
Group by location
order by TotalDeathCount desc

--For all continents including upper world, world, lower economic world
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid_EDA.dbo.[covid-data(deaths)]
Where continent is  NULL
Group by location
order by TotalDeathCount desc

--For all continents excluding upper world, world, lower economic world
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid_EDA.dbo.[covid-data(deaths)]
Where continent is not NULL
Group by continent
order by TotalDeathCount desc




--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From Covid_EDA.dbo.[covid-data(deaths)]
--Where location like '%india%'
Where continent is not NULL
--Group by date
order by 1,2

--USE CTE
With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
--Looking at total population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations ) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingpeopleVaccinated --,(RollingPeopleVaccinated/Population)*100
From Covid_EDA.dbo.[covid-data(deaths)] as dea
Join Covid_EDA.dbo.[covid-data(vaccinations)] as vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent  is not null
--order by 2,3 
)

Select * ,(RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table

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
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations ) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingpeopleVaccinated --,(RollingPeopleVaccinated/Population)*100
From Covid_EDA.dbo.[covid-data(deaths)] as dea
Join Covid_EDA.dbo.[covid-data(vaccinations)] as vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent  is not null
--order by 2,3 

Select * ,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated4 as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations ) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingpeopleVaccinated --,(RollingPeopleVaccinated/Population)*100
From Covid_EDA.dbo.[covid-data(deaths)] as dea
Join Covid_EDA.dbo.[covid-data(vaccinations)] as vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not  null
--order by 2,3

--CREATE VIEW PercentPopulationVaccinated1 AS
--SELECT 
--    dea.continent,
--    dea.location,
--    dea.date,
--    dea.population,
--    vac.new_vaccinations,
--    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--    (SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) / dea.population) * 100 AS PercentPopulationVaccinated
--FROM 
--    Covid_EDA.dbo.[covid-data(deaths)] AS dea
--JOIN 
--    Covid_EDA.dbo.[covid-data(vaccinations)] AS vac
--ON 
--    dea.location = vac.location
--AND 
--    dea.date = vac.date
--WHERE 
--    dea.continent IS NOT NULL;

