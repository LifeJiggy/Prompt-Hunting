# Helpers: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Overview

Helper functions for vulnerability hunting — payload generation, response analysis, WAF detection, and finding classification.

## PayloadGenerator

```python
class PayloadGenerator:
    XSS_PAYLOADS = ['<script>alert(1)</script>', '"><img src=x onerror=alert(1)>', "' OR '1'='1"]
    SQLI_PAYLOADS = ["' OR 1=1--", "1; DROP TABLE--", "' UNION SELECT NULL--"]

    @staticmethod
    def for_class(vuln_class, context=None):
        if vuln_class == "xss":
            return PayloadGenerator.XSS_PAYLOADS
        elif vuln_class == "sqli":
            return PayloadGenerator.SQLI_PAYLOADS
        return []
```

## ResponseAnalyzer

```python
class ResponseAnalyzer:
    @staticmethod
    def is_vulnerable(response, vuln_class):
        if vuln_class == "xss":
            return "<script>" in response.text or "onerror=" in response.text
        elif vuln_class == "sqli":
            return "sql" in response.text.lower() or "syntax" in response.text.lower()
        return False

    @staticmethod
    def detect_waf(response):
        waf_headers = ["x-cdn", "x-firewall", "cf-ray", "x-sucuri"]
        for header in response.headers:
            if any(w in header.lower() for w in waf_headers):
                return True
        return False
```

## FindingClassifier

```python
class FindingClassifier:
    @staticmethod
    def classify(finding):
        severity_map = {
            "rce": "critical", "sqli": "critical", "auth_bypass": "critical",
            "xss_stored": "high", "ssrf": "high", "idor": "high",
            "xss_reflected": "medium", "csrf": "medium", "info_disclosure": "low"
        }
        return severity_map.get(finding["type"], "info")
```

## Domain File References

All 50 files in `Core-Prompts-hunting/` use payload generation, response analysis, and finding classification helpers.
