-- PostgreSQL Extension Setup
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Drivers Table
CREATE TABLE drivers (
    driver_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    license_number VARCHAR(30) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'ON_TRIP', 'OFFLINE', 'SUSPENDED')),
    rating NUMERIC(3,2) CHECK (rating >= 1.00 AND rating <= 5.00),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Vehicles Table
CREATE TABLE vehicles (
    vehicle_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID REFERENCES drivers(driver_id) ON DELETE SET NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(30) NOT NULL,
    fuel_type VARCHAR(20) NOT NULL,
    max_payload_kg NUMERIC(8,2),
    is_active BOOLEAN DEFAULT TRUE
);

-- 3. Partitioned Trips Table (Range Partitioning)
CREATE TABLE trips (
    trip_id UUID DEFAULT uuid_generate_v4(),
    driver_id UUID NOT NULL REFERENCES drivers(driver_id),
    vehicle_id UUID NOT NULL REFERENCES vehicles(vehicle_id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    distance_km NUMERIC(8,2),
    fare_amount NUMERIC(10,2),
    status VARCHAR(20) DEFAULT 'SEARCHING' CHECK (status IN ('SEARCHING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    PRIMARY KEY (trip_id, start_time)
) PARTITION BY RANGE (start_time);

-- 4. Partitions for 2026
CREATE TABLE trips_2026_q1 PARTITION OF trips
    FOR VALUES FROM ('2026-01-01 00:00:00+00') TO ('2026-04-01 00:00:00+00');

CREATE TABLE trips_2026_q2 PARTITION OF trips
    FOR VALUES FROM ('2026-04-01 00:00:00+00') TO ('2026-07-01 00:00:00+00');

CREATE TABLE trips_2026_q3 PARTITION OF trips
    FOR VALUES FROM ('2026-07-01 00:00:00+00') TO ('2026-10-01 00:00:00+00');

CREATE TABLE trips_2026_q4 PARTITION OF trips
    FOR VALUES FROM ('2026-10-01 00:00:00+00') TO ('2027-01-01 00:00:00+00');

-- 5. Telemetry Logs Table (JSONB format)
CREATE TABLE telemetry_logs (
    log_id BIGSERIAL PRIMARY KEY,
    trip_id UUID NOT NULL,
    logged_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    sensor_data JSONB NOT NULL
);