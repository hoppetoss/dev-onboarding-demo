.PHONY: help dev stop build test lint logs clean setup

help: ## Show this help message
	@echo ""
	@echo "  🚀 Developer Commands"
	@echo "  ──────────────────────────────"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'
	@echo ""

setup: .venv ## First-time setup — copy .env and install dependencies
	@if [ ! -f .env ]; then cp .env.example .env; echo "  ✅ .env created — fill in your values"; fi
	.venv/bin/pip install -q -r app/requirements.txt
	@echo "  ✅ Dependencies installed"
	@echo "  👉 Run 'make dev' to start the stack"

dev: ## Start the full local stack (API + Prometheus + Grafana)
	docker compose up --build -d
	@echo ""
	@echo "  ✅ Stack is running!"
	@echo "  API       → http://localhost:8000"
	@echo "  API Docs  → http://localhost:8000/docs"
	@echo "  Grafana   → http://localhost:3000"
	@echo "  Prometheus→ http://localhost:9090"

stop: ## Stop all services
	docker compose down

build: ## Build the Docker image only
	docker build -t onboarding-demo:local .

.venv:
	python3 -m venv .venv

test: .venv ## Run tests
	.venv/bin/pip install -q -r app/requirements.txt
	.venv/bin/pytest tests/ -v

lint: .venv ## Lint the code
	.venv/bin/pip install -q ruff
	.venv/bin/ruff check app/

logs: ## Tail live logs from the API
	docker compose logs -f api

clean: ## Remove all containers and volumes
	docker compose down -v --remove-orphans
