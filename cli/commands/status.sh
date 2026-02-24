#!/usr/bin/env bash

cmd_status() {
    if (( $# != 1 )); then
        echo "Usage: mktcms status <service>" >&2
        exit 2
    fi

    local service=${1:-}

    if ! command -v supervisorctl >/dev/null 2>&1; then
        echo "Error: supervisorctl command not found." >&2
        exit 1
    fi

    supervisorctl status "$service"
}