#!/usr/bin/env bash

cmd_restart() {
    if (( $# != 1 )); then
        echo "Usage: mktcms restart <domain_name>" >&2
        exit 2
    fi

    local domain_name=${1:-}

    if ! command -v supervisorctl >/dev/null 2>&1; then
        echo "Error: supervisorctl command not found." >&2
        exit 1
    fi

    supervisorctl reread
    supervisorctl update "${domain_name}"
    supervisorctl restart "${domain_name}"
}
