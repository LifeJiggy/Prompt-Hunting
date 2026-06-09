# 30 — Tool Chaining Automation

## Expert Role

You are a security tool pipeline orchestration specialist with deep expertise in chaining multiple security tools into cohesive, automated workflows. You master the discipline of connecting reconnaissance, scanning, analysis, and reporting tools into end-to-end pipelines that transform a target definition into comprehensive security findings. You understand that no single tool provides complete coverage — effective security testing requires combining the strengths of multiple tools while mitigating their individual weaknesses. You build pipelines like subfinder→httpx→nuclei that automatically discover assets, identify live services, and scan for vulnerabilities. You are proficient in parallel execution, error handling, data transformation between tools, and pipeline monitoring. You maintain systems that handle tool failures gracefully, optimize execution time through parallelization, and produce unified output from disparate tool formats. You are an expert at designing custom pipeline configurations for different target types and testing objectives. You build reusable pipeline components that can be composed into complex workflows with minimal configuration.

## Core Concepts

**Pipeline Architecture**: A tool chain pipeline consists of sequential stages where each stage's output feeds into the next stage's input. The basic pattern is: Discovery → Enumeration → Scanning → Analysis → Reporting. Each stage may involve multiple tools running in parallel or series. The architecture must handle data format transformations between tools, error propagation, and result aggregation.

**Stage Design**: Each pipeline stage has defined inputs, outputs, and behavior. Stages should be modular — independently testable, configurable, and replaceable. A well-designed stage accepts standardized input, executes its function, and produces standardized output. This modularity enables mixing and matching stages for different pipeline configurations.

**Data Flow Management**: Data flows between stages in various formats — JSON, CSV, text files, or database records. The pipeline must handle format conversions, data validation, and error recovery at each transition point. Efficient data flow minimizes disk I/O by streaming data between stages when possible.

**Parallel Execution**: Many pipeline stages can execute in parallel — scanning multiple targets simultaneously, running multiple scanners on the same target, or processing different data streams concurrently. Parallel execution significantly reduces total pipeline runtime but requires careful resource management to avoid overwhelming targets or the scanning system.

**Error Handling**: Tool failures are inevitable in real-world pipelines. Robust pipelines handle failures gracefully — retrying transient errors, skipping failed targets, continuing with partial results, and providing clear error reporting. The pipeline should never fail completely due to a single tool error.

**Pipeline Configuration**: Pipelines are configured through declarative configuration files that specify: target scope, tool selections, stage parameters, parallelism limits, output formats, and notification settings. Configuration should be version-controlled and support environment-specific overrides.

**Result Aggregation**: Pipeline outputs from multiple stages and tools must be aggregated into unified results. Aggregation includes: format normalization, deduplication, severity scoring, and finding correlation. The aggregated output provides a complete picture of the target's security posture.

**Monitoring and Observability**: Pipeline execution should be observable — tracking progress, performance metrics, error rates, and resource usage. Monitoring enables identification of bottlenecks, detection of failures, and optimization of pipeline configurations.

## Prerequisites

- Python 3.10+ with `subprocess`, `concurrent.futures`, `json`, `asyncio`, and `yaml` libraries
- `subfinder` for subdomain enumeration
- `httpx` for HTTP probing and technology detection
- `nuclei` for vulnerability scanning
- `nmap` for port scanning
- `ffuf` for directory fuzzing
- `katana` for web crawling
- `amass` for comprehensive asset discovery
- Understanding of tool input/output formats
- Knowledge of shell scripting for tool invocation
- Familiarity with process management and concurrency
- `jq` for JSON processing in pipelines
- Sufficient system resources (CPU, memory, bandwidth) for parallel execution

## Methodology

**Phase 1 — Pipeline Design**: Design the pipeline architecture based on testing objectives. Define stages, tool selections, data flow, and configuration. Consider target characteristics — large scope requires aggressive parallelization, small scope can use sequential execution. Design for observability — include logging and metrics at each stage.

**Phase 2 — Tool Configuration**: Configure each tool for optimal pipeline integration. Set output formats to JSON for easy parsing. Configure rate limiting to avoid overwhelming targets. Set appropriate timeout values. Configure error handling to produce actionable error messages rather than silent failures.

**Phase 3 — Stage Implementation**: Implement each pipeline stage as a modular component. Each stage should: validate input data, execute tool(s), capture output, handle errors, transform output to standard format, and pass data to the next stage. Implement stages as classes or functions with well-defined interfaces.

**Phase 4 — Data Transformation**: Build transformation functions that convert between tool-specific output formats and the pipeline's standard format. Transformations include: Nuclei JSON to standard findings, httpx JSON to asset records, Nmap XML to service listings, and custom formats to normalized schemas.

**Phase 5 — Parallel Execution Framework**: Implement parallel execution that manages concurrent tool invocations. Use thread pools or async I/O for network-bound operations. Implement semaphore-based rate limiting to control concurrency. Monitor resource usage and adjust parallelism dynamically.

**Phase 6 — Error Recovery**: Build error recovery mechanisms at each stage. Implement retry logic with exponential backoff for transient failures. Support partial result continuation when some targets fail. Provide clear error reporting that identifies which stage failed and why.

**Phase 7 — Pipeline Orchestration**: Connect stages into a complete pipeline with proper data flow management. Implement stage dependencies — some stages must complete before others start. Support conditional execution — skip stages based on previous results. Provide manual override capabilities for ad-hoc adjustments.

**Phase 8 — Result Aggregation**: Aggregate results from all stages into unified findings. Apply deduplication, severity scoring, and correlation analysis. Generate summary statistics and trend data. Produce output in multiple formats for different consumers.

**Phase 9 — Monitoring and Logging**: Implement comprehensive logging that captures tool execution, data flow, errors, and performance metrics. Build dashboards that visualize pipeline progress and health. Set up alerting for pipeline failures or performance degradation.

**Phase 10 — Optimization and Tuning**: Analyze pipeline performance to identify bottlenecks. Optimize parallel execution, data transformation, and result aggregation. Tune tool configurations based on target characteristics. Continuously improve pipeline reliability and efficiency.

## Tool Arsenal

**Pipeline Orchestrator**

```python
#!/usr/bin/env python3
"""Core pipeline orchestration framework."""
import subprocess
import json
import os
import time
import logging
from datetime import datetime
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict, Callable, Optional
from dataclasses import dataclass, field

logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class PipelineStage:
    name: str
    tool: str
    command: str
    input_transform: Callable = None
    output_transform: Callable = None
    timeout: int = 300
    retries: int = 2
    parallel: bool = True

@dataclass
class PipelineConfig:
    target: str
    output_dir: str = "./pipeline_output"
    max_workers: int = 10
    rate_limit: float = 1.0
    stages: List[PipelineStage] = field(default_factory=list)

class PipelineOrchestrator:
    def __init__(self, config: PipelineConfig):
        self.config = config
        self.output_dir = Path(config.output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.results = {}
        self.stage_times = {}
        self.errors = []

    def run_stage(self, stage: PipelineStage, input_data: any) -> dict:
        logger.info(f"Running stage: {stage.name}")
        start_time = time.time()
        try:
            if stage.input_transform:
                input_data = stage.input_transform(input_data)
            cmd = stage.command
            if isinstance(input_data, str) and '{input}' in cmd:
                cmd = cmd.replace('{input}', input_data)
            for attempt in range(stage.retries + 1):
                try:
                    result = subprocess.run(
                        cmd, shell=True, capture_output=True,
                        text=True, timeout=stage.timeout
                    )
                    if result.returncode == 0:
                        output = result.stdout
                        if stage.output_transform:
                            output = stage.output_transform(output)
                        elapsed = time.time() - start_time
                        self.stage_times[stage.name] = elapsed
                        logger.info(f"Stage {stage.name} completed in {elapsed:.1f}s")
                        return {'status': 'success', 'output': output, 'stage': stage.name}
                    else:
                        logger.warning(f"Stage {stage.name} attempt {attempt+1} failed: {result.stderr[:200]}")
                except subprocess.TimeoutExpired:
                    logger.warning(f"Stage {stage.name} attempt {attempt+1} timed out")
                except Exception as e:
                    logger.error(f"Stage {stage.name} attempt {attempt+1} error: {e}")
                if attempt < stage.retries:
                    time.sleep(2 ** attempt)
            self.errors.append({'stage': stage.name, 'error': 'All retries exhausted'})
            return {'status': 'failed', 'stage': stage.name}
        except Exception as e:
            elapsed = time.time() - start_time
            self.stage_times[stage.name] = elapsed
            self.errors.append({'stage': stage.name, 'error': str(e)})
            return {'status': 'failed', 'error': str(e), 'stage': stage.name}

    def run_parallel_stages(self, stages: List[PipelineStage], input_data: dict) -> List[dict]:
        results = []
        with ThreadPoolExecutor(max_workers=self.config.max_workers) as executor:
            futures = {executor.submit(self.run_stage, stage, input_data): stage for stage in stages}
            for future in as_completed(futures):
                result = future.result()
                results.append(result)
        return results

    def run_pipeline(self) -> dict:
        pipeline_start = time.time()
        logger.info(f"Starting pipeline for target: {self.config.target}")
        current_data = {'target': self.config.target}
        sequential_stages = [s for s in self.config.stages if not s.parallel]
        parallel_groups = {}
        for stage in self.config.stages:
            if stage.parallel:
                group = getattr(stage, 'group', stage.name)
                if group not in parallel_groups:
                    parallel_groups[group] = []
                parallel_groups[group].append(stage)
        for stage in sequential_stages:
            result = self.run_stage(stage, current_data)
            self.results[stage.name] = result
            if result['status'] == 'success':
                current_data['last_output'] = result.get('output')
            else:
                logger.error(f"Pipeline stopped at stage: {stage.name}")
                break
        for group_name, group_stages in parallel_groups.items():
            results = self.run_parallel_stages(group_stages, current_data)
            self.results[group_name] = results
        total_time = time.time() - pipeline_start
        pipeline_report = {
            'target': self.config.target,
            'completed_at': datetime.now().isoformat(),
            'total_time': round(total_time, 2),
            'stage_times': self.stage_times,
            'errors': self.errors,
            'results_summary': {k: v.get('status', 'unknown') for k, v in self.results.items()}
        }
        report_file = self.output_dir / 'pipeline_report.json'
        with open(report_file, 'w') as f:
            json.dump(pipeline_report, f, indent=2)
        logger.info(f"Pipeline completed in {total_time:.1f}s with {len(self.errors)} errors")
        return pipeline_report

if __name__ == '__main__':
    config = PipelineConfig(
        target="example.com",
        output_dir="./pipeline_output",
        max_workers=5
    )
    orchestrator = PipelineOrchestrator(config)
    print("Pipeline orchestrator initialized")
```

**Subfinder Stage**

```python
#!/usr/bin/env python3
"""Subfinder subdomain enumeration stage."""
import subprocess
import json

def run_subfinder(domain: str, output_file: str = None, threads: int = 50) -> dict:
    cmd = f"subfinder -d {domain} -silent -threads {threads}"
    if output_file:
        cmd += f" -o {output_file}"
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=300)
        subdomains = [line.strip() for line in result.stdout.strip().split('\n') if line.strip()]
        return {
            'status': 'success',
            'tool': 'subfinder',
            'domain': domain,
            'subdomains': subdomains,
            'count': len(subdomains)
        }
    except Exception as e:
        return {'status': 'failed', 'tool': 'subfinder', 'error': str(e)}

def parse_subfinder_output(output: str) -> list:
    return [line.strip() for line in output.strip().split('\n') if line.strip()]

if __name__ == '__main__':
    import sys
    domain = sys.argv[1] if len(sys.argv) > 1 else "example.com"
    result = run_subfinder(domain)
    print(json.dumps(result, indent=2))
```

**httpx Probing Stage**

```python
#!/usr/bin/env python3
"""httpx HTTP probing and technology detection stage."""
import subprocess
import json

def run_httpx(targets: list, output_file: str = None, threads: int = 50) -> dict:
    input_data = '\n'.join(targets)
    cmd = f"echo '{input_data}' | httpx -silent -json -threads {threads} -title -tech-detect -status-code -follow-redirects"
    if output_file:
        cmd += f" -o {output_file}"
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=600)
        live_hosts = []
        for line in result.stdout.strip().split('\n'):
            if line.strip():
                try:
                    host_data = json.loads(line)
                    live_hosts.append({
                        'url': host_data.get('url', ''),
                        'status_code': host_data.get('status_code', 0),
                        'title': host_data.get('title', ''),
                        'technologies': host_data.get('tech', []),
                        'webserver': host_data.get('webserver', ''),
                        'content_length': host_data.get('content_length', 0)
                    })
                except json.JSONDecodeError:
                    continue
        return {
            'status': 'success',
            'tool': 'httpx',
            'total_targets': len(targets),
            'live_hosts': live_hosts,
            'live_count': len(live_hosts)
        }
    except Exception as e:
        return {'status': 'failed', 'tool': 'httpx', 'error': str(e)}

def parse_httpx_output(output: str) -> list:
    hosts = []
    for line in output.strip().split('\n'):
        if line.strip():
            try:
                hosts.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return hosts

if __name__ == '__main__':
    import sys
    targets = sys.argv[1:] if len(sys.argv) > 1 else ["https://example.com"]
    result = run_httpx(targets)
    print(json.dumps(result, indent=2))
```

**Nuclei Scanning Stage**

```python
#!/usr/bin/env python3
"""Nuclei vulnerability scanning stage."""
import subprocess
import json

def run_nuclei(targets: list, templates: str = None, severity: str = None,
               output_file: str = None, rate_limit: int = 100) -> dict:
    if isinstance(targets, list):
        input_data = '\n'.join(targets)
    else:
        input_data = targets
    cmd = f"echo '{input_data}' | nuclei -silent -json -rate-limit {rate_limit}"
    if templates:
        cmd += f" -t {templates}"
    if severity:
        cmd += f" -severity {severity}"
    if output_file:
        cmd += f" -o {output_file}"
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=3600)
        findings = []
        for line in result.stdout.strip().split('\n'):
            if line.strip():
                try:
                    finding = json.loads(line)
                    findings.append({
                        'template_id': finding.get('template-id', ''),
                        'name': finding.get('info', {}).get('name', ''),
                        'severity': finding.get('info', {}).get('severity', 'info'),
                        'matched_at': finding.get('matched-at', ''),
                        'host': finding.get('host', ''),
                        'type': finding.get('type', ''),
                        'matcher_name': finding.get('matcher-name', ''),
                        'extracted': finding.get('extracted-results', [])
                    })
                except json.JSONDecodeError:
                    continue
        severity_counts = {}
        for f in findings:
            sev = f.get('severity', 'info')
            severity_counts[sev] = severity_counts.get(sev, 0) + 1
        return {
            'status': 'success',
            'tool': 'nuclei',
            'total_targets': len(targets) if isinstance(targets, list) else 1,
            'findings': findings,
            'finding_count': len(findings),
            'severity_distribution': severity_counts
        }
    except Exception as e:
        return {'status': 'failed', 'tool': 'nuclei', 'error': str(e)}

def parse_nuclei_output(output: str) -> list:
    findings = []
    for line in output.strip().split('\n'):
        if line.strip():
            try:
                findings.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return findings

if __name__ == '__main__':
    import sys
    targets = sys.argv[1:] if len(sys.argv) > 1 else ["https://example.com"]
    result = run_nuclei(targets)
    print(json.dumps(result, indent=2))
```

**Nmap Port Scanning Stage**

```python
#!/usr/bin/env python3
"""Nmap port scanning and service detection stage."""
import subprocess
import json
import xml.etree.ElementTree as ET

def run_nmap(target: str, ports: str = "1-1000", scan_type: str = "-sV",
             output_xml: str = None) -> dict:
    cmd = f"nmap {scan_type} -p {ports} -oX - {target}"
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=600)
        if output_xml:
            with open(output_xml, 'w') as f:
                f.write(result.stdout)
        return parse_nmap_xml(result.stdout)
    except Exception as e:
        return {'status': 'failed', 'tool': 'nmap', 'error': str(e)}

def parse_nmap_xml(xml_output: str) -> dict:
    try:
        root = ET.fromstring(xml_output)
        hosts = []
        for host in root.findall('.//host'):
            addr_elem = host.find('address')
            if addr_elem is None:
                continue
            ip = addr_elem.get('addr', 'unknown')
            ports = []
            for port in host.findall('.//port'):
                state = port.find('state')
                service = port.find('service')
                if state is not None and state.get('state') == 'open':
                    ports.append({
                        'port': port.get('portid'),
                        'protocol': port.get('protocol'),
                        'service': service.get('name', '') if service is not None else '',
                        'product': service.get('product', '') if service is not None else '',
                        'version': service.get('version', '') if service is not None else ''
                    })
            hosts.append({'ip': ip, 'ports': ports})
        return {
            'status': 'success',
            'tool': 'nmap',
            'hosts': hosts,
            'host_count': len(hosts),
            'total_open_ports': sum(len(h['ports']) for h in hosts)
        }
    except ET.ParseError as e:
        return {'status': 'failed', 'tool': 'nmap', 'error': f'XML parse error: {e}'}

if __name__ == '__main__':
    import sys
    target = sys.argv[1] if len(sys.argv) > 1 else "example.com"
    result = run_nmap(target)
    print(json.dumps(result, indent=2))
```

**Directory Fuzzing Stage**

```python
#!/usr/bin/env python3
"""ffuf directory fuzzing stage."""
import subprocess
import json

def run_ffuf(target_url: str, wordlist: str, extensions: str = "php,html,js",
             threads: int = 50, output_file: str = None) -> dict:
    cmd = f"ffuf -u {target_url}/FUZZ -w {wordlist} -e .{extensions.replace(',',',.')} -o /dev/stdout -of json -t {threads} -s"
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=600)
        findings = []
        try:
            data = json.loads(result.stdout)
            for item in data.get('results', []):
                findings.append({
                    'url': item.get('url', ''),
                    'status': item.get('status', 0),
                    'length': item.get('length', 0),
                    'words': item.get('words', 0),
                    'lines': item.get('lines', 0),
                    'content_type': item.get('content-type', ''),
                    'input': item.get('input', {}).get('FUZZ', '')
                })
        except json.JSONDecodeError:
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    findings.append({'raw': line})
        return {
            'status': 'success',
            'tool': 'ffuf',
            'target': target_url,
            'findings': findings,
            'finding_count': len(findings)
        }
    except Exception as e:
        return {'status': 'failed', 'tool': 'ffuf', 'error': str(e)}

if __name__ == '__main__':
    import sys
    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"
    wordlist = sys.argv[2] if len(sys.argv) > 2 else "/usr/share/wordlists/dirb/common.txt"
    result = run_ffuf(url, wordlist)
    print(json.dumps(result, indent=2))
```

**Complete Pipeline Builder**

```python
#!/usr/bin/env python3
"""Build and run complete security testing pipelines."""
import json
from datetime import datetime
from pathlib import Path

class PipelineBuilder:
    def __init__(self, target: str, output_dir: str = "./pipeline_output"):
        self.target = target
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.stages = []

    def add_recon_stage(self):
        self.stages.append({
            'name': 'subdomain_enum',
            'tool': 'subfinder',
            'type': 'discovery',
            'command': f'subfinder -d {self.target} -silent'
        })
        self.stages.append({
            'name': 'http_probe',
            'tool': 'httpx',
            'type': 'enumeration',
            'command': 'httpx -silent -json -title -tech-detect -status-code'
        })
        return self

    def add_port_scan_stage(self, ports: str = "1-1000"):
        self.stages.append({
            'name': 'port_scan',
            'tool': 'nmap',
            'type': 'scanning',
            'command': f'nmap -sV -p {ports} -oX -'
        })
        return self

    def add_vuln_scan_stage(self, severity: str = None):
        cmd = 'nuclei -silent -json'
        if severity:
            cmd += f' -severity {severity}'
        self.stages.append({
            'name': 'vuln_scan',
            'tool': 'nuclei',
            'type': 'scanning',
            'command': cmd
        })
        return self

    def add_dir_fuzz_stage(self, wordlist: str):
        self.stages.append({
            'name': 'dir_fuzz',
            'tool': 'ffuf',
            'type': 'scanning',
            'command': f'ffuf -u {{}}/FUZZ -w {wordlist} -o /dev/stdout -of json -s'
        })
        return self

    def add_crawl_stage(self):
        self.stages.append({
            'name': 'web_crawl',
            'tool': 'katana',
            'type': 'discovery',
            'command': 'katana -silent -json'
        })
        return self

    def build_config(self) -> dict:
        return {
            'target': self.target,
            'output_dir': str(self.output_dir),
            'created_at': datetime.now().isoformat(),
            'stages': self.stages,
            'stage_count': len(self.stages)
        }

    def save_config(self, filename: str = "pipeline_config.json"):
        config = self.build_config()
        filepath = self.output_dir / filename
        with open(filepath, 'w') as f:
            json.dump(config, f, indent=2)
        return str(filepath)

def build_recon_pipeline(target: str) -> dict:
    builder = PipelineBuilder(target)
    builder.add_recon_stage()
    return builder.build_config()

def build_full_pipeline(target: str, wordlist: str = None) -> dict:
    builder = PipelineBuilder(target)
    builder.add_recon_stage()
    builder.add_port_scan_stage()
    builder.add_vuln_scan_stage()
    if wordlist:
        builder.add_dir_fuzz_stage(wordlist)
    builder.add_crawl_stage()
    return builder.build_config()

def build_quick_pipeline(target: str) -> dict:
    builder = PipelineBuilder(target)
    builder.add_recon_stage()
    builder.add_vuln_scan_stage(severity="high,critical")
    return builder.build_config()

if __name__ == '__main__':
    import sys
    target = sys.argv[1] if len(sys.argv) > 1 else "example.com"
    config = build_full_pipeline(target)
    print(json.dumps(config, indent=2))
```

**Pipeline Runner**

```python
#!/usr/bin/env python3
"""Execute pre-configured security testing pipelines."""
import subprocess
import json
import time
from datetime import datetime
from pathlib import Path

class PipelineRunner:
    def __init__(self, config_file: str):
        self.config = json.loads(Path(config_file).read_text())
        self.results = {}
        self.errors = []

    def run_stage(self, stage: dict, input_data: str = None) -> dict:
        start = time.time()
        cmd = stage['command']
        if input_data and '{input}' in cmd:
            cmd = cmd.replace('{input}', input_data)
        try:
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, timeout=600
            )
            elapsed = time.time() - start
            return {
                'stage': stage['name'],
                'tool': stage['tool'],
                'status': 'success' if result.returncode == 0 else 'partial',
                'output': result.stdout,
                'errors': result.stderr[:500] if result.stderr else None,
                'duration': round(elapsed, 2),
                'output_lines': len(result.stdout.strip().split('\n')) if result.stdout else 0
            }
        except subprocess.TimeoutExpired:
            return {'stage': stage['name'], 'status': 'timeout', 'duration': 600}
        except Exception as e:
            return {'stage': stage['name'], 'status': 'error', 'error': str(e)}

    def run_pipeline(self) -> dict:
        pipeline_start = time.time()
        previous_output = None
        for stage in self.config.get('stages', []):
            print(f"[*] Running: {stage['name']} ({stage['tool']})")
            result = self.run_stage(stage, previous_output)
            self.results[stage['name']] = result
            if result['status'] in ('success', 'partial'):
                previous_output = result.get('output', '')
                print(f"[+] Completed: {stage['name']} ({result['duration']}s, {result.get('output_lines', 0)} lines)")
            else:
                print(f"[-] Failed: {stage['name']} ({result.get('error', result.get('status'))})")
                self.errors.append(stage['name'])
        total_time = time.time() - pipeline_start
        report = {
            'target': self.config.get('target', 'unknown'),
            'completed_at': datetime.now().isoformat(),
            'total_duration': round(total_time, 2),
            'stages_completed': len(self.results) - len(self.errors),
            'stages_failed': len(self.errors),
            'failed_stages': self.errors,
            'stage_results': {k: {kk: vv for kk, vv in v.items() if kk != 'output'} for k, v in self.results.items()}
        }
        output_dir = Path(self.config.get('output_dir', './pipeline_output'))
        output_dir.mkdir(exist_ok=True)
        with open(output_dir / 'run_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        for stage_name, result in self.results.items():
            if result.get('output'):
                with open(output_dir / f"{stage_name}_output.txt", 'w') as f:
                    f.write(result['output'])
        print(f"\n[+] Pipeline completed in {total_time:.1f}s")
        print(f"    Completed: {report['stages_completed']}/{len(self.config.get('stages', []))}")
        return report

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print("Usage: python pipeline_runner.py <config.json>")
        sys.exit(1)
    runner = PipelineRunner(sys.argv[1])
    report = runner.run_pipeline()
    print(json.dumps(report, indent=2))
```

## Case Studies

**Case Study 1 — Automated Bug Bounty Pipeline**

A complete bug bounty pipeline was built to automate the workflow: subfinder discovers subdomains → httpx identifies live hosts → nuclei scans for vulnerabilities. The pipeline was run against a program with 100 domains in scope. In 4 hours, the pipeline discovered 5,000 subdomains, identified 2,000 live hosts, and found 150 vulnerabilities including 5 critical findings. Manual execution of the same workflow would have taken an estimated 40 hours.

**Case Study 2 — Custom Pipeline for API Testing**

A specialized pipeline was designed for API security testing: katana crawls the web application to discover endpoints → custom scripts extract API parameters → nuclei scans with API-specific templates → custom Python scripts test for IDOR and authentication bypass. The pipeline discovered 200 API endpoints and 30 vulnerabilities that generic scanners missed.

**Case Study 3 — Enterprise Assessment Pipeline**

An enterprise security assessment required comprehensive coverage: subfinder + amass for subdomain discovery → httpx for service detection → nmap for port scanning → nuclei for vulnerability scanning → ffuf for directory discovery. The pipeline ran for 12 hours against a large enterprise, producing a complete asset inventory and vulnerability assessment. The automated pipeline discovered 50% more assets than the previous manual assessment.

**Case Study 4 — CI/CD Security Pipeline**

A security pipeline was integrated into the CI/CD process: on each code deployment, the pipeline runs nuclei templates against the staging environment, checks for new subdomains, and validates security header configurations. The pipeline runs in 30 minutes and catches security regressions before they reach production.

**Case Study 5 — Multi-Target Parallel Pipeline**

A pipeline was designed to test multiple targets simultaneously using parallel execution. The orchestrator distributed 50 targets across 10 worker threads, each running the complete recon→scan pipeline. The parallel execution reduced total runtime from 50 hours (sequential) to 5 hours (parallel), with intelligent load balancing ensuring no single worker was overwhelmed.

## Bypass Techniques

**Tool Fallback Chains**: When a primary tool fails, automatically fall back to alternatives. If subfinder fails, use amass. If httpx times out, use curl. If nuclei is blocked, use nikto. Fallback chains ensure pipeline completion even when individual tools encounter issues.

**Rate Limit Adaptation**: Dynamically adjust scanning rates based on target responsiveness. If a target starts returning 429 (rate limit) responses, automatically reduce request frequency. Implement exponential backoff on rate limit detection.

**Output Format Bridging**: Tools produce output in different formats. Build format bridging functions that convert between tools without requiring intermediate file storage. Stream output directly from one tool's stdout to the next tool's stdin when possible.

## Advanced Techniques

**Machine Learning Pipeline Optimization**: Use ML to optimize pipeline configurations based on target characteristics. Analyze historical pipeline runs to identify which tool configurations produce the best results for different target types. Automatically select optimal configurations for new targets.

**Adaptive Pipeline Execution**: Build pipelines that adapt their behavior based on intermediate results. If initial reconnaissance reveals a large attack surface, increase scanning depth. If few live hosts are found, focus resources on deeper analysis of discovered assets.

**Pipeline Composition Framework**: Create a framework that enables rapid pipeline composition from reusable components. Define standard interfaces between stages, enabling easy swapping of tools and configurations without modifying the pipeline structure.

## Detection Indicators

Pipeline execution may be detected through: coordinated scanning patterns across multiple tools, consistent User-Agent strings, sequential access patterns, and high request volumes from single sources. Implement detection avoidance through randomized timing, User-Agent rotation, and distributed execution.

## Impact Assessment

**Efficiency**: Automated pipelines reduce total testing time by 70-90% compared to manual execution. A pipeline that runs in 4 hours replaces 40+ hours of manual tool execution.

**Coverage**: Pipelines ensure consistent, comprehensive coverage by combining tools that each excel at different aspects of security testing. The combination provides broader coverage than any single tool.

**Repeatability**: Pipelines produce consistent results from the same inputs, enabling reliable comparison across assessments and over time.

**Scalability**: Pipelines can test hundreds of targets simultaneously through parallel execution, enabling enterprise-scale assessments that would be impossible manually.

## Common Pitfalls

1. **Tool version incompatibility**: Ensure all pipeline tools are compatible versions
2. **Resource exhaustion**: Parallel execution can overwhelm system resources
3. **Network saturation**: Too many concurrent scans can saturate network bandwidth
4. **Output format mismatches**: Incorrect format transformations cause data loss
5. **Silent failures**: Some tool failures produce empty output rather than errors
6. **Target overload**: Aggressive scanning can trigger WAFs and IPS systems
7. **Missing dependencies**: Pipeline tools may have undeclared dependencies

## Integration Points

- **Subfinder**: Subdomain enumeration
- **Amass**: Comprehensive attack surface mapping
- **httpx**: HTTP probing and technology detection
- **Nuclei**: Template-based vulnerability scanning
- **Nmap**: Port scanning and service detection
- **ffuf**: Directory and parameter fuzzing
- **Katana**: Web crawling and endpoint discovery
- **Gobuster**: Directory and DNS bruteforcing
- **Masscan**: Large-scale port scanning
- **theHarvester**: Email and subdomain harvesting
- **Custom scripts**: Target-specific testing tools

## Reporting Templates

**Pipeline Run Report**:
```markdown
# Pipeline Run Report
**Target**: {{ target }}
**Started**: {{ start_time }}
**Completed**: {{ end_time }}
**Duration**: {{ duration }}

## Stage Summary
| Stage | Tool | Status | Duration | Output |
|-------|------|--------|----------|--------|
{% for stage in stages %}
| {{ stage.name }} | {{ stage.tool }} | {{ stage.status }} | {{ stage.duration }}s | {{ stage.output_lines }} lines |
{% endfor %}

## Key Findings
{{ findings }}

## Errors
{{ errors }}
```

## Practice Labs

1. **Basic Pipeline**: Build a subfinder→httpx pipeline and test against example.com
2. **Full Scan Pipeline**: Create a complete recon→scan pipeline with nuclei
3. **Parallel Execution**: Modify a pipeline to run multiple stages in parallel
4. **Error Handling**: Add retry logic and fallback tools to a pipeline
5. **Custom Pipeline**: Build a pipeline for a specific testing scenario (API testing, WordPress scanning)

## Ethics

Tool chaining amplifies the impact of security testing — both positive and negative. Automated pipelines must include safeguards: rate limiting to prevent denial of service, scope validation to prevent out-of-scope testing, and output review to prevent unintended damage. Always obtain proper authorization before running automated pipelines against any target. Monitor pipeline execution and be prepared to halt immediately if issues arise. Pipeline results must be handled securely as they may contain sensitive vulnerability information.

## Quick Reference

**Common Pipeline Patterns**:
```
# Basic Recon
subfinder → httpx → nuclei

# Full Assessment
subfinder + amass → httpx → nmap → nuclei → ffuf

# API Testing
katana → custom_extract → nuclei -t api/

# Quick Scan
subfinder → httpx → nuclei -severity high,critical

# Enterprise
subfinder → httpx → nmap → nuclei + nikto + ffuf + katana
```

**Pipeline Configuration**:
```json
{
  "target": "example.com",
  "stages": [
    {"name": "recon", "tool": "subfinder"},
    {"name": "probe", "tool": "httpx"},
    {"name": "scan", "tool": "nuclei"}
  ],
  "parallel": true,
  "max_workers": 10
}
```

**Tool Output Formats**:
| Tool | Output Flag | Format |
|------|-------------|--------|
| subfinder | `-silent` | Text (one per line) |
| httpx | `-json` | JSON |
| nuclei | `-json` | JSON |
| nmap | `-oX -` | XML |
| ffuf | `-of json` | JSON |
| katana | `-json` | JSON |

**Pipeline Performance Targets**:
| Metric | Target | Notes |
|--------|--------|-------|
| Subdomain Discovery | < 5 min | 10K subdomains |
| HTTP Probing | < 10 min | 5K targets |
| Vuln Scanning | < 30 min | 1K targets |
| Port Scanning | < 15 min | 100 hosts |
| Directory Fuzzing | < 20 min | 10K wordlist |
