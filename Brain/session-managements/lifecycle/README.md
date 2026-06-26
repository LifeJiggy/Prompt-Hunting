# Session Lifecycle

> Session creation, state transitions, metadata management, and teardown.

## Overview

The session lifecycle subsystem manages the complete lifetime of agent sessions — from creation through active use, suspension, resumption, and final closure. Every session follows a well-defined state machine that ensures consistency and enables recovery.

## Core Concepts

### Session States

Sessions progress through the following states:

```
created → active → suspended → active → closed
                ↘ terminated (on error)
```

| State | Description |
|-------|-------------|
| `created` | Session initialized but not yet active |
| `active` | Session is running and accepting work |
| `suspended` | Session paused; state serialized for later resume |
| `closed` | Session ended gracefully; resources released |
| `terminated` | Session ended due to error or timeout |

### SessionManager

The `SessionManager` is the primary interface for session operations. It coordinates lifecycle transitions, enforces limits, and delegates persistence to the session store.

```python
from session_managements import SessionManager

manager = SessionManager(config)

# Create a new session
session = manager.create(
    name="bug-hunt-session",
    metadata={"target": "example.com", "scope": "web"},
    auto_checkpoint=True
)

# Suspend for later
manager.suspend(session.id)

# Resume from saved state
session = manager.resume(session.id)

# Close when done
manager.close(session.id)
```

## Session Creation

### `create()`

Creates a new session with the specified configuration.

**Parameters:**
- `name` (str): Human-readable session identifier
- `metadata` (dict): Arbitrary key-value pairs attached to the session
- `auto_checkpoint` (bool): Enable automatic checkpointing (default: `True`)
- `max_duration` (int): Maximum session lifetime in seconds (default: no limit)
- `max_messages` (int): Maximum message count before auto-suspend (default: no limit)

**Returns:** `Session` object with generated `id` and `created_at` timestamp.

**Validation:**
- Session name must be unique within the active session namespace
- Metadata keys must be strings; values must be JSON-serializable
- `max_duration` and `max_messages` must be non-negative integers

**Session ID generation:**
- Format: `ses_<40-char-hex>` (160-bit random)
- Collision probability: < 2^-60 for 1 billion sessions
- IDs are immutable once assigned

## Session Close

### `close()`

Gracefully terminates a session and releases resources.

**Process:**
1. Flush any pending state changes to the session store
2. Run session teardown hooks (custom cleanup logic)
3. Transition state to `closed`
4. Remove session from active registry
5. Archive session metadata for audit

**Behavior:**
- If the session is already `closed`, the call is a no-op
- If the session is `suspended`, it is resumed briefly to flush, then closed
- Active subagents spawned by the session are signaled to stop
- All file locks held by the session are released

## Session Suspend

### `suspend()`

Pauses an active session, serializing its state for later resumption.

**Process:**
1. Trigger a checkpoint (if `auto_checkpoint` is enabled)
2. Serialize session state to the configured store
3. Release active resources (subagents, file handles, connections)
4. Transition state to `suspended`
5. Record suspension timestamp in metadata

**Use cases:**
- Long-running sessions that exceed resource budgets
- User-initiated pause during multi-phase workflows
- System-initiated suspension before maintenance windows
- Session persistence across machine restarts

## Session Resume

### `resume()`

Restores a suspended session from its serialized state.

**Process:**
1. Load session state from the session store
2. Validate state integrity (checksum verification)
3. Restore conversation history and task context
4. Reinitialize resource connections (file handles, caches)
5. Transition state to `active`
6. Resume any pending subagent work

**Validation:**
- Session must be in `suspended` state
- Stored state must pass integrity checks
- Session store must be accessible and responsive
- Resume must complete within configured timeout (default: 30s)

## Session Metadata

Metadata is a flexible key-value store attached to every session. Common keys:

| Key | Type | Description |
|-----|------|-------------|
| `target` | str | Primary target of the session |
| `scope` | str | Scope definition (e.g., "web", "api", "mobile") |
| `phase` | str | Current workflow phase |
| `parent_session` | str | Parent session ID (for nested sessions) |
| `created_at` | ISO 8601 | Session creation timestamp |
| `suspended_at` | ISO 8601 | Last suspension timestamp |
| `closed_at` | ISO 8601 | Session closure timestamp |

**Mutation:**
- Metadata can be updated via `update_metadata(session_id, key, value)`
- Updates are persisted on next checkpoint
- Metadata is included in session listing and search results

## Session Lookup

### `find()`

Search for sessions by metadata criteria.

**Examples:**
```python
# Find all sessions targeting a specific domain
sessions = manager.find(metadata={"target": "example.com"})

# Find active sessions
sessions = manager.find(state="active")

# Find sessions in a specific phase
sessions = manager.find(metadata={"phase": "recon"})
```

**Search behavior:**
- Metadata filters use exact-match semantics
- Multiple filters are AND-ed together
- Results are sorted by creation timestamp (newest first)
- A limit parameter caps the result count (default: 100)

## Session Limits

### Enforced Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_sessions` | 10 | Concurrent active sessions |
| `max_messages_per_session` | 10,000 | Messages before auto-suspend |
| `max_session_duration` | 24h | Maximum session lifetime |
| `max_metadata_size` | 1MB | Metadata payload limit |
| `max_state_size` | 50MB | Serialized state size limit |

### Limit Enforcement

- Limits are checked at each lifecycle transition
- Exceeding a limit triggers auto-suspend (not termination)
- Hard limits (state size) cause immediate suspension
- Soft limits (message count) are checked after each message
- Custom limits can be set per-session or per-user

## Error Handling

| Error | Recovery |
|-------|----------|
| `SessionNotFoundError` | Session may have been archived; check archive |
| `SessionAlreadyClosedError` | No-op; log warning |
| `SessionStateCorruptedError` | Attempt recovery from latest valid checkpoint |
| `SessionStoreUnavailableError` | Retry with exponential backoff |
| `SessionLimitExceededError` | Suspend oldest active session |

## Events

The session manager emits events at each lifecycle transition:

- `session.created` — New session initialized
- `session.activated` — Session transitioned to active
- `session.suspended` — Session paused
- `session.resumed` — Session restored from suspension
- `session.closed` — Session ended gracefully
- `session.terminated` — Session ended due to error
- `session.checkpoint` — State checkpoint created
- `session.metadata_updated` — Metadata changed

Events can be subscribed to for monitoring, logging, and automated workflows.
