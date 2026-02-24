#!/usr/bin/env bash

cmd_banned() {
    if ! command -v fail2ban-client >/dev/null 2>&1; then
        echo "Error: fail2ban-client command not found." >&2
        exit 1
    fi

    fail2ban-client status sshd
}