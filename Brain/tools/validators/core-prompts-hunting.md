# Core Prompts Hunting — Input Validation Reference

**Domain**: Core Prompts Hunting (Vulnerability Hunting Tools & Payloads)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all tool inputs and payloads across the Core-Prompts-hunting domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `core-prompts-hunting` |
| Root Directory | `Core-Prompts-hunting/` |
| Total Files | 50 (+ README.md, registry.json) |
| Category | Vulnerability Hunting, Tool Inputs, Payloads, PoC Development |
| Input Surface | Hunt targets, vulnerability payloads, tool configurations, PoC params |

---

## 2. Overview

The Core Prompts Hunting validator enforces strict input validation for every hunting prompt in the `Core-Prompts-hunting/` directory. Each file defines a vulnerability hunting technique — from reconnaissance to reporting — and accepts structured inputs including tool parameters, payloads, and exploitation configs. This validator ensures:

- Hunt targets are within authorized scope
- Vulnerability payloads are sanitized and safe
- Tool configurations use valid parameters
- PoC development inputs are properly formatted
- Exploitation parameters are within safe boundaries
- Report content meets quality standards
- All inputs are type-coerced and normalized

---

## 3. Schema Definition

### 3.1 Master Hunting Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CorePromptsHuntingInput",
  "type": "object",
  "required": ["domain", "hunt_type"],
  "properties": {
    "domain": { "type": "string", "const": "core-prompts-hunting" },
    "hunt_type": { "$ref": "#/definitions/HuntType" },
    "target": { "$ref": "#/definitions/HuntTarget" },
    "tool_config": { "$ref": "#/definitions/HuntToolConfig" },
    "payloads": { "$ref": "#/definitions/PayloadConfig" },
    "exploitation": { "$ref": "#/definitions/ExploitationConfig" },
    "output": { "$ref": "#/definitions/HuntOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 HuntType Schema

```json
{
  "definitions": {
    "HuntType": {
      "type": "string",
      "enum": [
        "reconnaissance", "javascript_analysis", "api_analysis",
        "authentication", "authorization", "input_validation",
        "business_logic", "client_storage", "cryptography",
        "error_handling", "file_upload", "ssrf", "csrf", "cors",
        "race_conditions", "third_party", "configuration",
        "network_infrastructure", "mobile_api", "reporting",
        "waf_bypass", "request_smuggling", "subdomain_takeover",
        "host_header", "xxe", "deserialization", "command_injection",
        "nosql_injection", "graphql", "websocket", "ssti", "jwt",
        "csp_bypass", "clickjacking", "parameter_pollution",
        "ldap_injection", "session_puzzling", "file_handling",
        "xssi", "prototype_pollution", "response_splitting",
        "xpath_injection", "csrf_duplicate", "cors_duplicate",
        "race_duplicate", "third_party_duplicate", "config_duplicate",
        "network_duplicate", "mobile_duplicate", "reporting_duplicate"
      ]
    }
  }
}
```

### 3.3 HuntTarget Schema

```json
{
  "definitions": {
    "HuntTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["domain", "url", "ip", "api", "mobile", "graphql", "websocket"]
        },
        "value": { "type": "string", "minLength": 1, "maxLength": 4096 },
        "method": { "type": "string", "enum": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"] },
        "endpoint": { "type": "string", "maxLength": 2048 },
        "parameters": { "type": "object" },
        "headers": { "type": "object", "additionalProperties": { "type": "string" } },
        "body": { "type": "string", "maxLength": 65536 },
        "cookies": { "type": "object", "additionalProperties": { "type": "string" } },
        "auth": { "$ref": "#/definitions/AuthConfig" },
        "scope": { "type": "array", "items": { "type": "string" }, "maxItems": 100 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 AuthConfig Schema

```json
{
  "definitions": {
    "AuthConfig": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string",
          "enum": ["none", "basic", "bearer", "cookie", "oauth", "jwt", "api_key"]
        },
        "token": { "type": "string", "maxLength": 4096 },
        "username": { "type": "string", "maxLength": 256 },
        "password": { "type": "string", "maxLength": 1024 },
        "header_name": { "type": "string", "maxLength": 128 },
        "cookie_name": { "type": "string", "maxLength": 128 }
      }
    }
  }
}
```

### 3.5 HuntToolConfig Schema

```json
{
  "definitions": {
    "HuntToolConfig": {
      "type": "object",
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 128 },
        "version": { "type": "string" },
        "command": { "type": "string", "maxLength": 4096 },
        "args": { "type": "array", "items": { "type": "string" }, "maxItems": 100 },
        "wordlist": { "type": "string", "maxLength": 4096 },
        "threads": { "type": "integer", "minimum": 1, "maximum": 500 },
        "timeout": { "type": "integer", "minimum": 100, "maximum": 300000 },
        "proxy": { "type": "string", "maxLength": 512 },
        "output_format": { "type": "string", "enum": ["json", "text", "csv", "xml"] }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 PayloadConfig Schema

```json
{
  "definitions": {
    "PayloadConfig": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string",
          "enum": [
            "xss", "sqli", "ssrf", "xxe", "ssti", "command_injection",
            "path_traversal", "lfi", "rfi", "open_redirect", "header_injection",
            "nosql", "xpath", "ldap", "template_injection", "deserialization",
            "prototype_pollution", "jwt_manipulation", "cors", "csrf",
            "clickjacking", "smuggling", "rebinding", "custom"
          ]
        },
        "payloads": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 10000
        },
        "encoding": {
          "type": "string",
          "enum": ["none", "url", "html", "base64", "unicode", "double_url"]
        },
        "context": {
          "type": "string",
          "enum": ["attribute", "script", "html", "css", "javascript", "url", "header", "body"]
        },
        "filter_bypass": { "type": "boolean", "default": false },
        "case_variation": { "type": "boolean", "default": false }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.7 ExploitationConfig Schema

```json
{
  "definitions": {
    "ExploitationConfig": {
      "type": "object",
      "properties": {
        "mode": {
          "type": "string",
          "enum": ["safe", "normal", "aggressive"]
        },
        "verify_only": { "type": "boolean", "default": true },
        "extract_data": { "type": "boolean", "default": false },
        "data_types": {
          "type": "array",
          "items": { "type": "string", "enum": ["user_data", "config", "tokens", "files", "env"] }
        },
        "max_requests": { "type": "integer", "minimum": 1, "maximum": 10000, "default": 100 },
        "delay_between_requests": { "type": "integer", "minimum": 0, "maximum": 60000, "default": 100 },
        "follow_redirects": { "type": "boolean", "default": true },
        "verify_ssl": { "type": "boolean", "default": true }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.8 HuntOutput Schema

```json
{
  "definitions": {
    "HuntOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "markdown", "csv", "html", "xml"] },
        "destination": { "type": "string", "maxLength": 4096 },
        "severity_filter": {
          "type": "array",
          "items": { "type": "string", "enum": ["info", "low", "medium", "high", "critical"] }
        },
        "include_evidence": { "type": "boolean", "default": true },
        "redact_sensitive": { "type": "boolean", "default": true }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateHuntType(input) → ValidationResult

```python
def validate_hunt_type(input_data):
    errors = []
    hunt_type = input_data.get("hunt_type", "")
    valid_types = [
        "reconnaissance", "javascript_analysis", "api_analysis",
        "authentication", "authorization", "input_validation",
        "business_logic", "client_storage", "cryptography",
        "error_handling", "file_upload", "ssrf", "csrf", "cors",
        "race_conditions", "third_party", "configuration",
        "network_infrastructure", "mobile_api", "reporting",
        "waf_bypass", "request_smuggling", "subdomain_takeover",
        "host_header", "xxe", "deserialization", "command_injection",
        "nosql_injection", "graphql", "websocket", "ssti", "jwt",
        "csp_bypass", "clickjacking", "parameter_pollution",
        "ldap_injection", "session_puzzling", "file_handling",
        "xssi", "prototype_pollution", "response_splitting",
        "xpath_injection"
    ]
    if hunt_type not in valid_types:
        errors.append(ValidationError("INVALID_HUNT_TYPE", f"Unknown hunt type: {hunt_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateHuntTarget(input) → ValidationResult

```python
def validate_hunt_target(input_data):
    errors = []
    target = input_data.get("target", {})
    if not target:
        errors.append(ValidationError("TARGET_MISSING", "Hunt target is required"))
        return ValidationResult(valid=False, errors=errors)

    target_type = target.get("type", "")
    target_value = target.get("value", "")

    if not target_value:
        errors.append(ValidationError("TARGET_VALUE_EMPTY", "Target value cannot be empty"))
    if len(target_value) > 4096:
        errors.append(ValidationError("TARGET_VALUE_TOO_LONG", "Target value exceeds 4096 characters"))

    if target_type == "domain":
        if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$', target_value):
            errors.append(ValidationError("INVALID_DOMAIN", f"Invalid domain: {target_value}"))
    elif target_type == "url":
        parsed = urlparse(target_value)
        if not parsed.scheme or not parsed.netloc:
            errors.append(ValidationError("INVALID_URL", f"Invalid URL: {target_value}"))
    elif target_type == "ip":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}(/\d{1,2})?$', target_value):
            errors.append(ValidationError("INVALID_IP", f"Invalid IP: {target_value}"))

    method = target.get("method", "")
    valid_methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"]
    if method and method not in valid_methods:
        errors.append(ValidationError("INVALID_METHOD", f"Invalid HTTP method: {method}"))

    endpoint = target.get("endpoint", "")
    if len(endpoint) > 2048:
        errors.append(ValidationError("ENDPOINT_TOO_LONG", "Endpoint exceeds 2048 characters"))

    body = target.get("body", "")
    if len(body) > 65536:
        errors.append(ValidationError("BODY_TOO_LARGE", "Request body exceeds 64KB"))

    scope = target.get("scope", [])
    if len(scope) > 100:
        errors.append(ValidationError("SCOPE_TOO_LARGE", "Scope list exceeds 100 entries"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validatePayloadConfig(input) → ValidationResult

```python
def validate_payload_config(input_data):
    errors = []
    payloads = input_data.get("payloads", {})
    if not payloads:
        return ValidationResult(valid=True, errors=[])

    payload_type = payloads.get("type", "")
    valid_types = [
        "xss", "sqli", "ssrf", "xxe", "ssti", "command_injection",
        "path_traversal", "lfi", "rfi", "open_redirect", "header_injection",
        "nosql", "xpath", "ldap", "template_injection", "deserialization",
        "prototype_pollution", "jwt_manipulation", "cors", "csrf",
        "clickjacking", "smuggling", "rebinding", "custom"
    ]
    if payload_type and payload_type not in valid_types:
        errors.append(ValidationError("INVALID_PAYLOAD_TYPE", f"Invalid payload type: {payload_type}"))

    payload_list = payloads.get("payloads", [])
    if len(payload_list) > 10000:
        errors.append(ValidationError("PAYLOAD_LIMIT_EXCEEDED", "Payload list exceeds 10000 items"))

    encoding = payloads.get("encoding", "none")
    if encoding not in ("none", "url", "html", "base64", "unicode", "double_url"):
        errors.append(ValidationError("INVALID_ENCODING", f"Invalid encoding: {encoding}"))

    context = payloads.get("context", "")
    valid_contexts = ["attribute", "script", "html", "css", "javascript", "url", "header", "body"]
    if context and context not in valid_contexts:
        errors.append(ValidationError("INVALID_CONTEXT", f"Invalid payload context: {context}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateExploitationConfig(input) → ValidationResult

```python
def validate_exploitation_config(input_data):
    errors = []
    explo = input_data.get("exploitation", {})
    if not explo:
        return ValidationResult(valid=True, errors=[])

    mode = explo.get("mode", "safe")
    if mode not in ("safe", "normal", "aggressive"):
        errors.append(ValidationError("INVALID_EXPLOIT_MODE", f"Invalid exploitation mode: {mode}"))

    max_requests = explo.get("max_requests", 100)
    if not isinstance(max_requests, int) or max_requests < 1 or max_requests > 10000:
        errors.append(ValidationError("MAX_REQUESTS_OUT_OF_RANGE", "max_requests must be 1-10000"))

    delay = explo.get("delay_between_requests", 100)
    if not isinstance(delay, (int, float)) or delay < 0 or delay > 60000:
        errors.append(ValidationError("DELAY_OUT_OF_RANGE", "delay must be 0-60000 ms"))

    data_types = explo.get("data_types", [])
    valid_data_types = ["user_data", "config", "tokens", "files", "env"]
    for dt in data_types:
        if dt not in valid_data_types:
            errors.append(ValidationError("INVALID_DATA_TYPE", f"Invalid data type: {dt}"))

    if mode == "aggressive":
        errors.append(ValidationWarning(
            "AGGRESSIVE_MODE",
            "Aggressive exploitation mode selected. Ensure authorization."
        ))

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
SANITIZE_PATTERNS = [
    r'rm\s+-rf\s+/',
    r'del\s+\/[sS]',
    r'format\s+[a-zA-Z]:',
    r'wget\s+.*\|\s*bash',
    r'curl\s+.*\|\s*sh',
    r'eval\s*\(',
    r'exec\s*\(',
    r'os\.system\s*\(',
]

def sanitize_payloads(payload_list):
    sanitized = []
    for payload in payload_list[:10000]:
        payload = str(payload)[:4096]
        is_dangerous = any(re.search(p, payload, re.IGNORECASE) for p in SANITIZE_PATTERNS)
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

### 5.4 sanitizeToolCommand(command) → str

```python
def sanitize_tool_command(command):
    command = command.strip()
    command = command[:4096]
    command = re.sub(r'[<>"\';\\|&$`]', '', command)
    return command
```

---

## 6. Type Coercion

### 6.1 coerceHuntType(raw_type) → str

```python
HUNT_TYPE_MAP = {
    "recon": "reconnaissance",
    "js": "javascript_analysis", "javascript": "javascript_analysis",
    "api": "api_analysis",
    "auth": "authentication", "authentication": "authentication",
    "authz": "authorization", "authorization": "authorization",
    "input": "input_validation",
    "logic": "business_logic",
    "storage": "client_storage",
    "crypto": "cryptography",
    "error": "error_handling",
    "upload": "file_upload",
    "ssrf": "ssrf", "csrf": "csrf", "cors": "cors",
    "race": "race_conditions",
    "3rd_party": "third_party", "thirdparty": "third_party",
    "config": "configuration",
    "network": "network_infrastructure",
    "mobile": "mobile_api",
    "report": "reporting",
    "waf": "waf_bypass",
    "smuggle": "request_smuggling",
    "subdomain": "subdomain_takeover",
    "host": "host_header",
    "xxe": "xxe",
    "deser": "deserialization", "deserialization": "deserialization",
    "cmdi": "command_injection",
    "nosql": "nosql_injection",
    "gql": "graphql", "graphql": "graphql",
    "ws": "websocket", "websocket": "websocket",
    "ssti": "ssti",
    "jwt": "jwt",
    "csp": "csp_bypass",
    "clickjack": "clickjacking",
    "hpp": "parameter_pollution",
    "ldap": "ldap_injection",
    "session": "session_puzzling",
    "file": "file_handling",
    "xssi": "xssi",
    "proto": "prototype_pollution",
    "splitting": "response_splitting",
    "xpath": "xpath_injection"
}

def coerce_hunt_type(raw_type):
    return HUNT_TYPE_MAP.get(str(raw_type).lower().strip(), raw_type)
```

### 6.2 coerceTargetType(raw_type) → str

```python
def coerce_target_type(raw_type):
    type_map = {
        "domain": "domain", "subdomain": "domain",
        "url": "url", "endpoint": "url", "link": "url",
        "ip": "ip", "address": "ip", "host": "ip",
        "api": "api", "graphql": "graphql", "rest": "api",
        "mobile": "mobile", "app": "mobile",
        "websocket": "websocket", "ws": "websocket", "wss": "websocket"
    }
    return type_map.get(str(raw_type).lower().strip(), "url")
```

### 6.3 coerceExploitationMode(raw_mode) → str

```python
def coerce_exploitation_mode(raw_mode):
    mode_map = {
        "safe": "safe", "careful": "safe", "gentle": "safe",
        "normal": "normal", "standard": "normal", "default": "normal",
        "aggressive": "aggressive", "full": "aggressive", "max": "aggressive"
    }
    return mode_map.get(str(raw_mode).lower().strip(), "normal")
```

### 6.4 coerceNumericParams(params) → dict

```python
def coerce_numeric_params(params):
    int_fields = ["threads", "timeout", "max_requests", "delay_between_requests"]
    for field in int_fields:
        if field in params:
            try:
                params[field] = int(params[field])
            except (ValueError, TypeError):
                params[field] = 0
    return params
```

---

## 7. Custom Validators

### 7.1 validateHuntTypeTargetCompatibility(hunt_type, target) → list

```python
HUNT_TYPE_TARGET_COMPAT = {
    "reconnaissance": ["domain", "url", "ip", "api"],
    "javascript_analysis": ["url"],
    "api_analysis": ["api", "url"],
    "authentication": ["url"],
    "authorization": ["url"],
    "ssrf": ["url"],
    "csrf": ["url"],
    "cors": ["url"],
    "graphql": ["graphql", "url"],
    "websocket": ["websocket", "url"],
    "mobile_api": ["mobile", "url"],
    "subdomain_takeover": ["domain"],
    "jwt": ["url"],
    "ssti": ["url"],
    "xxe": ["url"],
    "deserialization": ["url"],
    "command_injection": ["url"],
    "nosql_injection": ["url"],
}

def validate_hunt_type_target_compatibility(hunt_type, target):
    errors = []
    if not target:
        return errors
    target_type = target.get("type", "")
    compatible = HUNT_TYPE_TARGET_COMPAT.get(hunt_type, [])
    if compatible and target_type not in compatible:
        errors.append(ValidationWarning(
            "TYPE_TARGET_MISMATCH",
            f"Hunt type '{hunt_type}' is typically used with target types: {', '.join(compatible)}"
        ))
    return errors
```

### 7.2 validatePayloadContextMatch(payload_config, target) → list

```python
def validate_payload_context_match(payload_config, target):
    errors = []
    if not payload_config or not target:
        return errors

    context = payload_config.get("context", "")
    method = target.get("method", "GET")

    if context == "body" and method == "GET":
        errors.append(ValidationWarning(
            "CONTEXT_METHOD_MISMATCH",
            "Body context with GET method. POST/PUT typically required."
        ))
    if context == "header" and not target.get("headers"):
        errors.append(ValidationWarning(
            "CONTEXT_NO_HEADERS",
            "Header context but no headers defined in target."
        ))
    return errors
```

### 7.3 validateExploitationSafety(explo_config) → list

```python
def validate_exploitation_safety(explo_config):
    errors = []
    if not explo_config:
        return errors

    mode = explo_config.get("mode", "safe")
    extract = explo_config.get("extract_data", False)
    verify_only = explo_config.get("verify_only", True)

    if mode == "aggressive" and verify_only:
        errors.append(ValidationWarning(
            "MODE_VERIFY_CONFLICT",
            "Aggressive mode with verify_only may limit effectiveness"
        ))

    if extract and mode == "safe":
        errors.append(ValidationWarning(
            "SAFE_MODE_EXTRACT",
            "Data extraction in safe mode may return incomplete results"
        ))

    return errors
```

### 7.4 validateToolArgs(args) → list

```python
DANGEROUS_ARGS = [
    r'--output\s+\/',
    r'--file\s+\/etc',
    r'--wordlist\s+\/etc',
    r'--config\s+\/etc',
]

def validate_tool_args(args):
    errors = []
    for i, arg in enumerate(args):
        for pattern in DANGEROUS_ARGS:
            if re.search(pattern, arg, re.IGNORECASE):
                errors.append(ValidationError(
                    "DANGEROUS_TOOL_ARG",
                    f"Arg {i} references sensitive system path: {arg}"
                ))
    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_HUNT_TYPE` | ERROR | Hunt type not recognized |
| `TARGET_MISSING` | ERROR | Hunt target is required |
| `TARGET_VALUE_EMPTY` | ERROR | Target value cannot be empty |
| `TARGET_VALUE_TOO_LONG` | ERROR | Target value exceeds 4096 characters |
| `INVALID_DOMAIN` | ERROR | Domain format invalid |
| `INVALID_URL` | ERROR | URL format invalid |
| `INVALID_IP` | ERROR | IP address format invalid |
| `INVALID_METHOD` | ERROR | HTTP method not recognized |
| `ENDPOINT_TOO_LONG` | ERROR | Endpoint exceeds 2048 characters |
| `BODY_TOO_LARGE` | ERROR | Request body exceeds 64KB |
| `SCOPE_TOO_LARGE` | ERROR | Scope list exceeds 100 entries |
| `INVALID_PAYLOAD_TYPE` | ERROR | Payload type not recognized |
| `PAYLOAD_LIMIT_EXCEEDED` | ERROR | Payload list exceeds 10000 items |
| `INVALID_ENCODING` | ERROR | Encoding type not recognized |
| `INVALID_CONTEXT` | ERROR | Payload context not recognized |
| `INVALID_EXPLOIT_MODE` | ERROR | Exploitation mode not recognized |
| `MAX_REQUESTS_OUT_OF_RANGE` | ERROR | max_requests outside valid range |
| `DELAY_OUT_OF_RANGE` | ERROR | Request delay outside valid range |
| `INVALID_DATA_TYPE` | ERROR | Data type not recognized |
| `AGGRESSIVE_MODE` | WARNING | Aggressive mode selected |
| `TYPE_TARGET_MISMATCH` | WARNING | Hunt type may not match target type |
| `CONTEXT_METHOD_MISMATCH` | WARNING | Payload context conflicts with HTTP method |
| `CONTEXT_NO_HEADERS` | WARNING | Header context without headers defined |
| `MODE_VERIFY_CONFLICT` | WARNING | Aggressive mode with verify_only |
| `SAFE_MODE_EXTRACT` | WARNING | Data extraction in safe mode |
| `DANGEROUS_TOOL_ARG` | ERROR | Tool arg references sensitive system path |

---

## 9. Error Messages

```python
HUNTING_ERROR_MESSAGES = {
    "INVALID_HUNT_TYPE": "Hunt type not recognized. Check the supported hunting techniques.",
    "TARGET_MISSING": "Hunt target is required. Specify what to hunt.",
    "TARGET_VALUE_EMPTY": "Target value cannot be empty.",
    "TARGET_VALUE_TOO_LONG": "Target value must be 4096 characters or fewer.",
    "INVALID_DOMAIN": "Domain format is invalid.",
    "INVALID_URL": "URL format is invalid. Ensure it includes scheme and host.",
    "INVALID_IP": "IP address format is invalid.",
    "INVALID_METHOD": "HTTP method not recognized.",
    "ENDPOINT_TOO_LONG": "Endpoint must be 2048 characters or fewer.",
    "BODY_TOO_LARGE": "Request body exceeds 64KB limit.",
    "SCOPE_TOO_LARGE": "Scope list cannot exceed 100 entries.",
    "INVALID_PAYLOAD_TYPE": "Payload type not recognized.",
    "PAYLOAD_LIMIT_EXCEEDED": "Payload list cannot exceed 10000 items.",
    "INVALID_ENCODING": "Encoding type not recognized.",
    "INVALID_CONTEXT": "Payload context not recognized.",
    "INVALID_EXPLOIT_MODE": "Exploitation mode must be: safe, normal, or aggressive.",
    "MAX_REQUESTS_OUT_OF_RANGE": "max_requests must be between 1 and 10000.",
    "DELAY_OUT_OF_RANGE": "Delay must be between 0 and 60000 ms.",
    "INVALID_DATA_TYPE": "Data type not recognized.",
    "AGGRESSIVE_MODE": "Aggressive exploitation mode selected. Ensure proper authorization.",
    "TYPE_TARGET_MISMATCH": "Hunt type may not be optimal for this target type.",
    "CONTEXT_METHOD_MISMATCH": "Payload context conflicts with the HTTP method.",
    "CONTEXT_NO_HEADERS": "Header context specified but no headers defined.",
    "MODE_VERIFY_CONFLICT": "Aggressive mode with verify_only may limit effectiveness.",
    "SAFE_MODE_EXTRACT": "Data extraction in safe mode may return incomplete results.",
    "DANGEROUS_TOOL_ARG": "Tool argument references a sensitive system path.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| H001 | Hunt type must be valid | ERROR | No |
| H002 | Target must be provided | ERROR | No |
| H003 | Target value must not be empty | ERROR | No |
| H004 | Target value must not exceed 4096 chars | ERROR | Truncate |
| H005 | Domain format must be valid | ERROR | No |
| H006 | URL format must be valid | ERROR | No |
| H007 | IP format must be valid | ERROR | No |
| H008 | HTTP method must be valid | ERROR | No |
| H009 | Endpoint must not exceed 2048 chars | ERROR | Truncate |
| H010 | Request body must not exceed 64KB | ERROR | Truncate |
| H011 | Scope list max 100 entries | ERROR | Truncate |
| H012 | Payload type must be valid | ERROR | No |
| H013 | Payload list max 10000 items | ERROR | Truncate |
| H014 | Encoding must be valid | ERROR | Default to none |
| H015 | Context must be valid | ERROR | No |
| H016 | Exploitation mode must be valid | ERROR | Default to safe |
| H017 | max_requests must be 1-10000 | ERROR | Clamp |
| H018 | Delay must be 0-60000 ms | ERROR | Clamp |
| H019 | Data types must be valid | ERROR | No |
| H020 | Hunt type should match target type | WARNING | No |

---

## 11. Domain File References

All 50 files in `Core-Prompts-hunting/` that this validator covers:

| # | File | Hunt Type | Primary Validation |
|---|------|-----------|---------------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery.md` | reconnaissance | target.domain, scope |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation.md` | javascript_analysis | target.url |
| 03 | `3-API-Endpoint-Analysis.md` | api_analysis | target.api, method |
| 04 | `4-Authentication-and-Session-Management.md` | authentication | target.url, auth |
| 05 | `5-Authorization-and-Access-Control.md` | authorization | target.url, auth |
| 06 | `6-Input-Validation-and-Sanitization.md` | input_validation | target.url, payloads |
| 07 | `7-Business-Logic-Flaws.md` | business_logic | target.url |
| 08 | `8-Client-Side-Storage-Security.md` | client_storage | target.url |
| 09 | `9-Cryptography-and-Data-Protection.md` | cryptography | target.url |
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | error_handling | target.url |
| 11 | `11-File-Upload-and-Processing.md` | file_upload | target.url, payloads |
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | ssrf | target.url, payloads |
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | csrf | target.url |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | cors | target.url |
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | race_conditions | target.url |
| 16 | `16-Third-Party-Component-Analysis.md` | third_party | target.url |
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | configuration | target.url |
| 18 | `18-Network-and-Infrastructure-Security.md` | network_infrastructure | target.ip |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | mobile_api | target.mobile |
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | reporting | output |
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | waf_bypass | target.url, payloads |
| 22 | `22-HTTP-Request-Smuggling.md` | request_smuggling | target.url |
| 23 | `23-Subdomain-Takeover.md` | subdomain_takeover | target.domain |
| 24 | `24-Host-Header-Injection.md` | host_header | target.url, headers |
| 25 | `25-XML-External-Entity-XXE-Injection.md` | xxe | target.url, payloads |
| 26 | `26-Insecure-Deserialization.md` | deserialization | target.url |
| 27 | `27-Command-Injection.md` | command_injection | target.url, payloads |
| 28 | `28-NoSQL-Injection.md` | nosql_injection | target.url, payloads |
| 29 | `29-GraphQL-Vulnerabilities.md` | graphql | target.graphql |
| 30 | `30-WebSocket-Security.md` | websocket | target.websocket |
| 31 | `31-Server-Side-Template-Injection.md` | ssti | target.url, payloads |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | jwt | target.url, auth |
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | csp_bypass | target.url |
| 34 | `34-Clickjacking-and-UI-Redressing.md` | clickjacking | target.url |
| 35 | `35-HTTP-Parameter-Pollution.md` | parameter_pollution | target.url, parameters |
| 36 | `36-LDAP-Injection.md` | ldap_injection | target.url, payloads |
| 37 | `37-Session-Puzzling-and-Fixation.md` | session_puzzling | target.url |
| 38 | `38-Insecure-File-Handling.md` | file_handling | target.url |
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | xssi | target.url |
| 40 | `40-Prototype-Pollution.md` | prototype_pollution | target.url, payloads |
| 41 | `41-HTTP-Response-Splitting.md` | response_splitting | target.url, headers |
| 42 | `42-XPath-Injection.md` | xpath_injection | target.url, payloads |
| 43-50 | Duplicate files (43-50) | Various | Same validations as above |

---

## 12. Validation Pipeline

```python
def validate_core_prompts_hunting_input(input_data):
    results = []
    results.append(("hunt_type", validate_hunt_type(input_data)))
    results.append(("target", validate_hunt_target(input_data)))
    results.append(("payloads", validate_payload_config(input_data)))
    results.append(("exploitation", validate_exploitation_config(input_data)))

    hunt_type = input_data.get("hunt_type", "")
    target = input_data.get("target", {})
    results.append(("type_compat", ValidationResult(
        valid=True, errors=validate_hunt_type_target_compatibility(hunt_type, target)
    )))

    payload_config = input_data.get("payloads", {})
    results.append(("context_match", ValidationResult(
        valid=True, errors=validate_payload_context_match(payload_config, target)
    )))

    explo_config = input_data.get("exploitation", {})
    results.append(("exploit_safety", ValidationResult(
        valid=True, errors=validate_exploitation_safety(explo_config)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "core-prompts-hunting", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Hunting validation runs before any vulnerability scan or exploit attempt
- Type-target compatibility checks suggest optimal hunt configurations
- Payload context matching ensures payloads are appropriate for the injection point
- Exploitation safety checks warn about aggressive or unsafe configurations
- Tool argument validation prevents accidental system file access
- All validation results are logged for engagement audit trail
- Type coercion normalizes user inputs to canonical forms
- Payload sanitization filters dangerous system commands

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Core Prompts Hunting domain |
