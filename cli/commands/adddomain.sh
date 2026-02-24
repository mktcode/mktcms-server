#!/usr/bin/env bash

cmd_adddomain() {
    if (( $# != 2 )); then
        echo "Usage: mktcms adddomain <domain_name> <app_port>" >&2
        exit 2
    fi

    local domain_name=${1:-}
    local app_port=${2:-}

    if [[ -f "/etc/nginx/sites-available/${domain_name}.conf" ]]; then
        echo "Error: Domain configuration for ${domain_name} already exists." >&2
        exit 1
    fi

    if [[ ! -f "$TEMPLATE_DIR/nginx.conf" ]]; then
        echo "Template file not found in $TEMPLATE_DIR" >&2
        exit 1
    fi

    sed "s/{{DOMAIN_NAME}}/${domain_name}/g; s/{{APP_PORT}}/${app_port}/g" "$TEMPLATE_DIR/nginx.conf" > "/etc/nginx/sites-available/${domain_name}.conf"
    ln -s "/etc/nginx/sites-available/${domain_name}.conf" "/etc/nginx/sites-enabled/${domain_name}.conf"

    nginx -t
    systemctl reload nginx

    echo "Domain ${domain_name} has been added."
    echo "Please run the certificate setup script to enable HTTPS:"
    echo "mktcms cert ${domain_name} <email_address>"
}
