#!/usr/bin/env bash

cmd_new() {
    local domain_name=${1:-}
    local app_port=${2:-}
    local repo_param=${3:-}

    if [[ -z "$domain_name" || -z "$app_port" || -z "$repo_param" ]]; then
        echo "Usage: mktcms new <domain_name> <app_port> <owner/repo-name>" >&2
        exit 2
    fi

    if [[ ! "$app_port" =~ ^[0-9]+$ ]]; then
        echo "Error: app_port must be a number." >&2
        exit 2
    fi

    if [[ "$repo_param" != */* ]]; then
        echo "Error: repo must be in 'owner/repo-name' form." >&2
        exit 2
    fi

    local clone_url
    if [[ "$repo_param" == *.git ]]; then
        clone_url="git@github.com:${repo_param}"
    else
        clone_url="git@github.com:${repo_param}.git"
    fi

    local random_auth_key
    random_auth_key=$(openssl rand -base64 32 | tr -d '/=+' | cut -c1-32)

    if [[ -f "/etc/nginx/sites-available/${domain_name}.conf" || -f "/etc/supervisor/conf.d/${domain_name}.conf" || -d "/var/www/websites/${domain_name}" ]]; then
        echo "Error: Website configuration or directory for ${domain_name} already exists." >&2
        exit 1
    fi

    shopt -s nullglob
    local supervisor_confs=(/etc/supervisor/conf.d/*.conf)
    shopt -u nullglob

    if (( ${#supervisor_confs[@]} )); then
        if grep -q "PORT=\"${app_port}\"" "${supervisor_confs[@]}"; then
            echo "Error: Port ${app_port} is already in use by another application." >&2
            exit 1
        fi
    fi

    if [[ ! -f "$TEMPLATE_DIR/nginx.conf" || ! -f "$TEMPLATE_DIR/supervisor.conf" ]]; then
        echo "Template files not found in $TEMPLATE_DIR" >&2
        exit 1
    fi

    sed "s/{{DOMAIN_NAME}}/${domain_name}/g; s/{{APP_PORT}}/${app_port}/g" "$TEMPLATE_DIR/nginx.conf" > "/etc/nginx/sites-available/${domain_name}.conf"
    ln -s "/etc/nginx/sites-available/${domain_name}.conf" "/etc/nginx/sites-enabled/${domain_name}.conf"

    sed "s/{{DOMAIN_NAME}}/${domain_name}/g; s/{{REPO}}/${repo_param}/g; s/{{APP_PORT}}/${app_port}/g; s/{{RANDOM_AUTH_KEY}}/${random_auth_key}/g" "$TEMPLATE_DIR/supervisor.conf" > "/etc/supervisor/conf.d/${domain_name}.conf"

    mkdir -p "/var/www/websites/${domain_name}"
    cd "/var/www/websites/${domain_name}"
    git clone "$clone_url" .

    git config --global --add safe.directory "/var/www/websites/${domain_name}"

    npm ci
    npm run build
    chown -R websites:websites "/var/www/websites/${domain_name}"

    nginx -t
    systemctl reload nginx
    supervisorctl reread
    supervisorctl update

    echo "Website ${domain_name} has been created."
    echo "Auth Key: ${random_auth_key}"
    echo "Please run the certificate setup script to enable HTTPS:"
    echo "mktcms cert ${domain_name} <email_address>"
}
