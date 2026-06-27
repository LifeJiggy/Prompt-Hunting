# Automation Efficiency — Input Validation Reference

**Domain**: Automation Efficiency (Workflow Optimization & Tool Integration)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all optimization and workflow inputs across the Automation-Efficiency domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `automation-efficiency` |
| Root Directory | `Automation-Efficiency/` |
| Total Files | 50 (+ README.md, registry.json) |
| Category | Workflow Optimization, Tool Integration, Resource Management |
| Input Surface | Workflow configs, tool chains, deployment configs, optimization params |

---

## 2. Overview

The Automation Efficiency validator enforces strict input validation for every optimization workflow in the `Automation-Efficiency/` directory. Each file defines an efficiency or optimization technique — from workflow design to advanced architecture patterns — and accepts structured inputs that must be validated before execution. This validator ensures:

- Workflow configurations are syntactically and semantically valid
- Tool chain integrations reference existing registered tools
- Resource limits are within acceptable ranges
- Deployment configurations follow security best practices
- Performance thresholds are within measurable bounds
- Parallel processing configs respect concurrency limits
- API integration configs use valid endpoints and authentication
- Backup and recovery parameters are complete and consistent

---

## 3. Schema Definition

### 3.1 Master Efficiency Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AutomationEfficiencyInput",
  "type": "object",
  "required": ["domain", "efficiency_type", "config"],
  "properties": {
    "domain": { "type": "string", "const": "automation-efficiency" },
    "efficiency_type": { "$ref": "#/definitions/EfficiencyType" },
    "config": { "$ref": "#/definitions/EfficiencyConfig" },
    "resources": { "$ref": "#/definitions/ResourceConfig" },
    "optimization": { "$ref": "#/definitions/OptimizationParams" },
    "output": { "$ref": "#/definitions/EfficiencyOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 EfficiencyType Schema

```json
{
  "definitions": {
    "EfficiencyType": {
      "type": "string",
      "enum": [
        "workflow_design", "tool_chaining", "script_development", "api_integration",
        "result_parsing", "notification_system", "report_generation", "dashboard",
        "continuous_scanning", "change_detection", "target_management",
        "result_deduplication", "false_positive_reduction", "parallel_processing",
        "resource_management", "error_handling", "performance_monitoring",
        "scalability", "integration_testing", "deployment", "configuration_management",
        "version_control", "collaboration", "knowledge_base", "learning_adaptation",
        "custom_tool_development", "rate_limiting", "data_storage", "backup_recovery",
        "security_assessment", "cost_optimization", "maintenance", "documentation",
        "testing_workflows", "debugging", "benchmarking", "compliance",
        "disaster_recovery", "metrics_analytics", "workflow_optimization",
        "tool_integration", "custom_api", "database_automation", "network_automation",
        "cloud_automation", "container_automation", "orchestration", "standards",
        "advanced_architecture"
      ]
    }
  }
}
```

### 3.3 EfficiencyConfig Schema

```json
{
  "definitions": {
    "EfficiencyConfig": {
      "type": "object",
      "required": ["name", "type"],
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 256 },
        "type": { "type": "string" },
        "description": { "type": "string", "maxLength": 4096 },
        "version": { "type": "string", "pattern": "^\\d+\\.\\d+(\\.\\d+)?$" },
        "enabled": { "type": "boolean", "default": true },
        "priority": { "type": "integer", "minimum": 1, "maximum": 10, "default": 5 },
        "tags": { "type": "array", "items": { "type": "string" }, "maxItems": 20 },
        "steps": {
          "type": "array",
          "items": { "$ref": "#/definitions/ConfigStep" },
          "minItems": 1,
          "maxItems": 200
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 ConfigStep Schema

```json
{
  "definitions": {
    "ConfigStep": {
      "type": "object",
      "required": ["action"],
      "properties": {
        "action": { "type": "string", "minLength": 1, "maxLength": 128 },
        "tool": { "type": "string", "maxLength": 128 },
        "parameters": { "type": "object" },
        "condition": { "type": "string", "maxLength": 1024 },
        "timeout": { "type": "integer", "minimum": 100, "maximum": 3600000, "default": 30000 },
        "retry": { "type": "integer", "minimum": 0, "maximum": 10, "default": 3 },
        "on_failure": { "type": "string", "enum": ["stop", "skip", "retry", "fallback"], "default": "stop" },
        "output_variable": { "type": "string", "maxLength": 128 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 ResourceConfig Schema

```json
{
  "definitions": {
    "ResourceConfig": {
      "type": "object",
      "properties": {
        "max_cpu_percent": { "type": "number", "minimum": 1, "maximum": 100, "default": 80 },
        "max_memory_mb": { "type": "integer", "minimum": 64, "maximum": 65536, "default": 1024 },
        "max_disk_mb": { "type": "integer", "minimum": 64, "maximum": 1048576, "default": 10240 },
        "max_network_connections": { "type": "integer", "minimum": 1, "maximum": 10000, "default": 100 },
        "max_threads": { "type": "integer", "minimum": 1, "maximum": 500, "default": 10 },
        "max_concurrent_tasks": { "type": "integer", "minimum": 1, "maximum": 200, "default": 10 },
        "timeout_global": { "type": "integer", "minimum": 60, "maximum": 86400, "default": 3600 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 OptimizationParams Schema

```json
{
  "definitions": {
    "OptimizationParams": {
      "type": "object",
      "properties": {
        "target_latency_ms": { "type": "integer", "minimum": 1, "maximum": 300000, "default": 5000 },
        "target_throughput": { "type": "integer", "minimum": 1, "maximum": 100000, "default": 100 },
        "target_error_rate": { "type": "number", "minimum": 0, "maximum": 100, "default": 5 },
        "target_cost_per_run": { "type": "number", "minimum": 0, "maximum": 10000, "default": 100 },
        "deduplication_enabled": { "type": "boolean", "default": true },
        "caching_enabled": { "type": "boolean", "default": true },
        "cache_ttl_seconds": { "type": "integer", "minimum": 60, "maximum": 86400, "default": 3600 },
        "parallel_enabled": { "type": "boolean", "default": false },
        "max_parallel_workers": { "type": "integer", "minimum": 1, "maximum": 100, "default": 5 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.7 EfficiencyOutput Schema

```json
{
  "definitions": {
    "EfficiencyOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "csv", "markdown", "html", "log"] },
        "destination": { "type": "string", "maxLength": 4096 },
        "verbosity": { "type": "string", "enum": ["quiet", "normal", "verbose", "debug"], "default": "normal" },
        "include_metrics": { "type": "boolean", "default": true },
        "include_timings": { "type": "boolean", "default": false }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateEfficiencyType(input) → ValidationResult

```python
def validate_efficiency_type(input_data):
    errors = []
    eff_type = input_data.get("efficiency_type", "")
    valid_types = [
        "workflow_design", "tool_chaining", "script_development", "api_integration",
        "result_parsing", "notification_system", "report_generation", "dashboard",
        "continuous_scanning", "change_detection", "target_management",
        "result_deduplication", "false_positive_reduction", "parallel_processing",
        "resource_management", "error_handling", "performance_monitoring",
        "scalability", "integration_testing", "deployment", "configuration_management",
        "version_control", "collaboration", "knowledge_base", "learning_adaptation",
        "custom_tool_development", "rate_limiting", "data_storage", "backup_recovery",
        "security_assessment", "cost_optimization", "maintenance", "documentation",
        "testing_workflows", "debugging", "benchmarking", "compliance",
        "disaster_recovery", "metrics_analytics", "workflow_optimization",
        "tool_integration", "custom_api", "database_automation", "network_automation",
        "cloud_automation", "container_automation", "orchestration", "standards",
        "advanced_architecture"
    ]
    if eff_type not in valid_types:
        errors.append(ValidationError("INVALID_EFFICIENCY_TYPE", f"Unknown efficiency type: {eff_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateEfficiencyConfig(input) → ValidationResult

```python
def validate_efficiency_config(input_data):
    errors = []
    config = input_data.get("config", {})
    name = config.get("name", "")
    if not name:
        errors.append(ValidationError("CONFIG_NAME_EMPTY", "Configuration name is required"))
    if len(name) > 256:
        errors.append(ValidationError("CONFIG_NAME_TOO_LONG", "Configuration name exceeds 256 characters"))

    version = config.get("version", "")
    if version and not re.match(r'^\d+\.\d+(\.\d+)?$', version):
        errors.append(ValidationError("INVALID_VERSION", f"Invalid version format: {version}"))

    priority = config.get("priority", 5)
    if not isinstance(priority, int) or priority < 1 or priority > 10:
        errors.append(ValidationError("PRIORITY_OUT_OF_RANGE", "Priority must be 1-10"))

    steps = config.get("steps", [])
    if len(steps) > 200:
        errors.append(ValidationError("TOO_MANY_STEPS", f"Configuration has {len(steps)} steps, max 200"))

    tags = config.get("tags", [])
    if len(tags) > 20:
        errors.append(ValidationError("TOO_MANY_TAGS", "Cannot have more than 20 tags"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateResourceConfig(input) → ValidationResult

```python
def validate_resource_config(input_data):
    errors = []
    resources = input_data.get("resources", {})
    if not resources:
        return ValidationResult(valid=True, errors=[])

    cpu = resources.get("max_cpu_percent", 80)
    if cpu < 1 or cpu > 100:
        errors.append(ValidationError("CPU_OUT_OF_RANGE", "CPU percent must be 1-100"))

    memory = resources.get("max_memory_mb", 1024)
    if memory < 64 or memory > 65536:
        errors.append(ValidationError("MEMORY_OUT_OF_RANGE", "Memory must be 64-65536 MB"))

    disk = resources.get("max_disk_mb", 10240)
    if disk < 64 or disk > 1048576:
        errors.append(ValidationError("DISK_OUT_OF_RANGE", "Disk must be 64-1048576 MB"))

    net = resources.get("max_network_connections", 100)
    if net < 1 or net > 10000:
        errors.append(ValidationError("NET_CONN_OUT_OF_RANGE", "Network connections must be 1-10000"))

    threads = resources.get("max_threads", 10)
    if threads < 1 or threads > 500:
        errors.append(ValidationError("THREADS_OUT_OF_RANGE", "Threads must be 1-500"))

    concurrent = resources.get("max_concurrent_tasks", 10)
    if concurrent < 1 or concurrent > 200:
        errors.append(ValidationError("CONCURRENT_OUT_OF_RANGE", "Concurrent tasks must be 1-200"))

    if threads > concurrent:
        errors.append(ValidationWarning(
            "THREADS_EXCEED_CONCURRENT",
            "Thread count exceeds concurrent task count"
        ))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateOptimizationParams(input) → ValidationResult

```python
def validate_optimization_params(input_data):
    errors = []
    opt = input_data.get("optimization", {})
    if not opt:
        return ValidationResult(valid=True, errors=[])

    latency = opt.get("target_latency_ms", 5000)
    if latency < 1 or latency > 300000:
        errors.append(ValidationError("LATENCY_OUT_OF_RANGE", "Target latency must be 1-300000 ms"))

    throughput = opt.get("target_throughput", 100)
    if throughput < 1 or throughput > 100000:
        errors.append(ValidationError("THROUGHPUT_OUT_OF_RANGE", "Target throughput must be 1-100000"))

    error_rate = opt.get("target_error_rate", 5)
    if error_rate < 0 or error_rate > 100:
        errors.append(ValidationError("ERROR_RATE_OUT_OF_RANGE", "Target error rate must be 0-100%"))

    cost = opt.get("target_cost_per_run", 100)
    if cost < 0 or cost > 10000:
        errors.append(ValidationError("COST_OUT_OF_RANGE", "Target cost must be 0-10000"))

    cache_ttl = opt.get("cache_ttl_seconds", 3600)
    if cache_ttl < 60 or cache_ttl > 86400:
        errors.append(ValidationError("CACHE_TTL_OUT_OF_RANGE", "Cache TTL must be 60-86400 seconds"))

    parallel_workers = opt.get("max_parallel_workers", 5)
    if parallel_workers < 1 or parallel_workers > 100:
        errors.append(ValidationError("PARALLEL_WORKERS_OUT_OF_RANGE", "Parallel workers must be 1-100"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeConfigName(name) → str

```python
def sanitize_config_name(name):
    name = name.strip()
    name = re.sub(r'[^\w\- ]', '', name)
    name = re.sub(r'\s+', '-', name)
    return name[:256]
```

### 5.2 sanitizeStepParameters(params) → dict

```python
def sanitize_step_parameters(params):
    sanitized = {}
    for key, value in params.items():
        clean_key = re.sub(r'[^a-zA-Z0-9_]', '', key)
        if isinstance(value, str):
            value = value.strip()[:4096]
            value = re.sub(r'[<>"\';\\]', '', value)
        elif isinstance(value, list):
            value = [str(v)[:1024] for v in value[:1000]]
        sanitized[clean_key] = value
    return sanitized
```

### 5.3 sanitizeTags(tags) → list

```python
def sanitize_tags(tags):
    sanitized = []
    for tag in tags[:20]:
        tag = str(tag).strip().lower()
        tag = re.sub(r'[^a-z0-9\-_]', '', tag)
        if tag and len(tag) <= 64:
            sanitized.append(tag)
    return sanitized
```

### 5.4 sanitizeOutputConfig(output) → dict

```python
def sanitize_output_config(output):
    output["format"] = output.get("format", "json")
    if output["format"] not in ("json", "csv", "markdown", "html", "log"):
        output["format"] = "json"
    output["verbosity"] = output.get("verbosity", "normal")
    if output["verbosity"] not in ("quiet", "normal", "verbose", "debug"):
        output["verbosity"] = "normal"
    if "destination" in output:
        output["destination"] = re.sub(r'[^\w\-\/\.\~]', '', output["destination"])[:4096]
    return output
```

---

## 6. Type Coercion

### 6.1 coerceNumericResources(resources) → dict

```python
def coerce_numeric_resources(resources):
    int_fields = [
        "max_memory_mb", "max_disk_mb", "max_network_connections",
        "max_threads", "max_concurrent_tasks", "timeout_global"
    ]
    float_fields = ["max_cpu_percent"]
    for field in int_fields:
        if field in resources:
            try:
                resources[field] = int(resources[field])
            except (ValueError, TypeError):
                resources[field] = 0
    for field in float_fields:
        if field in resources:
            try:
                resources[field] = float(resources[field])
            except (ValueError, TypeError):
                resources[field] = 50.0
    return resources
```

### 6.2 coerceOptimizationParams(opt) → dict

```python
def coerce_optimization_params(opt):
    int_fields = [
        "target_latency_ms", "target_throughput", "cache_ttl_seconds",
        "max_parallel_workers"
    ]
    float_fields = ["target_error_rate", "target_cost_per_run"]
    bool_fields = ["deduplication_enabled", "caching_enabled", "parallel_enabled"]
    for field in int_fields:
        if field in opt:
            try:
                opt[field] = int(opt[field])
            except (ValueError, TypeError):
                opt[field] = 0
    for field in float_fields:
        if field in opt:
            try:
                opt[field] = float(opt[field])
            except (ValueError, TypeError):
                opt[field] = 0.0
    true_vals = {"true", "1", "yes", "on"}
    false_vals = {"false", "0", "no", "off"}
    for field in bool_fields:
        if field in opt:
            val = opt[field]
            if not isinstance(val, bool):
                val_str = str(val).lower().strip()
                opt[field] = val_str in true_vals
    return opt
```

### 6.3 coerceSteps(steps) → list

```python
def coerce_steps(steps):
    if isinstance(steps, dict):
        steps = [steps]
    coerced = []
    for step in steps:
        if not isinstance(step, dict):
            continue
        step.setdefault("action", "")
        step.setdefault("tool", "")
        step.setdefault("parameters", {})
        step.setdefault("timeout", 30000)
        step.setdefault("retry", 3)
        step.setdefault("on_failure", "stop")
        coerced.append(step)
    return coerced
```

### 6.4 coerceOutputVerbosity(verbosity) → str

```python
VERBOSITY_MAP = {
    "quiet": "quiet", "silent": "quiet", "off": "quiet",
    "normal": "normal", "default": "normal", "standard": "normal",
    "verbose": "verbose", "detailed": "verbose", "full": "verbose",
    "debug": "debug", "trace": "debug", "all": "debug"
}

def coerce_output_verbosity(verbosity):
    return VERBOSITY_MAP.get(str(verbosity).lower().strip(), "normal")
```

---

## 7. Custom Validators

### 7.1 validateStepDependencyGraph(steps) → list

```python
def validate_step_dependency_graph(steps):
    errors = []
    action_map = {f"step-{i}": s.get("action", "") for i, s in enumerate(steps)}
    for i, step in enumerate(steps):
        action = step.get("action", "")
        if not action:
            errors.append(ValidationError("STEP_ACTION_EMPTY", f"Step {i} has no action defined"))
    return errors
```

### 7.2 validateResourceConsistency(resources) → list

```python
def validate_resource_consistency(resources):
    errors = []
    if not resources:
        return errors
    threads = resources.get("max_threads", 10)
    concurrent = resources.get("max_concurrent_tasks", 10)
    memory = resources.get("max_memory_mb", 1024)

    memory_per_thread = memory // max(threads, 1)
    if memory_per_thread < 32:
        errors.append(ValidationWarning(
            "LOW_MEMORY_PER_THREAD",
            f"Memory per thread ({memory_per_thread}MB) is very low. Consider increasing memory or reducing threads."
        ))

    net = resources.get("max_network_connections", 100)
    if net < threads * 2:
        errors.append(ValidationWarning(
            "LOW_NET_CONNECTIONS",
            "Network connections may be insufficient for the configured thread count."
        ))

    return errors
```

### 7.3 validateOptimizationFeasibility(opt, resources) → list

```python
def validate_optimization_feasibility(opt, resources):
    errors = []
    if not opt or not resources:
        return errors

    latency = opt.get("target_latency_ms", 5000)
    timeout = resources.get("timeout_global", 3600)
    if latency > timeout * 1000:
        errors.append(ValidationError(
            "LATENCY_EXCEEDS_TIMEOUT",
            "Target latency exceeds global timeout"
        ))

    throughput = opt.get("target_throughput", 100)
    threads = resources.get("max_threads", 10)
    if throughput > threads * 100:
        errors.append(ValidationWarning(
            "THROUGHPUT_AMBITIOUS",
            "Target throughput may be unrealistic for the configured thread count"
        ))

    return errors
```

### 7.4 validateCostEfficiency(opt) → list

```python
def validate_cost_efficiency(opt):
    errors = []
    if not opt:
        return errors
    cost = opt.get("target_cost_per_run", 100)
    throughput = opt.get("target_throughput", 100)
    if throughput > 0:
        cost_per_unit = cost / throughput
        if cost_per_unit > 10:
            errors.append(ValidationWarning(
                "HIGH_COST_PER_UNIT",
                f"Cost per unit of work ({cost_per_unit:.2f}) is high"
            ))
    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_EFFICIENCY_TYPE` | ERROR | Efficiency type not recognized |
| `CONFIG_NAME_EMPTY` | ERROR | Configuration name is required |
| `CONFIG_NAME_TOO_LONG` | ERROR | Configuration name exceeds 256 characters |
| `INVALID_VERSION` | ERROR | Version format invalid |
| `PRIORITY_OUT_OF_RANGE` | ERROR | Priority must be 1-10 |
| `TOO_MANY_STEPS` | ERROR | More than 200 steps in configuration |
| `TOO_MANY_TAGS` | ERROR | More than 20 tags |
| `CPU_OUT_OF_RANGE` | ERROR | CPU percent must be 1-100 |
| `MEMORY_OUT_OF_RANGE` | ERROR | Memory must be 64-65536 MB |
| `DISK_OUT_OF_RANGE` | ERROR | Disk must be 64-1048576 MB |
| `NET_CONN_OUT_OF_RANGE` | ERROR | Network connections must be 1-10000 |
| `THREADS_OUT_OF_RANGE` | ERROR | Threads must be 1-500 |
| `CONCURRENT_OUT_OF_RANGE` | ERROR | Concurrent tasks must be 1-200 |
| `THREADS_EXCEED_CONCURRENT` | WARNING | Thread count exceeds concurrent tasks |
| `LATENCY_OUT_OF_RANGE` | ERROR | Target latency outside valid range |
| `THROUGHPUT_OUT_OF_RANGE` | ERROR | Target throughput outside valid range |
| `ERROR_RATE_OUT_OF_RANGE` | ERROR | Error rate must be 0-100% |
| `COST_OUT_OF_RANGE` | ERROR | Cost outside valid range |
| `CACHE_TTL_OUT_OF_RANGE` | ERROR | Cache TTL outside valid range |
| `PARALLEL_WORKERS_OUT_OF_RANGE` | ERROR | Parallel workers outside valid range |
| `STEP_ACTION_EMPTY` | ERROR | Step has no action defined |
| `LOW_MEMORY_PER_THREAD` | WARNING | Memory per thread is very low |
| `LOW_NET_CONNECTIONS` | WARNING | Network connections may be insufficient |
| `LATENCY_EXCEEDS_TIMEOUT` | ERROR | Target latency exceeds global timeout |
| `THROUGHPUT_AMBITIOUS` | WARNING | Target throughput may be unrealistic |
| `HIGH_COST_PER_UNIT` | WARNING | Cost per unit of work is high |

---

## 9. Error Messages

```python
EFFICIENCY_ERROR_MESSAGES = {
    "INVALID_EFFICIENCY_TYPE": "Efficiency type not recognized. Check the supported types list.",
    "CONFIG_NAME_EMPTY": "Configuration name is required for identification.",
    "CONFIG_NAME_TOO_LONG": "Configuration name must be 256 characters or fewer.",
    "INVALID_VERSION": "Version format invalid. Expected: semver (e.g., 1.0.0).",
    "PRIORITY_OUT_OF_RANGE": "Priority must be between 1 (lowest) and 10 (highest).",
    "TOO_MANY_STEPS": "Configuration cannot have more than 200 steps.",
    "TOO_MANY_TAGS": "Cannot have more than 20 tags on a configuration.",
    "CPU_OUT_OF_RANGE": "Maximum CPU percent must be between 1 and 100.",
    "MEMORY_OUT_OF_RANGE": "Maximum memory must be between 64MB and 65536MB.",
    "DISK_OUT_OF_RANGE": "Maximum disk must be between 64MB and 1048576MB (1TB).",
    "NET_CONN_OUT_OF_RANGE": "Maximum network connections must be between 1 and 10000.",
    "THREADS_OUT_OF_RANGE": "Maximum threads must be between 1 and 500.",
    "CONCURRENT_OUT_OF_RANGE": "Maximum concurrent tasks must be between 1 and 200.",
    "THREADS_EXCEED_CONCURRENT": "Thread count exceeds concurrent task count.",
    "LATENCY_OUT_OF_RANGE": "Target latency must be between 1ms and 300000ms (5 minutes).",
    "THROUGHPUT_OUT_OF_RANGE": "Target throughput must be between 1 and 100000 units.",
    "ERROR_RATE_OUT_OF_RANGE": "Target error rate must be between 0% and 100%.",
    "COST_OUT_OF_RANGE": "Target cost per run must be between 0 and 10000.",
    "CACHE_TTL_OUT_OF_RANGE": "Cache TTL must be between 60 seconds and 86400 seconds (24 hours).",
    "PARALLEL_WORKERS_OUT_OF_RANGE": "Parallel workers must be between 1 and 100.",
    "STEP_ACTION_EMPTY": "Each step must have an action defined.",
    "LOW_MEMORY_PER_THREAD": "Memory per thread is very low. Consider adjusting resources.",
    "LOW_NET_CONNECTIONS": "Network connections may be insufficient for the thread count.",
    "LATENCY_EXCEEDS_TIMEOUT": "Target latency exceeds the global timeout.",
    "THROUGHPUT_AMBITIOUS": "Target throughput may be unrealistic for the configured resources.",
    "HIGH_COST_PER_UNIT": "Cost per unit of work is high. Consider optimizing.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| E001 | Efficiency type must be valid | ERROR | No |
| E002 | Config name must be 1-256 chars | ERROR | Truncate |
| E003 | Version must be valid semver | ERROR | No |
| E004 | Priority must be 1-10 | ERROR | Clamp |
| E005 | Steps must be 1-200 | ERROR | Truncate |
| E006 | Tags must be 1-20 | ERROR | Truncate |
| E007 | CPU must be 1-100% | ERROR | Clamp |
| E008 | Memory must be 64-65536 MB | ERROR | Clamp |
| E009 | Disk must be 64-1048576 MB | ERROR | Clamp |
| E010 | Network connections must be 1-10000 | ERROR | Clamp |
| E011 | Threads must be 1-500 | ERROR | Clamp |
| E012 | Concurrent tasks must be 1-200 | ERROR | Clamp |
| E013 | Threads should not exceed concurrent tasks | WARNING | No |
| E014 | Latency must be 1-300000 ms | ERROR | Clamp |
| E015 | Throughput must be 1-100000 | ERROR | Clamp |
| E016 | Error rate must be 0-100% | ERROR | Clamp |
| E017 | Cost must be 0-10000 | ERROR | Clamp |
| E018 | Cache TTL must be 60-86400 seconds | ERROR | Clamp |
| E019 | Parallel workers must be 1-100 | ERROR | Clamp |
| E020 | Memory per thread should be >= 32MB | WARNING | No |

---

## 11. Domain File References

All 50 files in `Automation-Efficiency/` that this validator covers:

| # | File | Efficiency Type | Key Parameters |
|---|------|-----------------|----------------|
| 01 | `01-Workflow-Automation-Design.md` | workflow_design | steps, conditions, output |
| 02 | `02-Tool-Chaining-Strategies.md` | tool_chaining | tools, dependencies, parallel |
| 03 | `03-Script-Development-Best-Practices.md` | script_development | language, dependencies, tests |
| 04 | `04-API-Integration-Automation.md` | api_integration | endpoints, auth, rate_limit |
| 05 | `05-Result-Parsing-and-Analysis.md` | result_parsing | format, filters, output |
| 06 | `06-Notification-and-Alerting-Systems.md` | notification_system | channels, events, thresholds |
| 07 | `07-Report-Generation-Automation.md` | report_generation | format, templates, recipients |
| 08 | `08-Dashboard-and-Monitoring.md` | dashboard | metrics, refresh_rate, layout |
| 09 | `09-Continuous-Scanning-Workflows.md` | continuous_scanning | targets, schedule, tools |
| 10 | `10-Change-Detection-Automation.md` | change_detection | targets, interval, alert_on |
| 11 | `11-Target-Management-Systems.md` | target_management | targets, scope, exclusions |
| 12 | `12-Result-Deduplication.md` | result_deduplication | method, hash_algo, threshold |
| 13 | `13-False-Positive-Reduction.md` | false_positive_reduction | rules, confidence, filters |
| 14 | `14-Parallel-Processing-Optimization.md` | parallel_processing | workers, queue, batch_size |
| 15 | `15-Resource-Management-Automation.md` | resource_management | limits, monitoring, alerts |
| 16 | `16-Error-Handling-and-Recovery.md` | error_handling | retry_policy, fallback, circuit_breaker |
| 17 | `17-Performance-Monitoring.md` | performance_monitoring | metrics, thresholds, alerts |
| 18 | `18-Scalability-Design-Patterns.md` | scalability | pattern, load_balancing, auto_scale |
| 19 | `19-Integration-Testing-Automation.md` | integration_testing | test_cases, coverage, reports |
| 20 | `20-Deployment-Automation.md` | deployment | strategy, rollback, approval |
| 21 | `21-Configuration-Management.md` | configuration_management | configs, versioning, drift |
| 22 | `22-Version-Control-for-Tools.md` | version_control | repo, branching, tags |
| 23 | `23-Collaboration-Workflows.md` | collaboration | roles, permissions, handoff |
| 24 | `24-Knowledge-Base-Automation.md` | knowledge_base | articles, search, update_freq |
| 25 | `25-Learning-and-Adaptation.md` | learning_adaptation | model, feedback_loop, retrain |
| 26 | `26-Custom-Tool-Development.md` | custom_tool_development | language, framework, tests |
| 27 | `27-API-Rate-Limiting-Handling.md` | rate_limiting | limits, backoff, queue |
| 28 | `28-Data-Storage-and-Retrieval.md` | data_storage | engine, schema, index |
| 29 | `29-Backup-and-Recovery-Automation.md` | backup_recovery | schedule, retention, restore |
| 30 | `30-Security-for-Automation-Tools.md` | security_assessment | auth, encryption, audit |
| 31 | `31-Cost-Optimization-Strategies.md` | cost_optimization | budget, alerts, cleanup |
| 32 | `32-Maintenance-and-Updates.md` | maintenance | schedule, changelog, rollback |
| 33 | `33-Documentation-Automation.md` | documentation | format, auto_gen, review |
| 34 | `34-Testing-Automation-Workflows.md` | testing_workflows | suite, coverage, reporting |
| 35 | `35-Debugging-and-Troubleshooting.md` | debugging | logs, breakpoints, trace |
| 36 | `36-Performance-Benchmarking.md` | benchmarking | metrics, baseline, compare |
| 37 | `37-Automation-Security-Assessment.md` | security_assessment | audit, scan, remediate |
| 38 | `38-Compliance-and-Audit-Trails.md` | compliance | standards, logs, retention |
| 39 | `39-Disaster-Recovery-Planning.md` | disaster_recovery | rto, rpo, failover |
| 40 | `40-Automation-Metrics-and-Analytics.md` | metrics_analytics | kpis, dashboard, alerts |
| 41 | `41-Workflow-Optimization.md` | workflow_optimization | bottlenecks, parallel, cache |
| 42 | `42-Tool-Integration-Frameworks.md` | tool_integration | adapters, plugins, api |
| 43 | `43-Custom-API-Development.md` | custom_api | endpoints, auth, docs |
| 44 | `44-Database-Automation.md` | database_automation | migrations, backups, optimize |
| 45 | `45-Network-Automation.md` | network_automation | devices, protocols, monitoring |
| 46 | `46-Cloud-Automation.md` | cloud_automation | provider, resources, cost |
| 47 | `47-Container-Automation.md` | container_automation | images, orchestration, security |
| 48 | `48-Orchestration-Frameworks.md` | orchestration | engine, pipelines, schedule |
| 49 | `49-Automation-Standards.md` | standards | conventions, review, naming |
| 50 | `50-Advanced-Automation-Architecture.md` | advanced_architecture | components, scaling, resilience |

---

## 12. Validation Pipeline

```python
def validate_automation_efficiency_input(input_data):
    results = []
    results.append(("type", validate_efficiency_type(input_data)))
    results.append(("config", validate_efficiency_config(input_data)))
    results.append(("resources", validate_resource_config(input_data)))
    results.append(("optimization", validate_optimization_params(input_data)))

    resources = input_data.get("resources", {})
    results.append(("resource_consistency", ValidationResult(
        valid=True, errors=validate_resource_consistency(resources)
    )))

    opt = input_data.get("optimization", {})
    results.append(("feasibility", ValidationResult(
        valid=True, errors=validate_optimization_feasibility(opt, resources)
    )))

    results.append(("cost_efficiency", ValidationResult(
        valid=True, errors=validate_cost_efficiency(opt)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "automation-efficiency", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Efficiency validation runs before any optimization workflow is queued
- Resource consistency checks ensure thread/memory/network balance
- Optimization feasibility checks validate against actual resource limits
- Cost efficiency checks provide budget awareness
- All resource configs are coerced to numeric types before validation
- Step action validation ensures every workflow step has an actionable command
- Output config validation ensures compatible format/verbosity combinations
- All validation results feed into the performance monitoring dashboard

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Automation Efficiency domain |
