# Errors: Advanced-Automation

**Domain Mapping:** `Advanced-Automation/`

## Error Definitions

Errors specific to the automated scanning pipeline subsystem.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `AUTO_PIPELINE_TIMEOUT` | Pipeline Timeout | Pipeline exceeded total time limit | Retry with reduced scope |
| `AUTO_STEP_FAILED` | Step Failed | Individual pipeline step failed | Retry step, skip if optional |
| `AUTO_TOOL_UNAVAILABLE` | Tool Unavailable | Required scanning tool not found | Use alternative tool |
| `AUTO_TOOL_TIMEOUT` | Tool Timeout | Tool execution exceeded timeout | Increase timeout or skip |
| `AUTO_RATE_LIMITED` | Rate Limited | Target returned 429 Too Many Requests | Back off and retry |
| `AUTO_SCOPE_VIOLATION` | Scope Violation | Target is out of program scope | Stop, log, alert |
| `AUTO_REPORT_FAILED` | Report Generation Failed | Could not generate automated report | Manual report fallback |
| `AUTO_DEPENDENCY_MISSING` | Dependency Missing | Required tool or library not installed | Install dependency |
| `AUTO_PERMISSION_DENIED` | Permission Denied | Insufficient permissions for operation | Request elevation |
| `AUTO_CONFIG_INVALID` | Invalid Configuration | Pipeline configuration is malformed | Validate and fix config |

## Error Hierarchy

```
AutomationError (base)
├── PipelineError
│   ├── AUTO_PIPELINE_TIMEOUT
│   ├── AUTO_STEP_FAILED
│   └── AUTO_DEPENDENCY_MISSING
├── ToolError
│   ├── AUTO_TOOL_UNAVAILABLE
│   ├── AUTO_TOOL_TIMEOUT
│   └── AUTO_RATE_LIMITED
├── ScopeError
│   ├── AUTO_SCOPE_VIOLATION
│   └── AUTO_PERMISSION_DENIED
└── ConfigError
    └── AUTO_CONFIG_INVALID
```

## Recovery Strategies

| Error | Strategy | Max Retries | Backoff |
|-------|----------|-------------|---------|
| Pipeline Timeout | Reduce scope, re-run | 2 | Exponential |
| Step Failed | Retry step, then skip | 3 | Linear |
| Tool Unavailable | Fallback to alternative | 1 | None |
| Tool Timeout | Increase timeout 2x | 2 | Exponential |
| Rate Limited | Wait and retry | 5 | Exponential |
| Scope Violation | Stop immediately | 0 | None |
