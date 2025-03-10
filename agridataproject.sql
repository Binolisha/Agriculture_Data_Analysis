select * from cropdetails;
/*Year-wise Trend of Rice Production Across States (Top 3)*/
with state_ranking as (select state_name,round(sum(rice_production_1_ton),2) as tot_production from cropdetails group by state_name order by tot_production desc limit 3)
select a.year,a.state_name,round(sum(a.rice_production_1_ton),2) as production_over_year_in_tons from cropdetails as a join state_ranking as b on a.state_name = b.state_name 
group by a.year,a.state_name ;
/*Top 5 Districts by Wheat Yield Increase Over the Last 5 Years*/
with district_ranking as (select dist_name,round(sum(wheat_yield_ton_per_ha),2) as tot_yield from cropdetails group by dist_name order by tot_yield desc limit 5)
select a.year,a.dist_name,round(sum(a.wheat_yield_ton_per_ha),2) as yield_per_year from cropdetails a join district_ranking b on a.dist_name=b.dist_name 
group by a.year,a.dist_name
having a.year between 2013 and 2017;
/*States with the Highest Growth in Oilseed Production (5-Year Growth Rate)*/
WITH ProductionByStateAndYear AS (SELECT state_name, year, SUM(oilseeds_production_1_ton) as total_production
    FROM cropdetails GROUP BY state_name, year),
ProductionWithLag AS (SELECT p1.state_name, p1.year, p1.total_production as current_production,p2.total_production as previous_production 
    FROM ProductionByStateAndYear p1 LEFT JOIN ProductionByStateAndYear p2 ON p1.state_name = p2.state_name AND p1.year = p2.year + 5
    WHERE p1.year = (SELECT MAX(year) FROM ProductionByStateAndYear) )
SELECT state_name, ((current_production - previous_production) * 100.0 / previous_production) as growth_rate
FROM ProductionWithLag ORDER BY growth_rate DESC limit 3;
/*District-wise Correlation Between Area and Production for Major Crops (Rice, Wheat, and Maize)*/
SELECT dist_name,round(sum(rice_area_1_ha),2)as total_area_rice,round(sum(rice_production_1_ton),2) as total_production_rice,
round(sum(wheat_area_1_ha),2) as total_area_wheat,round(sum(wheat_production_1_ton),2) as total_production_wheat,
round(sum(maize_area_1_ha),2) as total_area_maize,round(sum(maize_production_1_ton),2) as total_production_maize from cropdetails group by dist_name ;
/*Yearly Production Growth of Cotton in Top 5 Cotton Producing States*/
WITH RankedCottonProduction AS (SELECT state_name, year, round(SUM(cotton_production_1_ton),2) AS total_cotton_production,
        RANK() OVER (PARTITION BY year ORDER BY SUM(cotton_production_1_ton) DESC) AS state_rank FROM cropdetails GROUP BY state_name,year),
LaggedProduction AS (SELECT state_name,year,
        total_cotton_production,
        LAG(total_cotton_production, 1, 0) OVER (PARTITION BY state_name ORDER BY year) AS previous_year_production FROM RankedCottonProduction
        WHERE state_rank <= 5)
SELECT state_name, year, total_cotton_production,(total_cotton_production - previous_year_production) * 100.0 / previous_year_production AS growth_rate
FROM LaggedProduction ORDER BY state_name,year;
/*Districts with the Highest Groundnut Production in 2017*/
select dist_name,round(sum(groundnut_production_1_ton),2) as total_production from cropdetails where year=2017 group by dist_name 
 order by total_production desc limit 20;
 /*Annual Average Maize Yield Across All States*/
 select year,state_name,round(avg(maize_yield_ton_per_ha),2) as average_maize_yield from cropdetails where year between 2000 and 20017 group by year,state_name ;
 /*Total Area Cultivated for Oilseeds in Each State*/
 select state_name, round(sum(oilseeds_area_1_ha),2) as total_area_cultivated_for_oilseeds from cropdetails group by state_name 
 order by total_area_cultivated_for_oilseeds desc;
/*Districts with the Highest Rice Yield*/
select dist_name, round(sum(rice_yield_ton_per_ha),2) as highest_rice_yield from cropdetails group by dist_name 
order by highest_rice_yield desc limit 20;
/*Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years*/
select a.year,a.state_name, round(sum(a.rice_production_1_ton),2) as rice_production,round(sum(a.wheat_production_1_ton),2) as wheat_production
from cropdetails  as a join (select state_name from cropdetails where year >= (select max(year)-9 from cropdetails) group by state_name 
order by sum(rice_production_1_ton)+sum(wheat_production_1_ton) desc limit 5)  as top_states ON a.state_name = top_states.state_name
WHERE a.year >= (SELECT MAX(year) - 9 FROM cropdetails)  GROUP BY a.year, a.state_name
ORDER BY a.year, a.state_name;


