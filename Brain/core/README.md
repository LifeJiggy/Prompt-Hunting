# Brain Core

**Component:** Core Types, Interfaces, and Base Classes

The foundational contract layer for the entire Brain domain. Core defines the abstract types, interfaces, event system, configuration schemas, error hierarchy, and type registry that all other Brain components depend on. Nothing in the Brain system operates without these primitives.

---

## Purpose

Core provides the shared vocabulary and structural contracts that enable all Brain subsystems to communicate. It establishes:

- **Agent interfaces** — What an agent is, what it can do, how it responds
- **Event system** — How components communicate asynchronously
- **Configuration types** — How the system is configured and validated
- **Error hierarchy** — How failures are classified and propagated
- **Type registry** — How components discover and reference each other

---

## Key Abstractions

### Agent Interface

The fundamental contract every agent must implement:

```
Agent
├── id: string              — Unique identifier
├── name: string            — Human-readable name
├── capabilities: string[]  — What the agent can do
├── configure(config)       — Initialize with settings
├── execute(task)           — Process a task
├── reset()                 — Clear state
└── destroy()               — Clean shutdown
```

Every agent in the system — whether a simple tool wrapper or a complex reasoning engine — satisfies this interface. This uniformity enables the execution engine to manage agents generically.

### Event System

The event bus decouples components through publish-subscribe messaging:

| Event Type | Purpose | Example |
|-----------|---------|---------|
| `agent.created` | New agent initialized | Agent registration |
| `task.started` | Execution began | Pipeline progress |
| `task.completed` | Execution finished | Result availability |
| `task.failed` | Execution error | Error handling |
| `memory.written` | New data stored | Knowledge update |
| `session.resumed` | Session restored | State recovery |
| `tool.invoked` | External tool called | Audit logging |

Events carry structured payloads and support both synchronous and asynchronous handlers. Handlers can filter by event type, source, or payload content.

### Configuration Schema

All Brain configuration follows a unified schema:

```yaml
brain:
  agent:
    model: "default"
    timeout: 30000
    max_retries: 3
  memory:
    working_size: 10000
    persistent: true
    storage_path: "./memory"
  execution:
    max_concurrent: 5
    queue_size: 100
    retry_policy: "exponential"
  session:
    checkpoint_interval: 300
    max_history: 1000
    isolation: "strict"
  tools:
    timeout: 10000
    sandbox: true
    allowed: ["*"]
```

Configuration is validated at startup against the schema. Invalid configurations fail fast with clear error messages.

### Error Hierarchy

Structured error types enable precise error handling:

```
BrainError (base)
├── ConfigError            — Configuration issues
│   ├── InvalidSchema      — Config does not match schema
│   ├── MissingRequired    — Required config absent
│   └── ReadOnlyField      — Attempting to change locked config
├── ExecutionError         — Task execution failures
│   ├── TimeoutError       — Task exceeded time limit
│   ├── ResourceError      — Insufficient resources
│   └── DependencyError    — Required dependency unavailable
├── MemoryError            — Storage failures
│   ├── StorageFull        — Storage capacity exceeded
│   ├── CorruptData        — Data integrity failure
│   └── IndexError         — Memory index failure
├── SessionError           — Session management failures
│   ├── SessionNotFound    — Referenced session missing
│   ├── CheckpointFailed   — Checkpoint creation failed
│   └── StateCorrupt       — Session state invalid
├── ToolError              — External tool failures
│   ├── ToolNotFound       — Referenced tool missing
│   ├── ToolTimeout        — Tool execution timeout
│   ├── ToolRejected       — Tool rejected input
│   └── SandboxViolation   — Tool attempted restricted action
└── EventError             — Event system failures
    ├── HandlerFailed      — Event handler threw error
    ├── BusFull            — Event queue overflow
    └── DeadHandler        — Handler no longer exists
```

### Type Registry

The type registry enables dynamic component discovery:

```python
# Register a component
registry.register("agent.planner", PlannerAgent)
registry.register("memory.short", WorkingMemory)
registry.register("tool.scanner", NucleiTool)

# Discover components
agent_cls = registry.get("agent.planner")
tool_cls = registry.get("tool.scanner")
```

This allows the system to load components dynamically based on configuration without hard-coded dependencies.

---

## Component Contracts

### Input/Output Contracts

Every Brain component follows standardized I/O patterns:

| Component | Input | Output |
|-----------|-------|--------|
| Agent | TaskDefinition | TaskResult |
| Memory | ReadQuery / WriteRequest | MemoryEntry / Confirmation |
| Tool | ToolInput | ToolResult |
| Session | SessionCommand | SessionState |
| Execution | ExecutionPlan | ExecutionReport |

### Lifecycle Contracts

All components share a lifecycle contract:

```
init → configure → ready → [active] → [paused] → [resuming] → shutdown
```

- **init** — Allocate resources
- **configure** — Apply configuration
- **ready** — Accepting work
- **active** — Processing tasks
- **paused** — Temporarily suspended
- **resuming** — Returning from pause
- **shutdown** — Clean resource release

---

## Dependency Graph

```
                    ┌──────────┐
                    │   CORE   │
                    └────┬─────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
     ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
     │ EXECUTE │   │ MEMORY  │   │  TOOLS  │
     └────┬────┘   └────┬────┘   └────┬────┘
          │              │              │
          └──────────────┼──────────────┘
                         │
                    ┌────▼─────┐
                    │ SESSIONS │
                    └────┬─────┘
                         │
                    ┌────▼─────┐
                    │ RUNTIME  │
                    └────┬─────┘
                         │
                    ┌────▼─────┐
                    │  UTILS   │
                    └──────────┘
```

Core is the root dependency. Every other component imports from Core but Core imports from nothing within Brain.

---

## Design Principles

1. **Interfaces over implementations** — Code to contracts, not concrete classes
2. **Fail fast** — Invalid configuration or state should error immediately
3. **Immutable contracts** — Once defined, interfaces do not change without versioning
4. **Minimal dependencies** — Core depends on nothing; everything depends on Core
5. **Explicit over implicit** — All component interactions are visible and traceable
6. **Event-driven communication** — Components communicate through events, not direct calls
7. **Configuration as data** — All behavior is configurable through structured data

---

## Integration Points

| Downstream Component | Uses Core For |
|---------------------|---------------|
| `executions/` | TaskDefinition, TaskResult, Error hierarchy |
| `memory/` | MemoryEntry, ReadQuery, WriteRequest types |
| `runtime/` | HealthStatus, MetricsReport, ResourceLimits |
| `session-managements/` | SessionState, Checkpoint types |
| `tools/` | ToolInput, ToolResult, ToolRegistration |
| `utils/` | LogEntry, SerializationFormat types |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
