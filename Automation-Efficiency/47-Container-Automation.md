# 47 — Container Automation

## Scope

Container automation uses Docker and Podman to package, run, and coordinate security scanning tools in isolated, reproducible environments. This file covers image building for individual scanners, Docker Compose for multi-tool stacks, volume strategies for result persistence, multi-arch builds, container security scanning, and Kubernetes Job specs for distributed campaigns.

---

## 1. Why Containers for Security Automation

Security scanners are messy: they have conflicting binary dependencies, require root-level network access (for Nmap, Masscan), generate large artefacts, and modify system state (Nmap generates `pcap` files, `subfinder` writes `~/subdomain.txt`). Containers solve these problems by:

- **Isolation**: each scanner runs in its own namespace — root in the container is not root on the host (rootless mode).
- **Reproducibility**: the same image yields the same results on any machine.
- **Ephemeral by default**: results must be explicitly persisted to survive container exit.
- **Registry distribution**: push once, pull anywhere — CI, remote workers air-gapped networks.

---

## 2. Dockerfile Patterns for Scanner Images

Scanner Dockerfiles share a common structure: base OS → runtime install → tool install → entrypoint. Prefer multi-stage builds to keep the final image small (reduces pull time in CI).

**Pattern 1 — Debian-based multi-stage (for CLIs with apt deps)**.

```dockerfile
# Stage 1: build
FROM debian:bookworm-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    golang-go gcc make git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 https://github.com/projectdiscovery/subfinder/v2.git && \
    cd subfinder/v2/cmd/subfinder && \
    go build -ldflags="-s -w" -o /build/subfinder

# Stage 2: runtime
FROM debian:bookworm-slim
COPY --from=builder /build/subfinder /usr/local/bin/subfinder
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl jq && rm -rf /var/lib/apt/lists/*

COPY config/ /etc/subfinder/

RUN subfinder -version  # warm cache

USER nobody:nogroup
ENTRYPOINT ["subfinder"]
CMD ["-d", "example.com", "-o", "/results/subdomains.json", "-oJ"]
```

**Pattern 2 — Alpine multi-stage (for pure-Go or Python tools)**.

```dockerfile
FROM golang:1.23-alpine3.20 AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /build/scanner ./cmd/scanner

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /build/scanner /usr/local/bin/scanner
RUN addgroup -g 10001 scanner && adduser -G scanner -u 10001 -D scanner
USER scanner
ENTRYPOINT ["scanner"]
```

**Pattern 3 — Python-based scanner with pinned venv**.

```dockerfile
FROM python:3.12-slim-bookworm AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim-bookworm
COPY --from=builder /install /usr/local
COPY scanner.py /app/scanner.py
WORKDIR /app
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["python", "scanner.py"]
```

**Best practices**:

- Pin all base images by digest (`debian:bookworm-slim@sha256:...`) — prevents supply-chain substitution.
- Run as non-root (`USER nobody:nogroup` or a dedicated UID/GID).
- Avoid `RUN` steps that install recommended packages — bloat.
- Use `--no-cache` and `-ldflags="-s -w"` in Go to strip symbols.
- Set `STOPSIGNAL SIGTERM` if the tool intercepts default signals.
- Add `HEALTHCHECK` for orchestration systems.

---

## 3. Volume Mounting for State Persistence

Container filesystem is ephemeral. Persist results outside the container using named volumes or bind mounts.

**Named volume — recommended for CI** (Docker manages the volume):

```bash
docker volume create scan-results

# Write results to the volume (container path /results maps to volume)
docker run --rm \
  -v scan-results:/results \
  projectdiscovery/subfinder:v2.12.0 \
  -d example.com -o /results/subdomains.json
```

**Bind mount — recommended for local development**.

```bash
docker run --rm \
  -v "$(pwd)/results:/results" \
  -v "$(pwd)/config:/etc/subfinder:ro" \
  projectdiscovery/subfinder:v2.12.0 \
  -d example.com -o /results/subdomains.json
```

**Docker Compose volume definitions**:

```yaml
volumes:
  scan-results:
  scan-config:
    driver_opts:
      type: none
      o: bind
      device: ./config/
```

**Common volume paths in automation**:

| Path            | Purpose                         | Mount Type   |
|-----------------|---------------------------------|--------------|
| `/results/*`    | Scan outputs (JSON, CSV, SARIF) | named volume |
| `/config/*`     | Tool config, API keys           | bind (read-only) |
| `/tmp/*`        | Temp files, caches              | tmpfs (in-memory) |
| `/secrets/*`    | Credential files                | secret (swarm) |

**tmpfs for sensitive in-memory scratch space**:

```bash
docker run --rm \
  -v "$(pwd)/results:/results" \
  --tmpfs /tmp:size=512m,exec,noatime \
  scanner-image
```

---

## 4. Docker Compose Orchestration for Multi-Tool Stacks

A full recon pipeline combines subdomain enumeration → HTTP probing → vulnerability scanning → reporting. Compose defines the full stack with start-order dependencies and shared volumes.

**`compose.yaml` — full recon pipeline**:

```yaml
version: "3.9"

services:
  subfinder:
    image: projectdiscovery/subfinder:v2.12.0
    volumes:
      - scan-results:/results
      - scan-config:/etc/subfinder:ro
    environment:
      - SUBFINDER_API_KEY=${SHODAN_API_KEY}
    command: >
      -d ${TARGET_DOMAIN}
      -o /results/subdomains.json
      -oJ
      -silent
    deploy:
      resources:
        limits: { cpus: "1.0", memory: 512M }
        reservations: { cpus: "0.5", memory: 256M }

  httpx:
    image: projectdiscovery/httpx:v1.6.8
    volumes:
      - scan-results:/results
    depends_on:
      subfinder:
        condition: service_completed_successfully
    command: >
      -l /results/subdomains.json
      -json -o /results/live_hosts.json
      -status-code -title -tech-detect
      -threads 200
      -rate-limit 50

  nuclei:
    image: projectdiscovery/nuclei:v3.3.4
    volumes:
      - scan-results:/results
    depends_on:
      httpx:
        condition: service_completed_successfully
    command: >
      -l /results/live_hosts.json
      -json -o /results/nuclei_results.json
      -severity critical,high,medium
      -rate-limit 150
      -bulk-size 25
    deploy:
      resources:
        limits: { cpus: "2.0", memory: 2G }

  report-generator:
    image: ghcr.io/org/scan-reporter:v3
    volumes:
      - scan-results:/results
    depends_on:
      nuclei:
        condition: service_completed_successfully
    command: >
      --input /results/nuclei_results.json
      --output /results/report.html
      --format html

volumes:
  scan-results:
  scan-config:
```

**Programmatic Compose runner (Python)**:

```python
import subprocess
import os

def run_compose_stack(target_domain: str):
    env = os.environ.copy()
    env["TARGET_DOMAIN"] = target_domain
    env["SHODAN_API_KEY"] = os.environ["SHODAN_API_KEY"]

    result = subprocess.run(
        ["docker", "compose", "up", "--abort-on-container-exit", "--exit-code-from", "nuclei"],
        env=env,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(f"Compose stack failed: {result.stderr}")
    return result.stdout
```

---

## 5. Podman — Rootless Containers

Podman runs rootless by default, removing the privilege escalation risk of the Docker daemon. Use Podman in compliance-restricted environments and hardened CI runners.

**Key differences from Docker**:

- No daemon process — containers are child processes of the invoking user.
- Pods are analogous to Docker Compose projects (a group of containers sharing network/storage).
- Rootless `podman run` requires a user namespace mapping (`/etc/subuid`, `/etc/subgid`).

**Podmanfile equivalent**:

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y curl jq nmap
RUN groupadd -r scanner && useradd -r -g scanner scanner
COPY --chown=scanner:scanner ./scanner /app/scanner.py
USER scanner
ENTRYPOINT ["python", "/app/scanner.py"]
```

**Rootless volume mounts in Podman**:

```bash
# --volume works identically
podman run --rm \
  -v ./results:/results \
  --security-opt label=disable \
  scanner-image \
  scan -o /results/results.json
```

**`podman-compose.yaml`** — same Compose v3 format as Docker Compose. Use overrides for rootless networking:

```yaml
services:
  nuclei:
    image: projectdiscovery/nuclei:v3.3.4
    volumes:
      - ./results:/results
    network_mode: bridge
    # Allow ICMP in rootless podman
    cap_add: ["NET_RAW"]
```

---

## 6. Multi-Architecture Image Builds

Build scanner images that run on AMD64 (standard x86), ARM64 (AWS Graviton, Apple Silicon, Raspberry Pi), and S390X (legacy mainframes). Use `docker buildx` declarative multi-arch.

**Create and use a buildx builder**.

```bash
docker buildx create --name multiarch-builder --use
docker buildx inspect --bootstrap
```

**Build and push for multiple platforms**.

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7,linux/s390x \
  --tag registry.example.com/scanner:v1.4.0 \
  --push \
  --provenance=true \
  --sbom=true \
  .
```

**`docker-buildx.yml` GitHub Actions workflow**:

```yaml
name: Build multiarch scanner image
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: registry.example.com
          username: ${{ secrets.REGISTRY_USER }}
          password: ${{ secrets.REGISTRY_PASS }}
      - run: |
          docker buildx build \
            --platform linux/amd64,linux/arm64 \
            --tag registry.example.com/scanner:${{ github.sha }} \
            --push \
            --provenance=true \
            .
```

---

## 7. Container Security Scanning of Images

Before using any container in production automation, scan it for vulnerabilities. Use Trivy (most comprehensive), Grype, or Snyk.

**Trivy — local CLI scan of a built image**.

```bash
trivy image \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  --format sarif \
  --output trivy-results.sarif \
  registry.example.com/scanner:v1.4.0
```

**Grype with SARIF output for CI integration**.

```bash
grype registry.example.com/scanner:v1.4.0 \
  --fail-on high \
  --output sarif \
  --file grype-results.sarif
```

**Snyk policy enforcement**.

```bash
snyk container test registry.example.com/scanner:v1.4.0 \
  --severity-threshold=high \
  --policy-path=.snyk
```

**CI gate — reject images with critical CVEs**.

```yaml
- name: Scan image with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: registry.example.com/scanner:${{ github.sha }}
    severity: "CRITICAL"
    exit-code: "1"
    format: "sarif"
    output: "trivy-results.sarif"
```

**Base image hygiene**:

- Use `golang:1.23-alpine` (small, frequent updates) rather than full Ubuntu images.
- Prefer Distroless (`gcr.io/distroless/base`) for production — no shell, no package manager.
- Rebase on updated base image monthly. Track with Renovate or Dependabot.

---

## 8. Kubernetes Job Specs for Distributed Scanning

Kubernetes Jobs run to completion, making them ideal for scheduled or ad-hoc vulnerability scans. Use Jobs (not Deployments) because scanning has a defined start and end.

**Job spec — nuclei scan on a live-host list**.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: nuclei-scan-20250605
  labels:
    scan-type: nuclei
    target-domain: example.com
spec:
  backoffLimit: 2
  ttlSecondsAfterFinished: 86400
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: nuclei
          image: registry.example.com/nuclei:v3.3.4
          imagePullPolicy: IfNotPresent
          securityContext:
            runAsNonRoot: true
            runAsUser: 10001
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
          resources:
            requests: { cpu: "250m", memory: "512Mi" }
            limits:   { cpu: "2",    memory: "4Gi" }
          env:
            - name: NUCLEI_TEMPLATES
              value: "/templates"
            - name: NUCLEI_RATE_LIMIT
              value: "150"
          volumeMounts:
            - name: scan-results
              mountPath: /results
            - name: nuclei-templates
              mountPath: /templates
            - name: tmp
              mountPath: /tmp
          command:
            - nuclei
            - -l
            - /results/live_hosts.json
            - -json
            - -o
            - /results/nuclei_results.json
            - -severity
            - critical,high,medium
            - -rate-limit
            - "150"
      volumes:
        - name: scan-results
          persistentVolumeClaim:
            claimName: scan-results-pvc
        - name: nuclei-templates
          configMap:
            name: nuclei-templates-cm
        - name: tmp
          emptyDir: { sizeLimit: "1Gi" }
```

**Job spec — Podman-in-Kubernetes (privileged, for TCP scanning)**.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: masscan-tcp-sweep
spec:
  template:
    spec:
      restartPolicy: Never
      securityContext:
        sysctls:
          - name: net.ipv4.ping_group_range
            value: "0 2147483647"
      containers:
        - name: masscan
          image: registry.example.com/masscan:v1.3
          securityContext:
            capabilities:
              add: ["NET_RAW", "NET_ADMIN"]
          resources:
            limits: { cpu: "4", memory: "2Gi" }
          command:
            - masscan
            - -p1-65535
            - 10.0.0.0/16
            - --rate
            - "10000"
            - -oL
            - /results/open_ports.txt
          volumeMounts:
            - name: scan-data
              mountPath: /results
      volumes:
        - name: scan-data
          persistentVolumeClaim:
            claimName: scan-results-pvc
```

---

## 9. Distributed Scanning with Kubernetes CronJobs

Schedule recurring scans using CronJobs. Set concurrency policy to avoid overlapping runs.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-subdomain-enum
spec:
  schedule: "0 2 * * *"   # 2 AM daily
  concurrencyPolicy: Forbid  # skip if previous run still active
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      backoffLimit: 1
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: subfinder
              image: registry.example.com/subfinder:v2.12.0
              resources:
                requests: { cpu: "200m", memory: "256Mi" }
                limits:   { cpu: "1",    memory: "1Gi" }
              env:
                - name: SUBFINDER_API_KEY
                  valueFrom:
                    secretKeyRef:
                      name: scan-credentials
                      key: shodan-api-key
              volumeMounts:
                - name: output-vol
                  mountPath: /results
          volumes:
            - name: output-vol
              persistentVolumeClaim:
                claimName: scan-results-pvc
```

**Horizontal scaling — fan-out Jobs using CompletionMode=Indexed** (available since Kubernetes 1.24, GA in 1.26):

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: nuclei-parallel-scan
spec:
  completions: 20          # 20 parallel pods
  parallelism: 5           # max 5 at once
  completionMode: Indexed  # each pod gets a unique index 0..19
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: worker
          image: registry.example.com/nuclei:v3.3.4
          command:
            - sh
            - -c
            - |
              INDEX=$(cat /pod/index)        # Kubernetes sets this file
              HOSTS_FILE=/results/hosts.json
              CHUNK_SIZE=50
              START=$((INDEX * CHUNK_SIZE))
              jq ".[$START:$((START + CHUNK_SIZE))]" "$HOSTS_FILE" > /results/my_chunk.json
              nuclei -l /results/my_chunk.json -json -o /results/result_${INDEX}.json
          volumeMounts:
            - name: scan-results
              mountPath: /results
      volumes:
        - name: scan-results
          persistentVolumeClaim:
            claimName: scan-results-pvc
```

**Argo Workflows — visual DAG for complex multi-step scans** (alternative to Compose):

```yaml
# workflows/subdomain-to-report.yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: recon-pipeline-
spec:
  entrypoint: main
  volumes:
    - name: shared-results
      persistentVolumeClaim:
        claimName: scan-results-pvc
  templates:
    - name: main
      dag:
        tasks:
          - name: subfinder
            template: subfinder-step
          - name: httpx
            template: httpx-step
            dependencies: [subfinder]
          - name: nuclei
            template: nuclei-step
            dependencies: [httpx]
          - name: report
            template: report-step
            dependencies: [nuclei]

    - name: subfinder-step
      container:
        image: registry.example.com/subfinder:v2.12.0
        command: [subfinder, -d, "{{workflow.parameters.target}}", -oJ, -o, /results/subdomains.json]
        resources:
          limits: { cpu: "1", memory: "512Mi" }
      volumes: [{name: shared-results, mountPath: /results}]

    - name: httpx-step
      container:
        image: registry.example.com/httpx:v1.6.8
        command: [httpx, -l, /results/subdomains.json, -json, -o, /results/live.json]
        resources:
          limits: { cpu: "2", memory: "1Gi" }
      volumes: [{name: shared-results, mountPath: /results}]

    - name: nuclei-step
      container:
        image: registry.example.com/nuclei:v3.3.4
        command: [nuclei, -l, /results/live.json, -json, -o, /results/results.json]
        resources:
          limits: { cpu: "4", memory: "4Gi" }
      volumes: [{name: shared-results, mountPath: /results}]

    - name: report-step
      container:
        image: registry.example.com/scan-reporter:v3
        command: [reporter, --input, /results/results.json, --out, /results/report.html]
      volumes: [{name: shared-results, mountPath: /results}]
```

---

## 10. Registry Management for Scanner Images

Host scanner images in a private registry to control access, scan images on push, and audit who downloads them.

**Harbor — open-source registry with built-in Trivy integration**:

```yaml
# docker-compose.harbor.yml (simplified)
services:
  nginx:
    image: goharbor/nginx-photon:v2.11
  harbor-core:
    image: goharbor/harbor-core:v2.11
  registry:
    image: goharbor/registry-photon:v2.11
    volumes:
      - ./storage:/storage
    environment:
      REGISTRY_STORAGE_DELETE_ENABLED: "true"
  trivy-adapter:
    image: goharbor/trivy-adapter-photon:v2.11
    environment:
      TRIVY_DB_REPOSITORY: ghcr.io/aquasecurity/trivy-db
```

**OCI image signing with Sigstore/cosign**:

```bash
# Sign image after push
cosign sign registry.example.com/scanner:v1.4.0

# Verify signature before running
cosign verify registry.example.com/scanner:v1.4.0 \
  --key cosign.key \
  --certificate-identity-regexp "registry.example.com"
```

---

## 11. Resource Limits and OOM Prevention

Scanner containers have erratic memory profiles — nuclei loads templates into memory, Nmap buffers large results. Always set `mem_limit` and `ulimit` to prevent OOM kills that corrupt scan state.

```bash
docker run --rm \
  --memory=4g \
  --memory-swap=4g \
  --ulimit nofile=65536:65536 \
  --pids-limit=256 \
  nuclei-image \
  -l targets.txt -o results.json
```

**Docker Compose per-service limits (production)**:

```yaml
services:
  nuclei:
    deploy:
      resources:
        limits:
          cpus: "2.0"
          memory: 4G
        reservations:
          cpus: "0.5"
          memory: 1G
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
```

**Kubernetes — QoS class affecting scheduling**:

| Resource Request | Limit  | QoS Class   | Eviction Priority |
|-----------------|--------|-------------|-------------------|
| cpu=1, mem=2Gi  | cpu=2  | Burstable   | Medium            |
| cpu=2, mem=4Gi  | cpu=4  | Guaranteed  | Lowest            |
| cpu=0.5         | cpu=2  | Burstable   | Medium            |

Use `Guaranteed` (requests == limits for both CPU and memory) for production scheduled scans that must not be evicted.

---

## 12. Token / Secret Handling in Containers

Never bake API keys into images. Use Docker secrets (Swarm) or Kubernetes Secrets, and mount them as files (not env vars) so they are not visible in `/proc/<pid>/environ`.

**Kubernetes Secret for API keys**:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: scan-credentials
type: Opaque
stringData:
  shodan-api-key: "YOUR_KEY"
  github-token: "YOUR_TOKEN"
---
apiVersion: batch/v1
kind: Job
metadata:
  name: nuclei-scan
spec:
  template:
    spec:
      containers:
        - name: scanner
          image: scanner:v1
          volumeMounts:
            - name: creds
              mountPath: /secrets
              readOnly: true
          env:
            - name: SHODAN_API_KEY_FILE
              value: /secrets/shodan-api-key
          command: ["sh", "-c", "exec scanner --api-key-file $SHODAN_API_KEY_FILE"]
      volumes:
        - name: creds
          secret:
            secretName: scan-credentials
```

**Docker Compose secrets** (requires Swarm mode):

```yaml
secrets:
  shodan_api_key:
    file: ./secrets/shodan_api_key.txt

services:
  scanner:
    secrets: ["shodan_api_key"]
    command: >
      sh -c "cat /run/secrets/shodan_api_key | scanner --stdin"
```

---

## 13. Logging from Containers

Emit logs to stdout/stderr so the container runtime captures them. Container-native logging stacks (Fluentd, Fluent Bit, Loki) then forward to Elasticsearch/Grafana.

**Structured logging in the container entrypoint**:

```python
# scanner.py
import sys
import json
import logging

class JsonFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            "ts": self.formatTime(record),
            "level": record.levelname,
            "logger": record.name,
            "msg": record.getMessage(),
            "container_image": "scanner:v1.4.0",
        })

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
root = logging.getLogger()
root.addHandler(handler)
root.setLevel(logging.INFO)
```

**Compose logging directives**:

```yaml
services:
  scanner:
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "3"
        tag: "scanner"
```

Fluent Bit sidecar to ship to Loki:

```yaml
services:
  scanner:
    image: scanner:v1
    logging:
      driver: "fluentd"
      options:
        fluentd-address: "fluentd:24224"
        tag: "scanner.{{.Name}}"
```

---

## 14. Network Policies and Egress Restrictions

Scanner containers need outbound internet for vulnerability checks. Limit outbound to 53/UDP, 80/TCP, 443/TCP and the scan targets only — prevents data exfil through a compromised scanner.

**Kubernetes NetworkPolicy**:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: scanner-egress
  namespace: security-scans
spec:
  podSelector:
    matchLabels:
      app: scanner
  policyTypes: ["Egress"]
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except: [10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16]
      ports:
        - protocol: TCP
          ports: [80, 443, 8080]
        - protocol: UDP
          ports: [53]
    - to:
        - namespaceSelector:
            matchLabels:
              name: scan-targets
      ports:
        - protocol: TCP
          ports: [1-65535]
```

---

## 15. Image Promotion — Dev → Prod Registry

Promote images from the development registry to production after securityScan passes.

```bash
#!/usr/bin/env bash
set -euo pipefail
DEV_REGISTRY="registry.dev.example.com"
PROD_REGISTRY="registry.prod.example.com"
IMAGE="scanner"
TAG="${1:-latest}"

# Re-tag and push to prod
docker pull "${DEV_REGISTRY}/${IMAGE}:${TAG}"
docker tag "${DEV_REGISTRY}/${IMAGE}:${TAG}" "${PROD_REGISTRY}/${IMAGE}:${TAG}"

# Proton for cosign signature in production
cosign copy "${DEV_REGISTRY}/${IMAGE}:${TAG}" "${PROD_REGISTRY}/${IMAGE}:${TAG}"

echo "Promoted ${IMAGE}:${TAG} to prod registry"
```

**Automated promotion in CI** (Runtek / GitHub Actions):

```yaml
- name: Promote image to prod
  if: github.ref == 'refs/heads/main' && job.result == 'success'
  run: |
    skopeo copy \
      docker://registry.dev.example.com/scanner:${{ github.sha }} \
      docker://registry.prod.example.com/scanner:${{ github.sha }} \
      --dest-tls-verify=true
```

---

## 16. Reference Checklist

Before using a containerized scanner in production:

- [ ] Image built with pinned base image digest and retagged with SHA
- [ ] Multi-arch manifest pushed for amd64 and arm64 at minimum
- [ ] Trivy scan passed (no CRITICAL CVEs above configured threshold)
- [ ] `cosign` / `sigstore` signature verified before pull
- [ ] Runs as non-root (`runAsNonRoot: true`, dedicated UID)
- [ ] `readOnlyRootFilesystem: true`, writable paths mounted via volumes only
- [ ] Resource requests and limits set (CPU, memory)
- [ ] Logs emitted as JSON to stdout (structured, machine-readable)
- [ ] Secrets loaded from K8s Secret or Docker secret, not env vars
- [ ] NetworkPolicy restricts egress to required destinations only
- [ ] Tmpfs used for scratch space where large temp files accumulate
- [ ] SARIF/SBOM attestation generated and stored in image metadata
- [ ] Registry access controlled by OIDC / short-lived tokens
- [ ] Image rebased on updated base image within the last 30 days
