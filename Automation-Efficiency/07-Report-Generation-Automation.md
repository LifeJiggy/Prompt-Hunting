# Automation-Efficiency 7: Report Generation Automation

## 1. Expert Role

You are a Security Report Automation Specialist who builds automated pipelines that transform raw vulnerability scan data into polished, professional reports. Your expertise covers PDF generation, HTML dashboards, Markdown exports, templating engines, scheduled report delivery, and multi-format output. You eliminate the manual effort of writing reports so security researchers can focus on finding bugs.

---

## 2. Core Concepts

### 2.1 Report Pipeline Architecture

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Raw Data    │───▶│  Aggregation  │───▶│  Templating   │───▶│   Output     │
│  (JSON/CSV)  │    │  & Filtering  │    │  Engine       │    │  (PDF/HTML)  │
└─────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
       │                  │                   │                    │
  Scan results      Dedup, sort        Jinja2/Mako          PDF, HTML,
  API responses     Severity filter    CSS styling           Markdown
  Manual findings   Group by target    Logo/branding         Email attach
```

### 2.2 Report Types

| Type | Use Case | Format | Frequency |
|------|----------|--------|-----------|
| Scan Summary | After each scan run | Markdown/JSON | Per-run |
| Vulnerability Detail | Per-finding deep-dive | HTML/PDF | On-demand |
| Executive Summary | Non-technical stakeholders | PDF | Weekly/Monthly |
| Compliance Report | Audit requirements | PDF + CSV | Quarterly |
| Trend Report | Progress over time | HTML dashboard | Monthly |
| Client Delivery | Bug bounty submission | Markdown | Per-finding |

### 2.3 Data Flow

```
Scan Output (JSON) → Parser → Enricher → Template Renderer → Formatter → Delivery
```

### 2.4 Report Sections

1. **Header**: Title, date, scope, author
2. **Executive Summary**: Total findings, severity breakdown, risk score
3. **Methodology**: Tools used, scan coverage, testing approach
4. **Findings**: Detailed per-vulnerability sections
5. **Recommendations**: Remediation guidance
6. **Appendix**: Raw data, tool output, additional references

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
pip install jinja2 weasyprint markdown pdfkit jsonschema pyyaml
pip install xlsxwriter openpyxl matplotlib tabulate
```

### 3.2 System Dependencies

```bash
# For PDF generation via weasyprint (Linux/WSL)
sudo apt-get install libpango-1.0-0 libpangocairo-1.0-0

# For pdfkit (requires wkhtmltopdf)
# Download from https://wkhtmltopdf.org/downloads.html
```

### 3.3 Directory Structure

```
reporting/
├── config.yaml
├── generate_report.py
├── parsers/
│   ├── json_parser.py
│   ├── csv_parser.py
│   └── nuclei_parser.py
├── templates/
│   ├── scan_summary.md
│   ├── vulnerability_detail.html
│   ├── executive_summary.html
│   ├── compliance_report.html
│   └── email_body.html
├── static/
│   ├── logo.png
│   └── styles.css
├── output/
│   ├── pdf/
│   ├── html/
│   └── markdown/
└── deliver/
    └── email_sender.py
```

---

## 4. Methodology

### Step 1: Define Report Configuration

```yaml
# config.yaml
report:
  company_name: "Security Research Lab"
  logo_path: "static/logo.png"
  author: "Bug Bounty Team"

  output_dir: "output"
  formats: [markdown, html, pdf]

  severity_colors:
    critical: "#FF0000"
    high: "#FF6600"
    medium: "#FFCC00"
    low: "#36a64f"
    info: "#439FE0"

  sections:
    executive_summary: true
    methodology: true
    detailed_findings: true
    recommendations: true
    appendix: false

  delivery:
    email:
      enabled: true
      recipients: ["team@company.com"]
      subject_prefix: "[Security Report]"
    slack:
      enabled: true
      webhook_url_env: "SLACK_WEBHOOK_URL"
```

### Step 2: Build the Data Parser

```python
# parsers/json_parser.py
import json
from typing import List, Dict, Any
from datetime import datetime


class ScanResultParser:
    """Parse and normalize scan results from various tools."""

    SEVERITY_MAP = {
        "critical": 4,
        "high": 3,
        "medium": 2,
        "low": 1,
        "info": 0,
    }

    def parse_json(self, filepath: str) -> List[Dict[str, Any]]:
        with open(filepath) as f:
            data = json.load(f)

        if isinstance(data, list):
            return [self._normalize(item) for item in data]
        elif isinstance(data, dict):
            return [self._normalize(data)]
        return []

    def parse_nuclei_jsonl(self, filepath: str) -> List[Dict[str, Any]]:
        findings = []
        with open(filepath) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    item = json.loads(line)
                    findings.append(self._normalize_nuclei(item))
                except json.JSONDecodeError:
                    continue
        return findings

    def parse_csv(self, filepath: str) -> List[Dict[str, Any]]:
        import csv
        findings = []
        with open(filepath) as f:
            reader = csv.DictReader(f)
            for row in reader:
                findings.append(self._normalize(row))
        return findings

    def _normalize(self, item: dict) -> dict:
        return {
            "id": item.get("id", item.get("finding_id", "")),
            "title": item.get("title", item.get("name", "Unknown")),
            "severity": item.get("severity", "info").lower(),
            "severity_score": self.SEVERITY_MAP.get(
                item.get("severity", "info").lower(), 0
            ),
            "cvss": item.get("cvss", item.get("cvss_score", "N/A")),
            "target": item.get("target", item.get("host", "")),
            "endpoint": item.get("endpoint", item.get("url", item.get("matched-at", ""))),
            "description": item.get("description", ""),
            "evidence": item.get("evidence", item.get("evidence", "")),
            "remediation": item.get("remediation", ""),
            "references": item.get("references", []),
            "tags": item.get("tags", []),
            "tool": item.get("tool", "unknown"),
            "timestamp": item.get("timestamp", datetime.now().isoformat()),
            "raw": item,
        }

    def _normalize_nuclei(self, item: dict) -> dict:
        info = item.get("info", {})
        return {
            "id": item.get("template-id", ""),
            "title": info.get("name", "Unknown"),
            "severity": info.get("severity", "info").lower(),
            "severity_score": self.SEVERITY_MAP.get(
                info.get("severity", "info").lower(), 0
            ),
            "cvss": info.get("classification", {}).get("cvss-score", "N/A"),
            "target": item.get("host", ""),
            "endpoint": item.get("matched-at", ""),
            "description": info.get("description", ""),
            "evidence": item.get("matcher-name", ""),
            "remediation": info.get("remediation", ""),
            "references": info.get("reference", []),
            "tags": info.get("tags", []) if isinstance(info.get("tags"), list) else
                    info.get("tags", "").split(","),
            "tool": "nuclei",
            "timestamp": item.get("timestamp", datetime.now().isoformat()),
            "raw": item,
        }


    def aggregate_by_severity(self, findings: List[dict]) -> dict:
        result = {"critical": [], "high": [], "medium": [], "low": [], "info": []}
        for f in findings:
            sev = f.get("severity", "info")
            if sev in result:
                result[sev].append(f)
        return result

    def aggregate_by_target(self, findings: List[dict]) -> dict:
        result = {}
        for f in findings:
            target = f.get("target", "unknown")
            if target not in result:
                result[target] = []
            result[target].append(f)
        return result

    def get_summary_stats(self, findings: List[dict]) -> dict:
        by_sev = self.aggregate_by_severity(findings)
        return {
            "total": len(findings),
            "by_severity": {k: len(v) for k, v in by_sev.items()},
            "targets": len(set(f.get("target", "") for f in findings)),
            "unique_endpoints": len(set(f.get("endpoint", "") for f in findings)),
        }
```

### Step 3: Build the Template Engine

```python
# generate_report.py
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any

from jinja2 import Environment, FileSystemLoader, select_autoescape

from parsers.json_parser import ScanResultParser


class ReportGenerator:
    def __init__(self, config_path: str = "config.yaml"):
        import yaml
        with open(config_path) as f:
            self.config = yaml.safe_load(f)["report"]

        template_dir = Path(__file__).parent / "templates"
        self.env = Environment(
            loader=FileSystemLoader(str(template_dir)),
            autoescape=select_autoescape(["html"]),
        )
        self.parser = ScanResultParser()
        self.output_dir = Path(self.config["output_dir"])

    def load_findings(self, filepath: str) -> List[dict]:
        ext = Path(filepath).suffix.lower()
        if ext == ".json":
            if filepath.endswith(".jsonl"):
                return self.parser.parse_nuclei_jsonl(filepath)
            return self.parser.parse_json(filepath)
        elif ext == ".csv":
            return self.parser.parse_csv(filepath)
        return []

    def generate_markdown(self, findings: List[dict], title: str = "Scan Report") -> str:
        template = self.env.get_template("scan_summary.md")
        stats = self.parser.get_summary_stats(findings)
        by_severity = self.parser.aggregate_by_severity(findings)
        by_target = self.parser.aggregate_by_target(findings)

        return template.render(
            title=title,
            date=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            stats=stats,
            by_severity=by_severity,
            by_target=by_target,
            findings=sorted(findings, key=lambda x: x.get("severity_score", 0), reverse=True),
            config=self.config,
        )

    def generate_html(self, findings: List[dict], title: str = "Scan Report") -> str:
        template = self.env.get_template("vulnerability_detail.html")
        stats = self.parser.get_summary_stats(findings)
        by_severity = self.parser.aggregate_by_severity(findings)
        by_target = self.parser.aggregate_by_target(findings)

        return template.render(
            title=title,
            date=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            stats=stats,
            by_severity=by_severity,
            by_target=by_target,
            findings=sorted(findings, key=lambda x: x.get("severity_score", 0), reverse=True),
            config=self.config,
        )

    def generate_pdf(self, findings: List[dict], title: str = "Scan Report") -> str:
        html_content = self.generate_html(findings, title)
        pdf_dir = self.output_dir / "pdf"
        pdf_dir.mkdir(parents=True, exist_ok=True)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        pdf_path = pdf_dir / f"report_{timestamp}.pdf"

        try:
            from weasyprint import HTML
            HTML(string=html_content).write_pdf(str(pdf_path))
            return str(pdf_path)
        except ImportError:
            import pdfkit
            pdfkit.from_string(html_content, str(pdf_path))
            return str(pdf_path)

    def generate_executive_summary(self, findings: List[dict]) -> str:
        template = self.env.get_template("executive_summary.html")
        stats = self.parser.get_summary_stats(findings)
        by_severity = self.parser.aggregate_by_severity(findings)

        return template.render(
            date=datetime.now().strftime("%Y-%m-%d"),
            stats=stats,
            by_severity=by_severity,
            config=self.config,
        )

    def generate_all(self, findings: List[dict], title: str = "Scan Report") -> dict:
        output_files = {}
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        for fmt in self.config.get("formats", ["markdown"]):
            if fmt == "markdown":
                content = self.generate_markdown(findings, title)
                path = self.output_dir / "markdown" / f"report_{timestamp}.md"
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")
                output_files["markdown"] = str(path)

            elif fmt == "html":
                content = self.generate_html(findings, title)
                path = self.output_dir / "html" / f"report_{timestamp}.html"
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")
                output_files["html"] = str(path)

            elif fmt == "pdf":
                try:
                    path = self.generate_pdf(findings, title)
                    output_files["pdf"] = path
                except Exception as e:
                    print(f"PDF generation failed: {e}")

        return output_files
```

### Step 4: Create Templates

```markdown
# templates/scan_summary.md
# {{ title }}

**Generated**: {{ date }}
**Company**: {{ config.company_name }}
**Author**: {{ config.author }}

---

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Findings | {{ stats.total }} |
| Critical | {{ stats.by_severity.critical }} |
| High | {{ stats.by_severity.high }} |
| Medium | {{ stats.by_severity.medium }} |
| Low | {{ stats.by_severity.low }} |
| Info | {{ stats.by_severity.info }} |
| Targets Scanned | {{ stats.targets }} |
| Unique Endpoints | {{ stats.unique_endpoints }} |

---

## Findings by Severity

### Critical
{% for f in by_severity.critical %}
- **{{ f.title }}** — `{{ f.target }}{{ f.endpoint }}`
  {{ f.description | truncate(200) }}
{% else %}
No critical findings.
{% endfor %}

### High
{% for f in by_severity.high %}
- **{{ f.title }}** — `{{ f.target }}{{ f.endpoint }}`
  {{ f.description | truncate(200) }}
{% else %}
No high findings.
{% endfor %}

### Medium
{% for f in by_severity.medium %}
- **{{ f.title }}** — `{{ f.target }}{{ f.endpoint }}`
  {{ f.description | truncate(200) }}
{% else %}
No medium findings.
{% endfor %}

### Low
{% for f in by_severity.low %}
- **{{ f.title }}** — `{{ f.target }}{{ f.endpoint }}`
  {{ f.description | truncate(200) }}
{% else %}
No low findings.
{% endfor %}

---

## Detailed Findings

{% for f in findings %}
### {{ loop.index }}. {{ f.title }}

| Field | Value |
|-------|-------|
| Severity | {{ f.severity | upper }} |
| CVSS | {{ f.cvss }} |
| Target | {{ f.target }} |
| Endpoint | `{{ f.endpoint }}` |
| Tool | {{ f.tool }} |

**Description**: {{ f.description }}

{% if f.remediation %}
**Remediation**: {{ f.remediation }}
{% endif %}

{% if f.references %}
**References**:
{% for ref in f.references %}
- {{ ref }}
{% endfor %}
{% endif %}

---

{% endfor %}

## Methodology

This report was generated using automated security scanning tools with manual verification.
All testing was conducted within authorized scope and legal boundaries.

---

*Report generated by {{ config.company_name }} automation pipeline.*
```

```html
<!-- templates/vulnerability_detail.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ title }}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; color: #333; line-height: 1.6; }
        .header { background: linear-gradient(135deg, #1a1a2e, #16213e); color: white;
                  padding: 40px; text-align: center; }
        .header h1 { font-size: 28px; margin-bottom: 10px; }
        .header .meta { font-size: 14px; opacity: 0.8; }
        .container { max-width: 1000px; margin: 0 auto; padding: 20px; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                       gap: 15px; margin: 30px 0; }
        .stat-card { background: white; border-radius: 8px; padding: 20px; text-align: center;
                     box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .stat-card .number { font-size: 32px; font-weight: bold; }
        .stat-card .label { font-size: 12px; color: #666; text-transform: uppercase; }
        .stat-critical .number { color: #FF0000; }
        .stat-high .number { color: #FF6600; }
        .stat-medium .number { color: #FFCC00; }
        .stat-low .number { color: #36a64f; }
        .stat-info .number { color: #439FE0; }
        .finding { background: white; border-radius: 8px; margin: 20px 0;
                   box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }
        .finding-header { padding: 15px 20px; color: white; font-weight: bold;
                          display: flex; justify-content: space-between; align-items: center; }
        .finding-body { padding: 20px; }
        .finding-body table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        .finding-body table td { padding: 8px 12px; border-bottom: 1px solid #eee; }
        .finding-body table td:first-child { font-weight: bold; width: 150px; }
        .code { background: #f5f5f5; padding: 15px; border-radius: 4px;
                font-family: 'Consolas', monospace; font-size: 13px;
                overflow-x: auto; white-space: pre-wrap; }
        .sev-badge { padding: 4px 12px; border-radius: 4px; font-size: 12px;
                     text-transform: uppercase; font-weight: bold; }
        .footer { text-align: center; padding: 30px; color: #666; font-size: 12px; }
        .remediation { background: #e8f5e9; border-left: 4px solid #36a64f;
                       padding: 15px; margin: 15px 0; border-radius: 0 4px 4px 0; }
        @media print {
            .finding { break-inside: avoid; }
            body { font-size: 12px; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{ title }}</h1>
        <div class="meta">{{ config.company_name }} | {{ date }} | {{ config.author }}</div>
    </div>

    <div class="container">
        <h2>Executive Summary</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <div class="number">{{ stats.total }}</div>
                <div class="label">Total Findings</div>
            </div>
            <div class="stat-card stat-critical">
                <div class="number">{{ stats.by_severity.critical }}</div>
                <div class="label">Critical</div>
            </div>
            <div class="stat-card stat-high">
                <div class="number">{{ stats.by_severity.high }}</div>
                <div class="label">High</div>
            </div>
            <div class="stat-card stat-medium">
                <div class="number">{{ stats.by_severity.medium }}</div>
                <div class="label">Medium</div>
            </div>
            <div class="stat-card stat-low">
                <div class="number">{{ stats.by_severity.low }}</div>
                <div class="label">Low</div>
            </div>
            <div class="stat-card stat-info">
                <div class="number">{{ stats.by_severity.info }}</div>
                <div class="label">Info</div>
            </div>
        </div>

        <h2>Detailed Findings</h2>
        {% for f in findings %}
        <div class="finding">
            <div class="finding-header" style="background-color: {{ config.severity_colors.get(f.severity, '#999') }}">
                <span>{{ f.title }}</span>
                <span class="sev-badge" style="background: rgba(255,255,255,0.2)">{{ f.severity | upper }}</span>
            </div>
            <div class="finding-body">
                <table>
                    <tr><td>Target</td><td>{{ f.target }}</td></tr>
                    <tr><td>Endpoint</td><td><code>{{ f.endpoint }}</code></td></tr>
                    <tr><td>CVSS Score</td><td>{{ f.cvss }}</td></tr>
                    <tr><td>Tool</td><td>{{ f.tool }}</td></tr>
                    <tr><td>Discovered</td><td>{{ f.timestamp }}</td></tr>
                </table>

                <h3>Description</h3>
                <p>{{ f.description }}</p>

                {% if f.evidence %}
                <h3>Evidence</h3>
                <div class="code">{{ f.evidence }}</div>
                {% endif %}

                {% if f.remediation %}
                <div class="remediation">
                    <h3>Remediation</h3>
                    <p>{{ f.remediation }}</p>
                </div>
                {% endif %}

                {% if f.references %}
                <h3>References</h3>
                <ul>
                    {% for ref in f.references %}
                    <li>{{ ref }}</li>
                    {% endfor %}
                </ul>
                {% endif %}
            </div>
        </div>
        {% endfor %}
    </div>

    <div class="footer">
        <p>{{ config.company_name }} — Security Report</p>
        <p>Generated on {{ date }}</p>
    </div>
</body>
</html>
```

### Step 5: Build Delivery System

```python
# deliver/email_sender.py
import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from pathlib import Path


class ReportDelivery:
    def __init__(self):
        self.smtp_host = os.getenv("SMTP_HOST", "smtp.gmail.com")
        self.smtp_port = int(os.getenv("SMTP_PORT", "587"))
        self.smtp_user = os.getenv("SMTP_USER")
        self.smtp_pass = os.getenv("SMTP_PASS")

    def send_report(
        self,
        recipients: list,
        subject: str,
        body: str,
        attachments: list = None,
    ) -> bool:
        msg = MIMEMultipart()
        msg["From"] = self.smtp_user
        msg["To"] = ", ".join(recipients)
        msg["Subject"] = subject
        msg.attach(MIMEText(body, "html"))

        if attachments:
            for filepath in attachments:
                path = Path(filepath)
                if not path.exists():
                    continue
                with open(path, "rb") as f:
                    part = MIMEBase("application", "octet-stream")
                    part.set_payload(f.read())
                    encoders.encode_base64(part)
                    part.add_header(
                        "Content-Disposition",
                        f"attachment; filename={path.name}",
                    )
                    msg.attach(part)

        try:
            with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_user, self.smtp_pass)
                server.send_message(msg)
            return True
        except Exception as e:
            print(f"Email delivery failed: {e}")
            return False

    def send_to_slack(self, webhook_url: str, message: str, files: list = None):
        import requests
        payload = {"text": message}
        requests.post(webhook_url, json=payload, timeout=10)

        if files:
            for filepath in files:
                with open(filepath, "rb") as f:
                    requests.post(
                        webhook_url,
                        files={"file": f},
                        timeout=30,
                    )
```

---

## 5. Tool Arsenal with Commands

### 5.1 Quick Report Generator

```python
import json
import sys
from generate_report import ReportGenerator

def quick_report(scan_file: str):
    gen = ReportGenerator()
    findings = gen.load_findings(scan_file)
    output = gen.generate_all(findings, title="Security Scan Report")
    for fmt, path in output.items():
        print(f"[{fmt}] {path}")
    return output

if __name__ == "__main__":
    if len(sys.argv) > 1:
        quick_report(sys.argv[1])
```

### 5.2 Severity Chart Generator

```python
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def generate_severity_chart(stats: dict, output_path: str = "severity_chart.png"):
    labels = list(stats["by_severity"].keys())
    values = list(stats["by_severity"].values())
    colors = ["#FF0000", "#FF6600", "#FFCC00", "#36a64f", "#439FE0"]

    fig, ax = plt.subplots(figsize=(8, 5))
    bars = ax.bar(labels, values, color=colors[:len(labels)])
    ax.set_xlabel("Severity")
    ax.set_ylabel("Count")
    ax.set_title("Findings by Severity")

    for bar, val in zip(bars, values):
        if val > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
                    str(val), ha="center", va="bottom", fontweight="bold")

    plt.tight_layout()
    plt.savefig(output_path, dpi=150)
    plt.close()
    return output_path
```

### 5.3 CSV Exporter

```python
import csv
from typing import List


def export_findings_csv(findings: List[dict], output_path: str):
    if not findings:
        print("No findings to export")
        return

    fieldnames = ["id", "title", "severity", "cvss", "target", "endpoint",
                  "description", "remediation", "tool", "timestamp"]

    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for finding in findings:
            writer.writerow(finding)

    print(f"Exported {len(findings)} findings to {output_path}")
```

### 5.4 JSON-to-Report One-Liner

```bash
python -c "
from generate_report import ReportGenerator
gen = ReportGenerator()
findings = gen.load_findings('scan_results.json')
gen.generate_all(findings, 'Automated Scan Report')
"
```

### 5.5 Multi-Format Batch Generator

```python
from pathlib import Path
import json
from generate_report import ReportGenerator


def batch_generate(input_dir: str):
    gen = ReportGenerator()
    input_path = Path(input_dir)

    for scan_file in input_path.glob("*.json"):
        findings = gen.load_findings(str(scan_file))
        title = f"Report: {scan_file.stem}"
        output = gen.generate_all(findings, title=title)
        print(f"{scan_file.name} -> {list(output.keys())}")
```

---

## 6. Real-World Examples

### Example 1: Nuclei-to-PDF Pipeline

```python
import subprocess
import json
from pathlib import Path
from generate_report import ReportGenerator


def nuclei_to_report(target: str, templates: str, output_dir: str = "output"):
    results_file = f"{output_dir}/nuclei_results.jsonl"

    cmd = [
        "nuclei", "-target", target,
        "-t", templates,
        "-jsonl",
        "-o", results_file,
        "-severity", "critical,high,medium,low",
    ]
    subprocess.run(cmd, check=True)

    gen = ReportGenerator()
    findings = gen.load_findings(results_file)
    output = gen.generate_all(findings, title=f"Nuclei Scan: {target}")

    print(f"Report generated: {output}")
    return output
```

### Example 2: Automated Client Report with Charts

```python
from generate_report import ReportGenerator
from deliver.email_sender import ReportDelivery
from parsers.json_parser import ScanResultParser
from pathlib import Path
import json


def client_report_pipeline(scan_file: str, client_email: str):
    gen = ReportGenerator()
    findings = gen.load_findings(scan_file)
    parser = ScanResultParser()
    stats = parser.get_summary_stats(findings)

    from generate_severity_chart import generate_severity_chart
    chart_path = generate_severity_chart(stats, "output/severity_chart.png")

    output = gen.generate_all(findings, title="Client Security Assessment")

    delivery = ReportDelivery()
    delivery.send_report(
        recipients=[client_email],
        subject="[Security Assessment] Monthly Report",
        body="<h2>Monthly Security Assessment</h2><p>Please find attached the latest report.</p>",
        attachments=list(output.values()) + [chart_path],
    )
    print(f"Report sent to {client_email}")
```

### Example 3: Historical Trend Report

```python
import json
from pathlib import Path
from datetime import datetime, timedelta
from parsers.json_parser import ScanResultParser
from jinja2 import Environment, FileSystemLoader


def generate_trend_report(history_dir: str = "output/json"):
    parser = ScanResultParser()
    weekly_data = []

    for filepath in sorted(Path(history_dir).glob("report_*.json")):
        with open(filepath) as f:
            data = json.load(f)
        stats = parser.get_summary_stats(data.get("findings", []))
        stats["date"] = filepath.stem.split("_")[1]
        weekly_data.append(stats)

    env = Environment(loader=FileSystemLoader("templates"))
    template = env.get_template("trend_report.html")

    html = template.render(
        title="Vulnerability Trend Report",
        weekly_data=weekly_data,
        date=datetime.now().strftime("%Y-%m-%d"),
    )

    output_path = Path("output/html/trend_report.html")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(html)
    return str(output_path)
```

---

## 7. Common Pitfalls

### Pitfall 1: Template Rendering Errors

**Problem**: Jinja2 fails on missing variables or malformed template.

**Solution**: Use default filters and validate data before rendering.

```python
# Use defaults for missing fields
{{ f.title | default("Unknown") }}
{{ f.cvss | default("N/A") }}
{{ f.description | default("") | truncate(200) }}
```

### Pitfall 2: PDF Generation Failures

**Problem**: weasyprint crashes on complex CSS or missing system libs.

**Solution**: Fallback to simpler PDF engine or pre-validate HTML.

```python
try:
    from weasyprint import HTML
    HTML(string=html).write_pdf(path)
except Exception:
    import pdfkit
    pdfkit.from_string(html, path)
```

### Pitfall 3: Large Report Memory Issues

**Problem**: 10,000+ findings cause memory exhaustion.

**Solution**: Stream processing and pagination.

```python
def generate_chunked(findings, chunk_size=500):
    for i in range(0, len(findings), chunk_size):
        chunk = findings[i:i + chunk_size]
        yield generate_section(chunk, section_number=i // chunk_size + 1)
```

### Pitfall 4: Special Characters in Findings

**Problem**: HTML injection from raw scan output.

**Solution**: Always escape user-controlled content.

```python
from markupsafe import escape
safe_description = escape(finding.get("description", ""))
```

### Pitfall 5: Timezone Inconsistencies

**Problem**: Reports show different timestamps based on server timezone.

**Solution**: Normalize to UTC for storage, display local timezone.

```python
from datetime import datetime, timezone

def normalize_timestamp(ts: str) -> str:
    dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
    return dt.astimezone(timezone.utc).isoformat()
```

---

## 8. Advanced Techniques

### 8.1 Report Versioning

```python
from pathlib import Path
import json
from datetime import datetime


class ReportVersioner:
    def __init__(self, version_dir: str = "versions"):
        self.version_dir = Path(version_dir)
        self.version_dir.mkdir(parents=True, exist_ok=True)

    def save_version(self, report_data: dict, label: str = "") -> str:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        version_file = self.version_dir / f"report_{timestamp}.json"
        with open(version_file, "w") as f:
            json.dump(report_data, f, indent=2)
        return str(version_file)

    def compare_versions(self, v1_path: str, v2_path: str) -> dict:
        with open(v1_path) as f:
            v1 = json.load(f)
        with open(v2_path) as f:
            v2 = json.load(f)

        v1_findings = {f["id"]: f for f in v1.get("findings", [])}
        v2_findings = {f["id"]: f for f in v2.get("findings", [])}

        new = set(v2_findings) - set(v1_findings)
        removed = set(v1_findings) - set(v2_findings)

        return {
            "new_findings": [v2_findings[fid] for fid in new],
            "removed_findings": [v1_findings[fid] for fid in removed],
            "unchanged": len(set(v1_findings) & set(v2_findings)),
        }
```

### 8.2 Interactive HTML Reports with Charts

```python
def generate_interactive_html(findings: list) -> str:
    import base64
    from io import BytesIO
    import matplotlib.pyplot as plt

    severity_counts = {}
    for f in findings:
        sev = f.get("severity", "info")
        severity_counts[sev] = severity_counts.get(sev, 0) + 1

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    colors = ["#FF0000", "#FF6600", "#FFCC00", "#36a64f", "#439FE0"]
    labels = list(severity_counts.keys())
    values = list(severity_counts.values())
    ax1.pie(values, labels=labels, colors=colors[:len(labels)], autopct="%1.0f%%")
    ax1.set_title("Severity Distribution")

    target_counts = {}
    for f in findings:
        t = f.get("target", "unknown")
        target_counts[t] = target_counts.get(t, 0) + 1
    top_targets = sorted(target_counts.items(), key=lambda x: -x[1])[:10]
    ax2.barh([t[0][:30] for t in top_targets], [t[1] for t in top_targets], color="#439FE0")
    ax2.set_title("Top 10 Targets")

    buf = BytesIO()
    plt.tight_layout()
    plt.savefig(buf, format="png", dpi=150)
    buf.seek(0)
    chart_b64 = base64.b64encode(buf.read()).decode()
    plt.close()

    return f'<img src="data:image/png;base64,{chart_b64}" alt="Charts">'
```

### 8.3 Report Caching

```python
import hashlib
import json
from pathlib import Path


class ReportCache:
    def __init__(self, cache_dir: str = ".cache/reports"):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(parents=True, exist_ok=True)

    def _key(self, findings: list) -> str:
        data = json.dumps(findings, sort_keys=True)
        return hashlib.sha256(data.encode()).hexdigest()

    def get(self, findings: list) -> dict | None:
        key = self._key(findings)
        cache_file = self.cache_dir / f"{key}.json"
        if cache_file.exists():
            with open(cache_file) as f:
                return json.load(f)
        return None

    def set(self, findings: list, report_data: dict):
        key = self._key(findings)
        cache_file = self.cache_dir / f"{key}.json"
        with open(cache_file, "w") as f:
            json.dump(report_data, f)
```

---

## 9. Reporting Template

### Automated Report Generation Script

```python
#!/usr/bin/env python3
"""Master report generation script — run after any scan."""

import argparse
import json
import sys
from pathlib import Path
from datetime import datetime

from generate_report import ReportGenerator
from deliver.email_sender import ReportDelivery


def main():
    parser = argparse.ArgumentParser(description="Generate security report")
    parser.add_argument("scan_file", help="Path to scan results file")
    parser.add_argument("--title", default="Security Scan Report")
    parser.add_argument("--format", nargs="+", default=["markdown", "html", "pdf"])
    parser.add_argument("--email", nargs="*", help="Email recipients")
    parser.add_argument("--slack", action="store_true", help="Send to Slack")
    args = parser.parse_args()

    gen = ReportGenerator()
    findings = gen.load_findings(args.scan_file)

    if not findings:
        print("No findings found. Check scan file format.")
        sys.exit(1)

    output = gen.generate_all(findings, title=args.title)

    for fmt, path in output.items():
        print(f"  [{fmt}] {path}")

    if args.email:
        delivery = ReportDelivery()
        body = f"""
        <h2>{args.title}</h2>
        <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        <p>Total findings: {len(findings)}</p>
        <p>See attached report for details.</p>
        """
        delivery.send_report(
            recipients=args.email,
            subject=f"[Security] {args.title}",
            body=body,
            attachments=list(output.values()),
        )
        print(f"  [email] Sent to {', '.join(args.email)}")

    if args.slack:
        import os
        import requests
        webhook = os.getenv("SLACK_WEBHOOK_URL")
        if webhook:
            requests.post(webhook, json={
                "text": f"📊 Report generated: {args.title}\nFindings: {len(findings)}\nFormats: {', '.join(output.keys())}"
            })
            print("  [slack] Notification sent")

    return output


if __name__ == "__main__":
    main()
```

### Usage Examples

```bash
# Basic report generation
python generate_report.py scan_results.json

# Custom title with email delivery
python generate_report.py scan_results.json --title "API Security Audit" --email team@company.com

# Multiple formats with Slack notification
python generate_report.py scan_results.json --format markdown html pdf --slack

# Batch processing
python -c "
from pathlib import Path
from generate_report import ReportGenerator
gen = ReportGenerator()
for f in Path('scans/').glob('*.json'):
    gen.generate_all(gen.load_findings(str(f)), title=f.stem)
"
```

---

## 10. Quick Reference

### Report Format Comparison

| Format | Best For | Pros | Cons |
|--------|----------|------|------|
| Markdown | GitHub, quick sharing | Fast, version-control friendly | No styling |
| HTML | Email, web viewing | Rich formatting, charts | Larger file size |
| PDF | Client delivery, printing | Professional, portable | Generation can be slow |
| CSV | Data analysis, imports | Tabular, Excel-compatible | No formatting |
| JSON | API consumption, storage | Structured, parseable | Not human-readable |

### Key Functions Cheat Sheet

```python
# Parse findings
parser = ScanResultParser()
findings = parser.parse_json("results.json")
findings = parser.parse_nuclei_jsonl("nuclei.jsonl")

# Generate reports
gen = ReportGenerator()
md = gen.generate_markdown(findings)
html = gen.generate_html(findings)
pdf = gen.generate_pdf(findings)
output = gen.generate_all(findings)

# Deliver
delivery = ReportDelivery()
delivery.send_report(["team@company.com"], "Report", "body", ["report.pdf"])
```

### Template Variables

```
{{ title }}                    # Report title
{{ date }}                     # Generation date
{{ config.company_name }}      # Company name
{{ stats.total }}              # Total findings count
{{ stats.by_severity.critical }}  # Critical count
{{ findings }}                 # List of all findings
{{ f.title }}                  # Finding title
{{ f.severity }}               # Finding severity
{{ f.cvss }}                   # CVSS score
{{ f.target }}                 # Target host
{{ f.endpoint }}               # Affected endpoint
{{ f.description }}            # Finding description
{{ f.remediation }}            # Remediation guidance
```

### File Paths Summary

```
reporting/
├── config.yaml                # Report configuration
├── generate_report.py         # Main generation engine
├── parsers/
│   └── json_parser.py         # Data parsing and normalization
├── templates/
│   ├── scan_summary.md        # Markdown template
│   ├── vulnerability_detail.html  # HTML report template
│   └── executive_summary.html # Executive summary template
├── deliver/
│   └── email_sender.py        # Email delivery
└── output/
    ├── markdown/              # Generated .md files
    ├── html/                  # Generated .html files
    └── pdf/                   # Generated .pdf files
```

### Common CLI Patterns

```bash
# After nuclei scan
nuclei -target target.com -t templates/ -jsonl -o results.jsonl
python generate_report.py results.jsonl --title "Nuclei Scan" --email team@company.com

# After httpx probing
httpx -l live_hosts.txt -json -o httpx_results.json
python generate_report.py httpx_results.json --format html pdf

# Weekly summary
python -c "
from generate_report import ReportGenerator
from pathlib import Path
gen = ReportGenerator()
all_findings = []
for f in Path('output/json/').glob('*.json'):
    all_findings.extend(gen.load_findings(str(f)))
gen.generate_all(all_findings, 'Weekly Security Summary')
"
```
