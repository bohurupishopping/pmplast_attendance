-- =============================================================================
-- SIMPLE LOCATION FIX (Alternative to PostGIS)
-- Run this if you get "type geography does not exist" error
-- =============================================================================

-- Option 1: If PostGIS extension is not available, add simple lat/lng columns

-- Add latitude and longitude columns to devices table
ALTER TABLE public.devices 
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;

-- Make location column nullable (if it exists)
ALTER TABLE public.devices 
ALTER COLUMN location DROP NOT NULL;

-- Add lat/lng columns to attendance_logs
ALTER TABLE public.attendance_logs
ADD COLUMN IF NOT EXISTS check_in_latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS check_in_longitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS check_out_latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS check_out_longitude DOUBLE PRECISION;

-- Update the RPC function to use simple lat/lng instead of geography
CREATE OR REPLACE FUNCTION public.log_verified_attendance(
    p_employee_id TEXT,
    p_device_unique_id TEXT,
    p_photo_url TEXT,
    p_longitude FLOAT,
    p_latitude FLOAT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    emp_id uuid;
    dev_id uuid;
    dev_latitude float;
    dev_longitude float;
    log_id bigint;
    emp_full_name text;
    distance_meters float;
BEGIN
    -- Find employee
    SELECT id, full_name INTO emp_id, emp_full_name 
    FROM public.employees 
    WHERE employee_id = p_employee_id AND is_active = TRUE;
    
    IF NOT FOUND THEN 
        RAISE EXCEPTION 'Employee not found or is inactive.'; 
    END IF;

    -- Find device and its location
    SELECT id, latitude, longitude INTO dev_id, dev_latitude, dev_longitude
    FROM public.devices 
    WHERE device_unique_id = p_device_unique_id AND is_active = TRUE;
    
    IF NOT FOUND THEN 
        RAISE EXCEPTION 'Device not registered or is inactive.'; 
    END IF;

    -- Calculate distance using Haversine formula (approximate)
    -- Returns distance in meters
    distance_meters := (
        6371000 * acos(
            cos(radians(dev_latitude)) * 
            cos(radians(p_latitude)) * 
            cos(radians(p_longitude) - radians(dev_longitude)) + 
            sin(radians(dev_latitude)) * 
            sin(radians(p_latitude))
        )
    );

    -- Verify location (within 50 meters)
    IF distance_meters > 50 THEN
        RAISE EXCEPTION 'Location verification failed: Device is % meters from office (max 50m allowed)', 
            ROUND(distance_meters::numeric, 1);
    END IF;

    -- Check for existing open log
    SELECT id INTO log_id 
    FROM public.attendance_logs 
    WHERE employee_id = emp_id 
        AND date = CURRENT_DATE 
        AND check_out_time IS NULL;

    IF log_id IS NOT NULL THEN
        -- CHECK-OUT
        UPDATE public.attendance_logs 
        SET check_out_time = NOW(), 
            check_out_photo_url = p_photo_url,
            check_out_latitude = p_latitude,
            check_out_longitude = p_longitude
        WHERE id = log_id;
        
        RETURN 'Goodbye, ' || emp_full_name || '!';
    ELSE
        -- CHECK-IN
        INSERT INTO public.attendance_logs (
            employee_id, 
            device_id, 
            check_in_time, 
            check_in_photo_url,
            check_in_latitude,
            check_in_longitude,
            date
        )
        VALUES (
            emp_id, 
            dev_id, 
            NOW(), 
            p_photo_url,
            p_latitude,
            p_longitude,
            CURRENT_DATE
        );
        
        RETURN 'Welcome, ' || emp_full_name || '!';
    END IF;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.log_verified_attendance TO anon;
GRANT EXECUTE ON FUNCTION public.log_verified_attendance TO authenticated;
