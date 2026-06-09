# 25 — Asset Tracking Automation

## Expert Role

You are an asset inventory and tracking specialist with deep expertise in maintaining comprehensive records of target infrastructure over time. You master the discipline of asset discovery, inventory management, change detection, and continuous monitoring. You understand that effective security testing requires a complete and current picture of the target's attack surface. You build automated systems that discover, catalog, track, and monitor digital assets — domains, subdomains, IP addresses, certificates, services, and technologies. You are proficient in asset database design, change detection algorithms, alerting systems, and dashboard visualization. You understand the importance of asset lifecycle management — from initial discovery through active monitoring to decommissioning. You maintain strict data quality standards, ensuring asset records are accurate, complete, and current. You build pipelines that correlate data from multiple discovery sources, deduplicate results, and maintain a single source of truth for target infrastructure. You are an expert at identifying new assets, tracking asset changes, detecting decommissioned systems, and monitoring certificate expirations. You leverage automation to maintain real-time visibility into target infrastructure changes that may create new attack vectors or affect testing activities.

## Core Concepts

**Asset Taxonomy**: A comprehensive asset taxonomy includes: domains, subdomains, IP addresses (IPv4 and IPv6), Autonomous System Numbers (ASN), SSL/TLS certificates, web services (HTTP/HTTPS), non-HTTP services (SSH, FTP, databases), cloud resources (S3 buckets, Lambda functions, CloudFront distributions), email infrastructure (MX records, SPF/DKIM), and technology components (CMS, frameworks, libraries). Each asset type requires specific discovery and monitoring techniques.

**Asset Database Design**: The asset database is the central repository for all discovered assets. It must support: hierarchical relationships (domain → subdomain → IP → service), temporal tracking (when was each asset discovered, last seen, last changed), metadata storage (technology stack, certificates, ownership), and change history (what changed, when, what was the previous state). Design decisions include relational vs graph database, schema flexibility, and query performance.

**Discovery Methods**: Asset discovery combines multiple techniques: DNS enumeration (zone transfer, bruteforcing, passive DNS), certificate transparency monitoring, web crawling, port scanning, cloud service enumeration, and third-party intelligence feeds. Each method discovers different asset types with varying completeness and timeliness. A comprehensive discovery system combines all methods.

**Change Detection**: Change detection compares current asset state against a known baseline. Changes include: new subdomains appearing, DNS record modifications, IP address changes, certificate renewals or replacements, technology stack changes, new services deployed, and services decommissioned. Change detection algorithms must handle both obvious changes (new DNS record) and subtle changes (technology version update).

**Asset Scoring**: Not all assets are equal. Asset scoring assigns priority based on multiple factors: asset criticality (production vs staging), exposure level (internet-facing vs internal), technology risk (outdated software, known CVEs), historical findings (previously discovered vulnerabilities), and business importance (revenue-generating systems). Scoring guides testing prioritization.

**Certificate Monitoring**: SSL/TLS certificates have expiration dates and must be renewed before expiry. Certificate monitoring tracks: certificate issuer, expiration date, renewal status, Subject Alternative Names (SANs), and key algorithm/strength. Expired certificates cause service disruptions and may indicate security issues.

**New Asset Alerting**: When new assets are discovered, the alerting system notifies the testing team. Alerts should include: asset details, discovery source, risk assessment, and recommended testing actions. Alerting must balance completeness with noise reduction — too many alerts cause fatigue, too few cause missed opportunities.

**Asset Relationship Mapping**: Assets have complex relationships — a domain resolves to an IP, which hosts a service, which uses a technology stack, which has certificates. Relationship mapping creates a graph representation of these connections, enabling impact analysis (if an IP changes, which domains and services are affected) and attack path identification.

## Prerequisites

- Python 3.10+ with `requests`, `dnspython`, `sqlite3`, `json`, and `schedule` libraries
- SQLite or PostgreSQL for asset database storage
- `nmap` for service discovery and port scanning
- `dig` and `dnsenum` for DNS enumeration
- `curl` and `httpx` for web service detection
- Understanding of DNS record types and hierarchy
- Knowledge of certificate formats (X.509, PEM, DER)
- Familiarity with cloud service architecture (AWS, Azure, GCP)
- `jq` for JSON processing
- Web framework knowledge for dashboard development (Flask, Django recommended)
- Understanding of time-series data concepts for trend analysis

## Methodology

**Phase 1 — Initial Asset Discovery**: Run comprehensive discovery to build the initial asset inventory. Combine DNS enumeration, CT log queries, subdomain bruteforcing, port scanning, and web crawling. Store all discovered assets in the database with discovery timestamps and source attribution. This phase creates the baseline inventory.

**Phase 2 — Asset Enrichment**: For each discovered asset, collect additional metadata — DNS records, IP ownership, technology stack, certificate details, HTTP headers, and service banners. Enrichment provides context that enables prioritization and risk assessment. Store enriched data alongside the basic asset information.

**Phase 3 — Relationship Mapping**: Link related assets together — domains to their subdomains, subdomains to their IPs, IPs to their services, services to their technologies. Store these relationships in the database to enable graph-based queries and impact analysis.

**Phase 4 — Baseline Establishment**: After initial discovery and enrichment, establish a baseline snapshot of the asset inventory. This snapshot serves as the reference point for change detection. Record the complete asset state at this point in time.

**Phase 5 — Continuous Discovery**: Run ongoing discovery processes to find new assets. Schedule periodic DNS enumeration, CT log queries, and subdomain bruteforcing. Compare new discoveries against the existing inventory to identify additions. New asset discovery should run at regular intervals (daily or weekly depending on target size).

**Phase 6 — Change Monitoring**: Compare current asset state against the baseline to detect changes. Monitor DNS record changes, IP address modifications, certificate updates, technology stack changes, and service status changes. Change monitoring should run more frequently than discovery (hourly or daily).

**Phase 7 — Alert Generation**: When changes or new assets are detected, generate alerts with appropriate priority. Critical changes (new production subdomain, certificate expiry approaching) require immediate notification. Lower-priority changes can be batched into periodic digests.

**Phase 8 — Dashboard Development**: Build a web-based dashboard that visualizes the asset inventory, shows change history, displays alerts, and provides search and filter capabilities. The dashboard enables quick assessment of target infrastructure and identification of testing opportunities.

**Phase 9 — Data Retention and Archival**: Implement data retention policies that preserve historical asset data while managing storage requirements. Archive old records while maintaining the ability to query historical states. Retention policies should align with engagement timelines and compliance requirements.

**Phase 10 — Reporting and Analytics**: Generate periodic reports summarizing asset inventory, changes, trends, and risk metrics. Reports should include: total assets by type, new assets discovered, changes detected, certificate expiry warnings, and risk score distributions. Analytics identify patterns that inform testing strategy.

## Tool Arsenal

**Asset Database Manager**

```python
#!/usr/bin/env python3
"""SQLite-based asset tracking database."""
import sqlite3
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional

class AssetDatabase:
    def __init__(self, db_path: str = "./assets.db"):
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row
        self._create_tables()

    def _create_tables(self):
        cursor = self.conn.cursor()
        cursor.executescript("""
            CREATE TABLE IF NOT EXISTS assets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asset_type TEXT NOT NULL,
                asset_value TEXT NOT NULL,
                parent_id INTEGER,
                discovered_at TEXT NOT NULL,
                last_seen TEXT NOT NULL,
                first_seen TEXT NOT NULL,
                status TEXT DEFAULT 'active',
                metadata TEXT,
                FOREIGN KEY (parent_id) REFERENCES assets(id)
            );
            CREATE TABLE IF NOT EXISTS asset_changes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asset_id INTEGER NOT NULL,
                change_type TEXT NOT NULL,
                old_value TEXT,
                new_value TEXT,
                detected_at TEXT NOT NULL,
                FOREIGN KEY (asset_id) REFERENCES assets(id)
            );
            CREATE TABLE IF NOT EXISTS asset_scores (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asset_id INTEGER NOT NULL,
                score REAL NOT NULL,
                factors TEXT,
                scored_at TEXT NOT NULL,
                FOREIGN KEY (asset_id) REFERENCES assets(id)
            );
            CREATE TABLE IF NOT EXISTS certificates (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                asset_id INTEGER,
                domain TEXT NOT NULL,
                issuer TEXT,
                not_before TEXT,
                not_after TEXT,
                san TEXT,
                serial_number TEXT,
                key_algorithm TEXT,
                discovered_at TEXT NOT NULL,
                FOREIGN KEY (asset_id) REFERENCES assets(id)
            );
            CREATE INDEX IF NOT EXISTS idx_assets_type ON assets(asset_type);
            CREATE INDEX IF NOT EXISTS idx_assets_value ON assets(asset_value);
            CREATE INDEX IF NOT EXISTS idx_assets_parent ON assets(parent_id);
            CREATE INDEX IF NOT EXISTS idx_changes_asset ON asset_changes(asset_id);
            CREATE INDEX IF NOT EXISTS idx_changes_date ON asset_changes(detected_at);
            CREATE INDEX IF NOT EXISTS idx_certs_domain ON certificates(domain);
        """)
        self.conn.commit()

    def add_asset(self, asset_type: str, asset_value: str,
                  parent_id: int = None, metadata: dict = None) -> int:
        now = datetime.now().isoformat()
        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO assets (asset_type, asset_value, parent_id,
                              discovered_at, last_seen, first_seen, metadata)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (asset_type, asset_value, parent_id, now, now, now,
              json.dumps(metadata) if metadata else None))
        self.conn.commit()
        return cursor.lastrowid

    def update_last_seen(self, asset_id: int):
        now = datetime.now().isoformat()
        self.conn.execute(
            "UPDATE assets SET last_seen = ? WHERE id = ?",
            (now, asset_id)
        )
        self.conn.commit()

    def record_change(self, asset_id: int, change_type: str,
                     old_value: str = None, new_value: str = None):
        now = datetime.now().isoformat()
        self.conn.execute("""
            INSERT INTO asset_changes (asset_id, change_type, old_value,
                                      new_value, detected_at)
            VALUES (?, ?, ?, ?, ?)
        """, (asset_id, change_type, old_value, new_value, now))
        self.conn.commit()

    def get_asset_by_value(self, asset_value: str) -> Optional[dict]:
        cursor = self.conn.execute(
            "SELECT * FROM assets WHERE asset_value = ?",
            (asset_value,)
        )
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_all_assets(self, asset_type: str = None) -> List[dict]:
        if asset_type:
            cursor = self.conn.execute(
                "SELECT * FROM assets WHERE asset_type = ? ORDER BY discovered_at DESC",
                (asset_type,)
            )
        else:
            cursor = self.conn.execute(
                "SELECT * FROM assets ORDER BY asset_type, discovered_at DESC"
            )
        return [dict(row) for row in cursor.fetchall()]

    def get_asset_changes(self, asset_id: int = None, days: int = 30) -> List[dict]:
        query = """
            SELECT ac.*, a.asset_value, a.asset_type
            FROM asset_changes ac
            JOIN assets a ON ac.asset_id = a.id
            WHERE ac.detected_at >= datetime('now', ?)
        """
        params = [f'-{days} days']
        if asset_id:
            query += " AND ac.asset_id = ?"
            params.append(asset_id)
        query += " ORDER BY ac.detected_at DESC"
        cursor = self.conn.execute(query, params)
        return [dict(row) for row in cursor.fetchall()]

    def add_certificate(self, domain: str, issuer: str, not_before: str,
                       not_after: str, san: str = None, **kwargs):
        now = datetime.now().isoformat()
        self.conn.execute("""
            INSERT INTO certificates (domain, issuer, not_before, not_after,
                                     san, discovered_at, serial_number, key_algorithm)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (domain, issuer, not_before, not_after, san, now,
              kwargs.get('serial_number'), kwargs.get('key_algorithm')))
        self.conn.commit()

    def get_expiring_certificates(self, days: int = 30) -> List[dict]:
        cursor = self.conn.execute("""
            SELECT * FROM certificates
            WHERE not_after <= datetime('now', '+' || ? || ' days')
            AND not_after > datetime('now')
            ORDER BY not_after ASC
        """, (days,))
        return [dict(row) for row in cursor.fetchall()]

    def get_statistics(self) -> dict:
        stats = {}
        cursor = self.conn.execute(
            "SELECT asset_type, COUNT(*) as count FROM assets GROUP BY asset_type"
        )
        stats['by_type'] = {row['asset_type']: row['count'] for row in cursor.fetchall()}
        cursor = self.conn.execute("SELECT COUNT(*) as total FROM assets")
        stats['total'] = cursor.fetchone()['total']
        cursor = self.conn.execute(
            "SELECT COUNT(*) as count FROM assets WHERE status = 'active'"
        )
        stats['active'] = cursor.fetchone()['count']
        return stats

    def close(self):
        self.conn.close()

if __name__ == '__main__':
    db = AssetDatabase()
    # Example usage
    domain_id = db.add_asset('domain', 'target.com', metadata={'source': 'scope'})
    sub_id = db.add_asset('subdomain', 'api.target.com', parent_id=domain_id)
    db.add_asset('ip', '192.168.1.100', parent_id=sub_id)
    print(json.dumps(db.get_statistics(), indent=2))
    db.close()
```

**Asset Discovery Engine**

```python
#!/usr/bin/env python3
"""Automated asset discovery combining multiple techniques."""
import subprocess
import json
import socket
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime

class AssetDiscovery:
    def __init__(self, domain: str):
        self.domain = domain
        self.discovered = {
            'domains': set(),
            'subdomains': set(),
            'ips': set(),
            'certificates': []
        }

    def dns_enumeration(self):
        """Enumerate DNS records for the domain."""
        record_types = ['A', 'AAAA', 'MX', 'TXT', 'CNAME', 'NS']
        for rtype in record_types:
            try:
                result = subprocess.run(
                    ['dig', '+short', self.domain, rtype],
                    capture_output=True, text=True, timeout=10
                )
                for line in result.stdout.strip().split('\n'):
                    line = line.strip().rstrip('.')
                    if line:
                        if rtype in ('A', 'AAAA'):
                            self.discovered['ips'].add(line)
                        elif rtype == 'CNAME':
                            self.discovered['subdomains'].add(line)
            except Exception:
                continue

    def ct_log_query(self):
        """Query Certificate Transparency logs."""
        try:
            url = f"https://crt.sh/?q=%.{self.domain}&output=json"
            response = requests.get(url, timeout=30)
            if response.status_code == 200:
                certs = response.json()
                for cert in certs:
                    name_value = cert.get('name_value', '')
                    for name in name_value.split('\n'):
                        name = name.strip().lower()
                        if name.endswith(self.domain):
                            self.discovered['subdomains'].add(name)
                    self.discovered['certificates'].append({
                        'id': cert.get('id'),
                        'name': cert.get('name_value'),
                        'issuer': cert.get('issuer_name'),
                        'not_before': cert.get('not_before'),
                        'not_after': cert.get('not_after')
                    })
        except Exception as e:
            print(f"CT log query failed: {e}")

    def subdomain_bruteforce(self, wordlist: str, max_workers: int = 10):
        """Bruteforce subdomains using a wordlist."""
        with open(wordlist, 'r') as f:
            words = [line.strip() for line in f if line.strip()]

        def check(sub):
            fqdn = f"{sub}.{self.domain}"
            try:
                socket.setdefaulttimeout(3)
                ip = socket.gethostbyname(fqdn)
                return (fqdn, ip)
            except:
                return None

        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(check, w): w for w in words}
            for future in as_completed(futures):
                result = future.result()
                if result:
                    subdomain, ip = result
                    self.discovered['subdomains'].add(subdomain)
                    self.discovered['ips'].add(ip)
                    print(f"[+] {subdomain} -> {ip}")

    def web_service_detection(self, ports: list = None):
        """Detect web services on discovered IPs."""
        if ports is None:
            ports = [80, 443, 8080, 8443, 3000, 5000, 8000, 9000]

        for ip in list(self.discovered['ips'])[:50]:  # Limit for performance
            for port in ports:
                try:
                    protocol = 'https' if port in (443, 8443) else 'http'
                    url = f"{protocol}://{ip}:{port}"
                    response = requests.get(url, timeout=3, verify=False,
                                          allow_redirects=False)
                    self.discovered['domains'].add(f"{ip}:{port}")
                except:
                    pass

    def run_full_discovery(self) -> dict:
        """Execute complete asset discovery pipeline."""
        print(f"[*] Starting asset discovery for {self.domain}")
        print(f"[*] Time: {datetime.now().isoformat()}")

        print("[*] DNS enumeration...")
        self.dns_enumeration()

        print("[*] CT log query...")
        self.ct_log_query()

        print(f"[*] Results: {len(self.discovered['subdomains'])} subdomains, "
              f"{len(self.discovered['ips'])} IPs, "
              f"{len(self.discovered['certificates'])} certificates")

        return {
            'domain': self.domain,
            'scan_time': datetime.now().isoformat(),
            'subdomains': sorted(list(self.discovered['subdomains'])),
            'ips': sorted(list(self.discovered['ips'])),
            'certificates': self.discovered['certificates'],
            'summary': {
                'subdomain_count': len(self.discovered['subdomains']),
                'ip_count': len(self.discovered['ips']),
                'certificate_count': len(self.discovered['certificates'])
            }
        }

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python asset_discovery.py <domain>")
        sys.exit(1)
    discovery = AssetDiscovery(sys.argv[1])
    results = discovery.run_full_discovery()
    print(json.dumps(results['summary'], indent=2))
```

**Change Detection Monitor**

```python
#!/usr/bin/env python3
"""Monitor assets for changes and generate alerts."""
import json
import hashlib
from datetime import datetime
from pathlib import Path

class ChangeDetector:
    def __init__(self, baseline_file: str = "./baseline.json"):
        self.baseline_file = Path(baseline_file)
        self.baseline = self._load_baseline()

    def _load_baseline(self) -> dict:
        if self.baseline_file.exists():
            return json.loads(self.baseline_file.read_text())
        return {}

    def save_baseline(self, data: dict):
        self.baseline_file.write_text(json.dumps(data, indent=2))
        self.baseline = data

    def compute_hash(self, data: dict) -> str:
        return hashlib.sha256(json.dumps(data, sort_keys=True).encode()).hexdigest()

    def detect_changes(self, current: dict) -> dict:
        """Compare current state against baseline."""
        changes = {
            'timestamp': datetime.now().isoformat(),
            'new_assets': [],
            'removed_assets': [],
            'modified_assets': [],
            'total_changes': 0
        }

        baseline_subdomains = set(self.baseline.get('subdomains', []))
        current_subdomains = set(current.get('subdomains', []))

        changes['new_assets'] = sorted(list(current_subdomains - baseline_subdomains))
        changes['removed_assets'] = sorted(list(baseline_subdomains - current_subdomains))

        baseline_ips = set(self.baseline.get('ips', []))
        current_ips = set(current.get('ips', []))
        changes['new_ips'] = sorted(list(current_ips - baseline_ips))
        changes['removed_ips'] = sorted(list(baseline_ips - current_ips))

        # Check for DNS record changes
        baseline_dns = self.baseline.get('dns_records', {})
        current_dns = current.get('dns_records', {})
        for domain in set(list(baseline_dns.keys()) + list(current_dns.keys())):
            if baseline_dns.get(domain) != current_dns.get(domain):
                changes['modified_assets'].append({
                    'type': 'dns_change',
                    'domain': domain,
                    'old': baseline_dns.get(domain),
                    'new': current_dns.get(domain)
                })

        changes['total_changes'] = (
            len(changes['new_assets']) +
            len(changes['removed_assets']) +
            len(changes['new_ips']) +
            len(changes['removed_ips']) +
            len(changes['modified_assets'])
        )

        return changes

    def generate_alert(self, changes: dict) -> str:
        """Generate alert message from changes."""
        if changes['total_changes'] == 0:
            return None

        alert_lines = [
            f"Asset Change Alert — {changes['timestamp']}",
            f"Total Changes: {changes['total_changes']}",
            ""
        ]

        if changes['new_assets']:
            alert_lines.append(f"NEW SUBDOMAINS ({len(changes['new_assets'])}):")
            for asset in changes['new_assets'][:20]:
                alert_lines.append(f"  + {asset}")
            alert_lines.append("")

        if changes['removed_assets']:
            alert_lines.append(f"REMOVED SUBDOMAINS ({len(changes['removed_assets'])}):")
            for asset in changes['removed_assets'][:20]:
                alert_lines.append(f"  - {asset}")
            alert_lines.append("")

        if changes.get('new_ips'):
            alert_lines.append(f"NEW IPs ({len(changes['new_ips'])}):")
            for ip in changes['new_ips'][:20]:
                alert_lines.append(f"  + {ip}")

        return "\n".join(alert_lines)

if __name__ == '__main__':
    detector = ChangeDetector()
    # Example: load current state and detect changes
    current = {'subdomains': ['api.target.com', 'new.target.com'], 'ips': ['1.2.3.4']}
    changes = detector.detect_changes(current)
    alert = detector.generate_alert(changes)
    if alert:
        print(alert)
    else:
        print("No changes detected.")
```

**Certificate Expiry Monitor**

```python
#!/usr/bin/env python3
"""Monitor SSL/TLS certificate expiry dates."""
import requests
import json
import ssl
import socket
from datetime import datetime, timedelta
from typing import List, Dict

class CertExpiryMonitor:
    def __init__(self):
        self.results = []

    def check_certificate(self, domain: str, port: int = 443) -> dict:
        """Check certificate expiry for a domain."""
        try:
            context = ssl.create_default_context()
            with socket.create_connection((domain, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=domain) as ssock:
                    cert = ssock.getpeercert()

            not_after = datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y %Z')
            not_before = datetime.strptime(cert['notBefore'], '%b %d %H:%M:%S %Y %Z')
            days_until_expiry = (not_after - datetime.now()).days

            return {
                'domain': domain,
                'port': port,
                'issuer': dict(x[0] for x in cert.get('issuer', [])),
                'subject': dict(x[0] for x in cert.get('subject', [])),
                'not_before': not_before.isoformat(),
                'not_after': not_after.isoformat(),
                'days_until_expiry': days_until_expiry,
                'status': self._get_status(days_until_expiry),
                'san': self._extract_san(cert)
            }
        except Exception as e:
            return {
                'domain': domain,
                'port': port,
                'error': str(e),
                'status': 'error'
            }

    def _get_status(self, days: int) -> str:
        if days < 0: return 'expired'
        elif days < 7: return 'critical'
        elif days < 30: return 'warning'
        elif days < 90: return 'attention'
        else: return 'ok'

    def _extract_san(self, cert: dict) -> List[str]:
        san = cert.get('subjectAltName', [])
        return [entry[1] for entry in san]

    def monitor_batch(self, domains: List[str]) -> List[dict]:
        """Check certificates for multiple domains."""
        results = []
        for domain in domains:
            result = self.check_certificate(domain)
            results.append(result)
            self.results.append(result)
        return results

    def get_expiring_soon(self, days: int = 30) -> List[dict]:
        """Get certificates expiring within specified days."""
        return [r for r in self.results
                if r.get('days_until_expiry', 999) <= days
                and r.get('status') != 'error']

    def generate_report(self) -> dict:
        """Generate certificate monitoring report."""
        expiring_7 = self.get_expiring_soon(7)
        expiring_30 = self.get_expiring_soon(30)
        expired = [r for r in self.results if r.get('days_until_expiry', 999) < 0]

        return {
            'total_checked': len(self.results),
            'expired': len(expired),
            'expiring_7_days': len(expiring_7),
            'expiring_30_days': len(expiring_30),
            'healthy': len(self.results) - len(expired) - len(expiring_30),
            'details': self.results
        }

if __name__ == '__main__':
    monitor = CertExpiryMonitor()
    domains = ['google.com', 'github.com', 'example.com']
    results = monitor.monitor_batch(domains)
    report = monitor.generate_report()
    print(json.dumps(report, indent=2))
```

**Asset Dashboard (Flask)**

```python
#!/usr/bin/env python3
"""Web-based asset tracking dashboard."""
from flask import Flask, render_template_string, jsonify
import json

app = Flask(__name__)

DASHBOARD_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Asset Tracking Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; border-radius: 8px; padding: 20px; margin: 10px 0;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }
        .stat-card { text-align: center; padding: 20px; background: #e3f2fd;
                    border-radius: 8px; }
        .stat-number { font-size: 36px; font-weight: bold; color: #1565c0; }
        .stat-label { color: #666; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; border-bottom: 1px solid #eee; text-align: left; }
        th { background: #f5f5f5; font-weight: bold; }
        .status-active { color: #2e7d32; }
        .status-expired { color: #c62828; }
        .status-warning { color: #ef6c00; }
        h1 { color: #1565c0; }
        h2 { color: #333; border-bottom: 2px solid #1565c0; padding-bottom: 5px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Asset Tracking Dashboard</h1>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-number">{{ stats.total }}</div>
            <div class="stat-label">Total Assets</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">{{ stats.active }}</div>
            <div class="stat-label">Active</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">{{ stats.new_today }}</div>
            <div class="stat-label">New Today</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">{{ stats.changes }}</div>
            <div class="stat-label">Changes (7d)</div>
        </div>
    </div>

    <div class="card">
        <h2>Recent Assets</h2>
        <table>
            <tr><th>Type</th><th>Value</th><th>Discovered</th><th>Status</th></tr>
            {% for asset in assets %}
            <tr>
                <td>{{ asset.type }}</td>
                <td>{{ asset.value }}</td>
                <td>{{ asset.discovered }}</td>
                <td class="status-{{ asset.status }}">{{ asset.status }}</td>
            </tr>
            {% endfor %}
        </table>
    </div>

    <div class="card">
        <h2>Certificate Expiry</h2>
        <table>
            <tr><th>Domain</th><th>Issuer</th><th>Expires</th><th>Status</th></tr>
            {% for cert in certificates %}
            <tr>
                <td>{{ cert.domain }}</td>
                <td>{{ cert.issuer }}</td>
                <td>{{ cert.expires }}</td>
                <td class="status-{{ cert.status }}">{{ cert.status }}</td>
            </tr>
            {% endfor %}
        </table>
    </div>
</div>
</body>
</html>
"""

@app.route('/')
def dashboard():
    stats = {'total': 0, 'active': 0, 'new_today': 0, 'changes': 0}
    assets = []
    certificates = []
    return render_template_string(DASHBOARD_HTML,
                                stats=stats, assets=assets, certificates=certificates)

@app.route('/api/assets')
def api_assets():
    return jsonify([])

@app.route('/api/changes')
def api_changes():
    return jsonify([])

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

## Case Studies

**Case Study 1 — New Subdomain Discovery Leading to Staging Environment**

Asset tracking discovered a new subdomain `staging-api.target.com` that appeared in CT logs. The subdomain was not in the original scope but matched a wildcard rule. Investigation revealed it was a staging API server running an older version of the application with debug mode enabled. The staging environment exposed detailed error messages, stack traces, and an admin panel with default credentials. The asset tracking system's CT log monitoring enabled discovery before the organization realized the subdomain was publicly accessible.

**Case Study 2 — Certificate Expiry Monitoring Preventing Service Disruption**

The certificate monitoring system flagged an expiring certificate for `payments.target.com` with 7 days until expiry. The alert was escalated to the testing team, who notified the organization. The organization was unaware of the impending expiry because the certificate was managed by a third-party contractor. The early warning prevented a potential service disruption during the testing engagement.

**Case Study 3 — Infrastructure Migration Detection Through IP Changes**

Asset tracking detected IP address changes for multiple subdomains over a two-week period. Analysis of the change patterns revealed the organization was migrating infrastructure from on-premise servers to AWS. The migration created a window where both old and new infrastructure were accessible, potentially with different security configurations. The change detection enabled targeted testing of the new infrastructure before it was fully hardened.

**Case Study 4 — Technology Stack Change Detection**

Change monitoring detected that the target's main application switched from Apache to Nginx. The technology change was accompanied by a change in the server header and different behavior on certain endpoints. The asset tracking system's technology monitoring enabled the testing team to adjust their approach for the new server configuration.

**Case Study 5 — Shadow IT Discovery Through Certificate Transparency**

CT log monitoring discovered certificates for `*.internal.target.com` and `*.dev.target.com` that were not in the known asset inventory. Investigation revealed these were developer-created services using the target's domain for convenience. These shadow IT services had no security oversight and contained multiple vulnerabilities. The CT log monitoring was the only detection method for these assets.

## Bypass Techniques

**Subdomain Obfuscation**: Some organizations use non-standard subdomain naming conventions that are not caught by standard bruteforcing. Use CT logs, passive DNS, and historical data to discover these assets. Analyze job postings and developer blogs for hints about internal naming conventions.

**Cloud-Hosted Assets**: Cloud services (S3 buckets, Lambda functions, Azure Blob storage) may not appear in traditional DNS enumeration. Use cloud-specific enumeration techniques — S3 bucket naming conventions, Azure subdomain patterns, and GCP project naming.

**Dynamic DNS**: Dynamic DNS services create subdomains that change frequently. Monitor DNS records more frequently for dynamic DNS patterns. Use historical DNS to identify dynamic DNS usage.

## Advanced Techniques

**Asset Graph Database**: Store asset relationships in a graph database (Neo4j) to enable complex queries like "find all assets connected to this IP" or "identify the shortest path between two assets." Graph databases excel at relationship-heavy data like asset inventories.

**Machine Learning for Anomaly Detection**: Apply machine learning to asset change data to identify anomalous patterns. Anomaly detection can identify unusual new asset creation, unexpected DNS changes, or certificate anomalies that may indicate security incidents.

**Automated Asset Scoring**: Develop scoring algorithms that consider multiple factors — asset type, technology age, exposure level, historical findings, and business criticality. Automated scoring enables consistent prioritization across large asset inventories.

## Detection Indicators

Asset tracking systems should monitor for: rapid asset creation (potential infrastructure provisioning for attack), sudden DNS changes (potential DNS hijacking), certificate anomalies (potential man-in-the-middle), and technology stack changes (potential security configuration changes).

## Impact Assessment

**Discovery Rate**: Automated asset tracking typically discovers 30-50% more assets than manual enumeration. This increased coverage directly translates to more testing opportunities and better security assessment.

**Change Response Time**: Automated change detection reduces response time from days (manual discovery) to minutes (automated alerts). This enables rapid response to infrastructure changes that may affect security.

**Audit Trail**: Asset tracking provides a complete audit trail of infrastructure changes, which is valuable for compliance, incident response, and historical analysis.

## Common Pitfalls

1. **Database growth**: Asset databases can grow large over time — implement proper retention policies
2. **False positives in change detection**: Minor DNS changes (TTL adjustments) may trigger unnecessary alerts
3. **Missing cloud assets**: Traditional DNS enumeration misses cloud-hosted assets
4. **Certificate monitoring gaps**: Not all certificates are discovered through CT logs
5. **Data staleness**: Asset data becomes stale without regular re-enforcement scanning
6. **Relationship tracking complexity**: Asset relationships can be complex and difficult to maintain accurately

## Integration Points

- **Subfinder**: Subdomain discovery
- **Amass**: Attack surface mapping
- **crt.sh**: Certificate transparency logs
- **SecurityTrails**: Historical DNS data
- **Shodan**: Internet-connected device discovery
- **Censys**: Certificate and host discovery
- **Nmap**: Service detection and port scanning
- **httpx**: Web service detection
- **SQLite/PostgreSQL**: Asset database storage
- **Flask/Django**: Dashboard web framework
- **Grafana**: Advanced visualization
- **Slack/Discord**: Alert notifications

## Reporting Templates

**Asset Inventory Report**:
```markdown
# Asset Inventory Report — {{ domain }}
**Generated**: {{ date }}

## Summary
- Total Assets: {{ total }}
- Domains: {{ domains }}
- Subdomains: {{ subdomains }}
- IP Addresses: {{ ips }}
- Certificates: {{ certificates }}

## New Assets (Last 7 Days)
{{ new_assets }}

## Certificate Expiry Warnings
{{ cert_warnings }}

## Change History
{{ changes }}
```

## Practice Labs

1. **Database Setup**: Create an SQLite asset database with the provided schema
2. **Discovery Pipeline**: Run the complete asset discovery against example.com
3. **Change Detection**: Set up baseline comparison and change alerting
4. **Certificate Monitoring**: Build a certificate expiry monitoring system
5. **Dashboard**: Deploy the Flask dashboard and visualize asset data

## Ethics

Asset tracking must respect scope boundaries. Discovery activities should only target in-scope assets. When new assets are discovered, verify they are within scope before testing. Asset data is sensitive infrastructure information and must be stored securely. Do not share asset inventories outside the authorized testing team. Maintain records of all discovery activities for audit purposes.

## Quick Reference

**Asset Types**:
| Type | Discovery Method | Monitoring Frequency |
|------|-----------------|---------------------|
| Domain | Scope definition | Daily |
| Subdomain | DNS enum, CT logs | Daily |
| IP Address | DNS resolution | Daily |
| Certificate | CT logs, SSL check | Weekly |
| Web Service | HTTP probing | Weekly |
| Cloud Resource | Cloud enum | Weekly |

**Database Schema**:
```sql
-- Assets table
CREATE TABLE assets (
    id INTEGER PRIMARY KEY,
    asset_type TEXT,
    asset_value TEXT,
    parent_id INTEGER,
    discovered_at TEXT,
    last_seen TEXT,
    status TEXT,
    metadata TEXT
);

-- Changes table
CREATE TABLE asset_changes (
    id INTEGER PRIMARY KEY,
    asset_id INTEGER,
    change_type TEXT,
    old_value TEXT,
    new_value TEXT,
    detected_at TEXT
);
```

**Monitoring Commands**:
```bash
# Run asset discovery
python asset_discovery.py target.com

# Check certificate expiry
python cert_monitor.py target.com api.target.com

# Detect changes
python change_detector.py --baseline baseline.json --current current.json

# Generate dashboard
python dashboard.py
```
