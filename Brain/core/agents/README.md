# Agent Interface Definitions

## Overview

The agent system defines the core interface and lifecycle for all agents within the Brain framework. Agents are autonomous units that perceive, decide, and act within the system. Every agent implements the `BaseAgent` interface and follows a standardized lifecycle.

## Key Components

### BaseAgent Interface

```python
class BaseAgent(ABC):
    @abstractmethod
    def think(self, observation: dict) -> Thought:
        """Analyze observation and produce internal reasoning."""
        
    @abstractmethod
    def act(self, thought: Thought) -> Action:
        """Execute an action based on reasoning."""
        
    @abstractmethod
    def reflect(self, action: Action, outcome: Outcome) -> Reflection:
        """Evaluate the outcome and update internal state."""
```

### ReactiveAgent

Responds immediately to stimuli. No planning horizon. Stateless between events.

```python
class ReactiveAgent(BaseAgent):
    def __init__(self, agent_id: str, config: AgentConfig):
        self.agent_id = agent_id
        self.config = config
        self.handlers: dict[EventType, Callable] = {}
```

### ProactiveAgent

Maintains goals, plans actions over time, can initiate behavior without external triggers.

```python
class ProactiveAgent(BaseAgent):
    def __init__(self, agent_id: str, config: AgentConfig):
        self.agent_id = agent_id
        self.config = config
        self.goals: list[Goal] = []
        self.plan: Plan | None = None
```

## Agent Lifecycle

```
INITIALIZED → READY → THINKING → ACTING → REFLECTING → READY
                  ↑                                      |
                  └──────────────────────────────────────┘
```

1. **INITIALIZED** — Agent created, config loaded
2. **READY** — Waiting for input or trigger
3. **THINKING** — Processing observation via `think()`
4. **ACTING** — Executing decision via `act()`
5. **REFLECTING** — Evaluating result via `reflect()`

## Capability Declarations

Agents declare capabilities through metadata:

```python
@dataclass
class Capability:
    name: str
    description: str
    required_tools: list[str]
    supported_event_types: list[EventType]
    max_concurrency: int = 1
```

Agents register capabilities during initialization. The EventBus and scheduler use these to route work appropriately.

## Agent Configuration

```python
@dataclass
class AgentConfig:
    agent_id: str
    agent_type: AgentType  # REACTIVE | PROACTIVE | HYBRID
    model: str
    temperature: float = 0.7
    max_tokens: int = 4096
    tools: list[str] = field(default_factory=list)
    timeout_seconds: float = 30.0
    retry_policy: RetryPolicy = field(default_factory=RetryPolicy)
```

## Usage Examples

```python
agent = ReactiveAgent(
    agent_id="scanner-01",
    config=AgentConfig(agent_type=AgentType.REACTIVE, model="gpt-4")
)

thought = agent.think({"type": "SCAN_REQUEST", "target": "example.com"})
action = agent.act(thought)
reflection = agent.reflect(action, outcome)
```

## Design Notes

- Agents are stateless by default; state is externalized to memory stores
- `think()` is pure — no side effects allowed
- `act()` is the only method with side effects
- `reflect()` updates internal state for learning
- Agents are identified by UUID, not by class name
- The system supports agent composition: agents can delegate to sub-agents
