# Memory Index: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Overview

The memory index for report writing enables fast retrieval of report templates, accepted report patterns, platform-specific formatting rules, and submission history. With 54 report writing resources, the index helps find the right template, reference, or methodology for any reporting situation.

The index serves two primary use cases: (1) during report creation, finding relevant templates and references for the current vulnerability class and platform; (2) after submission, tracking outcomes to improve future reports.

## Index Schema

```yaml
# Template Index Entry
template_entry:
  template_id: "tmpl_{vuln_class}_{platform}"
  vuln_class: "xss"
  platform: "hackerone"
  filename: "01-Report-Structure-Optimization.md"
  sections: ["title", "summary", "severity", "description", "impact", "steps", "remediation", "poc"]
  acceptance_rate: 0.92
  avg_bounty: 2500

# Reference Index Entry
reference_entry:
  ref_id: "ref_{topic}"
  topic: "impact_framing"
  filename: "Impact-Communication.md"
  category: "impact_and_severity"
  applicable_vuln_classes: ["*"]
  applicable_platforms: ["*"]

# Submission History Entry
submission_entry:
  submission_id: "sub_{uuid}"
  report_id: "rpt_{uuid}"
  platform: "hackerone"
  vuln_class: "idor"
  severity_submitted: "critical"
  severity_triaged: "critical"
  bounty: 10000
  status: "accepted"
  submitted_at: "2025-01-15"
  triaged_at: "2025-01-17"
  paid_at: "2025-02-01"
```

## Query API

```python
def find_template(index, vuln_class, platform):
    """Find report template for specific vuln class and platform."""
    return index.query(template_index, {"vuln_class": vuln_class, "platform": platform})

def find_reference(index, topic):
    """Find reference material for a specific topic."""
    return index.query(reference_index, topic)

def get_acceptance_stats(index, vuln_class=None, platform=None):
    """Get acceptance rate statistics."""
    filters = {}
    if vuln_class: filters["vuln_class"] = vuln_class
    if platform: filters["platform"] = platform
    return index.aggregate(submission_index, filters, metrics=["acceptance_rate", "avg_bounty"])

def find_successful_reports(index, vuln_class):
    """Find accepted reports for a vuln class to use as examples."""
    return index.query(submission_index, {"vuln_class": vuln_class, "status": "accepted"})
```

## Domain File References

All 54 files indexed:

**Structure (01, 02, 08, 10, 13, 19, 32, 35):** Report anatomy, writing standards, detail balancing, code formatting, platform formatting, templates, advanced formatting, cross-platform.

**Content (07, 14, 21, 27-29, 41-43):** Executive summary, language/tone, grammar, audience analysis, information hierarchy, recommendations, personalization, contextual intelligence, depth calibration.

**Technical (04, 22, 47):** PoC development, accuracy verification, advanced PoC.

**Impact (05, 23-24, 44, High-Severity, Impact-Communication):** Severity assessment, impact quantification, business context, visualization, critical findings, impact writing.

**Evidence (09, 33-34):** Visual aids, multimedia, interactive elements.

**Triage (03, 16-18, 31, 39):** Private programs, follow-up, rejection analysis, negotiation, pitfalls, feedback.

**Quality (20, 30, 37-38, 40, 49-50):** QA process, review process, analytics, peer review, continuous improvement, quality metrics, master framework.

**Platform (HackerOne, Bugcrowd):** Platform-specific analysis and dissection.

**Operations (06, 11-12, 15, 25-26, 36, 45-46, 48):** Remediation, timelines, collaboration, attachments, compliance, standards, version control, archiving, collaboration standards, automation tools.

## Integration

- **Working memory** loads templates and references during report creation
- **Long-term storage** persists submission history and acceptance statistics
- **Consolidation** updates template effectiveness based on outcomes
