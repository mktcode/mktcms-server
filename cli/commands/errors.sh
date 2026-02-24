#!/usr/bin/env bash

cmd_errors() {
    local service=${1:-}

    if [[ -z "$service" ]]; then
        echo "Usage: mktcms errors <service>" >&2
        exit 2
    fi

    if ! command -v supervisorctl >/dev/null 2>&1; then
        echo "Error: supervisorctl command not found." >&2
        exit 1
    fi

    supervisorctl tail -f "$service" stderr
}