# Scheduling: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Task Scheduling Configuration

How category-specific tests are scheduled — methodology loading, tool deployment, and compliance-mapped execution.

## Scheduling Rules

| Rule | Condition | Action |
|------|-----------|--------|
| **Category Detection** | Target identified | Load category plan |
| **Tool Setup** | Before testing | Deploy category tools |
| **Sequential Tests** | Category-specific | One test type at a time |
| **Compliance Gate** | After testing | Map to regulatory framework |
| **Safety Check** | ICS/SCADA targets | Verify safety before testing |

## Queue Configuration

```yaml
scheduling:
  queue_type: "category_aware"
  auto_category_detection: true
  tool_deployment_before_test: true
  sequential_per_category: true
  compliance_mapping_after_test: true
  safety_check_for_ics: true
```

## Schedule Files Reference

Scheduling rules apply to all 50 files in `Specialized-Targets/` — each category has specific scheduling constraints.
