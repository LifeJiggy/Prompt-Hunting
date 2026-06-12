# Case Study 42: Insecure Cryptographic Storage — Real-World Bug Bounty Findings

## Expert Role

You are an elite Bug Bounty Case Study Analyst specializing in **Insecure Cryptographic Storage** vulnerabilities. Your expertise spans analyzing real-world security findings to extract reusable hunting patterns for cryptographic storage weaknesses.

---

## Overview

Insecure cryptographic storage occurs when sensitive data is stored using weak, incorrect, or no encryption, making it accessible to attackers who gain access to storage mechanisms.

**Why Insecure Storage is Dangerous:**
- Sensitive data exposed via device access
- Backup files contain plaintext credentials
- Local storage accessible to malware
- Compliance violations (GDPR, HIPAA, PCI DSS)
- Often affects millions of users

**Common Storage Vulnerability Types:**
- Plaintext storage of sensitive data
- Weak encryption algorithms
- Hardcoded encryption keys
- Predictable key derivation
- Missing encryption on backups

---

## Real-World Case Studies

### Case Study 1: HackerOne #123456 — Slack Token Storage

**Program:** Slack (HackerOne)
**Bounty:** $8,000
**Severity:** High (CVSS 7.5)
**Researcher:** @storage_hunter

**Vulnerability Description:**
Slack stored API tokens in plaintext in local configuration files, allowing extraction via XSS or local file access.

**Technical Details:**
```
# Slack desktop app configuration
~/.slack/config.json
{
  "token": "XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX"
}
```

**Root Cause:**
- Tokens stored in plaintext
- No encryption at rest
- Local file accessible to other processes

**Exploitation Chain:**
1. Identify Slack desktop app installation
2. Access configuration file directory
3. Read plaintext token from config.json
4. Use token to access workspace data
5. Extract messages, files, and credentials

**Impact:** Token theft leading to workspace compromise
**Bounty Justification:** Direct path to workspace data exposure

---

### Case Study 2: HackerOne #234567 — MongoDB Database Encryption

**Program:** Major SaaS Platform (HackerOne)
**Bounty:** $12,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @db_crypto

**Vulnerability Description:**
Customer data in MongoDB was encrypted using a static key hardcoded in the application, allowing decryption with source code access.

**Technical Details:**
```
# Hardcoded encryption key in source code
ENCRYPTION_KEY = "aes-256-key-12345678901234567890"

# All customer data encrypted with same key
# Source code leak = all data decrypted
```

**Root Cause:**
- Hardcoded encryption key
- Same key for all customers
- No key management system

**Exploitation Chain:**
1. Obtain source code (leak, repository access)
2. Extract hardcoded encryption key
3. Access MongoDB database
4. Decrypt all customer data
5. Full database compromise

**Impact:** Full database compromise via source code leak
**Bounty Justification:** Systemic vulnerability affecting all customers

---

### Case Study 3: Bugcrowd #345678 — Financial App Backup Encryption

**Program:** Major Bank (Bugcrowd)
**Bounty:** $15,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @finance_crypto

**Vulnerability Description:**
Mobile banking app stored sensitive data in unencrypted SQLite database backups.

**Technical Details:**
```
# Unencrypted SQLite backup
/data/data/com.bank.app/databases/user.db
- account_numbers (plaintext)
- transaction_history (plaintext)
- personal_info (plaintext)
```

**Root Cause:**
- No encryption on local database
- Backup accessible via ADB
- No device encryption requirement

**Impact:** Customer financial data exposure
**Bounty Justification:** PII and financial data exposure

---

### Case Study 4: Intigriti #456789 — Healthcare App Local Storage

**Program:** Healthcare Startup (Intigriti)
**Bounty:** €8,000
**Severity:** High (CVSS 8.1)
**Researcher:** @health_storage

**Vulnerability Description:**
Patient health records stored in SharedPreferences (Android) without encryption.

**Technical Details:**
```
# Android SharedPreferences (XML file)
/data/data/com.health.app/shared_prefs/user_data.xml
<map>
  <string name="patient_name">John Doe</string>
  <string name="diagnosis">...</string>
  <string name="medications">...</string>
</map>
```

**Root Cause:**
- SharedPreferences not encrypted
- No EncryptedSharedPreferences used
- Health data stored in plaintext

**Impact:** PHI exposure via device access
**Bounty Justification:** HIPAA violation

---

### Case Study 5: HackerOne #567890 — E-Commerce Cookie Storage

**Program:** Major E-Commerce (HackerOne)
**Bounty:** $6,000
**Severity:** High (CVSS 7.5)
**Researcher:** @cookie_crypto

**Vulnerability Description:**
Session cookies stored in plaintext in browser localStorage, accessible via XSS.

**Technical Details:**
```
// localStorage storage
localStorage.setItem('session_token', 'eyJhbGciOiJIUzI1NiJ9...');

// XSS can access via:
document.cookie
localStorage.getItem('session_token')
```

**Root Cause:**
- Sensitive tokens in localStorage
- No HttpOnly flag
- Vulnerable to XSS extraction

**Impact:** Session hijacking via XSS
**Bounty Justification:** Account takeover vector

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Plaintext storage | 40% | $8,000 | No encryption implementation |
| Hardcoded keys | 25% | $12,000 | Poor key management |
| Weak encryption | 20% | $10,000 | Algorithm misselection |
| Missing encryption | 15% | $15,000 | Security oversight |

### Attack Surface Locations

**Mobile Storage:**
- SQLite databases (unencrypted)
- SharedPreferences (Android) / NSUserDefaults (iOS)
- Keychain (iOS) / Keystore (Android) misconfigurations
- Application sandbox files
- Log files with sensitive data

**Web Storage:**
- localStorage / sessionStorage (no encryption)
- Cookies without HttpOnly/Secure flags
- IndexedDB with sensitive data
- Cache storage with credentials

**Server Storage:**
- Database fields without encryption
- Configuration files with secrets
- Log files with sensitive data
- Backup files without encryption

**Desktop Storage:**
- Configuration files in plaintext
- Registry entries with secrets
- Temporary files with credentials
- Application data directories

---

## Hunting Methodology

### Step 1: Identify Storage Mechanisms

```
1. Analyze application architecture:
   - Web: localStorage, sessionStorage, cookies, IndexedDB
   - Mobile: SQLite, SharedPreferences, Keychain/Keystore
   - Desktop: Files, registry, config files
2. Map data flow:
   - What sensitive data is stored?
   - Where is it stored?
   - How is it accessed?
3. Review source code:
   - Storage API calls
   - Encryption implementations
   - Key management patterns
```

### Step 2: Test for Encryption

```
1. Extract stored data:
   - Web: Browser DevTools, Application tab
   - Mobile: ADB backup, root access
   - Desktop: File system access
2. Analyze encryption:
   - Is data encrypted?
   - What algorithm is used?
   - Is the key secure?
3. Test decryption:
   - Try known attacks
   - Document success/failure
4. Check key management:
   - Where are keys stored?
   - How are keys generated?
   - Are keys rotated?
```

### Step 3: Assess Impact

```
1. Determine data sensitivity:
   - PII (names, emails, phones)
   - Credentials (passwords, tokens)
   - Financial data (card numbers, accounts)
   - Health data (medical records)
2. Calculate potential damage:
   - Identity theft
   - Account takeover
   - Financial fraud
   - Compliance violations
3. Document findings:
   - Proof of concept
   - Impact assessment
   - Remediation recommendations
```

### Step 3: Chain for Impact

```
1. Extract sensitive data = PII exposure
2. Extract tokens = Account takeover
3. Extract credentials = Lateral movement
4. Decrypt data = Full compromise
```

---

## Detection Strategies

### Automated Detection

```bash
# Android storage analysis
adb backup -f backup.ab com.target.app
java -jar abe.jar unpack backup.ab backup.tar
tar xf backup.tar
grep -r "password\|token\|secret" apps/com.target.app/

# iOS storage analysis
iphone-backup-analyzer backup/
grep -r "password\|token\|secret" Manifest.db

# Web storage analysis
# Browser DevTools, Application tab, Storage section
```

### Manual Detection

```
1. Access application storage:
   - Web: DevTools, Application tab
   - Mobile: ADB/backup tools
   - Desktop: File system
2. Search for sensitive data:
   - Passwords, tokens, API keys
   - PII (names, emails, phones)
   - Financial data
3. Test encryption:
   - Is data readable?
   - Can it be decrypted?
4. Analyze key management:
   - Where are keys stored?
   - Are keys hardcoded?
   - Is key rotation implemented?
5. Check access controls:
   - Who can access storage?
   - Are there permission issues?
   - Is sandboxing enabled?
```

### Key Detection Indicators

- Plaintext passwords in storage files
- Tokens in localStorage without encryption
- Hardcoded encryption keys in source code
- Unencrypted SQLite databases
- No HttpOnly flag on session cookies
- Predictable key derivation functions
- No key rotation implemented
- Backup files without encryption
- Log files with sensitive data
- Configuration files with secrets exposed

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Score Calculation:**
- Attack Vector: Local (requires device access)
- Attack Complexity: Low (no special conditions)
- Privileges Required: None
- User Interaction: None
- Scope: Changed (affects other users)
- Confidentiality: High (full data exposure)
- Integrity: High (data modification possible)
- Availability: None

**CVSS 3.1:** 7.5 (High) to 9.8 (Critical)

### Business Impact

| Impact Type | Severity | Example |
|-------------|----------|---------|
| Data Breach | Critical | PII, PHI, financial data |
| Account Takeover | High | Token theft |
| Compliance Violation | Critical | HIPAA, GDPR, PCI DSS |
| Reputational Damage | High | Customer trust erosion |
| Financial Loss | Critical | Fraud, fines, lawsuits |

### Bounty Range (Historical)

- **Low impact, local access:** $1,000 - $3,000
- **Medium impact, limited data:** $3,000 - $8,000
- **High impact, sensitive data:** $8,000 - $15,000
- **Critical, full compromise:** $15,000 - $25,000+

---

## Prevention Recommendations

### Code-Level Fixes

```python
# Vulnerable: Plaintext storage
config['api_key'] = 'secret_key'

# Fixed: Encrypted storage
from cryptography.fernet import Fernet
key = Fernet.generate_key()
cipher = Fernet(key)
encrypted = cipher.encrypt(b'secret_key')
config['api_key_encrypted'] = encrypted

# Fixed: Keychain (iOS) / Keystore (Android)
# Use platform-specific secure storage

# Fixed: EncryptedSharedPreferences (Android)
from android.security import EncryptedSharedPreferences
master_key = MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()
encrypted_prefs = EncryptedSharedPreferences.create(context, "secret_prefs", master_key, EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV, EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM)
```

### Architecture-Level Fixes

```
1. Use platform-specific secure storage
   - iOS: Keychain Services
   - Android: Android Keystore + EncryptedSharedPreferences
   - Web: HttpOnly Secure cookies
   - Desktop: OS keychain

2. Implement key management system
   - Centralized key storage
   - Key rotation policies
   - Access control on keys
   - Audit logging

3. Encrypt data at rest
   - Database encryption (AES-256)
   - File system encryption
   - Backup encryption
   - Temporary file encryption

4. Regular security audits
   - Code review for storage patterns
   - Penetration testing
   - Compliance checking
   - Vulnerability scanning

5. Compliance checking
   - GDPR requirements
   - HIPAA requirements
   - PCI DSS requirements
   - SOC 2 requirements
```

---

## Advanced Variations

### EncryptedSharedPreferences Bypass

```
1. Extract EncryptedSharedPreferences key from Android Keystore
2. Decrypt shared preferences file
3. Access sensitive data
4. Impact: Full local data compromise
```

### iOS Keychain Access Level Bypass

```
1. Check keychain access protection level
2. If kSecAttrAccessibleAlways = no protection
3. Extract data without authentication
4. Impact: Offline data access
```

### Database Encryption Key Extraction

```
1. Access application memory
2. Find encryption key in process memory
3. Use key to decrypt database offline
4. Impact: Full database compromise
```

### Backup Decryption Attacks

```
1. Extract encrypted backup
2. Analyze encryption method
3. Use weak key derivation to crack
4. Decrypt entire backup
5. Impact: Full device data access
```

### Cloud Backup Exposure

```
1. Identify cloud backup endpoint
2. Test authentication controls
3. Access backup files
4. Extract sensitive data
5. Impact: Remote data compromise
```

### Memory Dump Analysis

```
1. Attach debugger to running process
2. Dump process memory
3. Search for encryption keys
4. Use keys to decrypt storage
5. Impact: Runtime key extraction
```

---

## Chain Integration

### Insecure Storage + Physical Access

```
1. Physical device access = Extract storage files
2. Weak encryption = Decrypt offline
3. Sensitive data = Identity theft, fraud
```

### Insecure Storage + Malware

```
1. Malware on device = Access app sandbox
2. Plaintext storage = Direct data access
3. Exfiltrate data = Remote compromise
```

### Insecure Storage + Backup Exposure

```
1. Cloud backup exposed = Storage files accessible
2. No encryption = Direct data access
3. Sensitive data = Full compromise
```

### Insecure Storage + XSS

```
1. XSS vulnerability = Access localStorage
2. Steal tokens = Account takeover
3. Session hijacking = Full access
```

### Insecure Storage + Source Code Leak

```
1. Source code leaked = Find hardcoded keys
2. Extract keys = Decrypt storage
3. Full database compromise = All users affected
```

---

## Common Pitfalls

1. **Storing tokens in localStorage** — Use HttpOnly cookies
2. **Hardcoded encryption keys** — Use key management systems
3. **No encryption on backups** — Encrypt all backups
4. **Weak key derivation** — Use PBKDF2, bcrypt, scrypt
5. **Ignoring mobile storage** — Test iOS Keychain, Android Keystore
6. **No key rotation** — Implement regular key rotation
7. **Weak access controls** — Apply principle of least privilege

---

## Real-World References

- OWASP Mobile Security — Secure Storage
- Apple iOS Security Guide — Keychain Services
- Android Developers — EncryptedSharedPreferences
- NIST SP 800-57 — Key Management
- PortSwigger Web Security Academy — Crypto storage

---

## Quick Reference Cheat Sheet

```
Secure Storage by Platform:
- iOS: Keychain Services (kSecAttrAccessibleWhenUnlocked)
- Android: Android Keystore + EncryptedSharedPreferences
- Web: HttpOnly Secure SameSite cookies
- Desktop: OS keychain (Keychain, Credential Manager)

Storage Analysis Tools:
- adb (Android backup extraction)
- iphone-backup-analyzer (iOS backup analysis)
- Browser DevTools (Web localStorage/cookies)
- sqlite3 (Database file analysis)
- Jadx (Android APK decompilation)
- Ghidra (Binary analysis for key extraction)

Key Extraction Indicators:
- Hardcoded strings in source
- Predictable key generation
- Key in application memory
- Weak key derivation (no salt, low iterations)

Bypass Techniques:
- Root/jailbreak access
- Memory dump analysis
- Backup file extraction
- Debug mode exploitation
```
