# MktCMS Server

`mktcms-server` provides server bootstrap config (`init.yml`) and a CLI utility (`mktcms`) to manage multiple websites (using the Nuxt 4 template https://github.com/mktcode/mktcms-website-template)  and quick ops tasks on a cloud VM.

## Installation

### Cloud-init/Automated Setup (Recommended)

If you use the provided `init.yml` (cloud-init), the repository will be cloned to `/root/mktcms-server` and the CLI will be added to root's `PATH` automatically.

### Manual Installation (Non-cloud-init)

Clone on the server and add the CLI folder to your `PATH`:

```bash
git clone https://github.com/mktcode/mktcms-server.git
echo 'export PATH=$PATH:~/mktcms-server/cli' >> ~/.bashrc
source ~/.bashrc
```

## Quick Start

1. Ensure your server SSH public key is added to GitHub (for private repo clone):

```bash
cat /root/.ssh/id_ed25519.pub
```

2. Create a website:

```bash
mktcms new yourdomain.com 3001 mktcode/your-repo
```

3. Enable HTTPS:

```bash
mktcms cert yourdomain.com admin@yourdomain.com
```

## Command Reference

### `mktcms new <domain_name> <app_port> <owner/repo-name>`
Creates a complete new site setup (Nginx + Supervisor config), clones the app repo, installs dependencies, builds it, and activates services.

```bash
mktcms new yourdomain.com 3001 mktcode/your-repo
```

### `mktcms update <domain_name>`
Updates one site by pulling latest git changes, reinstalling packages, rebuilding, and restarting the Supervisor service.

```bash
mktcms update yourdomain.com
```

### `mktcms delete <domain_name>`
Removes one site completely (files, Nginx config, Supervisor config) and deletes the related certificate.

```bash
mktcms delete yourdomain.com
```

### `mktcms restart <domain_name>`
Validates and reloads Nginx/Supervisor state, then restarts one Supervisor service.

```bash
mktcms restart yourdomain.com
```

### `mktcms cert <domain_name> <email>`
Requests/installs Let’s Encrypt certs for `<domain_name>` and `www.<domain_name>` via the Nginx Certbot plugin and enables redirect to HTTPS.

```bash
mktcms cert yourdomain.com admin@yourdomain.com
```

### `mktcms adddomain <domain_name> <app_port>`
Adds an additional Nginx domain configuration that points to an existing app port and reloads Nginx.

```bash
mktcms adddomain shop.yourdomain.com 3001
```

### `mktcms all <command> [args...]`
Runs any shell command inside every website directory under `/var/www/websites`.

```bash
mktcms all git status
```

### `mktcms banned`
Shows Fail2Ban status for the SSH jail (`sshd`).

```bash
mktcms banned
```

### `mktcms status <service>`
Shows Supervisor status for one service.

```bash
mktcms status yourdomain.com
```

### `mktcms errors <service>`
Tails Supervisor `stderr` logs for one service (`supervisorctl tail -f <service> stderr`).

```bash
mktcms errors yourdomain.com
```

### `mktcms help`
Prints usage and examples.

```bash
mktcms help
```

## Notes

- Run commands with privileges required to manage `/etc/nginx`, `/etc/supervisor`, certificates, and `/var/www/websites`.
- `mktcms` expects template files in `website/nginx.conf` and `website/supervisor.conf`.
- `mktcms new` and `mktcms update` assume the project uses `npm ci` and `npm run build`.

## Testing (Isolated Docker)

Run CLI tests in an ephemeral Docker container so host paths and services stay untouched:

```bash
bash tests/run-tests-docker.sh
```

This builds `tests/Dockerfile`, runs `tests/test-cli.sh` inside the container, and removes the container afterwards.