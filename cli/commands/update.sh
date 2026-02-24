#!/usr/bin/env bash

cmd_update() {
    if (( $# != 1 )); then
        echo "Usage: mktcms update <domain_name>" >&2
        exit 2
    fi

    local domain_name=${1:-}

    cd "/var/www/websites/${domain_name}"
    git pull
    npm ci
    npm run build
    chown -R websites:websites "/var/www/websites/${domain_name}"
    supervisorctl restart "${domain_name}"
}
