# Config: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Configuration Schema

Configuration options for the automated scanning pipeline subsystem.

```yaml
advanced_automation:
  # Pipeline Configuration
  pipeline:
    max_concurrent_pipelines: 5
    max_steps_per_pipeline: 20
    default_timeout_per_step: 300
    retry_policy: "exponential"
    retry_max_attempts: 3
    retry_base_delay: 1.0
    retry_max_delay: 60.0

  # Tool Configuration
  tools:
    subfinder:
      enabled: true
      timeout: 120
      max_results: 10000
    httpx:
      enabled: true
      timeout: 60
      threads: 50
      follow_redirects: true
    nuclei:
      enabled: true
      timeout: 300
      severity_filter: ["info", "low", "medium", "high", "critical"]
      rate_limit: 100
    ffuf:
      enabled: true
      timeout: 120
      threads: 40
      filter_codes: ["404"]
    sqlmap:
      enabled: false
      timeout: 600
      level: 3
      risk: 2
    naabu:
      enabled: true
      timeout: 120
      top_ports: 1000

  # Reporting
  reporting:
    auto_generate: true
    format: "json"
    include_raw_output: false
    screenshot_findings: true

  # Rate Limiting
  rate_limiting:
    global_rps: 100
    per_target_rps: 20
    per_tool_rps: 50
    backoff_on_429: true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_AUTO_PIPELINE_MAX` | 5 | Maximum concurrent pipelines |
| `BRAIN_AUTO_TIMEOUT` | 300 | Default step timeout seconds |
| `BRAIN_AUTO_RETRY_MAX` | 3 | Maximum retry attempts |
| `BRAIN_AUTO_RATE_LIMIT` | 100 | Global requests per second |
| `BRAIN_AUTO_REPORT_DIR` | `./reports` | Report output directory |

## Configuration Precedence

1. Runtime overrides (highest priority)
2. Environment variables
3. Configuration file
4. Built-in defaults (lowest priority)
