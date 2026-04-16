.PHONY: help dev stop build test lint clean

## Show this help message
help:
	@echo ""
	@echo "  🚀 Developer Commands"
	@echo "  ──────────────────────────────"
	@grep -E '^## ' Makefile | sed 's/## /  /'
	@echo ""

## Start the full local stack (API + Prometheus + Grafana)
dev:
	docker compose up --build -d
	@echo ""
	@echo "  ✅ Stack is running!"
	@echo "  API       → http://localhost:8000"
	@echo "  API Docs  → http://localhost:8000/docs"
	@echo "  Grafana   → http://localhost:3000"
	@echo "  Prometheus→ http://localhost:9090"

## Stop all services
stop:
	docker compose down

## Build the Docker image only
build:
	docker build -t onboarding-demo:local .

## Run tests
test:
	pip install -q -r app/requirements.txt
	pytest tests/ -v

## Lint the code
lint:
	pip install -q ruff
	ruff check app/

## Remove all containers and volumes
clean:
	docker compose down -v --remove-orphans
