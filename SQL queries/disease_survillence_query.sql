USE airpurifier;
-- List the top two most reported disease illnesses in each state over the past three years, 
-- along with the corresponding average Air Quality Index (AQI) for that period.
WITH disease_summary AS (
    SELECT 
        state,
        Disease_illness_name,
        SUM(Cases) AS total_cases,
        RANK() OVER (
            PARTITION BY state
            ORDER BY SUM(Cases) DESC
        ) AS disease_rank
    FROM disease_surveillance_data
    WHERE Year BETWEEN '2022' AND '2025'
    GROUP BY 
        state,
        Disease_illness_name
),

aqi_summary AS (
    SELECT 
        state,
        AVG(Aqi_value) AS avg_aqi
    FROM aqi_data
    WHERE YEAR(Date) BETWEEN '2022' AND '2025'
    GROUP BY state
)

SELECT 
    d.state,
    d.Disease_illness_name,
    d.total_cases,
    ROUND(a.avg_aqi,2) AS avg_aqi
FROM disease_summary d
JOIN aqi_summary a
ON d.state = a.state
WHERE d.disease_rank <= 2
ORDER BY 
    d.state,
    d.total_cases DESC;
    
-- Analyze how severe AQI spikes correlate with specific health burdens, 
-- particularly looking for trends in pediatric asthma admissions or respiratory outbreaks
WITH aqi_spike AS(
	SELECT 
		state,
        YEAR(Date) AS aqi_year,
        MONTH(Date) AS aqi_month,
        MAX(aqi_value) AS peak_aqi,
        AVG(aqi_value) AS avg_aqi
	FROM aqi_data
    WHERE aqi_value > 200
    GROUP BY 
		state,
        YEAR(Date),
        MONTH(Date) 
		),
	respiratory_outbreak AS (
		SELECT 
			state,
            Year AS outbreak_year,
			MONTH(STR_TO_DATE(Reporting_date, '%d-%m-%Y')) AS outbreak_month,
			SUM(Cases) AS total_respiratory_cases
		FROM disease_surveillance_data
		WHERE Disease_illness_name LIKE '%Respirat%' 
		OR Disease_illness_name LIKE '%Asthma%'
		GROUP BY State, Year, outbreak_month
)
SELECT 
    a.State,
    a.aqi_year AS Year,
    a.aqi_month AS Month,
    a.peak_aqi AS Peak_AQI_Value,
    a.avg_aqi AS Monthly_Avg_AQI,
    COALESCE(r.total_respiratory_cases, 0) AS Total_Respiratory_Cases
FROM AQI_Spike a
LEFT JOIN Respiratory_Outbreak r 
    ON a.State = r.State 
    AND a.aqi_year = r.outbreak_year 
    AND a.aqi_month = r.outbreak_month
ORDER BY a.peak_aqi DESC;
    