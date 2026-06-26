# Errors: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Error Definitions

Errors specific to report creation, quality assurance, and submission.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `REPORT_STRUCTURE_INVALID` | Invalid Structure | Report missing required sections | Add missing sections |
| `REPORT_SEVERITY_WRONG` | Wrong Severity | CVSS scoring is inaccurate | Recalculate vector |
| `REPORT_POC_FAILED` | PoC Failed | Proof of concept does not reproduce | Debug and fix PoC |
| `REPORT_QA_FAILED` | QA Failed | Report did not pass quality checks | Address checklist items |
| `REPORT_SUBMISSION_FAILED` | Submission Failed | Platform rejected submission | Retry, contact support |
| `REPORT_REJECTED` | Report Rejected | Triager marked as N/A | Analyze reason, appeal |
| `REPORT_DOWNGRADED` | Severity Downgraded | Severity reduced by triager | Prepare defense |
| `REPORT_DUPLICATE` | Duplicate Report | Finding already reported | Withdraw, find new vuln |
| `REPORT_PLATFORM_ERROR` | Platform Error | Bug bounty platform unavailable | Retry later |

## Error Hierarchy

```
ReportError (base)
├── REPORT_STRUCTURE_INVALID
├── REPORT_SEVERITY_WRONG
├── REPORT_POC_FAILED
├── REPORT_QA_FAILED
├── REPORT_SUBMISSION_FAILED
├── REPORT_REJECTED
├── REPORT_DOWNGRADED
├── REPORT_DUPLICATE
└── REPORT_PLATFORM_ERROR
```
