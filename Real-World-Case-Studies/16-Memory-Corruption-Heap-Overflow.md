# Case Study 16: Memory Corruption & Heap Overflow — Real-World Bug Bounty Findings

## Expert Role

Memory corruption vulnerabilities represent the most technically demanding and highest-impact class of bugs in modern software security. As a specialist in this domain, you must understand the intricate mechanics of how programs manage memory, how compilers optimize code, and how attackers can manipulate these low-level processes to achieve arbitrary code execution or information disclosure. This expertise spans from traditional C/C++ buffer overflows to modern exploitation techniques that bypass advanced mitigations like ASLR, DEP, and CFI.

The discipline requires deep understanding of operating system internals, CPU architecture, compiler behavior, and exploitation primitives. You need to master concepts like heap metadata manipulation, use-after-free exploitation, type confusion, integer overflow leading to buffer overflow, and format string vulnerabilities. Modern exploitation often involves chaining multiple memory corruption primitives, each providing a small capability that builds toward full system compromise.

Your role encompasses both defensive analysis and offensive testing. You must be able to identify potential memory corruption conditions through code review, fuzzing, and dynamic analysis. Equally important is understanding how these vulnerabilities impact the security model of the application and what an attacker could achieve through exploitation. The ability to develop proof-of-concept demonstrations that safely illustrate the vulnerability without causing harm is essential for effective reporting.

## Overview

Memory corruption vulnerabilities occur when a program inadvertently modifies memory locations in unintended ways. These vulnerabilities have been the dominant class of remotely exploitable bugs for decades, despite significant advances in compiler mitigations and operating system protections. In the context of bug bounty programs, memory corruption findings typically command the highest bounties due to their potential for complete system compromise.

The primary categories of memory corruption include buffer overflows (stack and heap), use-after-free, double-free, integer overflow leading to buffer overflow, format string vulnerabilities, type confusion, and out-of-bounds read/write. Each category has distinct root causes, exploitation techniques, and mitigation strategies.

Modern exploitation of memory corruption vulnerabilities often involves bypassing multiple layers of security mitigations. Address Space Layout Randomization (ASLR) requires information leaks to determine memory locations. Data Execution Prevention (DEP) necessitates return-oriented programming (ROP) or similar techniques. Control Flow Integrity (CFI) limits the available gadgets for code reuse. Understanding these mitigations and their weaknesses is crucial for both exploitation and defense.

The impact of memory corruption vulnerabilities in bug bounty programs varies based on the application context. In browser-based programs, these vulnerabilities can lead to sandbox escape and remote code execution. In server applications, they may enable data exfiltration or denial of service. In mobile applications, they can compromise user devices. The bounty reflects both the severity of the vulnerability and the difficulty of exploitation.

---

## Real-World Case Studies

### Case Study 1: Chrome V8 Engine Type Confusion Leading to RCE
**Program:** Google VRP (Vulnerability Reward Program)
**Bounty:** $150,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @niccokunzmann

**Vulnerability Description:**
The researcher discovered a type confusion vulnerability in Chrome's V8 JavaScript engine that allowed arbitrary memory read/write, ultimately leading to sandbox escape and remote code execution. The vulnerability occurred during optimization of JavaScript array operations.

**Technical Details:**
```javascript
// Proof of concept trigger
function trigger() {
    var a = [1.1, 2.2, 3.3];
    var b = a.slice(0, 2);
    
    // Type confusion: V8 assumes 'b' is a double array
    // but after certain optimizations, it becomes a SMI array
    b[0] = {};  // Object assigned to supposed double array
    
    // Subsequent operations use incorrect type assumptions
    // leading to out-of-bounds access
    return a[b[0]];  // OOB read
}
```

**Root Cause Analysis:**
The vulnerability existed in V8's TurboFan optimizer, which made incorrect assumptions about array types after certain optimization passes. The JIT compiler failed to properly track type information through the `slice` operation, leading to incorrect type specialization. When an object was assigned to what the optimizer believed was a double array, the type information mismatch led to memory corruption.

**Exploitation Chain:**
1. Trigger the type confusion to achieve OOB read/write
2. Use OOB read to leak heap pointers and bypass ASLR
3. Corrupt adjacent heap objects to achieve arbitrary read
4. Read JavaScript function pointers to bypass CFI
5. Construct ROP chain to load and execute test.txt
6. Use file operations to read local files

**Impact Assessment:**
- Complete browser sandbox escape
- Remote code execution on the target system
- Access to user data and system resources
- Potential for persistent compromise through file system access

**Bounty Justification:**
The $150,000 bounty reflected the maximum severity of the vulnerability—a remotely exploitable RCE in a major browser. The exploitation chain demonstrated complete security bypass, affecting all Chrome users on affected platforms.

---

### Case Study 2: OpenSSL Heartbleed (CVE-2014-0160)
**Program:** OpenSSL (Responsible Disclosure)
**Bounty:** N/A (Pre-bug bounty era)
**Severity:** Critical (CVSS 9.8)
**Researchers:** Neel Mehta (Google), Riku, Antti, Matti (Codenomicon)

**Vulnerability Description:**
Heartbleed was a catastrophic buffer over-read vulnerability in OpenSSL's implementation of the TLS heartbeat extension. The vulnerability allowed attackers to read up to 64KB of server memory per request, exposing private keys, session tokens, and other sensitive data.

**Technical Details:**
```c
// Vulnerable code in ssl/d1_both.c and ssl/t1_lib.c
int tls1_process_heartbeat(SSL *s) {
    unsigned char *p = &s->s3->rrec.data[0], *pl;
    unsigned short hbtype;
    unsigned int payload;
    unsigned int padding = 16;  // Minimum padding
    
    // Read heartbeat message type
    hbtype = *p++;
    // Read payload length from client (NO VALIDATION!)
    n2s(p, payload);  // payload = attacker-controlled value
    pl = p;           // p points to payload data
    
    // Allocate buffer based on ACTUAL payload in record
    // NOT the claimed payload length
    // If actual data < claimed length, we read beyond buffer
    unsigned char *buffer = OPENSSL_malloc(1 + 2 + payload + padding);
    *buffer++ = TLS1_HB_RESPONSE;
    s2n(payload, buffer);
    
    // MEMORY OVER-READ: copies 'payload' bytes from 'pl'
    // but only actual_record_length bytes exist
    memcpy(buffer, pl, payload);  // pl points to too little data
}
```

**Root Cause Analysis:**
The vulnerability existed because the heartbeat response handler did not validate that the claimed payload length matched the actual data in the TLS record. The `n2s` macro read a 16-bit value from the client-controlled data without bounds checking. The subsequent `memcpy` used this unchecked value as the copy length, reading beyond the allocated buffer.

**Impact Analysis:**
- Exposure of server private keys
- Session cookies and authentication tokens
- User credentials and personal data
- Internal configuration and API keys
- Affects approximately 17% of all SSL servers (500,000+ servers)

---

### Case Study 3: Windows SMBGhost (CVE-2020-0796)
**Program:** Microsoft (MSRC)
**Bounty:** $100,000
**Severity:** Critical (CVSS 10.0)
**Researcher:** @chompie1337

**Vulnerability Description:**
A buffer overflow vulnerability in Microsoft's SMBv3 protocol implementation allowed remote code execution without authentication. The vulnerability existed in the decompression of SMB packets, enabling attackers to execute arbitrary code on Windows systems.

**Technical Details:**
```c
// Simplified vulnerable code path
NTSTATUS SMBDecompressData(
    PVOID Buffer,
    ULONG BufferLength,
    ULONG OriginalLength
) {
    // Allocate buffer based on OriginalLength (attacker-controlled)
    PVOID DecompressedBuffer = ExAllocatePoolWithTag(
        PagedPool,
        OriginalLength,  // Attacker controls this value
        'mBsM'
    );
    
    // Decompression routine writes data to DecompressedBuffer
    // If OriginalLength is smaller than actual decompressed data,
    // heap buffer overflow occurs
    RtlDecompressBuffer(
        COMPRESSION_FORMAT_SMB2,
        DecompressedBuffer,
        OriginalLength,  // Too small!
        Buffer,
        BufferLength,
        &FinalLength
    );
}
```

**Root Cause Analysis:**
The vulnerability occurred in the SMB decompression routine where the original (uncompressed) length field was attacker-controlled but not validated against the actual compressed data. A compressed packet could claim a small original length while the decompressed data was actually larger, causing a heap buffer overflow.

**Exploitation Chain:**
1. Send specially crafted SMBv3 compression packet
2. Trigger heap overflow to corrupt adjacent heap metadata
3. Use heap grooming to place controlled data adjacent to freed chunks
4. Achieve arbitrary code execution with SYSTEM privileges
5. Install persistence or exfiltrate data

**Impact:**
- Unauthenticated remote code execution
- SYSTEM-level privileges
- Affects Windows 10 and Windows Server versions
- Wormable vulnerability (self-propagating)

**Bounty Justification:**
The $100,000 bounty reflected the wormable nature of the vulnerability—complete system compromise without authentication, affecting millions of Windows systems worldwide.

---

### Case Study 4: Android libwebp Heap Overflow (CVE-2023-4863)
**Program:** Google Android Security
**Bounty:** $75,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @niccokunzmann

**Vulnerability Description:**
A heap buffer overflow in libwebp, the library used for WebP image processing, allowed remote code execution when processing maliciously crafted WebP images. The vulnerability affected multiple platforms including Chrome, Android, Firefox, and numerous other applications.

**Technical Details:**
```c
// Vulnerable code in libwebp/src/dsp/huffman_encode.c
static int StoreImageToCache(VP8LEncoder* const enc) {
    // ...
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            // No bounds checking on cache buffer
            // If width*height exceeds buffer allocation, OOB write occurs
            enc->cache[url->data[x + y * width]]++;
        }
    }
}
```

**Root Cause Analysis:**
The vulnerability was in the Huffman code writer used during WebP encoding. The code did not properly validate that the output buffer had sufficient space for the encoded data. When processing specially crafted WebP images with specific metadata values, the encoding process could write beyond the allocated heap buffer.

**Impact Assessment:**
- Affects all platforms using libwebp (billions of devices)
- Remote code execution through image processing
- Exploitation could occur through web pages, messaging apps, or email
- Cross-platform impact (Chrome, Android, Firefox, etc.)

---

### Case Study 5: Node.js HTTP Request Smuggling via Integer Overflow
**Program:** Node.js (HackerOne)
**Bounty:** $25,000
**Severity:** High (CVSS 8.1)
**Researcher:** @sh2me

**Vulnerability Description:**
An integer overflow vulnerability in Node.js HTTP request parser allowed request smuggling attacks. The vulnerability occurred when parsing extremely large Content-Length headers, causing an integer wrap-around that bypassed size validation.

**Technical Details:**
```javascript
// Simplified vulnerable parsing logic
function parseContentLength(headerValue) {
    // parseInt with large values can cause integer overflow
    const length = parseInt(headerValue, 10);
    
    // On 32-bit systems, values > 2^31 wrap to negative
    // length could be negative or zero after overflow
    if (length < 0) {
        throw new Error('Invalid Content-Length');
    }
    
    // BUG: length > 0 check passes, but actual buffer
    // allocation uses wrapped value
    const buffer = Buffer.alloc(length);  // Allocates small buffer
    // But subsequent read uses original header value
    return readBody(buffer, headerValue);  // Reads too much data
}

// Request with oversized Content-Length
// Content-Length: 99999999999 (wraps on 32-bit)
```

**Root Cause Analysis:**
The vulnerability occurred because the Content-Length parsing used JavaScript numbers which could lose precision for very large values. On 32-bit systems or in certain V8 optimization scenarios, the integer could wrap to a smaller positive value, passing validation while the actual read operation used the original large value.

**Impact:**
- HTTP request smuggling between proxies
- Cache poisoning through malformed requests
- Potential for credential theft through request routing
- Bypass of security controls and WAFs

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Heap buffer overflow | Medium | $50,000-$150,000 | Insufficient bounds checking |
| Use-after-free | Medium | $30,000-$100,000 | Incorrect memory lifecycle |
| Stack buffer overflow | Low | $20,000-$80,000 | Missing bounds validation |
| Integer overflow → buffer overflow | Low | $25,000-$75,000 | Unchecked arithmetic |
| Type confusion | Medium | $40,000-$150,000 | JIT optimization bugs |
| Format string vulnerability | Very Low | $10,000-$50,000 | User input in format strings |
| Out-of-bounds read | Medium | $10,000-$50,000 | Missing bounds validation |
| Double free | Low | $15,000-$60,000 | Incorrect free patterns |

### Attack Surface Locations

**Client-Side Processing:**
- Image parsing libraries (libpng, libjpeg, libwebp)
- PDF rendering engines
- Document parsers (DOCX, XLSX)
- Media codecs (video/audio)
- JavaScript engines (V8, SpiderMonkey)

**Server-Side Processing:**
- HTTP request parsing
- Protocol implementations (TLS, SSH, SMB)
- File format processing
- Serialization/deserialization
- Database query building

**Memory Management:**
- Custom allocators
- Object pools
- Reference counting systems
- Garbage collection interfaces

---

## Hunting Methodology

### Step 1: Identify Attack Surface

Focus on components that process untrusted input:

```
Priority Targets:
1. Image/media processing libraries
2. Protocol implementations (HTTP, TLS, SMB)
3. Document parsing functions
4. Serialization/deserialization code
5. Custom memory allocators

Input Points:
- File uploads
- Network data reception
- User-controlled parameters affecting memory allocation
- Content-Length and other size headers
```

### Step 2: Code Review for Memory Safety

Analyze code patterns that indicate potential vulnerabilities:

**Dangerous Patterns to Look For:**
```c
// Unchecked buffer operations
memcpy(dest, src, user_controlled_size);
strcpy(dest, user_controlled_source);
sprintf(buffer, format, user_data);

// Integer arithmetic without overflow checks
size_t total = count * element_size;  // May overflow
void* ptr = malloc(total);

// Incorrect use of dynamic memory
char* buffer = malloc(1024);
free(buffer);
// ... some code ...
buffer[0] = 'x';  // Use-after-free

// Missing bounds checks
int index = user_input;
array[index] = value;  // No bounds validation
```

### Step 3: Fuzzing Strategy

Deploy targeted fuzzing for identified components:

**Fuzzing Configuration:**
```python
# AFL/libFuzzer seed generation
def generate_seeds():
    seeds = []
    # Boundary values
    for size in [0, 1, 255, 256, 65535, 65536, 2**31-1]:
        seeds.append(generate_input_with_size(size))
    
    # Common corruption patterns
    seeds.append(generate_maximal_input())
    seeds.append(generate_minimal_input())
    
    return seeds
```

**Coverage-Guided Fuzzing Setup:**
```bash
# Compile with sanitizers
clang -fsanitize=fuzzer,address -g target.c -o fuzz_target

# Run with timeout and memory limits
./fuzz_target -max_len=4096 -timeout=10 -rss_limit=2048 corpus/
```

### Step 4: Dynamic Analysis

Use memory debugging tools to identify corruption:

**Valgrind/ASan Usage:**
```bash
# Address Sanitizer (preferred for speed)
./target --asan-options=detect_leaks=1

# Valgrind for detailed analysis
valgrind --tool=memcheck --track-origins=yes ./target

# Thread Sanitizer for data races
./target --tsan-options=history_size=4
```

### Step 5: Exploitation Analysis

For confirmed vulnerabilities, analyze exploitation potential:

**Mitigation Status Assessment:**
```
Check:
- ASLR enabled? (default on modern systems)
- DEP/NX enabled? (default on modern systems)
- Stack canaries? (check with checksec)
- PIE enabled? (position-independent executable)
- RELRO? (read-only relocations)
- CFI? (control flow integrity)
```

---

## Detection Strategies

### Automated Detection

**Static Analysis Pattern Matching:**
```python
VULNERABLE_PATTERNS = [
    r'memcpy\([^,]+,\s*[^,]+,\s*[a-z_0-9]+\)',  # Potential OOB
    r'strcpy\([^,]+,\s*[a-z_0-9]+\)',  # No bounds checking
    r'malloc\([a-z_0-9]+\s*\*\s*[a-z_0-9]+\)',  # Potential overflow
    r'free\([a-z_]+\);\s*\n.*\1\[',  # Use-after-free
]

def scan_source_code(source_file):
    findings = []
    with open(source_file, 'r') as f:
        content = f.read()
    
    for pattern in VULNERABLE_PATTERNS:
        matches = re.finditer(pattern, content, re.MULTILINE)
        for match in matches:
            findings.append({
                'pattern': pattern,
                'line': content[:match.start()].count('\n') + 1,
                'code': match.group()
            })
    
    return findings
```

**Fuzzing Crash Analysis:**
```python
def analyze_crash(crash_file):
    with open(crash_file, 'rb') as f:
        crash_data = f.read()
    
    analysis = {
        'size': len(crash_data),
        'null_bytes': crash_data.count(b'\x00'),
        'high_bytes': sum(1 for b in crash_data if b > 127),
        'entropy': calculate_entropy(crash_data),
    }
    
    return analysis
```

### Manual Detection

**Memory Corruption Testing Checklist:**

1. **Buffer Overflow Indicators**
   - Test maximum length inputs
   - Check for stack canary crashes
   - Monitor heap allocation patterns
   - Test integer overflow conditions

2. **Use-After-Free Indicators**
   - Monitor object lifecycle
   - Test operations after free
   - Check reference counting
   - Analyze garbage collection timing

3. **Integer Overflow Indicators**
   - Test arithmetic with large values
   - Check multiplication overflows
   - Monitor allocation sizes
   - Test signed/unsigned conversions

### Key Detection Indicators

| Indicator | Severity | Exploitation Difficulty |
|-----------|----------|------------------------|
| Heap buffer overflow | Critical | Medium-High |
| Use-after-free | Critical | High |
| Stack buffer overflow | High | Medium |
| Integer overflow | High | Medium-High |
| Out-of-bounds read | Medium-High | Low-Medium |
| Type confusion | Critical | High |

---

## Impact Assessment

### CVSS 3.1 Scoring

**Memory Corruption CVSS Components:**

- **Attack Vector (AV):** Network for remote, Local for local exploitation
- **Attack Complexity (AC):** High for ASLR bypass, Low for straightforward overflows
- **Privileges Required (PR):** None for unauthenticated, Low for authenticated
- **User Interaction (UI):** None for server-side, Required for client-side
- **Scope (S):** Changed when affecting different security context
- **Confidentiality (C):** High for arbitrary read
- **Integrity (I):** High for arbitrary write
- **Availability (A):** High for crash conditions

### Business Impact

Memory corruption vulnerabilities have the highest business impact:

1. **Remote Code Execution:** Complete system compromise
2. **Data Breach:** Access to all data on affected systems
3. **Wormable Vulnerabilities:** Self-propagating attacks
4. **Supply Chain Impact:** Affects all users of vulnerable software
5. **Compliance Violations:** Potential for massive regulatory fines

### Bounty Range

| Vulnerability Type | Typical Range | Factors |
|-------------------|---------------|---------|
| Client-side RCE | $50,000-$150,000+ | Sandbox escape, reliability |
| Server-side RCE | $30,000-$100,000 | Authentication required |
| Information disclosure | $10,000-$50,000 | Data sensitivity |
| Denial of service | $5,000-$25,000 | Service criticality |

---

## Advanced Variations

### Variation 1: Heap Feng Shui

Precise control over heap layout to achieve reliable exploitation:

**Techniques:**
- Heap spraying to fill allocator with controlled data
- Heap grooming to manipulate free list
- Use-after-free with type confusion to achieve arbitrary read/write
- Tcache poisoning on glibc 2.26+

### Variation 2: JIT Spray

Abusing Just-In-Time compilers to create exploitation gadgets:

**Concept:**
```javascript
// JIT compiles to predictable machine code
function spray_jit() {
    var a = 0x3c909090;  // NOP sled instruction
    var b = 0x90909090;
    var c = 0x90909090;
    var d = 0x90909090;
    // Repeated patterns create predictable code layout
}
```

### Variation 3: Return-Oriented Programming (ROP)

Chaining existing code snippets to bypass DEP:

**Techniques:**
- Finding gadgets in program memory
- Building ROP chains for system calls
- Using ROP to enable code execution
- Defeating ASLR through information leaks

### Variation 4: Data-Only Attacks

Exploiting data corruption without code execution:

**Concept:**
- Modifying function pointers in vtables
- Corrupting control data structures
- Abusing type information for type confusion
- Manipulating object metadata

---

## Chain Integration

**Chain 1: Information Leak → Memory Corruption**
Use OOB read to leak addresses, then use OOB write for code execution.

**Chain 2: Integer Overflow → Buffer Overflow**
Integer overflow in size calculation leads to undersized buffer and subsequent overflow.

**Chain 3: Use-After-Free → Type Confusion → RCE**
Free object, reallocate with controlled data, access through original pointer with different type.

**Chain 4: Format String → Information Leak → Memory Corruption**
Use format string to leak addresses, then use for heap exploitation.

---

## Prevention Recommendations

1. **Memory-Safe Languages:** Use Rust, Go, or other memory-safe languages for new development
2. **Bounds Checking:** Implement comprehensive bounds checking on all buffer operations
3. **Compiler Mitigations:** Enable ASLR, DEP, stack canaries, and CFI
4. **Static Analysis:** Integrate static analysis tools in CI/CD pipeline
5. **Fuzzing:** Deploy continuous fuzzing for critical components
6. **Code Review:** Focus code review on memory management patterns
7. **Dependencies:** Keep all dependencies updated with security patches
8. **Sandboxing:** Implement process isolation and sandboxing

---

## Common Pitfalls

1. **Assuming Mitigations Are Sufficient:** Modern mitigations significantly raise the bar but don't eliminate risk
2. **Ignoring Information Leaks:** OOB reads often enable exploitation of OOB writes
3. **Platform Specificity:** Exploitation techniques vary across OS and architecture
4. **Compiler Optimizations:** Optimizations can introduce new vulnerabilities or change exploitation
5. **Timing Dependencies:** Race conditions and timing can affect exploitation reliability
6. **Incomplete Testing:** Not testing all input combinations and edge cases

---

## Real-World References

1. MITRE CWE-119: Buffer Overflow
2. MITRE CWE-416: Use After Free
3. MITRE CWE-190: Integer Overflow
4. Project Zero: https://googleprojectzero.blogspot.com/
5. Phrack Magazine: Memory Corruption Exploitation Techniques
6. BlackHat Archives: Memory Corruption Presentations

---

## Quick Reference Cheat Sheet

**Immediate Report Items:**
- Crash with controlled input (especially with controlled registers)
- ASan/Valgrind reports of memory errors
- Heap metadata corruption
- Stack buffer overflow with controllable return address
- Use-after-free with controlled reallocation

**Essential Tools:**
```bash
# Compilation with sanitizers
gcc -fsanitize=address -g target.c
gcc -fsanitize=undefined -g target.c

# Debugging with GDB
gdb ./target
(gdb) set disable-randomization off
(gdb) run $(python -c 'print("A"*1000)')

# Heap analysis
pwndbg> heap
pwndbg> bins
pwndbg> vis_heap_chunks
```

**Mitigation Check:**
```bash
# Check binary protections
checksec --file=./target

# Expected output for hardened binary:
# RELRO:    Full RELRO
# Stack:    Canary found
# NX:       NX enabled
# PIE:      PIE enabled
# ASLR:     Enabled (system default)
```

**Exploitation Primitive Checklist:**
- [ ] Information leak (heap/stack address)
- [ ] Arbitrary read
- [ ] Arbitrary write
- [ ] Code execution (ROP/JIT)
- [ ] Sandbox escape (if applicable)


---

## Appendix: Exploitation Tools and Techniques

### GDB Exploitation Helper Scripts

```bash
#!/bin/bash
# GDB Helper Script for Memory Corruption Analysis
# Usage: source this script in GDB session

# Enable pagination
set pagination off

# Set up pretty printing
set print pretty on
set print object on
set print array on

# Memory inspection commands
define heap_info
    info proc mappings
    x/20gx $sp
end

define check_canary
    x/1gx ($rbp-8)
end

define find_gadget
    search-pattern $arg0
end

# Register dump
define reg_dump
    info registers
    x/10i $pc
end

# Heap chunk inspection
define heap_chunk
    x/16gx (void*)$arg0-0x10
end

# Set breakpoint on malloc/free
define watch_alloc
    break malloc
    commands
        silent
        printf "malloc(%d)\n", $rdi
        continue
    end
end

define watch_free
    break free
    commands
        silent
        printf "free(%p)\n", $rdi
        continue
    end
end
```

### ASLR Bypass Techniques

```bash
# Information leak via /proc
cat /proc/self/maps | grep libc

# Partial overwrite technique
# Overwrite only least significant bytes of return address
# Low entropy on 32-bit systems makes this feasible

# Return-to-libc without full ASLR bypass
# Use ret2plt to call system() through PLT

#ROP gadget discovery
ROPgadget --binary ./target --ropchain

# ROPgadget search for specific instructions
ROPgadget --binary ./target | grep "pop rdi"
ROPgadget --binary ./target | grep "pop rsi"
ROPgadget --binary ./target | grep "pop rdx"
```

### Heap Exploitation Primitives

```python
#!/usr/bin/env python3
"""
Heap Exploitation Helper Functions
For educational purposes only
"""

class HeapExploitation:
    def __init__(self):
        self.primitives = {}
    
    def calculate_chunk_size(self, request_size):
        """Calculate chunk size for glibc malloc"""
        # Minimum chunk size is 32 bytes (64-bit)
        # Aligned to 16-byte boundary
        chunk_size = max(32, ((request_size + 16 + 15) // 16) * 16)
        return chunk_size
    
    def generate_tcache_poison(self, target_address, value):
        """
        Generate tcache poisoning payload
        Requires: heap overflow to corrupt tcache fd pointer
        """
        payload = {
            'corruption_offset': 'calculate based on heap layout',
            'target_address': target_address,
            'value': value,
            'constraints': [
                'Must control freed chunk metadata',
                'Target address must be 0x10 aligned'
            ]
        }
        return payload
    
    def generate_fastbin_attack(self, target_address):
        """
        Generate fastbin attack payload
        Requires: heap overflow in fastbin-sized chunk
        """
        payload = {
            'target_address': target_address,
            'chunk_size': 'must match fastbin index',
            'steps': [
                'Overflow to corrupt fd pointer',
                'Allocate to get chunk at target-0x10',
                'Target now in free list',
                'Next allocation returns target address'
            ]
        }
        return payload
    
    def calculate_unsorted_bin_offset(self):
        """Calculate offsets for unsorted bin attack"""
        return {
            'main_arena_offset': 'glibc version dependent',
            'bk_offset': 0x10,
            'technique': 'Overwrite bk to write main_arena+88 to target'
        }

# Educational demonstration
if __name__ == '__main__':
    heap = HeapExploitation()
    print("Chunk size for 24 bytes:", heap.calculate_chunk_size(24))
    print("Tcache poison:", heap.generate_tcache_poison(0x602000, 0x41414141))
```

### ROP Chain Construction

```python
#!/usr/bin/env python3
"""
ROP Chain Builder for x86-64 Linux
Educational purposes only
"""

class ROPChainBuilder:
    def __init__(self, binary_path):
        self.binary_path = binary_path
        self.gadgets = []
        self.chain = []
    
    def add_gadget(self, address, description):
        """Add a gadget to the chain"""
        self.gadgets.append({
            'address': address,
            'description': description
        })
    
    def build_execve_chain(self, binsh_address):
        """
        Build execve("/bin/sh", NULL, NULL) chain
        Requires: libc base address leak
        """
        # Simplified example - actual offsets vary by libc version
        chain = [
            # Pop rdi; ret
            'pop_rdi_address',
            binsh_address,  # "/bin/sh" string
            # Pop rsi; ret
            'pop_rsi_address',
            0,  # NULL
            # Pop rdx; ret
            'pop_rdx_address',
            0,  # NULL
            # execve()
            'execve_address'
        ]
        return chain
    
    def build_system_chain(self, command_address):
        """
        Build system(command) chain
        Alternative to execve when /bin/sh not available
        """
        chain = [
            'pop_rdi_address',
            command_address,
            'system_address'
        ]
        return chain
    
    def calculate_padding(self, buffer_offset):
        """Calculate padding to reach return address"""
        return b'A' * buffer_offset
    
    def generate_payload(self):
        """Generate complete exploit payload"""
        # In real exploitation, addresses would be actual gadget addresses
        payload = self.calculate_padding(72)  # Buffer + saved RBP
        payload += self.chain
        return payload

# Example usage (educational)
if __name__ == '__main__':
    builder = ROPChainBuilder('./target')
    print("ROP Chain Builder - Educational Tool")
    print("Requires actual binary analysis for real exploitation")
```

### Memory Corruption Detection Rules (YARA)

```yara
rule Java_Serialization_Magic {
    meta:
        description = "Detects Java serialization magic bytes"
        severity = "high"
        category = "deserialization"
    
    strings:
        $magic = { AC ED 00 05 }
        $magic2 = { AC ED 00 06 }
    
    condition:
        $magic at 0 or $magic2 at 0
}

rule Suspicious_Memory_Operation {
    meta:
        description = "Detects patterns indicating memory corruption"
        severity = "critical"
    
    strings:
        $memcpy = "memcpy" ascii
        $strcpy = "strcpy" ascii
        $sprintf = "sprintf" ascii
        $gets = "gets" ascii
        
    condition:
        any of them
}

rule Heap_Spray_Pattern {
    meta:
        description = "Detects heap spray NOP sled patterns"
        severity = "high"
        category = "exploitation"
    
    strings:
        $nop_sled = { 90 90 90 90 90 90 90 90 }
        $breakpoint = { CC CC CC CC CC CC CC CC }
    
    condition:
        #nop_sled > 4 or #breakpoint > 4
}
```

## Appendix: Mitigation Reference

### Memory Corruption Mitigations Matrix

| Mitigation | Protects Against | Bypass Difficulty | Implementation |
|------------|------------------|-------------------|----------------|
| ASLR | Code injection | Medium | OS default |
| DEP/NX | Stack execution | Medium-High | OS default |
| Stack Canaries | Stack overflow | Medium | Compiler flag |
| PIE | ROP | High | Compiler flag |
| RELRO | GOT overwrite | Medium | Compiler flag |
| CFI | Code reuse | High | Compiler extension |
| MTE | Heap corruption | Very High | Hardware required |

### Compiler Flags Reference

```bash
# GCC/Clang security flags
-fstack-protector-strong    # Stack canaries
-D_FORTIFY_SOURCE=2         # Buffer overflow detection
-fPIE -pie                  # Position independent executable
-Wl,-z,relro,-z,now         # Full RELRO
-fno-delete-null-pointer-checks  # Disable dangerous optimization

# Full hardened compilation
gcc -O2 \
    -fstack-protector-strong \
    -D_FORTIFY_SOURCE=2 \
    -fPIE -pie \
    -Wl,-z,relro,-z,now \
    -o target target.c
```

### Runtime Protection Configuration

```bash
# Linux kernel hardening
echo 1 > /proc/sys/kernel/randomize_va_space  # ASLR
echo 1 > /proc/sys/kernel/dmesg_restrict      # Restrict dmesg
echo 1 > /proc/sys/kernel/kptr_restrict        # Restrict kernel pointers

# Environment variables
export LD_BIND_NOW=1        # Force immediate binding
export MALLOC_CHECK_=3      # Enable malloc checking
```

## Appendix: Further Reading

### Essential Books
1. "The Art of Exploitation" by Jon Erickson
2. "Hacking: The Art of Exploitation" by Jon Erickson
3. "Practical Binary Analysis" by Dennis Andriesse
4. "The Shellcoder's Handbook" by Chris Anley

### Online Resources
1. Exploit Education: https://exploit.education/
2. ROP Emporium: https://ropemporium.com/
3. pwnable.kr: https://pwnable.kr/
4. OverTheWire Wargames: https://overthewire.org/wargames/

### Research Papers
1. "Smashing the Stack for Fun and Profit" - Aleph One
2. "The Geometry of Innocent Flesh on the Bone" - Hovav Shacham
3. "Jump-Oriented Programming" - Bletsch et al.
4. "SOCK: Combining ASLR and Compiler-level Defense" - Giuffrida et al.

