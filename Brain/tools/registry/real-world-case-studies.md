# Tool Registry: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Overview

Tool registry for disclosed report analysis manages the registration and discovery of tools used to analyze 50 real-world vulnerability findings — pattern extraction, technique cataloging, bounty correlation, and hunt prompt generation.

## Registered Tools

| Tool | Purpose | Category | Version |
|------|---------|----------|---------|
| `pattern_extractor` | Derive hunting patterns from disclosed reports | analysis | 2.1.0 |
| `technique_cataloger` | Build reusable technique library | cataloging | 1.5.0 |
| `bounty_correlator` | Correlate findings with bounty amounts | analysis | 1.3.0 |
| `hunt_prompt_generator` | Auto-generate hunting prompts from patterns | generation | 2.0.0 |
| `report_parser` | Parse disclosed report format | parsing | 1.8.0 |
| `vuln_classifier` | Classify vulnerability type and severity | classification | 1.6.0 |
| `platform_adapter` | Adapt analysis for different platforms | integration | 1.4.0 |
| `pattern_validator` | Validate extracted patterns | validation | 1.2.0 |

## Registration Schema

```yaml
tool:
  name: "pattern_extractor"
  version: "2.1.0"
  domain: "real-world-case-studies"
  category: "analysis"
  input_schema:
    type: "object"
    properties:
      report_content: { type: "string" }
      vuln_class: { type: "string" }
    required: ["report_content"]
  output_schema:
    type: "object"
    properties:
      pattern_id: { type: "string" }
      technique: { type: "string" }
      confidence: { type: "number" }
  config:
    timeout: 60
    retries: 2
    sandbox: false
```

## Operations

```python
def register_tool(registry, tool_config):
    """Register a disclosed analysis tool."""
    registry.register(tool_config["name"], tool_config)

def discover_tools(registry, capability="analysis"):
    """Find tools for disclosed analysis."""
    return registry.find(category=capability)

def list_tools(registry):
    """List all registered disclosed analysis tools."""
    return registry.list(domain="real-world-case-studies")
```

## Domain File References

All 50 files in `Real-World-Case-Studies/` use registered tools:
- Injection (01, 03, 06, 09-10, 28-29): Pattern extraction for injection classes
- XSS/Client (02, 25-26, 31, 38): Pattern extraction for client-side classes
- Auth (05, 11-12, 21, 33, 37, 39, 50): Pattern extraction for auth classes
- Deserialization (07, 16-19): Pattern extraction for deserialization classes
- SSRF/Network (04, 22, 27, 36, 46-47): Pattern extraction for network classes
- Logic (13-14, 20, 32, 34): Pattern extraction for logic classes
- Info (15, 40-42): Pattern extraction for disclosure classes
- File (08, 43-45): Pattern extraction for file inclusion classes
- Advanced (23-24, 35, 48-49): Pattern extraction for advanced classes
