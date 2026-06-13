# User Documentation — Inception

## What this stack provides

This infrastructure runs a WordPress website accessible over HTTPS. It is composed of three services:

| Service | Role |
|---|---|
| **NGINX** | Receives all incoming HTTPS traffic and forwards PHP requests to WordPress |
| **WordPress + PHP-FPM** | Serves the WordPress application |
| **MariaDB** | Stores the WordPress database |

The website is reachable at `https://alvcampo.42.fr` (port 443 by default).

## Starting and stopping the project

### Start

```bash
make
```

Wait a few seconds for all containers to finish starting. The first run will take longer because Docker needs to build the images.

### Stop (keep data)

```bash
make down
```

Stops and removes the containers. Your website data and database are preserved.

### Stop and delete all data

```bash
make clean
```

Stops containers and permanently deletes all website files and the database. The next `make` will start fresh.

## Accessing the website

### Public website

Open your browser and go to:

```
https://alvcampo.42.fr
```

Accept the browser security warning about the self-signed certificate and the site will load.

### Administration panel

```
https://alvcampo.42.fr/wp-admin
```

Log in with the administrator credentials found in `secrets/.env` (see below).

## Credentials

All credentials are stored in `secrets/.env` at the root of the project. This file is not committed to git.

| Variable | What it is |
|---|---|
| `WP_ADMIN_USR` | WordPress administrator username |
| `WP_ADMIN_PWD` | WordPress administrator password |
| `WP_ADMIN_EMAIL` | WordPress administrator email |
| `WP_USR` | Regular WordPress user (contributor role) |
| `WP_PWD` | Regular user password |
| `MYSQL_DB_USER` | MariaDB application user |
| `MYSQL_DB_PWD` | MariaDB application password |
| `DOMAIN_NAME` | The site domain (`alvcampo.42.fr`) |
| `NGINX_PORT` | The HTTPS port (default `443`) |

To change any credential or configuration value, edit `secrets/.env` and restart the stack with `make down && make`.

## Checking that services are running

### Quick status check

```bash
docker ps
```

You should see three containers running: `nginx`, `wordpress`, and `mariadb`.

### Check container logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Test NGINX is responding

```bash
curl -k https://alvcampo.42.fr
```

A successful response returns HTML. `-k` skips the self-signed certificate warning.

### Check MariaDB is healthy

```bash
docker inspect --format='{{.State.Health.Status}}' mariadb
```

Should return `healthy`.

### Verify website files are persisted

```bash
ls ~/data/wordpress/
ls ~/data/db/
```

Both directories should contain files as long as the stack has been started at least once.
