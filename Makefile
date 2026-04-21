# Developer Onboarding Demo

> Zero to running in under 5 minutes. No tribal knowledge required.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- [Cursor](https://cursor.sh/) (optional, for AI-assisted development)
- That's it.

## Quick Start

```bash
git clone <your-repo-url>
cd dev-onboarding-demo
make setup
make dev
```

## What you get

| Service    | URL                        | Description                    |
|------------|----------------------------|--------------------------------|
| API        | http://localhost:8000      | FastAPI application            |
| API Docs   | http://localhost:8000/docs | Auto-generated Swagger UI      |
| Grafana    | http://localhost:3000      | Request metrics dashboard      |
| Prometheus | http://localhost:9090      | Metrics storage                |

## Available Commands

```bash
make help    # Show all commands
make setup   # First-time setup — copy .env and install dependencies
make dev     # Start the full stack
make logs    # Tail live logs from the API
make test    # Run tests
make lint    # Lint code
make stop    # Stop all services
make clean   # Remove containers and volumes
```

## Endpoints

| Endpoint         | Purpose                                        |
|------------------|------------------------------------------------|
| GET /health      | Liveness probe — is the app alive?             |
| GET /ready       | Readiness probe — is it ready for traffic?     |
| GET /metrics     | Prometheus metrics                             |
| GET /hello/:name | Greeting endpoint                              |
| GET /docs        | Interactive API documentation (auto-generated) |

## Adding a New Endpoint

No restarts or rebuilds needed — the dev stack uses hot reload.

**1. Add the endpoint to `app/main.py`:**

```python
@app.get("/bla")
def bla():
    return {"message": "Hello World"}
```

**2. Save the file** — Uvicorn reloads automatically.

**3. Test it:**

```
http://localhost:8000/bla
→ {"message": "Hello World"}
```

**4. It appears in Swagger docs instantly** at http://localhost:8000/docs

**5. Metrics are tracked automatically** — open Grafana at http://localhost:3000, `/bla` appears in the dashboard with no extra configuration.

**6. Write the test:**

```python
@pytest.mark.asyncio
async def test_bla():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/bla")
    assert response.status_code == 200
    assert response.json()["message"] == "Hello World"
```

**7. Run it:**

```bash
make test
```

## Using Cursor (AI-assisted development)

Open the project in Cursor:

```bash
cursor .
```

Hit `Cmd+K` in `app/main.py` and type a prompt:

```
Add a GET endpoint /status that returns app version, environment and current timestamp
```

Accept the suggestion — it's live instantly via hot reload.

Then open `tests/test_main.py`, hit `Cmd+K`:

```
Add a test for the /status endpoint
```

Run `make test` — all green. Cursor uses the existing code patterns as context, so suggestions fit the project, not just the language.

## Logs

Logs are structured JSON — machine-readable and queryable:

```bash
make logs
```

```json
{"timestamp": "2026-04-16 21:00:12", "level": "INFO", "message": "GET /hello/Magnus → 200 (0.002s)", "logger": "app"}
```

A log aggregator like Loki, Datadog or CloudWatch can query these by any field. Plain text logs can't do that reliably.

## Secrets

Never commit secrets to git. `make setup` copies `.env.example` to `.env` automatically on first run.

`.env` is in `.gitignore` and will never be committed. `.env.example` documents every variable the app needs and is always up to date.

For CI, secrets live in **GitHub → Settings → Secrets and variables → Actions**.

## CI/CD Pipeline

Every push to `main` runs automatically:

```
push to main
    │
    ├── 1. Lint    — check code style (ruff)
    ├── 2. Test    — run all tests (pytest)
    └── 3. Build   — build and push Docker image to ghcr.io
```

Branch protection is enforced — merging to `main` requires lint and tests to pass.

## Project Structure

```
.
├── app/
│   ├── main.py              # FastAPI application
│   └── requirements.txt     # Python dependencies
├── tests/
│   └── test_main.py         # Tests
├── .github/workflows/
│   └── ci.yml               # CI/CD pipeline
├── grafana/                 # Pre-provisioned Grafana dashboard
├── prometheus/              # Prometheus scrape config
├── .env.example             # Environment variable template
├── conftest.py              # Pytest path config
├── pytest.ini               # Pytest settings
├── Dockerfile               # Multi-stage, non-root build
├── docker-compose.yml       # Local dev stack
└── Makefile                 # Developer command interface
```

## Architecture Decisions

| Decision | Why |
|----------|-----|
| Multi-stage Dockerfile | Smaller image, no build tools in production |
| Non-root container user | Reduced attack surface |
| `/health` vs `/ready` | Kubernetes liveness vs readiness probe semantics |
| Structured JSON logs | Machine-readable, queryable by log aggregators |
| Makefile as interface | Discoverable, consistent across all machines |
| `.env.example` pattern | Secrets documented but never committed |
| Prometheus + Grafana | Observability from day one, not bolted on later |
