-- 1. Insert 10 Drivers
INSERT INTO drivers (first_name, last_name, license_number, status, rating) VALUES
('Rahul', 'Sharma', 'DL-1420110012345', 'ACTIVE', 4.85),
('Amit', 'Verma', 'DL-1420110054321', 'ON_TRIP', 4.20),
('Suresh', 'Kumar', 'UP-8020120098765', 'ACTIVE', 4.90),
('Vikram', 'Singh', 'MH-0220150011223', 'ON_TRIP', 3.75),
('Priya', 'Nair', 'KL-0720180033445', 'OFFLINE', 4.95),
('Deepak', 'Gupta', 'HR-2620160055667', 'ACTIVE', 4.10),
('Rohan', 'Mehta', 'GJ-0120190077889', 'SUSPENDED', 2.30),
('Karan', 'Joshi', 'UK-0720200099001', 'ON_TRIP', 4.60),
('Manish', 'Yadav', 'BR-0120170022334', 'ACTIVE', 4.40),
('Pooja', 'Mishra', 'WB-0120210044556', 'ACTIVE', 4.80);

-- 2. Insert Vehicles Linked to Drivers
INSERT INTO vehicles (driver_id, license_plate, vehicle_type, fuel_type, max_payload_kg)
SELECT 
    driver_id,
    'IND-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6)) AS license_plate,
    (ARRAY['VAN', 'CONTAINER_TRUCK', 'BIKE', 'MINI_TRUCK'])[FLOOR(RANDOM() * 4 + 1)] AS vehicle_type,
    (ARRAY['DIESEL', 'PETROL', 'EV', 'CNG'])[FLOOR(RANDOM() * 4 + 1)] AS fuel_type,
    (FLOOR(RANDOM() * 5000 + 500))::NUMERIC AS max_payload_kg
FROM drivers;

-- 3. Insert Trips into Partitioned Table
INSERT INTO trips (driver_id, vehicle_id, start_time, end_time, distance_km, fare_amount, status)
SELECT 
    v.driver_id,
    v.vehicle_id,
    start_dt AS start_time,
    start_dt + (RANDOM() * INTERVAL '4 hours' + INTERVAL '20 minutes') AS end_time,
    ROUND((RANDOM() * 150 + 5)::NUMERIC, 2) AS distance_km,
    ROUND((RANDOM() * 3000 + 150)::NUMERIC, 2) AS fare_amount,
    (ARRAY['COMPLETED', 'COMPLETED', 'COMPLETED', 'CANCELLED'])[FLOOR(RANDOM() * 4 + 1)] AS status
FROM vehicles v
CROSS JOIN LATERAL (
    SELECT '2026-01-01 08:00:00+00'::TIMESTAMPTZ + (g * INTERVAL '18 hours' + RANDOM() * INTERVAL '2 hours') AS start_dt
    FROM generate_series(0, 100) g
) sub
WHERE v.driver_id IS NOT NULL;

-- 4. Insert Telemetry Sensor Logs (JSONB Data)
INSERT INTO telemetry_logs (trip_id, logged_at, sensor_data)
SELECT 
    t.trip_id,
    t.start_time + (INTERVAL '1 minute' * s.step) AS logged_at,
    jsonb_build_object(
        'speed', FLOOR(RANDOM() * 60 + 40),
        'engine_temp', FLOOR(RANDOM() * 30 + 80),
        'brake_events', FLOOR(RANDOM() * 5),
        'fuel_level_pct', ROUND((100 - (s.step * 0.5))::NUMERIC, 1)
    ) AS sensor_data
FROM trips t
CROSS JOIN LATERAL generate_series(1, 10) s(step)
WHERE t.status = 'COMPLETED'
LIMIT 5000;