
DATA_DIR := $(HOME)/data
WORDPRESS_DIR := $(DATA_DIR)/wordpress
NGINX_DIR := $(DATA_DIR)/nginx
MARIADB_DIR := $(DATA_DIR)/mariadb
name = inception

all: create_dirs build up

create_dirs:
	mkdir -p $(WORDPRESS_DIR) $(NGINX_DIR) $(MARIADB_DIR)

build:
	cd srcs && docker compose up -d --build
up:
	cd srcs && docker compose up -d
down:
	cd srcs && docker compose down -v
clean: down
	rm -rf $(WORDPRESS_DIR) $(NGINX_DIR) $(MARIADB_DIR)

.PHONY: all build up down clean