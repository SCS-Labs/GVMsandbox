#!/bin/bash

UPDATE_ON_START=false
SCHEDULED_UPDATES=false
GVM_USER="admin"
GVM_PASSWORD="admin"
SLAVE_USER="scanner"
SLAVE_PASSWORD="scannner"
GVMD_HOST="0.0.0.0"
GVMD_PORT="9391"
GVMD_MAXROWS="5000"
GVMD_MAX_IPS_PER_TARGET="4096"
OPENVAS_HOST="0.0.0.0"
OPENVAS_PORT="9391"
GSA_HOST="0.0.0.0"
GSA_PORT="9392"
GSA_TIMEOUT="600"
PG_MAJOR="10"
PGDATA="/var/lib/postgresql/data"
POSTGRES_DB="gvmd"