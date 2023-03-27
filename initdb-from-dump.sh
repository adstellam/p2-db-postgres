#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<-EOSQL
    DROP SCHEMA if EXISTS norma, stout, adapt CASCADE;
EOSQL

psql -U postgres -d postgres -f /tmp/pg_dump.sql

psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<-EOSQL
    GRANT select, insert, update, delete ON all tables IN schema public, norma, stout, adapt TO api;
    GRANT execute ON all functions IN schema public, norma, stout, adapt TO api;
    GRANT usage ON schema public, norma, stout, adapt TO api;
EOSQL