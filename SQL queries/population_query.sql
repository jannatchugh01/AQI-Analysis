--  Analyse states population size and avg_aqi for last 3 years
WITH avg_aqi_data AS(
	SELECT
		state,
        YEAR(Date) AS aqi_year,
        ROUND(AVG(aqi_value),2) AS avg_aqi
	FROM aqi_data 
    WHERE YEAR(date) BETWEEN '2022' AND '2025'
    GROUP BY state, YEAR(Date)
    ),
Population AS(
	SELECT 
		Year,
        state,
        SUM(value) AS Total_population
	FROM population_projections
    WHERE Year BETWEEN '2022' AND '2025'
    AND Gender = 'Total'
    GROUP BY state, Year
    )
SELECT
	a.state,
    a.aqi_year,
    a.avg_aqi,
    p.Total_population
FROM avg_aqi_data a
JOIN population p
ON a.state = p.state

   
        