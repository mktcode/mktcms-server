# MktCMS Server Setup

Spin up a new server using the provided `init.yml` cloud-config file.

This configuration installs and configures necessary packages such as Nginx, Node.js, and Supervisor, sets up user permissions, and prepares the server for hosting MktCMS websites.

## Installation Steps

On the server as root clone the repository and add the cli dir to your PATH in .bashrc:

```bash
# e.g. in /home/root
git clone https://github.com/mktcode/mktcms-server.git

echo 'export PATH=$PATH:~/mktcms-server/cli' >> ~/.bashrc
```

Restart your shell or source the .bashrc file:

```bash
source ~/.bashrc
```

## Create a New Website

To clone from private repositories from GitHub, ensure that your server's SSH public key is added to your GitHub account.

```bash
cat /root/.ssh/id_ed25519.pub
```

Create a new website using `mktcms new`:

```bash
mktcms new yourdomain.com 3001 mktcode/your-repo
```

Create an SSL certificate for the new website using `mktcms cert`.
This will create and install certificates for both `yourdomain.com` and `www.yourdomain.com`.
Make sure DNS records are properly set up.

```bash
mktcms cert yourdomain.com your@email.com
```

## Update an Existing Website

To update an existing website, use `mktcms update`.
This will pull the latest changes from the repository, rebuild the app and restart the associated service.

```bash
mktcms update yourdomain.com
```

## Delete a Website

To delete an existing website, use `mktcms delete`.
This will remove the application files, nginx and supervisor configurations, and delete the SSL certificates.

```bash
mktcms delete yourdomain.com
```

## Restart Website

To restart a website's service, use `mktcms restart`:

```bash
mktcms restart yourdomain.com
```

## Other helpful commands

Run a command in every website directory:

```bash
mktcms all <command> [args...]
# e.g.
mktcms all git pull
```

See how many IP addresses are currently banned by Fail2Ban for SSH:

```bash
mktcms banned
```

Show Supervisor status for one service:

```bash
mktcms status yourdomain.com
```