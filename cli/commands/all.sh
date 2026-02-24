#!/usr/bin/env bash

cmd_all() {
    if (( $# < 1 )); then
        echo "Usage: mktcms all <command> [args...]" >&2
        exit 2
    fi

    local websites_root="/var/www/websites"

    if [[ ! -d "$websites_root" ]]; then
        echo "Error: $websites_root does not exist." >&2
        exit 1
    fi

    cd "$websites_root"

    shopt -s nullglob
    local website_dirs=(*/)
    shopt -u nullglob

    if (( ${#website_dirs[@]} == 0 )); then
        echo "No websites found in $websites_root" >&2
        exit 0
    fi

    for website_dir in "${website_dirs[@]}"; do
        (
            cd "$website_dir"
            echo "== $website_dir =="
            "$@"
        )
    done
}
