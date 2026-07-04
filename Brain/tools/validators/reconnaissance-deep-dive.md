# Reconnaissance Deep Dive — Input Validation Reference

**Domain**: Reconnaissance Deep Dive (Asset Discovery & Intelligence)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all recon target inputs across the Reconnaissance-Deep-Dive domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `reconnaissance-deep-dive` |
| Root Directory | `Reconnaissance-Deep-Dive/` |
| Total Files | 50 (+ README.md, registry.json) |
| Category | Reconnaissance, OSINT, Asset Discovery, Intelligence Gathering |
| Input Surface | Recon targets, OSINT configs, discovery parameters, analysis inputs |

---

## 2. Overview

The Reconnaissance Deep Dive validator enforces strict input validation for every reconnaissance prompt in the `Reconnaissance-Deep-Dive/` directory. Each file defines a reconnaissance technique — from subdomain enumeration to advanced strategy — and accepts structured inputs that must be validated before execution. This validator ensures:

- Recon targets are within authorized scope
- OSINT collection parameters are safe and legal
- Asset discovery configs use valid parameters
- Technology fingerprinting inputs are properly formatted
- Cloud resource enumeration is within bounds
- API endpoint discovery uses valid configs
- All inputs are type-coerced and normalized

---

## 3. Schema Definition

### 3.1 Master Recon Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ReconDeepDiveInput",
  "type": "object",
  "required": ["domain", "recon_type", "target"],
  "properties": {
    "domain": { "type": "string", "const": "reconnaissance-deep-dive" },
    "recon_type": { "$ref": "#/definitions/ReconType" },
    "target": { "$ref": "#/definitions/ReconTarget" },
    "collection": { "$ref": "#/definitions/CollectionConfig" },
    "analysis": { "$ref": "#/definitions/AnalysisConfig" },
    "output": { "$ref": "#/definitions/ReconOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 ReconType Schema

```json
{
  "definitions": {
    "ReconType": {
      "type": "string",
      "enum": [
        "subdomain_enumeration", "passive_osint", "active_asset_discovery",
        "technology_fingerprinting", "cloud_resource_enum", "api_endpoint_discovery",
        "javascript_source_analysis", "config_file_extraction", "version_detection",
        "content_discovery", "directory_brute_force", "file_type_detection",
        "backup_file_discovery", "source_code_leak", "git_repository_analysis",
        "dns_enumeration", "certificate_transparency", "historical_data_analysis",
        "social_media_osint", "employee_linked_assets", "third_party_integration",
        "web_archive_analysis", "pastebin_leak_search", "code_repository_mining",
        "container_registry_enum", "iot_device_discovery", "mobile_app_analysis",
        "api_documentation_extraction", "websocket_endpoint_discovery",
        "graphql_introspection", "xml_rpc_soap_discovery", "email_address_harvesting",
        "phone_number_enumeration", "physical_location_intel", "supply_chain_asset_mapping",
        "competitor_analysis", "partner_network_discovery", "acquisition_target_analysis",
        "subsidiary_asset_mapping", "regional_infrastructure_mapping",
        "cms_detection", "framework_identification", "server_configuration_analysis",
        "ssl_tls_certificate_analysis", "http_header_intelligence",
        "cookie_analysis", "error_page_analysis", "debug_endpoint_discovery",
        "staging_environment_detection", "advanced_recon_strategy"
      ]
    }
  }
}
```

### 3.3 ReconTarget Schema

```json
{
  "definitions": {
    "ReconTarget": {
      "type": "object",
      "required": ["type", "value"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["domain", "subdomain", "ip", "cidr", "url", "org", "email", "username", "repo"]
        },
        "value": { "type": "string", "minLength": 1, "maxLength": 2048 },
        "scope": { "type": "array", "items": { "type": "string" }, "maxItems": 100 },
        "exclusions": { "type": "array", "items": { "type": "string" }, "maxItems": 100 },
        "authorized": { "type": "boolean", "default": false }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 CollectionConfig Schema

```json
{
  "definitions": {
    "CollectionConfig": {
      "type": "object",
      "properties": {
        "methods": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["passive", "active", "hybrid"]
          },
          "maxItems": 3
        },
        "sources": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 50
        },
        "depth": { "type": "integer", "minimum": 1, "maximum": 10, "default": 3 },
        "threads": { "type": "integer", "minimum": 1, "maximum": 100, "default": 10 },
        "timeout": { "type": "integer", "minimum": 1000, "maximum": 300000, "default": 30000 },
        "rate_limit": { "type": "number", "minimum": 0.1, "maximum": 100, "default": 10 },
        "user_agent": { "type": "string", "maxLength": 256 },
        "proxy": { "type": "string", "maxLength": 512 },
        "respect_robots": { "type": "boolean", "default": true }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 AnalysisConfig Schema

```json
{
  "definitions": {
    "AnalysisConfig": {
      "type": "object",
      "properties": {
        "focus": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["subdomains", "ips", "urls", "technologies", "cloud", "apis", "emails", "secrets", "config"]
          },
          "maxItems": 9
        },
        "exclude_internal": { "type": "boolean", "default": true },
        "include_historical": { "type": "boolean", "default": false },
        "max_results": { "type": "integer", "minimum": 1, "maximum": 100000, "default": 10000 },
        "deduplication": { "type": "boolean", "default": true },
        "enrichment": { "type": "boolean", "default": false }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 ReconOutput Schema

```json
{
  "definitions": {
    "ReconOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "csv", "markdown", "xml", "text"] },
        "destination": { "type": "string", "maxLength": 4096 },
        "verbose": { "type": "boolean", "default": false },
        "group_by": { "type": "string", "enum": ["type", "severity", "source", "none"], "default": "none" }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateReconType(input) → ValidationResult

```python
def validate_recon_type(input_data):
    errors = []
    recon_type = input_data.get("recon_type", "")
    valid_types = [
        "subdomain_enumeration", "passive_osint", "active_asset_discovery",
        "technology_fingerprinting", "cloud_resource_enum", "api_endpoint_discovery",
        "javascript_source_analysis", "config_file_extraction", "version_detection",
        "content_discovery", "directory_brute_force", "file_type_detection",
        "backup_file_discovery", "source_code_leak", "git_repository_analysis",
        "dns_enumeration", "certificate_transparency", "historical_data_analysis",
        "social_media_osint", "employee_linked_assets", "third_party_integration",
        "web_archive_analysis", "pastebin_leak_search", "code_repository_mining",
        "container_registry_enum", "iot_device_discovery", "mobile_app_analysis",
        "api_documentation_extraction", "websocket_endpoint_discovery",
        "graphql_introspection", "xml_rpc_soap_discovery", "email_address_harvesting",
        "phone_number_enumeration", "physical_location_intel", "supply_chain_asset_mapping",
        "competitor_analysis", "partner_network_discovery", "acquisition_target_analysis",
        "subsidiary_asset_mapping", "regional_infrastructure_mapping",
        "cms_detection", "framework_identification", "server_configuration_analysis",
        "ssl_tls_certificate_analysis", "http_header_intelligence",
        "cookie_analysis", "error_page_analysis", "debug_endpoint_discovery",
        "staging_environment_detection", "advanced_recon_strategy"
    ]
    if recon_type not in valid_types:
        errors.append(ValidationError("INVALID_RECON_TYPE", f"Unknown recon type: {recon_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateReconTarget(input) → ValidationResult

```python
def validate_recon_target(input_data):
    errors = []
    target = input_data.get("target", {})

    target_type = target.get("type", "")
    target_value = target.get("value", "")

    if not target_value:
        errors.append(ValidationError("TARGET_VALUE_EMPTY", "Target value cannot be empty"))
    if len(target_value) > 2048:
        errors.append(ValidationError("TARGET_VALUE_TOO_LONG", "Target value exceeds 2048 characters"))

    if target_type == "domain":
        if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$', target_value):
            errors.append(ValidationError("INVALID_DOMAIN", f"Invalid domain: {target_value}"))
    elif target_type == "subdomain":
        if not re.match(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$', target_value):
            errors.append(ValidationError("INVALID_SUBDOMAIN", f"Invalid subdomain: {target_value}"))
    elif target_type == "ip":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}(/\d{1,2})?$', target_value):
            errors.append(ValidationError("INVALID_IP", f"Invalid IP: {target_value}"))
    elif target_type == "cidr":
        if not re.match(r'^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$', target_value):
            errors.append(ValidationError("INVALID_CIDR", f"Invalid CIDR: {target_value}"))
    elif target_type == "url":
        parsed = urlparse(target_value)
        if not parsed.scheme or not parsed.netloc:
            errors.append(ValidationError("INVALID_URL", f"Invalid URL: {target_value}"))
    elif target_type == "email":
        if not re.match(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$', target_value):
            errors.append(ValidationError("INVALID_EMAIL", f"Invalid email: {target_value}"))
    elif target_type == "repo":
        if not re.match(r'^[a-zA-Z0-9\-_.]+\/[a-zA-Z0-9\-_.]+$', target_value):
            errors.append(ValidationError("INVALID_REPO", f"Invalid repo format: {target_value}"))

    scope = target.get("scope", [])
    if len(scope) > 100:
        errors.append(ValidationError("SCOPE_TOO_LARGE", "Scope list exceeds 100 entries"))

    exclusions = target.get("exclusions", [])
    if len(exclusions) > 100:
        errors.append(ValidationError("EXCLUSIONS_TOO_LARGE", "Exclusions list exceeds 100 entries"))

    if not target.get("authorized", False):
        errors.append(ValidationWarning("NOT_AUTHORIZED", "Target not marked as authorized"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateCollectionConfig(input) → ValidationResult

```python
def validate_collection_config(input_data):
    errors = []
    coll = input_data.get("collection", {})
    if not coll:
        return ValidationResult(valid=True, errors=[])

    methods = coll.get("methods", [])
    valid_methods = ["passive", "active", "hybrid"]
    for m in methods:
        if m not in valid_methods:
            errors.append(ValidationError("INVALID_METHOD", f"Invalid collection method: {m}"))
    if len(methods) > 3:
        errors.append(ValidationError("TOO_MANY_METHODS", "Cannot use more than 3 collection methods"))

    sources = coll.get("sources", [])
    if len(sources) > 50:
        errors.append(ValidationError("TOO_MANY_SOURCES", "Cannot have more than 50 sources"))

    depth = coll.get("depth", 3)
    if not isinstance(depth, int) or depth < 1 or depth > 10:
        errors.append(ValidationError("DEPTH_OUT_OF_RANGE", "Depth must be 1-10"))

    threads = coll.get("threads", 10)
    if not isinstance(threads, int) or threads < 1 or threads > 100:
        errors.append(ValidationError("THREADS_OUT_OF_RANGE", "Threads must be 1-100"))

    timeout = coll.get("timeout", 30000)
    if not isinstance(timeout, (int, float)) or timeout < 1000 or timeout > 300000:
        errors.append(ValidationError("TIMEOUT_OUT_OF_RANGE", "Timeout must be 1000-300000 ms"))

    rate_limit = coll.get("rate_limit", 10)
    if not isinstance(rate_limit, (int, float)) or rate_limit < 0.1 or rate_limit > 100:
        errors.append(ValidationError("RATE_LIMIT_OUT_OF_RANGE", "Rate limit must be 0.1-100"))

    proxy = coll.get("proxy", "")
    if proxy and len(proxy) > 512:
        errors.append(ValidationError("PROXY_TOO_LONG", "Proxy string exceeds 512 characters"))

    user_agent = coll.get("user_agent", "")
    if user_agent and len(user_agent) > 256:
        errors.append(ValidationError("USER_AGENT_TOO_LONG", "User agent exceeds 256 characters"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateAnalysisConfig(input) → ValidationResult

```python
def validate_analysis_config(input_data):
    errors = []
    analysis = input_data.get("analysis", {})
    if not analysis:
        return ValidationResult(valid=True, errors=[])

    focus = analysis.get("focus", [])
    valid_focus = ["subdomains", "ips", "urls", "technologies", "cloud", "apis", "emails", "secrets", "config"]
    for f in focus:
        if f not in valid_focus:
            errors.append(ValidationError("INVALID_FOCUS", f"Invalid analysis focus: {f}"))
    if len(focus) > 9:
        errors.append(ValidationError("TOO_MANY_FOCUS", "Cannot focus on more than 9 areas"))

    max_results = analysis.get("max_results", 10000)
    if not isinstance(max_results, int) or max_results < 1 or max_results > 100000:
        errors.append(ValidationError("MAX_RESULTS_OUT_OF_RANGE", "max_results must be 1-100000"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeTargetValue(value, target_type) → str

```python
def sanitize_target_value(value, target_type):
    value = value.strip()
    value = value[:2048]
    if target_type in ("domain", "subdomain"):
        value = value.lower()
        value = re.sub(r'[^\w\.\-]', '', value)
    elif target_type == "ip":
        value = re.sub(r'[^\d\.\/]', '', value)
    elif target_type == "url":
        value = re.sub(r'[<>"\';\\]', '', value)
    elif target_type == "email":
        value = value.lower()
    elif target_type == "repo":
        value = re.sub(r'[^\w\-_.\/]', '', value)
    return value
```

### 5.2 sanitizeSources(sources) → list

```python
def sanitize_sources(sources):
    sanitized = []
    for source in sources[:50]:
        source = str(source).strip()[:512]
        source = re.sub(r'[<>"\';\\]', '', source)
        if source:
            sanitized.append(source)
    return sanitized
```

### 5.3 sanitizeScopeRules(rules) → list

```python
def sanitize_scope_rules(rules):
    sanitized = []
    for rule in rules[:100]:
        rule = str(rule).strip()[:1024]
        rule = re.sub(r'[<>"\';\\]', '', rule)
        if rule:
            sanitized.append(rule)
    return sanitized
```

### 5.4 sanitizeUserAgent(ua) → str

```python
def sanitize_user_agent(ua):
    ua = ua.strip()
    ua = ua[:256]
    ua = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', ua)
    return ua
```

---

## 6. Type Coercion

### 6.1 coerceReconType(raw_type) → str

```python
RECON_TYPE_MAP = {
    "subdomain": "subdomain_enumeration", "sub_enum": "subdomain_enumeration",
    "osint": "passive_osint", "passive": "passive_osint",
    "active": "active_asset_discovery", "asset": "active_asset_discovery",
    "fingerprint": "technology_fingerprinting", "tech": "technology_fingerprinting",
    "cloud": "cloud_resource_enum", "aws": "cloud_resource_enum",
    "api": "api_endpoint_discovery", "endpoints": "api_endpoint_discovery",
    "js": "javascript_source_analysis", "javascript": "javascript_source_analysis",
    "config": "config_file_extraction",
    "version": "version_detection",
    "content": "content_discovery",
    "dir": "directory_brute_force", "directory": "directory_brute_force",
    "file_type": "file_type_detection",
    "backup": "backup_file_discovery",
    "source": "source_code_leak", "leak": "source_code_leak",
    "git": "git_repository_analysis",
    "dns": "dns_enumeration",
    "cert": "certificate_transparency", "crt": "certificate_transparency",
    "historical": "historical_data_analysis", "wayback": "historical_data_analysis",
    "social": "social_media_osint",
    "employee": "employee_linked_assets",
    "third_party": "third_party_integration",
    "archive": "web_archive_analysis",
    "pastebin": "pastebin_leak_search",
    "code_mine": "code_repository_mining",
    "container": "container_registry_enum",
    "iot": "iot_device_discovery",
    "mobile": "mobile_app_analysis",
    "api_doc": "api_documentation_extraction",
    "ws": "websocket_endpoint_discovery", "websocket": "websocket_endpoint_discovery",
    "gql": "graphql_introspection", "graphql": "graphql_introspection",
    "xml_rpc": "xml_rpc_soap_discovery",
    "email": "email_address_harvesting",
    "phone": "phone_number_enumeration",
    "physical": "physical_location_intel",
    "supply_chain": "supply_chain_asset_mapping",
    "competitor": "competitor_analysis",
    "partner": "partner_network_discovery",
    "acquisition": "acquisition_target_analysis",
    "subsidiary": "subsidiary_asset_mapping",
    "regional": "regional_infrastructure_mapping",
    "cms": "cms_detection",
    "framework": "framework_identification",
    "server": "server_configuration_analysis",
    "ssl": "ssl_tls_certificate_analysis", "tls": "ssl_tls_certificate_analysis",
    "header": "http_header_intelligence",
    "cookie": "cookie_analysis",
    "error": "error_page_analysis",
    "debug": "debug_endpoint_discovery",
    "staging": "staging_environment_detection",
    "strategy": "advanced_recon_strategy"
}

def coerce_recon_type(raw_type):
    return RECON_TYPE_MAP.get(str(raw_type).lower().strip(), raw_type)
```

### 6.2 coerceTargetType(raw_type) → str

```python
def coerce_target_type(raw_type):
    type_map = {
        "domain": "domain", "domain_name": "domain",
        "subdomain": "subdomain", "sub": "subdomain",
        "ip": "ip", "address": "ip", "host": "ip",
        "cidr": "cidr", "range": "cidr",
        "url": "url", "endpoint": "url", "link": "url",
        "org": "org", "organization": "org", "company": "org",
        "email": "email",
        "username": "username", "user": "username",
        "repo": "repo", "repository": "repo", "github": "repo"
    }
    return type_map.get(str(raw_type).lower().strip(), "domain")
```

### 6.3 coerceCollectionMethods(methods) → list

```python
def coerce_collection_methods(methods):
    if isinstance(methods, str):
        methods = [methods]
    valid = {"passive", "active", "hybrid"}
    return [m for m in methods if m in valid][:3]
```

### 6.4 coerceNumericParams(params) → dict

```python
def coerce_numeric_params(params):
    int_fields = ["depth", "threads", "timeout", "max_results"]
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

---

## 7. Custom Validators

### 7.1 validateReconTypeTargetCompatibility(recon_type, target) → list

```python
RECON_TYPE_TARGET_COMPAT = {
    "subdomain_enumeration": ["domain", "org"],
    "passive_osint": ["domain", "org", "email", "username"],
    "active_asset_discovery": ["domain", "ip", "cidr"],
    "technology_fingerprinting": ["url", "domain"],
    "cloud_resource_enum": ["domain", "org"],
    "api_endpoint_discovery": ["url", "domain"],
    "javascript_source_analysis": ["url"],
    "config_file_extraction": ["url", "domain"],
    "version_detection": ["url", "ip"],
    "content_discovery": ["url", "domain"],
    "directory_brute_force": ["url"],
    "file_type_detection": ["url"],
    "backup_file_discovery": ["url", "domain"],
    "source_code_leak": ["domain", "repo"],
    "git_repository_analysis": ["repo", "url"],
    "dns_enumeration": ["domain"],
    "certificate_transparency": ["domain"],
    "historical_data_analysis": ["domain", "url"],
    "social_media_osint": ["username", "org"],
    "employee_linked_assets": ["org", "email"],
    "third_party_integration": ["url", "domain"],
    "web_archive_analysis": ["url", "domain"],
    "pastebin_leak_search": ["domain", "org", "email"],
    "code_repository_mining": ["org", "repo"],
    "container_registry_enum": ["org"],
    "iot_device_discovery": ["ip", "cidr"],
    "mobile_app_analysis": ["org"],
    "api_documentation_extraction": ["url"],
    "websocket_endpoint_discovery": ["url"],
    "graphql_introspection": ["url"],
    "xml_rpc_soap_discovery": ["url"],
    "email_address_harvesting": ["domain", "org"],
    "phone_number_enumeration": ["org"],
    "physical_location_intel": ["org"],
    "supply_chain_asset_mapping": ["org"],
    "cms_detection": ["url"],
    "framework_identification": ["url"],
    "server_configuration_analysis": ["url", "ip"],
    "ssl_tls_certificate_analysis": ["domain", "url"],
    "http_header_intelligence": ["url"],
    "cookie_analysis": ["url"],
    "error_page_analysis": ["url"],
    "debug_endpoint_discovery": ["url"],
    "staging_environment_detection": ["domain"],
    "advanced_recon_strategy": ["domain", "org"]
}

def validate_recon_type_target_compatibility(recon_type, target):
    errors = []
    if not target:
        return errors
    target_type = target.get("type", "")
    compatible = RECON_TYPE_TARGET_COMPAT.get(recon_type, [])
    if compatible and target_type not in compatible:
        errors.append(ValidationWarning(
            "RECON_TYPE_TARGET_MISMATCH",
            f"Recon type '{recon_type}' is typically used with target types: {', '.join(compatible)}"
        ))
    return errors
```

### 7.2 validateScopeConsistency(target) → list

```python
def validate_scope_consistency(target):
    errors = []
    scope = target.get("scope", [])
    exclusions = target.get("exclusions", [])
    target_value = target.get("value", "")

    for exclusion in exclusions:
        if exclusion == target_value:
            errors.append(ValidationError(
                "TARGET_EXCLUDED",
                f"Target '{target_value}' matches an exclusion rule"
            ))

    if scope and exclusions:
        overlap = set(scope) & set(exclusions)
        if overlap:
            errors.append(ValidationWarning(
                "SCOPE_EXCLUSION_OVERLAP",
                f"Scope and exclusions overlap: {', '.join(overlap)}"
            ))

    return errors
```

### 7.3 validateCollectionSafety(collection, recon_type) → list

```python
def validate_collection_safety(collection, recon_type):
    errors = []
    if not collection:
        return errors

    methods = collection.get("methods", [])
    rate_limit = collection.get("rate_limit", 10)
    threads = collection.get("threads", 10)

    if "active" in methods:
        if rate_limit > 50:
            errors.append(ValidationWarning(
                "HIGH_ACTIVE_RATE",
                "Active reconnaissance with high rate limit may be detected"
            ))
        if threads > 50:
            errors.append(ValidationWarning(
                "HIGH_ACTIVE_THREADS",
                "Active reconnaissance with many threads may be aggressive"
            ))

    if recon_type in ("directory_brute_force", "content_discovery"):
        if rate_limit > 30:
            errors.append(ValidationWarning(
                "AGGRESSIVE_CONTENT_DISCOVERY",
                "Content discovery with high rate limit may trigger WAF"
            ))

    return errors
```

### 7.4 validateAnalysisFocusConsistency(analysis, recon_type) → list

```python
def validate_analysis_focus_consistency(analysis, recon_type):
    errors = []
    if not analysis:
        return errors

    focus = analysis.get("focus", [])
    if not focus:
        errors.append(ValidationWarning("NO_FOCUS", "No analysis focus areas specified"))
        return errors

    type_focus_map = {
        "subdomain_enumeration": ["subdomains", "ips"],
        "dns_enumeration": ["subdomains", "ips"],
        "technology_fingerprinting": ["technologies", "config"],
        "api_endpoint_discovery": ["apis", "urls"],
        "cloud_resource_enum": ["cloud", "config"],
        "email_address_harvesting": ["emails"],
        "source_code_leak": ["secrets", "config"],
        "git_repository_analysis": ["secrets", "config"],
    }

    expected_focus = type_focus_map.get(recon_type, [])
    if expected_focus:
        overlap = set(focus) & set(expected_focus)
        if not overlap:
            errors.append(ValidationWarning(
                "FOCUS_NOT_OPTIMAL",
                f"Analysis focus may not be optimal for '{recon_type}'. Consider: {', '.join(expected_focus)}"
            ))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_RECON_TYPE` | ERROR | Recon type not recognized |
| `TARGET_VALUE_EMPTY` | ERROR | Target value cannot be empty |
| `TARGET_VALUE_TOO_LONG` | ERROR | Target value exceeds 2048 characters |
| `INVALID_DOMAIN` | ERROR | Domain format invalid |
| `INVALID_SUBDOMAIN` | ERROR | Subdomain format invalid |
| `INVALID_IP` | ERROR | IP address format invalid |
| `INVALID_CIDR` | ERROR | CIDR notation invalid |
| `INVALID_URL` | ERROR | URL format invalid |
| `INVALID_EMAIL` | ERROR | Email format invalid |
| `INVALID_REPO` | ERROR | Repository format invalid |
| `SCOPE_TOO_LARGE` | ERROR | Scope list exceeds 100 entries |
| `EXCLUSIONS_TOO_LARGE` | ERROR | Exclusions list exceeds 100 entries |
| `NOT_AUTHORIZED` | WARNING | Target not marked as authorized |
| `INVALID_METHOD` | ERROR | Collection method not recognized |
| `TOO_MANY_METHODS` | ERROR | Cannot use more than 3 collection methods |
| `TOO_MANY_SOURCES` | ERROR | Cannot have more than 50 sources |
| `DEPTH_OUT_OF_RANGE` | ERROR | Depth must be 1-10 |
| `THREADS_OUT_OF_RANGE` | ERROR | Threads must be 1-100 |
| `TIMEOUT_OUT_OF_RANGE` | ERROR | Timeout outside valid range |
| `RATE_LIMIT_OUT_OF_RANGE` | ERROR | Rate limit outside valid range |
| `PROXY_TOO_LONG` | ERROR | Proxy string exceeds 512 characters |
| `USER_AGENT_TOO_LONG` | ERROR | User agent exceeds 256 characters |
| `INVALID_FOCUS` | ERROR | Analysis focus not recognized |
| `TOO_MANY_FOCUS` | ERROR | Cannot focus on more than 9 areas |
| `MAX_RESULTS_OUT_OF_RANGE` | ERROR | max_results outside valid range |
| `RECON_TYPE_TARGET_MISMATCH` | WARNING | Recon type may not match target type |
| `TARGET_EXCLUDED` | ERROR | Target matches exclusion rule |
| `SCOPE_EXCLUSION_OVERLAP` | WARNING | Scope and exclusions overlap |
| `HIGH_ACTIVE_RATE` | WARNING | Active recon with high rate limit |
| `HIGH_ACTIVE_THREADS` | WARNING | Active recon with many threads |
| `AGGRESSIVE_CONTENT_DISCOVERY` | WARNING | Content discovery may trigger WAF |
| `NO_FOCUS` | WARNING | No analysis focus areas specified |
| `FOCUS_NOT_OPTIMAL` | WARNING | Analysis focus may not be optimal |

---

## 9. Error Messages

```python
RECON_ERROR_MESSAGES = {
    "INVALID_RECON_TYPE": "Recon type not recognized. Check the supported reconnaissance techniques.",
    "TARGET_VALUE_EMPTY": "Target value cannot be empty.",
    "TARGET_VALUE_TOO_LONG": "Target value must be 2048 characters or fewer.",
    "INVALID_DOMAIN": "Domain format is invalid.",
    "INVALID_SUBDOMAIN": "Subdomain format is invalid.",
    "INVALID_IP": "IP address format is invalid.",
    "INVALID_CIDR": "CIDR notation is invalid.",
    "INVALID_URL": "URL format is invalid. Ensure it includes scheme and host.",
    "INVALID_EMAIL": "Email format is invalid.",
    "INVALID_REPO": "Repository format invalid. Expected: owner/repo",
    "SCOPE_TOO_LARGE": "Scope list cannot exceed 100 entries.",
    "EXCLUSIONS_TOO_LARGE": "Exclusions list cannot exceed 100 entries.",
    "NOT_AUTHORIZED": "Target has not been marked as authorized.",
    "INVALID_METHOD": "Collection method not recognized.",
    "TOO_MANY_METHODS": "Cannot use more than 3 collection methods.",
    "TOO_MANY_SOURCES": "Cannot have more than 50 sources.",
    "DEPTH_OUT_OF_RANGE": "Depth must be between 1 and 10.",
    "THREADS_OUT_OF_RANGE": "Threads must be between 1 and 100.",
    "TIMEOUT_OUT_OF_RANGE": "Timeout must be between 1000ms and 300000ms.",
    "RATE_LIMIT_OUT_OF_RANGE": "Rate limit must be between 0.1 and 100 requests/sec.",
    "PROXY_TOO_LONG": "Proxy string must be 512 characters or fewer.",
    "USER_AGENT_TOO_LONG": "User agent must be 256 characters or fewer.",
    "INVALID_FOCUS": "Analysis focus area not recognized.",
    "TOO_MANY_FOCUS": "Cannot focus on more than 9 areas.",
    "MAX_RESULTS_OUT_OF_RANGE": "max_results must be between 1 and 100000.",
    "RECON_TYPE_TARGET_MISMATCH": "Recon type may not be optimal for this target type.",
    "TARGET_EXCLUDED": "Target matches an exclusion rule.",
    "SCOPE_EXCLUSION_OVERLAP": "Scope and exclusions have overlapping entries.",
    "HIGH_ACTIVE_RATE": "Active reconnaissance with high rate limit may be detected.",
    "HIGH_ACTIVE_THREADS": "Active reconnaissance with many threads may be aggressive.",
    "AGGRESSIVE_CONTENT_DISCOVERY": "Content discovery with high rate may trigger WAF.",
    "NO_FOCUS": "No analysis focus areas specified.",
    "FOCUS_NOT_OPTIMAL": "Analysis focus may not be optimal for this recon type.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| RD001 | Recon type must be valid | ERROR | No |
| RD002 | Target value must not be empty | ERROR | No |
| RD003 | Target value must not exceed 2048 chars | ERROR | Truncate |
| RD004 | Domain format must be valid | ERROR | No |
| RD005 | IP format must be valid | ERROR | No |
| RD006 | URL format must be valid | ERROR | No |
| RD007 | Email format must be valid | ERROR | No |
| RD008 | Scope max 100 entries | ERROR | Truncate |
| RD009 | Exclusions max 100 entries | ERROR | Truncate |
| RD010 | Collection methods max 3 | ERROR | Truncate |
| RD011 | Sources max 50 | ERROR | Truncate |
| RD012 | Depth must be 1-10 | ERROR | Clamp |
| RD013 | Threads must be 1-100 | ERROR | Clamp |
| RD014 | Timeout must be 1000-300000 ms | ERROR | Clamp |
| RD015 | Rate limit must be 0.1-100 | ERROR | Clamp |
| RD016 | Focus max 9 areas | ERROR | Truncate |
| RD017 | Max results must be 1-100000 | ERROR | Clamp |
| RD018 | Target should match recon type | WARNING | No |
| RD019 | Active recon should have safe rate | WARNING | No |
| RD020 | Analysis focus should be optimal | WARNING | No |

---

## 11. Domain File References

All 50 files in `Reconnaissance-Deep-Dive/` that this validator covers:

| # | File | Recon Type | Key Validation |
|---|------|------------|----------------|
| 01 | `01-Advanced-Subdomain-Enumeration.md` | subdomain_enumeration | target.domain |
| 02 | `02-Passive-OSINT-Collection.md` | passive_osint | target.org/email |
| 03 | `03-Active-Asset-Discovery.md` | active_asset_discovery | target.ip/cidr |
| 04 | `04-Technology-Stack-Fingerprinting.md` | technology_fingerprinting | target.url |
| 05 | `05-Cloud-Resource-Enumeration.md` | cloud_resource_enum | target.org |
| 06 | `06-API-Endpoint-Discovery.md` | api_endpoint_discovery | target.url |
| 07 | `07-JavaScript-Source-Analysis.md` | javascript_source_analysis | target.url |
| 08 | `08-Configuration-File-Extraction.md` | config_file_extraction | target.url |
| 09 | `09-Version-Detection-Techniques.md` | version_detection | target.url/ip |
| 10 | `10-Content-Discovery-Automation.md` | content_discovery | target.url |
| 11 | `11-Directory-Brute-Forcing.md` | directory_brute_force | target.url |
| 12 | `12-File-Type-Detection.md` | file_type_detection | target.url |
| 13 | `13-Backup-File-Discovery.md` | backup_file_discovery | target.url/domain |
| 14 | `14-Source-Code-Leak-Detection.md` | source_code_leak | target.domain/repo |
| 15 | `15-Git-Repository-Analysis.md` | git_repository_analysis | target.repo/url |
| 16 | `16-DNS-Enumeration-Advanced.md` | dns_enumeration | target.domain |
| 17 | `17-Certificate-Transparency-Logs.md` | certificate_transparency | target.domain |
| 18 | `18-Historical-Data-Analysis.md` | historical_data_analysis | target.domain/url |
| 19 | `19-Social-Media-OSINT.md` | social_media_osint | target.username/org |
| 20 | `20-Employee-Linked-Assets.md` | employee_linked_assets | target.org/email |
| 21 | `21-Third-Party-Integration-Discovery.md` | third_party_integration | target.url/domain |
| 22 | `22-Web-Archive-Analysis.md` | web_archive_analysis | target.url/domain |
| 23 | `23-Pastebin-and-Leak-Searching.md` | pastebin_leak_search | target.domain/org |
| 24 | `24-Code-Repository-Mining.md` | code_repository_mining | target.org/repo |
| 25 | `25-Container-Registry-Enumeration.md` | container_registry_enum | target.org |
| 26 | `26-IoT-Device-Discovery.md` | iot_device_discovery | target.ip/cidr |
| 27 | `27-Mobile-App-Analysis.md` | mobile_app_analysis | target.org |
| 28 | `28-API-Documentation-Extraction.md` | api_documentation_extraction | target.url |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | websocket_endpoint_discovery | target.url |
| 30 | `30-GraphQL-Introspection.md` | graphql_introspection | target.url |
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | xml_rpc_soap_discovery | target.url |
| 32 | `32-Email-Address-Harvesting.md` | email_address_harvesting | target.domain/org |
| 33 | `33-Phone-Number-Enumeration.md` | phone_number_enumeration | target.org |
| 34 | `34-Physical-Location-Intelligence.md` | physical_location_intel | target.org |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | supply_chain_asset_mapping | target.org |
| 36 | `36-Competitor-Analysis.md` | competitor_analysis | target.org |
| 37 | `37-Partner-Network-Discovery.md` | partner_network_discovery | target.org |
| 38 | `38-Acquisition-Target-Analysis.md` | acquisition_target_analysis | target.org |
| 39 | `39-Subsidiary-Asset-Mapping.md` | subsidiary_asset_mapping | target.org |
| 40 | `40-Regional-Infrastructure-Mapping.md` | regional_infrastructure_mapping | target.domain |
| 41 | `41-Content-Management-System-Detection.md` | cms_detection | target.url |
| 42 | `42-Framework-and-Library-Identification.md` | framework_identification | target.url |
| 43 | `43-Server-Configuration-Analysis.md` | server_configuration_analysis | target.url/ip |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | ssl_tls_certificate_analysis | target.domain/url |
| 45 | `45-HTTP-Header-Intelligence.md` | http_header_intelligence | target.url |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | cookie_analysis | target.url |
| 47 | `47-Error-Page-Analysis.md` | error_page_analysis | target.url |
| 48 | `48-Debug-Endpoint-Discovery.md` | debug_endpoint_discovery | target.url |
| 49 | `49-Staging-Environment-Detection.md` | staging_environment_detection | target.domain |
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | advanced_recon_strategy | target.domain/org |

---

## 12. Validation Pipeline

```python
def validate_recon_deep_dive_input(input_data):
    results = []
    results.append(("recon_type", validate_recon_type(input_data)))
    results.append(("target", validate_recon_target(input_data)))
    results.append(("collection", validate_collection_config(input_data)))
    results.append(("analysis", validate_analysis_config(input_data)))

    recon_type = input_data.get("recon_type", "")
    target = input_data.get("target", {})
    results.append(("type_compat", ValidationResult(
        valid=True, errors=validate_recon_type_target_compatibility(recon_type, target)
    )))

    results.append(("scope", ValidationResult(
        valid=True, errors=validate_scope_consistency(target)
    )))

    collection = input_data.get("collection", {})
    results.append(("collection_safety", ValidationResult(
        valid=True, errors=validate_collection_safety(collection, recon_type)
    )))

    analysis = input_data.get("analysis", {})
    results.append(("focus_consistency", ValidationResult(
        valid=True, errors=validate_analysis_focus_consistency(analysis, recon_type)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "reconnaissance-deep-dive", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Recon validation runs before any reconnaissance activity
- Type-target compatibility checks suggest optimal recon configurations
- Scope consistency checks prevent scanning excluded targets
- Collection safety checks warn about aggressive active recon
- Analysis focus consistency suggests optimal focus areas
- All validation results are logged for engagement audit trail
- Type coercion normalizes recon types and target types
- Rate limit and thread validation prevent WAF detection

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Reconnaissance Deep Dive domain |
