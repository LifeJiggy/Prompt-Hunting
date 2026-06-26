# Configuration Types

## Overview

The configuration system provides typed, validated, and composable configuration for all Brain components. Configs are hierarchical, mergeable, and support environment variable overrides.

## Key Components

### AgentConfig

```python
@dataclass
class AgentConfig:
    agent_id: str
    agent_type: AgentType
    model: str = "gpt-4"
    temperature: float = 0.7
    max_tokens: int = 4096
    tools: list[str] = field(default_factory=list)
    timeout_seconds: float = 30.0
    retry_policy: RetryPolicy = field(default_factory=RetryPolicy)
    memory_config: MemoryConfig | None = None
```

### RuntimeConfig

```python
@dataclass
class RuntimeConfig:
    environment: str  # development | staging | production
    debug: bool = False
    log_level: str = "INFO"
    max_agents: int = 10
    event_bus: EventConfig = field(default_factory=EventConfig)
    session: SessionConfig = field(default_factory=SessionConfig)
```

### MemoryConfig

```python
@dataclass
class MemoryConfig:
    backend: str  # memory | redis | postgres
    max_entries: int = 10000
    ttl_seconds: int = 3600
    eviction_policy: str = "lru"
    namespace: str = "default"
```

### SessionConfig

```python
@dataclass
class SessionConfig:
    max_concurrent: int = 5
    timeout_seconds: float = 300.0
    auto_cleanup: bool = True
    persistence: str = "memory"  # memory | redis | file
```

### ToolConfig

```python
@dataclass
class ToolConfig:
    tool_id: str
    tool_type: str
    enabled: bool = True
    timeout_seconds: float = 10.0
    parameters: dict[str, Any] = field(default_factory=dict)
    permissions: list[str] = field(default_factory=list)
```

## Config Validation

Configs validate on instantiation:

```python
config = AgentConfig(agent_id="scanner-01", agent_type=AgentType.REACTIVE)
# Raises ConfigError if:
# - temperature < 0 or > 2
# - max_tokens < 1
# - model is empty
# - timeout_seconds < 0
```

Validation rules:
- Required fields: non-empty strings, valid enums
- Numeric ranges: temperature [0, 2], tokens > 0, timeout > 0
- Referential integrity: tool IDs must exist in the tool registry
- Composability: child configs must not reference parent components

## Config Merging

Configs merge with explicit precedence:

```python
base = RuntimeConfig(environment="development", debug=True)
override = RuntimeConfig(debug=False, log_level="DEBUG")

merged = merge_configs(base, override)
# Result: debug=False, log_level="DEBUG", environment="development"
```

Merge rules:
- Later configs override earlier
- Nested dicts merge recursively
- Lists replace (not append)
- `None` values are ignored (don't override)

## Environment Variable Overrides

Any config field can be overridden via environment variables:

```
BRAIN_AGENT_MODEL=gpt-4-turbo
BRAIN_MEMORY_BACKEND=redis
BRAIN_RUNTIME_DEBUG=true
BRAIN_SESSION_MAX_CONCURRENT=10
```

Pattern: `BRAIN_{CONFIG_CLASS}_{FIELD_NAME}` uppercased.

## Usage Examples

```python
# Load from YAML
config = load_config("runtime.yaml")

# Override with env vars
config = apply_env_overrides(config)

# Validate
validate_config(config)

# Merge agent-specific config
agent_config = merge_configs(config.agents["scanner"], user_overrides)
```

## Design Notes

- Configs are frozen after validation (immutable)
- Environment overrides take highest precedence
- Config files support YAML and JSON formats
- Secrets are never stored in config files; use environment variables or secret managers
- Config changes emit a `CONFIG_CHANGED` event through the EventBus
