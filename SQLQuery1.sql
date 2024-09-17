Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to use for this project
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null

order by 1,2

-- Looking at Total Cases vs Total Deaths from Covid-19 in the USA
-- Odds of dying if you contract covid in your country
Select Location, date, total_cases,  total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like  '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases,  Population, (total_cases/ Population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
--Where location like  '%states%'
Where continent is not null
order by 1,2


-- Looking at Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/ Population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
--Where location like  '%states%'
Where continent is not null

Group by Location, Population
order by InfectedPercentage desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like  '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like  '%states%'
Where continent is not null -- when cleaning the data I found that some of the locations would have the continent and the continent collumn would be null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_global_cases, SUM(cast(new_deaths as integer)) as total_global_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage  --total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like  '%states%'
Where continent is not null
Group By date -- total global death percentage per day
order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated / population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated / population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
) 
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE
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
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated / population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store data for later visuilizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date)
as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated / population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3