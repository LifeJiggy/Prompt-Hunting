# Event System Documentation

## Overview

The event system provides decoupled, asynchronous communication between agents and system components. It implements a publish-subscribe pattern with support for synchronous handlers, event filtering, and dead letter handling.

## Key Components

### EventBus

Central hub for event routing. Agents publish events; listeners subscribe to specific types.

```python
class EventBus:
    def __init__(self, config: EventConfig):
        self.listeners: dict[EventType, list[EventListener]] = {}
        self.filters: list[EventFilter] = []
        self.dead_letters: list[DeadLetter] = []
    
    def publish(self, event: Event) -> Result:
        """Route event to all matching listeners."""
        
    def subscribe(self, event_type: EventType, listener: EventListener):
        """Register a listener for an event type."""
        
    def unsubscribe(self, event_type: EventType, listener_id: str):
        """Remove a listener."""
```

### EventListener

```python
class EventListener(ABC):
    @abstractmethod
    def handle(self, event: Event) -> EventResponse:
        """Process an event and optionally return a response."""
        
    @property
    def listener_id(self) -> str: ...
    
    @property
    def priority(self) -> int:
        """Lower value = higher priority. Default 100."""
```

### EventType Registry

```python
class EventType(Enum):
    AGENT_STARTED = "agent.started"
    AGENT_STOPPED = "agent.stopped"
    THOUGHT_PRODUCED = "thought.produced"
    ACTION_REQUESTED = "action.requested"
    ACTION_COMPLETED = "action.completed"
    ACTION_FAILED = "action.failed"
    REFLECTION_PRODUCED = "reflection.produced"
    MEMORY_STORED = "memory.stored"
    MEMORY_RETRIEVED = "memory.retrieved"
    ERROR_OCCURRED = "error.occurred"
    CONFIG_CHANGED = "config.changed"
    SESSION_STARTED = "session.started"
    SESSION_ENDED = "session.ended"
```

### Event Payload

```python
@dataclass
class Event:
    event_id: str
    event_type: EventType
    source: str  # agent_id or component_id
    timestamp: datetime
    payload: dict[str, Any]
    metadata: dict[str, Any] = field(default_factory=dict)
```

## Synchronous vs Asynchronous Handlers

| Mode | Use Case | Behavior |
|------|----------|----------|
| Sync | State-critical events | Block until all handlers complete |
| Async | Non-critical events | Fire-and-forget, handlers run in background |
| Ordered | Sequenced operations | Process events in publish order |
| Concurrent | Parallel processing | Process events concurrently per listener |

## Event Filtering

```python
class EventFilter:
    def __init__(self, filter_fn: Callable[[Event], bool]):
        self.filter_fn = filter_fn
        
    def matches(self, event: Event) -> bool:
        return self.filter_fn(event)

# Example: only events from specific agent
scanner_filter = EventFilter(lambda e: e.source == "scanner-01")
event_bus.add_filter(scanner_filter)
```

## Dead Letter Handling

Events that fail all handlers are placed in the dead letter queue:

```python
@dataclass
class DeadLetter:
    event: Event
    error: Exception
    attempts: int
    timestamp: datetime
    handler_id: str
```

Dead letters are retried with exponential backoff (max 3 attempts). After exhausting retries, they are logged and optionally forwarded to a recovery handler.

## Usage Examples

```python
bus = EventBus(config=EventConfig())

# Subscribe to action events
bus.subscribe(EventType.ACTION_COMPLETED, my_listener)

# Publish an event
bus.publish(Event(
    event_id=str(uuid4()),
    event_type=EventType.AGENT_STARTED,
    source="scanner-01",
    timestamp=datetime.utcnow(),
    payload={"agent_id": "scanner-01", "capabilities": ["scan", "report"]}
))
```

## Design Notes

- Events are immutable after publication
- Listeners must not publish events synchronously (prevents infinite loops)
- Dead letters are stored in memory by default, backed by the memory store
- Event ordering is guaranteed only within a single event type
- The bus supports graceful shutdown: in-flight events complete before termination
