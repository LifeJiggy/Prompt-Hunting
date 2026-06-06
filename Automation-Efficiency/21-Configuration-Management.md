# Automation-Efficiency 21: Configuration Management

## Overview

Configuration management is the backbone of any scalable bug hunting automation framework. Poorly managed configuration leads to secrets leakage, cross-environment contamination, flaky pipelines, and wasted time debugging environment drift. This document covers multi-format config hierarchies, environment-specific overrides, secrets injection, validation, versioning, hot-reload, defaults, nested structures, and tool-chaining configuration.

---

## 1. Config Format Selection Guide

| Format | Best For | Human Editable | Schema Support | Secret Safe |
|--------|----------|---------------|----------------|-------------|
| YAML   | Human-authored hierarchy, tool configs | Yes | Yes (external) | No |
| TOML   | Structured nested configs, Rust/Python tools | Yes | Yes (inline) | No |
| JSON   | Programmatic generation, schema validation | No | Yes | No |
| .env   | 12-factor secrets, CI injection | Yes | No | Yes |
| SOPS   | Encrypted secrets in repos | No (binary) | Yes | Yes |

**Use TOML for machine-friendliness**, YAML for human-authored branch configs, and .env files exclusively for secrets that never check into a repository.

---

## 2. Config Hierarchy (Merge Order)

Configuration layers merge in a fixed sequence; later layers override earlier ones.

```
Layer 1: defaults/config.toml       ← shipped with tool, never modified
Layer 2: project/.bounty.toml       ← per-project overrides, tracked
Layer 3: env/.staging.toml          ← environment-specific, tracked
Layer 4: user/.config.toml          ← per-user overrides, untracked
Layer 5: .env                       ← secrets, NEVER tracked
Layer 6: CLI flags / env vars       ← highest precedence
```

The merge is **deep recursive merge**, not shallow. A CLI flag `--timeout 30` overrides the entire `timeout` key, but `--target.host api.example.com` only overrides the nested `target.host` field.

### Merge Implementation (Python)

```python
import tomllib
import os

def load_config(layers: list[str]) -> dict:
    merged = {}
    for layer in layers:
        with open(layer, "rb") as f:
            data = tomllib.load(f)
        merged = deep_merge(merged, data)
    return merged

def deep_merge(base: dict, override: dict) -> dict:
    result = dict(base)
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = value
    return result

DEFAULT_LAYERS = [
    "defaults/config.toml",
    "project/.bounty.toml",
    f"env/.{os.environ.get('BOUNTY_ENV', 'dev')}.toml",
    "user/.config.toml",
]

config = load_config(DEFAULT_LAYERS)
```

---

## 3. Environment-Specific Overrides

Support `dev`, `staging`, and `prod` environments with clean path resolution.

### `defaults/config.toml`

```toml
[scan]
threads = 50
timeout_seconds = 10
wordlist = "/opt/wordlists/common.txt"
exclude_status_codes = [403, 404]

[http]
user_agent = "bounty-hunter/2.1"
follow_redirects = true
max_redirects = 5

[report]
format = "json"
output_dir = "./reports"

[auth]
mode = "none"
```

### `env/staging.toml`

```toml
[scan]
threads = 20
exclude_status_codes = [401, 403, 404, 429]

[http]
proxy = "http://staging-proxy.internal:8080"

[report]
output_dir = "./reports-staging"
```

### `env/prod.toml`

```toml
[scan]
threads = 5
delay_seconds = 1          # mandatory politeness on production targets
exclude_status_codes = [400, 401, 403, 404, 405, 429, 500]

[auth]
mode = "oauth2"
```

### Environment Resolution

```python
def resolve_env_config(env: str | None = None) -> str:
    return f"env/{(env or os.environ.get('BOUNTY_ENV', 'dev')).lower()}.toml"

BOUNTY_ENV=staging python run.py   # loads env/staging.toml
BOUNTY_ENV=prod   python run.py   # loads env/prod.toml
                                # dev is default when unset
```

---

## 4. Secrets Injection — Never in Config Files

### The Rule

**No secret (API key, token, password, cookie, private key) may ever live in a tracked config file.** Secrets must be injected at runtime via one of four channels:

| Channel | Use Case | Tooling |
|---------|----------|---------|
| Environment variables | Local dev, CI pipes | `export API_KEY=...` |
| OS keychain | Local dev interactive | `keyring`, `pass` |
| Vault / SOPS | Team-shared secrets | HashiCorp Vault, SOPS + age |
| CI secrets store | Pipeline injection | GitHub Secrets, GitLab CI vars |

### Runtime Secrets Loader

```python
import os
import keyring
from pathlib import Path

def get_secret(key: str, fallback_env: str | None = None) -> str | None:
    """Load secret from keychain first, fall back to env var."""
    value = keyring.get_password("bounty-tool", key)
    if value:
        return value
    env_var = fallback_env or key.upper()
    return os.environ.get(env_var)

# Usage within config resolution
config["auth"]["shodan_key"] = get_secret("shodan_api", "SHODAN_API_KEY")
config["auth"]["h1_token"]   = get_secret("hackerone_api", "H1_API_TOKEN")
```

### SOPS Encrypted Secrets (Team-Scale)

```bash
# One-time setup
sops --age "$(cat ~/.config/sops/age.key)" create secrets.enc.yaml

# secrets.enc.yaml (encrypted in git, decrypts at runtime)
api_keys:
  shodan: ENC[AES256_GCM,...]
  hunter: ENC[AES256_GCM,...]
```

```yaml
# sops metadata — must be present
sops:
  kms: []
  gcp_kms: []
  azure_kv: []
  lastmodified: "2025-06-01T00:00:00Z"
  age:
    - recipient: age1xxxxxxxxxxxx
      enc: |
        -----BEGIN AGE ENCRYPTED FILE-----
        ...
```

Load in Python:
```python
import sops

raw = sops.load("secrets.enc.yaml")
config["auth"]["shodan_key"] = raw["api_keys"]["shodan"]
```

---

## 5. Config Validation on Load

Unvalidated configs fail silently mid-scan. Validate immediately on load using a schema.

### Using Pydantic (Python)

```python
from pydantic import BaseModel, Field, field_validator, PositiveInt
from typing import Literal

class HttpConfig(BaseModel):
    user_agent: str = "bounty-hunter/2.1"
    follow_redirects: bool = True
    max_redirects: PositiveInt = Field(le=10, default=5)
    proxy: str | None = None

class ScanConfig(BaseModel):
    threads: PositiveInt = Field(le=200, default=50)
    timeout_seconds: PositiveInt = Field(default=10)
    delay_seconds: float = Field(ge=0, default=0)
    wordlist: str
    exclude_status_codes: list[int] = [403, 404]

class AuthConfig(BaseModel):
    mode: Literal["none", "api_key", "oauth2", "bearer"]
    api_key: str | None = None
    bearer_token: str | None = None

    @field_validator("api_key")
    @classmethod
    def require_key_for_api_mode(cls, v, info):
        if info.data.get("mode") == "api_key" and not v:
            raise ValueError("api_key required when mode=api_key")
        return v

class BountyConfig(BaseModel):
    scan: ScanConfig
    http: HttpConfig
    report: dict
    auth: AuthConfig

# validate on load
def load_validated_config(layers: list[str]) -> BountyConfig:
    raw = load_config(layers)
    return BountyConfig.model_validate(raw)
```

### Validation Error Handling

```python
from pydantic import ValidationError

try:
    config = load_validated_config(DEFAULT_LAYERS)
except ValidationError as e:
    print("Config validation failed:")
    for err in e.errors():
        loc = ".".join(str(x) for x in err["loc"])
        print(f"  {loc}: {err['msg']}")
    sys.exit(1)
```

---

## 6. Config Versioning and History

Track config changes in git with a dedicated `configs/` directory. Use version tags to reproduce historical scan profiles.

```
configs/
├── defaults/
│   ├── config.toml
│   └── wordlists.tsv
├── env/
│   ├── dev.toml
│   ├── staging.toml
│   └── prod.toml
├── project/
│   ├── example-com.toml
│   └── api-example-com.toml
└── schemas/
    └── bounty.schema.json
```

### Semantic Version for Config Changes

```
configs/project/example-com.toml    # version 1.2.0
# Tag config state alongside code
git tag -a config-v1.2.0 -m "Increased threads, added XSS payloads"
```

### Reproducing Historical Scans

```bash
git checkout config-v1.1.0 -- configs/project/example-com.toml
python run.py --target example.com
```

---

## 7. Hot Reload for Long-Running Scans

For continuous recon jobs (subdomain enumeration, port watching), reload config on SIGHUP without restarting the process.

```python
import signal
import threading

_config_lock = threading.Lock()
_current_config: BountyConfig | None = None

def _reload_config(signum, frame):
    layers = resolve_layers()
    with _config_lock:
        global _current_config
        _current_config = load_validated_config(layers)
    log.info("Config reloaded via SIGHUP")

def init_hot_reload():
    signal.signal(signal.SIGHUP, _reload_config)
    _current_config = load_validated_config(resolve_layers())

def get_config() -> BountyConfig:
    with _config_lock:
        return _current_config
```

Usage:
```bash
# Edit configs/project/example-com.toml, then:
kill -HUP <pid>
# Scanner picks up new threads/wordlist mid-run without full restart
```

---

## 8. Default Values

Always provide sensible defaults in `defaults/config.toml`. Every tool configurable should have a no-args-required fallback.

### `defaults/config.toml` (complete reference)

```toml
[scan]
threads = 50
timeout_seconds = 10
retries = 2
retry_delay_seconds = 1
delay_seconds = 0
max_concurrent_targets = 5
wordlist = "/opt/wordlists/seclists/Discovery/DNS/dns-wordlist.txt"
exclude_status_codes = [403, 404]
include_content_types = ["text/html", "application/json"]

[http]
user_agent = "bounty-hunter/2.1"
accept = "*/*"
follow_redirects = true
max_redirects = 5
verify_tls = true
proxy = null

[report]
format = "json"          # json | html | markdown | jira
output_dir = "./reports"
include_raw_body = false
redact_headers = ["Authorization", "Cookie", "X-Api-Key"]

[auth]
mode = "none"            # none | api_key | oauth2 | bearer
api_key_env = null       # env var name for API key
bearer_token_env = null

[notify]
on_finding = true
slack_webhook_env = "SLACK_WEBHOOK_URL"
email_env = "SMTP_TO"
```

---

## 9. Nested Config Structures

Bounty hunting involves tool chains with deeply nested configuration.

```toml
[tools.nuclei]
enabled = true
templates_dir = "./nuclei-templates"
severity_filter = ["critical", "high"]
tags = ["cve", "lfi", "rce"]
rate_limit = 150

[tools.nuclei.headers]
X-Bounty-Tool = "true"
X-Env = "prod"

[tools.nuclei.matchers]
status_codes = [200, 301, 302]
word_size = [50, 100]

[tools.httpx]
enabled = true
follow_redirects = true
tech_detect = true
status_code = true
title = true
output_file = "./output/live_hosts.txt"

[tools.amass]
enabled = true
passive_only = true
max_depth = 3
```

Access in Python:

```python
config["tools"]["nuclei"]["rate_limit"]   # 150
config["tools"]["httpx"]["tech_detect"]   # true
```

Consume in subprocess calls:

```python
import subprocess, json

nuclei_args = [
    "nuclei",
    "-u", target_url,
    "-severity", ",".join(config["tools"]["nuclei"]["severity_filter"]),
    "-rate-limit", str(config["tools"]["nuclei"]["rate_limit"]),
    "-json",
]
```

---

## 10. Config for Tool Chaining

Each tool in a pipeline reads from the same config namespace but may require translated argument forms.

```python
def build_nuclei_cmd(target: str, config: dict) -> list[str]:
    t = config["tools"]["nuclei"]
    cmd = ["nuclei", "-u", target, "-jsonl", "-silent"]
    if t["templates_dir"]:
        cmd += ["-t", t["templates_dir"]]
    if t["severity_filter"]:
        cmd += ["-severity", ",".join(t["severity_filter"])]
    if t["tags"]:
        cmd += ["-tags", ",".join(t["tags"])]
    if t["rate_limit"]:
        cmd += ["-rl", str(t["rate_limit"])]
    if t["headers"]:
        for k, v in t["headers"].items():
            cmd += ["-H", f"{k}: {v}"]
    return cmd

def build_httpx_cmd(input_file: str, config: dict) -> list[str]:
    t = config["tools"]["httpx"]
    cmd = ["httpx", "-l", input_file, "-json", "-silent"]
    if t.get("tech_detect"):
        cmd.append("-tech-detect")
    if t.get("status_code"):
        cmd.append("-status-code")
    if t.get("title"):
        cmd.append("-title")
    return cmd

# Pipeline
urls = enumerate_subdomains(target)
for batch in chunk(urls, 100):
    live = subprocess.run(build_httpx_cmd(batch, config), capture_output=True)
    for url in parse_httpx(live.stdout):
        subprocess.run(build_nuclei_cmd(url, config))
```

---

## 11. Complete Example: Full Pipeline Configuration

```toml
# project/example-com.toml — a real per-target config
[target]
root_domain = "example.com"
scope = [
    "*.example.com",
    "example.com/*",
]
out_of_scope = [
    "*.example.com/admin/*",
    "example.com/wp-admin/*",
]

[scan]
threads = 30
timeout_seconds = 15
delay_seconds = 0.5
wordlist = "/opt/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt"

[http]
user_agent = "bounty-scout/2.1"
follow_redirects = true
max_redirects = 5

[report]
format = "json"
output_dir = "./reports/example-com"

[tools.amass]
enabled = true
passive_only = true
max_depth = 2

[tools.subfinder]
enabled = true
sources = ["shodan", "hunter", "threatcrowd"]

[tools.httpx]
enabled = true
tech_detect = true
status_code = true
title = true

[tools.nuclei]
enabled = true
severity_filter = ["critical", "high"]
rate_limit = 100
templates_dir = "./nuclei-templates"

[tools.katana]
enabled = true
depth = 3
concurrent_requests = 10
```

---

## 12. Checklist

- [ ] `defaults/config.toml` exists with all defaults
- [ ] Every environment has its own `.toml` in `env/`
- [ ] No secrets in any tracked file
- [ ] Secrets loaded via keychain / Vault / SOPS / env vars only
- [ ] Schema validation via Pydantic on every config load
- [ ] Config files are version-pinned with git tags
- [ ] SIGHUP handler reloads config for long-running jobs
- [ ] All tool subprocesses derive args from the validated config dict
- [ ] No hard-coded paths or credentials in source code
- [ ] `.env` and `user/.config.toml` are in `.gitignore`
