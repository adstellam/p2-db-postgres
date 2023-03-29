#!/bin/bash
set -e

# if there is no schema named '' we perform all of the database initialization
echo "Checking if database is initialized..."
set +e
EXISTING_DB=$(psql -v ON_ERROR_STOP=1 -U postgres -d postgres -c "SELECT schema_name FROM information_schema.schemata" | grep norma)
set -e

if [ ! -z "$EXISTING_DB" ]; then
    echo "Existing database detected."
    # For starting a new container with existing data
    psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS postgis;
        CREATE EXTENSION IF NOT EXISTS hstore;
        CREATE EXTENSION IF NOT EXISTS tablefunc;
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS plpgsql;
        CREATE EXTENSION IF NOT EXISTS pgcrypto;
        CREATE EXTENSION IF NOT EXISTS pg_cron;
        CREATE USER api WITH PASSWORD 'adstellam';
        GRANT connect ON database postgres TO api;
        GRANT select, insert, update, delete ON all tables IN SCHEMA public, norma, apiview, adapt TO api;
        GRANT usage on SCHEMA public, norma, apiview, adapt, cron to api;
        GRANT execute ON all functions IN SCHEMA public, norma, apiview, adapt TO api;
        CREATE USER replication WITH REPLICATION PASSWORD 'adstellam';
EOSQL
else
    echo "Initializing new database..."
    # Starting a new container with no existing database
    echo "Modifying postgresql.conf to enable pg_cron shared library..."
    cat <<EOT >> ${PGDATA}/postgresql.conf
shared_preload_libraries='pg_cron'
cron.database_name='${POSTGRES_DB:-postgres}'
EOT
    pg_ctl restart -w
    echo "pg server restarted successfully."

    echo "Set up extensions and basic permissions..."
    psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS postgis;
        CREATE EXTENSION IF NOT EXISTS hstore;
        CREATE EXTENSION IF NOT EXISTS tablefunc;
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS plpgsql;
        CREATE EXTENSION IF NOT EXISTS pgcrypto;
        CREATE EXTENSION IF NOT EXISTS pg_cron;
        CREATE USER api WITH PASSWORD 'adstellam';
        GRANT connect ON database postgres TO api;
        GRANT select, insert, update, delete ON all tables IN schema public TO api;
        GRANT execute ON all functions IN schema public TO api;
        CREATE USER replication WITH REPLICATION PASSWORD 'adstellam';
EOSQL

    echo "Creating database..."
    # Run all of our sql scripts to create the database, configure schemas, etc.
    for f in $(ls sql/b-*.sql); do
        echo "Executing $f"
        psql -v ON_ERROR_STOP=1 -U postgres -d postgres -f $f
    done
fi
