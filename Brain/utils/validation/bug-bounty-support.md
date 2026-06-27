# Bug Bounty Support — Schema Validation Reference

**Domain**: Bug Bounty Support (Hunting Support & Testing Prompts)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define schema validation rules, type validation, range validation, pattern matching, custom validators, sanitization, coercion, and error handling for all support prompt inputs across the bug-bounty-support domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `bug-bounty-support` |
| Root Directory | `bug-bounty-support/` |
| Total Files | 23 |
| Category | Hunting Prompts, Testing Support, Recon, Exploitation, Reporting |
| Input Surface | Target data, test configs, payload inputs, prompt parameters |

---

## 2. Overview

The Bug Bounty Support validator enforces strict schema validation for all hunting support inputs. Each file defines a support prompt — from reconnaissance to advanced vulnerability hunting — and accepts structured inputs that must be validated before prompt execution. This validator ensures:

- Target references are within authorized scope
- Test configurations are safe and scoped
- Payload inputs are sanitized
- Prompt parameters match expected types
- Reporting data is complete and accurate
- JavaScript analysis inputs are properly formatted

---

## 3. Schema Definition

### 3.1 Master Support Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "BugBountySupportInput",
  "type": "object",
  "required": ["domain", "prompt_type", "target"],
  "properties": {
    "domain": { "type": "string", "const": "bug-bounty-support" },
    "prompt_type": {
      "type": "string",
      "enum": [
        "recon", "testing", "exploitation", "reporting", "analysis",
        "javascript", "tools", "advanced_hunting", "parameters",
        "chaining", "ethical", "debugging", "disclosure", "poc",
        "vulnerability_detection", "injection_identification", "static_dynamic"
      ]
    },
    "target": { "$ref": "#/definitions/SupportTarget" },
    "config": { "$ref": "#/definitions/TestConfig" },
    "payloads": { "$ref": "#/definitions/PayloadConfig" },
    "output": { "$ref": "#/definitions/OutputConfig" }
  },
  "additionalProperties": false
}
```

### 3.2 SupportTarget Schema

```json
{
  "definitions": {
    "SupportTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": { "type": "string", "enum": ["domain", "url", "ip", "api_endpoint", "mobile_app", "source_code"] },
        "value": { "type": "string", "minLength": 1, "maxLength": 2048 },
        "scope": { "type": "array", "items": { "type": "string" }, "default": [] },
        "authorized": { "type": "boolean", "default": false },
        "notes": { "type": "string", "maxLength": 4096 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.3 TestConfig Schema

```json
{
  "definitions": {
    "TestConfig": {
      "type": "object",
      "properties": {
        "mode": { "type": "string", "enum": ["passive", "active", "semi_passive"], "default": "passive" },
        "severity_filter": {
          "type": "array",
          "items": { "type": "string", "enum": ["info", "low", "medium", "high", "critical"] },
          "default": ["medium", "high", "critical"]
        },
        "vuln_categories": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": [
              "xss", "sqli", "ssrf", "idor", "csrf", "ssti", "xxe",
              "file_upload", "command_injection", "auth_bypass",
              "info_disclosure", "open_redirect", "race_condition",
              "jwt_vulnerabilities", "session_management", "misconfiguration"
            ]
          },
          "maxItems": 20
        },
        "rate_limit_rps": { "type": "number", "minimum": 0.1, "maximum": 100, "default": 10 },
        "max_requests": { "type": "integer", "minimum": 1, "maximum": 1000000, "default": 10000 },
        "timeout_ms": { "type": "integer", "minimum": 1000, "maximum": 300000, "default": 30000 },
        "follow_redirects": { "type": "boolean", "default": false },
        "verify_ssl": { "type": "boolean", "default": true },
        "custom_headers": { "type": "object", "additionalProperties": { "type": "string" } }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 PayloadConfig Schema

```json
{
  "definitions": {
    "PayloadConfig": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string",
          "enum": ["xss", "sqli", "ssrf", "command_injection", "ssti", "xxe", "path_traversal", "custom"]
        },
        "encoding": { "type": "string", "enum": ["none", "url", "html", "base64", "unicode", "double_url"] },
        "payloads": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 10000
        },
        "wordlist": { "type": "string", "maxLength": 4096 },
        "max_payload_length": { "type": "integer", "minimum": 1, "maximum": 10000, "default": 1000 },
        "safe_mode": { "type": "boolean", "default": true }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 OutputConfig Schema

```json
{
  "definitions": {
    "OutputConfig": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "markdown", "csv", "text"], "default": "json" },
        "include_evidence": { "type": "boolean", "default": true },
        "include_payloads": { "type": "boolean", "default": false },
        "redact_sensitive": { "type": "boolean", "default": true },
        "verbose": { "type": "boolean", "default": false }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateSupportTarget(input) → ValidationResult

```python
def validate_support_target(input_data):
    errors = []
    target = input_data.get("target", {})

    if not target.get("value"):
        errors.append(ValidationError("TARGET_VALUE_EMPTY", "Target value cannot be empty"))
    if len(target.get("value", "")) > 2048:
        errors.append(ValidationError("TARGET_VALUE_TOO_LONG", "Target value exceeds 2048 characters"))
    if not target.get("authorized", False):
        errors.append(ValidationError("TARGET_NOT_AUTHORIZED", "Target has not been authorized"))

    target_type = target.get("type", "")
    value = target.get("value", "")

    if target_type == "url":
        parsed = urlparse(value)
        if not parsed.scheme or not parsed.netloc:
            errors.append(ValidationError("INVALID_URL", f"Invalid URL format: {value}"))
    elif target_type == "ip":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}(/\d{1,2})?$', value):
            errors.append(ValidationError("INVALID_IP", f"Invalid IP format: {value}"))
    elif target_type == "domain":
        if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$', value):
            errors.append(ValidationError("INVALID_DOMAIN", f"Invalid domain: {value}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateTestConfig(input) → list

```python
def validate_test_config(input_data):
    errors = []
    config = input_data.get("config", {})

    mode = config.get("mode", "passive")
    rate_limit = config.get("rate_limit_rps", 10)
    max_requests = config.get("max_requests", 10000)

    if mode == "active" and rate_limit > 50:
        errors.append(ValidationError(
            "ACTIVE_MODE_HIGH_RATE",
            "Active mode rate limit should be <= 50 rps"
        ))

    effective_total = rate_limit * (config.get("timeout_ms", 30000) / 1000)
    if effective_total > max_requests:
        errors.append(ValidationError(
            "REQUEST_BUDGET_EXCEEDED",
            "Effective request count exceeds max_requests"
        ))

    if not config.get("verify_ssl", True) and mode == "active":
        errors.append(ValidationError(
            "SSL_VERIFY_DISABLED",
            "SSL verification is disabled in active mode"
        ))

    return errors
```

### 4.3 validatePayloadConfig(input) → list

```python
def validate_payload_config(input_data):
    errors = []
    payloads = input_data.get("payloads", {})
    if not payloads:
        return errors

    payload_list = payloads.get("payloads", [])
    if len(payload_list) > 10000:
        errors.append(ValidationError("PAYLOAD_LIMIT_EXCEEDED", "Payload array exceeds 10000 items"))

    max_len = payloads.get("max_payload_length", 1000)
    for i, p in enumerate(payload_list):
        if len(p) > max_len:
            errors.append(ValidationError(
                "PAYLOAD_TOO_LONG",
                f"Payload at index {i} exceeds max length of {max_len}"
            ))

    if payloads.get("safe_mode", True):
        dangerous = [r'rm\s+-rf', r'eval\s*\(', r'exec\s*\(', r'__import__']
        for i, p in enumerate(payload_list):
            for pattern in dangerous:
                if re.search(pattern, p, re.IGNORECASE):
                    errors.append(ValidationError(
                        "DANGEROUS_PAYLOAD",
                        f"Payload at index {i} matches dangerous pattern in safe mode"
                    ))

    return errors
```

---

## 5. Sanitize Operations

### 5.1 sanitizeTargetValue(value, target_type) → string

```python
def sanitize_target_value(value, target_type):
    value = value.strip()
    value = re.sub(r'[<>"\';\\]', '', value)
    if target_type == "domain":
        value = value.lower()
    elif target_type == "url":
        parsed = urlparse(value)
        value = f"{parsed.scheme}://{parsed.netloc}{parsed.path}"
    return value[:2048]
```

### 5.2 sanitizePayloads(payloads) → list

```python
def sanitize_payloads(payload_list):
    sanitized = []
    for p in payloads[:10000]:
        p = re.sub(r'\x00', '', p)
        p = p[:1000]
        sanitized.append(p)
    return sanitized
```

---

## 6. Type Coercion

### 6.1 coercePromptType(raw_value) → string

```python
def coerce_prompt_type(raw_value):
    raw_value = str(raw_value).lower().strip().replace(" ", "_").replace("-", "_")
    valid_types = {
        "recon", "reconnaissance", "testing", "test", "exploitation", "exploit",
        "reporting", "report", "analysis", "analyze", "javascript", "js",
        "tools", "tool", "advanced_hunting", "advanced", "parameters", "params",
        "chaining", "chain", "ethical", "ethics", "debugging", "debug",
        "disclosure", "info_disclosure", "poc", "proof_of_concept",
        "vulnerability_detection", "vuln_detect", "injection_identification",
        "injection", "static_dynamic", "static", "dynamic"
    }
    type_map = {
        "reconnaissance": "recon", "test": "testing", "exploit": "exploitation",
        "report": "reporting", "analyze": "analysis", "js": "javascript",
        "tool": "tools", "advanced": "advanced_hunting", "params": "parameters",
        "chain": "chaining", "ethics": "ethical", "debug": "debugging",
        "info_disclosure": "disclosure", "proof_of_concept": "poc",
        "vuln_detect": "vulnerability_detection", "injection": "injection_identification",
        "static": "static_dynamic", "dynamic": "static_dynamic"
    }
    if raw_value in type_map:
        return type_map[raw_value]
    if raw_value in valid_types:
        return raw_value
    return "testing"
```

---

## 7. Custom Validators

### 7.1 validateEthicalCompliance(input) → list

```python
def validate_ethical_compliance(input_data):
    errors = []
    config = input_data.get("config", {})
    if config.get("mode") == "active":
        if not input_data.get("target", {}).get("authorized", False):
            errors.append(ValidationError(
                "UNAUTHORIZED_ACTIVE_TESTING",
                "Active testing requires explicit authorization"
            ))
    return errors
```

### 7.2 validatePromptCompleteness(input) → list

```python
def validate_prompt_completeness(input_data):
    errors = []
    prompt_type = input_data.get("prompt_type", "")
    target = input_data.get("target", {})

    required_by_type = {
        "recon": ["target"],
        "testing": ["target", "config"],
        "exploitation": ["target", "config", "payloads"],
        "reporting": ["target"],
        "javascript": ["target"],
        "advanced_hunting": ["target", "config"],
        "poc": ["target", "payloads"]
    }

    required = required_by_type.get(prompt_type, ["target"])
    for field in required:
        if not input_data.get(field):
            errors.append(ValidationError(
                "MISSING_REQUIRED_FIELD",
                f"Prompt type '{prompt_type}' requires field '{field}'"
            ))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `TARGET_VALUE_EMPTY` | ERROR | Target value cannot be empty |
| `TARGET_VALUE_TOO_LONG` | ERROR | Target value exceeds 2048 characters |
| `TARGET_NOT_AUTHORIZED` | CRITICAL | Target has not been authorized |
| `INVALID_URL` | ERROR | URL format is invalid |
| `INVALID_IP` | ERROR | IP format is invalid |
| `INVALID_DOMAIN` | ERROR | Domain format is invalid |
| `ACTIVE_MODE_HIGH_RATE` | WARNING | Active mode rate limit too high |
| `REQUEST_BUDGET_EXCEEDED` | WARNING | Request count exceeds budget |
| `SSL_VERIFY_DISABLED` | WARNING | SSL verification disabled in active mode |
| `PAYLOAD_LIMIT_EXCEEDED` | ERROR | Payload array exceeds 10000 items |
| `PAYLOAD_TOO_LONG` | ERROR | Individual payload exceeds max length |
| `DANGEROUS_PAYLOAD` | ERROR | Payload matches dangerous pattern in safe mode |
| `UNAUTHORIZED_ACTIVE_TESTING` | CRITICAL | Active testing requires authorization |
| `MISSING_REQUIRED_FIELD` | ERROR | Required field missing for prompt type |

---

## 9. Error Messages

```python
ERROR_MESSAGES = {
    "TARGET_VALUE_EMPTY": "Target value cannot be empty. Provide a valid domain, URL, or IP.",
    "TARGET_VALUE_TOO_LONG": "Target value exceeds the maximum length of 2048 characters.",
    "TARGET_NOT_AUTHORIZED": "Target has not been authorized for testing. Set authorized=true.",
    "INVALID_URL": "URL format is invalid. Ensure scheme and host are present.",
    "INVALID_IP": "IP address format is invalid. Expected: dotted-decimal notation.",
    "INVALID_DOMAIN": "Domain format is invalid. Expected: subdomain.example.tld",
    "ACTIVE_MODE_HIGH_RATE": "Active mode rate limit exceeds recommended maximum of 50 rps.",
    "REQUEST_BUDGET_EXCEEDED": "Effective request count exceeds the configured maximum.",
    "SSL_VERIFY_DISABLED": "SSL verification is disabled; this may expose sensitive data.",
    "PAYLOAD_LIMIT_EXCEEDED": "Payload array cannot exceed 10,000 items.",
    "PAYLOAD_TOO_LONG": "Individual payload exceeds the configured maximum length.",
    "DANGEROUS_PAYLOAD": "Payload contains a pattern associated with destructive operations.",
    "UNAUTHORIZED_ACTIVE_TESTING": "Active testing requires explicit authorization.",
    "MISSING_REQUIRED_FIELD": "A required field is missing for the specified prompt type.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| R001 | Target value must not be empty | ERROR | No |
| R002 | Target must be marked as authorized | CRITICAL | No |
| R003 | Active mode rate limit <= 50 rps | WARNING | Cap at 50 |
| R004 | Payload count <= 10000 | ERROR | Truncate |
| R005 | Individual payload length <= max_payload_length | ERROR | Truncate |
| R006 | Safe mode blocks dangerous payloads | ERROR | Strip pattern |
| R007 | SSL verification required for active mode | WARNING | Enable |
| R008 | Required fields must be present per prompt type | ERROR | No |
| R009 | Effective requests must not exceed max_requests | WARNING | Reduce rate |
| R010 | Target type must be in allowed enum | ERROR | No |

---

## 11. Domain File References

All 23 files in `bug-bounty-support/` that this validator covers:

| # | File | Validation Profile |
|---|------|--------------------|
| 01 | `Advanced-Bug-Security-Hunting-Prompt.md` | prompt_type: advanced_hunting, target: required |
| 02 | `Advanced-Bug-Bounty-Prompt.md` | prompt_type: advanced_hunting, config: required |
| 03 | `Advanced-Information-Disclosure-Analysis-Prompt.md` | prompt_type: disclosure, target: url |
| 04 | `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | prompt_type: javascript, target: url |
| 05 | `Advanced-Techniques.md` | prompt_type: advanced_hunting, payloads: optional |
| 06 | `Burp-AI.md` | prompt_type: tools, config: tool integration |
| 07 | `Chaining.md` | prompt_type: chaining, config: chain steps |
| 08 | `Core-Aspects-for-Bug-Security-Hunting.md` | prompt_type: testing, config: severity_filter |
| 09 | `debuging-using-browser-console-and-vscode-for-hunting.md` | prompt_type: debugging, target: url |
| 10 | `Ethical-Guidelines.md` | prompt_type: ethical, authorization check |
| 11 | `Exploitation.md` | prompt_type: exploitation, payloads: required |
| 12 | `JavaScript-Identification-Deobfuscation.md` | prompt_type: javascript, target: url |
| 13 | `manual-testing-scope.md` | prompt_type: testing, scope: required |
| 14 | `parameters.md` | prompt_type: parameters, config: params |
| 15 | `PoC-Development.md` | prompt_type: poc, target + payloads: required |
| 16 | `Reconnaissance.md` | prompt_type: recon, target: required |
| 17 | `Reporting.md` | prompt_type: reporting, output: required |
| 18 | `Specific-Vulnerabilities-Hunting.md` | prompt_type: vulnerability_detection, categories |
| 19 | `to-identify-injection-and-reflected-point-during-testing.md` | prompt_type: injection_identification |
| 20 | `Tools-Integration.md` | prompt_type: tools, config: tool settings |
| 21 | `user-functionality.md` | prompt_type: testing, config: mode |
| 22 | `Vulnerability-Detection.md` | prompt_type: vulnerability_detection, severity |
| 23 | `static-and-dynamic-testing.md` | prompt_type: static_dynamic, config: mode |

---

## 12. Validation Pipeline

```python
def validate_bug_bounty_support_input(input_data):
    results = []
    results.append(("target", validate_support_target(input_data)))
    results.append(("test_config", validate_test_config(input_data)))
    results.append(("payloads", validate_payload_config(input_data)))
    results.append(("ethical", validate_ethical_compliance(input_data)))
    results.append(("completeness", validate_prompt_completeness(input_data)))

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
- Safe mode is enforced by default for payload validation
- Active mode requires SSL verification
- All validation results are logged for audit purposes
- Ethical compliance is checked before any test execution
- Prompt completeness ensures all required data is available
- Cross-file validation ensures consistent testing parameters

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial schema validation reference for Bug Bounty Support domain |
