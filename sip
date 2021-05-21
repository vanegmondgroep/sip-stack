#!/bin/bash

set -e
set -u
set -o pipefail

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
    cli)
        docker-compose exec -e SIP_CLI=true sip artisan "${@:2}"
        ;;
    *)
        docker-compose exec sip "$@"
esac