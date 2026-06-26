# Events: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Event Definitions

Events for disclosed report analysis — tracking pattern extraction from 50 real-world vulnerability findings across HackerOne, Bugcrowd, and Intigriti.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `disclosed.study.selected` | `{case_id, vuln_class, platform}` | Disclosed report chosen |
| `disclosed.study.analyzed` | `{case_id, root_cause, exploitation}` | Analysis completed |
| `disclosed.pattern.derived` | `{pattern_id, vuln_class, technique}` | Hunting pattern extracted |
| `disclosed.pattern.validated` | `{pattern_id, test_results, confidence}` | Pattern confirmed working |
| `disclosed.severity.noted` | `{case_id, cvss, bounty}` | Severity/bounty recorded |
| `disclosed.bypass.documented` | `{case_id, defense, bypass}` | WAF/control bypass noted |
| `disclosed.methodology.mapped` | `{case_id, methodology_id}` | Linked to hunting methodology |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `hunt.vuln.confirmed` | Hunting | Cross-reference with disclosed findings |
| `support.vuln_pattern.detected` | Support | Validate against real reports |

## Event Flow

```
hunt.vuln.confirmed
        │
        ▼
disclosed.study.selected (matching vuln class)
        │
        ▼
disclosed.study.analyzed
        │
   ┌────┴────┐
   │         │
pattern.derived  severity.noted
   │         │
   ▼         ▼
pattern.validated  bypass.documented
   │
   ▼
methodology.mapped
```
