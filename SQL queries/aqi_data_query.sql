USE airpurifier;
-- List the top 5 and bottom 5 areas with highest average AQI.
WITH Avg_Aqi AS (
SELECT Area, 
	   AVG(Aqi_value) AS Avg_aqi
FROM aqi_data
GROUP BY Area),
Ranked_areas AS(
SELECT Area, 
	   Avg_aqi, 
       ROW_NUMBER() OVER(ORDER BY Avg_aqi DESC) AS Top_rank, 
       ROW_NUMBER() OVER(ORDER BY Avg_aqi ASC) AS Bottom_rank  
FROM Avg_Aqi
GROUP BY Area)
SELECT Area, 
	   Avg_aqi,
       CASE 
        WHEN Top_rank <= 5 THEN 'Top 5 (Highest AQI)'
        WHEN Bottom_rank <= 5 THEN 'Bottom 5 (Lowest AQI)'
        END AS Aqi_category
FROM Ranked_areas
WHERE Top_rank <=5 OR Bottom_rank <=5
ORDER BY Avg_aqi DESC;

-- Weekdays vs Weekend aqi in metro cities
WITH weekdays_aqi AS(
SELECT Area,
       Avg(aqi_value) AS Weekday_aqi
FROM aqi_data
WHERE Weekday(Date)<=4
AND Area IN ('Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'Bengaluru', 'Hyderabad', 'Ahmedabad', 'Pune')
GROUP BY Area),
weekend_aqi AS(
SELECT Area,
       Avg(aqi_value) AS Weekend_aqi
FROM aqi_data
WHERE Weekday(Date)>4
AND Area IN ('Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'Bengaluru', 'Hyderabad', 'Ahmedabad', 'Pune')
GROUP BY Area
)
SELECT wd.Area,
	   wd.Weekday_aqi,
       we.Weekend_aqi,
       (wd.Weekday_aqi - we.Weekend_aqi) AS AQI_improvement
FROM weekdays_aqi wd
JOIN weekend_aqi we
ON wd.Area = we.Area
ORDER BY AQI_improvement ;

-- Which months consistently show the worst air quality across Indian states — 
-- (Consider top 10 states with high distinct areas) 
WITH Top10 AS(
SELECT state,
	   COUNT(DISTINCT area) AS area_count
FROM aqi_data
GROUP BY state
ORDER BY COUNT(DISTINCT area) DESC
LIMIT 10
),
Monthwise_aqi AS(
SELECT state,
       MONTH(Date) AS month_number,
       MONTHNAME(Date) AS Month_name,
       AVG(aqi_value) AS avg_aqi
FROM aqi_data
WHERE state IN (
	SELECT state
    FROM Top10)
GROUP BY state,
		 MONTH(Date),
         MONTHNAME(Date)
)
SELECT month_name,
	   ROUND(AVG(avg_aqi),2) AS month_aqi
FROM Monthwise_aqi
GROUP BY month_name
ORDER BY AVG(avg_aqi) DESC;

-- For the metro cities, how many days fell under each air quality category (e.g., Good, Moderate, Poor, etc.) between March and May 2025?
SELECT area,
	   Air_quality_status,
	   COUNT(*) AS Total_days
FROM aqi_data
WHERE area IN ('Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'Bengaluru', 'Hyderabad', 'Ahmedabad', 'Pune')
AND Date BETWEEN '2025-03-01' AND '2025-05-01'
GROUP BY area,
		 Air_quality_status
ORDER BY COUNT(*) DESC;

-- TOP2 AND BOTTOM 2 POLLUTANT
WITH pollutant_counts AS(
SELECT prominent_pollutants, 
       COUNT(prominent_pollutants) AS pollutant_count
FROM aqi_data
GROUP BY prominent_pollutants),
ranked_pollutant AS(
SELECT prominent_pollutants,
	   pollutant_count,
       ROW_NUMBER() OVER(ORDER BY pollutant_count DESC) AS Top_rank, 
       ROW_NUMBER() OVER(ORDER BY pollutant_count ASC) AS Bottom_rank  
FROM pollutant_counts
GROUP BY prominent_pollutants
)
SELECT prominent_pollutants,
	   pollutant_count,
       CASE 
        WHEN Top_rank <= 2 THEN 'Top 2 (Highest Pollutant)'
        WHEN Bottom_rank <= 2 THEN 'Bottom 2 (Lowest Pollutant)'
        END AS Aqi_category
FROM ranked_pollutant
WHERE Top_rank <=2 OR Bottom_rank <=2
ORDER BY  pollutant_count DESC;


