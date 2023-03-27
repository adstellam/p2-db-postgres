SELECT cron.schedule('update_with_plant_spacing', '0 2 * * *', $$
    DO $1$
    DECLARE
        machine_obs_data_cursor CURSOR FOR 
            SELECT plant_id, machine_use_id, camera_id, plant_line, odometer_meter  
            FROM norma.machine_obs_data 
            WHERE machine_use_id IN (
                SELECT machine_use_id 
                FROM stout.machine_uses
                WHERE start_time > now() - '24 hours'::interval
            )
            ORDER BY machine_use_id, camera_id, plant_line, odometer_meter ASC;
        rec RECORD;
        prev_machine_use_id TEXT;
        prev_camera_id INT;
        prev_plant_line INT;
        prev_odometer_meter REAL;
        plant_spacing_meter REAL;
        tabname TEXT;
    BEGIN
        tabname := 'machine_obs_data';
        prev_machine_use_id := null;
        prev_camera_id := null;
        prev_plant_line := null;
        FOR rec IN machine_obs_cursor LOOP
            IF rec.machine_used_id = prev_machine_use_id AND rec.camera_id = prev_camera_id AND rec.plant_line = prev_plant_line THEN
                plant_spacing_meter := rec.odometer_meter - prev_odometer_meter;
                EXECUTE format(
                    'UPDATE norma.%I SET plant_spacing_meter = $1 WHERE plant_id = $2',
                    tabname
                ) USING plant_spacing_meter, rec.plant_id;
                prev_odometer_meter := rec.odometer_meter;
            ELSE
                prev_machine_use_id := rec.machine_use_id;
                prev_camera_id := rec.camera_id;
                prev_plant_line := rec.plant_line;
                prev_odometer_meter := rec.odometer_meter;
            END IF;
        END LOOP;
    END;
    $1$ LANGUAGE plpgsql;
$$);