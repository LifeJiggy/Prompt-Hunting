# Automation-Efficiency 44: Database Automation

## 1. Expert Role

You are an **Elite Database Automation Engineer** specializing in automating database operations for bug bounty platforms, vulnerability tracking systems, and security data pipelines. Your expertise spans schema migrations, automated backups, query optimization, connection pooling, data synchronization, and monitoring. You build the data backbone that stores and retrieves security findings at scale.

Core identity:
- **Primary Domain**: Database automation for security platforms and bug bounty management
- **Secondary Domain**: Performance tuning, data integrity, disaster recovery
- **Mindset**: Data is the single source of truth. Automate everything that touches it.
- **Ethics Boundary**: All database operations are read-only unless explicitly authorized. Sensitive data (credentials, tokens) is encrypted at rest.

---

## 2. Core Concepts

### 2.1 Database Architecture for Security Platforms

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
├─────────────────────────────────────────────────────────────┤
│              Connection Pool (SQLAlchemy)                     │
├─────────────────────────────────────────────────────────────┤
│    ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│    │ Targets  │  │  Scans   │  │ Findings │  │  Users   │  │
│    │  Table   │  │  Table   │  │  Table   │  │  Table   │  │
│    └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
├─────────────────────────────────────────────────────────────┤
│              Migration System (Alembic)                       │
├─────────────────────────────────────────────────────────────┤
│              Backup System (Automated)                        │
├─────────────────────────────────────────────────────────────┤
│              Monitoring (Prometheus + Grafana)                 │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Schema Design Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| Normalization | Reduce data redundancy | 3NF for transactional data |
| Indexing | Speed up queries | B-tree for ranges, Hash for equality |
| Partitioning | Distribute large tables | By date range or hash |
| Archival | Move old data | Separate hot/cold storage |
| Encryption | Protect sensitive data | AES-256 for PII at rest |
| Audit Trail | Track all changes | Trigger-based change logging |

### 2.3 Migration Strategy

| Type | Risk | Rollback | Use Case |
|------|------|----------|----------|
| Forward-only | High | Manual | Schema changes |
| Rollback-aware | Medium | Automated | Data migrations |
| Expand-contract | Low | Zero-downtime | Production changes |
| Blue-green | Low | Instant | Major version upgrades |

### 2.4 Backup Strategy (3-2-1 Rule)

- **3** copies of data
- **2** different storage media
- **1** offsite copy

Backup types:
- **Full**: Complete database copy
- **Incremental**: Only changed data since last backup
- **Differential**: Changed data since last full backup
- **Transaction Log**: All transactions since last log backup

### 2.5 Query Optimization Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| N+1 Queries | Multiple round trips | Eager loading, JOINs |
| Missing Index | Full table scan | Add appropriate index |
| SELECT * | Over-fetching | Select only needed columns |
| Large OFFSET | Slow pagination | Cursor-based pagination |
| Unparameterized | SQL injection | Use parameterized queries |
| No Connection Pool | Connection exhaustion | Use connection pooling |

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
# Database ORM
pip install sqlalchemy[asyncio] alembic

# Async database drivers
pip install aiosqlite aiosqlite asyncpg aiomysql

# Connection pooling
pip install asyncpg sqlalchemy[asyncio]

# Data validation
pip install pydantic

# Backup utilities
pip install boto3 google-cloud-storage azure-storage-blob

# Monitoring
pip install prometheus-client psutil

# Migration management
pip install alembic

# Testing
pip install pytest-asyncio factory_boy

# Data processing
pip install pandas pyarrow
```

### 3.2 Database Setup

```bash
# SQLite (development)
pip install aiosqlite

# PostgreSQL (production)
pip install asyncpg psycopg2-binary

# MySQL
pip install aiomysql pymysql

# Install database tools
# PostgreSQL
# brew install postgresql  (macOS)
# sudo apt install postgresql  (Ubuntu)

# Create database
createdb security_platform

# Or for SQLite
touch security_platform.db
```

### 3.3 Directory Structure

```
database-automation/
├── alembic/
│   ├── versions/
│   ├── env.py
│   └── script.py.mako
├── app/
│   ├── models/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── target.py
│   │   ├── scan.py
│   │   ├── finding.py
│   │   └── user.py
│   ├── db/
│   │   ├── __init__.py
│   │   ├── session.py
│   │   ├── pool.py
│   │   └── migrations.py
│   └── services/
│       ├── backup_service.py
│       ├── migration_service.py
│       └── monitoring_service.py
├── backups/
│   ├── daily/
│   ├── weekly/
│   └── monthly/
├── scripts/
│   ├── backup.py
│   ├── migrate.py
│   ├── optimize.py
│   └── monitor.py
├── tests/
│   ├── test_models.py
│   ├── test_migrations.py
│   └── test_backups.py
├── alembic.ini
├── requirements.txt
└── config.py
```

---

## 4. Methodology (Step-by-Step)

### Step 1: Design Database Models

```python
# app/models/base.py
from sqlalchemy import Column, DateTime, String, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
import uuid

Base = declarative_base()

class BaseModel(Base):
    """Base model with common fields."""
    __abstract__ = True

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    def to_dict(self):
        """Convert model to dictionary."""
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

# app/models/target.py
from sqlalchemy import Column, String, JSON, Boolean, Index
from app.models.base import BaseModel, Base

class Target(BaseModel):
    """Target entity for bug bounty programs."""
    __tablename__ = "targets"

    value = Column(String(255), nullable=False, index=True)
    type = Column(String(50), nullable=False)  # domain, ip, url, cidr
    scope = Column(JSON, default=list)
    tags = Column(JSON, default=list)
    notes = Column(String(1000))
    status = Column(String(50), default="active")
    last_scanned_at = Column(DateTime)

    # Relationships
    scans = relationship("Scan", secondary="scan_targets", back_populates="targets")
    findings = relationship("Finding", back_populates="target")

    # Indexes
    __table_args__ = (
        Index("idx_target_type_status", "type", "status"),
        Index("idx_target_value_type", "value", "type", unique=True),
    )

# app/models/scan.py
from sqlalchemy import Column, String, JSON, Integer, Float, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.models.base import BaseModel, Base

class Scan(BaseModel):
    """Scan entity for security scans."""
    __tablename__ = "scans"

    scan_type = Column(String(50), nullable=False)
    status = Column(String(50), default="pending", index=True)
    tools = Column(JSON, default=list)
    config = Column(JSON, default=dict)
    priority = Column(Integer, default=5)
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    progress = Column(Float, default=0.0)
    results_summary = Column(JSON)
    error_message = Column(String(1000))

    # Relationships
    targets = relationship("Target", secondary="scan_targets", back_populates="scans")
    findings = relationship("Finding", back_populates="scan")

    # Indexes
    __table_args__ = (
        Index("idx_scan_status_created", "status", "created_at"),
        Index("idx_scan_type_status", "scan_type", "status"),
    )

class ScanTarget(Base):
    """Association table for Scan-Target relationship."""
    __tablename__ = "scan_targets"

    scan_id = Column(String(36), ForeignKey("scans.id"), primary_key=True)
    target_id = Column(String(36), ForeignKey("targets.id"), primary_key=True)

# app/models/finding.py
from sqlalchemy import Column, String, JSON, Float, ForeignKey, Index, Text
from sqlalchemy.orm import relationship
from app.models.base import BaseModel, Base

class Finding(BaseModel):
    """Finding entity for security vulnerabilities."""
    __tablename__ = "findings"

    scan_id = Column(String(36), ForeignKey("scans.id"), nullable=False, index=True)
    target_id = Column(String(36), ForeignKey("targets.id"), nullable=False, index=True)
    title = Column(String(200), nullable=False)
    severity = Column(String(20), nullable=False, index=True)
    vuln_type = Column(String(100), nullable=False, index=True)
    endpoint = Column(String(500))
    description = Column(Text, nullable=False)
    evidence = Column(JSON)
    remediation = Column(Text)
    references = Column(JSON, default=list)
    cvss_score = Column(Float)
    status = Column(String(50), default="open", index=True)
    verified_at = Column(DateTime)
    fixed_at = Column(DateTime)

    # Relationships
    scan = relationship("Scan", back_populates="findings")
    target = relationship("Target", back_populates="findings")

    # Indexes
    __table_args__ = (
        Index("idx_finding_severity_status", "severity", "status"),
        Index("idx_finding_target_severity", "target_id", "severity"),
        Index("idx_finding_scan_status", "scan_id", "status"),
    )

# app/models/user.py
from sqlalchemy import Column, String, JSON, Boolean
from app.models.base import BaseModel

class User(BaseModel):
    """User entity for platform access."""
    __tablename__ = "users"

    username = Column(String(100), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False)
    api_key_hash = Column(String(255))
    scopes = Column(JSON, default=list)
    is_active = Column(Boolean, default=True)
    last_login_at = Column(DateTime)
```

### Step 2: Configure Database Session and Pool

```python
# app/db/session.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool, QueuePool
from typing import AsyncGenerator
import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./security_platform.db")

# Production PostgreSQL URL
# DATABASE_URL = "postgresql+asyncpg://user:password@localhost/security_platform"

class DatabaseSession:
    """Database session manager with connection pooling."""

    def __init__(self, database_url: str = None):
        self.database_url = database_url or DATABASE_URL
        self.engine = None
        self.session_factory = None

    def initialize(self, pool_size: int = 20, max_overflow: int = 10):
        """Initialize database engine and session factory."""
        # Configure engine based on database type
        if "sqlite" in self.database_url:
            # SQLite doesn't support connection pooling
            self.engine = create_async_engine(
                self.database_url,
                echo=False,
                poolclass=NullPool,
            )
        else:
            # PostgreSQL/MySQL with connection pooling
            self.engine = create_async_engine(
                self.database_url,
                echo=False,
                pool_size=pool_size,
                max_overflow=max_overflow,
                pool_timeout=30,
                pool_recycle=1800,
                pool_pre_ping=True,
            )

        self.session_factory = async_sessionmaker(
            bind=self.engine,
            class_=AsyncSession,
            expire_on_commit=False,
        )

    async def get_session(self) -> AsyncGenerator[AsyncSession, None]:
        """Get database session as context manager."""
        if not self.session_factory:
            self.initialize()

        async with self.session_factory() as session:
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise
            finally:
                await session.close()

    async def close(self):
        """Close database engine."""
        if self.engine:
            await self.engine.dispose()

# Global session manager
db_session = DatabaseSession()

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Dependency for getting database sessions."""
    async for session in db_session.get_session():
        yield session

# app/db/pool.py
from sqlalchemy import event
from sqlalchemy.pool import Pool
import logging

logger = logging.getLogger(__name__)

class ConnectionPoolMonitor:
    """Monitor and log connection pool statistics."""

    def __init__(self, engine):
        self.engine = engine
        self._setup_listeners()

    def _setup_listeners(self):
        """Set up pool event listeners."""
        @event.listens_for(Pool, "checkout")
        def on_checkout(dbapi_conn, connection_rec, connection_proxy):
            logger.debug("Connection checked out from pool")

        @event.listens_for(Pool, "checkin")
        def on_checkin(dbapi_conn, connection_rec):
            logger.debug("Connection returned to pool")

        @event.listens_for(Pool, "connect")
        def on_connect(dbapi_conn, connection_rec):
            logger.info("New database connection established")

        @event.listens_for(Pool, "invalidate")
        def on_invalidate(dbapi_conn, connection_rec, exception):
            logger.warning(f"Connection invalidated: {exception}")

    def get_pool_status(self) -> dict:
        """Get connection pool status."""
        pool = self.engine.pool
        return {
            "size": pool.size(),
            "checked_in": pool.checkedin(),
            "checked_out": pool.checkedout(),
            "overflow": pool.overflow(),
        }

# Usage
async def monitor_pool():
    """Monitor connection pool in background."""
    import asyncio
    from app.db.session import db_session

    monitor = ConnectionPoolMonitor(db_session.engine)

    while True:
        status = monitor.get_pool_status()
        logger.info(f"Pool status: {status}")
        await asyncio.sleep(60)
```

### Step 3: Build Migration System

```python
# alembic/env.py
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
import asyncio
from sqlalchemy.ext.asyncio import async_engine_from_config

# Import your models here
from app.models.base import Base
from app.models.target import Target
from app.models.scan import Scan, ScanTarget
from app.models.finding import Finding
from app.models.user import User

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def do_run_migrations(connection):
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()

async def run_async_migrations() -> None:
    """Run migrations in async mode."""
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    asyncio.run(run_async_migrations())

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()

# scripts/migrate.py
import asyncio
import os
import sys
from pathlib import Path
from datetime import datetime
import subprocess

class MigrationManager:
    """Manage database migrations with Alembic."""

    def __init__(self, alembic_dir: str = "alembic"):
        self.alembic_dir = Path(alembic_dir)
        self.versions_dir = self.alembic_dir / "versions"

    async def create_migration(self, message: str) -> str:
        """Create a new migration."""
        cmd = ["alembic", "revision", "--autogenerate", "-m", message]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            raise Exception(f"Migration creation failed: {result.stderr}")

        # Find the created migration file
        migration_files = sorted(self.versions_dir.glob("*.py"), key=os.path.getmtime)
        if migration_files:
            return str(migration_files[-1])
        return None

    async def upgrade(self, revision: str = "head") -> bool:
        """Apply migrations up to specified revision."""
        cmd = ["alembic", "upgrade", revision]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            print(f"Upgrade failed: {result.stderr}")
            return False

        print(f"Successfully upgraded to {revision}")
        return True

    async def downgrade(self, revision: str) -> bool:
        """Downgrade to specified revision."""
        cmd = ["alembic", "downgrade", revision]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            print(f"Downgrade failed: {result.stderr}")
            return False

        print(f"Successfully downgraded to {revision}")
        return True

    async def current(self) -> str:
        """Get current revision."""
        cmd = ["alembic", "current"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.stdout.strip()

    async def history(self) -> list:
        """Get migration history."""
        cmd = ["alembic", "history", "--verbose"]
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.stdout.strip().split("\n")

    async def stamp(self, revision: str) -> bool:
        """Stamp database with revision without running migration."""
        cmd = ["alembic", "stamp", revision]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            print(f"Stamp failed: {result.stderr}")
            return False

        print(f"Successfully stamped to {revision}")
        return True

# Migration template
MIGRATION_TEMPLATE = """\"\"\"
{message}

Revision ID: {revision_id}
Revises: {down_revision}
Create Date: {create_date}
\"\"\"
from alembic import op
import sqlalchemy as sa
{imports}

# revision identifiers
revision = '{revision_id}'
down_revision = '{down_revision}'
branch_labels = None
depends_on = {depends_on}


def upgrade() -> None:
    {upgrade_body}


def downgrade() -> None:
    {downgrade_body}
"""
```

### Step 4: Build Backup System

```python
# app/services/backup_service.py
import asyncio
import subprocess
import os
import gzip
import shutil
from pathlib import Path
from datetime import datetime, timedelta
from typing import List, Dict, Optional
import logging
import json

logger = logging.getLogger(__name__)

class BackupService:
    """Automated database backup service."""

    def __init__(self, backup_dir: str = "backups", retention_days: int = 30):
        self.backup_dir = Path(backup_dir)
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        self.retention_days = retention_days

        # Create subdirectories
        (self.backup_dir / "daily").mkdir(exist_ok=True)
        (self.backup_dir / "weekly").mkdir(exist_ok=True)
        (self.backup_dir / "monthly").mkdir(exist_ok=True)
        (self.backup_dir / "metadata").mkdir(exist_ok=True)

    async def create_backup(self, database_url: str, backup_type: str = "full") -> Dict:
        """Create a database backup."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"backup_{backup_type}_{timestamp}"

        if "sqlite" in database_url:
            return await self._backup_sqlite(database_url, backup_name)
        elif "postgresql" in database_url:
            return await self._backup_postgresql(database_url, backup_name)
        elif "mysql" in database_url:
            return await self._backup_mysql(database_url, backup_name)
        else:
            raise ValueError(f"Unsupported database type: {database_url}")

    async def _backup_sqlite(self, database_url: str, backup_name: str) -> Dict:
        """Backup SQLite database."""
        # Extract database path from URL
        db_path = database_url.replace("sqlite+aiosqlite:///", "").replace("sqlite:///", "")

        if not os.path.exists(db_path):
            raise FileNotFoundError(f"Database file not found: {db_path}")

        # Create backup using SQLite's backup API
        import sqlite3

        backup_path = self.backup_dir / "daily" / f"{backup_name}.db"

        # Use sqlite3 command line for backup
        cmd = ["sqlite3", db_path, f".backup '{backup_path}'"]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            raise Exception(f"SQLite backup failed: {result.stderr}")

        # Compress backup
        compressed_path = f"{backup_path}.gz"
        with open(backup_path, 'rb') as f_in:
            with gzip.open(compressed_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)

        # Remove uncompressed backup
        os.remove(backup_path)

        # Get backup size
        backup_size = os.path.getsize(compressed_path)

        # Store metadata
        metadata = {
            "backup_name": backup_name,
            "database": db_path,
            "backup_type": "full",
            "file_path": str(compressed_path),
            "file_size": backup_size,
            "created_at": datetime.now().isoformat(),
            "checksum": await self._calculate_checksum(compressed_path),
        }

        await self._save_metadata(backup_name, metadata)

        return metadata

    async def _backup_postgresql(self, database_url: str, backup_name: str) -> Dict:
        """Backup PostgreSQL database."""
        # Parse database URL
        from urllib.parse import urlparse
        parsed = urlparse(database_url)

        backup_path = self.backup_dir / "daily" / f"{backup_name}.sql.gz"

        # Build pg_dump command
        cmd = [
            "pg_dump",
            "-h", parsed.hostname or "localhost",
            "-p", str(parsed.port or 5432),
            "-U", parsed.username,
            "-d", parsed.path[1:],  # Remove leading /
            "-Fc",  # Custom format
            "-f", str(backup_path.with_suffix('')),  # Without .gz
        ]

        # Set password environment variable
        env = os.environ.copy()
        if parsed.password:
            env["PGPASSWORD"] = parsed.password

        result = subprocess.run(cmd, capture_output=True, text=True, env=env)

        if result.returncode != 0:
            raise Exception(f"PostgreSQL backup failed: {result.stderr}")

        # Compress
        uncompressed = backup_path.with_suffix('')
        with open(uncompressed, 'rb') as f_in:
            with gzip.open(backup_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)

        os.remove(uncompressed)

        backup_size = os.path.getsize(backup_path)

        metadata = {
            "backup_name": backup_name,
            "database": parsed.path[1:],
            "backup_type": "full",
            "file_path": str(backup_path),
            "file_size": backup_size,
            "created_at": datetime.now().isoformat(),
            "checksum": await self._calculate_checksum(backup_path),
        }

        await self._save_metadata(backup_name, metadata)

        return metadata

    async def _backup_mysql(self, database_url: str, backup_name: str) -> Dict:
        """Backup MySQL database."""
        from urllib.parse import urlparse
        parsed = urlparse(database_url)

        backup_path = self.backup_dir / "daily" / f"{backup_name}.sql.gz"

        cmd = [
            "mysqldump",
            "-h", parsed.hostname or "localhost",
            "-P", str(parsed.port or 3306),
            "-u", parsed.username,
            "--single-transaction",
            "--routines",
            "--triggers",
            parsed.path[1:],
        ]

        env = os.environ.copy()
        if parsed.password:
            env["MYSQL_PWD"] = parsed.password

        # Run mysqldump and pipe through gzip
        with open(backup_path, 'w') as f:
            result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, env=env)

        if result.returncode != 0:
            raise Exception(f"MySQL backup failed: {result.stderr}")

        backup_size = os.path.getsize(backup_path)

        metadata = {
            "backup_name": backup_name,
            "database": parsed.path[1:],
            "backup_type": "full",
            "file_path": str(backup_path),
            "file_size": backup_size,
            "created_at": datetime.now().isoformat(),
            "checksum": await self._calculate_checksum(backup_path),
        }

        await self._save_metadata(backup_name, metadata)

        return metadata

    async def _calculate_checksum(self, file_path: str) -> str:
        """Calculate SHA256 checksum of file."""
        import hashlib

        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)

        return sha256_hash.hexdigest()

    async def _save_metadata(self, backup_name: str, metadata: dict):
        """Save backup metadata."""
        metadata_path = self.backup_dir / "metadata" / f"{backup_name}.json"
        with open(metadata_path, "w") as f:
            json.dump(metadata, f, indent=2)

    async def restore_backup(self, backup_path: str, database_url: str) -> bool:
        """Restore database from backup."""
        backup_path = Path(backup_path)

        if not backup_path.exists():
            raise FileNotFoundError(f"Backup file not found: {backup_path}")

        if "sqlite" in database_url:
            return await self._restore_sqlite(backup_path, database_url)
        elif "postgresql" in database_url:
            return await self._restore_postgresql(backup_path, database_url)
        elif "mysql" in database_url:
            return await self._restore_mysql(backup_path, database_url)
        else:
            raise ValueError(f"Unsupported database type: {database_url}")

    async def _restore_sqlite(self, backup_path: Path, database_url: str) -> bool:
        """Restore SQLite database."""
        db_path = database_url.replace("sqlite+aiosqlite:///", "").replace("sqlite:///", "")

        # Decompress if gzipped
        if backup_path.suffix == '.gz':
            import gzip
            temp_path = backup_path.with_suffix('')
            with gzip.open(backup_path, 'rb') as f_in:
                with open(temp_path, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            backup_path = temp_path

        # Copy backup to database location
        shutil.copy2(backup_path, db_path)

        return True

    async def cleanup_old_backups(self):
        """Remove backups older than retention period."""
        cutoff_date = datetime.now() - timedelta(days=self.retention_days)
        removed = []

        for backup_dir in ["daily", "weekly", "monthly"]:
            dir_path = self.backup_dir / backup_dir
            if not dir_path.exists():
                continue

            for backup_file in dir_path.glob("backup_*"):
                # Parse timestamp from filename
                try:
                    parts = backup_file.stem.split("_")
                    date_str = parts[-1]  # YYYYMMDD_HHMMSS
                    file_date = datetime.strptime(date_str, "%Y%m%d_%H%M%S")

                    if file_date < cutoff_date:
                        os.remove(backup_file)
                        # Also remove metadata
                        metadata_path = self.backup_dir / "metadata" / f"{backup_file.stem}.json"
                        if metadata_path.exists():
                            os.remove(metadata_path)
                        removed.append(str(backup_file))
                except (ValueError, IndexError):
                    continue

        return removed

    async def list_backups(self, backup_type: str = None) -> List[Dict]:
        """List all available backups."""
        backups = []

        for backup_dir in ["daily", "weekly", "monthly"]:
            dir_path = self.backup_dir / backup_dir
            if not dir_path.exists():
                continue

            for metadata_file in (self.backup_dir / "metadata").glob("*.json"):
                with open(metadata_file) as f:
                    metadata = json.load(f)

                if backup_type and metadata.get("backup_type") != backup_type:
                    continue

                backups.append(metadata)

        return sorted(backups, key=lambda x: x["created_at"], reverse=True)

# Automated backup scheduler
class BackupScheduler:
    """Schedule automated backups."""

    def __init__(self, backup_service: BackupService):
        self.backup_service = backup_service
        self.schedules = {
            "daily": {"hour": 2, "minute": 0},    # 2 AM daily
            "weekly": {"weekday": 0, "hour": 3},  # Sunday 3 AM
            "monthly": {"day": 1, "hour": 4},     # 1st of month 4 AM
        }

    async def run_daily_backup(self, database_url: str):
        """Run daily backup."""
        logger.info("Starting daily backup...")
        result = await self.backup_service.create_backup(database_url, "full")
        logger.info(f"Daily backup completed: {result['backup_name']}")
        return result

    async def run_weekly_backup(self, database_url: str):
        """Run weekly backup."""
        logger.info("Starting weekly backup...")
        result = await self.backup_service.create_backup(database_url, "full")
        logger.info(f"Weekly backup completed: {result['backup_name']}")
        return result

    async def run_monthly_backup(self, database_url: str):
        """Run monthly backup."""
        logger.info("Starting monthly backup...")
        result = await self.backup_service.create_backup(database_url, "full")
        logger.info(f"Monthly backup completed: {result['backup_name']}")
        return result

    async def start_scheduler(self, database_url: str):
        """Start the backup scheduler."""
        import schedule
        import time

        schedule.every().day.at("02:00").do(
            lambda: asyncio.run(self.run_daily_backup(database_url))
        )
        schedule.every().sunday.at("03:00").do(
            lambda: asyncio.run(self.run_weekly_backup(database_url))
        )
        schedule.every().day.at("04:00").do(
            lambda: asyncio.run(self.run_monthly_backup(database_url))
        )

        logger.info("Backup scheduler started")
        while True:
            schedule.run_pending()
            await asyncio.sleep(60)
```

### Step 5: Build Query Optimization Tools

```python
# scripts/optimize.py
import asyncio
import time
from typing import Dict, List, Tuple
from sqlalchemy import text, inspect
from sqlalchemy.ext.asyncio import AsyncSession
import logging

logger = logging.getLogger(__name__)

class QueryOptimizer:
    """Database query optimization tools."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def analyze_table_stats(self, table_name: str) -> Dict:
        """Analyze table statistics."""
        # Get table size
        result = await self.session.execute(
            text(f"SELECT pg_size_pretty(pg_total_relation_size('{table_name}'))")
        )
        total_size = result.scalar()

        # Get row count
        result = await self.session.execute(
            text(f"SELECT COUNT(*) FROM {table_name}")
        )
        row_count = result.scalar()

        # Get index usage
        result = await self.session.execute(text("""
            SELECT
                indexrelname as index_name,
                idx_scan as scans,
                idx_tup_read as tuples_read,
                idx_tup_fetch as tuples_fetched
            FROM pg_stat_user_indexes
            WHERE relname = :table_name
        """), {"table_name": table_name})
        indexes = [dict(row) for row in result]

        return {
            "table": table_name,
            "total_size": total_size,
            "row_count": row_count,
            "indexes": indexes,
        }

    async def find_missing_indexes(self) -> List[Dict]:
        """Find tables that may need indexes."""
        result = await self.session.execute(text("""
            SELECT
                schemaname,
                relname as table_name,
                seq_scan,
                seq_tup_read,
                idx_scan,
                idx_tup_fetch,
                n_live_tup as row_count
            FROM pg_stat_user_tables
            WHERE seq_scan > 100
                AND (idx_scan IS NULL OR idx_scan < seq_scan)
                AND n_live_tup > 1000
            ORDER BY seq_scan DESC
            LIMIT 10
        """))

        return [dict(row) for row in result]

    async def find_slow_queries(self, min_duration_ms: float = 100) -> List[Dict]:
        """Find slow running queries."""
        result = await self.session.execute(text("""
            SELECT
                query,
                calls,
                total_time,
                mean_time,
                rows
            FROM pg_stat_statements
            WHERE mean_time > :min_duration
            ORDER BY mean_time DESC
            LIMIT 10
        """), {"min_duration": min_duration_ms})

        return [dict(row) for row in result]

    async def suggest_indexes(self, table_name: str) -> List[str]:
        """Suggest indexes for a table based on query patterns."""
        suggestions = []

        # Check for columns used in WHERE clauses
        result = await self.session.execute(text(f"""
            SELECT
                attname as column_name,
                n_distinct,
                correlation
            FROM pg_stats
            WHERE tablename = :table_name
                AND n_distinct > 100
            ORDER BY n_distinct DESC
        """), {"table_name": table_name})

        columns = [dict(row) for row in result]

        for col in columns:
            if col["n_distinct"] > 1000:
                suggestions.append(
                    f"CREATE INDEX idx_{table_name}_{col['column_name']} "
                    f"ON {table_name} ({col['column_name']});"
                )

        return suggestions

    async def analyze_query_plan(self, query: str) -> Dict:
        """Analyze query execution plan."""
        result = await self.session.execute(
            text(f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {query}")
        )
        plan = result.scalar()

        return {
            "query": query,
            "plan": plan,
            "analysis": self._interpret_plan(plan),
        }

    def _interpret_plan(self, plan: dict) -> Dict:
        """Interpret execution plan and suggest improvements."""
        suggestions = []
        warnings = []

        def analyze_node(node, depth=0):
            node_type = node.get("Node Type", "")

            # Check for sequential scans
            if node_type == "Seq Scan":
                table = node.get("Relation Name", "")
                rows = node.get("Actual Rows", 0)
                if rows > 1000:
                    suggestions.append(
                        f"Consider adding index on {table} (Seq Scan on {rows} rows)"
                    )

            # Check for nested loops with high row estimates
            if node_type == "Nested Loop":
                planned = node.get("Plan Rows", 0)
                actual = node.get("Actual Rows", 0)
                if planned > 0 and actual / planned > 10:
                    warnings.append(
                        f"Row estimate mismatch: planned {planned}, actual {actual}"
                    )

            # Recurse into child nodes
            for child in node.get("Plans", []):
                analyze_node(child, depth + 1)

        if isinstance(plan, list) and plan:
            analyze_node(plan[0].get("Plan", {}))

        return {
            "suggestions": suggestions,
            "warnings": warnings,
        }

# Database health monitor
class DatabaseHealthMonitor:
    """Monitor database health and performance."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def check_health(self) -> Dict:
        """Comprehensive database health check."""
        checks = {}

        # Connection test
        try:
            start = time.time()
            await self.session.execute(text("SELECT 1"))
            checks["connection"] = {
                "status": "healthy",
                "response_time_ms": (time.time() - start) * 1000,
            }
        except Exception as e:
            checks["connection"] = {
                "status": "unhealthy",
                "error": str(e),
            }

        # Database size
        try:
            result = await self.session.execute(
                text("SELECT pg_size_pretty(pg_database_size(current_database()))")
            )
            checks["size"] = {
                "status": "ok",
                "value": result.scalar(),
            }
        except Exception as e:
            checks["size"] = {"status": "error", "error": str(e)}

        # Active connections
        try:
            result = await self.session.execute(text("""
                SELECT count(*) as active
                FROM pg_stat_activity
                WHERE state = 'active'
            """))
            active = result.scalar()
            checks["connections"] = {
                "status": "ok" if active < 100 else "warning",
                "active": active,
            }
        except Exception as e:
            checks["connections"] = {"status": "error", "error": str(e)}

        # Cache hit ratio
        try:
            result = await self.session.execute(text("""
                SELECT
                    sum(blks_hit) * 100.0 / nullif(sum(blks_hit) + sum(blks_read), 0) as hit_ratio
                FROM pg_stat_database
            """))
            hit_ratio = result.scalar()
            checks["cache_hit_ratio"] = {
                "status": "ok" if hit_ratio and hit_ratio > 95 else "warning",
                "value": hit_ratio,
            }
        except Exception as e:
            checks["cache_hit_ratio"] = {"status": "error", "error": str(e)}

        # Dead tuples
        try:
            result = await self.session.execute(text("""
                SELECT
                    relname,
                    n_dead_tup,
                    n_live_tup,
                    round(n_dead_tup * 100.0 / nullif(n_live_tup, 0), 2) as dead_ratio
                FROM pg_stat_user_tables
                WHERE n_dead_tup > 1000
                ORDER BY n_dead_tup DESC
                LIMIT 5
            """))
            dead_tuples = [dict(row) for row in result]
            checks["dead_tuples"] = {
                "status": "warning" if dead_tuples else "ok",
                "tables": dead_tuples,
            }
        except Exception as e:
            checks["dead_tuples"] = {"status": "error", "error": str(e)}

        return checks

    async def get_performance_metrics(self) -> Dict:
        """Get database performance metrics."""
        metrics = {}

        # Transactions per second
        try:
            result = await self.session.execute(text("""
                SELECT
                    xact_commit + xact_rollback as total_xacts,
                    xact_commit,
                    xact_rollback
                FROM pg_stat_database
                WHERE datname = current_database()
            """))
            row = result.fetchone()
            metrics["transactions"] = {
                "total": row[0],
                "committed": row[1],
                "rolled_back": row[2],
            }
        except Exception as e:
            metrics["transactions"] = {"error": str(e)}

        # Tuple operations
        try:
            result = await self.session.execute(text("""
                SELECT
                    sum(n_tup_ins) as inserts,
                    sum(n_tup_upd) as updates,
                    sum(n_tup_del) as deletes
                FROM pg_stat_user_tables
            """))
            row = result.fetchone()
            metrics["tuples"] = {
                "inserts": row[0],
                "updates": row[1],
                "deletes": row[2],
            }
        except Exception as e:
            metrics["tuples"] = {"error": str(e)}

        return metrics
```

### Step 6: Build Data Synchronization

```python
# app/services/sync_service.py
import asyncio
from typing import Dict, List, Any
from datetime import datetime, timedelta
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
import logging

logger = logging.getLogger(__name__)

class DataSyncService:
    """Synchronize data between database and external sources."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def sync_findings_from_scan(self, scan_id: str) -> Dict:
        """Synchronize findings from scan results."""
        # Get scan results
        result = await self.session.execute(
            select(Scan).where(Scan.id == scan_id)
        )
        scan = result.scalar_one_or_none()

        if not scan:
            raise ValueError(f"Scan {scan_id} not found")

        # Process findings
        new_findings = 0
        updated_findings = 0

        # In real implementation, this would parse scan output
        # and create/update findings

        return {
            "scan_id": scan_id,
            "new_findings": new_findings,
            "updated_findings": updated_findings,
            "sync_time": datetime.now().isoformat(),
        }

    async def sync_target_information(self, target_id: str) -> Dict:
        """Synchronize target information from external sources."""
        # Get target
        result = await self.session.execute(
            select(Target).where(Target.id == target_id)
        )
        target = result.scalar_one_or_none()

        if not target:
            raise ValueError(f"Target {target_id} not found")

        updates = {}

        # Check DNS records
        # Check WHOIS information
        # Check certificate transparency
        # Update target with new information

        return {
            "target_id": target_id,
            "updates": updates,
            "sync_time": datetime.now().isoformat(),
        }

    async def cleanup_stale_data(self, days: int = 90) -> Dict:
        """Clean up old data that's no longer needed."""
        cutoff_date = datetime.now() - timedelta(days=days)

        # Archive old findings
        result = await self.session.execute(
            select(Finding).where(
                and_(
                    Finding.created_at < cutoff_date,
                    Finding.status.in_(["fixed", "false_positive"])
                )
            )
        )
        old_findings = result.scalars().all()

        archived = 0
        for finding in old_findings:
            # Move to archive table or mark as archived
            finding.status = "archived"
            archived += 1

        await self.session.commit()

        return {
            "archived_findings": archived,
            "cutoff_date": cutoff_date.isoformat(),
            "cleanup_time": datetime.now().isoformat(),
        }
```

---

## 5. Tool Arsenal with Commands

### 5.1 Database Migration Commands

```bash
# Create new migration
alembic revision --autogenerate -m "add_findings_table"

# Apply migrations
alembic upgrade head

# Rollback one step
alembic downgrade -1

# Rollback to specific version
alembic downgrade <revision_id>

# Show current version
alembic current

# Show migration history
alembic history --verbose

# Stamp database without running migration
alembic stamp head
```

### 5.2 Backup Commands

```python
# scripts/backup_runner.py
import asyncio
from app.services.backup_service import BackupService, BackupScheduler
from app.db.session import DatabaseSession

async def main():
    """Run backup operations."""
    db_session = DatabaseSession()
    db_session.initialize()

    backup_service = BackupService(
        backup_dir="backups",
        retention_days=30
    )

    # Create backup
    result = await backup_service.create_backup(
        database_url="sqlite+aiosqlite:///./security_platform.db",
        backup_type="full"
    )
    print(f"Backup created: {result}")

    # List backups
    backups = await backup_service.list_backups()
    print(f"Available backups: {len(backups)}")

    # Cleanup old backups
    removed = await backup_service.cleanup_old_backups()
    print(f"Removed {len(removed)} old backups")

if __name__ == "__main__":
    asyncio.run(main())
```

### 5.3 Performance Monitoring

```python
# scripts/monitor_db.py
import asyncio
from app.db.session import DatabaseSession
from scripts.optimize import DatabaseHealthMonitor, QueryOptimizer

async def main():
    """Monitor database performance."""
    db_session = DatabaseSession()
    db_session.initialize()

    async for session in db_session.get_session():
        # Health check
        health_monitor = DatabaseHealthMonitor(session)
        health = await health_monitor.check_health()
        print(f"Health status: {health}")

        # Performance metrics
        metrics = await health_monitor.get_performance_metrics()
        print(f"Performance metrics: {metrics}")

        # Query optimization
        optimizer = QueryOptimizer(session)

        # Find missing indexes
        missing_indexes = await optimizer.find_missing_indexes()
        print(f"Missing indexes: {len(missing_indexes)}")

        # Suggest indexes
        for table in ["targets", "scans", "findings"]:
            suggestions = await optimizer.suggest_indexes(table)
            if suggestions:
                print(f"\nIndex suggestions for {table}:")
                for suggestion in suggestions:
                    print(f"  {suggestion}")

        break

if __name__ == "__main__":
    asyncio.run(main())
```

### 5.4 Data Export/Import

```python
# scripts/data_transfer.py
import csv
import json
from pathlib import Path
from typing import List, Dict
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import asyncio

class DataTransfer:
    """Export and import data between systems."""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def export_findings_csv(self, output_path: str) -> int:
        """Export findings to CSV."""
        result = await self.session.execute(select(Finding))
        findings = result.scalars().all()

        with open(output_path, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([
                'id', 'scan_id', 'target_id', 'title', 'severity',
                'vuln_type', 'endpoint', 'description', 'status'
            ])

            for finding in findings:
                writer.writerow([
                    finding.id, finding.scan_id, finding.target_id,
                    finding.title, finding.severity, finding.vuln_type,
                    finding.endpoint, finding.description, finding.status
                ])

        return len(findings)

    async def import_findings_json(self, input_path: str) -> int:
        """Import findings from JSON."""
        with open(input_path) as f:
            findings_data = json.load(f)

        imported = 0
        for finding_dict in findings_data:
            finding = Finding(**finding_dict)
            self.session.add(finding)
            imported += 1

        await self.session.commit()
        return imported

    async def sync_with_external(self, external_data: List[Dict]) -> Dict:
        """Sync data with external system."""
        # Compare and merge logic
        new = 0
        updated = 0
        unchanged = 0

        for ext_item in external_data:
            result = await self.session.execute(
                select(Finding).where(Finding.id == ext_item.get('id'))
            )
            existing = result.scalar_one_or_none()

            if not existing:
                # New item
                finding = Finding(**ext_item)
                self.session.add(finding)
                new += 1
            else:
                # Check for updates
                if existing.updated_at < ext_item.get('updated_at'):
                    for key, value in ext_item.items():
                        setattr(existing, key, value)
                    updated += 1
                else:
                    unchanged += 1

        await self.session.commit()

        return {
            "new": new,
            "updated": updated,
            "unchanged": unchanged,
        }
```

---

## 6. Real-World Examples

### 6.1 Complete Database Setup Script

```python
# scripts/setup_database.py
import asyncio
from app.db.session import DatabaseSession
from app.models.base import Base
from app.models.target import Target
from app.models.scan import Scan, ScanTarget
from app.models.finding import Finding
from app.models.user import User
from app.services.backup_service import BackupService

async def setup_database():
    """Complete database setup script."""
    print("Setting up database...")

    # Initialize database session
    db_session = DatabaseSession()
    db_session.initialize()

    # Create all tables
    async with db_session.engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("✓ Tables created")

    # Create initial admin user
    async for session in db_session.get_session():
        admin_user = User(
            username="admin",
            email="admin@example.com",
            scopes=["admin", "read", "write"],
            is_active=True,
        )
        session.add(admin_user)
        await session.commit()
        print("✓ Admin user created")

        # Create sample target
        sample_target = Target(
            value="test-target.example.com",
            type="domain",
            scope=["test-target.example.com", "*.test-target.example.com"],
            tags=["test", "sample"],
        )
        session.add(sample_target)
        await session.commit()
        print("✓ Sample target created")

        break

    # Initialize backup service
    backup_service = BackupService(backup_dir="backups")
    print("✓ Backup service initialized")

    # Create initial backup
    result = await backup_service.create_backup(
        database_url="sqlite+aiosqlite:///./security_platform.db",
        backup_type="full"
    )
    print(f"✓ Initial backup created: {result['backup_name']}")

    print("\nDatabase setup complete!")
    print(f"Database: security_platform.db")
    print(f"Backups: backups/")

if __name__ == "__main__":
    asyncio.run(setup_database())
```

### 6.2 Database Seeder for Testing

```python
# scripts/seed_database.py
import asyncio
import random
from datetime import datetime, timedelta
from app.db.session import DatabaseSession
from app.models.target import Target
from app.models.scan import Scan
from app.models.finding import Finding

class DatabaseSeeder:
    """Seed database with test data."""

    def __init__(self, session):
        self.session = session

    async def seed_all(self, num_targets: int = 10, num_scans: int = 20, num_findings: int = 50):
        """Seed database with test data."""
        # Create targets
        targets = []
        for i in range(num_targets):
            target = Target(
                value=f"target{i}.example.com",
                type="domain",
                scope=[f"target{i}.example.com"],
                tags=[f"tag{i % 5}"],
                status="active",
            )
            self.session.add(target)
            targets.append(target)

        await self.session.commit()
        print(f"Created {len(targets)} targets")

        # Create scans
        scans = []
        for i in range(num_scans):
            scan = Scan(
                scan_type=random.choice(["recon", "vuln", "full"]),
                status=random.choice(["completed", "running", "pending"]),
                tools=["subfinder", "httpx", "nuclei"],
                config={"threads": 50},
                priority=random.randint(1, 10),
                started_at=datetime.now() - timedelta(hours=random.randint(1, 100)),
                progress=random.uniform(0, 100),
            )
            self.session.add(scan)
            scans.append(scan)

        await self.session.commit()
        print(f"Created {len(scans)} scans")

        # Create findings
        severities = ["critical", "high", "medium", "low", "info"]
        vuln_types = ["xss", "sqli", "ssrf", "idor", "rce", "info_disclosure"]

        findings = []
        for i in range(num_findings):
            finding = Finding(
                scan_id=random.choice(scans).id,
                target_id=random.choice(targets).id,
                title=f"Vulnerability {i + 1}",
                severity=random.choice(severities),
                vuln_type=random.choice(vuln_types),
                endpoint=f"http://target.example.com/path{i}",
                description=f"Description of vulnerability {i + 1}",
                status=random.choice(["open", "confirmed", "fixed"]),
                cvss_score=random.uniform(0, 10),
            )
            self.session.add(finding)
            findings.append(finding)

        await self.session.commit()
        print(f"Created {len(findings)} findings")

async def main():
    """Run database seeder."""
    db_session = DatabaseSession()
    db_session.initialize()

    async for session in db_session.get_session():
        seeder = DatabaseSeeder(session)
        await seeder.seed_all()
        break

    print("Database seeded successfully!")

if __name__ == "__main__":
    asyncio.run(main())
```

### 6.3 Database Report Generator

```python
# scripts/generate_report.py
import asyncio
from datetime import datetime, timedelta
from app.db.session import DatabaseSession
from sqlalchemy import select, func
from typing import Dict

class DatabaseReport:
    """Generate database reports."""

    def __init__(self, session):
        self.session = session

    async def generate_summary_report(self) -> Dict:
        """Generate summary report."""
        report = {
            "generated_at": datetime.now().isoformat(),
            "targets": {},
            "scans": {},
            "findings": {},
        }

        # Target statistics
        result = await self.session.execute(
            select(func.count(Target.id))
        )
        report["targets"]["total"] = result.scalar()

        result = await self.session.execute(
            select(func.count(Target.id)).where(Target.status == "active")
        )
        report["targets"]["active"] = result.scalar()

        # Scan statistics
        result = await self.session.execute(
            select(func.count(Scan.id))
        )
        report["scans"]["total"] = result.scalar()

        result = await self.session.execute(
            select(func.count(Scan.id)).where(Scan.status == "completed")
        )
        report["scans"]["completed"] = result.scalar()

        # Finding statistics
        result = await self.session.execute(
            select(func.count(Finding.id))
        )
        report["findings"]["total"] = result.scalar()

        # By severity
        for severity in ["critical", "high", "medium", "low", "info"]:
            result = await self.session.execute(
                select(func.count(Finding.id)).where(Finding.severity == severity)
            )
            report["findings"][severity] = result.scalar()

        return report

    async def generate_trend_report(self, days: int = 30) -> Dict:
        """Generate trend report for specified period."""
        start_date = datetime.now() - timedelta(days=days)

        report = {
            "period": f"Last {days} days",
            "start_date": start_date.isoformat(),
            "end_date": datetime.now().isoformat(),
            "findings_by_day": {},
        }

        # Findings per day
        for i in range(days):
            date = start_date + timedelta(days=i)
            next_date = date + timedelta(days=1)

            result = await self.session.execute(
                select(func.count(Finding.id)).where(
                    and_(
                        Finding.created_at >= date,
                        Finding.created_at < next_date
                    )
                )
            )
            report["findings_by_day"][date.strftime("%Y-%m-%d")] = result.scalar()

        return report

async def main():
    """Generate reports."""
    db_session = DatabaseSession()
    db_session.initialize()

    async for session in db_session.get_session():
        reporter = DatabaseReport(session)

        summary = await reporter.generate_summary_report()
        print("Summary Report:")
        print(f"  Targets: {summary['targets']['total']}")
        print(f"  Scans: {summary['scans']['total']}")
        print(f"  Findings: {summary['findings']['total']}")

        trends = await reporter.generate_trend_report(7)
        print(f"\nTrend Report ({trends['period']}):")
        for date, count in trends["findings_by_day"].items():
            print(f"  {date}: {count} findings")

        break

if __name__ == "__main__":
    asyncio.run(main())
```

---

## 7. Common Pitfalls

### 7.1 Connection Pool Exhaustion

```python
# Proper connection pool management
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

# BAD: No pool configuration
engine = create_engine("postgresql://localhost/db")

# GOOD: Proper pool configuration
engine = create_engine(
    "postgresql://localhost/db",
    pool_size=20,          # Number of connections to maintain
    max_overflow=10,       # Additional connections when pool is full
    pool_timeout=30,       # Seconds to wait for connection
    pool_recycle=1800,     # Recycle connections after 30 minutes
    pool_pre_ping=True,    # Verify connections before use
)
```

### 7.2 N+1 Query Problem

```python
# BAD: N+1 queries
async def get_scans_with_targets():
    scans = await session.execute(select(Scan))
    for scan in scans.scalars():
        # This runs a separate query for each scan!
        targets = await session.execute(
            select(Target).join(ScanTarget).where(ScanTarget.scan_id == scan.id)
        )

# GOOD: Eager loading
async def get_scans_with_targets():
    result = await session.execute(
        select(Scan).options(selectinload(Scan.targets))
    )
    return result.scalars().all()
```

### 7.3 Unparameterized Queries (SQL Injection)

```python
# BAD: SQL injection vulnerability
async def get_target_bad(domain: str):
    query = f"SELECT * FROM targets WHERE value = '{domain}'"
    result = await session.execute(text(query))

# GOOD: Parameterized query
async def get_target_good(domain: str):
    result = await session.execute(
        text("SELECT * FROM targets WHERE value = :domain"),
        {"domain": domain}
    )
```

### 7.4 Missing Indexes

```python
# Check for missing indexes
async def check_indexes(session):
    result = await session.execute(text("""
        SELECT
            schemaname,
            relname as table_name,
            seq_scan,
            idx_scan
        FROM pg_stat_user_tables
        WHERE seq_scan > 1000
            AND (idx_scan IS NULL OR idx_scan < seq_scan / 10)
    """))

    for row in result:
        print(f"Table {row.table_name}: {row.seq_scan} seq scans, {row.idx_scan} idx scans")
        print(f"  Consider adding indexes")
```

### 7.5 Not Using Transactions

```python
# BAD: No transaction
async def update_finding_bad(finding_id: str, status: str):
    await session.execute(
        text("UPDATE findings SET status = :status WHERE id = :id"),
        {"status": status, "id": finding_id}
    )
    # If this fails, previous update is already committed!

# GOOD: Use transactions
async def update_finding_good(finding_id: str, status: str):
    async with session.begin():
        await session.execute(
            text("UPDATE findings SET status = :status WHERE id = :id"),
            {"status": status, "id": finding_id}
        )
        # Everything is committed together or rolled back on error
```

---

## 8. Advanced Techniques

### 8.1 Database Sharding

```python
# Shard manager for horizontal scaling
class ShardManager:
    """Manage database shards for horizontal scaling."""

    def __init__(self, shard_configs: List[Dict]):
        self.shards = {}
        for config in shard_configs:
            engine = create_engine(config["url"])
            self.shards[config["name"]] = {
                "engine": engine,
                "weight": config.get("weight", 1),
            }

    def get_shard(self, key: str) -> str:
        """Get shard for a given key using consistent hashing."""
        hash_value = hash(key)
        total_weight = sum(s["weight"] for s in self.shards.values())
        current_weight = 0

        for shard_name, shard in self.shards.items():
            current_weight += shard["weight"]
            if hash_value % total_weight < current_weight:
                return shard_name

        return list(self.shards.keys())[0]

    async def execute_on_shard(self, shard_name: str, query, params=None):
        """Execute query on specific shard."""
        shard = self.shards[shard_name]
        async with shard["engine"].connect() as conn:
            return await conn.execute(query, params)
```

### 8.2 Read Replicas

```python
# Read replica manager
class ReadReplicaManager:
    """Manage read replicas for load distribution."""

    def __init__(self, primary_url: str, replica_urls: List[str]):
        self.primary = create_async_engine(primary_url)
        self.replicas = [create_async_engine(url) for url in replica_urls]
        self.current_replica = 0

    def get_read_session(self) -> AsyncSession:
        """Get session from round-robin replica."""
        replica_engine = self.replicas[self.current_replica % len(self.replicas)]
        self.current_replica += 1
        return async_sessionmaker(bind=replica_engine)()

    def get_write_session(self) -> AsyncSession:
        """Get session from primary for writes."""
        return async_sessionmaker(bind=self.primary)()
```

### 8.3 Change Data Capture (CDC)

```python
# CDC implementation
class ChangeDataCapture:
    """Capture and stream database changes."""

    def __init__(self, session: AsyncSession):
        self.session = session
        self.change_log = []

    async def setup_triggers(self):
        """Set up database triggers for CDC."""
        # PostgreSQL example
        await self.session.execute(text("""
            CREATE OR REPLACE FUNCTION audit_trigger_func()
            RETURNS TRIGGER AS $$
            BEGIN
                INSERT INTO audit_log (table_name, record_id, action, old_data, new_data)
                VALUES (
                    TG_TABLE_NAME,
                    COALESCE(NEW.id, OLD.id),
                    TG_OP,
                    CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) END,
                    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) END
                );
                RETURN NEW;
            END;
            $$ LANGUAGE plpgsql;
        """))

    async def capture_changes(self, table_name: str):
        """Capture changes for a table."""
        result = await self.session.execute(
            text(f"SELECT * FROM audit_log WHERE table_name = :table_name ORDER BY created_at DESC"),
            {"table_name": table_name}
        )
        return [dict(row) for row in result]
```

---

## 9. Reporting Template

### 9.1 Database Health Report

```markdown
# Database Health Report

## Overview
- **Database**: {database_name}
- **Type**: PostgreSQL / SQLite / MySQL
- **Size**: {db_size}
- **Uptime**: {uptime}
- **Last Backup**: {last_backup_time}

## Connection Pool Status
- **Pool Size**: {pool_size}
- **Active Connections**: {active_connections}
- **Idle Connections**: {idle_connections}
- **Waiting Requests**: {waiting_requests}

## Performance Metrics
- **Queries per Second**: {qps}
- **Average Query Time**: {avg_query_time}ms
- **Cache Hit Ratio**: {cache_hit_ratio}%
- **Index Hit Ratio**: {index_hit_ratio}%

## Table Statistics

| Table | Row Count | Size | Indexes | Seq Scans |
|-------|-----------|------|---------|-----------|
| targets | 1,234 | 256 KB | 3 | 45 |
| scans | 5,678 | 1.2 MB | 4 | 123 |
| findings | 12,345 | 2.5 MB | 5 | 234 |

## Slow Queries (>100ms)
1. SELECT * FROM findings WHERE severity = 'high' (avg: 250ms)
2. SELECT * FROM scans WHERE status = 'running' (avg: 180ms)

## Recommendations
1. Add index on findings.severity (high cardinality)
2. Increase pool_size to 30 (current utilization: 85%)
3. Enable connection recycling (pool_recycle=1800)
4. Archive old findings (>90 days)
```

### 9.2 Migration Report

```markdown
# Migration Report

## Migration Summary
- **Total Migrations**: {total_migrations}
- **Last Migration**: {last_migration_date}
- **Current Revision**: {current_revision}
- **Pending Migrations**: {pending_count}

## Recent Migrations

| Revision | Description | Date | Status |
|----------|-------------|------|--------|
| abc123 | Add findings table | 2024-01-15 | Applied |
| def456 | Add indexes | 2024-01-10 | Applied |
| ghi789 | Create users table | 2024-01-05 | Applied |

## Schema Changes
- **Tables Added**: 3
- **Columns Added**: 12
- **Indexes Added**: 5
- **Foreign Keys Added**: 4

## Rollback Plan
1. alembic downgrade -1 (revert last migration)
2. alembic downgrade <revision> (revert to specific version)
3. Restore from backup (if needed)
```

---

## 10. Quick Reference

### 10.1 Essential Commands

```bash
# Database setup
alembic upgrade head              # Apply all migrations
alembic downgrade -1              # Rollback one migration
alembic current                   # Show current version
alembic history                   # Show migration history

# Backup operations
pg_dump -U user -d dbname > backup.sql      # PostgreSQL backup
pg_restore -U user -d dbname backup.sql     # PostgreSQL restore
sqlite3 backup.db .dump > backup.sql        # SQLite backup

# Performance monitoring
pg_stat_activity                  # View active queries
pg_stat_user_tables               # View table statistics
pg_stat_statements                # View query statistics
```

### 10.2 SQLAlchemy Quick Reference

```python
# Basic operations
from sqlalchemy import select, update, delete
from sqlalchemy.orm import selectinload

# SELECT
result = await session.execute(select(Model).where(Model.id == id))
obj = result.scalar_one_or_none()

# SELECT with joins
result = await session.execute(
    select(Model).options(selectinload(Model.related))
)

# INSERT
obj = Model(**data)
session.add(obj)
await session.commit()

# UPDATE
await session.execute(
    update(Model).where(Model.id == id).values(**data)
)
await session.commit()

# DELETE
await session.execute(delete(Model).where(Model.id == id))
await session.commit()
```

### 10.3 Performance Tuning Checklist

```markdown
## Performance Tuning Checklist

### Indexes
- [ ] Primary keys indexed
- [ ] Foreign keys indexed
- [ ] Frequently queried columns indexed
- [ ] Composite indexes for multi-column queries
- [ ] Partial indexes for filtered queries

### Queries
- [ ] No SELECT * (select only needed columns)
- [ ] Use parameterized queries
- [ ] Avoid N+1 queries (use eager loading)
- [ ] Use cursor-based pagination
- [ ] Limit result sets

### Connection Pool
- [ ] Pool size appropriate for workload
- [ ] Connection recycling enabled
- [ ] Pre-ping enabled
- [ ] Timeout configured

### Maintenance
- [ ] Regular VACUUM/ANALYZE
- [ ] Old data archived
- [ ] Backups tested regularly
- [ ] Monitoring in place
```

### 10.4 Troubleshooting Guide

| Problem | Cause | Solution |
|---------|-------|----------|
| Connection refused | Pool exhausted | Increase pool_size |
| Slow queries | Missing indexes | Add appropriate indexes |
| Lock waits | Long transactions | Reduce transaction duration |
| Disk full | Large tables | Archive old data |
| Replication lag | Heavy writes | Optimize queries |
| Deadlocks | Conflicting locks | Order table access consistently |
| Memory high | Large result sets | Add LIMIT, paginate |
| Backup fails | Disk space | Clean old backups |
