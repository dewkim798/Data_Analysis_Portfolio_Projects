Select*
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

Select*
From PortfolioProject1..CovidVaccinations
order by 3,4



-- Looking at Total Cases vs. Total Deaths
-- (First query) Shows the likelihood of passing away from contracting Covid-19 in the United States daily
-- (Second query) Shows the likelihood of passying away from contracting Covid-19 in each country daily

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
order by 1,2



-- Looking at Total Cases vs Population
-- Portrays the percentage of the population contracting Covid-19 per day

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentageInfected
From PortfolioProject1..CovidDeaths
order by 1,2



-- Conveying the Prime Infection Rate in comparison to each country's population status

Select location, population, MAX(total_cases) as PrimeInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
From PortfolioProject1..CovidDeaths
Group by location, population
order by PopulationPercentageInfected desc



-- Portraying Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
and location not in ('World','European Union', 'International')
Group by location
order by TotalDeathCount desc



-- Starting with Continents


-- Portraying Continents with Highest Total Death Count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Global Numbers (In Total as well as new cases by date)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null 
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Looking at Total Population vs. Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as rollingvaccination
From PortfolioProject1..CovidDeaths cd
Join PortfolioProject1..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2, 3



-- Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rollingvaccination)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as rollingvaccination
From PortfolioProject1..CovidDeaths cd
Join PortfolioProject1..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
Select *, (rollingvaccination/population)*100 as rollingvacpercentage
From PopvsVac



-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccination numeric,
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as rollingvaccination
From PortfolioProject1..CovidDeaths cd
Join PortfolioProject1..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

Select *, (rollingvaccination/population)*100 as rollingvacpercentage
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) as rollingvaccination
From PortfolioProject1..CovidDeaths cd
Join PortfolioProject1..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null