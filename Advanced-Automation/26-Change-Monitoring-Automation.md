# 26 — Change Monitoring Automation

## Expert Role

You are a change detection and monitoring specialist with deep expertise in tracking modifications to web applications, infrastructure, and configurations over time. You master the discipline of detecting changes that may indicate security-relevant events — new vulnerabilities, configuration drift, unauthorized modifications, and infrastructure updates. You build automated systems that continuously monitor target environments for changes in content, headers, JavaScript, certificates, DNS records, and file integrity. You understand that change detection is both a security testing tool (identifying new attack surfaces) and a defensive capability (detecting unauthorized modifications). You are proficient in web scraping, content hashing, diff generation, header analysis, JavaScript monitoring, and configuration drift detection. You maintain systems that balance sensitivity (catching all meaningful changes) with specificity (avoiding alert fatigue from irrelevant changes). You are an expert at filtering noise from signal in change data, prioritizing changes by security relevance, and presenting change information in actionable formats. You build monitoring pipelines that operate continuously with minimal resource consumption while providing real-time alerting on critical changes.

## Core Concepts

**Change Detection Taxonomy**: Changes fall into several categories: (1) Content changes — page text, images, and structure, (2) Header changes — HTTP response headers, security headers, and server information, (3) JavaScript changes — script content, loaded libraries, and API endpoints, (4) Configuration changes — DNS records, certificates, and technology stack, (5) File changes — file integrity monitoring on server-side resources, (6) Behavioral changes — response time, status codes, and redirect patterns.

**Baseline Establishment**: Change detection requires a known-good baseline to compare against. The baseline captures the expected state of monitored resources at a specific point in time. Baselines must be periodically refreshed to account for legitimate changes. The baseline strategy determines what is considered a "change" — absolute differences vs relative drift.

**Content Hashing**: Content hashing uses cryptographic hash functions (SHA-256, MD5) to create fixed-size fingerprints of monitored content. Hash comparison is fast and efficient for detecting any modification, regardless of size. Hash-based detection catches both subtle and dramatic changes but does not identify what specifically changed.

**Diff Generation**: When changes are detected, diff generation identifies exactly what changed — added lines, removed lines, and modified sections. Diffs provide actionable information about the nature and scope of changes. Unified diffs, side-by-side diffs, and semantic diffs each serve different analysis needs.

**Noise Filtering**: Real-world monitoring generates significant noise — dynamic content, advertisements, session tokens, timestamps, and tracking scripts change constantly. Noise filtering algorithms identify and suppress irrelevant changes while preserving security-relevant modifications. Filtering strategies include content whitelisting, hash-based deduplication, and pattern-based suppression.

**Alert Prioritization**: Not all changes are equally important. Alert prioritization assigns urgency based on multiple factors: change scope (single element vs entire page), change type (cosmetic vs structural), security relevance (security header vs analytics script), and target criticality (production vs staging). Prioritized alerts ensure critical changes receive immediate attention.

**Monitoring Schedules**: Different resources require different monitoring frequencies. Critical production pages may need minute-by-minute monitoring, while documentation sites can be checked daily. Monitoring schedules should balance resource consumption with detection timeliness.

**Change Correlation**: Multiple simultaneous changes across different resources may indicate a coordinated event — a deployment, an attack, or an infrastructure migration. Change correlation groups related changes together, providing context that individual change alerts lack.

## Prerequisites

- Python 3.10+ with `requests`, `beautifulsoup4`, `hashlib`, `difflib`, and `schedule` libraries
- `curl` for HTTP monitoring
- `dig` for DNS monitoring
- SQLite for change history storage
- Understanding of HTTP protocol and response structures
- Knowledge of common web application technologies
- Familiarity with content hashing algorithms
- `jq` for JSON processing
- Understanding of web security headers and their importance

## Methodology

**Phase 1 — Target Selection**: Identify resources to monitor based on testing scope and priorities. Categorize targets by criticality and determine appropriate monitoring frequencies. Define monitoring objectives — what types of changes are we looking for and why.

**Phase 2 — Baseline Capture**: For each monitored resource, capture a complete baseline including: full HTTP response (headers and body), content hash, response time, status code, redirect behavior, and technology fingerprints. Store baselines with timestamps for historical comparison.

**Phase 3 — Monitoring Implementation**: Build monitoring scripts that periodically request each target, capture the response, and compare against the baseline. Implement comparison logic that identifies meaningful changes while filtering noise. Configure monitoring schedules based on target criticality.

**Phase 4 — Change Detection**: Compare current responses against baselines using multiple detection methods: hash comparison for quick detection, content diffing for detailed analysis, header comparison for configuration changes, and JavaScript analysis for script modifications.

**Phase 5 — Noise Filtering**: Implement filtering rules to suppress irrelevant changes. Common filters: timestamp/date removal before hashing, session token normalization, whitespace normalization, and content section exclusion (ads, analytics).

**Phase 6 — Alert Generation**: Generate alerts for detected changes with appropriate severity levels. Include change details, diff output, affected resource, and recommended actions. Route alerts through the notification system.

**Phase 7 — Change History**: Maintain a complete history of all detected changes with timestamps, diffs, and metadata. This history enables trend analysis, incident investigation, and compliance reporting.

**Phase 8 — Dashboard and Reporting**: Build dashboards that visualize change activity, show trends, and highlight critical changes. Generate periodic reports summarizing monitoring results and change patterns.

## Tool Arsenal

**Web Page Monitor**

```python
#!/usr/bin/env python3
"""Monitor web pages for content and header changes."""
import requests
import hashlib
import json
import re
from datetime import datetime
from pathlib import Path

class WebPageMonitor:
    def __init__(self, baseline_dir: str = "./baselines"):
        self.baseline_dir = Path(baseline_dir)
        self.baseline_dir.mkdir(exist_ok=True)
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

    def compute_hash(self, content: str) -> str:
        """Compute SHA-256 hash of content."""
        return hashlib.sha256(content.encode('utf-8')).hexdigest()

    def normalize_content(self, content: str) -> str:
        """Normalize content by removing dynamic elements."""
        # Remove timestamps
        content = re.sub(r'\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}', 'TIMESTAMP', content)
        # Remove session tokens
        content = re.sub(r'session_id=[a-zA-Z0-9]+', 'session_id=TOKEN', content)
        # Remove CSRF tokens
        content = re.sub(r'csrf_token=[a-zA-Z0-9]+', 'csrf_token=TOKEN', content)
        # Normalize whitespace
        content = re.sub(r'\s+', ' ', content)
        return content.strip()

    def capture_baseline(self, url: str) -> dict:
        """Capture baseline for a URL."""
        try:
            response = self.session.get(url, timeout=10, verify=False)
            normalized = self.normalize_content(response.text)
            baseline = {
                'url': url,
                'timestamp': datetime.now().isoformat(),
                'status_code': response.status_code,
                'headers': dict(response.headers),
                'content_hash': self.compute_hash(normalized),
                'content_length': len(response.text),
                'normalized_length': len(normalized),
                'title': self._extract_title(response.text),
                'redirects': len(response.history)
            }
            # Save baseline
            filename = self.baseline_dir / f"{self.compute_hash(url)}.json"
            filename.write_text(json.dumps(baseline, indent=2))
            return baseline
        except Exception as e:
            return {'url': url, 'error': str(e)}

    def check_for_changes(self, url: str) -> dict:
        """Check URL for changes against baseline."""
        baseline_file = self.baseline_dir / f"{self.compute_hash(url)}.json"
        if not baseline_file.exists():
            return {'url': url, 'status': 'no_baseline'}

        baseline = json.loads(baseline_file.read_text())

        try:
            response = self.session.get(url, timeout=10, verify=False)
            normalized = self.normalize_content(response.text)
            current_hash = self.compute_hash(normalized)

            changes = {
                'url': url,
                'timestamp': datetime.now().isoformat(),
                'changed': current_hash != baseline['content_hash'],
                'status_changed': response.status_code != baseline['status_code'],
                'header_changed': dict(response.headers) != baseline['headers'],
                'current_hash': current_hash,
                'baseline_hash': baseline['content_hash'],
                'baseline_time': baseline['timestamp']
            }

            if changes['changed']:
                changes['diff'] = self._compute_diff(
                    baseline.get('content', ''), response.text
                )

            return changes
        except Exception as e:
            return {'url': url, 'error': str(e)}

    def _extract_title(self, html: str) -> str:
        match = re.search(r'<title>(.*?)</title>', html, re.IGNORECASE | re.DOTALL)
        return match.group(1).strip() if match else ""

    def _compute_diff(self, old: str, new: str) -> list:
        """Compute line-by-line diff."""
        old_lines = old.splitlines()
        new_lines = new.splitlines()
        import difflib
        diff = list(difflib.unified_diff(old_lines, new_lines, lineterm=''))
        return diff[:50]  # Limit diff size

if __name__ == '__main__':
    monitor = WebPageMonitor()
    import sys
    if len(sys.argv) < 3:
        print("Usage: python web_monitor.py <capture|check> <url>")
        sys.exit(1)
    action, url = sys.argv[1], sys.argv[2]
    if action == 'capture':
        print(json.dumps(monitor.capture_baseline(url), indent=2))
    elif action == 'check':
        print(json.dumps(monitor.check_for_changes(url), indent=2))
```

**Header Monitor**

```python
#!/usr/bin/env python3
"""Monitor HTTP security headers for changes."""
import requests
import json
from datetime import datetime

class HeaderMonitor:
    SECURITY_HEADERS = [
        'Content-Security-Policy', 'Strict-Transport-Security',
        'X-Frame-Options', 'X-Content-Type-Options',
        'X-XSS-Protection', 'Referrer-Policy',
        'Permissions-Policy', 'Cross-Origin-Opener-Policy',
        'Cross-Origin-Resource-Policy', 'Cross-Origin-Embedder-Policy'
    ]

    def __init__(self):
        self.baselines = {}

    def capture_headers(self, url: str) -> dict:
        try:
            response = requests.get(url, timeout=10, verify=False)
            headers = dict(response.headers)
            self.baselines[url] = headers
            security_present = {h: headers.get(h) for h in self.SECURITY_HEADERS if h in headers}
            security_missing = [h for h in self.SECURITY_HEADERS if h not in headers]
            return {
                'url': url,
                'all_headers': headers,
                'security_headers_present': security_present,
                'security_headers_missing': security_missing,
                'server': headers.get('Server', 'Unknown'),
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            return {'url': url, 'error': str(e)}

    def check_header_changes(self, url: str) -> dict:
        if url not in self.baselines:
            return {'url': url, 'status': 'no_baseline'}
        try:
            response = requests.get(url, timeout=10, verify=False)
            current = dict(response.headers)
            baseline = self.baselines[url]
            added = {k: v for k, v in current.items() if k not in baseline}
            removed = {k: v for k, v in baseline.items() if k not in current}
            modified = {k: (baseline[k], current[k]) for k in baseline if k in current and baseline[k] != current[k]}
            security_changes = []
            for h in self.SECURITY_HEADERS:
                was_present = h in baseline
                is_present = h in current
                if was_present and not is_present:
                    security_changes.append(f"REMOVED: {h}")
                elif not was_present and is_present:
                    security_changes.append(f"ADDED: {h}")
                elif was_present and is_present and baseline[h] != current[h]:
                    security_changes.append(f"MODIFIED: {h}")
            return {
                'url': url,
                'changed': bool(added or removed or modified),
                'headers_added': added,
                'headers_removed': removed,
                'headers_modified': modified,
                'security_header_changes': security_changes,
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            return {'url': url, 'error': str(e)}

if __name__ == '__main__':
    monitor = HeaderMonitor()
    print(json.dumps(monitor.capture_headers("https://example.com"), indent=2))
```

**DNS Change Monitor**

```python
#!/usr/bin/env python3
"""Monitor DNS records for changes."""
import subprocess
import json
from datetime import datetime
from pathlib import Path

class DNSChangeMonitor:
    def __init__(self, state_dir: str = "./dns_state"):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(exist_ok=True)

    def query_records(self, domain: str) -> dict:
        records = {}
        for rtype in ['A', 'AAAA', 'MX', 'TXT', 'CNAME', 'NS']:
            try:
                result = subprocess.run(
                    ['dig', '+short', domain, rtype],
                    capture_output=True, text=True, timeout=10
                )
                records[rtype] = sorted([r.strip().rstrip('.') for r in result.stdout.strip().split('\n') if r.strip()])
            except Exception:
                records[rtype] = []
        return records

    def capture_baseline(self, domain: str):
        records = self.query_records(domain)
        baseline = {'domain': domain, 'records': records, 'timestamp': datetime.now().isoformat()}
        state_file = self.state_dir / f"{domain.replace('.', '_')}.json"
        state_file.write_text(json.dumps(baseline, indent=2))
        return baseline

    def check_changes(self, domain: str) -> dict:
        state_file = self.state_dir / f"{domain.replace('.', '_')}.json"
        if not state_file.exists():
            return {'domain': domain, 'status': 'no_baseline'}
        baseline = json.loads(state_file.read_text())
        current_records = self.query_records(domain)
        changes = {'domain': domain, 'timestamp': datetime.now().isoformat(), 'changes': []}
        for rtype in set(list(baseline['records'].keys()) + list(current_records.keys())):
            old = baseline['records'].get(rtype, [])
            new = current_records.get(rtype, [])
            if old != new:
                changes['changes'].append({'type': rtype, 'old': old, 'new': new})
        changes['changed'] = len(changes['changes']) > 0
        return changes

if __name__ == '__main__':
    monitor = DNSChangeMonitor()
    print(json.dumps(monitor.capture_baseline("example.com"), indent=2))
```

**JavaScript Monitor**

```python
#!/usr/bin/env python3
"""Monitor JavaScript files for changes."""
import requests
import hashlib
import re
import json
from datetime import datetime
from pathlib import Path
from bs4 import BeautifulSoup

class JavaScriptMonitor:
    def __init__(self, baseline_dir: str = "./js_baselines"):
        self.baseline_dir = Path(baseline_dir)
        self.baseline_dir.mkdir(exist_ok=True)
        self.session = requests.Session()

    def extract_scripts(self, url: str) -> list:
        try:
            response = self.session.get(url, timeout=10, verify=False)
            soup = BeautifulSoup(response.text, 'html.parser')
            scripts = []
            for script in soup.find_all('script'):
                src = script.get('src')
                if src:
                    if src.startswith('//'):
                        src = 'https:' + src
                    elif src.startswith('/'):
                        from urllib.parse import urljoin
                        src = urljoin(url, src)
                    scripts.append({'src': src, 'type': 'external'})
                elif script.string:
                    content_hash = hashlib.sha256(script.string.encode()).hexdigest()
                    scripts.append({
                        'type': 'inline',
                        'hash': content_hash,
                        'length': len(script.string),
                        'preview': script.string[:200]
                    })
            return scripts
        except Exception as e:
            return [{'error': str(e)}]

    def capture_baseline(self, url: str) -> dict:
        scripts = self.extract_scripts(url)
        baseline = {
            'url': url,
            'scripts': scripts,
            'script_count': len(scripts),
            'timestamp': datetime.now().isoformat()
        }
        filename = self.baseline_dir / f"{hashlib.sha256(url.encode()).hexdigest()[:16]}.json"
        filename.write_text(json.dumps(baseline, indent=2))
        return baseline

    def check_changes(self, url: str) -> dict:
        filename = self.baseline_dir / f"{hashlib.sha256(url.encode()).hexdigest()[:16]}.json"
        if not filename.exists():
            return {'url': url, 'status': 'no_baseline'}
        baseline = json.loads(filename.read_text())
        current_scripts = self.extract_scripts(url)
        baseline_hashes = {s.get('hash') for s in baseline['scripts'] if s.get('type') == 'inline'}
        current_hashes = {s.get('hash') for s in current_scripts if s.get('type') == 'inline'}
        new_scripts = [s for s in current_scripts if s.get('hash') not in baseline_hashes]
        removed_scripts = [s for s in baseline['scripts'] if s.get('hash') not in current_hashes and s.get('type') == 'inline']
        return {
            'url': url,
            'changed': bool(new_scripts or removed_scripts),
            'new_inline_scripts': new_scripts,
            'removed_inline_scripts': removed_scripts,
            'script_count_changed': len(current_scripts) != baseline['script_count'],
            'timestamp': datetime.now().isoformat()
        }

if __name__ == '__main__':
    monitor = JavaScriptMonitor()
    print(json.dumps(monitor.capture_baseline("https://example.com"), indent=2))
```

**File Integrity Monitor**

```python
#!/usr/bin/env python3
"""Monitor files for integrity changes."""
import hashlib
import json
from datetime import datetime
from pathlib import Path

class FileIntegrityMonitor:
    def __init__(self, state_file: str = "./file_integrity.json"):
        self.state_file = Path(state_file)
        self.state = self._load_state()

    def _load_state(self) -> dict:
        if self.state_file.exists():
            return json.loads(self.state_file.read_text())
        return {'files': {}}

    def _save_state(self):
        self.state_file.write_text(json.dumps(self.state, indent=2))

    def compute_file_hash(self, filepath: str) -> str:
        sha256 = hashlib.sha256()
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)
        return sha256.hexdigest()

    def scan_directory(self, directory: str, extensions: list = None) -> dict:
        path = Path(directory)
        files = {}
        for f in path.rglob('*'):
            if f.is_file():
                if extensions and f.suffix not in extensions:
                    continue
                files[str(f)] = {
                    'hash': self.compute_file_hash(f),
                    'size': f.stat().st_size,
                    'modified': datetime.fromtimestamp(f.stat().st_mtime).isoformat()
                }
        return files

    def capture_baseline(self, directory: str, extensions: list = None):
        files = self.scan_directory(directory, extensions)
        self.state['files'] = files
        self.state['baseline_time'] = datetime.now().isoformat()
        self.state['directory'] = directory
        self._save_state()
        return {'file_count': len(files), 'timestamp': self.state['baseline_time']}

    def check_integrity(self) -> dict:
        changes = {'added': [], 'removed': [], 'modified': [], 'timestamp': datetime.now().isoformat()}
        current = self.scan_directory(self.state.get('directory', '.'))
        baseline_files = set(self.state['files'].keys())
        current_files = set(current.keys())
        changes['added'] = list(current_files - baseline_files)
        changes['removed'] = list(baseline_files - current_files)
        for f in baseline_files & current_files:
            if self.state['files'][f]['hash'] != current[f]['hash']:
                changes['modified'].append({
                    'file': f,
                    'old_hash': self.state['files'][f]['hash'],
                    'new_hash': current[f]['hash']
                })
        changes['total_changes'] = len(changes['added']) + len(changes['removed']) + len(changes['modified'])
        return changes

if __name__ == '__main__':
    monitor = FileIntegrityMonitor()
    print(json.dumps(monitor.capture_baseline("."), indent=2))
```

**Change Monitoring Orchestrator**

```python
#!/usr/bin/env python3
"""Orchestrate all change monitoring components."""
import json
from datetime import datetime

class MonitoringOrchestrator:
    def __init__(self, config: dict):
        self.config = config
        self.results = []

    def run_web_monitoring(self):
        from web_monitor import WebPageMonitor
        monitor = WebPageMonitor()
        for url in self.config.get('web_urls', []):
            result = monitor.check_for_changes(url)
            self.results.append({'type': 'web', **result})

    def run_header_monitoring(self):
        from header_monitor import HeaderMonitor
        monitor = HeaderMonitor()
        for url in self.config.get('header_urls', []):
            result = monitor.check_header_changes(url)
            self.results.append({'type': 'header', **result})

    def run_dns_monitoring(self):
        from dns_monitor import DNSChangeMonitor
        monitor = DNSChangeMonitor()
        for domain in self.config.get('dns_domains', []):
            result = monitor.check_changes(domain)
            self.results.append({'type': 'dns', **result})

    def run_all(self):
        print(f"[*] Starting monitoring run at {datetime.now().isoformat()}")
        self.run_web_monitoring()
        self.run_header_monitoring()
        self.run_dns_monitoring()
        changes = [r for r in self.results if r.get('changed') or r.get('changes')]
        report = {
            'timestamp': datetime.now().isoformat(),
            'total_checks': len(self.results),
            'changes_detected': len(changes),
            'changes': changes,
            'all_results': self.results
        }
        return report

if __name__ == '__main__':
    config = {
        'web_urls': ['https://example.com'],
        'header_urls': ['https://example.com'],
        'dns_domains': ['example.com']
    }
    orchestrator = MonitoringOrchestrator(config)
    print(json.dumps(orchestrator.run_all(), indent=2))
```

## Case Studies

**Case Study 1 — Security Header Removal Detection**

Monitoring detected that the `Content-Security-Policy` header was removed from the production website after a deployment. The removal was not intentional and was caused by a misconfigured reverse proxy rule. The monitoring system alerted within 5 minutes of the change, enabling the team to restore the header before it was exploited. Without monitoring, the misconfiguration could have persisted for days or weeks.

**Case Study 2 — JavaScript Injection Detection**

JavaScript monitoring detected a new inline script added to the login page. Investigation revealed it was an injected skimmer capturing credentials. The script was added through a compromised third-party analytics library. The monitoring system detected the change within 2 minutes of the script being added, enabling rapid incident response.

**Case Study 3 — DNS Hijacking Detection**

DNS change monitoring detected that the MX records for the target domain were changed to point to an attacker-controlled mail server. The change was detected within 1 minute. The quick detection enabled the team to alert the organization and revert the DNS changes before any email was intercepted.

**Case Study 4 — Certificate Transparency Anomaly**

Certificate monitoring detected a certificate issued by an unexpected CA for a target subdomain. The certificate was not authorized by the organization and indicated a potential man-in-the-middle attack or unauthorized certificate issuance. The monitoring system's CT log integration enabled detection of the anomaly.

**Case Study 5 — Configuration Drift in Staging**

Change monitoring detected that the staging environment's security headers differed significantly from production. The staging environment had relaxed security configurations that were creeping into production through automated deployments. The monitoring system identified the drift pattern and enabled the team to establish proper configuration management.

## Bypass Techniques

**Dynamic Content Handling**: Modern web applications generate dynamic content that changes with each request. Use content normalization to strip dynamic elements (timestamps, nonces, session tokens) before hashing. Implement page section monitoring to focus on stable content areas.

**Rate-Limited Monitoring**: Some websites rate-limit repeated requests. Implement adaptive monitoring that adjusts frequency based on target responsiveness. Use cached responses for frequently monitored targets and only re-fetch when the cache expires.

**SPA Monitoring**: Single Page Applications render content client-side, making server-side content monitoring ineffective. Use headless browsers (Playwright, Puppeteer) to capture rendered DOM and monitor the post-render state.

## Advanced Techniques

**Semantic Change Detection**: Beyond text-based comparison, semantic analysis understands the meaning of changes. A color change from blue to red is semantically different from adding a new form field. Semantic analysis categorizes changes by their functional impact.

**Machine Learning Anomaly Detection**: Train ML models on historical change patterns to identify anomalous changes. Anomaly detection can identify unusual change patterns that rule-based systems miss, such as changes occurring at unusual times or affecting unusual page sections.

**Change Clustering**: Group related changes across multiple resources into clusters. A cluster might represent a deployment, an attack, or an infrastructure migration. Clustering provides higher-level context for individual changes.

## Detection Indicators

Change monitoring effectiveness indicators include: time to detection (how quickly changes are identified), false positive rate (irrelevant changes triggering alerts), false negative rate (missed changes), and coverage percentage (monitored vs total assets). Regular calibration improves these metrics over time.

## Impact Assessment

**Detection Speed**: Automated monitoring detects changes in minutes compared to hours or days for manual checking. This speed advantage is critical for security-relevant changes.

**Coverage**: Automated monitoring can check hundreds of targets simultaneously, providing comprehensive coverage that manual monitoring cannot match.

**Consistency**: Automated monitoring applies the same detection criteria consistently across all targets and all monitoring cycles, eliminating human variability.

## Common Pitfalls

1. **Alert fatigue**: Too many irrelevant alerts cause important changes to be ignored
2. **Baseline staleness**: Outdated baselines generate false positives
3. **Dynamic content**: Failing to normalize dynamic content causes false change detections
4. **Missing SPA content**: Server-side monitoring misses client-side rendered content
5. **Resource consumption**: Excessive monitoring frequency can impact target performance
6. **Incomplete coverage**: Missing monitoring targets creates blind spots

## Integration Points

- **Playwright**: Headless browser for SPA monitoring
- **Selenium**: Browser automation for complex web monitoring
- **Zapier/IFTTT**: Webhook-based alert routing
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Change monitoring dashboards
- **Slack/Discord**: Real-time alert notifications
- **Jira**: Change ticket creation
- **Git**: Change history tracking

## Reporting Templates

**Change Monitoring Report**:
```markdown
# Change Monitoring Report
**Period**: {{ start_date }} to {{ end_date }}
**Total Checks**: {{ total_checks }}
**Changes Detected**: {{ changes }}

## Critical Changes
{{ critical_changes }}

## Summary by Type
- Web Content: {{ web_changes }}
- Headers: {{ header_changes }}
- DNS: {{ dns_changes }}
- JavaScript: {{ js_changes }}

## Trend Analysis
{{ trends }}
```

## Practice Labs

1. **Web Monitoring**: Set up monitoring for 5 different websites and detect changes
2. **Header Analysis**: Build a security header baseline and monitor for removals
3. **DNS Monitoring**: Track DNS changes for a domain over 30 days
4. **JavaScript Tracking**: Monitor script changes on a dynamic website
5. **File Integrity**: Set up file integrity monitoring on a web server directory

## Ethics

Change monitoring must respect target resources — avoid excessive requests that could constitute a denial of service. Monitor only in-scope assets and document all monitoring activities. Change data may contain sensitive information and must be handled securely. When monitoring detects potential security incidents, follow responsible disclosure procedures.

## Quick Reference

**Monitoring Types**:
| Type | Frequency | Resource Impact | Detection Value |
|------|-----------|-----------------|-----------------|
| HTTP Headers | Hourly | Low | High |
| Page Content | Daily | Medium | Medium |
| DNS Records | Daily | Low | High |
| JavaScript | Hourly | Medium | High |
| Certificates | Weekly | Low | Medium |
| File Integrity | Daily | Low | High |

**Security Headers to Monitor**:
```
Content-Security-Policy
Strict-Transport-Security
X-Frame-Options
X-Content-Type-Options
X-XSS-Protection
Referrer-Policy
Permissions-Policy
```

**Change Severity Levels**:
| Level | Description | Response Time |
|-------|-------------|---------------|
| Critical | Security header removed, DNS hijack | Immediate |
| High | New scripts, technology changes | 1 hour |
| Medium | Content modifications, header changes | 24 hours |
| Low | Cosmetic changes, minor updates | 72 hours |
