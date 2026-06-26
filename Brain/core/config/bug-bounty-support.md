# Config: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Configuration Schema

Configuration for the master reference framework and support prompts.

```yaml
support:
  # Knowledge Base
  knowledge_base:
    path: "./support_prompts"
    auto_index: true
    index_interval: 3600
    supported_formats: ["md", "txt", "json"]
    max_context_tokens: 50000

  # Framework Management
  frameworks:
    auto_load: true
    version_tracking: true
    compatibility_check: true
    min_relevance_score: 0.3

  # Methodology Suggestion
  methodology:
    auto_suggest: true
    context_aware: true
    target_profiling: true
    max_suggestions: 3

  # Template Library
  templates:
    path: "./report_templates"
    auto_update: true
    platforms: ["hackerone", "bugcrowd", "intigriti"]
    vuln_classes: 50

  # Scope Analysis
  scope:
    auto_parse: true
    asset_discovery: true
    boundary_enforcement: true
    warning_on_out_of_scope: true

  # Tool Recommendations
  tools:
    auto_recommend: true
    tool_database: "./tool_catalog.json"
    include_alternatives: true
    version_check: true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_SUPPORT_KB_PATH` | `./support_prompts` | Knowledge base path |
| `BRAIN_SUPPORT_MAX_TOKENS` | 50000 | Max context tokens |
| `BRAIN_SUPPORT_AUTO_SUGGEST` | true | Auto-suggest methodologies |
