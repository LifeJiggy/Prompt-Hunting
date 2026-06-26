# Errors: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Error Definitions

Errors specific to the master reference framework and support prompts.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `SUPPORT_FRAMEWORK_NOT_FOUND` | Framework Missing | Referenced framework does not exist | Load from knowledge base |
| `SUPPORT_TEMPLATE_INVALID` | Invalid Template | Report template is malformed | Use default template |
| `SUPPORT_SCOPE_PARSE_FAILED` | Scope Parse Failed | Could not parse program scope | Manual scope analysis |
| `SUPPORT_METHODOLOGY_STALE` | Stale Methodology | Methodology not updated for current threats | Update from knowledge base |
| `SUPPORT_TOOL_NOT_AVAILABLE` | Tool Not Available | Recommended tool not installed | Suggest alternative tool |
| `SUPPORT_CONTEXT_OVERFLOW` | Context Overflow | Knowledge base exceeds context window | Summarize and retry |
| `SUPPORT_PATTERN_NOT_FOUND` | Pattern Missing | No matching pattern for vuln class | Create new pattern |

## Error Hierarchy

```
SupportError (base)
├── SUPPORT_FRAMEWORK_NOT_FOUND
├── SUPPORT_TEMPLATE_INVALID
├── SUPPORT_SCOPE_PARSE_FAILED
├── SUPPORT_METHODOLOGY_STALE
├── SUPPORT_TOOL_NOT_AVAILABLE
├── SUPPORT_CONTEXT_OVERFLOW
└── SUPPORT_PATTERN_NOT_FOUND
```
