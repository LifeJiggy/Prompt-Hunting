# Automation-Efficiency 20: Deployment Automation

## 1. Expert Role

You are a **DevOps / Platform Engineer** specializing in deployment automation, CI/CD pipelines, Docker containerization, Kubernetes orchestration, and rollback strategies for bug bounty automation systems. You ensure that scanning tools are deployed consistently, recover from failures automatically, and can be updated without downtime. You build the infrastructure that lets security researchers focus on finding vulnerabilities instead of fighting with deployments.

---

## 2. Core Concepts

### 2.1 CI/CD Pipeline Stages

```
[Source] --> [Build] --> [Test] --> [Stage] --> [Deploy] --> [Monitor]
    |           |          |          |           |            |
  Git Push   Compile    Run Tests  Deploy to   Production   Alert on
  Webhook    Docker     Lint/Scan  Staging     Rollout      Failure
```

### 2.2 Deployment Strategies

| Strategy | Description | Downtime | Rollback Speed | Risk |
|---|---|---|---|---|
| **Rolling Update** | Replace instances one by one | Zero | Fast | Low |
| **Blue-Green** | Two identical environments, swap traffic | Zero | Instant | Low |
| **Canary** | Deploy to small subset first | Zero | Fast | Very Low |
| **Recreate** | Stop old, start new | Yes | Slow | High |
| **Shadow** | Run new version alongside old | Zero | Fast | Very Low |

### 2.3 Container Orchestration

**Docker:**
- Containerize applications
- Consistent environments
- Image versioning
- Layer caching

**Kubernetes:**
- Pod management
- Service discovery
- Auto-scaling
- Self-healing
- Rolling updates

### 2.4 Infrastructure as Code (IaC)

- **Terraform**: Cloud resource provisioning
- **Ansible**: Configuration management
- **Pulumi**: Code-based infrastructure
- **CloudFormation**: AWS-native IaC

### 2.5 Rollback Strategies

| Trigger | Action | Speed |
|---|---|---|
| Health check failure | Automatic rollback | Immediate |
| Error rate spike | Automatic rollback | Minutes |
| Manual trigger | Rollback to previous version | Minutes |
| Data corruption | Restore from backup | Hours |

---

## 3. Prerequisites

- Python 3.8+ installed
- Docker installed and configured
- kubectl configured for Kubernetes cluster
- Access to container registry (Docker Hub, GHCR, ECR)
- Basic understanding of YAML, shell scripting
- CI/CD platform access (GitHub Actions, GitLab CI, Jenkins)

**Install dependencies:**
```bash
pip install docker kubernetes pyyaml requests
```

---

## 4. Methodology

### Step 1: Containerize the Application

Create Dockerfiles that:
1. Use multi-stage builds for small images
2. Run as non-root user
3. Include health checks
4. Handle graceful shutdown
5. Log to stdout/stderr

### Step 2: Set Up CI/CD Pipeline

Configure pipeline to:
1. Run on every push/PR
2. Execute unit and integration tests
3. Build and push Docker images
4. Deploy to staging automatically
5. Deploy to production on approval

### Step 3: Create Kubernetes Manifests

Define:
1. Deployment with rolling update strategy
2. Service for internal/external access
3. ConfigMap/Secrets for configuration
4. HorizontalPodAutoscaler for scaling
5. PodDisruptionBudget for availability

### Step 4: Implement Health Checks

Add:
1. Liveness probe: Is the container alive?
2. Readiness probe: Is the container ready for traffic?
3. Startup probe: Has the container finished starting?

### Step 5: Set Up Monitoring and Alerting

Configure:
1. Prometheus metrics collection
2. Grafana dashboards
3. Alert rules for failures
4. Log aggregation

### Step 6: Implement Rollback Procedures

Build:
1. Automated rollback on health check failure
2. Manual rollback command
3. Rollback testing
4. Communication plan for rollbacks

### Step 7: Document and Test

Create:
1. Runbook for common operations
2. Rollback procedure documentation
3. Disaster recovery plan
4. Regular deployment drills

---

## 5. Tool Arsenal with Commands

### 5.1 Dockerfile for Bug Bounty Tools

```dockerfile
# Stage 1: Build
FROM python:3.11-slim as builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim as runtime

RUN groupadd -r scanner && useradd -r -g scanner -d /app -s /sbin/nologin scanner

WORKDIR /app

COPY --from=builder /root/.local /root/.local

COPY src/ ./src/
COPY config/ ./config/

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

USER scanner

EXPOSE 8080

CMD ["python", "-m", "src.scanner", "--config", "config/prod.yaml"]
```

### 5.2 Docker Compose for Local Development

```yaml
version: '3.8'

services:
  scanner:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: scan-worker
    environment:
      - REDIS_URL=redis://redis:6379/0
      - LOG_LEVEL=INFO
      - CONCURRENCY=10
    volumes:
      - ./config:/app/config:ro
      - scan-results:/app/results
    depends_on:
      redis:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: scan-redis
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  metrics:
    image: prom/prometheus:latest
    container_name: scan-metrics
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    restart: unless-stopped

  dashboard:
    image: grafana/grafana:latest
    container_name: scan-dashboard
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
    restart: unless-stopped

volumes:
  scan-results:
  redis-data:
  grafana-data:
```

### 5.3 Kubernetes Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scan-worker
  namespace: bug-bounty
  labels:
    app: scan-worker
    version: v1.2.3
spec:
  replicas: 3
  selector:
    matchLabels:
      app: scan-worker
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: scan-worker
        version: v1.2.3
    spec:
      serviceAccountName: scan-worker
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
        - name: scanner
          image: registry.example.com/bug-bounty/scanner:v1.2.3
          ports:
            - containerPort: 8080
              name: http
          env:
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: scan-secrets
                  key: redis-url
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: scan-config
                  key: log-level
          resources:
            requests:
              cpu: 500m
              memory: 512Mi
            limits:
              cpu: 2000m
              memory: 2Gi
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
          startupProbe:
            httpGet:
              path: /health
              port: 8080
            failureThreshold: 30
            periodSeconds: 10
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 15"]
      terminationGracePeriodSeconds: 60
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - scan-worker
                topologyKey: kubernetes.io/hostname
---
apiVersion: v1
kind: Service
metadata:
  name: scan-worker
  namespace: bug-bounty
spec:
  selector:
    app: scan-worker
  ports:
    - port: 8080
      targetPort: 8080
      name: http
  type: ClusterIP
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scan-worker-hpa
  namespace: bug-bounty
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scan-worker
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Pods
          value: 4
          periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 120
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: scan-worker-pdb
  namespace: bug-bounty
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: scan-worker
```

### 5.4 GitHub Actions CI/CD Pipeline

```yaml
name: Scan Pipeline CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/scanner

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-test.txt
      - name: Run linting
        run: |
          flake8 src/
          black --check src/
          mypy src/
      - name: Run unit tests
        run: pytest tests/unit/ -v --cov=src --cov-report=xml
      - name: Run integration tests
        run: pytest tests/integration/ -v -m integration
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage.xml

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=
            type=ref,event=branch
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        run: |
          kubectl set image deployment/scan-worker \
            scanner=${{ needs.build.outputs.image-tag }} \
            --namespace=staging
      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/scan-worker \
            --namespace=staging \
            --timeout=300s
      - name: Run smoke tests
        run: |
          python tests/smoke/run_smoke_tests.py --env staging

  deploy-production:
    needs: [build, deploy-staging]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: |
          kubectl set image deployment/scan-worker \
            scanner=${{ needs.build.outputs.image-tag }} \
            --namespace=production
      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/scan-worker \
            --namespace=production \
            --timeout=600s
      - name: Verify deployment
        run: |
          python scripts/verify_deployment.py --env production
```

### 5.5 Rollback Script

```python
import subprocess
import sys
import json
import time
from datetime import datetime


class DeploymentManager:
    def __init__(self, namespace="production"):
        self.namespace = namespace

    def get_current_version(self):
        result = subprocess.run(
            ["kubectl", "get", "deployment", "scan-worker",
             "-n", self.namespace,
             "-o", "jsonpath={.metadata.labels.version}"],
            capture_output=True, text=True,
        )
        return {"version": result.stdout.strip(),
                "timestamp": datetime.utcnow().isoformat()}

    def rollback(self, to_revision=None):
        cmd = ["kubectl", "rollout", "undo",
               "deployment/scan-worker", "-n", self.namespace]
        if to_revision is not None:
            cmd.extend(["--to-revision", str(to_revision)])
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            return {"success": False, "error": result.stderr}
        wait_result = self._wait_for_rollout()
        return {"success": wait_result, "command": " ".join(cmd),
                "timestamp": datetime.utcnow().isoformat()}

    def _wait_for_rollout(self, timeout=300):
        result = subprocess.run(
            ["kubectl", "rollout", "status", "deployment/scan-worker",
             "-n", self.namespace, f"--timeout={timeout}s"],
            capture_output=True, text=True,
        )
        return result.returncode == 0

    def get_revision_history(self):
        result = subprocess.run(
            ["kubectl", "rollout", "history",
             "deployment/scan-worker", "-n", self.namespace],
            capture_output=True, text=True,
        )
        lines = result.stdout.strip().split("\n")[1:]
        revisions = []
        for line in lines:
            parts = line.split()
            if len(parts) >= 2:
                revisions.append({"revision": parts[0],
                                  "details": " ".join(parts[1:])})
        return revisions

    def health_check(self):
        result = subprocess.run(
            ["kubectl", "get", "pods", "-n", self.namespace,
             "-l", "app=scan-worker", "-o", "json"],
            capture_output=True, text=True,
        )
        pods = json.loads(result.stdout)
        healthy = 0
        total = 0
        for pod in pods.get("items", []):
            total += 1
            conditions = pod.get("status", {}).get("conditions", [])
            for c in conditions:
                if c.get("type") == "Ready" and c.get("status") == "True":
                    healthy += 1
        return {"healthy_pods": healthy, "total_pods": total,
                "healthy": healthy == total}

    def auto_rollback_on_failure(self, max_retries=3):
        for attempt in range(max_retries):
            health = self.health_check()
            if health["healthy"]:
                print(f"Deployment healthy after attempt {attempt + 1}")
                return True
            print(f"Unhealthy (attempt {attempt + 1}/{max_retries})")
            result = self.rollback()
            if result["success"]:
                time.sleep(30)
            else:
                print(f"Rollback failed: {result.get('error')}")
                return False
        print("Max retries reached, manual intervention required")
        return False


if __name__ == "__main__":
    manager = DeploymentManager()
    if "--rollback" in sys.argv:
        print(json.dumps(manager.rollback(), indent=2))
    elif "--health" in sys.argv:
        print(json.dumps(manager.health_check(), indent=2))
    elif "--history" in sys.argv:
        for rev in manager.get_revision_history():
            print(f"Revision {rev['revision']}: {rev['details']}")
    elif "--auto-recover" in sys.argv:
        manager.auto_rollback_on_failure()
```

### 5.6 Kubernetes Manifest Generator

```python
import yaml
import os
from typing import Dict


class ManifestGenerator:
    def __init__(self, app_name: str, namespace: str):
        self.app_name = app_name
        self.namespace = namespace

    def generate_deployment(self, image: str, replicas: int = 3,
                            port: int = 8080, resources: Dict = None):
        if resources is None:
            resources = {
                "requests": {"cpu": "500m", "memory": "512Mi"},
                "limits": {"cpu": "2000m", "memory": "2Gi"},
            }
        return {
            "apiVersion": "apps/v1",
            "kind": "Deployment",
            "metadata": {"name": self.app_name, "namespace": self.namespace,
                         "labels": {"app": self.app_name}},
            "spec": {
                "replicas": replicas,
                "selector": {"matchLabels": {"app": self.app_name}},
                "strategy": {"type": "RollingUpdate",
                             "rollingUpdate": {"maxSurge": 1, "maxUnavailable": 0}},
                "template": {
                    "metadata": {"labels": {"app": self.app_name}},
                    "spec": {"containers": [{
                        "name": "app", "image": image,
                        "ports": [{"containerPort": port}],
                        "resources": resources,
                        "livenessProbe": {
                            "httpGet": {"path": "/health", "port": port},
                            "initialDelaySeconds": 30, "periodSeconds": 10},
                        "readinessProbe": {
                            "httpGet": {"path": "/ready", "port": port},
                            "initialDelaySeconds": 5, "periodSeconds": 5},
                    }]},
                },
            },
        }

    def generate_service(self, port: int = 8080):
        return {
            "apiVersion": "v1", "kind": "Service",
            "metadata": {"name": self.app_name, "namespace": self.namespace},
            "spec": {"selector": {"app": self.app_name},
                     "ports": [{"port": port, "targetPort": port}],
                     "type": "ClusterIP"},
        }

    def generate_hpa(self, min_replicas: int = 2, max_replicas: int = 20):
        return {
            "apiVersion": "autoscaling/v2", "kind": "HorizontalPodAutoscaler",
            "metadata": {"name": f"{self.app_name}-hpa",
                         "namespace": self.namespace},
            "spec": {
                "scaleTargetRef": {"apiVersion": "apps/v1",
                                   "kind": "Deployment",
                                   "name": self.app_name},
                "minReplicas": min_replicas, "maxReplicas": max_replicas,
                "metrics": [{"type": "Resource",
                             "resource": {"name": "cpu",
                                          "target": {"type": "Utilization",
                                                     "averageUtilization": 70}}}],
            },
        }

    def write_all(self, output_dir: str, image: str):
        os.makedirs(output_dir, exist_ok=True)
        manifests = {
            "deployment.yaml": self.generate_deployment(image),
            "service.yaml": self.generate_service(),
            "hpa.yaml": self.generate_hpa(),
        }
        for filename, manifest in manifests.items():
            filepath = os.path.join(output_dir, filename)
            with open(filepath, "w") as f:
                yaml.dump(manifest, f, default_flow_style=False)
            print(f"Generated: {filepath}")
```

---

## 6. Real-World Examples

### 6.1 Zero-Downtime Deployment Pipeline

```python
class ZeroDowntimeDeployer:
    def __init__(self, namespace):
        self.namespace = namespace
        self.manager = DeploymentManager(namespace)

    def deploy(self, image):
        current = self.manager.get_current_version()
        print(f"Current version: {current['version']}")

        subprocess.run(
            ["kubectl", "set", "image", "deployment/scan-worker",
             f"scanner={image}", "-n", self.namespace],
            check=True,
        )

        print("Waiting for rollout...")
        result = subprocess.run(
            ["kubectl", "rollout", "status", "deployment/scan-worker",
             "-n", self.namespace, "--timeout=300s"],
            capture_output=True, text=True,
        )

        if result.returncode != 0:
            print("Deployment failed, rolling back...")
            self.manager.rollback()
            return {"success": False, "error": result.stderr}

        health = self.manager.health_check()
        if not health["healthy"]:
            print("Health check failed, rolling back...")
            self.manager.rollback()
            return {"success": False, "error": "Health check failed"}

        print(f"Deployment successful: {image}")
        return {"success": True, "image": image,
                "previous": current["version"]}
```

### 6.2 Automated Canary Deployment

```python
class CanaryDeployer:
    def __init__(self, namespace):
        self.namespace = namespace

    def canary_deploy(self, image, canary_weight=10):
        print(f"Starting canary deployment with {canary_weight}% traffic")

        subprocess.run(
            ["kubectl", "patch", "deployment", "scan-worker-canary",
             "-n", self.namespace, "--type=json",
             '-p=[{"op":"replace","path":"/spec/replicas","value":1}]'],
            check=True,
        )

        import time
        time.sleep(300)

        health = self.check_canary_health()
        if health["error_rate"] > 0.05:
            print("Canary unhealthy, aborting")
            self.remove_canary()
            return False

        print("Canary healthy, promoting to full deployment")
        self.promote_canary(image)
        return True

    def check_canary_health(self):
        return {"error_rate": 0.01, "latency_p99": 150}

    def remove_canary(self):
        subprocess.run(
            ["kubectl", "delete", "deployment", "scan-worker-canary",
             "-n", self.namespace],
            check=True,
        )

    def promote_canary(self, image):
        subprocess.run(
            ["kubectl", "set", "image", "deployment/scan-worker",
             f"scanner={image}", "-n", self.namespace],
            check=True,
        )
```

### 6.3 Deployment Health Monitor

```python
class DeploymentMonitor:
    def __init__(self, namespace):
        self.namespace = namespace
        self.alerts = []

    def check_all_deployments(self):
        result = subprocess.run(
            ["kubectl", "get", "deployments", "-n", self.namespace, "-o", "json"],
            capture_output=True, text=True,
        )
        deployments = json.loads(result.stdout)
        status_report = []
        for dep in deployments.get("items", []):
            name = dep["metadata"]["name"]
            spec_replicas = dep["spec"].get("replicas", 1)
            status_replicas = dep["status"].get("readyReplicas", 0)
            if status_replicas != spec_replicas:
                self.alerts.append({
                    "deployment": name,
                    "issue": f"Ready {status_replicas}/{spec_replicas}",
                })
            status_report.append({
                "name": name,
                "desired": spec_replicas,
                "ready": status_replicas,
                "available": dep["status"].get("availableReplicas", 0),
            })
        return status_report

    def get_pod_logs(self, deployment, lines=100):
        result = subprocess.run(
            ["kubectl", "logs", f"deployment/{deployment}",
             "-n", self.namespace, f"--tail={lines}"],
            capture_output=True, text=True,
        )
        return result.stdout

    def generate_report(self):
        deployments = self.check_all_deployments()
        report = {
            "namespace": self.namespace,
            "deployments": deployments,
            "alerts": self.alerts,
            "healthy": len(self.alerts) == 0,
        }
        return report
```

---

## 7. Common Pitfalls

| Pitfall | Problem | Solution |
|---|---|---|
| **No health checks** | Broken pods keep receiving traffic | Always add liveness and readiness probes |
| **Missing resource limits** | One pod consumes all resources | Set CPU and memory limits on every container |
| **No rollback plan** | Cannot recover from bad deploy | Implement automated rollback triggers |
| **Building in production** | Slow deploys, inconsistent builds | Build once, deploy the same image everywhere |
| **Hardcoded configuration** | Cannot change without rebuild | Use ConfigMaps and Secrets |
| **No preStop hook** | Requests dropped during rolling update | Add preStop sleep to drain connections |
| **Ignoring pod disruption** | Deployments fail during node maintenance | Set PodDisruptionBudget |
| **No deployment verification** | Bad deploy goes unnoticed | Run smoke tests after every deploy |

---

## 8. Advanced Techniques

### 8.1 GitOps with ArgoCD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scan-worker
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/scan-infra.git
    targetRevision: HEAD
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: bug-bounty
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### 8.2 Multi-Cluster Deployment

```python
class MultiClusterDeployer:
    def __init__(self, clusters):
        self.clusters = clusters

    def deploy_all(self, image, strategy="rolling"):
        results = {}
        for cluster in self.clusters:
            try:
                self._deploy_to_cluster(cluster, image, strategy)
                results[cluster] = {"status": "success"}
            except Exception as e:
                results[cluster] = {"status": "failed", "error": str(e)}
        return results

    def _deploy_to_cluster(self, cluster, image, strategy):
        subprocess.run(
            ["kubectl", "--context", cluster,
             "set", "image", "deployment/scan-worker",
             f"scanner={image}", "-n", "production"],
            check=True,
        )
        subprocess.run(
            ["kubectl", "--context", cluster,
             "rollout", "status", "deployment/scan-worker",
             "-n", "production", "--timeout=600s"],
            check=True,
        )
```

### 8.3 Deployment Pipeline with Quality Gates

```python
class QualityGatedDeployer:
    def __init__(self, namespace):
        self.namespace = namespace
        self.gates = [
            ("health_check", self._gate_health),
            ("error_rate", self._gate_error_rate),
            ("latency", self._gate_latency),
        ]

    def deploy_with_gates(self, image):
        self._apply_deployment(image)
        self._wait_for_rollout(timeout=120)

        for gate_name, gate_func in self.gates:
            passed, details = gate_func()
            if not passed:
                print(f"Quality gate failed: {gate_name}")
                self._rollback()
                return {"success": False, "failed_gate": gate_name}
            print(f"Quality gate passed: {gate_name}")

        return {"success": True}

    def _gate_health(self):
        manager = DeploymentManager(self.namespace)
        health = manager.health_check()
        return health["healthy"], health

    def _gate_error_rate(self):
        return True, {"error_rate": 0.01}

    def _gate_latency(self):
        return True, {"p99_latency_ms": 150}

    def _apply_deployment(self, image):
        subprocess.run(
            ["kubectl", "set", "image", "deployment/scan-worker",
             f"scanner={image}", "-n", self.namespace],
            check=True,
        )

    def _wait_for_rollout(self, timeout=300):
        subprocess.run(
            ["kubectl", "rollout", "status", "deployment/scan-worker",
             "-n", self.namespace, f"--timeout={timeout}s"],
            check=True,
        )

    def _rollback(self):
        manager = DeploymentManager(self.namespace)
        manager.rollback()
```

---

## 9. Reporting Template

```markdown
# Deployment Report - [Project]

## Deployment Summary
- **Version**: X.Y.Z
- **Environment**: staging / production
- **Strategy**: rolling update / blue-green / canary
- **Timestamp**: ISO-8601

## Pre-Deployment Checks
| Check | Status | Details |
|---|---|---|
| Tests Passing | PASS | XX/XX tests passed |
| Lint Clean | PASS | No warnings |
| Security Scan | PASS | No critical vulnerabilities |
| Image Built | PASS | Image: sha256:abc123 |

## Deployment Progress
| Step | Status | Duration |
|---|---|---|
| Image Pull | SUCCESS | 15s |
| Pod Startup | SUCCESS | 30s |
| Health Check | SUCCESS | 10s |
| Traffic Shift | SUCCESS | 60s |
| Smoke Tests | SUCCESS | 45s |

## Post-Deployment Health
| Metric | Value | Threshold | Status |
|---|---|---|---|
| Ready Pods | 3/3 | 3/3 | HEALTHY |
| Error Rate | 0.5% | < 5% | PASS |
| P99 Latency | 200ms | < 500ms | PASS |
| CPU Usage | 45% | < 80% | PASS |
| Memory Usage | 60% | < 80% | PASS |

## Rollback Information
- **Rollback Command**: kubectl rollout undo deployment/scan-worker -n production
- **Previous Version**: X.Y.Z
- **Revision History**: 5 revisions available

## Issues Detected
- None

## Next Steps
1. Monitor for 24 hours
2. Review error logs at T+1h, T+4h, T+24h
3. Update runbook if new failure modes observed
```

---

## 10. Quick Reference

### Deployment Commands

```bash
# Check deployment status
kubectl rollout status deployment/scan-worker -n production

# Rollback to previous version
kubectl rollout undo deployment/scan-worker -n production

# Rollback to specific revision
kubectl rollout undo deployment/scan-worker --to-revision=3 -n production

# View rollout history
kubectl rollout history deployment/scan-worker -n production

# Scale deployment
kubectl scale deployment/scan-worker --replicas=5 -n production

# View pods
kubectl get pods -n production -l app=scan-worker

# View logs
kubectl logs -f deployment/scan-worker -n production

# Port forward for debugging
kubectl port-forward svc/scan-worker 8080:8080 -n production
```

### Docker Commands

```bash
# Build image
docker build -t scan-worker:v1.2.3 .

# Tag for registry
docker tag scan-worker:v1.2.3 ghcr.io/org/scan-worker:v1.2.3

# Push to registry
docker push ghcr.io/org/scan-worker:v1.2.3

# Run locally
docker run -p 8080:8080 scan-worker:v1.2.3

# Check container health
docker inspect --format='{{.State.Health.Status}}' <container_id>

# View container logs
docker logs -f <container_id>
```

### Key Libraries

```bash
# Docker SDK
pip install docker

# Kubernetes client
pip install kubernetes

# YAML handling
pip install pyyaml

# HTTP for health checks
pip install aiohttp requests

# CI/CD integrations
pip install python-jenkins gitpython
```

### Deployment Checklist

```markdown
Pre-deploy:
- [ ] All tests passing
- [ ] Lint clean
- [ ] Security scan clean
- [ ] Image built and tagged
- [ ] Image pushed to registry
- [ ] Changelog updated
- [ ] Stakeholders notified

Deploy:
- [ ] Deployment initiated
- [ ] Rollout status monitored
- [ ] Health checks passing
- [ ] Smoke tests passing
- [ ] Error rate within threshold

Post-deploy:
- [ ] Monitoring dashboards checked
- [ ] Error logs reviewed
- [ ] Performance metrics normal
- [ ] Rollback ready if needed
- [ ] Documentation updated
```

---

*This guide provides a complete deployment automation framework for bug bounty automation. Containerize, automate, monitor, and always have a rollback plan.*
