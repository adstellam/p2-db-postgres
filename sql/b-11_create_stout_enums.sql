CREATE TYPE stout.api_resource_enum AS ENUM (
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

CREATE TYPE stout.http_method_enum AS ENUM (
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE'
);

CREATE TYPE stout.seed_type_enum AS ENUM (

);

CREATE TYPE stout.user_affiliation_category_enum AS ENUM (
    'Organization',
    'Grower',
    'Contractor'
);
