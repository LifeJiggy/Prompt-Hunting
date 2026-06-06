# Automation-Efficiency 22: Version Control for Tools

## Overview

Security tools change output formats, flag behavior, and supported flags between releases. A Nuclei template update may change JSON keys. An httpx upgrade may drop a flag. Without version control for your tool wrappers, automation pipelines break silently or produce false negatives. This document covers version pinning strategies, upgrade automation, changelog parsing, breaking-change detection, directory structure, git submodules for wrappers, binary versioning, rollback, and release notes.

---

## 1. Why Version Control for Tools Matters

### Failure Modes Without Version Pinning

| Scenario | Symptom | Root Cause |
|----------|---------|------------|
| Nuclei updates from 9.x to 10.0 | JSON output schema changed, parser crashes | No version pin |
| subfinder adds `-silent` flag removal | CI produces empty output | Wrapper not pinned |
| ffuf switches positional arg order | Fuzz paths hit wrong wordlists | Upgrade auto-merged |
| amass deprecates `-passive` | Every scan blocks on active enumeration | Breaking change undetected |

### The Rule

**Every tool involved in automation must have its version locked. Reproducibility requires the exact same binaries producing the exact same outputs for the exact same inputs.**

---

## 2. Version Pinning Strategies

### Semver Ranges (Compatible Changes Only)

Use semver ranges for tool categories where breaking changes are rare and the community documents them clearly.

```toml
# requirements-tools.toml
[tool.poetry.dependencies]
nuclei = ">=9.6.0,<10.0.0"      # 9.x.y safe, auto-patches
httpx = ">=1.0.0,<2.0.0"        # 1.x.y safe
subfinder = ">=2.6.0,<3.0.0"    # pinned major version
```

**Trade-off:** You get security patches but risk schema drift within the major version.

### Commit Hash Pinning (Exact Reproducibility)

Pin to a specific git commit for source-built tools or community forks.

```toml
[tool.poetry.dependencies]
nuclei = { git = "https://github.com/projectdiscovery/nuclei.git", rev = "v3.1.7" }
custom-nuclei-templates = { git = "https://github.com/offensive-ops/templates.git", rev = "a1b2c3d" }
```

```bash
# Lock file records exact commit
poetry lock
cat poetry.lock | grep -A5 "name = \"nuclei\""
# Shows: version = "0.0.0", source = { git = "...", rev = "a1b2c3" }
```

### Binary Digest Pinning (No Build Required)

For pre-built Go binaries, pin by release tag and verify SHA256.

```bash
# .bounty/versions.lock
[go-tools]
nuclei = { version = "v3.1.7", sha256 = "abc123...", source = "github.com/projectdiscovery/nuclei" }
httpx  = { version = "v1.6.7", sha256 = "def456...", source = "github.com/projectdiscovery/httpx" }
subfinder = { version = "v2.6.6", sha256 = "789abc...", source = "github.com/projectdiscovery/subfinder" }

[python-pkgs]
requests = "2.32.3"
pydantic = "2.10.4"
```

Verify on install:
```python
import hashlib, urllib.request

def verify_binary(url: str, expected_sha256: str) -> bytes:
    data = urllib.request.urlopen(url).read()
    actual = hashlib.sha256(data).hexdigest()
    if actual != expected_sha256:
        raise ValueError(f"SHA256 mismatch: {actual} != {expected_sha256}")
    return data

# Install path
def install_go_tool(name: str, version: str, expected_sha: str):
    url = f"https://github.com/projectdiscovery/{name}/releases/download/{version}/{name}-linux-amd64.zip"
    data = verify_binary(url, expected_sha)
    Path(f"/opt/tools/{name}").write_bytes(data)
```

---

## 3. Tool Directory Structure

A reproducible layout makes rollback atomic and isolates tools per-version.

```
/opt/tools/                          ← root for all installed tools
├── nuclei/
│   ├── current -> v3.1.7/           ← symlink: always points to active version
│   ├── v3.1.7/
│   │   ├── nuclei                   ← binary
│   │   ├── templates/               ← bundled templates
│   │   └── .version                 ← file containing "v3.1.7"
│   ├── v3.0.8/                      ← previous version (retained for rollback)
│   └── versions.lock                ← this tool's version record
├── httpx/
│   ├── current -> v1.6.7/
│   ├── v1.6.7/httpx
│   └── v1.5.10/httpx
├── wrappers/
│   ├── run_nuclei.sh                ← calls /opt/tools/nuclei/current/nuclei
│   ├── run_httpx.sh
│   └── common.sh                    ← shared env setup
└── versions.lock                    ← authoritative lock for all tools
```

### Symlink Approach (Preferred)

All automation references `current`. Switching versions is a symlink change (atomic on most filesystems).

```bash
ln -sfn /opt/tools/nuclei/v3.1.7 /opt/tools/nuclei/current
echo "v3.1.7" > /opt/tools/nuclei/.version
```

```python
# wrapper/py_bounty/tools.py
import subprocess
from pathlib import Path

TOOLS_DIR = Path("/opt/tools")

def tool_binary(tool_name: str) -> Path:
    return TOOLS_DIR / tool_name / "current" / tool_name

def tool_version(tool_name: str) -> str:
    return (TOOLS_DIR / tool_name / ".version").read_text().strip()

def run_tool(tool_name: str, args: list[str]) -> subprocess.CompletedProcess:
    binary = tool_binary(tool_name)
    version_file = TOOLS_DIR / tool_name / ".version"
    if not binary.exists():
        raise FileNotFoundError(f"Tool {tool_name} not installed at {binary}")
    log.info(f"Running {tool_name} {version_file.read_text().strip()}")
    return subprocess.run([str(binary)] + args, capture_output=True, text=True)
```

---

## 4. Upgrade Automation

Automated upgrades are triggered by new releases but never auto-applied to the running environment. Use a staged promotion model: download → verify → shadow-test → promote.

### Staged Upgrade Pipeline

```
Stage 1: DISCOVER   — Poll tool repos for new releases
Stage 2: DOWNLOAD   — Fetch binary, verify SHA256
Stage 3: VALIDATE   — Run smoke test against a known fixture
Stage 4: INSTALL    — Unpack to /opt/tools/<tool>/vX.Y.Z/
Stage 5: SHADOW     — Run parallel with current, compare outputs
Stage 6: PROMOTE    — Symlink switch + lock file update
Stage 7: CLEANUP    — Remove versions older than N (configurable)
```

### Upgrade Automation Script

```python
#!/usr/bin/env python3
# scripts/upgrade_tool.py

import requests, subprocess, hashlib, shutil, json
from pathlib import Path
from datetime import datetime

INSTALL_DIR = Path("/opt/tools")
LOCK_FILE  = INSTALL_DIR / "versions.lock"
RETENTION  = 3  # keep last 3 versions

GITHUB_REPOS = {
    "nuclei":   "projectdiscovery/nuclei",
    "httpx":    "projectdiscovery/httpx",
    "subfinder": "projectdiscovery/subfinder",
}

def check_release(repo: str) -> dict | None:
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    r = requests.get(url, timeout=10)
    if r.status_code != 200:
        return None
    data = r.json()
    return {
        "tag": data["tag_name"],
        "url": next(a["browser_download_url"]
                     for a in data["assets"]
                     if a["name"].endswith("linux-amd64.zip")),
        "sha256": next(
            next((h for h in a.get("digests", {})
                  if h["alg"] == "sha256"), {})
            for a in data["assets"]
            if a["name"].endswith(".zip")
        )["value"],
    }

def download_and_verify(url: str, expected_sha: str) -> bytes:
    data = requests.get(url, timeout=60).content
    actual = hashlib.sha256(data).hexdigest()
    assert actual == expected_sha, f"SHA256 mismatch: {actual}"
    return data

def install_version(tool: str, tag: str, binary_data: bytes):
    dest = INSTALL_DIR / tool / tag
    dest.mkdir(parents=True, exist_ok=True)
    (dest / tool).write_bytes(binary_data)
    (dest / tool).chmod(0o755)
    (INSTALL_DIR / tool / ".version").write_text(tag)

def cleanup_old_versions(tool: str):
    versions = sorted(
        (p.name for p in (INSTALL_DIR / tool).iterdir()
         if p.is_dir() and p.name not in ("current")),
        reverse=True,
    )
    for old in versions[RETENTION:]:
        shutil.rmtree(INSTALL_DIR / tool / old)

def run_smoke_test(tool: str, tag: str) -> bool:
    binary = INSTALL_DIR / tool / tag / tool
    result = subprocess.run(
        [str(binary), "-version"],
        capture_output=True, text=True, timeout=10,
    )
    return result.returncode == 0

def upgrade_tool(tool: str):
    repo = GITHUB_REPOS[tool]
    info = check_release(repo)
    if not info:
        print(f"[WARN] Could not fetch release for {tool}")
        return
    current_tag = (INSTALL_DIR / tool / ".version").read_text().strip()
    if info["tag"] == current_tag:
        print(f"[OK] {tool} already at {current_tag}")
        return
    print(f"[UPGRADE] {tool}: {current_tag} -> {info['tag']}")
    data = download_and_verify(info["url"], info["sha256"])
    install_version(tool, info["tag"], data)
    if not run_smoke_test(tool, info["tag"]):
        raise RuntimeError(f"Smoke test failed for {tool} {info['tag']}")
    symlink = INSTALL_DIR / tool / "current"
    symlink.symlink_to(info["tag"])
    cleanup_old_versions(tool)
    update_lock_file(tool, info["tag"])
    print(f"[DONE] {tool} upgraded to {info['tag']}")

def update_lock_file(tool: str, tag: str):
    lock = json.loads(LOCK_FILE.read_text()) if LOCK_FILE.exists() else {}
    lock.setdefault("go-tools", {})[tool] = {
        "version": tag,
        "updated_at": datetime.utcnow().isoformat() + "Z",
    }
    LOCK_FILE.write_text(json.dumps(lock, indent=2))
```

Schedule via cron:
```
0 3 * * 0  /usr/bin/python3 /opt/bounty/scripts/upgrade_tool.py nuclei
30 3 * * 0  /usr/bin/python3 /opt/bounty/scripts/upgrade_tool.py httpx
0 4 * * 0   /usr/bin/python3 /opt/bounty/scripts/upgrade_tool.py subfinder
```

---

## 5. Changelog Parsing and Breaking-Change Detection

Automate detection of breaking changes by monitoring CHANGELOG.md or release notes.

### Changelog Parser

```python
import re

BREAKING_PATTERNS = [
    re.compile(r"\bBREAKING[_\s]CHANGE\b", re.I),
    re.compile(r"breaking", re.I),
    re.compile(r"removed\s+\`?\w+\`?", re.I),
    re.compile(r"no longer\s+support", re.I),
    re.compile(r"deprecated", re.I),
    re.compile(r"flag\s+`?-(\w+)`?\s+(removed|renamed|deprecated)", re.I),
]

def analyze_changelog(changelog_md: str, tool: str) -> list[dict]:
    findings = []
    for line in changelog_md.splitlines():
        for pat in BREAKING_PATTERNS:
            if pat.search(line):
                findings.append({
                    "tool": tool,
                    "line": line.strip(),
                    "requires_action": True,
                })
    return findings

# Fetch changelog from GitHub
def fetch_changelog(repo: str) -> str:
    url = f"https://raw.githubusercontent.com/{repo}/master/CHANGELOG.md"
    return requests.get(url, timeout=15).text

# Run daily
for tool, repo in GITHUB_REPOS.items():
    changelog = fetch_changelog(repo)
    risks = analyze_changelog(changelog, tool)
    if risks:
        send_alert(f"[BREAKING CHANGE] {tool}: {risks}")
```

### Flag Drift Detector

```python
import subprocess, re

def get_supported_flags(tool: str) -> set[str]:
    result = subprocess.run(
        [str(tool_binary(tool)), "-h"],
        capture_output=True, text=True,
    )
    return set(re.findall(r"^  -(\S+)", result.stdout, re.M))

def diff_flags(tool: str, old_flags: set[str], new_flags: set[str]):
    removed = old_flags - new_flags
    added   = new_flags  - old_flags
    if removed:
        send_alert(f"[FLAG REMOVED] {tool}: -{', -'.join(removed)}")
    if added:
        log.info(f"[FLAG ADDED]   {tool}: -{', -'.join(added)}")
    return removed, added
```

---

## 6. Git Submodules for Tool Wrappers

Version-control your own automation scripts and wrappers using git submodules. This keeps the repo small while tracking external wrapper code.

### Directory Layout with Submodules

```
bounty-workspace/
├── .gitmodules
├── configs/                            ← your project configs
├── wrappers/                           ← git submodule: your wrapper scripts
│   └── subfinder/nuclei/
│       ├── wrapper.sh
│       └── py_bounty/
├── nuclei-templates/                   ← git submodule: curated templates
│   └── nuclei-templates/
└── tools/                              ← binaries, not in git (in .gitignore)
```

### `.gitmodules`

```ini
[submodule "wrappers/py_bounty"]
    path = wrappers/py_bounty
    url = git@github.com:your-org/py_bounty.git
    branch = main

[submodule "nuclei-templates"]
    path = nuclei-templates
    url = git@github.com:your-org/nuclei-templates.git
    branch = main
```

### Submodule Workflow

```bash
git submodule init
git submodule update
# Pin specific commit
cd wrappers/py_bounty && git checkout v1.2.0 && cd -
cd nuclei-templates && git checkout 2025-06-01 && cd -
git add wrappers/py_bounty nuclei-templates
git commit -m "chore: pin submodules to verified commits"

# Update a submodule
cd wrappers/py_bounty && git pull && git checkout v1.3.0 && cd -
git add wrappers/py_bounty
git commit -m "chore: upgrade py_bounty wrapper to v1.3.0"
```

---

## 7. Binary Versioning without Git

DO NOT commit tool binaries to git. Use an external version manifest in your wrapper repo.

`versions.lock` (committed to git):
```json
{
  "generated_at": "2025-06-05T00:00:00Z",
  "go-tools": {
    "nuclei": { "version": "v3.1.7", "sha256": "abc123", "os": "linux", "arch": "amd64" },
    "httpx":  { "version": "v1.6.7", "sha256": "def456", "os": "linux", "arch": "amd64" },
    "subfinder": { "version": "v2.6.6", "sha256": "789abc", "os": "linux", "arch": "amd64" }
  },
  "python-pkgs": {
    "requests": "2.32.3",
    "pydantic": "2.10.4",
    "httpx":    "0.27.2"
  }
}
```

Enforce in CI:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "==> Verifying tool binary checksums..."
python scripts/verify_tools.py versions.lock

echo "==> Checking virtualenv packages..."
pip freeze | sort > /tmp/actual.txt
python scripts/check_requirements.txt

echo "==> All versions verified."
```

---

## 8. Rollback Procedures

Rollbacks must be fast and atomic. Use the symlink approach described above.

### Rollback Script

```python
#!/usr/bin/env python3
# scripts/rollback_tool.py

import sys, shutil, json
from pathlib import Path

INSTALL_DIR = Path("/opt/tools")
LOCK_FILE  = INSTALL_DIR / "versions.lock"

def rollback(tool: str, target_version: str | None = None):
    tool_dir = INSTALL_DIR / tool
    symlink  = tool_dir / "current"
    versions = sorted(
        p.name for p in tool_dir.iterdir()
        if p.is_dir() and p.name != "current"
    )
    if not versions:
        raise RuntimeError(f"No historical versions found for {tool}")
    target = target_version or versions[-1]   # roll back 1 version by default
    if target not in versions:
        raise ValueError(f"Version {target} not installed. Available: {versions}")
    print(f"[ROLLBACK] {tool}: {symlink.readlink()} -> {target}")
    symlink.unlink()
    symlink.symlink_to(target)
    (tool_dir / ".version").write_text(target)
    update_lock(tool, target)
    print(f"[OK] {tool} rolled back to {target}")

def update_lock(tool: str, version: str):
    lock = json.loads(LOCK_FILE.read_text())
    lock["go-tools"][tool]["version"] = version
    LOCK_FILE.write_text(json.dumps(lock, indent=2))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: rollback_tool.py <tool> [version]")
        sys.exit(1)
    rollback(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
```

Usage:
```bash
# Roll back nuclei by one version
python scripts/rollback_tool.py nuclei

# Roll back to a specific version
python scripts/rollback_tool.py httpx v1.5.10
```

Full pipeline rollback:
```bash
#!/usr/bin/env bash
# scripts/rollback_all.sh
LOCK_FILE="/opt/tools/versions.lock"
python scripts/rollback_tool.py $(jq -r '.go-tools | keys[]' "$LOCK_FILE")
echo "All tools rolled back to previous versions."
```

---

## 9. Release Notes Integration

Parse release notes automatically to build a local change log and alert on updates.

### Release Note Archiver

```python
import requests, json
from datetime import datetime
from pathlib import Path

NOTES_DIR = Path("/opt/bounty/docs/release-notes")
NOTES_DIR.mkdir(parents=True, exist_ok=True)

def archive_release_notes(repo: str, tag: str):
    url = f"https://api.github.com/repos/{repo}/releases/tags/{tag}"
    data = requests.get(url, timeout=15).json()
    body = data.get("body", "")
    filename = NOTES_DIR / f"{repo.replace('/', '-')}-{tag}.md"
    filename.write_text(f"# {tag} — {data.get('published_at', '')}\n\n{body}")
    log.info(f"Archived release notes: {filename}")
    # Index
    index_file = NOTES_DIR / "INDEX.jsonl"
    with open(index_file, "a") as idx:
        idx.write(json.dumps({
            "repo": repo,
            "tag": tag,
            "published_at": data.get("published_at"),
            "body_preview": body[:200],
            "file": str(filename),
        }) + "\n")

# Run after every successful upgrade
for tool, repo in GITHUB_REPOS.items():
    archive_release_notes(repo, current_tag)
```

### Weekly Digest Email

```python
def send_weekly_digest():
    from email.mime.text import MIMEText
    entries = []
    for f in sorted(NOTES_DIR.glob("*.md")):
        stat = f.stat()
        if datetime.fromtimestamp(stat.st_mtime) > week_ago():
            entries.append(f"- {f.stem}: {f.read_text()[:300]}...")
    body = "## Tool Updates This Week\n\n" + "\n".join(entries)
    msg = MIMEText(body, "markdown")
    msg["Subject"] = "Bounty Tool Update Digest"
    msg["From"]    = os.environ["SMTP_FROM"]
    msg["To"]      = os.environ["SMTP_TO"]
    smtp.send_message(msg)
```

---

## 10. Version Enforcement in CI/CD

Prevent runs with mismatched tool versions.

```python
# scripts/check_versions.py
def enforce_versions(lock_file: str):
    lock = json.loads(Path(lock_file).read_text())
    violations = []
    for tool, meta in lock["go-tools"].items():
        installed = tool_version(tool)
        if installed != meta["version"]:
            violations.append(f"{tool}: installed={installed}, expected={meta['version']}")
    if violations:
        raise RuntimeError("Version violations:\n" + "\n".join(violations))

# In CI pipeline
enforce_versions("versions.lock")
```

---

## 11. Checklist

- [ ] All tools listed in `versions.lock` with exact versions + SHA256 digests
- [ ] `/opt/tools/<tool>/current` is a symlink, never a direct copy
- [ ] At least 2 previous versions retained per tool for rollback
- [ ] `upgrade_tool.py` runs weekly via cron, sends Slack alert on upgrades
- [ ] Changelog parsed for BREAKING CHANGE flags before promotion
- [ ] Flag diff detected between old and new version smoke tests
- [ ] Wrapper scripts in git submodules, pinned to specific commits
- [ ] Release notes archived to `docs/release-notes/` after every upgrade
- [ ] CI enforces `enforce_versions()` before any scan job starts
- [ ] Rollback procedure tested in staging at least once per quarter
