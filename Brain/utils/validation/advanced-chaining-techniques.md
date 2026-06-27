# Advanced Chaining Techniques — Schema Validation Reference

**Domain**: Advanced Chaining Techniques (Vulnerability Chain Exploitation)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define schema validation rules, type validation, range validation, pattern matching, custom validators, sanitization, coercion, and error handling for all chain input parameters across the Advanced-Chaining-Techniques domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `advanced-chaining-techniques` |
| Root Directory | `Advanced-Chaining-Techniques/` |
| Total Files | 49 |
| Category | Vulnerability Chaining, Exploitation Chains, Multi-Stage Attacks |
| Input Surface | Chain primitives, step configs, target references, payload sequences |

---

## 2. Overview

The Advanced Chaining Techniques validator enforces strict schema validation for multi-stage vulnerability chain configurations. Each file defines a chaining technique — from basic vulnerability chaining to APT chains — and accepts structured inputs that must be validated at every stage boundary. This validator ensures:

- Chain steps reference valid vulnerability types
- Prerequisites are met before each chain stage
- Target references are within authorized scope
- Payload sequences do not exceed safety thresholds
- Chain step dependencies form a valid DAG (no cycles)
- Output from one step matches input expectations of the next

---

## 3. Schema Definition

### 3.1 Master Chain Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ChainInput",
  "type": "object",
  "required": ["domain", "chain_name", "steps"],
  "properties": {
    "domain": { "type": "string", "const": "advanced-chaining-techniques" },
    "chain_name": { "type": "string", "minLength": 1, "maxLength": 256 },
    "target": { "$ref": "#/definitions/ChainTarget" },
    "steps": {
      "type": "array",
      "items": { "$ref": "#/definitions/ChainStep" },
      "minItems": 1,
      "maxItems": 50
    },
    "config": { "$ref": "#/definitions/ChainConfig" },
    "output": { "$ref": "#/definitions/ChainOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 ChainTarget Schema

```json
{
  "definitions": {
    "ChainTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": { "type": "string", "enum": ["domain", "ip", "url", "api_endpoint", "service"] },
        "value": { "type": "string", "minLength": 1, "maxLength": 2048 },
        "scope": { "type": "array", "items": { "type": "string" } },
        "authorized": { "type": "boolean", "default": false }
      }
    }
  }
}
```

### 3.3 ChainStep Schema

```json
{
  "definitions": {
    "ChainStep": {
      "type": "object",
      "required": ["id", "vuln_type", "technique"],
      "properties": {
        "id": { "type": "string", "pattern": "^[a-zA-Z0-9_-]{1,64}$" },
        "vuln_type": {
          "type": "string",
          "enum": [
            "xss", "sqli", "ssrf", "idor", "csrf", "ssti", "xxe",
            "file_upload", "command_injection", "deserialization",
            "auth_bypass", "privilege_escalation", "race_condition",
            "open_redirect", "cors_misconfiguration", "host_header",
            "jwt_manipulation", "session_fixation", "info_disclosure",
            "prototype_pollution", "nosql_injection", "xpath_injection",
            "ldap_injection", "log_injection", "cache_poisoning",
            "request_smuggling", "clickjacking", "subdomain_takeover",
            "webshell", "pivot", "lateral_movement", "data_exfil",
            "credential_dump", "persistence", "c2_setup"
          ]
        },
        "technique": { "type": "string", "minLength": 1, "maxLength": 512 },
        "prerequisites": {
          "type": "array",
          "items": { "type": "string" },
          "default": []
        },
        "inputs": { "type": "object" },
        "outputs": { "type": "object" },
        "severity": { "type": "string", "enum": ["info", "low", "medium", "high", "critical"] },
        "max_retries": { "type": "integer", "minimum": 0, "maximum": 5, "default": 1 },
        "timeout_ms": { "type": "integer", "minimum": 1000, "maximum": 300000, "default": 30000 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 ChainConfig Schema

```json
{
  "definitions": {
    "ChainConfig": {
      "type": "object",
      "properties": {
        "parallel_execution": { "type": "boolean", "default": false },
        "fail_fast": { "type": "boolean", "default": true },
        "max_parallel_steps": { "type": "integer", "minimum": 1, "maximum": 10, "default": 1 },
        "total_timeout_ms": { "type": "integer", "minimum": 10000, "maximum": 3600000, "default": 300000 },
        "retry_backoff_ms": { "type": "integer", "minimum": 100, "maximum": 60000, "default": 1000 },
        "evidence_collection": { "type": "boolean", "default": true },
        "dry_run": { "type": "boolean", "default": false }
      }
    }
  }
}
```

### 3.5 ChainOutput Schema

```json
{
  "definitions": {
    "ChainOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "markdown", "csv"] },
        "include_evidence": { "type": "boolean", "default": true },
        "include_payloads": { "type": "boolean", "default": false },
        "redact_sensitive": { "type": "boolean", "default": true }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateChainSteps(steps) → ValidationResult

```python
def validate_chain_steps(steps):
    errors = []
    warnings = []
    step_ids = set()

    for i, step in enumerate(steps):
        step_id = step.get("id", "")
        if not step_id:
            errors.append(ValidationError("STEP_ID_EMPTY", f"Step at index {i} has no ID"))
            continue
        if step_id in step_ids:
            errors.append(ValidationError("DUPLICATE_STEP_ID", f"Duplicate step ID: {step_id}"))
        step_ids.add(step_id)

        prereqs = step.get("prerequisites", [])
        for prereq in prereqs:
            if prereq not in step_ids and prereq not in [s.get("id") for s in steps[:i]]:
                warnings.append(ValidationError(
                    "UNRESOLVED_PREREQUISITE",
                    f"Step {step_id} references prerequisite '{prereq}' not yet defined"
                ))

    return ValidationResult(valid=len(errors) == 0, errors=errors, warnings=warnings)
```

### 4.2 validateChainDependencyGraph(steps) → list

```python
def validate_chain_dependency_graph(steps):
    errors = []
    graph = {s["id"]: s.get("prerequisites", []) for s in steps}
    visited = set()
    path = set()

    def dfs(node):
        if node in path:
            errors.append(ValidationError("CYCLIC_CHAIN_DEPENDENCY", f"Circular dependency in chain: {node}"))
            return True
        if node in visited:
            return False
        visited.add(node)
        path.add(node)
        for dep in graph.get(node, []):
            if dep not in graph:
                errors.append(ValidationError("MISSING_DEPENDENCY", f"Step '{node}' depends on unknown step '{dep}'"))
            elif dfs(dep):
                return True
        path.remove(node)
        return False

    for node in graph:
        if dfs(node):
            break
    return errors
```

### 4.3 validateChainStepInputs(step, prev_outputs) → list

```python
def validate_chain_step_inputs(step, prev_outputs):
    errors = []
    inputs = step.get("inputs", {})
    for key, expected_type in inputs.items():
        if key.startswith("$ref:"):
            ref_step = key.split(":")[1]
            ref_field = expected_type
            if ref_step not in prev_outputs:
                errors.append(ValidationError(
                    "MISSING_STEP_OUTPUT",
                    f"Step '{step.get('id')}' requires output from step '{ref_step}'"
                ))
            elif ref_field not in prev_outputs.get(ref_step, {}):
                errors.append(ValidationError(
                    "MISSING_OUTPUT_FIELD",
                    f"Step '{step.get('id')}' requires field '{ref_field}' from step '{ref_step}'"
                ))
    return errors
```

### 4.4 validateChainSafety(steps) → list

```python
def validate_chain_safety(steps):
    errors = []
    high_risk_types = {"webshell", "c2_setup", "data_exfil", "credential_dump", "persistence", "lateral_movement"}
    for step in steps:
        if step.get("vuln_type") in high_risk_types:
            if not step.get("severity") == "critical":
                errors.append(ValidationError(
                    "HIGH_RISK_MISCLASSIFIED",
                    f"Step '{step.get('id')}' uses high-risk type '{step.get('vuln_type')}' but severity is not critical"
                ))
        if step.get("timeout_ms", 30000) > 120000:
            errors.append(ValidationError(
                "EXCESSIVE_STEP_TIMEOUT",
                f"Step '{step.get('id')}' timeout exceeds 120 seconds"
            ))
    return errors
```

---

## 5. Sanitize Operations

### 5.1 sanitizeChainStep(step) → dict

```python
def sanitize_chain_step(step):
    sanitized = {}
    sanitized["id"] = re.sub(r'[^a-zA-Z0-9_-]', '', step.get("id", ""))
    sanitized["id"] = sanitized["id"][:64]
    sanitized["vuln_type"] = step.get("vuln_type", "")
    sanitized["technique"] = re.sub(r'[<>"\';\\]', '', step.get("technique", ""))
    sanitized["technique"] = sanitized["technique"][:512]
    sanitized["prerequisites"] = [
        re.sub(r'[^a-zA-Z0-9_-]', '', p) for p in step.get("prerequisites", [])
    ]
    if "inputs" in step:
        sanitized["inputs"] = {
            re.sub(r'[^a-zA-Z0-9_.$:]', '', k): sanitize_value(v)
            for k, v in step["inputs"].items()
        }
    sanitized["severity"] = step.get("severity", "info")
    sanitized["max_retries"] = min(max(int(step.get("max_retries", 1)), 0), 5)
    sanitized["timeout_ms"] = min(max(int(step.get("timeout_ms", 30000)), 1000), 300000)
    return sanitized
```

### 5.2 sanitizeValue(value) → any

```python
def sanitize_value(value):
    if isinstance(value, str):
        return re.sub(r'[<>"\';\\]', '', value)[:4096]
    elif isinstance(value, list):
        return [sanitize_value(v) for v in value[:1000]]
    elif isinstance(value, dict):
        return {k: sanitize_value(v) for k, v in list(value.items())[:100]}
    return value
```

---

## 6. Type Coercion

### 6.1 coerceChainSteps(steps) → list

```python
def coerce_chain_steps(steps):
    if isinstance(steps, dict):
        steps = [steps]
    coerced = []
    for step in steps:
        if not isinstance(step, dict):
            continue
        step.setdefault("id", f"step_{len(coerced) + 1}")
        step.setdefault("vuln_type", "info_disclosure")
        step.setdefault("technique", "")
        step.setdefault("prerequisites", [])
        step.setdefault("inputs", {})
        step.setdefault("outputs", {})
        step.setdefault("severity", "info")
        step.setdefault("max_retries", 1)
        step.setdefault("timeout_ms", 30000)
        coerced.append(step)
    return coerced
```

### 6.2 coerceChainConfig(config) → dict

```json
{
  "default_config": {
    "parallel_execution": false,
    "fail_fast": true,
    "max_parallel_steps": 1,
    "total_timeout_ms": 300000,
    "retry_backoff_ms": 1000,
    "evidence_collection": true,
    "dry_run": false
  }
}
```

---

## 7. Custom Validators

### 7.1 validateChainReachability(steps) → list

```python
def validate_chain_reachability(steps):
    errors = []
    if not steps:
        errors.append(ValidationError("EMPTY_CHAIN", "Chain must have at least one step"))
        return errors
    step_map = {s["id"]: s for s in steps}
    root_steps = [s for s in steps if not s.get("prerequisites")]
    if not root_steps:
        errors.append(ValidationError("NO_ROOT_STEP", "Chain has no entry point (all steps have prerequisites)"))
    return errors
```

### 7.2 validateChainEscalation(steps) → list

```python
def validate_chain_escalation(steps):
    errors = []
    severity_order = {"info": 0, "low": 1, "medium": 2, "high": 3, "critical": 4}
    for i in range(1, len(steps)):
        prev_sev = severity_order.get(steps[i-1].get("severity", "info"), 0)
        curr_sev = severity_order.get(steps[i].get("severity", "info"), 0)
        if curr_sev < prev_sev - 1:
            errors.append(ValidationError(
                "SEVERITY_DEESCALATION",
                f"Step '{steps[i].get('id')}' has unexpectedly low severity after high-severity step"
            ))
    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `STEP_ID_EMPTY` | ERROR | Chain step has no ID |
| `DUPLICATE_STEP_ID` | ERROR | Two steps share the same ID |
| `UNRESOLVED_PREREQUISITE` | WARNING | Prerequisite step not yet defined |
| `CYCLIC_CHAIN_DEPENDENCY` | ERROR | Chain contains circular dependency |
| `MISSING_DEPENDENCY` | ERROR | Step depends on unknown step |
| `MISSING_STEP_OUTPUT` | ERROR | Required output from previous step not found |
| `MISSING_OUTPUT_FIELD` | ERROR | Specific field missing from step output |
| `HIGH_RISK_MISCLASSIFIED` | ERROR | High-risk vuln_type with non-critical severity |
| `EXCESSIVE_STEP_TIMEOUT` | WARNING | Step timeout exceeds 120 seconds |
| `EMPTY_CHAIN` | ERROR | Chain has no steps |
| `NO_ROOT_STEP` | ERROR | All steps have prerequisites — no entry point |
| `SEVERITY_DEESCALATION` | WARNING | Severity drops more than one level between steps |
| `CHAIN_NAME_EMPTY` | ERROR | Chain name is required |
| `CHAIN_NAME_TOO_LONG` | ERROR | Chain name exceeds 256 characters |
| `CHAIN_TOO_LONG` | ERROR | Chain exceeds 50 steps |

---

## 9. Error Messages

```python
ERROR_MESSAGES = {
    "STEP_ID_EMPTY": "Each chain step must have a non-empty ID.",
    "DUPLICATE_STEP_ID": "Two or more steps share the same ID. IDs must be unique.",
    "UNRESOLVED_PREREQUISITE": "A step references a prerequisite that has not been defined yet.",
    "CYCLIC_CHAIN_DEPENDENCY": "Chain contains a circular dependency that would prevent execution.",
    "MISSING_DEPENDENCY": "A step depends on an ID that does not exist in the chain.",
    "MISSING_STEP_OUTPUT": "Required output data from a previous step is not available.",
    "MISSING_OUTPUT_FIELD": "A specific field is missing from the output of a required step.",
    "HIGH_RISK_MISCLASSIFIED": "High-risk exploitation types must be marked as critical severity.",
    "EXCESSIVE_STEP_TIMEOUT": "Individual step timeout exceeds 120 seconds; consider breaking it up.",
    "EMPTY_CHAIN": "Chain must contain at least one step.",
    "NO_ROOT_STEP": "Every step has prerequisites; chain has no entry point.",
    "SEVERITY_DEESCALATION": "Unexpected severity drop between consecutive chain steps.",
    "CHAIN_NAME_EMPTY": "Chain name is required for identification and logging.",
    "CHAIN_NAME_TOO_LONG": "Chain name must be 256 characters or fewer.",
    "CHAIN_TOO_LONG": "Chain cannot exceed 50 steps; split into sub-chains.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| R001 | Chain name must not be empty | ERROR | No |
| R002 | Chain name must not exceed 256 chars | ERROR | Truncate |
| R003 | Chain must have 1-50 steps | ERROR | No |
| R004 | Each step must have a unique ID | ERROR | No |
| R005 | Step IDs must match ^[a-zA-Z0-9_-]{1,64}$ | ERROR | Sanitize |
| R006 | vuln_type must be in allowed enum | ERROR | No |
| R007 | technique must not exceed 512 chars | ERROR | Truncate |
| R008 | Prerequisites must reference existing step IDs | ERROR | No |
| R009 | Chain must not have cyclic dependencies | ERROR | No |
| R010 | Chain must have at least one root step | ERROR | No |
| R011 | step timeout must be 1000-300000ms | ERROR | Clamp |
| R012 | max_retries must be 0-5 | ERROR | Clamp |
| R013 | High-risk types must have critical severity | ERROR | No |
| R014 | Total chain timeout must be 10000-3600000ms | ERROR | Clamp |
| R015 | max_parallel_steps must be 1-10 | ERROR | Clamp |

---

## 11. Domain File References

All 49 files in `Advanced-Chaining-Techniques/` that this validator covers:

| # | File | Chain Profile |
|---|------|---------------|
| 01 | `01-Basic-Vulnerability-Chaining.md` | 2-3 step chains, common vuln types |
| 02 | `02-Information-Disclosure-to-RCE.md` | info_disclosure → command_injection |
| 03 | `03-XSS-to-Account-Takeover.md` | xss → session_fixation → auth_bypass |
| 04 | `04-IDOR-to-Mass-Data-Extraction.md` | idor → data_exfil |
| 05 | `05-SQL-Injection-to-Shell-Access.md` | sqli → webshell |
| 06 | `06-SSRF-to-Internal-Network-Compromise.md` | ssrf → pivot → lateral_movement |
| 07 | `07-CORS-Misconfiguration-Chains.md` | cors_misconfiguration → xss |
| 08 | `08-CSRF-to-Privilege-Escalation.md` | csrf → privilege_escalation |
| 09 | `09-File-Upload-to-Web-Shell.md` | file_upload → webshell |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | xxe → data_exfil |
| 11 | `11-Deserialization-to-RCE.md` | deserialization → command_injection |
| 12 | `12-JWT-Manipulation-Chains.md` | jwt_manipulation → auth_bypass |
| 13 | `13-SSTI-to-Complete-Compromise.md` | ssti → command_injection → persistence |
| 14 | `14-Command-Injection-to-Data-Breach.md` | command_injection → data_exfil |
| 15 | `15-NoSQL-Injection-to-Data-Breach.md` | nosql_injection → data_exfil |
| 16 | `16-GraphQL-Abuse-Chains.md` | info_disclosure → privilege_escalation |
| 17 | `17-WebSocket-Security-Chains.md` | auth_bypass → data_exfil |
| 18 | `18-Prototype-Pollution-Exploitation.md` | prototype_pollution → xss → auth_bypass |
| 19 | `19-HTTP-Request-Smuggling-Chains.md` | request_smuggling → auth_bypass |
| 20 | `20-Host-Header-Injection-Chains.md` | host_header → credential_dump |
| 21 | `21-DNS-Rebinding-Attacks.md` | ssrf → pivot |
| 22 | `22-Race-Condition-Exploitation.md` | race_condition → privilege_escalation |
| 23 | `23-Subdomain-Takeover-Chains.md` | subdomain_takeover → xss |
| 24 | `24-Open-Redirect-to-Phishing.md` | open_redirect → auth_bypass |
| 25 | `25-Content-Spoofing-Chains.md` | info_disclosure → xss |
| 26 | `26-WebCache-Poisoning-Chains.md` | cache_poisoning → xss |
| 27 | `27-Clickjacking-to-Account-Compromise.md` | clickjacking → auth_bypass |
| 28 | `28-Parameter-Pollution-Attacks.md` | info_disclosure → auth_bypass |
| 29 | `29-LDAP-Injection-Chains.md` | ldap_injection → auth_bypass |
| 30 | `30-XPath-Injection-Exploitation.md` | xpath_injection → data_exfil |
| 31 | `31-Session-Puzzling-Techniques.md` | session_fixation → auth_bypass |
| 32 | `32-Insecure-File-Handling-Chains.md` | file_upload → command_injection |
| 33 | `33-Cross-Site-Script-Inclusion.md` | xss → data_exfil |
| 34 | `34-HTTP-Response-Splitting.md` | log_injection → cache_poisoning |
| 35 | `35-Client-Side-Storage-Abuse.md` | xss → credential_dump |
| 36 | `36-Cryptography-Weakness-Chains.md` | info_disclosure → credential_dump |
| 37 | `37-Third-Party-Component-Chains.md` | info_disclosure → command_injection |
| 38 | `38-Configuration-Misconfiguration-Chains.md` | info_disclosure → privilege_escalation |
| 39 | `39-Network-Infrastructure-Chains.md` | ssrf → pivot → lateral_movement |
| 40 | `40-Mobile-API-Chains.md` | idor → data_exfil |
| 41 | `41-Cloud-Misconfiguration-Chains.md` | info_disclosure → privilege_escalation → data_exfil |
| 42 | `42-Container-Escape-Chains.md` | privilege_escalation → command_injection → lateral_movement |
| 43 | `43-Kubernetes-Attack-Chains.md` | info_disclosure → lateral_movement → persistence |
| 44 | `44-Blockchain-Exploit-Chains.md` | info_disclosure → data_exfil |
| 45 | `45-IoT-Device-Compromise-Chains.md` | command_injection → pivot |
| 46 | `46-Supply-Chain-Attack-Chains.md` | info_disclosure → webshell → persistence |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | multi-step novel chains |
| 48 | `48-Multi-Platform-Attack-Chains.md` | cross-platform chains |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | full APT lifecycle chains |
| 50 | `50-Master-Chaining-Framework.md` | meta-framework for all chains |

---

## 12. Validation Pipeline

```python
def validate_chain_input(input_data):
    results = []
    results.append(("chain_name", validate_chain_name(input_data)))
    results.append(("target", validate_chain_target(input_data)))

    steps = input_data.get("steps", [])
    coerced_steps = coerce_chain_steps(steps)
    results.append(("step_schema", validate_chain_step_schemas(coerced_steps)))
    results.append(("step_ids", validate_chain_steps(coerced_steps)))
    results.append(("dependency_graph", validate_chain_dependency_graph(coerced_steps)))
    results.append(("reachability", validate_chain_reachability(coerced_steps)))
    results.append(("escalation", validate_chain_escalation(coerced_steps)))
    results.append(("safety", validate_chain_safety(coerced_steps)))

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

- Chain validation runs before any exploitation step execution
- Each step output is validated against the next step's input requirements
- Dry-run mode validates the full chain without executing any steps
- Evidence collection is validated independently from chain execution
- Chain steps exceeding timeout thresholds trigger automatic fail-fast
- Cross-chain references (chaining multiple chains) require separate validation

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial schema validation reference for Advanced Chaining Techniques domain |
