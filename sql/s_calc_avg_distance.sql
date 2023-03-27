CREATE OR REPLACE FUNCTION s_calc_avg_distance (ts_begin varchar, ts_end varchar) 
RETURNS integer AS 
$$
DECLARE

    dist integer;

BEGIN

    SELECT sum(avg_dist_by_ts_bucket.avg_dist) INTO dist
    FROM (
        SELECT ts_bucket, sum(ST_Length(trace::geography))/count(id) as avg_dist
        FROM cultivator_trace 
        WHERE ts_bucket >= date_trunc('hour', ts_begin::timestamp) AND ts_bucket <= date_trunc('hour', ts_end::timestamp)
        GROUP BY ts_bucket HAVING count(id) > 0
    ) AS avg_dist_by_ts_bucket;

    RETURN dist;   

END;
$$ LANGUAGE plpgsql; 