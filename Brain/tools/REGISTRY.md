# Tool Registry Reference

**Component:** Complete API Reference for Tool Registration and Discovery

---

## ToolRegistry Class

### Constructor

```python
ToolRegistry(config: RegistryConfig = None)
```

Creates a new tool registry instance. If no config is provided, uses default settings.

```python
registry = ToolRegistry()

# With custom config
from brain.tools.registry import RegistryConfig

registry = ToolRegistry(config=RegistryConfig(
    auto_discover=False,
    persist_to_disk=True,
    persistence_path="./my_registry.json"
))
```

---

## Registration API

### register()

```python
def register(
    self,
    name: str,
    tool_class: type[ToolBase],
    config: dict = None,
    metadata: dict = None
) -> ToolRegistration
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | `str` | Yes | Unique tool identifier |
| `tool_class` | `type[ToolBase]` | Yes | Tool implementation class |
| `config` | `dict` | No | Tool-specific configuration |
| `metadata` | `dict` | No | Additional metadata |

**Returns:** `ToolRegistration` object

**Raises:**
- `DuplicateToolError` — Tool name already registered
- `InvalidToolClassError` — Class does not extend ToolBase

---

### register_plugin()

```python
def register_plugin(
    self,
    plugin_path: str,
    config: dict = None
) -> ToolRegistration
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `plugin_path` | `str` | Yes | Path to plugin directory or Python module |
| `config` | `dict` | No | Configuration overrides |

**Returns:** `ToolRegistration` object

---

### register_batch()

```python
def register_batch(
    self,
    tools: list[dict]
) -> list[ToolRegistration]
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tools` | `list[dict]` | Yes | List of tool registration dicts |

Each dict must contain at minimum: `{"name": str, "class": type}`

**Returns:** List of `ToolRegistration` objects

---

### unregister()

```python
def unregister(self, name: str) -> bool
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | `str` | Yes | Tool name to remove |

**Returns:** `True` if removed, `False` if not found

**Raises:** `ToolInUseError` if tool has active executions

---

### update()

```python
def update(
    self,
    name: str,
    config: dict = None,
    metadata: dict = None,
    status: str = None
) -> ToolRegistration
```

Update an existing tool's configuration or metadata without re-registration.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | `str` | Yes | Tool name to update |
| `config` | `dict` | No | New configuration (merged with existing) |
| `metadata` | `dict` | No | New metadata (merged with existing) |
| `status` | `str` | No | New status ("active", "disabled", "error") |

---

## Discovery API

### find()

```python
def find(
    self,
    capability: str = None,
    category: str = None,
    name_pattern: str = None,
    tags: list[str] = None
) -> list[ToolRegistration]
```

Search for tools matching criteria. All provided filters are AND-combined.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `capability` | `str` | No | Required capability string |
| `category` | `str` | No | Required category string |
| `name_pattern` | `str` | No | Glob pattern (e.g., `"nuclei*"`) |
| `tags` | `list[str]` | No | All tags must be present |

**Returns:** List of matching `ToolRegistration` objects

**Examples:**

```python
# By capability
scanners = registry.find(capability="vulnerability_scanning")

# By category
recon = registry.find(category="reconnaissance")

# By name pattern
nuclei_variants = registry.find(name_pattern="nuclei*")

# Combined
fast_passive = registry.find(
    category="reconnaissance",
    tags=["passive", "fast"]
)
```

---

### get()

```python
def get(self, name: str) -> ToolRegistration
```

Retrieve a tool by exact name.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | `str` | Yes | Exact tool name |

**Returns:** `ToolRegistration` object

**Raises:** `ToolNotFoundError` if no tool with this name exists

---

### list()

```python
def list(
    self,
    category: str = None,
    status: str = None,
    sort_by: str = "name"
) -> list[ToolRegistration]
```

List all registered tools.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `category` | `str` | No | Filter by category |
| `status` | `str` | No | Filter by status |
| `sort_by` | `str` | No | Sort key: "name", "category", "registered_at" |

**Returns:** Sorted list of all matching `ToolRegistration` objects

---

### has()

```python
def has(self, name: str) -> bool
```

Check if a tool is registered.

**Returns:** `True` if tool exists in registry

---

### count()

```python
def count(self, category: str = None) -> int
```

Count registered tools, optionally filtered by category.

---

## Tool Registration Object

```python
@dataclass
class ToolRegistration:
    id: str                    # Auto-generated UUID
    name: str                  # Tool name
    version: str               # Semver version
    tool_class: type           # Implementation class
    category: str              # Tool category
    capabilities: list[str]    # Capability strings
    description: str           # Human-readable description
    input_schema: dict         # JSON Schema for input
    output_schema: dict        # JSON Schema for output
    config: dict               # Tool configuration
    metadata: dict             # Additional metadata
    registered_at: datetime    # Registration timestamp
    updated_at: datetime       # Last update timestamp
    status: str                # "active" | "disabled" | "error"
```

### Accessing Registration Properties

```python
tool = registry.get("nuclei")

print(tool.name)             # "nuclei"
print(tool.version)          # "3.2.0"
print(tool.category)         # "vulnerability_scanner"
print(tool.capabilities)     # ["vulnerability_scanning", ...]
print(tool.description)      # "Template-based vulnerability scanner"
print(tool.input_schema)     # {...}
print(tool.output_schema)    # {...}
print(tool.config)           # {...}
print(tool.status)           # "active"
print(tool.registered_at)    # datetime(2025, 1, 15, 10, 30, 0)
```

---

## Tool Metadata Format

```yaml
tool_metadata:
  # Identity
  name: "nuclei"
  version: "3.2.0"
  category: "vulnerability_scanner"
  description: "Template-based vulnerability scanner"
  
  # Discovery
  capabilities:
    - "vulnerability_scanning"
    - "template_execution"
    - "severity_filtering"
    - "report_generation"
  tags:
    - "scanner"
    - "active"
    - "network"
    - "templates"
  
  # Attribution
  author: "brain-team"
  license: "MIT"
  
  # Dependencies
  dependencies:
    binary:
      name: "nuclei"
      min_version: "3.0.0"
    python_requires: ">=3.9"
    pip_packages: []
  
  # Configuration
  config:
    default_timeout: 300
    sandbox: true
    rate_limit: 10
    max_concurrent: 2
  
  # Lifecycle hooks
  lifecycle:
    on_register: "on_register"
    on_unregister: "on_unregister"
```

---

## Registry Configuration

```python
@dataclass
class RegistryConfig:
    # Auto-discovery
    auto_discover: bool = True
    plugin_directories: list[str] = field(default_factory=lambda: ["./plugins/"])
    scan_interval: int = 60
    
    # Behavior
    allow_duplicate_names: bool = False
    allow_dynamic_registration: bool = True
    max_tools: int = 100
    
    # Persistence
    persist_to_disk: bool = True
    persistence_path: str = "./tool_registry.json"
    
    # Events
    emit_events: bool = True
```

### Configuration Example

```python
registry = ToolRegistry(config=RegistryConfig(
    auto_discover=True,
    plugin_directories=[
        "./plugins/",
        "/opt/brain/plugins/",
        "~/.brain/plugins/"
    ],
    scan_interval=30,
    allow_dynamic_registration=True,
    max_tools=200,
    persist_to_disk=True,
    persistence_path="./data/tool_registry.json"
))
```

---

## Event System

The registry emits events through the core event bus:

| Event | Payload | When |
|-------|---------|------|
| `tool.registered` | `{name, version, category}` | After successful registration |
| `tool.unregistered` | `{name}` | After tool removal |
| `tool.enabled` | `{name}` | Status changed to "active" |
| `tool.disabled` | `{name}` | Status changed to "disabled" |
| `tool.error` | `{name, error}` | Tool entered error state |
| `tool.updated` | `{name, changes}` | Config or metadata updated |

```python
# Subscribe to events
event_bus.on("tool.registered", lambda e: print(f"New tool: {e.data['name']}"))
event_bus.on("tool.error", lambda e: logger.error(f"Tool error: {e.data}"))
```

---

## Thread Safety

| Operation | Lock Type | Concurrent Reads |
|-----------|-----------|-----------------|
| `find()` | None (lock-free) | Yes |
| `get()` | None (lock-free) | Yes |
| `list()` | None (lock-free) | Yes |
| `has()` | None (lock-free) | Yes |
| `register()` | Write lock | No |
| `unregister()` | Write lock | No |
| `update()` | Write lock | No |

---

## Persistence

When `persist_to_disk=True`, the registry saves state to JSON:

```json
{
  "version": "1.0.0",
  "saved_at": "2025-01-15T10:30:00Z",
  "tools": {
    "nuclei": {
      "name": "nuclei",
      "version": "3.2.0",
      "category": "vulnerability_scanner",
      "capabilities": ["vulnerability_scanning"],
      "config": {"timeout": 300},
      "status": "active",
      "registered_at": "2025-01-15T10:00:00Z"
    }
  }
}
```

The registry loads from disk on initialization if the file exists.

---

*Part of the Brain tools subsystem — Prompt-Hunting.*
