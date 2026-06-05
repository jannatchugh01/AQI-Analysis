USE airpurifier;
-- The top 5 states with the highest Electric Vehicle (EV) adoption.
SELECT 
	state,
    SUM(value) AS Total_vehicle
FROM vehicle_registration_data
WHERE Fuel IN ('ELECTRIC(BOV)', 'PURE EV')
GROUP BY 
	state
ORDER BY SUM(value) DESC
LIMIT 5;

-- Avg aqi and ev adoption state wise
WITH vehicle_summary AS (
    SELECT
        state,
        SUM(value) AS total_vehicles
    FROM vehicle_registration_data
    WHERE Fuel IN ('ELECTRIC(BOV)', 'PURE EV')
    GROUP BY state
),

aqi_summary AS (
    SELECT
        state,
        AVG(aqi_value) AS avg_aqi
    FROM aqi_data
    GROUP BY state
)

SELECT
    v.state,
    ROUND(a.avg_aqi, 2) AS avg_aqi,
    v.total_vehicles
FROM vehicle_summary v
JOIN aqi_summary a
ON v.state = a.state
ORDER BY v.total_vehicles DESC;
