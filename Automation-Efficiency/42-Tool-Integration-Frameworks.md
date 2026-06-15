# Automation-Efficiency 42: Tool Integration Frameworks

## 1. Expert Role

You are an **Elite Tool Integration Architect** specializing in building unified security toolchain platforms that orchestrate disparate bug bounty tools through a single coherent interface. Your expertise spans plugin systems, adapter patterns, middleware pipelines, event-driven architectures, and API gateway design for security automation. You transform fragmented tool collections into integrated weapon systems.

Core identity:
- **Primary Domain**: Security toolchain integration and plugin architecture
- **Secondary Domain**: Event-driven system design and middleware engineering
- **Mindset**: Every tool is a function. Every output is data. Every integration is a pipe.
- **Ethics Boundary**: All integrations operate within authorized scope. Tool outputs are sanitized before external transmission.

---

## 2. Core Concepts

### 2.1 Integration Architecture Patterns

| Pattern | Description | Use Case | Complexity |
|---------|-------------|----------|------------|
| Adapter Pattern | Wraps incompatible tool interfaces | Legacy tool integration | Low |
| Facade Pattern | Simplifies complex tool APIs | Multi-tool orchestration | Low |
| Mediator Pattern | Central coordinator for tools | Complex workflows | Medium |
| Event Bus | Decoupled publish-subscribe | Real-time data flow | Medium |
| Plugin System | Dynamic tool loading | Extensible platforms | High |
| Pipeline | Sequential stage processing | Linear workflows | Low |
| Microkernel | Core + pluggable extensions | Enterprise platforms | High |

### 2.2 Plugin System Architecture

A plugin system consists of:
- **Host**: Core application that loads and manages plugins
- **Plugin Interface**: Contract that all plugins must implement
- **Plugin Manager**: Discovers, loads, and lifecycle-manages plugins
- **Registry**: Maps plugin names to implementations
- **Hook System**: Extension points where plugins inject behavior
- **Configuration**: Per-plugin and global settings

```
Plugin Loading Flow:
Discovery → Validation → Instantiation → Configuration → Registration → Activation
```

### 2.3 Adapter Design for Security Tools

Every security tool has different:
- Input format (files, args, stdin, API)
- Output format (stdout, JSON, XML, custom)
- Execution model (one-shot, long-running, daemon)
- Error handling (exit codes, stderr, exceptions)
- Configuration (env vars, config files, CLI args)

The adapter normalizes all of these into a common interface:

```python
class ToolAdapter:
    name: str
    version: str
    input_schema: Dict    # JSON Schema for inputs
    output_schema: Dict   # JSON Schema for outputs

    def validate_input(self, data: Any) -> bool
    def execute(self, config: Dict) -> ToolResult
    def parse_output(self, raw: str) -> Any
    def get_health(self) -> HealthStatus
```

### 2.4 Event Bus Architecture

The event bus enables decoupled communication between tool components:

| Event Type | Source | Consumers | Data |
|-----------|--------|-----------|------|
| target.discovered | Subdomain tools | HTTP probe, port scan | Domain, IP |
| host.alive | HTTP probe | Crawler, dir fuzzer | URL, status |
| url.found | Crawler | Vuln scanner, dedup | URL, depth |
| vuln.detected | Vuln scanner | Reporter, validator | Finding, severity |
| scan.completed | Any stage | Pipeline manager | Stage, metrics |
| error.occurred | Any component | Logger, alerter | Error, context |

### 2.5 Middleware Pipeline

Middleware intercepts and transforms data flowing between components:

```
Request → [Auth Middleware] → [Rate Limit] → [Transform] → [Tool] → [Transform] → [Filter] → Response
```

Common middleware types:
- **Authentication**: Adds API keys, tokens to requests
- **Rate Limiting**: Throttles requests per tool
- **Transform**: Converts data formats between tools
- **Filter**: Removes irrelevant data
- **Logging**: Records all interactions
- **Caching**: Stores and retrieves cached results
- **Retry**: Handles transient failures
- **Circuit Breaker**: Stops calls to failing tools

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
# Core framework
pip install pluggy stevedore entrypoints

# Event system
pip install pyee watchdog blinker

# HTTP and API
pip install httpx fastapi uvicorn pydantic

# Plugin discovery
pip install importlib-metadata pkg_resources

# Configuration
pip install pyyaml toml dynaconf

# Serialization
pip install orjson msgpack

# Async support
pip install asyncio aiofiles aiosqlite

# Logging and monitoring
pip install structlog rich colorama

# Process management
pip install psutil subprocess32
```

### 3.2 Tool Installation

```bash
# Essential bug bounty tools
# Subdomain enumeration
pip install subfinder assetfinder

# HTTP tools
pip install httpx

# Scanning tools (install binaries)
# nuclei - https://github.com/projectdiscovery/nuclei
# ffuf - https://github.com/ffuf/ffuf
# katana - https://github.com/projectdiscovery/katana
# httpx - https://github.com/projectdiscovery/httpx

# Verify installations
python -c "
import subprocess
tools = ['subfinder', 'httpx', 'nuclei', 'ffuf', 'katana']
for tool in tools:
    try:
        result = subprocess.run([tool, '-version'], capture_output=True, text=True, timeout=5)
        print(f'{tool}: OK')
    except FileNotFoundError:
        print(f'{tool}: NOT FOUND')
    except Exception as e:
        print(f'{tool}: ERROR - {e}')
"
```

### 3.3 Directory Structure

```
tool-integration-framework/
├── core/
│   ├── __init__.py
│   ├── plugin_manager.py
│   ├── event_bus.py
│   ├── middleware.py
│   └── registry.py
├── adapters/
│   ├── __init__.py
│   ├── base.py
│   ├── subfinder_adapter.py
│   ├── httpx_adapter.py
│   ├── nuclei_adapter.py
│   ├── ffuf_adapter.py
│   └── katana_adapter.py
├── plugins/
│   ├── __init__.py
│   ├── recon_plugin.py
│   ├── scan_plugin.py
│   └── report_plugin.py
├── middleware/
│   ├── __init__.py
│   ├── auth.py
│   ├── rate_limiter.py
│   ├── transformer.py
│   ├── logger.py
│   └── circuit_breaker.py
├── config/
│   ├── default.yaml
│   └── tools.yaml
├── tests/
│   ├── test_adapters.py
│   ├── test_plugins.py
│   └── test_middleware.py
└── main.py
```

---

## 4. Methodology (Step-by-Step)

### Step 1: Build the Plugin Interface

```python
# core/plugin_interface.py
from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional
from dataclasses import dataclass
from enum import Enum
import time

class PluginStatus(Enum):
    UNLOADED = "unloaded"
    LOADED = "loaded"
    ACTIVE = "active"
    ERROR = "error"
    DISABLED = "disabled"

@dataclass
class PluginMetadata:
    name: str
    version: str
    author: str
    description: str
    dependencies: List[str]
    hooks: List[str]  # Which hooks this plugin provides

@dataclass
class ToolResult:
    success: bool
    data: Any
    raw_output: str
    error: Optional[str] = None
    duration: float = 0.0
    metadata: Dict = None

class SecurityToolPlugin(ABC):
    """Base interface for all security tool plugins."""

    @abstractmethod
    def get_metadata(self) -> PluginMetadata:
        """Return plugin metadata."""
        pass

    @abstractmethod
    def initialize(self, config: Dict) -> bool:
        """Initialize plugin with configuration."""
        pass

    @abstractmethod
    def execute(self, task_type: str, input_data: Any, context: Dict) -> ToolResult:
        """Execute a tool operation."""
        pass

    @abstractmethod
    def get_capabilities(self) -> List[str]:
        """Return list of capabilities this plugin provides."""
        pass

    @abstractmethod
    def health_check(self) -> bool:
        """Verify tool is available and working."""
        pass

    def on_load(self):
        """Called when plugin is loaded."""
        pass

    def on_unload(self):
        """Called when plugin is unloaded."""
        pass

    def on_error(self, error: Exception):
        """Called when plugin encounters an error."""
        pass

class ReconPlugin(SecurityToolPlugin):
    """Specialized interface for reconnaissance plugins."""

    @abstractmethod
    def enumerate_subdomains(self, domain: str, config: Dict) -> ToolResult:
        """Enumerate subdomains for a domain."""
        pass

    @abstractmethod
    def probe_hosts(self, hosts: List[str], config: Dict) -> ToolResult:
        """Probe hosts for live HTTP services."""
        pass

    @abstractmethod
    def discover_urls(self, urls: List[str], config: Dict) -> ToolResult:
        """Discover URLs through crawling."""
        pass

class ScanPlugin(SecurityToolPlugin):
    """Specialized interface for scanning plugins."""

    @abstractmethod
    def scan_urls(self, urls: List[str], config: Dict) -> ToolResult:
        """Scan URLs for vulnerabilities."""
        pass

    @abstractmethod
    def scan_ports(self, hosts: List[str], config: Dict) -> ToolResult:
        """Scan hosts for open ports."""
        pass

    @abstractmethod
    def fuzz_directory(self, base_url: str, wordlist: str, config: Dict) -> ToolResult:
        """Fuzz for hidden directories."""
        pass
```

### Step 2: Build the Plugin Manager

```python
# core/plugin_manager.py
import importlib
import os
from pathlib import Path
from typing import Dict, List, Optional, Type
from dataclasses import dataclass
import json
import sys

@dataclass
class PluginInfo:
    name: str
    instance: SecurityToolPlugin
    status: PluginStatus
    metadata: PluginMetadata
    config: Dict

class PluginManager:
    """Manages discovery, loading, and lifecycle of plugins."""

    def __init__(self, plugin_dirs: List[str] = None):
        self.plugins: Dict[str, PluginInfo] = {}
        self.plugin_dirs = plugin_dirs or ["plugins", "adapters"]
        self.hooks: Dict[str, List[str]] = {}  # hook_name -> [plugin_names]
        self._load_paths()

    def _load_paths(self):
        """Add plugin directories to Python path."""
        for dir_path in self.plugin_dirs:
            abs_path = os.path.abspath(dir_path)
            if abs_path not in sys.path:
                sys.path.insert(0, abs_path)

    def discover_plugins(self) -> List[str]:
        """Discover all available plugins in plugin directories."""
        discovered = []

        for plugin_dir in self.plugin_dirs:
            plugin_path = Path(plugin_dir)
            if not plugin_path.exists():
                continue

            for py_file in plugin_path.glob("**/*.py"):
                if py_file.name.startswith("_"):
                    continue

                module_name = py_file.stem
                try:
                    module = importlib.import_module(module_name)
                    # Look for classes that implement SecurityToolPlugin
                    for attr_name in dir(module):
                        attr = getattr(module, attr_name)
                        if (isinstance(attr, type) and
                            issubclass(attr, SecurityToolPlugin) and
                            attr is not SecurityToolPlugin and
                            attr is not ReconPlugin and
                            attr is not ScanPlugin):
                            discovered.append(attr_name)
                except ImportError as e:
                    print(f"Failed to import {module_name}: {e}")

        return discovered

    def load_plugin(self, plugin_class: Type[SecurityToolPlugin], config: Dict = None) -> bool:
        """Load a single plugin."""
        try:
            instance = plugin_class()
            metadata = instance.get_metadata()

            # Check dependencies
            for dep in metadata.dependencies:
                if dep not in self.plugins:
                    print(f"Missing dependency: {dep}")
                    return False

            # Initialize
            if not instance.initialize(config or {}):
                print(f"Failed to initialize {metadata.name}")
                return False

            # Register
            self.plugins[metadata.name] = PluginInfo(
                name=metadata.name,
                instance=instance,
                status=PluginStatus.ACTIVE,
                metadata=metadata,
                config=config or {},
            )

            # Register hooks
            for hook in metadata.hooks:
                if hook not in self.hooks:
                    self.hooks[hook] = []
                self.hooks[hook].append(metadata.name)

            instance.on_load()
            print(f"Loaded plugin: {metadata.name} v{metadata.version}")
            return True

        except Exception as e:
            print(f"Failed to load plugin: {e}")
            return False

    def load_all_plugins(self, config: Dict = None):
        """Discover and load all available plugins."""
        discovered = self.discover_plugins()
        print(f"Discovered {len(discovered)} plugins")

        for plugin_name in discovered:
            # Dynamic import
            for plugin_dir in self.plugin_dirs:
                plugin_path = Path(plugin_dir)
                for py_file in plugin_path.glob(f"**/{plugin_name.lower()}*.py"):
                    module_name = py_file.stem
                    try:
                        module = importlib.import_module(module_name)
                        for attr_name in dir(module):
                            attr = getattr(module, attr_name)
                            if (isinstance(attr, type) and
                                attr.__name__ == plugin_name):
                                self.load_plugin(attr, config)
                    except ImportError:
                        continue

    def get_plugin(self, name: str) -> Optional[PluginInfo]:
        """Get a loaded plugin by name."""
        return self.plugins.get(name)

    def get_plugins_for_hook(self, hook_name: str) -> List[PluginInfo]:
        """Get all plugins that implement a specific hook."""
        plugin_names = self.hooks.get(hook_name, [])
        return [self.plugins[name] for name in plugin_names if name in self.plugins]

    def execute_hook(self, hook_name: str, *args, **kwargs) -> List[ToolResult]:
        """Execute all plugins registered for a hook."""
        results = []
        plugins = self.get_plugins_for_hook(hook_name)

        for plugin_info in plugins:
            try:
                result = plugin_info.instance.execute(hook_name, args, kwargs)
                results.append(result)
            except Exception as e:
                plugin_info.instance.on_error(e)
                results.append(ToolResult(
                    success=False,
                    data=None,
                    raw_output="",
                    error=str(e)
                ))

        return results

    def unload_plugin(self, name: str):
        """Unload a plugin."""
        if name in self.plugins:
            plugin_info = self.plugins[name]
            plugin_info.instance.on_unload()
            plugin_info.status = PluginStatus.UNLOADED

            # Remove from hooks
            for hook_name, plugin_names in self.hooks.items():
                if name in plugin_names:
                    plugin_names.remove(name)

            del self.plugins[name]

    def get_status(self) -> Dict:
        """Get status of all loaded plugins."""
        return {
            name: {
                "status": info.status.value,
                "version": info.metadata.version,
                "hooks": info.metadata.hooks,
            }
            for name, info in self.plugins.items()
        }

# Usage
manager = PluginManager(plugin_dirs=["adapters", "plugins"])
manager.load_all_plugins(config={"threads": 50, "timeout": 10})

# Execute a hook
results = manager.execute_hook("enumerate_subdomains", domain="test-target.example.com")
```

### Step 3: Build the Adapter Framework

```python
# adapters/base.py
import subprocess
import json
import time
from typing import Any, Dict, List, Optional
from abc import ABC, abstractmethod
import shlex

class BaseToolAdapter(ABC):
    """Base class for all tool adapters."""

    def __init__(self, tool_path: str = None, config: Dict = None):
        self.tool_path = tool_path or self._find_tool()
        self.config = config or {}
        self.timeout = self.config.get("timeout", 300)

    @abstractmethod
    def _find_tool(self) -> str:
        """Find the tool binary path."""
        pass

    @abstractmethod
    def build_command(self, input_data: Any, config: Dict) -> List[str]:
        """Build command line arguments."""
        pass

    @abstractmethod
    def parse_output(self, stdout: str, stderr: str) -> Any:
        """Parse tool output into structured data."""
        pass

    def execute(self, input_data: Any, config: Dict = None) -> ToolResult:
        """Execute the tool with given input."""
        config = config or self.config
        start_time = time.time()

        try:
            cmd = self.build_command(input_data, config)
            print(f"Executing: {' '.join(cmd)}")

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=self.timeout,
            )

            duration = time.time() - start_time

            if result.returncode == 0:
                parsed = self.parse_output(result.stdout, result.stderr)
                return ToolResult(
                    success=True,
                    data=parsed,
                    raw_output=result.stdout,
                    duration=duration,
                )
            else:
                return ToolResult(
                    success=False,
                    data=None,
                    raw_output=result.stdout,
                    error=result.stderr,
                    duration=duration,
                )

        except subprocess.TimeoutExpired:
            return ToolResult(
                success=False,
                data=None,
                raw_output="",
                error=f"Tool timed out after {self.timeout}s",
                duration=time.time() - start_time,
            )
        except Exception as e:
            return ToolResult(
                success=False,
                data=None,
                raw_output="",
                error=str(e),
                duration=time.time() - start_time,
            )

    def health_check(self) -> bool:
        """Verify tool is available."""
        try:
            result = subprocess.run(
                [self.tool_path, "-version"],
                capture_output=True,
                timeout=5,
            )
            return result.returncode == 0
        except (FileNotFoundError, subprocess.TimeoutExpired):
            return False

# adapters/subfinder_adapter.py
class SubfinderAdapter(BaseToolAdapter):
    """Adapter for subfinder subdomain enumeration tool."""

    def _find_tool(self) -> str:
        import shutil
        path = shutil.which("subfinder")
        if not path:
            raise FileNotFoundError("subfinder not found in PATH")
        return path

    def build_command(self, input_data: Any, config: Dict) -> List[str]:
        domain = input_data if isinstance(input_data, str) else input_data.get("domain", "")
        cmd = [self.tool_path, "-d", domain, "-silent"]

        if config.get("timeout"):
            cmd.extend(["-timeout", str(config["timeout"])])
        if config.get("recursive"):
            cmd.append("-recursive")
        if config.get("sources"):
            cmd.extend(["-sources", ",".join(config["sources"])])

        return cmd

    def parse_output(self, stdout: str, stderr: str) -> List[str]:
        return [line.strip() for line in stdout.strip().split("\n") if line.strip()]

# adapters/httpx_adapter.py
class HttpxAdapter(BaseToolAdapter):
    """Adapter for httpx HTTP probing tool."""

    def _find_tool(self) -> str:
        import shutil
        path = shutil.which("httpx")
        if not path:
            raise FileNotFoundError("httpx not found in PATH")
        return path

    def build_command(self, input_data: Any, config: Dict) -> List[str]:
        # Write input to temp file
        import tempfile
        input_file = tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False)
        if isinstance(input_data, list):
            input_file.write("\n".join(input_data))
        else:
            input_file.write(str(input_data))
        input_file.close()

        cmd = [
            self.tool_path,
            "-l", input_file.name,
            "-silent",
            "-json",
            "-threads", str(config.get("threads", 50)),
            "-timeout", str(config.get("timeout", 10)),
        ]

        if config.get("follow_redirects"):
            cmd.append("-follow-redirects")
        if config.get("status_codes"):
            cmd.extend(["-status-codes", ",".join(str(c) for c in config["status_codes"])])

        return cmd

    def parse_output(self, stdout: str, stderr: str) -> List[Dict]:
        results = []
        for line in stdout.strip().split("\n"):
            if line.strip():
                try:
                    results.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
        return results

# adapters/nuclei_adapter.py
class NucleiAdapter(BaseToolAdapter):
    """Adapter for nuclei vulnerability scanner."""

    def _find_tool(self) -> str:
        import shutil
        path = shutil.which("nuclei")
        if not path:
            raise FileNotFoundError("nuclei not found in PATH")
        return path

    def build_command(self, input_data: Any, config: Dict) -> List[str]:
        import tempfile
        input_file = tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False)
        if isinstance(input_data, list):
            input_file.write("\n".join(input_data))
        else:
            input_file.write(str(input_data))
        input_file.close()

        cmd = [
            self.tool_path,
            "-l", input_file.name,
            "-silent",
            "-json",
        ]

        if config.get("severity"):
            cmd.extend(["-severity", ",".join(config["severity"])])
        if config.get("rate_limit"):
            cmd.extend(["-rate-limit", str(config["rate_limit"])])
        if config.get("templates"):
            cmd.extend(["-t", config["templates"]])

        return cmd

    def parse_output(self, stdout: str, stderr: str) -> List[Dict]:
        results = []
        for line in stdout.strip().split("\n"):
            if line.strip():
                try:
                    results.append(json.loads(line))
                except json.JSONDecodeError:
                    continue
        return results

# adapters/ffuf_adapter.py
class FfufAdapter(BaseToolAdapter):
    """Adapter for ffuf directory fuzzer."""

    def _find_tool(self) -> str:
        import shutil
        path = shutil.which("ffuf")
        if not path:
            raise FileNotFoundError("ffuf not found in PATH")
        return path

    def build_command(self, input_data: Any, config: Dict) -> List[str]:
        base_url = input_data if isinstance(input_data, str) else input_data.get("url", "")
        wordlist = config.get("wordlist", "/usr/share/wordlists/common.txt")

        cmd = [
            self.tool_path,
            "-u", f"{base_url}/FUZZ",
            "-w", wordlist,
            "-o", "/dev/stdout",
            "-of", "json",
        ]

        if config.get("threads"):
            cmd.extend(["-t", str(config["threads"])])
        if config.get("extensions"):
            cmd.extend(["-e", config["extensions"]])
        if config.get("filters"):
            for filt in config["filters"]:
                cmd.extend(["-fc", str(filt)])

        return cmd

    def parse_output(self, stdout: str, stderr: str) -> List[Dict]:
        try:
            data = json.loads(stdout)
            return data.get("results", [])
        except json.JSONDecodeError:
            return []
```

### Step 4: Build the Event Bus

```python
# core/event_bus.py
from typing import Callable, Dict, List, Any, Optional
from dataclasses import dataclass, field
import time
import threading
from collections import defaultdict
import queue

@dataclass
class Event:
    event_type: str
    source: str
    data: Any
    timestamp: float = field(default_factory=time.time)
    metadata: Dict = field(default_factory=dict)

class EventBus:
    """In-process event bus for decoupled component communication."""

    def __init__(self, max_queue_size: int = 10000):
        self.subscribers: Dict[str, List[Callable]] = defaultdict(list)
        self.event_history: List[Event] = []
        self.max_history = 1000
        self.event_queue = queue.Queue(maxsize=max_queue_size)
        self._running = False
        self._worker_thread = None
        self._lock = threading.Lock()

    def subscribe(self, event_type: str, callback: Callable):
        """Subscribe to an event type."""
        with self._lock:
            self.subscribers[event_type].append(callback)

    def unsubscribe(self, event_type: str, callback: Callable):
        """Unsubscribe from an event type."""
        with self._lock:
            if event_type in self.subscribers:
                self.subscribers[event_type] = [
                    cb for cb in self.subscribers[event_type] if cb != callback
                ]

    def publish(self, event: Event):
        """Publish an event synchronously."""
        # Store in history
        with self._lock:
            self.event_history.append(event)
            if len(self.event_history) > self.max_history:
                self.event_history = self.event_history[-self.max_history:]

        # Notify subscribers
        callbacks = self.subscribers.get(event.event_type, [])
        wildcards = self.subscribers.get("*", [])

        for callback in callbacks + wildcards:
            try:
                callback(event)
            except Exception as e:
                print(f"Error in event handler for {event.event_type}: {e}")

    def publish_async(self, event: Event):
        """Publish an event asynchronously."""
        try:
            self.event_queue.put_nowait(event)
        except queue.Full:
            print(f"Event queue full, dropping event: {event.event_type}")

    def start(self):
        """Start async event processing."""
        self._running = True
        self._worker_thread = threading.Thread(target=self._process_events, daemon=True)
        self._worker_thread.start()

    def stop(self):
        """Stop async event processing."""
        self._running = False
        if self._worker_thread:
            self._worker_thread.join(timeout=5)

    def _process_events(self):
        """Process events from queue."""
        while self._running:
            try:
                event = self.event_queue.get(timeout=1)
                self.publish(event)
            except queue.Empty:
                continue

    def get_history(self, event_type: Optional[str] = None, limit: int = 100) -> List[Event]:
        """Get event history."""
        with self._lock:
            if event_type:
                events = [e for e in self.event_history if e.event_type == event_type]
            else:
                events = self.event_history.copy()
            return events[-limit:]

    def get_stats(self) -> Dict:
        """Get event bus statistics."""
        with self._lock:
            type_counts = defaultdict(int)
            for event in self.event_history:
                type_counts[event.event_type] += 1

            return {
                "total_events": len(self.event_history),
                "queue_size": self.event_queue.qsize(),
                "event_types": dict(type_counts),
                "subscriber_count": sum(len(cbs) for cbs in self.subscribers.values()),
            }

# Usage
bus = EventBus()
bus.start()

# Subscribe to events
def on_subdomain_found(event: Event):
    print(f"New subdomain: {event.data}")

def on_vuln_detected(event: Event):
    print(f"Vulnerability found: {event.data}")

bus.subscribe("subdomain.found", on_subdomain_found)
bus.subscribe("vuln.detected", on_vuln_detected)

# Publish events
bus.publish_async(Event(
    event_type="subdomain.found",
    source="subfinder",
    data={"subdomain": "api.test-target.example.com"}
))
```

### Step 5: Build the Middleware Pipeline

```python
# middleware/base.py
from typing import Any, Callable, Dict, Optional
from dataclasses import dataclass
import time

@dataclass
class MiddlewareContext:
    """Context passed through middleware pipeline."""
    request: Any
    response: Any = None
    metadata: Dict = None
    error: Optional[Exception] = None

    def __post_init__(self):
        if self.metadata is None:
            self.metadata = {}

class Middleware:
    """Base middleware class."""

    def __init__(self, name: str):
        self.name = name

    def process_request(self, context: MiddlewareContext) -> MiddlewareContext:
        """Process request before it reaches the handler."""
        return context

    def process_response(self, context: MiddlewareContext) -> MiddlewareContext:
        """Process response after the handler."""
        return context

    def on_error(self, context: MiddlewareContext, error: Exception) -> MiddlewareContext:
        """Handle errors."""
        context.error = error
        return context

class MiddlewarePipeline:
    """Manages and executes middleware chain."""

    def __init__(self):
        self.middlewares: List[Middleware] = []

    def add(self, middleware: Middleware):
        """Add middleware to the pipeline."""
        self.middlewares.append(middleware)

    def remove(self, name: str):
        """Remove middleware by name."""
        self.middlewares = [m for m in self.middlewares if m.name != name]

    def execute(self, handler: Callable, request: Any) -> Any:
        """Execute handler through middleware pipeline."""
        context = MiddlewareContext(request=request)

        # Process request through all middleware
        for middleware in self.middlewares:
            try:
                context = middleware.process_request(context)
            except Exception as e:
                context = middleware.on_error(context, e)
                if context.error:
                    raise context.error

        # Execute handler
        try:
            context.response = handler(context.request)
        except Exception as e:
            context.error = e
            # Process error through middleware
            for middleware in reversed(self.middlewares):
                context = middleware.on_error(context, e)
            if context.error:
                raise context.error

        # Process response through all middleware
        for middleware in reversed(self.middlewares):
            try:
                context = middleware.process_response(context)
            except Exception as e:
                context = middleware.on_error(context, e)

        return context.response

# middleware/auth.py
class AuthMiddleware(Middleware):
    """Adds authentication to requests."""

    def __init__(self, api_key: str = None, header: str = "Authorization"):
        super().__init__("auth")
        self.api_key = api_key
        self.header = header

    def process_request(self, context: MiddlewareContext) -> MiddlewareContext:
        if self.api_key:
            context.metadata[self.header] = f"Bearer {self.api_key}"
        return context

# middleware/rate_limiter.py
import time
from collections import defaultdict

class RateLimiterMiddleware(Middleware):
    """Rate limits requests per tool."""

    def __init__(self, max_requests: int = 100, window_seconds: int = 60):
        super().__init__("rate_limiter")
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests: Dict[str, List[float]] = defaultdict(list)

    def process_request(self, context: MiddlewareContext) -> MiddlewareContext:
        tool_name = context.metadata.get("tool_name", "default")
        now = time.time()

        # Clean old requests
        self.requests[tool_name] = [
            t for t in self.requests[tool_name]
            if now - t < self.window_seconds
        ]

        # Check rate limit
        if len(self.requests[tool_name]) >= self.max_requests:
            wait_time = self.window_seconds - (now - self.requests[tool_name][0])
            if wait_time > 0:
                time.sleep(wait_time)
                self.requests[tool_name] = self.requests[tool_name][1:]

        self.requests[tool_name].append(now)
        return context

# middleware/transformer.py
class TransformerMiddleware(Middleware):
    """Transforms data between tools."""

    def __init__(self, transforms: Dict[str, Callable] = None):
        super().__init__("transformer")
        self.transforms = transforms or {}

    def process_request(self, context: MiddlewareContext) -> MiddlewareContext:
        transform_name = context.metadata.get("transform_request")
        if transform_name and transform_name in self.transforms:
            context.request = self.transforms[transform_name](context.request)
        return context

    def process_response(self, context: MiddlewareContext) -> MiddlewareContext:
        transform_name = context.metadata.get("transform_response")
        if transform_name and transform_name in self.transforms:
            context.response = self.transforms[transform_name](context.response)
        return context

# middleware/circuit_breaker.py
class CircuitBreakerMiddleware(Middleware):
    """Circuit breaker for failing tools."""

    def __init__(self, failure_threshold: int = 5, recovery_timeout: int = 60):
        super().__init__("circuit_breaker")
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures: Dict[str, int] = defaultdict(int)
        self.last_failure: Dict[str, float] = {}
        self.state: Dict[str, str] = {}  # closed, open, half-open

    def process_request(self, context: MiddlewareContext) -> MiddlewareContext:
        tool_name = context.metadata.get("tool_name", "default")

        if self.state.get(tool_name) == "open":
            last_fail = self.last_failure.get(tool_name, 0)
            if time.time() - last_fail > self.recovery_timeout:
                self.state[tool_name] = "half-open"
            else:
                raise Exception(f"Circuit breaker open for {tool_name}")

        return context

    def process_response(self, context: MiddlewareContext) -> MiddlewareContext:
        tool_name = context.metadata.get("tool_name", "default")

        if context.error:
            self.failures[tool_name] += 1
            self.last_failure[tool_name] = time.time()

            if self.failures[tool_name] >= self.failure_threshold:
                self.state[tool_name] = "open"
                print(f"Circuit breaker opened for {tool_name}")
        else:
            self.failures[tool_name] = 0
            self.state[tool_name] = "closed"

        return context
```

### Step 6: Build the Registry and Configuration

```python
# core/registry.py
from typing import Dict, Any, Optional
import json
from pathlib import Path

class ToolRegistry:
    """Central registry for all tools and their configurations."""

    def __init__(self, config_path: str = "config/tools.yaml"):
        self.config_path = Path(config_path)
        self.tools: Dict[str, Dict] = {}
        self.configs: Dict[str, Dict] = {}
        self._load_config()

    def _load_config(self):
        """Load tool configurations."""
        if self.config_path.exists():
            import yaml
            with open(self.config_path) as f:
                data = yaml.safe_load(f)
                self.configs = data.get("tools", {})

    def register(self, name: str, adapter: BaseToolAdapter, config: Dict = None):
        """Register a tool adapter."""
        self.tools[name] = {
            "adapter": adapter,
            "config": config or self.configs.get(name, {}),
            "status": "registered",
        }

    def get_adapter(self, name: str) -> Optional[BaseToolAdapter]:
        """Get tool adapter by name."""
        tool = self.tools.get(name)
        if tool:
            return tool["adapter"]
        return None

    def get_config(self, name: str) -> Dict:
        """Get tool configuration."""
        return self.tools.get(name, {}).get("config", {})

    def list_tools(self) -> Dict[str, str]:
        """List all registered tools."""
        return {name: tool["status"] for name, tool in self.tools.items()}

    def health_check_all(self) -> Dict[str, bool]:
        """Check health of all registered tools."""
        results = {}
        for name, tool in self.tools.items():
            try:
                results[name] = tool["adapter"].health_check()
            except Exception:
                results[name] = False
        return results

# Usage
registry = ToolRegistry("config/tools.yaml")
registry.register("subfinder", SubfinderAdapter())
registry.register("httpx", HttpxAdapter())
registry.register("nuclei", NucleiAdapter())
registry.register("ffuf", FfufAdapter())

# Check health
health = registry.health_check_all()
print(f"Tool health: {health}")
```

---

## 5. Tool Arsenal with Commands

### 5.1 Unified Tool Runner

```python
# tool_runner.py
import asyncio
from typing import Dict, List, Any
import json
from pathlib import Path
import time

class UnifiedToolRunner:
    """Unified interface for running all security tools."""

    def __init__(self, registry: ToolRegistry, event_bus: EventBus = None):
        self.registry = registry
        self.event_bus = event_bus
        self.pipeline = MiddlewarePipeline()
        self._setup_default_middleware()

    def _setup_default_middleware(self):
        """Set up default middleware stack."""
        self.pipeline.add(RateLimiterMiddleware(max_requests=100, window_seconds=60))
        self.pipeline.add(CircuitBreakerMiddleware(failure_threshold=5, recovery_timeout=60))

    def run_tool(self, tool_name: str, input_data: Any, config: Dict = None) -> ToolResult:
        """Run a single tool through the pipeline."""
        adapter = self.registry.get_adapter(tool_name)
        if not adapter:
            return ToolResult(
                success=False,
                data=None,
                raw_output="",
                error=f"Tool not registered: {tool_name}"
            )

        config = config or self.registry.get_config(tool_name)

        # Publish start event
        if self.event_bus:
            self.event_bus.publish_async(Event(
                event_type="tool.start",
                source=tool_name,
                data={"input": str(input_data)[:100]},
            ))

        # Execute through middleware
        def handler(request):
            return adapter.execute(request, config)

        context = MiddlewareContext(
            request=input_data,
            metadata={"tool_name": tool_name}
        )

        start_time = time.time()
        try:
            result = self.pipeline.execute(handler, input_data)
        except Exception as e:
            result = ToolResult(
                success=False,
                data=None,
                raw_output="",
                error=str(e)
            )

        # Publish completion event
        if self.event_bus:
            self.event_bus.publish_async(Event(
                event_type="tool.complete",
                source=tool_name,
                data={
                    "success": result.success,
                    "duration": result.duration,
                    "error": result.error,
                },
            ))

        return result

    async def run_tool_async(self, tool_name: str, input_data: Any, config: Dict = None) -> ToolResult:
        """Run a tool asynchronously."""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, self.run_tool, tool_name, input_data, config)

    def run_pipeline(self, stages: List[Dict]) -> List[ToolResult]:
        """Run a sequence of tools as a pipeline."""
        results = []
        current_input = None

        for stage in stages:
            tool_name = stage["tool"]
            input_data = stage.get("input", current_input)
            config = stage.get("config", {})

            result = self.run_tool(tool_name, input_data, config)
            results.append(result)

            if result.success:
                current_input = result.data
            else:
                print(f"Pipeline failed at stage {tool_name}: {result.error}")
                break

        return results

# Usage
runner = UnifiedToolRunner(registry, event_bus=bus)

# Run single tool
result = runner.run_tool("subfinder", "test-target.example.com")
print(f"Subdomains: {result.data}")

# Run pipeline
pipeline_results = runner.run_pipeline([
    {"tool": "subfinder", "input": "test-target.example.com"},
    {"tool": "httpx", "config": {"threads": 50}},
    {"tool": "nuclei", "config": {"severity": ["high", "critical"]}},
])
```

### 5.2 Tool Health Monitor

```python
# health_monitor.py
import asyncio
import json
from typing import Dict
from pathlib import Path
import time
from datetime import datetime

class ToolHealthMonitor:
    """Monitor health and availability of all tools."""

    def __init__(self, registry: ToolRegistry, check_interval: int = 300):
        self.registry = registry
        self.check_interval = check_interval
        self.health_history: Dict[str, List[Dict]] = {}
        self._running = False

    async def check_health(self) -> Dict[str, bool]:
        """Check health of all tools."""
        results = {}
        for name, tool_info in self.registry.tools.items():
            try:
                adapter = tool_info["adapter"]
                is_healthy = adapter.health_check()
                results[name] = is_healthy

                # Record history
                if name not in self.health_history:
                    self.health_history[name] = []

                self.health_history[name].append({
                    "timestamp": time.time(),
                    "healthy": is_healthy,
                })

                # Keep only last 100 checks
                self.health_history[name] = self.health_history[name][-100:]

            except Exception as e:
                results[name] = False

        return results

    async def monitor_loop(self):
        """Continuous health monitoring loop."""
        self._running = True
        while self._running:
            health = await self.check_health()
            unhealthy = [name for name, healthy in health.items() if not healthy]

            if unhealthy:
                print(f"[{datetime.now()}] Unhealthy tools: {', '.join(unhealthy)}")
            else:
                print(f"[{datetime.now()}] All tools healthy")

            await asyncio.sleep(self.check_interval)

    def get_availability_stats(self) -> Dict[str, float]:
        """Calculate availability percentage for each tool."""
        stats = {}
        for name, history in self.health_history.items():
            if history:
                healthy_count = sum(1 for h in history if h["healthy"])
                stats[name] = (healthy_count / len(history)) * 100
            else:
                stats[name] = 0.0
        return stats

    def export_report(self, output_path: str = "health_report.json"):
        """Export health monitoring report."""
        report = {
            "timestamp": datetime.now().isoformat(),
            "current_health": asyncio.run(self.check_health()),
            "availability_stats": self.get_availability_stats(),
            "history": {
                name: history[-10:]  # Last 10 entries
                for name, history in self.health_history.items()
            },
        }

        with open(output_path, "w") as f:
            json.dump(report, f, indent=2)

        return report
```

### 5.3 Plugin Hot-Reloader

```python
# hot_reloader.py
import importlib
import os
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class PluginHotReloader(FileSystemEventHandler):
    """Hot-reload plugins when files change."""

    def __init__(self, plugin_manager: PluginManager):
        self.plugin_manager = plugin_manager
        self.observer = Observer()
        self._modified_files = set()

    def on_modified(self, event):
        if event.src_path.endswith(".py"):
            self._modified_files.add(event.src_path)
            print(f"Detected change in: {event.src_path}")

    def start_watching(self, plugin_dirs: List[str]):
        """Start watching plugin directories for changes."""
        for dir_path in plugin_dirs:
            self.observer.schedule(self, dir_path, recursive=True)
        self.observer.start()

    def stop_watching(self):
        """Stop watching for changes."""
        self.observer.stop()
        self.observer.join()

    def reload_changed_plugins(self):
        """Reload plugins that have been modified."""
        reloaded = []

        for file_path in self._modified_files:
            module_name = Path(file_path).stem

            # Find which plugin this belongs to
            for name, plugin_info in self.plugin_manager.plugins.items():
                plugin_file = Path(plugin_info.metadata.name.lower()).with_suffix(".py")
                if plugin_file.exists() and plugin_file.samefile(file_path):
                    # Reload module
                    try:
                        module = importlib.import_module(module_name)
                        importlib.reload(module)

                        # Re-initialize plugin
                        plugin_class = getattr(module, plugin_info.metadata.name)
                        new_instance = plugin_class()
                        new_instance.initialize(plugin_info.config)

                        plugin_info.instance = new_instance
                        reloaded.append(name)
                        print(f"Reloaded plugin: {name}")

                    except Exception as e:
                        print(f"Failed to reload {name}: {e}")

        self._modified_files.clear()
        return reloaded

# Usage
reloader = PluginHotReloader(manager)
reloader.start_watching(["adapters", "plugins"])

# In main loop
try:
    while True:
        time.sleep(1)
        reloaded = reloader.reload_changed_plugins()
        if reloaded:
            print(f"Reloaded plugins: {reloaded}")
except KeyboardInterrupt:
    reloader.stop_watching()
```

---

## 6. Real-World Examples

### 6.1 Complete Integration Platform

```python
# platform.py
import asyncio
import json
from typing import Dict, List
from pathlib import Path
import time

class SecurityToolPlatform:
    """Complete security tool integration platform."""

    def __init__(self, config_path: str = "config/platform.yaml"):
        self.config = self._load_config(config_path)
        self.plugin_manager = PluginManager(self.config.get("plugin_dirs", ["adapters", "plugins"]))
        self.event_bus = EventBus()
        self.registry = ToolRegistry(self.config.get("tools_config", "config/tools.yaml"))
        self.runner = UnifiedToolRunner(self.registry, self.event_bus)
        self.health_monitor = ToolHealthMonitor(self.registry)

        # Set up event handlers
        self._setup_event_handlers()

    def _load_config(self, path: str) -> Dict:
        """Load platform configuration."""
        config_path = Path(path)
        if config_path.exists():
            import yaml
            with open(config_path) as f:
                return yaml.safe_load(f)
        return {}

    def _setup_event_handlers(self):
        """Set up event handlers for platform events."""
        self.event_bus.subscribe("vuln.detected", self._on_vuln_detected)
        self.event_bus.subscribe("tool.error", self._on_tool_error)
        self.event_bus.subscribe("scan.completed", self._on_scan_completed)

    def _on_vuln_detected(self, event: Event):
        """Handle vulnerability detection."""
        vuln = event.data
        print(f"[VULN] {vuln.get('type', 'Unknown')} at {vuln.get('endpoint', 'N/A')}")

    def _on_tool_error(self, event: Event):
        """Handle tool errors."""
        error = event.data
        print(f"[ERROR] {error.get('tool', 'Unknown')}: {error.get('message', 'N/A')}")

    def _on_scan_completed(self, event: Event):
        """Handle scan completion."""
        scan = event.data
        print(f"[SCAN] Completed: {scan.get('tool', 'N/A')} in {scan.get('duration', 0):.1f}s")

    async def initialize(self):
        """Initialize the platform."""
        print("Initializing Security Tool Platform...")

        # Start event bus
        self.event_bus.start()

        # Load plugins
        self.plugin_manager.load_all_plugins(self.config.get("plugin_config", {}))

        # Register adapters
        self._register_default_adapters()

        # Start health monitoring
        asyncio.create_task(self.health_monitor.monitor_loop())

        print(f"Platform initialized with {len(self.registry.tools)} tools")

    def _register_default_adapters(self):
        """Register default tool adapters."""
        default_adapters = {
            "subfinder": SubfinderAdapter,
            "httpx": HttpxAdapter,
            "nuclei": NucleiAdapter,
            "ffuf": FfufAdapter,
        }

        for name, adapter_class in default_adapters.items():
            try:
                adapter = adapter_class(config=self.config.get("tool_configs", {}).get(name, {}))
                self.registry.register(name, adapter)
            except Exception as e:
                print(f"Failed to register {name}: {e}")

    async def run_scan(self, target: str, scan_type: str = "full") -> Dict:
        """Run a complete scan on target."""
        scan_id = f"scan_{int(time.time())}"
        print(f"Starting scan {scan_id} for {target}")

        start_time = time.time()

        if scan_type == "full":
            results = await self._run_full_scan(target)
        elif scan_type == "recon":
            results = await self._run_recon_scan(target)
        elif scan_type == "vuln":
            results = await self._run_vuln_scan(target)
        else:
            raise ValueError(f"Unknown scan type: {scan_type}")

        duration = time.time() - start_time

        # Publish completion event
        self.event_bus.publish_async(Event(
            event_type="scan.completed",
            source="platform",
            data={
                "scan_id": scan_id,
                "target": target,
                "scan_type": scan_type,
                "duration": duration,
                "results_summary": self._summarize_results(results),
            }
        ))

        return {
            "scan_id": scan_id,
            "target": target,
            "duration": duration,
            "results": results,
        }

    async def _run_full_scan(self, target: str) -> Dict:
        """Run full reconnaissance and vulnerability scan."""
        results = {}

        # Stage 1: Subdomain enumeration
        print("[1/4] Enumerating subdomains...")
        subdomains = await self.runner.run_tool_async("subfinder", target)
        results["subdomains"] = subdomains.data if subdomains.success else []

        # Stage 2: HTTP probing
        print("[2/4] Probing live hosts...")
        if results["subdomains"]:
            live_hosts = await self.runner.run_tool_async("httpx", results["subdomains"])
            results["live_hosts"] = live_hosts.data if live_hosts.success else []
        else:
            results["live_hosts"] = []

        # Stage 3: URL crawling
        print("[3/4] Crawling for URLs...")
        if results["live_hosts"]:
            urls = []
            for host in results["live_hosts"][:10]:  # Limit to 10 hosts
                crawled = await self.runner.run_tool_async("katana", host.get("url", host))
                if crawled.success:
                    urls.extend(crawled.data if isinstance(crawled.data, list) else [])
            results["urls"] = list(set(urls))
        else:
            results["urls"] = []

        # Stage 4: Vulnerability scanning
        print("[4/4] Scanning for vulnerabilities...")
        if results["urls"]:
            vulns = await self.runner.run_tool_async(
                "nuclei",
                results["urls"][:100],  # Limit to 100 URLs
                config={"severity": ["medium", "high", "critical"]}
            )
            results["vulnerabilities"] = vulns.data if vulns.success else []
        else:
            results["vulnerabilities"] = []

        return results

    async def _run_recon_scan(self, target: str) -> Dict:
        """Run reconnaissance only."""
        results = {}

        subdomains = await self.runner.run_tool_async("subfinder", target)
        results["subdomains"] = subdomains.data if subdomains.success else []

        if results["subdomains"]:
            live_hosts = await self.runner.run_tool_async("httpx", results["subdomains"])
            results["live_hosts"] = live_hosts.data if live_hosts.success else []
        else:
            results["live_hosts"] = []

        return results

    async def _run_vuln_scan(self, target: str) -> Dict:
        """Run vulnerability scan on known URLs."""
        results = {}

        # Assume we have URLs from previous recon
        urls_file = Path(f"output/{target}/crawled_urls.json")
        if urls_file.exists():
            with open(urls_file) as f:
                urls = json.load(f)
        else:
            urls = [f"http://{target}"]

        vulns = await self.runner.run_tool_async(
            "nuclei",
            urls,
            config={"severity": ["high", "critical"]}
        )
        results["vulnerabilities"] = vulns.data if vulns.success else []

        return results

    def _summarize_results(self, results: Dict) -> Dict:
        """Summarize scan results."""
        return {
            "subdomains_count": len(results.get("subdomains", [])),
            "live_hosts_count": len(results.get("live_hosts", [])),
            "urls_count": len(results.get("urls", [])),
            "vulnerabilities_count": len(results.get("vulnerabilities", [])),
        }

# Initialize and run platform
async def main():
    platform = SecurityToolPlatform()
    await platform.initialize()

    # Run scan
    results = await platform.run_scan("test-target.example.com", scan_type="full")

    # Save results
    output_path = Path(f"output/{results['scan_id']}.json")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(results, f, indent=2, default=str)

    print(f"\nScan completed: {results['scan_id']}")
    print(f"Results saved to: {output_path}")

if __name__ == "__main__":
    asyncio.run(main())
```

### 6.2 Custom Tool Integration Example

```python
# custom_tool_example.py
import subprocess
import json
from typing import Any, Dict, List

class CustomNmapAdapter(BaseToolAdapter):
    """Custom adapter for nmap port scanner."""

    def _find_tool(self) -> str:
        import shutil
        path = shutil.which("nmap")
        if not path:
            raise FileNotFoundError("nmap not found in PATH")
        return path

    def build_command(self, input_data: Any, config: Dict) -> List[str]:
        targets = input_data if isinstance(input_data, list) else [input_data]

        cmd = [
            self.tool_path,
            "-sV",  # Service detection
            "-sC",  # Default scripts
            "-T4",  # Aggressive timing
            "-oX", "-",  # Output XML to stdout
        ]

        if config.get("ports"):
            cmd.extend(["-p", config["ports"]])
        if config.get("scripts"):
            cmd.extend(["--script", config["scripts"]])

        cmd.extend(targets)

        return cmd

    def parse_output(self, stdout: str, stderr: str) -> List[Dict]:
        """Parse nmap XML output."""
        import xml.etree.ElementTree as ET

        try:
            root = ET.fromstring(stdout)
            hosts = []

            for host in root.findall(".//host"):
                host_data = {
                    "ip": "",
                    "hostname": "",
                    "ports": [],
                }

                # Get IP
                addr = host.find("address[@addrtype='ipv4']")
                if addr is not None:
                    host_data["ip"] = addr.get("addr", "")

                # Get hostname
                hostname = host.find(".//hostname")
                if hostname is not None:
                    host_data["hostname"] = hostname.get("name", "")

                # Get ports
                for port in host.findall(".//port"):
                    port_data = {
                        "port": port.get("portid", ""),
                        "protocol": port.get("protocol", ""),
                        "state": "",
                        "service": "",
                        "version": "",
                    }

                    state = port.find("state")
                    if state is not None:
                        port_data["state"] = state.get("state", "")

                    service = port.find("service")
                    if service is not None:
                        port_data["service"] = service.get("name", "")
                        port_data["version"] = service.get("version", "")

                    host_data["ports"].append(port_data)

                hosts.append(host_data)

            return hosts

        except ET.ParseError as e:
            print(f"Failed to parse nmap output: {e}")
            return []

# Register and use
nmap_adapter = CustomNmapAdapter(config={"timeout": 600})
registry.register("nmap", nmap_adapter)

# Run port scan
result = runner.run_tool("nmap", ["test-target.example.com"], config={"ports": "1-1000"})
print(f"Open ports: {json.dumps(result.data, indent=2)}")
```

---

## 7. Common Pitfalls

### 7.1 Plugin Dependency Conflicts

```python
# dependency_resolver.py
from typing import Dict, List, Set
from collections import defaultdict

class DependencyResolver:
    """Resolve plugin dependencies and detect conflicts."""

    def __init__(self):
        self.plugins: Dict[str, List[str]] = {}
        self.versions: Dict[str, str] = {}

    def register(self, name: str, dependencies: List[str], version: str = "1.0"):
        """Register a plugin with its dependencies."""
        self.plugins[name] = dependencies
        self.versions[name] = version

    def resolve(self) -> List[str]:
        """Resolve dependencies and return load order."""
        # Topological sort
        in_degree = defaultdict(int)
        graph = defaultdict(list)

        for name, deps in self.plugins.items():
            for dep in deps:
                graph[dep].append(name)
                in_degree[name] += 1

        queue = [n for n in self.plugins if in_degree[n] == 0]
        order = []

        while queue:
            node = queue.pop(0)
            order.append(node)
            for neighbor in graph[node]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

        if len(order) != len(self.plugins):
            raise ValueError("Circular dependency detected")

        return order

    def detect_conflicts(self) -> List[str]:
        """Detect version conflicts."""
        conflicts = []
        # Simple version conflict detection
        # In production, use semantic versioning library
        return conflicts

# Usage
resolver = DependencyResolver()
resolver.register("subfinder_adapter", [], "2.0")
resolver.register("httpx_adapter", [], "1.0")
resolver.register("recon_plugin", ["subfinder_adapter", "httpx_adapter"], "1.0")
resolver.register("scan_plugin", ["httpx_adapter"], "1.0")

load_order = resolver.resolve()
print(f"Load order: {load_order}")
```

### 7.2 Memory Leaks in Long-Running Processes

```python
# resource_manager.py
import gc
import psutil
import os
from typing import Dict
import threading
import time

class ResourceManager:
    """Monitor and manage resource usage in long-running processes."""

    def __init__(self, memory_limit_mb: int = 2048, cpu_limit_percent: int = 80):
        self.memory_limit = memory_limit_mb * 1024 * 1024
        self.cpu_limit = cpu_limit_percent
        self.process = psutil.Process(os.getpid())
        self._monitoring = False
        self._monitor_thread = None

    def start_monitoring(self, interval: int = 30):
        """Start resource monitoring."""
        self._monitoring = True
        self._monitor_thread = threading.Thread(
            target=self._monitor_loop,
            args=(interval,),
            daemon=True
        )
        self._monitor_thread.start()

    def stop_monitoring(self):
        """Stop resource monitoring."""
        self._monitoring = False
        if self._monitor_thread:
            self._monitor_thread.join(timeout=5)

    def _monitor_loop(self, interval: int):
        """Monitor resources periodically."""
        while self._monitoring:
            usage = self.get_usage()

            # Check memory
            if usage["memory_mb"] > self.memory_limit / (1024 * 1024):
                print(f"WARNING: Memory usage high: {usage['memory_mb']:.1f} MB")
                self._cleanup_memory()

            # Check CPU
            if usage["cpu_percent"] > self.cpu_limit:
                print(f"WARNING: CPU usage high: {usage['cpu_percent']:.1f}%")

            time.sleep(interval)

    def get_usage(self) -> Dict:
        """Get current resource usage."""
        mem_info = self.process.memory_info()
        return {
            "memory_mb": mem_info.rss / (1024 * 1024),
            "cpu_percent": self.process.cpu_percent(),
            "threads": self.process.num_threads(),
            "open_files": len(self.process.open_files()),
        }

    def _cleanup_memory(self):
        """Perform memory cleanup."""
        gc.collect()
        # Clear any caches
        # In production, implement specific cleanup for your data structures

# Usage
resource_manager = ResourceManager(memory_limit_mb=4096)
resource_manager.start_monitoring(interval=30)
```

### 7.3 Tool Output Parsing Failures

```python
# robust_parser.py
import re
import json
from typing import Any, Optional

class RobustParser:
    """Parse tool outputs with fallback strategies."""

    @staticmethod
    def parse_json_or_lines(raw_output: str) -> Any:
        """Try JSON parsing, fall back to line-by-line."""
        # Try JSON first
        try:
            return json.loads(raw_output)
        except json.JSONDecodeError:
            pass

        # Try JSON lines
        lines = raw_output.strip().split("\n")
        results = []
        for line in lines:
            line = line.strip()
            if not line:
                continue
            try:
                results.append(json.loads(line))
            except json.JSONDecodeError:
                continue

        if results:
            return results

        # Return raw lines
        return [l for l in lines if l.strip()]

    @staticmethod
    def extract_json_from_text(text: str) -> Optional[Any]:
        """Extract JSON objects from mixed text output."""
        # Find JSON-like patterns
        json_patterns = [
            r'\{[^{}]*\}',  # Simple objects
            r'\[[^\[\]]*\]',  # Simple arrays
        ]

        for pattern in json_patterns:
            matches = re.findall(pattern, text, re.DOTALL)
            for match in matches:
                try:
                    return json.loads(match)
                except json.JSONDecodeError:
                    continue

        return None

    @staticmethod
    def normalize_output(data: Any, target_format: str = "list") -> Any:
        """Normalize output to expected format."""
        if target_format == "list":
            if isinstance(data, list):
                return data
            elif isinstance(data, dict):
                return [data]
            elif isinstance(data, str):
                return [data]
            else:
                return [str(data)]

        elif target_format == "dict":
            if isinstance(data, dict):
                return data
            elif isinstance(data, list) and len(data) > 0:
                return {"items": data}
            else:
                return {"raw": str(data)}

        return data
```

---

## 8. Advanced Techniques

### 8.1 Tool Composition with Compose Pattern

```python
# tool_composer.py
from typing import Callable, Any, Dict
from functools import reduce

class ToolComposer:
    """Compose multiple tools into a single operation."""

    def __init__(self):
        self.tools: List[Callable] = []

    def add_tool(self, tool_func: Callable):
        """Add a tool to the composition."""
        self.tools.append(tool_func)
        return self

    def compose(self) -> Callable:
        """Create a composed function."""
        def composed(input_data: Any, config: Dict = None) -> Any:
            config = config or {}
            result = input_data

            for tool in self.tools:
                tool_config = config.get(tool.__name__, {})
                result = tool(result, **tool_config)

            return result

        return composed

# Usage
def enumerate_subdomains(domain: str, **kwargs) -> list:
    # Subfinder logic
    return [f"sub{i}.{domain}" for i in range(5)]

def probe_hosts(hosts: list, **kwargs) -> list:
    # HTTP probing logic
    return [{"host": h, "alive": True} for h in hosts]

def crawl_urls(hosts: list, **kwargs) -> list:
    # URL crawling logic
    urls = []
    for h in hosts:
        urls.extend([f"http://{h['host']}/page{i}" for i in range(3)])
    return urls

# Compose pipeline
pipeline = ToolComposer()
pipeline.add_tool(enumerate_subdomains)
pipeline.add_tool(probe_hosts)
pipeline.add_tool(crawl_urls)

run = pipeline.compose()
results = run("test-target.example.com")
print(f"Pipeline result: {len(results)} items")
```

### 8.2 Distributed Tool Execution

```python
# distributed_executor.py
import asyncio
import json
from typing import Dict, List, Any
from pathlib import Path
import uuid
import time
import redis

class DistributedExecutor:
    """Execute tools across multiple workers using Redis queue."""

    def __init__(self, redis_url: str = "redis://localhost:6379"):
        self.redis_client = redis.from_url(redis_url)
        self.worker_id = str(uuid.uuid4())[:8]

    def submit_task(self, tool_name: str, input_data: Any, config: Dict = None) -> str:
        """Submit a task to the distributed queue."""
        task_id = str(uuid.uuid4())
        task = {
            "id": task_id,
            "tool": tool_name,
            "input": input_data,
            "config": config or {},
            "submitted_by": self.worker_id,
            "submitted_at": time.time(),
            "status": "pending",
        }

        self.redis_client.lpush("tool_tasks", json.dumps(task, default=str))
        return task_id

    def get_result(self, task_id: str, timeout: int = 300) -> Optional[Dict]:
        """Get task result with timeout."""
        start = time.time()
        while time.time() - start < timeout:
            result = self.redis_client.get(f"task_result:{task_id}")
            if result:
                return json.loads(result)
            time.sleep(0.1)
        return None

    def worker_loop(self, max_tasks: int = 100):
        """Worker loop to process tasks."""
        tasks_completed = 0

        while tasks_completed < max_tasks:
            # Block waiting for tasks
            task_data = self.redis_client.brpop("tool_tasks", timeout=5)
            if not task_data:
                continue

            task = json.loads(task_data[1])
            task_id = task["id"]

            try:
                # Execute tool
                adapter = registry.get_adapter(task["tool"])
                if not adapter:
                    raise ValueError(f"Unknown tool: {task['tool']}")

                result = adapter.execute(task["input"], task["config"])

                # Store result
                self.redis_client.set(
                    f"task_result:{task_id}",
                    json.dumps({
                        "success": result.success,
                        "data": result.data,
                        "error": result.error,
                        "duration": result.duration,
                    }, default=str),
                    ex=3600  # Expire after 1 hour
                )

                tasks_completed += 1

            except Exception as e:
                self.redis_client.set(
                    f"task_result:{task_id}",
                    json.dumps({
                        "success": False,
                        "error": str(e),
                    }),
                    ex=3600
                )

        return tasks_completed

# Usage
executor = DistributedExecutor()

# Submit tasks
task_id = executor.submit_task("subfinder", "test-target.example.com")

# Get result
result = executor.get_result(task_id)
print(f"Result: {result}")
```

### 8.3 Tool Performance Profiling

```python
# tool_profiler.py
import time
import json
from typing import Dict, List, Any
from dataclasses import dataclass
from pathlib import Path
import statistics

@dataclass
class ToolProfile:
    tool_name: str
    executions: int
    avg_duration: float
    min_duration: float
    max_duration: float
    std_dev: float
    success_rate: float
    avg_output_size: float

class ToolProfiler:
    """Profile tool performance over multiple executions."""

    def __init__(self, profile_dir: str = "profiles"):
        self.profile_dir = Path(profile_dir)
        self.profile_dir.mkdir(exist_ok=True)
        self.profiles: Dict[str, List[Dict]] = {}

    def record_execution(self, tool_name: str, duration: float,
                         success: bool, output_size: int = 0):
        """Record a tool execution."""
        if tool_name not in self.profiles:
            self.profiles[tool_name] = []

        self.profiles[tool_name].append({
            "timestamp": time.time(),
            "duration": duration,
            "success": success,
            "output_size": output_size,
        })

    def get_profile(self, tool_name: str) -> ToolProfile:
        """Calculate profile for a tool."""
        executions = self.profiles.get(tool_name, [])
        if not executions:
            return None

        durations = [e["duration"] for e in executions]
        successes = [e["success"] for e in executions]
        output_sizes = [e["output_size"] for e in executions]

        return ToolProfile(
            tool_name=tool_name,
            executions=len(executions),
            avg_duration=statistics.mean(durations),
            min_duration=min(durations),
            max_duration=max(durations),
            std_dev=statistics.stdev(durations) if len(durations) > 1 else 0,
            success_rate=sum(successes) / len(successes) * 100,
            avg_output_size=statistics.mean(output_sizes),
        )

    def export_profiles(self):
        """Export all profiles."""
        for tool_name in self.profiles:
            profile = self.get_profile(tool_name)
            if profile:
                output_path = self.profile_dir / f"{tool_name}_profile.json"
                with open(output_path, "w") as f:
                    json.dump({
                        "tool": profile.tool_name,
                        "executions": profile.executions,
                        "avg_duration": profile.avg_duration,
                        "min_duration": profile.min_duration,
                        "max_duration": profile.max_duration,
                        "std_dev": profile.std_dev,
                        "success_rate": profile.success_rate,
                        "avg_output_size": profile.avg_output_size,
                    }, f, indent=2)

# Usage
profiler = ToolProfiler()

# Record executions
profiler.record_execution("subfinder", 45.2, True, 1024)
profiler.record_execution("subfinder", 42.1, True, 1024)
profiler.record_execution("httpx", 120.5, True, 4096)

# Get profile
profile = profiler.get_profile("subfinder")
print(f"Subfinder: {profile.executions} runs, avg {profile.avg_duration:.1f}s")
```

---

## 9. Reporting Template

### 9.1 Tool Integration Report

```markdown
# Tool Integration Framework Report

## Platform Overview
- **Total Tools Registered**: {total_tools}
- **Active Plugins**: {active_plugins}
- **Event Subscribers**: {event_subscribers}
- **Middleware Components**: {middleware_count}

## Tool Status

| Tool | Version | Status | Avg Duration | Success Rate |
|------|---------|--------|--------------|--------------|
| subfinder | 2.0 | Healthy | 45.2s | 100% |
| httpx | 1.0 | Healthy | 120.5s | 99.8% |
| nuclei | 3.0 | Healthy | 1800.2s | 99.5% |
| ffuf | 1.0 | Degraded | 600.3s | 95.0% |
| katana | 1.0 | Healthy | 300.1s | 100% |

## Plugin Architecture

### Loaded Plugins
- **ReconPlugin v1.0**: Subdomain enumeration, host probing, URL discovery
- **ScanPlugin v1.0**: Vulnerability scanning, port scanning
- **ReportPlugin v1.0**: Report generation, finding export

### Hook Usage
| Hook | Subscribers | Avg Execution Time |
|------|-------------|-------------------|
| enumerate_subdomains | 2 | 45.2s |
| probe_hosts | 1 | 120.5s |
| scan_urls | 1 | 1800.2s |

## Middleware Pipeline

### Active Middleware
1. **RateLimiter**: 100 req/min per tool
2. **CircuitBreaker**: 5 failures → open, 60s recovery
3. **AuthMiddleware**: API key injection
4. **TransformerMiddleware**: Input/output normalization

### Pipeline Performance
- **Average Overhead**: 2.3ms per request
- **Rate Limit Triggers**: 12 in last hour
- **Circuit Breaker Opens**: 0

## Event Bus Statistics

| Event Type | Count (last hour) | Avg Handlers |
|-----------|-------------------|--------------|
| tool.start | 45 | 1 |
| tool.complete | 45 | 2 |
| vuln.detected | 3 | 3 |
| tool.error | 1 | 2 |

## Performance Metrics

### Throughput
- **Tools executed**: 150
- **Total execution time**: 4,521.3s
- **Parallel efficiency**: 3.2×

### Resource Usage
- **Peak memory**: 1.2 GB
- **Average CPU**: 45%
- **Network I/O**: 2.1 GB

## Recommendations

1. **Add retry middleware**: Reduce transient failure impact
2. **Implement tool caching**: Cache subfinder results for 1 hour
3. **Add distributed execution**: Scale across multiple workers
4. **Implement tool versioning**: Support multiple tool versions
5. **Add performance profiling**: Track tool performance over time
```

### 9.2 Automated Report Generator

```python
# integration_report.py
import json
from pathlib import Path
from datetime import datetime
from typing import Dict

class IntegrationReportGenerator:
    """Generate integration framework reports."""

    def __init__(self, output_dir: str = "reports"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

    def generate_report(self, platform_data: Dict) -> str:
        """Generate markdown report."""
        report = f"""# Tool Integration Framework Report

## Platform Overview
- **Total Tools Registered**: {platform_data.get('total_tools', 0)}
- **Active Plugins**: {platform_data.get('active_plugins', 0)}
- **Event Subscribers**: {platform_data.get('event_subscribers', 0)}
- **Middleware Components**: {platform_data.get('middleware_count', 0)}

## Tool Status

| Tool | Version | Status | Avg Duration | Success Rate |
|------|---------|--------|--------------|--------------|
"""
        for tool in platform_data.get('tools', []):
            report += f"| {tool['name']} | {tool['version']} | {tool['status']} | {tool['avg_duration']:.1f}s | {tool['success_rate']:.1f}% |\n"

        report += f"""
## Performance Metrics

### Throughput
- **Tools executed**: {platform_data.get('total_executions', 0)}
- **Total execution time**: {platform_data.get('total_duration', 0):.1f}s
- **Parallel efficiency**: {platform_data.get('parallel_efficiency', 1.0):.1f}×

### Resource Usage
- **Peak memory**: {platform_data.get('peak_memory_mb', 0):.1f} MB
- **Average CPU**: {platform_data.get('avg_cpu_percent', 0):.1f}%

## Recommendations

"""
        for rec in platform_data.get('recommendations', []):
            report += f"1. {rec}\n"

        return report

    def save_report(self, platform_data: Dict):
        """Save report to file."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"integration_report_{timestamp}.md"
        filepath = self.output_dir / filename

        report = self.generate_report(platform_data)
        with open(filepath, "w") as f:
            f.write(report)

        return str(filepath)
```

---

## 10. Quick Reference

### 10.1 Essential Imports

```python
# Core framework
from typing import Any, Dict, List, Optional, Callable
from dataclasses import dataclass, field
from abc import ABC, abstractmethod
from enum import Enum
import json
import time
import asyncio
from pathlib import Path
from collections import defaultdict
import threading
import queue
import subprocess
import importlib
import sys

# Async support
import asyncio
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
```

### 10.2 Design Patterns Cheat Sheet

| Pattern | When to Use | Implementation |
|---------|-------------|----------------|
| Adapter | Wrapping incompatible tools | Implement BaseToolAdapter |
| Facade | Simplifying complex APIs | Create unified interface |
| Mediator | Complex tool coordination | Use EventBus |
| Plugin | Extensible platforms | Implement SecurityToolPlugin |
| Pipeline | Sequential processing | Use MiddlewarePipeline |
| Observer | Event-driven updates | Use EventBus.subscribe() |
| Circuit Breaker | Fault tolerance | Use CircuitBreakerMiddleware |

### 10.3 Plugin Development Checklist

```markdown
## Plugin Development Checklist

### Interface Implementation
- [ ] Inherit from SecurityToolPlugin
- [ ] Implement get_metadata()
- [ ] Implement initialize()
- [ ] Implement execute()
- [ ] Implement get_capabilities()
- [ ] Implement health_check()

### Lifecycle Hooks
- [ ] Implement on_load()
- [ ] Implement on_unload()
- [ ] Implement on_error()

### Testing
- [ ] Unit tests for all methods
- [ ] Integration tests with mock inputs
- [ ] Health check validation
- [ ] Error handling verification

### Documentation
- [ ] Plugin README with usage examples
- [ ] Configuration documentation
- [ ] Output format specification
- [ ] Troubleshooting guide
```

### 10.4 Configuration Reference

```yaml
# Platform configuration
platform:
  name: "Security Tool Platform"
  version: "1.0"
  plugin_dirs:
    - "adapters"
    - "plugins"
  log_level: "INFO"

# Tool configurations
tools:
  subfinder:
    timeout: 300
    threads: 4
  httpx:
    threads: 50
    timeout: 10
    follow_redirects: true
  nuclei:
    severity: ["medium", "high", "critical"]
    rate_limit: 150
  ffuf:
    threads: 40
    timeout: 30

# Middleware configuration
middleware:
  rate_limiter:
    max_requests: 100
    window_seconds: 60
  circuit_breaker:
    failure_threshold: 5
    recovery_timeout: 60
```

### 10.5 Troubleshooting Guide

| Problem | Cause | Solution |
|---------|-------|----------|
| Plugin not loading | Import error | Check dependencies, verify module path |
| Tool not found | Binary not in PATH | Install tool, add to PATH |
| Memory leak | Long-running process | Use ResourceManager, add GC |
| Event not firing | No subscribers | Verify subscription with bus.get_stats() |
| Pipeline hang | Deadlock in DAG | Validate DAG with validate_dag() |
| High latency | Sequential execution | Use parallel engine |
| Output parse failure | Tool version mismatch | Use RobustParser with fallbacks |
| Rate limit exceeded | Too many requests | Configure RateLimiterMiddleware |
