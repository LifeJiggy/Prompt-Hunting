# Advanced Automation — Tool Registry

**Domain:** `advanced-automation`
**Registry Path:** `Brain/tools/registry/advanced-automation.md`
**Source Directory:** `Advanced-Automation/`
**File Count:** 50 domain files

---

## Overview

This tool registry manages the lifecycle of all scanning and automation tools within the Brain system. It provides dynamic registration, discovery, listing, and lifecycle management for tools that automate vulnerability scanning, reconnaissance, fuzzing, and analysis workflows. Every tool registered here maps to one or more files in the `Advanced-Automation/` directory and exposes standardized metadata, input/output schemas, and dependency declarations.

The registry enables agents to discover available automation tools at runtime, chain them together, and orchestrate complex scanning pipelines without requiring system restarts or manual configuration.

---

## Domain Mapping

| Registry Key | Source File | Tool Category | Primary Capability |
|---|---|---|---|
| `subdomain-enum-auto` | `01-Subdomain-Enumeration-Automation.md` | reconnaissance | subdomain_enumeration |
| `port-scan-auto` | `02-Port-Scanning-Automation.md` | reconnaissance | port_scanning |
| `vuln-scan-auto` | `03-Vulnerability-Scanning-Automation.md` | vulnerability_scanning | vulnerability_detection |
| `js-analysis-auto` | `04-JavaScript-Analysis-Automation.md` | analysis | javascript_analysis |
| `api-endpoint-discovery` | `05-API-Endpoint-Discovery.md` | reconnaissance | api_discovery |
| `param-fuzz-auto` | `06-Parameter-Fuzzing-Automation.md` | fuzzing | parameter_fuzzing |
| `dir-brute-auto` | `07-Directory-Brute-Forcing.md` | fuzzing | directory_enumeration |
| `auth-test-auto` | `09-Authentication-Testing-Automation.md` | testing | authentication_testing |
| `session-mgmt-auto` | `10-Session-Management-Testing.md` | testing | session_testing |
| `idor-auto` | `11-IDOR-Detection-Automation.md` | vulnerability_scanning | idor_detection |
| `sqli-auto` | `12-SQL-Injection-Automation.md` | vulnerability_scanning | sql_injection |
| `xss-auto` | `13-XSS-Detection-Automation.md` | vulnerability_scanning | xss_detection |
| `ssrf-auto` | `14-SSRF-Testing-Automation.md` | vulnerability_scanning | ssrf_testing |
| `csrf-auto` | `15-CSRF-Testing-Automation.md` | vulnerability_scanning | csrf_testing |
| `cmdi-auto` | `16-Command-Injection-Automation.md` | vulnerability_scanning | command_injection |
| `xxe-auto` | `17-XXE-Testing-Automation.md` | vulnerability_scanning | xxe_testing |
| `ssti-auto` | `18-SSTI-Testing-Automation.md` | vulnerability_scanning | ssti_testing |
| `jwt-auto` | `19-JWT-Testing-Automation.md` | vulnerability_scanning | jwt_testing |
| `deser-auto` | `20-Deserialization-Testing.md` | vulnerability_scanning | deserialization |
| `report-gen-auto` | `21-Report-Generation-Automation.md` | reporting | report_generation |
| `poc-dev-auto` | `22-PoC-Development-Automation.md` | reporting | poc_development |
| `target-scout-auto` | `23-Target-Scouting-Automation.md` | reconnaissance | target_scouting |
| `scope-val-auto` | `24-Scope-Validation-Automation.md` | validation | scope_validation |
| `asset-track-auto` | `25-Asset-Tracking-Automation.md` | management | asset_tracking |
| `change-mon-auto` | `26-Change-Monitoring-Automation.md` | monitoring | change_detection |
| `notify-alert-auto` | `27-Notification-Alerting-Automation.md` | monitoring | alerting |
| `data-collect-auto` | `28-Data-Collection-Automation.md` | data_collection | data_collection |
| `result-analysis-auto` | `29-Result-Analysis-Automation.md` | analysis | result_analysis |
| `tool-chain-auto` | `30-Tool-Chaining-Automation.md` | orchestration | tool_chaining |
| `proxy-integ-auto` | `31-Proxy-Integration-Automation.md` | integration | proxy_integration |
| `browser-auto` | `32-Browser-Automation-Workflows.md` | automation | browser_automation |
| `headless-browser-auto` | `33-Headless-Browser-Scripting.md` | automation | headless_scripting |
| `regex-auto` | `34-Regex-Pattern-Automation.md` | analysis | regex_parsing |
| `response-analysis-auto` | `35-Response-Analysis-Automation.md` | analysis | response_analysis |
| `header-inject-auto` | `36-Header-Injection-Testing.md` | vulnerability_scanning | header_injection |
| `cors-auto` | `37-CORS-Testing-Automation.md` | vulnerability_scanning | cors_testing |
| `websocket-auto` | `38-WebSocket-Testing-Automation.md` | vulnerability_scanning | websocket_testing |
| `graphql-auto` | `39-GraphQL-Testing-Automation.md` | vulnerability_scanning | graphql_testing |
| `cloud-enum-auto` | `40-Cloud-Service-Enumeration.md` | reconnaissance | cloud_enumeration |
| `dns-extract-auto` | `41-DNS-Data-Extraction-Automation.md` | reconnaissance | dns_extraction |
| `email-recon-auto` | `42-Email-Recon-Automation.md` | reconnaissance | email_recon |
| `social-osint-auto` | `43-Social-Media-OSINT-Automation.md` | reconnaissance | social_osint |
| `framework-detect-auto` | `44-Framework-Detection-Automation.md` | fingerprinting | framework_detection |
| `tech-stack-id-auto` | `45-Technology-Stack-Identification.md` | fingerprinting | tech_stack_identification |
| `endpoint-map-auto` | `46-Endpoint-Mapping-Automation.md` | mapping | endpoint_mapping |
| `content-disc-auto` | `47-Content-Discovery-Automation.md` | discovery | content_discovery |
| `version-detect-auto` | `48-Version-Detection-Automation.md` | fingerprinting | version_detection |
| `compliance-check-auto` | `49-Compliance-Checking-Automation.md` | validation | compliance_checking |
| `workflow-orch-auto` | `50-Workflow-Orchestration-Automation.md` | orchestration | workflow_orchestration |

---

## Tool Registration Schema

Each tool registration follows this schema:

```yaml
tool_registration:
  name: string          # Unique identifier (e.g., "subfinder")
  version: string       # Semver (e.g., "1.0.0")
  category: string      # One of: reconnaissance, vulnerability_scanning, fuzzing, analysis, reporting, monitoring, orchestration, integration, automation, mapping, discovery, fingerprinting, validation, data_collection, management
  capabilities: list[string]  # Capability strings for discovery
  description: string   # Human-readable description
  input_schema: dict    # JSON Schema for input validation
  output_schema: dict   # JSON Schema for output validation
  config: dict          # Tool-specific configuration
  metadata: dict        # Additional metadata (author, tags, license)
  dependencies: dict    # Required binaries, libraries, Python version
  status: enum          # active | disabled | error | pending
  registered_at: datetime
  domain_files: list[string]  # Files this tool maps to in Advanced-Automation/
```

---

## Registered Tools

### Subdomain Enumeration

```python
registry.register(
    name="subfinder",
    tool_class=SubfinderTool,
    config={
        "binary_path": "/usr/local/bin/subfinder",
        "timeout": 300,
        "sources": "all",
        "max_enumeration_time": 10
    },
    metadata={
        "category": "reconnaissance",
        "capabilities": ["subdomain_enumeration", "passive_dns", "certificate_transparency"],
        "description": "Passive subdomain discovery using multiple sources",
        "tags": ["recon", "subdomain", "passive", "fast"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["01-Subdomain-Enumeration-Automation.md"]
    }
)
```

### Port Scanning

```python
registry.register(
    name="naabu",
    tool_class=NaabuTool,
    config={
        "binary_path": "/usr/local/bin/naabu",
        "timeout": 120,
        "top_ports": 1000,
        "rate": 1000
    },
    metadata={
        "category": "reconnaissance",
        "capabilities": ["port_scanning", "service_detection", "fast_scan"],
        "description": "Fast port scanner written in Go",
        "tags": ["recon", "ports", "network", "fast"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["02-Port-Scanning-Automation.md"]
    }
)
```

### HTTP Probing

```python
registry.register(
    name="httpx",
    tool_class=HttpxTool,
    config={
        "binary_path": "/usr/local/bin/httpx",
        "timeout": 30,
        "threads": 50,
        "follow_redirects": True,
        "tech_detect": True
    },
    metadata={
        "category": "reconnaissance",
        "capabilities": ["http_probing", "technology_detection", "status_code_check", "title_extraction"],
        "description": "Fast HTTP toolkit for probing web servers",
        "tags": ["recon", "http", "probing", "tech-detect"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["02-Port-Scanning-Automation.md", "45-Technology-Stack-Identification.md"]
    }
)
```

### Vulnerability Scanning

```python
registry.register(
    name="nuclei",
    tool_class=NucleiTool,
    config={
        "binary_path": "/usr/local/bin/nuclei",
        "timeout": 600,
        "templates": "/usr/local/nuclei-templates",
        "rate_limit": 150,
        "severity": "low,medium,high,critical"
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["vulnerability_scanning", "template_execution", "severity_filtering", "report_generation"],
        "description": "Template-based vulnerability scanner",
        "tags": ["scanner", "active", "network", "templates"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["03-Vulnerability-Scanning-Automation.md"]
    }
)
```

### Directory Fuzzing

```python
registry.register(
    name="ffuf",
    tool_class=FfufTool,
    config={
        "binary_path": "/usr/local/bin/ffuf",
        "timeout": 60,
        "threads": 40,
        "rate": 0,
        "recursion": True,
        "recursion_depth": 2
    },
    metadata={
        "category": "fuzzing",
        "capabilities": ["directory_enumeration", "parameter_fuzzing", "vhost_fuzzing", "filtering"],
        "description": "Fast web fuzzer for directory and parameter discovery",
        "tags": ["fuzzer", "active", "web", "directory"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["06-Parameter-Fuzzing-Automation.md", "07-Directory-Brute-Forcing.md", "47-Content-Discovery-Automation.md"]
    }
)
```

### SQL Injection

```python
registry.register(
    name="sqlmap",
    tool_class=SqlmapTool,
    config={
        "binary_path": "/usr/local/bin/sqlmap",
        "timeout": 600,
        "level": 3,
        "risk": 2,
        "threads": 4,
        "batch": True
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["sql_injection", "database_enumeration", "data_extraction", "privilege_escalation"],
        "description": "Automatic SQL injection and database takeover tool",
        "tags": ["sqli", "active", "database", "exploitation"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["12-SQL-Injection-Automation.md"]
    }
)
```

### XSS Detection

```python
registry.register(
    name="dalfox",
    tool_class=DalfoxTool,
    config={
        "binary_path": "/usr/local/bin/dalfox",
        "timeout": 120,
        "threads": 10,
        "blind": False,
        "silence": True
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["xss_detection", "reflected_xss", "stored_xss", "dom_xss"],
        "description": "Powerful XSS scanning and parameter analysis tool",
        "tags": ["xss", "active", "web", "scanner"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["13-XSS-Detection-Automation.md"]
    }
)
```

### SSRF Testing

```python
registry.register(
    name="ssrf-explorer",
    tool_class=SSRFExplorerTool,
    config={
        "timeout": 60,
        "endpoints_file": None,
        "oob_server": None
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["ssrf_testing", "blind_ssrf", "oob_interaction"],
        "description": "Automated SSRF endpoint discovery and testing",
        "tags": ["ssrf", "active", "web", "oob"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["14-SSRF-Testing-Automation.md"]
    }
)
```

### XXE Testing

```python
registry.register(
    name="xxe-tester",
    tool_class=XXETesterTool,
    config={
        "timeout": 60,
        "payloads": "standard",
        "oob_server": None
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["xxe_testing", "oob_data_extraction", "blind_xxe"],
        "description": "Automated XXE injection testing tool",
        "tags": ["xxe", "active", "xml", "oob"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["17-XXE-Testing-Automation.md"]
    }
)
```

### SSTI Testing

```python
registry.register(
    name="tplmap",
    tool_class=TplmapTool,
    config={
        "binary_path": "/usr/local/bin/tplmap",
        "timeout": 60,
        "os_shell": False
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["ssti_testing", "template_injection", "rce_via_template"],
        "description": "Server-side template injection detection and exploitation",
        "tags": ["ssti", "active", "template", "rce"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["18-SSTI-Testing-Automation.md"]
    }
)
```

### JWT Testing

```python
registry.register(
    name="jwt-tool",
    tool_class=JWTTool,
    config={
        "timeout": 30,
        "wordlist": "/usr/share/wordlists/jwt_secrets.txt"
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["jwt_testing", "jwt_analysis", "algorithm_confusion", "secret_bruteforce"],
        "description": "JSON Web Token security testing and analysis tool",
        "tags": ["jwt", "auth", "token", "crypto"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["19-JWT-Testing-Automation.md"]
    }
)
```

### Deserialization Testing

```python
registry.register(
    name="ysoserial",
    tool_class=YsoserialTool,
    config={
        "binary_path": "/usr/local/bin/ysoserial",
        "timeout": 30
    },
    metadata={
        "category": "vulnerability_scanning",
        "capabilities": ["deserialization", "java_deserialization", "rce_payload_generation"],
        "description": "Java deserialization exploit payload generator",
        "tags": ["deserialization", "java", "exploitation", "rce"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["20-Deserialization-Testing.md"]
    }
)
```

### Browser Automation

```python
registry.register(
    name="playwright-scanner",
    tool_class=PlaywrightScannerTool,
    config={
        "browser": "chromium",
        "headless": True,
        "timeout": 30000
    },
    metadata={
        "category": "automation",
        "capabilities": ["browser_automation", "headless_scripting", "dom_interaction", "screenshot"],
        "description": "Browser-based automation for dynamic web application testing",
        "tags": ["browser", "automation", "dynamic", "playwright"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["32-Browser-Automation-Workflows.md", "33-Headless-Browser-Scripting.md"]
    }
)
```

### Workflow Orchestration

```python
registry.register(
    name="workflow-orchestrator",
    tool_class=WorkflowOrchestratorTool,
    config={
        "max_parallel": 10,
        "retry_count": 3,
        "retry_delay": 5
    },
    metadata={
        "category": "orchestration",
        "capabilities": ["workflow_orchestration", "tool_chaining", "pipeline_management", "parallel_execution"],
        "description": "Orchestrate complex multi-tool scanning workflows",
        "tags": ["orchestration", "pipeline", "chaining", "automation"],
        "author": "brain-team",
        "license": "MIT",
        "domain_files": ["30-Tool-Chaining-Automation.md", "50-Workflow-Orchestration-Automation.md"]
    }
)
```

---

## Register Operation

```python
def register_tool(
    name: str,
    tool_class: type,
    config: dict = None,
    metadata: dict = None
) -> ToolRegistration:
    """
    Register a tool in the advanced-automation domain registry.

    Args:
        name: Unique tool identifier
        tool_class: Implementation class
        config: Tool-specific configuration
        metadata: Additional metadata including domain_files

    Returns:
        ToolRegistration object

    Raises:
        DuplicateToolError: If name already registered
        InvalidToolClassError: If tool_class invalid
        DomainMismatchError: If category not in domain scope
    """
    if name in self._tools:
        raise DuplicateToolError(f"Tool '{name}' already registered")

    registration = ToolRegistration(
        id=generate_id(),
        name=name,
        version=metadata.get("version", "1.0.0"),
        tool_class=tool_class,
        category=metadata.get("category", "unknown"),
        capabilities=metadata.get("capabilities", []),
        description=metadata.get("description", ""),
        input_schema=metadata.get("input_schema", {}),
        output_schema=metadata.get("output_schema", {}),
        config=config or {},
        metadata=metadata or {},
        registered_at=datetime.utcnow(),
        status="active"
    )

    self._tools[name] = registration
    self._index_categories(registration)
    self._index_capabilities(registration)
    self._event_bus.emit("tool.registered", {"name": name, "domain": "advanced-automation"})

    return registration
```

---

## Unregister Operation

```python
def unregister_tool(self, name: str) -> bool:
    """
    Remove a tool from the advanced-automation registry.

    Args:
        name: Tool identifier to remove

    Returns:
        True if removed, False if not found

    Raises:
        ToolInUseError: If tool has active executions
    """
    if name not in self._tools:
        return False

    tool = self._tools[name]

    if tool.status == "in_use":
        raise ToolInUseError(f"Cannot unregister '{name}' — active execution in progress")

    del self._tools[name]
    self._remove_from_categories(tool)
    self._remove_from_capabilities(tool)
    self._event_bus.emit("tool.unregistered", {"name": name, "domain": "advanced-automation"})

    return True
```

---

## Tool Discovery

```python
def discover_by_capability(self, capability: str) -> list[ToolRegistration]:
    """
    Discover tools in the advanced-automation domain by capability.

    Examples:
        discover_by_capability("vulnerability_scanning")
        discover_by_capability("subdomain_enumeration")
        discover_by_capability("directory_enumeration")
    """
    tool_names = self._capabilities.get(capability, set())
    return [self._tools[n] for n in tool_names if self._tools[n].status == "active"]

def discover_by_category(self, category: str) -> list[ToolRegistration]:
    """
    Discover tools by category within the domain.

    Categories: reconnaissance, vulnerability_scanning, fuzzing, analysis,
    reporting, monitoring, orchestration, integration, automation, mapping,
    discovery, fingerprinting, validation, data_collection, management
    """
    tool_names = self._categories.get(category, set())
    return [self._tools[n] for n in tool_names if self._tools[n].status == "active"]

def discover_by_tag(self, tag: str) -> list[ToolRegistration]:
    """Discover tools by tag (e.g., 'passive', 'active', 'fast')."""
    return [
        t for t in self._tools.values()
        if tag in t.metadata.get("tags", []) and t.status == "active"
    ]

def discover_by_domain_file(self, filename: str) -> list[ToolRegistration]:
    """Discover tools that map to a specific domain file."""
    return [
        t for t in self._tools.values()
        if filename in t.metadata.get("domain_files", [])
    ]

def discover_chainable(self, output_capability: str, input_capability: str) -> list[tuple]:
    """
    Discover tools that can be chained together.
    Find tools whose output matches another tool's required input.
    """
    chains = []
    providers = self.discover_by_capability(output_capability)
    consumers = [
        t for t in self._tools.values()
        if input_capability in t.metadata.get("input_capabilities", [])
    ]
    for provider in providers:
        for consumer in consumers:
            chains.append((provider, consumer))
    return chains
```

---

## Tool Listing

```python
def list_all(self, sort_by: str = "name", status_filter: str = None) -> list[ToolRegistration]:
    """
    List all registered tools in the advanced-automation domain.

    Args:
        sort_by: Sort key — "name", "category", "registered_at", "version"
        status_filter: Filter by status — "active", "disabled", "error", None (all)

    Returns:
        Sorted list of ToolRegistration objects
    """
    tools = list(self._tools.values())
    if status_filter:
        tools = [t for t in tools if t.status == status_filter]
    tools.sort(key=lambda t: getattr(t, sort_by, t.name))
    return tools

def list_categories(self) -> dict[str, list[str]]:
    """List all categories and their registered tool names."""
    return {
        cat: sorted(list(names))
        for cat, names in sorted(self._categories.items())
    }

def list_capabilities(self) -> dict[str, list[str]]:
    """List all capabilities and the tools that provide them."""
    return {
        cap: sorted(list(names))
        for cap, names in sorted(self._capabilities.items())
    }

def list_domain_files(self) -> dict[str, list[str]]:
    """List all domain files and the tools mapped to them."""
    mapping = {}
    for tool in self._tools.values():
        for f in tool.metadata.get("domain_files", []):
            mapping.setdefault(f, []).append(tool.name)
    return mapping
```

---

## Tool Metadata

Each tool registration exposes the following metadata fields:

```yaml
metadata:
  name: string              # Unique identifier
  version: string           # Semver version
  category: string          # Tool category
  capabilities: list[str]   # Capability strings
  description: string       # Human-readable description
  tags: list[str]           # Discovery tags
  author: string            # Tool author
  license: string           # License type
  domain_files: list[str]   # Source files in Advanced-Automation/
  input_capabilities: list[str]   # Required input capabilities (for chaining)
  output_capabilities: list[str]  # Produced output capabilities (for chaining)
  config_schema: dict       # JSON Schema for config validation
  risk_level: string        # low | medium | high | critical
  requires_auth: bool       # Whether tool needs authentication
  network_access: bool      # Whether tool requires network access
  sandbox_compatible: bool  # Whether tool can run in sandbox
```

---

## Tool Versioning

```python
class ToolVersionManager:
    """Manages version lifecycle for registered tools."""

    def check_compatibility(self, name: str, min_version: str) -> bool:
        """Check if tool meets minimum version requirement."""
        tool = self._tools.get(name)
        if not tool:
            return False
        return semver.compare(tool.version, min_version) >= 0

    def upgrade(self, name: str, new_version: str, new_class: type = None) -> ToolRegistration:
        """Upgrade tool to new version with optional class replacement."""
        tool = self._tools[name]
        old_version = tool.version
        tool.version = new_version
        if new_class:
            tool.tool_class = new_class
        tool.metadata["upgrade_history"] = tool.metadata.get("upgrade_history", [])
        tool.metadata["upgrade_history"].append({
            "from": old_version,
            "to": new_version,
            "timestamp": datetime.utcnow().isoformat()
        })
        self._event_bus.emit("tool.upgraded", {"name": name, "from": old_version, "to": new_version})
        return tool

    def get_upgrade_path(self, name: str, target_version: str) -> list[str]:
        """Determine the upgrade path from current to target version."""
        tool = self._tools[name]
        history = tool.metadata.get("upgrade_history", [])
        return [h["to"] for h in history if h["to"] <= target_version]
```

---

## Tool Dependencies

```python
class ToolDependencyManager:
    """Manages dependencies between registered tools."""

    def declare_dependency(self, tool_name: str, depends_on: str, dependency_type: str = "soft"):
        """
        Declare that one tool depends on another.

        dependency_type: "hard" (must exist) | "soft" (optional)
        """
        tool = self._tools[tool_name]
        deps = tool.metadata.setdefault("dependencies", {})
        deps.setdefault("tool_dependencies", []).append({
            "name": depends_on,
            "type": dependency_type
        })

    def resolve_dependencies(self, tool_name: str) -> list[str]:
        """Resolve all dependencies for a tool, returning ordered list."""
        visited = set()
        order = []

        def _resolve(name):
            if name in visited:
                return
            visited.add(name)
            tool = self._tools.get(name)
            if not tool:
                return
            for dep in tool.metadata.get("dependencies", {}).get("tool_dependencies", []):
                _resolve(dep["name"])
            order.append(name)

        _resolve(tool_name)
        return order

    def check_external_dependencies(self, name: str) -> dict[str, bool]:
        """Check if external binaries and libraries are available."""
        tool = self._tools[name]
        ext_deps = tool.metadata.get("dependencies", {})
        results = {}
        binary = ext_deps.get("binary")
        if binary:
            results[binary] = shutil.which(binary) is not None
        return results

    def get_dependents(self, name: str) -> list[str]:
        """Find all tools that depend on a given tool."""
        dependents = []
        for tool_name, tool in self._tools.items():
            deps = tool.metadata.get("dependencies", {}).get("tool_dependencies", [])
            if any(d["name"] == name for d in deps):
                dependents.append(tool_name)
        return dependents
```

---

## Full Domain File References

| # | File | Registered Tool(s) |
|---|---|---|
| 1 | `01-Subdomain-Enumeration-Automation.md` | subfinder |
| 2 | `02-Port-Scanning-Automation.md` | naabu, httpx |
| 3 | `03-Vulnerability-Scanning-Automation.md` | nuclei |
| 4 | `04-JavaScript-Analysis-Automation.md` | js-analyzer |
| 5 | `05-API-Endpoint-Discovery.md` | api-discovery |
| 6 | `06-Parameter-Fuzzing-Automation.md` | ffuf |
| 7 | `07-Directory-Brute-Forcing.md` | ffuf |
| 8 | `09-Authentication-Testing-Automation.md` | auth-tester |
| 9 | `10-Session-Management-Testing.md` | session-tester |
| 10 | `11-IDOR-Detection-Automation.md` | idor-detector |
| 11 | `12-SQL-Injection-Automation.md` | sqlmap |
| 12 | `13-XSS-Detection-Automation.md` | dalfox |
| 13 | `14-SSRF-Testing-Automation.md` | ssrf-explorer |
| 14 | `15-CSRF-Testing-Automation.md` | csrf-tester |
| 15 | `16-Command-Injection-Automation.md` | cmdi-tester |
| 16 | `17-XXE-Testing-Automation.md` | xxe-tester |
| 17 | `18-SSTI-Testing-Automation.md` | tplmap |
| 18 | `19-JWT-Testing-Automation.md` | jwt-tool |
| 19 | `20-Deserialization-Testing.md` | ysoserial |
| 20 | `21-Report-Generation-Automation.md` | report-generator |
| 21 | `22-PoC-Development-Automation.md` | poc-generator |
| 22 | `23-Target-Scouting-Automation.md` | target-scout |
| 23 | `24-Scope-Validation-Automation.md` | scope-validator |
| 24 | `25-Asset-Tracking-Automation.md` | asset-tracker |
| 25 | `26-Change-Monitoring-Automation.md` | change-monitor |
| 26 | `27-Notification-Alerting-Automation.md` | alert-manager |
| 27 | `28-Data-Collection-Automation.md` | data-collector |
| 28 | `29-Result-Analysis-Automation.md` | result-analyzer |
| 29 | `30-Tool-Chaining-Automation.md` | workflow-orchestrator |
| 30 | `31-Proxy-Integration-Automation.md` | proxy-integration |
| 31 | `32-Browser-Automation-Workflows.md` | playwright-scanner |
| 32 | `33-Headless-Browser-Scripting.md` | playwright-scanner |
| 33 | `34-Regex-Pattern-Automation.md` | regex-processor |
| 34 | `35-Response-Analysis-Automation.md` | response-analyzer |
| 35 | `36-Header-Injection-Testing.md` | header-injector |
| 36 | `37-CORS-Testing-Automation.md` | cors-tester |
| 37 | `38-WebSocket-Testing-Automation.md` | websocket-tester |
| 38 | `39-GraphQL-Testing-Automation.md` | graphql-tester |
| 39 | `40-Cloud-Service-Enumeration.md` | cloud-enum |
| 40 | `41-DNS-Data-Extraction-Automation.md` | dns-extractor |
| 41 | `42-Email-Recon-Automation.md` | email-recon |
| 42 | `43-Social-Media-OSINT-Automation.md` | social-osint |
| 43 | `44-Framework-Detection-Automation.md` | framework-detect |
| 44 | `45-Technology-Stack-Identification.md` | tech-stack-id |
| 45 | `46-Endpoint-Mapping-Automation.md` | endpoint-mapper |
| 46 | `47-Content-Discovery-Automation.md` | ffuf |
| 47 | `48-Version-Detection-Automation.md` | version-detect |
| 48 | `49-Compliance-Checking-Automation.md` | compliance-checker |
| 49 | `50-Workflow-Orchestration-Automation.md` | workflow-orchestrator |
| 50 | `README.md` | (documentation) |

---

## Capabilities Index

| Capability | Tools Providing It |
|---|---|
| `subdomain_enumeration` | subfinder |
| `port_scanning` | naabu |
| `http_probing` | httpx |
| `vulnerability_scanning` | nuclei, sqlmap, dalfox |
| `template_execution` | nuclei |
| `directory_enumeration` | ffuf |
| `parameter_fuzzing` | ffuf |
| `sql_injection` | sqlmap |
| `xss_detection` | dalfox |
| `ssrf_testing` | ssrf-explorer |
| `xxe_testing` | xxe-tester |
| `ssti_testing` | tplmap |
| `jwt_testing` | jwt-tool |
| `deserialization` | ysoserial |
| `browser_automation` | playwright-scanner |
| `workflow_orchestration` | workflow-orchestrator |
| `report_generation` | report-generator |
| `technology_detection` | httpx |
| `framework_detection` | framework-detect |
| `cloud_enumeration` | cloud-enum |
| `dns_extraction` | dns-extractor |
| `email_recon` | email-recon |
| `social_osint` | social-osint |
| `endpoint_mapping` | endpoint-mapper |
| `content_discovery` | ffuf |
| `version_detection` | version-detect |
| `compliance_checking` | compliance-checker |
| `asset_tracking` | asset-tracker |
| `change_detection` | change-monitor |
| `alerting` | alert-manager |
| `data_collection` | data-collector |
| `result_analysis` | result-analyzer |
| `tool_chaining` | workflow-orchestrator |
| `proxy_integration` | proxy-integration |

---

## Lifecycle Hooks

| Hook Point | Description |
|---|---|
| `pre_register` | Validate tool configuration before registration |
| `post_register` | Index tool in capability and category maps |
| `pre_unregister` | Check for active executions |
| `post_unregister` | Clean up indices and emit events |
| `pre_enable` | Validate external dependencies |
| `post_enable` | Update status and emit event |
| `pre_disable` | Pause any scheduled tasks |
| `post_disable` | Update status and emit event |
| `on_error` | Log error, set status to "error", emit event |
| `on_upgrade` | Validate new version, update metadata |

---

*Part of the Brain tools subsystem — Advanced Automation Domain Registry.*
