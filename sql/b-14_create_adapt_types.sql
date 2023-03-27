CREATE TYPE adapt.contact_info_record AS (
    contact VARCHAR,
    address_line_1 VARCHAR,
    address_line_2 VARCHAR,
    city VARCHAR,
    stateOrProvince VARCHAR,
    postalCode VARCHAR,
    country VARCHAR,
    countryCode VARCHAR
);

CREATE TYPE adapt.context_item_record AS (
    context_key VARCHAR,
    context_value VARCHAR
);

CREATE TYPE adapt.data_log_trigger_record AS (
    logging_level adapt.logging_level_enum,
    data_log_method adapt.logging_method_enum,
    data_log_time_interval REAL,
    data_log_distance_interval REAL,
    data_log_threshold_change REAL,
    data_log_threshold_maximum REAL,
    data_log_threshold_minimum REAL,
    representation VARCHAR
);

CREATE TYPE adapt.equipment_configuration_record AS (
    connector_1_id INT,
    connector_2_id INT,
    data_log_triggers adapt.data_log_trigger_record[]
);

CREATE TYPE adapt.gps_source_record AS (

);

CREATE TYPE adapt.guidance_shift_record AS (
    east_shift REAL,
    north_shift REAL,
    propagation_offset REAL
);

CREATE TYPE adapt.headland_record AS (

);

CREATE TYPE adapt.implement_configuration_record AS (
    implement_length REAL,
    width REAL,
    physical_width REAL,
    in_ground_turn_radius REAL,
    track_spacing REAL,
    y_offset REAL,
    gps_receiver_z_offset REAL,
    vertical_cutting_edge_z_offset REAL,
    camera_ids INT[]
);

CREATE TYPE adapt.interior_boundary_attribute_record AS (

);

CREATE TYPE adapt.machine_configuration_record AS (
    gps_receiver_x_offset REAL,
    gps_receiver_y_offset REAL,
    gps_receiver_z_offset REAL,
    origin_axel_location adapt.origin_axel_location_enum
);

CREATE TYPE adapt.manual_prescription_record AS (

);

CREATE TYPE adapt.person_role_record AS (

);

CREATE TYPE adapt.product_component_record AS (

);

CREATE TYPE adapt.radial_prescription_record AS (

);

CREATE TYPE adapt.raster_grid_prescription_record AS (

);


CREATE TYPE adapt.section_configuration_record AS (
    section_width REAL,
    inline_offset REAL,
    lateral_offset REAL
);

CREATE TYPE adapt.spatial_record AS (
    representation VARCHAR,
    shape GEOMETRY,
    ts TIMESTAMPTZ
);

CREATE TYPE adapt.trait_record AS (
    code_key VARCHAR,
    code_val VARCHAR
);

CREATE TYPE adapt.vector_prescription_record AS (

);

CREATE TYPE adapt.status_update_record AS (
    representation VARCHAR,
    ts TIMESTAMPTZ
);
