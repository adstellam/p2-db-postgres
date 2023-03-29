CREATE OR REPLACE FUNCTION apiview.insert_into_operation_data()
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
BEGIN
    tabname := 'operation_data';
    EXECUTE format(
        'INSERT INTO norma.%I (work_item_operation_id) VALUES ($1)',
        tabname
    ) USING NEW.id;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_inserted
AFTER INSERT ON norma.work_item_operations
FOR EACH ROW
EXECUTE FUNCTION apiview.insert_into_operation_data();




CREATE OR REPLACE FUNCTION apiview.add_crop_analytics_data_partition()
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
    id TEXT;
BEGIN
    tabname := 'crop_analytics_data_' || NEW.cname;
    id := NEW.code;
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS norma.%I '
        'PARTITION OF norma.crop_analytics_data FOR VALUES IN (%L::uuid)',
        tabname,
        id
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER crop_type_inserted
AFTER INSERT ON norma.crop_types
FOR EACH ROW
EXECUTE FUNCTION apiview.add_crop_analytics_data_partition();




CREATE OR REPLACE FUNCTION apiview.add_machine_obs_pos_telematics_data_partitions()
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
    cname TEXT;
BEGIN
    tabname := 'machine_obs_data_' || NEW.cname;
    cname := NEW.cname;
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS norma.%I '
        'PARTITION OF norma.machine_obs_data FOR VALUES IN (%L)',
        tabname,
        cname
    );
    tabname := 'machine_pos_data_' || NEW.cname;
    cname := NEW.cname;
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS norma.%I '
        'PARTITION OF norma.machine_pos_data FOR VALUES IN (%L)',
        tabname,
        cname
    );
    tabname := 'machine_telematics_data_' || NEW.cname;
    cname := NEW.cname;
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS norma.%I '
        'PARTITION OF norma.machine_telematics_data FOR VALUES IN (%L)',
        tabname,
        cname
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER device_element_inserted
AFTER INSERT ON norma.device_elements
FOR EACH ROW
EXECUTE FUNCTION apiview.add_machine_obs_pos_telematics_data_partitions();




CREATE OR REPLACE FUNCTION apiview.insert_into_or_update_machine_uses()
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
    start_ts TIMESTAMPTZ;
    end_ts TIMESTAMPTZ;
BEGIN
    tabname := 'device_element_uses';
    EXECUTE 
        'SELECT start_time FROM norma.device_element_uses WHERE id = $1'
    INTO start_ts
    USING NEW.machine_use_id;
    EXECUTE 
        'SELECT end_time FROM norma.device_element_uses WHERE id = $1'
    INTO end_ts
    USING NEW.machine_use_id;
    IF machine_use_id IN (SELECT id FROM norma.device_element_uses) THEN
        IF to_timestamp(NEW.gmt_time_s) > end_time THEN
            EXECUTE format(
                'UPDATE norma.%I SET end_time = to_timestamp($1) WHERE id = $2',
                tabname
            ) USING NEW.gmt_time_s, NEW.machine_use_id;
        END IF;
        IF to_timestamp(NEW.gmt_time_s) < start_time THEN
            EXECUTE format(
                'UPDATE norma.%I SET start_time = to_timestamp($1) WHERE id = $2',
                tabname
            ) USING NEW.gmt_time_s, NEW.machine_use_id;
        END IF;
    ELSE
        EXECUTE format(
            'INSERT INTO norma.%I (id, start_time, end_time) VALUES ($1, to_timestamp($2), to_timestamp($3))',
            tabname
        ) USING NEW.machine_use_id, NEW.gmt_time_s, NEW.gmt_time_s;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER machine_obs_data_inserted
AFTER INSERT ON norma.machine_obs_data
FOR EACH ROW
EXECUTE FUNCTION apiview.insert_into_or_update_machine_uses();




/* The followings are for possible future use. */

/*
CREATE OR REPLACE FUNCTION apiview.update_crop_score()
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
    crop_score INT;
    rec RECORD;
BEGIN
    tabname := 'machine_obs_data';
    crop_score := 0;
    FOR rec IN (SELECT factor, weight INTO crop_score FROM norma.crop_score_determinants)
    LOOP
        
    END LOOP;
    EXECUTE format(
        'UPDATE norma.%I SET crop_score = $1', tabname
    ) USING crop_score;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER machine_obs_data_inserted
AFTER INSERT ON norma.machine_obs_data
FOR EACH ROW
EXECUTE FUNCTION apiview.update_crop_score();
*/

/*
CREATE OR REPLACE FUNCTION apiview.insert_crop_analytics_data() 
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
BEGIN
    tabname := 'crop_analytics_data_' || NEW.cname;
    EXECUTE format(
        'INSERT INTO norma.%I SELECT NEW.*',
        tabname
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER crop_analytics_data_inserted
BEFORE INSERT ON norma.crop_analytics_data
FOR EACH ROW
EXECUTE FUNCTION apiview.insert_crop_analytics_data();
*/

/*
CREATE OR REPLACE FUNCTION apiview.insert_device_element_obs_data() 
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
BEGIN
    tabname := 'device_element_obs_data_' || NEW.series;
    EXECUTE format(
        'INSERT INTO norma.%I SELECT NEW.*',
        tabname
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER device_element_obs_data_inserted
BEFORE INSERT ON norma.device_element_obs_data
FOR EACH ROW
EXECUTE FUNCTION apiview.insert_device_element_obs_data();
*/

/*
CREATE OR REPLACE FUNCTION apiview.insert_device_element_telematics_data() 
RETURNS TRIGGER AS
$$
DECLARE
    tabname TEXT;
BEGIN
    tabname := 'device_element_telematics_data_' || NEW.series;
    EXECUTE format(
        'INSERT INTO norma.%I SELECT NEW.*',
        tabname
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER device_element_telematics_data_inserted
BEFORE INSERT ON norma.device_element_telematics_data
FOR EACH ROW
EXECUTE FUNCTION apiview.insert_device_element_telematics_data();
*/