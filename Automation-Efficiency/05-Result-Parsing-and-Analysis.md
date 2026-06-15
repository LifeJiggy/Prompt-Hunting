# Automation-Efficiency 5: Result Parsing and Analysis

## Expert Role

You are a Senior Security Data Analyst and Automation Engineer who specializes in transforming raw tool output into actionable intelligence. You have parsed millions of lines of scan results from nuclei, httpx, nmap, ffuf, subfinder, and dozens of other tools. You understand that the value of any security tool is only as good as the parsing and analysis layer that processes its output. You build systems that filter noise, correlate findings across tools, prioritize by severity and exploitability, and produce reports that drive action.

Your core belief: raw output is not intelligence. Intelligence is raw output that has been filtered, correlated, contextualized, and prioritized.

---

## Core Concepts

### What is Result Parsing and Analysis?

Result parsing and analysis is the process of converting raw, unstructured, or semi-structured tool output into structured, actionable data. It encompasses:

**1. Data Extraction**
- Parsing tool-specific output formats (JSON, JSONL, XML, CSV, plain text)
- Extracting relevant fields from verbose output
- Normalizing data across different tools

**2. Data Cleaning**
- Removing duplicates across tools
- Filtering false positives
- Handling malformed or incomplete data

**3. Data Enrichment**
- Adding context (geolocation, WHOIS, technology stack)
- Correlating findings across multiple tools
- Calculating risk scores

**4. Data Aggregation**
- Combining results from multiple scan runs
- Trend analysis over time
- Cross-tool correlation

**5. Data Presentation**
- Generating human-readable reports
- Creating dashboards
- Alerting on critical findings

### The Analysis Pipeline

```
[Raw Output] -> [Parse] -> [Clean] -> [Normalize] -> [Enrich] -> [Filter] -> [Correlate] -> [Prioritize] -> [Report]
     |              |          |           |            |           |            |              |              |
   nuclei        JSON       dedup      standardize   WHOIS     severity    cross-tool    CVSS/risk     markdown
   httpx         XML        filter     schema map    geoIP     threshold   matching      scoring       JSON/CSV
   nmap          CSV        sanitize   field map     tech      whitelist   grouping      ranking       HTML
```

### Output Format Standards

| Tool | Format | Key Fields |
|------|--------|------------|
| nuclei | JSONL | template-id, severity, host, matched-at, info |
| httpx | JSON | url, status_code, tech, content_length, title |
| nmap | XML | port, service, version, state, script output |
| ffuf | JSON | url, status, length, words, lines |
| subfinder | Plain text | one subdomain per line |
| masscan | XML | port, protocol, state, service |

### The Quality Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| False Positive Rate | % of findings that are not real vulnerabilities | < 5% |
| Deduplication Rate | % of results that are duplicates | > 30% |
| Coverage | % of target attack surface covered | > 90% |
| Enrichment Rate | % of findings with additional context | > 80% |
| Processing Speed | Findings processed per second | > 1000 |

---

## Prerequisites

### Required Knowledge
- Python 3.8+ (intermediate to advanced)
- JSON, XML, CSV parsing
- Regular expressions
- Data structures (sets, dicts, trees)
- Basic statistics for scoring

### Required Tools

```bash
# Python packages
pip install pydantic pyjq lxml
pip install pandas tabulate rich
pip install python-whois geoip2
pip install jinja2  # Report templates

# For XML parsing
pip install lxml defusedxml

# For data analysis
pip install pandas matplotlib
```

---

## Methodology

### Step 1: Build the Parser Registry

```python
# parsers/registry.py
"""Centralized parser registry for all tool outputs."""

import json
import csv
import xml.etree.ElementTree as ET
from typing import Any, Dict, List, Optional
from pathlib import Path
from dataclasses import dataclass
from enum import Enum


class OutputFormat(Enum):
    JSON = "json"
    JSONL = "jsonl"
    XML = "xml"
    CSV = "csv"
    TEXT = "text"


@dataclass
class ParsedFinding:
    """Normalized finding format from any tool."""
    tool: str
    title: str
    severity: str
    host: str
    matched_at: str = ""
    description: str = ""
    evidence: str = ""
    reference: List[str] = None
    tags: List[str] = None
    cvss_score: float = 0.0
    metadata: Dict[str, Any] = None

    def __post_init__(self):
        if self.reference is None:
            self.reference = []
        if self.tags is None:
            self.tags = []
        if self.metadata is None:
            self.metadata = {}

    def to_dict(self) -> dict:
        return {
            "tool": self.tool,
            "title": self.title,
            "severity": self.severity,
            "host": self.host,
            "matched_at": self.matched_at,
            "description": self.description,
            "evidence": self.evidence,
            "reference": self.reference,
            "tags": self.tags,
            "cvss_score": self.cvss_score,
            "metadata": self.metadata,
        }


class ParserRegistry:
    """Registry of parsers for different tool outputs."""

    def __init__(self):
        self._parsers = {}
        self._register_defaults()

    def _register_defaults(self):
        self.register("nuclei", NucleiParser())
        self.register("httpx", HttpxParser())
        self.register("ffuf", FfufParser())
        self.register("nmap", NmapParser())
        self.register("subfinder", SubfinderParser())
        self.register("linkfinder", LinkFinderParser())
        self.register("custom", GenericParser())

    def register(self, tool_name: str, parser):
        self._parsers[tool_name] = parser

    def parse(self, tool_name: str, raw_output: str,
              format: OutputFormat = None) -> List[ParsedFinding]:
        parser = self._parsers.get(tool_name, self._parsers["custom"])
        return parser.parse(raw_output, format)


class NucleiParser:
    """Parse nuclei JSONL output."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        findings = []
        for line in raw.strip().split("\n"):
            line = line.strip()
            if not line:
                continue
            try:
                data = json.loads(line)
                info = data.get("info", {})
                findings.append(ParsedFinding(
                    tool="nuclei",
                    title=info.get("name", data.get("template-id", "unknown")),
                    severity=info.get("severity", "info"),
                    host=data.get("host", ""),
                    matched_at=data.get("matched-at", ""),
                    description=info.get("description", ""),
                    evidence=data.get("extracted-results", [""])[0] if data.get("extracted-results") else "",
                    reference=info.get("reference", []),
                    tags=info.get("tags", []) if isinstance(info.get("tags"), list) else info.get("tags", "").split(","),
                    cvss_score=float(info.get("classification", {}).get("cvss-score", 0)),
                    metadata={
                        "template_id": data.get("template-id", ""),
                        "matcher_name": data.get("matcher-name", ""),
                        "type": data.get("type", ""),
                    }
                ))
            except (json.JSONDecodeError, KeyError):
                continue
        return findings


class HttpxParser:
    """Parse httpx JSON output."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        findings = []
        for line in raw.strip().split("\n"):
            line = line.strip()
            if not line:
                continue
            try:
                data = json.loads(line)
                findings.append(ParsedFinding(
                    tool="httpx",
                    title=f"HTTP service: {data.get('url', '')}",
                    severity="info",
                    host=data.get("url", ""),
                    matched_at=data.get("url", ""),
                    description=f"Status: {data.get('status_code', 'N/A')}, "
                                f"Tech: {', '.join(data.get('tech', []))}",
                    metadata={
                        "status_code": data.get("status_code"),
                        "content_length": data.get("content_length"),
                        "title": data.get("title"),
                        "tech": data.get("tech", []),
                        "webserver": data.get("webserver", ""),
                        "response_time": data.get("response_time", ""),
                    }
                ))
            except (json.JSONDecodeError, KeyError):
                continue
        return findings


class FfufParser:
    """Parse ffuf JSON output."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        findings = []
        try:
            data = json.loads(raw)
            for result in data.get("results", []):
                findings.append(ParsedFinding(
                    tool="ffuf",
                    title=f"Endpoint discovered: {result.get('input', {}).get('FUZZ', '')}",
                    severity="info",
                    host=result.get("url", ""),
                    matched_at=result.get("url", ""),
                    description=f"Status: {result.get('status')}, "
                                f"Length: {result.get('length')}, "
                                f"Words: {result.get('words')}",
                    metadata={
                        "status": result.get("status"),
                        "length": result.get("length"),
                        "words": result.get("words"),
                        "lines": result.get("lines"),
                    }
                ))
        except json.JSONDecodeError:
            pass
        return findings


class NmapParser:
    """Parse nmap XML output."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        findings = []
        try:
            root = ET.fromstring(raw)
            for host in root.findall(".//host"):
                addr = host.find("address")
                ip = addr.get("addr", "") if addr is not None else ""

                for port in host.findall(".//port"):
                    port_id = port.get("portid", "")
                    protocol = port.get("protocol", "")
                    state_el = port.find("state")
                    state = state_el.get("state", "") if state_el is not None else ""

                    service_el = port.find("service")
                    service_name = service_el.get("name", "") if service_el is not None else ""
                    service_version = service_el.get("version", "") if service_el is not None else ""

                    severity = "info"
                    if service_name in ("http", "https"):
                        severity = "low"

                    findings.append(ParsedFinding(
                        tool="nmap",
                        title=f"Open port: {port_id}/{protocol} ({service_name})",
                        severity=severity,
                        host=ip,
                        matched_at=f"{ip}:{port_id}",
                        description=f"Service: {service_name} {service_version}",
                        metadata={
                            "port": int(port_id) if port_id.isdigit() else 0,
                            "protocol": protocol,
                            "state": state,
                            "service": service_name,
                            "version": service_version,
                        }
                    ))
        except ET.ParseError:
            pass
        return findings


class SubfinderParser:
    """Parse subfinder text output (one subdomain per line)."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        findings = []
        for line in raw.strip().split("\n"):
            subdomain = line.strip()
            if subdomain and not subdomain.startswith("#"):
                findings.append(ParsedFinding(
                    tool="subfinder",
                    title=f"Subdomain discovered: {subdomain}",
                    severity="info",
                    host=subdomain,
                    matched_at=subdomain,
                ))
        return findings


class LinkFinderParser:
    """Parse LinkFinder JSON output."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        findings = []
        try:
            data = json.loads(raw)
            for entry in data:
                findings.append(ParsedFinding(
                    tool="linkfinder",
                    title=f"JS endpoint: {entry.get('link', '')}",
                    severity="info",
                    host=entry.get("source", ""),
                    matched_at=entry.get("link", ""),
                    description=f"Type: {entry.get('type', '')}",
                    metadata={
                        "type": entry.get("type", ""),
                        "source": entry.get("source", ""),
                    }
                ))
        except json.JSONDecodeError:
            pass
        return findings


class GenericParser:
    """Generic parser for unknown tool formats."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        if fmt == OutputFormat.JSON:
            return self._parse_json(raw)
        elif fmt == OutputFormat.JSONL:
            return self._parse_jsonl(raw)
        elif fmt == OutputFormat.XML:
            return self._parse_xml(raw)
        elif fmt == OutputFormat.CSV:
            return self._parse_csv(raw)
        return self._parse_text(raw)

    def _parse_json(self, raw: str) -> List[ParsedFinding]:
        try:
            data = json.loads(raw)
            if isinstance(data, list):
                return [self._dict_to_finding(d) for d in data]
            return [self._dict_to_finding(data)]
        except json.JSONDecodeError:
            return []

    def _parse_jsonl(self, raw: str) -> List[ParsedFinding]:
        findings = []
        for line in raw.strip().split("\n"):
            if line.strip():
                try:
                    data = json.loads(line)
                    findings.append(self._dict_to_finding(data))
                except json.JSONDecodeError:
                    continue
        return findings

    def _parse_xml(self, raw: str) -> List[ParsedFinding]:
        try:
            root = ET.fromstring(raw)
            return [self._dict_to_finding(self._elem_to_dict(el)) for el in root]
        except ET.ParseError:
            return []

    def _parse_csv(self, raw: str) -> List[ParsedFinding]:
        reader = csv.DictReader(raw.strip().split("\n"))
        return [self._dict_to_finding(row) for row in reader]

    def _parse_text(self, raw: str) -> List[ParsedFinding]:
        return [ParsedFinding(
            tool="unknown", title=raw[:100], severity="info", host=""
        )]

    def _dict_to_finding(self, d: dict) -> ParsedFinding:
        return ParsedFinding(
            tool=d.get("tool", "unknown"),
            title=d.get("title", d.get("name", str(d)[:100])),
            severity=d.get("severity", "info"),
            host=d.get("host", d.get("url", "")),
            matched_at=d.get("matched_at", d.get("matched-at", "")),
            description=d.get("description", ""),
            metadata=d,
        )

    def _elem_to_dict(self, elem) -> dict:
        result = dict(elem.attrib)
        for child in elem:
            result[child.tag] = self._elem_to_dict(child)
        result["text"] = (elem.text or "").strip()
        return result
```

### Step 2: Deduplication and Cleaning

```python
# analysis/cleaner.py
"""Deduplication and data cleaning for parsed findings."""

import hashlib
import re
from typing import List, Dict, Set, Tuple
from urllib.parse import urlparse
from parsers.registry import ParsedFinding


class FindingCleaner:
    """Clean and deduplicate parsed findings."""

    def __init__(self):
        self._seen_hashes: Set[str] = set()

    def deduplicate(self, findings: List[ParsedFinding]) -> List[ParsedFinding]:
        """Remove duplicate findings."""
        unique = []
        for finding in findings:
            key = self._fingerprint(finding)
            if key not in self._seen_hashes:
                self._seen_hashes.add(key)
                unique.append(finding)
        return unique

    def _fingerprint(self, finding: ParsedFinding) -> str:
        """Generate a unique fingerprint for a finding."""
        data = f"{finding.tool}:{finding.title}:{finding.host}:{finding.matched_at}"
        return hashlib.md5(data.encode()).hexdigest()

    def normalize_host(self, host: str) -> str:
        """Normalize host format."""
        host = host.strip().lower()
        if host.startswith("http://"):
            host = host[7:]
        elif host.startswith("https://"):
            host = host[8:]
        host = host.rstrip("/")
        return host

    def filter_in_scope(self, findings: List[ParsedFinding],
                        scope: List[str]) -> List[ParsedFinding]:
        """Filter findings to only include in-scope targets."""
        import fnmatch
        return [
            f for f in findings
            if any(fnmatch.fnmatch(f.host, pattern) for pattern in scope)
        ]

    def filter_by_severity(self, findings: List[ParsedFinding],
                           min_severity: str = "info") -> List[ParsedFinding]:
        """Filter findings by minimum severity level."""
        severity_order = {
            "info": 0, "low": 1, "medium": 2, "high": 3, "critical": 4
        }
        min_level = severity_order.get(min_severity, 0)
        return [
            f for f in findings
            if severity_order.get(f.severity, 0) >= min_level
        ]

    def remove_false_positives(self, findings: List[ParsedFinding]) -> List[ParsedFinding]:
        """Apply common false positive filters."""
        filtered = []
        for finding in findings:
            if self._is_likely_false_positive(finding):
                continue
            filtered.append(finding)
        return filtered

    def _is_likely_false_positive(self, finding: ParsedFinding) -> bool:
        """Check if a finding is likely a false positive."""
        # Common false positive patterns
        fp_patterns = [
            r"(?i)access denied",
            r"(?i)not found",
            r"(?i)forbidden",
            r"(?i)unauthorized",
            r"403\.css",
            r"404\.css",
            r"favicon\.ico",
            r"robots\.txt.*disallow",
        ]
        for pattern in fp_patterns:
            if re.search(pattern, finding.description + finding.matched_at):
                return True
        return False

    def merge_tool_results(self, *result_lists) -> List[ParsedFinding]:
        """Merge results from multiple tools, deduplicating."""
        all_findings = []
        for result_list in result_lists:
            all_findings.extend(result_list)
        return self.deduplicate(all_findings)
```

### Step 3: Cross-Tool Correlation

```python
# analysis/correlator.py
"""Cross-tool correlation engine."""

from typing import List, Dict, Set, Tuple, Optional
from collections import defaultdict
from parsers.registry import ParsedFinding
from dataclasses import dataclass


@dataclass
class CorrelatedFinding:
    """A finding enriched with cross-tool data."""
    primary: ParsedFinding
    supporting: List[ParsedFinding]
    confidence: float
    attack_surface: str
    exploitability_score: float

    def to_dict(self) -> dict:
        return {
            "primary": self.primary.to_dict(),
            "supporting": [s.to_dict() for s in self.supporting],
            "confidence": self.confidence,
            "attack_surface": self.attack_surface,
            "exploitability_score": self.exploitability_score,
        }


class FindingCorrelator:
    """Correlate findings across multiple tools."""

    def __init__(self):
        self.correlations: List[CorrelatedFinding] = []

    def correlate(self, findings: List[ParsedFinding]) -> List[CorrelatedFinding]:
        """Find correlations across tool results."""
        # Group by host
        by_host = defaultdict(list)
        for f in findings:
            host = f.host.rstrip("/")
            by_host[host].append(f)

        correlated = []
        for host, host_findings in by_host.items():
            # Find nuclei vulns for this host
            vulns = [f for f in host_findings if f.tool == "nuclei"]

            for vuln in vulns:
                supporting = [
                    f for f in host_findings
                    if f.tool != "nuclei" and self._supports(vuln, f)
                ]
                confidence = self._calculate_confidence(vuln, supporting)
                exploitability = self._calculate_exploitability(vuln, supporting)

                correlated.append(CorrelatedFinding(
                    primary=vuln,
                    supporting=supporting,
                    confidence=confidence,
                    attack_surface=self._classify_surface(vuln, supporting),
                    exploitability_score=exploitability,
                ))

        self.correlations = sorted(
            correlated,
            key=lambda c: c.exploitability_score,
            reverse=True
        )
        return self.correlations

    def _supports(self, vuln: ParsedFinding, other: ParsedFinding) -> bool:
        """Check if 'other' finding supports the vulnerability."""
        vuln_host = vuln.host.rstrip("/")
        other_host = other.host.rstrip("/")

        # Same host or subdomain match
        if not (other_host == vuln_host or other_host.endswith(f".{vuln_host}")):
            return False

        # Supporting tool types
        supporting_tools = {"httpx", "nmap", "ffuf", "linkfinder"}
        return other.tool in supporting_tools

    def _calculate_confidence(self, vuln: ParsedFinding,
                              supporting: List[ParsedFinding]) -> float:
        """Calculate confidence score based on supporting evidence."""
        base = 0.5  # Base confidence for any nuclei finding

        # Boost for multiple tools confirming
        tools = set(f.tool for f in supporting)
        base += len(tools) * 0.1

        # Boost for high severity
        severity_boost = {
            "critical": 0.2, "high": 0.15, "medium": 0.1,
            "low": 0.05, "info": 0
        }
        base += severity_boost.get(vuln.severity, 0)

        # Boost for open ports / live hosts
        if any(f.tool == "nmap" and f.metadata.get("state") == "open"
               for f in supporting):
            base += 0.1

        return min(base, 1.0)

    def _calculate_exploitability(self, vuln: ParsedFinding,
                                  supporting: List[ParsedFinding]) -> float:
        """Calculate exploitability score."""
        score = 0.0

        # Severity contribution
        severity_scores = {
            "critical": 10, "high": 8, "medium": 5, "low": 2, "info": 0
        }
        score += severity_scores.get(vuln.severity, 0)

        # CVSS score contribution
        if vuln.cvss_score > 0:
            score += vuln.cvss_score * 2

        # Supporting evidence contribution
        tools = set(f.tool for f in supporting)
        if "nmap" in tools:
            score += 1  # Network confirmed
        if "httpx" in tools:
            score += 1  # Web service confirmed
        if "ffuf" in tools:
            score += 0.5  # Endpoint confirmed

        return min(score, 20.0)

    def _classify_surface(self, vuln: ParsedFinding,
                          supporting: List[ParsedFinding]) -> str:
        """Classify the attack surface."""
        tools = set(f.tool for f in supporting)
        vuln_tags = set(vuln.tags)

        if any(t in vuln_tags for t in ["xss", "sqli", "ssrf", "ssti"]):
            return "web"
        if any(t in vuln_tags for t in ["cve", "rce", "lfi"]):
            return "application"
        if "nmap" in tools:
            return "network"
        if "httpx" in tools:
            return "web"
        return "unknown"
```

### Step 4: Risk Scoring and Prioritization

```python
# analysis/scorer.py
"""Risk scoring and prioritization engine."""

from typing import List, Dict
from parsers.registry import ParsedFinding
from analysis.correlator import CorrelatedFinding
from dataclasses import dataclass


@dataclass
class ScoredFinding:
    """Finding with calculated risk score."""
    finding: CorrelatedFinding
    risk_score: float
    priority: str
    reasoning: str

    def to_dict(self) -> dict:
        return {
            "finding": self.finding.to_dict(),
            "risk_score": self.risk_score,
            "priority": self.priority,
            "reasoning": self.reasoning,
        }


class RiskScorer:
    """Calculate risk scores and prioritize findings."""

    def score_findings(self, correlated: List[CorrelatedFinding]) -> List[ScoredFinding]:
        """Score and prioritize all correlated findings."""
        scored = []
        for c in correlated:
            score, reasoning = self._calculate_risk(c)
            priority = self._score_to_priority(score)
            scored.append(ScoredFinding(
                finding=c,
                risk_score=score,
                priority=priority,
                reasoning=reasoning,
            ))

        return sorted(scored, key=lambda s: s.risk_score, reverse=True)

    def _calculate_risk(self, correlated: CorrelatedFinding) -> tuple:
        """Calculate composite risk score."""
        score = 0.0
        reasons = []

        # 1. Severity (0-4 points)
        severity_scores = {
            "critical": 4, "high": 3, "medium": 2, "low": 1, "info": 0
        }
        sev = severity_scores.get(correlated.primary.severity, 0)
        score += sev
        if sev >= 3:
            reasons.append(f"High severity ({correlated.primary.severity})")

        # 2. CVSS score (0-10 points, normalized)
        if correlated.primary.cvss_score > 0:
            score += min(correlated.primary.cvss_score, 10)
            if correlated.primary.cvss_score >= 7:
                reasons.append(f"High CVSS ({correlated.primary.cvss_score})")

        # 3. Exploitability (0-5 points)
        score += min(correlated.exploitability_score, 5)
        if correlated.exploitability_score > 5:
            reasons.append("High exploitability")

        # 4. Confidence (0-3 points)
        score += correlated.confidence * 3
        if correlated.confidence > 0.8:
            reasons.append("High confidence (multi-tool validation)")

        # 5. Attack surface (0-2 points)
        surface_scores = {"web": 2, "application": 2, "network": 1, "unknown": 0}
        score += surface_scores.get(correlated.attack_surface, 0)

        # 6. Has exploit references (0-2 points)
        if correlated.primary.reference:
            score += 2
            reasons.append("Has exploit references")

        # 7. Supporting evidence count (0-1 point)
        if len(correlated.supporting) >= 3:
            score += 1
            reasons.append("Multiple supporting tools")

        reasoning = "; ".join(reasons) if reasons else "Low risk"
        return round(score, 2), reasoning

    def _score_to_priority(self, score: float) -> str:
        if score >= 15:
            return "critical"
        elif score >= 10:
            return "high"
        elif score >= 5:
            return "medium"
        elif score >= 2:
            return "low"
        return "info"
```

### Step 5: Report Generator

```python
# analysis/reporter.py
"""Report generation from analyzed findings."""

import json
from datetime import datetime
from typing import List, Dict, Optional
from pathlib import Path
from analysis.scorer import ScoredFinding


class ReportGenerator:
    """Generate reports from scored findings."""

    def __init__(self, output_dir: str = "./reports"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def generate_json_report(self, scored: List[ScoredFinding],
                             target: str, filename: str = None) -> str:
        """Generate JSON report."""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"report_{target}_{timestamp}.json"

        report = {
            "target": target,
            "generated_at": datetime.now().isoformat(),
            "summary": self._build_summary(scored),
            "findings": [s.to_dict() for s in scored],
        }

        path = self.output_dir / filename
        with open(path, "w") as f:
            json.dump(report, f, indent=2, default=str)
        return str(path)

    def generate_markdown_report(self, scored: List[ScoredFinding],
                                 target: str, filename: str = None) -> str:
        """Generate Markdown report."""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"report_{target}_{timestamp}.md"

        summary = self._build_summary(scored)
        lines = [
            f"# Security Assessment Report",
            f"",
            f"## Target: {target}",
            f"## Generated: {datetime.now().isoformat()}",
            f"",
            f"## Executive Summary",
            f"",
            f"| Metric | Value |",
            f"|--------|-------|",
            f"| Total Findings | {summary['total']} |",
            f"| Critical | {summary['critical']} |",
            f"| High | {summary['high']} |",
            f"| Medium | {summary['medium']} |",
            f"| Low | {summary['low']} |",
            f"| Avg Risk Score | {summary['avg_risk_score']:.1f} |",
            f"",
            f"## Findings by Priority",
            f"",
        ]

        for priority in ["critical", "high", "medium", "low", "info"]:
            findings = [s for s in scored if s.priority == priority]
            if findings:
                lines.append(f"### {priority.upper()} ({len(findings)})")
                lines.append("")
                for s in findings:
                    f = s.finding.primary
                    lines.append(f"#### {f.title}")
                    lines.append(f"- **Risk Score**: {s.risk_score}")
                    lines.append(f"- **Host**: {f.host}")
                    lines.append(f"- **Tool**: {f.tool}")
                    lines.append(f"- **Reasoning**: {s.reasoning}")
                    if f.description:
                        lines.append(f"- **Description**: {f.description}")
                    if s.finding.supporting:
                        tools = set(x.tool for x in s.finding.supporting)
                        lines.append(f"- **Supporting Tools**: {', '.join(tools)}")
                    lines.append("")

        path = self.output_dir / filename
        with open(path, "w") as f:
            f.write("\n".join(lines))
        return str(path)

    def generate_csv_report(self, scored: List[ScoredFinding],
                            target: str, filename: str = None) -> str:
        """Generate CSV report."""
        import csv
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"report_{target}_{timestamp}.csv"

        path = self.output_dir / filename
        with open(path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow([
                "Priority", "Risk Score", "Title", "Severity",
                "Host", "Tool", "CVSS", "Reasoning"
            ])
            for s in scored:
                writer.writerow([
                    s.priority, s.risk_score, s.finding.primary.title,
                    s.finding.primary.severity, s.finding.primary.host,
                    s.finding.primary.tool, s.finding.primary.cvss_score,
                    s.reasoning,
                ])
        return str(path)

    def _build_summary(self, scored: List[ScoredFinding]) -> Dict:
        if not scored:
            return {"total": 0, "critical": 0, "high": 0, "medium": 0,
                    "low": 0, "info": 0, "avg_risk_score": 0}

        return {
            "total": len(scored),
            "critical": sum(1 for s in scored if s.priority == "critical"),
            "high": sum(1 for s in scored if s.priority == "high"),
            "medium": sum(1 for s in scored if s.priority == "medium"),
            "low": sum(1 for s in scored if s.priority == "low"),
            "info": sum(1 for s in scored if s.priority == "info"),
            "avg_risk_score": sum(s.risk_score for s in scored) / len(scored),
        }
```

### Step 6: Analysis Pipeline Orchestrator

```python
# analysis/pipeline.py
"""Complete analysis pipeline from raw output to report."""

import json
from pathlib import Path
from typing import Dict, List
from parsers.registry import ParserRegistry, ParsedFinding
from analysis.cleaner import FindingCleaner
from analysis.correlator import FindingCorrelator
from analysis.scorer import RiskScorer
from analysis.reporter import ReportGenerator


class AnalysisPipeline:
    """End-to-end analysis pipeline."""

    def __init__(self, output_dir: str = "./reports"):
        self.parser = ParserRegistry()
        self.cleaner = FindingCleaner()
        self.correlator = FindingCorrelator()
        self.scorer = RiskScorer()
        self.reporter = ReportGenerator(output_dir)

    def analyze(self, tool_outputs: Dict[str, str],
                target: str, scope: List[str] = None) -> Dict:
        """Run complete analysis pipeline."""
        # Step 1: Parse all tool outputs
        all_findings = []
        for tool_name, raw_output in tool_outputs.items():
            findings = self.parser.parse(tool_name, raw_output)
            all_findings.extend(findings)
            print(f"  [parse] {tool_name}: {len(findings)} findings")

        # Step 2: Clean and deduplicate
        cleaned = self.cleaner.deduplicate(all_findings)
        print(f"  [clean] {len(all_findings)} -> {len(cleaned)} (removed {len(all_findings) - len(cleaned)} duplicates)")

        # Step 3: Filter by scope
        if scope:
            cleaned = self.cleaner.filter_in_scope(cleaned, scope)
            print(f"  [scope] {len(cleaned)} findings in scope")

        # Step 4: Remove false positives
        cleaned = self.cleaner.remove_false_positives(cleaned)
        print(f"  [fp] {len(cleaned)} findings after FP removal")

        # Step 5: Correlate across tools
        correlated = self.correlator.correlate(cleaned)
        print(f"  [correlate] {len(correlated)} correlated findings")

        # Step 6: Score and prioritize
        scored = self.scorer.score_findings(correlated)
        print(f"  [score] {len(scored)} scored findings")

        # Step 7: Generate reports
        json_path = self.reporter.generate_json_report(scored, target)
        md_path = self.reporter.generate_markdown_report(scored, target)
        csv_path = self.reporter.generate_csv_report(scored, target)

        return {
            "target": target,
            "total_raw": sum(len(v) for v in tool_outputs.values()),
            "total_parsed": len(all_findings),
            "total_cleaned": len(cleaned),
            "total_correlated": len(correlated),
            "total_scored": len(scored),
            "reports": {
                "json": json_path,
                "markdown": md_path,
                "csv": csv_path,
            },
            "summary": self.reporter._build_summary(scored),
        }


# Usage
if __name__ == "__main__":
    # Load tool outputs
    tool_outputs = {}
    output_dir = Path("./tool_outputs")
    for f in output_dir.glob("*.json"):
        tool_name = f.stem.split("_")[0]
        tool_outputs[tool_name] = f.read_text()

    pipeline = AnalysisPipeline()
    result = pipeline.analyze(
        tool_outputs=tool_outputs,
        target="example.com",
        scope=["*.example.com", "example.com"]
    )
    print(json.dumps(result, indent=2))
```

---

## Tool Arsenal

### Python Analysis Packages

```bash
# Data processing
pip install pandas tabulate
pip install pydantic jsonschema

# XML/JSON parsing
pip install lxml defusedxml jq

# Visualization
pip install matplotlib seaborn plotly

# Report generation
pip install jinja2 weasyprint

# Statistics
pip install scipy numpy
```

### Quick Commands

```bash
# Parse nuclei output
cat nuclei_results.jsonl | python -c "
import sys, json
for line in sys.stdin:
    d = json.loads(line)
    print(f\"{d['info']['severity']:10s} {d['host']} {d['info']['name']}\")
"

# Count findings by severity
cat results.jsonl | python -c "
import sys, json
from collections import Counter
severities = Counter()
for line in sys.stdin:
    d = json.loads(line)
    severities[d.get('info', {}).get('severity', 'unknown')] += 1
for sev, count in severities.most_common():
    print(f'{sev:12s}: {count}')
"

# Filter high-severity only
cat results.jsonl | python -c "
import sys, json
for line in sys.stdin:
    d = json.loads(line)
    if d.get('info', {}).get('severity') in ('high', 'critical'):
        print(line.strip())
" > high_severity.jsonl
```

---

## Real-World Examples

### Example 1: Multi-Tool Result Aggregation

```python
# examples/multi_tool_analysis.py
"""Analyze results from multiple recon tools."""

from analysis.pipeline import AnalysisPipeline

# Simulate tool outputs
nuclei_output = '''
{"template-id":"xss-reflected","info":{"name":"Reflected XSS","severity":"high","description":"Reflected XSS vulnerability"},"host":"https://example.com/search","matched-at":"https://example.com/search?q=test","type":"http"}
{"template-id":"sqli-error","info":{"name":"SQL Injection","severity":"critical","description":"Error-based SQL injection"},"host":"https://example.com/api/users","matched-at":"https://example.com/api/users?id=1","type":"http"}
'''

httpx_output = '''
{"url":"https://example.com","status_code":200,"tech":["nginx","php"],"title":"Example Site","content_length":1234}
{"url":"https://example.com/api","status_code":200,"tech":["nginx","node.js"],"title":"API","content_length":567}
{"url":"https://example.com/search","status_code":200,"tech":["nginx","php"],"title":"Search","content_length":890}
'''

ffuf_output = '''
{"commandline":"ffuf -u https://example.com/FUZZ -w wordlist.txt","results":[{"url":"https://example.com/admin","status":200,"length":5678},{"url":"https://example.com/api/v1","status":200,"length":123}]}
'''

# Run analysis
pipeline = AnalysisPipeline(output_dir="./reports")
result = pipeline.analyze(
    tool_outputs={
        "nuclei": nuclei_output,
        "httpx": httpx_output,
        "ffuf": ffuf_output,
    },
    target="example.com",
    scope=["*.example.com", "example.com"]
)

print(f"\nAnalysis complete:")
print(f"  Raw findings: {result['total_raw']}")
print(f"  After cleaning: {result['total_cleaned']}")
print(f"  Correlated: {result['total_correlated']}")
print(f"  Scored: {result['total_scored']}")
print(f"\nReports generated:")
for fmt, path in result['reports'].items():
    print(f"  {fmt}: {path}")
```

### Example 2: Custom Parser for Non-Standard Output

```python
# examples/custom_parser.py
"""Parse non-standard tool output."""

from parsers.registry import ParserRegistry, ParsedFinding, OutputFormat


class CustomNiktoParser:
    """Parser for nikto text output."""

    def parse(self, raw: str, fmt: OutputFormat = None) -> List[ParsedFinding]:
        findings = []
        for line in raw.split("\n"):
            if line.startswith("+ ") and "OSVDB" in line:
                # Extract OSVDB ID and description
                parts = line.split(": ", 2)
                if len(parts) >= 3:
                    findings.append(ParsedFinding(
                        tool="nikto",
                        title=parts[1].strip(),
                        severity="medium",
                        host="",
                        description=parts[2].strip(),
                        reference=[f"OSVDB-{parts[0].replace('+ ', '')}"]
                    ))
        return findings


# Register custom parser
registry = ParserRegistry()
registry.register("nikto", CustomNiktoParser())
```

---

## Common Pitfalls

### Pitfall 1: Not Handling Malformed JSON
**Problem:** Tools sometimes produce invalid JSON (truncated, extra output).
**Solution:** Wrap all JSON parsing in try/except. Validate schema. Skip malformed lines.

### Pitfall 2: Case-Sensitive Deduplication
**Problem:** `Example.com` and `example.com` treated as different hosts.
**Solution:** Normalize all hostnames to lowercase before deduplication.

### Pitfall 3: Ignoring Tool Version Differences
**Problem:** Output format changes between tool versions.
**Solution:** Version-tag your outputs. Add version detection to parsers.

### Pitfall 4: Not Filtering False Positives
**Problem:** Report full of noise obscures real findings.
**Solution:** Implement FP patterns. Filter common non-vulnerable responses (403, 404).

### Pitfall 5: Storing All Results in Memory
**Problem:** Large scans exhaust memory.
**Solution:** Use streaming/generators. Write intermediate results to disk.

### Pitfall 6: No Cross-Tool Correlation
**Problem:** Each tool's results analyzed in isolation.
**Solution:** Correlate findings by host, port, and URL to build complete picture.

### Pitfall 7: Ignoring Temporal Context
**Problem:** Old results mixed with new, stale findings reported.
**Solution:** Timestamp all findings. Filter by scan date. Track changes over time.

---

## Advanced Techniques

### 1. Change Detection Between Scans

```python
class ChangeDetector:
    """Detect changes between scan runs."""

    def __init__(self, history_dir: str = "./scan_history"):
        self.history_dir = Path(history_dir)

    def detect_changes(self, current: List[ParsedFinding],
                       target: str) -> Dict:
        history_path = self.history_dir / f"{target}_latest.json"
        if not history_path.exists():
            self._save(current, target)
            return {"status": "baseline", "new_findings": len(current)}

        previous = self._load(target)
        prev_set = {f.to_dict().get("title", "") + f.host for f in previous}
        curr_set = {f.to_dict().get("title", "") + f.host for f in current}

        new = curr_set - prev_set
        removed = prev_set - curr_set

        self._save(current, target)
        return {
            "status": "changes_detected",
            "new_findings": len(new),
            "removed_findings": len(removed),
            "new": [f for f in current if f.to_dict().get("title", "") + f.host in new],
            "removed": [f for f in previous if f.to_dict().get("title", "") + f.host in removed],
        }

    def _save(self, findings, target):
        self.history_dir.mkdir(parents=True, exist_ok=True)
        path = self.history_dir / f"{target}_latest.json"
        with open(path, "w") as f:
            json.dump([f.to_dict() for f in findings], f, indent=2)

    def _load(self, target) -> List[ParsedFinding]:
        path = self.history_dir / f"{target}_latest.json"
        with open(path) as f:
            data = json.load(f)
        return [ParsedFinding(**d) for d in data]
```

### 2. Trend Analysis

```python
class TrendAnalyzer:
    """Analyze security trends over time."""

    def __init__(self, history_dir: str = "./scan_history"):
        self.history_dir = Path(history_dir)

    def get_severity_trend(self, target: str) -> List[Dict]:
        """Get severity distribution over time."""
        scans = sorted(self.history_dir.glob(f"{target}_*.json"))
        trend = []
        for scan_file in scans:
            with open(scan_file) as f:
                findings = json.load(f)
            severity_count = {}
            for f in findings:
                sev = f.get("severity", "info")
                severity_count[sev] = severity_count.get(sev, 0) + 1
            trend.append({
                "date": scan_file.stem.split("_")[-1],
                "total": len(findings),
                "by_severity": severity_count,
            })
        return trend
```

### 3. Graph-Based Correlation

```python
import networkx as nx

class FindingGraph:
    """Build a graph of related findings."""

    def __init__(self):
        self.graph = nx.Graph()

    def build(self, findings: List[ParsedFinding]):
        """Build correlation graph."""
        for f in findings:
            self.graph.add_node(
                f"{f.tool}:{f.title}",
                finding=f.to_dict(),
                severity=f.severity
            )

        # Connect findings for same host
        by_host = {}
        for f in findings:
            by_host.setdefault(f.host, []).append(f)

        for host, host_findings in by_host.items():
            for i, f1 in enumerate(host_findings):
                for f2 in host_findings[i+1:]:
                    self.graph.add_edge(
                        f"{f1.tool}:{f1.title}",
                        f"{f2.tool}:{f2.title}",
                        relationship="same_host"
                    )

    def get_communities(self) -> List[List[str]]:
        """Find communities of related findings."""
        from networkx.algorithms.community import greedy_modularity_communities
        communities = greedy_modularity_communities(self.graph)
        return [list(c) for c in communities]
```

---

## Reporting Template

### Analysis Report

```markdown
# Result Analysis Report

## Summary
- **Target**: {target}
- **Analysis Date**: {date}
- **Tools Parsed**: {tool_count}
- **Total Raw Results**: {raw_count}
- **After Cleaning**: {clean_count}
- **Correlated Findings**: {correlated_count}
- **Final Prioritized Findings**: {final_count}

## Severity Distribution

| Severity | Count | Percentage |
|----------|-------|------------|
| Critical | {critical} | {critical_pct}% |
| High | {high} | {high_pct}% |
| Medium | {medium} | {medium_pct}% |
| Low | {low} | {low_pct}% |
| Info | {info} | {info_pct}% |

## Top Findings

| Rank | Title | Severity | Risk Score | Host | Tools |
|------|-------|----------|------------|------|-------|
| 1 | {title} | {severity} | {score} | {host} | {tools} |

## Cross-Tool Correlation Summary
- **Findings with multiple tool support**: {multi_tool_count}
- **Average confidence score**: {avg_confidence}
- **Most correlated host**: {top_host}

## Recommendations
1. {recommendation_1}
2. {recommendation_2}
3. {recommendation_3}
```

---

## Quick Reference

### One-Liner Commands

```bash
# Parse and count
cat results.jsonl | python -c "import sys,json;print(sum(1 for l in sys.stdin if l.strip()))"

# Filter by severity
cat results.jsonl | python -c "
import sys,json
[print(l.strip()) for l in sys.stdin if json.loads(l).get('info',{}).get('severity') in ('high','critical')]
"

# Extract unique hosts
cat results.jsonl | python -c "
import sys,json
hosts=set()
for l in sys.stdin:
    d=json.loads(l)
    hosts.add(d.get('host',''))
for h in sorted(hosts): print(h)
"

# Generate markdown table
python -c "
import json
with open('report.json') as f: data=json.load(f)
print('| Severity | Count |')
print('|----------|-------|')
for sev in ['critical','high','medium','low','info']:
    count=sum(1 for f in data['findings'] if f['priority']==sev)
    print(f'| {sev} | {count} |')
"
```

### Analysis Decision Matrix

| Scenario | Tool Combination | Analysis Approach |
|----------|------------------|-------------------|
| Quick recon | nuclei + httpx | Simple parse + filter |
| Full recon | subfinder + httpx + ffuf + nuclei | Correlate + score |
| API testing | nuclei + custom scripts | Custom parser + correlate |
| Network scan | nmap + masscan | Port correlation + service enum |
| JS analysis | linkfinder + secretfinder | Endpoint dedup + secret flag |

---

*Document Version: 1.0 | Last Updated: 2026 | Automation-Efficiency Series*
