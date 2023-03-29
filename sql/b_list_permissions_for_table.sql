SELECT grantee, privilege_type 
FROM information_schema.role_table_grants as rtg
WHERE table_name = 'plant_types';
