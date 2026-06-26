# Schema Validation

## Overview

The `utils/validation` module provides declarative schema definitions for validating data at runtime with clear, actionable error messages. Supports nested structures, custom rules, and composable schemas.

## Schema Definition

```python
from Brain.utils.validation import Schema, Field

user_schema = Schema(
    name=Field(type=str, required=True, min_length=1, max_length=100),
    email=Field(type=str, required=True, pattern=r"^[^@]+@[^@]+\.[^@]+$"),
    age=Field(type=int, required=False, gte=0, lte=150),
    role=Field(type=str, required=True, enum=["admin", "editor", "viewer"])
)

result = user_schema.validate({"name": "Alice", "email": "alice@example.com", "role": "admin"})
```

### Schema Construction

```python
Schema(
    *fields,               # Positional Field definitions
    strict: bool = False,  # Reject unknown keys
    coerce: bool = False,  # Attempt type coercion (str→int, etc.)
    custom_rules: dict = None  # {name: validator_func} for use in Field(rule=...)
)
```

### Field Constructor

```python
Field(
    type: type | list[type],    # Expected Python type(s)
    required: bool = True,      # Must be present
    default: Any = MISSING,     # Default value if not provided
    nullable: bool = False,     # Allow None
    coerce: bool = False,       # Attempt type coercion
    rule: str | callable = None # Named custom rule or inline function
)
```

## Type Validation

Built-in type checking with optional coercion:

```python
Schema(
    count=Field(type=int),            # Exact type match
    value=Field(type=(int, float)),   # Multiple allowed types
    label=Field(type=str, coerce=True)  # "123" → 123 not here, but str(123) = "123"
)

# Supported types
# int, float, str, bool, list, dict, tuple, set, bytes
# datetime, date, time, UUID, Decimal, Path
```

### Coercion Rules

| Source | Target | Behavior |
|--------|--------|----------|
| `"123"` | `int` | `int("123")` → `123` |
| `"3.14"` | `float` | `float("3.14")` → `3.14` |
| `123` | `str` | `str(123)` → `"123"` |
| `"true"` | `bool` | `True` |
| `"2026-06-25"` | `date` | `date(2026, 6, 25)` |
| `"550e8400-..."` | `UUID` | `UUID(...)` |

## Range Validation

Numeric and length constraints:

```python
Schema(
    # Numeric ranges
    score=Field(type=int, gte=0, lte=100),      # 0 ≤ score ≤ 100
    price=Field(type=float, gt=0),               # price > 0
    temperature=Field(type=float, gte=-273.15),  # minimum is absolute zero

    # String length
    username=Field(type=str, min_length=3, max_length=32),
    bio=Field(type=str, max_length=500),

    # Collection size
    tags=Field(type=list, min_items=1, max_items=10),
    coordinates=Field(type=tuple, min_items=2, max_items=3)
)
```

### Range Operators

| Operator | Meaning | Applies To |
|----------|---------|------------|
| `gt`     | Greater than | int, float |
| `gte`    | Greater than or equal | int, float |
| `lt`     | Less than | int, float |
| `lte`    | Less than or equal | int, float |
| `min_length` | Minimum string length | str |
| `max_length` | Maximum string length | str |
| `min_items`  | Minimum collection size | list, tuple, set |
| `max_items`  | Maximum collection size | list, tuple, set |

## Pattern Matching

Regex validation for string fields:

```python
Schema(
    email=Field(type=str, pattern=r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"),
    phone=Field(type=str, pattern=r"^\+?[1-9]\d{1,14}$"),  # E.164
    uuid=Field(type=str, pattern=r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"),
    ip=Field(type=str, pattern=r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")
)
```

## Enum Validation

Restrict values to a fixed set:

```python
Schema(
    status=Field(type=str, enum=["active", "inactive", "pending"]),
    priority=Field(type=int, enum=[1, 2, 3, 4, 5]),
    mode=Field(type=str, enum=["read", "write", "admin"])
)
```

### Dynamic Enums

```python
def available_roles(ctx):
    return db.get_roles_for_tenant(ctx.get("tenant_id"))

Schema(
    role=Field(type=str, enum=available_roles)
)
```

## Custom Validators

Inline functions for complex validation logic:

```python
Schema(
    password=Field(
        type=str,
        required=True,
        rule=lambda val, ctx: (
            len(val) >= 8
            and any(c.isupper() for c in val)
            and any(c.isdigit() for c in val)
        )
    ),
    confirm_password=Field(
        type=str,
        rule=lambda val, ctx: val == ctx.get("password")
    )
)
```

### Named Custom Rules

```python
def validate_strong_password(value, context):
    errors = []
    if len(value) < 8:
        errors.append("must be at least 8 characters")
    if not any(c.isupper() for c in value):
        errors.append("must contain an uppercase letter")
    if not any(c.isdigit() for c in value):
        errors.append("must contain a digit")
    return errors  # empty list = valid

schema = Schema(
    password=Field(type=str, rule="strong_password"),
    custom_rules={"strong_password": validate_strong_password}
)
```

## Validation Results

All validation returns a structured result object:

```python
result = schema.validate(data)

result.is_valid          # bool
result.errors            # list[ValidationError]
result.errors[0].field   # "email"
result.errors[0].message # "does not match pattern"
result.errors[0].code    # "PATTERN_MISMATCH"
result.errors[0].value   # "not-an-email"
result.errors[0].rule    # "pattern"
result.validated_data    # Coerged/cleaned data (if coerce=True)
```

### Error Codes

| Code | Meaning |
|------|---------|
| `TYPE_MISMATCH` | Value is wrong type |
| `REQUIRED` | Missing required field |
| `NULL_NOT_ALLOWED` | None when nullable=False |
| `TOO_SHORT` | Below min_length / min_items |
| `TOO_LONG` | Above max_length / max_items |
| `OUT_OF_RANGE` | Below gt/gte or above lt/lte |
| `PATTERN_MISMATCH` | Regex did not match |
| `INVALID_ENUM` | Value not in allowed set |
| `CUSTOM_RULE_FAILED` | Custom validator returned errors |

### Collecting All Errors

```python
result = schema.validate(data, collect_all=True)
# Returns ALL errors, not just the first per field

for err in result.errors:
    print(f"{err.field}: {err.message}")
```

## Nested Schema Validation

```python
address_schema = Schema(
    street=Field(type=str, required=True),
    city=Field(type=str, required=True),
    zip=Field(type=str, pattern=r"^\d{5}(-\d{4})?$")
)

company_schema = Schema(
    name=Field(type=str, required=True),
    address=Field(type=dict, schema=address_schema),
    employees=Field(type=list, items=Field(type=dict, schema=user_schema))
)
```

## Async Validation

```python
result = await schema.validate_async(data)
# Runs custom async validators concurrently
```
