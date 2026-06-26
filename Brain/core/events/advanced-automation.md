# Events: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Event Definitions

Events emitted by and consumed by the Advanced-Automation domain. These events drive the automated scanning pipeline lifecycle.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `automation.pipeline.created` | `{pipeline_id, target, steps[]}` | New scan pipeline initialized |
| `automation.pipeline.started` | `{pipeline_id, timestamp}` | Pipeline execution began |
| `automation.pipeline.completed` | `{pipeline_id, findings_count, duration}` | Pipeline finished all steps |
| `automation.pipeline.failed` | `{pipeline_id, failed_step, error}` | Pipeline halted on error |
| `automation.step.started` | `{pipeline_id, step_id, tool}` | Individual step execution began |
| `automation.step.completed` | `{pipeline_id, step_id, output_size}` | Step finished successfully |
| `automation.step.failed` | `{pipeline_id, step_id, error, will_retry}` | Step failed, retry status |
| `automation.tool.invoked` | `{tool_name, target, params}` | External tool called |
| `automation.tool.timeout` | `{tool_name, target, timeout_s}` | Tool exceeded time limit |
| `automation.finding.discovered` | `{finding_id, vuln_type, severity}` | New vulnerability found |
| `automation.report.generated` | `{report_path, format}` | Automated report created |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `recon.asset.discovered` | Reconnaissance | Add target to pipeline |
| `session.checkpoint` | Session Mgmt | Save pipeline state |
| `tool.available` | Tool Registry | Register new scanning tool |
| `runtime.resource.warning` | Runtime | Throttle pipeline concurrency |

## Event Handler Examples

```python
@event_handler("automation.pipeline.created")
def on_pipeline_created(event):
    """Initialize pipeline tracking and resource allocation."""
    pipeline = event.payload
    tracker.register(pipeline["pipeline_id"])
    resource_monitor.allocate(pipeline["steps"])

@event_handler("automation.finding.discovered")
def on_finding_discovered(event):
    """Store finding in memory and check for chaining opportunities."""
    finding = event.payload
    memory.persistent.write(f"finding_{finding['finding_id']}", finding)
    if finding["severity"] in ["high", "critical"]:
        event_bus.emit("chain.opportunity", {"finding": finding})
```

## Event Flow

```
recon.asset.discovered
        │
        ▼
automation.pipeline.created
        │
        ▼
automation.pipeline.started
        │
   ┌────┴────┐
   │         │
step.started  step.started (parallel)
   │         │
   ▼         ▼
step.completed  step.completed
   │         │
   └────┬────┘
        │
        ▼
automation.pipeline.completed
        │
        ▼
automation.finding.discovered (×N)
        │
        ▼
automation.report.generated
```
