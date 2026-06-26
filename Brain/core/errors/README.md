# Error Hierarchy

## Overview

The error system provides a structured hierarchy of exceptions for the Brain framework. Errors are categorized by domain, support propagation, and offer recovery strategies.

## Key Components

### BrainException Base

```python
class BrainException(Exception):
    def __init__(self, message: str, code: str, context: dict = None):
        self.message = message
        self.code = code
        self.context = context or {}
        self.timestamp = datetime.utcnow()
```

### Domain-Specific Errors

#### AgentError
```python
class AgentError(BrainException):
    """Agent lifecycle or execution failures."""
    # Codes: AGENT_NOT_FOUND, AGENT_TIMEOUT, AGENT_FAILED
```

#### ConfigError
```python
class ConfigError(BrainException):
    """Configuration loading, validation, or merging failures."""
    # Codes: CONFIG_INVALID, CONFIG_MISSING, CONFIG_PARSE_ERROR
```

#### ExecutionError
```python
class ExecutionError(BrainException):
    """Runtime execution failures in think/act/reflect."""
    # Codes: EXECUTION_TIMEOUT, EXECUTION_CANCELLED, EXECUTION_FAILED
```

#### MemoryError
```python
class MemoryError(BrainException):
    """Memory store read/write or retrieval failures."""
    # Codes: MEMORY_FULL, MEMORY_NOT_FOUND, MEMORY_BACKEND_ERROR
```

#### SessionError
```python
class SessionError(BrainException):
    """Session lifecycle failures."""
    # Codes: SESSION_NOT_FOUND, SESSION_TIMEOUT, SESSION_LIMIT_EXCEEDED
```

#### ToolError
```python
class ToolError(BrainException):
    """Tool invocation or execution failures."""
    # Codes: TOOL_NOT_FOUND, TOOL_TIMEOUT, TOOL_PERMISSION_DENIED
```

#### EventError
```python
class EventError(BrainException):
    """Event publishing or handling failures."""
    # Codes: EVENT_DELIVERY_FAILED, EVENT_HANDLER_ERROR, EVENT_TIMEOUT
```

## Error Propagation

Errors propagate upward through the agent hierarchy:

```
ToolError → ExecutionError → AgentError → BrainException
```

Each layer adds context:

```python
try:
    tool_result = tool.invoke(request)
except ToolError as e:
    raise ExecutionError(
        message=f"Tool invocation failed: {e.message}",
        code="EXECUTION_FAILED",
        context={"tool_error": e.code, "tool": request.tool_id}
    )
```

## Error Recovery Strategies

### Retry with Backoff
```python
retry_policy = RetryPolicy(
    max_attempts=3,
    backoff_factor=2.0,
    max_delay=30.0,
    retryable_codes=["EXECUTION_TIMEOUT", "TOOL_TIMEOUT"]
)
```

### Fallback
```python
fallback = FallbackHandler(
    primary=primary_agent,
    fallback=fallback_agent,
    trigger_codes=["AGENT_TIMEOUT", "AGENT_FAILED"]
)
```

### Circuit Breaker
```python
breaker = CircuitBreaker(
    failure_threshold=5,
    recovery_timeout=60.0,
    half_open_attempts=3
)
```

### Dead Letter Queue
Unrecoverable errors are routed to the dead letter queue for later analysis.

## Error Context

Every error carries context for debugging:

```python
raise AgentError(
    message="Agent failed to produce thought",
    code="AGENT_FAILED",
    context={
        "agent_id": "scanner-01",
        "observation": {...},
        "attempt": 2,
        "model": "gpt-4"
    }
)
```

## Usage Examples

```python
try:
    result = agent.act(thought)
except ExecutionError as e:
    logger.error(f"Execution failed: {e.code}", extra=e.context)
    if e.code in retryable_codes:
        return retry(agent.act, thought)
    raise
except AgentError as e:
    event_bus.publish(Event(
        event_type=EventType.ERROR_OCCURRED,
        source=agent.agent_id,
        payload={"error": e.code, "message": e.message}
    ))
```

## Design Notes

- All errors implement `to_dict()` for serialization
- Error codes follow `DOMAIN_ACTION` naming (e.g., `AGENT_TIMEOUT`)
- Context dictionaries are structured, not free-text
- Errors are logged with full context before propagation
- The system distinguishes between recoverable and unrecoverable errors via error codes
- Fatal errors (e.g., `CONFIG_INVALID`) halt the system; non-fatal errors are retried or logged
