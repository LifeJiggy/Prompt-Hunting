You are an elite Cryptography and Data Protection Learning AI, specializing in teaching encryption implementation security. Your expertise focuses on educating bug bounty hunters about cryptographic algorithm assessment, key management, digital signatures, and secure data handling practices.

Your mission is to guide aspiring security researchers through cryptography complexities, teaching them systematic approaches to testing encryption implementations, identifying weak algorithms, and developing secure cryptographic practices.

Key Learning Objectives:
- **Cryptographic Algorithm Assessment**: Master cipher strength and implementation security
- **Key Management**: Learn secure key generation, storage, and rotation practices
- **Hash Function Evaluation**: Assess password hashing and data integrity mechanisms
- **Digital Signature Verification**: Test signature validation and certificate handling
- **TLS/SSL Configuration**: Evaluate transport layer security implementations
- **Data at Rest Protection**: Assess encryption of stored sensitive data
- **Data in Transit Security**: Test secure communication channel implementations

Advanced Learning Concepts:
- **Cryptanalysis Techniques**: Learn known cryptographic weakness exploitation
- **Key Recovery Methods**: Understand key exposure and recovery attacks
- **Padding Oracle Attacks**: Master CBC padding oracle vulnerability exploitation
- **Side-Channel Analysis**: Study timing and power consumption leak assessment
- **Implementation Flaws**: Identify incorrect cryptographic API usage patterns
- **Protocol Downgrade**: Test for protocol version downgrade attack prevention
- **Certificate Validation**: Assess certificate pinning and validation mechanisms

Learning Process:
1. **Cryptography Fundamentals**: Understand core cryptographic principles and concepts
2. **Algorithm Assessment**: Learn cipher suite and hash function evaluation
3. **Key Management**: Study secure key lifecycle and storage practices
4. **Implementation Analysis**: Practice correct cryptographic API usage verification
5. **Protocol Security**: Test TLS configurations and secure channel implementations
6. **Attack Techniques**: Learn common cryptographic attack methodologies
7. **Compliance Standards**: Understand regulatory requirements for cryptography

Teaching Methodology:
- **Algorithm Deep Dives**: Detailed analysis of cryptographic algorithms and their weaknesses
- **Key Management Labs**: Hands-on key lifecycle and storage security exercises
- **Implementation Workshops**: Cryptographic API usage and best practice training
- **Protocol Testing**: TLS configuration and secure communication assessment
- **Attack Simulations**: Safe cryptographic attack technique demonstrations
- **Real-World Scenarios**: Case studies of cryptographic implementation failures
- **Compliance Frameworks**: Regulatory requirement understanding and implementation

Output Format:
- **Cryptography Modules**: Structured learning units for cryptographic concepts
- **Algorithm Exercises**: Practical cipher and hash function assessment labs
- **Key Management Tutorials**: Secure key lifecycle implementation guides
- **Implementation Labs**: Cryptographic API usage testing exercises
- **Protocol Workshops**: TLS and secure communication testing frameworks
- **Case Studies**: Real-world cryptographic vulnerability examples
- **Compliance Framework**: Regulatory requirement implementation guides

Example Learning Query: "Teach me cryptography and data protection security testing from basics to expert level"

---

# Module 1: Cryptographic Fundamentals

## 1.1 Core Cryptographic Concepts

### Symmetric vs Asymmetric Encryption

| Property | Symmetric | Asymmetric |
|----------|-----------|------------|
| Keys | Same key for encrypt/decrypt | Public/private key pair |
| Speed | Fast | Slow |
| Key Distribution | Problematic | Easier |
| Use Cases | Data encryption | Key exchange, signatures |
| Examples | AES, DES, 3DES | RSA, ECC, Ed25519 |

### Cryptographic Primitives

```python
# Symmetric Encryption (AES)
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import os

# Generate key and IV
key = os.urandom(32)  # 256-bit key
iv = os.urandom(16)   # 128-bit IV

# Encrypt
cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=default_backend())
encryptor = cipher.encryptor()
plaintext = b"Sensitive data to encrypt"
padded_plaintext = plaintext + b"\x00" * (16 - len(plaintext) % 16)
ciphertext = encryptor.update(padded_plaintext) + encryptor.finalize()

# Decrypt
decryptor = cipher.decryptor()
decrypted = decryptor.update(ciphertext) + decryptor.finalize()
print(decrypted.rstrip(b"\x00"))  # Remove padding
```

```python
# Asymmetric Encryption (RSA)
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes

# Generate key pair
private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048,
    backend=default_backend()
)
public_key = private_key.public_key()

# Encrypt with public key
plaintext = b"Sensitive data"
ciphertext = public_key.encrypt(
    plaintext,
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)

# Decrypt with private key
plaintext = private_key.decrypt(
    ciphertext,
    padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None
    )
)
```

## 1.2 Hash Functions

### Hash Function Properties

- **Deterministic**: Same input always produces same output
- **Fixed Output**: Output length is fixed regardless of input size
- **One-way**: Cannot reverse hash to get original input
- **Collision-resistant**: Difficult to find two inputs with same hash

### Common Hash Functions

```python
import hashlib

# MD5 (INSECURE - never use for security)
md5_hash = hashlib.md5(b"data").hexdigest()
print(f"MD5: {md5_hash}")

# SHA-1 (INSECURE - deprecated)
sha1_hash = hashlib.sha1(b"data").hexdigest()
print(f"SHA-1: {sha1_hash}")

# SHA-256 (Secure)
sha256_hash = hashlib.sha256(b"data").hexdigest()
print(f"SHA-256: {sha256_hash}")

# SHA-512 (Secure)
sha512_hash = hashlib.sha512(b"data").hexdigest()
print(f"SHA-512: {sha512_hash}")
```

### Password Hashing (Special Case)

```python
# Secure password hashing with bcrypt
import bcrypt

# Hash password
password = b"user_password"
salt = bcrypt.gensalt(rounds=12)  # Cost factor of 12
hashed = bcrypt.hashpw(password, salt)

# Verify password
if bcrypt.checkpw(password, hashed):
    print("Password matches!")
else:
    print("Password does not match!")
```

```python
# Password hashing with Argon2 (recommended)
from argon2 import PasswordHasher

ph = PasswordHasher(
    time_cost=3,        # Number of iterations
    memory_cost=65536,  # 64MB memory usage
    parallelism=4       # Number of parallel threads
)

# Hash password
hash = ph.hash("user_password")

# Verify password
try:
    ph.verify(hash, "user_password")
    print("Password verified!")
except Exception as e:
    print(f"Verification failed: {e}")
```

## 1.3 Cryptographic Exercises

### Exercise 1.1: Hash Function Comparison

1. Hash the same string with MD5, SHA-1, SHA-256, SHA-512
2. Compare output lengths
3. Test collision resistance by hashing similar inputs
4. Measure performance differences

```python
import hashlib
import time

test_strings = [
    "hello",
    "hello!",
    "Hello!",
    "hello1",
]

algorithms = ['md5', 'sha1', 'sha256', 'sha512']

for algo in algorithms:
    print(f"\n=== {algo.upper()} ===")
    for s in test_strings:
        h = hashlib.new(algo)
        h.update(s.encode())
        print(f"  {s:15} -> {h.hexdigest()}")
```

### Exercise 1.2: Password Hashing Strength

```python
import bcrypt
import time

passwords = [
    "password123",
    "Password123!",
    "correct horse battery staple",
    "a" * 64,
]

for pwd in passwords:
    start = time.time()
    salt = bcrypt.gensalt(rounds=12)
    hashed = bcrypt.hashpw(pwd.encode(), salt)
    elapsed = time.time() - start
    
    print(f"Password: {pwd[:20]}...")
    print(f"  Hash: {hashed.decode()[:40]}...")
    print(f"  Time: {elapsed:.3f}s\n")
```

---

# Module 2: Key Management Security

## 2.1 Key Generation

### Secure Random Number Generation

```python
import secrets
import os

# Secure random bytes
secure_bytes = secrets.token_bytes(32)
print(f"Secure bytes: {secure_bytes.hex()}")

# Secure random hex string
secure_hex = secrets.token_hex(16)
print(f"Secure hex: {secure_hex}")

# Secure random URL-safe string
secure_url = secrets.token_urlsafe(32)
print(f"Secure URL: {secure_url}")

# Secure random integer in range
secure_int = secrets.randbelow(1000)
print(f"Secure int: {secure_int}")
```

### INSECURE Random Number Generation

```python
import random
import time

# NEVER use for security purposes
insecure_random = random.random()
print(f"Insecure random: {insecure_random}")

# Predictable seed
random.seed(42)
predictable = random.randint(0, 1000000)
print(f"Predictable: {predictable}")

# Time-based seed (attackers can predict)
random.seed(int(time.time()))
time_based = random.randint(0, 1000000)
print(f"Time-based: {time_based}")
```

## 2.2 Key Storage

### Hardcoded Keys (Vulnerability)

```python
# INSECURE: Hardcoded encryption key
HARDCODED_KEY = b"super_secret_key_12345678901234"

def encrypt_insecure(data):
    cipher = Cipher(algorithms.AES(HARDCODED_KEY), modes.CBC(b'\x00' * 16))
    encryptor = cipher.encryptor()
    return encryptor.update(data) + encryptor.finalize()
```

### Environment Variables

```python
# Better: Use environment variables
import os
from dotenv import load_dotenv

load_dotenv()

def get_encryption_key():
    key_hex = os.getenv('ENCRYPTION_KEY')
    if not key_hex:
        raise ValueError("ENCRYPTION_KEY not set")
    return bytes.fromhex(key_hex)

def encrypt_secure(data):
    key = get_encryption_key()
    iv = os.urandom(16)
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(data) + encryptor.finalize()
    return iv + ciphertext  # Prepend IV for decryption
```

### Key Management Services

```python
# AWS KMS example
import boto3

kms_client = boto3.client('kms')

# Generate data key
response = kms_client.generate_data_key(
    KeyId='alias/my-key',
    KeySpec='AES_256'
)

plaintext_key = response['Plaintext']
encrypted_key = response['CiphertextBlob']

# Use plaintext_key for encryption
# Store encrypted_key with ciphertext
# Retrieve plaintext_key later using KMS decrypt
```

## 2.3 Key Rotation

```python
class KeyRotator:
    def __init__(self):
        self.keys = {}
        self.current_key_id = None
    
    def add_key(self, key_id, key_material):
        self.keys[key_id] = {
            'key': key_material,
            'created_at': datetime.now(),
            'active': True
        }
    
    def rotate_key(self, new_key_id, new_key_material):
        # Deactivate old key
        if self.current_key_id:
            self.keys[self.current_key_id]['active'] = False
        
        # Add new key
        self.add_key(new_key_id, new_key_material)
        self.current_key_id = new_key_id
    
    def get_active_key(self):
        if self.current_key_id:
            return self.keys[self.current_key_id]['key']
        return None
    
    def get_key_for_decryption(self, key_id):
        if key_id in self.keys:
            return self.keys[key_id]['key']
        return None
```

## 2.4 Key Management Exercises

### Exercise 2.1: Key Hardcoding Search

1. Find hardcoded keys in application code
2. Search patterns:
   ```
   KEY = b"..."
   SECRET = "..."
   password = "..."
   api_key = "..."
   ```
3. Document all hardcoded secrets found

### Exercise 2.2: Key Management Audit

```python
def audit_key_management():
    findings = []
    
    # Check for hardcoded keys
    import os
    for root, dirs, files in os.walk('.'):
        for file in files:
            if file.endswith(('.py', '.js', '.java')):
                with open(os.path.join(root, file)) as f:
                    content = f.read()
                    patterns = [
                        r'KEY\s*=\s*[b"\'][^"\']+[b"\']',
                        r'SECRET\s*=\s*["\'][^"\']+["\']',
                        r'password\s*=\s*["\'][^"\']+["\']',
                    ]
                    for pattern in patterns:
                        import re
                        matches = re.findall(pattern, content)
                        if matches:
                            findings.append({
                                'file': file,
                                'pattern': pattern,
                                'matches': matches
                            })
    
    return findings
```

---

# Module 3: TLS/SSL Security

## 3.1 TLS Configuration Assessment

### Checking TLS Configuration

```python
import ssl
import socket

def check_tls_config(hostname, port=443):
    context = ssl.create_default_context()
    
    # Check supported protocols
    print(f"\n=== TLS Configuration for {hostname} ===")
    
    # Test for weak protocols
    weak_protocols = []
    for protocol_name in ['SSLv2', 'SSLv3', 'TLSv1', 'TLSv1.1']:
        try:
            test_context = ssl.SSLContext(getattr(ssl, f'PROTOCOL_{protocol_name}'))
            weak_protocols.append(protocol_name)
        except:
            pass
    
    if weak_protocols:
        print(f"Weak protocols supported: {weak_protocols}")
    else:
        print("No weak protocols detected")
    
    # Check cipher suites
    print("\nCipher suites:")
    with socket.create_connection((hostname, port)) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as ssock:
            print(f"Protocol: {ssock.version()}")
            print(f"Cipher: {ssock.cipher()}")
            print(f"Certificates: {ssock.getpeercert()}")

# Test configuration
check_tls_config("example.com")
```

### TLS Scanner Script

```python
import ssl
import socket
from cryptography import x509
from cryptography.hazmat.backends import default_backend

def tls_security_scan(hostname, port=443):
    findings = []
    
    # Connect and get certificate
    context = ssl.create_default_context()
    
    with socket.create_connection((hostname, port)) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as ssock:
            # Check protocol version
            protocol = ssock.version()
            if protocol in ['TLSv1', 'TLSv1.1', 'SSLv3']:
                findings.append({
                    'severity': 'HIGH',
                    'issue': f'Weak protocol: {protocol}'
                })
            
            # Get certificate details
            cert_der = ssock.getpeercert(binary_form=True)
            cert = x509.load_der_x509_certificate(cert_der, default_backend())
            
            # Check key size
            if cert.public_key().key_size < 2048:
                findings.append({
                    'severity': 'HIGH',
                    'issue': f'Weak key size: {cert.public_key().key_size} bits'
                })
            
            # Check signature algorithm
            sig_algo = cert.signature_algorithm_oid._name
            if 'sha1' in sig_algo.lower() or 'md5' in sig_algo.lower():
                findings.append({
                    'severity': 'HIGH',
                    'issue': f'Weak signature algorithm: {sig_algo}'
                })
            
            # Check expiration
            import datetime
            if cert.not_valid_after < datetime.datetime.now():
                findings.append({
                    'severity': 'CRITICAL',
                    'issue': 'Certificate expired'
                })
    
    return findings

# Run scan
findings = tls_security_scan("example.com")
for f in findings:
    print(f"[{f['severity']}] {f['issue']}")
```

## 3.2 Common TLS Vulnerabilities

### Certificate Validation Bypass

```python
# INSECURE: Disabling certificate verification
import requests

# NEVER do this in production
response = requests.get('https://target.com', verify=False)

# This disables SSL certificate verification!
```

### MITM Attack Detection

```python
# Test for MITM vulnerability
import requests
import ssl
from urllib3.exceptions import InsecureRequestWarning

# Suppress only the single InsecureRequestWarning
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

def test_mitm(hostname):
    """Test if application accepts invalid certificates"""
    
    # Try with invalid certificate
    session = requests.Session()
    session.verify = False
    
    try:
        response = session.get(f'https://{hostname}')
        print(f"WARNING: {hostname} accepts invalid certificates!")
        return True
    except Exception as e:
        print(f"{hostname} properly rejects invalid certificates")
        return False
```

## 3.3 TLS Exercises

### Exercise 3.1: TLS Configuration Audit

1. Scan a target's TLS configuration
2. Check for:
   - Weak protocols (SSLv2, SSLv3, TLSv1, TLSv1.1)
   - Weak cipher suites
   - Certificate issues (expiry, key size, signature algorithm)
3. Document findings and recommendations

### Exercise 3.2: Certificate Pinning Test

```python
import requests
from requests_toolbelt.adapters.fingerprint import FingerprintAdapter

# Test certificate pinning
def test_cert_pinning(hostname):
    try:
        # Try to connect with custom CA
        session = requests.Session()
        session.mount('https://', FingerprintAdapter(hostname))
        
        response = session.get(f'https://{hostname}')
        print(f"Connection successful - no pinning enforced")
    except Exception as e:
        print(f"Certificate pinning enforced: {e}")
```

---

# Module 4: Encryption at Rest

## 4.1 Database Encryption

### Full Disk Encryption Check

```python
# Check if database files are encrypted
import os
import subprocess

def check_disk_encryption():
    if os.name == 'nt':  # Windows
        result = subprocess.run(
            ['manage-bde', '-status', 'C:'],
            capture_output=True,
            text=True
        )
        return 'Protection Status: Protection On' in result.stdout
    else:  # Linux/Mac
        result = subprocess.run(
            ['lsblk', '-o', 'NAME,FSTYPE,MOUNTPOINT,SIZE'],
            capture_output=True,
            text=True
        )
        return 'crypto' in result.stdout.lower()
```

### Field-Level Encryption

```python
from cryptography.fernet import Fernet

class FieldEncryptor:
    def __init__(self, key=None):
        if key is None:
            self.key = Fernet.generate_key()
        else:
            self.key = key
        self.cipher = Fernet(self.key)
    
    def encrypt_field(self, plaintext):
        """Encrypt a database field"""
        return self.cipher.encrypt(plaintext.encode()).decode()
    
    def decrypt_field(self, ciphertext):
        """Decrypt a database field"""
        return self.cipher.decrypt(ciphertext.encode()).decode()
    
    def encrypt_dict(self, data, fields):
        """Encrypt specific fields in a dictionary"""
        encrypted = data.copy()
        for field in fields:
            if field in encrypted:
                encrypted[field] = self.encrypt_field(str(encrypted[field]))
        return encrypted
    
    def decrypt_dict(self, data, fields):
        """Decrypt specific fields in a dictionary"""
        decrypted = data.copy()
        for field in fields:
            if field in decrypted:
                decrypted[field] = self.decrypt_field(decrypted[field])
        return decrypted

# Usage
encryptor = FieldEncryptor()

# Encrypt sensitive fields before storing
user_data = {
    'id': 123,
    'name': 'John Doe',
    'email': 'john@example.com',
    'ssn': '123-45-6789',
    'credit_card': '4111111111111111'
}

encrypted_data = encryptor.encrypt_dict(user_data, ['ssn', 'credit_card'])
print(f"Encrypted: {encrypted_data}")

# Decrypt when reading
decrypted_data = encryptor.decrypt_dict(encrypted_data, ['ssn', 'credit_card'])
print(f"Decrypted: {decrypted_data}")
```

## 4.2 File Encryption

```python
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import os

def encrypt_file(input_file, output_file, key):
    """Encrypt a file using AES-CBC"""
    iv = os.urandom(16)
    
    with open(input_file, 'rb') as f:
        plaintext = f.read()
    
    # Pad plaintext
    padder = padding.PKCS7(128).padder()
    padded_data = padder.update(plaintext) + padder.finalize()
    
    # Encrypt
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(padded_data) + encryptor.finalize()
    
    # Write IV + ciphertext
    with open(output_file, 'wb') as f:
        f.write(iv + ciphertext)

def decrypt_file(input_file, output_file, key):
    """Decrypt a file using AES-CBC"""
    with open(input_file, 'rb') as f:
        data = f.read()
    
    iv = data[:16]
    ciphertext = data[16:]
    
    # Decrypt
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()
    padded_data = decryptor.update(ciphertext) + decryptor.finalize()
    
    # Remove padding
    unpadder = padding.PKCS7(128).unpadder()
    plaintext = unpadder.update(padded_data) + unpadder.finalize()
    
    with open(output_file, 'wb') as f:
        f.write(plaintext)

# Usage
key = os.urandom(32)
encrypt_file('secret.txt', 'secret.enc', key)
decrypt_file('secret.enc', 'secret_decrypted.txt', key)
```

## 4.3 Encryption at Rest Exercises

### Exercise 4.1: Database Encryption Audit

1. Examine database configuration
2. Check for:
   - Full disk encryption
   - Transparent Data Encryption (TDE)
   - Field-level encryption
   - Backup encryption
3. Document encryption coverage

### Exercise 4.2: File Encryption Assessment

```python
# Test file encryption implementation
import os

def test_file_encryption():
    # Create test file
    test_content = b"Sensitive test data"
    test_file = "test_plain.txt"
    enc_file = "test_encrypted.bin"
    dec_file = "test_decrypted.txt"
    
    with open(test_file, 'wb') as f:
        f.write(test_content)
    
    # Generate key
    key = os.urandom(32)
    
    # Test encryption
    encrypt_file(test_file, enc_file, key)
    
    # Verify file is encrypted
    with open(enc_file, 'rb') as f:
        encrypted_content = f.read()
    
    if encrypted_content == test_content:
        print("FAIL: File not encrypted")
    else:
        print("PASS: File encrypted successfully")
    
    # Test decryption
    decrypt_file(enc_file, dec_file, key)
    
    with open(dec_file, 'rb') as f:
        decrypted_content = f.read()
    
    if decrypted_content == test_content:
        print("PASS: File decrypted correctly")
    else:
        print("FAIL: Decryption failed")
    
    # Cleanup
    os.remove(test_file)
    os.remove(enc_file)
    os.remove(dec_file)

test_file_encryption()
```

---

# Module 5: Padding Oracle Attacks

## 5.1 Understanding Padding Oracle Attacks

### CBC Mode Vulnerability

```python
# Simulating a vulnerable padding oracle
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import os

class VulnerableEncryption:
    def __init__(self):
        self.key = os.urandom(32)
    
    def encrypt(self, plaintext):
        iv = os.urandom(16)
        cipher = Cipher(algorithms.AES(self.key), modes.CBC(iv))
        encryptor = cipher.encryptor()
        
        padder = padding.PKCS7(128).padder()
        padded = padder.update(plaintext.encode()) + padder.finalize()
        
        ciphertext = encryptor.update(padded) + encryptor.finalize()
        return iv + ciphertext
    
    def decrypt(self, ciphertext):
        """Vulnerable decryption that leaks padding errors"""
        iv = ciphertext[:16]
        ct = ciphertext[16:]
        
        cipher = Cipher(algorithms.AES(self.key), modes.CBC(iv))
        decryptor = cipher.decryptor()
        padded = decryptor.update(ct) + decryptor.finalize()
        
        # VULNERABLE: Different error for invalid padding
        try:
            unpadder = padding.PKCS7(128).unpadder()
            plaintext = unpadder.update(padded) + unpadder.finalize()
            return plaintext.decode()
        except ValueError:
            raise ValueError("Invalid padding!")  # LEAKS INFO!
```

## 5.2 Padding Oracle Exploitation

```python
def padding_oracle_attack(oracle, ciphertext):
    """
    Exploit a padding oracle to decrypt ciphertext
    oracle: function that returns True if padding is valid
    ciphertext: the encrypted data to decrypt
    """
    block_size = 16  # AES block size
    iv = ciphertext[:16]
    ct = ciphertext[16:]
    
    plaintext = b''
    
    # Process each block
    for block_num in range(len(ct) // block_size):
        block = ct[block_num * block_size:(block_num + 1) * block_size]
        decrypted_block = b''
        
        # Decrypt each byte in the block
        for byte_pos in range(block_size - 1, -1, -1):
            padding_value = block_size - byte_pos
            
            # Create modified IV
            modified_iv = bytearray(iv)
            
            # Set known bytes to produce correct padding
            for i in range(byte_pos + 1, block_size):
                modified_iv[i] = decrypted_block[i - byte_pos - 1] ^ padding_value
            
            # Brute force the current byte
            for guess in range(256):
                modified_iv[byte_pos] = guess
                
                # Test if padding is valid
                test_ct = bytes(modified_iv) + block
                if oracle(test_ct):
                    # Verify it's not a false positive
                    if byte_pos > 0:
                        # Flip another byte to confirm
                        modified_iv[byte_pos - 1] ^= 1
                        if not oracle(bytes(modified_iv) + block):
                            continue
                    
                    decrypted_byte = guess ^ padding_value
                    decrypted_block = bytes([decrypted_byte]) + decrypted_block
                    print(f"Byte {byte_pos}: {chr(decrypted_byte)} ({hex(decrypted_byte)})")
                    break
        
        plaintext += decrypted_block
    
    return plaintext
```

## 5.3 Padding Oracle Exercises

### Exercise 5.1: Padding Oracle Detection

```python
def detect_padding_oracle(base_url, endpoint):
    """Test for padding oracle vulnerability"""
    import requests
    
    # Send valid ciphertext
    valid_response = requests.post(
        f"{base_url}{endpoint}",
        data={"data": "valid_ciphertext_hex"}
    )
    
    # Send ciphertext with modified last byte (invalid padding)
    invalid_response = requests.post(
        f"{base_url}{endpoint}",
        data={"data": "valid_ciphertext_hex_with_modified_byte"}
    )
    
    # Compare responses
    if valid_response.status_code != invalid_response.status_code:
        print("Potential padding oracle detected!")
        return True
    
    if len(valid_response.content) != len(invalid_response.content):
        print("Response length difference detected!")
        return True
    
    return False
```

### Exercise 5.2: Padding Oracle Exploitation Lab

1. Set up a vulnerable application with CBC encryption
2. Implement the padding oracle attack
3. Decrypt a target ciphertext
4. Encrypt arbitrary plaintext using the oracle

---

# Module 6: Common Cryptographic Vulnerabilities

## 6.1 Weak Algorithm Usage

### Identifying Weak Algorithms

```python
import re
import os

def scan_for_weak_crypto(directory):
    """Scan codebase for weak cryptographic algorithms"""
    weak_patterns = [
        (r'MD5', 'MD5 hash - use SHA-256 or better'),
        (r'SHA1', 'SHA-1 hash - use SHA-256 or better'),
        (r'DES\b', 'DES encryption - use AES'),
        (r'RC4', 'RC4 cipher - use AES'),
        (r'ECB', 'ECB mode - use CBC or GCM'),
        (r'random\(\)', 'Insecure random - use secrets module'),
        (r'Math\.random', 'Insecure random - use crypto.getRandomValues'),
    ]
    
    findings = []
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(('.py', '.js', '.java', '.php')):
                with open(os.path.join(root, file)) as f:
                    content = f.read()
                    
                    for pattern, description in weak_patterns:
                        if re.search(pattern, content, re.IGNORECASE):
                            findings.append({
                                'file': file,
                                'pattern': pattern,
                                'issue': description
                            })
    
    return findings
```

## 6.2 Hardcoded Secrets

### Secret Detection Patterns

```python
secret_patterns = [
    # API Keys
    r'(?i)(api[_-]?key|apikey)\s*[=:]\s*["\'][^"\']+["\']',
    r'(?i)(secret|token)\s*[=:]\s*["\'][^"\']+["\']',
    
    # AWS
    r'AKIA[0-9A-Z]{16}',
    r'(?i)aws[_-]?secret[_-]?access[_-]?key',
    
    # Private Keys
    r'-----BEGIN (RSA |EC )?PRIVATE KEY-----',
    
    # Passwords
    r'(?i)password\s*[=:]\s*["\'][^"\']+["\']',
    r'(?i)passwd\s*[=:]\s*["\'][^"\']+["\']',
    
    # Database
    r'(?i)(mysql|postgres|mongo|redis):\/\/[^"\']+',
    
    # JWT
    r'eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*',
]

def find_secrets(directory):
    import re
    findings = []
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            with open(os.path.join(root, file)) as f:
                content = f.read()
                
                for pattern in secret_patterns:
                    matches = re.findall(pattern, content)
                    if matches:
                        findings.append({
                            'file': file,
                            'pattern': pattern,
                            'matches': matches[:5]  # First 5 matches
                        })
    
    return findings
```

## 6.3 Cryptographic Exercises

### Exercise 6.1: Weak Crypto Scan

1. Scan a codebase for weak cryptographic implementations
2. Document all findings
3. Provide remediation recommendations

### Exercise 6.2: Secret Detection

```python
# Run secret detection on a target codebase
findings = find_secrets("/path/to/codebase")
for f in findings:
    print(f"\nFile: {f['file']}")
    print(f"Pattern: {f['pattern']}")
    print(f"Matches: {f['matches']}")
```

---

# Module 7: Practical Exercises

## Exercise Set A: Beginner

### A1: Hash Function Comparison

1. Hash the same string with multiple algorithms
2. Compare output lengths and formats
3. Measure performance
4. Determine which algorithms are suitable for which use cases

### A2: TLS Configuration Check

1. Use `openssl` to check a target's TLS configuration
2. Test for weak protocols and ciphers
3. Document findings

```bash
# Test TLS configuration
openssl s_client -connect target.com:443 -tls1
openssl s_client -connect target.com:443 -tls1_1
openssl s_client -connect target.com:443 -tls1_2
openssl s_client -connect target.com:443 -tls1_3
```

## Exercise Set B: Intermediate

### B1: Padding Oracle Lab

1. Set up a vulnerable application
2. Implement padding oracle attack
3. Decrypt target ciphertext
4. Encrypt arbitrary plaintext

### B2: Key Management Audit

1. Analyze application's key management
2. Identify hardcoded keys
3. Assess key rotation practices
4. Document vulnerabilities

## Exercise Set C: Advanced

### C1: Cryptographic Implementation Review

1. Perform full cryptographic audit of an application
2. Identify all cryptographic implementations
3. Assess algorithm strength
4. Test for implementation flaws
5. Document comprehensive findings

### C2: Custom Cryptographic Attack

1. Identify a cryptographic vulnerability
2. Develop exploitation script
3. Demonstrate impact
4. Provide remediation

---

# Module 8: Assessment Questions

## Knowledge Check

### Question 1
Which of the following is a secure way to generate cryptographic keys?
- A) `random.randint()`
- B) `secrets.token_bytes()`
- C) `time.time()`
- D) `hashlib.md5()`

### Question 2
What is the primary vulnerability that enables padding oracle attacks?
- A) Weak encryption algorithm
- B) Different error messages for invalid padding
- C) Hardcoded encryption key
- D) Using ECB mode

### Question 3
Which TLS protocol versions are considered insecure?
- A) TLS 1.2 and TLS 1.3
- B) SSLv2, SSLv3, TLS 1.0, TLS 1.1
- C) Only SSLv2
- D) All versions are secure

### Question 4
What is the recommended way to hash passwords?
- A) MD5 with salt
- B) SHA-256 with salt
- C) bcrypt or Argon2
- D) Plain text

### Question 5
What is a padding oracle attack?
- A) Brute-forcing encryption keys
- B) Exploiting error messages that reveal padding validity
- C) Stealing encryption keys from memory
- D) Downgrading TLS connections

## Practical Assessment

### Task 1: Cryptographic Audit

Perform a cryptographic audit of a web application:
1. Identify all cryptographic implementations
2. Assess algorithm strength
3. Test for common vulnerabilities
4. Document findings with severity ratings

### Task 2: TLS Security Assessment

Write a script that:
1. Connects to a target server
2. Extracts TLS configuration
3. Tests for weak protocols and ciphers
4. Generates a security report

### Task 3: Key Management Review

Analyze an application's key management:
1. Identify key storage methods
2. Test for hardcoded keys
3. Assess key rotation practices
4. Provide recommendations

---

# Module 9: Secure Implementation Guide

## 9.1 Secure Cryptographic Implementation

```python
# Secure encryption implementation
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

class SecureEncryption:
    def __init__(self):
        self.key = AESGCM.generate_key(bit_length=256)
    
    def encrypt(self, plaintext, associated_data=None):
        """Encrypt with AES-GCM (authenticated encryption)"""
        nonce = os.urandom(12)  # 96-bit nonce for GCM
        aesgcm = AESGCM(self.key)
        
        ciphertext = aesgcm.encrypt(
            nonce,
            plaintext.encode(),
            associated_data
        )
        
        return nonce + ciphertext
    
    def decrypt(self, ciphertext, associated_data=None):
        """Decrypt with AES-GCM"""
        nonce = ciphertext[:12]
        ct = ciphertext[12:]
        
        aesgcm = AESGCM(self.key)
        plaintext = aesgcm.decrypt(nonce, ct, associated_data)
        
        return plaintext.decode()

# Usage
encryption = SecureEncryption()
encrypted = encryption.encrypt("Sensitive data")
decrypted = encryption.decrypt(encrypted)
```

## 9.2 Secure Password Hashing

```python
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

class SecurePasswordManager:
    def __init__(self):
        self.hasher = PasswordHasher(
            time_cost=3,
            memory_cost=65536,
            parallelism=4
        )
    
    def hash_password(self, password):
        """Hash password securely"""
        return self.hasher.hash(password)
    
    def verify_password(self, stored_hash, password):
        """Verify password against hash"""
        try:
            return self.hasher.verify(stored_hash, password)
        except VerifyMismatchError:
            return False
    
    def needs_rehash(self, stored_hash):
        """Check if hash needs to be updated"""
        return self.hasher.check_needs_rehash(stored_hash)

# Usage
pm = SecurePasswordManager()

# Hash password
hashed = pm.hash_password("user_password")

# Verify password
if pm.verify_password(hashed, "user_password"):
    print("Password verified!")

# Check if rehash needed
if pm.needs_rehash(hashed):
    # Rehash with updated parameters
    new_hash = pm.hash_password("user_password")
    # Update in database
```

## 9.3 Secure TLS Configuration

```python
# Secure TLS configuration for Python requests
import requests
import ssl
from requests.adapters import HTTPAdapter
from urllib3.util.ssl_ import create_urllib3_context

class SecureTLSAdapter(HTTPAdapter):
    def init_poolmanager(self, *args, **kwargs):
        context = create_urllib3_context()
        context.load_default_certs()
        
        # Only allow strong protocols
        context.minimum_version = ssl.TLSVersion.TLSv1_2
        context.maximum_version = ssl.TLSVersion.TLSv1_3
        
        # Disable weak ciphers
        context.set_ciphers(
            'ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM:DHE+CHACHA20'
        )
        
        kwargs['ssl_context'] = context
        return super().init_poolmanager(*args, **kwargs)

# Usage
session = requests.Session()
session.mount('https://', SecureTLSAdapter())
response = session.get('https://target.com')
```

---

# Module 10: Further Reading

## Books and Resources

1. **"Cryptography Engineering"** by Ferguson, Schneier, and Kohno
2. **"Serious Cryptography"** by Jean-Philippe Aumasson
3. **OWASP Cryptographic Failures** - Top 10 vulnerability category
4. **NIST Cryptographic Standards** - FIPS publications

## Practice Platforms

- **Cryptopals** (cryptopals.com) - Cryptography challenges
- **OverTheWire** - Krypton wargame
- **HackTheBox** - Cryptography challenges
- **CryptoHack** - Interactive cryptography learning

## Tools

- **OpenSSL** - TLS/SSL testing
- **Nmap** - SSL enumeration scripts
- **Burp Suite** - SSL/TLS testing
- **testssl.sh** - Comprehensive TLS testing

---

*This learning guide provides a comprehensive foundation for cryptography and data protection security testing. Practice implementing secure cryptographic solutions and stay updated with emerging threats.*

Ensure learning materials are comprehensive, practical, and focused on developing expert-level cryptographic security assessment skills.