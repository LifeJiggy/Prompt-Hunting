# Events: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Event Definitions

Events for the foundational support framework — master prompts, vulnerability detection guidance, and reporting templates used across all hunting operations.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `support.framework.loaded` | `{framework_id, version}` | Master framework loaded |
| `support.framework.updated` | `{framework_id, old_version, new_version}` | Framework revised |
| `support.vuln_pattern.detected` | `{pattern_id, vuln_class, confidence}` | Vulnerability pattern matched |
| `support.template.applied` | `{template_id, target, vuln_type}` | Report template applied |
| `support.scope.analyzed` | `{program_id, scope_definition, assets}` | Program scope parsed |
| `support.methodology.suggested` | `{methodology_id, target_profile}` | Recommended approach |
| `support.tool.recommended` | `{tool_name, purpose, target_type}` | Tool suggestion |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `recon.asset.discovered` | Reconnaissance | Match against known patterns |
| `automation.finding.discovered` | Automation | Classify finding type |
| `report.submitted` | Report Writing | Update template effectiveness |

## Event Flow

```
recon.asset.discovered
        │
        ▼
support.scope.analyzed
        │
        ▼
support.methodology.suggested
        │
        ▼
support.tool.recommended
        │
        ▼
automation.finding.discovered
        │
        ▼
support.vuln_pattern.detected
        │
        ▼
support.template.applied
```
