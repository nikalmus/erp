#!/bin/bash

# Check if all required arguments are provided
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <dump_file> <source_db> <pg_user>"
  exit 1
fi

# Assign positional parameters to variables
DB_DUMP_FILE=$1
SOURCE_DB_NAME=$2
PG_USER=$3

# Dump the source database to a file
pg_dump -U "$PG_USER" -Fc "$SOURCE_DB_NAME" > "$DB_DUMP_FILE"

echo "Database dumped to $DB_DUMP_FILE"
