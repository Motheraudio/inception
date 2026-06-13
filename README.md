*This project has been created as part of the 42 curriculum by alvcampo.*

# Inception

## Description

Inception is a system administration exercise that involves building a small web infrastructure entirely from Docker containers. The stack consists of three services — NGINX, WordPress + PHP-FPM, and MariaDB — each running in its own dedicated container, orchestrated with Docker Compose and launched via a Makefile.

The project enforces strict rules: no pre-built images from Docker Hub (except Alpine/Debian base), TLSv1.3-only access through NGINX on port 443, persistent named volumes for the database and website files, and all secrets stored outside the repository.

## Instructions

### Prerequisites

- Docker and Docker Compose v2 installed on the host
- `sudo` access (to create data directories and update `/etc/hosts`)
- A `secrets/.env` file at the repository root (see [DEV_DOC.md](DEV_DOC.md) for the required variables)

### Build and run

```bash
make
```

This single command:
1. Creates the required data directories under `~/data/`
2. Adds `alvcampo.42.fr` to `/etc/hosts` if not already present
3. Builds all Docker images
4. Starts all containers in detached mode

### Stop and clean up

```bash
make down    # Stop containers and remove volumes
make clean   # Stop containers, remove volumes, and delete data directories
```

### Change the NGINX port

Edit `secrets/.env` and update the `NGINX_PORT` value, then run `make down && make`.

## Project Description

### Use of Docker

This project uses Docker to isolate each service in its own container. Each service has a custom `Dockerfile` built from Alpine Linux. Docker Compose coordinates the three containers on a shared bridge network (`inception-network`), with explicit `depends_on` and healthcheck conditions to enforce startup ordering.

The images built are:
- `nginx:inception` — NGINX reverse proxy with TLS termination
- `wordpress:inception` — WordPress + PHP-FPM (no web server)
- `mariadb:inception` — MariaDB database server

### Design choices

- **TLSv1.3 only**: the NGINX container generates a self-signed certificate at startup and enforces `ssl_protocols TLSv1.3`.
- **Runtime configuration**: all ports, domain name, and credentials are read from environment variables at container startup — no hardcoded values in any Dockerfile or image.
- **Reliable DB initialization**: MariaDB is initialized with `--init-file` on first boot, which is more reliable than `--bootstrap` for creating users and databases.
- **WordPress URL persistence**: `WP_HOME` and `WP_SITEURL` are updated on every WordPress container startup so port changes are always reflected without manual DB edits.

### Virtual Machines vs Docker

| | Virtual Machine | Docker Container |
|---|---|---|
| Isolation | Full OS isolation, separate kernel | Process isolation, shared host kernel |
| Overhead | High (full OS per VM) | Low (shares kernel, minimal overhead) |
| Boot time | Minutes | Seconds |
| Portability | Image files are large | Images are layered and cache-efficient |
| Use case | Strong isolation, different OS needed | Microservices, reproducible environments |

Docker containers are used here because the services are well-defined, lightweight, and benefit from fast startup and easy orchestration.

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| Storage | Files on disk, excluded from git | Shell environment or `.env` files |
| Exposure | Not visible in `docker inspect` | Visible in `docker inspect` and process list |
| Scope | Per-container, explicit mount | Inherited by child processes |
| 42 recommendation | Strongly recommended for credentials | Acceptable for non-sensitive config |

This project stores all configuration (including credentials) in `secrets/.env`, which is git-ignored. The file is passed to containers via Docker Compose's `env_file` directive.

### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|---|---|---|
| Isolation | Containers on a private virtual network | Containers share the host's network stack |
| Inter-container DNS | Containers reachable by service name | No isolation; must use `localhost` |
| Port exposure | Explicit port mapping required | Ports open directly on host |
| Security | Better: no unintended port exposure | Weaker: all container ports are host ports |

This project uses a named bridge network (`inception-network`) so containers communicate by service name (e.g., `wordpress:9000`, `mariadb:3306`) and only NGINX exposes a port to the host.

### Docker Volumes vs Bind Mounts

| | Docker Named Volumes | Bind Mounts |
|---|---|---|
| Managed by | Docker daemon | Host filesystem path |
| Portability | Yes — no host path dependency | No — tied to a specific host path |
| Subject requirement | Required | Forbidden for the two main volumes |
| Data location | Configurable via `driver_opts` | Explicit host path |

This project uses named volumes with a local bind backend pointing to `/home/alvcampo/data/`, satisfying the subject requirement that data live in `/home/login/data` while still being declared as named volumes.

## Resources

### Documentation

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB Server documentation](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [OpenSSL self-signed certificates](https://www.openssl.org/docs/manmaster/man1/openssl-req.html)

### AI usage

AI (Claude) was used in the following parts of this project:

- **Debugging**: diagnosing why MariaDB failed to create users (`--bootstrap` vs `--init-file`), why PHP-FPM was unreachable from NGINX (bound to `127.0.0.1` instead of `0.0.0.0`), and why the WordPress admin redirect looped after a port change.
- **Documentation**: drafting the three documentation files (README.md, USER_DOC.md, DEV_DOC.md).

All AI-generated content was reviewed, tested, and understood before being accepted into the project.
