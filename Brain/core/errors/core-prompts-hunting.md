# Errors: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Error Definitions

Errors specific to the core vulnerability hunting methodology across 50 classes.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `HUNT_CLASS_UNAVAILABLE` | Class Unavailable | Hunting methodology for this class not loaded | Load from domain files |
| `HUNT_ENDPOINT_UNREACHABLE` | Endpoint Unreachable | Target endpoint not responding | Verify target is live |
| `HUNT_WAF_BLOCKED` | WAF Blocked | Web application firewall blocked request | Apply bypass technique |
| `HUNT_FALSE_POSITIVE` | False Positive | Finding does not represent real vulnerability | Refine detection rules |
| `HUNT_EXPLOIT_FAILED` | Exploitation Failed | Could not demonstrate vulnerability impact | Document potential impact |
| `HUNT_TOOL_CRASHED` | Tool Crashed | Security tool crashed during testing | Restart tool, retry |
| `HUNT_AUTH_REQUIRED` | Authentication Required | Endpoint requires authentication not available | Test with auth tokens |
| `HUNT_RATE_LIMITED` | Rate Limited | Too many requests to target | Reduce request rate |
| `HUNT_SCOPE_EXCEEDED` | Scope Exceeded | Testing went out of authorized scope | Stop, verify scope |
| `HUNT_NO_VULNS_FOUND` | No Vulnerabilities Found | All tests for class came back clean | Move to next class |

## Error Hierarchy

```
HuntingError (base)
├── HUNT_CLASS_UNAVAILABLE
├── HUNT_ENDPOINT_UNREACHABLE
├── HUNT_WAF_BLOCKED
├── HUNT_FALSE_POSITIVE
├── HUNT_EXPLOIT_FAILED
├── HUNT_TOOL_CRASHED
├── HUNT_AUTH_REQUIRED
├── HUNT_RATE_LIMITED
├── HUNT_SCOPE_EXCEEDED
└── HUNT_NO_VULNS_FOUND
```
