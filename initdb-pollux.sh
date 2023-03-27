#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_USER" <<-EOSQL
    CREATE EXTENSION postgis;
    CREATE EXTENSION hstore;
    CREATE EXTENSION pgcrypto;
    CREATE USER api WITH PASSWORD '$tout';
    GRANT connect ON database postgres TO api;
    GRANT select, insert, update, delete ON all tables IN schema public TO api;
    GRANT execute ON all functions IN schema public TO api;
    CREATE USER replication WITH REPLICATION PASSWORD 'stout';
    \i /sql/s_concat_trace.sql
    \i /sql/s_calc_distance.sql
    \i /spl/s_calc_avg_distance.sql
    \i /sql/s_update_cultivator_trace.sql
    \i /sql/s_update_cultivator_pos.sql
EOSQL

pg_basebackup -h 54.241.248.194 -U replication -w -D /var/lib/postgresql/data -X fetch 