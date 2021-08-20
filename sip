#!/bin/bash

set -e
set -u
set -o pipefail

cd "$(dirname "$0")"

function log {
    echo "[SIP] $1"
}

case "$1" in
    up)
        docker-compose up "${@:2}"
        ;;
    down)
        docker-compose down "${@:2}"
        ;;
    pull)
        docker-compose pull "${@:2}"
        ;;
    cli)
        docker-compose exec -e SIP_CLI=true sip artisan "${@:2}"
        ;;
    backup)
        source .env

        USER_ID=`id -u`
        INFLUXDB_BACKUP_DIR="/opt/vanegmond/backup/influxdb"
        NODERED_BACKUP_DIR=/opt/vanegmond/backup/node-red
        GRAFANA_BACKUP_DIR=/opt/vanegmond/backup/grafana
        MYSQL_BACKUP_DIR=/opt/vanegmond/backup/mysql
        BACKUP_ARCHIVE=sip-backup_`date +%s`.tar.gz
        
        log "Cleanup old backup data"
        docker-compose exec -T -u root sip bash -c "rm -rf $INFLUXDB_BACKUP_DIR && mkdir -p $INFLUXDB_BACKUP_DIR"
        docker-compose exec -T -u root sip bash -c "rm -rf $NODERED_BACKUP_DIR && mkdir -p $NODERED_BACKUP_DIR"
        docker-compose exec -T -u root sip bash -c "rm -rf $GRAFANA_BACKUP_DIR && mkdir -p $GRAFANA_BACKUP_DIR"
        docker-compose exec -T -u root sip bash -c "rm -rf $MYSQL_BACKUP_DIR && mkdir -p $MYSQL_BACKUP_DIR"

        log "Backup InfluxDB data"
        docker-compose exec -T -u root influxdb bash -c "influx backup --token $INFLUXDB_TOKEN $INFLUXDB_BACKUP_DIR"

        log "Backup Node-RED flows"
        docker-compose exec -T -u root node-red bash -c "cp /data/flows.json $NODERED_BACKUP_DIR/flows.json"

        log "Backup Grafana database"
        docker-compose exec -T -u root grafana bash -c "cp /opt/vanegmond/grafana/data/grafana.db $GRAFANA_BACKUP_DIR/grafana.db"

        log "Dump MySQL database"
        docker-compose exec -T -u root mysql bash -c "mysqldump -u$DB_USERNAME -p$DB_PASSWORD -h$DB_HOST $DB_DATABASE > $MYSQL_BACKUP_DIR/dump.sql"

        log "Create backup archive $BACKUP_ARCHIVE"
        docker-compose exec -T -u root sip bash -c "tar -zcf /tmp/$BACKUP_ARCHIVE /opt/vanegmond/backup /home/runtime/public/storage && mv /tmp/$BACKUP_ARCHIVE /opt/vanegmond/backups"

        log "Fix permissions"
        docker-compose exec -T -u root sip bash -c "chown -R $USER_ID:$USER_ID /opt/vanegmond/backups"

        log "Cleanup old backup archives"
        THRESHOLD=$(date -d "30 days ago" +%s)
        find ./backups -maxdepth 1 -type f -print0  | while IFS= read -d '' -r file; do
            if [[ "$(basename "$file")" =~ ^sip-backup_[0-9]{10}.tar.gz$ ]]; then
                [ "$(basename "${file#*_}" .tar.gz)" -le "$THRESHOLD" ] && rm -v -- "$file"
            fi
        done
        ;;
    *)
        docker-compose exec sip "$@"
esac