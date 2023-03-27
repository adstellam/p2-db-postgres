CREATE OR REPLACE FUNCTION s_update_cultivator_trace (cid varchar, ts varchar, lon numeric, lat numeric) 
RETURNS void AS 
$$
DECLARE

    _trace geometry;
    _last_pos geometry := ST_Point(lon, lat);

BEGIN

    SELECT trace INTO _trace 
    FROM cultivator_trace 
    WHERE id = cid AND ts_bucket = date_trunc('hour', ts::timestamp);
    
    IF FOUND THEN
        _trace := ST_AddPoint(_trace, ST_Point(lon, lat));
        _last_pos := ST_PointN(_trace, -1);
        UPDATE cultivator_trace 
            SET trace = _trace
            WHERE id = cid AND ts_bucket = date_trunc('hour', ts::timestamp);
        RAISE NOTICE 'UPDATE %', cid;
    ELSE 
        _trace := ST_MakeLine(_last_pos, ST_Point(lon, lat));
        _last_pos := ST_PointN(_trace, -1);
        INSERT 
            INTO cultivator_trace (id, ts_bucket, trace)
            VALUES (cid, date_trunc('hour', ts::timestamp), _trace); 
        RAISE NOTICE 'INSERT %', cid;
    END IF;
    
END;
$$ LANGUAGE plpgsql;