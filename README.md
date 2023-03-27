# Start the Postgresql servers
docker-compose up

# To port the database to another Postgresql instance

Use pg_dump utility to dump the database in the current instance, and load it in another instance.
using psql -- i.e., psql postgres <pg_dump_file>. It will load not only data but also definitions
of database schemas, tables, views, and types.

# Schemas
The current database has four schemas:
* public -
* norma - Normalized tables
* apiview - abridged views derived from the tables defined in the NORMA schema for the purpose of simplifying the Stout web app's API design
* adapt - definition of types, enums, and views in compliance with the AgGateway's ADAPT common object model

# PL/pgsql subprograms

This project includes PL/pgsql functions, procedures, and anonymous blocks in the sql directory.
The functions and procedures are in files the names of which are prefixed with s_ while anonymous
blocks are prefixed with b_.

# [pgadmin4](https://www.pgadmin.org/)
* Started automatically when running docker-compose up.
* Login using credentials defined in docker-compose
* Add new server
     * connection
     * hostname: castor (primary db service name)
     * port: 5432
     * username: postgres
     * password: defined in .env file.