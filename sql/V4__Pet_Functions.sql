CREATE OR REPLACE FUNCTION find_pet (p_pet_id INT)
RETURNS TABLE (
  pet_id INT,
  pet_name VARCHAR(32),
  pet_status INT,
  pet_store INT,
  pet_image BYTEA,
  removed_at TIMESTAMPTZ
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pets WHERE pet_id = p_pet_id) THEN
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

CREATE OR REPLACE FUNCTION find_pets_by_status (p_pet_status INT)
RETURNS TABLE (
  pet_id INT,
  pet_name VARCHAR(32),
  pet_status INT,
  pet_store INT,
  pet_image BYTEA,
  removed_at TIMESTAMPTZ
) AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM pet_statuses WHERE pet_status_id = p_pet_status) THEN
        RAISE EXCEPTION 'Pet Status % does not exist', p_pet_status;
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
    WHERE p.pet_status = p_pet_status;
END;
$$ LANGUAGE plpgsql;