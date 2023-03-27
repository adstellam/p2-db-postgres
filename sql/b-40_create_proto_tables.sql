CREATE TABLE IF NOT EXISTS proto_plant (
    id INT,
    klass INT,
    confidence REAL,
    odometer_meter REAL,
    side_shift_pixel REAL,
    center_x_filtered_pixel REAL,
    center_y_filtered_pixel REAL,
    shape REAL,
    width_meter REAL,
    height_meter REAL,
    width_pixel REAL,
    height_pixel REAL,
    gmt_time_s DOUBLE PRECISION,
    monotonic_time_s DOUBLE PRECISION,
    side_shift_meter REAL,
    machine_type INT,
    machine_id INT,
    camera_id INT,
    phase INT,   
    plant_line INT,
    detection_valid BOOLEAN,
    vx_pixel_second REAL,
    vy_pixel_second REAL,
    correction_count INT,
    detection_x_pixel INT,
    detection_y_pixel INT,
    odometer_expiration_meter REAL
);

CREATE TABLE IF NOT EXISTS proto_machine_state (
    frame_id INT,
    lifted BOOLEAN,
    operator_flag INT,
    odometer_meter REAL,
    error INT,
    voltage REAL,
    oil_temp_celcius REAL,
    gmt_time_s DOUBLE PRECISION,
    monotonic_time_s DOUBLE PRECISION,
    frame_per_second REAL,
    odometer_meter_per_second REAL,
    machine_type INT,
    machine_id INT,
    camera_id INT,
    side_shift_meter REAL,
    side_shift_pixel REAL
);

CREATE TABLE IF NOT EXISTS proto_detection (
    klass INT,
    top INT,
    left_ INT,
    width INT,
    height INT,
    confidence REAL,
    plant_line INT
);

CREATE TABLE IF NOT EXISTS proto_machine (
    name TEXT,
    frame_id INT,
    camera_id INT,
    width_meter REAL,
    actuator_after_meter REAL,
    actuator_before_meter REAL,
    commodity_class_id INT,
    line_spacing_meter REAL,
    plant_spacing_meter REAL,
    confidence_threshold REAL,
    plant_line_count INT,
    machine_type INT,
    machine_id INT,
    actuator_speed_percent REAL,
    width_pixel INT,
    height_pixel INT,
    fov_height_degree REAL,
    buffer_distance_meter REAL,
    lens_working_dist_meter REAL,
    camera_height_setpoint_meter REAL,
    oil_temp_warning REAL,
    oil_temp_critical REAL,
    warning_speed_meter_per_second REAL,
    critical_speed_meter_per_second REAL,
    normal_minimum_voltage REAL,
    critical_maximum_voltage REAL,
    critical_minimum_voltage REAL,
    ssid TEXT,
    wifi_password TEXT,
    total_side_shift_travel_meter REAL,
    total_side_shift_travel_pixel REAL
);

CREATE TABLE IF NOT EXISTS proto_gps_position (
    monotonic_time_s DOUBLE PRECISION,
    gmt_time_s DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    heading REAL,
    itow INT
);

CREATE TABLE IF NOT EXISTS proto_odometer_position (
    monotonic_time_s DOUBLE PRECISION,
    gmt_time_s DOUBLE PRECISION,
    odometer_meter REAL
);
