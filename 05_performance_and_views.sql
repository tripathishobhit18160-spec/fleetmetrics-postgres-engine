-- 1. Expression Index on JSONB Speed Field
CREATE INDEX idx_telemetry_speed 
ON telemetry_logs (((sensor_data->>'speed')::INT));

-- 2. Composite B-Tree Index on Trips
CREATE INDEX idx_trips_driver_status 
ON trips (driver_id, status);

-- 3. Query Performance Benchmark Check
EXPLAIN ANALYZE 
SELECT 
    trip_id,
    logged_at,
    (sensor_data->>'speed')::INT AS current_speed
FROM telemetry_logs
WHERE (sensor_data->>'speed')::INT > 80;

-- 4. Create Production Materialized View for Daily Summary
CREATE MATERIALIZED VIEW mv_daily_fleet_summary AS
SELECT 
    DATE(t.start_time) AS trip_date,
    COUNT(t.trip_id) AS total_trips,
    COUNT(CASE WHEN t.status = 'COMPLETED' THEN 1 END) AS completed_trips,
    COUNT(CASE WHEN t.status = 'CANCELLED' THEN 1 END) AS cancelled_trips,
    COALESCE(SUM(t.fare_amount), 0) AS total_revenue_inr,
    COALESCE(ROUND(AVG(t.distance_km), 2), 0) AS avg_distance_km
FROM trips t
GROUP BY DATE(t.start_time)
ORDER BY trip_date DESC;

-- 5. Query Materialized View
SELECT * FROM mv_daily_fleet_summary;