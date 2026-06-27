# Advanced Automation — Schema Validation Reference

**Domain**: Advanced Automation (Scanning & Automated Workflows)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define schema validation rules, type validation, range validation, pattern matching, custom validators, sanitization, coercion, and error handling for all scanning and automation-related inputs across the Advanced-Automation domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `advanced-automation` |
| Root Directory | `Advanced-Automation/` |
| Total Files | 50 |
| Category | Scanning, Automation, Fuzzing, Enumeration |
| Input Surface | Scan targets, tool parameters, workflow configs, payload generators |

---

## 2. Overview

The Advanced Automation validator enforces strict schema validation for every automation workflow in the `Advanced-Automation/` directory. Each file defines a scanning or automation technique — from subdomain enumeration to workflow orchestration — and accepts structured inputs that must be validated before execution. This validator ensures:

- Scan targets are within authorized scope
- Tool parameters conform to expected types and ranges
- Payloads are sanitized to prevent self-injection
- Workflow configurations are internally consistent
- Rate limits and concurrency bounds are enforced
- Output format preferences are validated against supported types

---

## 3. Schema Definition

### 3.1 Master Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AdvancedAutomationInput",
  "type": "object",
  "required": ["domain", "target", "tool"],
  "properties": {
    "domain": {
      "type": "string",
      "const": "advanced-automation"
    },
    "target": { "$ref": "#/definitions/ScanTarget" },
    "tool": { "$ref": "#/definitions/AutomationTool" },
    "parameters": { "$ref": "#/definitions/ToolParameters" },
    "workflow": { "$ref": "#/definitions/WorkflowConfig" },
    "output": { "$ref": "#/definitions/OutputConfig" },
    "metadata": { "$ref": "#/definitions/Metadata" }
  },
  "additionalProperties": false
}
```

### 3.2 ScanTarget Schema

```json
{
  "definitions": {
    "ScanTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["domain", "ip", "url", "cidr", "range", "email", "org"]
        },
        "value": { "type": "string", "minLength": 1, "maxLength": 2048 },
        "scope": { "type": "array", "items": { "type": "string" }, "default": [] },
        "exclusions": { "type": "array", "items": { "type": "string" }, "default": [] },
        "authorized": { "type": "boolean", "default": false }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.3 AutomationTool Schema

```json
{
  "definitions": {
    "AutomationTool": {
      "type": "object",
      "required": ["name", "version"],
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 128 },
        "version": { "type": "string", "pattern": "^\\d+\\.\\d+(\\.\\d+)?(-[a-zA-Z0-9]+)?$" },
        "path": { "type": "string" },
        "config": { "type": "object" }
      }
    }
  }
}
```

### 3.4 ToolParameters Schema

```json
{
  "definitions": {
    "ToolParameters": {
      "type": "object",
      "properties": {
        "threads": { "type": "integer", "minimum": 1, "maximum": 500, "default": 10 },
        "timeout": { "type": "integer", "minimum": 1000, "maximum": 300000, "default": 30000 },
        "retries": { "type": "integer", "minimum": 0, "maximum": 10, "default": 3 },
        "rateLimit": { "type": "number", "minimum": 0.1, "maximum": 1000, "default": 10 },
        "wordlist": { "type": "string", "maxLength": 4096 },
        "payloads": { "type": "array", "items": { "type": "string" }, "maxItems": 10000 },
        "recursive": { "type": "boolean", "default": false },
        "depth": { "type": "integer", "minimum": 1, "maximum": 20, "default": 5 },
        "headers": { "type": "object", "additionalProperties": { "type": "string" } },
        "proxy": { "type": "string", "pattern": "^(https?|socks[45]?):\\/\\/.+" }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 WorkflowConfig Schema

```json
{
  "definitions": {
    "WorkflowConfig": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 256 },
        "steps": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["tool", "action"],
            "properties": {
              "tool": { "type": "string" },
              "action": { "type": "string" },
              "dependsOn": { "type": "array", "items": { "type": "string" } },
              "condition": { "type": "string" },
              "parameters": { "type": "object" }
            }
          },
          "minItems": 1,
          "maxItems": 100
        },
        "parallel": { "type": "boolean", "default": false },
        "failOnError": { "type": "boolean", "default": true }
      }
    }
  }
}
```

### 3.6 OutputConfig Schema

```json
{
  "definitions": {
    "OutputConfig": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "csv", "xml", "text", "markdown", "html"] },
        "destination": { "type": "string", "maxLength": 4096 },
        "verbose": { "type": "boolean", "default": false },
        "filter": { "type": "string", "maxLength": 1024 },
        "group": { "type": "string" }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateTarget(input) → ValidationResult

```python
def validate_target(input_data):
    errors = []
    warnings = []
    target_type = input_data.get("target", {}).get("type")
    target_value = input_data.get("target", {}).get("value", "")

    if not target_value:
        errors.append(ValidationError("TARGET_EMPTY", "Target value cannot be empty"))
        return ValidationResult(valid=False, errors=errors)

    if len(target_value) > 2048:
        errors.append(ValidationError("TARGET_TOO_LONG", "Target value exceeds 2048 characters"))

    if target_type == "domain":
        if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$', target_value):
            errors.append(ValidationError("INVALID_DOMAIN", f"Invalid domain format: {target_value}"))
        if target_value.startswith("-") or target_value.endswith("-"):
            errors.append(ValidationError("DOMAIN_DASH", "Domain cannot start or end with hyphen"))

    elif target_type == "ip":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}(/\d{1,2})?$', target_value):
            errors.append(ValidationError("INVALID_IP", f"Invalid IP format: {target_value}"))
        else:
            parts = target_value.split("/")[0].split(".")
            for part in parts:
                if int(part) > 255:
                    errors.append(ValidationError("IP_OCTET_RANGE", f"IP octet out of range: {part}"))

    elif target_type == "url":
        parsed = urlparse(target_value)
        if not parsed.scheme or not parsed.netloc:
            errors.append(ValidationError("INVALID_URL", f"Invalid URL format: {target_value}"))
        if parsed.scheme not in ("http", "https", "ws", "wss"):
            errors.append(ValidationError("UNSUPPORTED_SCHEME", f"Unsupported URL scheme: {parsed.scheme}"))

    elif target_type == "cidr":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$', target_value):
            errors.append(ValidationError("INVALID_CIDR", f"Invalid CIDR format: {target_value}"))
        else:
            parts, mask = target_value.split("/")
            octets = parts.split(".")
            for o in octets:
                if int(o) > 255:
                    errors.append(ValidationError("CIDR_OCTET_RANGE", "CIDR octet out of range"))
            if int(mask) > 32:
                errors.append(ValidationError("CIDR_MASK_RANGE", "CIDR mask must be 0-32"))

    elif target_type == "email":
        if not re.match(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$', target_value):
            errors.append(ValidationError("INVALID_EMAIL", f"Invalid email format: {target_value}"))

    elif target_type == "org":
        if len(target_value) < 2:
            errors.append(ValidationError("ORG_TOO_SHORT", "Organization name too short"))

    else:
        errors.append(ValidationError("UNKNOWN_TARGET_TYPE", f"Unknown target type: {target_type}"))

    if not input_data.get("target", {}).get("authorized", False):
        warnings.append(ValidationWarning("NOT_AUTHORIZED", "Target has not been marked as authorized"))

    scope = input_data.get("target", {}).get("scope", [])
    if not scope:
        warnings.append(ValidationWarning("EMPTY_SCOPE", "No scope boundaries defined"))

    return ValidationResult(valid=len(errors) == 0, errors=errors, warnings=warnings)
```

### 4.2 validateTool(input) → ValidationResult

```python
def validate_tool(input_data):
    errors = []
    tool = input_data.get("tool", {})
    tool_name = tool.get("name", "")
    tool_version = tool.get("version", "")

    if not tool_name:
        errors.append(ValidationError("TOOL_NAME_EMPTY", "Tool name is required"))
    if len(tool_name) > 128:
        errors.append(ValidationError("TOOL_NAME_TOO_LONG", "Tool name exceeds 128 characters"))
    if not re.match(r'^\d+\.\d+(\.\d+)?(-[a-zA-Z0-9]+)?$', tool_version):
        errors.append(ValidationError("INVALID_VERSION", f"Invalid version format: {tool_version}"))

    allowed_tools = [
        "subfinder", "httpx", "nuclei", "ffuf", "gobuster", "dirsearch",
        "nikto", "sqlmap", "xsstrike", "dalfox", "ssrfmap", "fff",
        "katana", "waybackurls", "gau", "amass", "sublist3r",
        "masscan", "nmap", "zgrab", "jaeles", "arjun", "paramspider"
    ]
    if tool_name.lower() not in [t.lower() for t in allowed_tools]:
        errors.append(ValidationError("TOOL_NOT_WHITELISTED", f"Tool '{tool_name}' not in allowed tools list"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateParameters(input) → ValidationResult

```python
def validate_parameters(input_data):
    errors = []
    params = input_data.get("parameters", {})

    threads = params.get("threads", 10)
    if not isinstance(threads, int) or threads < 1 or threads > 500:
        errors.append(ValidationError("THREADS_OUT_OF_RANGE", "Threads must be 1-500"))

    timeout = params.get("timeout", 30000)
    if not isinstance(timeout, (int, float)) or timeout < 1000 or timeout > 300000:
        errors.append(ValidationError("TIMEOUT_OUT_OF_RANGE", "Timeout must be 1000-300000 ms"))

    retries = params.get("retries", 3)
    if not isinstance(retries, int) or retries < 0 or retries > 10:
        errors.append(ValidationError("RETRIES_OUT_OF_RANGE", "Retries must be 0-10"))

    rate_limit = params.get("rateLimit", 10)
    if not isinstance(rate_limit, (int, float)) or rate_limit < 0.1 or rate_limit > 1000:
        errors.append(ValidationError("RATE_LIMIT_OUT_OF_RANGE", "Rate limit must be 0.1-1000 req/s"))

    depth = params.get("depth", 5)
    if not isinstance(depth, int) or depth < 1 or depth > 20:
        errors.append(ValidationError("DEPTH_OUT_OF_RANGE", "Depth must be 1-20"))

    payloads = params.get("payloads", [])
    if len(payloads) > 10000:
        errors.append(ValidationError("PAYLOAD_LIMIT_EXCEEDED", "Payload array exceeds 10000 items"))

    proxy = params.get("proxy", "")
    if proxy and not re.match(r'^(https?|socks[45]?):\/\/.+', proxy):
        errors.append(ValidationError("INVALID_PROXY", f"Invalid proxy format: {proxy}"))

    headers = params.get("headers", {})
    dangerous_headers = ["Authorization", "Cookie", "X-Forwarded-For", "X-Real-IP"]
    for h in headers:
        if h in dangerous_headers:
            errors.append(ValidationError("SENSITIVE_HEADER", f"Header '{h}' should not be set manually"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeTarget(value, type) → string

```python
def sanitize_target(value, target_type):
    value = value.strip()
    value = re.sub(r'[^\w\.\-\/\:@]', '', value)
    if target_type == "domain":
        value = value.lower()
        value = re.sub(r'\.{2,}', '.', value)
    elif target_type == "url":
        parsed = urlparse(value)
        value = f"{parsed.scheme}://{parsed.netloc}{parsed.path}"
    elif target_type == "ip":
        value = re.sub(r'[^\d\.\/]', '', value)
    elif target_type == "email":
        value = value.lower()
    return value
```

### 5.2 sanitizeToolParameters(params) → dict

```python
def sanitize_tool_parameters(params):
    sanitized = {}
    for key, value in params.items():
        key = re.sub(r'[^a-zA-Z0-9_]', '', key)
        if isinstance(value, str):
            value = value.strip()
            value = re.sub(r'[<>"\';\\]', '', value)
            value = value[:4096]
        elif isinstance(value, list):
            value = [sanitize_string_item(v) for v in value[:10000]]
        elif isinstance(value, (int, float)):
            value = max(0, min(value, 1000000))
        sanitized[key] = value
    return sanitized
```

### 5.3 sanitizeWorkflowConfig(config) → dict

```python
def sanitize_workflow_config(config):
    config["name"] = re.sub(r'[^\w\- ]', '', config.get("name", ""))
    config["name"] = config["name"][:256]
    for step in config.get("steps", []):
        step["tool"] = re.sub(r'[^a-zA-Z0-9\-]', '', step.get("tool", ""))
        step["action"] = re.sub(r'[^a-zA-Z0-9\-_]', '', step.get("action", ""))
        if "parameters" in step:
            step["parameters"] = sanitize_tool_parameters(step["parameters"])
    return config
```

---

## 6. Type Coercion

### 6.1 coerceTargetType(raw_value, declared_type) → (str, str)

```python
def coerce_target_type(raw_value, declared_type):
    raw_value = str(raw_value).strip()
    if declared_type == "ip":
        match = re.search(r'(\d{1,3}\.){3}\d{1,3}', raw_value)
        if match:
            return match.group(), "ip"
    if declared_type == "url":
        if not raw_value.startswith(("http://", "https://")):
            raw_value = "https://" + raw_value
        return raw_value, "url"
    if declared_type == "cidr":
        match = re.search(r'(\d{1,3}\.){3}\d{1,3}/\d{1,2}', raw_value)
        if match:
            return match.group(), "cidr"
    return raw_value, declared_type
```

### 6.2 coerceNumericParams(params) → dict

```python
def coerce_numeric_params(params):
    int_fields = ["threads", "timeout", "retries", "depth", "maxItems"]
    float_fields = ["rateLimit", "delay", "jitter"]
    for field in int_fields:
        if field in params:
            try:
                params[field] = int(params[field])
            except (ValueError, TypeError):
                params[field] = 10
    for field in float_fields:
        if field in params:
            try:
                params[field] = float(params[field])
            except (ValueError, TypeError):
                params[field] = 1.0
    return params
```

### 6.3 coerceWorkflowSteps(steps) → list

```python
def coerce_workflow_steps(steps):
    if isinstance(steps, dict):
        steps = [steps]
    elif isinstance(steps, str):
        steps = [{"tool": "unknown", "action": steps}]
    coerced = []
    for step in steps:
        if not isinstance(step, dict):
            continue
        step.setdefault("tool", "")
        step.setdefault("action", "")
        step.setdefault("dependsOn", [])
        step.setdefault("parameters", {})
        coerced.append(step)
    return coerced
```

### 6.4 coerceBooleanFields(params, fields) → dict

```python
def coerce_boolean_fields(params, fields):
    true_values = {"true", "1", "yes", "on", "enabled"}
    false_values = {"false", "0", "no", "off", "disabled"}
    for field in fields:
        if field in params:
            val = params[field]
            if isinstance(val, bool):
                continue
            val_str = str(val).lower().strip()
            if val_str in true_values:
                params[field] = True
            elif val_str in false_values:
                params[field] = False
            else:
                params[field] = False
    return params
```

---

## 7. Custom Validators

### 7.1 validateWorkflowCyclicDependency(steps) → list

```python
def validate_workflow_cyclic_dependency(steps):
    errors = []
    graph = {}
    for step in steps:
        name = step.get("tool", "") + ":" + step.get("action", "")
        deps = step.get("dependsOn", [])
        graph[name] = deps
    visited = set()
    path = set()
    def dfs(node):
        if node in path:
            errors.append(ValidationError("CYCLIC_DEPENDENCY", f"Circular dependency detected: {node}"))
            return True
        if node in visited:
            return False
        visited.add(node)
        path.add(node)
        for dep in graph.get(node, []):
            if dfs(dep):
                return True
        path.remove(node)
        return False
    for node in graph:
        if dfs(node):
            break
    return errors
```

### 7.2 validateTargetInScope(target, scope_rules) → list

```python
def validate_target_in_scope(target, scope_rules):
    errors = []
    if not scope_rules:
        errors.append(ValidationError("NO_SCOPE_RULES", "No scope rules defined"))
        return errors
    target_value = target.get("value", "")
    target_type = target.get("type", "")
    in_scope = False
    for rule in scope_rules:
        if rule.get("type") == target_type:
            pattern = rule.get("pattern", "")
            if re.match(pattern, target_value):
                in_scope = True
                break
        elif rule.get("type") == "wildcard":
            wildcard = rule.get("pattern", "")
            regex = re.escape(wildcard).replace(r'\*', '.*').replace(r'\?', '.')
            if re.match(regex, target_value):
                in_scope = True
                break
    if not in_scope:
        errors.append(ValidationError("OUT_OF_SCOPE", f"Target '{target_value}' is not within authorized scope"))
    for exclusion in scope_rules:
        if exclusion.get("type") == "exclude":
            pattern = exclusion.get("pattern", "")
            if re.match(pattern, target_value):
                errors.append(ValidationError("TARGET_EXCLUDED", f"Target matches exclusion rule: {pattern}"))
    return errors
```

### 7.3 validatePayloadSafety(payloads) → list

```python
def validate_payload_safety(payloads):
    errors = []
    dangerous_patterns = [
        r'rm\s+-rf\s+/', r'del\s+\/[sS]', r'format\s+[a-zA-Z]:',
        r':\(\)\{.*\|:', r'wget\s+.*\|\s*bash', r'curl\s+.*\|\s*sh',
        r'eval\s*\(', r'exec\s*\(',
    ]
    for i, payload in enumerate(payloads):
        for pattern in dangerous_patterns:
            if re.search(pattern, payload, re.IGNORECASE):
                errors.append(ValidationError(
                    "DANGEROUS_PAYLOAD",
                    f"Payload at index {i} contains dangerous pattern: {pattern}"
                ))
    return errors
```

### 7.4 validateRateLimitCompliance(config) → list

```python
def validate_rate_limit_compliance(config):
    errors = []
    params = config.get("parameters", {})
    threads = params.get("threads", 10)
    rate_limit = params.get("rateLimit", 10)
    effective_rate = threads * rate_limit
    if effective_rate > 1000:
        errors.append(ValidationError(
            "RATE_LIMIT_EXCEEDED",
            f"Effective rate ({effective_rate} req/s) exceeds maximum (1000 req/s)"
        ))
    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `TARGET_EMPTY` | CRITICAL | Target value is empty or missing |
| `TARGET_TOO_LONG` | ERROR | Target value exceeds 2048 characters |
| `INVALID_DOMAIN` | ERROR | Domain format does not match RFC standards |
| `DOMAIN_DASH` | ERROR | Domain starts or ends with hyphen |
| `INVALID_IP` | ERROR | IP address format is invalid |
| `IP_OCTET_RANGE` | ERROR | IP octet value exceeds 255 |
| `INVALID_URL` | ERROR | URL cannot be parsed |
| `UNSUPPORTED_SCHEME` | ERROR | URL scheme not in allowed list |
| `INVALID_CIDR` | ERROR | CIDR notation is invalid |
| `CIDR_OCTET_RANGE` | ERROR | CIDR octet value exceeds 255 |
| `CIDR_MASK_RANGE` | ERROR | CIDR mask must be 0-32 |
| `INVALID_EMAIL` | ERROR | Email format is invalid |
| `ORG_TOO_SHORT` | WARNING | Organization name shorter than 2 chars |
| `UNKNOWN_TARGET_TYPE` | ERROR | Target type not recognized |
| `NOT_AUTHORIZED` | WARNING | Target not marked as authorized |
| `EMPTY_SCOPE` | WARNING | No scope boundaries defined |
| `TOOL_NAME_EMPTY` | ERROR | Tool name is required |
| `TOOL_NAME_TOO_LONG` | ERROR | Tool name exceeds 128 characters |
| `INVALID_VERSION` | ERROR | Version string does not match semver pattern |
| `TOOL_NOT_WHITELISTED` | ERROR | Tool not in allowed tools list |
| `THREADS_OUT_OF_RANGE` | ERROR | Thread count outside valid range |
| `TIMEOUT_OUT_OF_RANGE` | ERROR | Timeout value outside valid range |
| `RETRIES_OUT_OF_RANGE` | ERROR | Retry count outside valid range |
| `RATE_LIMIT_OUT_OF_RANGE` | ERROR | Rate limit outside valid range |
| `DEPTH_OUT_OF_RANGE` | ERROR | Crawl depth outside valid range |
| `PAYLOAD_LIMIT_EXCEEDED` | ERROR | Payload array exceeds 10000 items |
| `INVALID_PROXY` | ERROR | Proxy URL format is invalid |
| `SENSITIVE_HEADER` | ERROR | Sensitive header should not be set manually |
| `CYCLIC_DEPENDENCY` | ERROR | Workflow contains circular dependency |
| `OUT_OF_SCOPE` | ERROR | Target outside authorized scope |
| `TARGET_EXCLUDED` | ERROR | Target matches an exclusion rule |
| `DANGEROUS_PAYLOAD` | ERROR | Payload contains dangerous system command pattern |
| `RATE_LIMIT_EXCEEDED` | ERROR | Effective request rate exceeds maximum |

---

## 9. Error Messages

```python
ERROR_MESSAGES = {
    "TARGET_EMPTY": "Target value cannot be empty. Provide a valid domain, IP, URL, CIDR, or email address.",
    "TARGET_TOO_LONG": "Target value exceeds the maximum length of 2048 characters.",
    "INVALID_DOMAIN": "Domain format is invalid. Expected: subdomain.example.tld",
    "DOMAIN_DASH": "Domain names cannot start or end with a hyphen per RFC 952.",
    "INVALID_IP": "IP address format is invalid. Expected: dotted-decimal notation (e.g., 192.168.1.1).",
    "IP_OCTET_RANGE": "Each IP octet must be between 0 and 255.",
    "INVALID_URL": "URL could not be parsed. Ensure it includes scheme and host.",
    "UNSUPPORTED_SCHEME": "URL scheme is not supported. Allowed: http, https, ws, wss.",
    "INVALID_CIDR": "CIDR notation is invalid. Expected: x.x.x.x/nn format.",
    "CIDR_OCTET_RANGE": "CIDR octets must be between 0 and 255.",
    "CIDR_MASK_RANGE": "CIDR mask must be between 0 and 32.",
    "INVALID_EMAIL": "Email format is invalid. Expected: user@domain.tld",
    "ORG_TOO_SHORT": "Organization name must be at least 2 characters.",
    "UNKNOWN_TARGET_TYPE": "Target type not recognized. Supported: domain, ip, url, cidr, range, email, org.",
    "NOT_AUTHORIZED": "Target has not been marked as authorized. Set authorized=true to proceed.",
    "EMPTY_SCOPE": "No scope boundaries defined. Add scope rules to prevent out-of-scope scanning.",
    "TOOL_NAME_EMPTY": "Tool name is required for automation configuration.",
    "TOOL_NAME_TOO_LONG": "Tool name must be 128 characters or fewer.",
    "INVALID_VERSION": "Version format is invalid. Expected: semver (e.g., 1.2.3 or 1.2.3-beta).",
    "TOOL_NOT_WHITELISTED": "Tool is not in the approved tools whitelist. Request access via the tool registry.",
    "THREADS_OUT_OF_RANGE": "Thread count must be between 1 and 500.",
    "TIMEOUT_OUT_OF_RANGE": "Timeout must be between 1000ms and 300000ms (5 minutes).",
    "RETRIES_OUT_OF_RANGE": "Retry count must be between 0 and 10.",
    "RATE_LIMIT_OUT_OF_RANGE": "Rate limit must be between 0.1 and 1000 requests per second.",
    "DEPTH_OUT_OF_RANGE": "Crawl depth must be between 1 and 20 levels.",
    "PAYLOAD_LIMIT_EXCEEDED": "Payload array cannot exceed 10,000 items.",
    "INVALID_PROXY": "Proxy URL format is invalid. Expected: protocol://host:port",
    "SENSITIVE_HEADER": "Sensitive headers should not be set manually in automation configs.",
    "CYCLIC_DEPENDENCY": "Workflow contains a circular dependency that would cause infinite loops.",
    "OUT_OF_SCOPE": "Target is outside the authorized scope. Verify scope rules before scanning.",
    "TARGET_EXCLUDED": "Target matches an explicit exclusion rule.",
    "DANGEROUS_PAYLOAD": "Payload contains a pattern associated with destructive system commands.",
    "RATE_LIMIT_EXCEEDED": "Effective request rate (threads * rateLimit) exceeds the 1000 req/s maximum.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| R001 | Target value must not be empty | CRITICAL | No |
| R002 | Target value must not exceed 2048 chars | ERROR | Truncate |
| R003 | Domain must match RFC 952/1123 format | ERROR | No |
| R004 | IP must be valid dotted-decimal | ERROR | No |
| R005 | URL must have valid scheme and host | ERROR | Prepend https:// |
| R006 | CIDR mask must be 0-32 | ERROR | Clamp to nearest valid |
| R007 | Email must match standard format | ERROR | No |
| R008 | Tool must be in whitelist | ERROR | No |
| R009 | Tool version must be valid semver | ERROR | No |
| R010 | Threads must be 1-500 | ERROR | Clamp to range |
| R011 | Timeout must be 1000-300000ms | ERROR | Clamp to range |
| R012 | Retries must be 0-10 | ERROR | Clamp to range |
| R013 | Rate limit must be 0.1-1000 req/s | ERROR | Clamp to range |
| R014 | Payload count must not exceed 10000 | ERROR | Truncate |
| R015 | Proxy must match protocol://host:port | ERROR | No |
| R016 | Workflow must not have cyclic dependencies | ERROR | No |
| R017 | Target must be within defined scope | ERROR | No |
| R018 | Effective rate must not exceed 1000 req/s | ERROR | Reduce threads or rate |
| R019 | Payloads must not contain dangerous patterns | ERROR | Strip matched pattern |
| R020 | Sensitive headers must not be manually set | WARNING | Remove header |

---

## 11. Domain File References

All 50 files in `Advanced-Automation/` that this validator covers:

| # | File | Validation Profile |
|---|------|--------------------|
| 01 | `01-Subdomain-Enumeration-Automation.md` | Target type: domain, tool: subfinder/amass, depth: 1-10 |
| 02 | `02-Port-Scanning-Automation.md` | Target type: ip/cidr, tool: masscan/nmap, threads: 100-500 |
| 03 | `03-Vulnerability-Scanning-Automation.md` | Target type: url, tool: nuclei, payloads: CVE templates |
| 04 | `04-JavaScript-Analysis-Automation.md` | Target type: url, tool: custom, recursive: true |
| 05 | `05-API-Endpoint-Discovery.md` | Target type: url, tool: arjun/paramspider, depth: 1-15 |
| 06 | `06-Parameter-Fuzzing-Automation.md` | Target type: url, tool: ffuf/arjun, wordlist: required |
| 07 | `07-Directory-Brute-Forcing.md` | Target type: url, tool: ffuf/gobuster, wordlist: required |
| 09 | `09-Authentication-Testing-Automation.md` | Target type: url, custom auth params required |
| 10 | `10-Session-Management-Testing.md` | Target type: url, cookie handling enabled |
| 11 | `11-IDOR-Detection-Automation.md` | Target type: url, param enumeration required |
| 12 | `12-SQL-Injection-Automation.md` | Target type: url, tool: sqlmap, tamper scripts |
| 13 | `13-XSS-Detection-Automation.md` | Target type: url, tool: xsstrike/dalfox, payloads |
| 14 | `14-SSRF-Testing-Automation.md` | Target type: url, tool: ssrfmap, callback URL |
| 15 | `15-CSRF-Testing-Automation.md` | Target type: url, method: POST/PUT |
| 16 | `16-Command-Injection-Automation.md` | Target type: url, payloads: OS command injection |
| 17 | `17-XXE-Testing-Automation.md` | Target type: url, payloads: XML entities |
| 18 | `18-SSTI-Testing-Automation.md` | Target type: url, payloads: template expressions |
| 19 | `19-JWT-Testing-Automation.md` | Target type: url, token: JWT string |
| 20 | `20-Deserialization-Testing.md` | Target type: url, format: java/php/python |
| 21 | `21-Report-Generation-Automation.md` | Output format: json/markdown/html |
| 22 | `22-PoC-Development-Automation.md` | Template: PoC type, output: file |
| 23 | `23-Target-Scouting-Automation.md` | Target type: org/domain, passive: true |
| 24 | `24-Scope-Validation-Automation.md` | Target: any, scope rules: required |
| 25 | `25-Asset-Tracking-Automation.md` | Target: domain, assets: persistent store |
| 26 | `26-Change-Monitoring-Automation.md` | Target: url, interval: 60-86400s |
| 27 | `27-Notification-Alerting-Automation.md` | Channel: webhook/email/slack, events: list |
| 28 | `28-Data-Collection-Automation.md` | Sources: list of URLs, format: json/csv |
| 29 | `29-Result-Analysis-Automation.md` | Input: scan results, filters: severity/type |
| 30 | `30-Tool-Chaining-Automation.md` | Steps: required, parallel: optional |
| 31 | `31-Proxy-Integration-Automation.md` | Proxy: required, rotation: optional |
| 32 | `32-Browser-Automation-Workflows.md` | Target: url, headless: true, actions: list |
| 33 | `33-Headless-Browser-Scripting.md` | Script: JS code, timeout: required |
| 34 | `34-Regex-Pattern-Automation.md` | Pattern: regex string, input: file/text |
| 35 | `35-Response-Analysis-Automation.md` | Input: HTTP responses, criteria: matchers |
| 36 | `36-Header-Injection-Testing.md` | Target: url, headers: custom list |
| 37 | `37-CORS-Testing-Automation.md` | Target: url, origins: test list |
| 38 | `38-WebSocket-Testing-Automation.md` | Target: ws/wss URL, messages: list |
| 39 | `39-GraphQL-Testing-Automation.md` | Target: url/graphql, queries: list |
| 40 | `40-Cloud-Service-Enumeration.md` | Target: org, services: AWS/GCP/Azure |
| 41 | `41-DNS-Data-Extraction-Automation.md` | Target: domain, records: A/AAAA/MX/TXT |
| 42 | `42-Email-Recon-Automation.md` | Target: domain/email, sources: list |
| 43 | `43-Social-Media-OSINT-Automation.md` | Target: username/org, platforms: list |
| 44 | `44-Framework-Detection-Automation.md` | Target: url, techniques: fingerprinting |
| 45 | `45-Technology-Stack-Identification.md` | Target: url, depth: 1-5 |
| 46 | `46-Endpoint-Mapping-Automation.md` | Target: domain, crawl depth: 1-10 |
| 47 | `47-Content-Discovery-Automation.md` | Target: url, wordlist: required |
| 48 | `48-Version-Detection-Automation.md` | Target: url, versions: known patterns |
| 49 | `49-Compliance-Checking-Automation.md` | Target: url, standards: PCI/HIPAA/OWASP |
| 50 | `50-Workflow-Orchestration-Automation.md` | Steps: workflow config, parallel: boolean |

---

## 12. Validation Pipeline

```python
def validate_advanced_automation_input(input_data):
    results = []
    results.append(("target", validate_target(input_data)))
    results.append(("tool", validate_tool(input_data)))
    results.append(("parameters", validate_parameters(input_data)))

    if "workflow" in input_data:
        steps = input_data["workflow"].get("steps", [])
        results.append(("cyclic_deps", validate_workflow_cyclic_dependency(steps)))

    scope_rules = input_data.get("target", {}).get("scope", [])
    target = input_data.get("target", {})
    if scope_rules:
        results.append(("scope", validate_target_in_scope(target, scope_rules)))

    if "parameters" in input_data and "payloads" in input_data["parameters"]:
        results.append(("payload_safety", validate_payload_safety(input_data["parameters"]["payloads"])))

    results.append(("rate_compliance", validate_rate_limit_compliance(input_data)))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    all_warnings = []
    for name, result in results:
        all_errors.extend(result.errors)
        all_warnings.extend(result.warnings)

    return ValidationResult(
        valid=all_valid,
        errors=all_errors,
        warnings=all_warnings,
        meta={"validated_at": datetime.utcnow().isoformat(), "validator_version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- All validators run before any automation tool execution
- Validation failures at CRITICAL/ERROR level block execution
- Warnings are logged but do not block execution
- Sanitization runs automatically after validation passes
- Type coercion runs before validation to normalize inputs
- Custom validators can be registered via the plugin system
- All validation results are persisted to the session audit log
- Cross-domain validators (scope, rate limiting) run in parallel

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial schema validation reference for Advanced Automation domain |
