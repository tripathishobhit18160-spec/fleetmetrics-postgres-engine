-- 1. Create Audit Table for Tracking Fare Alterations
CREATE TABLE fare_audit_logs (
    audit_id SERIAL PRIMARY KEY,
    trip_id UUID NOT NULL,
    old_fare NUMERIC(10,2),
    new_fare NUMERIC(10,2),
    modified_by VARCHAR(50) DEFAULT CURRENT_USER,
    modified_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. PL/pgSQL Function for Auditing Fare Changes
CREATE OR REPLACE FUNCTION process_fare_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fare_amount <> OLD.fare_amount THEN
        INSERT INTO fare_audit_logs (trip_id, old_fare, new_fare)
        VALUES (OLD.trip_id, OLD.fare_amount, NEW.fare_amount);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Bind Trigger to Trips Table
CREATE TRIGGER trg_audit_fare_change
BEFORE UPDATE ON trips
FOR EACH ROW
EXECUTE FUNCTION process_fare_audit();