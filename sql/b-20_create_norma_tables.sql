CREATE TABLE IF NOT EXISTS norma.growers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    contact_info adapt.contact_info_record,
    context_items adapt.context_item_record[]
); 

CREATE TABLE IF NOT EXISTS norma.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT
);

CREATE TABLE IF NOT EXISTS norma.manufacturers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT, 
    context_items adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT, 
    manufacturer_id UUID REFERENCES norma.manufacturers (id),
    context_items adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.crop_types (
    code TEXT PRIMARY KEY,
    cname TEXT NOT NULL,
    parent_code TEXT REFERENCES norma.crop_types (code),
    reference_weight REAL,
    standard_payable_moisture REAL,
    genetically_enhanced BOOLEAN,
    traits adapt.trait_record[],
    context_items adapt.context_item_record[]
);    

CREATE TABLE IF NOT EXISTS norma.facilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT,
    organization_id UUID REFERENCES norma.organizations (id),
    parent_facility_id UUID REFERENCES norma.facilities (id),
    facility_type TEXT,
    contact_info adapt.contact_info_record, 
    context_items adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rolename TEXT,
    organization_id UUID REFERENCES norma.organizations(id),
    role_permissions JSON,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE NOT NULL,
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    role_ids UUID[] NOT NULL,
    last_name TEXT,
    first_name TEXT,
    affiliated_entity TEXT NOT NULL,
    job_title TEXT,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.farms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    grower_id UUID REFERENCES norma.growers (id),
    permitee TEXT,
    permit_number TEXT,
    bounding_region GEOMETRY(MULTIPOLYGON,4326) NOT NULL,
    contct_info adapt.contact_info_record
);

CREATE TABLE IF NOT EXISTS norma.fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    farm_id UUID REFERENCES norma.farms (id) NOT NULL,
    active_boundary_id UUID NOT NULL,
    area_in_sq_meters REAL, 
    aspect REAL,
    slope REAL,
    slope_length REAL,
    archived BOOLEAN DEFAULT false,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ,
    context_items adapt.context_item_record[] DEFAULT ARRAY[]::adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.field_boundaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_id UUID REFERENCES norma.fields (id) NOT NULL,
    geom GEOMETRY(MULTIPOLYGON, 4326),
    original_epsg_code TEXT,
    interior_boundary_attributes adapt.interior_boundary_attribute_record[] DEFAULT ARRAY[]::adapt.interior_boundary_attribute_record[],
    headlands adapt.headland_record[] DEFAULT ARRAY[]::adapt.headland_record[],
    archived BOOLEAN DEFAULT false,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ,
    context_items adapt.context_item_record[] DEFAULT ARRAY[]::adapt.context_item_record[]
);

/*ALTER TABLE norma.field_boundaries ADD CONSTRAINT field_boundaries_field_id_fkey FOREIGN KEY (field_id) REFERENCES norma.fields (id);*/
ALTER TABLE norma.fields ADD CONSTRAINT fields_active_boundary_id_fkey FOREIGN KEY (active_boundary_id) REFERENCES norma.field_boundaries (id);


CREATE TABLE IF NOT EXISTS norma.crop_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    field_id UUID REFERENCES norma.fields (id) NOT NULL,
    crop_season TEXT NOT NULL,
    crop_code TEXT REFERENCES norma.crop_types (code) NOT NULL,
    bounding_region GEOMETRY(MULTIPOLYGON, 4326) NOT NULL,
    area_in_sq_meters REAL GENERATED ALWAYS AS (st_area(bounding_region::geography)) STORED,
    seed_type TEXT,
    wet_date DATE NOT NULL,
    calculated_harvest_date DATE,
    estimated_harvest_date DATE,
    harvest_date DATE,
    gps_source adapt.gps_source_record,
    notes TEXT[],
    archived BOOLEAN DEFAULT false,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.crop_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    crop_id TEXT NOT NULL,
    machine_name TEXT NOT NULL,
    camera_id INT,
    image_binary BYTEA DEFAULT '\x00'::bytea,
    image_annotations JSON,
    image_ts TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS norma.crop_analytics_data (
    crop_id TEXT NOT NULL,
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    grower_id UUID REFERENCES norma.growers (id) NOT NULL,
    crop_season TEXT NOT NULL,
    crop_zone_id UUID REFERENCES norma.crop_zones (id) NOT NULL,
    crop_code TEXT REFERENCES norma.crop_types (code) NOT NULL,
    crop_position GEOMETRY(Point, 4326) NOT NULL,
    irrigation_records stout.irrigation_record[] DEFAULT ARRAY[]::stout.irrigation_record[],
    cultivation_records stout.cultivation_record[] DEFAULT ARRAY[]::stout.cultivation_record[],
    application_records stout.application_record[] DEFAULT ARRAY[]::stout.application_record[],
    crop_measure_records stout.crop_measure_record[] DEFAULT ARRAY[]::stout.crop_measure_record[],
    insect_infestation_records stout.insect_infestation_record[] DEFAULT ARRAY[]::stout.insect_infestation_record[],
    fungal_infestation_records stout.fungal_infestation_record[] DEFAULT ARRAY[]::stout.fungal_infestation_record[],
    viral_infestation_records stout.viral_infestation_record[] DEFAULT ARRAY[]::stout.viral_infestation_record[],
    wet_date DATE,
    reject_date DATE,
    harvest_date DATE,
    CONSTRAINT crop_analytics_data_pkey PRIMARY KEY (crop_id, crop_code)
) PARTITION BY LIST (crop_code);

CREATE TABLE IF NOT EXISTS norma.work_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    work_order_version INT,
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    grower_id UUID REFERENCES norma.growers (id) NOT NULL,
    work_order_manager_id UUID REFERENCES norma.users (id),
    crop_season TEXT NOT NULL,
    crop_code TEXT REFERENCES norma.crop_types (code) NOT NULL,
    field_id UUID REFERENCES norma.fields (id) NOT NULL,
    status_updates adapt.status_update_record[] DEFAULT ARRAY[]::adapt.status_update_record[],
    archived BOOLEAN DEFAULT false,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ,
    context_items adapt.context_item_record[] DEFAULT ARRAY[]::adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.work_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    work_order_id UUID REFERENCES norma.work_orders (id) NOT NULL,
    crop_zone_id UUID REFERENCES norma.crop_zones (id) NOT NULL,
    work_item_supervisor_id UUID REFERENCES norma.users (id),
    operation_types adapt.operation_type_enum[] NOT NULL,
    work_item_status adapt.work_status_enum DEFAULT 'Scheduled',
    work_item_priority adapt.work_item_priority_enum DEFAULT 'AsSoonAsPossible',
    proposed_start_date DATE NOT NULL,
    proposed_end_date DATE NOT NULL,
    actual_start_date DATE,
    actual_end_date DATE,
    notes TEXT[],
    archived BOOLEAN DEFAULT false,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.device_elements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    brand_id UUID REFERENCES norma.brands (id) NOT NULL,
    device_element_type adapt.device_element_type_enum NOT NULL,
    device_classification TEXT,
    device_model TEXT,
    series INT,
    serial_number TEXT,
    active_configuration_id UUID,
    inet_domain_name TEXT,
    parent_device_id UUID REFERENCES norma.device_elements (id),
    archived BOOLEAN DEFAULT false,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.work_item_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    work_item_id UUID REFERENCES norma.work_items (id) NOT NULL,
    device_element_id UUID REFERENCES norma.device_elements (id) NOT NULL,
    operator_id UUID REFERENCES norma.users (id),
    operation_type adapt.operation_type_enum NOT NULL,
    work_item_operation_status adapt.work_status_enum,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    notes TEXT[],
    archived bOOLEAN DEFAULT false,
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.guidance_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT,
    bounding_polygon GEOMETRY(Polygon,4326)
);

CREATE TABLE IF NOT EXISTS norma.guidance_allocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    crop_zone_id UUID REFERENCES norma.crop_zones (id),
    guidance_group_id UUID REFERENCES norma.guidance_groups (id),
    guidance_shift adapt.guidance_shift_record,
    crop_season TEXT
);

CREATE TABLE IF NOT EXISTS norma.guidance_patterns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT,
    guidance_group_id UUID REFERENCES norma.guidance_groups (id),
    bounding_polygon GEOMETRY(MULTIPOLYGON, 4326),
    guidance_pattern_type adapt.guidance_pattern_type_enum,
    extension adapt.guidance_extension_enum,
    propagation_direction adapt.propagation_direction_enum,
    number_of_swaths_left INT,
    number_of_swaths_right INT,
    swath_width REAL,
    gps_source adapt.gps_source_enum,
    original_epsg_code TEXT
); 

CREATE TABLE IF NOT EXISTS norma.om_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code_key TEXT,
    code_val TEXT,
    context_items adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.obs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    om_code_id UUID REFERENCES norma.om_codes (id),
    val TEXT,
    spatial_extent GEOMETRY(Polygon, 4326),
    date_obs DATE,
    context_items adapt.context_item_record[]
); 

CREATE TABLE IF NOT EXISTS norma.operation_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    work_item_operation_id UUID REFERENCES norma.work_item_operations (id) NOT NULL,
    spatial_records adapt.spatial_record[] DEFAULT ARRAY[]::adapt.spatial_record[],
    data_log_trigger_record adapt.data_log_trigger_record,
    coincident_operation_data_ids UUID[],
    max_depth INT,
    variety_locator_id INT,
    context_items adapt.context_item_record[] DEFAULT ARRAY[]::adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.device_element_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_element_id UUID REFERENCES norma.device_elements (id) NOT NULL,
    machine_configuration adapt.machine_configuration_record,
    implement_configuration adapt.implement_configuration_record,
    section_configuration adapt.section_configuration_record,
    offsets REAL[],
    created TIMESTAMPTZ NOT NULL,
    updated TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.device_element_uses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alt_id TEXT,
    operation_data_id UUID REFERENCES norma.operation_data (id),
    use_order INT,
    use_depth INT,
    device_element_configuration_id UUID REFERENCES norma.device_element_configurations (id),
    travel_distance_meter INT,
    work_distance_meter INT,
    elapsed_time_seconds INT,
    work_time_seconds INT,
    crop_count INT,
    crop_counts_by_size JSON,
    crop_counts_by_score JSON,
    crop_counts_by_spacing JSON,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS norma.machine_config_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    machine_name TEXT NOT NULL,
    machine_use_id UUID,
    machine_use_id_alt TEXT,
    width_meter REAL,
    plant_line_count INT,
    line_spacing_meter REAL,
    plant_spacing_meter REAL,
    buffer_distance_meter REAL,
    lens_working_dist_meter REAL,
    max_side_shift_travel_meter REAL,
    fov_height_degree REAL,
    detection_rate_threshold REAL
);

CREATE TABLE IF NOT EXISTS norma.machine_obs_data (
    plant_id UUID NOT NULL DEFAULT gen_random_uuid(),
    machine_name TEXT NOT NULL,
    camera_id INT,
    crop_zone_id UUID REFERENCES norma.crop_zones (id),
    gmt_time_s DOUBLE PRECISION NOT NULL,
    machine_use_id UUID,
    machine_use_id_alt TEXT,
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    klass INT NOT NULL,
    confidence REAL,
    width_meter REAL,
    height_meter REAL,
    odometer_meter REAL,
    plant_line INT,
    insect_infestation_type TEXT,
    insect_infestation_severity TEXT,
    insect_infestation_infested_area_percentage INT,
    fungal_infestation_type TEXT,
    fungal_infestation_severity TEXT,
    fungal_infestation_infested_area_percentage INT,
    viral_infestation_type TEXT,
    viral_infestation_severity TEXT,
    viral_infestation_infested_area_percentage INT,
    crop_score INT,
    plant_spacing_meter REAL,
    CONSTRAINT device_element_obs_data_pkey PRIMARY KEY (plant_id, machine_name)
) PARTITION BY LIST (machine_name);

CREATE TABLE IF NOT EXISTS norma.machine_pos_data (
    machine_name TEXT NOT NULL,
    gmt_time_s DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    heading REAL,
    itow INT,
    CONSTRAINT device_element_pos_data_pkey PRIMARY KEY (machine_name, gmt_time_s)
) PARTITION BY LIST (machine_name);

CREATE TABLE IF NOT EXISTS norma.machine_telematics_data (
    machine_name TEXT NOT NULL,
    gmt_time_s DOUBLE PRECISION NOT NULL,
    lifted BOOLEAN,
    odometer_meter_per_second REAL,
    odometer_meter REAL,
    oil_temp_celcius REAL,
    voltage REAL,
    CONSTRAINT device_element_telematics_data_pkey PRIMARY KEY (machine_name, gmt_time_s)
) PARTITION BY LIST (machine_name);

CREATE TABLE IF NOT EXISTS norma.prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT,
    work_item_operation_id UUID REFERENCES norma.work_item_operations (id),
    rx_type adapt.prescription_type_enum,
    rx_recipes stout.prescription_recipe_record[],
    vector_rx_detail adapt.vector_prescription_record,
    raster_grid_rx_detail adapt.raster_grid_prescription_record,
    radial_rx_detail adapt.radial_prescription_record,
    manual_rx_detail adapt.manual_prescription_record,
    prescriber UUID REFERENCES norma.users (id),
    created TIMESTAMPTZ,
    updated TIMESTAMPTZ,
    context_items adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT,
    brand_id UUID REFERENCES norma.brands (id),
    category adapt.category_enum,
    product_type adapt.product_type_enum,
    product_form adapt.product_form_enum,
    product_components adapt.product_component_record[],
    density REAL,
    has_crop_nutrition BOOLEAN,
    has_crop_protection BOOLEAN,
    has_crop_variety BOOLEAN,
    has_harvested_commodity BOOLEAN,
    product_status adapt.product_status_enum,
    context_items adapt.context_item_record[]
);

CREATE TABLE IF NOT EXISTS norma.reference_layers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cname TEXT NOT NULL,
    notes TEXT[],
    organization_id UUID REFERENCES norma.organizations (id) NOT NULL,
    layer_type adapt.reference_layer_type_enum NOT NULL,
    source_format adapt.reference_layer_source_format_enum NOT NULL,
    source_date DATE,
    vector_source JSONB,
    raster_source BYTEA,
    bounding_polygon GEOMETRY(Polygon, 4326)
);


DO
$$
DECLARE
    crop_types_cursor CURSOR FOR SELECT code, cname FROM norma.crop_types;
    rec RECORD;
    tabname TEXT;
    id TEXT;
BEGIN
    FOR rec IN crop_types_cursor LOOP
        tabname := 'crop_analytics_data_' || rec.cname;
        id := rec.code;
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS norma.%I '
            'PARTITION OF norma.crop_analytics_data FOR VALUES IN (%L::uuid)',
            tabname,
            id
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;


DO
$$
DECLARE
    device_elements_cursor CURSOR FOR SELECT id, cname FROM norma.device_elements;
    rec RECORD;
    tabname TEXT;
    cname TEXT;
BEGIN
    FOR rec IN device_elements_cursor LOOP
        cname := rec.cname;
        tabname := 'machine_obs_data_' || rec.cname;
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS norma.%I '
            'PARTITION OF norma.machine_obs_data FOR VALUES IN (%L)',
            tabname,
            cname
        );
        tabname := 'machine_pos_data_' || rec.cname;
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS norma.%I '
            'PARTITION OF norma.machine_pos_data FOR VALUES IN (%L)',
            tabname,
            cname
        );
        tabname := 'machine_telematics_data_' || rec.cname;
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS norma.%I '
            'PARTITION OF norma.machine_telematics_data FOR VALUES IN (%L)',
            tabname,
            cname
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;


DO
$$
DECLARE
    machine_obs_data_cursor CURSOR FOR SELECT plant_id, width_meter FROM norma.machine_obs_data;
    rec RECORD;
    tabname TEXT;
BEGIN
    tabname := 'machine_obs_data';
    FOR rec IN machine_obs_data_cursor LOOP
        EXECUTE format(
            'UPDATE norma.%I SET crop_score = $1 WHERE plant_id = $2',
            tabname
        ) USING floor(rec.width_meter*200), rec.plant_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;



/* XXX: FIXME: @MichaelSuh what is this used for? it does not run */
/*
DO
$$
DECLARE
    machine_obs_data_cursor CURSOR FOR SELECT plant_id, machine_use_id FROM norma.machine_obs_data WHERE machine_use_id LIKE 'CULTIVATOR-%';
    rec RECORD;
    tabname TEXT;
BEGIN
    tabname := 'machine_obs_data';
    FOR rec IN machine_obs_data_cursor LOOP
        EXECUTE format(
            'UPDATE norma.%I SET machine_use_id = lower($1) WHERE plant_id = $2;',
            tabname
        ) USING rec.machine_use_id, rec.plant_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
*/




DO
$$
DECLARE
    machine_obs_data_cursor CURSOR FOR SELECT plant_id, machine_use_id, gmt_time_s FROM norma.machine_obs_data WHERE machine_use_id IS NOT NULL;
    rec RECORD;
    ts RECORD;
    ctr INT;
    tabname TEXT;
BEGIN
    ctr := 0;
    tabname := 'device_element_uses';
    FOR rec IN machine_obs_data_cursor LOOP
        ctr := ctr + 1;
        RAISE NOTICE '%: machine_use_id: %', ctr, rec.machine_use_id;
        EXECUTE 
            'SELECT start_time, end_time FROM norma.device_element_uses WHERE id = $1'
        INTO ts
        USING rec.machine_use_id;
        IF rec.machine_use_id IN (SELECT id FROM norma.device_element_uses) THEN
            IF ts.end_time IS NOT NULL THEN
                IF to_timestamp(rec.gmt_time_s) > ts.end_time THEN
                    EXECUTE format(
                        'UPDATE norma.%I SET end_time = to_timestamp($1) WHERE id = $2',
                        tabname
                    ) USING rec.gmt_time_s, rec.machine_use_id;
                    RAISE NOTICE 'updated 1 --- %', rec.machine_use_id;
                ELSE
                    RAISE NOTICE 'pass 1';
                END IF;
            ELSE
                EXECUTE format(
                    'UPDATE norma.%I SET end_time = to_timestamp($1) WHERE id = $2',
                    tabname
                ) USING rec.gmt_time_s, rec.machine_use_id;
                RAISE NOTICE 'updated 1A --- %', rec.machine_use_id;
            END IF;
            IF ts.start_time IS NOT NULL THEN
                IF to_timestamp(rec.gmt_time_s) < ts.start_time THEN
                    EXECUTE format(
                        'UPDATE norma.%I SET start_time = to_timestamp($1) WHERE id = $2',
                        tabname
                    ) USING rec.gmt_time_s, rec.machine_use_id;
                    RAISE NOTICE 'updated 2 --- %', rec.machine_use_id;
                ELSE
                    RAISE NOTICE 'pass 2';
                END IF;
            ELSE
                EXECUTE format(
                    'UPDATE norma.%I SET start_time = to_timestamp($1) WHERE id = $2',
                    tabname
                ) USING rec.gmt_time_s, rec.machine_use_id;
                RAISE NOTICE 'updated 2A --- %', rec.machine_use_id;
            END IF;  
        ELSE
            EXECUTE format(
                'INSERT INTO norma.%I (id, start_time, end_time) VALUES ($1, to_timestamp($2), to_timestamp($3))',
                tabname
            ) USING rec.machine_use_id, rec.gmt_time_s, rec.gmt_time_s;
            RAISE NOTICE 'inserted --- %', rec.machine_use_id;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;




DO
$$
DECLARE
    machine_obs_data_cursor CURSOR FOR SELECT machine_use_id, machine_use_id_alt FROM norma.machine_obs_data;
    rec RECORD;
    muid TEXT;
    tabname TEXT;
BEGIN
    tabname := 'machine_obs_data';
    FOR rec IN machine_obs_data_cursor LOOP
        SELECT machine_use_id::text INTO muid FROM norma.machine_config_data WHERE machine_use_id_alt = rec.machine_use_id_alt;
        IF (muid is not null) THEN
            EXECUTE format(
                'UPDATE norma.%I SET machine_use_id = $1::uuid WHERE machine_use_id_alt = $2',
                tabname
            ) USING muid, rec.machine_use_id_alt;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;