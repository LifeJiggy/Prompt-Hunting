# Real-World Case Studies — Input Validation Reference

**Domain**: Real-World Case Studies (Disclosed Vulnerability Patterns)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all pattern inputs across the Real-World-Case-Studies domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `real-world-case-studies` |
| Root Directory | `Real-World-Case-Studies/` |
| Total Files | 50 (+ README.md, registry.json) |
| Category | Disclosed Vulnerability Patterns, Exploitation Techniques, Mitigation |
| Input Surface | Pattern parameters, exploitation configs, mitigation inputs |

---

## 2. Overview

The Real-World Case Studies validator enforces strict input validation for every disclosed vulnerability pattern in the `Real-World-Case-Studies/` directory. Each file defines a real-world exploitation technique — from IDOR to API auth bypass — and accepts structured inputs that must be validated before analysis. This validator ensures:

- Pattern parameters are properly structured
- Exploitation configs are within safe boundaries
- Mitigation recommendations are actionable
- All inputs are type-coerced and normalized
- Pattern inputs do not exceed resource limits

---

## 3. Schema Definition

### 3.1 Master Case Study Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "RealWorldCaseStudyInput",
  "type": "object",
  "required": ["domain", "case_type", "pattern"],
  "properties": {
    "domain": { "type": "string", "const": "real-world-case-studies" },
    "case_type": { "$ref": "#/definitions/CaseType" },
    "pattern": { "$ref": "#/definitions/PatternConfig" },
    "exploitation": { "$ref": "#/definitions/ExploitationConfig" },
    "mitigation": { "$ref": "#/definitions/MitigationConfig" },
    "output": { "$ref": "#/definitions/CaseOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 CaseType Schema

```json
{
  "definitions": {
    "CaseType": {
      "type": "string",
      "enum": [
        "idor", "stored_xss", "sqli", "ssrf", "csrf", "command_injection",
        "deserialization", "file_upload", "xxe", "ssti", "jwt_manipulation",
        "auth_bypass", "privilege_escalation", "business_logic",
        "info_disclosure", "heap_overflow", "java_deser", "php_unserialize",
        "python_pickle", "race_condition", "host_header", "dns_rebinding",
        "websocket_issues", "graphql_introspection", "csp_bypass",
        "clickjacking", "response_splitting", "ldap_injection",
        "xpath_injection", "nosql_injection", "prototype_pollution",
        "subdomain_takeover", "open_redirect", "content_spoofing",
        "cache_poisoning", "request_smuggling", "websocket_hijacking",
        "cors_misconfiguration", "token_leakage", "sensitive_data_exposure",
        "weak_encryption", "insecure_crypto_storage", "path_traversal",
        "lfi", "rfi", "server_side_request_forgery", "client_side_request_forgery",
        "mobile_api_issues", "cloud_misconfiguration", "api_auth_bypass"
      ]
    }
  }
}
```

### 3.3 PatternConfig Schema

```json
{
  "definitions": {
    "PatternConfig": {
      "type": "object",
      "required": ["name", "vulnerability_class"],
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 256 },
        "vulnerability_class": { "type": "string", "maxLength": 128 },
        "description": { "type": "string", "maxLength": 4096 },
        "endpoint": { "type": "string", "maxLength": 2048 },
        "method": { "type": "string", "enum": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"] },
        "parameters": { "type": "object" },
        "payloads": { "type": "array", "items": { "type": "string" }, "maxItems": 1000 },
        "severity_range": {
          "type": "object",
          "properties": {
            "min": { "type": "string", "enum": ["low", "medium", "high", "critical"] },
            "max": { "type": "string", "enum": ["low", "medium", "high", "critical"] }
          }
        },
        "affected_components": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        },
        "references": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 ExploitationConfig Schema

```json
{
  "definitions": {
    "ExploitationConfig": {
      "type": "object",
      "properties": {
        "mode": { "type": "string", "enum": ["safe", "normal", "aggressive"] },
        "verify_only": { "type": "boolean", "default": true },
        "max_requests": { "type": "integer", "minimum": 1, "maximum": 10000, "default": 100 },
        "delay_ms": { "type": "integer", "minimum": 0, "maximum": 60000, "default": 100 },
        "follow_redirects": { "type": "boolean", "default": true },
        "extract_data": { "type": "boolean", "default": false },
        "data_targets": {
          "type": "array",
          "items": { "type": "string", "enum": ["user_data", "config", "tokens", "files", "env"] },
          "maxItems": 5
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 MitigationConfig Schema

```json
{
  "definitions": {
    "MitigationConfig": {
      "type": "object",
      "properties": {
        "priority": { "type": "string", "enum": ["immediate", "short_term", "long_term"] },
        "effort": { "type": "string", "enum": ["low", "medium", "high"] },
        "categories": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["input_validation", "access_control", "authentication", "encryption", "configuration", "code_review", "monitoring", "training"]
          },
          "maxItems": 8
        },
        "specific_recommendations": {
          "type": "array",
          "items": { "type": "string", "maxLength": 1024 },
          "maxItems": 20
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 CaseOutput Schema

```json
{
  "definitions": {
    "CaseOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "markdown", "html"] },
        "include_poc": { "type": "boolean", "default": false },
        "include_mitigation": { "type": "boolean", "default": true },
        "destination": { "type": "string", "maxLength": 4096 }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateCaseType(input) → ValidationResult

```python
def validate_case_type(input_data):
    errors = []
    case_type = input_data.get("case_type", "")
    valid_types = [
        "idor", "stored_xss", "sqli", "ssrf", "csrf", "command_injection",
        "deserialization", "file_upload", "xxe", "ssti", "jwt_manipulation",
        "auth_bypass", "privilege_escalation", "business_logic",
        "info_disclosure", "heap_overflow", "java_deser", "php_unserialize",
        "python_pickle", "race_condition", "host_header", "dns_rebinding",
        "websocket_issues", "graphql_introspection", "csp_bypass",
        "clickjacking", "response_splitting", "ldap_injection",
        "xpath_injection", "nosql_injection", "prototype_pollution",
        "subdomain_takeover", "open_redirect", "content_spoofing",
        "cache_poisoning", "request_smuggling", "websocket_hijacking",
        "cors_misconfiguration", "token_leakage", "sensitive_data_exposure",
        "weak_encryption", "insecure_crypto_storage", "path_traversal",
        "lfi", "rfi", "server_side_request_forgery", "client_side_request_forgery",
        "mobile_api_issues", "cloud_misconfiguration", "api_auth_bypass"
    ]
    if case_type not in valid_types:
        errors.append(ValidationError("INVALID_CASE_TYPE", f"Unknown case type: {case_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validatePatternConfig(input) → ValidationResult

```python
def validate_pattern_config(input_data):
    errors = []
    pattern = input_data.get("pattern", {})

    name = pattern.get("name", "")
    if not name:
        errors.append(ValidationError("PATTERN_NAME_EMPTY", "Pattern name is required"))
    if len(name) > 256:
        errors.append(ValidationError("PATTERN_NAME_TOO_LONG", "Pattern name exceeds 256 characters"))

    vuln_class = pattern.get("vulnerability_class", "")
    if not vuln_class:
        errors.append(ValidationError("VULN_CLASS_EMPTY", "Vulnerability class is required"))
    if len(vuln_class) > 128:
        errors.append(ValidationError("VULN_CLASS_TOO_LONG", "Vulnerability class exceeds 128 characters"))

    endpoint = pattern.get("endpoint", "")
    if len(endpoint) > 2048:
        errors.append(ValidationError("ENDPOINT_TOO_LONG", "Endpoint exceeds 2048 characters"))

    method = pattern.get("method", "")
    valid_methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"]
    if method and method not in valid_methods:
        errors.append(ValidationError("INVALID_METHOD", f"Invalid HTTP method: {method}"))

    payloads = pattern.get("payloads", [])
    if len(payloads) > 1000:
        errors.append(ValidationError("TOO_MANY_PAYLOADS", "Payload list exceeds 1000 items"))

    affected = pattern.get("affected_components", [])
    if len(affected) > 20:
        errors.append(ValidationError("TOO_MANY_COMPONENTS", "Cannot list more than 20 affected components"))

    refs = pattern.get("references", [])
    if len(refs) > 20:
        errors.append(ValidationError("TOO_MANY_REFERENCES", "Cannot have more than 20 references"))

    severity_range = pattern.get("severity_range", {})
    if severity_range:
        valid_sev = ("low", "medium", "high", "critical")
        min_sev = severity_range.get("min", "")
        max_sev = severity_range.get("max", "")
        if min_sev and min_sev not in valid_sev:
            errors.append(ValidationError("INVALID_MIN_SEVERITY", f"Invalid min severity: {min_sev}"))
        if max_sev and max_sev not in valid_sev:
            errors.append(ValidationError("INVALID_MAX_SEVERITY", f"Invalid max severity: {max_sev}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateExploitationConfig(input) → ValidationResult

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

    delay = explo.get("delay_ms", 100)
    if not isinstance(delay, (int, float)) or delay < 0 or delay > 60000:
        errors.append(ValidationError("DELAY_OUT_OF_RANGE", "delay_ms must be 0-60000"))

    data_targets = explo.get("data_targets", [])
    valid_targets = ["user_data", "config", "tokens", "files", "env"]
    for dt in data_targets:
        if dt not in valid_targets:
            errors.append(ValidationError("INVALID_DATA_TARGET", f"Invalid data target: {dt}"))
    if len(data_targets) > 5:
        errors.append(ValidationError("TOO_MANY_DATA_TARGETS", "Cannot have more than 5 data targets"))

    if mode == "aggressive":
        errors.append(ValidationWarning(
            "AGGRESSIVE_MODE",
            "Aggressive exploitation mode selected."
        ))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateMitigationConfig(input) → ValidationResult

```python
def validate_mitigation_config(input_data):
    errors = []
    mit = input_data.get("mitigation", {})
    if not mit:
        return ValidationResult(valid=True, errors=[])

    priority = mit.get("priority", "")
    if priority and priority not in ("immediate", "short_term", "long_term"):
        errors.append(ValidationError("INVALID_PRIORITY", f"Invalid mitigation priority: {priority}"))

    effort = mit.get("effort", "")
    if effort and effort not in ("low", "medium", "high"):
        errors.append(ValidationError("INVALID_EFFORT", f"Invalid mitigation effort: {effort}"))

    categories = mit.get("categories", [])
    valid_cats = [
        "input_validation", "access_control", "authentication", "encryption",
        "configuration", "code_review", "monitoring", "training"
    ]
    for cat in categories:
        if cat not in valid_cats:
            errors.append(ValidationError("INVALID_CATEGORY", f"Invalid mitigation category: {cat}"))
    if len(categories) > 8:
        errors.append(ValidationError("TOO_MANY_CATEGORIES", "Cannot have more than 8 mitigation categories"))

    recs = mit.get("specific_recommendations", [])
    if len(recs) > 20:
        errors.append(ValidationError("TOO_MANY_RECOMMENDATIONS", "Cannot have more than 20 recommendations"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizePatternName(name) → str

```python
def sanitize_pattern_name(name):
    name = name.strip()
    name = re.sub(r'[<>"\';\\]', '', name)
    return name[:256]
```

### 5.2 sanitizePayloads(payloads) → list

```python
SANITIZE_PATTERNS = [
    r'rm\s+-rf\s+/', r'del\s+\/[sS]', r'format\s+[a-zA-Z]:',
    r'wget\s+.*\|\s*bash', r'curl\s+.*\|\s*sh',
    r'eval\s*\(', r'exec\s*\(',
]

def sanitize_payloads(payloads):
    sanitized = []
    for payload in payloads[:1000]:
        payload = str(payload)[:4096]
        is_dangerous = any(re.search(p, payload, re.IGNORECASE) for p in SANITIZE_PATTERNS)
        if not is_dangerous:
            sanitized.append(payload)
    return sanitized
```

### 5.3 sanitizeRecommendations(recs) → list

```python
def sanitize_recommendations(recs):
    sanitized = []
    for rec in recs[:20]:
        rec = str(rec).strip()[:1024]
        rec = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', rec)
        if rec:
            sanitized.append(rec)
    return sanitized
```

### 5.4 sanitizeEndpoint(endpoint) → str

```python
def sanitize_endpoint(endpoint):
    endpoint = endpoint.strip()
    endpoint = endpoint[:2048]
    endpoint = re.sub(r'[<>"\';\\]', '', endpoint)
    return endpoint
```

---

## 6. Type Coercion

### 6.1 coerceCaseType(raw_type) → str

```python
CASE_TYPE_MAP = {
    "idor": "idor", "idor": "idor",
    "xss": "stored_xss", "stored_xss": "stored_xss", "reflected_xss": "stored_xss",
    "sqli": "sqli", "sql_injection": "sqli",
    "ssrf": "ssrf", "server_side_request forgery": "ssrf",
    "csrf": "csrf", "cross_site_request_forgery": "csrf",
    "cmdi": "command_injection", "command_injection": "command_injection",
    "deser": "deserialization", "deserialization": "deserialization",
    "upload": "file_upload", "file_upload": "file_upload",
    "xxe": "xxe", "xml_external_entity": "xxe",
    "ssti": "ssti", "template_injection": "ssti",
    "jwt": "jwt_manipulation",
    "auth": "auth_bypass", "auth_bypass": "auth_bypass",
    "privesc": "privilege_escalation",
    "logic": "business_logic",
    "info": "info_disclosure", "info_disc": "info_disclosure",
    "overflow": "heap_overflow",
    "java_deser": "java_deser",
    "php_deser": "php_unserialize",
    "pickle": "python_pickle",
    "race": "race_condition",
    "host": "host_header",
    "dns": "dns_rebinding",
    "ws": "websocket_issues", "websocket": "websocket_issues",
    "gql": "graphql_introspection", "graphql": "graphql_introspection",
    "csp": "csp_bypass",
    "clickjack": "clickjacking",
    "splitting": "response_splitting",
    "ldap": "ldap_injection",
    "xpath": "xpath_injection",
    "nosql": "nosql_injection",
    "proto": "prototype_pollution",
    "subdomain": "subdomain_takeover",
    "redirect": "open_redirect",
    "spoof": "content_spoofing",
    "cache": "cache_poisoning",
    "smuggle": "request_smuggling",
    "ws_hijack": "websocket_hijacking",
    "cors": "cors_misconfiguration",
    "token": "token_leakage",
    "sensitive": "sensitive_data_exposure",
    "crypto": "weak_encryption",
    "crypto_store": "insecure_crypto_storage",
    "traversal": "path_traversal",
    "lfi": "lfi", "rfi": "rfi",
    "ssrf_f": "server_side_request_forgery",
    "csrf_f": "client_side_request_forgery",
    "mobile": "mobile_api_issues",
    "cloud": "cloud_misconfiguration",
    "api_auth": "api_auth_bypass"
}

def coerce_case_type(raw_type):
    return CASE_TYPE_MAP.get(str(raw_type).lower().strip(), raw_type)
```

### 6.2 coerceExploitationMode(raw_mode) → str

```python
def coerce_exploitation_mode(raw_mode):
    mode_map = {
        "safe": "safe", "careful": "safe",
        "normal": "normal", "standard": "normal",
        "aggressive": "aggressive", "full": "aggressive"
    }
    return mode_map.get(str(raw_mode).lower().strip(), "normal")
```

### 6.3 coerceSeverityRange(sev_range) → dict

```python
SEV_ORDER = {"low": 0, "medium": 1, "high": 2, "critical": 3}

def coerce_severity_range(sev_range):
    if not sev_range:
        return sev_range
    min_sev = sev_range.get("min", "low")
    max_sev = sev_range.get("max", "critical")
    if SEV_ORDER.get(min_sev, 0) > SEV_ORDER.get(max_sev, 3):
        sev_range["min"], sev_range["max"] = max_sev, min_sev
    return sev_range
```

### 6.4 coerceNumericParams(params) → dict

```python
def coerce_numeric_params(params):
    int_fields = ["max_requests", "delay_ms"]
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

### 7.1 validatePatternCaseTypeMatch(pattern, case_type) → list

```python
PATTERN_CASE_MAP = {
    "idor": ["idor"],
    "stored_xss": ["stored_xss"],
    "sqli": ["sqli"],
    "ssrf": ["ssrf", "server_side_request_forgery"],
    "csrf": ["csrf"],
    "command_injection": ["command_injection"],
    "deserialization": ["deserialization", "java_deser", "php_unserialize", "python_pickle"],
    "file_upload": ["file_upload"],
    "xxe": ["xxe"],
    "ssti": ["ssti"],
    "jwt_manipulation": ["jwt_manipulation"],
    "auth_bypass": ["auth_bypass"],
    "privilege_escalation": ["privilege_escalation"],
    "business_logic": ["business_logic"],
    "info_disclosure": ["info_disclosure"],
    "race_condition": ["race_condition"],
    "host_header": ["host_header"],
    "dns_rebinding": ["dns_rebinding"],
    "graphql_introspection": ["graphql_introspection"],
    "csp_bypass": ["csp_bypass"],
    "clickjacking": ["clickjacking"],
    "ldap_injection": ["ldap_injection"],
    "xpath_injection": ["xpath_injection"],
    "nosql_injection": ["nosql_injection"],
    "prototype_pollution": ["prototype_pollution"],
    "subdomain_takeover": ["subdomain_takeover"],
    "open_redirect": ["open_redirect"],
    "content_spoofing": ["content_spoofing"],
    "cache_poisoning": ["cache_poisoning"],
    "request_smuggling": ["request_smuggling"],
    "cors_misconfiguration": ["cors_misconfiguration"],
    "token_leakage": ["token_leakage"],
    "sensitive_data_exposure": ["sensitive_data_exposure"],
    "weak_encryption": ["weak_encryption"],
    "path_traversal": ["path_traversal", "lfi", "rfi"],
    "server_side_request_forgery": ["server_side_request_forgery"],
    "mobile_api_issues": ["mobile_api_issues"],
    "cloud_misconfiguration": ["cloud_misconfiguration"],
    "api_auth_bypass": ["api_auth_bypass"]
}

def validate_pattern_case_type_match(pattern, case_type):
    errors = []
    vuln_class = pattern.get("vulnerability_class", "")
    compatible = PATTERN_CASE_MAP.get(case_type, [])
    if compatible and vuln_class and vuln_class.lower() not in [c.lower() for c in compatible]:
        errors.append(ValidationWarning(
            "PATTERN_CASE_MISMATCH",
            f"Pattern vulnerability class '{vuln_class}' may not match case type '{case_type}'"
        ))
    return errors
```

### 7.2 validatePayloadSafety(payloads) → list

```python
def validate_payload_safety(payloads):
    errors = []
    dangerous = [
        (r'rm\s+-rf\s+/', "System file deletion"),
        (r'del\s+\/[sS]', "Windows file deletion"),
        (r'format\s+[a-zA-Z]:', "Drive formatting"),
        (r'wget.*\|.*bash', "Remote code execution"),
        (r'curl.*\|.*sh', "Remote code execution"),
    ]
    for i, payload in enumerate(payloads):
        for pattern, desc in dangerous:
            if re.search(pattern, payload, re.IGNORECASE):
                errors.append(ValidationError(
                    "DANGEROUS_PAYLOAD",
                    f"Payload {i} contains dangerous pattern: {desc}"
                ))
    return errors
```

### 7.3 validateMitigationCompleteness(mitigation, case_type) → list

```python
def validate_mitigation_completeness(mitigation, case_type):
    errors = []
    if not mitigation:
        errors.append(ValidationWarning("NO_MITIGATION", "No mitigation recommendations provided"))
        return errors

    priority = mitigation.get("priority", "")
    categories = mitigation.get("categories", [])
    recs = mitigation.get("specific_recommendations", [])

    if not priority:
        errors.append(ValidationWarning("NO_PRIORITY", "Mitigation priority not set"))
    if not categories:
        errors.append(ValidationWarning("NO_CATEGORIES", "No mitigation categories specified"))
    if not recs:
        errors.append(ValidationWarning("NO_RECOMMENDATIONS", "No specific recommendations provided"))

    if case_type in ("sqli", "nosql_injection", "ldap_injection", "xpath_injection"):
        if "input_validation" not in categories:
            errors.append(ValidationWarning(
                "MISSING_INPUT_VALIDATION",
                f"Injection type '{case_type}' should include input_validation mitigation"
            ))

    if case_type in ("idor", "auth_bypass", "privilege_escalation"):
        if "access_control" not in categories:
            errors.append(ValidationWarning(
                "MISSING_ACCESS_CONTROL",
                f"Auth type '{case_type}' should include access_control mitigation"
            ))

    return errors
```

### 7.4 validateSeverityRangeConsistency(severity_range, case_type) → list

```python
CASE_TYPE_EXPECTED_SEVERITY = {
    "sqli": "high", "command_injection": "critical", "ssrf": "high",
    "idor": "high", "auth_bypass": "critical", "privilege_escalation": "critical",
    "deserialization": "critical", "rce": "critical", "xxe": "high",
    "ssti": "critical", "file_upload": "high", "stored_xss": "medium",
    "csrf": "medium", "open_redirect": "medium", "info_disclosure": "low"
}

def validate_severity_range_consistency(severity_range, case_type):
    errors = []
    if not severity_range:
        return errors
    expected = CASE_TYPE_EXPECTED_SEVERITY.get(case_type, "")
    max_sev = severity_range.get("max", "")
    if expected and max_sev:
        SEV_ORDER = {"low": 0, "medium": 1, "high": 2, "critical": 3}
        if SEV_ORDER.get(max_sev, 0) < SEV_ORDER.get(expected, 0):
            errors.append(ValidationWarning(
                "SEVERITY_BELOW_EXPECTED",
                f"Max severity '{max_sev}' is below expected '{expected}' for '{case_type}'"
            ))
    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_CASE_TYPE` | ERROR | Case type not recognized |
| `PATTERN_NAME_EMPTY` | ERROR | Pattern name is required |
| `PATTERN_NAME_TOO_LONG` | ERROR | Pattern name exceeds 256 characters |
| `VULN_CLASS_EMPTY` | ERROR | Vulnerability class is required |
| `VULN_CLASS_TOO_LONG` | ERROR | Vulnerability class exceeds 128 characters |
| `ENDPOINT_TOO_LONG` | ERROR | Endpoint exceeds 2048 characters |
| `INVALID_METHOD` | ERROR | HTTP method not recognized |
| `TOO_MANY_PAYLOADS` | ERROR | Payload list exceeds 1000 items |
| `TOO_MANY_COMPONENTS` | ERROR | Cannot list more than 20 components |
| `TOO_MANY_REFERENCES` | ERROR | Cannot have more than 20 references |
| `INVALID_MIN_SEVERITY` | ERROR | Minimum severity not recognized |
| `INVALID_MAX_SEVERITY` | ERROR | Maximum severity not recognized |
| `INVALID_EXPLOIT_MODE` | ERROR | Exploitation mode not recognized |
| `MAX_REQUESTS_OUT_OF_RANGE` | ERROR | max_requests outside valid range |
| `DELAY_OUT_OF_RANGE` | ERROR | delay_ms outside valid range |
| `INVALID_DATA_TARGET` | ERROR | Data target not recognized |
| `TOO_MANY_DATA_TARGETS` | ERROR | More than 5 data targets |
| `AGGRESSIVE_MODE` | WARNING | Aggressive exploitation mode |
| `INVALID_PRIORITY` | ERROR | Mitigation priority not recognized |
| `INVALID_EFFORT` | ERROR | Mitigation effort not recognized |
| `INVALID_CATEGORY` | ERROR | Mitigation category not recognized |
| `TOO_MANY_CATEGORIES` | ERROR | More than 8 mitigation categories |
| `TOO_MANY_RECOMMENDATIONS` | ERROR | More than 20 recommendations |
| `PATTERN_CASE_MISMATCH` | WARNING | Pattern may not match case type |
| `DANGEROUS_PAYLOAD` | ERROR | Payload contains dangerous system command |
| `NO_MITIGATION` | WARNING | No mitigation recommendations |
| `NO_PRIORITY` | WARNING | Mitigation priority not set |
| `NO_CATEGORIES` | WARNING | No mitigation categories specified |
| `NO_RECOMMENDATIONS` | WARNING | No specific recommendations |
| `MISSING_INPUT_VALIDATION` | WARNING | Injection type should include input_validation |
| `MISSING_ACCESS_CONTROL` | WARNING | Auth type should include access_control |
| `SEVERITY_BELOW_EXPECTED` | WARNING | Severity below expected for case type |

---

## 9. Error Messages

```python
CASE_STUDY_ERROR_MESSAGES = {
    "INVALID_CASE_TYPE": "Case type not recognized. Check the supported vulnerability patterns.",
    "PATTERN_NAME_EMPTY": "Pattern name is required.",
    "PATTERN_NAME_TOO_LONG": "Pattern name must be 256 characters or fewer.",
    "VULN_CLASS_EMPTY": "Vulnerability class is required.",
    "VULN_CLASS_TOO_LONG": "Vulnerability class must be 128 characters or fewer.",
    "ENDPOINT_TOO_LONG": "Endpoint must be 2048 characters or fewer.",
    "INVALID_METHOD": "HTTP method not recognized.",
    "TOO_MANY_PAYLOADS": "Payload list cannot exceed 1000 items.",
    "TOO_MANY_COMPONENTS": "Cannot list more than 20 affected components.",
    "TOO_MANY_REFERENCES": "Cannot have more than 20 references.",
    "INVALID_MIN_SEVERITY": "Minimum severity not recognized.",
    "INVALID_MAX_SEVERITY": "Maximum severity not recognized.",
    "INVALID_EXPLOIT_MODE": "Exploitation mode must be: safe, normal, or aggressive.",
    "MAX_REQUESTS_OUT_OF_RANGE": "max_requests must be between 1 and 10000.",
    "DELAY_OUT_OF_RANGE": "delay_ms must be between 0 and 60000.",
    "INVALID_DATA_TARGET": "Data target not recognized.",
    "TOO_MANY_DATA_TARGETS": "Cannot have more than 5 data targets.",
    "AGGRESSIVE_MODE": "Aggressive exploitation mode selected.",
    "INVALID_PRIORITY": "Mitigation priority must be: immediate, short_term, or long_term.",
    "INVALID_EFFORT": "Mitigation effort must be: low, medium, or high.",
    "INVALID_CATEGORY": "Mitigation category not recognized.",
    "TOO_MANY_CATEGORIES": "Cannot have more than 8 mitigation categories.",
    "TOO_MANY_RECOMMENDATIONS": "Cannot have more than 20 specific recommendations.",
    "PATTERN_CASE_MISMATCH": "Pattern vulnerability class may not match the case type.",
    "DANGEROUS_PAYLOAD": "Payload contains a pattern associated with destructive system commands.",
    "NO_MITIGATION": "No mitigation recommendations provided.",
    "NO_PRIORITY": "Mitigation priority not set.",
    "NO_CATEGORIES": "No mitigation categories specified.",
    "NO_RECOMMENDATIONS": "No specific recommendations provided.",
    "MISSING_INPUT_VALIDATION": "Injection types should include input_validation mitigation.",
    "MISSING_ACCESS_CONTROL": "Auth types should include access_control mitigation.",
    "SEVERITY_BELOW_EXPECTED": "Severity is below the expected range for this vulnerability type.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| R001 | Case type must be valid | ERROR | No |
| R002 | Pattern name must be 1-256 chars | ERROR | Truncate |
| R003 | Vulnerability class is required | ERROR | No |
| R004 | Endpoint max 2048 chars | ERROR | Truncate |
| R005 | HTTP method must be valid | ERROR | No |
| R006 | Payloads max 1000 | ERROR | Truncate |
| R007 | Affected components max 20 | ERROR | Truncate |
| R008 | References max 20 | ERROR | Truncate |
| R009 | Severity range must be valid | ERROR | No |
| R010 | Exploitation mode must be valid | ERROR | Default to safe |
| R011 | max_requests must be 1-10000 | ERROR | Clamp |
| R012 | delay_ms must be 0-60000 | ERROR | Clamp |
| R013 | Data targets max 5 | ERROR | Truncate |
| R014 | Mitigation priority must be valid | ERROR | No |
| R015 | Mitigation effort must be valid | ERROR | No |
| R016 | Mitigation categories max 8 | ERROR | Truncate |
| R017 | Recommendations max 20 | ERROR | Truncate |
| R018 | Pattern should match case type | WARNING | No |
| R019 | Payloads should be safe | ERROR | Filter dangerous |
| R020 | Mitigation should be complete | WARNING | No |

---

## 11. Domain File References

All 50 files in `Real-World-Case-Studies/` that this validator covers:

| # | File | Case Type | Key Validation |
|---|------|-----------|----------------|
| 01 | `01-IDOR-Account-Takeover-Case-Studies.md` | idor | pattern, exploitation |
| 02 | `02-XSS-Stored-Persistent-Attacks.md` | stored_xss | pattern, payloads |
| 03 | `03-SQL-Injection-Data-Breaches.md` | sqli | pattern, payloads |
| 04 | `04-SSRF-Internal-Network-Access.md` | ssrf | pattern, exploitation |
| 05 | `05-CSRF-State-Changing-Attacks.md` | csrf | pattern |
| 06 | `06-Command-Injection-RCE.md` | command_injection | pattern, payloads |
| 07 | `07-Deserialization-Remote-Code-Execution.md` | deserialization | pattern, payloads |
| 08 | `08-File-Upload-Arbitrary-Upload.md` | file_upload | pattern, exploitation |
| 09 | `09-XXE-XML-External-Entity-Attacks.md` | xxe | pattern, payloads |
| 10 | `10-SSTI-Server-Side-Template-Injection.md` | ssti | pattern, payloads |
| 11 | `11-JWT-Token-Manipulation.md` | jwt_manipulation | pattern |
| 12 | `12-Authentication-Bypass.md` | auth_bypass | pattern, impact |
| 13 | `13-Privilege-Escalation.md` | privilege_escalation | pattern, impact |
| 14 | `14-Business-Logic-Flaws.md` | business_logic | pattern |
| 15 | `15-Information-Disclosure.md` | info_disclosure | pattern |
| 16 | `16-Memory-Corruption-Heap-Overflow.md` | heap_overflow | pattern |
| 17 | `17-Deserialization-Java-Deserialization.md` | java_deser | pattern, payloads |
| 18 | `18-Deserialization-PHP-Unserialize.md` | php_unserialize | pattern, payloads |
| 19 | `19-Deserialization-Python-Pickle.md` | python_pickle | pattern, payloads |
| 20 | `20-Race-Condition-Time-of-Check.md` | race_condition | pattern |
| 21 | `21-Host-Header-Injection.md` | host_header | pattern, headers |
| 22 | `22-DNS-Rebinding-Attacks.md` | dns_rebinding | pattern |
| 23 | `23-WebSocket-Security-Issues.md` | websocket_issues | pattern |
| 24 | `24-GraphQL-Introspection-Attacks.md` | graphql_introspection | pattern |
| 25 | `25-CSP-Bypass-Techniques.md` | csp_bypass | pattern |
| 26 | `26-Clickjacking-UI-Redressing.md` | clickjacking | pattern |
| 27 | `27-HTTP-Response-Splitting.md` | response_splitting | pattern, headers |
| 28 | `28-LDAP-Injection-Attacks.md` | ldap_injection | pattern, payloads |
| 29 | `29-XPath-Injection-Attacks.md` | xpath_injection | pattern, payloads |
| 30 | `30-NoSQL-Injection-MongoDB.md` | nosql_injection | pattern, payloads |
| 31 | `31-Prototype-Pollution-JavaScript.md` | prototype_pollution | pattern |
| 32 | `32-Subdomain-Takeover.md` | subdomain_takeover | pattern |
| 33 | `33-Open-Redirect-Phishing.md` | open_redirect | pattern |
| 34 | `34-Content-Spoofing-Attacks.md` | content_spoofing | pattern |
| 35 | `35-WebCache-Poisoning.md` | cache_poisoning | pattern |
| 36 | `36-HTTP-Request-Smuggling.md` | request_smuggling | pattern |
| 37 | `37-WebSocket-Hijacking.md` | websocket_hijacking | pattern |
| 38 | `38-CORS-Misconfiguration.md` | cors_misconfiguration | pattern |
| 39 | `39-Token-Leakage-URL-Parameters.md` | token_leakage | pattern |
| 40 | `40-Sensitive-Data-Exposure.md` | sensitive_data_exposure | pattern |
| 41 | `41-Weak-Encryption-Algorithms.md` | weak_encryption | pattern |
| 42 | `42-Insecure-Cryptographic-Storage.md` | insecure_crypto_storage | pattern |
| 43 | `43-Path-Traversal-File-Inclusion.md` | path_traversal | pattern, payloads |
| 44 | `44-Local-File-Inclusion-LFI.md` | lfi | pattern, payloads |
| 45 | `45-Remote-File-Inclusion-RFI.md` | rfi | pattern, payloads |
| 46 | `46-Server-Side-Request-Forgery.md` | server_side_request_forgery | pattern |
| 47 | `47-Client-Side-Request-Forgery.md` | client_side_request_forgery | pattern |
| 48 | `48-Mobile-API-Security-Issues.md` | mobile_api_issues | pattern |
| 49 | `49-Cloud-Misconfiguration-AWS.md` | cloud_misconfiguration | pattern |
| 50 | `50-API-Authentication-Bypass.md` | api_auth_bypass | pattern |

---

## 12. Validation Pipeline

```python
def validate_real_world_case_study_input(input_data):
    results = []
    results.append(("case_type", validate_case_type(input_data)))
    results.append(("pattern", validate_pattern_config(input_data)))
    results.append(("exploitation", validate_exploitation_config(input_data)))
    results.append(("mitigation", validate_mitigation_config(input_data)))

    pattern = input_data.get("pattern", {})
    case_type = input_data.get("case_type", "")
    results.append(("pattern_match", ValidationResult(
        valid=True, errors=validate_pattern_case_type_match(pattern, case_type)
    )))

    payloads = pattern.get("payloads", [])
    results.append(("payload_safety", ValidationResult(
        valid=len(validate_payload_safety(payloads)) == 0,
        errors=validate_payload_safety(payloads)
    )))

    mitigation = input_data.get("mitigation", {})
    results.append(("mitigation_completeness", ValidationResult(
        valid=True, errors=validate_mitigation_completeness(mitigation, case_type)
    )))

    severity_range = pattern.get("severity_range", {})
    results.append(("severity_consistency", ValidationResult(
        valid=True, errors=validate_severity_range_consistency(severity_range, case_type)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "real-world-case-studies", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Case study validation runs before any pattern analysis
- Pattern-case type matching warns about potential inconsistencies
- Payload safety checks filter dangerous system commands
- Mitigation completeness checks ensure actionable recommendations
- Severity range consistency checks validate against expected ranges
- All validation results are logged for analysis audit trail
- Type coercion normalizes case types and exploitation modes
- Severity range coercion ensures min <= max ordering

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Real-World Case Studies domain |
