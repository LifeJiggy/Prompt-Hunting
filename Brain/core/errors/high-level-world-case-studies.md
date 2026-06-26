# Errors: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Error Definitions

Errors specific to major incident analysis and attack pattern extraction.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `CASE_STUDY_NOT_FOUND` | Case Study Missing | Requested case study not available | Search alternative cases |
| `CASE_DATA_INCOMPLETE` | Incomplete Data | Case study has missing information | Note gaps, proceed |
| `CASE_PATTERN_INVALID` | Invalid Pattern | Extracted pattern is not reusable | Refine extraction |
| `CASE_MITRE_MAPPING_FAILED` | MITRE Mapping Failed | Could not map to ATT&CK framework | Manual mapping |
| `CASE_TIMELINE_AMBIGUOUS` | Ambiguous Timeline | Incident timeline unclear from sources | Note uncertainty |
| `CASE_DEFENSE_INAPPLICABLE` | Defense Inapplicable | Recommended defense not relevant to target | Adapt recommendation |

## Error Hierarchy

```
CaseStudyError (base)
├── CASE_STUDY_NOT_FOUND
├── CASE_DATA_INCOMPLETE
├── CASE_PATTERN_INVALID
├── CASE_MITRE_MAPPING_FAILED
├── CASE_TIMELINE_AMBIGUOUS
└── CASE_DEFENSE_INAPPLICABLE
```
