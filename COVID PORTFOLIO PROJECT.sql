SELECT*
FROM [PORTFOLIO PROJECT]..CovidDeaths$
Where continent is not null
ORDER BY 3,4
-- Looking at tolat-cases vs total-death

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
Where location like '%kingdom%'
and continent is not null
ORDER BY 1,2

--Looking at total-cases vs population

SELECT location, date, population,total_cases, (total_cases/population) * 100 as populationPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
Where location like '%kingdom%'
and continent is not null
ORDER BY 1,2

-- Showing countries with the highest infection rate compared to population
SELECT location, population
,MAX (total_cases)as highestInfectionCount
, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths$
--Where location like '%KINGDOM%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


--Showing countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths$
--Where location like '%KINGDOM%'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breaking things down by continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths$
--Where location like '%KINGDOM%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths$
--Where location like '%KINGDOM%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers~
SELECT date
,SUM( new_cases) Total_Cases
,SUM(CAST(new_deaths AS INT)) as Total_Death
,SUM(CAST(new_deaths AS INT))/SUM( new_cases) AS DeathPercentage
FROM [PORTFOLIO PROJECT].dbo.CovidDeaths$
--Where location like '%KINGDOM%'
Where continent is not null
GROUP BY date
ORDER BY 1,2

--Showing Total population Vs Vaccination

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
,SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.LOCATION
,DEA.DATE)AS ROLLINGPEOPLEVACCINATED
--,ROLLINGPEOPLEVACCINATED
FROM [PORTFOLIO PROJECT]..CovidDeaths$ DEA
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent IS NOT NULL
   ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,ROLLINGPEOPLEVACCINATED)
as(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
,SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.LOCATION
,DEA.DATE)AS ROLLINGPEOPLEVACCINATED
--,ROLLINGPEOPLEVACCINATED
FROM [PORTFOLIO PROJECT]..CovidDeaths$ DEA
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent IS NOT NULL
   )
   SELECT*,(ROLLINGPEOPLEVACCINATED/population)*100
   FROM PopvsVac

   --TEMP TABLE
   --DROP TABLE if exists #PERCENTPOPULATIONVACCINATED (helps run the table mutiple times incase new features need to b  added)
   CREATE TABLE #PERCENTPOPULATIONVACCINATED
   (
   CONTINENT nvarchar(255)
   ,location nvarchar(255)
   ,date datetime
   ,population numeric
   ,new_vaccination numeric
   ,ROLLINGPEOPLEVACCINATED numeric
   )
   INSERT INTO #PERCENTPOPULATIONVACCINATED
   SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
,SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.LOCATION
,DEA.DATE)AS ROLLINGPEOPLEVACCINATED
--,ROLLINGPEOPLEVACCINATED
FROM [PORTFOLIO PROJECT]..CovidDeaths$ DEA
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent IS NOT NULL
   ORDER BY 2,3

   SELECT*,(ROLLINGPEOPLEVACCINATED/population)*100
   FROM #PERCENTPOPULATIONVACCINATED

   CREATE VIEW PopulationVaccinated as
   (
   SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
,SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.LOCATION
,DEA.DATE)AS ROLLINGPEOPLEVACCINATED
--,ROLLINGPEOPLEVACCINATED
FROM [PORTFOLIO PROJECT]..CovidDeaths$ DEA
JOIN [PORTFOLIO PROJECT]..CovidVaccinations$ VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
   WHERE DEA.continent IS NOT NULL
   --ORDER BY 2,3
   )
   select*
   FROM PopulationVaccinated 
