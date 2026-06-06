# Custom Tool Development

## Overview

Security workflows demand custom tooling that standard utilities cannot provide. Building purpose-built tools in Go, Python, or Rust ensures performance, portability, and seamless integration with automation pipelines. This guide covers CLI argument design, exit codes, structured output, plugin architecture, and distribution patterns for security-focused command-line tools.

## Language Selection

| Language | Strengths | Best For |
|----------|-----------|----------|
| Go | Static binaries, fast compile, great stdlib | Network scanners, distributed crawlers |
| Python | Rapid prototyping, rich ecosystem | Scripting glue, API wrappers |
| Rust | Memory safety, zero-cost abstractions | High-throughput parsers, concurrent scanners |

### Go Tool Authoring

Go produces static binaries with no runtime dependency. The standard library covers HTTP, TLS, and concurrency primitives needed for security tools.

```go
// main.go
package main

import (
    "flag"
    "fmt"
    "net/http"
    "os"
    "sync"
    "time"
)

type ScanConfig struct {
    Target     string
    Concurrency int
    Output     string
    Timeout    time.Duration
}

func main() {
    target := flag.String("target", "", "Target host to scan")
    concurrency := flag.Int("concurrency", 10, "Concurrent request limit")
    output := flag.String("output", "results.json", "Output file path")
    timeout := flag.Int("timeout", 5, "Request timeout in seconds")
    flag.Parse()

    if *target == "" {
        fmt.Fprintln(os.Stderr, "Error: -target is required")
        os.Exit(2)
    }

    config := ScanConfig{
        Target:      *target,
        Concurrency: *concurrency,
        Output:      *output,
        Timeout:     time.Duration(*timeout) * time.Second,
    }

    if err := runScan(config); err != nil {
        fmt.Fprintf(os.Stderr, "Scan failed: %v\n", err)
        os.Exit(1)
    }
    os.Exit(0)
}
```

### Python Tool Authoring

Use Click for composable CLIs with type coercion, subcommands, and context objects.

```python
# scanner.py
import click
import httpx
import json
from pathlib import Path
from typing import List

@click.group()
@click.option('--config', type=click.Path(exists=True), help='Config file path')
@click.pass_context
def cli(ctx, config):
    ctx.ensure_object(dict)
    if config:
        with open(config) as f:
            ctx.obj['config'] = json.load(f)

@cli.command()
@click.option('--target', required=True, help='Target URL')
@click.option('--concurrency', default=10, help='Concurrent workers')
@click.option('--output', type=click.Path(), default='results.json')
@click.option('--timeout', default=5, help='Timeout in seconds')
@click.pass_context
def scan(ctx, target, concurrency, output, timeout):
    config = {**ctx.obj.get('config', {}), 
              'target': target, 'concurrency': concurrency}
    results = execute_scan(config)
    Path(output).write_text(json.dumps(results, indent=2))
    click.echo(f"Wrote {len(results)} results to {output}")

if __name__ == '__main__':
    cli(obj={})
```

### Rust Tool Authoring

Use Clap with derive macros for type-safe argument parsing. Ideal for tools requiring maximum throughput with minimal overhead.

```rust
// scanner.rs
use clap::Parser;
use std::path::PathBuf;
use std::time::Duration;

#[derive(Parser)]
#[command(name = "scanner")]
#[command(about = "Security scanner", long_about = None)]
struct Args {
    /// Target host to scan
    #[arg(short, long)]
    target: String,

    /// Concurrent worker count
    #[arg(short, long, default_value_t = 10)]
    concurrency: usize,

    /// Output file path
    #[arg(short, long, default_value = "results.json")]
    output: PathBuf,

    /// Request timeout in seconds
    #[arg(short, long, default_value_t = 5)]
    timeout: u64,
}

fn main() {
    let args = Args::parse();
    let config = ScanConfig::from(args);
    if let Err(e) = run(config) {
        eprintln!("Fatal: {}", e);
        std::process::exit(1);
    }
}
```

## CLI Argument Design Patterns

Consistent CLI conventions reduce cognitive load for operators running tools in pipelines.

### Positional vs Flag Arguments

- **Positional**: The primary input (target file, URL, domain).
- **Flags**: Modifiers and output controls.

```python
@click.command()
@click.argument('target', type=click.Path(exists=True))
@click.option('--format', type=click.Choice(['json', 'csv', 'text']), default='json')
@click.option('--verbose', is_flag=True)
@click.option('--dry-run', is_flag=True, help='Validate without execution')
def audit(target, format, verbose, dry_run):
    pass
```

### Subcommand Organization

```go
// Go Cobra pattern
var scanCmd = &cobra.Command{
    Use:   "scan [target]",
    Short: "Run vulnerability scan",
    Args:  cobra.ExactArgs(1),
    RunE: func(cmd *cobra.Command, args []string) error {
        return scan(args[0], opts)
    },
}

var rootCmd = &cobra.Command{
    Use: "sentinel",
}
rootCmd.AddCommand(scanCmd, reportCmd, exportCmd)
```

### Common Options Inventory

- `--config <path>` for non-secret configuration
- `--output <path>` for result destination
- `--format <type>` (json, csv, ndjson, xml)
- `--concurrency <n>` for parallelism control
- `--timeout <seconds>` for network operations
- `--verbose` / `--quiet` for log level

## Exit Codes Policy

Standardized exit codes enable reliable orchestration in shell scripts and CI/CD pipelines.

```python
class ExitCode:
    SUCCESS = 0
    GENERAL_ERROR = 1
    INVALID_INPUT = 2
    NETWORK_ERROR = 3
    AUTH_FAILURE = 4
    PARTIAL_RESULTS = 5
    RATE_LIMITED = 6
```

```go
const (
    ExitSuccess       = 0
    ExitError         = 1
    ExitUsage         = 2
    ExitConfig        = 3
    ExitAuth          = 4
    ExitPartial       = 5
    ExitRateLimited   = 6
)
```

**Operator usage:**
```bash
scanner --target example.com
case $? in
  0) echo "Complete" ;;
  1) echo "General failure" ;;
  2) echo "Usage error" ;;
  3) echo "Config issue" ;;
  4) echo "Auth required" ;;
  5) echo "Partial results - inspect output" ;;
  6) echo "Rate limited - backoff and retry" ;;
esac
```

Exit code 5 (partial results) is security-tool-specific. It signals that some targets were scanned while others failed, allowing downstream tools to process available data without aborting.

## Structured Output

Security tools must emit structured output for ingestion by downstream systems. JSON Lines (NDJSON) remains the preferred format for streaming large result sets.

### JSON Schema for Findings

```json
{
  "version": "1.0",
  "generated_at": "2026-06-05T19:00:00Z",
  "target": "example.com",
  "metadata": {
    "tool_version": "2.4.1",
    "scan_duration_seconds": 142
  },
  "findings": [
    {
      "id": "f-a1b2c3",
      "type": "open_port",
      "severity": "info",
      "title": "SSH on port 22",
      "description": "OpenSSH 8.9 detected",
      "location": {"host": "10.0.0.1", "port": 22},
      "evidence": {"banner": "SSH-2.0-OpenSSH_8.9"},
      "remediation": "Restrict access via firewall",
      "references": ["https://..."]
    }
  ],
  "statistics": {"total": 24, "by_severity": {"critical": 1, "high": 3, "medium": 8, "low": 12}}
}
```

### NDJSON Streaming for Large Output

```python
import json

class NDJSONWriter:
    def __init__(self, path):
        self.file = open(path, 'w')
        self.file.write(json.dumps({"type": "metadata", "version": "1.0"}) + '\n')

    def write_finding(self, finding):
        self.file.write(json.dumps({"type": "finding", "data": finding}) + '\n')
        self.file.flush()

    def write_stats(self, stats):
        self.file.write(json.dumps({"type": "statistics", "data": stats}) + '\n')
        self.file.close()
```

### JSON Output in Go

```go
type Finding struct {
    ID          string    `json:"id"`
    Type        string    `json:"type"`
    Severity    string    `json:"severity"`
    Title       string    `json:"title"`
    Description string    `json:"description"`
    Location    Location  `json:"location"`
    Evidence    Evidence  `json:"evidence"`
    Timestamp   time.Time `json:"timestamp"`
}

func outputJSON(findings []Finding, w io.Writer) error {
    enc := json.NewEncoder(w)
    enc.SetIndent("", "  ")
    return enc.Encode(findings)
}
```

### Binary Protocol Buffers for High-Volume

For tools generating millions of events, Protocol Buffers reduce serialization overhead and payload size compared to JSON.

```protobuf
syntax = "proto3";
package scanner.v1;
message Finding {
  string id = 1;
  string type = 2;
  Severity severity = 3;
  string title = 4;
  Location location = 5;
  Evidence evidence = 6;
  int64 timestamp = 7;
}
enum Severity { CRITICAL = 0; HIGH = 1; MEDIUM = 2; LOW = 3; INFO = 4; }
message Location { string host = 1; int32 port = 2; string path = 3; }
message Evidence { map<string, string> fields = 1; }
```

## Plugin Architecture

Plugin systems allow teams to extend tool behavior without modifying core code. A well-designed plugin interface keeps the core stable while enabling rapid custom rule development.

### Python Plugin Pattern (Entry Points)

```python
# core/scanner.py
from importlib.metadata import entry_points

class PluginManager:
    def __init__(self):
        self.plugins = []
        for ep in entry_points(group='sentinel.plugins'):
            plugin = ep.load()
            self.plugins.append(plugin())

    def run_all(self, context):
        results = []
        for plugin in self.plugins:
            results.extend(plugin.run(context))
        return results

# In pyproject.toml
# [project.entry-points."sentinel.plugins"]
# sql_injection = "sentinel_plugins.sql_injection:SQLiPlugin"
# xss_detector = "sentinel_plugins.xss:XSSPlugin"
```

### Go Plugin Pattern

Go supports runtime plugin loading on Linux with `plugin` package. Design a clear ABI boundary.

```go
// plugin.go - stable interface
type Plugin interface {
    Name() string
    Version() string
    Check(ctx *Context, target string) []Finding
}

// scanner loads plugins at runtime
func loadPlugins(dir string) ([]Plugin, error) {
    var plugins []Plugin
    entries, _ := os.ReadDir(dir)
    for _, entry := range entries {
        if strings.HasSuffix(entry.Name(), ".so") {
            p, err := plugin.Open(filepath.Join(dir, entry.Name()))
            // ... load symbols
            plugins = append(plugins, plugin)
        }
    }
    return plugins, nil
}
```

### Rust Plugin Pattern (WASM)

For maximum portability, compile security checks to WASM and load them in a sandboxed runtime.

```rust
// wasm_plugin.rs
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct CheckInput {
    headers: HashMap<String, String>,
    body: String,
}

#[derive(Serialize)]
struct CheckOutput {
    severity: String,
    message: String,
}

#[no_mangle]
pub extern "C" fn check(input_ptr: *const u8, input_len: usize) -> *mut u8 {
    let input = deserialize(input_ptr, input_len);
    let result = perform_check(input);
    serialize_output(result)
}
```

## Compilation and Distribution

### Static Binary Compilation

Cross-compile Go binaries for all major platforms with ldflags for metadata injection.

```bash
VERSION="2.4.1"
COMMIT=$(git rev-parse --short HEAD)
BUILT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

go build \
  -ldflags "-X main.Version=$VERSION -X main.Commit=$COMMIT -X main.Built=$BUILT" \
  -o bin/scanner-linux-amd64 \
  ./cmd/scanner

GOOS=windows GOARCH=amd64 go build -o bin/scanner-windows-amd64.exe ./cmd/scanner
GOOS=darwin GOARCH=arm64 go build -o bin/scanner-darwin-arm64 ./cmd/scanner
```

**Rust cross-compilation with Cargo:**

```bash
cargo build --release --target x86_64-unknown-linux-gnu
cargo build --release --target x86_64-pc-windows-gnu
cargo build --release --target aarch64-apple-darwin
```

### Release Packaging

```bash
VERSION="2.4.1"
PLATFORMS="linux-amd64 linux-arm64 darwin-amd64 darwin-arm64 windows-amd64"

for platform in $PLATFORMS; do
    os=$(echo $platform | cut -d- -f1)
    arch=$(echo $platform | cut -d- -f2)
    bin="scanner-${VERSION}-${os}-${arch}"
    if [ "$os" = "windows" ]; then
        bin="${bin}.exe"
    fi
    cp bin/scanner-$platform "$bin"
    tar czf "${bin}.tar.gz" "$bin"
    rm "$bin"
done

sha256sum scanner-*.tar.gz > checksums.txt
```

### GitHub Release Workflow

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        goos: [linux, darwin, windows]
        goarch: [amd64, arm64]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with: {go-version: '1.23'}
      - run: |
          CGO_ENABLED=0 GOOS=${{ matrix.goos }} GOARCH=${{ matrix.goarch }} \
            go build -o scanner-${{ matrix.goos }}-${{ matrix.goarch }}\
            -ldflags "-X main.Version=${{ github.ref_name }}" ./cmd/scanner
      - uses: actions/upload-artifact@v4
        with: {name: scanner-${{ matrix.goos }}-${{ matrix.goarch }}, path: scanner-*}
  release:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
      - uses: softprops/action-gh-release@v2
        with:
          files: 'scanner-*/*'
          generate_release_notes: true
```

### Python Wheel Distribution

```toml
# pyproject.toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "sentinel-scanner"
version = "2.4.1"
scripts = {sentinel-scan = "sentinel.scanner:main"}
dependencies = ["httpx", "click", "rich"]

[project.optional-dependencies]
dev = ["pytest", "mypy", "ruff"]
```

```bash
python -m build
twine upload dist/*
```

### Key Distribution Patterns

| Pattern | Use Case | Tooling |
|---------|----------|---------|
| Static binary | Linux/macOS/Windows directly | Go, Rust |
| Brew tap | macOS user distribution | Homebrew formula |
| Docker image | Containerized pipelines | Dockerfile + registry |
| Python package | Virtualenv users | PyPI + pip |
| Go install | Go users | `go install pkg@version` |
| OS packages | Enterprise deploys | DEB, RPM, Chocolatey |

## Testing Custom Security Tools

Treat security tools as critical infrastructure. Unit tests validate argument parsing, mock tests prevent accidental live execution, and integration tests catch regressions before deployment.

```go
// scanner_test.go
func TestExitCodeOnMissingTarget(t *testing.T) {
    cmd := NewRootCmd()
    cmd.SetArgs([]string{"--concurrency", "50"})
    _, code, _ := cmd.ExecuteC()
    assert.Equal(t, 2, code)
}

func TestJSONOutput(t *testing.T) {
    findings := []Finding{{ID: "f1", Type: "open_port"}}
    var buf bytes.Buffer
    outputJSON(findings, &buf)
    var parsed []Finding
    json.Unmarshal(buf.Bytes(), &parsed)
    assert.Len(t, parsed, 1)
}
```

```python
# tests/test_scanner.py
from click.testing import CliRunner

def test_missing_target_exits_2():
    runner = CliRunner()
    result = runner.invoke(cli, ['--concurrency', '50'])
    assert result.exit_code == 2
    assert '--target' in result.output

def test_json_output_schema():
    runner = CliRunner()
    result = runner.invoke(cli, [
        'scan', '--target', 'example.com', '--output', '-'
    ])
    assert result.exit_code == 0
    data = json.loads(result.output)
    assert 'findings' in data
    assert 'statistics' in data
```
