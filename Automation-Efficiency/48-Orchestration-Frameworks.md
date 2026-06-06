# 48 — Orchestration Frameworks

## Scope

Orchestration frameworks (Prefect, Temporal, Airflow) convert ad-hoc scripts into production-grade pipelines. This file covers Prefect 3 flows and blocks, Temporal workflows and activities, Airflow DAG design for multi-phase recon, retry and timeout policies, event-driven triggers, cron patterns, and monitoring integrations. The goal is to give concrete, drop-in code examples for each framework, not just a feature list.

---

## 1. Why Orchestrate Security Automation

A security scan is never a single command: discover subdomains → probe HTTP → run vulnerability scanner → normalize results → deduplicate → alert → generate report. Without orchestration each step is scripted independently, failures are not retried, state is lost on crash, and running 50 concurrent targets is manual work. Orchestration provides:

- **DAG-based task graphs** — explicit dependencies.
- **Retries and timeouts** — handled at framework level, not in tooling.
- **State persistence** — resume from the last successful task after a crash.
- **Backfilling** — re-run failed scans for a past date range.
- **Monitoring** — built-in UI shows task timeline, failures, retry count.
- **Event-driven triggering** — GitHub webhook or PagerDuty alert starts a new scan automatically.

---

## 2. Prefect 3 — Modern Python Orchestration

Prefect 3 is a Python-native orchestration framework with a clean imperative API, built-in retries, and result persistence. It is the best fit for teams already writing Python automation.

**Minimal flow — two-step pipeline**.

```python
from prefect import flow, task
from prefect.artifacts import create_markdown_artifact
import httpx
import subprocess
import json

PROXY_SAFELIST = {
    "example.com",
    "target.com",
}

@task(retries=3, retry_delay_seconds=[1, 5, 15], timeout=120)
def enumerate_subdomains(domain: str) -> list[dict]:
    result = subprocess.run(
        ["subfinder", "-d", domain, "-oJ", "-silent"],
        capture_output=True, text=True, timeout=60,
    )
    return [json.loads(line) for line in result.stdout.splitlines() if line.strip()]

@task(retries=2, retry_delay_seconds=10, timeout=300)
def probe_http(subdomains: list[dict]) -> list[dict]:
    urls = [f"https://{s['host']}" for s in subdomains]
    results = []
    async with httpx.AsyncClient(follow_redirects=True, timeout=10) as client:
        for url in urls:
            host = httpx.URL(url).host
            if host not in PROXY_SAFELIST:
                continue
            try:
                r = await client.get(url)
                results.append({"url": url, "status": r.status_code, "title": r.text[:80]})
            except httpx.HTTPError:
                pass
    return results

@flow(name="subdomain-to-live-hosts", retries=1)
def recon_flow(domain: str):
    subdomains = enumerate_subdomains(domain)
    live = probe_http(subdomains)

    create_markdown_artifact(
        key=f"recon-result-{domain}",
        markdown=f"# Recon: {domain}\n\nFound **{len(subdomains)}** subdomains, **{len(live)}** live hosts.",
    )
    return {"subdomains": subdomains, "live_hosts": live}

if __name__ == "__main__":
    recon_flow("example.com")
```

**Prefect Blocks for reusable configuration**.

Blocks are typed config objects stored in Prefect Cloud (or SQLite for local). Create a single block that wraps `nuclei` invocation and reuse it across flows.

```python
from prefect.blocks.system import Secret
from pydantic import BaseModel
from prefect.blocks.core import Block

class NucleiConfig(BaseModel):
    image: str = "registry.example.com/nuclei:v3.3.4"
    templates_path: str = "/templates"
    rate_limit: int = 150
    severity: str = "critical,high,medium"

class NucleiScanner(Block):
    config: NucleiConfig

    async def scan(self, hosts_file_path: str) -> str:
        result_path = "/tmp/nuclei_results.json"
        cmd = [
            "docker", "run", "--rm",
            "-v", f"{hosts_file_path}:/hosts/hosts.json:ro",
            "-v", f"{result_path}:/results.json",
            "-v", "/templates:/templates",
            self.config.image,
            "-l", "/hosts/hosts.json",
            "-json", "-o", "/results.json",
            "-severity", self.config.severity,
            "-rate-limit", str(self.config.rate_limit),
        ]
        subprocess.run(cmd, check=True, timeout=900)
        return result_path

# Use the block
scanner = NucleiScanner(config=NucleiConfig(rate_limit=200))
result_path = await scanner.scan("/tmp/hosts.json")
```

**Mapping objects for validating task inputs (Pydantic-integrated)**:

```python
from prefect.utilities.mapping import ensure_protected_substrings
from pydantic import BaseModel, Field, field_validator

class SubdomainResult(BaseModel):
    host: str
    ip: str
    source: str

    @field_validator("host")
    @classmethod
    def host_must_be_domain(cls, v):
        if not all(part.isalnum() or part == "-" for part in v.split(".")):
            raise ValueError("Invalid hostname")
        return v

@task
def parse_subfinder(line: str) -> SubdomainResult:
    data = json.loads(line)
    return SubdomainResult(**data)
```

**Concurrent task mapping — fan out**.

```python
from prefect.task_runners import ThreadPoolTaskRunner

@flow(task_runner=ThreadPoolTaskRunner(max_workers=8))
def parallel_scan(targets: list[str]):
    results = enumerate_subdomains.map(targets)
    live = probe_http.map(results)
    return {"results": results, "live": live}
```

---

## 3. Temporal Workflows

Temporal provides durable execution guarantees with a mental model of workflows (deterministic orchestration code) and activities (imperative, can fail, can be retried). Choose Temporal when you need **exactly-once** semantics, long-running multiphase scans (hours), or human-in-the-loop approvals.

**Workflow definition (Python — `temporalio` SDK)**.

```python
from datetime import timedelta
from temporalio import workflow
from temporalio.common import RetryPolicy
from temporalio.exceptions import ApplicationError

RETRY_POLICY = RetryPolicy(
    initial_interval=timedelta(seconds=1),
    maximum_interval=timedelta(minutes=1),
    backoff_coefficient=2.0,
    maximum_attempts=5,
    non_retryable_error_types=["ValueError"],
)

@workflow.defn
class ReconWorkflow:
    @workflow.run
    async def run(self, domain: str) -> dict:
        subdomains = await workflow.execute_activity(
            enumerate_subdomains_activity,
            domain,
            start_to_close_timeout=timedelta(minutes=5),
            retry_policy=RETRY_POLICY,
        )
        live = await workflow.execute_activity(
            probe_http_activity,
            subdomains,
            start_to_close_timeout=timedelta(minutes=10),
            retry_policy=RETRY_POLICY,
            heartbeat_timeout=timedelta(seconds=30),
        )
        scan_result = await workflow.execute_activity(
            nuclei_scan_activity,
            live,
            start_to_close_timeout=timedelta(hours=2),
            retry_policy=RETRY_POLICY,
            heartbeat_timeout=timedelta(minutes=2),
        )
        await workflow.execute_activity(
            publish_results_activity,
            scan_result,
            start_to_close_timeout=timedelta(minutes=2),
        )
        return {"status": "complete", "findings": len(scan_result)}
```

**Activities — the executable unit (run outside workflow determinism boundary)**.

```python
from temporalio import activity
import subprocess
import json
import httpx

@activity.defn
async def enumerate_subdomains_activity(domain: str) -> list[str]:
    result = subprocess.run(
        ["subfinder", "-d", domain, "-silent"],
        capture_output=True, text=True, timeout=60,
    )
    if result.returncode != 0:
        raise ApplicationError(f"subfinder failed: {result.stderr}", non_retryable=True)
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

@activity.defn
async def probe_http_activity(subdomains: list[str]) -> list[dict]:
    urls = [f"https://{s}/" for s in subdomains]
    SAFELIST = {"example.com", "target.com"}
    live = []
    async with httpx.AsyncClient(follow_redirects=True, timeout=8) as client:
        for url in urls:
            host = httpx.URL(url).host
            if host not in SAFELIST:
                continue
            try:
                r = await client.get(url)
                live.append({"url": str(r.url), "status": r.status_code})
            except httpx.HTTPError:
                pass
    return live

@activity.defn
async def nuclei_scan_activity(live_hosts: list[dict]) -> list[dict]:
    hosts_path = "/tmp/hosts.json"
    with open(hosts_path, "w") as f:
        json.dump([h["url"] for h in live_hosts], f)
    result = subprocess.run(
        ["nuclei", "-l", hosts_path, "-json",
         "-o", "/tmp/nuclei.json", "-severity", "critical,high,medium",
         "-rate-limit", "150"],
        capture_output=True, text=True, timeout=3600,
    )
    if result.returncode != 0 and not Path("/tmp/nuclei.json").exists():
        raise RuntimeError(f"nuclei failed: {result.stderr}")
    with open("/tmp/nuclei.json") as f:
        return [json.loads(line) for line in f]

@activity.defn
async def publish_results_activity(findings: list[dict]) -> None:
    # Send to SIEM, Slack, S3, etc.
    import boto3
    s3 = boto3.client("s3")
    key = f"results/{activity.info().workflow_id}.json"
    s3.put_object(Bucket="scan-results", Key=key, Body=json.dumps(findings))
```

**Worker entrypoint**:

```python
import asyncio
from temporalio.worker import Worker
from temporalio.client import Client

async def main():
    client = await Client.connect("temporal:7233")
    worker = Worker(
        client,
        task_queue="recon-queue",
        workflows=[ReconWorkflow],
        activities=[
            enumerate_subdomains_activity,
            probe_http_activity,
            nuclei_scan_activity,
            publish_results_activity,
        ],
    )
    await worker.run()

if __name__ == "__main__":
    asyncio.run(main())
```

**Signalling a running workflow (human approval gate)**:

```python
@workflow.defn
class ApprovedScanWorkflow:
    def __init__(self):
        self._approval_event = asyncio.Event()

    @workflow.run
    async def run(self, domain: str) -> dict:
        subdomains = await self._enumerate(domain)
        await workflow.wait_condition(lambda: self._approval_event.is_set(), timeout=timedelta(hours=24))
        live = await self._probe(subdomains)
        return await self._scan(live)

    @workflow.signal
    async def approve(self):
        self._approval_event.set()
```

---

## 4. Airflow DAG Design for Recon Phases

Apache Airflow is the most mature option for scheduled, time-based pipelines. Prefer Airflow for environments that already use it (enterprise security teams) or when you need calendar-based schedules and rich integration with enterprise tooling.

**DAG design principles**:
- Each task is atomic (one tool, one output).
- Tasks share state via XComs or external storage (S3, not XCom for large payloads).
- Use `@task` decorator (TaskFlow API) — no `PythonOperator` boilerplate.
- Set `pool` to limit concurrency per tool.
- Schedule only the root task; downstream tasks are dependent.

**`dags/recon_pipeline.py`**:

```python
from datetime import datetime, timedelta
from airflow.decorators import dag, task
from airflow.utils.trigger_rule import TriggerRule
from airflow.models import Variable

DOMAINS = Variable.get("scan_targets", deserialize_json=True)
RESULTS_BUCKET = Variable.get("results_bucket", default_var="scan-results-bucket")
NOTIFY_SLACK_WEBHOOK = Variable.get("slack_webhook")

default_args = {
    "owner": "security-automation",
    "depends_on_past": False,
    "email_on_failure": True,
    "email": ["sec-alerts@company.com"],
    "retries": 2,
    "retry_delay": timedelta(minutes=3),
    "execution_timeout": timedelta(hours=4),
}

@dag(
    dag_id="daily_external_recon",
    start_date=datetime(2025, 1, 1),
    schedule_interval="0 2 * * *",
    catchup=False,
    default_args=default_args,
    tags=["recon", "security"],
)
def recon_pipeline():
    @task(pool="network-scans", queue="high")
    def enumerate_subdomains(domain: str) -> list[dict]:
        import subprocess, json
        result = subprocess.run(
            ["subfinder", "-d", domain, "-oJ", "-silent"],
            capture_output=True, text=True, timeout=120,
        )
        return [json.loads(l) for l in result.stdout.splitlines() if l.strip()]

    @task(pool="http-probes", trigger_rule=TriggerRule.ALL_DONE, retries=3)
    def probe_http(subdomains: list[dict]) -> list[dict]:
        import httpx, asyncio
        urls = [f"https://{s['host']}/" for s in subdomains]
        SAFELIST = {"example.com", "target.com"}
        async def main():
            live = []
            async with httpx.AsyncClient(follow_redirects=True, timeout=8) as client:
                for url in urls:
                    host = httpx.URL(url).host
                    if host not in SAFELIST:
                        continue
                    try:
                        r = await client.get(url)
                        live.append({"url": str(r.url), "status": r.status_code, "title": r.text[:80]})
                    except httpx.HTTPError:
                        pass
            return live
        return asyncio.run(main())

    @task(pool="vuln-scans")
    def run_nuclei(live_hosts: list[dict]) -> str:
        import json, subprocess, uuid
        hosts_path = f"/tmp/hosts_{uuid.uuid4().hex}.json"
        with open(hosts_path, "w") as f:
            json.dump([h["url"] for h in live_hosts], f)
        out_path = f"/tmp/nuclei_{uuid.uuid4().hex}.json"
        subprocess.run([
            "nuclei", "-l", hosts_path, "-json", "-o", out_path,
            "-severity", "critical,high,medium", "-rate-limit", "150",
        ], check=True, timeout=3600)
        return out_path

    @task(pool="reporting", trigger_rule=TriggerRule.ALL_DONE)
    def upload_results(nuclei_path: str, domain: str) -> str:
        import boto3
        s3 = boto3.client("s3")
        key = f"daily/{domain}/{datetime.utcnow().strftime('%Y%m%d')}/nuclei.json"
        with open(nuclei_path, "rb") as f:
            s3.upload_fileobj(f, RESULTS_BUCKET, key)
        return key

    @task(trigger_rule=TriggerRule.ONE_SUCCESS)
    def notify_slack(key: str, domain: str):
        import requests
        message = f":white_check_mark: Recon complete for *{domain}*. Results: s3://{RESULTS_BUCKET}/{key}"
        requests.post(NOTIFY_SLACK_WEBHOOK, json={"text": message}, timeout=10)

    # Fan-out over domains
    subdomain_results = enumerate_subdomains.expand(domain=DOMAINS)
    live_results = probe_http.expand(subdomains=subdomain_results)
    nuclei_paths  = run_nuclei.expand(live_hosts=live_results)
    result_keys   = upload_results.expand(nuclei_path=nuclei_paths, domain=DOMAINS)
    notify_slack.expand(key=result_keys, domain=DOMAINS)

recon_dag = recon_pipeline()
```

**Pools to limit expensive tool concurrency**:

```python
from airflow.models.pool import Pool

# Managed via UI or CLI, equivalent Python:
# in airflow db shell
# Pool.create_or_update_pool("vuln-scans", slots=4, description="Limits nuclei concurrency")
# Pool.create_or_update_pool("network-scans", slots=10, description="subfinder, ammass concurrency")
```

---

## 5. Retry Policies and Circuit Breakers

Different tools have different retry semantics. Nuclei failing once is likely transient (rate limit) — retry. Subfinder returning no results for a valid domain means `subfinder` has an issue — alert, do not silently retry.

| Tool          | Retries | Backoff       | Timeout  | Non-retryable signals            |
|---------------|---------|---------------|----------|----------------------------------|
| subfinder     | 2       | Exponential   | 120 s    | `no subdomains found`            |
| httpx         | 2       | Fixed 5s      | 10 s/URL | HTTP 4xx on valid host           |
| nuclei        | 3       | Exponential   | 900 s    | `nuclei: error: unknown flag`    |
| amass         | 1       | Fixed         | 600 s    | process exit 2 (config error)    |

**Temporal Activity retry with non-retryable classification**:

```python
class ScannerException(Exception):
    def __init__(self, message: str, retryable: bool = True):
        super().__init__(message)
        self.retryable = retryable

class NoResultsError(ScannerException):
    def __init__(self):
        super().__init__("Scanner returned no results", retryable=False)

class RateLimitError(ScannerException):
    def __init__(self):
        super().__init__("Rate limited", retryable=True)

# In the activity:
@activity.defn
async def scan_with_policy(targets: list[str]) -> list[dict]:
    results = do_scan(targets)
    if not results:
        raise NoResultsError()  # Won't retry
    return results

# The retry policy in workflow:
retry_policy = RetryPolicy(
    initial_interval=timedelta(seconds=1),
    maximum_interval=timedelta(minutes=2),
    backoff_coefficient=2.0,
    maximum_attempts=5,
    non_retryable_error_types=["NoResultsError"],
)
```

**Prefect task-specific retry**:

```python
from prefect.task_runners import ThreadPoolTaskRunner

@task(
    retries=3,
    retry_delay_seconds=[1, 5, 15],  # Tech
    retry_on_exception_condition=lambda e: isinstance(e, httpx.TimeoutException),
    timeout=120,
)
def probe_http(subdomains: list[dict]) -> list[dict]:
    ...
```

---

## 6. Event-Driven Triggers

Traditional cron schedules scans at fixed times. Event-driven scanning reacts to changes: a new domain is added to a scope file, a GitHub repo is pushed to, a HackerOne disclosure fires, or a DNS change is detected.

**Prefect webhooks — start a flow from external events**:

```python
from fastapi import FastAPI, Request
from prefect.deployments import run_deployment
from prefect.artifacts import create_link_artifact

webhook_app = FastAPI()

WEBHOOK_SECRET = os.environ["WEBHOOK_SECRET"]

@webhook_app.post("/hooks/github-push")
async def trigger_on_push(request: Request):
    body = await request.json()
    if request.headers.get("X-Hub-Signature-256") != compute_signature(body):
        return {"status": "forbidden"}, 403

    repo = body["repository"]["full_name"]
    branch = body["ref"].replace("refs/heads/", "")
    deployment_name = f"recon-pipeline/{repo}-{branch}"

    flow_run = await run_deployment(
        name=deployment_name,
        parameters={"repo": repo, "branch": branch},
    )
    create_link_artifact(
        key=f"github-trigger-{flow_run.id}",
        link=f"https://cloud.prefect.io/flow-run/{flow_run.id}",
        description=f"Flow triggered by GitHub push to {repo}:{branch}",
    )
    return {"flow_run_id": flow_run.id}
```

**Airflow — HTTP trigger via REST API**:

```python
# aiflow/plugins/recon_trigger.py
from airflow.api.client.local_client import Client
from flask import request, jsonify

@app.route("/trigger_recon", methods=["POST"])
def trigger_recon():
    token = request.headers.get("X-Auth-Token")
    if token != os.environ["WEBHOOK_TOKEN"]:
        return jsonify({"error": "unauthorized"}), 401
    dag_id = request.json["dag_id"]
    conf   = request.json.get("conf", {})
    c = Client(None, None)
    c.trigger_dag(dag_id=dag_id, conf=conf)
    return jsonify({"status": "triggered", "dag_id": dag_id})
```

---

## 7. Notification and Workflow Observability

Every significant state change in a workflow should produce a notification or log event. Attach the Prefect run ID or Temporal workflow ID to make triage clickable.

**Prefect on-failure and on-completion hooks**:

```python
from prefect import flow
from prefect.blocks.notifications import SlackWebhook

@flow(
    on_failure=[lambda flow, flow_run, task: SlackWebhook.load("sec-alerts").notify(
        f":x: Flow *{flow.name}* failed (run: {flow_run.id})"
    )],
    on_completion=[lambda flow, flow_run: SlackWebhook.load("sec-reports").notify(
        f":white_check_mark: Flow *{flow.name}* completed (run: {flow_run.id})"
    )],
)
def recon_flow(domain: str):
    ...

    @task
    def send_daily_report(findings: list[dict]):
        ...
```

**Temporal — signal handler or child workflow completion callback**:

```python
@workflow.defn
class ReconWorkflow:
    @workflow.run
    async def run(self, domain: str):
        scan_result = await self._scan(domain)
        await workflow.execute_activity(
            slack_notify_activity,
            f"Scan complete for {domain}: {len(scan_result)} findings",
            start_to_close_timeout=timedelta(seconds=10),
        )
        return scan_result
```

---

## 8. Infrastructure-as-Code for Deployment

Orchestrator infrastructure itself is code. Use Terraform/OpenTofu to deploy Prefect workers, Temporal clusters, and Airflow on Kubernetes.

**Prefect worker on Kubernetes**:

```hcl
resource "helm_release" "prefect_worker" {
  name       = "prefect-worker"
  repository = "https://prefecthq.github.io/prefect-helm"
  chart      = "prefect-worker"
  version    = "2024.11.0"

  values = [
    <<-EOT
    server:
      connectionUrl: ${var.prefect_api_url}
    worker:
      workPool: recon-pool
      image:
        repository: registry.example.com/prefect-worker
        tag: latest
      serviceAccount:
        create: true
        name: prefect-worker-sa
    EOT
  ]

  depends_on = [kubernetes_service_account.prefect_sa]
}
```

**Temporal on Kubernetes via Helm**:

```bash
helm repo add temporalio https://temporalio.github.io/helm-charts
helm install temporal temporalio/temporal-server \
  --version 1.22.0 \
  --set server.persistence.sql.host=postgres.default.svc.cluster.local \
  --set server.persistence.sql.user=temporal \
  --set server.persistence.sql.database=temporal \
  --set server.persistence.visibility.enabled=true
```

**Airflow on Astronomer or Helm**:

```bash
helm repo add apache-airflow https://airflow.apache.org
helm install airflow apache-airflow/airflow \
  --version 1.14.0 \
  --set executor=CeleryExecutor \
  --set data.persistence.enabled=true \
  --set data.persistence.size=10Gi \
  --set webserver.defaultUser.username=admin \
  --set webserver.defaultUser.password=ch4ng3m3 \
  --set workers.replicas=4
```

---

## 9. Backfill and Catch-Up Strategies

When a scheduled scan is interrupted (infrastructure outage, CI failure), the pipeline should resume without scanning the same targets again. Use deterministic identifiers and idempotency keys.

**Airflow — skip existing runs with `LogicalDate`**:

```python
@task
def enumerate_subdomains(domain: str, logical_date: str) -> list[dict]:
    import subprocess, json
    # Include logical_date in output key so re-runs for the same date
    # overwrite rather than duplicate
    result = subprocess.run(
        ["subfinder", "-d", domain, "-oJ", "-silent"],
        capture_output=True, text=True, timeout=120,
    )
    return [...]
```

**Prefect — idempotency via flow run name**:

```python
@flow(
    name="daily_recon",
    flow_run_name="{domain}-{date}",
)
def recon_flow(domain: str, date: str):
    ...
```

**Temporal — use deterministic workflow IDs**:

```python
workflow_id = f"recon-{domain}-{datetime.utcnow().strftime('%Y%m%d')}"
client.start_workflow(ReconWorkflow.run, domain, id=workflow_id, task_queue="recon-queue")
```

---

## 10. Monitoring Metrics for Pipelines

Track the same metrics across all three frameworks. Emit to Prometheus, CloudWatch, or Datadog.

| Metric Name                        | Framework Label | Description                                  |
|------------------------------------|-----------------|----------------------------------------------|
| `recon_task_duration_seconds`      | task=subfinder  | Histogram of task durations                  |
| `recon_task_retries_total`         | task=nuclei     | Counter of retries by task name              |
| `recon_flow_runs_active`           | flow=recon      | Gauge of currently running flows             |
| `recon_task_failures_total`        | task=httpx      | Failure count by task                        |
| `recon_workflow_executions_total`  |                 | Temporal: completed workflows                |
| `recon_dag_run_duration_seconds`   | dag=recon       | Airflow: end-to-end DAG duration             |
| `recon_findings_count_total`       | severity=high   | Count of findings by severity per flow run   |

---

## 11. Framework Selection Guide

| Criterion                          | Prefect 3   | Temporal               | Airflow               |
|------------------------------------|-------------|------------------------|-----------------------|
| Language                           | Python      | Python, Go, TypeScript | Python                |
| Mental model                       | Tasks + flows | Workflows + activities | DAGs + operators      |
| State persistence                  | PostgreSQL  | Cassandra/PostgreSQL   | PostgreSQL / metadata  |
| Concurrency model                  | Async tasks  | Activity workers       | Celery / Kubernetes   |
| Long-running task support          | Yes         | Excellent               | Via deferrable ops    |
| Human-in-the-loop                   | Manual approval | Signals / queries   | ExternalTaskSensor    |
| UI                                | Cloud / OSS | Web UI (Temporal Web)  | Rich (Tree/Graph)     |
| Enterprise SLAs                    | Prefect Cloud | Self-hosted / Temporal Cloud | Astronomer |
| Best for                           | Python-first, lightweight | Durable, critical-path | Enterprise, scheduled |

**Recommendation**:

- Investigate / recon labs: **Prefect 3** — fastest to stand up, lowest boilerplate.
- Critical-path / long-running scans: **Temporal** — durability guarantees.
- Scheduled enterprise reporting: **Airflow** — if already deployed, extend; if greenfield, Prefect is likely better.
