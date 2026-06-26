# Brain Tools

**Component:** Extensible Tool Plugin System

Provides the framework for agents to interact with external systems through a standardized tool interface. Tools enable agents to execute security scanners, make API calls, run scripts, and interact with the operating system — all through a safe, validated, and monitored plugin architecture.

---

## Purpose

Tools extend agent capabilities beyond pure reasoning. The tools subsystem provides:

- **Dynamic registration** — Add new tools at runtime without restart
- **Safe execution** — Timeout enforcement, sandboxing, output capture
- **Input validation** — Schema-based parameter validation before execution
- **Standardized results** — Uniform output format across all tools
- **Tool discovery** — Agents can find available tools by capability
- **Audit logging** — Complete record of all tool invocations

---

## Tool Architecture

```
┌─────────────────────────────────────────────┐
│              TOOL SYSTEM                    │
├──────────┬──────────┬──────────┬────────────┤
│ REGISTRY │ VALIDATOR│ EXECUTOR │  RESULT    │
│          │          │          │  FORMATTER │
│ Discover │ Schema   │ Timeout  │ Standardize│
│ Register │ Check    │ Sandbox  │ Structure  │
│ List     │ Sanitize │ Capture  │ Serialize  │
└──────────┴──────────┴──────────┴────────────┘
```

---

## Tool Interface

Every tool implements the standard interface:

```yaml
tool:
  name: "nuclei"
  version: "3.2.0"
  category: "vulnerability_scanner"
  description: "Nuclei template-based vulnerability scanner"
  capabilities:
    - "vulnerability_scanning"
    - "template_execution"
    - "severity_filtering"
  input_schema:
    type: "object"
    properties:
      targets:
        type: "array"
        items: { type: "string" }
        description: "List of target URLs"
      templates:
        type: "array"
        items: { type: "string" }
        description: "Template paths or IDs"
      severity:
        type: "array"
        items: { type: "string", enum: ["info", "low", "medium", "high", "critical"] }
        description: "Filter by severity"
      rate_limit:
        type: "integer"
        default: 100
        description: "Requests per second"
    required: ["targets"]
  output_schema:
    type: "object"
    properties:
      findings:
        type: "array"
        items:
          type: "object"
          properties:
            template_id: { type: "string" }
            severity: { type: "string" }
            endpoint: { type: "string" }
            matched_at: { type: "string" }
            evidence: { type: "string" }
  config:
    timeout: 300
    retries: 2
    sandbox: true
    allowed_paths: ["/usr/local/bin/nuclei"]
```

---

## Tool Registry

### Registration

```python
# Register a new tool
tool_registry.register(
    name="nuclei",
    tool_class=NucleiTool,
    config={
        "binary_path": "/usr/local/bin/nuclei",
        "template_path": "~/.nuclei-templates",
        "timeout": 300
    }
)

# Register from plugin
tool_registry.register_plugin("./plugins/custom_scanner.py")

# Register multiple tools at once
tool_registry.register_batch([
    {"name": "subfinder", "class": SubfinderTool},
    {"name": "httpx", "class": HttpxTool},
    {"name": "ffuf", "class": FfufTool}
])
```

### Discovery

```python
# Find tools by capability
scanners = tool_registry.find(capability="vulnerability_scanning")

# Find tools by category
recon_tools = tool_registry.find(category="reconnaissance")

# Find tools by name pattern
nuclei_variants = tool_registry.find(name_pattern="nuclei*")

# List all registered tools
all_tools = tool_registry.list()

# Get tool details
tool_info = tool_registry.get("nuclei")
print(tool_info.name)
print(tool_info.version)
print(tool_info.capabilities)
```

---

## Tool Execution

### Execution Flow

```
Tool Invocation Request
        │
        ▼
┌───────────────┐
│ LOOKUP TOOL   │ ← Find tool in registry
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ VALIDATE INPUT│ ← Check against input schema
└───────┬───────┘
        │
   Valid?
   ├── No → Return validation error
   └── Yes
        │
        ▼
┌───────────────┐
│ CHECK POLICY  │ ← Is tool allowed? Rate limit?
└───────┬───────┘
        │
   Allowed?
   ├── No → Return policy violation
   └── Yes
        │
        ▼
┌───────────────┐
│ EXECUTE TOOL  │ ← Run with timeout and sandbox
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ CAPTURE OUTPUT│ ← stdout, stderr, exit code
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ FORMAT RESULT │ ← Standardized output format
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ LOG INVOCATION│ ← Audit trail
└───────────────┘
```

### Execution Example

```python
# Execute a tool
result = tool_executor.run(
    tool="nuclei",
    input={
        "targets": ["https://target.com"],
        "templates": ["cves/"],
        "severity": ["high", "critical"]
    },
    config={
        "timeout": 300,
        "retry": 2
    }
)

# Access results
print(result.status)      # "success" | "error" | "timeout"
print(result.exit_code)   # 0
print(result.stdout)      # Raw output
print(result.findings)    # Parsed findings
print(result.duration)    # 45.2 seconds
print(result.resources)   # CPU/memory used
```

---

## Input Validation

### Schema Validation

All tool inputs are validated against the tool's input schema before execution:

```python
# Validation catches:
# - Missing required fields
# - Wrong types (string where array expected)
# - Invalid enum values
# - Out-of-range numbers
# - Invalid formats (bad URLs, paths)

validation = tool_validator.validate(
    tool="nuclei",
    input={
        "targets": "https://target.com",  # Error: expected array
        "severity": ["invalid_severity"]   # Error: not in enum
    }
)

if not validation.valid:
    print(validation.errors)
    # [
    #   "targets: expected array, got string",
    #   "severity[0]: 'invalid_severity' not in enum [info, low, medium, high, critical]"
    # ]
```

### Input Sanitization

Before validation, inputs are sanitized:

| Sanitization | Action |
|-------------|--------|
| **Path traversal** | Remove `../` sequences |
| **Shell injection** | Escape special characters |
| **Null bytes** | Strip null characters |
| **Encoding** | Normalize unicode |
| **Length** | Truncate to maximum length |

---

## Standardized Results

All tool outputs follow a uniform format:

```yaml
tool_result:
  tool: "nuclei"
  version: "3.2.0"
  status: "success"
  exit_code: 0
  started_at: "2025-01-15T10:30:00Z"
  completed_at: "2025-01-15T10:30:45Z"
  duration_ms: 45200
  input_summary:
    targets: 1
    templates: "cves/"
    severity: ["high", "critical"]
  output:
    stdout: "[full output]"
    stderr: ""
    findings:
      - template_id: "CVE-2024-1234"
        severity: "critical"
        endpoint: "https://target.com/api/v1"
        matched_at: "https://target.com/api/v1/users"
        evidence: "SQL Injection found in search parameter"
        curl_command: "curl 'https://target.com/api/v1/users?search=test'"
      - template_id: "CVE-2024-5678"
        severity: "high"
        endpoint: "https://target.com/admin"
        matched_at: "https://target.com/admin/login"
        evidence: "Admin panel accessible without authentication"
  resources:
    peak_memory_mb: 256
    cpu_time_s: 30.5
    wall_time_s: 45.2
  metadata:
    command: "nuclei -l /tmp/targets.txt -t cves/ -severity high,critical"
    working_dir: "/workspace"
```

---

## Tool Policies

### Access Control

```yaml
tool_policies:
  nuclei:
    allowed: true
    sandbox: true
    timeout: 600
    rate_limit: 10  # executions per minute
    allowed_targets:
      - "*.target.com"
      - "*.example.com"
    blocked_targets:
      - "localhost"
      - "127.0.0.1"
      - "10.0.0.0/8"
  sqlmap:
    allowed: true
    sandbox: true
    timeout: 1800
    rate_limit: 5
    require_approval: true  # Needs human confirmation
  custom_tool:
    allowed: false  # Not registered
```

### Rate Limiting

```python
# Rate limit enforcement
@tool_executor.rate_limit(tool="nuclei", max_per_minute=10)
def run_nuclei(targets):
    return tool_executor.run(tool="nuclei", input={"targets": targets})

# Rate limit status
status = tool_executor.rate_limit_status("nuclei")
print(status.remaining)   # 7
print(status.reset_at)    # "2025-01-15T10:31:00Z"
```

---

## Tool Plugins

### Plugin Structure

```
plugins/
├── nuclei_scanner/
│   ├── __init__.py
│   ├── plugin.json      # Plugin metadata
│   ├── tool.py          # Tool implementation
│   └── schemas/
│       ├── input.json   # Input schema
│       └── output.json  # Output schema
├── custom_fuzzer/
│   ├── plugin.json
│   ├── tool.py
│   └── wordlists/
└── api_tester/
    ├── plugin.json
    ├── tool.py
    └── configs/
```

### Plugin Manifest

```json
{
  "name": "nuclei_scanner",
  "version": "1.0.0",
  "description": "Nuclei vulnerability scanner plugin",
  "author": "brain-team",
  "tool": {
    "name": "nuclei",
    "category": "vulnerability_scanner",
    "capabilities": ["vulnerability_scanning"]
  },
  "dependencies": {
    "binary": "nuclei",
    "min_version": "3.0.0"
  },
  "config": {
    "default_timeout": 300,
    "sandbox": true
  }
}
```

---

## Audit Logging

Every tool invocation is logged for accountability:

```yaml
audit_log:
  - id: "inv_001"
    tool: "nuclei"
    agent: "agent_scanner"
    session: "ses_abc123"
    timestamp: "2025-01-15T10:30:00Z"
    input_hash: "sha256:abc123..."
    status: "success"
    duration_ms: 45200
    findings_count: 2
    exit_code: 0
  - id: "inv_002"
    tool: "sqlmap"
    agent: "agent_exploiter"
    session: "ses_def456"
    timestamp: "2025-01-15T10:35:00Z"
    input_hash: "sha256:def456..."
    status: "timeout"
    duration_ms: 1800000
    exit_code: -1
    error: "Execution exceeded timeout"
```

---

## Integration Points

| Connected Component | Interaction |
|--------------------|-------------|
| `core/` | ToolInput, ToolResult, ToolRegistration types |
| `executions/` | Tools called as execution steps |
| `memory/` | Tools write findings, read past results |
| `runtime/` | Resource limits, sandbox enforcement |
| `session-managements/` | Tool state checkpointed per session |
| `utils/` | Logging, validation, serialization |

---

*Part of the Brain domain — autonomous agent system infrastructure for Prompt-Hunting.*
