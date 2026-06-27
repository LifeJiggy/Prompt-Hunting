# Logging: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Overview

Structured logging for automated scanning pipelines captures every pipeline event, tool invocation, finding discovery, and error with full context. Each log entry includes timestamp, component, session, and structured data for post-hoc analysis.

## Log Levels

| Level | Usage | Examples |
|-------|-------|---------|
| DEBUG | Verbose tool output, raw responses | HTTP response headers, raw scan output |
| INFO | Pipeline lifecycle events | Pipeline started, step completed, finding discovered |
| WARN | Non-fatal issues | Rate limit approached, fallback used, timeout retried |
| ERROR | Operation failed | Tool crashed, target unreachable, permission denied |
| FATAL | System cannot continue | Out of memory, disk full, configuration invalid |

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "pipeline_runner"
  domain: "advanced-automation"
  session_id: "ses_abc123"
  pipeline_id: "plan_001"
  message: "Pipeline step completed"
  data:
    step_id: "step_3"
    tool: "nuclei"
    target: "target.com"
    duration_ms: 45200
    findings: 3
    exit_code: 0
  context:
    plan_name: "full_scan_target.com"
    step_index: 3
    total_steps: 5
```

## Logging API

```python
from brain.utils.logging import get_logger

logger = get_logger("advanced-automation")

# Pipeline events
logger.info("Pipeline started", pipeline_id="plan_001", target="target.com")
logger.info("Step completed", step_id="step_3", tool="nuclei", findings=3)
logger.error("Step failed", step_id="step_4", tool="sqlmap", error="timeout")

# Tool invocations
logger.info("Tool invoked", tool="nuclei", target="https://target.com", templates="cves/")
logger.warn("Rate limit approaching", tool="nuclei", current_rps=90, limit=100)

# Findings
logger.info("Finding discovered", vuln_type="xss", severity="medium", endpoint="/search")
```

## Log Outputs

| Output | Format | Use Case |
|--------|--------|----------|
| Console | Colored text | Development |
| File | JSON lines | Production |
| HTTP | JSON POST | Centralized |
| Syslog | Syslog | System integration |

## Rotation

```yaml
rotation:
  max_size_mb: 100
  backup_count: 5
  compress: true
  compress_after: 7
  retention_days: 30
```

## Domain File References

Logging applies to all 50 files in `Advanced-Automation/`:
- Files 01-07: Recon automation logs (subdomain, port, vuln scanning)
- Files 08-20: Vulnerability scanning logs (auth, IDOR, SQLi, XSS, SSRF, CSRF, XXE, SSTI, JWT, deser)
- Files 21-30: Reporting and data logs (report gen, PoC, target scouting, asset tracking)
- Files 31-40: Browser and proxy logs (headless, regex, response, header, CORS, WebSocket, GraphQL)
- Files 41-50: Advanced recon and compliance logs (DNS, email, OSINT, framework, compliance)
