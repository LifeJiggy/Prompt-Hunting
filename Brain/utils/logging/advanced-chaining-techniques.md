# Logging: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Overview

Structured logging for vulnerability chaining captures chain discovery, design, execution, and impact demonstration with full step-by-step context.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "chain_executor"
  domain: "advanced-chaining"
  chain_id: "chain_001"
  message: "Chain step completed"
  data:
    step_id: "step_2"
    primitive: "xss_stored"
    endpoint: "/profile"
    output: "session_token_stolen"
    success: true
```

## Logging API

```python
logger = get_logger("advanced-chaining")
logger.info("Chain discovered", chain_id="chain_001", primitives=2, potential_impact="critical")
logger.info("Chain step completed", chain_id="chain_001", step_id="step_2", success=True)
logger.error("Chain step failed", chain_id="chain_001", step_id="step_3", error="WAF blocked")
logger.info("Chain impact confirmed", chain_id="chain_001", severity="critical", impact="account_takeover")
```

## Domain File References

Logging applies to all 49 files in `Advanced-Chaining-Techniques/` — chain steps, primitives, and impact demonstrations are logged at each stage.
