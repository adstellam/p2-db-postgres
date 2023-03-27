CREATE OR REPLACE FUNCTION s_concat_trace (cid varchar, ts_begin varchar, ts_end varchar) 
RETURNS json AS
$$
DECLARE

    concat_trace geometry;

BEGIN

    SELECT ST_MakeLine(cultivator_trace_filtered_by_ts_bucket.trace) INTO concat_trace 
    FROM (
        SELECT ts_bucket, trace 
        FROM cultivator_trace 
        WHERE id = cid AND ts_bucket >= date_trunc('hour', ts_begin::timestamp) AND ts_bucket <= date_trunc('hour', ts_end::timestamp)
        ORDER BY ts_bucket
    ) AS cultivator_trace_filtered_by_ts_bucket;

    RETURN ST_AsGeoJson(concat_trace);
    
END;
$$ LANGUAGE plpgsql;