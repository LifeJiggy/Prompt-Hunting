# Automation-Efficiency 28: Data Storage and Retrieval

## Expert Role

You are an elite Bug Bounty Data Infrastructure Engineer specializing in storage systems, caching layers, and data retrieval optimization. Your expertise spans SQLite, PostgreSQL, Redis, and hybrid storage architectures used in bug bounty automation pipelines. You understand how efficient data management directly impacts testing velocity, finding deduplication, and reporting accuracy.

Your core competencies include:
- Designing schema architectures that support rapid querying across millions of subdomains, URLs, and vulnerability records
- Implementing caching strategies that eliminate redundant API calls and network requests
- Building indexing strategies that make complex JOIN operations and full-text searches performant
- Optimizing query patterns that reduce database load during large-scale recon operations
- Architecting storage systems that scale from single-file SQLite to distributed PostgreSQL clusters

---

## Core Concepts

### Storage Tier Selection

| Tier | Engine | Use Case | Scale |
|------|--------|----------|-------|
| Local File | JSON/CSV/YAML | Small recon results, config | < 10K records |
| Embedded DB | SQLite | Single-machine automation, portable findings DB | < 1M records |
| Relational DB | PostgreSQL | Multi-tool pipeline, complex queries, reporting | > 1M records |
| Cache Layer | Redis | Deduplication, rate limit tracking, session state | High-throughput |
| Object Storage | S3/GCS | Large binaries, scan outputs, evidence files | Unlimited |

### Schema Design Principles for Bug Bounty

**Deduplication-First Design**: Every record must have a natural key that prevents duplicates.

```sql
-- Core findings table with deduplication
CREATE TABLE findings (
    id SERIAL PRIMARY KEY,
    target_domain VARCHAR(255) NOT NULL,
    endpoint VARCHAR(512) NOT NULL,
    vuln_class VARCHAR(100) NOT NULL,
    severity VARCHAR(20),
    proof_hash VARCHAR(64) NOT NULL,  -- SHA-256 of PoC evidence
    first_seen TIMESTAMP DEFAULT NOW(),
    last_verified TIMESTAMP,
    status VARCHAR(50) DEFAULT 'new',
    UNIQUE(target_domain, endpoint, vuln_class, proof_hash)
);
```

**Indexing Strategy**: Composite indexes matching common query patterns.

```sql
-- Common query: "Find all critical XSS on target.com"
CREATE INDEX idx_findings_target_severity
ON findings(target_domain, severity, vuln_class);

-- Common query: "Recent findings across all targets"
CREATE INDEX idx_findings_recent
ON findings(last_verified DESC NULLS LAST);

-- Full-text search on endpoint URLs
CREATE INDEX idx_findings_endpoint_gin
ON findings USING gin(endpoint gin_trgm_ops);
```

### Caching Architecture

```
Request Flow:
Client -> Rate Limiter -> Cache Check -> [HIT: Return cached]
                                    -> [MISS: Query DB -> Cache Result -> Return]
```

**Cache Invalidation Strategies**:
- **TTL-based**: Items expire after N seconds (good for rate limit headers)
- **Event-based**: Invalidate on write (good for finding status changes)
- **Hybrid**: TTL with event override (best for most bug bounty data)

---

## Prerequisites

### Required Knowledge
- SQL fundamentals (SELECT, JOIN, GROUP BY, subqueries)
- Python database libraries (sqlite3, psycopg2, redis)
- Basic understanding of B-tree indexes and query plans
- Data modeling concepts (normalization, denormalization trade-offs)

### Required Tools
```bash
pip install psycopg2-binary redis sqlalchemy alembic rich tabulate
```

### SQLite Quick Setup
```bash
# SQLite comes with Python - no additional install needed
python -c "import sqlite3; print('SQLite version:', sqlite3.sqlite_version)"
```

### PostgreSQL Setup (for production pipelines)
```bash
# Install PostgreSQL client
pip install psycopg2-binary asyncpg

# Connect and initialize
python -c "
import psycopg2
conn = psycopg2.connect('postgresql://user:pass@localhost:5432/bounty')
print('Connected to PostgreSQL:', conn.server_version)
conn.close()
"
```

---

## Methodology

### Phase 1: Schema Design and Implementation

**Step 1: Design the Core Schema**

```python
import sqlite3
from datetime import datetime

def create_bounty_database(db_path="bounty.db"):
    """Create optimized schema for bug bounty data storage."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Targets table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS targets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            domain VARCHAR(255) UNIQUE NOT NULL,
            scope_type VARCHAR(50) DEFAULT 'wildcard',
            program_name VARCHAR(255),
            max_bounty INTEGER,
            status VARCHAR(50) DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Subdomains table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS subdomains (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            target_id INTEGER NOT NULL,
            subdomain VARCHAR(255) UNIQUE NOT NULL,
            ip_address VARCHAR(45),
            cname VARCHAR(255),
            status VARCHAR(50) DEFAULT 'pending',
            first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_checked TIMESTAMP,
            FOREIGN KEY (target_id) REFERENCES targets(id)
        )
    """)
    
    # Endpoints table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS endpoints (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subdomain_id INTEGER NOT NULL,
            url VARCHAR(2048) NOT NULL,
            method VARCHAR(10) DEFAULT 'GET',
            status_code INTEGER,
            content_length INTEGER,
            content_type VARCHAR(100),
            response_time_ms REAL,
            last_crawled TIMESTAMP,
            FOREIGN KEY (subdomain_id) REFERENCES subdomains(id),
            UNIQUE(subdomain_id, url, method)
        )
    """)
    
    # Findings table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS findings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint_id INTEGER NOT NULL,
            vuln_class VARCHAR(100) NOT NULL,
            severity VARCHAR(20),
            title VARCHAR(500),
            description TEXT,
            proof_of_concept TEXT,
            proof_hash VARCHAR(64) NOT NULL,
            cvss_score REAL,
            status VARCHAR(50) DEFAULT 'new',
            submitted_at TIMESTAMP,
            reported_at TIMESTAMP,
            first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_verified TIMESTAMP,
            FOREIGN KEY (endpoint_id) REFERENCES endpoints(id),
            UNIQUE(endpoint_id, vuln_class, proof_hash)
        )
    """)
    
    # Scan results table (high-volume, partitioned)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS scan_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            target_id INTEGER NOT NULL,
            scan_type VARCHAR(50) NOT NULL,
            tool_name VARCHAR(100),
            raw_output TEXT,
            parsed_results JSON,
            started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            completed_at TIMESTAMP,
            status VARCHAR(50) DEFAULT 'running',
            FOREIGN KEY (target_id) REFERENCES targets(id)
        )
    """)
    
    # Create indexes
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_subdomains_domain
        ON subdomains(subdomain)
    """)
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_endpoints_url
        ON endpoints(url)
    """)
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_findings_status
        ON findings(status, severity)
    """)
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_findings_vuln_class
        ON findings(vuln_class, severity)
    """)
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_scan_results_target
        ON scan_results(target_id, scan_type)
    """)
    
    conn.commit()
    return conn

print("Database schema created successfully")
```

**Step 2: Implement Data Access Layer**

```python
from contextlib import contextmanager
from dataclasses import dataclass
from typing import Optional, List
import hashlib
import json

@dataclass
class Finding:
    endpoint_id: int
    vuln_class: str
    severity: str
    title: str
    description: str
    proof_of_concept: str
    cvss_score: float = 0.0

class BountyDataStore:
    """Data access layer for bug bounty operations."""
    
    def __init__(self, db_path="bounty.db"):
        self.db_path = db_path
    
    @contextmanager
    def get_connection(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()
    
    def add_target(self, domain, program_name=None, max_bounty=None):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT OR IGNORE INTO targets (domain, program_name, max_bounty)
                VALUES (?, ?, ?)
            """, (domain, program_name, max_bounty))
            return cursor.lastrowid
    
    def add_subdomain(self, target_id, subdomain, ip_address=None):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT OR IGNORE INTO subdomains (target_id, subdomain, ip_address)
                VALUES (?, ?, ?)
            """, (target_id, subdomain, ip_address))
            return cursor.lastrowid
    
    def add_endpoint(self, subdomain_id, url, method="GET"):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT OR IGNORE INTO endpoints (subdomain_id, url, method)
                VALUES (?, ?, ?)
            """, (subdomain_id, url, method))
            return cursor.lastrowid
    
    def add_finding(self, finding: Finding):
        proof_hash = hashlib.sha256(
            finding.proof_of_concept.encode()
        ).hexdigest()
        
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT OR IGNORE INTO findings
                (endpoint_id, vuln_class, severity, title, description,
                 proof_of_concept, proof_hash, cvss_score)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                finding.endpoint_id, finding.vuln_class, finding.severity,
                finding.title, finding.description, finding.proof_of_concept,
                proof_hash, finding.cvss_score
            ))
            return cursor.lastrowid
    
    def get_findings_by_severity(self, severity):
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT f.*, e.url, s.subdomain, t.domain
                FROM findings f
                JOIN endpoints e ON f.endpoint_id = e.id
                JOIN subdomains s ON e.subdomain_id = s.id
                JOIN targets t ON s.target_id = t.id
                WHERE f.severity = ?
                ORDER BY f.last_verified DESC
            """, (severity,))
            return cursor.fetchall()
    
    def deduplicate_findings(self):
        """Remove duplicate findings based on proof hash."""
        with self.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                DELETE FROM findings
                WHERE id NOT IN (
                    SELECT MIN(id)
                    FROM findings
                    GROUP BY endpoint_id, vuln_class, proof_hash
                )
            """)
            return cursor.rowcount
```

### Phase 2: Caching Implementation

**Step 3: Build Redis Cache Layer**

```python
import redis
import json
from functools import wraps
import time

class BountyCache:
    """Redis-based caching for bug bounty operations."""
    
    def __init__(self, host='localhost', port=6379, db=0):
        self.client = redis.Redis(
            host=host, port=port, db=db,
            decode_responses=True,
            socket_connect_timeout=5
        )
        self.default_ttl = 3600  # 1 hour
    
    def cache_result(self, key, value, ttl=None):
        """Cache a result with optional TTL."""
        serialized = json.dumps(value, default=str)
        self.client.setex(
            key,
            ttl or self.default_ttl,
            serialized
        )
    
    def get_cached(self, key):
        """Retrieve cached result."""
        cached = self.client.get(key)
        if cached:
            return json.loads(cached)
        return None
    
    def invalidate_pattern(self, pattern):
        """Invalidate all keys matching a pattern."""
        keys = self.client.keys(pattern)
        if keys:
            self.client.delete(*keys)
    
    def get_or_compute(self, key, compute_fn, ttl=None):
        """Cache-aside pattern: return cached or compute and cache."""
        cached = self.get_cached(key)
        if cached is not None:
            return cached
        
        result = compute_fn()
        self.cache_result(key, result, ttl)
        return result
    
    def rate_limit_check(self, identifier, limit, window_seconds):
        """Sliding window rate limiter using Redis sorted sets."""
        pipe = self.client.pipeline()
        now = time.time()
        window_start = now - window_seconds
        
        # Remove old entries
        pipe.zremrangebyscore(identifier, 0, window_start)
        # Add current request
        pipe.zadd(identifier, {str(now): now})
        # Count requests in window
        pipe.zcard(identifier)
        # Set expiry
        pipe.expire(identifier, window_seconds)
        
        results = pipe.execute()
        request_count = results[2]
        
        return {
            "allowed": request_count <= limit,
            "remaining": max(0, limit - request_count),
            "reset_at": now + window_seconds
        }

def cached(ttl=3600, key_prefix="bounty"):
    """Decorator for automatic result caching."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            cache_key = f"{key_prefix}:{func.__name__}:{hash(str(args) + str(kwargs))}"
            cache = BountyCache()
            return cache.get_or_compute(
                cache_key,
                lambda: func(*args, **kwargs),
                ttl
            )
        return wrapper
    return decorator

# Usage
@cached(ttl=300, key_prefix="recon")
def get_subdomains(domain):
    """This result will be cached for 5 minutes."""
    # Simulate expensive lookup
    return ["sub1.example.com", "sub2.example.com"]
```

**Step 4: Query Optimization**

```python
def optimize_queries(db_path="bounty.db"):
    """Demonstrate query optimization patterns."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # BAD: N+1 query pattern
    print("BAD: N+1 Query Pattern")
    cursor.execute("SELECT * FROM targets")
    targets = cursor.fetchall()
    for target in targets:
        cursor.execute(
            "SELECT * FROM subdomains WHERE target_id = ?",
            (target['id'],)
        )
        subs = cursor.fetchall()
    
    # GOOD: JOIN-based query
    print("GOOD: JOIN-based Query")
    cursor.execute("""
        SELECT t.domain, COUNT(s.id) as subdomain_count
        FROM targets t
        LEFT JOIN subdomains s ON t.id = s.target_id
        GROUP BY t.id
        ORDER BY subdomain_count DESC
    """)
    results = cursor.fetchall()
    
    # GOOD: Batch insert
    print("GOOD: Batch Insert")
    subdomains = [
        (1, "sub1.example.com", "1.2.3.4"),
        (1, "sub2.example.com", "5.6.7.8"),
        (1, "sub3.example.com", "9.10.11.12"),
    ]
    cursor.executemany("""
        INSERT OR IGNORE INTO subdomains (target_id, subdomain, ip_address)
        VALUES (?, ?, ?)
    """, subdomains)
    
    # GOOD: Paginated results
    print("GOOD: Paginated Query")
    page_size = 50
    page = 0
    while True:
        cursor.execute("""
            SELECT * FROM findings
            WHERE status = 'new'
            ORDER BY first_seen DESC
            LIMIT ? OFFSET ?
        """, (page_size, page * page_size))
        batch = cursor.fetchall()
        if not batch:
            break
        print(f"Page {page}: {len(batch)} findings")
        page += 1
    
    conn.close()
    return results
```

### Phase 3: Advanced Data Operations

**Step 5: Full-Text Search Implementation**

```python
def setup_fulltext_search(db_path="bounty.db"):
    """Implement full-text search for finding content."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Enable FTS5
    cursor.execute("""
        CREATE VIRTUAL TABLE IF NOT EXISTS findings_fts USING fts5(
            title, description, proof_of_concept,
            content=findings,
            content_rowid=id
        )
    """)
    
    # Populate FTS index
    cursor.execute("""
        INSERT INTO findings_fts(rowid, title, description, proof_of_concept)
        SELECT id, title, description, proof_of_concept FROM findings
    """)
    
    # Create triggers to keep FTS in sync
    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS findings_ai AFTER INSERT ON findings BEGIN
            INSERT INTO findings_fts(rowid, title, description, proof_of_concept)
            VALUES (new.id, new.title, new.description, new.proof_of_concept);
        END
    """)
    
    cursor.execute("""
        CREATE TRIGGER IF NOT EXISTS findings_ad AFTER DELETE ON findings BEGIN
            INSERT INTO findings_fts(findings_fts, rowid, title, description, proof_of_concept)
            VALUES ('delete', old.id, old.title, old.description, old.proof_of_concept);
        END
    """)
    
    conn.commit()
    
    # Example search
    cursor.execute("""
        SELECT f.*, rank
        FROM findings_fts
        JOIN findings f ON findings_fts.rowid = f.id
        WHERE findings_fts MATCH 'XSS OR injection OR SSRF'
        ORDER BY rank
        LIMIT 10
    """)
    
    conn.close()
```

**Step 6: Data Export and Reporting**

```python
import csv
from io import StringIO
from datetime import datetime, timedelta

class BountyReporter:
    """Generate reports from stored bounty data."""
    
    def __init__(self, db_path="bounty.db"):
        self.db_path = db_path
    
    def generate_summary(self, days=30):
        """Generate summary statistics for the last N days."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        since = (datetime.now() - timedelta(days=days)).isoformat()
        
        summary = {}
        
        # Total findings by severity
        cursor.execute("""
            SELECT severity, COUNT(*) as count
            FROM findings
            WHERE first_seen >= ?
            GROUP BY severity
        """, (since,))
        summary['by_severity'] = dict(cursor.fetchall())
        
        # Top vulnerability classes
        cursor.execute("""
            SELECT vuln_class, COUNT(*) as count
            FROM findings
            WHERE first_seen >= ?
            GROUP BY vuln_class
            ORDER BY count DESC
            LIMIT 10
        """, (since,))
        summary['top_vulns'] = cursor.fetchall()
        
        # Findings per target
        cursor.execute("""
            SELECT t.domain, COUNT(f.id) as count
            FROM findings f
            JOIN endpoints e ON f.endpoint_id = e.id
            JOIN subdomains s ON e.subdomain_id = s.id
            JOIN targets t ON s.target_id = t.id
            WHERE f.first_seen >= ?
            GROUP BY t.id
            ORDER BY count DESC
        """, (since,))
        summary['per_target'] = cursor.fetchall()
        
        conn.close()
        return summary
    
    def export_findings_csv(self, output_path="findings.csv", status="new"):
        """Export findings to CSV for external processing."""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT
                f.id, t.domain, s.subdomain, e.url, e.method,
                f.vuln_class, f.severity, f.title, f.description,
                f.proof_of_concept, f.cvss_score, f.status,
                f.first_seen, f.last_verified
            FROM findings f
            JOIN endpoints e ON f.endpoint_id = e.id
            JOIN subdomains s ON e.subdomain_id = s.id
            JOIN targets t ON s.target_id = t.id
            WHERE f.status = ?
            ORDER BY f.severity DESC, f.first_seen DESC
        """, (status,))
        
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description]
        
        with open(output_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(columns)
            writer.writerows(rows)
        
        conn.close()
        return len(rows)
```

---

## Tool Arsenal

### Database Management Commands

```python
# Database statistics
def db_stats(db_path="bounty.db"):
    """Get comprehensive database statistics."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    tables = ['targets', 'subdomains', 'endpoints', 'findings', 'scan_results']
    stats = {}
    
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        cursor.execute(f"PRAGMA table_info({table})")
        columns = len(cursor.fetchall())
        stats[table] = {"rows": count, "columns": columns}
    
    # Database file size
    import os
    size_mb = os.path.getsize(db_path) / (1024 * 1024)
    stats['file_size_mb'] = round(size_mb, 2)
    
    conn.close()
    return stats

# Migration helper
def migrate_schema(db_path, migration_sql):
    """Apply schema migration with backup."""
    import shutil
    backup_path = f"{db_path}.backup.{datetime.now().strftime('%Y%m%d%H%M%S')}"
    shutil.copy2(db_path, backup_path)
    
    conn = sqlite3.connect(db_path)
    conn.executescript(migration_sql)
    conn.close()
    
    return backup_path
```

---

## Real-World Examples

### Example 1: Scaling Recon Data Storage

**Scenario**: Processing 10,000 subdomains with 100 endpoints each = 1M endpoint records.

```python
def bulk_import_endpoints(db_path, subdomains_data):
    """Efficiently import large volumes of recon data."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Disable autocommit for performance
    cursor.execute("PRAGMA journal_mode=WAL")
    cursor.execute("PRAGMA synchronous=NORMAL")
    
    batch = []
    for subdomain, endpoints in subdomains_data.items():
        for url, method in endpoints:
            batch.append((subdomain, url, method))
    
    # Batch insert in chunks of 10,000
    chunk_size = 10000
    for i in range(0, len(batch), chunk_size):
        chunk = batch[i:i+chunk_size]
        cursor.executemany("""
            INSERT OR IGNORE INTO endpoints (subdomain_id, url, method)
            SELECT s.id, ?, ?
            FROM subdomains s WHERE s.subdomain = ?
        """, [(url, method, sub) for sub, url, method in chunk])
        conn.commit()
        print(f"Imported {min(i+chunk_size, len(batch))}/{len(batch)}")
    
    conn.close()
```

### Example 2: Finding Deduplication at Scale

```python
def advanced_dedup(db_path="bounty.db"):
    """Multi-strategy deduplication for findings."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Strategy 1: Exact proof hash match
    cursor.execute("""
        DELETE FROM findings
        WHERE id NOT IN (
            SELECT MIN(id)
            FROM findings
            GROUP BY endpoint_id, vuln_class, proof_hash
        )
    """)
    exact_removed = cursor.rowcount
    
    # Strategy 2: Similar titles (fuzzy matching)
    cursor.execute("""
        SELECT f1.id, f2.id
        FROM findings f1
        JOIN findings f2 ON f1.id < f2.id
        WHERE f1.endpoint_id = f2.endpoint_id
        AND f1.vuln_class = f2.vuln_class
        AND f1.title LIKE '%' || SUBSTR(f2.title, 1, 20) || '%'
    """)
    similar_pairs = cursor.fetchall()
    
    # Keep the newer one for each similar pair
    ids_to_remove = set()
    for f1_id, f2_id in similar_pairs:
        ids_to_remove.add(f1_id)
    
    if ids_to_remove:
        placeholders = ','.join(['?'] * len(ids_to_remove))
        cursor.execute(f"""
            DELETE FROM findings WHERE id IN ({placeholders})
        """, list(ids_to_remove))
    
    conn.commit()
    conn.close()
    
    return {
        "exact_duplicates_removed": exact_removed,
        "similar_duplicates_removed": len(ids_to_remove)
    }
```

### Example 3: Real-time Query Dashboard

```python
from rich.console import Console
from rich.table import Table

def live_dashboard(db_path="bounty.db"):
    """Real-time dashboard of bounty pipeline status."""
    console = Console()
    
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Pipeline status table
    table = Table(title="Bug Bounty Pipeline Status")
    table.add_column("Metric", style="cyan")
    table.add_column("Value", style="green")
    
    cursor.execute("SELECT COUNT(*) FROM targets WHERE status='active'")
    table.add_row("Active Targets", str(cursor.fetchone()[0]))
    
    cursor.execute("SELECT COUNT(*) FROM subdomains")
    table.add_row("Total Subdomains", str(cursor.fetchone()[0]))
    
    cursor.execute("SELECT COUNT(*) FROM endpoints")
    table.add_row("Total Endpoints", str(cursor.fetchone()[0]))
    
    cursor.execute("SELECT COUNT(*) FROM findings WHERE status='new'")
    table.add_row("New Findings", str(cursor.fetchone()[0]))
    
    cursor.execute("SELECT COUNT(*) FROM findings WHERE status='submitted'")
    table.add_row("Submitted Findings", str(cursor.fetchone()[0]))
    
    # Severity breakdown
    cursor.execute("""
        SELECT severity, COUNT(*) as count
        FROM findings WHERE status='new'
        GROUP BY severity
    """)
    for row in cursor.fetchall():
        table.add_row(f"  {row['severity']}", str(row['count']))
    
    console.print(table)
    conn.close()
```

---

## Common Pitfalls

### Pitfall 1: No Indexes on Query Columns
Queries without proper indexes cause full table scans. Always index columns used in WHERE, JOIN, and ORDER BY clauses.

### Pitfall 2: Storing Large Blobs in SQLite
SQLite performs poorly with large binary data in cells. Store file paths or use object storage for evidence files.

### Pitfall 3: Ignoring Connection Pooling
Creating a new database connection per request wastes resources. Use connection pools or keep persistent connections.

### Pitfall 4: Not Using Transactions
Individual INSERT statements without transactions are extremely slow. Wrap batch operations in explicit transactions.

### Pitfall 5: Over-Caching
Caching immutable data (like historical findings) wastes memory. Cache only frequently-accessed, frequently-changing data.

### Pitfall 6: No Backup Strategy
Bug bounty data accumulates value over time. Implement automated backups before each major scan operation.

### Pitfall 7: Schema Drift
Multiple tools writing to the same database without coordinated schema changes causes data corruption. Use migrations.

---

## Advanced Techniques

### Partitioned Storage for High-Volume Data

```python
def create_partitioned_scan_results(db_path):
    """Create partitioned storage for scan results."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Create separate tables per scan type
    scan_types = ['nuclei', 'nmap', 'ffuf', 'katana', 'subfinder']
    
    for scan_type in scan_types:
        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS scan_{scan_type} (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                target_id INTEGER NOT NULL,
                started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP,
                result_count INTEGER DEFAULT 0,
                raw_output TEXT,
                FOREIGN KEY (target_id) REFERENCES targets(id)
            )
        """)
    
    conn.commit()
    conn.close()
```

### Read Replicas for Reporting

```python
class ReadReplicaManager:
    """Manage read replicas for reporting queries."""
    
    def __init__(self, primary_db, replica_dbs):
        self.primary = primary_db
        self.replicas = replica_dbs
        self.current_replica = 0
    
    def get_read_connection(self):
        """Round-robin read connections across replicas."""
        db_path = self.replicas[self.current_replica % len(self.replicas)]
        self.current_replica += 1
        return sqlite3.connect(db_path)
    
    def get_write_connection(self):
        """Always write to primary."""
        return sqlite3.connect(self.primary)
```

### Data Archival Strategy

```python
def archive_old_data(db_path, archive_path, days_old=90):
    """Archive old findings to separate database."""
    import shutil
    cutoff = (datetime.now() - timedelta(days=days_old)).isoformat()
    
    # Copy database
    shutil.copy2(db_path, archive_path)
    
    # Purge from main database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    cursor.execute("""
        DELETE FROM scan_results WHERE started_at < ?
    """, (cutoff,))
    
    cursor.execute("""
        DELETE FROM findings
        WHERE status IN ('closed', 'duplicate', 'informative')
        AND last_verified < ?
    """, (cutoff,))
    
    conn.commit()
    conn.close()
```

---

## Reporting Template

### Data Storage Health Report

```markdown
## Storage System Health Report

**Date**: [Date]
**Database**: [Path/Connection String]
**Total Size**: [Size MB/GB]

### Record Counts
| Table | Records | Growth (30d) |
|-------|---------|--------------|
| Targets | [N] | [+N%] |
| Subdomains | [N] | [+N%] |
| Endpoints | [N] | [+N%] |
| Findings | [N] | [+N%] |
| Scan Results | [N] | [+N%] |

### Performance Metrics
| Query Type | Avg Time | P99 Time |
|------------|----------|----------|
| Finding lookup | [ms] | [ms] |
| Subdomain search | [ms] | [ms] |
| Report generation | [s] | [s] |

### Recommendations
- [ ] [Index optimization recommendation]
- [ ] [Archival recommendation]
- [ ] [Cache tuning recommendation]
```

---

## Quick Reference

### SQLite PRAGMA Optimizations
```sql
PRAGMA journal_mode=WAL;       -- Write-ahead logging for concurrent reads
PRAGMA synchronous=NORMAL;     -- Balanced durability/performance
PRAGMA cache_size=-64000;      -- 64MB page cache
PRAGMA temp_store=MEMORY;      -- In-memory temp tables
PRAGMA mmap_size=268435456;    -- 256MB memory-mapped I/O
```

### PostgreSQL Connection String
```
postgresql://user:password@host:5432/database?sslmode=require
```

### Redis Cache Patterns
```python
# Cache-aside
value = cache.get(key) or cache.set(key, compute_value())

# Write-through
cache.set(key, value)
db.save(key, value)

# Write-behind
db.save(key, value)
cache.invalidate(key)
```

### Performance Checklist
- [ ] All query columns indexed
- [ ] Batch inserts wrapped in transactions
- [ ] Connection pooling enabled
- [ ] Read replicas for reporting
- [ ] Regular vacuum/analyze scheduled
- [ ] Backup before major operations
- [ ] Schema migrations versioned
