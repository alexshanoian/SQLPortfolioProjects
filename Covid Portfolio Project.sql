Select *
	From PortfolioProject..['Covid Deaths$']
	Where continent is not null
	order by 3,4

	--Select *
	--From PortfolioProject..CovidVaccinations$
	--order by 3,4

	-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..['Covid Deaths$']
	order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood  of death if you contract Covid in the US

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..['Covid Deaths$']
	Where location like '%states%'
	order by 1,2
	

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (Total_cases/population)*100 as PercentageInfected
	From PortfolioProject..['Covid Deaths$']
	Where location like '%states%'
	order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentageInfected
	From PortfolioProject..['Covid Deaths$']
	--Where location like '%states%'
	Group by Location, Population
	order by PercentageInfected desc


-- Looking at countries with Highest Death Rate compared to Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From PortfolioProject..['Covid Deaths$']
	--Where location like '%states%'
	Where continent is not null
	Group by Location
	order by TotalDeathCount desc

-- Let's break things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From PortfolioProject..['Covid Deaths$']
	--Where location like '%states%'
	Where continent is not null
	Group by continent
	order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	From PortfolioProject..['Covid Deaths$']
	--Where location like '%states%'
	where continent is not null
	Group by date
	order by 1,2

--Total Global Impact of Covid

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	From PortfolioProject..['Covid Deaths$']
	--Where location like '%states%'
	where continent is not null
	--Group by date
	order by 1,2


-- Looking at Total Population vs Vaccinations

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..['Covid Deaths$'] dea
	Join PortfolioProject..CovidVaccinations$ vac
		On dea.location = vac.location
		and dea.date = vac.date
		where dea.continent is not null
		order by 2,3

-- USE CTE

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as 
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..['Covid Deaths$'] dea
	Join PortfolioProject..CovidVaccinations$ vac
		On dea.location = vac.location
		and dea.date = vac.date
		where dea.continent is not null
		--order by 2,3
		)
	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac


	-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..['Covid Deaths$'] dea
	Join PortfolioProject..CovidVaccinations$ vac
		On dea.location = vac.location
		and dea.date = vac.date
		where dea.continent is not null
		--order by 2,3
		
	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View DeathCountByContinent as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From PortfolioProject..['Covid Deaths$']
	Where continent is not null
	Group by continent