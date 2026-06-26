# Tool Registry

**Component:** Tool Registration and Discovery

Manages the lifecycle of tool registrations within the Brain system. The registry serves as the central catalog where tools are registered, discovered, and managed at runtime.

---

## Overview

The `ToolRegistry` provides dynamic tool management without requiring system restarts. Tools register themselves with metadata, capabilities, and schemas. Agents discover available tools through capability-based queries or direct name lookups.

---

## Core Class: ToolRegistry

```python
class ToolRegistry:
    """
    Central catalog for tool registration and discovery.
    
    Maintains an in-memory store of all registered tools with their
    metadata, schemas, and configuration. Supports dynamic registration,
    removal, and capability-based discovery.
    """
    
    def __init__(self, config: RegistryConfig = None):
        self._tools: dict[str, ToolRegistration] = {}
        self._categories: dict[str, set[str]] = {}
        self._capabilities: dict[str, set[str]] = {}
        self._event_bus = None
```

---

## Registration Methods

### register()

Register a new tool with the registry.

```python
def register(
    self,
    name: str,
    tool_class: type[ToolBase],
    config: dict = None,
    metadata: dict = None
) -> ToolRegistration:
    """
    Register a tool by name and implementation class.
    
    Args:
        name: Unique tool identifier (e.g., "nuclei", "subfinder")
        tool_class: Class implementing ToolBase interface
        config: Tool-specific configuration overrides
        metadata: Additional metadata (author, tags, etc.)
    
    Returns:
        ToolRegistration object with assigned ID and timestamp
    
    Raises:
        DuplicateToolError: If a tool with this name is already registered
        InvalidToolClassError: If tool_class does not implement ToolBase
    """
```

**Example:**

```python
registry = ToolRegistry()

# Basic registration
registration = registry.register(
    name="nuclei",
    tool_class=NucleiTool,
    config={
        "binary_path": "/usr/local/bin/nuclei",
        "timeout": 300
    }
)

# Registration with metadata
registration = registry.register(
    name="subfinder",
    tool_class=SubfinderTool,
    config={"binary_path": "/usr/local/bin/subfinder"},
    metadata={
        "author": "brain-team",
        "tags": ["recon", "subdomain", "passive"],
        "license": "MIT"
    }
)
```

### register_plugin()

Register a tool from a plugin directory or module path.

```python
def register_plugin(
    self,
    plugin_path: str,
    config: dict = None
) -> ToolRegistration:
    """
    Load and register a tool from a plugin package.
    
    The plugin directory must contain:
    - plugin.json (manifest with tool metadata)
    - tool.py (implementation class)
    
    Args:
        plugin_path: Path to plugin directory or Python module
        config: Optional configuration overrides
    
    Returns:
        ToolRegistration from the loaded plugin
    """
```

**Example:**

```python
# From directory path
registry.register_plugin("./plugins/nuclei_scanner/")

# From Python module
registry.register_plugin("brain.tools.plugins.sqlmap_scanner")
```

### register_batch()

Register multiple tools in a single call.

```python
def register_batch(
    self,
    tools: list[dict]
) -> list[ToolRegistration]:
    """
    Register multiple tools at once.
    
    Args:
        tools: List of dicts, each with at least "name" and "class" keys
    
    Returns:
        List of ToolRegistration objects
    """
```

**Example:**

```python
registrations = registry.register_batch([
    {"name": "subfinder", "class": SubfinderTool},
    {"name": "httpx", "class": HttpxTool},
    {"name": "ffuf", "class": FfufTool},
    {"name": "katana", "class": KatanaTool}
])
```

### unregister()

Remove a tool from the registry.

```python
def unregister(self, name: str) -> bool:
    """
    Remove a tool by name.
    
    Args:
        name: Tool identifier to remove
    
    Returns:
        True if the tool was found and removed, False otherwise
    
    Raises:
        ToolInUseError: If the tool has active executions
    """
```

---

## Discovery Methods

### find()

Search for tools matching criteria.

```python
def find(
    self,
    capability: str = None,
    category: str = None,
    name_pattern: str = None,
    tags: list[str] = None
) -> list[ToolRegistration]:
    """
    Find tools matching the given criteria.
    
    All provided filters are AND-combined. A tool must match
    all non-None filters to be included in results.
    
    Args:
        capability: Required capability string
        category: Required category string
        name_pattern: Glob pattern for name matching (e.g., "nuclei*")
        tags: All tags must be present on the tool
    
    Returns:
        List of matching ToolRegistration objects
    """
```

**Examples:**

```python
# Find by capability
scanners = registry.find(capability="vulnerability_scanning")
# Returns: [NucleiTool, SqlmapTool, ...]

# Find by category
recon_tools = registry.find(category="reconnaissance")
# Returns: [SubfinderTool, HttpxTool, KatanaTool, ...]

# Find by name pattern
variants = registry.find(name_pattern="nuclei*")
# Returns: [NucleiTool, NucleiLiteTool, ...]

# Combined filters
active_scanners = registry.find(
    category="reconnaissance",
    tags=["passive", "fast"]
)
```

### get()

Retrieve a specific tool by name.

```python
def get(self, name: str) -> ToolRegistration:
    """
    Get a tool registration by exact name.
    
    Args:
        name: Exact tool identifier
    
    Returns:
        ToolRegistration object
    
    Raises:
        ToolNotFoundError: If no tool with this name exists
    """
```

### list()

List all registered tools.

```python
def list(
    self,
    category: str = None,
    sort_by: str = "name"
) -> list[ToolRegistration]:
    """
    List all registered tools, optionally filtered.
    
    Args:
        category: Filter by category (None for all)
        sort_by: Sort key ("name", "category", "registered_at")
    
    Returns:
        Sorted list of all ToolRegistration objects
    """
```

---

## Tool Registration Object

Each registered tool is represented by a `ToolRegistration` object:

```python
@dataclass
class ToolRegistration:
    id: str                    # Auto-generated unique ID
    name: str                  # Tool name (e.g., "nuclei")
    version: str               # Semver version string
    tool_class: type           # Implementation class reference
    category: str              # Tool category
    capabilities: list[str]    # List of capability strings
    description: str           # Human-readable description
    input_schema: dict         # JSON Schema for input validation
    output_schema: dict        # JSON Schema for output validation
    config: dict               # Tool-specific configuration
    metadata: dict             # Additional metadata
    registered_at: datetime    # Registration timestamp
    status: str                # "active" | "disabled" | "error"
```

---

## Dynamic Registration

Tools can be registered and unregistered at runtime without restarting the agent:

```python
# Agent discovers it needs a new capability
if not registry.find(capability="dns_enumeration"):
    # Register the missing tool dynamically
    from tools.plugins.dnsx_tool import DnsxTool
    registry.register(
        name="dnsx",
        tool_class=DnsxTool,
        config={"binary_path": "/usr/local/bin/dnsx"}
    )

# Disable a tool temporarily
tool = registry.get("nuclei")
tool.status = "disabled"

# Re-enable it
tool.status = "active"
```

### Event Emission

Registry operations emit events through the core event bus:

| Event | When |
|-------|------|
| `tool.registered` | After successful registration |
| `tool.unregistered` | After tool removal |
| `tool.enabled` | After status set to "active" |
| `tool.disabled` | After status set to "disabled" |
| `tool.error` | After tool enters error state |

```python
# Listen for tool registration events
event_bus.on("tool.registered", lambda event: logger.info(
    f"Tool registered: {event.data['name']} v{event.data['version']}"
))
```

---

## Tool Metadata Format

Tools declare metadata that the registry uses for discovery and policy enforcement:

```yaml
tool_metadata:
  name: "nuclei"
  version: "3.2.0"
  category: "vulnerability_scanner"
  description: "Template-based vulnerability scanner"
  capabilities:
    - "vulnerability_scanning"
    - "template_execution"
    - "severity_filtering"
    - "report_generation"
  tags:
    - "scanner"
    - "active"
    - "network"
  author: "brain-team"
  license: "MIT"
  dependencies:
    binary: "nuclei"
    min_version: "3.0.0"
    python_requires: ">=3.9"
  config:
    default_timeout: 300
    sandbox: true
    rate_limit: 10
```

---

## Registry Configuration

```python
@dataclass
class RegistryConfig:
    # Auto-discovery settings
    auto_discover: bool = True
    plugin_directories: list[str] = field(default_factory=lambda: ["./plugins/"])
    scan_interval: int = 60  # Seconds between plugin directory scans
    
    # Behavior settings
    allow_duplicate_names: bool = False
    allow_dynamic_registration: bool = True
    max_tools: int = 100
    
    # Persistence settings
    persist_to_disk: bool = True
    persistence_path: str = "./tool_registry.json"
```

---

## Integration Points

| Component | Interaction |
|-----------|-------------|
| `executor/` | Looks up tools by name before execution |
| `validators/` | Reads input/output schemas from registrations |
| `core/` | Uses ToolRegistration type definitions |
| `runtime/` | Enforces tool policies based on metadata |

---

## Thread Safety

The registry uses a read-write lock pattern. Reads (find, get, list) are lock-free for concurrent access. Writes (register, unregister) acquire an exclusive lock. This ensures agents can discover tools concurrently without contention.

---

*Part of the Brain tools subsystem — Prompt-Hunting.*
