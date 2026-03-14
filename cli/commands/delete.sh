#!/usr/bin/env bash

# TODO: Perform git status check and warn if there are uncommitted changes before deleting a website.

cmd_delete() {
    if (( $# != 1 )); then
        echo "Usage: mktcms delete <domain_name>" >&2
        exit 2
    fi

    local domain_name=${1:-}

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
