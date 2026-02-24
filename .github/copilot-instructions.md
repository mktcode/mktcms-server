# Copilot Instructions

- Keep changes minimal and production-safe; this repo manages real server infrastructure.
- Main CLI entrypoint is `cli/mktcms` (dispatcher only). Subcommands live in `cli/commands/*.sh`.
- For new CLI actions, add a dedicated `cli/commands/<name>.sh` file with a `cmd_<name>()` function.
- Wire every new command in **both** places: `cli/mktcms` (`source` + `case`) and `cli/lib/common.sh` (`usage()` text + examples).
- Reuse shared paths from `cli/lib/common.sh` (`TEMPLATE_DIR`), avoid redefining conflicting globals.
- Keep Bash style consistent: `set -euo pipefail`, explicit arg validation, clear error messages to stderr, non-zero exits on failure.
- Current operational commands: `new`, `update`, `delete`, `restart`, `cert`, `adddomain`, `all`, `banned`, `status`, `errors`.
- `status <service>` and `errors <service>` are Supervisor-focused; `banned` is Fail2Ban-focused.
- If behavior changes, update `README.md` command docs in the same change.
- Prefer README for full workflow/details; keep this file short and implementation-oriented.
