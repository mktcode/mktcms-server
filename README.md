# MktCMS Server Setup

Spin up a new server using the provided `init.yml` cloud-config file.

This configuration installs and configures necessary packages such as Nginx, Node.js, and Supervisor, sets up user permissions, and prepares the server for hosting MktCMS websites.

## Installation Steps

Clone the repository and add the cli dir to your PATH in .bashrc:

```bash
git clone https://github.com/mktcode/mktcms-server.git

echo 'export PATH=$PATH:~/mktcms-server/cli' >> ~/.bashrc
```