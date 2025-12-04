CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;
select count(*) from country; -- 231

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);
DESC EMISSION_3;
SELECT * FROM EMISSION_3;
select count(*) from EMISSION_3; -- 3515

-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);
DESC POPULATION;
SELECT * FROM POPULATION;
select count(*) from population; -- 1000

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

DESC production;

SELECT * FROM PRODUCTION;
select count(*) from production; -- 5294

-- gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);
DESC GDP_3;
SELECT * FROM GDP_3;
select count(*) from gdp_3; -- 1000

-- consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);
DESC CONSUMPTION;

SELECT * FROM CONSUMPTION;
select count(*) from consumption; -- 5277

-- General & Comparative Analysis


-- What is the total emission per country for the most recent year available?
select country,sum(emission) as totalemissionpercountry
from emission_3
where year= (select max(year) from emission_3)
group by country
order by totalemissionpercountry desc;



-- What are the top 5 countries by GDP in the most recent year?
SELECT COUNTRY ,VALUE FROM GDP_3
WHERE YEAR=(SELECT MAX(YEAR) FROM GDP_3)
ORDER BY value DESC
LIMIT 5;
 

-- Compare energy production and consumption by country and year. 

SELECT P.country, P.year, C.TotalConsumption, P.TotalProduction
FROM 
    -- Calculate Production Totals first
    (SELECT country, year, SUM(production) AS TotalProduction
     FROM production
     GROUP BY country, year) AS P
JOIN 
    -- Calculate Consumption Totals first
    (SELECT country, year, SUM(consumption) AS TotalConsumption
     FROM consumption
     GROUP BY country, year) AS C
-- Join on BOTH Country and Year
ON P.country = C.country AND P.year = C.year
ORDER BY P.country, P.year ;


-- Which energy types contribute most to emissions across all countries?

SELECT energy_type, SUM(EMISSION) AS TOTALEMISSION
FROM emission_3
GROUP BY energy_type
ORDER BY TOTALEMISSION DESC;

-- Trend Analysis Over Time
-- How have global emissions changed year over year?
SELECT YEAR,SUM(emission) AS GOBALEMISSION
FROM EMISSION_3
GROUP BY YEAR
ORDER BY GOBALEMISSION DESC;

-- What is the trend in GDP for each country over the given years?
SELECT Country, Year, Value AS GDP
FROM GDP_3
ORDER BY Country, Year;

-- How has population growth affected total emissions in each country?
SELECT E.country, E.year, P.Value AS Population, E.Total_Emission
FROM (SELECT country, year, SUM(emission) AS Total_Emission 
     FROM emission_3 
     GROUP BY country, year) AS E
JOIN population P 
ON E.country = P.countries AND E.year = P.year      
ORDER BY E.country, E.year;

-- Has energy consumption increased or decreased over the years for major economies?
SELECT c.country, c.year, SUM(c.consumption) AS total_energy_consumption
FROM consumption c
JOIN (SELECT Country FROM gdp_3
    WHERE year = (SELECT MAX(year) FROM gdp_3)
    ORDER BY Value DESC
    LIMIT 5
) AS major_economies ON c.country = major_economies.Country
GROUP BY c.country, c.year
ORDER BY c.country, c.year;

-- What is the average yearly change in emissions per capita for each country?
SELECT country, year,
    per_capita_emission,
    per_capita_emission - LAG(per_capita_emission) OVER (PARTITION BY country ORDER BY year)AS yoy_change
FROM emission_3
ORDER BY country, year;

-- Ratio & Per Capita Analysis
-- What is the emission-to-GDP ratio for each country by year?
SELECT e.country,e.year,SUM(e.emission) AS total_emission,MAX(g.Value) AS gdp,
(SUM(e.emission) / MAX(g.Value)) AS emission_to_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
ON e.country = g.Country AND e.year = g.year
GROUP BY e.country, e.year
ORDER BY e.country, e.year;

-- What is the energy consumption per capita for each country over the last decade?
SELECT 
    c.country, 
    c.year, 
    (SUM(c.consumption) / p.Value) AS consumption_per_capita
FROM consumption c
JOIN population p 
    ON c.country = p.countries AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) - 10 FROM consumption) 
GROUP BY c.country, c.year, p.Value
ORDER BY c.country, c.year;
-- How does energy production per capita vary across countries?
SELECT pr.country, pr.year, (SUM(pr.production) / p.Value) AS production_per_capita
FROM production pr
JOIN population p 
ON pr.country = p.countries AND pr.year = p.year
GROUP BY pr.country, pr.year, p.Value
ORDER BY pr.country, pr.year;
-- Which countries have the highest energy consumption relative to GDP?
SELECT c.country, c.year,SUM(c.consumption) AS total_energy,g.Value AS gdp,
       (SUM(c.consumption) / g.Value) AS energy_intensity
FROM consumption c
JOIN gdp_3 g 
ON c.country = g.Country AND c.year = g.year
WHERE c.year = (SELECT MAX(year) FROM consumption)
GROUP BY c.country, c.year, g.Value
ORDER BY energy_intensity DESC;
-- What is the correlation between GDP growth and energy production growth?
SELECT g.Country,g.Year,g.Value AS GDP,p.TotalProduction
FROM gdp_3 g
JOIN (SELECT country, year, SUM(production) AS TotalProduction FROM production
GROUP BY country, year
) p ON g.Country = p.country AND g.Year = p.year
ORDER BY g.Country, g.Year;
 -- Global Comparisons

-- What are the top 10 countries by population and how do their emissions compare?
SELECT p.countries AS country, p.Value AS population, 
    COALESCE(e.emission, 0) AS total_emission 
FROM
(SELECT countries, Value FROM population  
WHERE year = (SELECT MAX(year) FROM population)) p
LEFT JOIN 
(SELECT country, SUM(emission) as emission  FROM emission_3  
WHERE year = (SELECT MAX(year) FROM emission_3) 
GROUP BY country) e
ON p.countries = e.country
ORDER BY p.Value DESC
LIMIT 10;

-- Which countries have improved (reduced) their per capita emissions the most over the last decade?
SELECT country,(SELECT SUM(per_capita_emission) FROM emission_3 e2 
     WHERE e2.country = e1.country AND year = (SELECT MIN(year) FROM emission_3)) AS start_emission,
    -- Find value at latest year
    (SELECT SUM(per_capita_emission) FROM emission_3 e3 
     WHERE e3.country = e1.country AND year = (SELECT MAX(year) FROM emission_3)) AS end_emission,
    -- Calculate Difference
    (
      (SELECT SUM(per_capita_emission) FROM emission_3 e3 WHERE e3.country = e1.country AND year = (SELECT MAX(year) FROM emission_3)) -
      (SELECT SUM(per_capita_emission) FROM emission_3 e2 WHERE e2.country = e1.country AND year = (SELECT MIN(year) FROM emission_3))
    ) AS total_change
FROM emission_3 e1
GROUP BY country
-- Order by lowest change (most negative = best reduction)
ORDER BY total_change;

-- What is the global share (%) of emissions by country?
SELECT country, SUM(emission) as country_total, (SUM(emission) / SUM(SUM(emission)) OVER()) * 100 as global_share_percentage
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY global_share_percentage DESC;
-- What is the global average GDP, emission, and population by year?

SELECT e.year,AVG(g.Value) as avg_global_gdp,AVG(p.Value) as avg_global_pop,
AVG(total_emission) as avg_global_emission
FROM (
SELECT country, year, SUM(emission) as total_emission 
FROM emission_3 GROUP BY country, year
) e
JOIN gdp_3 g ON e.country = g.Country AND e.year = g.year
JOIN population p ON e.country = p.countries AND e.year = p.year
GROUP BY e.year
ORDER BY e.year;













