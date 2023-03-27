CREATE OR REPLACE FUNCTION s_calc_distance (cid varchar, ts_begin varchar, ts_end varchar) 
RETURNS integer AS 
$$
DECLARE

    dist integer;

BEGIN

    SELECT ST_Length(ST_MakeLine(cultivator_trace_filtered.trace)::geography)::integer INTO dist
    FROM (
        SELECT ts_bucket, trace 
        FROM cultivator_trace 
        WHERE id = cid AND ts_bucket >= date_trunc('hour', ts_begin::timestamp) AND ts_bucket <= date_trunc('hour', ts_end::timestamp)
        ORDER BY ts_bucket
    ) AS cultivator_trace_filtered;

    RETURN dist;

END;
$$ LANGUAGE plpgsql; 