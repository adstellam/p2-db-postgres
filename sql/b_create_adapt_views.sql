CREATE OR REPLACE VIEW adapt.field AS
    SELECT norma.field.*, norma.farm.grower_id 
    FROM norma.field 
    LEFT JOIN norma.farm
    ON norma.field.farm_id = norma.farm.id;

CREATE OR REPLACE VIEW adapt.logged_data AS
    SELECT a.*, array_agg(b.)
    FROM
    (
        SELECT 
            norma.logged_data.*, 
            adapt.field.id AS field_id, 
            adapt.field.farm_id AS farm_id, 
            adap.field.grower_id AS grower_id, 
        FROM norma.logged_data
        LEFT JOIN norma.crop_zone
        ON norma.logged_data.crop_zone_id = norma.crop_zone.id
        LEFT JOIN adapt.field
        ON norma.crop_zone.field_id = adapt.field.id
    ) a,
    (

    ) b


CREATE OR REPLACE VIEW adapt.obs AS
    SELECT norma.obs.*,  
        CASE
            WHEN norma.obs.place_type = "Location" THEN null
            WHEN norma.obs.place_type = "CropZone" THEN
            (
                SELECT grower_id
                FROM adapt.field
                JOIN norma.crop_zone
                ON adapt.field.id = norma.crop_zone.field_id
                WHERE norma.crop_zone.id = norma.obs.crop_zone_id
            )
            WHEN norma.obs.place_type = "Field" THEN
            (
                SELECT grower_id
                FROM adapt.field
                WHERE adapt.field.id = norma.obs.field_id
            )
            WHEN norma.obs.place_type = "Farm" THEN
            (   
                SELECT grower_id 
                FROM norma.farm
                WHERE norma.farm.id = norma.obs.farm_id 
            )
            WHEN norma.obs.place_type = "Facility" THEN null
            WHEN norma.obs.place_type = "DeviceElement" THEN null
        END AS grower_id
    FROM norma.obs 
    LEFT JOIN norma.place
    ON norma.obs.place_id = norma.place.id;

CREATE OR REPLACE VIEW adapt.operation_data AS 
    SELECT 
        norma.operation_data.*, 
        norma.work_item_operation.operation_type, 
        norma.work_item_operation.prescription_id, 
        adapt.prescription.product_ids  
    FROM norma.operation_data
    LEFT JOIN norma.work_item_operation
    ON norma.operation_data.work_item_operation_id = norma.work_item_operation.id
    LEFT JOIN norma.prescription
    ON norma.work_item_operation.prescription_id = adapt.prescription.id

CREATE OR REPLACE VIEW adapt.prescription AS
    SELECT a.*, b.product_ids
    FROM 
    (   
        SELECT norma.prescription.*, norma.crop_zone.field_id, 
        FROM norma.prescription 
        LEFT JOIN norma.crop_zone
        ON norma.prescription.crop_zone_id = norma.crop_zone.id
    ) a
    LEFT JOIN
    (   
        SELECT id, array_agg(product_unnested) AS product_ids
        FROM 
        (   
            SELECT id, unnest(rx_product_lookups) AS product_unnested
            FROM norma.prescription
        )
        GROUP BY id
    ) b
    ON a.id = b.id;

CREATE OR REPLACE VIEW adapt.work_item AS 
    SELECT a.*, array_agg(b.equipment_configuration_unnested)
    FROM
    (
        SELECT 
            norma.work_item.*, 
            adapt.field.id AS field_id, 
            adapt.field.farm_id AS farm_id, 
            adapt.field.grower_id AS grower_id, 
            adapt.field.active_boundary_id AS boundary_id 
        FROM norma.work_item
        LEFT JOIN norma.crop_zone
        ON norma.work_item.crop_zone_d = norma.crop_zone.id
        LEFT JOIN adapt.field
        ON norma.crop_zone.field_id = adapt.field.id
    ) a,
    LEFT JOIN
    (
        SELECT work_item_id, unnest(equipment_configuration_ids) AS equipment_configuration_unnested
        FROM norma.work_item_operation
    ) b
    ON a.id = b.work_item_id
    GROUP BY a.id;
    
CREATE OR REPLACE VIEW adapt.work_order AS 
    SELECT 
        a.*, 
        array_agg(a.crop_zone_id) AS crop_zone_ids, 
        array_agg(a.field_id) AS field_ids, 
        array_agg(a.farm_id) AS farm_ids, 
        array_agg(norma.crop_one.crop_id) AS crop_ids, 
        sum(norma.crop_zone.area) AS estimated_area
    FROM 
    (
        SELECT *, unnest(work_items) AS item
        FROM norma.work_order
    ) a
    LEFT JOIN adapt.work_item
    ON a.item.id = adapt.work_item.id
    LEFT JOIN norma.crop_zone
    ON adapt.work_item.crop_zond_id = norma.crop_zone.id
    GROUP BY a.id;
