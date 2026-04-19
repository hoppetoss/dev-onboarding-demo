.PHONY: help dev stop build test lint clean

help: ## Show this help message
	@echo ""
	@echo "  🚀 Developer Commands"
	@echo "  ──────────────────────────────"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'
	@echo ""

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

logs: ## Tail logs from all running services
	docker compose logs -f api

clean: ## Remove all containers and volumes
	docker compose down -v --remove-orphans