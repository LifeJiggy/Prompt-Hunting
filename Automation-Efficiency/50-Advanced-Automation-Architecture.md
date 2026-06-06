# 50 — Advanced Automation Architecture

## Scope

Advanced automation architecture describes production-grade platforms that scale beyond single-script workflows. This file covers event-driven microservices using message queues, polyglot persistence, API gateway design for tool orchestration, service mesh patterns for internal communication, progressive enhancement from single tools to full platforms, and enterprise-scale considerations (tenancy, rate limiting, cost allocation, audit trails). Apply these patterns when a single orchestration framework (Prefect/Airflow/Temporal) is insufficient and you need a distributed system.

---

## 1. From Scripts to Platform — Progressive Enhancement

Do not start with microservices. Progressively evolve the architecture as concurrency, failure domain, and team size demands.

| Stage             | Scale            | Architecture                        | Tooling                        |
|-------------------|------------------|-------------------------------------|--------------------------------|
| Level 0: Scripts  | 1–5 targets/day  | Single Python script, subprocess    | `subprocess`, `schedule`       |
| Level 1: Pipeline | 5–50 targets/day | Prefect / Airflow DAG               | Prefect, Airflow               |
| Level 2: Platform | 50–1000+/day     | Microservices + message queues      | Temporal + Redis Streams       |
| Level 3: Enterprise | 10k+/day       | Multi-tenant, service mesh, sharded | Kafka + Kubernetes + Istio    |

**Evolution trigger**: when a single pipeline run exceeds 1 hour, or when failure of one scan stage blocks others. Split into services at Level 2.

---

## 2. Event-Driven Microservices Architecture

At Level 2+ the system is a network of independent services that communicate via events. The core services for a security automation platform are:

```
                   ┌─────────────────┐
                   │   API Gateway   │   ← external trigger, auth, rate-limit
                   └────────┬────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
        ┌─────▼─────┐ ┌────▼────┐ ┌─────▼─────┐
        │ Discover  │ │ Scan    │ │  Report   │
        │  Service  │ │ Service │ │  Service  │
        └─────┬─────┘ └────┬────┘ └─────┬─────┘
              │             │             │
              └─────────────┼─────────────┘
                            │
                     ┌──────▼────────┐
                     │ Message Queue │   ← Redis Streams or Kafka
                     └──────────────┘
```

**Discover Service** — enumerates assets (subdomains, IPs, cloud resources). Pushes `asset.discovered` events.
**Scan Service** — subscribes to `asset.discovered`, runs vulnerability scanners, pushes `scan.completed` events.
**Report Service** — subscribes to `scan.completed`, generates SARIF/HTML reports, pushes `report.published` events.
**Notification Service** — subscribes to all terminal events, sends Slack/email/PagerDuty alerts.

Each service owns its data storage and is deployed, scaled, and failed independently.

---

## 3. Redis Streams for Workflow Coordination

Redis Streams is the lightweight option for service-to-service messaging. It is sufficient for teams < 10k events/day and provides consumer groups, message acknowledgment, and replay.

**Service consumer with Redis Streams (Python)**.

```python
import asyncio
import json
import logging
import os
import redis.asyncio as redis

REDIS_URL = os.environ["REDIS_URL"]
SCAN_STREAM = "scan-jobs"
SCAN_GROUP  = "scan-service-workers"
CONSUMER_NAME = f"worker-{os.getpid()}"

STREAMS = {
    "asset.discovered": "scan",
    "scan.completed":  "report",
    "report.published": "notify",
}

logger = logging.getLogger("platform")

async def consume_stream(stream_name: str, target_group: str):
    r = redis.from_url(REDIS_URL, decode_responses=True)

    # Ensure consumer group exists
    try:
        await r.xgroup_create(stream_name, target_group, id="0", mkstream=True)
    except redis.ResponseError as e:
        if "BUSYGROUP" not in str(e):
            raise

    logger.info("consumer started", extra={"stream": stream_name, "consumer": CONSUMER_NAME})

    while True:
        # Block for 5s waiting for new messages
        result = await r.xreadgroup(
            groupname=target_group,
            consumername=CONSUMER_NAME,
            streams={stream_name: ">"},
            count=10,
            block=5000,
        )
        if not result:
            continue

        for stream_key, messages in result:
            for message_id, payload in messages:
                try:
                    await handle_message(stream_name, payload)
                    await r.xack(stream_name, target_group, message_id)
                except Exception as e:
                    logger.exception("message failed", extra={"id": message_id})
                    # Message stays un-acked and will be redelivered after group
                    # idle time expires, or manually claimed by another consumer

async def handle_message(stream: str, payload: dict[str, str]) -> None:
    event = json.loads(payload["data"])
    if stream == "asset.discovered":
        await run_scan(event)
    elif stream == "scan.completed":
        await generate_report(event)
    elif stream == "report.published":
        await send_notification(event)
```

**Producer — Discover Service pushing asset events**.

```python
import redis.asyncio as redis

async def publish_discovery_event(assets: list[dict]) -> None:
    r = redis.from_url(REDIS_URL, decode_responses=True)
    pipe = r.pipeline()
    for asset in assets:
        pipe.xadd(
            "asset.discovered",
            {
                "data": json.dumps({
                    "asset_id": str(uuid.uuid4()),
                    "type": asset["type"],
                    "value": asset["value"],
                    "source": asset["source"],
                    "discovered_at": utcnow().isoformat(),
                }),
                "domain": asset.get("domain", ""),
            },
        )
    await pipe.execute()
```

**Consumer group for scale (multiple workers)**:

```bash
# Start 5 instances of the same service across 5 processes or hosts
# Redis delivers each message to exactly one consumer in the group
python -m services.scan_service &  # consumer-1
python -m services.scan_service &  # consumer-2
python -m services.scan_service &  # consumer-3
python -m services.scan_service &  # consumer-4
python -m services.scan_service &  # consumer-5
```

---

## 4. Kafka for High-Throughput Pipelines

Kafka replaces Redis Streams when you exceed 10k messages/day, need multi-datacenter replication, or require ordered partition consumption with offset commit.

**Producer using `confluent-kafka`**:

```python
from confluent_kafka import Producer
import json

KAFKA_BOOTSTRAP = os.environ["KAFKA_BOOTSTRAP_SERVERS"]

producer = Producer({
    "bootstrap.servers": KAFKA_BOOTSTRAP,
    "linger.ms": 100,           # batch up to 100ms before sending
    "batch.num.messages": 1000, # or send when buffer hits 1000
    "acks": "all",              # wait for all in-sync replicas
    "retries": 5,
    "max.in.flight.requests.per.connection": 1,  # preserve order
})

def delivery_report(err, msg):
    if err:
        logger.error("delivery failed", extra={"topic": msg.topic(), "error": str(err)})
    else:
        logger.debug("delivered", extra={"topic": msg.topic(), "partition": msg.partition(), "offset": msg.offset()})

def publish_asset_discovered(assets: list[dict]) -> None:
    for asset in assets:
        producer.produce(
            topic="asset.discovered",
            key=asset["domain"].encode(),
            value=json.dumps(asset).encode(),
            on_delivery=delivery_report,
        )
    producer.flush()  # wait for all pending messages
```

**Consumer group using `aiokafka`**:

```python
from aiokafka import AIOKafkaConsumer

async def consume_assets():
    consumer = AIOKafkaConsumer(
        "asset.discovered",
        bootstrap_servers=KAFKA_BOOTSTRAP,
        group_id="scan-service",
        enable_auto_commit=False,  # manual commit after processing
        auto_offset_reset="earliest",
        value_deserializer=lambda v: json.loads(v.decode()),
        key_deserializer=lambda k: k.decode(),
        max_poll_records=50,
    )
    await consumer.start()
    try:
        async for msg in consumer:
            try:
                await process_asset(msg.value)
                await consumer.commit()  # advance offset only on success
            except Exception:
                logger.exception("processing failed")
                # Do not commit — message will be redelivered
    finally:
        await consumer.stop()
```

**Kafka topic design for the security platform**:

| Topic Name            | Partitions | Retention | Key              | Use Case                     |
|---------------------- |-----------|-----------|------------------|-------------------------------|
| `asset.discovered`   | 8         | 7d        | domain (or IP)  | Discover → Scan handoff       |
| `scan.completed`     | 8         | 14d       | scan_id          | Scan → Report handoff         |
| `report.published`   | 4         | 30d       | report_id        | Report → Notify / Archive     |
| `alerts.high`        | 2         | 90d       | finding_id       | Alert queue for on-call       |
| `dlq`                | 2         | 30d       | original topic   | Dead-letter queue for failures|

**Dead-letter queue (DLQ) pattern for failed events**:

```python
async def process_with_dlq(msg):
    try:
        event = msg.value
        await handle(event)
        await consumer.commit()
    except PermanentError as e:
        logger.error("permanent failure, routing to DLQ", extra={"error": str(e)})
        dlq_producer.produce("dlq", value=json.dumps({
            "original_topic": msg.topic,
            "original_partition": msg.partition,
            "original_offset": msg.offset,
            "payload": msg.value,
            "error": str(e),
            "timestamp": utcnow().isoformat(),
        }))
        await consumer.commit()
    except TransientError as e:
        logger.warning("transient failure, will retry", extra={"error": str(e)})
```

---

## 5. Polyglot Persistence

Different data types require different databases. Use the right storage engine for each job.

```
               ┌───────────────────┐
               │   Security        │
               │   Platform API    │
               └────────┬──────────┘
                  ┌─────┼─────┐
                  │     │     │
      ┌───────────▼──┐ ┌▼─────┐ ┌▼──────────────┐
      │  PostgreSQL  │ │Redis│ │  Elasticsearch │
      │ (relational) │ │Cache│ │  (full-text)   │
      └──────┬───────┘ └─────┘ └───────┬────────┘
             │                          │
             │       ┌──────────────────▼────────┐
             │       │   S3 / GCS (object store)  │
             │       │   - raw scan outputs       │
             │       │   - SARIF/JSONL results    │
             │       │   - report PDFs/HTML       │
             │       └────────────────────────────┘
             │
             │       ┌──────────────────┐
             │       │   TimescaleDB    │
             │       │   (time-series)  │
             │       │   - metrics      │
             │       │   - billing data │
             │       └──────────────────┘
```

**When to use each storage engine**:

| Data Type                   | Storage         | Justification                                                        |
|-----------------------------|-----------------|----------------------------------------------------------------------|
| Scan results, findings      | PostgreSQL + JSONB | Relational queries, ACID, GIN indexes on JSONB for fast filtering |
| Live state, locks, caching  | Redis           | Sub-millisecond reads, TTL eviction, pub/sub for presence           |
| Full-text search, dashboards | Elasticsearch  | Aggregations, keyword matching, Kibana/Grafana visualizations       |
| Raw artefacts, backups      | S3 / GCS        | Cheap, immutable, lifecycle policies                                |
| Time-series metrics         | TimescaleDB / Prometheus + VictoriaMetrics | Efficient rollups, retention policies |
| Graph relationships (assets ↔ findings) | Neo4j | Gremlin/Cypher queries for attack-path modeling |

**PostgreSQL schema for findings**:

```sql
CREATE TABLE scan_runs (
    scan_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain       TEXT NOT NULL,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at   TIMESTAMPTZ,
    finished_at  TIMESTAMPTZ,
    status       TEXT NOT NULL DEFAULT 'running', -- pending | running | complete | failed
    runner       TEXT,
    CONSTRAINT check_status CHECK (status IN ('pending','running','complete','failed'))
);

CREATE TABLE findings (
    finding_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scan_id        UUID NOT NULL REFERENCES scan_runs(scan_id) ON DELETE CASCADE,
    severity       TEXT NOT NULL,
    category       TEXT,
    title          TEXT NOT NULL,
    affected_resource TEXT,
    evidence       JSONB,
    remediation    TEXT[],
    first_seen     TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen      TIMESTAMPTZ NOT NULL DEFAULT now(),
    false_positive BOOLEAN NOT NULL DEFAULT FALSE,
    acknowledged   BOOLEAN NOT NULL DEFAULT FALSE,
    acknowledged_by TEXT,
    acknowledged_at TIMESTAMPTZ
);

CREATE INDEX idx_findings_scan ON findings(scan_id);
CREATE INDEX idx_findings_severity ON findings(severity);
CREATE INDEX idx_findings_evidence_gin ON findings USING GIN (evidence);
CREATE INDEX idx_findings_first_seen ON findings(first_seen DESC);
```

---

## 6. API Gateway for Tool Orchestration

An API gateway is the single external entry point that handles authentication, rate-limiting, request validation, and routing to internal services.

**Technology choices**:

| Gateway           | Best For                         | Notes                                  |
|-------------------|----------------------------------|----------------------------------------|
| Kong (OSS)        | Plugin ecosystem, enterprise      | Lua plugins, rate limiting built-in    |
| Tyk               | Developer portal, multi-tenancy  | Good SaaS offering                     |
| APISIX            | Cloud-native, etcd-backed        | Declarative config, Ingress Controller |
| FastAPI + Uvicorn | Lightweight, self-hosted          | Fastest to stand up, Python-native     |
| AWS API Gateway   | Cloud-native, Lambda integration  | Pay-per-request SP                     |

**FastAPI-based internal gateway**:

```python
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, Field, HttpUrl, field_validator
from redis.asyncio import Redis
import httpx

app = FastAPI(title="Security Automation Gateway")
security = HTTPBearer()
redis_client = Redis.from_url(os.environ["REDIS_URL"], decode_responses=True)

class ScanRequest(BaseModel):
    target: HttpUrl
    scan_types: list[str] = Field(default_factory=lambda: ["subdomain", "nuclei"])
    max_concurrency: int = Field(default=5, gt=0, le=20)

    @field_validator("scan_types")
    @classmethod
    def valid_scan_types(cls, v: list[str]) -> list[str]:
        allowed = {"subdomain", "httpx", "nuclei", "s3_enum"}
        invalid = set(v) - allowed
        if invalid:
            raise ValueError(f"Unknown scan types: {invalid}")
        return v

async def verify_token(
    creds: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    token = creds.credentials
    if not await is_valid_jwt(token):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return {"sub": "automation-service", "scopes": ["scan:write"]}

async def rate_limiter(key: str, limit: int, window: int) -> bool:
    """Sliding window rate limiter using Redis sorted sets."""
    now = int(time.time())
    pipe = redis_client.pipeline()
    pipe.zadd(key, {str(now): now})
    pipe.zremrangebyscore(key, "-inf", now - window)
    pipe.zcard(key)
    pipe.expire(key, window)
    _, _, count, _ = await pipe.execute()
    return count <= limit

@app.post("/v1/scan", status_code=202)
async def start_scan(
    req: ScanRequest,
    claims: dict = Depends(verify_token),
) -> dict:
    rate_key = f"rate:{claims['sub']}"
    if not await rate_limiter(rate_key, limit=100, window=3600):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")

    scan_id = str(uuid.uuid4())
    await publish_event("scan.requested", {
        "scan_id": scan_id,
        "target": str(req.target),
        "scan_types": req.scan_types,
        "requested_by": claims["sub"],
        "requested_at": utcnow().isoformat(),
    })
    return {"scan_id": scan_id, "status": "accepted", "eta_seconds": 120}

@app.get("/v1/scan/{scan_id}/status")
async def get_scan_status(scan_id: str, claims: dict = Depends(verify_token)) -> dict:
    run = await db.fetchrow("SELECT * FROM scan_runs WHERE scan_id = $1", scan_id)
    if not run:
        raise HTTPException(status_code=404, detail="Scan not found")
    findings_count = await db.fetchval("SELECT count(*) FROM findings WHERE scan_id = $1", scan_id)
    return {
        "scan_id": run["scan_id"],
        "status": run["status"],
        "started_at": run["started_at"],
        "finished_at": run["finished_at"],
        "findings_count": findings_count,
        "domain": run["domain"],
    }
```

**HTTP-level rate limiting in Kong**:

```bash
# Enable rate-limiting plugin on the /v1/scan route
curl -i -X POST http://localhost:8001/services/security-gateway/routes \
  --data "paths[]=/v1/scan" \
  --data "service.id=<uuid>"

curl -i -X POST http://localhost:8001/routes/<route-id>/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=10" \
  --data "config.policy=local"
```

---

## 7. Authentication and Authorization for Services

Each microservice authenticates requests using mTLS or JWTs. Use a shared OPA (Open Policy Agent) for centralized authorization decisions.

**mTLS in Kubernetes**:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secrets
type: kubernetes.io/tls
data:
  tls.crt: <base64 cert>
  tls.key: <base64 key>
---
# Service enforces client cert verification
apiVersion: v1
kind: ConfigMap
metadata:
  name: service-config
data:
  TLS_CERT_FILE: "/etc/tls/tls.crt"
  TLS_KEY_FILE: "/etc/tls/tls.key"
  TLS_CA_FILE: "/etc/tls/ca.crt"
  REQUIRE_CLIENT_CERT: "true"
```

**OPA Rego policy for scan authorization**:

```rego
package security.scan

default allow = false

allow {
    input.method = "POST"
    input.path = ["v1", "scan"]
    input.claims.scopes[_] = "scan:write"
}

allow {
    input.method = "GET"
    regex.match("^/v1/scan/[^/]+/status$", concat("/", input.path))
    input.claims.scopes[_] = "scan:read"
}
```

**OPA sidecar integration**:

```python
import httpx

OPA_URL = "http://localhost:8181/v1/data/security/scan/allow"

async def check_authorization(input_data: dict) -> bool:
    async with httpx.AsyncClient() as client:
        resp = await client.post(OPA_URL, json={"input": input_data})
        result = resp.json()
        return result.get("result", False)
```

---

## 8. Service Mesh — Istio for Internal Traffic

At enterprise scale, service-to-service communication needs mTLS, traffic shaping, circuit breaking, and observability without modifying application code. A service mesh (Istio, Linkerd) injects a sidecar proxy into each pod that handles these concerns.

**Istio sidecar injection**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: security-scan
  labels:
    istio-injection: enabled
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scan-service
  namespace: security-scan
spec:
  replicas: 5
  selector:
    matchLabels:
      app: scan-service
  template:
    metadata:
      labels:
        app: scan-service
        version: v3
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
        - name: scan
          image: registry.example.com/scan-service:v3.1.0
          ports:
            - containerPort: 8080
          env:
            - name: REDIS_URL
              value: "redis://redis.security-scan.svc.cluster.local:6379"
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: scan-service-secrets
                  key: database-url
```

**Istio PeerAuthentication — enforce mTLS within the mesh**.

```yaml
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: security-scan
spec:
  mtls:
    mode: STRICT  # All in-mesh traffic must use mTLS
```

**Istio DestinationRule — circuit breaker on scan service**.

```yaml
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: scan-service
  namespace: security-scan
spec:
  host: scan-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 50
      http:
        h2UpgradePolicy: UPGRADE
        http1MaxPendingRequests: 25
        http2MaxRequests: 100
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
```

---

## 9. Distributed Tracing and Observability

Every event in a distributed scan must carry a trace ID so you can reconstruct the end-to-end path across services.

**Propagate trace context with W3C Trace Context headers**:

```python
import httpx
from opentelemetry import trace
from opentelemetry.propagate import inject

tracer = trace.get_tracer("security.automation")

async def publish_asset_discovered(asset: dict) -> None:
    headers = {}
    inject(headers)  # Injects traceparent, tracestate per W3C spec
    async with httpx.AsyncClient() as client:
        await client.post(
            "http://discover-service.internal/v1/assets",
            json=asset,
            headers=headers,
            timeout=5,
        )
```

**Instrumentation with OpenTelemetry**:

```python
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor

provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter(endpoint=os.environ["OTEL_EXPORTER_OTLP_ENDPOINT"]))
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

# Auto-instrument httpx to propagate trace context
HTTPXClientInstrumentor().instrument()
```

**Jaeger UI query**:

```bash
# Query trace by scan_id in Jaeger
curl "http://jaeger:16686/api/traces?service=scan-service&tags=%7B%22scan_id%22%3A%22abc-123%22%7D&lookback=2h&limit=20" | jq .
```

---

## 10. Tenancy and Multi-Tenancy

Enterprise environments serve multiple teams (Red Team, Blue Team, Compliance). Isolation is mandatory.

**Schema-level tenancy in PostgreSQL**.

```sql
CREATE TABLE tenants (
    tenant_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    api_key     TEXT NOT NULL UNIQUE,
    max_concurrent_scans INT DEFAULT 5,
    allowed_targets      TEXT[] DEFAULT '{}',
    created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE scan_runs (
    ...
    tenant_id    UUID NOT NULL REFERENCES tenants(tenant_id),
    ...
);

-- Row Level Security (RLS)
ALTER TABLE scan_runs ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON scan_runs
    FOR ALL
    TO application_role
    USING (tenant_id = current_setting('app.current_tenant')::UUID);
```

**Setting tenant context per request**:

```python
@app.post("/v1/scan")
async def start_scan(req: ScanRequest, claims: dict = Depends(verify_token)):
    tenant_id = claims.get("tenant_id")
    if not tenant_id:
        raise HTTPException(status_code=401)
    # Set RLS context for the duration of this request
    async with db.acquire() as conn:
        await conn.execute(
            "SELECT set_config('app.current_tenant', $1, true)",
            str(tenant_id),
        )
        scan_id = await conn.fetchrow(
            "INSERT INTO scan_runs(tenant_id, domain, scheduled_at) VALUES ($1, $2, now()) RETURNING scan_id",
            tenant_id, str(req.target),
        )
    return {"scan_id": str(scan_id["scan_id"])}
```

---

## 11. Enterprise Scale — Rate Limiting and Cost Allocation

At 10k scans/day, aggregate cost tracking and per-team rate limiting are non-negotiable.

**Redis sliding window per-team rate limiter**:

```python
import time
import redis.asyncio as redis

RATE_LIMIT_WINDOW = 3600  # 1 hour

async def enforce_team_rate_limit(
    team_id: str,
    max_requests: int,
    redis_client: redis.Redis,
) -> None:
    key = f"rate:team:{team_id}"
    now_ms = int(time.time() * 1000)
    pipe = redis_client.pipeline()
    pipe.zadd(key, {str(now_ms): now_ms})
    pipe.zremrangebyscore(key, "-inf", now_ms - (RATE_LIMIT_WINDOW * 1000))
    pipe.zcard(key)
    pipe.expire(key, RATE_LIMIT_WINDOW)
    _, _, count, _ = await pipe.execute()
    if count > max_requests:
        raise RateLimitError(
            f"Team {team_id} exceeded rate limit: {count}/{max_requests} requests in last hour"
        )
```

**Per-scan cost tracking in PostgreSQL**:

```sql
CREATE TABLE scan_runs (
    ...
    estimated_cost_usd NUMERIC(10,4) DEFAULT 0,
    actual_cost_usd    NUMERIC(10,4),
    billed_to_tenant   UUID REFERENCES tenants(tenant_id)
);

-- Monthly cost summary by tenant
SELECT
    t.name,
    COUNT(s.scan_id)                as scan_count,
    SUM(s.estimated_cost_usd)       as total_estimated_usd,
    SUM(s.actual_cost_usd)          as total_actual_usd,
    DATE_TRUNC('month', s.scheduled_at) as billing_month
FROM scan_runs s
JOIN tenants t ON s.billed_to_tenant = t.tenant_id
WHERE s.scheduled_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
GROUP BY t.name, billing_month
ORDER BY total_estimated_usd DESC;
```

---

## 12. Progressive Enhancement Patterns

A platform that starts as cron jobs can gradually add sophistication. Here is how to add each layer without rewriting.

**Level 0 → 1: Wrap scripts in Prefect**.

```python
# Existing: scripts/run_scan.py (CLI)
# Wrap:
from prefect import flow
import subprocess

@flow(name="run_scan")
def run_scan_flow(domain: str, scan_types: str):
    cmd = ["python", "scripts/run_scan.py", "--domain", domain, "--types", scan_types]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr)
    return result.stdout
```

**Level 1 → 2: Replace direct subprocess calls with message queues**.

```python
# Old: direct subprocess call
result = subprocess.run(["nuclei", "-l", targets], check=True)

# New: send to URL queue, let Scan Service pick it up
await producer.send("scan.jobs", {
    "scan_id": scan_id,
    "tool": "nuclei",
    "targets": targets,
    "requested_at": utcnow().isoformat(),
})
```

**Level 2 → 3: Add API Gateway and multi-team tenancy**.

```python
# Before: CLI invoked directly
# After: call through internal API gateway that enforces JWT + tenant_id
async with httpx.AsyncClient() as client:
    resp = await client.post(
        GATEWAY_URL + "/v1/scan",
        headers={"Authorization": f"Bearer {service_token}"},
        json={"target": domain, "scan_types": ["nuclei"]},
    )
    scan_id = resp.json()["scan_id"]
```

---

## 13. Health Checks and Readiness Probes

Each microservice must expose an HTTP health endpoint. Kubernetes and service meshes use these for routing decisions.

**Health endpoint implementation**:

```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class HealthResponse(BaseModel):
    status: str
    version: str
    checks: dict

@app.get("/healthz", response_model=HealthResponse)
async def healthz():
    # Non-fatal background checks
    checks = {}

    try:
        pong = await redis_client.ping()
        checks["redis"] = "ok" if pong else "failed"
    except Exception as e:
        checks["redis"] = f"error: {e}"

    try:
        result = await db.fetchval("SELECT 1")
        checks["postgres"] = "ok" if result == 1 else "failed"
    except Exception as e:
        checks["postgres"] = f"error: {e}"

    overall = "healthy" if all(v == "ok" for v in checks.values()) else "degraded"
    return HealthResponse(status=overall, version=os.environ["APP_VERSION"], checks=checks)
```

**Kubernetes probes**:

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 15
  failureThreshold: 3
readinessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 2
startupProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 5
  failureThreshold: 60  # 5 minutes to start up
```

---

## 14. Graceful Shutdown and Request Draining

Services must handle SIGTERM (from Kubernetes pod deletion or Docker stop) without losing in-flight scan results.

```python
import asyncio
import signal
from contextlib import asynccontextmanager

shutdown_event = asyncio.Event()

def handle_sigterm(*args):
    logger.info("SIGTERM received — draining in-flight requests")
    shutdown_event.set()

signal.signal(signal.SIGTERM, handle_sigterm)
signal.signal(signal.SIGINT,  handle_sigterm)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await redis_client.initialize()
    await db.connect()
    yield
    # Shutdown
    await drain_in_flight()
    await redis_client.close()
    await db.disconnect()
    logger.info("service shut down cleanly")

async def drain_in_flight() -> None:
    MAX_WAIT = 30
    start = asyncio.get_event_loop().time()
    while active_requests > 0 and (asyncio.get_event_loop().time() - start) < MAX_WAIT:
        await asyncio.sleep(0.5)
    if active_requests > 0:
        logger.warning("shutdown with in-flight requests remaining", extra={"count": active_requests})
```

Kubernetes `preStop` hook for DNS propagation:

```yaml
lifecycle:
  preStop:
    exec:
      command: ["/bin/sh", "-c", "sleep 10"]
```

---

## 15. Multi-Architecture Image Builds for Microservices

Each service produces its own image. Version and push with the same buildx pattern from Container Automation, extended to multiple services.

**Build all services in a monorepo**:

```bash
#!/usr/bin/env bash
set -euo pipefail
REGISTRY="registry.example.com"
TAG="${1:-latest}"

SERVICES=("api-gateway" "discover-service" "scan-service" "report-service" "notify-service")

for svc in "${SERVICES[@]}"; do
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag "${REGISTRY}/${svc}:${TAG}" \
        --push \
        --provenance=true \
        --sbom=true \
        "services/${svc}/"
done
```

**CI: build and promote per-service on change**:

```yaml
name: Build microservice images
on:
  push:
    paths: ["services/**", "src/**"]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [api-gateway, discover-service, scan-service, report-service, notify-service]
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: registry.example.com
          username: ${{ secrets.REGISTRY_USER }}
          password: ${{ secrets.REGISTRY_PASS }}
      - uses: docker/build-push-action@v6
        with:
          context: services/${{ matrix.service }}
          tags: registry.example.com/${{ matrix.service }}:${{ github.sha }}
          platforms: linux/amd64,linux/arm64
          push: true
          cache-from: type=registry,ref=registry.example.com/${{ matrix.service }}:buildcache
          cache-to: type=registry,ref=registry.example.com/${{ matrix.service }}:buildcache,mode=max
          provenance: true
          sbom: true
```

---

## 16. Feature Flags and Progressive Rollout

Roll out new service versions to a subset of traffic using service mesh traffic splitting or API gateway canary routing.

**Istio VirtualService — 10% canary for new scan service**:

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: scan-service
  namespace: security-scan
spec:
  hosts: ["scan-service"]
  http:
    - route:
        - destination:
            host: scan-service
            subset: stable
          weight: 90
        - destination:
            host: scan-service
            subset: canary
          weight: 10
      timeout: 3600s
      retries:
        attempts: 3
        perTryTimeout: 30s
        retryOn: 5xx,connect-failure,refused-stream
```

**Feature flag with LaunchDarkly or Flagsmith for scanner capabilities**:

```python
import flagsmith

flagsmith_client = flagsmith.Flagsmith(environment_key=FLAGSMITH_KEY)

def should_run_nuclei_ai_scan(tenant_id: str) -> bool:
    return flagsmith_client.has_feature("use_nuclei_ai_template", tenant_id=tenant_id)

@app.post("/v1/scan")
async def start_scan(req: ScanRequest, claims: dict = Depends(verify_token)):
    scan_types = list(req.scan_types)
    if "nuclei-auto" in scan_types and not should_run_nuclei_ai_scan(claims["tenant_id"]):
        scan_types.remove("nuclei-auto")
    ...
```

---

## 17. Chaos Engineering and Resilience Testing

Test that individual service failures do not cascade. Use chaos engineering (Chaos Monkey, Gremlin, or manual) to intentionally inject failures.

**Kubernetes pod kill with Chaos Monkey**:

```yaml
# chaos-experiment.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: scan-service-pod-failure
  namespace: security-scan
spec:
  action: pod-kill
  mode: one
  duration: "30s"
  selector:
    namespaces:
      - security-scan
    labelSelectors:
      app: scan-service
  scheduler:
    cron: "@every 4h"
```

**Validate system resilience via integration test**:

```python
import pytest
import httpx

@pytest.mark.integration
async def test_scan_survives_discover_service_outage():
    """Verify Scan Service can replay pending messages when Discover recovers."""
    # Simulate Discover outage by stopping Redis for 10s
    await kill_discover_service()

    # Publish messages during outage
    await redis_client.xadd("asset.discovered", {"data": json.dumps({"host": "test.com"})})
    await asyncio.sleep(2)

    # Restart Discover
    await start_discover_service()
    await asyncio.sleep(15)  # Allow idle consumer group to replay

    # Check all messages were processed
    count = await redis_client.xlen("scan.completed")
    assert count >= 1, "Messages were lost during service outage"
```

---

## 18. Enterprise Considerations

### 18.1 Audit Logging for Compliance

Log every scan request, authorization decision, and result access to an append-only audit store. Use PostgreSQL with `pgaudit` or export to an immutable S3 bucket with WORM (Write Once Read Many) policies.

```sql
CREATE TABLE audit_log (
    audit_id     BIGSERIAL PRIMARY KEY,
    timestamp    TIMESTAMPTZ NOT NULL DEFAULT now(),
    actor        TEXT NOT NULL,
    action       TEXT NOT NULL,
    resource     TEXT NOT NULL,
    resource_id  TEXT,
    ip_address   INET,
    user_agent   TEXT,
    outcome      TEXT NOT NULL,
    error        TEXT,
    correlation_id UUID
);

CREATE INDEX idx_audit_timestamp ON audit_log(timestamp DESC);
CREATE INDEX idx_audit_correlation ON audit_log(correlation_id);
```

**Emit audit events from the gateway**:

```python
async def audit_log(conn, actor: str, action: str, resource: str, outcome: str, **kwargs):
    await conn.execute(
        """INSERT INTO audit_log (actor, action, resource, outcome, correlation_id, ip_address)
           VALUES ($1, $2, $3, $4, $5, $6)""",
        actor, action, resource, outcome, kwargs.get("correlation_id"), kwargs.get("ip_address"),
    )
```

### 18.2 Horizontal Pod Autoscaling (HPA)

Scale scan workers based on queue depth, not CPU. Use KEDA (Kubernetes Event-Driven Autoscaling).

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: scan-service-scaler
  namespace: security-scan
spec:
  scaleTargetRef:
    name: scan-service
  minReplicaCount: 2
  maxReplicaCount: 50
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus:9090
        metricName: scan_jobs_pending
        threshold: "10"
        query: sum(kafka_consumergroup_lag{topic="asset.discovered", group="scan-service"})
```

### 18.3 Cross-Origin Isolation for Reporting UI

If the platform exposes a web UI for report review, set COOP/COEP headers to enable `SharedArrayBuffer` for advanced WASM-based PDF generation.

```python
@app.get("/reports/{scan_id}")
async def get_report(scan_id: str):
    response = HTMLResponse(content=report_html)
    response.headers["Cross-Origin-Opener-Policy"] = "same-origin"
    response.headers["Cross-Origin-Embedder-Policy"] = "require-corp"
    response.headers["Cross-Origin-Resource-Policy"] = "cross-origin"
    return response
```

### 18.4 Cost Anomaly Detection at Platform Level

Aggregate platform costs using CloudWatch / GCP Billing / Azure Cost Management. Alert when total daily cost exceeds 3σ from the 14-day rolling mean.

```python
def rolling_cost_anomaly(cost_data: list[float], window: int = 14) -> bool:
    """Return True if today's cost is more than 3 standard deviations above the mean."""
    recent = cost_data[-window:]
    mean = sum(recent) / len(recent)
    variance = sum((c - mean) ** 2 for c in recent) / len(recent)
    std = variance ** 0.5
    today = cost_data[-1]
    return today > (mean + 3 * std)
```

### 18.5 High Availability Deployment Topology

```
              ┌───────────────────┐
              │   External DNS    │
              └────────┬──────────┘
                        │
              ┌─────────▼─────────┐
              │   Load Balancer   │  ← AWS NLB / GCP L7 LB
              └─────────┬─────────┘
                        │
               ┌────────▼────────┐
               │   API Gateway   │  ← 3 replicas
               └────────┬────────┘
                        │
         ┌──────────────┼──────────────┐
         │              │              │
    ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
    │Discover │   │ Scan    │   │ Report  │
    │Service  │   │ Service │   │ Service │
    │  (3x)   │   │ (5x)    │   │  (2x)   │
    └────┬────┘   └────┬────┘   └────┬────┘
         │              │              │
         └──────────────┼──────────────┘
                        │
              ┌─────────▼─────────┐
              │  Redis Cluster    │  3 masters, 3 replicas
              │  (6-node cluster) │
              └───────────────────┘
                        │
              ┌─────────▼─────────┐
              │  Kafka Cluster    │  3 brokers, replication factor 3
              └───────────────────┘
                        │
              ┌─────────▼─────────┐
              │  PostgreSQL       │  Primary + 2 standbys + Patroni
              │  (with pgBouncer) │
              └───────────────────┘
                        │
              ┌─────────▼─────────┐
              │  S3 / GCS Bucket  │  Multi-region, versioned, WORM
              └───────────────────┘
```

---

## 19. Reference

- [Prefect Documentation](https://docs.prefect.io/)
- [Temporal Documentation](https://docs.temporal.io/)
- [Redis Streams Reference](https://redis.io/docs/latest/develop/interact/streams/)
- [Istio Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/)
- [KEDA Scalers](https://keda.sh/docs/latest/scalers/)
- [NFD / OpenTelemetry Pipelines](https://opentelemetry.io/docs/collector/)
- [Database Sizing for Python](https://docs.sqlalchemy.org/en/20/orm/session_basics.html) — ORM patterns for multi-tenant data models
