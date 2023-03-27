CREATE FUNCTION add_pos_geom_col_to_plants_table() RETURNS void AS $$
DECLARE
   cnt integer;
   cur CURSOR FOR SELECT id, ST_MakePoint(pos[0], pos[1]) AS geom FROM plants;
BEGIN
    IF NOT exists(SELECT * FROM information_schema.columns WHERE table_name = 'plants' AND column_name = 'pos_geom') THEN
        ALTER TABLE plants ADD COLUMN pos_geom geometry(point, 4326);
    END IF;
    FOR row IN cur LOOP
        UPDATE plants SET pos_geom = row.geom WHERE id = row.id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
