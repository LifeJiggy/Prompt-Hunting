# Automation-Efficiency 6: Notification and Alerting Systems

## 1. Expert Role

You are a Senior DevOps Automation Engineer specializing in notification and alerting infrastructure for bug bounty and security research workflows. Your expertise covers multi-channel alert routing, event-driven notification pipelines, severity-based escalation, and quiet-hours management. You build systems that ensure the right team member gets the right alert at the right time — never missing a critical finding, never drowning in noise.

---

## 2. Core Concepts

### 2.1 Notification Architecture

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Event Source │───▶│  Alert Engine │───▶│ Notification  │
│  (scan tools)│    │  (rules/sev) │    │   Channels    │
└──────────────┘    └──────────────┘    └──────────────┘
                           │
                    ┌──────┴──────┐
                    │  Dedup &    │
                    │  Aggregation│
                    └─────────────┘
```

**Key Components:**
- **Event Source**: Python scripts, scan tools (nuclei, httpx, subfinder), cron jobs, webhooks
- **Alert Engine**: Rule evaluation, severity mapping, deduplication, throttling
- **Notification Channels**: Slack, Discord, Email, Telegram, SMS, Webhooks, PagerDuty
- **Routing Layer**: Channel selection based on severity, time-of-day, team assignment

### 2.2 Severity Classification

| Level | Label | Response Time | Channels | Example |
|-------|-------|---------------|----------|---------|
| P0 | Critical | Immediate | All + SMS | Active exploit, data leak |
| P1 | High | < 1 hour | Slack + Email | RCE, SQLi, Auth Bypass |
| P2 | Medium | < 4 hours | Slack | XSS, CSRF, IDOR |
| P3 | Low | < 24 hours | Slack digest | Info disclosure, minor config |
| P4 | Info | Weekly | Email digest | Recon results, new subdomains |

### 2.3 Alert Lifecycle

```
Generated → Deduplicated → Enriched → Routed → Delivered → Acknowledged → Resolved
```

### 2.4 Deduplication Strategy

- **Exact match**: Same alert key (hash of target + vuln type + endpoint)
- **Fuzzy match**: Same target + same vuln class within time window
- **Incremental**: Count-based alerts (e.g., "5 new subdomains found")

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
pip install requests python-dotenv schedule aiohttp jinja2 pyyaml
```

### 3.2 Required API Tokens

Store in `.env` file:

```env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T.../B.../xxx
SLACK_BOT_TOKEN=xoxb-...
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
TELEGRAM_CHAT_ID=-100123456789
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=alerts@company.com
SMTP_PASS=app-password-here
PAGERDUTY_ROUTING_KEY=abc123...
```

### 3.3 Directory Structure

```
alerting/
├── .env
├── config.yaml
├── alert_engine.py
├── channels/
│   ├── slack_channel.py
│   ├── discord_channel.py
│   ├── email_channel.py
│   ├── telegram_channel.py
│   └── webhook_channel.py
├── rules/
│   └── severity_rules.yaml
├── templates/
│   ├── slack_message.json
│   ├── email_template.html
│   └── discord_embed.json
└── logs/
    └── alert_history.json
```

---

## 4. Methodology

### Step 1: Define Alert Rules

Create `config.yaml`:

```yaml
alerting:
  default_channel: slack
  severity_routes:
    critical:
      channels: [slack, email, telegram]
      quiet_hours: false
      repeat_interval_min: 15
      max_repeats: 5
    high:
      channels: [slack, email]
      quiet_hours: false
      repeat_interval_min: 60
      max_repeats: 3
    medium:
      channels: [slack]
      quiet_hours: true
      repeat_interval_min: 240
      max_repeats: 1
    low:
      channels: [slack]
      quiet_hours: true
      repeat_interval_min: 1440
      max_repeats: 0
    info:
      channels: [email]
      quiet_hours: true
      repeat_interval_min: 10080
      max_repeats: 0

  dedup_window_min: 60
  quiet_hours_start: "23:00"
  quiet_hours_end: "07:00"
  timezone: "Asia/Jakarta"

  aggregation:
    enabled: true
    window_min: 30
    min_events: 5
```

### Step 2: Build the Alert Engine

```python
# alert_engine.py
import hashlib
import json
import os
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

import yaml


class AlertEngine:
    """Core alerting engine with deduplication, routing, and throttling."""

    def __init__(self, config_path: str = "config.yaml"):
        with open(config_path) as f:
            self.config = yaml.safe_load(f)["alerting"]
        self.history_path = Path("logs/alert_history.json")
        self.history = self._load_history()

    def _load_history(self) -> dict:
        if self.history_path.exists():
            with open(self.history_path) as f:
                return json.load(f)
        return {"alerts": [], "last_cleanup": time.time()}

    def _save_history(self):
        self.history_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.history_path, "w") as f:
            json.dump(self.history, f, indent=2)

    def _generate_alert_key(self, alert: dict) -> str:
        raw = f"{alert.get('target', '')}:{alert.get('vuln_type', '')}:{alert.get('endpoint', '')}"
        return hashlib.sha256(raw.encode()).hexdigest()[:16]

    def _is_duplicate(self, alert_key: str) -> bool:
        window = self.config["dedup_window_min"] * 60
        now = time.time()
        for past in self.history.get("alerts", []):
            if past["key"] == alert_key and (now - past["timestamp"]) < window:
                return True
        return False

    def _is_quiet_hours(self) -> bool:
        if not self.config.get("quiet_hours_start"):
            return False
        tz_name = self.config.get("timezone", "UTC")
        now = datetime.now()
        start = datetime.strptime(self.config["quiet_hours_start"], "%H:%M").time()
        end = datetime.strptime(self.config["quiet_hours_end"], "%H:%M").time()
        current = now.time()
        if start > end:
            return current >= start or current <= end
        return start <= current <= end

    def _get_repeat_info(self, alert_key: str, severity: str) -> tuple:
        routes = self.config["severity_routes"].get(severity, {})
        interval = routes.get("repeat_interval_min", 60) * 60
        max_repeats = routes.get("max_repeats", 0)
        count = sum(
            1 for a in self.history["alerts"]
            if a["key"] == alert_key
        )
        return count < max_repeats, interval

    def process_alert(self, alert: dict) -> dict:
        alert_key = self._generate_alert_key(alert)
        severity = alert.get("severity", "info").lower()

        if self._is_duplicate(alert_key):
            can_repeat, _ = self._get_repeat_info(alert_key, severity)
            if not can_repeat:
                return {"status": "suppressed", "reason": "duplicate"}
            alert["repeat"] = True

        route = self.config["severity_routes"].get(severity, {})
        channels = route.get("channels", ["slack"])

        if self._is_quiet_hours() and route.get("quiet_hours", True):
            if severity not in ("critical", "high"):
                return {"status": "queued", "reason": "quiet_hours"}

        self.history["alerts"].append({
            "key": alert_key,
            "timestamp": time.time(),
            "severity": severity,
            "target": alert.get("target", ""),
        })
        self._save_history()

        return {
            "status": "routed",
            "key": alert_key,
            "channels": channels,
            "severity": severity,
        }

    def cleanup_old_alerts(self, max_age_days: int = 30):
        cutoff = time.time() - (max_age_days * 86400)
        self.history["alerts"] = [
            a for a in self.history["alerts"] if a["timestamp"] > cutoff
        ]
        self._save_history()
```

### Step 3: Build Channel Implementations

```python
# channels/slack_channel.py
import json
import os

import requests


class SlackNotifier:
    def __init__(self):
        self.webhook_url = os.getenv("SLACK_WEBHOOK_URL")

    def send(self, alert: dict, severity: str) -> bool:
        colors = {
            "critical": "#FF0000",
            "high": "#FF6600",
            "medium": "#FFCC00",
            "low": "#36a64f",
            "info": "#439FE0",
        }
        emoji = {
            "critical": "🚨",
            "high": "🔴",
            "medium": "🟡",
            "low": "🟢",
            "info": "ℹ️",
        }
        payload = {
            "attachments": [{
                "color": colors.get(severity, "#999"),
                "blocks": [
                    {
                        "type": "header",
                        "text": {
                            "type": "plain_text",
                            "text": f"{emoji.get(severity, '📢')} [{severity.upper()}] Security Alert"
                        }
                    },
                    {
                        "type": "section",
                        "fields": [
                            {"type": "mrkdwn", "text": f"*Target:*\n{alert.get('target', 'N/A')}"},
                            {"type": "mrkdwn", "text": f"*Type:*\n{alert.get('vuln_type', 'N/A')}"},
                            {"type": "mrkdwn", "text": f"*Endpoint:*\n{alert.get('endpoint', 'N/A')}"},
                            {"type": "mrkdwn", "text": f"*CVSS:*\n{alert.get('cvss', 'N/A')}"},
                        ]
                    },
                    {
                        "type": "section",
                        "text": {
                            "type": "mrkdwn",
                            "text": f"*Description:*\n{alert.get('description', 'No description provided.')}"
                        }
                    },
                    {
                        "type": "context",
                        "elements": [{
                            "type": "mrkdwn",
                            "text": f"Alert Key: `{alert.get('key', 'N/A')}` | {alert.get('timestamp', '')}"
                        }]
                    }
                ]
            }]
        }
        resp = requests.post(self.webhook_url, json=payload, timeout=10)
        return resp.status_code == 200


# channels/telegram_channel.py
import os

import requests


class TelegramNotifier:
    def __init__(self):
        self.bot_token = os.getenv("TELEGRAM_BOT_TOKEN")
        self.chat_id = os.getenv("TELEGRAM_CHAT_ID")

    def send(self, alert: dict, severity: str) -> bool:
        emoji = {
            "critical": "🚨", "high": "🔴",
            "medium": "🟡", "low": "🟢", "info": "ℹ️"
        }
        text = (
            f"{emoji.get(severity, '📢')} *[{severity.upper()}] Security Alert*\n\n"
            f"*Target:* {alert.get('target', 'N/A')}\n"
            f"*Type:* {alert.get('vuln_type', 'N/A')}\n"
            f"*Endpoint:* `{alert.get('endpoint', 'N/A')}`\n"
            f"*CVSS:* {alert.get('cvss', 'N/A')}\n\n"
            f"{alert.get('description', '')}"
        )
        url = f"https://api.telegram.org/bot{self.bot_token}/sendMessage"
        resp = requests.post(url, json={
            "chat_id": self.chat_id,
            "text": text,
            "parse_mode": "Markdown",
        }, timeout=10)
        return resp.status_code == 200


# channels/email_channel.py
import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


class EmailNotifier:
    def __init__(self):
        self.host = os.getenv("SMTP_HOST")
        self.port = int(os.getenv("SMTP_PORT", "587"))
        self.user = os.getenv("SMTP_USER")
        self.password = os.getenv("SMTP_PASS")

    def send(self, alert: dict, severity: str) -> bool:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = f"[{severity.upper()}] Security Alert: {alert.get('vuln_type', 'Unknown')}"
        msg["From"] = self.user
        msg["To"] = alert.get("recipient", self.user)

        html = f"""
        <html>
        <body style="font-family: Arial; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #f44336; color: white; padding: 15px;
                    text-align: center; font-size: 18px;">
            [{severity.upper()}] Security Alert
        </div>
        <div style="padding: 20px; border: 1px solid #ddd;">
            <table style="width: 100%; border-collapse: collapse;">
                <tr><td style="padding: 8px; font-weight: bold;">Target</td>
                    <td style="padding: 8px;">{alert.get('target', 'N/A')}</td></tr>
                <tr><td style="padding: 8px; font-weight: bold;">Type</td>
                    <td style="padding: 8px;">{alert.get('vuln_type', 'N/A')}</td></tr>
                <tr><td style="padding: 8px; font-weight: bold;">Endpoint</td>
                    <td style="padding: 8px;"><code>{alert.get('endpoint', 'N/A')}</code></td></tr>
                <tr><td style="padding: 8px; font-weight: bold;">CVSS</td>
                    <td style="padding: 8px;">{alert.get('cvss', 'N/A')}</td></tr>
            </table>
            <h3>Description</h3>
            <p>{alert.get('description', 'No description provided.')}</p>
        </div>
        </body>
        </html>
        """
        msg.attach(MIMEText(html, "html"))

        try:
            with smtplib.SMTP(self.host, self.port) as server:
                server.starttls()
                server.login(self.user, self.password)
                server.send_message(msg)
            return True
        except Exception as e:
            print(f"Email send failed: {e}")
            return False


# channels/discord_channel.py
import os
import requests


class DiscordNotifier:
    def __init__(self):
        self.webhook_url = os.getenv("DISCORD_WEBHOOK_URL")

    def send(self, alert: dict, severity: str) -> bool:
        colors = {
            "critical": 0xFF0000, "high": 0xFF6600,
            "medium": 0xFFCC00, "low": 0x36a64f, "info": 0x439FE0,
        }
        payload = {
            "embeds": [{
                "title": f"[{severity.upper()}] Security Alert",
                "color": colors.get(severity, 0x999999),
                "fields": [
                    {"name": "Target", "value": alert.get("target", "N/A"), "inline": True},
                    {"name": "Type", "value": alert.get("vuln_type", "N/A"), "inline": True},
                    {"name": "CVSS", "value": str(alert.get("cvss", "N/A")), "inline": True},
                    {"name": "Endpoint", "value": f"`{alert.get('endpoint', 'N/A')}`", "inline": False},
                    {"name": "Description", "value": alert.get("description", "N/A"), "inline": False},
                ],
                "footer": {"text": f"Alert Key: {alert.get('key', 'N/A')}"}
            }]
        }
        resp = requests.post(self.webhook_url, json=payload, timeout=10)
        return resp.status_code in (200, 204)
```

### Step 4: Build the Dispatcher

```python
# dispatcher.py
import json
import logging
from datetime import datetime
from typing import Optional

from alert_engine import AlertEngine
from channels.slack_channel import SlackNotifier
from channels.telegram_channel import TelegramNotifier
from channels.email_channel import EmailNotifier
from channels.discord_channel import DiscordNotifier

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


class AlertDispatcher:
    def __init__(self):
        self.engine = AlertEngine()
        self.notifiers = {
            "slack": SlackNotifier(),
            "telegram": TelegramNotifier(),
            "email": EmailNotifier(),
            "discord": DiscordNotifier(),
        }

    def dispatch(self, alert: dict) -> dict:
        result = self.engine.process_alert(alert)
        logger.info(f"Alert processed: {result}")

        if result["status"] in ("suppressed", "queued"):
            return result

        timestamp = datetime.now().isoformat()
        alert["timestamp"] = timestamp
        alert["key"] = result.get("key", "unknown")

        delivered = []
        failed = []

        for channel_name in result["channels"]:
            notifier = self.notifiers.get(channel_name)
            if not notifier:
                logger.warning(f"No notifier for channel: {channel_name}")
                failed.append(channel_name)
                continue
            try:
                success = notifier.send(alert, result["severity"])
                if success:
                    delivered.append(channel_name)
                    logger.info(f"Delivered to {channel_name}")
                else:
                    failed.append(channel_name)
                    logger.warning(f"Failed to deliver to {channel_name}")
            except Exception as e:
                failed.append(channel_name)
                logger.error(f"Error delivering to {channel_name}: {e}")

        return {
            "status": "delivered",
            "delivered": delivered,
            "failed": failed,
            "severity": result["severity"],
        }


if __name__ == "__main__":
    dispatcher = AlertDispatcher()

    test_alert = {
        "target": "test-target.example.com",
        "vuln_type": "SQL Injection",
        "endpoint": "/api/users?id=1",
        "cvss": "9.8",
        "description": "Blind SQL injection found in user parameter. Database type: PostgreSQL.",
        "severity": "critical",
    }

    result = dispatcher.dispatch(test_alert)
    print(json.dumps(result, indent=2))
```

---

## 5. Tool Arsenal with Commands

### 5.1 Quick Slack Test

```python
import requests
import os
from dotenv import load_dotenv

load_dotenv()
url = os.getenv("SLACK_WEBHOOK_URL")
requests.post(url, json={"text": "Test alert from bug bounty automation"})
```

### 5.2 Quick Telegram Test

```python
import requests
import os
from dotenv import load_dotenv

load_dotenv()
token = os.getenv("TELEGRAM_BOT_TOKEN")
chat_id = os.getenv("TELEGRAM_CHAT_ID")
requests.post(
    f"https://api.telegram.org/bot{token}/sendMessage",
    json={"chat_id": chat_id, "text": "Test alert from bug bounty automation"}
)
```

### 5.3 Alert Rate Limiter

```python
import time
from collections import defaultdict


class RateLimiter:
    def __init__(self, max_per_hour: int = 30):
        self.max_per_hour = max_per_hour
        self.timestamps = defaultdict(list)

    def allow(self, channel: str) -> bool:
        now = time.time()
        self.timestamps[channel] = [
            t for t in self.timestamps[channel] if now - t < 3600
        ]
        if len(self.timestamps[channel]) < self.max_per_hour:
            self.timestamps[channel].append(now)
            return True
        return False
```

### 5.4 Batch Alert Sender

```python
import json
from pathlib import Path


def send_batch_alerts(scan_results_path: str):
    with open(scan_results_path) as f:
        results = json.load(f)

    dispatcher = AlertDispatcher()
    summary = {"delivered": 0, "failed": 0, "suppressed": 0}

    for finding in results.get("findings", []):
        alert = {
            "target": finding["target"],
            "vuln_type": finding["type"],
            "endpoint": finding.get("url", "N/A"),
            "cvss": finding.get("cvss", "N/A"),
            "description": finding.get("description", ""),
            "severity": finding.get("severity", "info"),
        }
        result = dispatcher.dispatch(alert)
        status = result.get("status", "unknown")
        if status in summary:
            summary[status] += 1

    print(f"Batch complete: {json.dumps(summary, indent=2)}")
    return summary
```

### 5.5 Webhook Listener for Inbound Alerts

```python
from http.server import HTTPServer, BaseHTTPRequestHandler
import json


class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length)) if length else {}

        print(f"Inbound webhook: {json.dumps(body, indent=2)}")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "received"}).encode())

    def log_message(self, format, *args):
        print(f"[Webhook] {args[0]}")


def run_webhook_server(port: int = 9000):
    server = HTTPServer(("0.0.0.0", port), WebhookHandler)
    print(f"Webhook listener running on port {port}")
    server.serve_forever()
```

---

## 6. Real-World Examples

### Example 1: Nuclei Scan with Live Alerts

```python
import subprocess
import json
from dispatcher import AlertDispatcher


def run_nuclei_with_alerts(target: str, templates: str):
    dispatcher = AlertDispatcher()

    cmd = [
        "nuclei", "-target", target,
        "-t", templates,
        "-json",
        "-severity", "critical,high,medium",
        "-silent",
    ]

    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True)

    for line in process.stdout:
        line = line.strip()
        if not line:
            continue
        try:
            finding = json.loads(line)
            alert = {
                "target": finding.get("host", target),
                "vuln_type": finding.get("info", {}).get("name", "Unknown"),
                "endpoint": finding.get("matched-at", "N/A"),
                "cvss": finding.get("info", {}).get("classification", {}).get("cvss-score", "N/A"),
                "description": finding.get("info", {}).get("description", ""),
                "severity": finding.get("info", {}).get("severity", "info"),
            }
            result = dispatcher.dispatch(alert)
            print(f"[{result['severity']}] {alert['vuln_type']} -> {result.get('status')}")
        except json.JSONDecodeError:
            continue

    process.wait()
```

### Example 2: Webhook-to-Slack Bridge

```python
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import requests


class SlackBridge(BaseHTTPRequestHandler):
    SLACK_WEBHOOK = os.getenv("SLACK_WEBHOOK_URL")

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length)) if length else {}

        slack_payload = {
            "text": f"Webhook received from {self.client_address[0]}",
            "attachments": [{
                "color": "#36a64f",
                "text": json.dumps(body, indent=2)[:2000],
            }]
        }
        requests.post(self.SLACK_WEBHOOK, json=slack_payload, timeout=10)

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"forwarded"}')

    def log_message(self, format, *args):
        pass
```

### Example 3: Scheduled Digest Report

```python
import schedule
import time
import json
from datetime import datetime
from pathlib import Path


def send_daily_digest():
    history_path = Path("logs/alert_history.json")
    if not history_path.exists():
        return

    with open(history_path) as f:
        history = json.load(f)

    now = time.time()
    last_24h = [
        a for a in history["alerts"]
        if now - a["timestamp"] < 86400
    ]

    severity_counts = {}
    for a in last_24h:
        s = a.get("severity", "unknown")
        severity_counts[s] = severity_counts.get(s, 0) + 1

    digest_text = (
        f"*Daily Security Alert Digest*\n"
        f"Date: {datetime.now().strftime('%Y-%m-%d')}\n\n"
        f"Total alerts: {len(last_24h)}\n"
    )
    for sev, count in sorted(severity_counts.items()):
        digest_text += f"  - {sev}: {count}\n"

    print(digest_text)


schedule.every().day.at("08:00").do(send_daily_digest)

while True:
    schedule.run_pending()
    time.sleep(60)
```

---

## 7. Common Pitfalls

### Pitfall 1: Alert Fatigue

**Problem**: Too many low-severity alerts cause team to ignore all notifications.

**Solution**: Aggregate and deduplicate aggressively. Use digest mode for P3/P4.

```python
# Instead of alerting per finding, aggregate by target
def aggregate_findings(findings: list) -> dict:
    by_target = {}
    for f in findings:
        target = f.get("target", "unknown")
        if target not in by_target:
            by_target[target] = []
        by_target[target].append(f)
    return by_target
```

### Pitfall 2: Missing Critical Alerts During Quiet Hours

**Problem**: Critical alerts filtered by quiet hours.

**Solution**: Always bypass quiet hours for P0/P1.

```python
if severity in ("critical", "high") or not self._is_quiet_hours():
    # Send immediately
```

### Pitfall 3: No Alert Acknowledgment

**Problem**: Alerts sent but nobody knows if they were seen.

**Solution**: Add acknowledgment tracking with Slack reactions or Telegram callbacks.

```python
# After sending, add tracking
def track_ack(alert_key: str, channel: str, ack_timeout_min: int = 30):
    """If no ack within timeout, escalate."""
    # Implementation depends on channel API
```

### Pitfall 4: Webhook URL Exposure

**Problem**: `.env` committed to git, webhook URLs leaked.

**Solution**: Use `.gitignore`, rotate keys, validate inbound webhooks.

```python
# Validate inbound webhook signatures
import hmac
import hashlib

def verify_webhook_signature(payload: bytes, signature: str, secret: str) -> bool:
    expected = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
    return hmac.compare_digest(f"sha256={expected}", signature)
```

### Pitfall 5: Single Point of Failure

**Problem**: If Slack is down, no alerts delivered.

**Solution**: Fallback chain — if primary fails, try secondary.

```python
def dispatch_with_fallback(alert: dict, channels: list) -> str:
    for channel in channels:
        try:
            success = notifiers[channel].send(alert, alert["severity"])
            if success:
                return channel
        except Exception:
            continue
    return "none_failed"
```

---

## 8. Advanced Techniques

### 8.1 Intelligent Alert Routing Based on On-Call

```python
ON_CALL_SCHEDULE = {
    "monday": "alice@company.com",
    "tuesday": "bob@company.com",
    "wednesday": "alice@company.com",
    "thursday": "bob@company.com",
    "friday": "alice@company.com",
    "saturday": "team-shared",
    "sunday": "team-shared",
}

def get_oncall_recipient(severity: str) -> str:
    day = datetime.now().strftime("%A").lower()
    return ON_CALL_SCHEDULE.get(day, "team-shared")
```

### 8.2 Alert Enrichment with Context

```python
def enrich_alert(alert: dict) -> dict:
    """Add context from previous scan results."""
    target = alert.get("target", "")

    # Check if target was previously scanned
    history = load_scan_history()
    if target in history:
        alert["previous_findings"] = history[target].get("finding_count", 0)
        alert["first_seen"] = history[target].get("first_seen", "unknown")
        alert["change_since_last"] = (
            alert["previous_findings"] > 0 and
            alert.get("severity") in ("critical", "high")
        )

    # Add CVSS color coding
    cvss = float(alert.get("cvss", 0))
    if cvss >= 9.0:
        alert["cvss_color"] = "red"
    elif cvss >= 7.0:
        alert["cvss_color"] = "orange"
    elif cvss >= 4.0:
        alert["cvss_color"] = "yellow"
    else:
        alert["cvss_color"] = "green"

    return alert
```

### 8.3 Multi-Tenant Alert Routing

```python
TENANT_CHANNELS = {
    "team_alpha": {
        "slack_channel": "#alpha-alerts",
        "email": "alpha-lead@company.com",
    },
    "team_beta": {
        "slack_channel": "#beta-alerts",
        "email": "beta-lead@company.com",
    },
}

def route_by_tenant(alert: dict) -> list:
    tenant = alert.get("tenant", "default")
    config = TENANT_CHANNELS.get(tenant, {})
    channels = []
    if config.get("slack_channel"):
        channels.append("slack")
    if config.get("email"):
        channels.append("email")
    return channels or ["slack"]
```

### 8.4 Alert Correlation Engine

```python
from collections import defaultdict
from datetime import datetime, timedelta


class AlertCorrelator:
    """Correlate related alerts into incidents."""

    def __init__(self, window_minutes: int = 30):
        self.window = timedelta(minutes=window_minutes)
        self.pending = defaultdict(list)

    def add_alert(self, alert: dict) -> dict:
        target = alert.get("target", "")
        now = datetime.now()
        self.pending[target].append({"alert": alert, "time": now})

        # Clean old alerts
        self.pending[target] = [
            a for a in self.pending[target]
            if now - a["time"] < self.window
        ]

        # If multiple alerts for same target within window, create incident
        if len(self.pending[target]) >= 3:
            incident = {
                "type": "incident",
                "target": target,
                "alerts": [a["alert"] for a in self.pending[target]],
                "count": len(self.pending[target"]),
                "created": now.isoformat(),
            }
            self.pending[target] = []
            return incident

        return {"type": "single_alert", "alert": alert}
```

---

## 9. Reporting Template

### Weekly Alert Summary Report

```markdown
# Weekly Security Alert Report
**Period**: {start_date} to {end_date}
**Generated**: {timestamp}

## Summary
| Metric | Value |
|--------|-------|
| Total Alerts | {total} |
| Critical | {critical_count} |
| High | {high_count} |
| Medium | {medium_count} |
| Low | {low_count} |
| Info | {info_count} |
| Avg Response Time | {avg_response} |
| False Positive Rate | {fp_rate}% |

## Top Targets
| Target | Alert Count | Highest Severity |
|--------|-------------|------------------|
| {target_1} | {count_1} | {sev_1} |
| {target_2} | {count_2} | {sev_2} |

## Alert Trend (7-day)
{sparkline_chart}

## Escalation Summary
- Escalated: {escalated_count}
- Acknowledged: {ack_count}
- Average time to ack: {avg_ack_time}

## Recommendations
1. {recommendation_1}
2. {recommendation_2}
3. {recommendation_3}
```

### Python Report Generator

```python
from datetime import datetime, timedelta
from pathlib import Path
import json


def generate_weekly_report(history_path: str = "logs/alert_history.json") -> str:
    with open(history_path) as f:
        history = json.load(f)

    now = datetime.now()
    week_start = now - timedelta(days=7)
    cutoff = week_start.timestamp()

    week_alerts = [a for a in history["alerts"] if a["timestamp"] > cutoff]

    severity_counts = {}
    for a in week_alerts:
        s = a.get("severity", "unknown")
        severity_counts[s] = severity_counts.get(s, 0) + 1

    report = f"""# Weekly Security Alert Report
**Period**: {week_start.strftime('%Y-%m-%d')} to {now.strftime('%Y-%m-%d')}
**Generated**: {now.strftime('%Y-%m-%d %H:%M:%S')}

## Summary
| Metric | Value |
|--------|-------|
| Total Alerts | {len(week_alerts)} |
| Critical | {severity_counts.get('critical', 0)} |
| High | {severity_counts.get('high', 0)} |
| Medium | {severity_counts.get('medium', 0)} |
| Low | {severity_counts.get('low', 0)} |
| Info | {severity_counts.get('info', 0)} |

## Targets Hit
"""
    target_counts = {}
    for a in week_alerts:
        t = a.get("target", "unknown")
        target_counts[t] = target_counts.get(t, 0) + 1

    for target, count in sorted(target_counts.items(), key=lambda x: -x[1])[:10]:
        report += f"- `{target}`: {count} alerts\n"

    output_path = Path("reports") / f"weekly_{now.strftime('%Y%m%d')}.md"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        f.write(report)

    return str(output_path)
```

---

## 10. Quick Reference

### Alert Severity Matrix

```
P0 Critical  → Slack + Email + Telegram + SMS  → No quiet hours
P1 High      → Slack + Email                   → No quiet hours
P2 Medium    → Slack                           → Respects quiet hours
P3 Low       → Slack                           → Digest mode only
P4 Info      → Email                           → Weekly digest
```

### Environment Variables Checklist

```
SLACK_WEBHOOK_URL          ✓
SLACK_BOT_TOKEN            ✓ (for interactive messages)
DISCORD_WEBHOOK_URL        ✓
TELEGRAM_BOT_TOKEN         ✓
TELEGRAM_CHAT_ID           ✓
SMTP_HOST                  ✓
SMTP_PORT                  ✓
SMTP_USER                  ✓
SMTP_PASS                  ✓
PAGERDUTY_ROUTING_KEY      ✓ (optional)
```

### Python Package Quick Install

```bash
pip install requests python-dotenv schedule aiohttp jinja2 pyyaml
```

### Test Commands

```bash
# Test all channels
python -c "from dispatcher import AlertDispatcher; d=AlertDispatcher(); print(d.dispatch({'target':'test.example.com','vuln_type':'Test','severity':'info','description':'Test alert','endpoint':'/test','cvss':'0.0'}))"

# Test Slack only
python -c "from channels.slack_channel import SlackNotifier; s=SlackNotifier(); print(s.send({'target':'test','vuln_type':'Test','endpoint':'/','cvss':'5.0','description':'Test','key':'abc123'},'medium'))"

# Run webhook listener
python -c "from dispatcher import run_webhook_server; run_webhook_server(9000)"
```

### File Structure Summary

```
alerting/
├── .env                  # API tokens (gitignored)
├── config.yaml           # Alert rules and routing
├── alert_engine.py       # Core dedup + routing
├── dispatcher.py         # Multi-channel dispatch
├── channels/
│   ├── __init__.py
│   ├── slack_channel.py
│   ├── discord_channel.py
│   ├── email_channel.py
│   └── telegram_channel.py
├── logs/
│   └── alert_history.json
└── reports/
    └── weekly_YYYYMMDD.md
```

### Key Design Principles

1. **Never miss critical**: P0/P1 bypass all filters
2. **Reduce noise**: Deduplicate, aggregate, digest
3. **Fallback always**: If primary channel fails, try secondary
4. **Track everything**: Log all alerts with timestamps
5. **Quiet hours matter**: Respect team sleep schedules
6. **Escalation path**: Unacknowledged P1 escalates after 30 min
7. **Test regularly**: Send test alerts weekly to verify channels work
