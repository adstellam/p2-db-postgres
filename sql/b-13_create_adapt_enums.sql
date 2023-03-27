CREATE TYPE adapt.application_strategy_enum AS ENUM (
    'RatePerArea',
    'RatePerTank',
    'TotalProduct'
);

CREATE TYPE adapt.category_enum AS ENUM (
    'Additive',
    'Carrier',
    'Fungicide',
    'GrowthRegulator',
    'Insecticide',
    'Herbicide',
    'Manure',
    'NitrogenStabilizer',
    'Unknown',
    'Variety',
    'Fertilizer',
    'Pesticide'
);

CREATE TYPE adapt.date_context_enum AS ENUM (
    'Approval',
    'ProposedStart',
    'ProposedEnd',
    'CropSeason',
    'TimingEvent',
    'ActualStart',
    'ActualEnd',
    'RequestedStart',
    'RequestedEnd',
    'Expiration',
    'Creation',
    'Modification',
    'ValidityRange',
    'RequestedShipping',
    'AcutalShipping',
    'Calibration',
    'Load',
    'Unload',
    'Suspend',
    'Resume',
    'Unspecified',
    'Installation',
    'Maintenance',
    'PhenomenonTime'
);

CREATE TYPE adapt.device_element_type_enum AS ENUM (
    'Machine',
    'Implement',
    'Sensor',
    'Bin',
    'Section',
    'Unit',
    'Function',
    'IrrSystem',
    'IrrSection',
    'Endgun'
);

CREATE TYPE adapt.gps_source_enum AS ENUM (
    'Unknown',
    'Drawn',
    'MobileGPS',
    'DeereRTK',
    'DeereRTKX',
    'DeereSF1',
    'DeereSF2',
    'DeereWAAS',
    'GNSSfix',
    'DGNSSfix',
    'PreciseGNSS',
    'RTKFixedInteger',
    'RTKFloat',
    'EstDRMode',
    'ManualInput',
    'SimulateMode',
    'DesktopGeneratedData',
    'Other',
    'PPP',
    'SBAS',
    'Mechanical'
);

CREATE TYPE adapt.guidance_extension_enum AS ENUM (
    'FromBothPoints',
    'FromA',
    'FromB',
    'None'
);

CREATE TYPE adapt.guidance_pattern_type_enum AS ENUM (
    'APlus',
    'AbLine',
    'AbCurve',
    'CenterPivot',
    'Spiral'
);

CREATE TYPE adapt.logging_level_enum AS ENUM (
    'MachineType',
    'SpecificMachine',
    'ImplementType',
    'SpecificImplement',
    'SpecificSection',
    'SpecificMeter',
    'Unspecified'
);

CREATE TYPE adapt.logging_method_enum AS ENUM (
    'TimeInterval',
    'DistanceInterval',
    'ThresholdLimits',
    'OnChange',
    'Total'
);

CREATE TYPE adapt.operation_type_enum AS ENUM (
    'Unknown',
    'Fertilizing',
    'SowingAndPlanting',
    'CropProtection',
    'Tillage',
    'Baling',
    'Mowing',
    'Wrapping',
    'Harvesting',
    'ForageHarvesting',
    'Tansport',
    'Swathing',
    'Irrigation'
);

CREATE TYPE adapt.origin_axel_location_enum AS ENUM (
    'Front',
    'Rear'
);

CREATE TYPE adapt.place_type_enum AS ENUM (
    'Location',
    'CropZone',
    'Field',
    'Farm',
    'Facility',
    'DeviceElement'
);

CREATE TYPE adapt.prescription_type_enum AS ENUM (
    'VectorPrescription',
    'RasterGridPrescription',
    'RadialPrescription',
    'ManualPrescription'
);

CREATE TYPE adapt.product_form_enum AS ENUM (

);

CREATE TYPE adapt.product_status_enum AS ENUM (

);

CREATE TYPE adapt.product_type_enum AS ENUM (

);

CREATE TYPE adapt.propagation_direction_enum AS ENUM (
    'BothDirections',
    'LeftOnly',
    'RightOnly',
    'NoPropagation'
);

CREATE TYPE adapt.reference_layer_source_format_enum AS ENUM (
    'Vector',
    'Raster'
);

CREATE TYPE adapt.reference_layer_type_enum AS ENUM (
    'BackgroundImage',
    'CommonLandUnit',
    'ElevationMap',
    'ManagementZone',
    'Obstacles',
    'ProfitMap',
    'SoilTypeMap',
    'VarietyLocator'
);

CREATE TYPE adapt.seed_type_enum AS ENUM (

);

CREATE TYPE adapt.work_item_priority_enum AS ENUM (
    'Immediately',
    'AsSoonAsPossible',
    'High',
    'Medium',
    'Low'
);

CREATE TYPE adapt.work_status_enum AS ENUM (
    'Scheduled',
    'InProgress',
    'Paused',
    'PartiallyCompleted',
    'Completed',
    'Cancelled'
);

