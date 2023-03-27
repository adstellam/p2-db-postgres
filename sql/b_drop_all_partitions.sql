DO
$$
DECLARE
    tabname TEXT;
BEGIN
    FOR i IN 2..27 LOOP
        tabname := 'machine_obs_data_' || i;
        EXECUTE format(
            'DROP TABLE norma.%I', tabname
        );
        tabname := 'machine_pos_data_' || i;
        EXECUTE format(
            'DROP TABLE norma.%I', tabname
        );
        tabname := 'machine_telematics_data_' || i;
        EXECUTE format(
            'DROP TABLE norma.%I', tabname
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;