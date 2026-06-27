# Helpers: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Overview

Helper functions for disclosed report analysis — pattern extraction, bounty correlation, technique validation, and hunt prompt generation.

## PatternExtractor

```python
class PatternExtractor:
    @staticmethod
    def extract_from_report(report):
        return {
            "vuln_class": report.get("vuln_type"),
            "technique": report.get("exploitation_method"),
            "endpoint_pattern": report.get("endpoint_regex"),
            "bounty": report.get("bounty_usd"),
            "platform": report.get("platform")
        }
```

## BountyCorrelator

```python
class BountyCorrelator:
    @staticmethod
    def correlate(patterns):
        by_class = {}
        for p in patterns:
            vc = p["vuln_class"]
            if vc not in by_class:
                by_class[vc] = {"bounties": [], "count": 0}
            by_class[vc]["bounties"].append(p.get("bounty", 0))
            by_class[vc]["count"] += 1
        for vc in by_class:
            bounties = by_class[vc]["bounties"]
            by_class[vc]["avg_bounty"] = sum(bounties) / len(bounties) if bounties else 0
            by_class[vc]["max_bounty"] = max(bounties) if bounties else 0
        return by_class
```

## HuntPromptGenerator

```python
class HuntPromptGenerator:
    @staticmethod
    def generate(pattern):
        return f"""Hunting Prompt for {pattern['vuln_class']}:

Target: {{target}}
Technique: {pattern['technique']}
Endpoint Pattern: {pattern.get('endpoint_pattern', 'N/A')}
Expected Severity: {pattern.get('severity', 'medium')}

Steps:
1. Enumerate endpoints matching pattern
2. Test with technique: {pattern['technique']}
3. Validate finding
4. Document with PoC
"""
```

## Domain File References

All 50 files in `Real-World-Case-Studies/` use pattern extraction, bounty correlation, and hunt prompt generation helpers.
