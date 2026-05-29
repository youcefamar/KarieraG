# Kariera — developer commands
# Usage: make <target>

COMPOSE := docker compose -f infrastructure/docker/docker-compose.local.yml
BACKEND := backend
MOBILE  := apps/mobile

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Install backend + mobile dependencies
	cd $(BACKEND) && python -m pip install -r requirements/dev.txt
	cd $(MOBILE) && npm install

.PHONY: backend
backend: ## Run Django dev server (host)
	cd $(BACKEND) && python manage.py runserver 0.0.0.0:8000

.PHONY: mobile
mobile: ## Start Expo dev server
	cd $(MOBILE) && npm install && npx expo start

.PHONY: migrate
migrate: ## Apply DB migrations (in backend container)
	$(COMPOSE) exec backend python manage.py migrate

.PHONY: makemigrations
makemigrations: ## Create new migrations
	$(COMPOSE) exec backend python manage.py makemigrations

.PHONY: createsuperuser
createsuperuser: ## Create a Django admin user
	$(COMPOSE) exec backend python manage.py createsuperuser

.PHONY: test
test: ## Run backend tests
	$(COMPOSE) exec backend pytest

.PHONY: lint
lint: ## Lint backend (ruff)
	cd $(BACKEND) && ruff check .

.PHONY: format
format: ## Format backend (black + isort + ruff --fix)
	cd $(BACKEND) && isort . && black . && ruff check --fix .

.PHONY: docker-up
docker-up: ## Start local stack (postgres, redis, backend, ...)
	$(COMPOSE) up -d --build

.PHONY: docker-down
docker-down: ## Stop local stack
	$(COMPOSE) down

.PHONY: logs
logs: ## Tail backend logs
	$(COMPOSE) logs -f backend
