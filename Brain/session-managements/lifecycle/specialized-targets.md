# Session Lifecycle: Specialized Targets Domain

> Session lifecycle management for category-specific security testing, specialized target analysis, and domain-expertise tracking across all 50 Specialized-Targets modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `specialized-targets` |
| Source Directory | `Specialized-Targets/` |
| Module Count | 50 |
| Session Type | `specialized-session` |
| State Complexity | High — tracks category testing, specialized tools, and domain expertise |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Specialized Targets domain. Specialized sessions manage security testing of specific target categories — IoT devices, mobile applications, cloud infrastructure, blockchain systems, healthcare platforms, and more. Each session tracks which specialized modules are loaded, the current testing phase, category-specific findings, and domain expertise applied.

Specialized sessions differ from general hunting sessions in their focus on domain-specific vulnerabilities, tools, and methodologies. An IoT security session requires different tools and knowledge than a web application session, and the lifecycle must accommodate these differences.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │categorizing│            │analyzing │              │testing   │
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │profiling │              │exploiting│              │validating│
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       └──────────────────────────┼──────────────────────────┘
                                  ▼
                           ┌──────────┐
                           │completed │
                           └────┬─────┘
                                │
                                ▼
                           ┌──────────┐
                           │  closed  │
                           └──────────┘
```

### State Definitions

| State | Description |
|-------|-------------|
| `created` | Session initialized; target category and specific target defined |
| `active` | Session running; specialized testing workflow active |
| `categorizing` | Target being categorized and classified |
| `profiling` | Building detailed profile of target category |
| `analyzing` | Category-specific vulnerability analysis |
| `testing` | Active specialized testing in progress |
| `exploiting` | Exploitation of category-specific vulnerabilities |
| `validating` | Validating findings with domain-specific PoC |
| `completed` | Testing objectives achieved |
| `closed` | Session terminated and results archived |

## Session Creation

### `create_specialized_session()`

Creates a new session for a specialized target testing workflow.

**Parameters:**
- `name` (str): Human-readable session identifier
- `target` (str): Specific target to test
- `category` (str): Target category (iot, mobile, cloud, blockchain, healthcare, etc.)
- `modules` (list[str]): Specialized modules to load
- `testing_scope` (dict): Scope boundaries for testing
- `specialized_tools` (list[str]): Category-specific tools to use
- `max_duration` (int): Maximum session lifetime in seconds (default: `28800` — 8 hours)
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)

**Returns:** `Session` object with unique ID, target, category, and testing configuration.

**Validation:**
- Session name must be unique
- Target must be within authorized scope
- Category must be from recognized set
- Module references must exist in the directory

**Initialization Steps:**
1. Generate session ID: `spec_ses_<40-char-hex>`
2. Validate target and category
3. Create session directory: `sessions/<session_id>/`
4. Initialize category-specific test tracker
5. Register session in the active specialized session registry
6. Emit `session.created` event

## Session Close

### `close_specialized_session(session_id)`

Gracefully terminates a specialized session.

**Pre-close Checks:**
1. Verify all category-specific findings are saved
2. Check if specialized testing is complete
3. Ensure domain-specific PoCs are documented

**Close Process:**
1. Transition state to `closing`
2. Generate specialized testing summary
3. Archive category-specific findings
4. Save domain expertise applied
5. Release specialized tool connections
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event

## Session Suspend

### `suspend_specialized_session(session_id)`

Pauses an active specialized session.

**Suspend Process:**
1. Complete current testing step
2. Serialize specialized state including:
   - Current category and testing phase
   - Category-specific findings
   - Specialized tool states
   - Domain expertise notes
3. Save progress
4. Release specialized tool connections
5. Transition state to `suspended`

## Session Resume

### `resume_specialized_session(session_id)`

Restores a suspended specialized session.

**Resume Process:**
1. Load serialized specialized state
2. Verify state integrity
3. Reinitialize specialized tools
4. Restore testing queue
5. Transition state to `active`
6. Emit `session.resumed` event

## Session Metadata Schema

### Standard Fields

| Field | Type | Description |
|-------|------|-------------|
| `session_id` | str | Unique session identifier |
| `name` | str | Human-readable name |
| `state` | str | Current lifecycle state |
| `created_at` | ISO 8601 | Creation timestamp |
| `updated_at` | ISO 8601 | Last update timestamp |
| `suspended_at` | ISO 8601 | Last suspension timestamp |
| `closed_at` | ISO 8601 | Closure timestamp |
| `target` | str | Specific target |

### Specialized-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `category` | str | Target category |
| `modules_loaded` | list[str] | Specialized modules loaded |
| `testing_scope` | dict | Scope boundaries |
| `current_phase` | str | Current testing phase |
| `specialized_tools` | list[str] | Category-specific tools |
| `category_findings` | list[dict] | Category-specific vulnerabilities |
| `findings_by_subcategory` | dict | Findings grouped by subcategory |
| `domain_expertise_applied` | list[str] | Domain expertise applied |
| `tool_coverage` | dict | Coverage of specialized tools |
| `category_profile` | dict | Target category profile |
| `testing_progress` | dict | Progress through category tests |

## Session Lookup

### `find_specialized_sessions()`

Search for specialized sessions by criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `target` (str): Filter by target
- `category` (str): Filter by target category
- `completed` (bool): Filter by completion status

**Examples:**
```python
# Find all active specialized sessions
sessions = find_specialized_sessions(state="active")

# Find IoT testing sessions
sessions = find_specialized_sessions(category="iot")
```

## Session Limits

### Specialized-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_specialized_sessions` | 5 | Concurrent specialized sessions |
| `max_modules_per_session` | 8 | Specialized modules per session |
| `max_session_duration` | 28800s (8h) | Maximum testing runtime |
| `max_findings_per_session` | 50 | Category-specific findings |
| `max_specialized_tools` | 5 | Specialized tools per session |
| `max_category_tests` | 100 | Tests per category |
| `max_state_size` | 50MB | Serialized state size limit |

## Session Isolation

### File System Isolation

```
sessions/<session_id>/
├── state/
│   ├── specialized-state.json  # Testing phase tracker
│   ├── category-tests/         # Category-specific test results
│   ├── tool-states/            # Specialized tool states
│   ├── findings/               # Category-specific findings
│   └── checkpoints/            # Serialized checkpoints
├── output/
│   ├── findings.json           # Aggregated findings
│   ├── category-report.md      # Category-specific report
│   ├── domain-expertise.md     # Domain expertise applied
│   └── artifacts/              # Test artifacts
├── config/
│   ├── specialized-config.json # Session configuration
│   ├── category.json           # Category configuration
│   ├── scope.json              # Scope boundaries
│   └── tools.json              # Specialized tool configs
└── metadata.json               # Session metadata
```

## Module References for Specialized Targets

| Module | File Reference |
|--------|---------------|
| IoT Device Security | `Specialized-Targets/01-IoT-Device-Security.md` |
| Mobile Application Testing | `Specialized-Targets/02-Mobile-Application-Testing.md` |
| Cloud Infrastructure Security | `Specialized-Targets/03-Cloud-Infrastructure-Security.md` |
| Container Security | `Specialized-Targets/04-Container-Security.md` |
| Kubernetes Cluster Security | `Specialized-Targets/05-Kubernetes-Cluster-Security.md` |
| Blockchain Smart Contracts | `Specialized-Targets/06-Blockchain-Smart-Contracts.md` |
| DeFi Protocol Security | `Specialized-Targets/07-DeFi-Protocol-Security.md` |
| NFT Marketplace Security | `Specialized-Targets/08-NFT-Marketplace-Security.md` |
| Web3 Application Security | `Specialized-Targets/09-Web3-Application-Security.md` |
| Cryptocurrency Exchange Security | `Specialized-Targets/10-Cryptocurrency-Exchange-Security.md` |
| Traditional Finance API Security | `Specialized-Targets/11-Traditional-Finance-API-Security.md` |
| Healthcare System Security | `Specialized-Targets/12-Healthcare-System-Security.md` |
| Financial Institution Security | `Specialized-Targets/13-Financial-Institution-Security.md` |
| Government System Security | `Specialized-Targets/14-Government-System-Security.md` |
| Education Platform Security | `Specialized-Targets/15-Education-Platform-Security.md` |
| E-commerce Platform Security | `Specialized-Targets/16-E-commerce-Platform-Security.md` |
| Social Media Platform Security | `Specialized-Targets/17-Social-Media-Platform-Security.md` |
| Content Management System Security | `Specialized-Targets/18-Content-Management-System-Security.md` |
| Learning Management System Security | `Specialized-Targets/19-Learning-Management-System-Security.md` |
| Human Resources System Security | `Specialized-Targets/20-Human-Resources-System-Security.md` |
| Supply Chain Management Security | `Specialized-Targets/21-Supply-Chain-Management-Security.md` |
| Manufacturing Control System Security | `Specialized-Targets/22-Manufacturing-Control-System-Security.md` |
| Smart Building Automation | `Specialized-Targets/23-Smart-Building-Automation.md` |
| Connected Vehicle Security | `Specialized-Targets/24-Connected-Vehicle-Security.md` |
| Autonomous System Security | `Specialized-Targets/25-Autonomous-System-Security.md` |
| Industrial Control System Security | `Specialized-Targets/26-Industrial-Control-System-Security.md` |
| Medical Device Security | `Specialized-Targets/27-Medical-Device-Security.md` |
| Wearable Technology Security | `Specialized-Targets/28-Wearable-Technology-Security.md` |
| Smart Home Device Security | `Specialized-Targets/29-Smart-Home-Device-Security.md` |
| Embedded System Security | `Specialized-Targets/30-Embedded-System-Security.md` |
| Real-Time Operating System Security | `Specialized-Targets/31-Real-Time-Operating-System-Security.md` |
| Firmware Security Analysis | `Specialized-Targets/32-Firmware-Security-Analysis.md` |
| Network Device Security | `Specialized-Targets/33-Network-Device-Security.md` |
| Telecommunication System Security | `Specialized-Targets/34-Telecommunication-System-Security.md` |
| Satellite Communication Security | `Specialized-Targets/35-Satellite-Communication-Security.md` |
| Air Traffic Control System Security | `Specialized-Targets/36-Air-Traffic-Control-System-Security.md` |
| Power Grid Security | `Specialized-Targets/37-Power-Grid-Security.md` |
| Water Treatment Facility Security | `Specialized-Targets/38-Water-Treatment-Facility-Security.md` |
| Transportation System Security | `Specialized-Targets/39-Transportation-System-Security.md` |
| Energy Management System Security | `Specialized-Targets/40-Energy-Management-System-Security.md` |
| Research Institution Security | `Specialized-Targets/41-Research-Institution-Security.md` |
| Non-Profit Organization Security | `Specialized-Targets/42-Non-Profit-Organization-Security.md` |
| Startup Company Security | `Specialized-Targets/43-Startup-Company-Security.md` |
| Enterprise Corporate Security | `Specialized-Targets/44-Enterprise-Corporate-Security.md` |
| Fortune 500 Company Security | `Specialized-Targets/45-Fortune-500-Company-Security.md` |
| Open Source Project Security | `Specialized-Targets/46-Open-Source-Project-Security.md` |
| Academic Research Security | `Specialized-Targets/47-Academic-Research-Security.md` |
| International Organization Security | `Specialized-Targets/48-International-Organization-Security.md` |
| Developing Country Infrastructure | `Specialized-Targets/49-Developing-Country-Infrastructure.md` |
| Global Scale System Security | `Specialized-Targets/50-Global-Scale-System-Security.md` |

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `specialized.session.created` | session_id, category | New specialized session created |
| `specialized.category.identified` | session_id, category | Target category identified |
| `specialized.profile.built` | session_id, profile_type | Category profile built |
| `specialized.test.started` | session_id, test_id | Specialized test started |
| `specialized.test.completed` | session_id, test_id, result | Test completed |
| `specialized.finding.discovered` | session_id, finding | Category-specific finding |
| `specialized.tool.used` | session_id, tool_name | Specialized tool used |
| `specialized.exploitation.successful` | session_id, vuln_type | Exploitation successful |
| `specialized.session.suspended` | session_id, reason | Session suspended |
| `specialized.session.resumed` | session_id | Session resumed |
| `specialized.session.completed` | session_id, findings_count | Session completed |
| `specialized.session.closed` | session_id | Session closed |

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| Tool Unavailable | Specialized tool missing | Use alternative; skip test |
| Category Change | Target reclassified | Update session; adjust scope |
| Test Failure | Incompatible test | Skip; log reason |
| State Corruption | Checksum mismatch | Restore from checkpoint |

## Usage Examples

### Creating an IoT Testing Session

```python
session = create_specialized_session(
    name="test-iot-camera-01",
    target="192.168.1.100",
    category="iot",
    modules=[
        "01-IoT-Device-Security.md",
        "32-Firmware-Security-Analysis.md",
        "30-Embedded-System-Security.md"
    ],
    testing_scope={"network": "192.168.1.0/24"},
    specialized_tools=["binwalk", "nmap", "firmwalker"]
)
```

### Creating a Cloud Security Session

```python
session = create_specialized_session(
    name="audit-aws-account",
    target="aws-account-123456",
    category="cloud",
    modules=[
        "03-Cloud-Infrastructure-Security.md",
        "04-Container-Security.md",
        "05-Kubernetes-Cluster-Security.md"
    ],
    testing_scope={"cloud_provider": "aws", "regions": ["us-east-1"]},
    specialized_tools=["aws-cli", " scoutuite", "prowler"]
)
```

### Querying Specialized Results

```python
sessions = find_specialized_sessions(
    completed=True,
    category="iot"
)
for s in sessions:
    print(f"Target: {s.target}, "
          f"Findings: {len(s.category_findings)}, "
          f"Tools used: {len(s.specialized_tools)}")
```
