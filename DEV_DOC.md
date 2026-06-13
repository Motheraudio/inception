# Developer Documentation — Inception

## Environment setup from scratch

### Prerequisites

- A Linux virtual machine (Debian or Ubuntu recommended)
- Docker Engine and Docker Compose v2: `apt install docker.io docker-compose-plugin`
- `make`, `sudo`, `openssl` available on the host
- The repository cloned to a local directory

### Configuration files

All configuration lives in `secrets/.env` at the repository root. This file is git-ignored and must be created manually.

Create `secrets/.env` with the following variables:

```env
NGINX_PORT=
WP_PORT=
MYSQL_PORT=
MYSQL_DB=
MYSQL_DB_USER=
MYSQL_DB_PWD=
DOMAIN_NAME=
WP_USR=
WP_PWD=
WP_EMAIL=
WP_ADMIN_USR=
WP_ADMIN_PWD=
WP_ADMIN_EMAIL=
```

**Security rules:**
- Never commit `secrets/.env` to git
- No passwords may appear in any Dockerfile
- Credentials outside of properly configured secrets will cause project failure

### Hosts entry

The Makefile adds this automatically, but you can also do it manually:

```bash
echo "127.0.0.1 alvcampo.42.fr" | sudo tee -a /etc/hosts
```

## Building and launching the project

### Full startup (build + run)

```bash
make
```

This runs the following targets in order:

| Target | Action |
|---|---|
| `create_dirs` | Creates `~/data/wordpress`, `~/data/nginx`, `~/data/db` with `sudo` |
| `hosts` | Adds `alvcampo.42.fr` to `/etc/hosts` if not present |
| `build` | Builds all Docker images via `docker compose build` |
| `up` | Starts all containers detached via `docker compose up -d` |

### Individual targets

```bash
make build   # Build images only
make up      # Start containers only (images must already be built)
make down    # Stop and remove containers and volumes
make clean   # down + delete ~/data/* directories
```

### How NGINX_PORT flows into the stack

`NGINX_PORT` is read from `secrets/.env` by the Makefile at build time using `$(shell grep)`. It is then passed as an inline environment variable prefix to every `docker compose` call. Docker Compose uses it for the `ports:` mapping in `docker-compose.yml`. The containers themselves receive it via `env_file: ../secrets/.env`.

## Managing containers and volumes

### View running containers

```bash
docker ps
```

### View logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs -f mariadb   # follow live
```

### Execute a shell inside a container

```bash
docker exec -it nginx sh
docker exec -it wordpress bash
docker exec -it mariadb bash
```

### Connect to MariaDB directly

```bash
docker exec -it mariadb mariadb -u mysql_user -p mysql_db
```

### Restart a single container

```bash
docker restart wordpress
```

Useful when changing `NGINX_PORT` — restarting the WordPress container forces it to re-run `wp config set WP_HOME/WP_SITEURL` with the new URL.

### Inspect volume details

```bash
docker volume ls
docker volume inspect wordpress
docker volume inspect db
```

### Rebuild a single service after a Dockerfile change

```bash
cd srcs && NGINX_PORT=$(grep '^NGINX_PORT=' ../secrets/.env | cut -d= -f2) docker compose build nginx
```

## Data storage and persistence

### Where data lives

| Volume | Container path | Host path |
|---|---|---|
| `wordpress` | `/var/www/wordpress` | `~/data/wordpress` |
| `db` | `/var/lib/mysql` | `~/data/db` |

Both are declared as Docker **named volumes** backed by a local bind driver pointing at the host paths above. This satisfies the subject requirement (data in `/home/alvcampo/data`) while using named volumes rather than bare bind mounts.

### How persistence works

- **MariaDB**: `mariadb.sh` checks for the existence of `/var/lib/mysql/mysql` on startup. If absent, it runs `mariadb-install-db` and then starts `mariadbd` with `--init-file` to create the application database and user. On subsequent starts the init is skipped.
- **WordPress**: `wordpress.sh` checks for `wp-config.php` on startup. If absent, it downloads WordPress core, creates `wp-config.php`, installs WordPress, and creates the two required users. On subsequent starts only `WP_HOME`/`WP_SITEURL` are updated to reflect any port changes.

### Wiping data completely

```bash
make clean
```

This calls `make down` (removes containers and Docker volumes) and then deletes the host data directories. The next `make` starts completely fresh.

## Project structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   └── .env                  # git-ignored, must be created manually
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │       └── nginx.sh  # generates nginx.conf + TLS cert at runtime
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── wordpress.sh  # installs WP and starts php-fpm at runtime
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            └── tools/
                └── mariadb.sh    # initializes DB on first boot
```
