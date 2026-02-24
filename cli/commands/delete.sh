#!/usr/bin/env bash

cmd_delete() {
    local domain_name=${1:-}
    if [[ -z "$domain_name" ]]; then
        echo "Usage: mktcms delete <domain_name>" >&2
        exit 2
    fi

    rm -f "/etc/nginx/sites-enabled/${domain_name}.conf"
    rm -f "/etc/nginx/sites-available/${domain_name}.conf"
    rm -f "/etc/supervisor/conf.d/${domain_name}.conf"
    rm -rf "/var/www/websites/${domain_name}"

    nginx -t
    systemctl reload nginx
    supervisorctl reread
    supervisorctl update

    certbot delete --cert-name "${domain_name}" -n --quiet

    echo "Website ${domain_name} has been deleted."
}
