#!/bin/bash

# Check if all required arguments are provided
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <dump_file> <target_db> <pg_user>"
  exit 1
fi

# Assign positional parameters to variables
DB_DUMP_FILE=$1
TARGET_DB_NAME=$2
PG_USER=$3

# Create the target database
createdb -U "$PG_USER" "$TARGET_DB_NAME"

echo "Target database created: $TARGET_DB_NAME"

# Restore the dumped data to the target database
pg_restore -U "$PG_USER" -d "$TARGET_DB_NAME" "$DB_DUMP_FILE"

echo "Database restored to $TARGET_DB_NAME"
