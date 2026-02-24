#!/usr/bin/env bash

cmd_status() {
    local overall_rc=0

    echo "== fail2ban-client status sshd =="
    if command -v fail2ban-client >/dev/null 2>&1; then
        if ! fail2ban-client status sshd; then
            overall_rc=1
        fi
    else
        echo "Error: fail2ban-client command not found." >&2
        overall_rc=1
    fi

    echo
    echo "== supervisorctl status =="
    if command -v supervisorctl >/dev/null 2>&1; then
        if ! supervisorctl status; then
            overall_rc=1
        fi
    else
        echo "Error: supervisorctl command not found." >&2
        overall_rc=1
    fi

    return "$overall_rc"
}