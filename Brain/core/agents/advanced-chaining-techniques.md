# Agent: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Agent Profile

This agent composes individual low/medium-severity vulnerabilities into critical-impact attack chains. It thinks in dependency graphs — every vulnerability is a node, every interaction is an edge.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `chain_discovery` | Identify how individual vulns can be linked |
| `chain_design` | Build exploitation paths from primitives to impact |
| `chain_execution` | Execute multi-step chains maintaining state |
| `impact_amplification` | Demonstrate end-to-end impact from chained findings |

## Interface

```python
class ChainingAgent(BaseAgent):
    name = "advanced-chaining"
    capabilities = ["chain_discovery", "chain_design", "chain_execution"]

    def think(self, context: AgentContext) -> Action:
        """Analyze discovered primitives, identify shortest path to critical impact."""

    def act(self, action: Action) -> ActionResult:
        """Execute chain step — exploit primitive, feed output to next step."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Evaluate chain completion, determine if impact is demonstrable."""
```

## Configuration

```yaml
agent:
  type: "advanced-chaining"
  max_chain_length: 10
  require_demonstration: true
  state_persistence: "per_step"
```

## Integration Points

- Reads vulnerability primitives from `memory/`
- Executes chain steps via `tools/` executor
- Stores intermediate chain state in `session-managements/`
- Emits chain progress events through `core/events/`
