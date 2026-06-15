# Automation-Efficiency 43: Custom API Development

## 1. Expert Role

You are an **Elite Security API Architect** specializing in designing and building custom RESTful and GraphQL APIs for bug bounty automation, vulnerability management, and security orchestration. Your expertise spans API design patterns, authentication systems, rate limiting, payload validation, OpenAPI documentation, and high-performance endpoint development. You build the control planes that drive automated security operations.

Core identity:
- **Primary Domain**: Security API design and development for bug bounty automation
- **Secondary Domain**: API gateway design, authentication/authorization, performance optimization
- **Mindset**: Every security operation is an API call. Design for automation first, humans second.
- **Ethics Boundary**: All APIs enforce scope validation. No endpoint allows unauthorized testing.

---

## 2. Core Concepts

### 2.1 API Design Philosophy for Security Tools

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| Scope-First | Every request validated against authorized scope | Middleware scope check |
| Idempotency | Safe retries on failure | Idempotency keys |
| Pagination | Handle large result sets | Cursor-based pagination |
| Filtering | Reduce response payload | Query parameter filters |
| Versioning | Backward compatibility | URL path versioning |
| Rate Limiting | Prevent abuse | Token bucket algorithm |
| Audit Logging | Track all operations | Request/response logging |

### 2.2 REST vs GraphQL for Security APIs

| Aspect | REST | GraphQL |
|--------|------|---------|
| Endpoint design | Multiple endpoints per resource | Single endpoint |
| Data fetching | Over/under-fetching common | Exact data requested |
| Caching | HTTP caching built-in | Requires custom caching |
| Real-time | WebSocket/SSE needed | Subscriptions built-in |
| File upload | Native support | Multipart spec required |
| Authentication | Header-based | Header-based |
| Documentation | OpenAPI/Swagger | Schema introspection |
| Rate limiting | Per-endpoint easy | Query complexity analysis |

**Recommendation**: Use REST for simple tool integrations, GraphQL for complex dashboards with varied data needs.

### 2.3 Authentication Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Client     │────▶│  API Gateway │────▶│  Auth Service│
└─────────────┘     └──────────────┘     └─────────────┘
                           │                     │
                           ▼                     ▼
                    ┌──────────────┐     ┌─────────────┐
                    │  Rate Limiter│     │  Token Store │
                    └──────────────┘     └─────────────┘
```

Authentication methods:
- **API Keys**: Simple, good for server-to-server
- **JWT Tokens**: Stateless, good for distributed systems
- **OAuth 2.0**: Delegated access, good for third-party integrations
- **mTLS**: Certificate-based, highest security

### 2.4 Rate Limiting Algorithms

| Algorithm | Memory | Accuracy | Burst Handling |
|-----------|--------|----------|----------------|
| Fixed Window | Low | Low | Poor |
| Sliding Window Log | High | High | Good |
| Sliding Window Counter | Medium | High | Good |
| Token Bucket | Low | High | Excellent |
| Leaky Bucket | Low | Medium | Poor |

### 2.5 API Response Standards

```json
{
  "status": "success",
  "data": {},
  "meta": {
    "request_id": "uuid",
    "timestamp": "ISO8601",
    "pagination": {
      "cursor": "string",
      "has_more": true,
      "total_count": 1000
    }
  },
  "errors": []
}
```

---

## 3. Prerequisites

### 3.1 Required Python Packages

```bash
# Web framework
pip install fastapi uvicorn[standard]

# Validation and serialization
pip install pydantic[email]

# Authentication
pip install python-jose[cryptography] passlib[bcrypt] python-multipart

# Database
pip install sqlalchemy aiosqlite databases

# Rate limiting
pip install slowapi redis

# Documentation
pip install swagger-ui-bundled

# Testing
pip install pytest pytest-asyncio httpx

# Monitoring
pip install prometheus-client structlog

# CORS
pip install cors

# WebSocket
pip install websockets
```

### 3.2 Project Structure

```
security-api/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── dependencies.py
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── rate_limiter.py
│   │   ├── scope_validator.py
│   │   └── audit_logger.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── schemas.py
│   │   ├── database.py
│   │   └── entities.py
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── targets.py
│   │   ├── scans.py
│   │   ├── findings.py
│   │   ├── tools.py
│   │   └── reports.py
│   ├── services/
│   │   ├── __init__.py
│   │   ├── target_service.py
│   │   ├── scan_service.py
│   │   ├── finding_service.py
│   │   └── tool_service.py
│   └── utils/
│       ├── __init__.py
│       ├── pagination.py
│       ├── validators.py
│       └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_targets.py
│   ├── test_scans.py
│   └── test_findings.py
├── alembic/
│   └── versions/
├── alembic.ini
├── requirements.txt
└── README.md
```

---

## 4. Methodology (Step-by-Step)

### Step 1: Define Data Models and Schemas

```python
# app/models/schemas.py
from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum
import uuid

class SeverityLevel(str, Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFO = "info"

class ScanStatus(str, Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

class TargetType(str, Enum):
    DOMAIN = "domain"
    IP = "ip"
    URL = "url"
    CIDR = "cidr"

# Base schemas
class TimestampMixin(BaseModel):
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class PaginationParams(BaseModel):
    cursor: Optional[str] = None
    limit: int = Field(default=50, ge=1, le=200)

class PaginatedResponse(BaseModel):
    data: List[Any]
    pagination: Dict[str, Any]
    meta: Dict[str, Any]

# Target schemas
class TargetCreate(BaseModel):
    value: str = Field(..., description="Target value (domain, IP, URL, or CIDR)")
    type: TargetType
    scope: List[str] = Field(default_factory=list, description="Associated scope identifiers")
    tags: List[str] = Field(default_factory=list)
    notes: Optional[str] = None

    @validator("value")
    def validate_target_value(cls, v, values):
        target_type = values.get("type")
        if target_type == TargetType.DOMAIN:
            if not v.replace(".", "").replace("-", "").isalnum():
                raise ValueError("Invalid domain format")
        elif target_type == TargetType.IP:
            parts = v.split(".")
            if len(parts) != 4 or not all(p.isdigit() and 0 <= int(p) <= 255 for p in parts):
                raise ValueError("Invalid IP format")
        return v

class TargetResponse(TimestampMixin):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    value: str
    type: TargetType
    scope: List[str]
    tags: List[str]
    notes: Optional[str]
    status: str = "active"

# Scan schemas
class ScanCreate(BaseModel):
    target_ids: List[str] = Field(..., min_length=1, max_length=10)
    scan_type: str = Field(..., description="recon, vuln, full")
    tools: List[str] = Field(default_factory=list, description="Specific tools to use")
    config: Dict[str, Any] = Field(default_factory=dict)
    priority: int = Field(default=5, ge=1, le=10)

class ScanResponse(TimestampMixin):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    target_ids: List[str]
    scan_type: str
    status: ScanStatus
    tools: List[str]
    config: Dict[str, Any]
    priority: int
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    progress: float = 0.0
    results_summary: Optional[Dict[str, Any]]

# Finding schemas
class FindingCreate(BaseModel):
    scan_id: str
    target_id: str
    title: str = Field(..., min_length=1, max_length=200)
    severity: SeverityLevel
    vuln_type: str
    endpoint: Optional[str]
    description: str
    evidence: Optional[Dict[str, Any]]
    remediation: Optional[str]
    references: List[str] = Field(default_factory=list)
    cvss_score: Optional[float] = Field(None, ge=0, le=10)

class FindingResponse(TimestampMixin):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    scan_id: str
    target_id: str
    title: str
    severity: SeverityLevel
    vuln_type: str
    endpoint: Optional[str]
    description: str
    evidence: Optional[Dict[str, Any]]
    remediation: Optional[str]
    references: List[str]
    cvss_score: Optional[float]
    status: str = "open"

# Tool schemas
class ToolConfig(BaseModel):
    name: str
    enabled: bool = True
    config: Dict[str, Any] = Field(default_factory=dict)
    rate_limit: int = Field(default=100, description="Requests per minute")

class ToolStatus(BaseModel):
    name: str
    version: str
    healthy: bool
    last_check: datetime
    avg_response_time: float
    success_rate: float
```

### Step 2: Build the Database Layer

```python
# app/models/database.py
from sqlalchemy import create_engine, Column, String, Integer, Float, DateTime, JSON, Boolean, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from datetime import datetime
import uuid

DATABASE_URL = "sqlite+aiosqlite:///./security_api.db"

engine = create_async_engine(DATABASE_URL, echo=True)
async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
Base = declarative_base()

def generate_uuid():
    return str(uuid.uuid4())

class Target(Base):
    __tablename__ = "targets"

    id = Column(String, primary_key=True, default=generate_uuid)
    value = Column(String, nullable=False, index=True)
    type = Column(String, nullable=False)
    scope = Column(JSON, default=list)
    tags = Column(JSON, default=list)
    notes = Column(Text)
    status = Column(String, default="active")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    scans = relationship("Scan", secondary="scan_targets")
    findings = relationship("Finding", back_populates="target")

class Scan(Base):
    __tablename__ = "scans"

    id = Column(String, primary_key=True, default=generate_uuid)
    scan_type = Column(String, nullable=False)
    status = Column(String, default="pending")
    tools = Column(JSON, default=list)
    config = Column(JSON, default=dict)
    priority = Column(Integer, default=5)
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    progress = Column(Float, default=0.0)
    results_summary = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    targets = relationship("Target", secondary="scan_targets")
    findings = relationship("Finding", back_populates="scan")

class ScanTarget(Base):
    __tablename__ = "scan_targets"

    scan_id = Column(String, ForeignKey("scans.id"), primary_key=True)
    target_id = Column(String, ForeignKey("targets.id"), primary_key=True)

class Finding(Base):
    __tablename__ = "findings"

    id = Column(String, primary_key=True, default=generate_uuid)
    scan_id = Column(String, ForeignKey("scans.id"), nullable=False)
    target_id = Column(String, ForeignKey("targets.id"), nullable=False)
    title = Column(String, nullable=False)
    severity = Column(String, nullable=False)
    vuln_type = Column(String, nullable=False)
    endpoint = Column(String)
    description = Column(Text, nullable=False)
    evidence = Column(JSON)
    remediation = Column(Text)
    references = Column(JSON, default=list)
    cvss_score = Column(Float)
    status = Column(String, default="open")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    scan = relationship("Scan", back_populates="findings")
    target = relationship("Target", back_populates="findings")

async def init_db():
    """Initialize database tables."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def get_db():
    """Dependency for getting async database sessions."""
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### Step 3: Build Authentication System

```python
# app/middleware/auth.py
from fastapi import Depends, HTTPException, status, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials, APIKeyHeader
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
from typing import Optional
import uuid
import hashlib

# Configuration
SECRET_KEY = "your-secret-key-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
API_KEY_HEADER = APIKeyHeader(name="X-API-Key", auto_error=False)
BEARER_HEADER = HTTPBearer(auto_error=False)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# In-memory stores (use database in production)
api_keys_db = {}
users_db = {}

class APIKeyManager:
    """Manage API keys for authentication."""

    @staticmethod
    def generate_api_key(prefix: str = "sk") -> str:
        """Generate a new API key."""
        key = f"{prefix}_{uuid.uuid4().hex}"
        return key

    @staticmethod
    def hash_api_key(key: str) -> str:
        """Hash API key for storage."""
        return hashlib.sha256(key.encode()).hexdigest()

    @staticmethod
    def store_api_key(key: str, user_id: str, scopes: list = None, expires_at: datetime = None):
        """Store API key with metadata."""
        key_hash = APIKeyManager.hash_api_key(key)
        api_keys_db[key_hash] = {
            "user_id": user_id,
            "scopes": scopes or ["read"],
            "created_at": datetime.utcnow(),
            "expires_at": expires_at,
            "active": True,
        }

    @staticmethod
    def validate_api_key(key: str) -> Optional[dict]:
        """Validate API key and return metadata."""
        key_hash = APIKeyManager.hash_api_key(key)
        key_data = api_keys_db.get(key_hash)

        if not key_data:
            return None

        if not key_data["active"]:
            return None

        if key_data["expires_at"] and key_data["expires_at"] < datetime.utcnow():
            return None

        return key_data

class TokenManager:
    """Manage JWT tokens for authentication."""

    @staticmethod
    def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
        """Create JWT access token."""
        to_encode = data.copy()
        expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        to_encode.update({"exp": expire, "iat": datetime.utcnow(), "jti": str(uuid.uuid4())})
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

    @staticmethod
    def verify_token(token: str) -> Optional[dict]:
        """Verify and decode JWT token."""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            return payload
        except JWTError:
            return None

# Authentication dependencies
async def get_current_user_api_key(
    api_key: Optional[str] = Depends(API_KEY_HEADER)
) -> dict:
    """Authenticate user via API key."""
    if not api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API key required",
            headers={"WWW-Authenticate": "ApiKey"},
        )

    key_data = APIKeyManager.validate_api_key(api_key)
    if not key_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired API key",
        )

    return key_data

async def get_current_user_token(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(BEARER_HEADER)
) -> dict:
    """Authenticate user via JWT token."""
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Bearer token required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token_data = TokenManager.verify_token(credentials.credentials)
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    return token_data

async def require_scope(required_scope: str, user: dict = Depends(get_current_user_api_key)):
    """Require specific scope for access."""
    user_scopes = user.get("scopes", [])
    if required_scope not in user_scopes and "admin" not in user_scopes:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Scope '{required_scope}' required",
        )
    return user

# Scope-based access control
def require_read(user: dict = Depends(get_current_user_api_key)):
    return require_scope("read", user)

def require_write(user: dict = Depends(get_current_user_api_key)):
    return require_scope("write", user)

def require_admin(user: dict = Depends(get_current_user_api_key)):
    return require_scope("admin", user)
```

### Step 4: Build Rate Limiter

```python
# app/middleware/rate_limiter.py
from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
import time
from typing import Dict, Tuple
from collections import defaultdict
import asyncio

class TokenBucketRateLimiter:
    """Token bucket rate limiter implementation."""

    def __init__(self, requests_per_minute: int = 60, burst_size: int = 10):
        self.rpm = requests_per_minute
        self.burst_size = burst_size
        self.buckets: Dict[str, Tuple[float, float]] = {}  # key -> (tokens, last_refill)
        self._lock = asyncio.Lock()

    async def _refill(self, key: str):
        """Refill tokens based on time elapsed."""
        now = time.time()
        if key in self.buckets:
            tokens, last_refill = self.buckets[key]
            elapsed = now - last_refill
            # Add tokens based on elapsed time
            new_tokens = min(self.burst_size, tokens + (elapsed * self.rpm / 60))
            self.buckets[key] = (new_tokens, now)
        else:
            self.buckets[key] = (self.burst_size, now)

    async def acquire(self, key: str) -> bool:
        """Try to acquire a token."""
        async with self._lock:
            await self._refill(key)

            tokens, _ = self.buckets[key]
            if tokens >= 1:
                self.buckets[key] = (tokens - 1, self.buckets[key][1])
                return True
            return False

    def get_remaining(self, key: str) -> int:
        """Get remaining tokens for a key."""
        if key in self.buckets:
            return int(self.buckets[key][0])
        return self.burst_size

class SlidingWindowRateLimiter:
    """Sliding window rate limiter for more accurate limiting."""

    def __init__(self, max_requests: int = 100, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests: Dict[str, list] = defaultdict(list)

    async def is_allowed(self, key: str) -> bool:
        """Check if request is allowed."""
        now = time.time()
        window_start = now - self.window_seconds

        # Remove old requests
        self.requests[key] = [t for t in self.requests[key] if t > window_start]

        if len(self.requests[key]) < self.max_requests:
            self.requests[key].append(now)
            return True
        return False

    def get_retry_after(self, key: str) -> float:
        """Get seconds until next request is allowed."""
        if not self.requests[key]:
            return 0
        oldest = min(self.requests[key])
        return max(0, self.window_seconds - (time.time() - oldest))

# Global rate limiters
rate_limiters = {
    "default": TokenBucketRateLimiter(requests_per_minute=60, burst_size=10),
    "scan": TokenBucketRateLimiter(requests_per_minute=10, burst_size=2),
    "export": TokenBucketRateLimiter(requests_per_minute=5, burst_size=1),
}

async def rate_limit_middleware(request: Request, call_next):
    """Rate limiting middleware."""
    # Get client identifier
    client_id = request.client.host
    if "X-API-Key" in request.headers:
        client_id = f"apikey:{request.headers['X-API-Key'][:8]}"

    # Get rate limiter for endpoint
    path = request.url.path
    if "/scans" in path and request.method == "POST":
        limiter = rate_limiters["scan"]
    elif "/export" in path:
        limiter = rate_limiters["export"]
    else:
        limiter = rate_limiters["default"]

    # Check rate limit
    if not await limiter.acquire(client_id):
        retry_after = limiter.get_remaining(client_id)
        return JSONResponse(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            content={
                "error": "rate_limit_exceeded",
                "message": "Too many requests",
                "retry_after": retry_after,
            },
            headers={"Retry-After": str(int(retry_after))},
        )

    # Add rate limit headers
    response = await call_next(request)
    response.headers["X-RateLimit-Limit"] = str(limiter.rpm)
    response.headers["X-RateLimit-Remaining"] = str(limiter.get_remaining(client_id))

    return response
```

### Step 5: Build API Routers

```python
# app/routers/targets.py
from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.models.schemas import TargetCreate, TargetResponse, PaginationParams
from app.models.database import get_db, Target
from app.middleware.auth import require_read, require_write
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
import uuid

router = APIRouter(prefix="/api/v1/targets", tags=["targets"])

@router.get("/", response_model=List[TargetResponse])
async def list_targets(
    type: Optional[str] = Query(None, description="Filter by target type"),
    status: Optional[str] = Query("active", description="Filter by status"),
    tag: Optional[str] = Query(None, description="Filter by tag"),
    cursor: Optional[str] = Query(None, description="Pagination cursor"),
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_read),
):
    """List all targets with optional filtering."""
    query = select(Target)

    if type:
        query = query.where(Target.type == type)
    if status:
        query = query.where(Target.status == status)
    if tag:
        query = query.where(Target.tags.contains([tag]))
    if cursor:
        query = query.where(Target.id > cursor)

    query = query.order_by(Target.created_at.desc()).limit(limit + 1)
    result = await db.execute(query)
    targets = result.scalars().all()

    has_more = len(targets) > limit
    if has_more:
        targets = targets[:limit]

    return [TargetResponse.from_orm(t) for t in targets]

@router.post("/", response_model=TargetResponse, status_code=status.HTTP_201_CREATED)
async def create_target(
    target: TargetCreate,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Create a new target."""
    # Check for duplicate
    existing = await db.execute(
        select(Target).where(Target.value == target.value, Target.type == target.type)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Target {target.value} already exists"
        )

    db_target = Target(
        id=str(uuid.uuid4()),
        value=target.value,
        type=target.type,
        scope=target.scope,
        tags=target.tags,
        notes=target.notes,
    )
    db.add(db_target)
    await db.commit()
    await db.refresh(db_target)

    return TargetResponse.from_orm(db_target)

@router.get("/{target_id}", response_model=TargetResponse)
async def get_target(
    target_id: str,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_read),
):
    """Get a specific target by ID."""
    result = await db.execute(select(Target).where(Target.id == target_id))
    target = result.scalar_one_or_none()

    if not target:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Target {target_id} not found"
        )

    return TargetResponse.from_orm(target)

@router.put("/{target_id}", response_model=TargetResponse)
async def update_target(
    target_id: str,
    target_update: TargetCreate,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Update an existing target."""
    result = await db.execute(select(Target).where(Target.id == target_id))
    db_target = result.scalar_one_or_none()

    if not db_target:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Target {target_id} not found"
        )

    db_target.value = target_update.value
    db_target.type = target_update.type
    db_target.scope = target_update.scope
    db_target.tags = target_update.tags
    db_target.notes = target_update.notes

    await db.commit()
    await db.refresh(db_target)

    return TargetResponse.from_orm(db_target)

@router.delete("/{target_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_target(
    target_id: str,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Soft delete a target."""
    result = await db.execute(select(Target).where(Target.id == target_id))
    target = result.scalar_one_or_none()

    if not target:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Target {target_id} not found"
        )

    target.status = "deleted"
    await db.commit()

    return None

@router.post("/bulk", response_model=dict, status_code=status.HTTP_201_CREATED)
async def bulk_create_targets(
    targets: List[TargetCreate],
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Bulk create targets."""
    created = []
    errors = []

    for i, target in enumerate(targets):
        try:
            existing = await db.execute(
                select(Target).where(Target.value == target.value, Target.type == target.type)
            )
            if existing.scalar_one_or_none():
                errors.append({"index": i, "error": "Duplicate target"})
                continue

            db_target = Target(
                id=str(uuid.uuid4()),
                value=target.value,
                type=target.type,
                scope=target.scope,
                tags=target.tags,
                notes=target.notes,
            )
            db.add(db_target)
            created.append(target.value)
        except Exception as e:
            errors.append({"index": i, "error": str(e)})

    await db.commit()

    return {
        "created": len(created),
        "errors": errors,
        "targets": created,
    }

# app/routers/scans.py
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from typing import List, Optional
from app.models.schemas import ScanCreate, ScanResponse, ScanStatus
from app.models.database import get_db, Scan, Target
from app.middleware.auth import require_read, require_write
from sqlalchemy.ext.asyncio import AsyncSession
import uuid
import asyncio

router = APIRouter(prefix="/api/v1/scans", tags=["scans"])

async def run_scan_background(scan_id: str, target_ids: List[str], config: dict):
    """Background task to run a scan."""
    # This would integrate with your tool framework
    # For now, simulate scan execution
    await asyncio.sleep(5)  # Simulate work
    print(f"Scan {scan_id} completed for targets {target_ids}")

@router.get("/", response_model=List[ScanResponse])
async def list_scans(
    status: Optional[str] = Query(None, description="Filter by status"),
    scan_type: Optional[str] = Query(None, description="Filter by scan type"),
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_read),
):
    """List all scans."""
    query = select(Scan)

    if status:
        query = query.where(Scan.status == status)
    if scan_type:
        query = query.where(Scan.scan_type == scan_type)

    query = query.order_by(Scan.created_at.desc()).limit(limit)
    result = await db.execute(query)
    scans = result.scalars().all()

    return [ScanResponse.from_orm(s) for s in scans]

@router.post("/", response_model=ScanResponse, status_code=status.HTTP_201_CREATED)
async def create_scan(
    scan: ScanCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Create and start a new scan."""
    # Validate targets exist
    for target_id in scan.target_ids:
        result = await db.execute(select(Target).where(Target.id == target_id))
        if not result.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Target {target_id} not found"
            )

    db_scan = Scan(
        id=str(uuid.uuid4()),
        scan_type=scan.scan_type,
        status=ScanStatus.PENDING,
        tools=scan.tools,
        config=scan.config,
        priority=scan.priority,
    )

    # Add target relationships
    for target_id in scan.target_ids:
        target = await db.execute(select(Target).where(Target.id == target_id))
        db_scan.targets.append(target.scalar_one_one())

    db.add(db_scan)
    await db.commit()
    await db.refresh(db_scan)

    # Start scan in background
    background_tasks.add_task(
        run_scan_background,
        db_scan.id,
        scan.target_ids,
        scan.config,
    )

    return ScanResponse.from_orm(db_scan)

@router.get("/{scan_id}", response_model=ScanResponse)
async def get_scan(
    scan_id: str,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_read),
):
    """Get a specific scan."""
    result = await db.execute(select(Scan).where(Scan.id == scan_id))
    scan = result.scalar_one_or_none()

    if not scan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Scan {scan_id} not found"
        )

    return ScanResponse.from_orm(scan)

@router.post("/{scan_id}/cancel", response_model=ScanResponse)
async def cancel_scan(
    scan_id: str,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Cancel a running scan."""
    result = await db.execute(select(Scan).where(Scan.id == scan_id))
    scan = result.scalar_one_or_none()

    if not scan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Scan {scan_id} not found"
        )

    if scan.status not in [ScanStatus.PENDING, ScanStatus.RUNNING]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot cancel scan in {scan.status} status"
        )

    scan.status = ScanStatus.CANCELLED
    await db.commit()
    await db.refresh(scan)

    return ScanResponse.from_orm(scan)

# app/routers/findings.py
from fastapi import APIRouter, Depends, HTTPException, status, Query
from typing import List, Optional
from app.models.schemas import FindingCreate, FindingResponse, SeverityLevel
from app.models.database import get_db, Finding
from app.middleware.auth import require_read, require_write
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

router = APIRouter(prefix="/api/v1/findings", tags=["findings"])

@router.get("/", response_model=List[FindingResponse])
async def list_findings(
    scan_id: Optional[str] = Query(None, description="Filter by scan ID"),
    target_id: Optional[str] = Query(None, description="Filter by target ID"),
    severity: Optional[SeverityLevel] = Query(None, description="Filter by severity"),
    status: Optional[str] = Query("open", description="Filter by status"),
    vuln_type: Optional[str] = Query(None, description="Filter by vulnerability type"),
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_read),
):
    """List all findings with filtering."""
    query = select(Finding)

    if scan_id:
        query = query.where(Finding.scan_id == scan_id)
    if target_id:
        query = query.where(Finding.target_id == target_id)
    if severity:
        query = query.where(Finding.severity == severity.value)
    if status:
        query = query.where(Finding.status == status)
    if vuln_type:
        query = query.where(Finding.vuln_type == vuln_type)

    query = query.order_by(
        # Order by severity (critical first)
        Finding.severity.desc()
    ).limit(limit)

    result = await db.execute(query)
    findings = result.scalars().all()

    return [FindingResponse.from_orm(f) for f in findings]

@router.post("/", response_model=FindingResponse, status_code=status.HTTP_201_CREATED)
async def create_finding(
    finding: FindingCreate,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Create a new finding."""
    db_finding = Finding(
        id=str(uuid.uuid4()),
        scan_id=finding.scan_id,
        target_id=finding.target_id,
        title=finding.title,
        severity=finding.severity.value,
        vuln_type=finding.vuln_type,
        endpoint=finding.endpoint,
        description=finding.description,
        evidence=finding.evidence,
        remediation=finding.remediation,
        references=finding.references,
        cvss_score=finding.cvss_score,
    )
    db.add(db_finding)
    await db.commit()
    await db.refresh(db_finding)

    return FindingResponse.from_orm(db_finding)

@router.get("/{finding_id}", response_model=FindingResponse)
async def get_finding(
    finding_id: str,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_read),
):
    """Get a specific finding."""
    result = await db.execute(select(Finding).where(Finding.id == finding_id))
    finding = result.scalar_one_or_none()

    if not finding:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Finding {finding_id} not found"
        )

    return FindingResponse.from_orm(finding)

@router.patch("/{finding_id}", response_model=FindingResponse)
async def update_finding_status(
    finding_id: str,
    new_status: str,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_write),
):
    """Update finding status."""
    result = await db.execute(select(Finding).where(Finding.id == finding_id))
    finding = result.scalar_one_or_none()

    if not finding:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Finding {finding_id} not found"
        )

    valid_statuses = ["open", "confirmed", "fixed", "false_positive", "deferred"]
    if new_status not in valid_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid status. Must be one of: {valid_statuses}"
        )

    finding.status = new_status
    await db.commit()
    await db.refresh(finding)

    return FindingResponse.from_orm(finding)

@router.get("/stats/summary")
async def get_finding_stats(
    scan_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(require_read),
):
    """Get finding statistics summary."""
    query = select(Finding)
    if scan_id:
        query = query.where(Finding.scan_id == scan_id)

    result = await db.execute(query)
    findings = result.scalars().all()

    stats = {
        "total": len(findings),
        "by_severity": {},
        "by_status": {},
        "by_type": {},
    }

    for finding in findings:
        # By severity
        stats["by_severity"][finding.severity] = stats["by_severity"].get(finding.severity, 0) + 1
        # By status
        stats["by_status"][finding.status] = stats["by_status"].get(finding.status, 0) + 1
        # By type
        stats["by_type"][finding.vuln_type] = stats["by_type"].get(finding.vuln_type, 0) + 1

    return stats
```

### Step 6: Build the Main Application

```python
# app/main.py
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import time
import logging

from app.models.database import init_db
from app.routers import targets, scans, findings
from app.middleware.rate_limiter import rate_limit_middleware

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    logger.info("Starting Security API...")
    await init_db()
    logger.info("Database initialized")
    yield
    # Shutdown
    logger.info("Shutting down Security API...")

app = FastAPI(
    title="Security Automation API",
    description="Custom API for bug bounty automation and vulnerability management",
    version="1.0.0",
    lifespan=lifespan,
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add rate limiting middleware
app.middleware("http")(rate_limit_middleware)

# Add request timing middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response

# Include routers
app.include_router(targets.router)
app.include_router(scans.router)
app.include_router(findings.router)

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "version": "1.0.0"}

# Root endpoint
@app.get("/")
async def root():
    """API root with documentation links."""
    return {
        "name": "Security Automation API",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
        "openapi": "/openapi.json",
    }

# Error handlers
@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    return JSONResponse(
        status_code=404,
        content={"error": "not_found", "message": "Resource not found"},
    )

@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    logger.error(f"Internal error: {exc}")
    return JSONResponse(
        status_code=500,
        content={"error": "internal_error", "message": "Internal server error"},
    )

# Run the application
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
```

---

## 5. Tool Arsenal with Commands

### 5.1 API Testing Script

```python
# tests/test_api.py
import httpx
import json
import asyncio
from typing import Dict

class APITester:
    """Automated API testing client."""

    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url.rstrip("/")
        self.headers = {"X-API-Key": api_key}

    async def test_targets_crud(self):
        """Test full CRUD operations for targets."""
        results = []

        # Create target
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/api/v1/targets/",
                json={
                    "value": "test-target.example.com",
                    "type": "domain",
                    "scope": ["test-scope"],
                    "tags": ["test"],
                },
                headers=self.headers,
            )
            results.append({"operation": "create", "status": response.status_code})
            target_id = response.json().get("id")

            # Read target
            response = await client.get(
                f"{self.base_url}/api/v1/targets/{target_id}",
                headers=self.headers,
            )
            results.append({"operation": "read", "status": response.status_code})

            # Update target
            response = await client.put(
                f"{self.base_url}/api/v1/targets/{target_id}",
                json={
                    "value": "updated-target.example.com",
                    "type": "domain",
                    "scope": ["test-scope"],
                    "tags": ["test", "updated"],
                },
                headers=self.headers,
            )
            results.append({"operation": "update", "status": response.status_code})

            # List targets
            response = await client.get(
                f"{self.base_url}/api/v1/targets/",
                headers=self.headers,
            )
            results.append({"operation": "list", "status": response.status_code})

            # Delete target
            response = await client.delete(
                f"{self.base_url}/api/v1/targets/{target_id}",
                headers=self.headers,
            )
            results.append({"operation": "delete", "status": response.status_code})

        return results

    async def test_rate_limiting(self):
        """Test rate limiting behavior."""
        results = []

        async with httpx.AsyncClient() as client:
            # Send many requests quickly
            for i in range(70):  # Exceed 60 rpm limit
                response = await client.get(
                    f"{self.base_url}/api/v1/targets/",
                    headers=self.headers,
                )
                results.append({
                    "request": i + 1,
                    "status": response.status_code,
                    "rate_limit_remaining": response.headers.get("X-RateLimit-Remaining"),
                })

                if response.status_code == 429:
                    break

        return results

    async def test_authentication(self):
        """Test authentication methods."""
        results = []

        async with httpx.AsyncClient() as client:
            # Test without API key
            response = await client.get(f"{self.base_url}/api/v1/targets/")
            results.append({"test": "no_auth", "status": response.status_code})

            # Test with invalid API key
            response = await client.get(
                f"{self.base_url}/api/v1/targets/",
                headers={"X-API-Key": "invalid_key"},
            )
            results.append({"test": "invalid_key", "status": response.status_code})

            # Test with valid API key
            response = await client.get(
                f"{self.base_url}/api/v1/targets/",
                headers=self.headers,
            )
            results.append({"test": "valid_key", "status": response.status_code})

        return results

# Run tests
async def main():
    tester = APITester("http://localhost:8000", "test_api_key")

    print("Testing CRUD operations...")
    crud_results = await tester.test_targets_crud()
    print(f"CRUD results: {json.dumps(crud_results, indent=2)}")

    print("\nTesting rate limiting...")
    rate_results = await tester.test_rate_limiting()
    print(f"Rate limit results: {len(rate_results)} requests sent")

    print("\nTesting authentication...")
    auth_results = await tester.test_authentication()
    print(f"Auth results: {json.dumps(auth_results, indent=2)}")

if __name__ == "__main__":
    asyncio.run(main())
```

### 5.2 API Documentation Generator

```python
# docs_generator.py
import json
from typing import Dict, List
from pathlib import Path

class APIDocGenerator:
    """Generate API documentation from OpenAPI spec."""

    def __init__(self, openapi_path: str = "openapi.json"):
        self.openapi_path = openapi_path

    def generate_markdown_docs(self, output_path: str = "API_DOCS.md"):
        """Generate markdown documentation from OpenAPI spec."""
        with open(self.openapi_path) as f:
            spec = json.load(f)

        docs = f"""# {spec.get('info', {}).get('title', 'API')} Documentation

Version: {spec.get('info', {}).get('version', '1.0')}

{spec.get('info', {}).get('description', '')}

## Authentication

This API supports two authentication methods:

1. **API Key**: Include `X-API-Key` header with your API key
2. **Bearer Token**: Include `Authorization: Bearer <token>` header

## Rate Limiting

- Default: 60 requests per minute
- Scan endpoints: 10 requests per minute
- Export endpoints: 5 requests per minute

Rate limit headers are included in all responses:
- `X-RateLimit-Limit`: Maximum requests per window
- `X-RateLimit-Remaining`: Remaining requests in window
- `Retry-After`: Seconds until next request is allowed (on 429)

## Endpoints

"""
        # Group endpoints by tag
        endpoints_by_tag = {}
        for path, methods in spec.get("paths", {}).items():
            for method, details in methods.items():
                if method in ["get", "post", "put", "patch", "delete"]:
                    tags = details.get("tags", ["Other"])
                    for tag in tags:
                        if tag not in endpoints_by_tag:
                            endpoints_by_tag[tag] = []
                        endpoints_by_tag[tag].append({
                            "path": path,
                            "method": method.upper(),
                            "summary": details.get("summary", ""),
                            "description": details.get("description", ""),
                        })

        # Generate docs for each tag
        for tag, endpoints in endpoints_by_tag.items():
            docs += f"### {tag}\n\n"

            for endpoint in endpoints:
                docs += f"#### `{endpoint['method']}` {endpoint['path']}\n\n"
                docs += f"{endpoint['summary']}\n\n"
                if endpoint['description']:
                    docs += f"{endpoint['description']}\n\n"

            docs += "\n"

        # Write docs
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w") as f:
            f.write(docs)

        return output_path

    def generate_sdk_example(self, output_path: str = "sdk_example.py"):
        """Generate SDK usage examples."""
        with open(self.openapi_path) as f:
            spec = json.load(f)

        sdk_code = '''"""
SDK Example for Security Automation API
Auto-generated from OpenAPI specification
"""

import httpx
from typing import Dict, List, Optional, Any

class SecurityAPIClient:
    """Client for Security Automation API."""

    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url.rstrip("/")
        self.headers = {"X-API-Key": api_key}

    async def _request(self, method: str, path: str, **kwargs) -> Dict:
        """Make API request."""
        async with httpx.AsyncClient() as client:
            response = await client.request(
                method,
                f"{self.base_url}{path}",
                headers=self.headers,
                **kwargs,
            )
            response.raise_for_status()
            return response.json()

    # Target operations
    async def list_targets(self, type: str = None, status: str = "active") -> List[Dict]:
        """List all targets."""
        params = {"type": type, "status": status}
        return await self._request("GET", "/api/v1/targets/", params=params)

    async def create_target(self, value: str, type: str, scope: List[str] = None) -> Dict:
        """Create a new target."""
        return await self._request("POST", "/api/v1/targets/", json={
            "value": value,
            "type": type,
            "scope": scope or [],
        })

    async def get_target(self, target_id: str) -> Dict:
        """Get a specific target."""
        return await self._request("GET", f"/api/v1/targets/{target_id}")

    # Scan operations
    async def create_scan(self, target_ids: List[str], scan_type: str) -> Dict:
        """Create and start a new scan."""
        return await self._request("POST", "/api/v1/scans/", json={
            "target_ids": target_ids,
            "scan_type": scan_type,
        })

    async def list_scans(self, status: str = None) -> List[Dict]:
        """List all scans."""
        params = {"status": status}
        return await self._request("GET", "/api/v1/scans/", params=params)

    async def get_scan(self, scan_id: str) -> Dict:
        """Get a specific scan."""
        return await self._request("GET", f"/api/v1/scans/{scan_id}")

    # Finding operations
    async def list_findings(self, severity: str = None, status: str = "open") -> List[Dict]:
        """List all findings."""
        params = {"severity": severity, "status": status}
        return await self._request("GET", "/api/v1/findings/", params=params)

    async def create_finding(self, finding_data: Dict) -> Dict:
        """Create a new finding."""
        return await self._request("POST", "/api/v1/findings/", json=finding_data)

# Usage example
async def main():
    client = SecurityAPIClient(
        base_url="http://localhost:8000",
        api_key="your-api-key"
    )

    # Create a target
    target = await client.create_target(
        value="test-target.example.com",
        type="domain",
        scope=["test-scope"]
    )
    print(f"Created target: {target['id']}")

    # Start a scan
    scan = await client.create_scan(
        target_ids=[target['id']],
        scan_type="full"
    )
    print(f"Started scan: {scan['id']}")

    # List findings
    findings = await client.list_findings(severity="high")
    print(f"Found {len(findings)} high severity findings")

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
'''
        with open(output_path, "w") as f:
            f.write(sdk_code)

        return output_path
```

---

## 6. Real-World Examples

### 6.1 Complete Bug Bounty Management API

```python
# complete_api_example.py
from fastapi import FastAPI, Depends, HTTPException, status, Query, BackgroundTasks
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid
import asyncio
import json

app = FastAPI(title="Bug Bounty Management API")

# In-memory database (use real database in production)
targets_db = {}
scans_db = {}
findings_db = {}

# Models
class Program(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    platform: str  # hackerone, bugcrowd, etc.
    scope: List[str]
    max_bounty: Optional[float]
    status: str = "active"
    created_at: datetime = Field(default_factory=datetime.utcnow)

class ScopeEntry(BaseModel):
    asset: str
    asset_type: str  # domain, url, wildcard
    in_scope: bool = True

# Program management
@app.post("/api/v1/programs/", response_model=Program)
async def create_program(program: Program):
    """Create a new bug bounty program."""
    targets_db[program.id] = program
    return program

@app.get("/api/v1/programs/")
async def list_programs(status: str = "active"):
    """List all programs."""
    return [p for p in targets_db.values() if p.status == status]

# Automated scope validation
@app.post("/api/v1/validate-scope")
async def validate_scope(url: str, program_id: str):
    """Validate if a URL is within program scope."""
    program = targets_db.get(program_id)
    if not program:
        raise HTTPException(status_code=404, detail="Program not found")

    # Check if URL matches any scope entry
    from urllib.parse import urlparse
    parsed = urlparse(url)
    domain = parsed.hostname

    in_scope = False
    for scope_entry in program.scope:
        if scope_entry.startswith("*."):
            # Wildcard match
            wildcard_domain = scope_entry[2:]
            if domain.endswith(wildcard_domain) or domain == wildcard_domain:
                in_scope = True
                break
        elif domain == scope_entry or url.startswith(scope_entry):
            in_scope = True
            break

    return {
        "url": url,
        "program": program.name,
        "in_scope": in_scope,
        "validated_at": datetime.utcnow().isoformat(),
    }

# Scan orchestration
@app.post("/api/v1/auto-scan")
async def auto_scan(program_id: str, background_tasks: BackgroundTasks):
    """Automatically scan all in-scope assets."""
    program = targets_db.get(program_id)
    if not program:
        raise HTTPException(status_code=404, detail="Program not found")

    scan_id = str(uuid.uuid4())

    async def run_auto_scan():
        """Background scan task."""
        scans_db[scan_id] = {
            "status": "running",
            "program": program.name,
            "targets": len(program.scope),
            "started_at": datetime.utcnow().isoformat(),
        }

        # Simulate scanning
        await asyncio.sleep(10)

        scans_db[scan_id]["status"] = "completed"
        scans_db[scan_id]["completed_at"] = datetime.utcnow().isoformat()

    background_tasks.add_task(run_auto_scan)

    return {
        "scan_id": scan_id,
        "program": program.name,
        "status": "started",
    }

# Finding management with deduplication
@app.post("/api/v1/findings/deduplicated")
async def create_deduplicated_finding(finding: FindingCreate):
    """Create a finding with automatic deduplication."""
    # Check for duplicates
    for existing_id, existing_finding in findings_db.items():
        if (existing_finding.endpoint == finding.endpoint and
            existing_finding.vuln_type == finding.vuln_type):
            # Duplicate found
            return {
                "status": "duplicate",
                "existing_finding_id": existing_id,
                "message": "Similar finding already exists",
            }

    # Create new finding
    db_finding = FindingResponse(**finding.dict())
    findings_db[db_finding.id] = db_finding

    return {
        "status": "created",
        "finding_id": db_finding.id,
    }

# Report generation
@app.get("/api/v1/reports/{program_id}")
async def generate_report(program_id: str):
    """Generate a report for a program."""
    program = targets_db.get(program_id)
    if not program:
        raise HTTPException(status_code=404, detail="Program not found")

    # Get all findings for this program's scope
    program_findings = []
    for finding in findings_db.values():
        # Check if finding endpoint is in scope
        for scope in program.scope:
            if finding.endpoint and scope in finding.endpoint:
                program_findings.append(finding)
                break

    report = {
        "program": program.name,
        "generated_at": datetime.utcnow().isoformat(),
        "total_findings": len(program_findings),
        "by_severity": {},
        "findings": program_findings,
    }

    for finding in program_findings:
        severity = finding.severity
        report["by_severity"][severity] = report["by_severity"].get(severity, 0) + 1

    return report

# Webhook support for tool integration
@app.post("/api/v1/webhooks/tool-results")
async def receive_tool_results(results: Dict[str, Any]):
    """Receive results from external tools."""
    tool = results.get("tool")
    data = results.get("data")

    # Process based on tool type
    if tool == "nuclei":
        # Convert nuclei output to findings
        for vuln in data:
            finding = FindingCreate(
                scan_id=results.get("scan_id", "external"),
                target_id=results.get("target_id", "unknown"),
                title=vuln.get("info", {}).get("name", "Unknown vulnerability"),
                severity=vuln.get("info", {}).get("severity", "medium"),
                vuln_type=vuln.get("info", {}).get("classification", {}).get("cwe-id", ["unknown"])[0],
                endpoint=vuln.get("matched-at"),
                description=vuln.get("info", {}).get("description", ""),
                evidence={"template": vuln.get("template-id"), "matcher": vuln.get("matcher-name")},
            )
            # Store finding
            finding_id = str(uuid.uuid4())
            findings_db[finding_id] = FindingResponse(**finding.dict())

    return {"status": "processed", "tool": tool}
```

### 6.2 GraphQL API Example

```python
# graphql_api.py
import strawberry
from typing import List, Optional
from datetime import datetime
import uuid

@strawberry.type
class Target:
    id: str
    value: str
    type: str
    scope: List[str]
    tags: List[str]
    created_at: datetime

@strawberry.type
class Scan:
    id: str
    target_ids: List[str]
    scan_type: str
    status: str
    created_at: datetime
    completed_at: Optional[datetime]

@strawberry.type
class Finding:
    id: str
    scan_id: str
    target_id: str
    title: str
    severity: str
    vuln_type: str
    endpoint: Optional[str]
    created_at: datetime

@strawberry.type
class Query:
    @strawberry.field
    def targets(self, type: Optional[str] = None, status: str = "active") -> List[Target]:
        """List all targets with optional filtering."""
        targets = list(targets_db.values())
        if type:
            targets = [t for t in targets if t.type == type]
        return targets

    @strawberry.field
    def target(self, id: str) -> Optional[Target]:
        """Get a specific target."""
        return targets_db.get(id)

    @strawberry.field
    def scans(self, status: Optional[str] = None) -> List[Scan]:
        """List all scans."""
        scans = list(scans_db.values())
        if status:
            scans = [s for s in scans if s.status == status]
        return scans

    @strawberry.field
    def findings(
        self,
        severity: Optional[str] = None,
        vuln_type: Optional[str] = None,
        status: str = "open"
    ) -> List[Finding]:
        """List all findings with filtering."""
        findings = list(findings_db.values())
        if severity:
            findings = [f for f in findings if f.severity == severity]
        if vuln_type:
            findings = [f for f in findings if f.vuln_type == vuln_type]
        return findings

    @strawberry.field
    def finding_stats(self) -> dict:
        """Get finding statistics."""
        findings = list(findings_db.values())
        return {
            "total": len(findings),
            "by_severity": {},
            "by_type": {},
        }

@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_target(self, value: str, type: str, scope: List[str] = []) -> Target:
        """Create a new target."""
        target = Target(
            id=str(uuid.uuid4()),
            value=value,
            type=type,
            scope=scope,
            tags=[],
            created_at=datetime.utcnow(),
        )
        targets_db[target.id] = target
        return target

    @strawberry.mutation
    def create_scan(self, target_ids: List[str], scan_type: str) -> Scan:
        """Create a new scan."""
        scan = Scan(
            id=str(uuid.uuid4()),
            target_ids=target_ids,
            scan_type=scan_type,
            status="pending",
            created_at=datetime.utcnow(),
        )
        scans_db[scan.id] = scan
        return scan

    @strawberry.mutation
    def update_finding_status(self, id: str, status: str) -> Finding:
        """Update finding status."""
        finding = findings_db.get(id)
        if not finding:
            raise ValueError(f"Finding {id} not found")
        # Update status (in real app, would persist)
        return finding

schema = strawberry.Schema(query=Query, mutation=Mutation)

# FastAPI integration
from strawberry.fastapi import GraphQLRouter
from fastapi import FastAPI

app = FastAPI()
graphql_app = GraphQLRouter(schema)
app.include_router(graphql_app, prefix="/graphql")
```

---

## 7. Common Pitfalls

### 7.1 N+1 Query Problem

```python
# N+1 query solution
from sqlalchemy.orm import selectinload, joinedload

# BAD: N+1 queries
async def get_scans_with_targets_bad():
    scans = await db.execute(select(Scan))
    for scan in scans.scalars():
        # This triggers a new query for each scan!
        targets = await db.execute(
            select(Target).join(ScanTarget).where(ScanTarget.scan_id == scan.id)
        )

# GOOD: Eager loading
async def get_scans_with_targets_good():
    result = await db.execute(
        select(Scan).options(selectinload(Scan.targets))
    )
    return result.scalars().all()
```

### 7.2 Race Conditions in Rate Limiting

```python
# Thread-safe rate limiter
import asyncio
from collections import defaultdict

class ThreadSafeRateLimiter:
    def __init__(self, max_requests: int, window_seconds: int):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests: Dict[str, list] = defaultdict(list)
        self._lock = asyncio.Lock()

    async def is_allowed(self, key: str) -> bool:
        async with self._lock:
            now = time.time()
            window_start = now - self.window_seconds

            # Clean old requests
            self.requests[key] = [t for t in self.requests[key] if t > window_start]

            if len(self.requests[key]) < self.max_requests:
                self.requests[key].append(now)
                return True
            return False
```

### 7.3 Large Response Payloads

```python
# Streaming response for large datasets
from fastapi import Response
from fastapi.responses import StreamingResponse
import json

@app.get("/api/v1/findings/export")
async def export_findings(format: str = "json"):
    """Stream findings export for large datasets."""
    async def generate():
        yield "["
        first = True
        async for finding in stream_findings():
            if not first:
                yield ","
            yield json.dumps(finding)
            first = False
        yield "]"

    return StreamingResponse(
        generate(),
        media_type="application/json",
        headers={"Content-Disposition": "attachment; filename=findings.json"},
    )
```

---

## 8. Advanced Techniques

### 8.1 API Versioning Strategy

```python
# Versioned API structure
from fastapi import APIRouter

# Version 1 router
v1_router = APIRouter(prefix="/api/v1")

@v1_router.get("/targets/")
async def list_targets_v1():
    """V1 target listing."""
    return {"version": "1", "data": []}

# Version 2 router with new features
v2_router = APIRouter(prefix="/api/v2")

@v2_router.get("/targets/")
async def list_targets_v2(cursor: str = None, limit: int = 50):
    """V2 target listing with cursor pagination."""
    return {"version": "2", "data": [], "pagination": {"cursor": cursor}}

# Include both versions
app.include_router(v1_router)
app.include_router(v2_router)
```

### 8.2 Webhook System

```python
# Webhook management
import hashlib
import hmac
from typing import List

class WebhookManager:
    """Manage webhooks for event notifications."""

    def __init__(self):
        self.webhooks: Dict[str, Dict] = {}

    def register(self, url: str, events: List[str], secret: str) -> str:
        """Register a new webhook."""
        webhook_id = str(uuid.uuid4())
        self.webhooks[webhook_id] = {
            "url": url,
            "events": events,
            "secret": secret,
            "active": True,
            "created_at": datetime.utcnow(),
        }
        return webhook_id

    def sign_payload(self, payload: bytes, secret: str) -> str:
        """Sign payload with HMAC-SHA256."""
        return hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()

    async def send(self, event: str, data: dict):
        """Send webhook for event."""
        import httpx

        for webhook_id, webhook in self.webhooks.items():
            if not webhook["active"]:
                continue

            if event not in webhook["events"]:
                continue

            payload = json.dumps(data).encode()
            signature = self.sign_payload(payload, webhook["secret"])

            async with httpx.AsyncClient() as client:
                try:
                    await client.post(
                        webhook["url"],
                        content=payload,
                        headers={
                            "Content-Type": "application/json",
                            "X-Webhook-Signature": signature,
                            "X-Webhook-Event": event,
                        },
                        timeout=10,
                    )
                except Exception as e:
                    print(f"Webhook delivery failed: {e}")

# Usage
webhook_manager = WebhookManager()

# Register webhook
webhook_id = webhook_manager.register(
    url="https://example.com/webhook",
    events=["finding.created", "scan.completed"],
    secret="webhook-secret-key",
)

# Send webhook on event
await webhook_manager.send("finding.created", {
    "finding_id": "abc123",
    "severity": "high",
    "endpoint": "http://example.com/vuln",
})
```

### 8.3 API Caching Strategy

```python
# Response caching
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_cache.decorator import cache
import redis

# Setup cache
redis_client = redis.from_url("redis://localhost:6379")
FastAPICache.init(RedisBackend(redis_client), prefix="api-cache")

# Cache endpoints
@app.get("/api/v1/targets/")
@cache(expire=300)  # Cache for 5 minutes
async def list_targets_cached():
    """List targets with caching."""
    # This response will be cached
    return {"data": []}

# Cache with key builder for different parameters
from fastapi_cache.key import builder

@app.get("/api/v1/findings/")
@cache(expire=60, key_builder=builder.query_key_builder)
async def list_findings_cached(severity: str = None):
    """List findings with parameter-based caching."""
    return {"data": []}
```

---

## 9. Reporting Template

### 9.1 API Performance Report

```markdown
# API Performance Report

## Overview
- **Total Requests**: {total_requests}
- **Average Response Time**: {avg_response_time}ms
- **Error Rate**: {error_rate}%
- **Uptime**: {uptime}%

## Endpoint Performance

| Endpoint | Method | Avg Response | P95 Response | Requests | Errors |
|----------|--------|--------------|--------------|----------|--------|
| /api/v1/targets/ | GET | 45ms | 120ms | 1,234 | 2 |
| /api/v1/scans/ | POST | 250ms | 500ms | 456 | 5 |
| /api/v1/findings/ | GET | 85ms | 200ms | 2,345 | 0 |

## Rate Limiting

- **Total Rate Limited**: 23 requests
- **Most Limited Endpoint**: /api/v1/scans/ (15 rate limits)
- **Average Wait Time**: 2.3 seconds

## Authentication

- **API Key Auth**: 95% of requests
- **JWT Auth**: 5% of requests
- **Failed Auth Attempts**: 12

## Database Performance

- **Total Queries**: 12,345
- **Average Query Time**: 12ms
- **Slow Queries (>100ms)**: 3
- **Connection Pool Usage**: 45%

## Recommendations

1. **Add caching** for GET /api/v1/targets/ (high traffic, low mutation)
2. **Optimize N+1 queries** in scan listing endpoint
3. **Increase rate limit** for authenticated users
4. **Add pagination** for large result sets
5. **Implement request compression** for large payloads
```

### 9.2 Security Audit Report

```markdown
# API Security Audit Report

## Authentication & Authorization
- **API Key Rotation**: Not enforced (recommend 90-day rotation)
- **Token Expiry**: 30 minutes (appropriate)
- **Scope Enforcement**: Implemented ✓
- **Rate Limiting**: Implemented ✓

## Input Validation
- **SQL Injection Protection**: Parameterized queries ✓
- **XSS Protection**: Output encoding ✓
- **Request Size Limits**: 10MB default ✓
- **Content-Type Validation**: Implemented ✓

## Transport Security
- **HTTPS**: Required in production ✓
- **HSTS**: Recommended ✓
- **CORS**: Configured ✓

## Audit Logging
- **Request Logging**: Implemented ✓
- **Authentication Events**: Logged ✓
- **Data Access**: Logged ✓
- **Error Logging**: Implemented ✓

## Recommendations

1. Implement API key rotation policy
2. Add request signing for sensitive operations
3. Implement IP allowlisting for admin endpoints
4. Add anomaly detection for unusual patterns
5. Implement data masking for sensitive fields in logs
```

---

## 10. Quick Reference

### 10.1 Essential Imports

```python
# FastAPI core
from fastapi import FastAPI, Depends, HTTPException, status, Query, Path, Body
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse
from pydantic import BaseModel, Field, validator
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid

# Authentication
from fastapi.security import HTTPBearer, APIKeyHeader
from jose import jwt

# Database
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

# Caching
from fastapi_cache import FastAPICache
from fastapi_cache.decorator import cache

# Rate limiting
from slowapi import Limiter
from slowapi.util import get_remote_address
```

### 10.2 Response Format Cheat Sheet

```python
# Success response
{
    "status": "success",
    "data": {...},
    "meta": {
        "request_id": "uuid",
        "timestamp": "ISO8601"
    }
}

# Error response
{
    "status": "error",
    "error": {
        "code": "validation_error",
        "message": "Invalid input",
        "details": [...]
    }
}

# Paginated response
{
    "status": "success",
    "data": [...],
    "pagination": {
        "cursor": "next_cursor",
        "has_more": true,
        "total_count": 1000
    }
}
```

### 10.3 HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource |
| 422 | Unprocessable Entity | Validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

### 10.4 Testing Commands

```bash
# Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Run tests
pytest tests/ -v

# Generate OpenAPI spec
python -c "import json; from app.main import app; print(json.dumps(app.openapi(), indent=2))"

# Load test
locust -f locustfile.py --host=http://localhost:8000
```

### 10.5 Troubleshooting Guide

| Problem | Cause | Solution |
|---------|-------|----------|
| 422 Validation Error | Request body mismatch | Check Pydantic model |
| 401 Unauthorized | Missing/invalid API key | Verify API key in header |
| 429 Rate Limited | Too many requests | Implement backoff |
| 500 Server Error | Unhandled exception | Check server logs |
| Slow responses | N+1 queries | Use eager loading |
| Memory leak | Large result sets | Implement pagination |
| CORS error | Missing headers | Configure CORS middleware |
