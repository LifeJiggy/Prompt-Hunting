# Events: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Event Definitions

Events for major incident analysis — tracking case study selection, pattern extraction, and defensive recommendation generation.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `casestudy.selected` | `{case_id, category, target_similarity}` | Case study chosen |
| `casestudy.analyzed` | `{case_id, attack_vector, impact}` | Analysis completed |
| `casestudy.pattern.extracted` | `{pattern_id, technique, applicability}` | TTP extracted |
| `casestudy.pattern.applied` | `{pattern_id, target, match_score}` | Pattern matched to target |
| `casestudy.lesson.learned` | `{lesson_id, category, severity}` | Key takeaway identified |
| `casestudy.defense.recommended` | `{defense_id, technique, priority}` | Defensive measure suggested |
| `casestudy.mitre.mapped` | `{case_id, tactic, technique_id}` | MITRE ATT&CK mapping |
| `casestudy.timeline.reconstructed` | `{case_id, stages[], duration}` | Attack timeline built |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `hunt.vuln.confirmed` | Hunting | Find similar historical incidents |
| `chain.impact.confirmed` | Chaining | Map to known breach patterns |

## Event Flow

```
hunt.vuln.confirmed
        │
        ▼
casestudy.selected (based on vuln type)
        │
        ▼
casestudy.analyzed
        │
   ┌────┴────┐
   │         │
pattern.extracted  lesson.learned
   │         │
   ▼         ▼
pattern.applied  defense.recommended
   │
   ▼
mitre.mapped
```
