# Host preparation (assuming Debian 12.9)

* act below as root user

   ```bash
   sudo su
   ```

* install Debian packages:

   ```bash
   apt install docker.io docker-compose mariadb-client python3-venv cron
   ```

* install Python modules in virtual environment:

   ```bash
   mkdir -p /opt/venv
   python3 -m venv /opt/venv/mysql-shared
   source /opt/venv/mysql-shared/bin/activate
   pip install -r requirements.txt
   deactivate
   ```

# Docker image preparation

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

We're using `docker-compose` to create our shared MySQL server.

* create target directory:

   ```bash
   mkdir -p /etc/docker/compose/mysql/
   ```

* copy files from this repository's `docker-compose` folder into the created folder

   ```bash
   cp docker-compose/* /etc/docker/compose/mysql/
   ```

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
   ufw allow out to 172.19.0.0/16 port 3306
   ```

# Usage

* check if the image is building correctly:

   ```bash
   cd /etc/docker/compose/mysql/
   docker-compose up &
   ```

* if it is, then shut it down and configure systemd for automatic startup:

   ```bash
   docker-compose down

   systemctl enable docker-cleanup.timer
   systemctl enable docker-compose@mysql
   systemctl start docker-compose@mysql
   ```

* as a precaution we can add a restart into cron; run editor:

   ```bash
   crontab -e
   ```

   and add the following line:

   ```text
   30 3 * * * /bin/systemctl start docker-compose@mysql.service
   ```

# Moodle

In the course question bank import the prototype and sample questions from `.xml` files.
