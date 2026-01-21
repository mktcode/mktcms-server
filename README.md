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

Create a new website using the `websitenew` script:

```bash
websitenew yourdomain.com 3001
```

Create an SSL certificate for the new website using the `websitecert` script.
This will create and install certificates for both `yourdomain.com` and `www.yourdomain.com`.
Make sure DNS records are properly set up.

```bash
websitecert yourdomain.com
```

## Update an Existing Website

To update an existing website, use the `websiteupdate` script.
This will pull the latest changes from the repository, rebuild the app and restart the associated service.

```bash
websiteupdate yourdomain.com
```

## Delete a Website

To delete an existing website, use the `websitedelete` script.
This will remove the application files, nginx and supervisor configurations, and delete the SSL certificates.

```bash
websitedelete yourdomain.com
```

## Restart Website

To restart a website's service, use the `websiterestart` script:

```bash
websiterestart yourdomain.com
```

## Other helpful commands

See how many IP addresses are currently banned by Fail2Ban for SSH:

```bash
fail2ban-client status sshd
```