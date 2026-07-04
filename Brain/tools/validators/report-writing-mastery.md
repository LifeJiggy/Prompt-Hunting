# Report Writing Mastery — Input Validation Reference

**Domain**: Report Writing Mastery (Bug Bounty Report Content)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all report content inputs across the Report-Writing-Mastery domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `report-writing-mastery` |
| Root Directory | `Report-Writing-Mastery/` |
| Total Files | 54 (+ README.md, registry.json) |
| Category | Report Writing, PoC Development, Severity Assessment, Communication |
| Input Surface | Report content, PoC params, severity scores, remediation inputs |

---

## 2. Overview

The Report Writing Mastery validator enforces strict input validation for every report writing prompt in the `Report-Writing-Mastery/` directory. Each file defines a report writing technique — from structure optimization to master framework — and accepts structured inputs that must be validated before execution. This validator ensures:

- Report content meets platform-specific formatting requirements
- Severity assessments use valid CVSS scoring
- PoC development inputs are properly structured
- Remediation recommendations are actionable
- All report sections meet minimum quality thresholds
- Communication parameters are properly configured
- Attachments and references are valid

---

## 3. Schema Definition

### 3.1 Master Report Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ReportWritingInput",
  "type": "object",
  "required": ["domain", "report_type", "report"],
  "properties": {
    "domain": { "type": "string", "const": "report-writing-mastery" },
    "report_type": { "$ref": "#/definitions/ReportType" },
    "report": { "$ref": "#/definitions/ReportConfig" },
    "severity": { "$ref": "#/definitions/SeverityConfig" },
    "poc": { "$ref": "#/definitions/PoCConfig" },
    "remediation": { "$ref": "#/definitions/RemediationConfig" },
    "output": { "$ref": "#/definitions/ReportOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 ReportType Schema

```json
{
  "definitions": {
    "ReportType": {
      "type": "string",
      "enum": [
        "structure_optimization", "technical_writing", "private_program_case",
        "poc_development", "severity_assessment", "remediation_recommendations",
        "executive_summary", "technical_detail", "visual_aid",
        "code_sample", "timeline_documentation", "collaboration_crediting",
        "program_formatting", "language_tone", "attachment_management",
        "follow_up_communication", "rejection_analysis", "reward_negotiation",
        "report_template", "quality_assurance", "grammar_style",
        "technical_accuracy", "impact_quantification", "business_context",
        "compliance_documentation", "international_standard", "audience_analysis",
        "information_hierarchy", "actionable_recommendations", "report_review",
        "common_pitfalls", "advanced_formatting", "multimedia_integration",
        "interactive_elements", "cross_platform", "version_control",
        "report_analytics", "peer_review", "feedback_incorporation",
        "continuous_improvement", "report_personalization", "contextual_intelligence",
        "technical_depth", "impact_visualization", "report_archiving",
        "collaboration_standards", "advanced_poc", "report_automation",
        "quality_metrics", "master_framework", "bugcrowd_dissection",
        "hackerone_analysis", "high_severity_analysis", "impact_communication"
      ]
    }
  }
}
```

### 3.3 ReportConfig Schema

```json
{
  "definitions": {
    "ReportConfig": {
      "type": "object",
      "required": ["title", "vulnerability_class"],
      "properties": {
        "title": { "type": "string", "minLength": 10, "maxLength": 256 },
        "vulnerability_class": { "type": "string", "minLength": 1, "maxLength": 128 },
        "platform": {
          "type": "string",
          "enum": ["hackerone", "bugcrowd", "intigriti", "immunefi", "yeswehack", "custom"]
        },
        "program_name": { "type": "string", "maxLength": 256 },
        "target": { "type": "string", "maxLength": 2048 },
        "endpoint": { "type": "string", "maxLength": 2048 },
        "method": { "type": "string", "enum": ["GET", "POST", "PUT", "DELETE", "PATCH"] },
        "description": { "type": "string", "minLength": 50, "maxLength": 16384 },
        "impact_statement": { "type": "string", "minLength": 20, "maxLength": 4096 },
        "steps_to_reproduce": {
          "type": "array",
          "items": { "type": "string", "maxLength": 2048 },
          "minItems": 1,
          "maxItems": 50
        },
        "supporting_materials": {
          "type": "array",
          "items": { "$ref": "#/definitions/SupportingMaterial" },
          "maxItems": 20
        },
        "tags": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 10
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 SupportingMaterial Schema

```json
{
  "definitions": {
    "SupportingMaterial": {
      "type": "object",
      "required": ["type", "description"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["screenshot", "video", "code_snippet", "request_response", "har_file", "log", "other"]
        },
        "description": { "type": "string", "minLength": 5, "maxLength": 512 },
        "content": { "type": "string", "maxLength": 65536 },
        "filename": { "type": "string", "maxLength": 256 }
      }
    }
  }
}
```

### 3.5 SeverityConfig Schema

```json
{
  "definitions": {
    "SeverityConfig": {
      "type": "object",
      "properties": {
        "cvss_version": { "type": "string", "enum": ["3.0", "3.1", "4.0"], "default": "3.1" },
        "cvss_vector": { "type": "string", "maxLength": 256 },
        "cvss_score": { "type": "number", "minimum": 0, "maximum": 10 },
        "severity": {
          "type": "string",
          "enum": ["low", "medium", "high", "critical", "informational"]
        },
        "justification": { "type": "string", "minLength": 20, "maxLength": 2048 },
        "cvss_metrics": {
          "type": "object",
          "properties": {
            "attack_vector": { "type": "string", "enum": ["N", "A", "L", "P"] },
            "attack_complexity": { "type": "string", "enum": ["L", "H"] },
            "privileges_required": { "type": "string", "enum": ["N", "L", "H"] },
            "user_interaction": { "type": "string", "enum": ["N", "R"] },
            "scope": { "type": "string", "enum": ["U", "C"] },
            "confidentiality": { "type": "string", "enum": ["N", "L", "H"] },
            "integrity": { "type": "string", "enum": ["N", "L", "H"] },
            "availability": { "type": "string", "enum": ["N", "L", "H"] }
          }
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 PoCConfig Schema

```json
{
  "definitions": {
    "PoCConfig": {
      "type": "object",
      "properties": {
        "type": {
          "type": "string",
          "enum": ["curl", "python", "burp", "javascript", "manual", "hybrid"]
        },
        "code": { "type": "string", "maxLength": 65536 },
        "language": { "type": "string", "enum": ["bash", "python", "javascript", "go", "ruby"] },
        "dependencies": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        },
        "expected_output": { "type": "string", "maxLength": 4096 },
        "redacted_fields": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 50
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.7 RemediationConfig Schema

```json
{
  "definitions": {
    "RemediationConfig": {
      "type": "object",
      "properties": {
        "priority": { "type": "string", "enum": ["immediate", "short_term", "long_term"] },
        "effort": { "type": "string", "enum": ["low", "medium", "high"] },
        "recommendations": {
          "type": "array",
          "items": { "type": "string", "maxLength": 1024 },
          "minItems": 1,
          "maxItems": 20
        },
        "code_references": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        },
        "references": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 10
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.8 ReportOutput Schema

```json
{
  "definitions": {
    "ReportOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["markdown", "html", "pdf", "json"] },
        "platform_template": {
          "type": "string",
          "enum": ["hackerone", "bugcrowd", "intigriti", "immunefi", "custom"]
        },
        "include_poc": { "type": "boolean", "default": true },
        "include_remediation": { "type": "boolean", "default": true },
        "destination": { "type": "string", "maxLength": 4096 }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateReportType(input) → ValidationResult

```python
def validate_report_type(input_data):
    errors = []
    report_type = input_data.get("report_type", "")
    valid_types = [
        "structure_optimization", "technical_writing", "private_program_case",
        "poc_development", "severity_assessment", "remediation_recommendations",
        "executive_summary", "technical_detail", "visual_aid",
        "code_sample", "timeline_documentation", "collaboration_crediting",
        "program_formatting", "language_tone", "attachment_management",
        "follow_up_communication", "rejection_analysis", "reward_negotiation",
        "report_template", "quality_assurance", "grammar_style",
        "technical_accuracy", "impact_quantification", "business_context",
        "compliance_documentation", "international_standard", "audience_analysis",
        "information_hierarchy", "actionable_recommendations", "report_review",
        "common_pitfalls", "advanced_formatting", "multimedia_integration",
        "interactive_elements", "cross_platform", "version_control",
        "report_analytics", "peer_review", "feedback_incorporation",
        "continuous_improvement", "report_personalization", "contextual_intelligence",
        "technical_depth", "impact_visualization", "report_archiving",
        "collaboration_standards", "advanced_poc", "report_automation",
        "quality_metrics", "master_framework", "bugcrowd_dissection",
        "hackerone_analysis", "high_severity_analysis", "impact_communication"
    ]
    if report_type not in valid_types:
        errors.append(ValidationError("INVALID_REPORT_TYPE", f"Unknown report type: {report_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateReportConfig(input) → ValidationResult

```python
def validate_report_config(input_data):
    errors = []
    report = input_data.get("report", {})

    title = report.get("title", "")
    if not title:
        errors.append(ValidationError("TITLE_EMPTY", "Report title is required"))
    if len(title) < 10:
        errors.append(ValidationError("TITLE_TOO_SHORT", "Report title must be at least 10 characters"))
    if len(title) > 256:
        errors.append(ValidationError("TITLE_TOO_LONG", "Report title exceeds 256 characters"))

    vuln_class = report.get("vulnerability_class", "")
    if not vuln_class:
        errors.append(ValidationError("VULN_CLASS_EMPTY", "Vulnerability class is required"))
    if len(vuln_class) > 128:
        errors.append(ValidationError("VULN_CLASS_TOO_LONG", "Vulnerability class exceeds 128 characters"))

    platform = report.get("platform", "")
    valid_platforms = ["hackerone", "bugcrowd", "intigriti", "immunefi", "yeswehack", "custom"]
    if platform and platform not in valid_platforms:
        errors.append(ValidationError("INVALID_PLATFORM", f"Invalid platform: {platform}"))

    description = report.get("description", "")
    if description and len(description) < 50:
        errors.append(ValidationError("DESCRIPTION_TOO_SHORT", "Description must be at least 50 characters"))
    if len(description) > 16384:
        errors.append(ValidationError("DESCRIPTION_TOO_LONG", "Description exceeds 16384 characters"))

    impact = report.get("impact_statement", "")
    if impact and len(impact) < 20:
        errors.append(ValidationError("IMPACT_TOO_SHORT", "Impact statement must be at least 20 characters"))
    if len(impact) > 4096:
        errors.append(ValidationError("IMPACT_TOO_LONG", "Impact statement exceeds 4096 characters"))

    steps = report.get("steps_to_reproduce", [])
    if not steps:
        errors.append(ValidationError("NO_STEPS", "Steps to reproduce are required"))
    if len(steps) > 50:
        errors.append(ValidationError("TOO_MANY_STEPS", "Cannot have more than 50 steps"))

    materials = report.get("supporting_materials", [])
    if len(materials) > 20:
        errors.append(ValidationError("TOO_MANY_MATERIALS", "Cannot have more than 20 supporting materials"))

    tags = report.get("tags", [])
    if len(tags) > 10:
        errors.append(ValidationError("TOO_MANY_TAGS", "Cannot have more than 10 tags"))

    target = report.get("target", "")
    if len(target) > 2048:
        errors.append(ValidationError("TARGET_TOO_LONG", "Target exceeds 2048 characters"))

    endpoint = report.get("endpoint", "")
    if len(endpoint) > 2048:
        errors.append(ValidationError("ENDPOINT_TOO_LONG", "Endpoint exceeds 2048 characters"))

    method = report.get("method", "")
    valid_methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    if method and method not in valid_methods:
        errors.append(ValidationError("INVALID_METHOD", f"Invalid HTTP method: {method}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateSeverityConfig(input) → ValidationResult

```python
def validate_severity_config(input_data):
    errors = []
    severity = input_data.get("severity", {})
    if not severity:
        return ValidationResult(valid=True, errors=[])

    cvss_version = severity.get("cvss_version", "3.1")
    if cvss_version not in ("3.0", "3.1", "4.0"):
        errors.append(ValidationError("INVALID_CVSS_VERSION", f"Invalid CVSS version: {cvss_version}"))

    cvss_vector = severity.get("cvss_vector", "")
    if cvss_vector and len(cvss_vector) > 256:
        errors.append(ValidationError("CVSS_VECTOR_TOO_LONG", "CVSS vector exceeds 256 characters"))

    cvss_score = severity.get("cvss_score", -1)
    if cvss_score != -1 and (cvss_score < 0 or cvss_score > 10):
        errors.append(ValidationError("CVSS_SCORE_INVALID", "CVSS score must be 0-10"))

    sev = severity.get("severity", "")
    valid_sev = ["low", "medium", "high", "critical", "informational"]
    if sev and sev not in valid_sev:
        errors.append(ValidationError("INVALID_SEVERITY", f"Invalid severity: {sev}"))

    justification = severity.get("justification", "")
    if justification and len(justification) < 20:
        errors.append(ValidationError("JUSTIFICATION_TOO_SHORT", "Justification must be at least 20 characters"))
    if len(justification) > 2048:
        errors.append(ValidationError("JUSTIFICATION_TOO_LONG", "Justification exceeds 2048 characters"))

    metrics = severity.get("cvss_metrics", {})
    if metrics:
        valid_av = ["N", "A", "L", "P"]
        valid_ac = ["L", "H"]
        valid_pr = ["N", "L", "H"]
        valid_ui = ["N", "R"]
        valid_scope = ["U", "C"]
        valid_cia = ["N", "L", "H"]

        if "attack_vector" in metrics and metrics["attack_vector"] not in valid_av:
            errors.append(ValidationError("INVALID_AV", f"Invalid attack vector: {metrics['attack_vector']}"))
        if "attack_complexity" in metrics and metrics["attack_complexity"] not in valid_ac:
            errors.append(ValidationError("INVALID_AC", f"Invalid attack complexity: {metrics['attack_complexity']}"))
        if "privileges_required" in metrics and metrics["privileges_required"] not in valid_pr:
            errors.append(ValidationError("INVALID_PR", f"Invalid privileges required: {metrics['privileges_required']}"))
        if "user_interaction" in metrics and metrics["user_interaction"] not in valid_ui:
            errors.append(ValidationError("INVALID_UI", f"Invalid user interaction: {metrics['user_interaction']}"))
        if "scope" in metrics and metrics["scope"] not in valid_scope:
            errors.append(ValidationError("INVALID_SCOPE", f"Invalid scope: {metrics['scope']}"))
        if "confidentiality" in metrics and metrics["confidentiality"] not in valid_cia:
            errors.append(ValidationError("INVALID_C", f"Invalid confidentiality: {metrics['confidentiality']}"))
        if "integrity" in metrics and metrics["integrity"] not in valid_cia:
            errors.append(ValidationError("INVALID_I", f"Invalid integrity: {metrics['integrity']}"))
        if "availability" in metrics and metrics["availability"] not in valid_cia:
            errors.append(ValidationError("INVALID_A", f"Invalid availability: {metrics['availability']}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validatePoCConfig(input) → ValidationResult

```python
def validate_poc_config(input_data):
    errors = []
    poc = input_data.get("poc", {})
    if not poc:
        return ValidationResult(valid=True, errors=[])

    poc_type = poc.get("type", "")
    valid_types = ["curl", "python", "burp", "javascript", "manual", "hybrid"]
    if poc_type and poc_type not in valid_types:
        errors.append(ValidationError("INVALID_POC_TYPE", f"Invalid PoC type: {poc_type}"))

    code = poc.get("code", "")
    if len(code) > 65536:
        errors.append(ValidationError("POC_CODE_TOO_LONG", "PoC code exceeds 64KB"))

    language = poc.get("language", "")
    valid_langs = ["bash", "python", "javascript", "go", "ruby"]
    if language and language not in valid_langs:
        errors.append(ValidationError("INVALID_LANGUAGE", f"Invalid language: {language}"))

    dependencies = poc.get("dependencies", [])
    if len(dependencies) > 20:
        errors.append(ValidationError("TOO_MANY_DEPENDENCIES", "Cannot have more than 20 dependencies"))

    expected = poc.get("expected_output", "")
    if len(expected) > 4096:
        errors.append(ValidationError("EXPECTED_OUTPUT_TOO_LONG", "Expected output exceeds 4096 characters"))

    redacted = poc.get("redacted_fields", [])
    if len(redacted) > 50:
        errors.append(ValidationError("TOO_MANY_REDACTED", "Cannot redact more than 50 fields"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.5 validateRemediationConfig(input) → ValidationResult

```python
def validate_remediation_config(input_data):
    errors = []
    remed = input_data.get("remediation", {})
    if not remed:
        return ValidationResult(valid=True, errors=[])

    priority = remed.get("priority", "")
    if priority and priority not in ("immediate", "short_term", "long_term"):
        errors.append(ValidationError("INVALID_PRIORITY", f"Invalid remediation priority: {priority}"))

    effort = remed.get("effort", "")
    if effort and effort not in ("low", "medium", "high"):
        errors.append(ValidationError("INVALID_EFFORT", f"Invalid remediation effort: {effort}"))

    recs = remed.get("recommendations", [])
    if not recs:
        errors.append(ValidationError("NO_RECOMMENDATIONS", "Remediation recommendations are required"))
    if len(recs) > 20:
        errors.append(ValidationError("TOO_MANY_RECOMMENDATIONS", "Cannot have more than 20 recommendations"))

    refs = remed.get("references", [])
    if len(refs) > 10:
        errors.append(ValidationError("TOO_MANY_REFS", "Cannot have more than 10 references"))

    code_refs = remed.get("code_references", [])
    if len(code_refs) > 20:
        errors.append(ValidationError("TOO_MANY_CODE_REFS", "Cannot have more than 20 code references"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeReportTitle(title) → str

```python
def sanitize_report_title(title):
    title = title.strip()
    title = re.sub(r'[<>"\';\\]', '', title)
    return title[:256]
```

### 5.2 sanitizeDescription(desc) → str

```python
def sanitize_description(desc):
    desc = desc.strip()
    desc = desc[:16384]
    desc = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', desc)
    return desc
```

### 5.3 sanitizeSteps(steps) → list

```python
def sanitize_steps(steps):
    sanitized = []
    for step in steps[:50]:
        step = str(step).strip()[:2048]
        step = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', step)
        if step:
            sanitized.append(step)
    return sanitized
```

### 5.4 sanitizeRemediationRecs(recs) → list

```python
def sanitize_remediation_recs(recs):
    sanitized = []
    for rec in recs[:20]:
        rec = str(rec).strip()[:1024]
        rec = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', rec)
        if rec:
            sanitized.append(rec)
    return sanitized
```

---

## 6. Type Coercion

### 6.1 coerceReportType(raw_type) → str

```python
REPORT_TYPE_MAP = {
    "structure": "structure_optimization", "format": "structure_optimization",
    "writing": "technical_writing", "technical": "technical_writing",
    "private": "private_program_case",
    "poc": "poc_development", "exploit": "poc_development",
    "severity": "severity_assessment", "cvss": "severity_assessment",
    "remediation": "remediation_recommendations", "fix": "remediation_recommendations",
    "executive": "executive_summary", "summary": "executive_summary",
    "detail": "technical_detail",
    "visual": "visual_aid",
    "code": "code_sample",
    "timeline": "timeline_documentation",
    "collab": "collaboration_crediting",
    "program": "program_formatting",
    "tone": "language_tone", "language": "language_tone",
    "attachment": "attachment_management",
    "followup": "follow_up_communication", "follow_up": "follow_up_communication",
    "rejection": "rejection_analysis",
    "negotiation": "reward_negotiation", "reward": "reward_negotiation",
    "template": "report_template",
    "qa": "quality_assurance", "quality": "quality_assurance",
    "grammar": "grammar_style", "style": "grammar_style",
    "accuracy": "technical_accuracy",
    "impact": "impact_quantification",
    "business": "business_context",
    "compliance": "compliance_documentation",
    "standard": "international_standard",
    "audience": "audience_analysis",
    "hierarchy": "information_hierarchy",
    "actionable": "actionable_recommendations",
    "review": "report_review",
    "pitfalls": "common_pitfalls",
    "formatting": "advanced_formatting",
    "multimedia": "multimedia_integration",
    "interactive": "interactive_elements",
    "cross_platform": "cross_platform",
    "version": "version_control",
    "analytics": "report_analytics",
    "peer": "peer_review",
    "feedback": "feedback_incorporation",
    "improvement": "continuous_improvement",
    "personalize": "report_personalization",
    "context": "contextual_intelligence",
    "depth": "technical_depth",
    "viz": "impact_visualization",
    "archive": "report_archiving",
    "collab_standards": "collaboration_standards",
    "advanced_poc": "advanced_poc",
    "automation": "report_automation",
    "metrics": "quality_metrics",
    "master": "master_framework",
    "bugcrowd": "bugcrowd_dissection",
    "hackerone": "hackerone_analysis",
    "high_sev": "high_severity_analysis",
    "impact_comm": "impact_communication"
}

def coerce_report_type(raw_type):
    return REPORT_TYPE_MAP.get(str(raw_type).lower().strip(), raw_type)
```

### 6.2 coerceCVSSScore(score) → float

```python
def coerce_cvss_score(score):
    try:
        score = float(score)
    except (ValueError, TypeError):
        return 0.0
    return max(0.0, min(10.0, score))
```

### 6.3 coerceSeverity(severity) → str

```python
SEV_MAP = {
    "low": "low", "l": "low",
    "medium": "medium", "m": "medium", "moderate": "medium",
    "high": "high", "h": "high",
    "critical": "critical", "c": "critical", "crit": "critical",
    "info": "informational", "informational": "informational", "none": "informational"
}

def coerce_severity(severity):
    return SEV_MAP.get(str(severity).lower().strip(), "medium")
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

### 7.1 validateReportCompleteness(report) → list

```python
def validate_report_completeness(report):
    errors = []
    required_fields = ["title", "vulnerability_class", "description", "impact_statement", "steps_to_reproduce"]
    for field in required_fields:
        if not report.get(field):
            errors.append(ValidationError(
                f"MISSING_{field.upper()}",
                f"Required field '{field}' is missing"
            ))

    steps = report.get("steps_to_reproduce", [])
    if steps and len(steps) < 2:
        errors.append(ValidationWarning(
            "FEW_STEPS",
            "Only 1 step to reproduce. Consider adding more detail."
        ))

    return errors
```

### 7.2 validateSeverityCVSSConsistency(severity) → list

```python
CVSS_SEVERITY_RANGES = {
    "informational": (0, 0),
    "low": (0.1, 3.9),
    "medium": (4.0, 6.9),
    "high": (7.0, 8.9),
    "critical": (9.0, 10.0)
}

def validate_severity_cvss_consistency(severity):
    errors = []
    sev = severity.get("severity", "")
    cvss = severity.get("cvss_score", -1)

    if sev and cvss >= 0:
        expected = CVSS_SEVERITY_RANGES.get(sev, (0, 10))
        if cvss < expected[0] or cvss > expected[1]:
            errors.append(ValidationWarning(
                "CVSS_SEVERITY_MISMATCH",
                f"CVSS score {cvss} does not match severity '{sev}'"
            ))
    return errors
```

### 7.3 validatePoCRedaction(poc) → list

```python
def validate_poc_redaction(poc):
    errors = []
    code = poc.get("code", "")
    redacted = poc.get("redacted_fields", [])

    sensitive_patterns = [
        (r'[A-Za-z0-9+/]{40,}={0,2}', "Potential base64 token"),
        (r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', "Bearer token"),
        (r'Authorization:\s*\S+', "Authorization header"),
        (r'Cookie:\s*\S+', "Cookie header"),
        (r'password\s*[=:]\s*\S+', "Password value"),
        (r'api[_-]?key\s*[=:]\s*\S+', "API key"),
        (r'secret\s*[=:]\s*\S+', "Secret value"),
    ]

    for pattern, desc in sensitive_patterns:
        if re.search(pattern, code, re.IGNORECASE):
            if not redacted:
                errors.append(ValidationWarning(
                    "UNREDACTED_SENSITIVE",
                    f"PoC code contains potentially sensitive data: {desc}"
                ))

    return errors
```

### 7.4 validateRemediationActionability(remediation) → list

```python
def validate_remediation_actionability(remediation):
    errors = []
    recs = remediation.get("recommendations", [])

    vague_patterns = [
        r'^fix\s+the\s+vulnerability',
        r'^patch\s+this\s+issue',
        r'^resolve\s+the\s+problem',
        r'^update\s+the\s+code',
        r'^improve\s+security',
    ]

    for i, rec in enumerate(recs):
        for pattern in vague_patterns:
            if re.match(pattern, rec, re.IGNORECASE):
                errors.append(ValidationWarning(
                    "VAGUE_RECOMMENDATION",
                    f"Recommendation {i+1} may be too vague: '{rec[:50]}...'"
                ))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_REPORT_TYPE` | ERROR | Report type not recognized |
| `TITLE_EMPTY` | ERROR | Report title is required |
| `TITLE_TOO_SHORT` | ERROR | Report title must be at least 10 characters |
| `TITLE_TOO_LONG` | ERROR | Report title exceeds 256 characters |
| `VULN_CLASS_EMPTY` | ERROR | Vulnerability class is required |
| `VULN_CLASS_TOO_LONG` | ERROR | Vulnerability class exceeds 128 characters |
| `INVALID_PLATFORM` | ERROR | Platform not recognized |
| `DESCRIPTION_TOO_SHORT` | ERROR | Description must be at least 50 characters |
| `DESCRIPTION_TOO_LONG` | ERROR | Description exceeds 16384 characters |
| `IMPACT_TOO_SHORT` | ERROR | Impact statement must be at least 20 characters |
| `IMPACT_TOO_LONG` | ERROR | Impact statement exceeds 4096 characters |
| `NO_STEPS` | ERROR | Steps to reproduce are required |
| `TOO_MANY_STEPS` | ERROR | Cannot have more than 50 steps |
| `TOO_MANY_MATERIALS` | ERROR | Cannot have more than 20 supporting materials |
| `TOO_MANY_TAGS` | ERROR | Cannot have more than 10 tags |
| `TARGET_TOO_LONG` | ERROR | Target exceeds 2048 characters |
| `ENDPOINT_TOO_LONG` | ERROR | Endpoint exceeds 2048 characters |
| `INVALID_METHOD` | ERROR | HTTP method not recognized |
| `INVALID_CVSS_VERSION` | ERROR | CVSS version not recognized |
| `CVSS_VECTOR_TOO_LONG` | ERROR | CVSS vector exceeds 256 characters |
| `CVSS_SCORE_INVALID` | ERROR | CVSS score must be 0-10 |
| `INVALID_SEVERITY` | ERROR | Severity not recognized |
| `JUSTIFICATION_TOO_SHORT` | ERROR | Justification must be at least 20 characters |
| `JUSTIFICATION_TOO_LONG` | ERROR | Justification exceeds 2048 characters |
| `INVALID_AV` | ERROR | Invalid attack vector metric |
| `INVALID_AC` | ERROR | Invalid attack complexity metric |
| `INVALID_PR` | ERROR | Invalid privileges required metric |
| `INVALID_UI` | ERROR | Invalid user interaction metric |
| `INVALID_SCOPE` | ERROR | Invalid scope metric |
| `INVALID_C` | ERROR | Invalid confidentiality metric |
| `INVALID_I` | ERROR | Invalid integrity metric |
| `INVALID_A` | ERROR | Invalid availability metric |
| `INVALID_POC_TYPE` | ERROR | PoC type not recognized |
| `POC_CODE_TOO_LONG` | ERROR | PoC code exceeds 64KB |
| `INVALID_LANGUAGE` | ERROR | Language not recognized |
| `TOO_MANY_DEPENDENCIES` | ERROR | Cannot have more than 20 dependencies |
| `EXPECTED_OUTPUT_TOO_LONG` | ERROR | Expected output exceeds 4096 characters |
| `TOO_MANY_REDACTED` | ERROR | Cannot redact more than 50 fields |
| `INVALID_PRIORITY` | ERROR | Remediation priority not recognized |
| `INVALID_EFFORT` | ERROR | Remediation effort not recognized |
| `NO_RECOMMENDATIONS` | ERROR | Remediation recommendations are required |
| `TOO_MANY_RECOMMENDATIONS` | ERROR | Cannot have more than 20 recommendations |
| `TOO_MANY_REFS` | ERROR | Cannot have more than 10 references |
| `TOO_MANY_CODE_REFS` | ERROR | Cannot have more than 20 code references |
| `CVSS_SEVERITY_MISMATCH` | WARNING | CVSS score doesn't match severity |
| `UNREDACTED_SENSITIVE` | WARNING | PoC contains unredacted sensitive data |
| `VAGUE_RECOMMENDATION` | WARNING | Remediation recommendation is too vague |
| `FEW_STEPS` | WARNING | Only 1 step to reproduce |
| `MISSING_*` | ERROR | Required report field is missing |

---

## 9. Error Messages

```python
REPORT_ERROR_MESSAGES = {
    "INVALID_REPORT_TYPE": "Report type not recognized.",
    "TITLE_EMPTY": "Report title is required.",
    "TITLE_TOO_SHORT": "Report title must be at least 10 characters.",
    "TITLE_TOO_LONG": "Report title must be 256 characters or fewer.",
    "VULN_CLASS_EMPTY": "Vulnerability class is required.",
    "VULN_CLASS_TOO_LONG": "Vulnerability class must be 128 characters or fewer.",
    "INVALID_PLATFORM": "Platform not recognized.",
    "DESCRIPTION_TOO_SHORT": "Description must be at least 50 characters.",
    "DESCRIPTION_TOO_LONG": "Description must be 16384 characters or fewer.",
    "IMPACT_TOO_SHORT": "Impact statement must be at least 20 characters.",
    "IMPACT_TOO_LONG": "Impact statement must be 4096 characters or fewer.",
    "NO_STEPS": "Steps to reproduce are required.",
    "TOO_MANY_STEPS": "Cannot have more than 50 steps.",
    "TOO_MANY_MATERIALS": "Cannot have more than 20 supporting materials.",
    "TOO_MANY_TAGS": "Cannot have more than 10 tags.",
    "TARGET_TOO_LONG": "Target must be 2048 characters or fewer.",
    "ENDPOINT_TOO_LONG": "Endpoint must be 2048 characters or fewer.",
    "INVALID_METHOD": "HTTP method not recognized.",
    "INVALID_CVSS_VERSION": "CVSS version must be 3.0, 3.1, or 4.0.",
    "CVSS_VECTOR_TOO_LONG": "CVSS vector must be 256 characters or fewer.",
    "CVSS_SCORE_INVALID": "CVSS score must be between 0 and 10.",
    "INVALID_SEVERITY": "Severity must be: low, medium, high, critical, or informational.",
    "JUSTIFICATION_TOO_SHORT": "Justification must be at least 20 characters.",
    "JUSTIFICATION_TOO_LONG": "Justification must be 2048 characters or fewer.",
    "INVALID_AV": "Attack vector must be N, A, L, or P.",
    "INVALID_AC": "Attack complexity must be L or H.",
    "INVALID_PR": "Privileges required must be N, L, or H.",
    "INVALID_UI": "User interaction must be N or R.",
    "INVALID_SCOPE": "Scope must be U or C.",
    "INVALID_C": "Confidentiality must be N, L, or H.",
    "INVALID_I": "Integrity must be N, L, or H.",
    "INVALID_A": "Availability must be N, L, or H.",
    "INVALID_POC_TYPE": "PoC type not recognized.",
    "POC_CODE_TOO_LONG": "PoC code must be 64KB or fewer.",
    "INVALID_LANGUAGE": "Language not recognized.",
    "TOO_MANY_DEPENDENCIES": "Cannot have more than 20 dependencies.",
    "EXPECTED_OUTPUT_TOO_LONG": "Expected output must be 4096 characters or fewer.",
    "TOO_MANY_REDACTED": "Cannot redact more than 50 fields.",
    "INVALID_PRIORITY": "Remediation priority must be: immediate, short_term, or long_term.",
    "INVALID_EFFORT": "Remediation effort must be: low, medium, or high.",
    "NO_RECOMMENDATIONS": "Remediation recommendations are required.",
    "TOO_MANY_RECOMMENDATIONS": "Cannot have more than 20 recommendations.",
    "TOO_MANY_REFS": "Cannot have more than 10 references.",
    "TOO_MANY_CODE_REFS": "Cannot have more than 20 code references.",
    "CVSS_SEVERITY_MISMATCH": "CVSS score does not match the assigned severity.",
    "UNREDACTED_SENSITIVE": "PoC code contains potentially sensitive data that should be redacted.",
    "VAGUE_RECOMMENDATION": "Remediation recommendation is too vague to be actionable.",
    "FEW_STEPS": "Only 1 step to reproduce. Consider adding more detail.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| RW001 | Report type must be valid | ERROR | No |
| RW002 | Title must be 10-256 chars | ERROR | Truncate/Pad |
| RW003 | Vulnerability class is required | ERROR | No |
| RW004 | Description must be 50-16384 chars | ERROR | Truncate/Pad |
| RW005 | Impact statement must be 20-4096 chars | ERROR | Truncate/Pad |
| RW006 | Steps to reproduce required | ERROR | No |
| RW007 | Steps max 50 | ERROR | Truncate |
| RW008 | Supporting materials max 20 | ERROR | Truncate |
| RW009 | Tags max 10 | ERROR | Truncate |
| RW010 | CVSS score must be 0-10 | ERROR | Clamp |
| RW011 | Severity must be valid | ERROR | No |
| RW012 | CVSS metrics must be valid | ERROR | No |
| RW013 | PoC type must be valid | ERROR | No |
| RW014 | PoC code max 64KB | ERROR | Truncate |
| RW015 | Dependencies max 20 | ERROR | Truncate |
| RW016 | Remediation priority must be valid | ERROR | No |
| RW017 | Remediation recommendations required | ERROR | No |
| RW018 | Recommendations max 20 | ERROR | Truncate |
| RW019 | References max 10 | ERROR | Truncate |
| RW020 | CVSS should match severity | WARNING | No |

---

## 11. Domain File References

All 54 files in `Report-Writing-Mastery/` that this validator covers:

| # | File | Report Type | Key Validation |
|---|------|-------------|----------------|
| 01 | `01-Report-Structure-Optimization.md` | structure_optimization | report |
| 02 | `02-Technical-Writing-Standards.md` | technical_writing | report |
| 03 | `03-Private-Program-Case-Study.md` | private_program_case | report |
| 04 | `04-Proof-of-Concept-Development.md` | poc_development | poc |
| 05 | `05-Vulnerability-Severity-Assessment.md` | severity_assessment | severity |
| 06 | `06-Remediation-Recommendations.md` | remediation_recommendations | remediation |
| 07 | `07-Executive-Summary-Crafting.md` | executive_summary | report |
| 08 | `08-Technical-Detail-Balancing.md` | technical_detail | report |
| 09 | `09-Visual-Aid-Integration.md` | visual_aid | report |
| 10 | `10-Code-Sample-Formatting.md` | code_sample | poc |
| 11 | `11-Timeline-Documentation.md` | timeline_documentation | report |
| 12 | `12-Collaboration-Crediting.md` | collaboration_crediting | report |
| 13 | `13-Program-Specific-Formatting.md` | program_formatting | report |
| 14 | `14-Language-and-Tone-Optimization.md` | language_tone | report |
| 15 | `15-Attachment-Management.md` | attachment_management | report |
| 16 | `16-Follow-up-Communication.md` | follow_up_communication | report |
| 17 | `17-Rejection-Analysis-and-Improvement.md` | rejection_analysis | report |
| 18 | `18-Reward-Negotiation-Preparation.md` | reward_negotiation | report |
| 19 | `19-Report-Template-Development.md` | report_template | report |
| 20 | `20-Quality-Assurance-Process.md` | quality_assurance | report |
| 21 | `21-Grammar-and-Style-Standards.md` | grammar_style | report |
| 22 | `22-Technical-Accuracy-Verification.md` | technical_accuracy | report |
| 23 | `23-Impact-Quantification.md` | impact_quantification | severity |
| 24 | `24-Business-Context-Integration.md` | business_context | report |
| 25 | `25-Compliance-Documentation.md` | compliance_documentation | report |
| 26 | `26-International-Standard-Adherence.md` | international_standard | report |
| 27 | `27-Audience-Analysis.md` | audience_analysis | report |
| 28 | `28-Information-Hierarchy.md` | information_hierarchy | report |
| 29 | `29-Actionable-Recommendations.md` | actionable_recommendations | remediation |
| 30 | `30-Report-Review-Process.md` | report_review | report |
| 31 | `31-Common-Pitfalls-Avoidance.md` | common_pitfalls | report |
| 32 | `32-Advanced-Formatting-Techniques.md` | advanced_formatting | report |
| 33 | `33-Multimedia-Integration.md` | multimedia_integration | report |
| 34 | `34-Interactive-Report-Elements.md` | interactive_elements | report |
| 35 | `35-Cross-Platform-Compatibility.md` | cross_platform | report |
| 36 | `36-Version-Control-for-Reports.md` | version_control | report |
| 37 | `37-Report-Analytics-and-Metrics.md` | report_analytics | report |
| 38 | `38-Peer-Review-Optimization.md` | peer_review | report |
| 39 | `39-Program-Feedback-Incorporation.md` | feedback_incorporation | report |
| 40 | `40-Continuous-Improvement.md` | continuous_improvement | report |
| 41 | `41-Report-Personalization.md` | report_personalization | report |
| 42 | `42-Contextual-Intelligence.md` | contextual_intelligence | report |
| 43 | `43-Technical-Depth-Calibration.md` | technical_depth | report |
| 44 | `44-Impact-Visualization.md` | impact_visualization | report |
| 45 | `45-Report-Archiving-Strategy.md` | report_archiving | report |
| 46 | `46-Collaboration-Report-Standards.md` | collaboration_standards | report |
| 47 | `47-Advanced-Proof-of-Concept.md` | advanced_poc | poc |
| 48 | `48-Report-Automation-Tools.md` | report_automation | report |
| 49 | `49-Quality-Metrics-Development.md` | quality_metrics | report |
| 50 | `50-Master-Report-Writing-Framework.md` | master_framework | report |
| 51 | `Bugcrowd-Finding-Dissection.md` | bugcrowd_dissection | report |
| 52 | `HackerOne-Report-Analysis.md` | hackerone_analysis | report |
| 53 | `High-Severity-Vulnerability-Analysis.md` | high_severity_analysis | severity |
| 54 | `Impact-Communication.md` | impact_communication | report |

---

## 12. Validation Pipeline

```python
def validate_report_writing_input(input_data):
    results = []
    results.append(("report_type", validate_report_type(input_data)))
    results.append(("report", validate_report_config(input_data)))
    results.append(("severity", validate_severity_config(input_data)))
    results.append(("poc", validate_poc_config(input_data)))
    results.append(("remediation", validate_remediation_config(input_data)))

    report = input_data.get("report", {})
    results.append(("completeness", ValidationResult(
        valid=True, errors=validate_report_completeness(report)
    )))

    severity = input_data.get("severity", {})
    results.append(("cvss_consistency", ValidationResult(
        valid=True, errors=validate_severity_cvss_consistency(severity)
    )))

    poc = input_data.get("poc", {})
    results.append(("poc_redaction", ValidationResult(
        valid=True, errors=validate_poc_redaction(poc)
    )))

    remediation = input_data.get("remediation", {})
    results.append(("remediation_actionability", ValidationResult(
        valid=True, errors=validate_remediation_actionability(remediation)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "report-writing-mastery", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Report validation runs before any report generation
- Completeness checks ensure all required fields are present
- CVSS-severity consistency checks detect scoring errors
- PoC redaction checks warn about unredacted sensitive data
- Remediation actionability checks ensure recommendations are specific
- All validation results are logged for report audit trail
- Type coercion normalizes severity and CVSS values
- Platform-specific formatting is applied after validation

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Report Writing Mastery domain |
