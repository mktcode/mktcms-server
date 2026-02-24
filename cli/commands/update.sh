#!/usr/bin/env bash

cmd_update() {
    if (( $# != 1 )); then
        echo "Usage: mktcms update <domain_name>" >&2
        exit 2
    fi

    local domain_name=${1:-}

    cd "/var/www/websites/${domain_name}"
    GIT_PULL_OUTPUT=$(git pull)
    echo "$GIT_PULL_OUTPUT"
    if echo "$GIT_PULL_OUTPUT" | grep -Eq '^ [1-9][0-9]* file(s)? changed'; then
        npm ci
        npm run build
    fi
    chown -R websites:websites "/var/www/websites/${domain_name}"
    supervisorctl restart "${domain_name}"
}
