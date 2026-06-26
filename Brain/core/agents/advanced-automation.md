# Agent: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Agent Profile

This agent automates security testing workflows — vulnerability scanning, tool chaining, and CI/CD pipeline construction for bug bounty operations.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `recon_automation` | Automated subdomain enumeration, port scanning, technology fingerprinting |
| `vuln_scanning` | Nuclei template execution, custom scanner deployment |
| `tool_chaining` | Connecting multiple tools into cohesive pipelines |
| `report_generation` | Automated report creation from scan results |
| `pipeline_orchestration` | DAG-based workflow scheduling and execution |

## Interface

```python
class AdvancedAutomationAgent(BaseAgent):
    name = "advanced-automation"
    capabilities = ["recon_automation", "vuln_scanning", "tool_chaining"]

    def think(self, context: AgentContext) -> Action:
        """Determine next automation step based on pipeline state."""

    def act(self, action: Action) -> ActionResult:
        """Execute automation step — run tool, chain output, store results."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Evaluate pipeline progress, adjust scheduling."""
```

## Configuration

```yaml
agent:
  type: "advanced-automation"
  pipeline_depth: 10
  parallel_steps: 5
  timeout_per_step: 300
  retry_policy: "exponential"
```

## Integration Points

- Reads scan targets from `memory/` working storage
- Writes findings to `memory/` persistent storage
- Invokes tools through `tools/` executor
- Reports progress via `core/events/` event bus
