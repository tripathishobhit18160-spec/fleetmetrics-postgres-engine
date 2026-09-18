-- Query 1: Top Performing Drivers Ranking using DENSE_RANK()
WITH DriverMetrics AS (
    SELECT 
        d.driver_id,
        d.first_name || ' ' || d.last_name AS driver_name,
        COUNT(t.trip_id) AS completed_trips,
        COALESCE(SUM(t.fare_amount), 0) AS total_earnings_inr,
        COALESCE(ROUND(AVG(t.distance_km), 2), 0) AS avg_distance_per_trip
    FROM drivers d
    LEFT JOIN trips t ON d.driver_id = t.driver_id AND t.status = 'COMPLETED'
    GROUP BY d.driver_id, d.first_name, d.last_name
)
SELECT 
    driver_name,
    completed_trips,
    total_earnings_inr,
    avg_distance_per_trip,
    DENSE_RANK() OVER (ORDER BY total_earnings_inr DESC) AS revenue_rank
FROM DriverMetrics
ORDER BY revenue_rank;

-- Query 2: JSONB Telemetry Extraction for Overspeeding Events
SELECT 
    t.trip_id,
    d.first_name || ' ' || d.last_name AS driver_name,
    tl.logged_at,
    (tl.sensor_data->>'speed')::INT AS current_speed,
    (tl.sensor_data->>'engine_temp')::INT AS engine_temperature,
    CASE 
        WHEN (tl.sensor_data->>'speed')::INT > 80 THEN 'HIGH_RISK_OVERSPEED'
        WHEN (tl.sensor_data->>'engine_temp')::INT > 105 THEN 'ENGINE_OVERHEAT'
        ELSE 'NORMAL'
    END AS telemetry_alert
FROM telemetry_logs tl
JOIN trips t ON tl.trip_id = t.trip_id
JOIN drivers d ON t.driver_id = d.driver_id
WHERE (tl.sensor_data->>'speed')::INT > 80 
   OR (tl.sensor_data->>'engine_temp')::INT > 105
ORDER BY tl.logged_at DESC
LIMIT 20;

-- Query 3: Driver Fatigue Analysis using LAG()
WITH TripTimeline AS (
    SELECT 
        driver_id,
        trip_id,
        start_time,
        end_time,
        LAG(end_time) OVER (PARTITION BY driver_id ORDER BY start_time) AS previous_trip_end
    FROM trips
    WHERE status = 'COMPLETED'
)
SELECT 
    d.first_name || ' ' || d.last_name AS driver_name,
    tt.trip_id,
    tt.previous_trip_end,
    tt.start_time AS current_trip_start,
    ROUND(EXTRACT(EPOCH FROM (tt.start_time - tt.previous_trip_end)) / 3600, 2) AS rest_time_hours
FROM TripTimeline tt
JOIN drivers d ON tt.driver_id = d.driver_id
WHERE tt.previous_trip_end IS NOT NULL
  AND (tt.start_time - tt.previous_trip_end) < INTERVAL '12 hours'
ORDER BY rest_time_hours ASC;