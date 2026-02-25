#!/usr/bin/env bash

cmd_deletedomain() {
    if (( $# != 1 )); then
        echo "Usage: mktcms deletedomain <domain_name>" >&2
        exit 2
    fi

    local domain_name=${1:-}
    local conf_file="/etc/nginx/sites-available/${domain_name}.conf"
    local enabled_link="/etc/nginx/sites-enabled/${domain_name}.conf"

    if [[ ! -f "$conf_file" ]]; then
        echo "Error: Domain configuration for ${domain_name} does not exist." >&2
        exit 1
    fi

    # Remove symlink from sites-enabled if it exists
    if [[ -L "$enabled_link" ]]; then
        rm -f "$enabled_link"
    fi

    # Remove the config file from sites-available
    rm -f "$conf_file"

    nginx -t
    systemctl reload nginx

    echo "Domain ${domain_name} has been deleted."
}