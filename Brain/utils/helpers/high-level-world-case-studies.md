# Helpers: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Overview

Helper functions for case study analysis — MITRE ATT&CK mapping, timeline reconstruction, pattern similarity scoring, and impact quantification.

## MITREMapper

```python
class MITREMapper:
    TECHNIQUE_MAP = {
        "phishing": "T1566", "lateral_movement": "T1021",
        "privilege_escalation": "T1068", "ransomware": "T1486",
        "credential_dumping": "T1003", "persistence": "T1053"
    }

    @staticmethod
    def map_technique(technique_name):
        return MITREMapper.TECHNIQUE_MAP.get(technique_name.lower(), "T0000")

    @staticmethod
    def map_tactics(techniques):
        tactics = set()
        for t in techniques:
            tactic = t.split("_")[0] if "_" in t else t
            tactics.add(tactic)
        return list(tactics)
```

## TimelineReconstructor

```python
class TimelineReconstructor:
    def __init__(self):
        self.events = []

    def add_event(self, timestamp, event_type, description):
        self.events.append({"time": timestamp, "type": event_type, "desc": description})

    def get_timeline(self):
        return sorted(self.events, key=lambda x: x["time"])

    def duration(self):
        timeline = self.get_timeline()
        if len(timeline) < 2:
            return 0
        return (timeline[-1]["time"] - timeline[0]["time"]).total_seconds()
```

## PatternSimilarity

```python
class PatternSimilarity:
    @staticmethod
    def calculate(pattern_a, pattern_b):
        common = set(pattern_a.get("techniques", [])) & set(pattern_b.get("techniques", []))
        total = set(pattern_a.get("techniques", [])) | set(pattern_b.get("techniques", []))
        if not total:
            return 0.0
        return len(common) / len(total)
```

## Domain File References

All 46 files in `High-Level-World-Case-Studies/` use MITRE mapping, timeline reconstruction, and similarity scoring helpers.
