#!/bin/bash
set -e

# Restore the database, fail if db exists already for some reason
/bin/litestream restore -v -if-replica-exists /db.sqlite

exec /bin/litestream replicate


