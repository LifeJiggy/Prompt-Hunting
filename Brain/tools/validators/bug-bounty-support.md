# Bug Bounty Support — Input Validation Reference

**Domain**: Bug Bounty Support (Framework & Tool Integration)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all framework and tool integration inputs across the bug-bounty-support domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `bug-bounty-support` |
| Root Directory | `bug-bounty-support/` |
| Total Files | 23 (+ README.md, registry.json) |
| Category | Framework Inputs, Tool Integration, Recon, Exploitation, Reporting |
| Input Surface | Recon targets, exploitation params, tool configs, report content |

---

## 2. Overview

The Bug Bounty Support validator enforces strict input validation for every support workflow in the `bug-bounty-support/` directory. Each file defines a support technique or framework component — from reconnaissance to reporting — and accepts structured inputs that must be validated before execution. This validator ensures:

- Reconnaissance inputs are properly scoped and safe
- Exploitation parameters do not exceed authorized boundaries
- Tool integration configs reference valid tools and endpoints
- JavaScript analysis inputs are syntactically valid
- Reporting content meets quality standards
- Manual testing scope is properly defined
- Parameter fuzzing inputs are sanitized
- Debugging configs are safe for production use
- Ethical guidelines are acknowledged

---

## 3. Schema Definition

### 3.1 Master Support Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "BugBountySupportInput",
  "type": "object",
  "required": ["domain", "support_type"],
  "properties": {
    "domain": { "type": "string", "const": "bug-bounty-support" },
    "support_type": { "$ref": "#/definitions/SupportType" },
    "target": { "$ref": "#/definitions/SupportTarget" },
    "tool_config": { "$ref": "#/definitions/ToolConfig" },
    "parameters": { "$ref": "#/definitions/SupportParameters" },
    "output": { "$ref": "#/definitions/SupportOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 SupportType Schema

```json
{
  "definitions": {
    "SupportType": {
      "type": "string",
      "enum": [
        "advanced_hunting", "advanced_security_hunting", "information_disclosure",
        "javascript_vulnerability", "advanced_techniques", "burp_integration",
        "chaining", "core_aspects", "debugging", "ethical_guidelines",
        "exploitation", "javascript_identification", "manual_testing",
        "parameters", "poc_development", "reconnaissance", "reporting",
        "specific_vulnerabilities", "static_dynamic_testing", "injection_identification",
        "tools_integration", "user_functionality", "vulnerability_detection"
      ]
    }
  }
}
```

### 3.3 SupportTarget Schema

```json
{
  "definitions": {
    "SupportTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["domain", "url", "ip", "api", "mobile", "source_code", "file"]
        },
        "value": { "type": "string", "minLength": 1, "maxLength": 4096 },
        "method": { "type": "string", "enum": ["GET", "POST", "PUT", "DELETE", "PATCH"] },
        "headers": { "type": "object", "additionalProperties": { "type": "string" } },
        "body": { "type": "string", "maxLength": 65536 },
        "cookies": { "type": "object", "additionalProperties": { "type": "string" } },
        "auth_token": { "type": "string", "maxLength": 4096 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 ToolConfig Schema

```json
{
  "definitions": {
    "ToolConfig": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 128 },
        "version": { "type": "string" },
        "path": { "type": "string", "maxLength": 1024 },
        "config_file": { "type": "string", "maxLength": 4096 },
        "extensions": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 50
        },
        "profiles": { "type": "object" },
        "proxy": { "type": "string", "pattern": "^(https?|socks[45]?):\\/\\/.+" }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 SupportParameters Schema

```json
{
  "definitions": {
    "SupportParameters": {
      "type": "object",
      "properties": {
        "wordlist": { "type": "string", "maxLength": 4096 },
        "payloads": { "type": "array", "items": { "type": "string" }, "maxItems": 10000 },
        "threads": { "type": "integer", "minimum": 1, "maximum": 500, "default": 10 },
        "timeout": { "type": "integer", "minimum": 100, "maximum": 300000, "default": 30000 },
        "depth": { "type": "integer", "minimum": 1, "maximum": 20, "default": 5 },
        "recursive": { "type": "boolean", "default": false },
        "follow_redirects": { "type": "boolean", "default": true },
        "verify_ssl": { "type": "boolean", "default": true },
        "user_agent": { "type": "string", "maxLength": 256 },
        "custom_headers": { "type": "object", "additionalProperties": { "type": "string" } },
        "scope_rules": {
          "type": "array",
          "items": { "$ref": "#/definitions/ScopeRule" },
          "maxItems": 100
        },
        "rate_limit": { "type": "number", "minimum": 0.1, "maximum": 1000, "default": 10 },
        "retries": { "type": "integer", "minimum": 0, "maximum": 10, "default": 3 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 ScopeRule Schema

```json
{
  "definitions": {
    "ScopeRule": {
      "type": "object",
      "required": ["pattern", "action"],
      "properties": {
        "pattern": { "type": "string", "minLength": 1, "maxLength": 1024 },
        "action": { "type": "string", "enum": ["include", "exclude"] },
        "type": { "type": "string", "enum": ["glob", "regex", "exact", "wildcard"] }
      }
    }
  }
}
```

### 3.7 SupportOutput Schema

```json
{
  "definitions": {
    "SupportOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "csv", "markdown", "html", "xml"] },
        "destination": { "type": "string", "maxLength": 4096 },
        "verbose": { "type": "boolean", "default": false },
        "filter_severity": {
          "type": "array",
          "items": { "type": "string", "enum": ["info", "low", "medium", "high", "critical"] }
        }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateSupportType(input) → ValidationResult

```python
def validate_support_type(input_data):
    errors = []
    support_type = input_data.get("support_type", "")
    valid_types = [
        "advanced_hunting", "advanced_security_hunting", "information_disclosure",
        "javascript_vulnerability", "advanced_techniques", "burp_integration",
        "chaining", "core_aspects", "debugging", "ethical_guidelines",
        "exploitation", "javascript_identification", "manual_testing",
        "parameters", "poc_development", "reconnaissance", "reporting",
        "specific_vulnerabilities", "static_dynamic_testing", "injection_identification",
        "tools_integration", "user_functionality", "vulnerability_detection"
    ]
    if support_type not in valid_types:
        errors.append(ValidationError("INVALID_SUPPORT_TYPE", f"Unknown support type: {support_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateSupportTarget(input) → ValidationResult

```python
def validate_support_target(input_data):
    errors = []
    target = input_data.get("target", {})
    if not target:
        return ValidationResult(valid=True, errors=[])

    target_type = target.get("type", "")
    target_value = target.get("value", "")

    if not target_value:
        errors.append(ValidationError("TARGET_VALUE_EMPTY", "Target value cannot be empty"))
    if len(target_value) > 4096:
        errors.append(ValidationError("TARGET_VALUE_TOO_LONG", "Target value exceeds 4096 characters"))

    if target_type == "domain":
        if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$', target_value):
            errors.append(ValidationError("INVALID_DOMAIN_FORMAT", f"Invalid domain: {target_value}"))
    elif target_type == "url":
        parsed = urlparse(target_value)
        if not parsed.scheme or not parsed.netloc:
            errors.append(ValidationError("INVALID_URL_FORMAT", f"Invalid URL: {target_value}"))
    elif target_type == "ip":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}(/\d{1,2})?$', target_value):
            errors.append(ValidationError("INVALID_IP_FORMAT", f"Invalid IP: {target_value}"))

    method = target.get("method", "")
    if method and method not in ("GET", "POST", "PUT", "DELETE", "PATCH"):
        errors.append(ValidationError("INVALID_HTTP_METHOD", f"Invalid HTTP method: {method}"))

    body = target.get("body", "")
    if len(body) > 65536:
        errors.append(ValidationError("BODY_TOO_LARGE", "Request body exceeds 64KB"))

    auth_token = target.get("auth_token", "")
    if len(auth_token) > 4096:
        errors.append(ValidationError("AUTH_TOKEN_TOO_LONG", "Auth token exceeds 4096 characters"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateToolConfig(input) → ValidationResult

```python
def validate_tool_config(input_data):
    errors = []
    tool = input_data.get("tool_config", {})
    if not tool:
        return ValidationResult(valid=True, errors=[])

    name = tool.get("name", "")
    if not name:
        errors.append(ValidationError("TOOL_NAME_EMPTY", "Tool name is required"))
    if len(name) > 128:
        errors.append(ValidationError("TOOL_NAME_TOO_LONG", "Tool name exceeds 128 characters"))

    path = tool.get("path", "")
    if path and len(path) > 1024:
        errors.append(ValidationError("TOOL_PATH_TOO_LONG", "Tool path exceeds 1024 characters"))

    extensions = tool.get("extensions", [])
    if len(extensions) > 50:
        errors.append(ValidationError("TOO_MANY_EXTENSIONS", "Cannot have more than 50 extensions"))

    proxy = tool.get("proxy", "")
    if proxy and not re.match(r'^(https?|socks[45]?):\/\/.+', proxy):
        errors.append(ValidationError("INVALID_PROXY_FORMAT", f"Invalid proxy: {proxy}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateSupportParameters(input) → ValidationResult

```python
def validate_support_parameters(input_data):
    errors = []
    params = input_data.get("parameters", {})
    if not params:
        return ValidationResult(valid=True, errors=[])

    threads = params.get("threads", 10)
    if not isinstance(threads, int) or threads < 1 or threads > 500:
        errors.append(ValidationError("THREADS_OUT_OF_RANGE", "Threads must be 1-500"))

    timeout = params.get("timeout", 30000)
    if not isinstance(timeout, (int, float)) or timeout < 100 or timeout > 300000:
        errors.append(ValidationError("TIMEOUT_OUT_OF_RANGE", "Timeout must be 100-300000 ms"))

    depth = params.get("depth", 5)
    if not isinstance(depth, int) or depth < 1 or depth > 20:
        errors.append(ValidationError("DEPTH_OUT_OF_RANGE", "Depth must be 1-20"))

    payloads = params.get("payloads", [])
    if len(payloads) > 10000:
        errors.append(ValidationError("PAYLOAD_LIMIT_EXCEEDED", "Payloads exceed 10000 items"))

    rate_limit = params.get("rate_limit", 10)
    if not isinstance(rate_limit, (int, float)) or rate_limit < 0.1 or rate_limit > 1000:
        errors.append(ValidationError("RATE_LIMIT_OUT_OF_RANGE", "Rate limit must be 0.1-1000"))

    retries = params.get("retries", 3)
    if not isinstance(retries, int) or retries < 0 or retries > 10:
        errors.append(ValidationError("RETRIES_OUT_OF_RANGE", "Retries must be 0-10"))

    scope_rules = params.get("scope_rules", [])
    if len(scope_rules) > 100:
        errors.append(ValidationError("TOO_MANY_SCOPE_RULES", "Cannot have more than 100 scope rules"))

    for rule in scope_rules:
        if "pattern" not in rule:
            errors.append(ValidationError("SCOPE_RULE_NO_PATTERN", "Scope rule must have a pattern"))
        if "action" not in rule:
            errors.append(ValidationError("SCOPE_RULE_NO_ACTION", "Scope rule must have an action"))
        elif rule["action"] not in ("include", "exclude"):
            errors.append(ValidationError("INVALID_SCOPE_ACTION", f"Invalid scope action: {rule['action']}"))

    user_agent = params.get("user_agent", "")
    if user_agent and len(user_agent) > 256:
        errors.append(ValidationError("USER_AGENT_TOO_LONG", "User agent exceeds 256 characters"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeTargetValue(value, target_type) → str

```python
def sanitize_target_value(value, target_type):
    value = value.strip()
    value = value[:4096]
    if target_type == "domain":
        value = value.lower()
        value = re.sub(r'[^\w\.\-]', '', value)
    elif target_type == "url":
        value = re.sub(r'[<>"\';\\]', '', value)
    elif target_type == "ip":
        value = re.sub(r'[^\d\.\/]', '', value)
    return value
```

### 5.2 sanitizePayloads(payloads) → list

```python
def sanitize_payloads(payloads):
    sanitized = []
    dangerous = [r'rm\s+-rf', r'del\s+\/', r'format\s+[a-zA-Z]:', r'wget.*\|.*bash', r'curl.*\|.*sh']
    for payload in payloads[:10000]:
        payload = str(payload)[:4096]
        is_dangerous = any(re.search(p, payload, re.IGNORECASE) for p in dangerous)
        if not is_dangerous:
            sanitized.append(payload)
    return sanitized
```

### 5.3 sanitizeHeaders(headers) → dict

```python
def sanitize_headers(headers):
    sanitized = {}
    for key, value in headers.items():
        clean_key = re.sub(r'[^a-zA-Z0-9\-]', '', key)
        clean_value = str(value)[:1024]
        clean_value = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', clean_value)
        sanitized[clean_key] = clean_value
    return sanitized
```

### 5.4 sanitizeScopeRules(rules) → list

```python
def sanitize_scope_rules(rules):
    sanitized = []
    for rule in rules[:100]:
        if not isinstance(rule, dict):
            continue
        rule["pattern"] = str(rule.get("pattern", ""))[:1024].strip()
        rule["action"] = rule.get("action", "include")
        rule["type"] = rule.get("type", "glob")
        if rule["action"] not in ("include", "exclude"):
            rule["action"] = "include"
        if rule["type"] not in ("glob", "regex", "exact", "wildcard"):
            rule["type"] = "glob"
        sanitized.append(rule)
    return sanitized
```

---

## 6. Type Coercion

### 6.1 coerceSupportType(raw_type) → str

```python
SUPPORT_TYPE_MAP = {
    "hunting": "advanced_hunting",
    "security_hunting": "advanced_security_hunting",
    "info_disclosure": "information_disclosure",
    "js_vuln": "javascript_vulnerability",
    "js_analysis": "javascript_vulnerability",
    "techniques": "advanced_techniques",
    "burp": "burp_integration",
    "chain": "chaining",
    "core": "core_aspects",
    "debug": "debugging",
    "ethics": "ethical_guidelines",
    "exploit": "exploitation",
    "js_identify": "javascript_identification",
    "manual": "manual_testing",
    "params": "parameters",
    "poc": "poc_development",
    "recon": "reconnaissance",
    "report": "reporting",
    "vuln_specific": "specific_vulnerabilities",
    "static": "static_dynamic_testing",
    "injection": "injection_identification",
    "tools": "tools_integration",
    "user_func": "user_functionality",
    "vuln_detect": "vulnerability_detection"
}

def coerce_support_type(raw_type):
    return SUPPORT_TYPE_MAP.get(str(raw_type).lower().strip(), raw_type)
```

### 6.2 coerceTargetType(raw_type) → str

```python
TARGET_TYPE_MAP = {
    "domain": "domain", "subdomain": "domain",
    "url": "url", "endpoint": "url", "link": "url",
    "ip": "ip", "address": "ip", "host": "ip",
    "api": "api", "graphql": "api", "rest": "api",
    "mobile": "mobile", "app": "mobile", "apk": "mobile",
    "source_code": "source_code", "code": "source_code", "repo": "source_code",
    "file": "file", "document": "file"
}

def coerce_target_type(raw_type):
    return TARGET_TYPE_MAP.get(str(raw_type).lower().strip(), "url")
```

### 6.3 coerceNumericParams(params) → dict

```python
def coerce_numeric_params(params):
    int_fields = ["threads", "timeout", "depth", "retries"]
    float_fields = ["rate_limit"]
    for field in int_fields:
        if field in params:
            try:
                params[field] = int(params[field])
            except (ValueError, TypeError):
                params[field] = 0
    for field in float_fields:
        if field in params:
            try:
                params[field] = float(params[field])
            except (ValueError, TypeError):
                params[field] = 1.0
    return params
```

### 6.4 coerceBooleanParams(params, fields) → dict

```python
def coerce_boolean_params(params, fields):
    true_vals = {"true", "1", "yes", "on"}
    false_vals = {"false", "0", "no", "off"}
    for field in fields:
        if field in params:
            val = params[field]
            if isinstance(val, bool):
                continue
            val_str = str(val).lower().strip()
            params[field] = val_str in true_vals
    return params
```

---

## 7. Custom Validators

### 7.1 validateEthicalCompliance(input_data) → list

```python
def validate_ethical_compliance(input_data):
    errors = []
    support_type = input_data.get("support_type", "")
    target = input_data.get("target", {})

    if support_type in ("exploitation", "chaining", "advanced_hunting"):
        if not target.get("auth_token") and not target.get("headers", {}).get("Authorization"):
            errors.append(ValidationWarning(
                "NO_AUTH_PROVIDED",
                "Exploitation activities should have authentication context"
            ))

    params = input_data.get("parameters", {})
    scope_rules = params.get("scope_rules", [])
    if support_type in ("reconnaissance", "advanced_hunting") and not scope_rules:
        errors.append(ValidationWarning(
            "NO_SCOPE_RULES",
            "Reconnaissance activities should have scope rules defined"
        ))

    return errors
```

### 7.2 validatePayloadSafety(payloads) → list

```python
def validate_payload_safety(payloads):
    errors = []
    dangerous_patterns = [
        (r'rm\s+-rf\s+/', "System file deletion"),
        (r'del\s+\/[sS]', "Windows file deletion"),
        (r'format\s+[a-zA-Z]:', "Drive formatting"),
        (r'wget\s+.*\|\s*bash', "Remote code execution via download"),
        (r'curl\s+.*\|\s*sh', "Remote code execution via curl"),
        (r'eval\s*\(', "Dynamic code evaluation"),
        (r'exec\s*\(', "Dynamic code execution"),
        (r'os\.system\s*\(', "OS command execution"),
        (r'subprocess\.call\s*\(', "Subprocess execution"),
    ]
    for i, payload in enumerate(payloads):
        for pattern, desc in dangerous_patterns:
            if re.search(pattern, payload, re.IGNORECASE):
                errors.append(ValidationError(
                    "DANGEROUS_PAYLOAD",
                    f"Payload {i} contains dangerous pattern: {desc}"
                ))
    return errors
```

### 7.3 validateScopeConsistency(scope_rules, target) → list

```python
def validate_scope_consistency(scope_rules, target):
    errors = []
    if not scope_rules or not target:
        return errors

    target_value = target.get("value", "")
    target_type = target.get("type", "")

    include_rules = [r for r in scope_rules if r.get("action") == "include"]
    exclude_rules = [r for r in scope_rules if r.get("action") == "exclude"]

    if not include_rules:
        errors.append(ValidationWarning("NO_INCLUDE_RULES", "No include rules in scope definition"))

    if not exclude_rules:
        errors.append(ValidationWarning("NO_EXCLUDE_RULES", "No exclude rules in scope definition"))

    for rule in exclude_rules:
        pattern = rule.get("pattern", "")
        if pattern == target_value:
            errors.append(ValidationError(
                "TARGET_EXCLUDED",
                f"Target '{target_value}' matches an exclusion rule"
            ))

    return errors
```

### 7.4 validateToolCompatibility(tool_config, support_type) → list

```python
TOOL_TYPE_COMPAT = {
    "burp_integration": ["burpsuite"],
    "reconnaissance": ["subfinder", "amass", "httpx", "nmap", "masscan"],
    "exploitation": ["sqlmap", "xsstrike", "dalfox", "ssrfmap"],
    "javascript_identification": ["linkfinder", "secretfinder"],
    "manual_testing": ["burpsuite", "owasp_zap"],
    "poc_development": ["curl", "python", "custom"],
}

def validate_tool_compatibility(tool_config, support_type):
    errors = []
    if not tool_config:
        return errors

    tool_name = tool_config.get("name", "").lower()
    compatible_tools = TOOL_TYPE_COMPAT.get(support_type, [])
    if compatible_tools and tool_name not in compatible_tools:
        errors.append(ValidationWarning(
            "TOOL_MAY_NOT_BE_OPTIMAL",
            f"Tool '{tool_name}' may not be optimal for '{support_type}'. Consider: {', '.join(compatible_tools)}"
        ))
    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_SUPPORT_TYPE` | ERROR | Support type not recognized |
| `TARGET_VALUE_EMPTY` | ERROR | Target value cannot be empty |
| `TARGET_VALUE_TOO_LONG` | ERROR | Target value exceeds 4096 characters |
| `INVALID_DOMAIN_FORMAT` | ERROR | Domain format invalid |
| `INVALID_URL_FORMAT` | ERROR | URL format invalid |
| `INVALID_IP_FORMAT` | ERROR | IP address format invalid |
| `INVALID_HTTP_METHOD` | ERROR | HTTP method not recognized |
| `BODY_TOO_LARGE` | ERROR | Request body exceeds 64KB |
| `AUTH_TOKEN_TOO_LONG` | ERROR | Auth token exceeds 4096 characters |
| `TOOL_NAME_EMPTY` | ERROR | Tool name is required |
| `TOOL_NAME_TOO_LONG` | ERROR | Tool name exceeds 128 characters |
| `TOOL_PATH_TOO_LONG` | ERROR | Tool path exceeds 1024 characters |
| `TOO_MANY_EXTENSIONS` | ERROR | More than 50 extensions |
| `INVALID_PROXY_FORMAT` | ERROR | Proxy URL format invalid |
| `THREADS_OUT_OF_RANGE` | ERROR | Threads must be 1-500 |
| `TIMEOUT_OUT_OF_RANGE` | ERROR | Timeout must be 100-300000 ms |
| `DEPTH_OUT_OF_RANGE` | ERROR | Depth must be 1-20 |
| `PAYLOAD_LIMIT_EXCEEDED` | ERROR | Payloads exceed 10000 items |
| `RATE_LIMIT_OUT_OF_RANGE` | ERROR | Rate limit must be 0.1-1000 |
| `RETRIES_OUT_OF_RANGE` | ERROR | Retries must be 0-10 |
| `TOO_MANY_SCOPE_RULES` | ERROR | More than 100 scope rules |
| `SCOPE_RULE_NO_PATTERN` | ERROR | Scope rule missing pattern |
| `SCOPE_RULE_NO_ACTION` | ERROR | Scope rule missing action |
| `INVALID_SCOPE_ACTION` | ERROR | Scope action not include/exclude |
| `USER_AGENT_TOO_LONG` | ERROR | User agent exceeds 256 characters |
| `NO_AUTH_PROVIDED` | WARNING | No authentication context provided |
| `NO_SCOPE_RULES` | WARNING | No scope rules defined |
| `DANGEROUS_PAYLOAD` | ERROR | Payload contains dangerous system command |
| `NO_INCLUDE_RULES` | WARNING | No include rules in scope |
| `NO_EXCLUDE_RULES` | WARNING | No exclude rules in scope |
| `TARGET_EXCLUDED` | ERROR | Target matches exclusion rule |
| `TOOL_MAY_NOT_BE_OPTIMAL` | WARNING | Tool may not be optimal for support type |

---

## 9. Error Messages

```python
SUPPORT_ERROR_MESSAGES = {
    "INVALID_SUPPORT_TYPE": "Support type not recognized. Check the supported types list.",
    "TARGET_VALUE_EMPTY": "Target value cannot be empty.",
    "TARGET_VALUE_TOO_LONG": "Target value must be 4096 characters or fewer.",
    "INVALID_DOMAIN_FORMAT": "Domain format is invalid. Expected: subdomain.example.tld",
    "INVALID_URL_FORMAT": "URL format is invalid. Ensure it includes scheme and host.",
    "INVALID_IP_FORMAT": "IP address format is invalid. Expected: dotted-decimal notation.",
    "INVALID_HTTP_METHOD": "HTTP method not recognized. Supported: GET, POST, PUT, DELETE, PATCH.",
    "BODY_TOO_LARGE": "Request body exceeds 64KB limit.",
    "AUTH_TOKEN_TOO_LONG": "Auth token must be 4096 characters or fewer.",
    "TOOL_NAME_EMPTY": "Tool name is required.",
    "TOOL_NAME_TOO_LONG": "Tool name must be 128 characters or fewer.",
    "TOOL_PATH_TOO_LONG": "Tool path must be 1024 characters or fewer.",
    "TOO_MANY_EXTENSIONS": "Cannot have more than 50 extensions.",
    "INVALID_PROXY_FORMAT": "Proxy URL format is invalid.",
    "THREADS_OUT_OF_RANGE": "Thread count must be between 1 and 500.",
    "TIMEOUT_OUT_OF_RANGE": "Timeout must be between 100ms and 300000ms.",
    "DEPTH_OUT_OF_RANGE": "Depth must be between 1 and 20.",
    "PAYLOAD_LIMIT_EXCEEDED": "Payload array cannot exceed 10000 items.",
    "RATE_LIMIT_OUT_OF_RANGE": "Rate limit must be between 0.1 and 1000 requests/sec.",
    "RETRIES_OUT_OF_RANGE": "Retry count must be between 0 and 10.",
    "TOO_MANY_SCOPE_RULES": "Cannot have more than 100 scope rules.",
    "SCOPE_RULE_NO_PATTERN": "Each scope rule must have a pattern.",
    "SCOPE_RULE_NO_ACTION": "Each scope rule must have an action (include/exclude).",
    "INVALID_SCOPE_ACTION": "Scope action must be 'include' or 'exclude'.",
    "USER_AGENT_TOO_LONG": "User agent must be 256 characters or fewer.",
    "NO_AUTH_PROVIDED": "Exploitation activities should have authentication context.",
    "NO_SCOPE_RULES": "Reconnaissance activities should have scope rules defined.",
    "DANGEROUS_PAYLOAD": "Payload contains a pattern associated with destructive system commands.",
    "NO_INCLUDE_RULES": "Scope definition has no include rules.",
    "NO_EXCLUDE_RULES": "Scope definition has no exclude rules.",
    "TARGET_EXCLUDED": "Target matches an explicit exclusion rule.",
    "TOOL_MAY_NOT_BE_OPTIMAL": "Selected tool may not be optimal for this support type.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| B001 | Support type must be valid | ERROR | No |
| B002 | Target value must not be empty | ERROR | No |
| B003 | Target value must not exceed 4096 chars | ERROR | Truncate |
| B004 | Domain format must be valid | ERROR | No |
| B005 | URL format must be valid | ERROR | No |
| B006 | IP format must be valid | ERROR | No |
| B007 | HTTP method must be valid | ERROR | No |
| B008 | Request body must not exceed 64KB | ERROR | Truncate |
| B009 | Auth token must not exceed 4096 chars | ERROR | Truncate |
| B010 | Tool name must be 1-128 chars | ERROR | Truncate |
| B011 | Tool path must not exceed 1024 chars | ERROR | Truncate |
| B012 | Extensions max 50 | ERROR | Truncate |
| B013 | Proxy format must be valid | ERROR | No |
| B014 | Threads must be 1-500 | ERROR | Clamp |
| B015 | Timeout must be 100-300000 ms | ERROR | Clamp |
| B016 | Depth must be 1-20 | ERROR | Clamp |
| B017 | Payloads max 10000 | ERROR | Truncate |
| B018 | Rate limit must be 0.1-1000 | ERROR | Clamp |
| B019 | Retries must be 0-10 | ERROR | Clamp |
| B020 | Scope rules max 100 | ERROR | Truncate |

---

## 11. Domain File References

All 23 files in `bug-bounty-support/` that this validator covers:

| # | File | Support Type | Key Validation |
|---|------|--------------|----------------|
| 01 | `Advanced-Bug-Bounty-Prompt.md` | advanced_hunting | target, parameters |
| 02 | `Advanced-Bug-Security-Hunting-Prompt.md` | advanced_security_hunting | target, parameters |
| 03 | `Advanced-Information-Disclosure-Analysis-Prompt.md` | information_disclosure | target, scope |
| 04 | `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | javascript_vulnerability | target, tool_config |
| 05 | `Advanced-Techniques.md` | advanced_techniques | parameters, payloads |
| 06 | `Burp-AI.md` | burp_integration | tool_config |
| 07 | `Chaining.md` | chaining | target, parameters |
| 08 | `Core-Aspects-for-Bug-Security-Hunting.md` | core_aspects | target, parameters |
| 09 | `debuging-using-browser-console-and-vscode-for-hunting.md` | debugging | tool_config |
| 10 | `Ethical-Guidelines.md` | ethical_guidelines | target (auth required) |
| 11 | `Exploitation.md` | exploitation | target, payloads |
| 12 | `JavaScript-Identification-Deobfuscation.md` | javascript_identification | target, tool_config |
| 13 | `manual-testing-scope.md` | manual_testing | target, scope_rules |
| 14 | `parameters.md` | parameters | target, payloads |
| 15 | `PoC-Development.md` | poc_development | target, output |
| 16 | `Reconnaissance.md` | reconnaissance | target, scope_rules |
| 17 | `Reporting.md` | reporting | output |
| 18 | `Specific-Vulnerabilities-Hunting.md` | specific_vulnerabilities | target, parameters |
| 19 | `static-and-dynamic-testing.md` | static_dynamic_testing | target, tool_config |
| 20 | `to-identify-injection-and-reflected-point-during-testing.md` | injection_identification | target, payloads |
| 21 | `Tools-Integration.md` | tools_integration | tool_config |
| 22 | `user-functionality.md` | user_functionality | target, parameters |
| 23 | `Vulnerability-Detection.md` | vulnerability_detection | target, parameters |

---

## 12. Validation Pipeline

```python
def validate_bug_bounty_support_input(input_data):
    results = []
    results.append(("type", validate_support_type(input_data)))
    results.append(("target", validate_support_target(input_data)))
    results.append(("tool", validate_tool_config(input_data)))
    results.append(("params", validate_support_parameters(input_data)))

    target = input_data.get("target", {})
    params = input_data.get("parameters", {})
    results.append(("ethical", ValidationResult(
        valid=True, errors=validate_ethical_compliance(input_data)
    )))

    payloads = params.get("payloads", [])
    results.append(("payload_safety", ValidationResult(
        valid=len(validate_payload_safety(payloads)) == 0,
        errors=validate_payload_safety(payloads)
    )))

    scope_rules = params.get("scope_rules", [])
    results.append(("scope", ValidationResult(
        valid=True, errors=validate_scope_consistency(scope_rules, target)
    )))

    tool_config = input_data.get("tool_config", {})
    support_type = input_data.get("support_type", "")
    results.append(("tool_compat", ValidationResult(
        valid=True, errors=validate_tool_compatibility(tool_config, support_type)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "bug-bounty-support", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Support validation runs before any tool execution
- Ethical compliance checks run for exploitation and recon activities
- Payload safety checks filter dangerous system commands
- Scope consistency checks verify target is not excluded
- Tool compatibility warnings suggest optimal tools for each support type
- All validation results are logged for audit and accountability
- Type coercion normalizes inputs before validation
- Sanitization removes dangerous characters from all string inputs

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Bug Bounty Support domain |
