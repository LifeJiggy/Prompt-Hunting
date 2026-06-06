# Automation-Efficiency 23: Collaboration Workflows

## Overview

Bug bounty teams ranging from two-person startups to 50+ researcher collectives all share the same challenge: distributing recon work without losing context, duplicating effort, or stepping on each other's findings. This document covers shared workspace design, result sync protocols, conflict resolution, merge workflows, push notifications, shared config layers, attribution tracking, team-specific tool configs, and permission boundaries.

---

## 1. Shared Workspace Architecture

### Storage Backend Comparison

| Backend | Latency | Offline Cache | Cost | Best For |
|---------|---------|---------------|------|----------|
| S3 + s3fs | Low | No | $ | Cloud-native, long-term archive |
| SFTP (internal) | Medium | No | $ | Existing infra, no cloud |
| NFS/NAS | Very low | Yes (local) | $$ | On-premise, LAN |
| Syncthing | P2P | Yes | $ | Offline-capable, ad-hoc teams |
| Git | Versioned | Full | $ | Text results only |

**Recommended hybrid:** Git for structured results (findings, configs, reports) + S3 for large binary artifacts (screenshots, HAR files, raw nuclei JSON dumps).

### S3 Workspace Layout

```
bounty-workspace/
├── configs/                    ← shared, versioned in git
├── results/
│   ├── raw/                    ← S3: nuclei JSONl, httpx output
│   │   ├── by-date/
│   │   │   └── 2025-06-05/
│   │   └── by-target/
│   │       └── example.com/
│   ├── processed/              ← findings after dedup
│   │   ├── open/
│   │   └── submitted/
│   └── reports/                ← final reports
├── screenshots/                ← S3: evidence artifacts
│   └── finding-ids/
└── lock-files/                 ← coordination state
    ├── active-targets.lock
    └── assignment.lock
```

S3 path convention:
```
s3://bounty-workspace/results/raw/by-target/example.com/nuclei-20250605T143022Z.jsonl
s3://bounty-workspace/results/processed/open/F-2025-001.json
s3://bounty-workspace/screenshots/finding-0042/referer-leak.png
```

---

## 2. Result Sync Protocol

### Pull Model (Polling-Based)

Each researcher runs a local agent that periodically syncs.

```python
import boto3, hashlib
from pathlib import Path

s3 = boto3.client("s3")
BUCKET = "bounty-workspace"
LOCAL_RESULTS = Path("./results")
SYNC_INTERVAL = 300   # 5 minutes

def list_since(since_iso: str, prefix: str) -> list[dict]:
    resp = s3.list_objects_v2(
        Bucket=BUCKET,
        Prefix=prefix,
        StartAfter=since_iso,
    )
    return resp.get("Contents", [])

def download_new(since_iso: str, prefix: str = "results/raw/"):
    objs = list_since(since_iso, prefix)
    for obj in objs:
        dest = LOCAL_RESULTS / obj["Key"]
        dest.parent.mkdir(parents=True, exist_ok=True)
        s3.download_file(BUCKET, obj["Key"], str(dest))
        log.info(f"Synced: {obj['Key']} ({obj['Size']} bytes)")
    return objs

# Cron/polling loop
last_sync = load_last_sync_timestamp()
download_new(last_sync)
save_last_sync_timestamp(datetime.utcnow().isoformat())
```

### Push Model (Event-Based)

Use S3 Event Notifications → Lambda → Slack webhook.

```yaml
# CloudFormation / Terraform
# S3 bucket notification on PUT for results/processed/
AWS::S3::Bucket:
  Properties:
    NotificationConfiguration:
      LambdaConfigurations:
        - Event: s3:ObjectCreated:*
          Filter:
            S3Key:
              Rules:
                - Name: prefix
                  Value: results/processed/
          Function: !GetAtt NewFindingNotifier.Arn
```

Lambda handler:
```python
def handler(event, context):
    for record in event["Records"]:
        bucket  = record["s3"]["bucket"]["name"]
        key     = record["s3"]["object"]["key"]
        body    = json.loads(s3.get_object(bucket, key)["Body"].read())
        finding = {
            "target": extract_target(key),
            "severity": body.get("severity"),
            "title": body.get("title"),
            "url": f"https://bounty-hunter.example.com/findings/{body['id']}",
        }
        slack_webhook(finding)
```

---

## 3. Conflict Resolution

### ETag-Based Merge for JSON Findings

S3 ETags (or file hashes for git) identify conflicting writes.

```python
import json, hashlib

def atomic_upload(local_path: Path, s3_key: str):
    content = local_path.read_bytes()
    etag = hashlib.md5(content).hexdigest()
    s3.head_object(BUCKET, s3_key)  # raises 404 or returns current ETag
    # Optimistic lock
    try:
        s3.put_object(
            Bucket=BUCKET,
            Key=s3_key,
            Body=content,
            IfMatch=current_etag,      # overwrite only if unchanged
        )
        log.info(f"Uploaded: {s3_key}")
    except s3.exceptions.PreconditionFailed:
        log.warning(f"Conflict on {s3_key}, pulling remote and merging")
        remote  = s3.get_object(BUCKET, s3_key)["Body"].read()
        merged  = merge_findings(
            json.loads(remote),
            json.loads(content),
        )
        s3.put_object(Bucket=BUCKET, Key=s3_key, Body=json.dumps(merged))
```

### Git Merge Strategy for Shared Config

```bash
# Rebase config changes on top of main before pushing
git checkout feature/my-target
git rebase main
git push origin feature/my-target
# If conflict in configs/project/example-com.toml:
#  - Resolve manually by comparing both branches
#  - Mark conflict resolved
git add configs/project/example-com.toml
git rebase --continue
```

Conflict markers handling in non-code TOML:
Resolve by taking the union of top-level keys from both versions, not purely line-based merge. A custom merge driver is recommended for TOML.

`.gitattributes` entry:
```
configs/*.toml merge=toml-union
```

Custom merge driver (`.git/config`):
```
[merge "toml-union"]
    name = TOML union merge driver
    driver = python scripts/toml_merge_driver.py %A %O %B %L
```

---

## 4. Merge Workflows for Shared Data

### Pull Request Flow for Findings

```
1. Researcher A discovers XSS → writes finding F-2025-042
   → results/processed/open/F-2025-042.json
2. git pull origin main (always rebase first)
3. git checkout -b feature/F-2025-042
4. git add results/processed/open/F-2025-042.json configs/project/example-com.toml
5. git commit -m "find: stored XSS on example.com/contact (F-2025-042)"
6. Ensure finding is NOT in results/processed/open/ (dedup check first)
7. git push -u origin feature/F-2025-042
8. Open PR with checklist:
   - [ ] Finding triaged as valid (not N/A)
   - [ ] Screenshot attached
   - [ ] Scope verified
   - [ ] Console-only or richtext PoC included
   - [ ] HAR file sanitized (cookies redacted)
```

### Dedup Before Commit (Critical)

```python
def is_duplicate(new_finding: dict, existing_dir: Path) -> bool:
    for existing in existing_dir.glob("F-*.json"):
        data = json.loads(existing.read_text())
        if (
            data["target"]   == new_finding["target"]
            and data["type"]  == new_finding["type"]
            and data["url"]   == new_finding["url"]
            and data["param"] == new_finding.get("param")
        ):
            log.warning(f"Duplicate found: {existing.name}")
            return True
    return False

# Reject duplicate before testing or reporting
new = load_finding_candidate()
if is_duplicate(new, LOCAL_RESULTS / "processed/open"):
    print("Duplicate — skipping commit")
else:
    save_and_commit(new)
```

---

## 5. Push Notification on New Findings

### Slack Integration

```python
import os, requests
from dataclasses import dataclass

@dataclass
class Finding:
    id: str
    severity: str
    title: str
    target: str
    url: str
    discovered_by: str
    discovered_at: str

SEVERITY_COLORS = {
    "critical": "#ff0000",
    "high":     "#ff6600",
    "medium":   "#ffcc00",
    "low":      "#36a64f",
    "info":     "#808080",
}

SEVERITY_EMOJI = {
    "critical": "🚨",
    "high":     "🔴",
    "medium":   "🟡",
    "low":      "🟢",
    "info":     "ℹ️",
}

def slack_webhook_url() -> str | None:
    return os.environ.get("SLACK_FINDINGS_WEBHOOK")

def post_finding_to_slack(f: Finding):
    webhook = slack_webhook_url()
    if not webhook:
        return
    payload = {
        "attachments": [{
            "color": SEVERITY_COLORS.get(f.severity, "#808080"),
            "title": f"{SEVERITY_EMOJI.get(f.severity, '')} {f.title}",
            "fields": [
                {"title": "Finding ID",   "value": f.id,      "short": True},
                {"title": "Target",       "value": f.target,  "short": True},
                {"title": "Discovered by","value": f.discovered_by, "short": True},
                {"title": "URL",          "value": f.url,     "short": False},
            ],
            "footer": "Bounty Hunter Automation",
            "ts": int(datetime.fromisoformat(f.discovered_at).timestamp()),
        }]
    }
    requests.post(webhook, json=payload, timeout=10)

# Hook into merge pipeline
def on_finding_merged(finding_path: Path):
    f = Finding(**json.loads(finding_path.read_text()))
    post_finding_to_slack(f)
    update_team_dashboard(f)
```

### Webhook from Git Push

```yaml
# .github/workflows/finding-alert.yml
on:
  push:
    branches: [main]
    paths:
      - "results/processed/open/*.json"
jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Post new findings to Slack
        env:
          SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
        run: python scripts/notify_new_findings.py
```

---

## 6. Shared Config Layer

The shared config is the single source of truth for tool settings, target scope, and notification channels.

`configs/shared/base.toml` (committed to git, team-wide):
```toml
[scan]
default_threads = 20
delay_seconds = 0
politeness_policy = true

[report]
default_format = "json"
output_dir = "./results"

[http]
verify_tls = true
max_redirects = 5
user_agent = "bounty-hunter-team/2.1"

[notify]
slack_enabled = true
email_enabled = false
on_finding = true
on_error = false
```

`configs/team-leads/notify.toml` (override for leads, not committed):
```toml
[notify]
on_finding = true
on_error = true
email_enabled = true
slack_channel = "#bounty-leads"
```

### Load Order with Team vs Personal Layer

```python
def get_config_layers(team_name: str, researcher: str) -> list[str]:
    return [
        "configs/shared/base.toml",
        f"configs/teams/{team_name}/overrides.toml",
        "configs/project/example-com.toml",
        f"configs/researchers/{researcher}.toml",   # personal overrides
    ]
```

---

## 7. Attribution Tracking

Every artifact in the shared workspace must carry author attribution for fairness and triage clarity.

### Finding Attribution Schema

```json
{
  "id": "F-2025-0042",
  "meta": {
    "discovered_by": "researcher-alice",
    "team": "redshift",
    "created_at": "2025-06-05T14:32:00Z",
    "updated_at": "2025-06-05T14:32:00Z",
    "last_modified_by": "researcher-alice",
    "git_commit": "abc1234def5678"
  },
  "status": "open",
  "target": "example.com",
  "type": "stored-xss",
  "severity": "medium",
  "title": "Stored XSS in /contact form title field",
  "url": "https://example.com/contact",
  "param": "subject",
  "proof": "screenshots/finding-0042/poc.png"
}
```

Attribution extractor:
```python
def blame_finding(finding_id: str) -> dict:
    """Find who originally discovered a finding via git log."""
    path = f"results/processed/open/{finding_id}.json"
    result = subprocess.run(
        ["git", "log", "--follow", "--format=%an|%ae|%ai|%H", "--", path],
        capture_output=True, text=True,
    )
    if not result.stdout:
        return {"discovered_by": "unknown", "created_at": "unknown"}
    first_commit = result.stdout.strip().split("\n")[-1]
    author, email, date, sha = first_commit.split("|")
    return {
        "discovered_by": author,
        "email": email,
        "created_at": date,
        "commit": sha,
    }
```

---

## 8. Team-Specific Tool Configs

Different teams may run different scan profiles per target tier.

`configs/teams/redshift/example-com.toml`:
```toml
[scan]
threads = 30
delay_seconds = 0.5

[tools.nuclei]
enabled = true
severity_filter = ["critical", "high", "medium"]
rate_limit = 150

[tools.httpx]
enabled = true
tech_detect = true
```

`configs/teams/cobalt/example-com.toml`:
```toml
[scan]
threads = 10               # cobalt is on a shared lab, fewer threads
delay_seconds = 2          # mandatory politeness for this target

[tools.nuclei]
enabled = true
severity_filter = ["critical", "high"]  # cobalt only cares about h1/critical
rate_limit = 50

[tools.nuclei.tags]
# Only run CVE-tagged templates for cobalt's scope
cve = true
lfi = true
rce = true
```

### Team Config Router

```python
def get_team_overrides(team_name: str) -> dict | None:
    path = Path(f"configs/teams/{team_name}.toml")
    if not path.exists():
        return None
    with open(path, "rb") as f:
        return tomllib.load(f)

def build_final_config(team: str, researcher: str, target_alias: str) -> dict:
    layers = [
        "configs/shared/base.toml",
        f"configs/teams/{team}/{target_alias}.toml",
        f"configs/researchers/{researcher}.toml",
    ]
    config = load_config([p for p in layers if Path(p).exists()])
    annotate_with_attribution(config, researcher)
    return config
```

---

## 9. Permission Boundaries

### S3 ACL / Bucket Policy Per Team

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TeamReadWriteOwnNamespace",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::123456789:role/team-redshift" },
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::bounty-workspace/teams/redshift/*"
    },
    {
      "Sid": "TeamReadAllOpenResults",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::123456789:role/team-redshift" },
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::bounty-workspace/results/processed/open/*"
    },
    {
      "Sid": "TeamSubmitOnlyOwnFindings",
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::123456789:role/team-redshift" },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::bounty-workspace/results/processed/submitted/F-2025-042*"
      ,
      "Condition": {
        "StringEquals": {
          "s3:x-amz-metadata-author": "researcher-alice"
        }
      }
    }
  ]
}
```

### Git Branch Protection

```bash
# Protect main from direct pushes
git branch --set-upstream-to=origin/main main
# Require PR reviews
gh repo edit YOUR_ORG/bounty-workspace \
  --enable-branch-protection \
  --required-approving-review-count=1 \
  --dismiss-stale-reviews \
  --require-code-owner-reviews
```

`.github/CODEOWNERS`:
```
# Team leads must approve findings before merge
configs/teams/*          @team-leads
results/processed/open/* @team-leads
configs/shared/*         @team-leads
```

---

## 10. Conflict-Free Workflow Example

### Researcher Onboarding Script

```bash
#!/usr/bin/env bash
# scripts/onboard_researcher.sh
set -euo pipefail
RESEARCHER=$1
TEAM=$2
TARGET=$3

# 1. Clone shared workspace
git clone git@github.com:your-org/bounty-workspace.git /opt/bounty/$RESEARCHER
cd /opt/bounty/$RESEARCHER
git config user.name "$RESEARCHER"
git config user.email "$RESEARCHER@your-org.internal"

# 2. Add S3 sync profile
mkdir -p ~/.config/rclone
cat > ~/.config/rclone/rclone.conf <<EOF
[bounty-workspace]
type = s3
provider = AWS
env_auth = true
region = us-east-1
EOF

# 3. Create per-researcher config
cat > configs/researchers/$RESEARCHER.toml <<EOF
[researcher]
name = "$RESEARCHER"
team = "$TEAM"
notify_slack = true
EOF

# 4. Install toolchain (uses shared versions.lock)
python scripts/install_tools.py versions.lock

echo "Researcher $RESEARCHER onboarded. Start hunting."
```

### Daily Sync Loop

```
08:00 — git pull --rebase origin main
08:05 — rclone sync s3:bounty-workspace/results/raw/ ./results/raw/
08:10 — python scripts/ingest_raw.py              # dedup against open findings
08:15 — python scripts/run_pipeline.py example-com
18:00 — python scripts/export_and_sync.py         # push results to S3
18:10 — git add -A && git commit -m "daily: example.com scan 2025-06-05"
18:15 — git push origin $(git branch --show-current)
```

---

## 11. Checklist

- [ ] Shared workspace uses S3 (large artifacts) + git (configs, findings, code)
- [ ] S3 bucket policy enforces per-team read/write boundaries
- [ ] All findings carry `discovered_by` and `git_commit` attribution fields
- [ ] Dedup check runs before any result is written to `processed/open/`
- [ ] Slack webhook fires on merge to `main` (not on every commit)
- [ ] Git submodules pinned to specific commits (not floating branches)
- [ ] `.gitattributes` defines merge driver for shared TOML files
- [ ] Per-researcher config layer exists at `configs/researchers/<name>.toml`
- [ ] Team-specific config overrides at `configs/teams/<team>/`
- [ ] `onboard_researcher.sh` automates new-team setup end-to-end
