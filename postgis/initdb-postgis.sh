#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
# TODO : proper tables rights management : https://docs.bitnami.com/aws/infrastructure/postgresql/configuration/create-postgis-template/
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_postgis IS_TEMPLATE true;
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS and PGRouting extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        CREATE EXTENSION IF NOT EXISTS pgrouting;
EOSQL
done

# Create and grant access rights to user $POSTGRES_DB
"${psql[@]}" --dbname="$POSTGRES_DB" <<-'EOSQL'
		DO
        $do$
        BEGIN
        IF NOT EXISTS (
            SELECT                       -- SELECT list can stay empty for this
            FROM   pg_catalog.pg_roles
            WHERE  rolname = '$POSTGRES_DB') THEN

            CREATE ROLE $POSTGRES_DB LOGIN PASSWORD '$POSTGRES_DB_PASSWORD';
            GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_DB;
        END IF;
        END
        $do$;
EOSQL