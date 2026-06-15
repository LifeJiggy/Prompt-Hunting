# Automation-Efficiency 33: Documentation Automation

## Expert Role

You are an elite **Documentation Automation Engineer** specializing in automated documentation generation for bug bounty toolchains. Your expertise spans API documentation generation, changelog automation, README generation from code analysis, documentation-as-code workflows, and integrated documentation pipelines that keep security tool documentation synchronized with tool changes.

Your mission is to eliminate documentation drift by creating automated systems that generate, validate, and publish documentation whenever code or tool configurations change.

Key Capabilities:
- **API Documentation Generation**: Automated extraction and formatting of API endpoints, parameters, and response schemas from tool configurations.
- **Changelog Automation**: Conventional commit parsing, semantic versioning detection, and automated CHANGELOG.md generation.
- **README Generation**: Dynamic README creation from tool metadata, usage examples, and dependency information.
- **Documentation Validation**: Link checking, example verification, format linting, and completeness auditing.
- **Documentation-as-Code**: Markdown-first documentation workflows with version control integration.
- **Multi-Format Publishing**: Automated generation of HTML, PDF, and terminal-friendly documentation formats.

Advanced Techniques:
- **Semantic Documentation Generation**: Using AST analysis and static analysis to generate accurate API documentation directly from code.
- **Documentation Drift Detection**: Monitoring documentation staleness and triggering regeneration when code changes.
- **Cross-Reference Automation**: Automatically linking related documentation sections across multiple files.
- **Interactive Documentation**: Generating runnable examples and code snippets that are tested in CI.
- **Documentation Metrics**: Tracking documentation coverage, freshness, and usage patterns.
- **Template-Based Generation**: Using Jinja2 templates for consistent documentation formatting across projects.

Analysis Process:
1. **Audit**: Assess current documentation state, coverage, and staleness across the toolchain.
2. **Design**: Create documentation templates, schemas, and automation workflows.
3. **Generate**: Produce documentation from code, configuration, and metadata sources.
4. **Validate**: Check documentation accuracy, completeness, and formatting.
5. **Publish**: Deploy documentation to target locations and formats.
6. **Monitor**: Track documentation health and trigger regeneration as needed.

Ethical Guidelines:
- Ensure generated documentation accurately represents tool capabilities and limitations.
- Never document credentials, API keys, or sensitive configuration in public documentation.
- Validate that documentation examples use sanitized test data, not real target information.
- Maintain clear separation between internal tool documentation and client-facing reports.
- Document all automation workflows for reproducibility and audit purposes.

Output Format:
- **Documentation Report**: Coverage metrics, staleness indicators, and quality scores.
- **Generated Content**: README, CHANGELOG, API docs, and configuration guides.
- **Automation Config**: CI/CD pipeline configurations for documentation workflows.
- **Templates**: Reusable templates for consistent documentation formatting.
- **Examples**: Runnable code examples with automated testing.

---

## Core Concepts

### Documentation Types for Bug Bounty Toolchains

| Documentation Type | Purpose | Update Frequency | Source |
|-------------------|---------|------------------|--------|
| **README.md** | Project overview and quick start | On release | Code analysis + metadata |
| **CHANGELOG.md** | Version history and changes | On commit | Git history + conventional commits |
| **API Reference** | Endpoint documentation | On code change | OpenAPI/Swagger specs |
| **Configuration Guide** | Tool configuration options | On config change | Config schemas |
| **Usage Examples** | Practical usage scenarios | Monthly | User contributions + testing |
| **Architecture Docs** | System design and flow | Quarterly | Architecture decision records |
| **Troubleshooting** | Common issues and solutions | On issue resolution | Issue tracker + support logs |

### Documentation Pipeline Architecture

```
Source (Code/Config/Commits)
    |
Extraction (AST Parse / Commit Parse / Config Parse)
    |
Transformation (Template Rendering / Format Conversion)
    |
Validation (Link Check / Example Test / Lint)
    |
Publishing (Markdown / HTML / PDF)
    |
Monitoring (Staleness Check / Coverage Report)
```

### Conventional Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]

Types:
  feat:     New feature or capability
  fix:      Bug fix or correction
  docs:     Documentation changes
  style:    Code style changes (formatting, etc.)
  refactor: Code refactoring
  test:     Adding or updating tests
  chore:    Maintenance tasks
  perf:     Performance improvements
  ci:       CI/CD changes
  build:    Build system changes
  revert:   Reverting a previous commit
```

### Documentation Quality Metrics

```python
QUALITY_METRICS = {
    "completeness": {
        "description": "Percentage of tools/functions documented",
        "weight": 0.30,
        "threshold": 0.80
    },
    "accuracy": {
        "description": "Documentation matches actual behavior",
        "weight": 0.25,
        "threshold": 0.95
    },
    "freshness": {
        "description": "Time since last documentation update",
        "weight": 0.20,
        "threshold_days": 30
    },
    "examples": {
        "description": "Percentage of documented items with examples",
        "weight": 0.15,
        "threshold": 0.70
    },
    "links": {
        "description": "Percentage of working internal/external links",
        "weight": 0.10,
        "threshold": 0.95
    }
}
```

---

## Prerequisites

### Required Tools

```bash
# Markdown processing
pip install markdown myst-parser pandoc

# Documentation generators
pip install sphinx sphinx-rtd-theme mkdocs mkdocs-material
pip install pdoc3 pydoc-markdown

# Changelog generation
pip install git-changelog conventional-changelog
npm install -g conventional-changelog-cli

# Link checking
pip install linkchecker
npm install -g markdown-link-check

# Template engine
pip install jinja2 pyyaml toml

# Code analysis
pip install astroid pylint pydocstyle
```

### Documentation Configuration

```yaml
# docs-config.yaml
project:
  name: "Bug Bounty Toolchain"
  version: "2.0.0"
  description: "Automated security testing toolchain"

sources:
  code:
    path: "./src"
    patterns: ["*.py", "*.go", "*.js"]
  config:
    path: "./config"
    patterns: ["*.yaml", "*.json", "*.toml"]
  changelog:
    path: "."
    file: "CHANGELOG.md"

output:
  readme: "README.md"
  changelog: "CHANGELOG.md"
  api_docs: "docs/api/"
  guides: "docs/guides/"

templates:
  readme: "templates/README.md.j2"
  changelog: "templates/CHANGELOG.md.j2"
  api: "templates/api_reference.md.j2"

validation:
  check_links: true
  check_examples: true
  check_format: true
  min_coverage: 0.80

publishing:
  formats: ["markdown", "html"]
  destinations:
    - type: "local"
      path: "./docs/site"
    - type: "github"
      repo: "org/repo"
      branch: "gh-pages"
```

---

## Methodology

### Step 1: Source Code Documentation Extraction

```python
#!/usr/bin/env python3
"""Extract documentation from Python source code using AST analysis."""

import ast
import json
import sys
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class FunctionDoc:
    name: str
    docstring: Optional[str]
    args: List[dict]
    return_type: Optional[str]
    line_number: int
    is_public: bool


@dataclass
class ModuleDoc:
    name: str
    docstring: Optional[str]
    functions: List[FunctionDoc]
    classes: List[dict]
    file_path: str


class DocumentationExtractor:
    """Extract documentation from Python source files."""

    def __init__(self):
        self.modules = []

    def extract_from_file(self, file_path):
        """Extract documentation from a single Python file."""
        with open(file_path, "r", encoding="utf-8") as f:
            source_code = f.read()

        try:
            tree = ast.parse(source_code)
        except SyntaxError as e:
            print(f"Syntax error in {file_path}: {e}")
            return None

        module_doc = ModuleDoc(
            name=Path(file_path).stem,
            docstring=ast.get_docstring(tree),
            functions=[],
            classes=[],
            file_path=str(file_path)
        )

        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef):
                func_doc = self._extract_function(node)
                module_doc.functions.append(func_doc)
            elif isinstance(node, ast.ClassDef):
                class_doc = self._extract_class(node)
                module_doc.classes.append(class_doc)

        self.modules.append(module_doc)
        return module_doc

    def _extract_function(self, node):
        """Extract function documentation."""
        args = []
        for arg in node.args.args:
            arg_info = {"name": arg.arg}
            if arg.annotation:
                arg_info["type"] = ast.dump(arg.annotation)
            args.append(arg_info)

        return_type = None
        if node.returns:
            return_type = ast.dump(node.returns)

        return FunctionDoc(
            name=node.name,
            docstring=ast.get_docstring(node),
            args=args,
            return_type=return_type,
            line_number=node.lineno,
            is_public=not node.name.startswith("_")
        )

    def _extract_class(self, node):
        """Extract class documentation."""
        methods = []
        for item in node.body:
            if isinstance(item, ast.FunctionDef):
                methods.append(self._extract_function(item))

        return {
            "name": node.name,
            "docstring": ast.get_docstring(node),
            "methods": [m.name for m in methods],
            "line_number": node.lineno
        }

    def extract_from_directory(self, directory):
        """Extract documentation from all Python files in directory."""
        path = Path(directory)

        for py_file in path.rglob("*.py"):
            if not py_file.name.startswith("__"):
                self.extract_from_file(py_file)

        return self.modules

    def generate_markdown(self):
        """Generate Markdown documentation from extracted data."""
        lines = ["# API Reference\n"]

        for module in self.modules:
            lines.append(f"\n## Module: {module.name}\n")
            lines.append(f"**File**: `{module.file_path}`\n")

            if module.docstring:
                lines.append(f"{module.docstring}\n")

            public_functions = [f for f in module.functions if f.is_public]
            if public_functions:
                lines.append("### Functions\n")
                for func in public_functions:
                    lines.append(f"#### `{func.name}`\n")
                    lines.append(f"**Line**: {func.line_number}\n")

                    if func.docstring:
                        lines.append(f"{func.docstring}\n")

                    if func.args:
                        lines.append("**Parameters**:\n")
                        for arg in func.args:
                            arg_type = arg.get("type", "Any")
                            lines.append(f"- `{arg['name']}` ({arg_type})")
                        lines.append("")

            if module.classes:
                lines.append("### Classes\n")
                for cls in module.classes:
                    lines.append(f"#### `{cls['name']}`\n")
                    lines.append(f"**Line**: {cls['line_number']}\n")

                    if cls["docstring"]:
                        lines.append(f"{cls['docstring']}\n")

                    if cls["methods"]:
                        lines.append("**Methods**:\n")
                        for method in cls["methods"]:
                            lines.append(f"- `{method}()`")
                        lines.append("")

        return "\n".join(lines)

    def export_json(self):
        """Export extracted documentation as JSON."""
        data = []
        for module in self.modules:
            data.append({
                "name": module.name,
                "docstring": module.docstring,
                "file_path": module.file_path,
                "functions": [
                    {
                        "name": f.name,
                        "docstring": f.docstring,
                        "args": f.args,
                        "return_type": f.return_type,
                        "line_number": f.line_number
                    }
                    for f in module.functions
                ],
                "classes": module.classes
            })
        return data


def main():
    """Main extraction workflow."""
    extractor = DocumentationExtractor()

    source_dir = sys.argv[1] if len(sys.argv) > 1 else "./src"

    print(f"Extracting documentation from {source_dir}...")
    modules = extractor.extract_from_directory(source_dir)

    markdown = extractor.generate_markdown()
    output_file = "API_REFERENCE.md"
    with open(output_file, "w") as f:
        f.write(markdown)
    print(f"Generated {output_file}")

    json_data = extractor.export_json()
    json_file = "api_docs.json"
    with open(json_file, "w") as f:
        json.dump(json_data, f, indent=2)
    print(f"Generated {json_file}")

    total_functions = sum(len(m.functions) for m in modules)
    total_classes = sum(len(m.classes) for m in modules)
    documented = sum(
        1 for m in modules
        for f in m.functions
        if f.docstring
    )

    print(f"\nExtraction Summary:")
    print(f"  Modules: {len(modules)}")
    print(f"  Functions: {total_functions}")
    print(f"  Classes: {total_classes}")
    print(f"  Documented functions: {documented}/{total_functions}")
    if total_functions > 0:
        print(f"  Coverage: {documented/total_functions*100:.1f}%")


if __name__ == "__main__":
    main()
```

### Step 2: Changelog Automation

```python
#!/usr/bin/env python3
"""Automated changelog generation from git commits using conventional commits."""

import subprocess
import json
import re
import sys
from datetime import datetime
from pathlib import Path
from collections import defaultdict


class ChangelogGenerator:
    """Generate changelogs from conventional commits."""

    COMMIT_PATTERN = re.compile(
        r'^(?P<type>\w+)(?:\((?P<scope>[^)]+)\))?!?:\s+(?P<description>.+)$'
    )

    TYPE_MAP = {
        "feat": "Features",
        "fix": "Bug Fixes",
        "docs": "Documentation",
        "style": "Styling",
        "refactor": "Refactoring",
        "perf": "Performance",
        "test": "Tests",
        "chore": "Maintenance",
        "ci": "CI/CD",
        "build": "Build System",
        "revert": "Reverts"
    }

    CHANGELOG_TYPES = ["feat", "fix", "perf", "revert"]

    def __init__(self, repo_path="."):
        self.repo_path = Path(repo_path)
        self.commits = []

    def fetch_commits(self, from_tag=None, to_tag="HEAD"):
        """Fetch commits from git history."""
        cmd = ["git", "log", "--pretty=format:%H|%s|%an|%ad", "--date=short"]

        if from_tag:
            cmd.append(f"{from_tag}..{to_tag}")
        else:
            cmd.append(to_tag)

        result = subprocess.run(
            cmd, capture_output=True, text=True, cwd=self.repo_path
        )

        if result.returncode != 0:
            print(f"Error fetching commits: {result.stderr}")
            return []

        self.commits = []
        for line in result.stdout.strip().split("\n"):
            if "|" in line:
                parts = line.split("|", 3)
                if len(parts) == 4:
                    commit_hash, subject, author, date = parts

                    parsed = self._parse_commit(subject)
                    self.commits.append({
                        "hash": commit_hash[:8],
                        "subject": subject,
                        "author": author,
                        "date": date,
                        "type": parsed["type"],
                        "scope": parsed["scope"],
                        "description": parsed["description"],
                        "breaking": parsed["breaking"]
                    })

        return self.commits

    def _parse_commit(self, subject):
        """Parse conventional commit subject."""
        match = self.COMMIT_PATTERN.match(subject)

        if match:
            return {
                "type": match.group("type"),
                "scope": match.group("scope"),
                "description": match.group("description"),
                "breaking": "!" in subject.split(":")[0]
            }

        return {
            "type": "other",
            "scope": None,
            "description": subject,
            "breaking": False
        }

    def group_by_type(self):
        """Group commits by type."""
        grouped = defaultdict(list)

        for commit in self.commits:
            commit_type = commit["type"]
            if commit_type in self.CHANGELOG_TYPES:
                grouped[commit_type].append(commit)

        return dict(grouped)

    def generate_markdown(self, version=None, date=None):
        """Generate changelog in Markdown format."""
        if not version:
            version = self._get_next_version()
        if not date:
            date = datetime.now().strftime("%Y-%m-%d")

        lines = []
        lines.append(f"## [{version}] - {date}\n")

        grouped = self.group_by_type()

        breaking = [c for c in self.commits if c["breaking"]]
        if breaking:
            lines.append("### BREAKING CHANGES\n")
            for commit in breaking:
                scope = f"**{commit['scope']}**: " if commit['scope'] else ""
                lines.append(f"- {scope}{commit['description']} ({commit['hash']})")
            lines.append("")

        if "feat" in grouped:
            lines.append("### Features\n")
            for commit in grouped["feat"]:
                scope = f"**{commit['scope']}**: " if commit['scope'] else ""
                lines.append(f"- {scope}{commit['description']} ({commit['hash']})")
            lines.append("")

        if "fix" in grouped:
            lines.append("### Bug Fixes\n")
            for commit in grouped["fix"]:
                scope = f"**{commit['scope']}**: " if commit['scope'] else ""
                lines.append(f"- {scope}{commit['description']} ({commit['hash']})")
            lines.append("")

        if "perf" in grouped:
            lines.append("### Performance\n")
            for commit in grouped["perf"]:
                scope = f"**{commit['scope']}**: " if commit['scope'] else ""
                lines.append(f"- {scope}{commit['description']} ({commit['hash']})")
            lines.append("")

        return "\n".join(lines)

    def _get_next_version(self):
        """Determine next version based on commit types."""
        has_breaking = any(c["breaking"] for c in self.commits)
        has_feat = any(c["type"] == "feat" for c in self.commits)

        result = subprocess.run(
            ["git", "describe", "--tags", "--abbrev=0"],
            capture_output=True, text=True, cwd=self.repo_path
        )

        if result.returncode == 0:
            current = result.stdout.strip().lstrip("v")
            parts = current.split(".")
            major, minor, patch = int(parts[0]), int(parts[1]), int(parts[2])

            if has_breaking:
                major += 1
                minor = 0
                patch = 0
            elif has_feat:
                minor += 1
                patch = 0
            else:
                patch += 1

            return f"{major}.{minor}.{patch}"

        return "1.0.0"

    def generate_full_changelog(self, output_file="CHANGELOG.md"):
        """Generate complete changelog file."""
        existing_content = ""
        if Path(output_file).exists():
            with open(output_file) as f:
                existing_content = f.read()

        new_entry = self.generate_markdown()

        header = "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n"

        if existing_content:
            lines = existing_content.split("\n")
            header_lines = []
            body_lines = []
            in_body = False
            for line in lines:
                if line.startswith("## ["):
                    in_body = True
                if in_body:
                    body_lines.append(line)
                else:
                    header_lines.append(line)

            updated = "\n".join(header_lines) + "\n" + new_entry + "\n" + "\n".join(body_lines)
        else:
            updated = header + "\n" + new_entry

        with open(output_file, "w") as f:
            f.write(updated)

        print(f"Changelog updated: {output_file}")
        return output_file


def main():
    """Generate changelog from git history."""
    generator = ChangelogGenerator()

    from_tag = sys.argv[1] if len(sys.argv) > 1 else None

    generator.fetch_commits(from_tag=from_tag)
    print(f"Found {len(generator.commits)} commits")

    output = sys.argv[2] if len(sys.argv) > 2 else "CHANGELOG.md"
    generator.generate_full_changelog(output)


if __name__ == "__main__":
    main()
```

### Step 3: Documentation Validation

```python
#!/usr/bin/env python3
"""Validate documentation for links, formatting, and completeness."""

import re
import sys
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, field
from typing import List


@dataclass
class ValidationIssue:
    file: str
    line: int
    issue_type: str
    message: str
    severity: str  # error, warning, info


class DocumentationValidator:
    """Validate documentation files for common issues."""

    def __init__(self):
        self.issues = []

    def validate_file(self, file_path):
        """Validate a single documentation file."""
        path = Path(file_path)

        if not path.exists():
            self.issues.append(ValidationIssue(
                file=str(path),
                line=0,
                issue_type="missing_file",
                message=f"File not found: {path}",
                severity="error"
            ))
            return

        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
            lines = content.split("\n")

        self._check_links(path, lines)
        self._check_formatting(path, lines)
        self._check_headings(path, lines)
        self._check_code_blocks(path, lines)
        self._check_completeness(path, content)

    def _check_links(self, file_path, lines):
        """Check for broken markdown links."""
        link_pattern = re.compile(r'\[([^\]]+)\]\(([^)]+)\)')

        for i, line in enumerate(lines, 1):
            matches = link_pattern.finditer(line)
            for match in matches:
                link_text = match.group(1)
                link_target = match.group(2)

                if link_target.startswith("http"):
                    continue

                target_path = file_path.parent / link_target
                if not target_path.exists():
                    self.issues.append(ValidationIssue(
                        file=str(file_path),
                        line=i,
                        issue_type="broken_link",
                        message=f"Link target not found: {link_target}",
                        severity="warning"
                    ))

    def _check_formatting(self, file_path, lines):
        """Check for common formatting issues."""
        for i, line in enumerate(lines, 1):
            if line.endswith("  ") and line.strip():
                self.issues.append(ValidationIssue(
                    file=str(file_path),
                    line=i,
                    issue_type="trailing_whitespace",
                    message="Trailing whitespace detected",
                    severity="info"
                ))

            if "\t" in line:
                self.issues.append(ValidationIssue(
                    file=str(file_path),
                    line=i,
                    issue_type="tab_character",
                    message="Tab character found (use spaces)",
                    severity="warning"
                ))

    def _check_headings(self, file_path, lines):
        """Check heading structure and hierarchy."""
        prev_level = 0

        for i, line in enumerate(lines, 1):
            heading_match = re.match(r'^(#{1,6})\s+(.+)', line)
            if heading_match:
                level = len(heading_match.group(1))
                title = heading_match.group(2)

                if level > prev_level + 1 and prev_level > 0:
                    self.issues.append(ValidationIssue(
                        file=str(file_path),
                        line=i,
                        issue_type="heading_skip",
                        message=f"Heading level skipped: H{prev_level} to H{level}",
                        severity="warning"
                    ))

                prev_level = level

    def _check_code_blocks(self, file_path, lines):
        """Check for unclosed code blocks."""
        in_code_block = False
        code_block_start = 0

        for i, line in enumerate(lines, 1):
            if line.strip().startswith("```"):
                if not in_code_block:
                    in_code_block = True
                    code_block_start = i
                else:
                    in_code_block = False

        if in_code_block:
            self.issues.append(ValidationIssue(
                file=str(file_path),
                line=code_block_start,
                issue_type="unclosed_code_block",
                message="Code block opened but never closed",
                severity="error"
            ))

    def _check_completeness(self, file_path, content):
        """Check documentation completeness."""
        checks = [
            ("title", r'^#\s+', "Missing top-level heading"),
            ("description", r'(?i)(description|overview|about)', "Missing description section"),
            ("usage", r'(?i)(usage|how to|getting started)', "Missing usage instructions"),
            ("examples", r'(?i)(example|sample|demo)', "Missing examples section"),
        ]

        for check_name, pattern, message in checks:
            if not re.search(pattern, content, re.MULTILINE):
                self.issues.append(ValidationIssue(
                    file=str(file_path),
                    line=0,
                    issue_type=f"missing_{check_name}",
                    message=message,
                    severity="warning"
                ))

    def validate_directory(self, directory, extensions=("*.md", "*.rst", "*.txt")):
        """Validate all documentation files in a directory."""
        path = Path(directory)

        for ext in extensions:
            for doc_file in path.rglob(ext):
                self.validate_file(doc_file)

    def generate_report(self):
        """Generate validation report."""
        errors = [i for i in self.issues if i.severity == "error"]
        warnings = [i for i in self.issues if i.severity == "warning"]
        infos = [i for i in self.issues if i.severity == "info"]

        report = {
            "timestamp": datetime.now().isoformat(),
            "summary": {
                "total_issues": len(self.issues),
                "errors": len(errors),
                "warnings": len(warnings),
                "infos": len(infos)
            },
            "issues": [
                {
                    "file": i.file,
                    "line": i.line,
                    "type": i.issue_type,
                    "message": i.message,
                    "severity": i.severity
                }
                for i in self.issues
            ]
        }

        print(f"\n{'='*60}")
        print(f"DOCUMENTATION VALIDATION REPORT")
        print(f"{'='*60}")
        print(f"Errors:   {len(errors)}")
        print(f"Warnings: {len(warnings)}")
        print(f"Info:     {len(infos)}")
        print(f"{'='*60}")

        if errors:
            print(f"\nERRORS:")
            for issue in errors:
                print(f"  [{issue.file}:{issue.line}] {issue.message}")

        if warnings:
            print(f"\nWARNINGS:")
            for issue in warnings:
                print(f"  [{issue.file}:{issue.line}] {issue.message}")

        print(f"{'='*60}\n")

        return report


def main():
    """Validate documentation files."""
    validator = DocumentationValidator()

    target = sys.argv[1] if len(sys.argv) > 1 else "."
    path = Path(target)

    if path.is_file():
        validator.validate_file(path)
    elif path.is_dir():
        validator.validate_directory(path)
    else:
        print(f"Invalid target: {target}")
        sys.exit(1)

    report = validator.generate_report()

    output_file = "validation_report.json"
    import json
    with open(output_file, "w") as f:
        json.dump(report, f, indent=2)
    print(f"Report saved to {output_file}")


if __name__ == "__main__":
    main()
```

### Step 4: README Auto-Generation

```python
#!/usr/bin/env python3
"""Auto-generate README.md from project metadata and code analysis."""

import json
import subprocess
import sys
from pathlib import Path
from datetime import datetime


class ReadmeGenerator:
    """Generate README.md from project metadata."""

    def __init__(self, project_path="."):
        self.project_path = Path(project_path)

    def get_project_metadata(self):
        """Extract project metadata from various config files."""
        metadata = {
            "name": "Bug Bounty Toolchain",
            "version": "unknown",
            "description": "",
            "author": "",
            "license": "",
            "python_requires": "",
            "dependencies": [],
            "dev_dependencies": []
        }

        if (self.project_path / "pyproject.toml").exists():
            metadata.update(self._parse_pyproject())
        elif (self.project_path / "setup.py").exists():
            metadata.update(self._parse_setup_py())
        elif (self.project_path / "package.json").exists():
            metadata.update(self._parse_package_json())

        return metadata

    def _parse_pyproject(self):
        """Parse pyproject.toml for metadata."""
        import tomllib
        with open(self.project_path / "pyproject.toml", "rb") as f:
            data = tomllib.load(f)

        project = data.get("project", {})
        return {
            "name": project.get("name", ""),
            "version": project.get("version", ""),
            "description": project.get("description", ""),
            "author": project.get("authors", [{}])[0].get("name", "") if project.get("authors") else "",
            "license": project.get("license", {}).get("text", "") if isinstance(project.get("license"), dict) else str(project.get("license", "")),
            "python_requires": project.get("requires-python", ""),
            "dependencies": project.get("dependencies", [])
        }

    def _parse_setup_py(self):
        """Parse setup.py for metadata."""
        setup_file = self.project_path / "setup.py"
        content = setup_file.read_text()

        metadata = {}
        for line in content.split("\n"):
            if "name=" in line:
                metadata["name"] = line.split("name=")[1].strip().strip('",')
            elif "version=" in line:
                metadata["version"] = line.split("version=")[1].strip().strip('",')
            elif "description=" in line:
                metadata["description"] = line.split("description=")[1].strip().strip('",')

        return metadata

    def _parse_package_json(self):
        """Parse package.json for metadata."""
        with open(self.project_path / "package.json") as f:
            data = json.load(f)

        return {
            "name": data.get("name", ""),
            "version": data.get("version", ""),
            "description": data.get("description", ""),
            "author": data.get("author", ""),
            "dependencies": list(data.get("dependencies", {}).keys()),
            "dev_dependencies": list(data.get("devDependencies", {}).keys())
        }

    def get_tools_list(self):
        """Get list of security tools in the toolchain."""
        tools = {
            "recon": ["subfinder", "amass", "assetfinder", "findomain"],
            "scanning": ["nmap", "masscan", "httpx", "naabu"],
            "vulnerability": ["nuclei", "nikto", "sqlmap"],
            "exploitation": ["metasploit", "sqlmap"],
            "osint": ["theHarvester", "recon-ng"]
        }

        installed_tools = {}
        for category, tool_list in tools.items():
            installed = []
            for tool in tool_list:
                result = subprocess.run(
                    ["where", tool] if sys.platform == "win32" else ["which", tool],
                    capture_output=True, text=True
                )
                if result.returncode == 0:
                    installed.append(tool)
            if installed:
                installed_tools[category] = installed

        return installed_tools

    def generate_readme(self, output_file="README.md"):
        """Generate complete README.md."""
        metadata = self.get_project_metadata()
        tools = self.get_tools_list()

        sections = []

        sections.append(f"# {metadata['name']}\n")

        if metadata['description']:
            sections.append(f"{metadata['description']}\n")

        sections.append(f"**Version**: {metadata['version']}  ")
        if metadata['author']:
            sections.append(f"**Author**: {metadata['author']}  ")
        if metadata['license']:
            sections.append(f"**License**: {metadata['license']}  ")
        sections.append("")

        sections.append("## Overview\n")
        sections.append("This automated toolchain provides comprehensive security testing capabilities ")
        sections.append("for authorized bug bounty engagements.\n")

        if tools:
            sections.append("## Included Tools\n")
            for category, tool_list in tools.items():
                sections.append(f"### {category.replace('_', ' ').title()}\n")
                for tool in tool_list:
                    sections.append(f"- {tool}")
                sections.append("")

        sections.append("## Installation\n")
        sections.append("```bash")
        sections.append("# Clone the repository")
        sections.append("git clone <repository-url>")
        sections.append("cd <repository-name>")
        sections.append("")
        sections.append("# Install dependencies")
        if metadata['dependencies']:
            sections.append("pip install -r requirements.txt")
        sections.append("```\n")

        sections.append("## Quick Start\n")
        sections.append("```bash")
        sections.append("# Initialize the toolchain")
        sections.append("python setup.py")
        sections.append("")
        sections.append("# Run a basic scan")
        sections.append("python scan.py --target test_target")
        sections.append("```\n")

        sections.append("## Configuration\n")
        sections.append("See [Configuration Guide](docs/configuration.md) for detailed settings.\n")

        sections.append("## Usage Examples\n")
        sections.append("See [Examples](docs/examples.md) for practical usage scenarios.\n")

        sections.append("## Contributing\n")
        sections.append("Contributions are welcome. Please read CONTRIBUTING.md before submitting PRs.\n")

        sections.append("## License\n")
        sections.append(f"This project is licensed under the {metadata['license'] or 'MIT'} License.\n")

        sections.append(f"---\n*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} by Documentation Automation*")

        content = "\n".join(sections)

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(content)

        print(f"README generated: {output_file}")
        return output_file


def main():
    """Generate README for the project."""
    project_path = sys.argv[1] if len(sys.argv) > 1 else "."
    generator = ReadmeGenerator(project_path)
    generator.generate_readme()


if __name__ == "__main__":
    main()
```

### Step 5: Documentation Pipeline Orchestrator

```python
#!/usr/bin/env python3
"""Documentation pipeline orchestrator - runs all documentation automation steps."""

import json
import sys
from datetime import datetime
from pathlib import Path


class DocumentationPipeline:
    """Orchestrate the full documentation automation pipeline."""

    def __init__(self, config_file=None):
        self.config = self._load_config(config_file)
        self.results = {}

    def _load_config(self, config_file):
        """Load pipeline configuration."""
        default_config = {
            "source_dirs": ["./src"],
            "output_dir": "./docs",
            "validate": True,
            "generate_readme": True,
            "generate_changelog": True,
            "generate_api_docs": True
        }

        if config_file and Path(config_file).exists():
            with open(config_file) as f:
                return json.load(f)

        return default_config

    def run_extraction(self):
        """Run documentation extraction step."""
        print("[1/5] Extracting documentation from source code...")

        try:
            from doc_extractor import DocumentationExtractor
            extractor = DocumentationExtractor()

            for source_dir in self.config["source_dirs"]:
                extractor.extract_from_directory(source_dir)

            api_docs = extractor.generate_markdown()
            output_file = Path(self.config["output_dir"]) / "API_REFERENCE.md"
            output_file.parent.mkdir(parents=True, exist_ok=True)

            with open(output_file, "w") as f:
                f.write(api_docs)

            self.results["extraction"] = {
                "status": "success",
                "modules": len(extractor.modules),
                "output": str(output_file)
            }
            print(f"  Generated API reference ({len(extractor.modules)} modules)")

        except ImportError:
            print("  Skipping extraction (doc_extractor not available)")
            self.results["extraction"] = {"status": "skipped"}

    def run_changelog(self):
        """Run changelog generation step."""
        print("[2/5] Generating changelog...")

        try:
            from changelog_gen import ChangelogGenerator
            generator = ChangelogGenerator()
            generator.fetch_commits()

            output_file = Path(self.config["output_dir"]) / "CHANGELOG.md"
            output_file.parent.mkdir(parents=True, exist_ok=True)
            generator.generate_full_changelog(str(output_file))

            self.results["changelog"] = {
                "status": "success",
                "commits": len(generator.commits),
                "output": str(output_file)
            }
            print(f"  Generated changelog ({len(generator.commits)} commits)")

        except ImportError:
            print("  Skipping changelog (changelog_gen not available)")
            self.results["changelog"] = {"status": "skipped"}

    def run_validation(self):
        """Run documentation validation step."""
        print("[3/5] Validating documentation...")

        if not self.config.get("validate", True):
            print("  Validation disabled in config")
            self.results["validation"] = {"status": "disabled"}
            return

        try:
            from doc_validator import DocumentationValidator
            validator = DocumentationValidator()

            output_dir = Path(self.config["output_dir"])
            if output_dir.exists():
                validator.validate_directory(str(output_dir))

            report = validator.generate_report()
            self.results["validation"] = {
                "status": "success",
                "issues": report["summary"]["total_issues"],
                "errors": report["summary"]["errors"]
            }
            print(f"  Validation complete ({report['summary']['total_issues']} issues)")

        except ImportError:
            print("  Skipping validation (doc_validator not available)")
            self.results["validation"] = {"status": "skipped"}

    def run_readme_generation(self):
        """Run README generation step."""
        print("[4/5] Generating README...")

        if not self.config.get("generate_readme", True):
            print("  README generation disabled in config")
            self.results["readme"] = {"status": "disabled"}
            return

        try:
            from readme_gen import ReadmeGenerator
            generator = ReadmeGenerator()
            output_file = generator.generate_readme()

            self.results["readme"] = {
                "status": "success",
                "output": output_file
            }
            print(f"  Generated {output_file}")

        except ImportError:
            print("  Skipping README generation (readme_gen not available)")
            self.results["readme"] = {"status": "skipped"}

    def generate_report(self):
        """Generate pipeline execution report."""
        print("[5/5] Generating report...")

        report = {
            "timestamp": datetime.now().isoformat(),
            "results": self.results,
            "summary": {
                "total_steps": len(self.results),
                "successful": sum(1 for r in self.results.values() if r.get("status") == "success"),
                "skipped": sum(1 for r in self.results.values() if r.get("status") == "skipped"),
                "failed": sum(1 for r in self.results.values() if r.get("status") == "failed")
            }
        }

        output_file = Path(self.config["output_dir"]) / "pipeline_report.json"
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, "w") as f:
            json.dump(report, f, indent=2)

        print(f"\n{'='*60}")
        print(f"DOCUMENTATION PIPELINE COMPLETE")
        print(f"{'='*60}")
        print(f"Successful: {report['summary']['successful']}/{report['summary']['total_steps']}")
        print(f"Skipped:    {report['summary']['skipped']}")
        print(f"Failed:     {report['summary']['failed']}")
        print(f"Report:     {output_file}")
        print(f"{'='*60}\n")

        return report

    def run(self):
        """Execute the complete pipeline."""
        print(f"\n{'='*60}")
        print(f"DOCUMENTATION AUTOMATION PIPELINE")
        print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}\n")

        Path(self.config["output_dir"]).mkdir(parents=True, exist_ok=True)

        self.run_extraction()
        self.run_changelog()
        self.run_validation()
        self.run_readme_generation()

        return self.generate_report()


def main():
    """Run the documentation pipeline."""
    config_file = sys.argv[1] if len(sys.argv) > 1 else None

    pipeline = DocumentationPipeline(config_file)
    pipeline.run()


if __name__ == "__main__":
    main()
```

---

## Tool Arsenal

### Documentation Commands

```bash
# Sphinx documentation
sphinx-build -b html docs/ docs/_build/html   # Build HTML docs
sphinx-apidoc -o docs/api/ src/               # Generate API docs

# MkDocs
mkdocs build                                  # Build documentation site
mkdocs serve                                  # Serve documentation locally

# Link checking
markdown-link-check README.md                 # Check links in README
linkchecker docs/_build/html/                 # Check links in HTML docs

# Format checking
mdformat --check *.md                         # Check Markdown formatting
mdl *.md                                      # Markdown linting

# Changelog
conventional-changelog -p angular             # Generate changelog
git-changelog                                 # Alternative changelog generator
```

### Template Examples

```jinja2
{# README template (templates/README.md.j2) #}
# {{ project.name }}

{{ project.description }}

**Version**: {{ project.version }}
**Author**: {{ project.author }}

## Installation

```bash
pip install {{ project.name }}
```

{% if project.tools %}
## Tools

{% for category, tools in project.tools.items() %}
### {{ category | title }}

{% for tool in tools %}
- {{ tool }}
{% endfor %}
{% endfor %}
{% endif %}

## Usage

```python
from {{ project.name }} import main
main()
```

## License

{{ project.license }}
```

```jinja2
{# CHANGELOG template (templates/CHANGELOG.md.j2) #}
# Changelog

{% for version in versions %}
## [{{ version.tag }}] - {{ version.date }}

{% for type, commits in version.groups.items() %}
### {{ type | title }}

{% for commit in commits %}
- {{ commit.description }} ({{ commit.hash }})
{% endfor %}
{% endfor %}
{% endfor %}
```

---

## Real-World Examples

### Example 1: Automated API Documentation for Tool Scripts

```python
# Generate API docs for all Python scripts in the toolchain
import subprocess
import json
from pathlib import Path


def generate_tool_api_docs():
    """Generate API documentation for all tool wrapper scripts."""
    scripts_dir = Path("./scripts")
    docs_dir = Path("./docs/api")
    docs_dir.mkdir(parents=True, exist_ok=True)

    for script in scripts_dir.glob("*.py"):
        if script.name.startswith("_"):
            continue

        print(f"Documenting {script.name}...")

        result = subprocess.run(
            [sys.executable, "-m", "pydoc", "-w", str(script)],
            capture_output=True, text=True
        )

        html_file = scripts_dir / f"{script.stem}.html"
        if html_file.exists():
            html_file.rename(docs_dir / html_file.name)
            print(f"  Generated {docs_dir / html_file.name}")


if __name__ == "__main__":
    generate_tool_api_docs()
```

### Example 2: Documentation Coverage Report

```python
"""Generate documentation coverage report for the toolchain."""

import json
from pathlib import Path
from datetime import datetime


def calculate_coverage(project_path):
    """Calculate documentation coverage metrics."""
    project = Path(project_path)

    metrics = {
        "python_files": 0,
        "python_documented": 0,
        "markdown_files": 0,
        "config_files": 0,
        "total_lines": 0,
        "documented_lines": 0
    }

    for py_file in project.rglob("*.py"):
        if py_file.name.startswith("__"):
            continue
        metrics["python_files"] += 1

        content = py_file.read_text(encoding="utf-8", errors="ignore")
        metrics["total_lines"] += len(content.split("\n"))

        if '"""' in content or "'''" in content:
            metrics["python_documented"] += 1
            metrics["documented_lines"] += content.count('"""') // 2
            metrics["documented_lines"] += content.count("'''") // 2

    for md_file in project.rglob("*.md"):
        metrics["markdown_files"] += 1

    for config_file in project.rglob("*.yaml"):
        metrics["config_files"] += 1
    for config_file in project.rglob("*.json"):
        metrics["config_files"] += 1

    coverage = {
        "python_doc_coverage": (
            metrics["python_documented"] / metrics["python_files"]
            if metrics["python_files"] > 0 else 0
        ),
        "line_doc_coverage": (
            metrics["documented_lines"] / metrics["total_lines"]
            if metrics["total_lines"] > 0 else 0
        ),
        "has_readme": (project / "README.md").exists(),
        "has_changelog": (project / "CHANGELOG.md").exists(),
        "has_license": (project / "LICENSE").exists()
    }

    print(f"\n{'='*60}")
    print(f"DOCUMENTATION COVERAGE REPORT")
    print(f"{'='*60}")
    print(f"Python files:      {metrics['python_files']}")
    print(f"Documented:        {metrics['python_documented']}")
    print(f"Coverage:          {coverage['python_doc_coverage']*100:.1f}%")
    print(f"Markdown files:    {metrics['markdown_files']}")
    print(f"Config files:      {metrics['config_files']}")
    print(f"README:            {'YES' if coverage['has_readme'] else 'NO'}")
    print(f"CHANGELOG:         {'YES' if coverage['has_changelog'] else 'NO'}")
    print(f"LICENSE:           {'YES' if coverage['has_license'] else 'NO'}")
    print(f"{'='*60}\n")

    return coverage


if __name__ == "__main__":
    import sys
    calculate_coverage(sys.argv[1] if len(sys.argv) > 1 else ".")
```

### Example 3: Auto-Update Documentation on Config Change

```python
"""Watch for config changes and regenerate documentation."""

import time
import json
from pathlib import Path
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class DocUpdateHandler(FileSystemEventHandler):
    """Handle file changes to trigger documentation regeneration."""

    def __init__(self, pipeline):
        self.pipeline = pipeline
        self.debounce_seconds = 5
        self.last_run = 0

    def on_modified(self, event):
        if event.is_directory:
            return

        file_path = Path(event.src_path)
        if file_path.suffix in (".py", ".yaml", ".json", ".toml"):
            current_time = time.time()
            if current_time - self.last_run > self.debounce_seconds:
                print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Change detected: {file_path.name}")
                print("Regenerating documentation...")
                self.pipeline.run()
                self.last_run = current_time


def watch_and_regenerate(config_file=None):
    """Watch for changes and regenerate documentation."""
    from doc_pipeline import DocumentationPipeline

    pipeline = DocumentationPipeline(config_file)
    handler = DocUpdateHandler(pipeline)

    observer = Observer()
    observer.schedule(handler, path=".", recursive=True)
    observer.start()

    print("Watching for changes... (Press Ctrl+C to stop)")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    import sys
    watch_and_regenerate(sys.argv[1] if len(sys.argv) > 1 else None)
```

---

## Common Pitfalls

### Pitfall 1: Documentation Drift

**Problem**: Documentation becomes outdated as code changes, leading to inaccurate guides.

**Prevention**:
```python
# Check documentation freshness
from datetime import datetime, timedelta
from pathlib import Path

def check_doc_freshness(doc_file, max_age_days=30):
    """Check if documentation is stale."""
    path = Path(doc_file)
    if not path.exists():
        return False, "File not found"

    mtime = datetime.fromtimestamp(path.stat().st_mtime)
    age = datetime.now() - mtime

    is_fresh = age.days <= max_age_days
    return is_fresh, f"Last updated: {age.days} days ago"
```

### Pitfall 2: Broken Links After Restructuring

**Problem**: Moving or renaming files breaks internal documentation links.

**Prevention**:
```python
# Automated link checking in CI
import re
from pathlib import Path

def check_all_links(doc_dir):
    """Check all markdown links in documentation."""
    broken = []
    for md_file in Path(doc_dir).rglob("*.md"):
        content = md_file.read_text()
        for match in re.finditer(r'\[([^\]]+)\]\(([^)]+)\)', content):
            link = match.group(2)
            if not link.startswith("http"):
                target = md_file.parent / link
                if not target.exists():
                    broken.append((str(md_file), link))

    return broken
```

### Pitfall 3: Inconsistent Formatting

**Problem**: Different documentation files use different formatting styles.

**Prevention**:
```bash
# Add to CI pipeline
mdformat --check docs/**/*.md
mdl docs/**/*.md
```

### Pitfall 4: Missing Examples

**Problem**: Documentation describes features but provides no usage examples.

**Prevention**:
```python
# Track example coverage
def check_example_coverage(doc_file):
    """Verify documented items include examples."""
    content = Path(doc_file).read_text()

    functions = re.findall(r'#### `(\w+)`', content)
    examples = re.findall(r'```python', content)

    return len(examples) >= len(functions) * 0.7
```

### Pitfall 5: Not Generating Changelog

**Problem**: Releases ship without changelogs, frustrating users.

**Prevention**:
```bash
# Add to git hook or CI
conventional-changelog -p angular -i CHANGELOG.md -s
```

---

## Advanced Techniques

### Semantic Versioning Automation

```python
"""Automated semantic versioning based on conventional commits."""

import subprocess
import re
from pathlib import Path


def determine_version_bump():
    """Determine version bump type from commits."""
    result = subprocess.run(
        ["git", "log", "--pretty=format:%s", "HEAD~20..HEAD"],
        capture_output=True, text=True
    )

    commits = result.stdout.strip().split("\n")

    has_breaking = any("!" in c or "BREAKING" in c.upper() for c in commits)
    has_feat = any(c.startswith("feat") for c in commits)
    has_fix = any(c.startswith("fix") for c in commits)

    if has_breaking:
        return "major"
    elif has_feat:
        return "minor"
    elif has_fix:
        return "patch"
    else:
        return None


def get_current_version():
    """Get current version from git tags."""
    result = subprocess.run(
        ["git", "describe", "--tags", "--abbrev=0"],
        capture_output=True, text=True
    )

    if result.returncode == 0:
        return result.stdout.strip().lstrip("v")
    return "0.0.0"


def calculate_new_version():
    """Calculate new version based on commits."""
    current = get_current_version()
    bump_type = determine_version_bump()

    if not bump_type:
        print("No version bump needed")
        return current

    major, minor, patch = map(int, current.split("."))

    if bump_type == "major":
        return f"{major + 1}.0.0"
    elif bump_type == "minor":
        return f"{major}.{minor + 1}.0"
    else:
        return f"{major}.{minor}.{patch + 1}"


if __name__ == "__main__":
    new_version = calculate_new_version()
    print(f"New version: {new_version}")
```

### Documentation Metrics Dashboard

```python
"""Documentation metrics dashboard."""

import json
from pathlib import Path
from datetime import datetime


def collect_metrics(project_path):
    """Collect comprehensive documentation metrics."""
    project = Path(project_path)

    metrics = {
        "timestamp": datetime.now().isoformat(),
        "files": {
            "readme": (project / "README.md").exists(),
            "changelog": (project / "CHANGELOG.md").exists(),
            "contributing": (project / "CONTRIBUTING.md").exists(),
            "license": (project / "LICENSE").exists(),
            "api_docs": list(project.rglob("docs/api/*.md")),
            "guides": list(project.rglob("docs/guides/*.md"))
        },
        "coverage": {},
        "quality": {}
    }

    # File counts
    metrics["files"]["api_docs_count"] = len(metrics["files"]["api_docs"])
    metrics["files"]["guides_count"] = len(metrics["files"]["guides"])

    # Coverage
    total_py = len(list(project.rglob("*.py")))
    documented_py = sum(
        1 for f in project.rglob("*.py")
        if '"""' in f.read_text(encoding="utf-8", errors="ignore")
    )

    metrics["coverage"]["python_files"] = total_py
    metrics["coverage"]["documented"] = documented_py
    metrics["coverage"]["percentage"] = (
        documented_py / total_py * 100 if total_py > 0 else 0
    )

    return metrics


def print_dashboard(metrics):
    """Print metrics dashboard."""
    print(f"\n{'='*60}")
    print(f"DOCUMENTATION METRICS DASHBOARD")
    print(f"Generated: {metrics['timestamp']}")
    print(f"{'='*60}")

    print(f"\nEssential Files:")
    for key, exists in metrics["files"].items():
        if isinstance(exists, bool):
            status = "PRESENT" if exists else "MISSING"
            print(f"  {key.replace('_', ' ').title():.<30} {status}")

    print(f"\nCoverage:")
    cov = metrics["coverage"]
    print(f"  Python files:   {cov['python_files']}")
    print(f"  Documented:     {cov['documented']}")
    print(f"  Coverage:       {cov['percentage']:.1f}%")

    print(f"\n{'='*60}\n")


if __name__ == "__main__":
    import sys
    metrics = collect_metrics(sys.argv[1] if len(sys.argv) > 1 else ".")
    print_dashboard(metrics)
```

### Multi-Format Publishing

```python
"""Publish documentation in multiple formats."""

import subprocess
from pathlib import Path


def publish_html(source_md, output_dir):
    """Convert Markdown to HTML."""
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)

    result = subprocess.run(
        ["pandoc", source_md, "-o", str(output / "index.html"),
         "--standalone", "--toc", "--highlight-style=tango"],
        capture_output=True, text=True
    )

    return result.returncode == 0


def publish_pdf(source_md, output_dir):
    """Convert Markdown to PDF."""
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)

    result = subprocess.run(
        ["pandoc", source_md, "-o", str(output / "documentation.pdf"),
         "--pdf-engine=xelatex", "--toc"],
        capture_output=True, text=True
    )

    return result.returncode == 0


def publish_terminal(source_md, output_dir):
    """Convert Markdown to terminal-friendly format."""
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)

    with open(source_md) as f:
        content = f.read()

    import re
    terminal_text = re.sub(r'#{1,6}\s+', '\n### ', content)
    terminal_text = re.sub(r'```[\s\S]*?```', '[code block]', terminal_text)
    terminal_text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', terminal_text)

    output_file = output / "documentation.txt"
    with open(output_file, "w") as f:
        f.write(terminal_text)

    return True


def publish_all(formats=("html", "pdf", "terminal")):
    """Publish documentation in all specified formats."""
    source = "docs/API_REFERENCE.md"
    output_base = "docs/site"

    publishers = {
        "html": publish_html,
        "pdf": publish_pdf,
        "terminal": publish_terminal
    }

    for fmt in formats:
        if fmt in publishers:
            output_dir = f"{output_base}/{fmt}"
            success = publishers[fmt](source, output_dir)
            status = "SUCCESS" if success else "FAILED"
            print(f"  [{status}] Published to {fmt}")


if __name__ == "__main__":
    publish_all()
```

---

## Reporting Template

### Documentation Activity Report

```
# Documentation Activity Report

**Date**: [DATE]
**Pipeline Run**: [RUN_ID]
**Duration**: [DURATION]

## Summary

| Metric | Value |
|--------|-------|
| Files Generated | [N] |
| Files Updated | [N] |
| Links Checked | [N] |
| Broken Links Found | [N] |
| Coverage Score | [SCORE]% |

## Generated Documentation

| File | Type | Size | Last Modified |
|------|------|------|---------------|
| [filename] | [README/API/CHANGELOG] | [size] | [date] |

## Validation Results

| Check | Status | Issues |
|-------|--------|--------|
| Link checking | [PASS/FAIL] | [N] broken |
| Format linting | [PASS/FAIL] | [N] warnings |
| Completeness | [PASS/FAIL] | [N] missing sections |

## Coverage Metrics

| Category | Documented | Total | Coverage |
|----------|------------|-------|----------|
| Python functions | [N] | [N] | [X]% |
| Python classes | [N] | [N] | [X]% |
| Configuration options | [N] | [N] | [X]% |

## Recommendations

1. [recommendation_1]
2. [recommendation_2]
3. [recommendation_3]

## Next Steps

- [ ] [action_item_1]
- [ ] [action_item_2]
- [ ] [action_item_3]
```

---

## Quick Reference

### Documentation Commands Cheat Sheet

```bash
# Documentation generation
python doc_extractor.py ./src              # Extract API docs from Python
python changelog_gen.py                    # Generate changelog
python readme_gen.py                       # Generate README
python doc_validator.py ./docs             # Validate documentation
python doc_pipeline.py                     # Run full pipeline

# Markdown tools
mdformat --check *.md                      # Check formatting
markdown-link-check README.md              # Check links
pandoc input.md -o output.html             # Convert formats

# Sphinx
sphinx-build -b html docs/ docs/_build/    # Build docs
sphinx-apidoc -o docs/ src/               # Generate API docs

# MkDocs
mkdocs build                               # Build site
mkdocs serve                               # Local preview
```

### Documentation Checklist

- [ ] README.md with project overview
- [ ] CHANGELOG.md with version history
- [ ] API documentation for all public functions
- [ ] Configuration guide
- [ ] Usage examples with runnable code
- [ ] Contributing guidelines
- [ ] License file
- [ ] All internal links working
- [ ] No broken code examples
- [ ] Consistent formatting throughout

### Template Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `{{ project.name }}` | Project name | "Bug Bounty Toolchain" |
| `{{ project.version }}` | Current version | "2.0.0" |
| `{{ project.description }}` | Project description | "Security testing..." |
| `{{ commit.type }}` | Commit type | "feat", "fix" |
| `{{ commit.scope }}` | Commit scope | "nuclei", "api" |
| `{{ commit.description }}` | Commit description | "Add new template" |

---

*Last Updated: [DATE]*
*Version: 2.0*
*Author: Documentation Automation Guide v2*
