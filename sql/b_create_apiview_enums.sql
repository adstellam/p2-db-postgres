CREATE TYPE apiview.api_resource_enum AS ENUM (
    'Job',
    'JobDTO',
    'Task',
    'TaskDTO',
    'TasKOperationsData',
    'TaskOperationsDataDTO',
    'Field',
    'FieldDTO',
    'FieldBoundary',
    'FieldBoundaryDTO',
    'CropZone',
    'CropZoneDTO',
    'CropObservationsData',
    'CropObservationsDataDTO',
    'CropImage',
    'CropImageDTO',
    'Machine',
    'MachineDTO',
    'MachineTelematicsData',
    'MachineTelematicsDataDTO',
    'MapLayer',
    'MapLayerDTO',
    'User',
    'UserDTO',
    'Role',
    'RoleDTO'
);

CREATE TYPE apiview.http_method_enum AS ENUM (
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE'
);

CREATE TYPE apiview.seed_type_enum AS ENUM (

);

CREATE TYPE apiview.user_affiliation_category_enum AS ENUM (
    'Organization',
    'Grower',
    'Contractor'
);
