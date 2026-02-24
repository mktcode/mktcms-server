#!/usr/bin/env bash

cmd_restart() {
    local domain_name=${1:-}
    if [[ -z "$domain_name" ]]; then
        echo "Usage: mktcms restart <domain_name>" >&2
        exit 2
    fi

    nginx -t
    systemctl reload nginx
    supervisorctl reread
    supervisorctl update
    supervisorctl restart "${domain_name}"
}
