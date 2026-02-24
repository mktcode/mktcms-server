#!/usr/bin/env bash
set -euo pipefail

if [[ "${MKTCMS_TESTS_IN_DOCKER:-}" != "1" ]]; then
    echo "Error: Refusing to run tests outside the Docker test container." >&2
    echo "Run: bash tests/run-tests-docker.sh" >&2
    exit 1
fi

REPO_ROOT="$(cd -P -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd)"
cd "$REPO_ROOT"

TEST_TMP_DIR="$(mktemp -d)"
TEST_BIN_DIR="$TEST_TMP_DIR/bin"
TEST_LOG_FILE="$TEST_TMP_DIR/commands.log"
mkdir -p "$TEST_BIN_DIR"
touch "$TEST_LOG_FILE"

cleanup() {
    rm -rf "$TEST_TMP_DIR"
}
trap cleanup EXIT

export TEST_LOG_FILE
export PATH="$TEST_BIN_DIR:$PATH"

create_stub() {
    local name=$1
    cat > "$TEST_BIN_DIR/$name"
    chmod +x "$TEST_BIN_DIR/$name"
}

create_stub vim <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "vim $*" >> "$TEST_LOG_FILE"
EOF

create_stub openssl <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "rand" ]]; then
    printf 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\n'
    exit 0
fi
echo "openssl $*" >> "$TEST_LOG_FILE"
EOF

create_stub git <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "git $*" >> "$TEST_LOG_FILE"
if [[ "${1:-}" == "clone" ]]; then
    mkdir -p .git
fi
EOF

create_stub npm <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "npm $*" >> "$TEST_LOG_FILE"
EOF

create_stub chown <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "chown $*" >> "$TEST_LOG_FILE"
EOF

create_stub nginx <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "nginx $*" >> "$TEST_LOG_FILE"
EOF

create_stub systemctl <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "systemctl $*" >> "$TEST_LOG_FILE"
EOF

create_stub supervisorctl <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "supervisorctl $*" >> "$TEST_LOG_FILE"
EOF

create_stub certbot <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "certbot $*" >> "$TEST_LOG_FILE"
EOF

create_stub fail2ban-client <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "fail2ban-client $*" >> "$TEST_LOG_FILE"
EOF

reset_fixtures() {
    rm -rf /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/supervisor/conf.d /var/www/websites
    mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/supervisor/conf.d /var/www/websites
    : > "$TEST_LOG_FILE"
}

assert_exit() {
    local expected=$1
    local actual=$2
    if [[ "$actual" -ne "$expected" ]]; then
        echo "FAIL ${CURRENT_TEST:-unknown}: Expected exit code $expected, got $actual" >&2
        exit 1
    fi
}

assert_contains() {
    local needle=$1
    local haystack=$2
    if ! grep -Fq "$needle" "$haystack"; then
        echo "FAIL ${CURRENT_TEST:-unknown}: Expected '$needle' in $haystack" >&2
        exit 1
    fi
}

run_cli_capture() {
    local output_file=$1
    shift

    set +e
    bash ./cli/mktcms "$@" >"$output_file" 2>&1
    RUN_CLI_RC=$?
    set -e
    return 0
}

test_help_and_usage() {
    local output
    output="$(mktemp)"
    run_cli_capture "$output" help
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "Usage:" "$output"

    run_cli_capture "$output"
    assert_exit 2 "$RUN_CLI_RC"
    assert_contains "Usage:" "$output"

    run_cli_capture "$output" not-a-command
    assert_exit 2 "$RUN_CLI_RC"
    assert_contains "Unknown command: not-a-command" "$output"

    rm -f "$output"
}

test_new_command_success() {
    reset_fixtures

    local output
    output="$(mktemp)"
    run_cli_capture "$output" new example.com 3001 mktcode/sample
    assert_exit 0 "$RUN_CLI_RC"

    [[ -f /etc/nginx/sites-available/example.com.conf ]]
    [[ -L /etc/nginx/sites-enabled/example.com.conf ]]
    [[ -f /etc/supervisor/conf.d/example.com.conf ]]
    [[ -d /var/www/websites/example.com ]]

    assert_contains "example.com" /etc/nginx/sites-available/example.com.conf
    assert_contains "3001" /etc/nginx/sites-available/example.com.conf
    assert_contains "mktcode/sample" /etc/supervisor/conf.d/example.com.conf
    assert_contains "PORT=\"3001\"" /etc/supervisor/conf.d/example.com.conf

    assert_contains "nginx -t" "$TEST_LOG_FILE"
    assert_contains "systemctl reload nginx" "$TEST_LOG_FILE"
    assert_contains "supervisorctl reread" "$TEST_LOG_FILE"
    assert_contains "supervisorctl update" "$TEST_LOG_FILE"
    assert_contains "Website example.com has been created." "$output"

    rm -f "$output"
}

test_new_command_validation() {
    reset_fixtures
    local output
    output="$(mktemp)"

    run_cli_capture "$output" new example.com notaport mktcode/sample
    assert_exit 2 "$RUN_CLI_RC"
    assert_contains "app_port must be a number" "$output"

    run_cli_capture "$output" new example.com 3001 invalidrepo
    assert_exit 2 "$RUN_CLI_RC"
    assert_contains "repo must be in 'owner/repo-name' form" "$output"

    rm -f "$output"
}

test_adddomain_update_delete_and_ops() {
    reset_fixtures

    mkdir -p /var/www/websites/example.com

    local output
    output="$(mktemp)"

    run_cli_capture "$output" adddomain shop.example.com 3001
    assert_exit 0 "$RUN_CLI_RC"
    [[ -f /etc/nginx/sites-available/shop.example.com.conf ]]
    assert_contains "Domain shop.example.com has been added." "$output"

    run_cli_capture "$output" update example.com
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "supervisorctl restart example.com" "$TEST_LOG_FILE"

    run_cli_capture "$output" restart example.com
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "supervisorctl restart example.com" "$TEST_LOG_FILE"

    run_cli_capture "$output" cert example.com admin@example.com
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "certbot --nginx -d example.com -d www.example.com -m admin@example.com --agree-tos --non-interactive --redirect" "$TEST_LOG_FILE"

    run_cli_capture "$output" status example.com
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "supervisorctl status example.com" "$TEST_LOG_FILE"

    run_cli_capture "$output" errors example.com
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "supervisorctl tail -f example.com stderr" "$TEST_LOG_FILE"

    run_cli_capture "$output" banned
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "fail2ban-client status sshd" "$TEST_LOG_FILE"

    run_cli_capture "$output" delete example.com
    assert_exit 0 "$RUN_CLI_RC"
    [[ ! -e /etc/nginx/sites-available/example.com.conf ]]
    [[ ! -e /etc/supervisor/conf.d/example.com.conf ]]
    assert_contains "certbot delete --cert-name example.com -n --quiet" "$TEST_LOG_FILE"

    rm -f "$output"
}

test_all_command() {
    reset_fixtures
    mkdir -p /var/www/websites/site-a /var/www/websites/site-b

    local output
    output="$(mktemp)"
    run_cli_capture "$output" all pwd
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "== site-a/ ==" "$output"
    assert_contains "== site-b/ ==" "$output"

    rm -f "$output"
}

test_env_command() {
    reset_fixtures
    mkdir -p /var/www/websites/example.com
    echo "dummy config" > /etc/supervisor/conf.d/example.com.conf

    local output
    output="$(mktemp)"

    # success case
    run_cli_capture "$output" env example.com
    assert_exit 0 "$RUN_CLI_RC"
    assert_contains "vim /etc/supervisor/conf.d/example.com.conf" "$TEST_LOG_FILE"

    # non-existing
    run_cli_capture "$output" env nonexisting
    assert_exit 1 "$RUN_CLI_RC"
    assert_contains "Error: /etc/supervisor/conf.d/nonexisting.conf does not exist." "$output"

    # wrong usage
    run_cli_capture "$output" env
    assert_exit 2 "$RUN_CLI_RC"
    assert_contains "Usage: mktcms env <service>" "$output"

    rm -f "$output"
}

main() {
    local -a tests=(
        "test_help_and_usage"
        "test_new_command_success"
        "test_new_command_validation"
        "test_adddomain_update_delete_and_ops"
        "test_all_command"
        "test_env_command"
    )

    local test_name
    for test_name in "${tests[@]}"; do
        CURRENT_TEST="$test_name"
        "$test_name"
        echo "PASS ${test_name}"
    done

    echo "All isolated Docker CLI tests passed (${#tests[@]}/${#tests[@]})."
}

main