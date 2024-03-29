#!/bin/bash

set -e
set -u
set -o pipefail

cd "$(dirname "$0")"

# ---------------------------------------------------------- #
# Configuration
# ---------------------------------------------------------- #
EXPORTS_PATH="./data" # Backups destination path
BACKUPS_PATH="./data" # Exports destination path
CLEANUP_DAYS="30" # Cleanup files after x days

source .env

# ---------------------------------------------------------- #
# Defaults
# ---------------------------------------------------------- #
USER_ID=`id -u`
PATH="$PATH:/usr/local/bin"

LOCAL_DATA_PATH=./data
CONTAINER_DATA_PATH=/opt/stack/data
CONTAINER_CONFIG_PATH=/opt/stack/config

COLOR_RED='\033[0;31m'
COLOR_NONE='\033[0m'

# ---------------------------------------------------------- #
# Functions
# ---------------------------------------------------------- #
function log {
    DATETIME=$(date '+%Y/%m/%d %H:%M:%S');
    echo -e "[SIP][$DATETIME] $1"
}

function error {
    log "${COLOR_RED}$1${COLOR_NONE}"
    exit
}

function cleanup {
    THRESHOLD=$(date -d "$CLEANUP_DAYS days ago" +%s)
    find $1 -maxdepth 1 -type f -print0  | while IFS= read -d '' -r file; do
        if [[ "$(basename "$file")" =~ ^$2_[0-9]{10}$3$ ]]; then
            [ "$(basename "${file#*_}" $3)" -le "$THRESHOLD" ] && rm -v -- "$file"
        fi
    done
}

function runExport {
    EXPORT_FILE=sip-export_`date +%s`.csv

    log "Export data to $EXPORT_FILE"
    docker compose exec -T -u root influxdb bash -c "influx query -t '$INFLUXDB_TOKEN' -o '$INFLUXDB_ORG' -f /opt/stack/config/export.flux -r > $CONTAINER_DATA_PATH/$EXPORT_FILE" || return 1

    log "Fix permissions for $EXPORT_FILE"
    docker compose exec -T -u root sip bash -c "chown $USER_ID:$USER_ID $CONTAINER_DATA_PATH/$EXPORT_FILE" || return 1

    if [ $BACKUPS_PATH != $LOCAL_DATA_PATH ]; then 
        log "Move file to $EXPORTS_PATH/$EXPORT_FILE"
        mv $LOCAL_DATA_PATH/$EXPORT_FILE $EXPORTS_PATH/$EXPORT_FILE
    fi

    log "Cleanup old exports in $EXPORTS_PATH"
    cleanup $EXPORTS_PATH sip-export .csv

    return 0
}

function runBackup {
    BACKUP_FILE=sip-backup_`date +%s`.tar.gz

    LOCAL_BACKUP_PATH=$LOCAL_DATA_PATH/backup
    CONTAINER_BACKUP_PATH=$CONTAINER_DATA_PATH/backup

    log "Cleanup old backup data"
    docker compose exec -T -u root sip bash -c "rm -rf $CONTAINER_BACKUP_PATH"

    log "Initialize backup data folders"
    mkdir -p $LOCAL_BACKUP_PATH/mysql
    mkdir -p $LOCAL_BACKUP_PATH/grafana
    mkdir -p $LOCAL_BACKUP_PATH/influxdb
    mkdir -p $LOCAL_BACKUP_PATH/node-red        

    log "Backup InfluxDB data"
    docker compose exec -T -u root influxdb bash -c "influx backup -t '$INFLUXDB_TOKEN' '$CONTAINER_BACKUP_PATH/influxdb'" || return 1

    log "Backup Node-RED flows"
    docker compose exec -T -u root node-red bash -c "cp /data/flows.json $CONTAINER_BACKUP_PATH/node-red/flows.json" || return 1

    log "Backup Grafana database"
    docker compose exec -T -u root grafana bash -c "cp /var/lib/grafana/data/grafana.db $CONTAINER_BACKUP_PATH/grafana/grafana.db" || return 1

    log "Dump MySQL database"
    docker compose exec -T -u root mysql bash -c "mysqldump -u$DB_USERNAME -p$DB_PASSWORD -h$DB_HOST $DB_DATABASE > $CONTAINER_BACKUP_PATH/mysql/dump.sql" || return 1

    log "Create backup archive $BACKUP_FILE"
    docker compose exec -T -u root sip bash -c "tar -zcf $CONTAINER_DATA_PATH/$BACKUP_FILE $CONTAINER_BACKUP_PATH /home/runtime/public/storage" || return 1

    log "Fix permissions for $BACKUP_FILE"
    docker compose exec -T -u root sip bash -c "chown $USER_ID:$USER_ID $CONTAINER_DATA_PATH/$BACKUP_FILE" || return 1

    if [ $BACKUPS_PATH != $LOCAL_DATA_PATH ]; then 
        log "Move file to $BACKUPS_PATH/$BACKUP_FILE"
        mv $LOCAL_DATA_PATH/$BACKUP_FILE $BACKUPS_PATH/$BACKUP_FILE
    fi

    log "Cleanup old backups in $BACKUPS_PATH"
    cleanup $BACKUPS_PATH sip-backup .tar.gz

    return 0
}

# ---------------------------------------------------------- #
# Commands
# ---------------------------------------------------------- #
case "$1" in
    up)
        docker compose up "${@:2}"
        ;;
    down)
        docker compose down "${@:2}"
        ;;
    pull)
        docker compose pull "${@:2}"
        ;;
    cli)
        docker compose exec -e SIP_CLI=true sip artisan "${@:2}"
        ;;
    export)
        runExport || error "Export failed, please check the configuration."
        ;;
    backup)
        runBackup || error "Backup failed, please check the configuration."
        ;;
    *)
        docker compose exec sip "$@"
esac
