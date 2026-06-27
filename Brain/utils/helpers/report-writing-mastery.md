# Helpers: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Overview

Helper functions for report writing — CVSS calculation, format adaptation, evidence annotation, and report diff comparison.

## CVSSCalculator

```python
class CVSSCalculator:
    @staticmethod
    def calculate(vector_string):
        """Calculate CVSS 3.1 score from vector string."""
        weights = {
            "AV:N": 0.85, "AV:A": 0.62, "AV:L": 0.55, "AV:P": 0.20,
            "AC:L": 0.77, "AC:H": 0.44,
            "PR:N": 0.85, "PR:L": 0.62, "PR:H": 0.27,
            "UI:N": 0.85, "UI:R": 0.62,
            "S:U": 1.0, "S:C": 1.08,
            "C:N": 0.0, "C:L": 0.22, "C:H": 0.56,
            "I:N": 0.0, "I:L": 0.22, "I:H": 0.56,
            "A:N": 0.0, "A:L": 0.22, "A:H": 0.56
        }
        parts = vector_string.split("/")
        score = sum(weights.get(p, 0) for p in parts)
        return min(round(score * 10, 1), 10.0)
```

## FormatAdapter

```python
class FormatAdapter:
    @staticmethod
    def to_hackerone(report):
        return f"""## Summary
{report['summary']}

## Steps to Reproduce
{chr(10).join(f'{i+1}. {s}' for i, s in enumerate(report['steps']))}

## Impact
{report['impact']}

## Remediation
{report['remediation']}
"""

    @staticmethod
    def to_bugcrowd(report):
        return f"""## Description
{report['description']}

## Impact
{report['impact']}

## Vulnerability Details
{report['steps'][0] if report['steps'] else 'N/A'}
"""
```

## ReportDiffer

```python
class ReportDiffer:
    @staticmethod
    def compare(old_report, new_report):
        changes = {}
        for key in old_report:
            if old_report[key] != new_report.get(key):
                changes[key] = {"old": old_report[key], "new": new_report.get(key)}
        return changes
```

## Domain File References

All 54 files in `Report-Writing-Mastery/` use CVSS calculation, format adaptation, and report comparison helpers.
