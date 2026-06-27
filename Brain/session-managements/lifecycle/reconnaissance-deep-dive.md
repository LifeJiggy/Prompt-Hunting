# Session Lifecycle: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Overview

Session lifecycle management for the reconnaissance subsystem handles the creation, state management, and teardown of recon sessions. Each recon session encapsulates the complete attack surface mapping workflow — from initial subdomain enumeration through technology fingerprinting and asset graph construction.

Recon sessions are uniquely long-lived compared to other session types. A comprehensive recon against a large target can run for hours, processing thousands of subdomains across multiple enumeration sources. The session must maintain state across this extended duration, checkpointing intermediate results to survive interruptions and enable resumption.

The session lifecycle must also handle the multi-phase nature of reconnaissance. Passive enumeration, active probing, fingerprinting, and deep analysis each represent distinct phases with different resource requirements and risk profiles. The session tracks which phases are complete and which are pending, enabling intelligent resumption after any interruption.

## Session State Machine

```
                    ┌──────────────┐
           ┌───────│   CREATED    │
           │       └──────┬───────┘
           │              │ init()
           │       ┌──────▼───────┐
           │       │ INITIALIZING │
           │       └──────┬───────┘
           │              │ load_sources()
           │       ┌──────▼───────┐
           │       │   PASSIVE    │ ← Phase 1: OSINT, CT logs
           │       └──────┬───────┘
           │              │ complete_passive()
           │       ┌──────▼───────┐
           │       │    ACTIVE    │ ← Phase 2: DNS, HTTP probing
           │       └──────┬───────┘
           │              │ complete_active()
           │       ┌──────▼───────┐
           │       │ FINGERPRINT  │ ← Phase 3: Tech detection
           │       └──────┬───────┘
           │              │ complete_fingerprint()
           │       ┌──────▼───────┐
     ┌─────┤       │    DEEP      │ ← Phase 4: JS, API, cloud
     │     │       └──────┬───────┘
     │     │              │ complete_deep()
     │     │       ┌──────▼───────┐
     │     │       │  SYNTHESIZE  │ ← Build asset graph
     │     │       └──────┬───────┘
     │     │              │ complete()
     │     │       ┌──────▼───────┐
     │     │       │  COMPLETED   │
     │     │       └──────────────┘
     │     │
     │   suspend()        resume()
     │     │                │
     │  ┌──▼────────┐  ┌───▼──────┐
     └─▶│  SUSPENDED │──│ RESUMING │
        └────────────┘  └──────────┘
                │
              close()
                │
        ┌───────▼──────┐
        │    CLOSED    │
        └──────────────┘
```

## Session Schema

```yaml
recon_session:
  session_id: "rses_{uuid}"
  target: "target.com"
  created_at: "2025-01-15T10:00:00Z"
  status: "active"
  current_phase: "active"

  # Phase Progress
  phases:
    passive:
      status: "completed"
      started: "2025-01-15T10:00:00Z"
      completed: "2025-01-15T10:15:00Z"
      assets_discovered: 245
      sources_used: ["crt.sh", "virustotal", "github"]
    active:
      status: "in_progress"
      started: "2025-01-15T10:15:00Z"
      assets_verified: 120
      live_hosts: 85
    fingerprint:
      status: "pending"
    deep:
      status: "pending"
    synthesize:
      status: "pending"

  # Discovered Assets
  assets:
    total: 245
    live: 85
    dead: 120
    unknown: 40

  # Resource Usage
  resources:
    queries_made: 1500
    bandwidth_mb: 250
    duration_seconds: 900
```

## Operations

### Create Session

```python
def create_recon_session(session_mgr, target):
    session = session_mgr.create(
        session_type="recon",
        target=target,
        config={
            "phases": ["passive", "active", "fingerprint", "deep", "synthesize"],
            "rate_limit_rps": 10,
            "checkpoint_interval": 300,
            "max_duration": 7200
        }
    )
    return session
```

### Phase Transition

```python
def transition_phase(session, new_phase):
    """Move session to next recon phase."""
    session.current_phase = new_phase
    session.phases[new_phase]["status"] = "in_progress"
    session.phases[new_phase]["started"] = now()
    session_mgr.save_checkpoint(session)
```

### Suspend and Resume

```python
def suspend_recon_session(session_mgr, session_id):
    session = session_mgr.get(session_id)
    session_mgr.create_checkpoint(session)
    session_mgr.suspend(session_id)

def resume_recon_session(session_mgr, session_id):
    session = session_mgr.resume(session_id)
    # Resume from last completed phase
    current = session.current_phase
    session.phases[current]["status"] = "in_progress"
    return session
```

## Domain File References

All 50 files in `Reconnaissance-Deep-Dive/` are supported by this session lifecycle:

**Subdomain/DNS (01, 16-17):** `01-Advanced-Subdomain-Enumeration.md` — Multi-source enumeration session phase. `16-DNS-Enumeration-Advanced.md` — DNS query session phase. `17-Certificate-Transparency-Logs.md` — CT log mining session phase.

**OSINT (02, 18-20, 22-23):** `02-Passive-OSINT-Collection.md` — Passive intelligence gathering phase. `18-Historical-Data-Analysis.md` — Historical data retrieval phase. `19-Social-Media-OSINT.md` — Social media enumeration phase. `20-Employee-Linked-Assets.md` — Employee asset mapping phase. `22-Web-Archive-Analysis.md` — Wayback Machine analysis phase. `23-Pastebin-and-Leak-Searching.md` — Leak monitoring phase.

**Active (03, 10-11):** `03-Active-Asset-Discovery.md` — Live host verification phase. `10-Content-Discovery-Automation.md` — Hidden content discovery phase. `11-Directory-Brute-Forcing.md` — Directory enumeration phase.

**Fingerprinting (04, 09, 12, 41-45):** `04-Technology-Stack-Fingerprinting.md` — Technology detection phase. `09-Version-Detection-Techniques.md` — Version extraction phase. `12-File-Type-Detection.md` — File format analysis phase. `41-45` — CMS, framework, server, SSL, header analysis phases.

**Cloud (05, 25):** `05-Cloud-Resource-Enumeration.md` — Cloud asset discovery phase. `25-Container-Registry-Enumeration.md` — Container registry phase.

**API (06, 28-31):** `06-API-Endpoint-Discovery.md` — API enumeration phase. `28-31` — Documentation, WebSocket, GraphQL, SOAP discovery phases.

**Code (07, 14-15, 24):** `07-JavaScript-Source-Analysis.md` — JS analysis phase. `14-Source-Code-Leak-Detection.md` — Source leak detection phase. `15-Git-Repository-Analysis.md` — Git exposure phase. `24-Code-Repository-Mining.md` — Repository mining phase.

**Config (08, 13):** `08-Configuration-File-Extraction.md` — Config file discovery phase. `13-Backup-File-Discovery.md` — Backup file enumeration phase.

**Enterprise (21, 26-27, 32-40):** All enterprise recon phases — third-party, IoT, mobile, email, phone, physical, supply chain, competitor, partner, acquisition, subsidiary, regional.

**Advanced (46-50):** Cookie, error page, debug, staging, and advanced strategy phases.

## Integration

- Checkpoints save phase progress for resume after interruption
- Memory stores discovered assets persistently
- Runtime monitors resource usage during long-running recon
- Health checks ensure recon workers remain responsive
