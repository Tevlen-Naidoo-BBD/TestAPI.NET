CREATE OR REPLACE PROCEDURE add_pet (
   p_pet_name VARCHAR(32),
   p_pet_status INT DEFAULT 1,
   p_pet_store INT DEFAULT NULL,
   p_pet_image BYTEA DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pet_statuses WHERE pet_status_id = p_pet_status) THEN
        RAISE EXCEPTION 'Pet Status % does not exist', p_pet_status;
    END IF;

    IF (p_pet_store IS NOT NULL) AND (NOT EXISTS (SELECT 1 FROM stores WHERE store_id = p_pet_store)) THEN
        RAISE EXCEPTION 'Pet Store % does not exist', p_pet_status;
    END IF;

    INSERT INTO pets (pet_name, pet_status, pet_store, pet_image)
    VALUES (p_pet_name, p_pet_status, p_pet_store, p_pet_image);

    RAISE NOTICE 'Successfully added pet';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error adding pet: %', SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE update_pet (
    p_pet_id INT,
    p_pet_name VARCHAR(32) DEFAULT NULL,
    p_pet_status INT DEFAULT NULL,
    p_pet_store INT DEFAULT NULL,
    p_pet_image BYTEA DEFAULT NULL,
    p_removed_at TIMESTAMPTZ DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_pet_status IS NOT NULL AND NOT EXISTS (SELECT 1 FROM pet_statuses WHERE pet_status_id = p_pet_status) THEN
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
        removed_at = COALESCE(p_removed_at, removed_at)
    WHERE
        pet_id = p_pet_id;

    RAISE NOTICE 'Successfully updated pet';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error updating pet: %', SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE remove_pet (
    p_pet_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_removed_at TIMESTAMPTZ;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM pets wHERE pet_id = p_pet_id) THEN
        RAISE EXCEPTION 'Pet ID % does not exist', p_pet_id;
    END IF;

    SELECT removed_at INTO v_removed_at FROM pets WHERE pet_id = p_pet_id;

    IF v_removed_at IS NOT NULL THEN
        RAISE EXCEPTION 'This pet has already been removed';
    END IF;

    CALL update_pet(p_pet_id, p_removed_at := NOW());

    RAISE NOTICE 'Successfully removed pet';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error removing pet: %', SQLERRM;

END;
$$;

CREATE OR REPLACE PROCEDURE upload_pet_image (
    p_pet_id INT,
    p_pet_image BYTEA
) LANGUAGE plpgsql AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM pets WHERE pet_id = p_pet_id) THEN
        RAISE EXCEPTION 'Pet ID % does not exist', p_pet_id;
    END IF;

    CALL update_pet(p_pet_id, p_pet_image := p_pet_image);

    RAISE NOTICE 'Successfully uploaded pet image';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error uploading pet image: %', SQLERRM;
            
END;
$$;

CREATE OR REPLACE PROCEDURE add_user (
   p_user_name VARCHAR(16),
   p_user_email VARCHAR(128)
) LANGUAGE plpgsql AS $$
BEGIN

    p_user_name := TRIM(p_user_name);
    p_user_email := TRIM(p_user_email);

    INSERT INTO users (user_name, user_email)
    VALUES (p_user_name, p_user_email);

    RAISE NOTICE 'Successfully added user';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error adding user: %', SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE update_user (
    p_user_id INT,
    p_user_email VARCHAR(128) DEFAULT NULL,
    p_deactivated_at TIMESTAMPTZ DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'User ID % does not exist', p_user_id;
    END IF;

    IF p_user_email IS NULL AND p_user_name IS NULL THEN
        RAISE EXCEPTION 'At least one valid parameter must be passed in';
    END IF;

    IF p_deactivated_at IS NOT NULL AND p_deactivated_at > NOW() THEN
        RAISE EXCEPTION 'Cannot set the deactivation time of a user to be in the future';
    END IF;

    IF p_user_email IS NOT NULL THEN
        p_user_email := TRIM(p_user_email);
    END IF;

    UPDATE users
    SET
        user_email = COALESCE(user_email, p_user_email),
        deactivated_at = COALESCE(deactivated_at, p_deactivated_at)
    WHERE
        user_id = p_user_id;

    RAISE NOTICE 'Successfully updated user';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error updated user: %', SQLERRM;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_user (
    p_user_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_deactivated TIMESTAMPTZ
BEGIN

    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'User ID % does not exist', p_user_id;
    END IF;

    SELECT deactivated_at INTO v_deactivated FROM users WHERE user_id = p_user_id;

    IF v_deactivated IS NOT NULL THEN
        RAISE EXCEPTION 'User % has already been deleted', p_user_id;
    END IF;

    CALL update_user(p_user_id, p_deactivated_at := p_deactivated_at);

    RAISE NOTICE 'Successfully deleted user';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error deleting user: %', SQLERRM;

END;
$$;

CREATE OR REPLACE PROCEDURE add_order (
    p_user_id INT,
    p_pet_id INT
) LANGUAGE plpgsql AS $$
BEGIN

    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'User ID % does not exist', p_user_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pets wHERE pet_id = p_pet_id) THEN
        RAISE EXCEPTION 'Pet ID % does not exist', p_pet_id;
    END IF;

    INSERT INTO orders (user_id, pet_id)
    VALUES (p_user_id, p_pet_id);

    RAISE NOTICE 'Successfully placed order';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error placing order: %', SQLERRM;

END;
$$;

CREATE OR REPLACE PROCEDURE cancel_order (
    p_order_id INT
) LANGUAGE plpgsql AS $$
DECLARE
    v_cancelled INT;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION 'order ID % does not exist', p_order_id;
    END IF;

    SELECT order_status_id INTO v_cancelled FROM order_statuses WHERE order_status_name = 'CANCELLED';

    UPDATE orders
    SET
        order_status = v_cancelled
    WHERE
        order_id = p_order_id;

    RAISE NOTICE 'Successfully cancelled order';

    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION 'Error cancelling order: %', SQLERRM;
            
END;
$$;
