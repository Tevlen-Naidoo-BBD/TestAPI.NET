CREATE OR REPLACE FUNCTION find_pet (p_pet_id INT)
RETURNS TABLE (
  "PetId" INT,
  "PetName" VARCHAR(32),
  "PetStore" VARCHAR(64),
  "PetStatus" VARCHAR(32)
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pets p WHERE p.pet_id = p_pet_id) THEN
        RAISE EXCEPTION 'Pet ID % does not exist', p_pet_id;
    END IF;
    
    RETURN QUERY
    SELECT
        p.pet_id AS "PetId",
        p.pet_name AS "PetName",
        s.store_name AS "PetStore",
        ps.pet_status_name AS "PetStatus"
    FROM pets p
    INNER JOIN pet_statuses ps ON p.pet_status = ps.pet_status_id
    LEFT JOIN stores s ON p.pet_store = s.store_id
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

CREATE OR REPLACE FUNCTION find_user (p_user_name VARCHAR(16))
RETURNS TABLE (
    user_id INT,
    user_name VARCHAR(16)
) LANGUAGE plpgsql AS $$
BEGIN

    RETURN QUERY
    SELECT
        user_id,
        user_name
    FROM users
    WHERE user_name = p_user_name;
END;
$$;

CREATE OR REPLACE FUNCTION get_order (p_order_id INT)
RETURNS TABLE (
    order_id INT,
    user_name VARCHAR(16),
    pet_name VARCHAR(32),
    order_status VARCHAR(16)
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION 'Order ID % does not exist', p_order_id;
    END IF;
    
    RETURN QUERY
    SELECT
        o.order_id,
        u.user_name,
        p.pet_name,
        os.order_status_name AS order_status
    FROM orders o
    INNER JOIN users u ON o.user_id = u.user_id
    INNER JOIN pets p ON o.pet_id = p.pet_id
    INNER JOIN order_statuses os ON o.order_status = os.order_status_id
    WHERE o.order_id = p.order_id;

END;
$$ LANGUAGE plpgsql;