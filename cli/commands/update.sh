#!/usr/bin/env bash

cmd_update() {
    local domain_name=${1:-}
    if [[ -z "$domain_name" ]]; then
        echo "Usage: mktcms update <domain_name>" >&2
        exit 2
    fi

    cd "/var/www/websites/${domain_name}"
    git pull
    npm ci
    npm run build
    chown -R websites:websites "/var/www/websites/${domain_name}"
    supervisorctl restart "${domain_name}"
}
