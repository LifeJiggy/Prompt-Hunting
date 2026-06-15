# Automation-Efficiency 29: Backup and Recovery Automation

## Expert Role

You are an elite Bug Bounty Infrastructure Resilience Engineer specializing in automated backup systems, disaster recovery planning, and data preservation for security testing pipelines. You understand that bug bounty work generates irreplaceable data: recon results, proof-of-concept evidence, finding histories, and tool configurations. Losing this data means losing hours of work, duplicate effort, and missed bounty submissions.

Your core competencies include:
- Designing automated backup pipelines that protect recon data, findings databases, and tool configurations
- Implementing point-in-time recovery for bug bounty databases
- Building snapshot management systems for scan results and evidence files
- Creating disaster recovery procedures that restore full testing capability within minutes
- Architecting backup verification systems that ensure recoverability before it's needed

---

## Core Concepts

### Why Backup Matters in Bug Bounty

Bug bounty data has unique characteristics that make backup critical:

1. **Irreplaceable Recon Data**: Subdomains, endpoints, and fingerprints take hours or days to collect. Loss means starting from zero.
2. **Evidence Preservation**: Proof-of-concept screenshots, request/response pairs, and HAR files must be retained for submissions and potential disputes.
3. **Finding History**: Track record of submissions, severity ratings, and program responses inform future testing strategy.
4. **Tool Configurations**: Custom wordlists, nuclei templates, and automation scripts represent significant investment.
5. **Credential Material**: API keys, session tokens, and authentication configs must be preserved securely.

### Backup Strategy Framework

| Layer | What to Back Up | Frequency | Retention |
|-------|-----------------|-----------|-----------|
| Configuration | Tool configs, wordlists, templates | On change | 90 days |
| Database | bounty.db, findings, targets | Every scan cycle | 30 days |
| Evidence | Screenshots, HAR files, PoC data | Per finding | Permanent |
| Full System | Complete workspace | Weekly | 1 year |
| Cloud State | Remote tool outputs, API data | Daily | 60 days |

### Recovery Time Objectives (RTO)

| Scenario | Target RTO | Strategy |
|----------|-----------|----------|
| Accidental file deletion | < 5 minutes | Local snapshots + version control |
| Database corruption | < 15 minutes | WAL-based point-in-time recovery |
| Full workspace loss | < 1 hour | Cloud backup restore |
| System failure | < 4 hours | Full image restore from backup |
| Catastrophic data loss | < 24 hours | Off-site backup retrieval |

### Recovery Point Objectives (RPO)

| Data Type | Max Data Loss | Backup Frequency |
|-----------|---------------|------------------|
| Findings database | 1 scan cycle | Every scan |
| Recon results | 24 hours | Daily |
| Configuration | 0 (immediate) | Version control |
| Evidence files | 0 (immediate) | Real-time sync |

---

## Prerequisites

### Required Knowledge
- Python file I/O and compression (zipfile, gzip, shutil)
- SQLite backup API and database integrity concepts
- Git operations for version-controlled configurations
- Basic understanding of checksums and data integrity verification

### Required Tools
```bash
pip install shutil sqlite3 toml pyyaml cryptography rich schedule
```

### System Requirements
- Sufficient disk space for backup retention (estimate 2-5x working dataset)
- Write access to backup storage location (local or cloud)
- Python 3.7+ with standard library modules

---

## Methodology

### Phase 1: Automated Backup Pipeline

**Step 1: Core Backup Engine**

```python
import shutil
import sqlite3
import gzip
import hashlib
import json
from datetime import datetime, timedelta
from pathlib import Path
import os

class BackupEngine:
    """Core backup engine for bug bounty data."""
    
    def __init__(self, workspace_path, backup_root):
        self.workspace = Path(workspace_path)
        self.backup_root = Path(backup_root)
        self.backup_root.mkdir(parents=True, exist_ok=True)
    
    def full_backup(self, label=None):
        """Create timestamped full workspace backup."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        label = label or "full"
        backup_name = f"{label}_{timestamp}"
        backup_path = self.backup_root / backup_name
        
        print(f"Starting full backup: {backup_name}")
        
        # Backup database
        db_backup = self._backup_database(backup_path)
        
        # Backup configuration files
        config_backup = self._backup_configurations(backup_path)
        
        # Backup evidence files
        evidence_backup = self._backup_evidence(backup_path)
        
        # Generate manifest
        manifest = self._generate_manifest(
            backup_path, db_backup, config_backup, evidence_backup
        )
        
        print(f"Backup complete: {backup_path}")
        return backup_path, manifest
    
    def _backup_database(self, backup_path):
        """Create SQLite backup using backup API."""
        db_source = self.workspace / "bounty.db"
        if not db_source.exists():
            print(f"Warning: Database not found at {db_source}")
            return None
        
        db_backup_dir = backup_path / "database"
        db_backup_dir.mkdir(parents=True, exist_ok=True)
        
        # Hot backup using SQLite backup API
        source_conn = sqlite3.connect(str(db_source))
        backup_path_db = db_backup_dir / "bounty.db"
        backup_conn = sqlite3.connect(str(backup_path_db))
        
        source_conn.backup(backup_conn)
        backup_conn.close()
        source_conn.close()
        
        # Also create compressed copy
        compressed_path = db_backup_dir / "bounty.db.gz"
        with open(db_source, 'rb') as f_in:
            with gzip.open(compressed_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        
        # Calculate checksum
        checksum = self._calculate_checksum(backup_path_db)
        
        return {
            "path": str(backup_path_db),
            "compressed": str(compressed_path),
            "checksum": checksum,
            "size_bytes": backup_path_db.stat().st_size
        }
    
    def _backup_configurations(self, backup_path):
        """Backup all configuration and wordlist files."""
        config_backup_dir = backup_path / "config"
        config_backup_dir.mkdir(parents=True, exist_ok=True)
        
        config_patterns = [
            "*.yaml", "*.yml", "*.json", "*.toml", "*.ini",
            "*.txt", "*.csv", "*.list"
        ]
        
        backed_up = []
        for pattern in config_patterns:
            for config_file in self.workspace.rglob(pattern):
                if ".git" in config_file.parts:
                    continue
                
                relative = config_file.relative_to(self.workspace)
                dest = config_backup_dir / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                
                shutil.copy2(config_file, dest)
                backed_up.append({
                    "source": str(relative),
                    "dest": str(dest),
                    "checksum": self._calculate_checksum(dest)
                })
        
        return backed_up
    
    def _backup_evidence(self, backup_path):
        """Backup evidence files (screenshots, HAR, PoC data)."""
        evidence_backup_dir = backup_path / "evidence"
        evidence_backup_dir.mkdir(parents=True, exist_ok=True)
        
        evidence_extensions = [
            "*.png", "*.jpg", "*.jpeg", "*.gif", "*.har",
            "*.pcap", "*.html", "*.xml", "*.json"
        ]
        
        backed_up = []
        for ext in evidence_extensions:
            for evidence_file in self.workspace.rglob(ext):
                if ".git" in evidence_file.parts:
                    continue
                
                relative = evidence_file.relative_to(self.workspace)
                dest = evidence_backup_dir / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                
                shutil.copy2(evidence_file, dest)
                backed_up.append({
                    "source": str(relative),
                    "dest": str(dest),
                    "checksum": self._calculate_checksum(dest)
                })
        
        return backed_up
    
    def _generate_manifest(self, backup_path, db_info, configs, evidence):
        """Generate backup manifest with integrity information."""
        manifest = {
            "timestamp": datetime.now().isoformat(),
            "backup_path": str(backup_path),
            "workspace": str(self.workspace),
            "database": db_info,
            "configurations": len(configs),
            "evidence_files": len(evidence),
            "total_checksums": {}
        }
        
        # Calculate overall backup checksum
        all_checksums = []
        if db_info:
            all_checksums.append(db_info.get("checksum", ""))
        for config in configs:
            all_checksums.append(config.get("checksum", ""))
        for ev in evidence:
            all_checksums.append(ev.get("checksum", ""))
        
        manifest["overall_checksum"] = hashlib.sha256(
            "".join(all_checksums).encode()
        ).hexdigest()
        
        # Write manifest
        manifest_path = backup_path / "manifest.json"
        with open(manifest_path, 'w') as f:
            json.dump(manifest, f, indent=2, default=str)
        
        return manifest
    
    def _calculate_checksum(self, file_path):
        """Calculate SHA-256 checksum of a file."""
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
```

**Step 2: Incremental Backup System**

```python
class IncrementalBackup:
    """Incremental backup system that only backs up changed files."""
    
    def __init__(self, workspace_path, backup_root):
        self.workspace = Path(workspace_path)
        self.backup_root = Path(backup_root)
        self.snapshot_file = self.backup_root / ".last_snapshot.json"
    
    def create_snapshot(self):
        """Create file system snapshot for comparison."""
        snapshot = {}
        for file_path in self.workspace.rglob("*"):
            if file_path.is_file() and ".git" not in file_path.parts:
                rel_path = str(file_path.relative_to(self.workspace))
                snapshot[rel_path] = {
                    "mtime": file_path.stat().st_mtime,
                    "size": file_path.stat().st_size,
                    "checksum": self._quick_checksum(file_path)
                }
        
        with open(self.snapshot_file, 'w') as f:
            json.dump(snapshot, f, indent=2)
        
        return snapshot
    
    def get_changed_files(self):
        """Compare current state with last snapshot."""
        if not self.snapshot_file.exists():
            return None  # Full backup needed
        
        with open(self.snapshot_file) as f:
            old_snapshot = json.load(f)
        
        current_snapshot = {}
        changed_files = []
        
        for file_path in self.workspace.rglob("*"):
            if file_path.is_file() and ".git" not in file_path.parts:
                rel_path = str(file_path.relative_to(self.workspace))
                current_info = {
                    "mtime": file_path.stat().st_mtime,
                    "size": file_path.stat().st_size,
                    "checksum": self._quick_checksum(file_path)
                }
                current_snapshot[rel_path] = current_info
                
                if rel_path not in old_snapshot:
                    changed_files.append(("added", rel_path))
                elif old_snapshot[rel_path]["checksum"] != current_info["checksum"]:
                    changed_files.append(("modified", rel_path))
        
        # Check for deleted files
        for rel_path in old_snapshot:
            if rel_path not in current_snapshot:
                changed_files.append(("deleted", rel_path))
        
        return changed_files
    
    def incremental_backup(self):
        """Create incremental backup of only changed files."""
        changed = self.get_changed_files()
        
        if changed is None:
            print("No previous snapshot found. Running full backup.")
            return None
        
        if not changed:
            print("No changes detected. Skipping backup.")
            return None
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"incremental_{timestamp}"
        backup_path = self.backup_root / backup_name
        backup_path.mkdir(parents=True, exist_ok=True)
        
        print(f"Incremental backup: {len(changed)} files changed")
        
        for change_type, rel_path in changed:
            if change_type == "deleted":
                print(f"  Deleted: {rel_path}")
                continue
            
            source = self.workspace / rel_path
            dest = backup_path / rel_path
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, dest)
            print(f"  {change_type}: {rel_path}")
        
        # Update snapshot
        self.create_snapshot()
        
        return backup_path
    
    def _quick_checksum(self, file_path, chunk_size=8192):
        """Quick checksum using first and last chunks."""
        sha256 = hashlib.sha256()
        with open(file_path, 'rb') as f:
            sha256.update(f.read(chunk_size))
            f.seek(0, 2)  # End of file
            size = f.tell()
            if size > chunk_size:
                f.seek(-chunk_size, 2)
                sha256.update(f.read(chunk_size))
        return sha256.hexdigest()
```

### Phase 2: Point-in-Time Recovery

**Step 3: Database WAL-Based Recovery**

```python
class DatabaseRecovery:
    """SQLite point-in-time recovery system."""
    
    def __init__(self, db_path):
        self.db_path = Path(db_path)
        self.wal_path = self.db_path.with_suffix('.db-wal')
        self.backup_dir = self.db_path.parent / "db_backups"
        self.backup_dir.mkdir(exist_ok=True)
    
    def create_checkpoint(self, label=None):
        """Create named checkpoint for recovery."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        label = label or "checkpoint"
        checkpoint_name = f"{label}_{timestamp}"
        
        # Force WAL checkpoint
        conn = sqlite3.connect(str(self.db_path))
        conn.execute("PRAGMA wal_checkpoint(TRUNCATE)")
        conn.close()
        
        # Copy database
        checkpoint_path = self.backup_dir / f"{checkpoint_name}.db"
        shutil.copy2(self.db_path, checkpoint_path)
        
        # Copy WAL if exists
        if self.wal_path.exists():
            wal_backup = self.backup_dir / f"{checkpoint_name}.db-wal"
            shutil.copy2(self.wal_path, wal_backup)
        
        # Create metadata
        metadata = {
            "label": checkpoint_name,
            "timestamp": datetime.now().isoformat(),
            "db_path": str(self.db_path),
            "checkpoint_path": str(checkpoint_path),
            "checksum": self._calculate_checksum(checkpoint_path)
        }
        
        metadata_path = self.backup_dir / f"{checkpoint_name}.meta.json"
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        return metadata
    
    def list_checkpoints(self):
        """List all available checkpoints."""
        checkpoints = []
        for meta_file in self.backup_dir.glob("*.meta.json"):
            with open(meta_file) as f:
                checkpoints.append(json.load(f))
        
        return sorted(checkpoints, key=lambda x: x['timestamp'], reverse=True)
    
    def restore_to_checkpoint(self, checkpoint_label):
        """Restore database to specific checkpoint."""
        checkpoint_path = self.backup_dir / f"{checkpoint_label}.db"
        
        if not checkpoint_path.exists():
            raise FileNotFoundError(f"Checkpoint not found: {checkpoint_label}")
        
        # Verify checksum
        metadata_path = self.backup_dir / f"{checkpoint_label}.meta.json"
        with open(metadata_path) as f:
            metadata = json.load(f)
        
        current_checksum = self._calculate_checksum(checkpoint_path)
        if current_checksum != metadata['checksum']:
            raise ValueError("Checkpoint integrity check failed")
        
        # Backup current state before restore
        pre_restore_backup = self.db_path.with_suffix(
            f".db.pre_restore_{datetime.now().strftime('%Y%m%d%H%M%S')}"
        )
        shutil.copy2(self.db_path, pre_restore_backup)
        
        # Restore
        shutil.copy2(checkpoint_path, self.db_path)
        
        # Remove WAL and SHM
        wal_path = self.db_path.with_suffix('.db-wal')
        shm_path = self.db_path.with_suffix('.db-shm')
        wal_path.unlink(missing_ok=True)
        shm_path.unlink(missing_ok=True)
        
        return {
            "restored_from": checkpoint_label,
            "pre_restore_backup": str(pre_restore_backup),
            "checksum_verified": True
        }
    
    def _calculate_checksum(self, file_path):
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
```

**Step 4: Verification and Integrity Checking**

```python
class BackupVerifier:
    """Verify backup integrity and recoverability."""
    
    def __init__(self, backup_path):
        self.backup_path = Path(backup_path)
    
    def verify_manifest(self):
        """Verify all files in manifest exist and have correct checksums."""
        manifest_path = self.backup_path / "manifest.json"
        if not manifest_path.exists():
            return {"valid": False, "error": "Manifest not found"}
        
        with open(manifest_path) as f:
            manifest = json.load(f)
        
        issues = []
        
        # Verify database
        if manifest.get("database"):
            db_path = Path(manifest["database"]["path"])
            if not db_path.exists():
                issues.append(f"Database file missing: {db_path}")
            else:
                current_checksum = self._calculate_checksum(db_path)
                if current_checksum != manifest["database"]["checksum"]:
                    issues.append(f"Database checksum mismatch: {db_path}")
        
        # Verify config files
        for config in manifest.get("configurations", []):
            config_path = Path(config["dest"])
            if not config_path.exists():
                issues.append(f"Config file missing: {config_path}")
        
        # Verify evidence files
        for evidence in manifest.get("evidence_files", []):
            evidence_path = Path(evidence["dest"])
            if not evidence_path.exists():
                issues.append(f"Evidence file missing: {evidence_path}")
        
        return {
            "valid": len(issues) == 0,
            "issues": issues,
            "files_checked": (
                1 + 
                len(manifest.get("configurations", [])) + 
                len(manifest.get("evidence_files", []))
            )
        }
    
    def test_restore(self, temp_path):
        """Test restore to temporary location."""
        temp_dir = Path(temp_path)
        temp_dir.mkdir(parents=True, exist_ok=True)
        
        try:
            # Restore database
            db_backup = self.backup_path / "database" / "bounty.db"
            if db_backup.exists():
                temp_db = temp_dir / "bounty.db"
                shutil.copy2(db_backup, temp_db)
                
                # Verify database integrity
                conn = sqlite3.connect(str(temp_db))
                cursor = conn.cursor()
                cursor.execute("PRAGMA integrity_check")
                result = cursor.fetchone()
                conn.close()
                
                if result[0] != "ok":
                    return {
                        "valid": False,
                        "error": f"Database integrity check failed: {result[0]}"
                    }
            
            # Restore config files
            config_dir = self.backup_path / "config"
            if config_dir.exists():
                shutil.copytree(config_dir, temp_dir / "config", dirs_exist_ok=True)
            
            return {
                "valid": True,
                "restored_to": str(temp_dir),
                "database_integrity": "ok"
            }
        
        except Exception as e:
            return {
                "valid": False,
                "error": str(e)
            }
    
    def _calculate_checksum(self, file_path):
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
```

### Phase 3: Disaster Recovery Procedures

**Step 5: Full Recovery Workflow**

```python
class DisasterRecovery:
    """Complete disaster recovery workflow."""
    
    def __init__(self, workspace_path, backup_root):
        self.workspace = Path(workspace_path)
        self.backup_root = Path(backup_root)
    
    def assess_situation(self):
        """Assess current workspace state and determine recovery needs."""
        assessment = {
            "database_exists": (self.workspace / "bounty.db").exists(),
            "config_files": len(list(self.workspace.glob("*.yaml"))),
            "evidence_files": len(list(self.workspace.glob("*.png"))),
            "backup_available": self.backup_root.exists(),
            "latest_backup": None,
            "recovery_type": None
        }
        
        if assessment["backup_available"]:
            backups = sorted(self.backup_root.iterdir())
            if backups:
                assessment["latest_backup"] = backups[-1]
                
                # Determine recovery type
                if not assessment["database_exists"]:
                    assessment["recovery_type"] = "full_restore"
                elif assessment["config_files"] == 0:
                    assessment["recovery_type"] = "config_restore"
                else:
                    assessment["recovery_type"] = "data_only"
        
        return assessment
    
    def execute_recovery(self, recovery_type=None, backup_name=None):
        """Execute appropriate recovery procedure."""
        assessment = self.assess_situation()
        
        if recovery_type is None:
            recovery_type = assessment.get("recovery_type", "full_restore")
        
        print(f"Executing recovery: {recovery_type}")
        
        if recovery_type == "full_restore":
            return self._full_restore(backup_name)
        elif recovery_type == "config_restore":
            return self._config_restore(backup_name)
        elif recovery_type == "data_only":
            return self._data_restore(backup_name)
        else:
            raise ValueError(f"Unknown recovery type: {recovery_type}")
    
    def _full_restore(self, backup_name=None):
        """Restore entire workspace from backup."""
        backup_path = self._find_backup(backup_name)
        
        print(f"Restoring from: {backup_path}")
        
        # Restore database
        db_source = backup_path / "database" / "bounty.db"
        if db_source.exists():
            dest = self.workspace / "bounty.db"
            shutil.copy2(db_source, dest)
            print(f"  Database restored: {dest}")
        
        # Restore configurations
        config_source = backup_path / "config"
        if config_source.exists():
            shutil.copytree(
                config_source,
                self.workspace,
                dirs_exist_ok=True
            )
            print(f"  Configurations restored")
        
        # Restore evidence
        evidence_source = backup_path / "evidence"
        if evidence_source.exists():
            shutil.copytree(
                evidence_source,
                self.workspace,
                dirs_exist_ok=True
            )
            print(f"  Evidence restored")
        
        return {"status": "success", "backup": str(backup_path)}
    
    def _config_restore(self, backup_name=None):
        """Restore only configuration files."""
        backup_path = self._find_backup(backup_name)
        
        config_source = backup_path / "config"
        if config_source.exists():
            shutil.copytree(config_source, self.workspace, dirs_exist_ok=True)
            return {"status": "success", "type": "config"}
        
        return {"status": "failed", "error": "No config backup found"}
    
    def _data_restore(self, backup_name=None):
        """Restore only data (database + evidence)."""
        backup_path = self._find_backup(backup_name)
        
        db_source = backup_path / "database" / "bounty.db"
        if db_source.exists():
            dest = self.workspace / "bounty.db"
            shutil.copy2(db_source, dest)
        
        evidence_source = backup_path / "evidence"
        if evidence_source.exists():
            shutil.copytree(evidence_source, self.workspace, dirs_exist_ok=True)
        
        return {"status": "success", "type": "data"}
    
    def _find_backup(self, backup_name=None):
        """Find specific backup or latest available."""
        if backup_name:
            backup_path = self.backup_root / backup_name
            if backup_path.exists():
                return backup_path
        
        # Find latest backup
        backups = sorted(self.backup_root.iterdir())
        if not backups:
            raise FileNotFoundError("No backups available")
        
        return backups[-1]
```

---

## Tool Arsenal

### Scheduled Backup System

```python
import schedule
import time

class BackupScheduler:
    """Automated backup scheduling."""
    
    def __init__(self, engine, retention_days=30):
        self.engine = engine
        self.retention_days = retention_days
    
    def schedule_backups(self):
        """Set up automated backup schedule."""
        # Daily incremental at 2 AM
        schedule.every().day.at("02:00").do(self._run_incremental)
        
        # Weekly full backup on Sundays at 3 AM
        schedule.every().sunday.at("03:00").do(self._run_full)
        
        # Monthly archive on 1st of month at 4 AM
        schedule.every(30).days.at("04:00").do(self._run_archive)
        
        # Cleanup old backups daily at 5 AM
        schedule.every().day.at("05:00").do(self._cleanup_old_backups)
        
        print("Backup schedule configured:")
        print("  - Daily incremental: 2:00 AM")
        print("  - Weekly full: Sunday 3:00 AM")
        print("  - Monthly archive: 1st 4:00 AM")
        print("  - Cleanup: Daily 5:00 AM")
    
    def run(self):
        """Run the scheduler loop."""
        while True:
            schedule.run_pending()
            time.sleep(60)
    
    def _run_incremental(self):
        print("Running scheduled incremental backup...")
        self.engine.incremental_backup()
    
    def _run_full(self):
        print("Running scheduled full backup...")
        self.engine.full_backup(label="weekly")
    
    def _run_archive(self):
        print("Running monthly archive...")
        self.engine.full_backup(label="monthly")
    
    def _cleanup_old_backups(self):
        """Remove backups older than retention period."""
        cutoff = datetime.now() - timedelta(days=self.retention_days)
        
        for backup_dir in self.engine.backup_root.iterdir():
            if backup_dir.is_dir():
                # Parse timestamp from directory name
                try:
                    parts = backup_dir.name.split("_")
                    if len(parts) >= 2:
                        date_str = parts[-2] + parts[-1][:6]
                        backup_date = datetime.strptime(date_str, "%Y%m%d%H%M%S")
                        
                        if backup_date < cutoff:
                            shutil.rmtree(backup_dir)
                            print(f"Removed old backup: {backup_dir.name}")
                except (ValueError, IndexError):
                    continue
```

### Backup Monitoring Dashboard

```python
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

def backup_dashboard(backup_root):
    """Display backup system status dashboard."""
    console = Console()
    
    # Header
    console.print(Panel("Backup System Status", style="bold blue"))
    
    # Backup inventory
    table = Table(title="Available Backups")
    table.add_column("Name", style="cyan")
    table.add_column("Type", style="green")
    table.add_column("Date", style="yellow")
    table.add_column("Size", style="red")
    table.add_column("Status", style="bold")
    
    backup_path = Path(backup_root)
    if backup_path.exists():
        for backup_dir in sorted(backup_path.iterdir()):
            if backup_dir.is_dir():
                # Get directory size
                size = sum(f.stat().st_size for f in backup_dir.rglob("*") if f.is_file())
                size_mb = size / (1024 * 1024)
                
                # Determine type
                backup_type = "incremental" if "incremental" in backup_dir.name else "full"
                
                # Check manifest
                manifest_path = backup_dir / "manifest.json"
                status = "Valid" if manifest_path.exists() else "No manifest"
                
                table.add_row(
                    backup_dir.name,
                    backup_type,
                    backup_dir.stat().st_mtime.strftime("%Y-%m-%d %H:%M"),
                    f"{size_mb:.1f} MB",
                    status
                )
    
    console.print(table)
    
    # Recommendations
    console.print("\n[bold]Recommendations:[/bold]")
    
    backups = list(backup_path.glob("*"))
    if len(backups) < 7:
        console.print("  [yellow]![/yellow] Consider more frequent backups")
    
    if backups:
        latest = max(backups, key=lambda x: x.stat().st_mtime)
        age_hours = (datetime.now() - datetime.fromtimestamp(
            latest.stat().st_mtime
        )).total_seconds() / 3600
        
        if age_hours > 24:
            console.print("  [red]![/red] Latest backup is over 24 hours old")
        else:
            console.print("  [green]✓[/green] Recent backup available")
```

---

## Real-World Examples

### Example 1: Pre-Scan Backup with Rollback

```python
def safe_scan_workflow(workspace, scan_function):
    """Wrap scan operations with backup and rollback capability."""
    engine = BackupEngine(workspace, workspace / "backups")
    
    # Create pre-scan checkpoint
    print("Creating pre-scan checkpoint...")
    checkpoint = engine.full_backup(label="pre_scan")
    
    try:
        # Execute scan
        print("Running scan...")
        results = scan_function()
        
        # Verify database integrity after scan
        db_path = workspace / "bounty.db"
        if db_path.exists():
            conn = sqlite3.connect(str(db_path))
            cursor = conn.cursor()
            cursor.execute("PRAGMA integrity_check")
            result = cursor.fetchone()
            conn.close()
            
            if result[0] != "ok":
                print(f"Database integrity failed: {result[0]}")
                print("Rolling back to pre-scan state...")
                restore_from_backup(checkpoint, workspace)
                return None
        
        return results
    
    except Exception as e:
        print(f"Scan failed: {e}")
        print("Rolling back to pre-scan state...")
        restore_from_backup(checkpoint, workspace)
        raise
```

### Example 2: Multi-Workspace Synchronization

```python
def sync_workspaces(primary_workspace, secondary_workspaces):
    """Sync backup data across multiple workspaces."""
    engine = BackupEngine(primary_workspace, primary_workspace / "backups")
    
    # Create backup from primary
    backup_path, manifest = engine.full_backup(label="sync")
    
    # Distribute to secondary workspaces
    for secondary in secondary_workspaces:
        secondary_path = Path(secondary)
        
        if secondary_path.exists():
            # Restore to secondary
            dest_backup_root = secondary_path / "backups"
            dest_backup_root.mkdir(exist_ok=True)
            
            shutil.copytree(
                backup_path,
                dest_backup_root / backup_path.name,
                dirs_exist_ok=True
            )
            
            print(f"Synced to: {secondary}")
    
    return {
        "primary": str(primary_workspace),
        "secondary": secondary_workspaces,
        "backup_label": backup_path.name
    }
```

### Example 3: Automated Backup with Verification

```python
def verified_backup_workflow(workspace, backup_root, verify_after=True):
    """Complete backup workflow with automatic verification."""
    engine = BackupEngine(workspace, backup_root)
    
    # Create backup
    backup_path, manifest = engine.full_backup(label="verified")
    
    if verify_after:
        print("Verifying backup integrity...")
        verifier = BackupVerifier(backup_path)
        
        # Verify manifest
        manifest_result = verifier.verify_manifest()
        if not manifest_result["valid"]:
            print(f"Verification failed: {manifest_result['issues']}")
            return {"status": "failed", "issues": manifest_result["issues"]}
        
        # Test restore
        import tempfile
        with tempfile.TemporaryDirectory() as temp_dir:
            restore_result = verifier.test_restore(temp_dir)
            if not restore_result["valid"]:
                print(f"Restore test failed: {restore_result['error']}")
                return {"status": "failed", "error": restore_result["error"]}
        
        print("Backup verification passed")
    
    return {"status": "success", "backup": str(backup_path)}
```

---

## Common Pitfalls

### Pitfall 1: Not Testing Backups
Creating backups without ever testing recovery is useless. Always verify restore capability periodically.

### Pitfall 2: Single Backup Location
Storing backups on the same machine as the source data means a hardware failure loses both. Use off-site storage.

### Pitfall 3: Ignoring Database WAL Files
SQLite WAL (Write-Ahead Logging) files contain uncommitted data. Always back up WAL files alongside the database.

### Pitfall 4: No Backup Rotation
Keeping all backups forever fills disk space. Implement retention policies with automated cleanup.

### Pitfall 5: Unencrypted Backups
Bug bounty data may contain sensitive information (API keys, credentials). Encrypt backups at rest.

### Pitfall 6: Missing Git-ignored Files
Tools often store configs in `.gitignore`d directories. Ensure backup covers these files.

### Pitfall 7: No Notification System
Silent backup failures go unnoticed. Implement alerts for failed or missing backups.

---

## Advanced Techniques

### Encrypted Backup System

```python
from cryptography.fernet import Fernet
import getpass

class EncryptedBackup:
    """Encrypted backup for sensitive bug bounty data."""
    
    def __init__(self, encryption_key=None):
        if encryption_key:
            self.key = encryption_key.encode()
        else:
            self.key = Fernet.generate_key()
        self.cipher = Fernet(self.key)
    
    def encrypt_file(self, input_path, output_path):
        """Encrypt a file."""
        with open(input_path, 'rb') as f:
            data = f.read()
        
        encrypted = self.cipher.encrypt(data)
        
        with open(output_path, 'wb') as f:
            f.write(encrypted)
        
        return output_path
    
    def decrypt_file(self, input_path, output_path):
        """Decrypt a file."""
        with open(input_path, 'rb') as f:
            encrypted = f.read()
        
        decrypted = self.cipher.decrypt(encrypted)
        
        with open(output_path, 'wb') as f:
            f.write(decrypted)
        
        return output_path
    
    def encrypted_backup(self, workspace, backup_root):
        """Create encrypted backup of workspace."""
        engine = BackupEngine(workspace, backup_root)
        backup_path, manifest = engine.full_backup(label="encrypted")
        
        # Encrypt database
        db_path = backup_path / "database" / "bounty.db"
        if db_path.exists():
            self.encrypt_file(db_path, db_path.with_suffix('.db.enc'))
            db_path.unlink()
        
        # Save encryption key securely
        key_path = backup_path / ".backup_key.enc"
        with open(key_path, 'wb') as f:
            f.write(self.key)
        
        return backup_path
```

### Cloud Backup Integration

```python
class CloudBackup:
    """Cloud backup integration for off-site storage."""
    
    def __init__(self, provider="s3"):
        self.provider = provider
    
    def upload_backup(self, local_path, remote_path):
        """Upload backup to cloud storage."""
        import subprocess
        
        if self.provider == "s3":
            cmd = f"aws s3 sync {local_path} s3://{remote_path}"
        elif self.provider == "gcs":
            cmd = f"gsutil -m rsync -r {local_path} gs://{remote_path}"
        elif self.provider == "azure":
            cmd = f"azcopy sync {local_path} https://{remote_path}"
        else:
            raise ValueError(f"Unknown provider: {self.provider}")
        
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        return {
            "success": result.returncode == 0,
            "output": result.stdout,
            "error": result.stderr
        }
    
    def download_backup(self, remote_path, local_path):
        """Download backup from cloud storage."""
        import subprocess
        
        if self.provider == "s3":
            cmd = f"aws s3 sync s3://{remote_path} {local_path}"
        elif self.provider == "gcs":
            cmd = f"gsutil -m rsync -r gs://{remote_path} {local_path}"
        
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        return {
            "success": result.returncode == 0,
            "output": result.stdout
        }
```

---

## Reporting Template

### Backup System Health Report

```markdown
## Backup System Health Report

**Report Date**: [Date]
**Workspace**: [Path]
**Backup Location**: [Path]

### Backup Inventory
| Backup | Type | Date | Size | Verified |
|--------|------|------|------|----------|
| [Name] | [Full/Incr] | [Date] | [Size] | [Yes/No] |

### Recovery Readiness
| Component | Status | Last Verified | RTO |
|-----------|--------|---------------|-----|
| Database | [OK/Fail] | [Date] | [Time] |
| Configs | [OK/Fail] | [Date] | [Time] |
| Evidence | [OK/Fail] | [Date] | [Time] |

### Storage Usage
- Total backup size: [Size]
- Available space: [Size]
- Retention policy: [Days]
- Estimated days until full: [Days]

### Recommendations
- [ ] [Action item 1]
- [ ] [Action item 2]
- [ ] [Action item 3]
```

---

## Quick Reference

### Backup Commands
```python
# Full backup
engine = BackupEngine("/workspace", "/backups")
engine.full_backup(label="manual")

# Incremental backup
inc = IncrementalBackup("/workspace", "/backups")
inc.incremental_backup()

# Verify backup
verifier = BackupVerifier("/backups/backup_name")
verifier.verify_manifest()

# Restore
dr = DisasterRecovery("/workspace", "/backups")
dr.execute_recovery("full_restore")
```

### Recovery Checklist
- [ ] Assess damage and determine recovery type
- [ ] Locate most recent valid backup
- [ ] Verify backup integrity before restore
- [ ] Create pre-restore checkpoint
- [ ] Execute restore procedure
- [ ] Verify restored data integrity
- [ ] Resume normal operations
- [ ] Document incident and recovery

### Retention Policy Template
| Backup Type | Retention | Storage |
|-------------|-----------|---------|
| Daily incremental | 14 days | Local |
| Weekly full | 90 days | Local + Cloud |
| Monthly archive | 1 year | Cloud |
| Pre-scan checkpoints | 7 days | Local |
| Evidence snapshots | Permanent | Cloud |
