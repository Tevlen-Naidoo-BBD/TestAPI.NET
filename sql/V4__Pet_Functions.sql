CREATE OR REPLACE IF EXISTS FIND_PET (p_pet_id INT)
RETURNS TABLE (
  pet_id INT,
  pet_name VARCHAR(32),
  pet_status INT,
  pet_store INT,
  pet_image BYTEA,
  removed_at TIMESTAMPTZ
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pets wHERE pet_id = p_pet_id) THEN
        RAISE EXCEPTION 'Pet ID % does not exist', p_pet_id;
    END IF;
    
    RETURN QUERY
    SELECT
        p.pet_id,
        p.pet_name,
        ps.pet_status_name AS pet_status,
        pst.pet_store_name AS pet_store,
        p.pet_image
    FROM pets p
    INNER JOIN pet_statuses ps ON p.pet_status = ps.pet_status_id
    INNER JOIN pet_storees ps ON p.pet_store = ps.pet_store_id
    WHERE p.pet_id = p_pet_id;
END;
$$ LANGUAGE plpgsql;