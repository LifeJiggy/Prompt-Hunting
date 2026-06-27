# Core Prompts Hunting — Schema Validation Reference

**Domain**: Core Prompts Hunting (Vulnerability Hunting Prompts)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define schema validation rules, type validation, range validation, pattern matching, custom validators, sanitization, coercion, and error handling for all hunting prompt inputs across the Core-Prompts-hunting domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `core-prompts-hunting` |
| Root Directory | `Core-Prompts-hunting/` |
| Total Files | 50 |
| Category | Vulnerability Hunting, Reconnaissance, Exploitation, Reporting |
| Input Surface | Hunting targets, vuln type configs, payload params, scan settings |

---

## 2. Overview

The Core Prompts Hunting validator enforces strict schema validation for all vulnerability hunting inputs. Each file defines a hunting prompt for a specific vulnerability class — from reconnaissance to reporting — and accepts structured inputs that must be validated before prompt execution. This validator ensures:

- Hunting targets are within authorized scope
- Vulnerability type specifications are valid
- Payload configurations are safe and scoped
- Scan parameters are within safe ranges
- Hunting techniques are properly categorized
- All inputs are sanitized against injection

---

## 3. Schema Definition

### 3.1 Master Hunting Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CoreHuntingInput",
  "type": "object",
  "required": ["domain", "hunt_type", "target"],
  "properties": {
    "domain": { "type": "string", "const": "core-prompts-hunting" },
    "hunt_type": {
      "type": "string",
      "enum": [
        "reconnaissance", "javascript_analysis", "api_analysis",
        "authentication", "authorization", "input_validation",
        "cryptography", "client_storage", "business_logic",
        "error_handling", "file_upload", "ssrf", "xss",
        "csrf", "cors", "race_condition", "third_party",
        "config_hunting", "network_security", "mobile_api",
        "reporting", "waf_bypass", "http_smuggling",
        "xxe", "ssti", "command_injection", "nosql_injection",
        "jwt_vulnerabilities", "graphql", "websocket",
        "deserialization", "host_header", "subdomain_takeover",
        "session_puzzling", "clickjacking", "ldap_injection",
        "xpath_injection", "prototype_pollution", "http_response_splitting",
        "parameter_pollution", "csp_bypass", "xssi",
        "insecure_file_handling", "configuration_hunting"
      ]
    },
    "target": { "$ref": "#/definitions/HuntingTarget" },
    "config": { "$ref": "#/definitions/HuntingConfig" },
    "payloads": { "$ref": "#/definitions/HuntingPayloads" },
    "technique": { "$ref": "#/definitions/HuntingTechnique" }
  },
  "additionalProperties": false
}
```

### 3.2 HuntingTarget Schema

```json
{
  "definitions": {
    "HuntingTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": { "type": "string", "enum": ["domain", "url", "ip", "api_endpoint", "mobile_app", "source_code", "graphql", "websocket"] },
        "value": { "type": "string", "minLength": 1, "maxLength": 2048 },
        "scope": { "type": "array", "items": { "type": "string" } },
        "authorized": { "type": "boolean", "default": false },
        "context": { "type": "string", "maxLength": 4096 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.3 HuntingConfig Schema

```json
{
  "definitions": {
    "HuntingConfig": {
      "type": "object",
      "properties": {
        "depth": { "type": "integer", "minimum": 1, "maximum": 20, "default": 5 },
        "threads": { "type": "integer", "minimum": 1, "maximum": 100, "default": 10 },
        "timeout_ms": { "type": "integer", "minimum": 1000, "maximum": 120000, "default": 30000 },
        "rate_limit_rps": { "type": "number", "minimum": 0.1, "maximum": 50, "default": 5 },
        "max_findings": { "type": "integer", "minimum": 1, "maximum": 10000, "default": 100 },
        "severity_threshold": { "type": "string", "enum": ["info", "low", "medium", "high", "critical"], "default": "low" },
        "passive_only": { "type": "boolean", "default": false },
        "follow_redirects": { "type": "boolean", "default": false },
        "verify_ssl": { "type": "boolean", "default": true },
        "proxy": { "type": "string", "pattern": "^(https?|socks[45]?):\\/\\/.+" },
        "custom_headers": { "type": "object", "additionalProperties": { "type": "string" } },
        "cookies": { "type": "object", "additionalProperties": { "type": "string" } },
        "auth_token": { "type": "string", "maxLength": 8192 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 HuntingPayloads Schema

```json
{
  "definitions": {
    "HuntingPayloads": {
      "type": "object",
      "properties": {
        "category": { "type": "string", "enum": ["xss", "sqli", "ssrf", "command_injection", "ssti", "xxe", "path_traversal", "idor", "custom"] },
        "encoding": { "type": "string", "enum": ["none", "url", "html", "base64", "unicode", "double_url", "utf7"] },
        "list": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 5000
        },
        "max_length": { "type": "integer", "minimum": 1, "maximum": 5000, "default": 500 },
        "safe_mode": { "type": "boolean", "default": true },
        "test_reflection": { "type": "boolean", "default": true },
        "test_execution": { "type": "boolean", "default": false }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 HuntingTechnique Schema

```json
{
  "definitions": {
    "HuntingTechnique": {
      "type": "object",
      "properties": {
        "approach": { "type": "string", "enum": ["blackbox", "greybox", "whitebox"], "default": "blackbox" },
        "methodology": { "type": "string", "maxLength": 256 },
        "tools": {
          "type": "array",
          "items": { "type": "string", "maxLength": 128 },
          "maxItems": 20
        },
        "custom_rules": {
          "type": "array",
          "items": { "type": "string", "maxLength": 1024 },
          "maxItems": 50
        }
      },
      "additionalProperties": false
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateHuntingTarget(input) → ValidationResult

```python
def validate_hunting_target(input_data):
    errors = []
    target = input_data.get("target", {})

    if not target.get("value"):
        errors.append(ValidationError("TARGET_EMPTY", "Hunting target value cannot be empty"))
    if len(target.get("value", "")) > 2048:
        errors.append(ValidationError("TARGET_TOO_LONG", "Target value exceeds 2048 characters"))
    if not target.get("authorized", False):
        errors.append(ValidationError("TARGET_NOT_AUTHORIZED", "Target not authorized for hunting"))

    target_type = target.get("type", "")
    value = target.get("value", "")

    if target_type == "url":
        parsed = urlparse(value)
        if not parsed.scheme or not parsed.netloc:
            errors.append(ValidationError("INVALID_URL", f"Invalid URL: {value}"))
    elif target_type == "ip":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}(/\d{1,2})?$', value):
            errors.append(ValidationError("INVALID_IP", f"Invalid IP: {value}"))
    elif target_type == "domain":
        if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$', value):
            errors.append(ValidationError("INVALID_DOMAIN", f"Invalid domain: {value}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateHuntingConfig(input) → list

```python
def validate_hunting_config(input_data):
    errors = []
    config = input_data.get("config", {})

    threads = config.get("threads", 10)
    rate_limit = config.get("rate_limit_rps", 5)
    effective_rate = threads * rate_limit
    if effective_rate > 500:
        errors.append(ValidationError(
            "EFFECTIVE_RATE_TOO_HIGH",
            f"Effective rate ({effective_rate} rps) exceeds 500 rps"
        ))

    if not config.get("verify_ssl", True):
        errors.append(ValidationError(
            "SSL_VERIFY_DISABLED",
            "SSL verification is disabled"
        ))

    if config.get("auth_token") and len(config["auth_token"]) > 8192:
        errors.append(ValidationError(
            "AUTH_TOKEN_TOO_LONG",
            "Auth token exceeds 8192 characters"
        ))

    return errors
```

### 4.3 validatePayloadSafety(input) → list

```python
def validate_payload_safety(input_data):
    errors = []
    payloads = input_data.get("payloads", {})
    if not payloads:
        return errors

    payload_list = payloads.get("list", [])
    if len(payload_list) > 5000:
        errors.append(ValidationError("PAYLOAD_LIMIT", "Payload list exceeds 5000 items"))

    if payloads.get("safe_mode", True):
        dangerous = [r'rm\s+-rf', r'eval\s*\(', r'exec\s*\(', r'os\.system', r'subprocess']
        for i, p in enumerate(payload_list):
            for pattern in dangerous:
                if re.search(pattern, p, re.IGNORECASE):
                    errors.append(ValidationError(
                        "DANGEROUS_PAYLOAD",
                        f"Payload {i} matches dangerous pattern in safe mode"
                    ))

    if payloads.get("test_execution", False) and not payloads.get("safe_mode", True):
        errors.append(ValidationError(
            "EXECUTION_UNSAFE",
            "test_execution requires safe_mode=true"
        ))

    return errors
```

---

## 5. Sanitize Operations

### 5.1 sanitizeHuntingTarget(value, target_type) → string

```python
def sanitize_hunting_target(value, target_type):
    value = value.strip()
    value = re.sub(r'[<>"\';\\]', '', value)
    if target_type == "domain":
        value = value.lower()
    return value[:2048]
```

### 5.2 sanitizePayloads(payload_list) → list

```python
def sanitize_payloads(payload_list):
    sanitized = []
    for p in payload_list[:5000]:
        p = re.sub(r'\x00', '', p)
        p = p[:500]
        sanitized.append(p)
    return sanitized
```

---

## 6. Type Coercion

### 6.1 coerceHuntType(raw_value) → string

```python
def coerce_hunt_type(raw_value):
    raw_value = str(raw_value).lower().strip().replace(" ", "_").replace("-", "_")
    type_map = {
        "recon": "reconnaissance", "js": "javascript_analysis",
        "api": "api_analysis", "auth": "authentication",
        "authz": "authorization", "input": "input_validation",
        "crypto": "cryptography", "storage": "client_storage",
        "logic": "business_logic", "errors": "error_handling",
        "upload": "file_upload", "ssrf": "ssrf", "xss": "xss",
        "csrf": "csrf", "cors": "cors", "race": "race_condition",
        "third": "third_party", "config": "config_hunting",
        "network": "network_security", "mobile": "mobile_api",
        "report": "reporting", "waf": "waf_bypass", "smuggle": "http_smuggling",
        "jwt": "jwt_vulnerabilities", "gql": "graphql", "ws": "websocket",
        "deauth": "deserialization", "host": "host_header",
        "sub": "subdomain_takeover", "session": "session_puzzling",
        "click": "clickjacking", "ldap": "ldap_injection",
        "xpath": "xpath_injection", "proto": "prototype_pollution"
    }
    return type_map.get(raw_value, raw_value)
```

---

## 7. Custom Validators

### 7.1 validateHuntTypeTargetCompatibility(input) → list

```python
def validate_hunt_type_target_compatibility(input_data):
    errors = []
    hunt_type = input_data.get("hunt_type", "")
    target_type = input_data.get("target", {}).get("type", "")

    incompatible = {
        "graphql": ["ip", "domain"],
        "websocket": ["ip", "domain"],
        "mobile_api": ["ip", "domain"],
        "source_code": ["ip", "domain", "url"]
    }

    if hunt_type in incompatible and target_type in incompatible[hunt_type]:
        errors.append(ValidationError(
            "HUNT_TARGET_INCOMPATIBLE",
            f"Hunt type '{hunt_type}' requires target type not in {incompatible[hunt_type]}"
        ))

    return errors
```

### 7.2 validateSeverityThreshold(config, hunt_type) → list

```json
{
  "severity_minimums": {
    "reconnaissance": "info",
    "xss": "low",
    "sqli": "high",
    "ssrf": "high",
    "command_injection": "critical",
    "ssti": "critical",
    "deserialization": "critical",
    "authentication": "high",
    "authorization": "high"
  }
}
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `TARGET_EMPTY` | ERROR | Hunting target value cannot be empty |
| `TARGET_TOO_LONG` | ERROR | Target value exceeds 2048 characters |
| `TARGET_NOT_AUTHORIZED` | CRITICAL | Target not authorized for hunting |
| `INVALID_URL` | ERROR | URL format is invalid |
| `INVALID_IP` | ERROR | IP format is invalid |
| `INVALID_DOMAIN` | ERROR | Domain format is invalid |
| `EFFECTIVE_RATE_TOO_HIGH` | WARNING | Effective scan rate exceeds 500 rps |
| `SSL_VERIFY_DISABLED` | WARNING | SSL verification is disabled |
| `AUTH_TOKEN_TOO_LONG` | ERROR | Auth token exceeds 8192 characters |
| `PAYLOAD_LIMIT` | ERROR | Payload list exceeds 5000 items |
| `DANGEROUS_PAYLOAD` | ERROR | Payload matches dangerous pattern |
| `EXECUTION_UNSAFE` | ERROR | test_execution requires safe_mode |
| `HUNT_TARGET_INCOMPATIBLE` | ERROR | Hunt type incompatible with target type |

---

## 9. Error Messages

```python
ERROR_MESSAGES = {
    "TARGET_EMPTY": "Hunting target value cannot be empty.",
    "TARGET_TOO_LONG": "Target value exceeds 2048 characters.",
    "TARGET_NOT_AUTHORIZED": "Target has not been authorized for vulnerability hunting.",
    "INVALID_URL": "URL format is invalid. Ensure scheme and host are present.",
    "INVALID_IP": "IP address format is invalid.",
    "INVALID_DOMAIN": "Domain format is invalid.",
    "EFFECTIVE_RATE_TOO_HIGH": "Effective scan rate exceeds 500 rps safety limit.",
    "SSL_VERIFY_DISABLED": "SSL verification is disabled; data may be intercepted.",
    "AUTH_TOKEN_TOO_LONG": "Auth token exceeds 8192 character limit.",
    "PAYLOAD_LIMIT": "Payload list cannot exceed 5000 items.",
    "DANGEROUS_PAYLOAD": "Payload contains a dangerous pattern blocked in safe mode.",
    "EXECUTION_UNSAFE": "Execution testing requires safe_mode to be enabled.",
    "HUNT_TARGET_INCOMPATIBLE": "Hunt type is not compatible with the specified target type.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| R001 | Target value must not be empty | ERROR | No |
| R002 | Target must be authorized | CRITICAL | No |
| R003 | Effective scan rate <= 500 rps | WARNING | Reduce threads |
| R004 | SSL verification should be enabled | WARNING | Enable |
| R005 | Payload count <= 5000 | ERROR | Truncate |
| R006 | Safe mode blocks dangerous payloads | ERROR | Strip |
| R007 | Execution testing requires safe_mode | ERROR | No |
| R008 | Hunt type must be compatible with target | ERROR | No |
| R009 | Auth token <= 8192 chars | ERROR | Truncate |
| R010 | Hunt type must be in allowed enum | ERROR | No |

---

## 11. Domain File References

All 50 files in `Core-Prompts-hunting/` that this validator covers:

| # | File | Hunting Profile |
|---|------|-----------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery.md` | hunt_type: reconnaissance, target: domain/url |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation.md` | hunt_type: javascript_analysis, target: url |
| 03 | `3-API-Endpoint-Analysis.md` | hunt_type: api_analysis, target: url/api |
| 04 | `4-Authentication-and-Session-Management.md` | hunt_type: authentication, target: url |
| 05 | `5-Authorization-and-Access-Control.md` | hunt_type: authorization, target: url |
| 06 | `6-Input-Validation-and-Sanitization.md` | hunt_type: input_validation, target: url |
| 07 | `7-Business-Logic-Flaws.md` | hunt_type: business_logic, target: url |
| 08 | `8-Client-Side-Storage-Security.md` | hunt_type: client_storage, target: url |
| 09 | `9-Cryptography-and-Data-Protection.md` | hunt_type: cryptography, target: url |
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | hunt_type: error_handling, target: url |
| 11 | `11-File-Upload-and-Processing.md` | hunt_type: file_upload, target: url |
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | hunt_type: ssrf, target: url |
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | hunt_type: csrf, target: url |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | hunt_type: cors, target: url |
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | hunt_type: race_condition, target: url |
| 16 | `16-Third-Party-Component-Analysis.md` | hunt_type: third_party, target: url |
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | hunt_type: config_hunting, target: url |
| 18 | `18-Network-and-Infrastructure-Security.md` | hunt_type: network_security, target: ip/url |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | hunt_type: mobile_api, target: mobile_app |
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | hunt_type: reporting, target: any |
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | hunt_type: waf_bypass, target: url |
| 22 | `22-HTTP-Request-Smuggling.md` | hunt_type: http_smuggling, target: url |
| 23 | `23-Subdomain-Takeover.md` | hunt_type: subdomain_takeover, target: domain |
| 24 | `24-Host-Header-Injection.md` | hunt_type: host_header, target: url |
| 25 | `25-XML-External-Entity-XXE-Injection.md` | hunt_type: xxe, target: url |
| 26 | `26-Insecure-Deserialization.md` | hunt_type: deserialization, target: url |
| 27 | `27-Command-Injection.md` | hunt_type: command_injection, target: url |
| 28 | `28-NoSQL-Injection.md` | hunt_type: nosql_injection, target: url |
| 29 | `29-GraphQL-Vulnerabilities.md` | hunt_type: graphql, target: graphql |
| 30 | `30-WebSocket-Security.md` | hunt_type: websocket, target: websocket |
| 31 | `31-Server-Side-Template-Injection.md` | hunt_type: ssti, target: url |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | hunt_type: jwt_vulnerabilities, target: url |
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | hunt_type: csp_bypass, target: url |
| 34 | `34-Clickjacking-and-UI-Redressing.md` | hunt_type: clickjacking, target: url |
| 35 | `35-HTTP-Parameter-Pollution.md` | hunt_type: parameter_pollution, target: url |
| 36 | `36-LDAP-Injection.md` | hunt_type: ldap_injection, target: url |
| 37 | `37-Session-Puzzling-and-Fixation.md` | hunt_type: session_puzzling, target: url |
| 38 | `38-Insecure-File-Handling.md` | hunt_type: insecure_file_handling, target: url |
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | hunt_type: xssi, target: url |
| 40 | `40-Prototype-Pollution.md` | hunt_type: prototype_pollution, target: url |
| 41 | `41-HTTP-Response-Splitting.md` | hunt_type: http_response_splitting, target: url |
| 42 | `42-XPath-Injection.md` | hunt_type: xpath_injection, target: url |
| 43 | `43-Cross-Site-Request-Forgery-CSRF.md` | hunt_type: csrf, target: url |
| 44 | `44-Cross-Origin-Resource-Sharing-CORS.md` | hunt_type: cors, target: url |
| 45 | `45-Race-Conditions-and-Concurrency-Issues.md` | hunt_type: race_condition, target: url |
| 46 | `46-Third-Party-Component-Analysis.md` | hunt_type: third_party, target: url |
| 47 | `47-Configuration-and-Misconfiguration-Hunting.md` | hunt_type: configuration_hunting, target: url |
| 48 | `48-Network-and-Infrastructure-Security.md` | hunt_type: network_security, target: ip/url |
| 49 | `49-Mobile-and-API-Specific-Vulnerabilities.md` | hunt_type: mobile_api, target: mobile_app |
| 50 | `50-Reporting-and-Proof-of-Concept-Development.md` | hunt_type: reporting, target: any |

---

## 12. Validation Pipeline

```python
def validate_core_hunting_input(input_data):
    results = []
    results.append(("target", validate_hunting_target(input_data)))
    results.append(("config", validate_hunting_config(input_data)))
    results.append(("payloads", validate_payload_safety(input_data)))
    results.append(("compat", validate_hunt_type_target_compatibility(input_data)))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    all_warnings = []
    for name, result in results:
        all_errors.extend(result.errors)
        all_warnings.extend(result.warnings)

    return ValidationResult(
        valid=all_valid, errors=all_errors, warnings=all_warnings,
        meta={"validated_at": datetime.utcnow().isoformat(), "validator_version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Authorization checks are enforced at CRITICAL level
- Hunt type / target compatibility is checked before execution
- Safe mode is enforced by default for payload validation
- Effective scan rate is validated against safety limits
- All validation results are logged for audit
- Hunt-specific severity thresholds are applied per vulnerability class

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial schema validation reference for Core Prompts Hunting domain |
