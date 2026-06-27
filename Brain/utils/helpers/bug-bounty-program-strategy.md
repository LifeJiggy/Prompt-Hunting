# Helpers: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Overview

Helper functions for program strategy — time tracking, ROI calculation, bounty normalization, and program scoring.

## TimeTracker

```python
class TimeTracker:
    def __init__(self):
        self.sessions = []

    def start(self, program_id):
        self.sessions.append({"program_id": program_id, "start": time.time()})

    def stop(self, program_id):
        for s in reversed(self.sessions):
            if s["program_id"] == program_id and "end" not in s:
                s["end"] = time.time()
                return s["end"] - s["start"]
        return 0

    def total_hours(self, program_id=None):
        total = sum(s.get("end", time.time()) - s["start"] for s in self.sessions if not program_id or s["program_id"] == program_id)
        return total / 3600
```

## ROICalculator

```python
class ROICalculator:
    @staticmethod
    def calculate(bounty_usd, hours_spent):
        if hours_spent == 0:
            return float('inf')
        return bounty_usd / hours_spent

    @staticmethod
    def monthly_roi(bounties, hours):
        return sum(bounties) / max(sum(hours), 1)
```

## BountyNormalizer

```python
class BountyNormalizer:
    CURRENCY_RATES = {"USD": 1.0, "EUR": 0.92, "GBP": 0.79, "BTC": 0.000024}

    @staticmethod
    def to_usd(amount, currency):
        rate = BountyNormalizer.CURRENCY_RATES.get(currency, 1.0)
        return amount / rate
```

## Domain File References

All 50 files in `Bug-Bounty-Program-Strategy/` use time tracking, ROI calculation, and bounty normalization helpers.
