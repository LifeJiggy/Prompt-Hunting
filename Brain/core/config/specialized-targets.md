# Config: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Configuration Schema

Configuration for target-specific security testing across 50 specialized domains.

```yaml
specialized:
  # Category Detection
  detection:
    auto_detect: true
    fingerprint_confidence: 0.7
    fallback_category: "web_application"

  # Category-Specific Settings
  categories:
    iot:
      firmware_analysis: true
      hardware_interfaces: ["uart", "jtag", "spi"]
      protocol_testing: ["mqtt", "zigbee", "ble"]
    mobile:
      ios_testing: true
      android_testing: true
      certificate_pinning_bypass: true
      deep_link_testing: true
    cloud:
      aws_testing: true
      azure_testing: true
      gcp_testing: true
      metadata_service: true
      iam_analysis: true
    blockchain:
      solidity_audit: true
      flash_loan_testing: true
      oracle_manipulation: true
    healthcare:
      hipaa_compliance: true
      dicom_testing: true
      hl7_fhir: true
    ics_scada:
      modbus_testing: true
      dnp3_testing: true
      opc_testing: true
      safety_analysis: true
    enterprise:
      active_directory: true
      exchange_testing: true
      sharepoint_testing: true

  # Compliance Frameworks
  compliance:
    frameworks: ["hipaa", "pci_dss", "gdpr", "nist", "iso_27001"]
    auto_map: true
    requirement_tracking: true

  # Tool Specialization
  tools:
    iot: ["binwalk", "firmware-mod-kit", "jtag"]
    mobile: ["frida", "objection", "apktool"]
    cloud: ["pacu", " ScoutSuite", "prowler"]
    blockchain: ["slither", "mythril", "echidna"]
    ics: ["modbus-client", "mbtget", "dnp3-master"]
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_SPECIAL_AUTO_DETECT` | true | Auto-detect target category |
| `BRAIN_SPECIAL_COMPLIANCE` | true | Enable compliance mapping |
| `BRAIN_SPECIAL_IOT` | true | Enable IoT testing |
| `BRAIN_SPECIAL_CLOUD` | true | Enable cloud testing |
