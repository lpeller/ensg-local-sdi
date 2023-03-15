# Set default no argument goal to help
.DEFAULT_GOAL := help

# Ensure that errors don't hide inside pipes
SHELL         = /bin/bash
.SHELLFLAGS   = -o pipefail -c

# Setup variables
#
# -> Project variables
#PROJECT_NAME?=$(shell cat .env | grep -v ^\# | grep COMPOSE_PROJECT_NAME | sed 's/.*=//')

# -> App variables
APP_BASEURL?=$(shell cat .env | grep VIRTUALHOST | sed 's/.*=//')

# Every command is a PHONY, to avoid file naming confliction -> strengh comes from good habits!
.PHONY: help
help:
	@echo "=================================================================================="
	@echo " ENSG : training SDI  "
	@echo "  https://github.com/lpeller/ensg-local-sdi dépot"
	@echo " "
	@echo " Few hints:"
	@echo "  make build            # Checks that everythings's OK then builds the stack"
	@echo "  make up               # With working proxy, brings up the software stack"
	@echo "  make update           # Update the whole stack"
	@echo "  make hard-cleanup     # /!\ Remove images, containers, networks, volumes & data"
	@echo "=================================================================================="

.PHONY: build
build:
	docker compose build

.PHONY: up
up: build
	@bash echo "[INFO] Bringing up the stack"
	docker compose up -d --remove-orphans
	@make urls

.PHONY: hard-cleanup
hard-cleanup:
	@bash echo "[INFO] Bringing done the HTTPS automated proxy"
	docker compose -f docker-compose.yml down --remove-orphans
	# Delete all hosted persistent data available in volumes
	@bash echo "[INFO] Cleaning up static volumes"
	
	TODO

	@bash echo "[INFO] Cleaning up containers & images"
	docker system prune -a

.PHONY: urls
urls:
	@bash echo "[WARNING] You should now activate projet host file with # make set-hosts"
	@bash echo "[INFO] You may then access your project at the following URL:"
	@bash echo "Portainer docker admin GUI:  https://portainer.${APP_BASEURL}/"
	@echo ""

.PHONY: pull
pull: 
	docker compose pull

.PHONY: update
update: pull up wait
	docker image prune

.PHONY: wait
wait: 
	sleep 5
