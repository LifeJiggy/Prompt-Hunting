# Tool Executor: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

Tool executor for specialized targets manages category-specific tool execution with appropriate isolation levels, timeout configurations, and output capture for 50 target domains.

## Execution Configuration

```yaml
executor:
  domain: "specialized-targets"
  default_timeout: 600
  max_retries: 2
  sandbox_level: "category_dependent"
  output_capture: true

  category_overrides:
    iot:
      timeout: 1800
      sandbox: "level_4"
      tools: ["binwalk", "jtag", "uart"]
    mobile:
      timeout: 600
      sandbox: "level_3"
      tools: ["frida", "objection", "apktool"]
    cloud:
      timeout: 300
      sandbox: "level_2"
      tools: ["pacu", "prowler"]
    blockchain:
      timeout: 900
      sandbox: "level_1"
      tools: ["slither", "mythril"]
    ics_scada:
      timeout: 1200
      sandbox: "level_4"
      tools: ["modbus-client"]
```

## Execution Schema

```yaml
execution:
  tool_name: "binwalk"
  input:
    target: "/path/to/firmware.bin"
    flags: ["-e", "-M"]
  output:
    stdout: ""
    stderr: ""
    exit_code: 0
    duration_ms: 45000
    files_extracted: 25
```

## Domain File References

All 50 files in `Specialized-Targets/` use category-specific execution configurations.
