# State Persistence: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Overview

State persistence for high-level case study analysis stores the long-lived analysis state across the multi-step case study workflow. Case analyses involve gathering sources, reconstructing timelines, extracting TTPs, mapping to MITRE ATT&CK, and generating defensive recommendations. This state must persist across session interruptions.

## Persistence Schema

```yaml
case_analysis_persistence:
  session_id: "cses_{uuid}"
  case_id: "case_05"
  storage_format: "json"
  storage_backend: "filesystem"
  storage_path: "./brain_sessions/case_analysis_{session_id}.json"

  # Persisted State
  state:
    sources_gathered: ["report_1.pdf", "news_article.html", "court_filing.pdf"]
    timeline_stages: 8
    timeline_complete: true
    ttps_extracted: 12
    mitre_mappings: 15
    impact_assessment: { financial: "$4.4M", users: "millions", downtime: "6 days" }
    defenses_generated: 8

  # Persistence Triggers
  triggers:
    - event: "source_gathered"
      action: "save_incremental"
    - event: "stage_completed"
      action: "save_checkpoint"
    - event: "session_suspend"
      action: "save_full"
```

## Operations

```python
def save_case_state(persistence, session):
    """Persist case analysis state."""
    state = {
        "sources": session.sources,
        "timeline": session.timeline,
        "ttps": session.ttps,
        "mitre": session.mitre_mappings,
        "impact": session.impact,
        "defenses": session.defenses
    }
    persistence.write(session.storage_path, state, format="json")

def restore_case_state(persistence, session_id):
    """Restore case analysis from persistence."""
    path = f"./brain_sessions/case_analysis_{session_id}.json"
    return persistence.read(path, format="json")
```

## Domain File References

All 46 files in `High-Level-World-Case-Studies/` persist analysis state:
- Critical Infrastructure (05, 21-23, 28-29): Incident analysis state
- Vulnerability Research (06-07): Zero-day and chain analysis state
- Impact/Timeline (08-09, 14, 50): Assessment and timeline state
- Program Dynamics (10-13, 15-16): Strategy analysis state
- Industry (17-20, 24-25): Sector-specific analysis state
- Attack Techniques (26-27, 30-38): Technique analysis state
- Advanced (39-49): Complex attack analysis state
