# Tool Validators

**Component:** Input Validation and Sanitization

Validates tool inputs against JSON schemas before execution. Provides type checking, value constraints, input sanitization, and custom validation rules. Prevents malformed or malicious inputs from reaching tool binaries.

---

## Overview

The `ToolValidator` is the first line of defense in the tool execution pipeline. Every tool invocation passes through validation before reaching the executor. Validation ensures inputs conform to declared schemas, dangerous characters are sanitized, and custom business rules are enforced.

---

## Core Class: ToolValidator

```python
class ToolValidator:
    """
    Validates and sanitizes tool inputs against declared schemas.
    
    Performs JSON Schema validation, type coercion, input sanitization,
    and custom validator execution. Returns structured validation results.
    """
    
    def __init__(self, config: ValidatorConfig = None):
        self._registry = None        # ToolRegistry reference
        self._custom_validators = {} # name → validator function
        self._sanitizers = {}        # type → sanitizer function
```

---

## Validation Methods

### validate()

Validate tool input against its declared schema.

```python
def validate(
    self,
    tool: str,
    input: dict,
    strict: bool = True
) -> ValidationResult:
    """
    Validate input parameters for a specific tool.
    
    Args:
        tool: Tool name to look up schema from registry
        input: Input parameters to validate
        strict: If True, reject unknown properties
    
    Returns:
        ValidationResult with valid flag, errors, and sanitized input
    """
```

**Example:**

```python
result = validator.validate(
    tool="nuclei",
    input={
        "targets": ["https://target.com"],
        "severity": ["high", "critical"]
    }
)

if result.valid:
    # Use result.sanitized_input for execution
    executor.run(tool="nuclei", input=result.sanitized_input)
else:
    # Handle validation errors
    for error in result.errors:
        print(f"Field: {error.path}, Error: {error.message}")
```

### validate_raw()

Validate against an arbitrary JSON schema (not registered tool).

```python
def validate_raw(
    self,
    input: dict,
    schema: dict,
    strict: bool = True
) -> ValidationResult:
    """
    Validate input against a provided JSON Schema.
    
    Use for ad-hoc validation without a registered tool.
    """
```

---

## JSON Schema Validation

All tool inputs are validated using JSON Schema Draft-07:

### Type Checking

```python
# Schema declares type
schema = {
    "type": "object",
    "properties": {
        "targets": {"type": "array", "items": {"type": "string"}},
        "timeout": {"type": "integer", "minimum": 1, "maximum": 3600},
        "verbose": {"type": "boolean"},
        "output_file": {"type": "string", "pattern": "^[a-zA-Z0-9_\\-\\.]+$"}
    },
    "required": ["targets"]
}

# Validation catches:
# - targets: "https://target.com" → "expected array, got string"
# - timeout: "30" → "expected integer, got string"
# - verbose: "yes" → "expected boolean, got string"
# - output_file: "../etc/passwd" → "matches no allowed pattern"
```

### Constraint Checking

| Constraint | Description |
|------------|-------------|
| `minimum` / `maximum` | Numeric range bounds |
| `minLength` / `maxLength` | String length bounds |
| `minItems` / `maxItems` | Array length bounds |
| `enum` | Allowed value list |
| `pattern` | Regex pattern match |
| `format` | Built-in format (uri, email, date) |
| `exclusiveMinimum` / `exclusiveMaximum` | Strict numeric bounds |

### Required Fields

```python
schema = {
    "type": "object",
    "properties": {
        "targets": {"type": "array"},
        "templates": {"type": "array"},
        "severity": {"type": "array"}
    },
    "required": ["targets"]  # Only targets is mandatory
}
```

### Nested Object Validation

```python
schema = {
    "type": "object",
    "properties": {
        "scan_config": {
            "type": "object",
            "properties": {
                "ports": {"type": "string"},
                "rate": {"type": "integer"},
                "timing": {"type": "string", "enum": ["T1", "T2", "T3", "T4", "T5"]}
            },
            "required": ["ports"]
        }
    }
}
```

---

## Input Sanitization

Before schema validation, inputs are sanitized to remove dangerous content:

### Sanitization Rules

| Rule | Target | Action |
|------|--------|--------|
| **Path traversal** | All strings | Remove `../` sequences |
| **Shell injection** | Command-related strings | Escape `;`, `\|`, `&`, `` ` ``, `$()` |
| **Null bytes** | All strings | Strip `\x00` characters |
| **Unicode normalization** | All strings | NFC normalization |
| **Length truncation** | All strings | Truncate to `max_string_length` (default: 10000) |
| **HTML stripping** | Description fields | Remove HTML tags |
| **URL normalization** | URL strings | Normalize scheme, host, path |

### Sanitization Pipeline

```
Raw Input
    │
    ▼
┌──────────────────┐
│ Null byte strip   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Unicode normalize │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Path traversal    │
│ remove            │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Shell escape      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Length truncate   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Schema validation │
└──────────────────┘
```

---

## Type Coercion

The validator can coerce loosely-typed inputs to match schema types:

```python
@dataclass
class CoercionConfig:
    enabled: bool = True
    rules: dict = field(default_factory=lambda: {
        # "string" → "integer": parse int
        "string_to_integer": True,
        # "string" → "boolean": "true"/"false"/"1"/"0"
        "string_to_boolean": True,
        # "string" → "array": wrap single string in array
        "string_to_array": True,
        # "string" → "string": trim whitespace
        "trim_strings": True,
        # "integer" → "string": convert to string
        "integer_to_string": False
    })
```

**Examples:**

```python
# Input with loose types
input = {
    "targets": "https://target.com",    # string, expected array
    "timeout": "30",                     # string, expected integer
    "verbose": "true"                    # string, expected boolean
}

# After coercion:
input = {
    "targets": ["https://target.com"],   # wrapped in array
    "timeout": 30,                        # parsed to integer
    "verbose": True                       # parsed to boolean
}
```

---

## Custom Validators

Register custom validation functions for tool-specific business rules:

### Registering Custom Validators

```python
def validate_target_not_internal(value, context):
    """Reject private IP ranges."""
    import ipaddress
    for target in value:
        try:
            ip = ipaddress.ip_address(target.split("//")[-1].split(":")[0].split("/")[0])
            if ip.is_private or ip.is_loopback:
                return ValidationError(
                    path="targets",
                    message=f"Private/internal IP not allowed: {target}"
                )
        except ValueError:
            pass  # Not an IP, might be hostname — allow
    return None

validator.register_custom(
    name="no_internal_targets",
    tool="nuclei",
    fn=validate_target_not_internal
)
```

### Custom Validator Interface

```python
def my_validator(value, context) -> ValidationError | None:
    """
    Custom validation function.
    
    Args:
        value: The input value being validated
        context: {
            "tool": "nuclei",
            "field": "targets",
            "full_input": {...},
            "schema": {...}
        }
    
    Returns:
        None if valid, ValidationError if invalid
    """
```

### Built-in Custom Validators

| Validator | Tool | Rule |
|-----------|------|------|
| `no_internal_targets` | Any scanner | Rejects private/loopback IPs |
| `rate_limit_max` | Any | Enforces max requests per second |
| `template_exists` | nuclei | Validates template path exists |
| `port_range_valid` | nmap | Validates port specification format |
| `url_reachable` | httpx | Optional connectivity check |

---

## Validation Errors

Structured error objects returned when validation fails:

```python
@dataclass
class ValidationError:
    path: str           # JSON path to error (e.g., "targets[0]")
    message: str        # Human-readable error description
    code: str           # Machine-readable error code
    expected: str       # What was expected
    received: str       # What was actually provided
    severity: str       # "error" | "warning"
```

**Error codes:**

| Code | Description |
|------|-------------|
| `missing_required` | Required field not provided |
| `type_mismatch` | Wrong type for field |
| `value_out_of_range` | Number outside min/max bounds |
| `invalid_enum` | Value not in allowed enum |
| `pattern_mismatch` | String fails regex pattern |
| `invalid_format` | String fails format check (uri, email, etc.) |
| `string_too_long` | String exceeds maxLength |
| `string_too_short` | String below minLength |
| `array_too_long` | Array exceeds maxItems |
| `array_too_short` | Array below minItems |
| `unknown_property` | Extra property in strict mode |
| `sanitization_failed` | Input could not be sanitized |
| `custom_validation` | Custom validator rejected input |

**Example result with errors:**

```python
result = validator.validate(tool="nuclei", input={
    "targets": "https://target.com",
    "severity": ["invalid", "also_invalid"]
})

# result.valid = False
# result.errors = [
#   ValidationError(
#       path="targets",
#       message="Expected array, got string",
#       code="type_mismatch",
#       expected="array",
#       received="string",
#       severity="error"
#   ),
#   ValidationError(
#       path="severity[0]",
#       message="'invalid' not in enum [info, low, medium, high, critical]",
#       code="invalid_enum",
#       expected="info|low|medium|high|critical",
#       received="invalid",
#       severity="error"
#   ),
#   ValidationError(
#       path="severity[1]",
#       message="'also_invalid' not in enum [info, low, medium, high, critical]",
#       code="invalid_enum",
#       expected="info|low|medium|high|critical",
#       received="also_invalid",
#       severity="error"
#   )
# ]
```

---

## Validation Result

```python
@dataclass
class ValidationResult:
    valid: bool                          # Overall validation status
    errors: list[ValidationError]        # List of errors (empty if valid)
    warnings: list[ValidationError]      # Non-blocking warnings
    sanitized_input: dict                # Cleaned input (post-sanitization)
    coercion_applied: list[str]          # Fields that were type-coerced
    validation_time_ms: float            # Time spent validating
```

---

## Validator Configuration

```python
@dataclass
class ValidatorConfig:
    strict_mode: bool = True             # Reject unknown properties
    coerce_types: bool = True            # Enable type coercion
    sanitize_input: bool = True          # Enable input sanitization
    max_string_length: int = 10000       # Max string field length
    max_array_items: int = 1000          # Max array length
    max_nesting_depth: int = 10          # Max object nesting depth
    custom_validators_enabled: bool = True
```

---

## Integration Points

| Component | Interaction |
|-----------|-------------|
| `executor/` | Calls validate() before launching process |
| `registry/` | Provides input_schema for each tool |
| `core/` | Uses ValidationResult and ValidationError types |
| `utils/` | Leverages shared JSON Schema library |

---

*Part of the Brain tools subsystem — Prompt-Hunting.*
