# Helpers: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Overview

Helper functions for vulnerability chaining — chain graph traversal, primitive dependency resolution, impact calculation, and chain serialization.

## ChainGraph

```python
class ChainGraph:
    def __init__(self):
        self.nodes = {}  # primitive_id -> vuln_data
        self.edges = {}  # primitive_id -> [dependent_ids]

    def add_primitive(self, primitive_id, vuln_data):
        self.nodes[primitive_id] = vuln_data
        self.edges[primitive_id] = []

    def add_dependency(self, source, target):
        self.edges[source].append(target)

    def find_shortest_chain(self, start, impact_target):
        """BFS to find shortest chain from start primitive to impact."""
        queue = [(start, [start])]
        visited = {start}
        while queue:
            current, path = queue.pop(0)
            if self._meets_impact(current, impact_target):
                return path
            for neighbor in self.edges.get(current, []):
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append((neighbor, path + [neighbor]))
        return None
```

## ImpactCalculator

```python
def calculate_chain_severity(primitives):
    """Calculate amplified severity from chain primitives."""
    base_severities = {"info": 0, "low": 1, "medium": 2, "high": 3, "critical": 4}
    max_severity = max(base_severities.get(p["severity"], 0) for p in primitives)
    amplification = min(len(primitives) * 0.5, 2.0)
    amplified = min(max_severity + amplification, 4)
    return [k for k, v in base_severities.items() if v == round(amplified)][0]
```

## Domain File References

All 49 files in `Advanced-Chaining-Techniques/` use chain graph traversal, impact calculation, and dependency resolution helpers.
