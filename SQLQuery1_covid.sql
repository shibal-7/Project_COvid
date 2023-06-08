--select * 
--From covid..covid_deaths$
--order by 3,4;

--select Location,date,total_cases,new_cases,total_deaths,
--population
--From covid..covid_deaths$
--order by 1,2;

--Total cases vs total deaths
select Location,date,total_cases,
total_deaths, CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as deathperc
From covid..covid_deaths$ 
where Location like '%india%'
order by 1,2;

--Looking at total cases vs population
select Location,date,total_cases,
population, CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population)))*100 as deathperc
From covid..covid_deaths$ 
where Location like '%states%'
order by 1,2;

--Looking at countries with highest infection rate compared to population

select location,
population, MAX(total_cases) as highest, MAX(CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population))))*100 as deathperc
From covid..covid_deaths$ 
Group by location,population
order by deathperc desc;

-- Showing countries with highest death count per pop
select location, MAX(total_deaths) as highest 
from covid..covid_deaths$
Group by location
order by highest desc;


--CONTINENT WISE;
select continent, SUM(CONVERT(DECIMAL(18,2) ,total_deaths )) as totalcases
from covid..covid_deaths$ 
where continent is not null
group by continent
order by totalcases desc;

--Global numbers

--want to see the cases of all 
--countries on a specific date

select date,SUM(CONVERT(DECIMAL(18,2),total_cases)) as sum_of_cases_on_this_date,
SUM(CONVERT(DECIMAL(18,2) ,total_deaths ))/SUM(CONVERT(DECIMAL(18,2) ,total_cases ))*100  as death_percentage    
from 
covid..covid_deaths$
where date like '%2020%'
group by date
order by date desc;

--New table

select  dea.location, dea.date ,total_deaths
from covid..covid_vaccinations$ dea
join covid..covid_deaths$ vac
on dea.location=vac.location and dea.date=vac.date;

--total population vs vaccination  (CTE)
With PopvsVac 
(continent, location,date,population,new_vaccinations,sum_new)
as
 (
 select dea.continent,dea.location,
 dea.date,dea.population,vac.new_vaccinations, 
 
 SUM(CONVERT (decimal,vac.new_vaccinations))  OVER 
 (Partition by dea.location Order by dea.location, dea.date) 
 AS sum_new
 
from covid..covid_vaccinations$ vac
join covid..covid_deaths$ dea
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select * , (sum_new/population )*100 
from PopvsVac


--Temp table
DROP TABLE IF EXISTS #percentpopvac
create table #percentpopvac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
sum_new numeric)

Insert into  #percentpopvac
select dea.continent,dea.location,
dea.date,dea.population,vac.new_vaccinations, 
 
 SUM(CONVERT (decimal,vac.new_vaccinations))  OVER 
 (Partition by dea.location Order by dea.location, dea.date) 
 AS sum_new
 
from covid..covid_vaccinations$ vac
join covid..covid_deaths$ dea
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null


select * , (sum_new/population )*100 
from #percentpopvac



--View to store data for later visualizations
create View percentpopvac as 
select dea.continent,dea.location,
dea.date,dea.population,vac.new_vaccinations, 
 
 SUM(CONVERT (decimal,vac.new_vaccinations))  OVER 
 (Partition by dea.location Order by dea.location, dea.date) 
 AS sum_new
 
from covid..covid_vaccinations$ vac
join covid..covid_deaths$ dea
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

