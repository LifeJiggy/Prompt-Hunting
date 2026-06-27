# Specialized Targets — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `specialized-targets` |
| Domain Path | `Specialized-Targets/` |
| File Count | 50 prompt files |
| Registry | `Specialized-Targets/registry.json` |
| Category | Specialized Testing |
| Lifecycle Scope | Category-specific workers, domain experts, specialized scanners, platform testers |

## Overview

This document defines the complete process lifecycle management for the Specialized Targets domain. The domain encompasses 50 prompt files covering security testing for specialized target categories, from IoT devices through global-scale systems. The lifecycle manages processes that apply domain-specific testing methodologies, tools, and techniques to non-standard target types.

Specialized target testing requires unique process handling because each target category has distinct protocols, attack surfaces, and testing methodologies. The lifecycle manages the selection and configuration of appropriate testing workers based on the target category, and handles the unique resource requirements of each category.

## Process State Machine

```
                    +------------------+
                    |                  |
            +------>|    CREATED       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   INITIALIZING   |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |  CATEGORY_SETUP  |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            +-------+    TESTING       |
            |       |                  |
            |       +--+----+----+-----+
            |          |    |    |
            | pause    |    |    | complete
            |          v    |    v
            |    +-----+--+ |  +-----------+
            |    |        | |  |           |
            |    |PAUSED  | |  |COMPLETED  |
            |    |        | |  |           |
            |    +---+----+ |  +-----------+
            |        |      |
            | resume |      | error
            |        v      v
            +-------+------+------+
                           |
                           v
                    +------+------+
                    |             |
                    |  STOPPING   |
                    |             |
                    +------+------+
                           |
                           v
                    +------+------+
                    |             |
                    |   STOPPED   |
                    |             |
                    +-------------+
```

## State Definitions

### CREATED

Process entry allocated. Target category and scope determined.

**Internal data:**
- Process ID assigned
- Target category selected from 50 categories
- Category-specific testing methodology loaded
- All 50 file references loaded:
  - `01-IoT-Device-Security.md`
  - `02-Mobile-Application-Testing.md`
  - `03-Cloud-Infrastructure-Security.md`
  - `04-Container-Security.md`
  - `05-Kubernetes-Cluster-Security.md`
  - `06-Blockchain-Smart-Contracts.md`
  - `07-DeFi-Protocol-Security.md`
  - `08-NFT-Marketplace-Security.md`
  - `09-Web3-Application-Security.md`
  - `10-Cryptocurrency-Exchange-Security.md`
  - `11-Traditional-Finance-API-Security.md`
  - `12-Healthcare-System-Security.md`
  - `13-Financial-Institution-Security.md`
  - `14-Government-System-Security.md`
  - `15-Education-Platform-Security.md`
  - `16-E-commerce-Platform-Security.md`
  - `17-Social-Media-Platform-Security.md`
  - `18-Content-Management-System-Security.md`
  - `19-Learning-Management-System-Security.md`
  - `20-Human-Resources-System-Security.md`
  - `21-Supply-Chain-Management-Security.md`
  - `22-Manufacturing-Control-System-Security.md`
  - `23-Smart-Building-Automation.md`
  - `24-Connected-Vehicle-Security.md`
  - `25-Autonomous-System-Security.md`
  - `26-Industrial-Control-System-Security.md`
  - `27-Medical-Device-Security.md`
  - `28-Wearable-Technology-Security.md`
  - `29-Smart-Home-Device-Security.md`
  - `30-Embedded-System-Security.md`
  - `31-Real-Time-Operating-System-Security.md`
  - `32-Firmware-Security-Analysis.md`
  - `33-Network-Device-Security.md`
  - `34-Telecommunication-System-Security.md`
  - `35-Satellite-Communication-Security.md`
  - `36-Air-Traffic-Control-System-Security.md`
  - `37-Power-Grid-Security.md`
  - `38-Water-Treatment-Facility-Security.md`
  - `39-Transportation-System-Security.md`
  - `40-Energy-Management-System-Security.md`
  - `41-Research-Institution-Security.md`
  - `42-Non-Profit-Organization-Security.md`
  - `43-Startup-Company-Security.md`
  - `44-Enterprise-Corporate-Security.md`
  - `45-Fortune-500-Company-Security.md`
  - `46-Open-Source-Project-Security.md`
  - `47-Academic-Research-Security.md`
  - `48-International-Organization-Security.md`
  - `49-Developing-Country-Infrastructure.md`
  - `50-Global-Scale-System-Security.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading category-specific configuration, initializing specialized tools, setting up testing environment.

**Sub-steps:**
1. Load `Specialized-Targets/registry.json`
2. Load category-specific testing methodology
3. Initialize category-specific tools and scanners
4. Set up testing environment (emulators, test instances, APIs)
5. Load category-specific vulnerability patterns
6. Configure safety constraints (especially for critical infrastructure)
7. Validate scope boundaries

**Exit:** INITIALIZING -> CATEGORY_SETUP | INITIALIZING -> FAILED

### CATEGORY_SETUP

Configuring category-specific testing infrastructure and workers.

**Category-specific setup:**

*IoT and Embedded (01, 23, 24, 25, 27, 28, 29, 30, 31, 32):*
- Firmware extraction tools
- Hardware interface setup (UART, JTAG, SPI)
- Protocol analyzers (MQTT, CoAP, Zigbee, BLE)
- Emulation environment (QEMU, FirmAE)
- Network analysis tools

*Web and Application (02, 15, 16, 17, 18, 19, 20, 21):*
- Mobile testing frameworks (Frida, Objection)
- CMS-specific scanners
- API testing tools
- Browser automation

*Cloud and Infrastructure (03, 04, 05, 33, 34):*
- Cloud provider CLI tools
- Container security scanners
- Kubernetes security tools
- Network device firmware tools

*Blockchain and Finance (06, 07, 08, 09, 10, 11, 13):*
- Smart contract analyzers (Slither, Mythril)
- DeFi protocol testers
- Blockchain explorers
- Financial API testing tools

*Critical Infrastructure (22, 26, 35, 36, 37, 38, 39, 40):*
- ICS/SCADA protocol tools
- Safety validation frameworks
- Industrial protocol analyzers
- Critical infrastructure checklists

*Enterprise and Organization (12, 14, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50):*
- Enterprise security scanners
- Compliance validation tools
- Organization-specific testing frameworks

**Exit:** CATEGORY_SETUP -> TESTING (setup complete) | CATEGORY_SETUP -> FAILED

### TESTING

Active testing with category-specific workers.

**Testing activities (organized by category):**

*IoT and Embedded Devices:*
- `01-IoT-Device-Security.md` — IoT device testing
- `23-Smart-Building-Automation.md` — Smart building testing
- `24-Connected-Vehicle-Security.md` — Vehicle security testing
- `25-Autonomous-System-Security.md` — Autonomous system testing
- `27-Medical-Device-Security.md` — Medical device testing
- `28-Wearable-Technology-Security.md` — Wearable testing
- `29-Smart-Home-Device-Security.md` — Smart home testing
- `30-Embedded-System-Security.md` — Embedded system testing
- `31-Real-Time-Operating-System-Security.md` — RTOS testing
- `32-Firmware-Security-Analysis.md` — Firmware analysis

*Web and Application Platforms:*
- `02-Mobile-Application-Testing.md` — Mobile app testing
- `15-Education-Platform-Security.md` — Education platform testing
- `16-E-commerce-Platform-Security.md` — E-commerce testing
- `17-Social-Media-Platform-Security.md` — Social media testing
- `18-Content-Management-System-Security.md` — CMS testing
- `19-Learning-Management-System-Security.md` — LMS testing
- `20-Human-Resources-System-Security.md` — HR system testing
- `21-Supply-Chain-Management-Security.md` — Supply chain testing

*Cloud and Infrastructure:*
- `03-Cloud-Infrastructure-Security.md` — Cloud testing
- `04-Container-Security.md` — Container testing
- `05-Kubernetes-Cluster-Security.md` — Kubernetes testing
- `33-Network-Device-Security.md` — Network device testing
- `34-Telecommunication-System-Security.md` — Telecom testing

*Blockchain and Finance:*
- `06-Blockchain-Smart-Contracts.md` — Smart contract testing
- `07-DeFi-Protocol-Security.md` — DeFi protocol testing
- `08-NFT-Marketplace-Security.md` — NFT marketplace testing
- `09-Web3-Application-Security.md` — Web3 app testing
- `10-Cryptocurrency-Exchange-Security.md` — Exchange testing
- `11-Traditional-Finance-API-Security.md` — Finance API testing
- `13-Financial-Institution-Security.md` — Financial institution testing

*Critical Infrastructure:*
- `22-Manufacturing-Control-System-Security.md` — Manufacturing control testing
- `26-Industrial-Control-System-Security.md` — ICS testing
- `35-Satellite-Communication-Security.md` — Satellite testing
- `36-Air-Traffic-Control-System-Security.md` — ATC testing
- `37-Power-Grid-Security.md` — Power grid testing
- `38-Water-Treatment-Facility-Security.md` — Water treatment testing
- `39-Transportation-System-Security.md` — Transportation testing
- `40-Energy-Management-System-Security.md` — Energy management testing

*Enterprise and Organization:*
- `12-Healthcare-System-Security.md` — Healthcare testing
- `14-Government-System-Security.md` — Government system testing
- `41-Research-Institution-Security.md` — Research institution testing
- `42-Non-Profit-Organization-Security.md` — Non-profit testing
- `43-Startup-Company-Security.md` — Startup testing
- `44-Enterprise-Corporate-Security.md` — Enterprise testing
- `45-Fortune-500-Company-Security.md` — Fortune 500 testing
- `46-Open-Source-Project-Security.md` — Open source testing
- `47-Academic-Research-Security.md` — Academic research testing
- `48-International-Organization-Security.md` — International org testing
- `49-Developing-Country-Infrastructure.md` — Developing country testing
- `50-Global-Scale-System-Security.md` — Global scale system testing

**Exit:** TESTING -> COMPLETED (testing complete) | TESTING -> PAUSED | TESTING -> FAILED

### PAUSED

Testing suspended. Category-specific state preserved.

**Exit:** PAUSED -> TESTING | PAUSED -> STOPPING

### COMPLETED

All category-specific testing complete. Final report generated.

**Exit:** COMPLETED -> STOPPED

### STOPPING

Graceful shutdown. Testing state preserved.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All testing workers terminated.

## Start Operations

### Specialized Target Start

```
1. Receive test command with target and category
2. Transition: CREATED -> INITIALIZING
3. Load category-specific methodology
4. Initialize specialized tools
5. Transition: INITIALIZING -> CATEGORY_SETUP
6. Set up category-specific testing infrastructure
7. Configure safety constraints
8. Transition: CATEGORY_SETUP -> TESTING
9. Execute category-specific tests
10. Transition: TESTING -> COMPLETED
11. Generate category-specific report
```

## Stop Operations

### Graceful Stop

```
1. Receive stop signal
2. Transition: CURRENT_STATE -> STOPPING
3. Save testing state
4. Complete in-progress tests where safe
5. Release specialized tools
6. Clean testing environment
7. Transition: STOPPING -> STOPPED
```

### Emergency Stop (Critical Infrastructure)

For critical infrastructure targets (22, 26, 35-40):
```
1. IMMEDIATELY stop all active testing
2. Disconnect from target
3. Preserve all test logs
4. Notify operator
5. Do NOT attempt to complete any tests
```

## Graceful Shutdown Protocol

### Phase 1: Test Completion (0-60s)
- Allow safe tests to complete
- Stop all potentially disruptive tests
- Disconnect from target where appropriate

### Phase 2: Environment Cleanup (60-120s)
- Remove test artifacts from target
- Restore target to pre-test state (if modified)
- Release emulated environments
- Clean testing tools

### Phase 3: State Persistence (120-150s)
- Save all test results
- Write category-specific report
- Archive testing data

### Phase 4: Resource Release (150-180s)
- Release specialized tool licenses
- Close hardware interfaces
- Free emulation resources
- Write shutdown log

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Complete tests, clean, shutdown |
| `SIGINT` | `handle_emergency_stop()` | Immediate safe stop |
| `SIGHUP` | `handle_target_reload()` | Reload target configuration |
| `SIGUSR1` | `handle_results_dump()` | Dump current test results |
| `SIGUSR2` | `handle_category_switch()` | Switch testing category (debug) |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

| Metric | Description | Alert |
|--------|-------------|-------|
| `current_category` | Active target category | N/A (info) |
| `tests_completed` | Tests finished | N/A (info) |
| `tests_failed` | Tests failed | > 0 |
| `tests_in_progress` | Active tests | N/A (info) |
| `category_specific_tools` | Active specialized tools | N/A (info) |
| `safety_violations` | Safety constraint violations | > 0 |
| `target_responsive` | Target responsiveness | False |
| `memory_usage_mb` | Process memory | > 4096 MB |
| `specialized_tool_count` | Active tools | > 20 |

### Safety Monitoring (Critical Infrastructure)

For critical infrastructure targets (22, 26, 35-40):
- Continuous safety constraint monitoring
- Automatic test termination on safety violation
- Target impact assessment after each test
- Emergency disconnect capability

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| Memory | 4096 MB | Kill non-essential tools |
| CPU | 4 cores | Throttle testing |
| Specialized tools | 20 concurrent | Queue excess |
| Network connections | 500 | Rate limit |
| Emulation instances | 5 | Kill idle emulators |
| Hardware interfaces | 10 | Release idle interfaces |
| Test result storage | 10 GB | Rotate old results |

## Cleanup Procedures

### Standard Cleanup

```
1. Remove test artifacts from target
2. Release specialized tool sessions
3. Close hardware interfaces
4. Stop emulation instances
5. Archive test results
6. Write cleanup verification report
```

### Critical Infrastructure Cleanup

```
1. Disconnect from target immediately
2. Verify target operational state
3. Remove all test modifications
4. Document any target impact
5. Notify operator of cleanup status
6. Archive all test evidence
```

## Domain File References

All 50 files serve as category-specific testing configurations. See the TESTING state definition for the complete organized listing grouped by target category.

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Specialized Testing Manager
        |
        +-- IoT/Embedded Workers
        |     +-- Firmware Analyzer
        |     +-- Hardware Interface Worker
        |     +-- Protocol Analyzer Worker
        |     +-- Emulation Worker
        |
        +-- Web/App Workers
        |     +-- Mobile Tester
        |     +-- CMS Scanner
        |     +-- API Tester
        |     +-- Browser Automation Worker
        |
        +-- Cloud/Infra Workers
        |     +-- Cloud Scanner
        |     +-- Container Scanner
        |     +-- K8s Scanner
        |     +-- Network Device Worker
        |
        +-- Blockchain/Finance Workers
        |     +-- Smart Contract Analyzer
        |     +-- DeFi Protocol Tester
        |     +-- Exchange Tester
        |     +-- Finance API Worker
        |
        +-- Critical Infrastructure Workers
        |     +-- ICS/SCADA Worker
        |     +-- Safety Monitor
        |     +-- Protocol Analyzer Worker
        |
        +-- Enterprise Workers
        |     +-- Compliance Scanner
        |     +-- Enterprise Assessment Worker
        |     +-- Organization-Specific Worker
        |
        +-- Safety Controller
              +-- Safety Constraint Monitor
              +-- Emergency Disconnect
              +-- Impact Assessor
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `test.category_timeout` | 7200 | Category test timeout (seconds) |
| `test.max_concurrent_tools` | 20 | Max concurrent specialized tools |
| `test.safety_monitoring` | true | Enable safety monitoring |
| `test.safety_auto_stop` | true | Auto-stop on safety violation |
| `test.emulation_enabled` | true | Enable emulation |
| `test.max_emulation_instances` | 5 | Max emulation instances |
| `test.hardware_interfaces` | 10 | Max hardware interfaces |
| `test.result_storage_gb` | 10 | Result storage limit |
| `test.emergency_disconnect` | true | Enable emergency disconnect |
| `test.critical_infra_mode` | auto | Critical infrastructure mode |
