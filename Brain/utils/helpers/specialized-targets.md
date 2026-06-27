# Helpers: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

Helper functions for specialized target testing — category detection, tool selection, protocol parsing, and compliance mapping.

## CategoryDetector

```python
class CategoryDetector:
    CATEGORY_SIGNALS = {
        "iot": ["mqtt", "zigbee", "ble", "firmware", "uart", "jtag"],
        "mobile": ["ios", "android", "apk", "ipa", "certificate_pinning"],
        "cloud": ["aws", "azure", "gcp", "s3", "lambda", "iam"],
        "blockchain": ["solidity", "ethereum", "smart_contract", "defi"],
        "healthcare": ["hipaa", "dicom", "hl7", "fhir", "ehr"],
        "ics": ["modbus", "dnp3", "opc", "plc", "scada"]
    }

    @staticmethod
    def detect(target_info):
        for category, signals in CategoryDetector.CATEGORY_SIGNALS.items():
            matches = sum(1 for s in signals if s in str(target_info).lower())
            if matches >= 2:
                return category
        return "web_application"
```

## ToolSelector

```python
class ToolSelector:
    CATEGORY_TOOLS = {
        "iot": ["binwalk", "firmware-mod-kit", "jtag"],
        "mobile": ["frida", "objection", "apktool"],
        "cloud": ["pacu", "prowler", " ScoutSuite"],
        "blockchain": ["slither", "mythril", "echidna"],
        "ics": ["modbus-client", "mbtget"]
    }

    @staticmethod
    def for_category(category):
        return ToolSelector.CATEGORY_TOOLS.get(category, ["nmap", "burpsuite"])
```

## ComplianceMapper

```python
class ComplianceMapper:
    FRAMEWORK_MAP = {
        "healthcare": ["hipaa", "HITECH"],
        "finance": ["pci_dss", "sox", "glba"],
        "government": ["fisma", "nist_800_53", "fedramp"],
        "enterprise": ["iso_27001", "soc2"]
    }

    @staticmethod
    def for_category(category):
        return ComplianceMapper.FRAMEWORK_MAP.get(category, [])
```

## Domain File References

All 50 files in `Specialized-Targets/` use category detection, tool selection, and compliance mapping helpers.
