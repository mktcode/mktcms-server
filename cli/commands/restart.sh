#!/usr/bin/env bash

cmd_restart() {
    if (( $# != 1 )); then
        echo "Usage: mktcms restart <domain_name>" >&2
        exit 2
    fi

    local domain_name=${1:-}

    nginx -t
    systemctl reload nginx
    supervisorctl reread
    supervisorctl update
    supervisorctl restart "${domain_name}"
}
