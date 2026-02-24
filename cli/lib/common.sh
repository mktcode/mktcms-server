#!/usr/bin/env bash

readonly COMMON_DIR="$(cd -P -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd)"
readonly TEMPLATE_DIR="$COMMON_DIR/../../website"

usage() {
    cat >&2 <<'EOF'
Usage:
  mktcms new <domain_name> <app_port> <owner/repo-name>
  mktcms update <domain_name>
  mktcms delete <domain_name>
  mktcms restart <domain_name>
  mktcms cert <domain_name> <email>
  mktcms adddomain <domain_name> <app_port>
  mktcms all <command> [args...]
  mktcms banned
  mktcms status <service>
  mktcms errors <service>
  mktcms env <service>

Examples:
  mktcms new yourdomain.com 3001 mktcode/your-repo
  mktcms update yourdomain.com
  mktcms all git status
  mktcms banned
  mktcms status yourdomain.com
  mktcms errors yourdomain.com
  mktcms env yourdomain.com
EOF
}
