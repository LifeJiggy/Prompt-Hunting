# Brain Runtime — Configuration Reference

Complete reference for all runtime configuration options. Configuration is loaded from `brain.config.yaml` under the `runtime:` key and can be overridden by environment variables.

---

## Top-Level Runtime Config

```yaml
runtime:
  environment: "production"         # development | staging | production | sandbox
  workspace: "/opt/brain/workspace" # Working directory for agent operations
  temp_dir: "/tmp/brain"            # Temporary file storage
  log_dir: "/var/log/brain"         # Log file directory
  max_concurrent_agents: 10         # Maximum simultaneous agent processes
  graceful_shutdown_timeout: 30     # Seconds to wait during shutdown
  debug: false                      # Enable debug mode
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `environment` | string | `"production"` | Operational environment |
| `workspace` | string | `"/opt/brain/workspace"` | Agent working directory |
| `temp_dir` | string | `"/tmp/brain"` | Temporary file storage |
| `log_dir` | string | `"/var/log/brain"` | Log output directory |
| `max_concurrent_agents` | int | `10` | Max simultaneous agents |
| `graceful_shutdown_timeout` | int | `30` | Shutdown timeout (seconds) |
| `debug` | bool | `false` | Debug mode flag |

---

## Process Lifecycle

```yaml
runtime:
  lifecycle:
    auto_restart: true              # Restart crashed processes automatically
    max_restart_attempts: 3         # Max restart attempts before giving up
    restart_backoff:
      initial_seconds: 5            # Initial wait before first restart
      multiplier: 2                 # Exponential backoff multiplier
      max_seconds: 120              # Maximum backoff duration
    shutdown:
      phase_timeout: 10             # Timeout per shutdown phase (seconds)
      force_kill_after: 30          # Force-kill if graceful fails
    signals:
      SIGTERM: "graceful_shutdown"
      SIGINT: "graceful_shutdown"
      SIGHUP: "reload_config"
      SIGUSR1: "dump_state"
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `auto_restart` | bool | `true` | Auto-restart on crash |
| `max_restart_attempts` | int | `3` | Max restarts before escalation |
| `restart_backoff.initial_seconds` | int | `5` | Initial restart delay |
| `restart_backoff.multiplier` | float | `2.0` | Backoff multiplier |
| `restart_backoff.max_seconds` | int | `120` | Max backoff cap |
| `shutdown.phase_timeout` | int | `10` | Per-phase timeout |
| `shutdown.force_kill_after` | int | `30` | Force-kill timeout |

---

## Resource Monitoring

```yaml
runtime:
  resources:
    tracking_interval: 5            # Seconds between metric samples
    history_retention_days: 30      # Days to keep raw metrics
    per_agent:
      cpu:
        soft_percent: 50            # Warning threshold
        hard_percent: 80            # Throttle threshold
        kill_percent: 95            # Kill threshold
      memory:
        soft_mb: 1024               # Warning threshold
        hard_mb: 2048               # Throttle threshold
        kill_mb: 3072               # Kill threshold
      disk:
        soft_mb: 5120
        hard_mb: 10240
        kill_mb: 15360
      network:
        soft_mbps: 50
        hard_mbps: 100
        kill_mbps: 150
      open_files:
        soft: 256
        hard: 512
        kill: 1024
    global:
      total_cpu_percent: 80
      total_memory_mb: 8192
      total_disk_mb: 51200
      total_network_mbps: 500
    export:
      format: "prometheus"          # prometheus | json | csv
      endpoint: ""                  # Export endpoint URL
      interval: 60                  # Export interval (seconds)
```

---

## Sandbox

```yaml
runtime:
  sandbox:
    enabled: true                   # Enable sandboxed execution
    default_isolation: "namespace"  # none | namespace | container | vm
    container_runtime: "docker"     # docker | podman
    tmp_dir: "/tmp/brain-sandbox"   # Sandbox temp directory
    max_execution_time: 300         # Max execution time (seconds)
    cleanup_on_exit: true           # Clean up after execution
    capture:
      stdout: true
      stderr: true
      filesystem: true
      network: true
      process_tree: true
      max_output_mb: 100
    policies:
      standard:
        filesystem:
          readable: ["/workspace", "/usr/local/lib"]
          writable: ["/tmp/sandbox", "/workspace/output"]
          blocked: ["/etc/passwd", "/etc/shadow", "/root"]
        network:
          outbound_allow: ["*.target.com:443"]
          outbound_block: ["169.254.169.254:*"]
          inbound_block: ["*"]
        process:
          max_children: 10
```

---

## Health Checking

```yaml
runtime:
  health:
    enabled: true                   # Enable health checking
    check_interval: 60             # Seconds between full health checks
    heartbeat:
      enabled: true
      interval_seconds: 5          # Heartbeat send interval
      timeout_seconds: 30          # Heartbeat timeout
      missed_threshold: 3          # Missed before degraded
    auto_recovery:
      enabled: true
      max_attempts: 3              # Max recovery attempts
      backoff:
        initial_seconds: 5
        multiplier: 2
        max_seconds: 120
    dependencies:
      - name: "llm_api"
        type: "http"
        url: "https://api.openai.com/health"
        timeout: 10
        critical: true
      - name: "redis_cache"
        type: "tcp"
        host: "localhost"
        port: 6379
        timeout: 3
        critical: false
    alerts:
      - name: "unhealthy"
        condition: "health.status >= 2"
        severity: "error"
        channels: ["slack"]
      - name: "critical"
        condition: "health.status == 3"
        severity: "critical"
        channels: ["slack", "email", "pager"]
```

---

## Metrics

```yaml
runtime:
  metrics:
    enabled: true
    collection_interval: 10        # Seconds between metric collection
    retention:
      raw:
        granularity: "5s"
        retention_days: 7
      hourly:
        granularity: "1h"
        retention_days: 30
      daily:
        granularity: "1d"
        retention_days: 365
    export:
      format: "prometheus"
      endpoint: "http://localhost:9090/metrics"
      job_name: "brain"
```

---

## Environment Variables

All configuration options can be overridden by environment variables using the prefix `BRAIN_RUNTIME_`:

| Environment Variable | Config Path | Example |
|---------------------|-------------|---------|
| `BRAIN_RUNTIME_ENV` | `runtime.environment` | `BRAIN_RUNTIME_ENV=staging` |
| `BRAIN_RUNTIME_WORKSPACE` | `runtime.workspace` | `BRAIN_RUNTIME_WORKSPACE=/data` |
| `BRAIN_RUNTIME_MAX_AGENTS` | `runtime.max_concurrent_agents` | `BRAIN_RUNTIME_MAX_AGENTS=20` |
| `BRAIN_RUNTIME_SHUTDOWN_TIMEOUT` | `runtime.graceful_shutdown_timeout` | `BRAIN_RUNTIME_SHUTDOWN_TIMEOUT=60` |
| `BRAIN_RUNTIME_SANDBOX_ENABLED` | `runtime.sandbox.enabled` | `BRAIN_RUNTIME_SANDBOX_ENABLED=false` |
| `BRAIN_RUNTIME_HEALTH_ENABLED` | `runtime.health.enabled` | `BRAIN_RUNTIME_HEALTH_ENABLED=false` |
| `BRAIN_RUNTIME_DEBUG` | `runtime.debug` | `BRAIN_RUNTIME_DEBUG=true` |

---

## Configuration Validation

The runtime validates all configuration at startup:

1. **Type checking** — Ensures values match expected types
2. **Range validation** — Verifies numeric values are within acceptable ranges
3. **Dependency checking** — Confirms required services are configured
4. **Policy consistency** — Ensures sandbox policies don't conflict
5. **Path verification** — Checks that configured directories exist or can be created

Invalid configuration fails fast with clear error messages:

```
ConfigError: runtime.resources.per_agent.memory.kill_mb (3072)
  must be greater than hard_mb (2048)
  Current: 3072 > 2048 ✓
ConfigError: runtime.sandbox.max_execution_time (300)
  exceeds lifecycle.shutdown.force_kill_after (30)
  Suggestion: increase force_kill_after or decrease max_execution_time
```

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
