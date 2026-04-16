import time
import logging
import json
from fastapi import FastAPI, Request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response

# Structured JSON logger — every log line is machine-readable
class JSONFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
        })

handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger = logging.getLogger("app")
logger.addHandler(handler)
logger.setLevel(logging.INFO)

app = FastAPI(title="Onboarding Demo API", version="1.0.0")

# Prometheus metrics — request count and latency
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"]
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency",
    ["endpoint"]
)

START_TIME = time.time()

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    """Automatically track metrics for every request"""
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(endpoint=request.url.path).observe(duration)
    logger.info(f"{request.method} {request.url.path} → {response.status_code} ({duration:.3f}s)")
    return response

@app.get("/")
def root():
    return {"message": "Welcome to the Onboarding Demo API", "docs": "/docs"}

@app.get("/health")
def health():
    """Liveness probe — is the app alive?"""
    return {"status": "ok"}

@app.get("/ready")
def ready():
    """Readiness probe — is the app ready to serve traffic?"""
    uptime = time.time() - START_TIME
    return {"status": "ready", "uptime_seconds": round(uptime, 2)}

@app.get("/metrics")
def metrics():
    """Prometheus metrics endpoint — scraped every 5 seconds"""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/hello/{name}")
def hello(name: str):
    logger.info(f"Greeting requested for: {name}")
    return {"message": f"Hello, {name}! Welcome to the team."}

@app.get("/bla")
def bla():
    return {"message": "Hello World"}