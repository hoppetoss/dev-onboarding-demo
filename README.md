# Developer Onboarding Demo

> Zero to running in under 5 minutes.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)
- That's it.

## Quick Start

```bash
git clone <your-repo-url>
cd dev-onboarding-demo
make dev
```

## What you get

| Service    | URL                          | Description              |
|------------|------------------------------|--------------------------|
| API        | http://localhost:8000        | FastAPI application      |
| API Docs   | http://localhost:8000/docs   | Auto-generated Swagger   |
| Grafana    | http://localhost:3000        | Request metrics dashboard|
| Prometheus | http://localhost:9090        | Metrics storage          |

## Available Commands

```bash
make help    # Show all commands
make dev     # Start everything
make test    # Run tests
make lint    # Lint code
make stop    # Stop everything
make clean   # Remove containers + volumes
```

## Endpoints

| Endpoint        | Purpose                          |
|----------------|----------------------------------|
| GET /health    | Liveness probe                   |
| GET /ready     | Readiness probe + uptime         |
| GET /metrics   | Prometheus metrics               |
| GET /hello/:name | Greeting (try it!)             |
| GET /docs      | Interactive API documentation    |

## CI/CD

Every push to `main` runs:
1. **Lint** → checks code style
2. **Test** → runs all tests
3. **Build** → builds and pushes Docker image to GitHub Container Registry

