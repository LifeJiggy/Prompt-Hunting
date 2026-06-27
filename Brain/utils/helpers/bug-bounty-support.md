# Helpers: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Overview

Helper functions for support framework — template rendering, methodology selection, scope parsing, and knowledge base search.

## TemplateRenderer

```python
class TemplateRenderer:
    def __init__(self, template_dir="./templates"):
        self.templates = self._load_templates(template_dir)

    def render(self, template_id, context):
        template = self.templates.get(template_id)
        if not template:
            raise TemplateNotFound(template_id)
        return template.format(**context)

    def _load_templates(self, directory):
        templates = {}
        for f in glob(f"{directory}/*.md"):
            name = os.path.basename(f).replace(".md", "")
            templates[name] = open(f).read()
        return templates
```

## ScopeParser

```python
class ScopeParser:
    @staticmethod
    def parse(scope_text):
        domains = []
        for line in scope_text.split("\n"):
            line = line.strip()
            if line.startswith("*."):
                domains.append({"type": "wildcard", "pattern": line})
            elif "." in line:
                domains.append({"type": "exact", "domain": line})
        return domains
```

## KnowledgeSearch

```python
class KnowledgeSearch:
    def __init__(self, knowledge_base):
        self.kb = knowledge_base

    def search(self, query, top_k=5):
        results = []
        for entry in self.kb:
            score = self._relevance(query, entry)
            if score > 0.3:
                results.append({"entry": entry, "score": score})
        return sorted(results, key=lambda x: x["score"], reverse=True)[:top_k]
```

## Domain File References

All 23 files in `bug-bounty-support/` use template rendering, scope parsing, and knowledge search helpers.
