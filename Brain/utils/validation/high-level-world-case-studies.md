# High-Level World Case Studies — Schema Validation Reference

**Domain**: High-Level World Case Studies (Security Case Analysis)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define schema validation rules, type validation, range validation, pattern matching, custom validators, sanitization, coercion, and error handling for all case study analysis inputs across the High-Level-World-Case-Studies domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `high-level-world-case-studies` |
| Root Directory | `High-Level-World-Case-Studies/` |
| Total Files | 46 |
| Category | Case Analysis, Impact Assessment, Disclosure Timelines, Post-Mortems |
| Input Surface | Case data, timeline configs, impact metrics, analysis parameters |

---

## 2. Overview

The High-Level World Case Studies validator enforces strict schema validation for all case study analysis inputs. Each file defines a case study analysis — from critical infrastructure breaches to post-mortem analysis — and accepts structured inputs that must be validated for accurate and ethical analysis. This validator ensures:

- Case data is complete and well-structured
- Timeline data is chronologically consistent
- Impact metrics are within realistic ranges
- Disclosure timelines follow responsible disclosure practices
- Analysis parameters are appropriate for the case type
- All data is properly sourced and attributed

---

## 3. Schema Definition

### 3.1 Master Case Study Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CaseStudyInput",
  "type": "object",
  "required": ["domain", "case_type", "case_data"],
  "properties": {
    "domain": { "type": "string", "const": "high-level-world-case-studies" },
    "case_type": {
      "type": "string",
      "enum": [
        "critical_infrastructure", "zero_day", "chain_analysis",
        "real_world_impact", "timeline", "reward_analysis",
        "report_quality", "triage", "program_response",
        "disclosure", "collaboration", "industry_specific",
        "web_application", "mobile_app", "api_security",
        "cloud_config", "container_escape", "iot_device",
        "blockchain", "cryptocurrency", "social_engineering",
        "physical_security", "network_infrastructure", "database",
        "file_system", "authentication", "authorization",
        "session_management", "input_validation", "business_logic",
        "information_disclosure", "weak_cryptography", "insecure_communication",
        "third_party", "supply_chain", "zero_trust_bypass",
        "mfa_bypass", "privilege_escalation", "lateral_movement",
        "data_exfiltration", "persistence", "anti_forensic",
        "incident_response", "compliance_violation", "post_mortem"
      ]
    },
    "case_data": { "$ref": "#/definitions/CaseData" },
    "timeline": { "$ref": "#/definitions/TimelineConfig" },
    "impact": { "$ref": "#/definitions/ImpactMetrics" },
    "analysis": { "$ref": "#/definitions/AnalysisConfig" },
    "disclosure": { "$ref": "#/definitions/DisclosureConfig" }
  },
  "additionalProperties": false
}
```

### 3.2 CaseData Schema

```json
{
  "definitions": {
    "CaseData": {
      "type": "object",
      "required": ["title", "severity"],
      "properties": {
        "title": { "type": "string", "minLength": 1, "maxLength": 512 },
        "description": { "type": "string", "minLength": 1, "maxLength": 10000 },
        "severity": { "type": "string", "enum": ["info", "low", "medium", "high", "critical"] },
        "cvss_score": { "type": "number", "minimum": 0, "maximum": 10 },
        "cve_id": { "type": "string", "pattern": "^CVE-\\d{4}-\\d{4,}$" },
        "affected_systems": {
          "type": "array",
          "items": { "type": "string", "maxLength": 256 },
          "maxItems": 100
        },
        "industry": { "type": "string", "maxLength": 128 },
        "region": { "type": "string", "maxLength": 128 },
        "date_discovered": { "type": "string", "format": "date" },
        "date_disclosed": { "type": "string", "format": "date" },
        "reporter": { "type": "string", "maxLength": 256 },
        "program": { "type": "string", "maxLength": 256 },
        "payout_usd": { "type": "number", "minimum": 0, "maximum": 10000000 },
        "source_url": { "type": "string", "format": "uri" },
        "tags": { "type": "array", "items": { "type": "string" }, "maxItems": 20 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.3 TimelineConfig Schema

```json
{
  "definitions": {
    "TimelineConfig": {
      "type": "object",
      "properties": {
        "events": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["date", "event"],
            "properties": {
              "date": { "type": "string", "format": "date" },
              "event": { "type": "string", "minLength": 1, "maxLength": 512 },
              "actor": { "type": "string", "maxLength": 256 },
              "impact": { "type": "string", "enum": ["none", "low", "medium", "high", "critical"] }
            }
          },
          "maxItems": 100
        },
        "total_duration_days": { "type": "integer", "minimum": 0, "maximum": 3650 },
        "disclosure_window_days": { "type": "integer", "minimum": 0, "maximum": 365 }
      }
    }
  }
}
```

### 3.4 ImpactMetrics Schema

```json
{
  "definitions": {
    "ImpactMetrics": {
      "type": "object",
      "properties": {
        "financial_impact_usd": { "type": "number", "minimum": 0, "maximum": 10000000000 },
        "users_affected": { "type": "integer", "minimum": 0, "maximum": 1000000000 },
        "data_records_exposed": { "type": "integer", "minimum": 0, "maximum": 10000000000 },
        "system_downtime_hours": { "type": "number", "minimum": 0, "maximum": 8760 },
        "regulatory_fines_usd": { "type": "number", "minimum": 0, "maximum": 1000000000 },
        "reputation_score": { "type": "number", "minimum": 0, "maximum": 100 },
        "remediation_cost_usd": { "type": "number", "minimum": 0, "maximum": 1000000000 },
        "classification": { "type": "string", "enum": ["none", "confidential", "restricted", "top_secret"] }
      }
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
        "depth": { "type": "string", "enum": ["overview", "detailed", "comprehensive"], "default": "detailed" },
        "focus_areas": {
          "type": "array",
          "items": { "type": "string", "maxLength": 128 },
          "maxItems": 20
        },
        "comparison_cases": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 10
        },
        "include_code_samples": { "type": "boolean", "default": false },
        "include_remediation": { "type": "boolean", "default": true },
        "include_lessons_learned": { "type": "boolean", "default": true }
      }
    }
  }
}
```

### 3.6 DisclosureConfig Schema

```json
{
  "definitions": {
    "DisclosureConfig": {
      "type": "object",
      "properties": {
        "type": { "type": "string", "enum": ["responsible", "coordinated", "full", "partial", "none"], "default": "responsible" },
        "timeline_days": { "type": "integer", "minimum": 0, "maximum": 365, "default": 90 },
        "vendor_notified": { "type": "boolean", "default": false },
        "patch_available": { "type": "boolean", "default": false },
        "public_exploit": { "type": "boolean", "default": false },
        "mitigations_available": { "type": "boolean", "default": false }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateCaseData(input) → ValidationResult

```python
def validate_case_data(input_data):
    errors = []
    case = input_data.get("case_data", {})

    if not case.get("title"):
        errors.append(ValidationError("CASE_TITLE_EMPTY", "Case title is required"))
    if len(case.get("title", "")) > 512:
        errors.append(ValidationError("CASE_TITLE_TOO_LONG", "Title exceeds 512 characters"))
    if not case.get("description"):
        errors.append(ValidationError("CASE_DESC_EMPTY", "Case description is required"))
    if len(case.get("description", "")) > 10000:
        errors.append(ValidationError("CASE_DESC_TOO_LONG", "Description exceeds 10000 characters"))

    cvss = case.get("cvss_score")
    if cvss is not None:
        if not (0 <= cvss <= 10):
            errors.append(ValidationError("CVSS_OUT_OF_RANGE", f"CVSS score {cvss} out of range 0-10"))
        severity = case.get("severity", "")
        if severity == "critical" and cvss < 9.0:
            errors.append(ValidationError("CVSS_SEVERITY_MISMATCH", "Critical severity requires CVSS >= 9.0"))

    cve = case.get("cve_id", "")
    if cve and not re.match(r'^CVE-\d{4}-\d{4,}$', cve):
        errors.append(ValidationError("INVALID_CVE", f"Invalid CVE format: {cve}"))

    if case.get("date_discovered") and case.get("date_disclosed"):
        if case["date_disclosed"] < case["date_discovered"]:
            errors.append(ValidationError("DISCLOSURE_BEFORE_DISCOVERY", "Disclosure date before discovery date"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateTimeline(input) → list

```python
def validate_timeline(input_data):
    errors = []
    timeline = input_data.get("timeline", {})
    events = timeline.get("events", [])

    dates = [e.get("date", "") for e in events]
    if dates != sorted(dates):
        errors.append(ValidationError("TIMELINE_NOT_SORTED", "Timeline events must be in chronological order"))

    for i, event in enumerate(events):
        if not event.get("event"):
            errors.append(ValidationError("EVENT_EMPTY", f"Event at index {i} has no description"))

    return errors
```

### 4.3 validateImpactMetrics(input) → list

```python
def validate_impact_metrics(input_data):
    errors = []
    impact = input_data.get("impact", {})
    if not impact:
        return errors

    if impact.get("users_affected", 0) > 0 and impact.get("financial_impact_usd", 0) == 0:
        errors.append(ValidationError(
            "IMPACT_MISMATCH",
            "Users affected but no financial impact recorded"
        ))

    if impact.get("system_downtime_hours", 0) > 720:
        errors.append(ValidationError(
            "EXCESSIVE_DOWNTIME",
            "System downtime exceeds 30 days"
        ))

    return errors
```

---

## 5. Sanitize Operations

### 5.1 sanitizeCaseTitle(title) → string

```python
def sanitize_case_title(title):
    title = re.sub(r'[<>"\';\\]', '', title)
    return title[:512]
```

### 5.2 sanitizeCaseDescription(desc) → string

```python
def sanitize_case_description(desc):
    desc = re.sub(r'<script[^>]*>.*?</script>', '', desc, flags=re.DOTALL)
    desc = re.sub(r'[<>"\';\\]', '', desc)
    return desc[:10000]
```

---

## 6. Type Coercion

### 6.1 coerceCaseType(raw_value) → string

```python
def coerce_case_type(raw_value):
    raw_value = str(raw_value).lower().strip().replace(" ", "_").replace("-", "_")
    type_map = {
        "infra": "critical_infrastructure", "infrastructure": "critical_infrastructure",
        "zero": "zero_day", "zeroday": "zero_day",
        "chain": "chain_analysis", "chaining": "chain_analysis",
        "impact": "real_world_impact", "timeline": "timeline",
        "reward": "reward_analysis", "report": "report_quality",
        "triage": "triage", "response": "program_response",
        "disclosure": "disclosure", "collab": "collaboration",
        "industry": "industry_specific", "web": "web_application",
        "mobile": "mobile_app", "api": "api_security",
        "cloud": "cloud_config", "container": "container_escape",
        "iot": "iot_device", "blockchain": "blockchain",
        "crypto": "cryptocurrency", "social": "social_engineering",
        "physical": "physical_security", "network": "network_infrastructure",
        "database": "database", "file": "file_system",
        "auth": "authentication", "authz": "authorization",
        "session": "session_management", "input": "input_validation",
        "logic": "business_logic", "info": "information_disclosure",
        "crypto_weak": "weak_cryptography", "tls": "insecure_communication",
        "third": "third_party", "supply": "supply_chain",
        "zt": "zero_trust_bypass", "mfa": "mfa_bypass",
        "privesc": "privilege_escalation", "lateral": "lateral_movement",
        "exfil": "data_exfiltration", "persist": "persistence",
        "forensic": "anti_forensic", "ir": "incident_response",
        "compliance": "compliance_violation", "postmortem": "post_mortem"
    }
    return type_map.get(raw_value, raw_value)
```

---

## 7. Custom Validators

### 7.1 validateDisclosureEthics(disclosure, case_data) → list

```python
def validate_disclosure_ethics(disclosure, case_data):
    errors = []
    if disclosure.get("public_exploit") and not disclosure.get("patch_available"):
        errors.append(ValidationError(
            "EXPLOIT_BEFORE_PATCH",
            "Public exploit released before patch availability"
        ))

    if disclosure.get("type") == "responsible":
        if not disclosure.get("vendor_notified"):
            errors.append(ValidationError(
                "NO_VENDOR_NOTIFICATION",
                "Responsible disclosure requires vendor notification"
            ))

    return errors
```

### 7.2 validateCaseConsistency(case_data, timeline, impact) → list

```python
def validate_case_consistency(case_data, timeline, impact):
    errors = []
    severity = case_data.get("severity", "")
    impact_score = 0

    if impact:
        if impact.get("financial_impact_usd", 0) > 1000000:
            impact_score += 3
        if impact.get("users_affected", 0) > 100000:
            impact_score += 2
        if impact.get("data_records_exposed", 0) > 1000000:
            impact_score += 2

    if severity == "critical" and impact_score < 2:
        errors.append(ValidationError(
            "SEVERITY_IMPACT_MISMATCH",
            "Critical severity not supported by impact metrics"
        ))

    if severity == "info" and impact_score > 4:
        errors.append(ValidationError(
            "LOW_SEVERITY_HIGH_IMPACT",
            "Info severity contradicts high impact metrics"
        ))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `CASE_TITLE_EMPTY` | ERROR | Case title is required |
| `CASE_TITLE_TOO_LONG` | ERROR | Title exceeds 512 characters |
| `CASE_DESC_EMPTY` | ERROR | Case description is required |
| `CASE_DESC_TOO_LONG` | ERROR | Description exceeds 10000 characters |
| `CVSS_OUT_OF_RANGE` | ERROR | CVSS score out of range 0-10 |
| `CVSS_SEVERITY_MISMATCH` | WARNING | CVSS score inconsistent with severity |
| `INVALID_CVE` | ERROR | CVE format is invalid |
| `DISCLOSURE_BEFORE_DISCOVERY` | ERROR | Disclosure before discovery date |
| `TIMELINE_NOT_SORTED` | ERROR | Timeline events not chronological |
| `EVENT_EMPTY` | ERROR | Timeline event has no description |
| `IMPACT_MISMATCH` | WARNING | Users affected but no financial impact |
| `EXCESSIVE_DOWNTIME` | WARNING | Downtime exceeds 30 days |
| `EXPLOIT_BEFORE_PATCH` | ERROR | Exploit before patch available |
| `NO_VENDOR_NOTIFICATION` | ERROR | Responsible disclosure requires vendor notification |
| `SEVERITY_IMPACT_MISMATCH` | WARNING | Severity not supported by impact |
| `LOW_SEVERITY_HIGH_IMPACT` | WARNING | Info severity contradicts high impact |

---

## 9. Error Messages

```python
ERROR_MESSAGES = {
    "CASE_TITLE_EMPTY": "Case title is required for identification.",
    "CASE_TITLE_TOO_LONG": "Case title must be 512 characters or fewer.",
    "CASE_DESC_EMPTY": "Case description is required for analysis.",
    "CASE_DESC_TOO_LONG": "Case description must be 10000 characters or fewer.",
    "CVSS_OUT_OF_RANGE": "CVSS score must be between 0 and 10.",
    "CVSS_SEVERITY_MISMATCH": "CVSS score is inconsistent with the assigned severity.",
    "INVALID_CVE": "CVE ID format is invalid. Expected: CVE-YYYY-NNNNN+",
    "DISCLOSURE_BEFORE_DISCOVERY": "Disclosure date cannot precede discovery date.",
    "TIMELINE_NOT_SORTED": "Timeline events must be in chronological order.",
    "EVENT_EMPTY": "Each timeline event must have a description.",
    "IMPACT_MISMATCH": "Impact metrics are inconsistent.",
    "EXCESSIVE_DOWNTIME": "System downtime exceeds 30 days.",
    "EXPLOIT_BEFORE_PATCH": "Public exploit released before patch availability.",
    "NO_VENDOR_NOTIFICATION": "Responsible disclosure requires vendor notification.",
    "SEVERITY_IMPACT_MISMATCH": "Severity level is not supported by impact metrics.",
    "LOW_SEVERITY_HIGH_IMPACT": "Info severity contradicts high impact metrics.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| R001 | Case title must not be empty | ERROR | No |
| R002 | Case description must not be empty | ERROR | No |
| R003 | CVSS score must be 0-10 | ERROR | Clamp |
| R004 | CVE ID must match pattern | ERROR | No |
| R005 | Disclosure date >= discovery date | ERROR | No |
| R006 | Timeline must be chronological | ERROR | Sort |
| R007 | Responsible disclosure requires vendor notification | ERROR | No |
| R008 | Exploit before patch is flagged | ERROR | No |
| R009 | Severity must match impact metrics | WARNING | No |
| R010 | Downtime <= 30 days flagged | WARNING | No |

---

## 11. Domain File References

All 46 files in `High-Level-World-Case-Studies/` that this validator covers:

| # | File | Case Profile |
|---|------|--------------|
| 05 | `05-Critical-Infrastructure-Breach.md` | case_type: critical_infrastructure |
| 06 | `06-Zero-Day-Exploitation-Case.md` | case_type: zero_day |
| 07 | `07-Chain-of-Vulnerabilities.md` | case_type: chain_analysis |
| 08 | `08-Real-World-Impact-Assessment.md` | case_type: real_world_impact |
| 09 | `09-Timeline-from-Discovery-to-Fix.md` | case_type: timeline |
| 10 | `10-Reward-Maximization-Strategies.md` | case_type: reward_analysis |
| 11 | `11-Report-Quality-Analysis.md` | case_type: report_quality |
| 12 | `12-Triage-Process-Understanding.md` | case_type: triage |
| 13 | `13-Program-Response-Analysis.md` | case_type: program_response |
| 14 | `14-Disclosure-Timeline-Study.md` | case_type: disclosure |
| 15 | `15-Collaborative-Hunting-Case.md` | case_type: collaboration |
| 16 | `16-Cross-Program-Vulnerability-Patterns.md` | case_type: industry_specific |
| 17 | `17-Industry-Specific-Findings.md` | case_type: industry_specific |
| 18 | `18-Mobile-App-Vulnerability-Case.md` | case_type: mobile_app |
| 19 | `19-Web-Application-Security-Case.md` | case_type: web_application |
| 20 | `20-API-Security-Breach-Analysis.md` | case_type: api_security |
| 21 | `21-Cloud-Configuration-Error.md` | case_type: cloud_config |
| 22 | `22-Container-Escape-Case-Study.md` | case_type: container_escape |
| 23 | `23-IoT-Device-Compromise.md` | case_type: iot_device |
| 24 | `24-Blockchain-Smart-Contract-Bug.md` | case_type: blockchain |
| 25 | `25-Cryptocurrency-Exchange-Hack.md` | case_type: cryptocurrency |
| 26 | `26-Social-Engineering-Success.md` | case_type: social_engineering |
| 27 | `27-Physical-Security-Bypass.md` | case_type: physical_security |
| 28 | `28-Network-Infrastructure-Attack.md` | case_type: network_infrastructure |
| 29 | `29-Database-Compromise-Case.md` | case_type: database |
| 30 | `30-File-System-Attack-Analysis.md` | case_type: file_system |
| 31 | `31-Authentication-Bypass-Case.md` | case_type: authentication |
| 32 | `32-Authorization-Flaw-Study.md` | case_type: authorization |
| 33 | `33-Session-Management-Issue.md` | case_type: session_management |
| 34 | `34-Input-Validation-Failure.md` | case_type: input_validation |
| 35 | `35-Business-Logic-Flaw-Analysis.md` | case_type: business_logic |
| 36 | `36-Information-Disclosure-Case.md` | case_type: information_disclosure |
| 37 | `37-Weak-Cryptography-Example.md` | case_type: weak_cryptography |
| 38 | `38-Insecure-Communication-Study.md` | case_type: insecure_communication |
| 39 | `39-Third-Party-Component-Vulnerability.md` | case_type: third_party |
| 40 | `40-Supply-Chain-Attack-Case.md` | case_type: supply_chain |
| 41 | `41-Zero-Trust-Bypass-Analysis.md` | case_type: zero_trust_bypass |
| 42 | `42-Multi-Factor-Authentication-Bypass.md` | case_type: mfa_bypass |
| 43 | `43-Privilege-Escalation-Case.md` | case_type: privilege_escalation |
| 44 | `44-Lateral-Movement-Study.md` | case_type: lateral_movement |
| 45 | `45-Data-Exfiltration-Method.md` | case_type: data_exfiltration |
| 46 | `46-Persistence-Mechanism-Analysis.md` | case_type: persistence |
| 47 | `47-Anti-Forensic-Technique-Study.md` | case_type: anti_forensic |
| 48 | `48-Incident-Response-Failure.md` | case_type: incident_response |
| 49 | `49-Compliance-Violation-Case.md` | case_type: compliance_violation |
| 50 | `50-Post-Mortem-Analysis.md` | case_type: post_mortem |

---

## 12. Validation Pipeline

```python
def validate_case_study_input(input_data):
    results = []
    results.append(("case_data", validate_case_data(input_data)))
    results.append(("timeline", validate_timeline(input_data)))
    results.append(("impact", validate_impact_metrics(input_data)))

    disclosure = input_data.get("disclosure", {})
    case_data = input_data.get("case_data", {})
    if disclosure:
        results.append(("disclosure", validate_disclosure_ethics(disclosure, case_data)))

    timeline = input_data.get("timeline", {})
    impact = input_data.get("impact", {})
    results.append(("consistency", validate_case_consistency(case_data, timeline, impact)))

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

- Case data validation ensures completeness for analysis
- Timeline validation enforces chronological consistency
- Impact metrics are validated for realism
- Disclosure ethics checks enforce responsible practices
- Severity/impact consistency is verified
- All results are logged for case study analytics
- CVE IDs are validated against NVD patterns

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial schema validation reference for High-Level World Case Studies domain |
