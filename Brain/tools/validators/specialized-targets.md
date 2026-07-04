# Specialized Targets — Input Validation Reference

**Domain**: Specialized Targets (Category-Specific Security Testing)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all category-specific inputs across the Specialized-Targets domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `specialized-targets` |
| Root Directory | `Specialized-Targets/` |
| Total Files | 50 (+ README.md, registry.json) |
| Category | IoT, Mobile, Cloud, Container, Blockchain, Industry-Specific Testing |
| Input Surface | Target configs, category-specific params, testing configs |

---

## 2. Overview

The Specialized Targets validator enforces strict input validation for every specialized target prompt in the `Specialized-Targets/` directory. Each file defines a category-specific testing technique — from IoT device security to global-scale systems — and accepts structured inputs that must be validated before execution. This validator ensures:

- Target configurations are within authorized scope
- Category-specific parameters are properly formatted
- Industry-specific testing configs follow regulations
- All inputs are type-coerced and normalized
- Specialized testing parameters do not exceed safe boundaries

---

## 3. Schema Definition

### 3.1 Master Specialized Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "SpecializedTargetInput",
  "type": "object",
  "required": ["domain", "target_category", "target"],
  "properties": {
    "domain": { "type": "string", "const": "specialized-targets" },
    "target_category": { "$ref": "#/definitions/TargetCategory" },
    "target": { "$ref": "#/definitions/SpecializedTarget" },
    "category_config": { "$ref": "#/definitions/CategoryConfig" },
    "testing_params": { "$ref": "#/definitions/TestingParams" },
    "output": { "$ref": "#/definitions/SpecializedOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 TargetCategory Schema

```json
{
  "definitions": {
    "TargetCategory": {
      "type": "string",
      "enum": [
        "iot_device", "mobile_application", "cloud_infrastructure",
        "container_security", "kubernetes_cluster", "blockchain_smart_contract",
        "defi_protocol", "nft_marketplace", "web3_application",
        "cryptocurrency_exchange", "traditional_finance_api",
        "healthcare_system", "financial_institution", "government_system",
        "education_platform", "ecommerce_platform", "social_media_platform",
        "content_management_system", "learning_management_system",
        "human_resources_system", "supply_chain_management",
        "manufacturing_control", "smart_building", "connected_vehicle",
        "autonomous_system", "industrial_control_system", "medical_device",
        "wearable_technology", "smart_home_device", "embedded_system",
        "real_time_os", "firmware", "network_device",
        "telecommunication_system", "satellite_communication",
        "air_traffic_control", "power_grid", "water_treatment",
        "transportation_system", "energy_management",
        "research_institution", "non_profit_organization",
        "startup_company", "enterprise_corporate", "fortune_500",
        "open_source_project", "academic_research",
        "international_organization", "developing_country_infrastructure",
        "global_scale_system"
      ]
    }
  }
}
```

### 3.3 SpecializedTarget Schema

```json
{
  "definitions": {
    "SpecializedTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["url", "ip", "domain", "api", "mobile", "firmware", "device", "network"]
        },
        "value": { "type": "string", "minLength": 1, "maxLength": 4096 },
        "method": { "type": "string", "enum": ["GET", "POST", "PUT", "DELETE", "PATCH"] },
        "endpoint": { "type": "string", "maxLength": 2048 },
        "parameters": { "type": "object" },
        "headers": { "type": "object", "additionalProperties": { "type": "string" } },
        "body": { "type": "string", "maxLength": 65536 },
        "auth": { "$ref": "#/definitions/AuthConfig" },
        "scope": { "type": "array", "items": { "type": "string" }, "maxItems": 100 },
        "authorized": { "type": "boolean", "default": false }
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
          "enum": ["none", "basic", "bearer", "cookie", "oauth", "jwt", "api_key", "certificate"]
        },
        "token": { "type": "string", "maxLength": 4096 },
        "username": { "type": "string", "maxLength": 256 },
        "password": { "type": "string", "maxLength": 1024 }
      }
    }
  }
}
```

### 3.5 CategoryConfig Schema

```json
{
  "definitions": {
    "CategoryConfig": {
      "type": "object",
      "properties": {
        "subcategory": { "type": "string", "maxLength": 128 },
        "industry": { "type": "string", "maxLength": 128 },
        "regulations": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["hipaa", "gdpr", "pci_dss", "sox", "ferpa", "coppa", "glba", "ccpa", "iso27001", "nist", "owasp", "cis"]
          },
          "maxItems": 10
        },
        "compliance_level": {
          "type": "string",
          "enum": ["basic", "standard", "strict", "maximum"]
        },
        "testing_scope": {
          "type": "string",
          "enum": ["passive", "active", "invasive", "full"]
        },
        "risk_tolerance": {
          "type": "string",
          "enum": ["low", "medium", "high"]
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 TestingParams Schema

```json
{
  "definitions": {
    "TestingParams": {
      "type": "object",
      "properties": {
        "threads": { "type": "integer", "minimum": 1, "maximum": 200, "default": 10 },
        "timeout": { "type": "integer", "minimum": 1000, "maximum": 300000, "default": 30000 },
        "retries": { "type": "integer", "minimum": 0, "maximum": 10, "default": 3 },
        "rate_limit": { "type": "number", "minimum": 0.1, "maximum": 500, "default": 10 },
        "payloads": { "type": "array", "items": { "type": "string" }, "maxItems": 5000 },
        "wordlist": { "type": "string", "maxLength": 4096 },
        "depth": { "type": "integer", "minimum": 1, "maximum": 20, "default": 5 },
        "follow_redirects": { "type": "boolean", "default": true },
        "verify_ssl": { "type": "boolean", "default": true },
        "user_agent": { "type": "string", "maxLength": 256 },
        "proxy": { "type": "string", "maxLength": 512 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.7 SpecializedOutput Schema

```json
{
  "definitions": {
    "SpecializedOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "csv", "markdown", "html", "xml"] },
        "destination": { "type": "string", "maxLength": 4096 },
        "verbose": { "type": "boolean", "default": false },
        "include_recommendations": { "type": "boolean", "default": true },
        "compliance_report": { "type": "boolean", "default": false }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateTargetCategory(input) → ValidationResult

```python
def validate_target_category(input_data):
    errors = []
    category = input_data.get("target_category", "")
    valid_categories = [
        "iot_device", "mobile_application", "cloud_infrastructure",
        "container_security", "kubernetes_cluster", "blockchain_smart_contract",
        "defi_protocol", "nft_marketplace", "web3_application",
        "cryptocurrency_exchange", "traditional_finance_api",
        "healthcare_system", "financial_institution", "government_system",
        "education_platform", "ecommerce_platform", "social_media_platform",
        "content_management_system", "learning_management_system",
        "human_resources_system", "supply_chain_management",
        "manufacturing_control", "smart_building", "connected_vehicle",
        "autonomous_system", "industrial_control_system", "medical_device",
        "wearable_technology", "smart_home_device", "embedded_system",
        "real_time_os", "firmware", "network_device",
        "telecommunication_system", "satellite_communication",
        "air_traffic_control", "power_grid", "water_treatment",
        "transportation_system", "energy_management",
        "research_institution", "non_profit_organization",
        "startup_company", "enterprise_corporate", "fortune_500",
        "open_source_project", "academic_research",
        "international_organization", "developing_country_infrastructure",
        "global_scale_system"
    ]
    if category not in valid_categories:
        errors.append(ValidationError("INVALID_TARGET_CATEGORY", f"Unknown target category: {category}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateSpecializedTarget(input) → ValidationResult

```python
def validate_specialized_target(input_data):
    errors = []
    target = input_data.get("target", {})

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
    valid_methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
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

    if not target.get("authorized", False):
        errors.append(ValidationWarning("NOT_AUTHORIZED", "Target not marked as authorized"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateCategoryConfig(input) → ValidationResult

```python
def validate_category_config(input_data):
    errors = []
    config = input_data.get("category_config", {})
    if not config:
        return ValidationResult(valid=True, errors=[])

    subcategory = config.get("subcategory", "")
    if subcategory and len(subcategory) > 128:
        errors.append(ValidationError("SUBCATEGORY_TOO_LONG", "Subcategory exceeds 128 characters"))

    industry = config.get("industry", "")
    if industry and len(industry) > 128:
        errors.append(ValidationError("INDUSTRY_TOO_LONG", "Industry exceeds 128 characters"))

    regulations = config.get("regulations", [])
    valid_regulations = [
        "hipaa", "gdpr", "pci_dss", "sox", "ferpa", "coppa",
        "glba", "ccpa", "iso27001", "nist", "owasp", "cis"
    ]
    for reg in regulations:
        if reg not in valid_regulations:
            errors.append(ValidationError("INVALID_REGULATION", f"Invalid regulation: {reg}"))
    if len(regulations) > 10:
        errors.append(ValidationError("TOO_MANY_REGULATIONS", "Cannot have more than 10 regulations"))

    compliance = config.get("compliance_level", "")
    if compliance and compliance not in ("basic", "standard", "strict", "maximum"):
        errors.append(ValidationError("INVALID_COMPLIANCE_LEVEL", f"Invalid compliance level: {compliance}"))

    scope = config.get("testing_scope", "")
    if scope and scope not in ("passive", "active", "invasive", "full"):
        errors.append(ValidationError("INVALID_TESTING_SCOPE", f"Invalid testing scope: {scope}"))

    risk = config.get("risk_tolerance", "")
    if risk and risk not in ("low", "medium", "high"):
        errors.append(ValidationError("INVALID_RISK_TOLERANCE", f"Invalid risk tolerance: {risk}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateTestingParams(input) → ValidationResult

```python
def validate_testing_params(input_data):
    errors = []
    params = input_data.get("testing_params", {})
    if not params:
        return ValidationResult(valid=True, errors=[])

    threads = params.get("threads", 10)
    if not isinstance(threads, int) or threads < 1 or threads > 200:
        errors.append(ValidationError("THREADS_OUT_OF_RANGE", "Threads must be 1-200"))

    timeout = params.get("timeout", 30000)
    if not isinstance(timeout, (int, float)) or timeout < 1000 or timeout > 300000:
        errors.append(ValidationError("TIMEOUT_OUT_OF_RANGE", "Timeout must be 1000-300000 ms"))

    retries = params.get("retries", 3)
    if not isinstance(retries, int) or retries < 0 or retries > 10:
        errors.append(ValidationError("RETRIES_OUT_OF_RANGE", "Retries must be 0-10"))

    rate_limit = params.get("rate_limit", 10)
    if not isinstance(rate_limit, (int, float)) or rate_limit < 0.1 or rate_limit > 500:
        errors.append(ValidationError("RATE_LIMIT_OUT_OF_RANGE", "Rate limit must be 0.1-500"))

    payloads = params.get("payloads", [])
    if len(payloads) > 5000:
        errors.append(ValidationError("PAYLOAD_LIMIT_EXCEEDED", "Payloads exceed 5000 items"))

    depth = params.get("depth", 5)
    if not isinstance(depth, int) or depth < 1 or depth > 20:
        errors.append(ValidationError("DEPTH_OUT_OF_RANGE", "Depth must be 1-20"))

    user_agent = params.get("user_agent", "")
    if user_agent and len(user_agent) > 256:
        errors.append(ValidationError("USER_AGENT_TOO_LONG", "User agent exceeds 256 characters"))

    proxy = params.get("proxy", "")
    if proxy and len(proxy) > 512:
        errors.append(ValidationError("PROXY_TOO_LONG", "Proxy exceeds 512 characters"))

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
    r'rm\s+-rf\s+/', r'del\s+\/[sS]', r'format\s+[a-zA-Z]:',
    r'wget\s+.*\|\s*bash', r'curl\s+.*\|\s*sh',
    r'eval\s*\(', r'exec\s*\(',
]

def sanitize_payloads(payloads):
    sanitized = []
    for payload in payloads[:5000]:
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

### 5.4 sanitizeRegulations(regulations) → list

```python
def sanitize_regulations(regulations):
    valid = {"hipaa", "gdpr", "pci_dss", "sox", "ferpa", "coppa", "glba", "ccpa", "iso27001", "nist", "owasp", "cis"}
    return [r for r in regulations[:10] if r in valid]
```

---

## 6. Type Coercion

### 6.1 coerceTargetCategory(raw_category) → str

```python
CATEGORY_MAP = {
    "iot": "iot_device", "iot_device": "iot_device",
    "mobile": "mobile_application", "mobile_app": "mobile_application",
    "cloud": "cloud_infrastructure", "cloud_infra": "cloud_infrastructure",
    "container": "container_security", "docker": "container_security",
    "kubernetes": "kubernetes_cluster", "k8s": "kubernetes_cluster",
    "blockchain": "blockchain_smart_contract", "smart_contract": "blockchain_smart_contract",
    "defi": "defi_protocol",
    "nft": "nft_marketplace",
    "web3": "web3_application",
    "crypto_exchange": "cryptocurrency_exchange", "exchange": "cryptocurrency_exchange",
    "finance_api": "traditional_finance_api",
    "healthcare": "healthcare_system", "hipaa_system": "healthcare_system",
    "financial": "financial_institution", "bank": "financial_institution",
    "government": "government_system", "gov": "government_system",
    "education": "education_platform", "edu": "education_platform",
    "ecommerce": "ecommerce_platform", "e_commerce": "ecommerce_platform",
    "social": "social_media_platform", "social_media": "social_media_platform",
    "cms": "content_management_system",
    "lms": "learning_management_system",
    "hr": "human_resources_system",
    "supply_chain": "supply_chain_management",
    "manufacturing": "manufacturing_control", "ics": "industrial_control_system",
    "smart_building": "smart_building",
    "vehicle": "connected_vehicle", "automotive": "connected_vehicle",
    "autonomous": "autonomous_system",
    "ics_system": "industrial_control_system", "scada": "industrial_control_system",
    "medical": "medical_device", "med_device": "medical_device",
    "wearable": "wearable_technology",
    "smart_home": "smart_home_device",
    "embedded": "embedded_system",
    "rtos": "real_time_os",
    "firmware": "firmware",
    "network": "network_device",
    "telecom": "telecommunication_system",
    "satellite": "satellite_communication",
    "atc": "air_traffic_control",
    "power": "power_grid",
    "water": "water_treatment",
    "transport": "transportation_system",
    "energy": "energy_management",
    "research": "research_institution",
    "nonprofit": "non_profit_organization",
    "startup": "startup_company",
    "enterprise": "enterprise_corporate",
    "fortune500": "fortune_500",
    "open_source": "open_source_project",
    "academic": "academic_research",
    "international": "international_organization",
    "developing": "developing_country_infrastructure",
    "global": "global_scale_system"
}

def coerce_target_category(raw_category):
    return CATEGORY_MAP.get(str(raw_category).lower().strip(), raw_category)
```

### 6.2 coerceTargetType(raw_type) → str

```python
def coerce_target_type(raw_type):
    type_map = {
        "url": "url", "endpoint": "url", "link": "url",
        "ip": "ip", "address": "ip", "host": "ip",
        "domain": "domain", "subdomain": "domain",
        "api": "api", "graphql": "api", "rest": "api",
        "mobile": "mobile", "app": "mobile", "apk": "mobile",
        "firmware": "firmware", "fw": "firmware",
        "device": "device", "iot": "device",
        "network": "network", "net": "network"
    }
    return type_map.get(str(raw_type).lower().strip(), "url")
```

### 6.3 coerceNumericParams(params) → dict

```python
def coerce_numeric_params(params):
    int_fields = ["threads", "timeout", "retries", "depth"]
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

### 6.4 coerceBooleanFields(params, fields) → dict

```python
def coerce_boolean_fields(params, fields):
    true_vals = {"true", "1", "yes", "on"}
    for field in fields:
        if field in params:
            val = params[field]
            if not isinstance(val, bool):
                params[field] = str(val).lower().strip() in true_vals
    return params
```

---

## 7. Custom Validators

### 7.1 validateCategoryTargetCompatibility(category, target) → list

```python
CATEGORY_TARGET_COMPAT = {
    "iot_device": ["url", "ip", "device"],
    "mobile_application": ["url", "mobile"],
    "cloud_infrastructure": ["url", "ip", "domain", "api"],
    "container_security": ["url", "ip", "domain"],
    "kubernetes_cluster": ["url", "ip", "domain"],
    "blockchain_smart_contract": ["url", "api"],
    "defi_protocol": ["url", "api"],
    "nft_marketplace": ["url", "api"],
    "web3_application": ["url", "api"],
    "cryptocurrency_exchange": ["url", "api"],
    "traditional_finance_api": ["url", "api"],
    "healthcare_system": ["url", "api"],
    "financial_institution": ["url", "api"],
    "government_system": ["url", "domain"],
    "education_platform": ["url", "domain"],
    "ecommerce_platform": ["url", "domain"],
    "social_media_platform": ["url", "api"],
    "content_management_system": ["url", "domain"],
    "learning_management_system": ["url", "domain"],
    "human_resources_system": ["url", "api"],
    "supply_chain_management": ["url", "api"],
    "manufacturing_control": ["ip", "network", "device"],
    "smart_building": ["ip", "network", "device"],
    "connected_vehicle": ["ip", "network", "device"],
    "autonomous_system": ["ip", "network"],
    "industrial_control_system": ["ip", "network", "device"],
    "medical_device": ["ip", "network", "device"],
    "wearable_technology": ["url", "api", "device"],
    "smart_home_device": ["ip", "network", "device"],
    "embedded_system": ["ip", "device", "firmware"],
    "real_time_os": ["firmware", "device"],
    "firmware": ["firmware", "device"],
    "network_device": ["ip", "network"],
    "telecommunication_system": ["url", "ip", "network"],
    "satellite_communication": ["ip", "network"],
    "air_traffic_control": ["ip", "network"],
    "power_grid": ["ip", "network"],
    "water_treatment": ["ip", "network"],
    "transportation_system": ["ip", "network"],
    "energy_management": ["ip", "network"],
    "research_institution": ["url", "domain"],
    "non_profit_organization": ["url", "domain"],
    "startup_company": ["url", "domain", "api"],
    "enterprise_corporate": ["url", "domain", "api"],
    "fortune_500": ["url", "domain", "api"],
    "open_source_project": ["url", "domain"],
    "academic_research": ["url", "domain"],
    "international_organization": ["url", "domain"],
    "developing_country_infrastructure": ["url", "ip", "network"],
    "global_scale_system": ["url", "ip", "domain", "api"]
}

def validate_category_target_compatibility(category, target):
    errors = []
    if not target:
        return errors
    target_type = target.get("type", "")
    compatible = CATEGORY_TARGET_COMPAT.get(category, [])
    if compatible and target_type not in compatible:
        errors.append(ValidationWarning(
            "CATEGORY_TARGET_MISMATCH",
            f"Category '{category}' is typically used with target types: {', '.join(compatible)}"
        ))
    return errors
```

### 7.2 validateRegulatoryCompliance(category_config, category) → list

```python
CATEGORY_REGULATIONS = {
    "healthcare_system": ["hipaa", "gdpr"],
    "financial_institution": ["pci_dss", "sox", "glba"],
    "education_platform": ["ferpa", "coppa"],
    "ecommerce_platform": ["pci_dss", "gdpr", "ccpa"],
    "government_system": ["nist", "iso27001"],
    "enterprise_corporate": ["iso27001", "nist", "cis"],
    "fortune_500": ["iso27001", "nist", "cis"],
    "iot_device": ["owasp", "cis"],
    "medical_device": ["hipaa", "iso27001"],
}

def validate_regulatory_compliance(category_config, category):
    errors = []
    if not category_config:
        return errors

    regulations = category_config.get("regulations", [])
    expected = CATEGORY_REGULATIONS.get(category, [])

    if expected and not regulations:
        errors.append(ValidationWarning(
            "NO_REGULATIONS",
            f"Category '{category}' typically requires compliance with: {', '.join(expected)}"
        ))

    if regulations:
        missing = set(expected) - set(regulations)
        if missing:
            errors.append(ValidationWarning(
                "MISSING_REGULATIONS",
                f"Category '{category}' may also require: {', '.join(missing)}"
            ))

    return errors
```

### 7.3 validateTestingScopeRisk(config) → list

```python
def validate_testing_scope_risk(config):
    errors = []
    if not config:
        return errors

    scope = config.get("testing_scope", "")
    risk = config.get("risk_tolerance", "")

    if scope == "invasive" and risk == "low":
        errors.append(ValidationWarning(
            "SCOPE_RISK_MISMATCH",
            "Invasive testing scope with low risk tolerance may be inconsistent"
        ))

    if scope == "passive" and risk == "high":
        errors.append(ValidationWarning(
            "PASSIVE_HIGH_RISK",
            "Passive testing with high risk tolerance may be underutilizing access"
        ))

    return errors
```

### 7.4 validatePayloadSafety(payloads) → list

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

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_TARGET_CATEGORY` | ERROR | Target category not recognized |
| `TARGET_VALUE_EMPTY` | ERROR | Target value cannot be empty |
| `TARGET_VALUE_TOO_LONG` | ERROR | Target value exceeds 4096 characters |
| `INVALID_DOMAIN` | ERROR | Domain format invalid |
| `INVALID_URL` | ERROR | URL format invalid |
| `INVALID_IP` | ERROR | IP address format invalid |
| `INVALID_METHOD` | ERROR | HTTP method not recognized |
| `ENDPOINT_TOO_LONG` | ERROR | Endpoint exceeds 2048 characters |
| `BODY_TOO_LARGE` | ERROR | Request body exceeds 64KB |
| `SCOPE_TOO_LARGE` | ERROR | Scope list exceeds 100 entries |
| `NOT_AUTHORIZED` | WARNING | Target not marked as authorized |
| `SUBCATEGORY_TOO_LONG` | ERROR | Subcategory exceeds 128 characters |
| `INDUSTRY_TOO_LONG` | ERROR | Industry exceeds 128 characters |
| `INVALID_REGULATION` | ERROR | Regulation not recognized |
| `TOO_MANY_REGULATIONS` | ERROR | Cannot have more than 10 regulations |
| `INVALID_COMPLIANCE_LEVEL` | ERROR | Compliance level not recognized |
| `INVALID_TESTING_SCOPE` | ERROR | Testing scope not recognized |
| `INVALID_RISK_TOLERANCE` | ERROR | Risk tolerance not recognized |
| `THREADS_OUT_OF_RANGE` | ERROR | Threads must be 1-200 |
| `TIMEOUT_OUT_OF_RANGE` | ERROR | Timeout must be 1000-300000 ms |
| `RETRIES_OUT_OF_RANGE` | ERROR | Retries must be 0-10 |
| `RATE_LIMIT_OUT_OF_RANGE` | ERROR | Rate limit must be 0.1-500 |
| `PAYLOAD_LIMIT_EXCEEDED` | ERROR | Payloads exceed 5000 items |
| `DEPTH_OUT_OF_RANGE` | ERROR | Depth must be 1-20 |
| `USER_AGENT_TOO_LONG` | ERROR | User agent exceeds 256 characters |
| `PROXY_TOO_LONG` | ERROR | Proxy exceeds 512 characters |
| `CATEGORY_TARGET_MISMATCH` | WARNING | Category may not match target type |
| `NO_REGULATIONS` | WARNING | No regulations specified |
| `MISSING_REGULATIONS` | WARNING | Missing expected regulations |
| `SCOPE_RISK_MISMATCH` | WARNING | Invasive scope with low risk tolerance |
| `PASSIVE_HIGH_RISK` | WARNING | Passive scope with high risk tolerance |
| `DANGEROUS_PAYLOAD` | ERROR | Payload contains dangerous system command |

---

## 9. Error Messages

```python
SPECIALIZED_ERROR_MESSAGES = {
    "INVALID_TARGET_CATEGORY": "Target category not recognized. Check the supported categories list.",
    "TARGET_VALUE_EMPTY": "Target value cannot be empty.",
    "TARGET_VALUE_TOO_LONG": "Target value must be 4096 characters or fewer.",
    "INVALID_DOMAIN": "Domain format is invalid.",
    "INVALID_URL": "URL format is invalid. Ensure it includes scheme and host.",
    "INVALID_IP": "IP address format is invalid.",
    "INVALID_METHOD": "HTTP method not recognized.",
    "ENDPOINT_TOO_LONG": "Endpoint must be 2048 characters or fewer.",
    "BODY_TOO_LARGE": "Request body exceeds 64KB limit.",
    "SCOPE_TOO_LARGE": "Scope list cannot exceed 100 entries.",
    "NOT_AUTHORIZED": "Target has not been marked as authorized.",
    "SUBCATEGORY_TOO_LONG": "Subcategory must be 128 characters or fewer.",
    "INDUSTRY_TOO_LONG": "Industry must be 128 characters or fewer.",
    "INVALID_REGULATION": "Regulation not recognized.",
    "TOO_MANY_REGULATIONS": "Cannot have more than 10 regulations.",
    "INVALID_COMPLIANCE_LEVEL": "Compliance level must be: basic, standard, strict, or maximum.",
    "INVALID_TESTING_SCOPE": "Testing scope must be: passive, active, invasive, or full.",
    "INVALID_RISK_TOLERANCE": "Risk tolerance must be: low, medium, or high.",
    "THREADS_OUT_OF_RANGE": "Threads must be between 1 and 200.",
    "TIMEOUT_OUT_OF_RANGE": "Timeout must be between 1000ms and 300000ms.",
    "RETRIES_OUT_OF_RANGE": "Retries must be between 0 and 10.",
    "RATE_LIMIT_OUT_OF_RANGE": "Rate limit must be between 0.1 and 500 requests/sec.",
    "PAYLOAD_LIMIT_EXCEEDED": "Payload array cannot exceed 5000 items.",
    "DEPTH_OUT_OF_RANGE": "Depth must be between 1 and 20.",
    "USER_AGENT_TOO_LONG": "User agent must be 256 characters or fewer.",
    "PROXY_TOO_LONG": "Proxy must be 512 characters or fewer.",
    "CATEGORY_TARGET_MISMATCH": "Category may not be optimal for this target type.",
    "NO_REGULATIONS": "No regulations specified. This category typically requires compliance.",
    "MISSING_REGULATIONS": "Missing expected regulatory compliance requirements.",
    "SCOPE_RISK_MISMATCH": "Invasive testing scope with low risk tolerance may be inconsistent.",
    "PASSIVE_HIGH_RISK": "Passive testing with high risk tolerance may be underutilizing access.",
    "DANGEROUS_PAYLOAD": "Payload contains a pattern associated with destructive system commands.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| ST001 | Target category must be valid | ERROR | No |
| ST002 | Target value must not be empty | ERROR | No |
| ST003 | Target value must not exceed 4096 chars | ERROR | Truncate |
| ST004 | Domain format must be valid | ERROR | No |
| ST005 | URL format must be valid | ERROR | No |
| ST006 | IP format must be valid | ERROR | No |
| ST007 | HTTP method must be valid | ERROR | No |
| ST008 | Endpoint max 2048 chars | ERROR | Truncate |
| ST009 | Request body max 64KB | ERROR | Truncate |
| ST010 | Scope max 100 entries | ERROR | Truncate |
| ST011 | Regulations max 10 | ERROR | Truncate |
| ST012 | Compliance level must be valid | ERROR | No |
| ST013 | Testing scope must be valid | ERROR | No |
| ST014 | Risk tolerance must be valid | ERROR | No |
| ST015 | Threads must be 1-200 | ERROR | Clamp |
| ST016 | Timeout must be 1000-300000 ms | ERROR | Clamp |
| ST017 | Retries must be 0-10 | ERROR | Clamp |
| ST018 | Rate limit must be 0.1-500 | ERROR | Clamp |
| ST019 | Payloads max 5000 | ERROR | Truncate |
| ST020 | Category should match target type | WARNING | No |

---

## 11. Domain File References

All 50 files in `Specialized-Targets/` that this validator covers:

| # | File | Target Category | Key Validation |
|---|------|-----------------|----------------|
| 01 | `01-IoT-Device-Security.md` | iot_device | target.device, regulations |
| 02 | `02-Mobile-Application-Testing.md` | mobile_application | target.mobile |
| 03 | `03-Cloud-Infrastructure-Security.md` | cloud_infrastructure | target.url/api |
| 04 | `04-Container-Security.md` | container_security | target.url/ip |
| 05 | `05-Kubernetes-Cluster-Security.md` | kubernetes_cluster | target.url/ip |
| 06 | `06-Blockchain-Smart-Contracts.md` | blockchain_smart_contract | target.url/api |
| 07 | `07-DeFi-Protocol-Security.md` | defi_protocol | target.url/api |
| 08 | `08-NFT-Marketplace-Security.md` | nft_marketplace | target.url/api |
| 09 | `09-Web3-Application-Security.md` | web3_application | target.url/api |
| 10 | `10-Cryptocurrency-Exchange-Security.md` | cryptocurrency_exchange | target.url/api |
| 11 | `11-Traditional-Finance-API-Security.md` | traditional_finance_api | target.url/api |
| 12 | `12-Healthcare-System-Security.md` | healthcare_system | target.url/api, hipaa |
| 13 | `13-Financial-Institution-Security.md` | financial_institution | target.url/api, pci_dss |
| 14 | `14-Government-System-Security.md` | government_system | target.url/domain |
| 15 | `15-Education-Platform-Security.md` | education_platform | target.url/domain |
| 16 | `16-E-commerce-Platform-Security.md` | ecommerce_platform | target.url/domain |
| 17 | `17-Social-Media-Platform-Security.md` | social_media_platform | target.url/api |
| 18 | `18-Content-Management-System-Security.md` | content_management_system | target.url/domain |
| 19 | `19-Learning-Management-System-Security.md` | learning_management_system | target.url/domain |
| 20 | `20-Human-Resources-System-Security.md` | human_resources_system | target.url/api |
| 21 | `21-Supply-Chain-Management-Security.md` | supply_chain_management | target.url/api |
| 22 | `22-Manufacturing-Control-System-Security.md` | manufacturing_control | target.ip/network |
| 23 | `23-Smart-Building-Automation.md` | smart_building | target.ip/network |
| 24 | `24-Connected-Vehicle-Security.md` | connected_vehicle | target.ip/network |
| 25 | `25-Autonomous-System-Security.md` | autonomous_system | target.ip/network |
| 26 | `26-Industrial-Control-System-Security.md` | industrial_control_system | target.ip/network |
| 27 | `27-Medical-Device-Security.md` | medical_device | target.ip/device |
| 28 | `28-Wearable-Technology-Security.md` | wearable_technology | target.url/api |
| 29 | `29-Smart-Home-Device-Security.md` | smart_home_device | target.ip/device |
| 30 | `30-Embedded-System-Security.md` | embedded_system | target.ip/firmware |
| 31 | `31-Real-Time-Operating-System-Security.md` | real_time_os | target.firmware |
| 32 | `32-Firmware-Security-Analysis.md` | firmware | target.firmware |
| 33 | `33-Network-Device-Security.md` | network_device | target.ip/network |
| 34 | `34-Telecommunication-System-Security.md` | telecommunication_system | target.url/ip |
| 35 | `35-Satellite-Communication-Security.md` | satellite_communication | target.ip/network |
| 36 | `36-Air-Traffic-Control-System-Security.md` | air_traffic_control | target.ip/network |
| 37 | `37-Power-Grid-Security.md` | power_grid | target.ip/network |
| 38 | `38-Water-Treatment-Facility-Security.md` | water_treatment | target.ip/network |
| 39 | `39-Transportation-System-Security.md` | transportation_system | target.ip/network |
| 40 | `40-Energy-Management-System-Security.md` | energy_management | target.ip/network |
| 41 | `41-Research-Institution-Security.md` | research_institution | target.url/domain |
| 42 | `42-Non-Profit-Organization-Security.md` | non_profit_organization | target.url/domain |
| 43 | `43-Startup-Company-Security.md` | startup_company | target.url/domain |
| 44 | `44-Enterprise-Corporate-Security.md` | enterprise_corporate | target.url/domain |
| 45 | `45-Fortune-500-Company-Security.md` | fortune_500 | target.url/domain |
| 46 | `46-Open-Source-Project-Security.md` | open_source_project | target.url/domain |
| 47 | `47-Academic-Research-Security.md` | academic_research | target.url/domain |
| 48 | `48-International-Organization-Security.md` | international_organization | target.url/domain |
| 49 | `49-Developing-Country-Infrastructure.md` | developing_country_infrastructure | target.url/ip |
| 50 | `50-Global-Scale-System-Security.md` | global_scale_system | target.url/ip/domain |

---

## 12. Validation Pipeline

```python
def validate_specialized_target_input(input_data):
    results = []
    results.append(("category", validate_target_category(input_data)))
    results.append(("target", validate_specialized_target(input_data)))
    results.append(("config", validate_category_config(input_data)))
    results.append(("params", validate_testing_params(input_data)))

    category = input_data.get("target_category", "")
    target = input_data.get("target", {})
    results.append(("cat_compat", ValidationResult(
        valid=True, errors=validate_category_target_compatibility(category, target)
    )))

    config = input_data.get("category_config", {})
    results.append(("compliance", ValidationResult(
        valid=True, errors=validate_regulatory_compliance(config, category)
    )))

    results.append(("scope_risk", ValidationResult(
        valid=True, errors=validate_testing_scope_risk(config)
    )))

    params = input_data.get("testing_params", {})
    payloads = params.get("payloads", [])
    results.append(("payload_safety", ValidationResult(
        valid=len(validate_payload_safety(payloads)) == 0,
        errors=validate_payload_safety(payloads)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "specialized-targets", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Specialized validation runs before any category-specific testing
- Category-target compatibility checks suggest optimal configurations
- Regulatory compliance checks warn about missing compliance requirements
- Scope-risk consistency checks ensure aligned testing approach
- Payload safety checks filter dangerous system commands
- All validation results are logged for engagement audit trail
- Type coercion normalizes categories and target types
- Industry-specific regulations are validated against category expectations

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Specialized Targets domain |
