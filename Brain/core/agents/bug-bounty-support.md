# Agent: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Agent Profile

This agent serves as the foundational reference system — providing master frameworks, vulnerability detection guidance, exploitation methodology, and reporting templates that support all other hunting agents.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `framework_reference` | Provide comprehensive hunting frameworks |
| `vuln_detection` | Guide vulnerability pattern recognition |
| `exploitation_guidance` | Support PoC development and validation |
| `report_templates` | Supply submission templates and strategies |
| `scope_analysis` | Interpret program rules and boundaries |

## Interface

```python
class SupportAgent(BaseAgent):
    name = "bug-bounty-support"
    capabilities = ["framework_reference", "vuln_detection", "exploitation_guidance"]

    def think(self, context: AgentContext) -> Action:
        """Identify which framework or guidance the current task needs."""

    def act(self, action: Action) -> ActionResult:
        """Provide reference material, methodology, or template."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Track which references are most used, refine library."""
```

## Configuration

```yaml
agent:
  type: "bug-bounty-support"
  knowledge_base: "./support_prompts"
  auto_suggest: true
  context_window: 50000
```

## Integration Points

- Serves reference content to all other agents via `core/events/`
- Reads task context from `memory/`
- Provides templates to `executions/` report generation
