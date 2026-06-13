
DATA_DIR := $(HOME)/data
WORDPRESS_DIR := $(DATA_DIR)/wordpress
NGINX_DIR := $(DATA_DIR)/nginx
MARIADB_DIR := $(DATA_DIR)/db
name = inception

all: create_dirs hosts build up

create_dirs:
	sudo mkdir -p $(WORDPRESS_DIR) $(NGINX_DIR) $(MARIADB_DIR)

hosts:
	@grep -qF "alvcampo.42.fr" /etc/hosts || echo "127.0.0.1 alvcampo.42.fr" | sudo tee -a /etc/hosts

build:
	cd srcs && docker compose build
up:
	cd srcs && docker compose up -d
down:
	cd srcs && docker compose down -v
clean: down
	sudo rm -rf $(WORDPRESS_DIR) $(NGINX_DIR) $(MARIADB_DIR)

.PHONY: all build up down clean