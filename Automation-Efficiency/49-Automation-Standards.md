# 49 — Automation Standards

## Scope

Standards make automation maintainable across contributors and over time. This file covers naming conventions, code style, directory layout, config file placement, output formats, logging levels, error codes, documentation requirements, review checklists, and compatibility guarantees. Standards are not suggestions — they are the shared contract between team members and between automation scripts and their consumers.

---

## 1. Naming Conventions

Consistent naming eliminates ambiguity. Apply these rules uniformly across Python, Terraform, Helm values, and YAML config.

### 1.1 File Naming

| Artifact Type        | Convention                | Example                                  |
|----------------------|---------------------------|------------------------------------------|
| Python modules       | `snake_case.py`          | `subdomain_enum.py`                      |
| Python packages      | `snake_case/`            | `cloud_automation/`                      |
| Terraform modules    | `terraform-<name>-<provider>` | `terraform-scan-bucket-aws`            |
| Helm charts          | lowercase with hyphens   | `nuclei-scanner`                         |
| Compose services     | lowercase with hyphens   | `subfinder`, `httpx-probe`              |
| Config files         | `kebab-case.ext`         | `scan-targets.yaml`, `aws-policy.json`   |
| Log files            | `<tool>-<date>.log`      | `nuclei-20250605.log`                   |

**Never use camelCase or PascalCase in filenames in Linux-native environments.**

### 1.2 Python Identifiers

Follow PEP 8 exactly. Enforce in CI with `ruff` or `flake8`.

```python
# Module-level constants: UPPER_SNAKE_CASE
MAX_CONCURRENT_SCANS = 20
DEFAULT_RATE_LIMIT  = 150
RESULTS_BUCKET      = "scan-results-prod"

# Functions / methods: snake_case
def probe_http_targets(hosts: list[str]) -> list[dict]:
    ...

# Classes: PascalCase
class SubdomainEnumerator:
    ...

# Private (module-internal): leading underscore
def _parse_burp_xml(xml_path: str) -> list[dict]:
    ...
```

### 1.3 Terraform Identifiers

```hcl
variable "scan_targets" {}        # snake_case
resource "aws_s3_bucket" "scan_results" {}  # resource type + snake_case name
locals {
  common_tags = {                # snake_case locals
    Team       = "security-automation"
    ManagedBy  = "terraform"
  }
}
module "scan_bucket" { }         # module source: local path or registry
```

### 1.4 Kubernetes Resource Names

```yaml
# Resource names: lowercase, max 253 chars, no underscores
apiVersion: batch/v1
kind: Job
metadata:
  name: nuclei-daily-scan-20250605     # include date for uniqueness
  labels:
    app: nuclei-scan
    managed-by: automation
    scan-type: vulnerability
```

---

## 2. Code Style Rules

### 2.1 Python — Ruff Configuration

Create `pyproject.toml` at the project root:

```toml
[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "F",   # pyflakes
    "I",   # isort
    "UP",  # pyupgrade
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "SIM", # flake8-simplify
    "TID", # flake8-tidy-imports
]
ignore = [
    "E501",  # line-length (handled by formatter)
]

[tool.ruff.lint.isort]
known-first-party = ["cloud_automation", "scan_utils"]
```

Run in CI:

```yaml
- name: Lint Python
  run: ruff check . --output-format github
- name: Format check
  run: ruff format --check .
```

### 2.2 Type Hints — Mandatory in New Code

```python
from __future__ import annotations
import httpx
from typing import Sequence

async def probe_urls(
    urls: Sequence[str],
    client: httpx.AsyncClient,
    timeout: float = 10.0,
    safelist: frozenset[str] | None = None,
) -> list[dict]:
    """Probe a list of URLs and return live results."""
    if safelist is None:
        safelist = ALLOWED_DOMAINS
    results: list[dict] = []
    for url in urls:
        host = httpx.URL(url).host
        if host not in safelist:
            results.append({"url": url, "skipped": True, "reason": "not in safelist"})
            continue
        try:
            resp = await client.get(url, follow_redirects=True)
            results.append({"url": str(resp.url), "status": resp.status_code})
        except httpx.HTTPError as exc:
            results.append({"url": url, "error": str(exc)})
    return results
```

**Add `mypy` to CI with `--strict` on new modules**:

```toml
# pyproject.toml
[tool.mypy]
strict = true
python_version = "3.12"
warn_return_any = true
warn_unused_ignores = true
```

---

## 3. Directory Layout

Adopt a uniform layout for every automation repository. Plugins and scripts know where to find configs, templates, and outputs without following symlinks.

```
automation-repo/
├── .github/workflows/            # CI pipelines
│   └── ci.yml
├── .kilo/                        # Kilo commands / agents (if using Kilo)
│   ├── command/
│   └── agent/
├── charts/                       # Helm charts for Deploy components
│   └── scanner/
│       ├── Chart.yaml
│       └── values.yaml
├── cloud/                        # Cloud automation modules
│   ├── __init__.py
│   ├── aws_asset_discovery.py
│   ├── gcp_metadata_check.py
│   ├── s3_enum.py
│   └── billing_alerts.py
├── config/                       # Static config, not secret
│   ├── scan_targets.yaml
│   ├── nuclei_templates.yaml     # template inclusion/exclusion rules
│   ├── tool_settings.json
│   └── allowed_domains.txt
├── containers/                   # Dockerfiles, Containerfiles
│   ├── scanner/
│   │   └── Dockerfile
│   └── reporter/
│       └── Dockerfile
├── docs/                         # File-per-topic markdown (this file)
│   ├── 49-Automation-Standards.md
│   └── ...
├── infra/                        # Terraform / OpenTofu, Helm overlays
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── scripts/                      # Runnable entrypoints (not importable)
│   ├── run_daily_scan.sh         # shell scripts
│   ├── generate_report.py
│   └── seed_targets.py
├── src/                          # Core library imports (Python)
│   └── scan_platform/
│       ├── __init__.py
│       ├── scanner.py
│       └── models.py
├── tests/                        # Tests mirror source layout
│   ├── unit/
│   │   └── test_aws_assets.py
│   ├── integration/
│   └── conftest.py
├── volumes/                      # Bind-mount targets for local dev
│   └── results/
├── pyproject.toml                # Python project config (ruff, mypy, pytest)
├── docker-compose.yaml
├── Makefile                      # common targets (lint, test, scan)
├── README.md
├── CHANGELOG.md
└── VERSION                       # semver file, e.g. "1.4.0"
```

**Core rules**:

- `src/` and `cloud/` contain importable Python modules.
- `scripts/` contains entrypoints that are not imported elsewhere.
- `config/` contains non-secret config; `secrets/` (gitignored) for credentials.
- `tests/` mirrors the package structure exactly.
- Every directory has an `__init__.py` if it is importable.

---

## 4. Config File Locations and Precedence

Specify a clear precedence for config files. Automations must not depend on secrets baked into defaults.

**Precedence order (highest wins)**:

1. **Environment variables** (e.g., `SHODAN_API_KEY`, `SCAN_RESULTS_BUCKET`)
2. **CI/CD secrets / K8s Secrets** (mounted as files or injected)
3. **Local `.env` file** (gitignored, loaded via `python-dotenv`)
4. **Project `config/` directory** (committed, non-sensitive)
5. **User-level `~/.config/automation/`** (machine-specific)
6. **Hardcoded defaults** (lowest, must be safe no-ops)

**Load config with precedence**:

```python
import os
from pathlib import Path
from dotenv import load_dotenv

REPO_ROOT = Path(__file__).resolve().parents[2]
USER_CONFIG = Path.home() / ".config" / "automation" / "config.yaml"

def load_config() -> dict:
    env_file = REPO_ROOT / ".env"
    if env_file.exists():
        load_dotenv(dotenv_path=env_file)

    config_files = [
        REPO_ROOT / "config" / "scan_targets.yaml",
        USER_CONFIG,
    ]
    merged = {}
    for path in config_files:
        if path.exists():
            merged.update(yaml.safe_load(path.read_text()))

    merged.setdefault("rate_limit", 150)
    merged.setdefault("results_bucket", os.environ.get("RESULTS_BUCKET", "scan-results-dev"))
    return merged

CONFIG = load_config()
```

**Config schema validation with Pydantic**:

```python
from pydantic import BaseModel, Field, HttpUrl
from pydantic_settings import BaseSettings, SettingsConfigDict

class ScanToolConfig(BaseModel):
    image: str = "registry.example.com/nuclei:v3.3.4"
    rate_limit: int = Field(gt=0, le=500)
    severity: str = "critical,high,medium"
    templates_path: Path | None = None

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="SCAN_", env_file=".env")
    results_bucket: str = "scan-results-dev"
    max_concurrent: int = Field(default=10, gt=0, le=100)
    safelist_path: Path = Path("config/allowed_domains.txt")
    nuclei: ScanToolConfig = ScanToolConfig()

SETTINGS = Settings()
```

---

## 5. Output Format Standards

Define output formats as versioned schemas. Support JSON Lines (`.jsonl`) for streaming, JSON for structured data, Markdown for human reports, and SARIF for GitHub/CodeQL integration.

**Canonical finding schema**:

```json
{
  "finding_id": "UUID-v7",
  "scan_id": "UUID-v7",
  "severity": "CRITICAL",
  "category": "exposed-storage",
  "title": "S3 bucket allows public Read access",
  "description": "Bucket policy grants GetObject to allUsers.",
  "affected_resource": "arn:aws:s3:::my-exposed-bucket",
  "evidence": {
    "url": "http://my-exposed-bucket.s3.amazonaws.com/",
    "acl_grantees": ["AllUsers:READ"]
  },
  "affected_assignee": "cloud-team",
  "remediation": ["Enable Block Public Access", "Remove wildcard Principal from policy"],
  "references": ["https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html"],
  "scanner": {
    "name": "s3-enumerator",
    "version": "2.1.0",
    "rule_id": "S3-PUBLIC-READ"
  },
  "first_seen": "2025-06-05T14:30:00Z",
  "last_seen": "2025-06-05T14:30:00Z",
  "false_positive": false
}
```

**Emit JSONL for downstream consumers**:

```python
import json
import uuid
from pathlib import Path

def write_findings_jsonl(findings: list[dict], output_dir: Path, scan_id: str) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    path = output_dir / f"{scan_id}.findings.jsonl"
    with path.open("w") as f:
        for finding in findings:
            row = {
                "finding_id": str(uuid.uuid7()),
                "scan_id": scan_id,
                **finding,
            }
            f.write(json.dumps(row, default=str) + "\n")
    return path
```

---

## 6. Logging Levels and Conventions

Use Python's `logging` module with a structured JSON formatter. Never use `print()` in production automation.

| Level     | Use Case                                                          |
|-----------|-------------------------------------------------------------------|
| `DEBUG`   | SDK request/response, paginator page details                      |
| `INFO`    | Task start/finish, files written, API calls count                 |
| `WARNING` | Retries, rate-limit backoffs, deprecated API usage               |
| `ERROR`   | Tool invocation failed, API returned error, validation error     |
| `CRITICAL`| Pipeline aborted, billing threshold exceeded, credential expired |

**Structured logging configuration**:

```python
import logging
import sys

class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        import json, datetime
        payload = {
            "ts": datetime.datetime.fromtimestamp(record.created, tz=datetime.timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "msg": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        if hasattr(record, "extra"):
            payload.update(record.extra)
        return json.dumps(payload)

def setup_logging(level: str = "INFO") -> None:
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    root = logging.getLogger()
    root.addHandler(handler)
    root.setLevel(level)

logger = logging.getLogger("automation")
logger.info("pipeline started", extra={"pipeline": "daily_recon", "domain": "example.com"})
```

---

## 7. Error Codes and Exception Hierarchy

Define a small, typed exception hierarchy. Map exceptions to exit codes for CI scripts.

```python
from enum import IntEnum

class ExitCode(IntEnum):
    SUCCESS            = 0
    CONFIG_ERROR       = 1   # Missing config, invalid YAML
    AUTH_ERROR         = 2   # Credential missing, expired, or permission denied
    TOOL_ERROR         = 3   # subprocess scanner returned non-zero
    RATE_LIMIT_ERROR   = 4   # Rate limit hit, caller should backoff
    VALIDATION_ERROR   = 5   # Input schema failed validation
    OUTPUT_ERROR       = 6   # Cannot write to output path
    UNKNOWN_ERROR      = 99

class AutomationBaseError(Exception):
    exit_code: ExitCode = ExitCode.UNKNOWN_ERROR

class ConfigurationError(AutomationBaseError):
    exit_code = ExitCode.CONFIG_ERROR

class AuthenticationError(AutomationBaseError):
    exit_code = ExitCode.AUTH_ERROR

class ToolExecutionError(AutomationBaseError):
    exit_code = ExitCode.TOOL_ERROR
    def __init__(self, tool: str, stderr: str):
        super().__init__(f"{tool} failed: {stderr[:200]}")
        self.tool = tool
        self.stderr = stderr

class RateLimitError(AutomationBaseError):
    exit_code = ExitCode.RATE_LIMIT_ERROR

# Usage in a subprocess caller:
def run_scanner(cmd: list[str]) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    if result.returncode != 0:
        raise ToolExecutionError(cmd[0], result.stderr)
    return result.stdout
```

**Top-level CLI entrypoint returning proper exit codes**:

```python
import sys

def main() -> None:
    try:
        # ... pipeline logic
        sys.exit(ExitCode.SUCCESS.value)
    except ConfigurationError as e:
        logger.error(str(e))
        sys.exit(ExitCode.CONFIG_ERROR.value)
    except AuthenticationError as e:
        logger.error(str(e))
        sys.exit(ExitCode.AUTH_ERROR.value)
    except AutomationBaseError as e:
        logger.error(str(e))
        sys.exit(e.exit_code.value)

if __name__ == "__main__":
    main()
```

---

## 8. Documentation Requirements

### 8.1 README.md — Minimum Viable Documentation

Every automation repository must have a README that answers these questions within the first 20 lines:

1. What does this automation do?
2. How do I run it?
3. What credentials does it need?
4. Where are results written?
5. How do I contribute?

**Template**:

```markdown
# External Recon Pipeline

Performs daily subdomain enumeration and vulnerability scanning for scoped assets.

## Run Locally

\```bash
cp .env.example .env
# Fill in SHODAN_API_KEY, TARGETS_PATH
python -m pip install -r requirements.txt
python scripts/run_daily_scan.py --targets config/scan_targets.yaml
\```

## Outputs

- JSONL findings: `volumes/results/<scan_id>.findings.jsonl`
- SARIF report: `volumes/results/<scan_id>.sarif`
- Markdown summary: `volumes/results/<scan_id>.md`

## Architecture

See `docs/` for the full design.
```

### 8.2 Docstrings — Google Style

All public functions and classes must have docstrings. Enforce with `pydocstyle` in CI.

```python
def probe_http_targets(
    hosts: Sequence[str],
    client: httpx.AsyncClient,
    timeout: float = 10.0,
    safelist: frozenset[str] | None = None,
) -> list[dict]:
    """Probe a list of HTTP(S) endpoints and return live host results.

    Args:
        hosts: Fully qualified URLs to probe.
        client: Reusable HTTP/2 capable async client.
        timeout: Per-request timeout in seconds.
        safelist: Optional set of allowed hostnames. Defaults to
            the project's `ALLOWED_DOMAINS` constant when None.

    Returns:
        A list of dicts. Each dict contains `url`, `status` (int),
        and optionally `title` (str) and `skipped` (bool).

    Raises:
        httpx.HTTPError: Propagated only if all requests fail and
            `strict` mode is enabled.
    """
    ...
```

---

## 9. Review Checklists

### 9.1 Pre-Commit Checklist

Before submitting a PR, the author must verify:

- [ ] `ruff check .` passes with zero warnings
- [ ] `mypy src/` passes with zero type errors (new files use `--strict`)
- [ ] All test files updated for changed behavior (`pytest tests/`)
- [ ] New config keys documented in the schema reference (`docs/config-schema.md`)
- [ ] Secrets are loaded via env vars or a secrets manager, never hardcoded
- [ ] `correlation_id` is generated and logged for every pipeline invocation
- [ ] Exit code mapping verified in `main()` entrypoint
- [ ] Output written to the conventional path under `volumes/results/`

### 9.2 PR Review Checklist

The reviewer must verify:

- [ ] Change is scoped to the stated purpose (no scope creep)
- [ ] New dependencies added to `pyproject.toml` with version pins
- [ ] Any new cloud IAM permissions are listed and justified in the PR description
- [ ] Retry counts and timeouts are appropriate for the target tool
- [ ] `safelist` is enforced before any external request leaves the environment
- [ ] No PII, credentials, or raw scan results are committed to git history
- [ ] Rate-limiting headers or backoff logic present for every external API client
- [ ] `results_bucket` is the non-production bucket by default unless explicitly overridden

---

## 10. Compatibility Guarantees

### 10.1 Python Version Support

Specify a supported Python version range in `pyproject.toml`. Do not rely on bleeding-edge language features without a pinned minimum version.

```toml
[project]
requires-python = ">=3.12,<3.14"
```

This guarantees the codebase runs on Python 3.12 and 3.13 but not on 3.11 or 3.14.

### 10.2 Tool Version Pinning

Pin every external scanner tool to a specific version. Document known-breaking version changes.

**In Dockerfiles**:

```dockerfile
ARG SUBFINDER_VERSION=v2.12.0
ARG NUCLEI_VERSION=v3.3.4
ARG HTTPX_VERSION=v1.6.8
```

**In code (for tools invoked as subprocesses)**:

```python
# config/tool_versions.yaml
subfinder:
  version: v2.12.0
  min_version: v2.10.0
  known_breaking:
    - version: v2.12.0
      note: "--silent flag renamed to --output-mode silent"
nuclei:
  version: v3.3.4
  min_version: v3.0.0
```

**Version validation at startup**:

```python
import subprocess
import re

def validate_tool_version(tool: str, required: str) -> str:
    result = subprocess.run([tool, "-version"], capture_output=True, text=True, timeout=5)
    output = result.stdout + result.stderr
    match = re.search(r"v?\d+\.\d+\.\d+", output)
    if not match:
        raise ConfigurationError(f"Cannot determine {tool} version")
    detected = match.group(0)
    logger.info("tool_version", extra={"tool": tool, "detected": detected, "required": required})
    return detected
```

### 10.3 Output Format Versions

Every output file must include a `schema_version` field so downstream consumers can evolve gracefully.

```json
{
  "schema_version": "2.0.0",
  "scan_id": "...",
  "findings": [...]
}
```

Maintain a changelog of schema versions in `docs/output-schema-changelog.md`.

---

## 11. Makefile — Common Targets

A single `Makefile` replaces ad-hoc shell commands and enforces consistency across contributors.

```makefile
.PHONY: lint format typecheck test scan clean all

VERSION := $(shell cat VERSION)
PYTHON := python3
RUFF   := ruff

lint:
	$(RUFF) check src/ cloud/ scripts/

format:
	$(RUFF) format src/ cloud/ scripts/

typecheck:
	mypy src/ --strict

test:
	pytest tests/ -v --tb=short

sort-imports:
	$(RUFF) check --select I src/ cloud/ scripts/ --fix

scan:
	$(PYTHON) scripts/run_daily_scan.py --targets config/scan_targets.yaml

clean:
	rm -rf volumes/results/*.jsonl volumes/results/*.sarif volumes/results/*.html
	rm -rf .pytest_cache .mypy_cache .ruff_cache

all: lint typecheck test
```

Every contributor runs `make all` before pushing. CI runs the same targets.

---

## 12. Compatibility Guarantees for Breakage Prevention

| Guarantee                         | Enforcement                         |
|-----------------------------------|-------------------------------------|
| Public API functions are typed    | `mypy --strict` in CI               |
| Output format is versioned        | `schema_version` field in every file|
| Tool versions are pinned          | SHA pin in Dockerfile / lock file    |
| Python version range is declared  | `requires-python` in pyproject.toml  |
| CI passes before merge            | Branch protection rule              |
| Breaking changes require MAJOR bump | Semver + CHANGELOG check           |
| Config schema is versioned        | `config_schema_version` in every config file |

**Semver enforcement in CI**:

```yaml
- name: Verify semver tags
  run: |
    TAG="${GITHUB_REF#refs/tags/}"
    if ! echo "$TAG" | grep -Eq '^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$'; then
      echo "Tag $TAG does not follow semver. Expected vX.Y.Z"
      exit 1
    fi
```

---

## 13. Constants and Global State

Centralize global constants in a single module. No string literals scattered across modules.

```python
# src/scan_platform/constants.py
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
RESULTS_DIR = REPO_ROOT / "volumes" / "results"
CONFIG_DIR  = REPO_ROOT / "config"
SCHEMA_VERSION = "2.0.0"

ALLOWED_DOMAINS: frozenset[str] = frozenset({
    "example.com", "target.com", "app.target.com",
})

DEFAULT_TIMEOUT = 10.0
DEFAULT_RATE_LIMIT = 150
MAX_CONCURRENT_SCANS = 20
```

Import from this module everywhere:

```python
from scan_platform.constants import RESULTS_DIR, ALLOWED_DOMAINS
```

---

## 14. Security Standards for Automation Code

- **No hardcoded secrets**: run `detect-secrets` or `gitleaks` in pre-commit.
- **No `shell=True`** in subprocess calls unless absolutely necessary and sanitized.
- **No `eval()` or `exec()`** on untrusted input.
- **Validate all external input** with Pydantic before processing.
- **Enforce SSL verification**: `httpx.Client(verify=True)` — never disable.
- **Use `frozenset` for safelists** so accidental mutation is caught at type-check time.
- **Pin all transitive dependencies**: run `pip-compile-multi` and commit the `.in`/`.txt` lock files.
- **Rotate secrets quarterly** and automate discovery of stale credentials.

```bash
# pre-commit hook config (.pre-commit-config.yaml)
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.11.0
    hooks:
      - id: mypy
        additional_dependencies: ["types-requests"]
```

---

## 15. Version Control Conventions

- **main branch** is always deployable.
- **PR size**: each PR addresses a single, reviewable concern (< 400 lines changed).
- **Commit messages**: imperative mood, scoped prefix.

```
scan(subfinder): add timeout guard for stalled DNS resolution

- Wrap subprocess call in asyncio.wait_for with 120s cap
- Log TimeoutError without retrying (subdomain data is partial)
- Fixes #42
```

**Branch naming**:

| Type       | Pattern                    | Example                             |
|------------|----------------------------|-------------------------------------|
| Feature    | `feat/description`         | `feat/nuclei-filter-by-severity`    |
| Bugfix     | `fix/description`          | `fix/s3-credential-leak-logging`    |
| Hotfix     | `hotfix/description`       | `hotfix/rate-limit-backoff`         |
| Chore      | `chore/description`        | `chore/upgrade-nuclei-v3.3.5`       |
| Documentation | `docs/description`      | `docs/cloud-automation-principles`  |
| Refactor   | `refactor/description`     | `refactor/extract-http-client`      |

---

## 16. Release and Versioning Policy

- Follow semantic versioning (MAJOR.MINOR.PATCH).
- MAJOR: incompatible output schema change or breaking API change.
- MINOR: new features (new scanner integration, new output format support).
- PATCH: bug fixes, documentation corrections.

**Automated release with GitHub Actions**:

```yaml
name: Release
on:
  push:
    tags: ["v*"]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: registry.example.com
          username: ${{ secrets.REGISTRY_USER }}
          password: ${{ secrets.REGISTRY_PASS }}
      - uses: docker/build-push-action@v6
        with:
          tags: |
            registry.example.com/scanner:${{ github.ref_name }}
            registry.example.com/scanner:latest
          push: true
          platforms: linux/amd64,linux/arm64
          cache-from: type=registry,ref=registry.example.com/scanner:buildcache
          cache-to: type=registry,ref=registry.example.com/scanner:buildcache,mode=max
```
