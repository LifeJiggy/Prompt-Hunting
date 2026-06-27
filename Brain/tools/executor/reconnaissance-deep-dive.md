# Reconnaissance Deep Dive — Tool Execution Domain

**Component:** Tool Executor for Enumeration Tools  
**Domain:** `reconnaissance-deep-dive`  
**Registry:** `Reconnaissance-Deep-Dive/registry.json`  
**File Count:** 50 prompt files  
**Execution Mode:** Enumeration tool execution with progressive depth

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `reconnaissance-deep-dive` |
| Domain Path | `Reconnaissance-Deep-Dive/` |
| Category | `recon` |
| Execution Profile | `enumerator` |
| Default Timeout | 300s |
| Max Timeout | 3600s |
| Default Retries | 2 |
| Concurrency Limit | 6 |
| Stealth Level | `medium` |
| Rate Limit | 15 req/s |

---

## Overview

The Reconnaissance Deep Dive executor manages tool execution for comprehensive enumeration operations. This domain covers 50 prompt files spanning advanced subdomain enumeration, passive OSINT collection, active asset discovery, technology stack fingerprinting, cloud resource enumeration, API endpoint discovery, JavaScript source analysis, configuration file extraction, version detection techniques, content discovery automation, directory brute-forcing, file type detection, backup file discovery, source code leak detection, git repository analysis, DNS enumeration advanced, certificate transparency logs, historical data analysis, social media OSINT, employee-linked assets, third-party integration discovery, web archive analysis, Pastebin and leak searching, code repository mining, container registry enumeration, IoT device discovery, mobile app analysis, API documentation extraction, WebSocket endpoint discovery, GraphQL introspection, XML-RPC and SOAP discovery, email address harvesting, phone number enumeration, physical location intelligence, supply chain asset mapping, competitor analysis, partner network discovery, acquisition target analysis, subsidiary asset mapping, regional infrastructure mapping, CMS detection, framework and library identification, server configuration analysis, SSL/TLS certificate analysis, HTTP header intelligence, cookie analysis and session management, error page analysis, debug endpoint discovery, staging environment detection, and advanced reconnaissance strategy.

This executor runs enumeration tools with progressive depth levels, from passive OSINT to active probing, while respecting target scope and rate limits.

---

## Execution Schema

### ReconInvocation (Input)

```json
{
  "tool": "string — enumeration tool name",
  "recon_phase": "string — passive|active|deep",
  "input": {
    "target": "string — target domain or IP",
    "scope": ["string — in-scope targets"],
    "depth": "number — enumeration depth 1-5",
    "options": {
      "follow_redirects": "boolean",
      "resolve_dns": "boolean",
      "check_alive": "boolean",
      "extract_endpoints": "boolean"
    }
  },
  "config": {
    "timeout": "number",
    "retries": "number",
    "rate_limit": "number",
    "stealth": "boolean"
  }
}
```

### ReconResult (Output)

```json
{
  "status": "string",
  "recon_phase": "string",
  "assets": {
    "subdomains": ["string"],
    "ips": ["string"],
    "endpoints": ["string"],
    "technologies": ["string"],
    "emails": ["string"],
    "secrets": ["string"]
  },
  "total_assets": "number",
  "new_assets": "number",
  "duration_ms": "number"
}
```

---

## Run Operations

### Reconnaissance Execution

```python
def run_recon(
    self,
    tool: str,
    recon_phase: str,
    input_data: dict,
    config: dict = None
) -> ReconResult:
    """
    Execute a reconnaissance tool.
    
    Flow:
    1. Validate target is in-scope
    2. Check recon phase permissions
    3. Apply stealth settings
    4. Execute enumeration tool
    5. Capture and deduplicate results
    6. Classify discovered assets
    7. Return structured results
    8. Log for audit
    """
```

### Passive Reconnaissance

```python
def run_passive_recon(
    self,
    target: str
) -> ReconResult:
    """
    Execute passive reconnaissance.
    No direct interaction with target infrastructure.
    Uses OSINT sources, CT logs, and public data.
    """
```

### Active Reconnaissance

```python
def run_active_recon(
    self,
    target: str,
    scope: list[str]
) -> ReconResult:
    """
    Execute active reconnaissance.
    Direct interaction with target within scope.
    Applies rate limiting and stealth measures.
    """
```

### Deep Reconnaissance

```python
def run_deep_recon(
    self,
    target: str,
    scope: list[str],
    depth: int = 3
) -> ReconResult:
    """
    Execute deep reconnaissance.
    Combines passive and active techniques.
    Recursive discovery with configurable depth.
    """
```

---

## Stop Operations

### Recon Stop

```python
def stop_recon(
    self,
    invocation_id: str,
    save_partial: bool = True
) -> StopResult:
    """Stop a running reconnaissance operation."""
```

---

## Retry Operations

### Recon Retry Configuration

```python
@dataclass
class ReconRetryConfig:
    max_retries: int = 2
    backoff_base: float = 5.0
    backoff_multiplier: float = 2.0
    retry_on_network_error: bool = True
    retry_on_timeout: bool = False
    retry_on_rate_limit: bool = True
```

---

## Timeout Handling

### Recon Timeout Configuration

```python
@dataclass
class ReconTimeoutConfig:
    default: int = 300
    overrides: dict[str, int] = field(default_factory=lambda: {
        "subdomain_enum": 600,
        "port_scan": 600,
        "osint_collection": 300,
        "fingerprinting": 120,
        "api_discovery": 300,
        "js_analysis": 300,
        "config_extraction": 120,
        "content_discovery": 600,
        "directory_bruteforce": 600,
        "git_analysis": 120,
        "dns_enum": 120,
        "ct_log_search": 60,
        "email_harvest": 120,
        "cloud_enum": 600
    })
    hard_maximum: int = 3600
```

---

## Output Capture

### Recon Output Capture

```python
@dataclass
class ReconCapturedOutput:
    assets: dict
    total_assets: int
    new_assets: int
    duplicates_removed: int
    duration_ms: int
    raw_output_path: str
```

### Asset Deduplication

```python
def _deduplicate_assets(self, assets: dict) -> dict:
    """Remove duplicate assets from results."""
    deduplicated = {}
    for asset_type, asset_list in assets.items():
        seen = set()
        deduplicated[asset_type] = []
        for asset in asset_list:
            normalized = self._normalize_asset(asset, asset_type)
            if normalized not in seen:
                seen.add(normalized)
                deduplicated[asset_type].append(asset)
    return deduplicated
```

---

## Stderr Handling

### Recon Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Process reconnaissance stderr."""
    classifications = []
    
    if "rate limit" in stderr.lower():
        classifications.append("rate_limited")
    if "connection refused" in stderr.lower():
        classifications.append("connection_error")
    if "timeout" in stderr.lower():
        classifications.append("timeout")
    
    return StderrResult(
        raw=stderr,
        classifications=classifications,
        retryable=any(c in ["rate_limited", "connection_error"] for c in classifications)
    )
```

---

## Exit Code Handling

### Recon Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process reconnaissance exit code."""
    if exit_code == 0:
        return ExitCodeResult(status="success", action="process_assets")
    elif exit_code == 1:
        return ExitCodeResult(status="partial_results", action="process_assets")
    else:
        return ExitCodeResult(status="error", action="retry")
```

---

## Concurrent Execution

### Recon Concurrency Configuration

```python
@dataclass
class ReconConcurrencyConfig:
    max_concurrent: int = 6
    max_per_phase: int = 3
    max_per_target: int = 2
    sequential_depth: bool = True
```

### Phase-Based Scheduling

```python
def _schedule_by_phase(
    self,
    invocations: list[ReconInvocation]
) -> list[list[ReconInvocation]]:
    """Schedule recon by phase (passive → active → deep)."""
    phases = defaultdict(list)
    for inv in invocations:
        phases[inv.recon_phase].append(inv)
    
    ordered = []
    for phase in ["passive", "active", "deep"]:
        if phase in phases:
            ordered.append(phases[phase])
    return ordered
```

---

## Execution Logging

### Recon Execution Log

```python
@dataclass
class ReconExecutionLog:
    invocation_id: str
    tool: str
    recon_phase: str
    target: str
    status: str
    assets_found: int
    new_assets: int
    duration_ms: int
    timestamp_start: str
    timestamp_end: str
```

---

## Full Domain File References

### Category: Subdomain and DNS

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 01 | `01-Advanced-Subdomain-Enumeration.md` | Advanced Subdomain Enumeration | active | 600s |
| 16 | `16-DNS-Enumeration-Advanced.md` | DNS Enumeration Advanced | active | 120s |
| 17 | `17-Certificate-Transparency-Logs.md` | Certificate Transparency Logs | passive | 60s |

### Category: OSINT and Passive

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 02 | `02-Passive-OSINT-Collection.md` | Passive OSINT Collection | passive | 300s |
| 18 | `18-Historical-Data-Analysis.md` | Historical Data Analysis | passive | 120s |
| 19 | `19-Social-Media-OSINT.md` | Social Media OSINT | passive | 300s |
| 20 | `20-Employee-Linked-Assets.md` | Employee-Linked Assets | passive | 120s |
| 22 | `22-Web-Archive-Analysis.md` | Web Archive Analysis | passive | 120s |
| 23 | `23-Pastebin-and-Leak-Searching.md` | Pastebin and Leak Searching | passive | 120s |
| 32 | `32-Email-Address-Harvesting.md` | Email Address Harvesting | passive | 120s |
| 33 | `33-Phone-Number-Enumeration.md` | Phone Number Enumeration | passive | 120s |

### Category: Active Discovery

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 03 | `03-Active-Asset-Discovery.md` | Active Asset Discovery | active | 600s |
| 10 | `10-Content-Discovery-Automation.md` | Content Discovery Automation | active | 600s |
| 11 | `11-Directory-Brute-Forcing.md` | Directory Brute-Forcing | active | 600s |
| 26 | `26-IoT-Device-Discovery.md` | IoT Device Discovery | active | 600s |
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | XML-RPC and SOAP Discovery | active | 120s |
| 48 | `48-Debug-Endpoint-Discovery.md` | Debug Endpoint Discovery | active | 120s |

### Category: Fingerprinting

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 04 | `04-Technology-Stack-Fingerprinting.md` | Technology Stack Fingerprinting | active | 120s |
| 09 | `09-Version-Detection-Techniques.md` | Version Detection Techniques | active | 120s |
| 41 | `41-Content-Management-System-Detection.md` | CMS Detection | active | 60s |
| 42 | `42-Framework-and-Library-Identification.md` | Framework and Library Identification | active | 60s |
| 43 | `43-Server-Configuration-Analysis.md` | Server Configuration Analysis | active | 60s |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | SSL/TLS Certificate Analysis | passive | 30s |

### Category: Cloud Resources

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 05 | `05-Cloud-Resource-Enumeration.md` | Cloud Resource Enumeration | active | 600s |
| 25 | `25-Container-Registry-Enumeration.md` | Container Registry Enumeration | active | 300s |

### Category: API Discovery

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 06 | `06-API-Endpoint-Discovery.md` | API Endpoint Discovery | active | 300s |
| 28 | `28-API-Documentation-Extraction.md` | API Documentation Extraction | passive | 60s |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | WebSocket Endpoint Discovery | active | 120s |
| 30 | `30-GraphQL-Introspection.md` | GraphQL Introspection | active | 60s |
| 45 | `45-HTTP-Header-Intelligence.md` | HTTP Header Intelligence | passive | 30s |

### Category: Code Analysis

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 07 | `07-JavaScript-Source-Analysis.md` | JavaScript Source Analysis | active | 300s |
| 08 | `08-Configuration-File-Extraction.md` | Configuration File Extraction | active | 120s |
| 14 | `14-Source-Code-Leak-Detection.md` | Source Code Leak Detection | passive | 120s |
| 15 | `15-Git-Repository-Analysis.md` | Git Repository Analysis | active | 120s |
| 24 | `24-Code-Repository-Mining.md` | Code Repository Mining | passive | 300s |

### Category: Enterprise Recon

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 12 | `12-File-Type-Detection.md` | File Type Detection | active | 30s |
| 13 | `13-Backup-File-Discovery.md` | Backup File Discovery | active | 300s |
| 21 | `21-Third-Party-Integration-Discovery.md` | Third-Party Integration Discovery | passive | 120s |
| 27 | `27-Mobile-App-Analysis.md` | Mobile App Analysis | active | 600s |
| 34 | `34-Physical-Location-Intelligence.md` | Physical Location Intelligence | passive | 120s |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | Supply Chain Asset Mapping | passive | 300s |
| 36 | `36-Competitor-Analysis.md` | Competitor Analysis | passive | 120s |
| 37 | `37-Partner-Network-Discovery.md` | Partner Network Discovery | passive | 120s |
| 38 | `38-Acquisition-Target-Analysis.md` | Acquisition Target Analysis | passive | 120s |
| 39 | `39-Subsidiary-Asset-Mapping.md` | Subsidiary Asset Mapping | passive | 120s |

### Category: Advanced Techniques

| ID | File | Title | Recon Phase | Timeout |
|----|------|-------|-------------|---------|
| 40 | `40-Regional-Infrastructure-Mapping.md` | Regional Infrastructure Mapping | active | 300s |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | Cookie Analysis and Session Management | active | 60s |
| 47 | `47-Error-Page-Analysis.md` | Error Page Analysis | active | 60s |
| 49 | `49-Staging-Environment-Detection.md` | Staging Environment Detection | active | 120s |
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | Advanced Reconnaissance Strategy | deep | 600s |

---

## Recon Depth Levels

| Level | Phase | Description | Tools |
|-------|-------|-------------|-------|
| 1 | Passive | OSINT, CT logs, public data | waybackurls, gau, ct logs |
| 2 | Active | Direct probing, port scanning | httpx, nmap, masscan |
| 3 | Deep | Recursive enumeration | subfinder, amass, ffuf |
| 4 | Aggressive | Full attack surface mapping | nuclei, nikto |
| 5 | Custom | Targeted custom scripts | Custom tooling |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
