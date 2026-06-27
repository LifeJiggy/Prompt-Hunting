# Helpers: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Overview

Helper functions for reconnaissance — asset deduplication, technology fingerprinting, DNS resolution, and live host verification.

## AssetDeduplicator

```python
class AssetDeduplicator:
    def __init__(self):
        self.seen = {}

    def add(self, asset):
        key = asset["address"]
        if key in self.seen:
            existing = self.seen[key]
            existing["sources"] = list(set(existing.get("sources", []) + asset.get("sources", [])))
            return False
        self.seen[key] = asset
        return True

    def get_unique(self):
        return list(self.seen.values())
```

## TechFingerprint

```python
class TechFingerprint:
    @staticmethod
    def from_headers(headers):
        techs = []
        if "server" in headers:
            techs.append(headers["server"])
        if "x-powered-by" in headers:
            techs.append(headers["x-powered-by"])
        if "x-generator" in headers:
            techs.append(headers["x-generator"])
        return techs

    @staticmethod
    def from_body(body):
        indicators = {
            "WordPress": "wp-content", "Drupal": "drupal", "Joomla": "joomla",
            "React": "react", "Angular": "ng-app", "Vue": "vue.js"
        }
        found = []
        for tech, marker in indicators.items():
            if marker in body.lower():
                found.append(tech)
        return found
```

## DNSResolver

```python
class DNSResolver:
    @staticmethod
    def resolve(domain):
        import dns.resolver
        results = {}
        for rtype in ["A", "AAAA", "CNAME", "MX", "NS", "TXT"]:
            try:
                answers = dns.resolver.resolve(domain, rtype)
                results[rtype] = [str(r) for r in answers]
            except:
                results[rtype] = []
        return results
```

## Domain File References

All 50 files in `Reconnaissance-Deep-Dive/` use asset deduplication, tech fingerprinting, and DNS resolution helpers.
