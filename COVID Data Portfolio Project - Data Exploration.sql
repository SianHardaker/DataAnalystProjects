/* COVID DATA EXPLORATION 

Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Viewa, Converting Data Types

*/

Select * 
From CovidDeaths
Where Continent is not NULL
Order by 3,4 

-- Select data we are going to be starting with 

Select location, date, total_cases, new_cases, total_deaths, population 
From CovidDeaths
Where Continent is not NULL
order by 1,2

-- Total cases vs Total deaths 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From CovidDeaths
Where location like '%kingdom%'
AND continent is not null
order by 1,2

--Total cases vs Population

Select location, date, total_cases, total_deaths, (total_cases/population)* 100 as percentage_population_infected
From CovidDeaths
order by 1,2

--Countries with highest infection rate compared to population 

Select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentage_population_infected
From CovidDeaths
Group by location, population 
order by percentage_population_infected desc

-- countries with highest death count 

Select location, MAX(total_deaths) as totaldeathcount
From CovidDeaths
Where continent is not null
Group by location
order by totaldeathcount desc

-- BREAKING THINGS DOWN BY CONTINENT --

--Showing continents with the highest death count

Select continent, MAX(total_deaths) as highestdeathcount
From CovidDeaths
Where continent is not null
Group by continent
order by highestdeathcount desc

--GLOBAL NUMBERS--

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as deathpercentage 
From CovidDeaths
Where continent is not NULL
order by 1,2 

--Total Population vs Vaccinations--

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From CovidDeaths dea
Join CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Using CTE's--

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.Date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null)
Select *, (rolling_people_vaccinated/Population)*100 AS total_vaccinated_percentage
FROM PopvsVac

--Using Temp Tables--

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, new_vaccinations numeric, rolling_people_vaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.Date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/Population)*100 AS total_vaccinated_percentage
FROM #PercentPopulationVaccinated

--Creating a View to stora data for later visualisations--

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.Date) as rolling_people_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null