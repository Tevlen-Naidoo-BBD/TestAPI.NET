CREATE OR REPLACE IF EXISTS PROCEDURE add_pet (
    p_pet_name VARCHAR(32),
    p_pet_status INT DEFAULT 1,
    p_pet_store INT DEFAULT NULL,
    p_pet_image BYTEA DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pet_statuses WHERE pet_status_id = p_pet_status) THEN
        RAISE EXCEPTION 'Pet Status % does not exist', p_pet_status;
    END IF;

    IF p_pet_store IS NOT NULL AND NOT EXISTS (SELECT 1 FROM stores WHERE store_id = p_pet_store) THEN
        RAISE EXCEPTION 'Pet Store % does not exist', p_pet_status;
    END IF;

    INSERT INTO pets (pet_name, pet_status, pet_store, pet_image)
    VALUES (p_pet_name, p_pet_status, p_pet_store, p_pet_image);

    RAISE NOTICE 'Successfully added pet';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error adding pet: %', SQLERR;
END;
$$;

CREATE OR REPLACE IF EXISTS PROCEDURE update_pet (
    p_pet_id INT,
    p_pet_name VARCHAR(32),
    p_pet_status INT DEFAULT NULL,
    p_pet_store INT DEFAULT NULL,
    p_pet_image BYTEA DEFAULT NULL,
    p_removed_at TIMESTAMPTZ DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pet_statuses WHERE pet_status_id = p_pet_status) THEN
        RAISE EXCEPTION 'Pet Status % does not exist', p_pet_status;
    END IF;

    IF p_pet_store IS NOT NULL AND NOT EXISTS (SELECT 1 FROM stores WHERE store_id = p_pet_store) THEN
        RAISE EXCEPTION 'Pet Store % does not exist', p_pet_status;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pets wHERE pet_id = p_pet_id) THEN
        RAISE EXCEPTION 'Pet ID % does not exist', p_pet_id;
    END IF;

    UPDATE pets
    SET
        pet_name = COALESCE(p_pet_name, pet_name),
        pet_store = COALESCE(p_pet_store, pet_store),
        pet_status = COALESCE(p_pet_status, pet_status),
        pet_image = COALESCE(p_pet_image, pet_image),
        removed_at = COALESCE(p_removed_at, removed_at),
    WHERE
        pet_id = p_pet_id;

    RAISE NOTICE 'Successfully updated pet';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error updating pet: %', SQLERR;
END;
$$;
