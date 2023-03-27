CREATE OR REPLACE FUNCTION s_update_cultivator_pos (cultivator_id varchar, cultivator_pos varchar) 
RETURNS void AS
$$
DECLARE

BEGIN

    UPDATE cultivators 
    SET pos = cultivator_pos::json
    WHERE cid = cultivator_id;
    
END;
$$ LANGUAGE plpgsql;