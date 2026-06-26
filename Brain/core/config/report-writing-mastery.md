# Config: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Configuration Schema

Configuration for report creation, quality assurance, and platform-specific formatting.

```yaml
reporting:
  # Report Structure
  structure:
    required_sections: ["title", "summary", "severity", "description", "impact", "steps", "remediation", "poc"]
    max_title_length: 80
    summary_length: "2-4 sentences"
    numbered_steps: true

  # Severity Assessment
  severity:
    model: "cvss_3.1"
    auto_score: true
    require_justification: true
    comparable_references: true
    prevent_downgrade: true

  # Quality Assurance
  qa:
    pre_submit_checklist: true
    grammar_check: true
    technical_accuracy_check: true
    peer_review: false
    max_revisions: 3

  # Platform Formatting
  platforms:
    hackerone:
      template: "hackerone_standard"
      vrt_alignment: true
      max_evidence_size_mb: 10
    bugcrowd:
      template: "bugcrowd_vrt"
      severity_override: true
      max_evidence_size_mb: 10
    intigriti:
      template: "intigriti_standard"
      max_evidence_size_mb: 5
    immunefi:
      template: "immunefi_defi"
      max_evidence_size_mb: 10

  # Evidence Management
  evidence:
    screenshot_annotation: true
    video_recording: false
    max_screenshots: 20
    max_video_length_s: 120
    redact_pii: true

  # Follow-up
  followup:
    auto_followup: true
    followup_delay_days: 7
    max_followups: 3
    negotiation_enabled: true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_REPORT_PLATFORM` | auto | Target platform |
| `BRAIN_REPORT_QA` | true | Enable QA checks |
| `BRAIN_REPORT_SEVERITY` | cvss_3.1 | Severity model |
| `BRAIN_REPORT_FOLLOWUP` | true | Enable auto follow-up |
