# Tool Plugin Development Guide

**Component:** Plugin Architecture for Extending Agent Capabilities

This guide explains how to create, configure, test, and register tool plugins for the Brain system. Plugins are self-contained packages that add new tool capabilities without modifying core code.

---

## Plugin Structure

Every tool plugin follows a standardized directory layout:

```
plugins/
└── my_scanner/
    ├── __init__.py         # Package marker, exports tool class
    ├── plugin.json         # Plugin manifest (required)
    ├── tool.py             # Tool implementation (required)
    ├── schemas/
    │   ├── input.json      # Input JSON Schema
    │   └── output.json     # Output JSON Schema
    ├── tests/
    │   ├── test_tool.py    # Unit tests
    │   └── fixtures/       # Test data
    └── README.md           # Plugin documentation
```

### Minimal Plugin

The smallest viable plugin requires two files:

```
plugins/
└── echo/
    ├── plugin.json
    └── tool.py
```

---

## Plugin Manifest

The `plugin.json` file declares plugin metadata and tool configuration:

```json
{
  "name": "nuclei_scanner",
  "version": "1.0.0",
  "description": "Template-based vulnerability scanner plugin",
  "author": "brain-team",
  "license": "MIT",
  "homepage": "https://github.com/brain-team/brain-nuclei",

  "tool": {
    "name": "nuclei",
    "version": "3.2.0",
    "category": "vulnerability_scanner",
    "description": "Nuclei template-based vulnerability scanner",
    "capabilities": [
      "vulnerability_scanning",
      "template_execution",
      "severity_filtering"
    ],
    "tags": ["scanner", "active", "network", "templates"]
  },

  "dependencies": {
    "binary": {
      "name": "nuclei",
      "min_version": "3.0.0",
      "install_command": "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    },
    "python_requires": ">=3.9",
    "pip_packages": []
  },

  "config": {
    "default_timeout": 300,
    "sandbox": true,
    "rate_limit": 10,
    "max_concurrent": 2
  },

  "lifecycle": {
    "on_register": "on_register",
    "on_unregister": "on_unregister",
    "on_enable": "on_enable",
    "on_disable": "on_disable"
  }
}
```

### Manifest Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique plugin identifier |
| `version` | Yes | Semver version string |
| `description` | Yes | Human-readable description |
| `author` | No | Plugin author name |
| `license` | No | License identifier (SPDX) |
| `tool.name` | Yes | Tool name used in registry |
| `tool.version` | Yes | Tool version string |
| `tool.category` | Yes | Category for discovery |
| `tool.capabilities` | Yes | Capability strings |
| `dependencies` | No | External dependency requirements |
| `config` | No | Default configuration values |
| `lifecycle` | No | Lifecycle hook function names |

---

## Tool Interface Implementation

### Base Class

All tools extend `ToolBase`:

```python
from brain.tools.base import ToolBase, ToolResult

class MyScannerTool(ToolBase):
    """
    Tool implementation for MyScanner.
    
    Must implement execute() and declare class-level schema attributes.
    """
    
    # Class-level declarations (also in plugin.json)
    name = "my_scanner"
    version = "1.0.0"
    category = "vulnerability_scanner"
    description = "Custom vulnerability scanner"
    capabilities = ["vulnerability_scanning", "custom_checks"]
    
    # Input and output schemas (JSON Schema dicts)
    input_schema = {
        "type": "object",
        "properties": {
            "targets": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Target URLs to scan"
            },
            "checks": {
                "type": "array",
                "items": {"type": "string"},
                "description": "Check IDs to run"
            }
        },
        "required": ["targets"]
    }
    
    output_schema = {
        "type": "object",
        "properties": {
            "findings": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "check_id": {"type": "string"},
                        "severity": {"type": "string"},
                        "endpoint": {"type": "string"},
                        "evidence": {"type": "string"}
                    }
                }
            }
        }
    }
    
    def __init__(self, config: dict = None):
        super().__init__(config)
        self.binary_path = config.get("binary_path", "my_scanner")
        self.template_dir = config.get("template_dir", "./templates")
    
    def execute(self, input: dict, context: dict = None) -> ToolResult:
        """
        Execute the tool with validated input.
        
        Args:
            input: Validated input parameters
            context: Execution context (session, agent info)
        
        Returns:
            ToolResult with status and output
        """
        targets = input["targets"]
        checks = input.get("checks", [])
        
        # Build command
        cmd = self._build_command(targets, checks)
        
        # Run the binary
        proc_result = self._run_process(cmd, timeout=self.config.get("timeout", 300))
        
        # Parse output
        findings = self._parse_output(proc_result.stdout)
        
        return ToolResult(
            status="success" if proc_result.exit_code == 0 else "error",
            exit_code=proc_result.exit_code,
            stdout=proc_result.stdout,
            stderr=proc_result.stderr,
            output={"findings": findings},
            duration_ms=proc_result.duration_ms
        )
    
    def _build_command(self, targets: list[str], checks: list[str]) -> list[str]:
        cmd = [self.binary_path]
        for target in targets:
            cmd.extend(["-target", target])
        for check in checks:
            cmd.extend(["-check", check])
        return cmd
    
    def _parse_output(self, stdout: str) -> list[dict]:
        # Parse tool-specific output format
        findings = []
        for line in stdout.strip().split("\n"):
            if line:
                findings.append(self._parse_finding_line(line))
        return findings
```

### Lifecycle Hooks

Plugins can define lifecycle hooks that run at registration events:

```python
def on_register(tool_class, registry, config):
    """Called after tool is registered."""
    # Verify binary exists
    import shutil
    binary = config.get("binary_path", tool_class.name)
    if not shutil.which(binary):
        raise PluginError(f"Binary not found: {binary}")
    
    # Download templates if needed
    template_dir = config.get("template_dir")
    if template_dir and not os.path.exists(template_dir):
        _download_templates(template_dir)

def on_unregister(tool_class, registry):
    """Called before tool is removed."""
    # Clean up temporary files
    _cleanup_temp_files()

def on_enable(tool_class, registry):
    """Called when tool status changes to active."""
    pass

def on_disable(tool_class, registry):
    """Called when tool status changes to disabled."""
    pass
```

---

## Input/Output Schemas

### Input Schema

Defines what the tool accepts:

```json
{
  "type": "object",
  "properties": {
    "targets": {
      "type": "array",
      "items": {"type": "string", "format": "uri"},
      "minItems": 1,
      "maxItems": 1000,
      "description": "Target URLs to scan"
    },
    "templates": {
      "type": "array",
      "items": {"type": "string"},
      "default": ["cves/", "misconfigurations/"],
      "description": "Template paths or IDs"
    },
    "severity": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["info", "low", "medium", "high", "critical"]
      },
      "default": ["medium", "high", "critical"],
      "description": "Filter by severity level"
    },
    "rate_limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000,
      "default": 100,
      "description": "Requests per second"
    },
    "output_format": {
      "type": "string",
      "enum": ["json", "yaml", "csv"],
      "default": "json",
      "description": "Output format"
    }
  },
  "required": ["targets"],
  "additionalProperties": false
}
```

### Output Schema

Defines what the tool produces:

```json
{
  "type": "object",
  "properties": {
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "template_id": {"type": "string"},
          "severity": {"type": "string"},
          "endpoint": {"type": "string", "format": "uri"},
          "matched_at": {"type": "string"},
          "evidence": {"type": "string"},
          "curl_command": {"type": "string"},
          "reference": {
            "type": "array",
            "items": {"type": "string", "format": "uri"}
          }
        },
        "required": ["template_id", "severity", "endpoint"]
      }
    },
    "summary": {
      "type": "object",
      "properties": {
        "total_findings": {"type": "integer"},
        "by_severity": {
          "type": "object",
          "properties": {
            "info": {"type": "integer"},
            "low": {"type": "integer"},
            "medium": {"type": "integer"},
            "high": {"type": "integer"},
            "critical": {"type": "integer"}
          }
        }
      }
    }
  }
}
```

---

## Registering Plugins

### From Directory

```python
from brain.tools.registry import ToolRegistry

registry = ToolRegistry()

# Register a single plugin
registration = registry.register_plugin("./plugins/nuclei_scanner/")

# Register with config overrides
registration = registry.register_plugin(
    "./plugins/nuclei_scanner/",
    config={
        "binary_path": "/custom/path/nuclei",
        "timeout": 600
    }
)
```

### From Python Class

```python
from plugins.my_scanner.tool import MyScannerTool

registry.register(
    name="my_scanner",
    tool_class=MyScannerTool,
    config={"binary_path": "/usr/local/bin/my_scanner"}
)
```

### Batch Registration

```python
registry.register_batch([
    {"name": "subfinder", "class": SubfinderTool, "config": {"binary_path": "/usr/local/bin/subfinder"}},
    {"name": "httpx", "class": HttpxTool, "config": {"binary_path": "/usr/local/bin/httpx"}},
    {"name": "ffuf", "class": FfufTool, "config": {"binary_path": "/usr/local/bin/ffuf"}}
])
```

### Auto-Discovery

```python
# Scan plugin directories and register all found plugins
registry.auto_discover(directories=[
    "./plugins/",
    "/opt/brain/plugins/",
    "~/.brain/plugins/"
])
```

---

## Testing Plugins

### Unit Test Template

```python
import pytest
from plugins.my_scanner.tool import MyScannerTool

@pytest.fixture
def tool():
    return MyScannerTool(config={
        "binary_path": "echo",  # Use echo for testing
        "timeout": 5
    })

class TestMyScannerTool:
    def test_execute_success(self, tool):
        result = tool.execute(input={
            "targets": ["https://example.com"]
        })
        assert result.status == "success"
        assert result.exit_code == 0
    
    def test_execute_with_checks(self, tool):
        result = tool.execute(input={
            "targets": ["https://example.com"],
            "checks": ["check1", "check2"]
        })
        assert result.status == "success"
    
    def test_input_validation_rejects_missing_targets(self, tool):
        with pytest.raises(ValidationError):
            tool.validate_input({})
    
    def test_output_parsing(self, tool):
        output = tool._parse_output("finding1\nfinding2\n")
        assert len(output) == 2
    
    def test_command_building(self, tool):
        cmd = tool._build_command(
            targets=["https://a.com", "https://b.com"],
            checks=["check1"]
        )
        assert "-target" in cmd
        assert "https://a.com" in cmd
```

### Integration Test

```python
import pytest
from brain.tools.registry import ToolRegistry
from brain.tools.executor import ToolExecutor
from brain.tools.validators import ToolValidator

@pytest.fixture
def system():
    registry = ToolRegistry()
    validator = ToolValidator()
    executor = ToolExecutor()
    
    # Connect components
    executor.set_registry(registry)
    executor.set_validator(validator)
    
    # Register the plugin
    registry.register_plugin("./plugins/my_scanner/")
    
    return {"registry": registry, "executor": executor, "validator": validator}

class TestMyScannerIntegration:
    def test_end_to_end(self, system):
        result = system["executor"].run(
            tool="my_scanner",
            input={"targets": ["https://example.com"]}
        )
        assert result.status in ("success", "error")
        assert result.duration_ms > 0
```

---

## Plugin Lifecycle

```
Plugin Directory Detected
        │
        ▼
┌───────────────────┐
│ LOAD manifest     │ ← Read plugin.json
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ VALIDATE manifest │ ← Check required fields
└────────┬──────────┘
         │
    Valid?
    ├── No → Skip plugin, log warning
    └── Yes
         │
         ▼
┌───────────────────┐
│ LOAD tool class   │ ← Import tool.py
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ CHECK dependencies│ ← Verify binary, pip packages
└────────┬──────────┘
         │
    Met?
    ├── No → Mark as "missing_deps", log warning
    └── Yes
         │
         ▼
┌───────────────────┐
│ REGISTER tool     │ ← Add to ToolRegistry
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ RUN on_register   │ ← Execute lifecycle hook
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Tool is ACTIVE    │ ← Available for execution
└───────────────────┘
```

### Lifecycle States

| State | Description |
|-------|-------------|
| `discovered` | Plugin directory found, manifest loaded |
| `loading` | Importing tool class |
| `registering` | Adding to registry |
| `active` | Tool is available for execution |
| `disabled` | Tool temporarily unavailable |
| `error` | Tool encountered an error |
| `missing_deps` | Required dependencies not met |

---

## Best Practices

### Plugin Design

1. **Single tool per plugin** — Each plugin package should provide one tool
2. **Declare all schemas** — Both input and output schemas must be complete
3. **Handle timeouts gracefully** — Tools should clean up on SIGTERM
4. **Use structured output** — Parse tool output into structured findings
5. **Log verbosely** — Use the Brain logger for debug information

### Error Handling

1. **Return ToolResult, don't raise** — Execution errors return status="error"
2. **Include stderr** — Always capture and return stderr for debugging
3. **Set exit codes** — Use non-zero exit codes for tool-specific errors
4. **Validate binary exists** — Check in on_register, fail fast

### Security

1. **Validate all inputs** — Never trust raw user input
2. **Sanitize paths** — Prevent path traversal in file arguments
3. **Use sandbox mode** — Run untrusted tools in sandboxed environments
4. **Rate limit external calls** — Respect API rate limits
5. **Don't log secrets** — Redact tokens and credentials from logs

### Documentation

1. **Include README.md** — Document usage, examples, and configuration
2. **Describe capabilities** — Help agents discover when to use the tool
3. **Provide examples** — Show common usage patterns
4. **Document config options** — List all configurable parameters

---

## Plugin Distribution

Plugins can be distributed as:

1. **Local directories** — Placed in `./plugins/` directory
2. **Python packages** — Installed via pip
3. **Git repositories** — Cloned and registered from URL
4. **Registry entries** — Registered in the Brain plugin registry

```python
# From pip-installed package
registry.register_plugin("pip:brain-plugin-nuclei")

# From git repository
registry.register_plugin("git:https://github.com/brain-team/brain-nuclei.git")

# From local directory
registry.register_plugin("./plugins/nuclei_scanner/")
```

---

*Part of the Brain tools subsystem — Prompt-Hunting.*
