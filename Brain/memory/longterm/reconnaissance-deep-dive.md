# Long-Term Memory: Reconnaissance Deep-Dive

## Domain Mapping

- **Domain**: Reconnaissance Deep-Dive
- **Root Directory**: `Reconnaissance-Deep-Dive/`
- **Total Files**: 50 (including README.md)
- **Purpose**: Persistent memory for historical asset data, OSINT cache, technology fingerprints, and recon intelligence

---

## Overview

This long-term memory system stores the accumulated knowledge from reconnaissance operations. It maintains asset inventories, technology fingerprints, OSINT caches, and discovery patterns that accelerate future recon on familiar targets.

### Memory Categories

1. **Asset Inventory** - Complete asset database for targets
2. **Technology Fingerprints** - Detected technologies and versions
3. **OSINT Cache** - Cached intelligence data
4. **Discovery History** - Historical recon results
5. **Correlation Database** - Asset relationship mappings

---

## Storage Schema

### Asset Inventory Record

```json
{
  "asset_id": "uuid-v4",
  "target_domain": "string",
  "asset_type": "enum: subdomain|ip|port|service|certificate|url|endpoint",
  "asset_value": "string",
  "metadata": {
    "first_seen": "ISO-8601",
    "last_seen": "ISO-8601",
    "status": "enum: active|inactive|unknown",
    "ip_addresses": ["array"],
    "ports": ["array"],
    "services": ["array"],
    "technology_stack": ["array"]
  },
  "source": "enum: dns|scan|crawl|osint|certificate|manual",
  "confidence": "float 0-1",
  "in_scope": "boolean",
  "notes": "string",
  "created": "ISO-8601",
  "last_updated": "ISO-8601"
}
```

### Technology Fingerprint Record

```json
{
  "fingerprint_id": "string",
  "target_domain": "string",
  "technology": "string",
  "category": "enum: web_server|framework|cms|language|database|cdn|analytics|security",
  "version": "string",
  "detection_method": "string",
  "confidence": "float 0-1",
  "endpoints": ["array of URLs"],
  "known_vulnerabilities": ["array"],
  "first_detected": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

### OSINT Cache Record

```json
{
  "cache_id": "string",
  "query": "string",
  "source": "enum: google|bing|github|pastebin|shodan|censys|other",
  "results": [
    {
      "result_url": "string",
      "title": "string",
      "snippet": "string",
      "relevance_score": "float 0-1"
    }
  ],
  "total_results": "integer",
  "cached_date": "ISO-8601",
  "expires_date": "ISO-8601",
  "hit_count": "integer"
}
```

### Discovery History Record

```json
{
  "discovery_id": "uuid-v4",
  "target_domain": "string",
  "recon_type": "enum: passive|active|osint|deep",
  "tools_used": ["array"],
  "findings": {
    "subdomains_found": "integer",
    "ips_found": "integer",
    "ports_found": "integer",
    "endpoints_found": "integer",
    "technologies_found": "integer",
    "credentials_found": "integer"
  },
  "duration_minutes": "float",
  "new_assets": "integer",
  "updated_assets": "integer",
  "completed_date": "ISO-8601",
  "notes": "string"
}
```

### Correlation Record

```json
{
  "correlation_id": "string",
  "asset_id_1": "string",
  "asset_id_2": "string",
  "relationship_type": "enum: resolves_to|points_to|hosted_on|shares_ip|related_to",
  "confidence": "float 0-1",
  "evidence": ["array"],
  "first_observed": "ISO-8601",
  "last_verified": "ISO-8601"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/recon/assets
POST /memory/longterm/recon/fingerprints
POST /memory/longterm/recon/osint-cache
POST /memory/longterm/recon/discovery-history
POST /memory/longterm/recon/correlations
```

### Read

```
GET /memory/longterm/recon/assets/{asset_id}
GET /memory/longterm/recon/assets?target_domain={domain}&asset_type={type}
GET /memory/longterm/recon/fingerprints?target_domain={domain}
GET /memory/longterm/recon/osint-cache?query={query}&source={source}
GET /memory/longterm/recon/discovery-history?target_domain={domain}
GET /memory/longterm/recon/correlations?asset_id={id}
```

### Update

```
PATCH /memory/longterm/recon/assets/{asset_id}/metadata
PUT /memory/longterm/recon/fingerprints/{fingerprint_id}/version
PATCH /memory/longterm/recon/osint-cache/{cache_id}/hit_count
```

### Delete

```
DELETE /memory/longterm/recon/assets/{asset_id} (archive)
DELETE /memory/longterm/recon/osint-cache/{cache_id}
DELETE /memory/longterm/recon/correlations/{correlation_id}
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Asset Inventory | 90 days active | Assets change frequently |
| Technology Fingerprints | 60 days | Technology stacks evolve |
| OSINT Cache | 30 days | OSINT data ages quickly |
| Discovery History | 365 days | Historical data valuable |
| Correlations | 90 days | Relationships change |

### TTL Enforcement

```python
def enforce_recon_ttl():
    assets.flag_stale_after_days(90)
    fingerprints.refresh_after_days(60)
    osint_cache.expire_after_days(30)
    discovery_history.archive_after_days(365)
    correlations.verify_after_days(90)
```

---

## Compression

### Compression Strategy

- **Asset Inventory**: GZIP (JSON arrays)
- **Technology Fingerprints**: None (small records)
- **OSINT Cache**: GZIP (search results)
- **Discovery History**: GZIP (detailed results)
- **Correlations**: None (small records)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "assets": {
    "asset_id": "primary_key",
    "target_domain": "btree_index",
    "asset_type": "hash_index",
    "status": "hash_index",
    "last_seen": "btree_index"
  },
  "fingerprints": {
    "fingerprint_id": "primary_key",
    "target_domain": "btree_index",
    "technology": "hash_index",
    "category": "hash_index"
  },
  "osint_cache": {
    "cache_id": "primary_key",
    "query": "hash_index",
    "source": "hash_index",
    "expires_date": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "domain_assets": ["target_domain", "asset_type", "status"],
  "technology_versions": ["target_domain", "technology", "version"],
  "osint_effectiveness": ["source", "total_results", "hit_count"]
}
```

---

## Retrieval Patterns

### Pattern 1: Asset Discovery Delta

```
SELECT asset_id, asset_value, asset_type, metadata
FROM assets
WHERE target_domain = ?
  AND last_seen > ?
  AND first_seen > ?
ORDER BY asset_type, asset_value
```

**Find newly discovered assets since last recon.

### Pattern 2: Technology Stack Analysis

```
SELECT technology, category, version, confidence,
       COUNT(DISTINCT endpoints) as endpoint_count
FROM fingerprints
WHERE target_domain = ?
GROUP BY technology, category, version, confidence
ORDER BY category, technology
```

**Map the complete technology stack.

### Pattern 3: OSINT Cache Hit Analysis

```
SELECT source, query,
       total_results, hit_count,
       cached_date, expires_date
FROM osint_cache
WHERE query LIKE ?
  AND expires_date > NOW()
ORDER BY hit_count DESC
```

**Find high-value cached OSINT data.

### Pattern 4: Asset Correlation Graph

```
SELECT c.asset_id_1, a1.asset_value as value_1,
       c.relationship_type,
       c.asset_id_2, a2.asset_value as value_2,
       c.confidence
FROM correlations c
JOIN assets a1 ON c.asset_id_1 = a1.asset_id
JOIN assets a2 ON c.asset_id_2 = a2.asset_id
WHERE a1.target_domain = ?
  OR a2.target_domain = ?
ORDER BY c.confidence DESC
```

**Build the asset relationship graph.

### Pattern 5: Recon Efficiency Analysis

```
SELECT recon_type,
       COUNT(*) as total_runs,
       AVG(duration_minutes) as avg_duration,
       AVG(new_assets) as avg_new_assets,
       AVG(findings.endpoints_found) as avg_endpoints
FROM discovery_history
WHERE target_domain = ?
GROUP BY recon_type
ORDER BY avg_new_assets DESC
```

**Analyze which recon types yield the most results.

---

## Consolidation Triggers

### Automatic Consolidation

1. **Daily**: Verify asset status (active/inactive)
2. **Weekly**: Refresh technology fingerprints
3. **Monthly**: Archive old OSINT cache entries
4. **Quarterly**: Rebuild correlation graph

### Event-Triggered Consolidation

1. **New asset discovered**: Update correlation graph
2. **Technology version change**: Update fingerprint record
3. **Asset goes inactive**: Mark for review
4. **OSINT cache expires**: Remove or refresh

### Manual Consolidation

```
POST /memory/longterm/recon/consolidate
{
  "action": "verify_assets|refresh_fingerprints|rebuild_correlations",
  "target_domain": "optional filter"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Advanced-Automation | Output | Asset data for scanning |
| Core-Prompts-Hunting | Output | Technology stack for testing |
| Reconnaissance-Deep-Dive | Input | Recon results |
| Specialized-Targets | Bidirectional | Target-specific recon |

---

## Domain File References

### Subdomain & Asset Discovery (Files 01-10)

1. `01-Advanced-Subdomain-Enumeration.md` - Subdomain discovery
2. `02-Passive-OSINT-Collection.md` - Passive recon
3. `03-Active-Asset-Discovery.md` - Active asset discovery
4. `04-Technology-Stack-Fingerprinting.md` - Tech fingerprinting
5. `05-Cloud-Resource-Enumeration.md` - Cloud asset discovery
6. `06-API-Endpoint-Discovery.md` - API endpoint discovery
7. `07-JavaScript-Source-Analysis.md` - JS source analysis
8. `08-Configuration-File-Extraction.md` - Config file discovery
9. `09-Version-Detection-Techniques.md` - Version detection
10. `10-Content-Discovery-Automation.md` - Content discovery

### Deep Reconnaissance (Files 11-20)

11. `11-Directory-Brute-Forcing.md` - Directory brute-forcing
12. `12-File-Type-Detection.md` - File type analysis
13. `13-Backup-File-Discovery.md` - Backup file discovery
14. `14-Source-Code-Leak-Detection.md` - Source code leaks
15. `15-Git-Repository-Analysis.md` - Git repo analysis
16. `16-DNS-Enumeration-Advanced.md` - Advanced DNS recon
17. `17-Certificate-Transparency-Logs.md` - CT log analysis
18. `18-Historical-Data-Analysis.md` - Historical data
19. `19-Social-Media-OSINT.md` - Social media OSINT
20. `20-Employee-Linked-Assets.md` - Employee asset mapping

### Intelligence Gathering (Files 21-30)

21. `21-Third-Party-Integration-Discovery.md` - Third-party discovery
22. `22-Web-Archive-Analysis.md` - Wayback analysis
23. `23-Pastebin-and-Leak-Searching.md` - Leak searching
24. `24-Code-Repository-Mining.md` - Code repo mining
25. `25-Container-Registry-Enumeration.md` - Container registry
26. `26-IoT-Device-Discovery.md` - IoT discovery
27. `27-Mobile-App-Analysis.md` - Mobile app recon
28. `28-API-Documentation-Extraction.md` - API doc extraction
29. `29-WebSocket-Endpoint-Discovery.md` - WebSocket discovery
30. `30-GraphQL-Introspection.md` - GraphQL recon

### Enterprise Reconnaissance (Files 31-40)

31. `31-XML-RPC-and-SOAP-Discovery.md` - XML-RPC/SOAP recon
32. `32-Email-Address-Harvesting.md` - Email harvesting
33. `33-Phone-Number-Enumeration.md` - Phone enumeration
34. `34-Physical-Location-Intelligence.md` - Physical recon
35. `35-Supply-Chain-Asset-Mapping.md` - Supply chain mapping
36. `36-Competitor-Analysis.md` - Competitor recon
37. `37-Partner-Network-Discovery.md` - Partner network
38. `38-Acquisition-Target-Analysis.md` - Acquisition analysis
39. `39-Subsidiary-Asset-Mapping.md` - Subsidiary mapping
40. `40-Regional-Infrastructure-Mapping.md` - Regional mapping

### Advanced Reconnaissance (Files 41-50)

41. `41-Content-Management-System-Detection.md` - CMS detection
42. `42-Framework-and-Library-Identification.md` - Framework ID
43. `43-Server-Configuration-Analysis.md` - Server config analysis
44. `44-SSL-TLS-Certificate-Analysis.md` - SSL/TLS analysis
45. `45-HTTP-Header-Intelligence.md` - Header intelligence
46. `46-Cookie-Analysis-and-Session-Management.md` - Cookie analysis
47. `47-Error-Page-Analysis.md` - Error page analysis
48. `48-Debug-Endpoint-Discovery.md` - Debug endpoint discovery
49. `49-Staging-Environment-Detection.md` - Staging detection
50. `50-Advanced-Reconnaissance-Strategy.md` - Advanced strategy

---

## Asset Discovery Benchmarks

### By Recon Type

| Recon Type | Avg Assets Found | Avg Duration | New Asset Rate |
|------------|------------------|--------------|----------------|
| Passive OSINT | 50-100 | 15 min | 20% |
| Active Discovery | 100-200 | 30 min | 40% |
| Deep Recon | 200-500 | 60 min | 60% |
| Targeted Recon | 20-50 | 45 min | 80% |

### By Target Type

| Target Type | Avg Subdomains | Avg Technologies | Avg Endpoints |
|-------------|----------------|------------------|---------------|
| Small Business | 5-15 | 5-10 | 20-50 |
| Medium Enterprise | 50-200 | 15-30 | 100-500 |
| Large Enterprise | 200-1000 | 30-50 | 500-2000 |
| Tech Company | 500-2000 | 40-60 | 1000-5000 |

---

## Technology Fingerprint Reference

### Detection Methods

| Technology | Detection Method | Confidence |
|------------|-----------------|------------|
| Nginx | Server header | 95% |
| Apache | Server header, error pages | 95% |
| WordPress | wp-admin, generator tag | 90% |
| React | X-Powered-By, source code | 85% |
| Angular | ng-version attribute | 90% |
| Vue.js | Vue devtools, source code | 80% |
| Laravel | Cookie, debug mode | 85% |
| Django | CSRF cookie, admin | 85% |
| Express.js | X-Powered-By | 90% |
| Spring Boot | Actuator endpoints | 90% |

---

## Security Considerations

### Data Sensitivity

- **Asset Inventory**: Confidential - target infrastructure data
- **Technology Fingerprints**: Internal - target technology data
- **OSINT Cache**: Internal - intelligence data
- **Discovery History**: Internal - operational data
- **Correlations**: Internal - relationship data

### Data Protection

- Encrypt asset data at rest
- Restrict access to recon results
- Anonymize shared recon data
- Audit access to OSINT caches
- Protect correlation graphs from competitors

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-11-01 | Initial recon schema |
| 1.1.0 | 2025-02-01 | Added technology fingerprints |
| 1.2.0 | 2025-05-01 | Added OSINT cache |
| 1.3.0 | 2025-08-01 | Added correlation graph |
| 2.0.0 | 2025-11-01 | Complete schema redesign |
