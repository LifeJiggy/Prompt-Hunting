# Agent: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Agent Profile

This agent handles program selection, ROI analysis, and strategic planning for bug bounty hunting — choosing the right programs, allocating time effectively, and maximizing earnings.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `program_discovery` | Find and catalog available programs |
| `program_scoring` | Rank programs by ROI potential |
| `time_allocation` | Optimize time distribution across programs |
| `reward_analysis` | Track bounty patterns and negotiate |
| `relationship_management` | Maintain program engagement history |

## Interface

```python
class StrategyAgent(BaseAgent):
    name = "bug-bounty-strategy"
    capabilities = ["program_discovery", "program_scoring", "time_allocation"]

    def think(self, context: AgentContext) -> Action:
        """Evaluate program portfolio, identify highest-ROI targets."""

    def act(self, action: Action) -> ActionResult:
        """Update program scores, adjust time allocation."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Analyze bounty outcomes, refine scoring model."""
```

## Configuration

```yaml
agent:
  type: "bug-bounty-strategy"
  scoring_weights:
    bounty_range: 0.4
    response_time: 0.2
    competition: 0.2
    scope_clarity: 0.2
  review_interval: 86400
```

## Integration Points

- Stores program data in `memory/` persistent storage
- Receives bounty outcomes via `core/events/`
- Generates strategy reports through `executions/`
