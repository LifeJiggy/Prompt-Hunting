# Agent: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Agent Profile

This agent executes the core vulnerability hunting methodology — systematic testing across 50 vulnerability classes with step-by-step exploitation, tool configurations, bypass techniques, and real-world examples.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `vuln_hunting` | Systematic vulnerability discovery methodology |
| `tool_configuration` | Exact commands for Burp, sqlmap, nuclei, etc. |
| `bypass_techniques` | WAF evasion and security control bypass |
| `exploitation` | Step-by-step exploitation for each vuln class |
| `real_world_examples` | Apply disclosed report patterns to targets |

## Interface

```python
class HuntingAgent(BaseAgent):
    name = "core-hunting"
    capabilities = ["vuln_hunting", "tool_configuration", "bypass_techniques"]

    def think(self, context: AgentContext) -> Action:
        """Select vulnerability class to test based on attack surface."""

    def act(self, action: Action) -> ActionResult:
        """Execute hunting methodology — run tools, analyze responses."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Classify finding, determine severity, document exploitation path."""
```

## Configuration

```yaml
agent:
  type: "core-hunting"
  vuln_classes: 50
  test_depth: "thorough"
  bypass_attempts: 3
```

## Integration Points

- Reads target attack surface from `memory/`
- Invokes security tools via `tools/` executor
- Stores findings in `memory/` persistent storage
- Chains findings via `executions/` pipeline
