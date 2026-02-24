#!/usr/bin/env bash

cmd_cert() {
    local domain_name=${1:-}
    local email=${2:-}

    if [[ -z "$domain_name" || -z "$email" ]]; then
        echo "Usage: mktcms cert <domain_name> <email>" >&2
        exit 2
    fi

    local domains=(-d "${domain_name}" -d "www.${domain_name}")
    certbot --nginx "${domains[@]}" -m "${email}" --agree-tos --non-interactive --redirect
}
