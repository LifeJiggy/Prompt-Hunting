# Structured Logging

## Overview

The `utils/logging` module provides a production-grade structured logging system with support for multiple output destinations, log rotation, contextual metadata, and performance tracking.

## Logger Class

```python
from Brain.utils.logging import Logger

logger = Logger(name="app.service", level="DEBUG")
logger.info("Service started", extra={"port": 8080, "env": "production"})
```

### Initialization

```python
Logger(
    name: str,                    # Logger namespace
    level: str = "INFO",          # Minimum log level
    outputs: list[Output] = None, # Where logs are sent
    formatters: dict = None,      # Custom formatters per output
    context: dict = None,         # Persistent metadata attached to all entries
    rotation: RotationConfig = None  # File rotation settings
)
```

### Log Levels

| Level   | Numeric | When to Use |
|---------|---------|-------------|
| `DEBUG` | 10      | Diagnostic info, variable values, control flow |
| `INFO`  | 20      | Normal operations, startup, config loaded |
| `WARN`  | 30      | Unexpected but recoverable conditions |
| `ERROR` | 40      | Operation failed, needs attention |
| `FATAL` | 50      | Process cannot continue, imminent shutdown |

Level hierarchy: a logger set to `INFO` emits INFO, WARN, ERROR, FATAL but suppresses DEBUG.

```python
logger.debug("Query plan", extra={"plan": query.explain()})
logger.warn("Cache miss ratio high", extra={"ratio": 0.42})
logger.error("Connection failed", exc_info=True)
logger.fatal("Unrecoverable state", extra={"heap": mem usage})
```

## Structured Log Entries

Every log call produces a structured entry (dict/JSON), not a plain string:

```json
{
  "timestamp": "2026-06-25T14:30:00.123Z",
  "level": "INFO",
  "logger": "app.auth",
  "message": "User authenticated",
  "context": {
    "request_id": "req-abc-123",
    "service": "auth-api"
  },
  "data": {
    "user_id": 4821,
    "method": "oauth2",
    "duration_ms": 34
  }
}
```

### Entry Fields

- `timestamp` — ISO 8601 with millisecond precision, UTC by default
- `level` — Severity label
- `logger` — Namespace that produced the entry
- `message` — Human-readable description
- `context` — Persistent metadata from Logger config (request_id, service name, etc.)
- `data` — Ad-hoc payload passed via `extra=`
- `exception` — Stack trace if `exc_info=True` or exception was caught

## Log Outputs

### Console Output

```python
from Brain.utils.logging.outputs import ConsoleOutput

ConsoleOutput(
    stream="stdout",        # or "stderr"
    colorize=True,          # ANSI color codes by level
    format="pretty"         # "pretty" | "json" | "minimal"
)
```

### File Output

```python
from Brain.utils.logging.outputs import FileOutput

FileOutput(
    path="/var/log/app/service.log",
    format="json",
    append=True,
    encoding="utf-8"
)
```

### Syslog Output

```python
from Brain.utils.logging.outputs import SyslogOutput

SyslogOutput(
    address=("localhost", 514),  # (host, port) or Unix socket path
    facility="local0",
    sock_type="udp"              # or "tcp"
)
```

### HTTP Output

```python
from Brain.utils.logging.outputs import HTTPOutput

HTTPOutput(
    url="https://log-collector.internal/ingest",
    method="POST",
    headers={"Authorization": "Bearer ${LOG_TOKEN}"},
    batch_size=50,          # Buffer entries before sending
    flush_interval=5.0,     # Seconds between flushes
    timeout=10.0,
    retry_attempts=3
)
```

## Log Rotation

Prevents unbounded log file growth:

```python
from Brain.utils.logging import RotationConfig

RotationConfig(
    max_bytes=10_000_000,       # Rotate after 10 MB
    backup_count=5,             # Keep 5 old files
    rotation="size",            # "size" | "time" | "interval"
    interval="daily",           # For time/interval: "hourly" | "daily" | "weekly"
    compress_backups=True       # gzip old files
)
```

Rotation produces files like:
```
service.log
service.log.1
service.log.2
service.log.3.gz
service.log.4.gz
service.log.5.gz
```

## Contextual Logging

Attach persistent context to a logger so every entry carries it automatically:

```python
logger = Logger(name="request", context={
    "request_id": "req-7f3a",
    "user_id": 4821,
    "trace_id": "abc-123-def"
})

logger.info("Processing order")  # context fields included automatically
logger.info("Order completed", extra={"order_id": 9921})  # merged with extra
```

### Child Loggers

```python
child = logger.child("payments", context={"provider": "stripe"})
child.info("Charge created")  # includes both parent and child context
```

### Context Propagation

```python
with logger.context_scope(request_id="req-new"):
    logger.info("Scoped entry")  # uses "req-new"
    helper.do_work()
logger.info("Back to original context")
```

## Performance Logging

Track timing and resource usage alongside log entries:

```python
from Brain.utils.logging import PerfTimer

with PerfTimer(logger, "database.query", extra={"table": "users"}):
    results = db.execute(query)
# Emits: {"message": "database.query completed", "duration_ms": 42.7, "status": "ok"}

with PerfTimer(logger, "api.call", raise_on_error=False) as timer:
    response = http.get(url)
    timer.add_metric("status_code", response.status_code)
    timer.add_metric("body_bytes", len(response.content))
```

### Manual Timing

```python
timer = logger.start_timer("build.process")
# ... work ...
timer.stop(extra={"items_processed": 150})
```

## Configuration Example

```python
from Brain.utils.logging import Logger, RotationConfig
from Brain.utils.logging.outputs import ConsoleOutput, FileOutput, HTTPOutput

logger = Logger(
    name="app",
    level="INFO",
    outputs=[
        ConsoleOutput(colorize=True, format="minimal"),
        FileOutput(
            path="logs/app.log",
            format="json",
            rotation=RotationConfig(max_bytes=50_000_000, backup_count=10)
        ),
        HTTPOutput(url="https://collector.internal/ingest", batch_size=100)
    ],
    context={"service": "my-app", "version": "2.1.0"}
)
```
