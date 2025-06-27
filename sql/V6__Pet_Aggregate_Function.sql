CREATE OR REPLACE FUNCTION pet_status_aggregate()
RETURNS TABLE (
    pet_status_name VARCHAR,
    count INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT ps.pet_status_name, COUNT(*) as count
    FROM pets p
    JOIN pet_statuses ps ON p.pet_status = ps.pet_status_id
    WHERE p.removed_at IS NULL
    GROUP BY ps.pet_status_name;
END;
$$ LANGUAGE plpgsql; 