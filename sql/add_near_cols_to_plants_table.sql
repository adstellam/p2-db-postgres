CREATE FUNCTION add_near_cols_to_plants_table() RETURNS void AS $$    
    DECLARE
        _dist numeric;
        _n_nears integer;
        _sum_dist numeric;
        _sum_squared_dist numeric;
        _min_dist numeric;
        _max_dist numeric;
        _avg_dist numeric;
        _sdv_dist numeric;
        _hstore text;
        _cur_i CURSOR FOR SELECT id, pos_geom FROM plants;
        _cur_j CURSOR FOR SELECT id, pos_geom FROM plants;
    BEGIN
        IF NOT exists(SELECT * FROM information_schema.columns WHERE table_name = 'plants' AND column_name = 'near_9') THEN
            ALTER TABLE plants ADD COLUMN near_9 hstore;
        END IF;
        IF NOT exists(SELECT * FROM information_schema.columns WHERE table_name = 'plants' AND column_name = 'near_12') THEN
            ALTER TABLE plants ADD COLUMN near_12 hstore;
        END IF;
        IF NOT exists(SELECT * FROM information_schema.columns WHERE table_name = 'plants' AND column_name = 'near_15') THEN
            ALTER TABLE plants ADD COLUMN near_15 hstore;
        END IF;
        FOR radius IN 9..15 BY 3 LOOP
            FOR row_i IN _cur_i LOOP
                _n_nears := 0;
                _sum_dist := 0;
                _sum_squared_dist := 0;
                _min_dist := radius*0.0254;
                _max_dist := 0;
                FOR row_j IN _cur_j LOOP
                    IF row_j.id != row_i.id AND ST_DWithin(row_j.pos_geom::geography, row_i.pos_geom::geography, radius*0.0254, true) THEN
                        _n_nears := _n_nears + 1;
                        _dist := ST_Distance(row_j.pos_geom::geography, row_i.pos_geom::geography, true);
                        _sum_dist := _sum_dist + _dist;
                        _sum_squared_dist := _sum_squared_dist + _dist * _dist;
                        IF _dist < _min_dist THEN
                            _min_dist := _dist;
                        END IF;
                        IF _dist > _max_dist THEN
                            _max_dist := _dist;
                        END IF;
                    END IF;
                END LOOP;
                IF _n_nears != 0 THEN
                    _avg_dist := _sum_dist/_n_nears::numeric;
                    _sdv_dist := sqrt(_sum_squared_dist/_n_nears::numeric - _avg_dist * _avg_dist); 
                ELSE
                    _avg_dist := 0;
                    _sdv_dist := 0; 
                END IF;
                _hstore := 'id=>' || row_i.id
                    || ',n=>' || to_char(_n_nears, '999999') 
                    || ',min=>' || to_char(_min_dist, '99D9999') 
                    || ',max=>' || to_char(_max_dist, '99D9999') 
                    || ',avg=>' || to_char(_avg_dist, '99D9999')
                    || ',sdv=>' || to_char(_sdv_dist, '99D9999');
                IF radius = 9 THEN
                    UPDATE plants SET near_9 = _hstore::hstore WHERE id = row_i.id;
                END IF;
                IF radius = 12 THEN
                    UPDATE plants SET near_12 = _hstore::hstore WHERE id = row_i.id;
                END IF;
                IF radius = 15 THEN
                    UPDATE plants SET near_15 = _hstore::hstore WHERE id = row_i.id;
                END IF;
            END LOOP;
        END LOOP;
    END;
$$ LANGUAGE plpgsql;
