CREATE OR REPLACE VIEW apiview.brands AS (
    SELECT 
        brands.id AS id,
        brands.cname AS brand_name,
        manufacturers.cname AS manufacturer_name
    FROM norma.brands AS brands
    LEFT JOIN norma.manufacturers AS manufacturers 
    ON manufacturers.id = brands.manufacturer_id
); 

CREATE OR REPLACE VIEW apiview.crop_images AS (
    SELECT 
        crop_images.id AS id,
        crop_images.organization_id AS organization_id,
        crop_images.crop_id AS crop_id,
        crop_images.machine_name AS machine_name,
        crop_images.camera_id AS camera_id,
        crop_zones.id AS crop_zone_id,
        crop_zones.cname AS crop_zone_name,
        crop_zones.field_id AS field_id,
        crop_analytics_data.crop_code AS crop_code,
        crop_analytics_data.wet_date AS wet_date,
        encode(crop_images.image_binary, 'base64') AS image_binary,
        crop_images.image_annotations AS image_annotations,
        crop_images.image_ts AS image_ts
    FROM norma.crop_images AS crop_images
    LEFT JOIN norma.crop_analytics_data AS crop_analytics_data 
    ON crop_analytics_data.crop_id = crop_images.crop_id
    LEFT JOIN norma.crop_zones AS crop_zones 
    ON crop_zones.id = crop_analytics_data.crop_zone_id
);

CREATE OR REPLACE VIEW apiview.crop_zones AS (
    SELECT 
        crop_zones.id AS id, 
        crop_zones.cname AS crop_zone_name,
        farms.organization_id AS organization_id,
        growers.cname AS grower_name, 
        crop_zones.crop_season AS crop_season,
        farms.cname AS farm_name,
        fields.cname AS field_name, 
        crop_types.cname AS crop_name,
        crop_zones.bounding_region AS bounding_region,
        st_area(crop_zones.bounding_region::geography) AS area_in_sq_meters_calculated,
        crop_zones.area_in_sq_meters AS area_in_sq_meters_given,
        guidance_allocations_aggregated.guidance_group_names AS guidance_group_names,
        crop_zones.seed_type AS seed_type,
        crop_zones.wet_date AS wet_date,
        crop_zones.calculated_harvest_date AS calculated_harvest_date,
        crop_zones.estimated_harvest_date AS estimated_harvest_date,
        crop_zones.harvest_date AS harvest_date,
        crop_zones.archived AS archived,
        crop_zones.created AS created,
        crop_zones.updated AS updated
    FROM norma.crop_zones AS crop_zones
    LEFT JOIN norma.fields AS fields 
    ON fields.id = crop_zones.field_id
    LEFT JOIN norma.farms AS farms 
    ON farms.id = fields.farm_id
    LEFT JOIN norma.growers AS growers 
    ON growers.id = farms.grower_id
    LEFT JOIN norma.crop_types AS crop_types 
    ON crop_types.code = crop_zones.crop_code
    LEFT JOIN (
        SELECT 
            guidance_allocations.id AS id,
            guidance_allocations.crop_zone_id AS crop_zone_id,
            array_agg(guidance_groups.cname) AS guidance_group_names
        FROM norma.guidance_allocations AS guidance_allocations
        LEFT JOIN norma.guidance_groups AS guidance_groups
        ON guidance_groups.id = guidance_allocations.guidance_group_id
        GROUP BY guidance_allocations.id
    ) AS guidance_allocations_aggregated
    ON guidance_allocations_aggregated.crop_zone_id = crop_zones.id
);

CREATE OR REPLACE VIEW apiview.crop_analytics_data AS (
    SELECT 
        crop_analytics_data.crop_id AS crop_id,
        crop_analytics_data.organization_id AS organization_id,
        crop_analytics_data.grower_id AS grower_id,
        crop_zones.grower_name AS grower_name,
        crop_analytics_data.crop_season AS crop_season,
        crop_analytics_data.crop_zone_id AS crop_zone_id,
        crop_zones.crop_zone_name AS crop_zone_name,
        crop_zones.field_name AS field_name,
        crop_zones.crop_name AS crop_name,
        crop_zones.seed_type AS seed_type,
        crop_analytics_data.crop_position AS crop_position,
        cad1_aggregated.irrigation_records_json AS irrigation_records_json,
        cad2_aggregated.cultivation_records_json AS cultivation_records_json,
        cad3_aggregated.application_records_json AS application_records_json,
        cad4_aggregated.crop_measure_records_json AS crop_measure_records_json,
        cad5_aggregated.insect_infestation_records_json AS insect_infestation_records_json,
        cad6_aggregated.fungal_infestation_records_json AS fungal_infestation_records_json,
        cad7_aggregated.viral_infestation_records_json AS viral_infestation_records_json,
        crop_analytics_data.wet_date AS wet_date,
        crop_analytics_data.reject_date AS reject_date,
        crop_analytics_data.harvest_date AS harvest_date
    FROM norma.crop_analytics_data AS crop_analytics_data
    LEFT JOIN (
        SELECT 
            cad1_unnested.crop_id AS crop_id, 
            array_agg(cad1_unnested.irrigation_record_json) AS irrigation_records_json
        FROM (
            SELECT 
                cad1.crop_id AS crop_id,
                row_to_json(row(unnest(cad1.irrigation_records))) AS irrigation_record_json
            FROM norma.crop_analytics_data AS cad1
        ) AS cad1_unnested
        GROUP BY cad1_unnested.crop_id
    ) AS cad1_aggregated 
    ON cad1_aggregated.crop_id = crop_analytics_data.crop_id
    LEFT JOIN (
        SELECT 
            cad2_unnested.crop_id AS crop_id, 
            array_agg(cad2_unnested.cultivation_record_json) AS cultivation_records_json
        FROM (
            SELECT 
                cad2.crop_id AS crop_id,
                row_to_json(row(unnest(cad2.cultivation_records))) AS cultivation_record_json
            FROM norma.crop_analytics_data AS cad2
        ) AS cad2_unnested
        GROUP BY cad2_unnested.crop_id
    ) AS cad2_aggregated 
    ON cad2_aggregated.crop_id = crop_analytics_data.crop_id
    LEFT JOIN (
        SELECT 
            cad3_unnested.crop_id AS crop_id, 
            array_agg(cad3_unnested.application_record_json) AS application_records_json
        FROM (
            SELECT 
                cad3.crop_id AS crop_id,
                row_to_json(row(unnest(cad3.application_records))) AS application_record_json
            FROM norma.crop_analytics_data AS cad3
        ) AS cad3_unnested
        GROUP BY cad3_unnested.crop_id 
    ) AS cad3_aggregated 
    ON cad3_aggregated.crop_id = crop_analytics_data.crop_id
    LEFT JOIN (
        SELECT 
            cad4_unnested.crop_id AS crop_id, 
            array_agg(cad4_unnested.crop_measure_record_json) AS crop_measure_records_json
        FROM (
            SELECT 
                cad4.crop_id AS crop_id,
                row_to_json(row(unnest(cad4.crop_measure_records))) AS crop_measure_record_json
            FROM norma.crop_analytics_data AS cad4
        ) AS cad4_unnested
        GROUP BY cad4_unnested.crop_id
    ) AS cad4_aggregated
    ON cad4_aggregated.crop_id = crop_analytics_data.crop_id
    LEFT JOIN (
        SELECT 
            cad5_unnested.crop_id AS crop_id, 
            array_agg(cad5_unnested.insect_infestation_record_json) AS insect_infestation_records_json
        FROM (
            SELECT 
                cad5.crop_id AS crop_id,
                row_to_json(row(unnest(cad5.insect_infestation_records))) AS insect_infestation_record_json
            FROM norma.crop_analytics_data AS cad5
        ) AS cad5_unnested
        GROUP BY cad5_unnested.crop_id
    ) AS cad5_aggregated
    ON cad5_aggregated.crop_id = crop_analytics_data.crop_id
    LEFT JOIN (
        SELECT 
            cad6_unnested.crop_id AS crop_id, 
            array_agg(cad6_unnested.fungal_infestation_record_json) AS fungal_infestation_records_json
        FROM (
            SELECT 
                cad6.crop_id AS crop_id,
                row_to_json(row(unnest(cad6.fungal_infestation_records))) AS fungal_infestation_record_json
            FROM norma.crop_analytics_data AS cad6
        ) AS cad6_unnested
        GROUP BY cad6_unnested.crop_id
    ) AS cad6_aggregated
    ON cad6_aggregated.crop_id = crop_analytics_data.crop_id
    LEFT JOIN (
        SELECT 
            cad7_unnested.crop_id AS crop_id, 
            array_agg(cad7_unnested.viral_infestation_record_json) AS viral_infestation_records_json
        FROM (
            SELECT 
                cad7.crop_id AS crop_id,
                row_to_json(row(unnest(cad7.viral_infestation_records))) AS viral_infestation_record_json
            FROM norma.crop_analytics_data AS cad7
        ) AS cad7_unnested
        GROUP BY cad7_unnested.crop_id
    ) AS cad7_aggregated
    ON cad7_aggregated.crop_id = crop_analytics_data.crop_id
    LEFT JOIN apiview.crop_zones AS crop_zones 
    ON crop_zones.id = crop_analytics_data.crop_zone_id
);

CREATE OR REPLACE VIEW apiview.crop_types AS (
    SELECT 
        code AS crop_code,
        cname AS crop_name,
        reference_weight,
        standard_payable_moisture,
        genetically_enhanced,
        row_to_json(row(traits)) AS crop_traits_json 
    FROM norma.crop_types
);   

CREATE OR REPLACE VIEW apiview.equipment AS (
    SELECT 
        device_elements.id AS id, 
        device_elements.cname AS equipment_name,
        device_elements.organization_id AS organiation_id,
        brands.cname AS equipment_brand_name,
        device_elements.device_element_type AS equipment_type,
        device_elements.device_classification AS equipment_classification, 
        device_elements.device_model AS equipment_model,
        device_elements.series AS equipment_series,
        device_elements.serial_number AS equipment_serial_number,
        CASE
            WHEN device_elements.device_element_type = 'Machine' THEN row_to_json(row(device_element_configurations.machine_configuration))
            WHEN device_elements.device_element_type = 'Implement' THEN row_to_json(row(device_element_configurations.implement_configuration))
            WHEN device_elements.device_element_type = 'Section' THEN row_to_json(row(device_element_configurations.section_configuration))
        END AS active_configuration_json,
        device_elements.inet_domain_name AS inet_domain_name,
        device_elements.archived AS archived,
        device_elements.created AS created,
        device_elements.updated AS updated
    FROM norma.device_elements AS device_elements
    LEFT JOIN norma.brands AS brands 
    ON brands.id = device_elements.brand_id
    LEFT JOIN norma.device_element_configurations AS device_element_configurations 
    ON device_element_configurations.id = device_elements.active_configuration_id
);

CREATE OR REPLACE VIEW apiview.equipment_configurations AS (
    SELECT 
        device_element_configurations.id AS id, 
        device_elements.cname AS equipment_name, 
        CASE
            WHEN device_elements.device_element_type = 'Machine' THEN row_to_json(row(device_element_configurations.machine_configuration))
            WHEN device_elements.device_element_type = 'Implement' THEN row_to_json(row(device_element_configurations.implement_configuration))
            WHEN device_elements.device_element_type = 'Section' THEN row_to_json(row(device_element_configurations.section_configuration))
        END AS configuration_json, 
        device_element_configurations.offsets AS offsets,
        device_element_configurations.created AS created,
        device_element_configurations.updated AS updated
    FROM norma.device_element_configurations AS device_element_configurations
    LEFT JOIN norma.device_elements AS device_elements 
    ON device_elements.id = device_element_configurations.device_element_id
);

CREATE OR REPLACE VIEW apiview.equipment_uses AS (
    SELECT 
        device_element_uses.id AS id,
        device_elements.cname AS equipment_name,
        crop_zones.crop_season AS crop_season,
        fields.cname AS field_name,
        crop_zones.cname AS crop_zone_name,
        work_items.cname AS job_name,
        work_item_operations.cname AS task_name,
        device_element_uses.use_order AS use_order,
        device_element_uses.use_depth AS use_depth,
        CASE
            WHEN device_elements.device_element_type = 'Machine' THEN row_to_json(row(device_element_configurations.machine_configuration))
            WHEN device_elements.device_element_type = 'Implement' THEN row_to_json(row(device_element_configurations.implement_configuration))
            WHEN device_elements.device_element_type = 'Section' THEN row_to_json(row(device_element_configurations.section_configuration))
        END AS configuration_in_use_json,
        device_element_uses.travel_distance_meter AS travel_distance_meter,
        device_element_uses.crop_counts_by_size AS crop_counts_by_size,
        extract(EPOCH FROM (device_element_uses.end_time - device_element_uses.start_time)) AS elapsed_time_in_seconds,
        device_element_uses.start_time AS start_time,
        device_element_uses.end_time AS end_time
    FROM norma.device_element_uses AS device_element_uses
    LEFT JOIN norma.operation_data AS operation_data 
    ON operation_data.id = device_element_uses.operation_data_id
    LEFT JOIN norma.work_item_operations AS work_item_operations 
    ON work_item_operations.id = operation_data.work_item_operation_id
    LEFT JOIN norma.work_items AS work_items 
    ON work_items.id = work_item_operations.work_item_id 
    LEFT JOIN norma.crop_zones AS crop_zones 
    ON crop_zones.id = work_items.crop_zone_id
    LEFT JOIN norma.fields AS fields 
    ON fields.id = crop_zones.field_id
    LEFT JOIN norma.device_element_configurations AS device_element_configurations 
    ON device_element_configurations.id = device_element_uses.device_element_configuration_id
    LEFT JOIN norma.device_elements AS device_elements 
    ON device_elements.id = device_element_configurations.device_element_id
);

CREATE OR REPLACE VIEW apiview.farms AS (
    SELECT
        farms.id AS id,
        farms.cname AS farm_name,
        farms.organization_id AS organization_id,
        growers.cname AS grower_name,
        farms.permitee AS permitee,
        farms.permit_number AS permit_number,
        farms.bounding_region AS bounding_region,
        farms_inner_aggregated.field_names
    FROM norma.farms AS farms
    LEFT JOIN (
        SELECT
            farms_inner.id AS id,
            array_agg(fields.cname) AS field_names
        FROM norma.farms AS farms_inner
        LEFT JOIN norma.fields AS fields 
        ON fields.farm_id = farms_inner.id
        GROUP BY farms_inner.id
    ) AS farms_inner_aggregated
    ON farms_inner_aggregated.id = farms.id
    LEFT JOIN norma.growers AS growers 
    ON growers.id = farms.grower_id
);

CREATE OR REPLACE VIEW apiview._fields_ AS (
    SELECT 
        fields.id AS id, 
        fields.cname AS field_name, 
        farms.organization_id AS organization_id,
        growers.cname AS grower_name, 
        farms.cname AS farm_name, 
        fields1_aggregated.crop_zone_names AS crop_zone_names,
        fields2_aggregated.crop_names AS crop_names,
        field_boundaries.geom AS active_boundary_geom,
        st_area(field_boundaries.geom::geography) AS area_in_sq_meters_calculated,
        fields.area_in_sq_meters AS area_in_sq_meters_given,
        fields.aspect AS aspect,
        fields.slope AS slope,
        fields.slope_length AS slope_length,
        fields3_aggregated.relevant_map_names AS relevant_map_names,
        fields.archived AS archived,
        fields.created AS created,
        fields.updated AS updated
    FROM norma.fields AS fields
    LEFT JOIN norma.farms AS farms 
    ON farms.id = fields.farm_id
    LEFT JOIN norma.growers AS growers 
    ON growers.id = farms.grower_id
    LEFT JOIN norma.field_boundaries AS field_boundaries 
    ON field_boundaries.id = fields.active_boundary_id
    LEFT JOIN (
        SELECT
            fields1.id AS id,
            array_agg(crop_zones.cname) AS crop_zone_names
        FROM norma.fields AS fields1
        LEFT JOIN norma.crop_zones As crop_zones 
        ON crop_zones.field_id = fields1.id
        GROUP BY fields1.id
    ) AS fields1_aggregated
    ON fields1_aggregated.id = fields.id
    LEFT JOIN (
        SELECT
            fields2.id AS id,
            array_agg(crop_types.cname) AS crop_names
        FROM norma.fields AS fields2
        LEFT JOIN norma.crop_zones AS crop_zones
        ON crop_zones.field_id = fields2.id
        LEFT JOIN norma.crop_types AS crop_types
        ON crop_types.code = crop_zones.crop_code
        GROUP BY fields2.id
    ) AS fields2_aggregated
    ON fields2_aggregated.id = fields.id
    LEFT JOIN (
        SELECT 
            fields3.id AS id,
            array_agg(reference_layers.cname) AS relevant_map_names
        FROM norma.fields AS fields3
        LEFT JOIN norma.field_boundaries AS fb 
        ON fb.id = fields3.active_boundary_id
        LEFT JOIN norma.reference_layers AS reference_layers 
        ON st_contains(reference_layers.bounding_polygon, fb.geom)
        group BY fields3.id
    ) AS fields3_aggregated
    ON fields3_aggregated.id = fields.id
);

CREATE OR REPLACE VIEW apiview.fields AS (
    SELECT 
        _fields_.id AS id, 
        _fields_.field_name AS field_name, 
        _fields_.organization_id AS organization_id,
        _fields_.grower_name AS grower_name, 
        _fields_.farm_name AS farm_name, 
        _fields_.crop_zone_names[0] AS crop_zone_name,
        _fields_.crop_names[0] AS crop_name, 
        _fields_.active_boundary_geom AS active_boundary_geom,
        _fields_.area_in_sq_meters_calculated AS area_in_sq_meters_calculated,
        _fields_.area_in_sq_meters_given AS area_in_sq_meters_given,
        _fields_.aspect AS aspect,
        _fields_.slope AS slope,
        _fields_.slope_length AS slope_length,
        _fields_aggregated.guidance_group_names AS guidance_group_names,
        _fields_.relevant_map_names AS relevant_map_names,
        crop_zones.wet_date AS wet_date,
        crop_zones.calculated_harvest_date AS calculated_harvest_date,
        crop_zones.estimated_harvest_date AS estimated_harvest_date,
        crop_zones.harvest_date AS harvest_date,
        _fields_.archived AS archived,
        _fields_.created AS created,
        _fields_.updated AS updated
    FROM apiview._fields_ AS _fields_
    LEFT JOIN norma.crop_zones AS crop_zones 
    ON crop_zones.field_id = _fields_.id
    LEFT JOIN (
        SELECT
            _fields_inner.id AS id,
            guidance_allocations_aggregated.guidance_group_names AS guidance_group_names
        FROM apiview._fields_ AS _fields_inner
        LEFT JOIN norma.crop_zones AS cz
        ON cz.field_id = _fields_inner.id
        LEFT JOIN (
            SELECT 
                guidance_allocations.id AS id,
                guidance_allocations.crop_zone_id AS crop_zone_id,
                array_agg(guidance_groups.cname) AS guidance_group_names
            FROM norma.guidance_allocations AS guidance_allocations
            LEFT JOIN norma.guidance_groups AS guidance_groups
            ON guidance_groups.id = guidance_allocations.guidance_group_id
            GROUP BY guidance_allocations.id
        ) AS guidance_allocations_aggregated
        ON guidance_allocations_aggregated.crop_zone_id = cz.id
    ) AS _fields_aggregated
    ON _fields_aggregated.id = _fields_.id
);

CREATE OR REPLACE VIEW apiview.field_boundaries AS (
    SELECT 
        field_boundaries.id AS id,
        farms.organization_id AS organization_id,
        fields.id AS field_id,
        fields.cname AS field_name,
        field_boundaries.geom AS geom,
        fb1_aggregated.interior_boundary_attributes_json AS interior_boundary_attributes_json,
        fb2_aggregated.headlands_json AS headlands_json,
        field_boundaries.archived AS archived,
        field_boundaries.created AS created,
        field_boundaries.updated AS updated
    FROM norma.field_boundaries AS field_boundaries
    LEFT JOIN norma.fields AS fields 
    ON fields.id = field_boundaries.field_id
    LEFT JOIN norma.farms AS farms
    ON farms.id = fields.farm_id
    LEFT JOIN (
        SELECT 
            fb1_unnested.id AS id,
            array_agg(fb1_unnested.interior_boundary_attribute_json) AS interior_boundary_attributes_json
        FROM (
            SELECT 
                fb1.id AS id,
                row_to_json(row(unnest(fb1.interior_boundary_attributes))) AS interior_boundary_attribute_json
            FROM norma.field_boundaries AS fb1
        ) AS fb1_unnested
        GROUP BY fb1_unnested.id
    ) AS fb1_aggregated
    ON fb1_aggregated.id = field_boundaries.id
    LEFT JOIN (
        SELECT 
            fb2_unnested.id AS id,
            array_agg(fb2_unnested.headland_json) AS headlands_json
        FROM (
            SELECT
                fb2.id AS id,
                row_to_json(row(unnest(fb2.headlands))) AS headland_json
            FROM norma.field_boundaries AS fb2
        ) AS fb2_unnested
        GROUP BY fb2_unnested.id
    ) AS fb2_aggregated
    ON fb2_aggregated.id = field_boundaries.id
);

CREATE OR REPLACE VIEW apiview.growers AS (
    SELECT 
        growers.id AS id,
        growers.cname AS grower_name,
        array_agg(farms.cname) AS farm_names,
        array_agg(fields.cname) AS field_names
    FROM norma.growers AS growers
    LEFT JOIN norma.farms AS farms ON farms.grower_id = growers.id
    LEFT JOIN norma.fields AS fields ON fields.farm_id = farms.id
    GROUP BY growers.id
);

CREATE OR REPLACE VIEW apiview.guidance_groups AS (
    SELECT 
        guidance_groups.id AS id, 
        guidance_groups.cname AS guidance_group_name, 
        guidance_groups.bounding_polygon AS bounding_polygon, 
        array_agg(guidance_patterns.id) AS guidance_pattern_ids
    FROM norma.guidance_groups AS guidance_groups
    LEFT JOIN norma.guidance_patterns AS guidance_patterns ON guidance_patterns.guidance_group_id = guidance_groups.id
    GROUP BY guidance_groups.id
);

CREATE OR REPLACE VIEW apiview.guidance_patterns AS (
    SELECT 
        guidance_patterns.id AS id,
        guidance_groups.cname AS guidance_group_name,
        guidance_patterns.bounding_polygon AS bounding_polygon,
        guidance_patterns.guidance_pattern_type AS guidance_pattern_type,
        guidance_patterns.extension AS extenstion_type,
        guidance_patterns.propagation_direction AS propagation_direction_type,
        guidance_patterns.number_of_swaths_left AS number_of_swaths_left,
        guidance_patterns.number_of_swaths_right AS number_of_swaths_right,
        guidance_patterns.swath_width AS swath_width,
        guidance_patterns.gps_source AS gps_source
    FROM norma.guidance_patterns AS guidance_patterns
    LEFT JOIN norma.guidance_groups ON guidance_groups.id = guidance_patterns.guidance_group_id
);

CREATE OR REPLACE VIEW apiview.jobs AS (
    SELECT 
        work_items.id AS id,
        work_items.cname AS job_name,
        crop_zones.organization_id AS organization_id,
        crop_zones.grower_name AS grower_name,
        crop_zones.crop_season AS crop_season,
        crop_zones.farm_name AS farm_name,
        crop_zones.field_name AS field_name,
        crop_zones.id AS crop_zone_id,
        crop_zones.crop_zone_name AS crop_zone_name, 
        crop_zones.crop_name AS crop_name,
        work_orders.id AS work_order_id,
        work_orders.cname AS work_order_name,
        work_items.operation_types AS operation_types,
        work_item_operations_aggregated.work_item_operation_names AS task_names,
        concat(users.first_name, ' ', users.last_name) AS job_supervisor_name,
        work_items.work_item_priority AS job_priority,
        work_items.work_item_status AS job_status,
        work_items.proposed_start_date AS planned_start_date,
        work_items.proposed_end_date AS planned_end_date,
        work_items.actual_start_date AS actual_start_date,
        work_items.actual_end_date AS actual_end_date,
        work_items.notes AS notes,
        work_items.archived AS archived,
        work_items.created AS created,
        work_items.updated AS updated
    FROM norma.work_items AS work_items
    LEFT JOIN norma.work_orders AS work_orders 
    ON work_orders.id = work_items.work_order_id
    LEFT JOIN apiview.crop_zones AS crop_zones 
    ON crop_zones.id = work_items.crop_zone_id
    LEFT JOIN norma.users AS users 
    ON users.id = work_items.work_item_supervisor_id
    LEFT JOIN (
        SELECT
            work_items_inner.id AS id,
            array_agg(work_item_operations.cname) AS work_item_operation_names
        FROM norma.work_items AS work_items_inner
        LEFT JOIN norma.work_item_operations AS work_item_operations
        ON work_item_operations.work_item_id = work_items_inner.id
        GROUP BY work_items_inner.id
    ) AS work_item_operations_aggregated
    ON work_item_operations_aggregated.id = work_items.id
); 

CREATE OR REPLACE VIEW apiview.machines AS (
    SELECT 
        device_elements.id AS id,
        device_elements.cname AS machine_name,
        device_elements.organization_id AS organization_id,
        device_elements.device_classification AS machine_classification,
        brands.cname AS machine_brand,
        device_elements.device_model AS machine_model,
        device_elements.series AS machine_series,
        device_elements.serial_number AS machine_serial_number,
        CASE
            WHEN device_elements.device_element_type = 'Machine' THEN row_to_json(row(device_element_configurations.machine_configuration))
            WHEN device_elements.device_element_type = 'Implement' THEN row_to_json(row(device_element_configurations.implement_configuration))
            WHEN device_elements.device_element_type = 'Section' THEN row_to_json(row(device_element_configurations.section_configuration))
        END AS active_configuration_json,
        device_elements.inet_domain_name AS inet_domain_name,
        device_elements.archived AS archived,
        device_elements.created AS created,
        device_elements.updated AS updated
    FROM norma.device_elements AS device_elements
    LEFT JOIN norma.brands AS brands
    ON brands.id = device_elements.brand_id
    LEFT JOIN norma.device_element_configurations AS device_element_configurations 
    ON device_element_configurations.device_element_id = device_elements.id
    WHERE device_elements.device_element_type = 'Implement' AND device_elements.brand_id = '6dda70d3-e839-4724-b140-84f2250333bf'
);

CREATE OR REPLACE VIEW apiview.machine_configurations AS (
    SELECT 
        device_element_configurations.id AS id,
        device_elements.cname AS machine_name,
        CASE
            WHEN device_elements.device_element_type = 'Machine' THEN row_to_json(row(device_element_configurations.machine_configuration))
            WHEN device_elements.device_element_type = 'Implement' THEN row_to_json(row(device_element_configurations.implement_configuration))
            WHEN device_elements.device_element_type = 'Section' THEN row_to_json(row(device_element_configurations.section_configuration))
        END AS configuration_json, 
        device_element_configurations.offsets AS offsets,
        device_element_configurations.created AS created,
        device_element_configurations.updated AS updated
    FROM norma.device_element_configurations AS device_element_configurations
    LEFT JOIN norma.device_elements AS device_elements 
    ON device_elements.id = device_element_configurations.device_element_id
    WHERE device_elements.device_element_type = 'Implement' AND device_elements.brand_id = '6dda70d3-e839-4724-b140-84f2250333bf'
);

CREATE OR REPLACE VIEW apiview.machine_config_data AS (
    SELECT * 
    FROM norma.machine_config_data
);

CREATE OR REPLACE VIEW apiview.machine_obs_data AS (
    WITH machine_obs_data AS (
        SELECT *
        FROM norma.machine_obs_data
        WHERE klass::text IN (SELECT code FROM norma.crop_types)
    )
    SELECT 
        machine_obs_data.plant_id AS crop_id,
        device_elements.id AS machine_id,
        device_elements.cname AS machine_name,
        machine_obs_data.camera_id AS camera_id,
        crop_zones.id AS crop_zone_id,
        crop_zones.crop_zone_name AS crop_zone_name,
        crop_zones.farm_name AS farm_name,
        crop_zones.crop_season AS crop_season,
        crop_zones.seed_type AS seed_type,
        date_trunc('day', to_timestamp(gmt_time_s)) - crop_zones.wet_date AS days_from_wet_date,
        to_timestamp(machine_obs_data.gmt_time_s) AS ts,
        st_setsrid(st_point(machine_obs_data.longitude, machine_obs_data.latitude), 4326) AS position,
        machine_obs_data.klass AS klass,
        crop_types.cname AS crop_name,
        machine_obs_data.confidence AS confidence,
        machine_obs_data.width_meter * 100 AS width_cm,
        machine_obs_data.height_meter * 100 AS height_cm,
        machine_obs_data.odometer_meter AS odometer_meter,
        machine_obs_data.plant_line AS plant_line,
        machine_obs_data.insect_infestation_type AS insect_infestation_type,
        machine_obs_data.insect_infestation_severity AS insect_infestation_severity,
        machine_obs_data.insect_infestation_infested_area_percentage AS insect_infestation_infested_area_percentage,
        machine_obs_data.fungal_infestation_type AS fungal_infestation_type,
        machine_obs_data.fungal_infestation_severity AS fungal_infestation_severity,
        machine_obs_data.fungal_infestation_infested_area_percentage AS fungal_infestation_infested_area_percentage,
        machine_obs_data.viral_infestation_type AS viral_infestation_type,
        machine_obs_data.viral_infestation_severity AS viral_infestation_severity,
        machine_obs_data.viral_infestation_infested_area_percentage AS viral_infestation_infested_area_percentage,
        machine_obs_data.crop_score AS crop_score,
        machine_obs_data.plant_spacing_meter AS plant_spacing_meter,
        machine_obs_data.machine_use_id AS machine_use_id
    FROM machine_obs_data
    LEFT JOIN norma.crop_types AS crop_types
    ON crop_types.code = machine_obs_data.klass::text
    LEFT JOIN apiview.crop_zones AS crop_zones
    ON crop_zones.id = machine_obs_data.crop_zone_id
    LEFT JOIN norma.device_elements AS device_elements 
    ON device_elements.cname = lower(machine_obs_data.machine_name)
);

CREATE OR REPLACE VIEW apiview.machine_pos_data AS (
    SELECT 
        device_elements.id AS machine_id,
        device_elements.cname AS machine_name,
        device_elements.organization_id AS organization_id,
        to_timestamp(machine_pos_data.gmt_time_s) AS ts,
        st_setsrid(st_point(machine_pos_data.longitude, machine_pos_data.latitude), 4326) AS position,
        machine_pos_data.heading AS heading,
        machine_pos_data.itow AS itow
    FROM norma.machine_pos_data AS machine_pos_data
    LEFT JOIN norma.device_elements AS device_elements 
    ON device_elements.cname = lower(machine_pos_data.machine_name)
);

CREATE OR REPLACE VIEW apiview.machine_telematics_data AS (
    SELECT 
        device_elements.id AS machine_id,
        device_elements.cname AS machine_name,
        device_elements.organization_id AS organization_id,
        to_timestamp(machine_telematics_data.gmt_time_s) AS ts,
        machine_telematics_data.odometer_meter_per_second AS odometer_meter_per_second,
        machine_telematics_data.odometer_meter AS odometer_meter,
        machine_telematics_data.oil_temp_celcius AS oil_temp_celcius,
        machine_telematics_data.voltage AS voltage
    FROM norma.machine_telematics_data AS machine_telematics_data
    LEFT JOIN norma.device_elements AS device_elements 
    ON device_elements.cname = lower(machine_telematics_data.machine_name)
);

CREATE OR REPLACE VIEW apiview.machine_uses AS (
    SELECT 
        device_element_uses.id AS id,
        device_element_uses.id_alt AS id_alt,
        device_element_uses.operation_data_id AS task_operations_data_id,
        work_item_operations.id AS task_id,
        work_item_operations.cname AS task_name,
        work_item_operations.device_element_id AS machine_id,
        device_elements.cname AS machine_name,
        device_elements.organization_id AS organization_id,
        device_element_uses.travel_distance_meter AS travel_distance_meter,
        device_element_uses.work_distance_meter AS work_distance_meter,
        device_element_uses.elapsed_time_seconds AS elapsed_time_seconds,
        device_element_uses.work_time_seconds AS work_time_seconds,
        device_element_uses.crop_count AS crop_count,
        device_element_uses.crop_counts_by_size AS crop_counts_by_size,
        device_element_uses.crop_counts_by_score AS crop_counts_by_score,
        device_element_uses.crop_counts_by_spacing AS crop_counts_by_spacing,
        machine_config_data.lens_working_dist_meter AS lens_working_dist_meter,
        machine_config_data.plant_line_count AS plant_line_count,
        machine_config_data.width_meter AS width_meter,
        machine_config_data.line_spacing_meter AS line_spacing_meter,
        machine_config_data.plant_spacing_meter AS plant_spacing_meter,
        machine_config_data.max_side_shift_travel_meter AS max_side_shift_travel_meter,
        device_element_uses.start_time AS start_time,
        device_element_uses.end_time AS end_time
    FROM norma.device_element_uses AS device_element_uses
    LEFT JOIN norma.machine_config_data AS machine_config_data 
    ON machine_config_data.machine_use_id = device_element_uses.id
    LEFT JOIN norma.operation_data AS operation_data
    ON operation_data.id = device_element_uses.operation_data_id
    LEFT JOIN norma.work_item_operations AS work_item_operations
    ON work_item_operations.id = operation_data.work_item_operation_id
    LEFT JOIN norma.device_elements AS device_elements
    ON device_elements.id = work_item_operations.device_element_id
);

CREATE OR REPLACE VIEW apiview.manufacturers AS (
    SELECT 
        id,
        cname AS manufacturer_name
    FROM norma.manufacturers
);

CREATE OR REPLACE VIEW apiview.map_layers AS (
    SELECT 
        reference_layers.id AS id,
        reference_layers.cname AS map_layer_name,
        reference_layers.notes AS map_layer_notes,
        reference_layers.organization_id AS organization_id,
        reference_layers.layer_type AS map_layer_type,
        reference_layers.source_format AS map_layer_source_format,
        reference_layers.source_date AS map_layer_source_date,
        CASE
            WHEN reference_layers.source_format = 'Vector' THEN reference_layers.vector_source->>0
            WHEN reference_layers.source_format = 'Raster' THEN encode(reference_layers.raster_source, 'base64')
        END AS map_layer_source,
        reference_layers.bounding_polygon AS bounding_polygon,
        array_agg(fields.cname) AS contained_field_names
    FROM norma.reference_layers AS reference_layers
    LEFT JOIN norma.field_boundaries AS field_boundaries 
    ON st_contains(reference_layers.bounding_polygon, field_boundaries.geom)
    LEFT JOIN norma.fields AS fields 
    ON fields.id = field_boundaries.field_id
    GROUP BY reference_layers.id
);

CREATE OR REPLACE VIEW apiview.organizations AS (
    SELECT 
        organizations.id AS id,
        organizations.cname AS organization_name,
        array_agg(farms.cname) AS farm_names,
        array_agg(fields.cname) AS field_names,
        array_agg(DISTINCT growers.cname) AS grower_names
    FROM norma.organizations AS organizations
    LEFT JOIN norma.farms AS farms 
    ON farms.organization_id = organizations.id
    LEFT JOIN norma.fields AS fields
    ON fields.farm_id = farms.id
    LEFT JOIN norma.growers AS growers 
    ON growers.id = farms.grower_id
    GROUP BY organizations.id
);

CREATE OR REPLACE VIEW apiview.prescriptions AS (
    SELECT 
        prescriptions.id AS id,
        prescriptions.cname AS rx_name,
        work_item_operations.cname AS task_name,
        crop_zones.crop_season AS crop_season,
        crop_zones.cname AS crop_zone_name,
        fields.cname AS field_name,
        prescriptions.rx_type AS rx_type,
        prescriptions_aggregated.rx_recipes_json AS rx_recipes_json,
        CASE
            WHEN prescriptions.rx_type = 'VectorPrescription' THEN row_to_json(row(prescriptions.vector_rx_detail))
            WHEN prescriptions.rx_type = 'RasterGridPrescription' THEN row_to_json(row(prescriptions.raster_grid_rx_detail))
            WHEN prescriptions.rx_type = 'RadialPrescription' THEN row_to_json(row(prescriptions.radial_rx_detail))
            WHEN prescriptions.rx_type = 'ManualPrescription' THEN row_to_json(row(prescriptions.manual_rx_detail))
        END AS rx_detail_json,
        concat(users.first_name, ' ', users.last_name) AS prescriber_name,
        prescriptions.created AS created,
        prescriptions.updated AS updated
    FROM norma.prescriptions AS prescriptions
    LEFT JOIN norma.work_item_operations AS work_item_operations 
    ON work_item_operations.id = prescriptions.work_item_operation_id
    LEFT JOIN norma.work_items AS work_items 
    ON work_items.id = work_item_operations.work_item_id
    LEFT JOIN norma.crop_zones AS crop_zones
    ON crop_zones.id = work_items.crop_zone_id
    LEFT JOIN norma.fields AS fields
    ON fields.id = crop_zones.field_id
    LEFT JOIN norma.users AS users 
    ON users.id = prescriptions.prescriber
    LEFT JOIN (
        SELECT 
            prescriptions_unnested.id AS id,
            array_agg(prescriptions_unnested.rx_recipe_json) AS rx_recipes_json
        FROM (
            SELECT 
                prescriptions_inner.id AS id,
                row_to_json(row(unnest(prescriptions_inner.rx_recipes))) AS rx_recipe_json
            FROM norma.prescriptions AS prescriptions_inner
        ) AS prescriptions_unnested
        GROUP BY prescriptions_unnested.id
    ) AS prescriptions_aggregated
    ON prescriptions_aggregated.id = prescriptions.id
);

CREATE OR REPLACE VIEW apiview.products AS (
    SELECT 
        products.id AS id,
        products.cname AS product_name,
        brands.cname AS product_brand_name,
        products.category AS product_category,
        products.product_type AS product_type,
        products.product_form AS product_form,
        products.product_components AS product_components,
        products.density AS density,
        products.has_crop_nutrition AS has_crop_nutrition,
        products.has_crop_protection AS has_crop_protection,
        products.has_crop_variety AS has_crop_variety,
        products.has_harvested_commodity AS harvested_commodity,
        products.product_status AS product_status
    FROM norma.products AS products
    LEFT JOIN norma.brands AS brands 
    ON brands.id = products.brand_id
);

CREATE OR REPLACE VIEW apiview.roles AS (
    SELECT 
        roles.id AS id,
        roles.rolename AS rolename,
        roles.organization_id AS organization_id,
        organizations.cname AS organization_name,
        roles.role_permissions AS role_permissions,
        roles.created AS created,
        roles.updated AS updated
    FROM norma.roles AS roles
    LEFT JOIN norma.organizations AS organizations ON organizations.id = roles.organization_id
);

CREATE OR REPLACE VIEW apiview.tasks AS (
    SELECT 
        work_item_operations.id AS id,
        work_item_operations.cname AS task_name,
        jobs.organization_id AS organization_id,
        jobs.grower_name AS grower_name,
        jobs.crop_season AS crop_season,
        jobs.farm_name AS farm_name,
        jobs.field_name AS field_name,
        jobs.crop_zone_name AS crop_zone_name,
        jobs.work_order_name AS work_order_name,
        jobs.id AS job_id,
        jobs.job_name AS job_name,
        work_item_operations.operation_type AS operation_type,
        device_elements.id AS machine_id,
        device_elements.cname AS machine_name,
        prescriptions.cname AS prescription_name,
        concat(users.first_name, ' ', users.last_name) AS task_operator_name,
        work_item_operations.work_item_operation_status AS task_status,
        operation_data.id AS task_operations_data_id,
        work_item_operations.start_time AS start_time,
        work_item_operations.end_time AS end_time,
        work_item_operations.notes AS notes,
        work_item_operations.archived AS archived,
        work_item_operations.created AS created,
        work_item_operations.updated AS updated
    FROM norma.work_item_operations AS work_item_operations
    LEFT JOIN apiview.jobs AS jobs 
    ON jobs.id = work_item_operations.work_item_id
    LEFT JOIN norma.device_elements AS device_elements 
    ON device_elements.id = work_item_operations.device_element_id
    LEFT JOIN norma.prescriptions AS prescriptions 
    ON prescriptions.work_item_operation_id = work_item_operations.id
    LEFT JOIN norma.users AS users 
    ON users.id = work_item_operations.operator_id
    LEFT JOIN norma.operation_data AS operation_data
    ON operation_data.work_item_operation_id = work_item_operations.id
);

CREATE OR REPLACE VIEW apiview.task_operations_data AS (
    SELECT 
        operation_data.id AS id,
        tasks.work_order_name AS work_order_name,
        tasks.job_id AS job_id,
        tasks.job_name AS job_name,
        tasks.id AS task_id,
        tasks.task_name AS task_name,
        tasks.organization_id AS organization_id,
        tasks.grower_name AS grower_name,
        tasks.crop_season AS crop_season,
        tasks.field_name AS field_name,
        tasks.crop_zone_name AS crop_zone_name,
        tasks.operation_type AS operation_type,
        tasks.machine_id AS machine_id,
        tasks.machine_name AS machine_name,
        od1_aggregated.device_element_use_id_array AS machine_use_id_array,
        od1_aggregated.travel_distance_meter_array AS travel_distance_meter_array,
        od1_aggregated.work_distance_meter_array AS work_distance_meter_array,
        od1_aggregated.elapsed_time_seconds_array AS elapsed_time_seconds_array,
        od1_aggregated.work_time_seconds_array AS work_time_seconds_array,
        od1_aggregated.crop_count_array AS crop_count_array,
        od1_aggregated.crop_counts_by_size_array AS crop_counts_by_size_array,
        od1_aggregated.crop_counts_by_score_array AS crop_counts_by_score_array,
        od1_aggregated.crop_counts_by_spacing_array AS crop_counts_by_spacing_array,
        od1_aggregated.width_meter_array AS width_meter_array,
        od1_aggregated.plant_line_count_array AS plant_line_count_array,
        od1_aggregated.line_spacing_meter_array AS line_spacing_meter_array,
        od1_aggregated.plant_spacing_meter_array AS plant_spacing_meter_array,
        od1_aggregated.buffer_distance_meter_array AS buffer_distance_meter_array,
        od1_aggregated.lens_working_dist_meter_array AS lens_working_dist_meter_array,
        od1_aggregated.max_side_shift_travel_meter_array AS max_side_shift_travel_meter_array,
        od1_aggregated.fov_height_degree_array AS fov_height_degree_array,
        od1_aggregated.detection_rate_threshold_array AS detection_rate_threshold_array,
        od2_aggregated.spatial_records_json AS spatial_records_json,
        row_to_json(row(operation_data.data_log_trigger_record)) AS data_log_trigger_record_json
    FROM norma.operation_data AS operation_data 
    LEFT JOIN apiview.tasks AS tasks 
    ON tasks.id = operation_data.work_item_operation_id
    LEFT JOIN (
        SELECT 
            od_deu_mcd_joined.id AS id,
            array_agg(od_deu_mcd_joined.device_element_use_id) AS device_element_use_id_array,
            array_agg(od_deu_mcd_joined.travel_distance_meter) AS travel_distance_meter_array,
            array_agg(od_deu_mcd_joined.work_distance_meter) AS work_distance_meter_array,
            array_agg(od_deu_mcd_joined.elapsed_time_seconds) AS elapsed_time_seconds_array,
            array_agg(od_deu_mcd_joined.work_time_seconds) AS work_time_seconds_array,
            array_agg(od_deu_mcd_joined.crop_count) AS crop_count_array,
            array_agg(od_deu_mcd_joined.crop_counts_by_size) AS crop_counts_by_size_array,
            array_agg(od_deu_mcd_joined.crop_counts_by_score) AS crop_counts_by_score_array,
            array_agg(od_deu_mcd_joined.crop_counts_by_spacing) AS crop_counts_by_spacing_array,
            array_agg(od_deu_mcd_joined.width_meter) AS width_meter_array,
            array_agg(od_deu_mcd_joined.plant_line_count) AS plant_line_count_array,
            array_agg(od_deu_mcd_joined.line_spacing_meter) AS line_spacing_meter_array,
            array_agg(od_deu_mcd_joined.plant_spacing_meter) AS plant_spacing_meter_array,
            array_agg(od_deu_mcd_joined.buffer_distance_meter) AS buffer_distance_meter_array,
            array_agg(od_deu_mcd_joined.lens_working_dist_meter) AS lens_working_dist_meter_array,
            array_agg(od_deu_mcd_joined.max_side_shift_travel_meter) AS max_side_shift_travel_meter_array,
            array_agg(od_deu_mcd_joined.fov_height_degree) AS fov_height_degree_array,
            array_agg(od_deu_mcd_joined.detection_rate_threshold) AS detection_rate_threshold_array
        FROM (
            SELECT 
                od1.id AS id,
                deu.id AS device_element_use_id,
                deu.travel_distance_meter AS travel_distance_meter,
                deu.work_distance_meter AS work_distance_meter,
                deu.elapsed_time_seconds AS elapsed_time_seconds,
                deu.work_time_seconds AS work_time_seconds,
                deu.crop_count AS crop_count,
                deu.crop_counts_by_size AS crop_counts_by_size,
                deu.crop_counts_by_score AS crop_counts_by_score,
                deu.crop_counts_by_spacing AS crop_counts_by_spacing,
                mcd.width_meter AS width_meter,
                mcd.plant_line_count AS plant_line_count,
                mcd.line_spacing_meter AS line_spacing_meter,
                mcd.plant_spacing_meter AS plant_spacing_meter,
                mcd.buffer_distance_meter AS buffer_distance_meter,
                mcd.lens_working_dist_meter AS lens_working_dist_meter,
                mcd.max_side_shift_travel_meter AS max_side_shift_travel_meter,
                mcd.fov_height_degree AS fov_height_degree,
                mcd.detection_rate_threshold AS detection_rate_threshold
            FROM norma.operation_data AS od1
            LEFT JOIN norma.device_element_uses AS deu 
            ON deu.operation_data_id = od1.id
            LEFT JOIN norma.machine_config_data AS mcd
            ON mcd.machine_use_id = deu.id
        ) AS od_deu_mcd_joined
        GROUP BY od_deu_mcd_joined.id
    ) AS od1_aggregated
    ON od1_aggregated.id = operation_data.id
    LEFT JOIN (
        SELECT 
            od2_unnested.id AS id,
            array_agg(od2_unnested.spatial_record_json) AS spatial_records_json
        FROM (
            SELECT
                od2.id AS id,
                row_to_json(row(unnest(od2.spatial_records))) AS spatial_record_json
            FROM norma.operation_data AS od2
        ) AS od2_unnested
        GROUP BY od2_unnested.id
    ) AS od2_aggregated
    ON od2_aggregated.id = operation_data.id
);

CREATE OR REPLACE VIEW apiview.users AS (
    SELECT 
        users.id AS id,
        users.username AS username,
        users.organization_id AS organization_id,
        users.role_ids AS role_ids,
        users_with_limited_fields.role_names AS role_names,
        users_with_limited_fields.permissions_list AS permissions_list,
        users.last_name AS last_name,
        users.first_name AS first_name,
        users.affiliated_entity AS affiliated_entity,
        users.job_title AS job_title,
        users.created AS created,
        users.updated AS updated
    FROM (
        SELECT 
            users_joined_with_roles.id AS id,
            array_agg(users_joined_with_roles.rolename) AS role_names,
            array_agg(users_joined_with_roles.role_permissions) AS permissions_list
        FROM (
            SELECT 
                users_with_unnested_role_ids.id AS id,
                roles.rolename AS rolename,
                roles.role_permissions AS role_permissions
            FROM (
                SELECT 
                    _users_.id AS id,
                    unnest(_users_.role_ids) AS role_id
                FROM norma.users AS _users_
            ) AS users_with_unnested_role_ids
            LEFT JOIN norma.roles AS roles ON roles.id = users_with_unnested_role_ids.role_id
        ) AS users_joined_with_roles
        GROUP BY users_joined_with_roles.id
    ) AS users_with_limited_fields
    INNER JOIN norma.users AS users ON users.id = users_with_limited_fields.id
);

CREATE OR REPLACE VIEW apiview.work_orders AS (
    SELECT 
        work_orders.id AS id,
        work_orders.cname AS work_order_name,
        work_orders.work_order_version AS work_order_version,
        work_orders.organization_id AS organization_id,
        growers.cname AS grower_name,
        CONCAT(users.first_name, ' ', users.last_name) AS farm_manager_name,
        work_orders.crop_season AS crop_season,
        crop_types.cname AS crop_name,
        fields.cname AS field_name,
        wo1_aggregated.job_names AS job_names,
        wo2_aggregated.status_updates_json AS status_updates_json,
        work_orders.archived AS archived,
        work_orders.created AS created,
        work_orders.updated AS updated
    FROM norma.work_orders AS work_orders
    LEFT JOIN norma.growers AS growers
    ON growers.id = work_orders.grower_id
    LEFT JOIN norma.users AS users
    ON users.id = work_orders.work_order_manager_id
    LEFT JOIN norma.crop_types AS crop_types
    ON crop_types.code = work_orders.crop_code
    LEFT JOIN norma.fields AS fields
    ON fields.id = work_orders.field_id
    LEFT JOIN (
        SELECT 
            wo1.id AS id,
            array_agg(work_items.cname) AS job_names
        FROM norma.work_orders AS wo1
        LEFT JOIN norma.work_items AS work_items
        ON work_items.work_order_id = wo1.id
        GROUP BY wo1.id
    ) AS wo1_aggregated
    ON wo1_aggregated.id = work_orders.id
    LEFT JOIN (
        SELECT
            wo2_unnested.id AS id,
            array_agg(wo2_unnested.status_update_json) AS status_updates_json
        FROM (
            SELECT 
                wo2.id AS id,
                row_to_json(row(unnest(wo2.status_updates))) AS status_update_json
            FROM norma.work_orders AS wo2
        ) wo2_unnested
        GROUP BY wo2_unnested.id
    ) AS wo2_aggregated
    ON wo2_aggregated.id = work_orders.id
);