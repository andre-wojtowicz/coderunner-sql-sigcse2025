# Host preparation (assuming Debian 12.9)

* act below as root user

   ```bash
   sudo su
   ```

* install Debian packages

   ```bash
   apt install docker.io docker-compose gnupg2 python3-venv cron
   curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
   curl -sSL https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
   apt update
   ACCEPT_EULA=Y apt install mssql-tools unixodbc-dev
   ```

* install Python modules in virtual environment

  ```bash
  mkdir -p /opt/venv
  python3 -m venv /opt/venv/mssql-shared
  source /opt/venv/mssql-shared/bin/activate
  pip install -r requirements.txt
  deactivate
  ```

# Docker image preparation

## SQL Server incompatibility with ZFS <0.8

SQL Server running on ZFS <0.8 is not compatible with `O_DIRECT`, but Docker can use a special library to remove this mode.

```bash
git clone https://github.com/t-oster/mssql-docker-zfs.git
cp mssql-docker-zfs/nodirect_open.so docker-compose/
sed -i -e 's/#\(- LD_PRELOAD=\/nodirect_open.so\)/\1/' \
       -e 's/#\(- \/etc\/docker\/compose\/mssql\/nodirect_open.so:\/nodirect_open.so\)/\1/' \
       docker-compose/docker-compose.yml
```

Obviously, if you're not running ZFS or the version is 0.8 or newer, then you can skip this step.

## systemd

We're using systemd facilities to manage our Docker images and their cleanup.

* edit `/etc/systemd/system/docker-compose@.service`:

   ```ini
   [Unit]
   Description=%i service with docker compose
   Requires=docker.service
   After=docker.service
   
   [Service]
   Restart=always
   
   WorkingDirectory=/etc/docker/compose/%i
   
   # Remove old containers, images and volumes
   ExecStartPre=/usr/bin/docker-compose down -v
   ExecStartPre=/usr/bin/docker-compose rm -fv
   ExecStartPre=-/bin/bash -c 'docker volume ls -qf "name=%i_" | xargs docker volume rm'
   ExecStartPre=-/bin/bash -c 'docker network ls -qf "name=%i_" | xargs docker network rm'
   ExecStartPre=-/bin/bash -c 'docker ps -aqf "name=%i_*" | xargs docker rm'
   
   # Compose up
   ExecStart=/usr/bin/docker-compose up
   
   # Compose down, remove containers and volumes
   ExecStop=/usr/bin/docker-compose down -v
   
   [Install]
   WantedBy=multi-user.target
   ```

* edit `/etc/systemd/system/docker-cleanup.timer`:

   ```ini
   [Unit]
   Description=Docker cleanup timer
   
   [Timer]
   OnUnitInactiveSec=12h
   
   [Install]
   WantedBy=timers.target
   ```

* edit `/etc/systemd/system/docker-cleanup.service`:

   ```ini
   [Unit]
   Description=Docker cleanup
   Requires=docker.service
   After=docker.service
   
   [Service]
   Type=oneshot
   WorkingDirectory=/tmp
   User=root
   Group=root
   ExecStart=/usr/bin/docker system prune -f
   
   [Install]
   WantedBy=multi-user.target
   ```

## docker-compose

We're using `docker-compose` to create our shared MS SQL Server.

* create target directory:

   ```bash
   mkdir -p /etc/docker/compose/mssql/
   ```

* copy files from this repository's `docker-compose` folder into the created folder

   ```bash
   cp docker-compose/* /etc/docker/compose/mssql/
   ```

* make scripts executable:

   ```bash
   chmod +x /etc/docker/compose/mssql/*.sh
   ```

* edit `/etc/docker/compose/mssql/docker-compose.yml` and substitute password in `SA_PASSWORD=FIXME` (replace `FIXME`) with a complex password that passes SQL Server's [requirements](https://learn.microsoft.com/en-us/sql/relational-databases/security/password-policy)
* enter the same password into `/etc/docker/compose/mssql/bootstrap.sh` in `-P FIXME` (replace `FIXME`)
* if needed, in `/etc/docker/compose/mssql/docker-compose.yml` adjust [collation](https://learn.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support) and [timezone](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-configure-time-zone) in `MSSQL_COLLATION=SQL_Latin1_General_CP1_CI_AS` and `TZ=Etc/UTC`, respectively
* if you are running your own firewall then Docker's iptables support has to be disabled via `/etc/docker/daemon.json`:

   ```json
   { "iptables": false }
   ```

   restart Docker service to apply changes

   ```bash
   systemctl restart docker
   ```

* if a firewall (in this case `ufw`) is configured with default block mode add a rule to allow connection via the network defined in `docker-compose.yml`:

   ```bash
   ufw allow out to 172.18.0.0/16 port 1433
   ```

# Usage

* check if the image is building correctly:

   ```bash
   cd /etc/docker/compose/mssql/
   docker-compose up &
   ```

* if it is, then shut it down and configure systemd for automatic startup:

   ```bash
   docker-compose down
   
   systemctl enable docker-cleanup.timer
   systemctl enable docker-compose@mssql
   systemctl start docker-compose@mssql
   ```

* as a precaution we can add a restart into cron; run editor:

   ```bash
   crontab -e
   ```

   and add the following line:

   ```text
   30 3 * * * /bin/systemctl start docker-compose@mssql.service
   ```

# Moodle

In the course question bank import the prototype and sample questions from `.xml` files.
