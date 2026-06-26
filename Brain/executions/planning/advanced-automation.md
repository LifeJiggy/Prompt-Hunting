# Planning: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Execution Plan Design

This document defines how execution plans are structured for automated scanning pipelines — from subdomain enumeration through vulnerability scanning and report generation.

## Plan Template

```yaml
plan:
  name: "auto_scan_{target}"
  domain: "advanced-automation"
  trigger: "recon.asset.discovered"
  steps:
    - id: step_1
      action: "subdomain_enumerate"
      tool: "subfinder"
      input: "{target}"
      output: "subdomains.txt"
      timeout: 120
      retries: 2
      depends_on: []
    - id: step_2
      action: "http_probe"
      tool: "httpx"
      input: "subdomains.txt"
      output: "live_hosts.txt"
      timeout: 60
      retries: 1
      depends_on: [step_1]
    - id: step_3
      action: "port_scan"
      tool: "naabu"
      input: "live_hosts.txt"
      output: "open_ports.txt"
      timeout: 120
      retries: 1
      depends_on: [step_2]
    - id: step_4
      action: "vuln_scan"
      tool: "nuclei"
      input: "live_hosts.txt"
      output: "findings.json"
      timeout: 300
      retries: 1
      depends_on: [step_2]
      parallel_with: [step_3]
    - id: step_5
      action: "report_generate"
      tool: "report_engine"
      input: "findings.json"
      output: "report.md"
      timeout: 60
      retries: 0
      depends_on: [step_4]
  max_concurrent_steps: 3
  total_timeout: 600
  on_failure: "best_effort"
```

## Plan Categories

| Plan Type | Steps | Tools | Timeout |
|-----------|-------|-------|---------|
| Quick Recon | 2-3 | subfinder, httpx | 5 min |
| Full Recon | 5-7 | subfinder, httpx, naabu, nuclei | 30 min |
| Targeted Vuln Scan | 3-4 | nuclei, ffuf, sqlmap | 60 min |
| Full Pipeline | 8-12 | All tools | 120 min |
| CI/CD Integration | 5-6 | Custom scripts | 30 min |

## Step Dependencies

```
subdomain_enumerate
        │
        ▼
   http_probe
    ┌───┴───┐
    │       │
port_scan  vuln_scan (parallel)
    │       │
    └───┬───┘
        │
        ▼
  report_generate
```

## Plan Files Reference

This planning template supports all 50 files in `Advanced-Automation/`:
- Steps 01-07 map to recon_automation tools (subfinder, naabu, nuclei, ffuf)
- Steps 08-20 map to vulnerability scanning tools (sqlmap, nuclei templates)
- Steps 21-23 map to reporting and PoC automation
- Steps 24-30 map to target management and data collection
- Steps 31-40 map to browser and proxy automation
- Steps 41-50 map to advanced recon and compliance checking
