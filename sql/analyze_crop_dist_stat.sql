CREATE FUNCTION analyze_crop_dist_stat() RETURNS void AS $$
DECLARE
    _sub_cnt integer;
    _avg_avg numeric;
    _avg_sdv numeric;
BEGIN
    IF NOT exists(SELECT * FROM information_schema.columns WHERE table_name = 'crop_dist_stat') THEN
        CREATE TABLE crop_dist_stat (radius_in integer, analysis_band integer, sub_crop_cnt integer, avg_avg_dist numeric, avg_sdv_dist numeric);
    END IF;
    FOR i IN 0..10 LOOP
        SELECT count(*), avg(to_number(near_9->'avg', '99D9999')), avg(to_number(near_9->'sdv', '99D9999'))
            INTO _sub_cnt, _avg_avg, _avg_sdv
            FROM plants
            WHERE to_number(near_9->'n', '999999') = i;
        INSERT 
            INTO crop_dist_stat (radius_in, analysis_band, sub_crop_cnt, avg_avg_dist, avg_sdv_dist) 
            VALUES (9, i, _sub_cnt, _avg_avg*39.37, _avg_sdv*39.37);
    END LOOP;
    FOR i IN 0..10 LOOP
        SELECT count(*), avg(to_number(near_12->'avg', '99D9999')), avg(to_number(near_12->'sdv', '99D9999'))
            INTO _sub_cnt, _avg_avg, _avg_sdv
            FROM plants
            WHERE to_number(near_12->'n', '999999') = i;
        INSERT 
            INTO crop_dist_stat (radius_in, analysis_band, sub_crop_cnt, avg_avg_dist, avg_sdv_dist) 
            VALUES (12, i, _sub_cnt, _avg_avg*39.37, _avg_sdv*39.37);
    END LOOP;
    FOR i IN 0..10 LOOP
        SELECT count(*), avg(to_number(near_15->'avg', '99D9999')), avg(to_number(near_15->'sdv', '99D9999')) 
            INTO _sub_cnt, _avg_avg, _avg_sdv
            FROM plants
            WHERE to_number(near_15->'n', '999999') = i;
        INSERT 
            INTO crop_dist_stat (radius_in, analysis_band, sub_crop_cnt, avg_avg_dist, avg_sdv_dist) 
            VALUES (15, i, _sub_cnt, _avg_avg*39.37, _avg_sdv*39.37);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
