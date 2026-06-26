# Events: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Event Definitions

Events for the vulnerability chaining subsystem. These events track chain discovery, design, execution, and impact demonstration.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `chain.opportunity` | `{finding_a, finding_b, potential_impact}` | Two vulns may chain |
| `chain.discovered` | `{chain_id, steps[], primitives[]}` | Complete chain identified |
| `chain.design.started` | `{chain_id, target_impact}` | Chain design began |
| `chain.design.completed` | `{chain_id, exploitation_path}` | Chain design finished |
| `chain.execution.started` | `{chain_id, current_step}` | Chain exploitation began |
| `chain.step.completed` | `{chain_id, step_id, output}` | Chain step succeeded |
| `chain.step.failed` | `{chain_id, step_id, error}` | Chain step failed |
| `chain.execution.completed` | `{chain_id, impact_demonstrated}` | Full chain executed |
| `chain.impact.confirmed` | `{chain_id, severity, impact_description}` | Critical impact proven |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `automation.finding.discovered` | Automation | Check if finding enables chains |
| `memory.pattern.matched` | Memory | Known chain pattern detected |
| `session.checkpoint` | Session Mgmt | Save chain execution state |

## Event Flow

```
automation.finding.discovered
        │
        ▼
chain.opportunity (if composable)
        │
        ▼
chain.discovered
        │
        ▼
chain.design.started → chain.design.completed
        │
        ▼
chain.execution.started
        │
   step.completed → step.completed → step.completed
        │
        ▼
chain.execution.completed
        │
        ▼
chain.impact.confirmed
```
