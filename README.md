# MktCMS Server

`mktcms-server` provides server bootstrap config (`init.yml`) and a CLI utility (`mktcms`) to manage websites, Nginx, Supervisor, certificates, and quick ops tasks.

## Installation

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
What it does: Creates a complete new site setup (Nginx + Supervisor config), clones the app repo, installs dependencies, builds it, and activates services.

Example:
```bash
mktcms new yourdomain.com 3001 mktcode/your-repo
```

### `mktcms update <domain_name>`
What it does: Updates one site by pulling latest git changes, reinstalling packages, rebuilding, fixing ownership, and restarting the Supervisor service.

Example:
```bash
mktcms update yourdomain.com
```

### `mktcms delete <domain_name>`
What it does: Removes one site completely (files, Nginx config, Supervisor config) and deletes the related certificate.

Example:
```bash
mktcms delete yourdomain.com
```

### `mktcms restart <domain_name>`
What it does: Validates and reloads Nginx/Supervisor state, then restarts one Supervisor service.

Example:
```bash
mktcms restart yourdomain.com
```

### `mktcms cert <domain_name> <email>`
What it does: Requests/installs Let’s Encrypt certs for `<domain_name>` and `www.<domain_name>` via the Nginx Certbot plugin and enables redirect to HTTPS.

Example:
```bash
mktcms cert yourdomain.com admin@yourdomain.com
```

### `mktcms adddomain <domain_name> <app_port>`
What it does: Adds an additional Nginx domain configuration that points to an existing app port and reloads Nginx.

Example:
```bash
mktcms adddomain shop.yourdomain.com 3001
```

### `mktcms all <command> [args...]`
What it does: Runs any shell command inside every website directory under `/var/www/websites`.

Example:
```bash
mktcms all git status
```

### `mktcms banned`
What it does: Shows Fail2Ban status for the SSH jail (`sshd`).

Example:
```bash
mktcms banned
```

### `mktcms status <service>`
What it does: Shows Supervisor status for one service.

Example:
```bash
mktcms status yourdomain.com
```

### `mktcms errors <service>`
What it does: Tails Supervisor `stderr` logs for one service (`supervisorctl tail -f <service> stderr`).

Example:
```bash
mktcms errors yourdomain.com
```

### `mktcms help`
What it does: Prints usage and examples.

Example:
```bash
mktcms help
```

## Notes

- Run commands with privileges required to manage `/etc/nginx`, `/etc/supervisor`, certificates, and `/var/www/websites`.
- `mktcms` expects template files in `website/nginx.conf` and `website/supervisor.conf`.
- `mktcms new` and `mktcms update` assume the project uses `npm ci` and `npm run build`.