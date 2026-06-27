# Advanced Chaining Techniques — Input Validation Reference

**Domain**: Advanced Chaining Techniques (Vulnerability Chain Exploitation)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all vulnerability chaining inputs across the Advanced-Chaining-Techniques domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `advanced-chaining-techniques` |
| Root Directory | `Advanced-Chaining-Techniques/` |
| Total Files | 49 (+ README.md, registry.json) |
| Category | Vulnerability Chaining, Multi-Stage Exploitation, Attack Chains |
| Input Surface | Chain definitions, vulnerability primitives, exploit sequences |

---

## 2. Overview

The Advanced Chaining Techniques validator enforces strict input validation for every chain definition in the `Advanced-Chaining-Techniques/` directory. Each file defines a vulnerability chaining pattern — from basic chaining to advanced persistent threat chains — and accepts structured inputs that describe multi-step exploitation paths. This validator ensures:

- Chain steps are defined in valid order with proper dependencies
- Vulnerability primitives have required fields (type, target, payload)
- Exploit sequences do not exceed maximum chain depth
- Primitives are compatible and can be logically connected
- Authorization and scope constraints are maintained across all chain steps
- Output capture points are properly defined
- Intermediate state is validated at each chain transition

---

## 3. Schema Definition

### 3.1 Master Chain Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ChainingInput",
  "type": "object",
  "required": ["domain", "chain"],
  "properties": {
    "domain": {
      "type": "string",
      "const": "advanced-chaining-techniques"
    },
    "chain": {
      "$ref": "#/definitions/ChainDefinition"
    },
    "context": {
      "$ref": "#/definitions/ChainContext"
    },
    "constraints": {
      "$ref": "#/definitions/ChainConstraints"
    },
    "output": {
      "$ref": "#/definitions/ChainOutput"
    }
  },
  "additionalProperties": false
}
```

### 3.2 ChainDefinition Schema

```json
{
  "definitions": {
    "ChainDefinition": {
      "type": "object",
      "required": ["name", "steps"],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 256,
          "pattern": "^[a-zA-Z0-9\\-\\_\\s]+$"
        },
        "description": {
          "type": "string",
          "maxLength": 4096
        },
        "steps": {
          "type": "array",
          "items": { "$ref": "#/definitions/ChainStep" },
          "minItems": 2,
          "maxItems": 50
        },
        "primitives": {
          "type": "array",
          "items": { "$ref": "#/definitions/VulnPrimitive" },
          "minItems": 1,
          "maxItems": 100
        },
        "maxDepth": {
          "type": "integer",
          "minimum": 2,
          "maximum": 50,
          "default": 20
        }
      },
      "additionalProperties": false
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
      "required": ["id", "type", "target"],
      "properties": {
        "id": {
          "type": "string",
          "pattern": "^[a-zA-Z0-9\\-]+$",
          "minLength": 1,
          "maxLength": 64
        },
        "type": {
          "type": "string",
          "enum": [
            "recon", "discovery", "exploitation", "post_exploitation",
            "lateral_movement", "privilege_escalation", "data_access",
            "exfiltration", "persistence", "evasion", "impact"
          ]
        },
        "target": { "$ref": "#/definitions/StepTarget" },
        "primitive": { "type": "string" },
        "payload": { "type": "string", "maxLength": 65536 },
        "dependencies": {
          "type": "array",
          "items": { "type": "string" },
          "default": []
        },
        "conditions": {
          "type": "array",
          "items": { "$ref": "#/definitions/StepCondition" },
          "default": []
        },
        "capture": {
          "type": "array",
          "items": { "$ref": "#/definitions/CapturePoint" },
          "default": []
        },
        "onFailure": {
          "type": "string",
          "enum": ["abort", "skip", "retry", "fallback"],
          "default": "abort"
        },
        "timeout": {
          "type": "integer",
          "minimum": 1000,
          "maximum": 600000,
          "default": 30000
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 VulnPrimitive Schema

```json
{
  "definitions": {
    "VulnPrimitive": {
      "type": "object",
      "required": ["id", "class", "severity"],
      "properties": {
        "id": { "type": "string", "pattern": "^[a-zA-Z0-9\\-]+$" },
        "class": {
          "type": "string",
          "enum": [
            "xss", "sqli", "ssrf", "csrf", "idor", "xxe", "ssti",
            "rce", "lfi", "rfi", "path_traversal", "open_redirect",
            "cors_misconfiguration", "jwt_flaw", "auth_bypass",
            "race_condition", "deserialization", "file_upload",
            "command_injection", "header_injection", "info_disclosure",
            "session_fixation", "host_header_injection", "cache_poisoning",
            "prototype_pollution", "nosql_injection", "graphql_abuse",
            "websocket_hijacking", "clickjacking", "request_smuggling"
          ]
        },
        "severity": {
          "type": "string",
          "enum": ["low", "medium", "high", "critical"]
        },
        "endpoint": { "type": "string", "maxLength": 2048 },
        "method": { "type": "string", "enum": ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"] },
        "parameters": { "type": "object" },
        "evidence": { "type": "string", "maxLength": 65536 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 StepTarget Schema

```json
{
  "definitions": {
    "StepTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["url", "endpoint", "parameter", "header", "cookie", "body", "file", "service"]
        },
        "value": { "type": "string", "maxLength": 2048 },
        "method": { "type": "string" },
        "content_type": { "type": "string" }
      }
    }
  }
}
```

### 3.6 ChainContext Schema

```json
{
  "definitions": {
    "ChainContext": {
      "type": "object",
      "properties": {
        "session_tokens": { "type": "object" },
        "cookies": { "type": "object" },
        "headers": { "type": "object", "additionalProperties": { "type": "string" } },
        "environment": { "type": "string", "enum": ["staging", "production", "lab", "unknown"] },
        "authorization_proof": { "type": "string", "maxLength": 4096 },
        "scope_document": { "type": "string", "maxLength": 4096 }
      }
    }
  }
}
```

### 3.7 ChainConstraints Schema

```json
{
  "definitions": {
    "ChainConstraints": {
      "type": "object",
      "properties": {
        "maxSteps": { "type": "integer", "minimum": 2, "maximum": 50, "default": 20 },
        "maxDuration": { "type": "integer", "minimum": 60, "maximum": 86400, "default": 3600 },
        "requiresAuthorization": { "type": "boolean", "default": true },
        "destructiveAllowed": { "type": "boolean", "default": false },
        "networkAccess": { "type": "boolean", "default": true },
        "interactiveSteps": { "type": "integer", "minimum": 0, "maximum": 10, "default": 0 }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateChainDefinition(input) → ValidationResult

```python
def validate_chain_definition(input_data):
    errors = []
    chain = input_data.get("chain", {})
    chain_name = chain.get("name", "")
    steps = chain.get("steps", [])

    if not chain_name:
        errors.append(ValidationError("CHAIN_NAME_EMPTY", "Chain name is required"))
    if len(chain_name) > 256:
        errors.append(ValidationError("CHAIN_NAME_TOO_LONG", "Chain name exceeds 256 characters"))
    if not re.match(r'^[a-zA-Z0-9\-\_\s]+$', chain_name):
        errors.append(ValidationError("CHAIN_NAME_INVALID_CHARS", "Chain name contains invalid characters"))

    if len(steps) < 2:
        errors.append(ValidationError("CHAIN_TOO_SHORT", "Chain must have at least 2 steps"))
    if len(steps) > 50:
        errors.append(ValidationError("CHAIN_TOO_LONG", "Chain cannot exceed 50 steps"))

    step_ids = set()
    for step in steps:
        step_id = step.get("id", "")
        if step_id in step_ids:
            errors.append(ValidationError("DUPLICATE_STEP_ID", f"Duplicate step ID: {step_id}"))
        step_ids.add(step_id)

        if not step_id:
            errors.append(ValidationError("STEP_ID_EMPTY", "Step ID cannot be empty"))
        if len(step_id) > 64:
            errors.append(ValidationError("STEP_ID_TOO_LONG", f"Step ID '{step_id}' exceeds 64 characters"))

    max_depth = chain.get("maxDepth", 20)
    if max_depth < 2 or max_depth > 50:
        errors.append(ValidationError("MAX_DEPTH_OUT_OF_RANGE", "maxDepth must be 2-50"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateChainStep(step, all_step_ids) → list

```python
def validate_chain_step(step, all_step_ids):
    errors = []

    step_id = step.get("id", "")
    step_type = step.get("type", "")

    if not step_type:
        errors.append(ValidationError("STEP_TYPE_EMPTY", f"Step '{step_id}' type is required"))
    if step_type not in ["recon", "discovery", "exploitation", "post_exploitation",
                          "lateral_movement", "privilege_escalation", "data_access",
                          "exfiltration", "persistence", "evasion", "impact"]:
        errors.append(ValidationError("INVALID_STEP_TYPE", f"Invalid step type: {step_type}"))

    target = step.get("target", {})
    if not target.get("type"):
        errors.append(ValidationError("TARGET_TYPE_MISSING", f"Step '{step_id}' target type is required"))
    if not target.get("value"):
        errors.append(ValidationError("TARGET_VALUE_MISSING", f"Step '{step_id}' target value is required"))
    if len(target.get("value", "")) > 2048:
        errors.append(ValidationError("TARGET_VALUE_TOO_LONG", f"Step '{step_id}' target value exceeds 2048 chars"))

    deps = step.get("dependencies", [])
    for dep in deps:
        if dep not in all_step_ids:
            errors.append(ValidationError("INVALID_DEPENDENCY", f"Step '{step_id}' depends on unknown step: {dep}"))

    payload = step.get("payload", "")
    if len(payload) > 65536:
        errors.append(ValidationError("PAYLOAD_TOO_LARGE", f"Step '{step_id}' payload exceeds 64KB"))

    timeout = step.get("timeout", 30000)
    if timeout < 1000 or timeout > 600000:
        errors.append(ValidationError("STEP_TIMEOUT_OUT_OF_RANGE", f"Step '{step_id}' timeout must be 1000-600000ms"))

    return errors
```

### 4.3 validateChainDependencies(steps) → list

```python
def validate_chain_dependencies(steps):
    errors = []
    step_ids = {s["id"] for s in steps}
    graph = {s["id"]: s.get("dependencies", []) for s in steps}
    visited = set()
    path = set()

    def has_cycle(node):
        if node in path:
            return True
        if node in visited:
            return False
        visited.add(node)
        path.add(node)
        for dep in graph.get(node, []):
            if dep in step_ids and has_cycle(dep):
                return True
        path.remove(node)
        return False

    for sid in step_ids:
        if has_cycle(sid):
            errors.append(ValidationError("CHAIN_CYCLE_DETECTED", f"Circular dependency in chain involving step: {sid}"))
            break

    roots = [s["id"] for s in steps if not s.get("dependencies")]
    if not roots:
        errors.append(ValidationError("NO_CHAIN_ROOT", "Chain has no root step (all steps have dependencies)"))

    reachable = set()
    def mark_reachable(node):
        if node in reachable:
            return
        reachable.add(node)
        for sid, deps in graph.items():
            if node in deps:
                mark_reachable(sid)

    for root in roots:
        mark_reachable(root)

    unreachable = step_ids - reachable
    for uid in unreachable:
        errors.append(ValidationError("UNREACHABLE_STEP", f"Step '{uid}' is unreachable from any root"))

    return errors
```

### 4.4 validatePrimitives(primitives) → list

```python
def validate_primitives(primitives):
    errors = []
    valid_classes = [
        "xss", "sqli", "ssrf", "csrf", "idor", "xxe", "ssti",
        "rce", "lfi", "rfi", "path_traversal", "open_redirect",
        "cors_misconfiguration", "jwt_flaw", "auth_bypass",
        "race_condition", "deserialization", "file_upload",
        "command_injection", "header_injection", "info_disclosure",
        "session_fixation", "host_header_injection", "cache_poisoning",
        "prototype_pollution", "nosql_injection", "graphql_abuse",
        "websocket_hijacking", "clickjacking", "request_smuggling"
    ]

    for prim in primitives:
        prim_id = prim.get("id", "")
        if not prim_id:
            errors.append(ValidationError("PRIMITIVE_ID_EMPTY", "Primitive ID is required"))
        prim_class = prim.get("class", "")
        if prim_class not in valid_classes:
            errors.append(ValidationError("INVALID_PRIMITIVE_CLASS", f"Invalid primitive class: {prim_class}"))
        severity = prim.get("severity", "")
        if severity not in ("low", "medium", "high", "critical"):
            errors.append(ValidationError("INVALID_SEVERITY", f"Invalid severity: {severity}"))
        endpoint = prim.get("endpoint", "")
        if len(endpoint) > 2048:
            errors.append(ValidationError("ENDPOINT_TOO_LONG", "Primitive endpoint exceeds 2048 characters"))
        method = prim.get("method", "")
        if method and method not in ("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"):
            errors.append(ValidationError("INVALID_HTTP_METHOD", f"Invalid HTTP method: {method}"))

    return errors
```

### 4.5 validateChainConstraints(constraints, chain) → list

```python
def validate_chain_constraints(constraints, chain):
    errors = []
    max_steps = constraints.get("maxSteps", 20)
    actual_steps = len(chain.get("steps", []))
    if actual_steps > max_steps:
        errors.append(ValidationError("CHAIN_EXCEEDS_MAX_STEPS", f"Chain has {actual_steps} steps but maxSteps is {max_steps}"))

    max_duration = constraints.get("maxDuration", 3600)
    if max_duration < 60 or max_duration > 86400:
        errors.append(ValidationError("DURATION_OUT_OF_RANGE", "maxDuration must be 60-86400 seconds"))

    if constraints.get("requiresAuthorization", True):
        context = chain.get("context", {})
        if not context.get("authorization_proof"):
            errors.append(ValidationError("AUTHORIZATION_REQUIRED", "Authorization proof is required"))

    if not constraints.get("destructiveAllowed", False):
        for step in chain.get("steps", []):
            if step.get("type") in ("exfiltration", "impact"):
                errors.append(ValidationError("DESTRUCTIVE_NOT_ALLOWED", f"Step '{step.get('id')}' requires destructiveAllowed=true"))

    return errors
```

---

## 5. Sanitize Operations

### 5.1 sanitizeChainName(name) → string

```python
def sanitize_chain_name(name):
    name = name.strip()
    name = re.sub(r'[^\w\-\s]', '', name)
    name = re.sub(r'\s+', '-', name)
    return name[:256]
```

### 5.2 sanitizeStepPayload(payload) → string

```python
def sanitize_step_payload(payload):
    if not payload:
        return ""
    payload = payload[:65536]
    payload = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', payload)
    return payload
```

### 5.3 sanitizeChainContext(context) → dict

```python
def sanitize_chain_context(context):
    sanitized = {}
    if "session_tokens" in context:
        sanitized["session_tokens"] = {
            k: v[:256] for k, v in context["session_tokens"].items()
        }
    if "cookies" in context:
        sanitized["cookies"] = {
            k: v[:4096] for k, v in context["cookies"].items()
        }
    if "headers" in context:
        sanitized["headers"] = {
            re.sub(r'[^\w\-]', '', k): v[:1024]
            for k, v in context["headers"].items()
        }
    sanitized["environment"] = context.get("environment", "unknown")
    if "authorization_proof" in context:
        sanitized["authorization_proof"] = context["authorization_proof"][:4096]
    if "scope_document" in context:
        sanitized["scope_document"] = context["scope_document"][:4096]
    return sanitized
```

### 5.4 sanitizePrimitiveEvidence(evidence) → string

```python
def sanitize_primitive_evidence(evidence):
    if not evidence:
        return ""
    evidence = evidence[:65536]
    evidence = re.sub(r'(<script[^>]*>)(.*?)(</script>)', r'\1[REDACTED]\3', evidence, flags=re.IGNORECASE | re.DOTALL)
    return evidence
```

---

## 6. Type Coercion

### 6.1 coerceChainSteps(raw_steps) → list

```python
def coerce_chain_steps(raw_steps):
    if isinstance(raw_steps, dict):
        raw_steps = [raw_steps]
    coerced = []
    for step in raw_steps:
        if not isinstance(step, dict):
            continue
        step.setdefault("id", f"step-{len(coerced) + 1}")
        step.setdefault("type", "recon")
        step.setdefault("target", {"type": "url", "value": ""})
        step.setdefault("dependencies", [])
        step.setdefault("conditions", [])
        step.setdefault("capture", [])
        step.setdefault("onFailure", "abort")
        step.setdefault("timeout", 30000)
        coerced.append(step)
    return coerced
```

### 6.2 coercePrimitives(raw_primitives) → list

```python
def coerce_primitives(raw_primitives):
    if isinstance(raw_primitives, dict):
        raw_primitives = [raw_primitives]
    coerced = []
    for prim in raw_primitives:
        if not isinstance(prim, dict):
            continue
        prim.setdefault("id", f"prim-{len(coerced) + 1}")
        prim.setdefault("class", "info_disclosure")
        prim.setdefault("severity", "medium")
        prim.setdefault("endpoint", "")
        prim.setdefault("method", "GET")
        prim.setdefault("parameters", {})
        prim.setdefault("evidence", "")
        coerced.append(prim)
    return coerced
```

### 6.3 coerceConstraints(raw_constraints) → dict

```python
def coerce_constraints(raw_constraints):
    if not isinstance(raw_constraints, dict):
        return {"maxSteps": 20, "maxDuration": 3600, "requiresAuthorization": True,
                "destructiveAllowed": False, "networkAccess": True, "interactiveSteps": 0}
    raw_constraints.setdefault("maxSteps", 20)
    raw_constraints.setdefault("maxDuration", 3600)
    raw_constraints.setdefault("requiresAuthorization", True)
    raw_constraints.setdefault("destructiveAllowed", False)
    raw_constraints.setdefault("networkAccess", True)
    raw_constraints.setdefault("interactiveSteps", 0)
    return raw_constraints
```

### 6.4 coerceStepType(raw_type) → str

```python
STEP_TYPE_MAP = {
    "recon": "recon", "reconnaissance": "recon",
    "discover": "discovery", "discovery": "discovery",
    "exploit": "exploitation", "exploitation": "exploitation",
    "post": "post_exploitation", "post_exploitation": "post_exploitation",
    "lateral": "lateral_movement", "lateral_movement": "lateral_movement",
    "privesc": "privilege_escalation", "privilege_escalation": "privilege_escalation",
    "data": "data_access", "data_access": "data_access",
    "exfil": "exfiltration", "exfiltration": "exfiltration",
    "persist": "persistence", "persistence": "persistence",
    "evade": "evasion", "evasion": "evasion",
    "impact": "impact",
}

def coerce_step_type(raw_type):
    raw_type = raw_type.lower().strip().replace(" ", "_").replace("-", "_")
    return STEP_TYPE_MAP.get(raw_type, "recon")
```

---

## 7. Custom Validators

### 7.1 validateChainLogicalFlow(steps) → list

```python
LOGICAL_ORDER = {
    "recon": 0, "discovery": 0,
    "exploitation": 1,
    "post_exploitation": 2,
    "lateral_movement": 3, "privilege_escalation": 3,
    "data_access": 4, "exfiltration": 5,
    "persistence": 6, "evasion": 7, "impact": 8
}

def validate_chain_logical_flow(steps):
    errors = []
    prev_order = -1
    for step in steps:
        step_type = step.get("type", "recon")
        current_order = LOGICAL_ORDER.get(step_type, 0)
        if current_order < prev_order:
            errors.append(ValidationError(
                "ILLEGAL_FLOW_ORDER",
                f"Step '{step.get('id')}' type '{step_type}' appears after a later phase in the kill chain"
            ))
        prev_order = current_order
    return errors
```

### 7.2 validatePrimitiveChainingCompatibility(primitives) → list

```python
INCOMPATIBLE_PAIRS = [
    ("xss", "sqli"),
    ("csrf", "ssrf"),
    ("idor", "xxe"),
]

def validate_primitive_chaining_compatibility(primitives):
    errors = []
    classes = [p.get("class", "") for p in primitives]
    for pair in INCOMPATIBLE_PAIRS:
        if pair[0] in classes and pair[1] in classes:
            endpoints_p1 = [p.get("endpoint") for p in primitives if p.get("class") == pair[0]]
            endpoints_p2 = [p.get("endpoint") for p in primitives if p.get("class") == pair[1]]
            if set(endpoints_p1) & set(endpoints_p2):
                errors.append(ValidationError(
                    "INCOMPATIBLE_PRIMITIVES",
                    f"Primitives '{pair[0]}' and '{pair[1]}' share endpoints and may conflict"
                ))
    return errors
```

### 7.3 validateCapturePoints(capture_points, step_ids) → list

```python
def validate_capture_points(capture_points, step_ids):
    errors = []
    for cp in capture_points:
        if "name" not in cp:
            errors.append(ValidationError("CAPTURE_NAME_MISSING", "Capture point must have a name"))
        if "step" in cp and cp["step"] not in step_ids:
            errors.append(ValidationError("CAPTURE_INVALID_STEP", f"Capture references unknown step: {cp['step']}"))
        if "type" not in cp:
            errors.append(ValidationError("CAPTURE_TYPE_MISSING", "Capture point must have a type"))
    return errors
```

### 7.4 validateChainSeverityEscalation(primitives) → list

```python
SEVERITY_ORDER = {"low": 0, "medium": 1, "high": 2, "critical": 3}

def validate_chain_severity_escalation(primitives):
    errors = []
    if len(primitives) < 2:
        return errors
    first_sev = SEVERITY_ORDER.get(primitives[0].get("severity", "low"), 0)
    last_sev = SEVERITY_ORDER.get(primitives[-1].get("severity", "low"), 0)
    if last_sev < first_sev:
        errors.append(ValidationWarning(
            "SEVERITY_DEESCALATION",
            "Chain ends with lower severity than it started. Verify chain impact assessment."
        ))
    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `CHAIN_NAME_EMPTY` | ERROR | Chain name is required |
| `CHAIN_NAME_TOO_LONG` | ERROR | Chain name exceeds 256 characters |
| `CHAIN_NAME_INVALID_CHARS` | ERROR | Chain name contains disallowed characters |
| `CHAIN_TOO_SHORT` | ERROR | Chain must have at least 2 steps |
| `CHAIN_TOO_LONG` | ERROR | Chain cannot exceed 50 steps |
| `DUPLICATE_STEP_ID` | ERROR | Two steps share the same ID |
| `STEP_ID_EMPTY` | ERROR | Step ID cannot be empty |
| `STEP_ID_TOO_LONG` | ERROR | Step ID exceeds 64 characters |
| `STEP_TYPE_EMPTY` | ERROR | Step type is required |
| `INVALID_STEP_TYPE` | ERROR | Step type not in valid enum |
| `TARGET_TYPE_MISSING` | ERROR | Step target type is required |
| `TARGET_VALUE_MISSING` | ERROR | Step target value is required |
| `TARGET_VALUE_TOO_LONG` | ERROR | Step target value exceeds 2048 characters |
| `INVALID_DEPENDENCY` | ERROR | Step depends on non-existent step |
| `PAYLOAD_TOO_LARGE` | ERROR | Step payload exceeds 64KB |
| `STEP_TIMEOUT_OUT_OF_RANGE` | ERROR | Step timeout outside 1000-600000ms |
| `CHAIN_CYCLE_DETECTED` | ERROR | Circular dependency detected in chain |
| `NO_CHAIN_ROOT` | ERROR | All steps have dependencies, no root exists |
| `UNREACHABLE_STEP` | ERROR | Step cannot be reached from any root |
| `PRIMITIVE_ID_EMPTY` | ERROR | Primitive ID is required |
| `INVALID_PRIMITIVE_CLASS` | ERROR | Primitive class not recognized |
| `INVALID_SEVERITY` | ERROR | Severity must be low/medium/high/critical |
| `ENDPOINT_TOO_LONG` | ERROR | Primitive endpoint exceeds 2048 characters |
| `INVALID_HTTP_METHOD` | ERROR | HTTP method not in valid list |
| `CHAIN_EXCEEDS_MAX_STEPS` | ERROR | Step count exceeds maxSteps constraint |
| `DURATION_OUT_OF_RANGE` | ERROR | maxDuration outside 60-86400 seconds |
| `AUTHORIZATION_REQUIRED` | ERROR | Authorization proof required when constraints mandate it |
| `DESTRUCTIVE_NOT_ALLOWED` | ERROR | Destructive steps require destructiveAllowed=true |
| `ILLEGAL_FLOW_ORDER` | ERROR | Step violates kill chain phase ordering |
| `INCOMPATIBLE_PRIMITIVES` | ERROR | Primitives conflict on shared endpoints |
| `CAPTURE_NAME_MISSING` | ERROR | Capture point must have a name |
| `CAPTURE_INVALID_STEP` | ERROR | Capture references non-existent step |
| `CAPTURE_TYPE_MISSING` | ERROR | Capture point type is required |
| `SEVERITY_DEESCALATION` | WARNING | Chain severity de-escalates |

---

## 9. Error Messages

```python
CHAIN_ERROR_MESSAGES = {
    "CHAIN_NAME_EMPTY": "Chain name is required. Provide a descriptive name for the attack chain.",
    "CHAIN_NAME_TOO_LONG": "Chain name must be 256 characters or fewer.",
    "CHAIN_NAME_INVALID_CHARS": "Chain name may only contain letters, numbers, hyphens, underscores, and spaces.",
    "CHAIN_TOO_SHORT": "A chain requires at least 2 steps to form a meaningful exploitation path.",
    "CHAIN_TOO_LONG": "Chain cannot exceed 50 steps. Break into sub-chains if needed.",
    "DUPLICATE_STEP_ID": "Each step must have a unique ID. No duplicates allowed.",
    "STEP_ID_EMPTY": "Step ID cannot be empty. Use a descriptive identifier.",
    "STEP_ID_TOO_LONG": "Step ID must be 64 characters or fewer.",
    "STEP_TYPE_EMPTY": "Step type is required. Specify the phase of the kill chain.",
    "INVALID_STEP_TYPE": "Step type not recognized. Valid types: recon, discovery, exploitation, etc.",
    "TARGET_TYPE_MISSING": "Step target type is required. Specify what the step targets.",
    "TARGET_VALUE_MISSING": "Step target value is required. Provide the specific target.",
    "TARGET_VALUE_TOO_LONG": "Step target value exceeds 2048 characters.",
    "INVALID_DEPENDENCY": "Step depends on a step ID that does not exist in the chain.",
    "PAYLOAD_TOO_LARGE": "Step payload exceeds 64KB limit.",
    "STEP_TIMEOUT_OUT_OF_RANGE": "Step timeout must be between 1000ms and 600000ms (10 minutes).",
    "CHAIN_CYCLE_DETECTED": "Chain contains a circular dependency. Resolve before execution.",
    "NO_CHAIN_ROOT": "All steps depend on other steps. At least one step must be a root.",
    "UNREACHABLE_STEP": "Step is not reachable from any root step.",
    "PRIMITIVE_ID_EMPTY": "Each vulnerability primitive must have a unique ID.",
    "INVALID_PRIMITIVE_CLASS": "Primitive class not recognized. Check the vulnerability taxonomy.",
    "INVALID_SEVERITY": "Severity must be one of: low, medium, high, critical.",
    "ENDPOINT_TOO_LONG": "Primitive endpoint URL exceeds 2048 characters.",
    "INVALID_HTTP_METHOD": "HTTP method must be GET, POST, PUT, DELETE, PATCH, OPTIONS, or HEAD.",
    "CHAIN_EXCEEDS_MAX_STEPS": "Chain step count exceeds the configured maximum.",
    "DURATION_OUT_OF_RANGE": "Chain maxDuration must be between 60 seconds and 86400 seconds (24 hours).",
    "AUTHORIZATION_REQUIRED": "Chain requires authorization proof. Document scope and permission.",
    "DESTRUCTIVE_NOT_ALLOWED": "Destructive operations (exfiltration, impact) require explicit permission.",
    "ILLEGAL_FLOW_ORDER": "Step type violates expected kill chain phase ordering.",
    "INCOMPATIBLE_PRIMITIVES": "Vulnerability primitives conflict on shared endpoints.",
    "CAPTURE_NAME_MISSING": "Capture points must have a name for data flow tracking.",
    "CAPTURE_INVALID_STEP": "Capture point references a step ID that does not exist.",
    "CAPTURE_TYPE_MISSING": "Capture points must specify a type (header, body, cookie, parameter).",
    "SEVERITY_DEESCALATION": "Chain severity de-escalates from start to end.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| C001 | Chain name must not be empty | ERROR | No |
| C002 | Chain must have 2-50 steps | ERROR | No |
| C003 | Step IDs must be unique | ERROR | Append suffix |
| C004 | Step type must be valid kill chain phase | ERROR | No |
| C005 | Step target type and value required | ERROR | No |
| C006 | Dependencies must reference existing steps | ERROR | No |
| C007 | No circular dependencies allowed | ERROR | Break cycle |
| C008 | Chain must have at least one root step | ERROR | No |
| C009 | All steps must be reachable from root | ERROR | Add path |
| C010 | Primitive class must be recognized | ERROR | No |
| C011 | Primitive severity must be valid | ERROR | Default to medium |
| C012 | Chain must respect maxSteps constraint | ERROR | Trim chain |
| C013 | Authorization proof required if mandated | ERROR | No |
| C014 | Destructive steps require explicit permission | ERROR | No |
| C015 | Kill chain phase order should be logical | WARNING | No |
| C016 | Capture points must have name and type | ERROR | No |
| C017 | Payload size must not exceed 64KB | ERROR | Truncate |
| C018 | Step timeout must be in valid range | ERROR | Clamp |
| C019 | Chain maxDepth must be 2-50 | ERROR | Clamp |
| C020 | Chain duration must be 60-86400 seconds | ERROR | Clamp |

---

## 11. Domain File References

All 49 files in `Advanced-Chaining-Techniques/` that this validator covers:

| # | File | Chain Type | Primary Primitives |
|---|------|------------|---------------------|
| 01 | `01-Basic-Vulnerability-Chaining.md` | Basic chain | Any two vulns |
| 02 | `02-Information-Disclosure-to-RCE.md` | Info disc → RCE | info_disclosure → rce |
| 03 | `03-XSS-to-Account-Takeover.md` | XSS → ATO | xss → session_fixation |
| 04 | `04-IDOR-to-Mass-Data-Extraction.md` | IDOR → exfil | idor → exfiltration |
| 05 | `05-SQL-Injection-to-Shell-Access.md` | SQLi → shell | sqli → command_injection |
| 06 | `06-SSRF-to-Internal-Network-Compromise.md` | SSRF → internal | ssrf → lateral_movement |
| 07 | `07-CORS-Misconfiguration-Chains.md` | CORS abuse | cors_misconfiguration → xss |
| 08 | `08-CSRF-to-Privilege-Escalation.md` | CSRF → privesc | csrf → privilege_escalation |
| 09 | `09-File-Upload-to-Web-Shell.md` | Upload → shell | file_upload → rce |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | XXE → data | xxe → data_access |
| 11 | `11-Deserialization-to-RCE.md` | Deser → RCE | deserialization → rce |
| 12 | `12-JWT-Manipulation-Chains.md` | JWT abuse | jwt_flaw → auth_bypass |
| 13 | `13-SSTI-to-Complete-Compromise.md` | SSTI → full | ssti → rce |
| 15 | `15-NoSQL-Injection-to-Data-Breach.md` | NoSQLi → breach | nosql_injection → exfiltration |
| 16 | `16-GraphQL-Abuse-Chains.md` | GraphQL chain | graphql_abuse → data_access |
| 17 | `17-WebSocket-Security-Chains.md` | WS chain | websocket_hijacking → xss |
| 18 | `18-Prototype-Pollution-Exploitation.md` | Proto pollution | prototype_pollution → rce |
| 19 | `19-HTTP-Request-Smuggling-Chains.md` | Smuggling chain | request_smuggling → cache_poisoning |
| 20 | `20-Host-Header-Injection-Chains.md` | Host header | host_header_injection → auth_bypass |
| 21 | `21-DNS-Rebinding-Attacks.md` | DNS rebinding | ssrf → internal |
| 22 | `22-Race-Condition-Exploitation.md` | Race chain | race_condition → privilege_escalation |
| 23 | `23-Subdomain-Takeover-Chains.md` | Subdomain takeover | open_redirect → persistence |
| 24 | `24-Open-Redirect-to-Phishing.md` | Redirect → phishing | open_redirect → info_disclosure |
| 25 | `25-Content-Spoofing-Chains.md` | Spoofing chain | header_injection → xss |
| 26 | `26-WebCache-Poisoning-Chains.md` | Cache poisoning | cache_poisoning → xss |
| 27 | `27-Clickjacking-to-Account-Compromise.md` | Clickjack chain | clickjacking → csrf |
| 28 | `28-Parameter-Pollution-Attacks.md` | Param pollution | header_injection → auth_bypass |
| 29 | `29-LDAP-Injection-Chains.md` | LDAP chain | command_injection → auth_bypass |
| 30 | `30-XPath-Injection-Exploitation.md` | XPath chain | command_injection → data_access |
| 31 | `31-Session-Puzzling-Techniques.md` | Session abuse | session_fixation → auth_bypass |
| 32 | `32-Insecure-File-Handling-Chains.md` | File handling | path_traversal → rce |
| 33 | `33-Cross-Site-Script-Inclusion.md` | XSSI chain | xss → data_access |
| 34 | `34-HTTP-Response-Splitting.md` | Response split | header_injection → xss |
| 35 | `35-Client-Side-Storage-Abuse.md` | Storage abuse | xss → persistence |
| 36 | `36-Cryptography-Weakness-Chains.md` | Crypto weakness | info_disclosure → auth_bypass |
| 37 | `37-Third-Party-Component-Chains.md` | 3rd party chain | info_disclosure → rce |
| 38 | `38-Configuration-Misconfiguration-Chains.md` | Config abuse | cors_misconfiguration → data_access |
| 39 | `39-Network-Infrastructure-Chains.md` | Network chain | ssrf → lateral_movement |
| 40 | `40-Mobile-API-Chains.md` | Mobile API chain | idor → data_access |
| 41 | `41-Cloud-Misconfiguration-Chains.md` | Cloud chain | ssrf → privilege_escalation |
| 42 | `42-Container-Escape-Chains.md` | Container escape | path_traversal → rce |
| 43 | `43-Kubernetes-Attack-Chains.md` | K8s chain | ssrf → privilege_escalation |
| 44 | `44-Blockchain-Exploit-Chains.md` | Blockchain chain | deserialization → data_access |
| 45 | `45-IoT-Device-Compromise-Chains.md` | IoT chain | command_injection → persistence |
| 46 | `46-Supply-Chain-Attack-Chains.md` | Supply chain | info_disclosure → rce |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | Zero-day chain | custom |
| 48 | `48-Multi-Platform-Attack-Chains.md` | Multi-platform | cross-domain |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | APT chain | multi-stage persistence |
| 50 | `50-Master-Chaining-Framework.md` | Master framework | all types |

---

## 12. Validation Pipeline

```python
def validate_chaining_input(input_data):
    results = []

    results.append(("chain_def", validate_chain_definition(input_data)))

    chain = input_data.get("chain", {})
    steps = chain.get("steps", [])
    step_ids = {s.get("id", "") for s in steps}

    for step in steps:
        step_errors = validate_chain_step(step, step_ids)
        results.append(("step_" + step.get("id", ""), ValidationResult(
            valid=len(step_errors) == 0, errors=step_errors
        )))

    results.append(("dependencies", ValidationResult(
        valid=len(validate_chain_dependencies(steps)) == 0,
        errors=validate_chain_dependencies(steps)
    )))

    primitives = chain.get("primitives", [])
    results.append(("primitives", ValidationResult(
        valid=len(validate_primitives(primitives)) == 0,
        errors=validate_primitives(primitives)
    )))

    results.append(("flow_order", ValidationResult(
        valid=len(validate_chain_logical_flow(steps)) == 0,
        errors=validate_chain_logical_flow(steps)
    )))

    constraints = input_data.get("constraints", {})
    results.append(("constraints", ValidationResult(
        valid=len(validate_chain_constraints(constraints, chain)) == 0,
        errors=validate_chain_constraints(constraints, chain)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid,
        errors=all_errors,
        meta={"validator": "advanced-chaining-techniques", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Chain validation runs before any exploitation step is queued
- Cyclic dependency detection uses DFS traversal
- Logical flow validation enforces kill chain phase ordering (soft check, warning only)
- Primitive compatibility validation is endpoint-aware
- Capture points are validated against step IDs
- Chain constraints override defaults when provided
- All chain validation results are logged for audit purposes
- Cross-chain validation (multiple chains) supported via the workflow orchestrator

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Advanced Chaining Techniques domain |
