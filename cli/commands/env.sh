#!/usr/bin/env bash

cmd_env() {
    if (( $# != 1 )); then
        echo "Usage: mktcms env <service>" >&2
        exit 2
    fi

    local service=${1:-}
    local conf_file="/etc/supervisor/conf.d/${service}.conf"

    if [[ ! -f "$conf_file" ]]; then
        echo "Error: $conf_file does not exist." >&2
        exit 1
    fi

    "${EDITOR:-vim}" "$conf_file"
}
