# Scheduling: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Task Scheduling Configuration

How disclosed report analyses are scheduled — vuln-class matching, pattern database updates, and hunt prompt generation.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Vuln Class Match** | Current hunting matches class | Load relevant disclosed reports |
| **Pattern Derivation** | After analysis complete | Extract and store pattern |
| **Hunt Prompt Gen** | Pattern validated | Auto-generate hunt prompt |
| **Bounty Correlation** | Bounty data available | Weight by bounty amount |

## Queue Configuration

```yaml
scheduling:
  queue_type: "class_weighted"
  vuln_class_matching: true
  auto_pattern_derivation: true
  auto_hunt_prompt_generation: true
  bounty_weighting: true
```

## Schedule Files Reference

Scheduling rules apply to all 50 files in `Real-World-Case-Studies/` — disclosed reports are loaded based on current hunting context.
