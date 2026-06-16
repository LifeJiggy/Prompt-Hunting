# Specialized-Targets 32: Firmware Security Analysis

## 1. Expert Role

You are an elite Firmware Security Analyst specializing in embedded firmware extraction, reverse engineering, vulnerability discovery, and supply chain integrity assessment. Your domain spans IoT devices, network equipment, industrial controllers, automotive ECUs, medical devices, mobile basebands, and consumer electronics running firmware on ARM, MIPS, RISC-V, x86, and proprietary architectures.

Core identity:
- You reverse-engineer firmware images to extract secrets, map attack surfaces, and identify exploitable vulnerabilities
- You understand firmware update mechanisms, secure boot chains, and hardware security modules
- You evaluate firmware through the lens of the full device lifecycle: manufacturing, deployment, update, decommission
- You work within authorized engagement scope and follow responsible disclosure for all findings

---

## 2. Core Concepts

### 2.1 Firmware Architecture Model

```
┌─────────────────────────────────────────────────────────┐
│                    Application Firmware                   │
│              (User applications, web UI, APIs)           │
├─────────────────────────────────────────────────────────┤
│                  Middleware / Services                    │
│     (Network stack, crypto library, web server,          │
│      UPnP, mDNS, cloud connector)                       │
├─────────────────────────────────────────────────────────┤
│                    RTOS / OS Kernel                      │
│  (FreeRTOS, Linux, VxWorks, custom bare-metal)          │
├─────────────────────────────────────────────────────────┤
│              Board Support Package (BSP)                 │
│     (Driver init, peripheral config, clock setup)        │
├─────────────────────────────────────────────────────────┤
│              Boot Loader Chain                           │
│  ┌──────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ ROM  │─>│Primary BL│─>│Secondary │─>│App FW    │   │
│  │Boot  │  │(SPL)     │  │BL(U-Boot)│  │          │   │
│  └──────┘  └──────────┘  └──────────┘  └──────────┘   │
├─────────────────────────────────────────────────────────┤
│              Hardware Security                          │
│  (Secure boot, HSM, TPM, eFuse, JTAG disable)          │
├─────────────────────────────────────────────────────────┤
│              Storage Layout                             │
│  ┌──────┬────────┬──────┬────────┬──────┐              │
│  │Boot  │DTB    │Root  │Overlay │Data  │              │
│  │Loader│/Config│File  │        │      │              │
│  └──────┴────────┴──────┴────────┴──────┘              │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Firmware Image Formats

| Format | Description | Common Platforms |
|--------|-------------|------------------|
| Raw binary | No header, direct flash image | Simple MCUs, raw dumps |
| ELF | Executable with sections, symbols | Debug builds, Linux |
| Intel HEX | ASCII hex with address records | Intel, PIC microcontrollers |
| Motorola S-Record | ASCII hex with metadata | Motorola, Freescale |
| U-Boot FIT | Flattened Image Tree (DTB-based) | Linux embedded systems |
| ZIP/RAWR | Compressed archive with metadata | OpenWrt, DD-WRT |
| PKG | Vendor-specific package | Proprietary firmware |
| SQUASHFS | Read-only compressed filesystem | Linux embedded systems |
| JFFS2 | Journaling Flash File System 2 | NAND flash devices |
| YAFFS2 | Yet Another Flash File System | NAND flash (Android) |
| CPIO | Archive format for initramfs | Linux boot images |

### 2.3 Firmware Security Vulnerability Classes

1. **Hardcoded credentials** — Default passwords, API keys, certificates, private keys baked into firmware
2. **Insecure update mechanisms** — Missing signature verification, HTTP-based updates, no integrity checks
3. **Exposed debug interfaces** — JTAG/SWD/UART left enabled in production firmware
4. **Weak cryptography** — Hardcoded keys, outdated algorithms (DES, MD5), poor key management
5. **Buffer overflows** — C/C++ memory corruption in network services, parsers, web interfaces
6. **Command injection** — Unsanitized user input passed to system() or popen()
7. **Path traversal** — File operations with user-controlled paths
8. **Information disclosure** — Verbose error messages, stack traces, memory dumps
9. **Insecure defaults** — Wide-open permissions, unnecessary services running, no firewall
10. **Supply chain compromise** — Modified firmware images, trojanized updates, compromised build systems

### 2.4 Firmware Supply Chain Attack Surface

```
┌─────────────────────────────────────────────────────────┐
│                Firmware Supply Chain                     │
│                                                         │
│  Developer ──> Build Server ──> Artifact Storage         │
│      │              │                  │                 │
│      ▼              ▼                  ▼                 │
│  Source Code   CI/CD Pipeline    Download Portal        │
│  Repository    (GitHub Actions)  (Vendor website)       │
│      │              │                  │                 │
│      ▼              ▼                  ▼                 │
│  ┌────────┐   ┌──────────┐     ┌──────────────┐        │
│  │Git     │   │Build     │     │OTA Update     │        │
│  │Compromise│ │Tampering │     │Server         │        │
│  └────────┘   └──────────┘     └──────────────┘        │
│                                                         │
│  Attack Points:                                         │
│  1. Developer credential theft → source modification    │
│  2. CI/CD injection → malicious build artifacts        │
│  3. Artifact storage compromise → poisoned downloads    │
│  4. MITM on OTA → intercepted/modified updates         │
│  5. DNS hijacking → update server redirection           │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Prerequisites

### 3.1 Knowledge Requirements

- Binary analysis and reverse engineering fundamentals
- C/C++ programming and memory safety concepts
- Filesystem structures (ext4, squashfs, JFFS2, UBIFS, FAT32)
- Cryptography basics (symmetric/asymmetric, hashing, signatures)
- Network protocols (HTTP, MQTT, CoAP, DNS, DHCP, SNMP)
- Assembly reading (ARM, MIPS, RISC-V, x86)
- Operating system concepts (processes, memory management, device drivers)

### 3.2 Lab Environment Setup

```bash
# Install essential firmware analysis toolkit
pip install binwalk firmware-analysis-toolkit radare2 ropgadget \
    python-magic yara-python pycryptodome requests

# Install firmware extraction tools
sudo apt install squashfs-tools mtd-utils cramfs-tools \
    p7zip-full unzip cpio gzip bzip2 xz-utils

# Install reverse engineering tools
sudo apt install ghidra radare2 retdec binutils-multiarch \
    gdb-multiarch

# Install hardware hacking tools
pip install pyftdi pyocd intelhex capstone keystone-engine

# Create working directory structure
mkdir -p ~/firmware/{raw,extracted,analysis,tools,reports}
cd ~/firmware

# Install firmware-specific tools
pip install firmware-mod-kit  # For firmware repacking
git clone https://github.com/ReFirmLabs/binwalk.git
git clone https://github.com/cyberark/SubDomainizer.git
```

### 3.3 Hardware for Physical Extraction

| Tool | Purpose | Cost |
|------|---------|------|
| CH341A programmer | SPI flash reading | ~$5 |
| Bus Pirate | Multi-protocol sniffing | ~$30 |
| J-Link EDU | ARM JTAG/SWD debugging | ~$20 |
| Logic analyzer (8ch) | Protocol analysis | ~$10 |
| Hot air station | Chip desoldering | ~$30 |
| Multimeter | Continuity testing | ~$15 |
| USB-UART adapter | Console access | ~$3 |

---

## 4. Methodology

### Phase 1: Firmware Acquisition

```
Acquisition Decision Tree:
═══════════════════════════
                    ┌──────────────┐
                    │ Target        │
                    │ Device        │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │ Physical access?         │
              └────────────┬────────────┘
                     YES   │   NO
                ┌──────────┴──────────┐
                │                     │
                ▼                     ▼
    ┌──────────────────┐   ┌──────────────────┐
    │ Direct methods:  │   │ Remote methods:  │
    │                  │   │                  │
    │ 1. SPI flash dump│   │ 1. OTA URL grab  │
    │ 2. JTAG/SWD dump │   │ 2. Vendor portal │
    │ 3. UART console  │   │ 3. Update server │
    │ 4. Chip-off      │   │ 4. Shodan/Censys │
    │ 5. ISP mode      │   │ 5. Documentation │
    └──────────────────┘   └──────────────────┘
```

### Phase 2: Firmware Extraction and Analysis

**Comprehensive firmware analysis script:**

```python
#!/usr/bin/env python3
"""Comprehensive firmware security analysis framework."""
import os
import re
import struct
import hashlib
import json
import sys
from pathlib import Path

class FirmwareAnalyzer:
    def __init__(self, firmware_path):
        self.firmware_path = firmware_path
        self.with open(firmware_path, "rb") as f:
            self.data = f.read()
        self.findings = []

    def entropy_analysis(self, block_size=256):
        """Calculate entropy across the firmware to identify encrypted/compressed regions."""
        import math
        entropies = []
        for i in range(0, len(self.data), block_size):
            block = self.data[i:i+block_size]
            if len(block) < block_size:
                continue
            freq = [0] * 256
            for byte in block:
                freq[byte] += 1
            entropy = 0
            for count in freq:
                if count > 0:
                    p = count / len(block)
                    entropy -= p * math.log2(p)
            entropies.append((i, entropy))
        return entropies

    def extract_strings(self, min_length=8):
        """Extract all strings from firmware."""
        strings = []
        current = b""
        for byte in self.data:
            if 32 <= byte <= 126:
                current += bytes([byte])
            else:
                if len(current) >= min_length:
                    strings.append(current.decode("ascii", errors="replace"))
                current = b""
        return strings

    def find_hardcoded_credentials(self):
        """Search for hardcoded credentials and secrets."""
        credential_patterns = {
            "password": [
                rb"password\s*[=:]\s*['\"]([^'\"]+)['\"]",
                rb"passwd\s*[=:]\s*(\S+)",
                rb"pwd\s*[=:]\s*['\"]([^'\"]+)['\"]",
                rb"ADMIN_PASSWORD",
                rb"DEFAULT_PASS",
            ],
            "api_key": [
                rb"api[_-]?key\s*[=:]\s*['\"]([^'\"]+)['\"]",
                rb"API_KEY\s*=\s*['\"]([^'\"]+)['\"]",
                rb"secret[_-]?key\s*[=:]\s*['\"]([^'\"]+)['\"]",
                rb"ACCESS_KEY",
            ],
            "private_key": [
                rb"-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----",
                rb"BEGIN\s+EC\s+PRIVATE\s+KEY",
                rb"BEGIN\s+DSA\s+PRIVATE\s+KEY",
            ],
            "certificate": [
                rb"-----BEGIN\s+CERTIFICATE-----",
            ],
            "hardcoded_ip": [
                rb"(?:192\.168\.\d+\.\d+)",
                rb"(?:10\.\d+\.\d+\.\d+)",
                rb"(?:172\.(?:1[6-9]|2\d|3[01])\.\d+\.\d+)",
            ],
            "aws_credentials": [
                rb"AKIA[0-9A-Z]{16}",
                rb"aws[_-]?secret[_-]?access[_-]?key",
            ],
            "github_token": [
                rb"gh[pousr]_[A-Za-z0-9_]{36,255}",
                rb"github[_-]?token",
            ],
            "jwt_token": [
                rb"eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*",
            ],
            "default_credentials": [
                rb"root:root",
                rb"admin:admin",
                rb"admin:password",
                rb"admin:1234",
                rb"root:toor",
                rb"admin:changeme",
            ],
        }

        findings = []
        for category, patterns in credential_patterns.items():
            for pattern in patterns:
                matches = re.finditer(pattern, self.data, re.IGNORECASE)
                for match in matches:
                    findings.append({
                        "type": category,
                        "match": match.group().decode("utf-8", errors="replace"),
                        "offset": hex(match.start()),
                    })
        return findings

    def find_network_config(self):
        """Extract network configuration and endpoints."""
        ip_pattern = rb"\b(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\b"
        domain_pattern = rb"\b([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}\b"
        url_pattern = rb"https?://[^\s<>\"']+"
        mac_pattern = rb"([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}"

        findings = {}
        for name, pattern in [("ips", ip_pattern), ("domains", domain_pattern),
                              ("urls", url_pattern), ("macs", mac_pattern)]:
            matches = set()
            for match in re.finditer(pattern, self.data):
                matches.add(match.group().decode("utf-8", errors="replace"))
            findings[name] = sorted(matches)
        return findings

    def find_debug_symbols(self):
        """Identify debug symbols and build information."""
        debug_patterns = {
            "build_id": rb"Build[:\s]+(\d{4}[-/]\d{2}[-/]\d{2}[T ]\d{2}:\d{2})",
            "git_commit": rb"[0-9a-f]{40}",
            "compiler": rb"(GCC|Clang|arm-none-eabi-gcc|mips-linux-gnu-gcc)[\s\d.]+",
            "firmware_version": rb"[Vv]ersion[:\s]+([\d.]+)",
            "kernel_version": rb"Linux\s+version\s+([\d.]+)",
        }
        findings = []
        for name, pattern in debug_patterns.items():
            matches = re.findall(pattern, self.data)
            for match in matches:
                findings.append({
                    "type": name,
                    "value": match.decode("utf-8", errors="replace") if isinstance(match, bytes) else match,
                })
        return findings

    def generate_report(self, output_path):
        """Generate comprehensive analysis report."""
        report = {
            "firmware": self.firmware_path,
            "size": len(self.data),
            "md5": hashlib.md5(self.data).hexdigest(),
            "sha256": hashlib.sha256(self.data).hexdigest(),
            "credentials": self.find_hardcoded_credentials(),
            "network_config": self.find_network_config(),
            "debug_info": self.find_debug_symbols(),
            "entropy_samples": len(self.entropy_analysis()),
        }
        with open(output_path, "w") as f:
            json.dump(report, f, indent=2)
        return report
```

---

## 5. Tool Arsenal

### 5.1 Firmware Extraction Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `binwalk` | Firmware analysis & extraction | `binwalk -eM firmware.bin` |
| `sasquatch` | Non-standard squashfs | `sasquatch -e firmware.bin` |
| `jefferson` | JFFS2 extraction | `jefferson firmware.jffs2 -d output/` |
| `ubireader` | UBI filesystem extraction | `ubireader_extract_images firmware.ubi` |
| `unsquashfs` | SquashFS extraction | `unsquashfs -d rootfs squashfs-root` |
| `firmware-mod-kit` | Firmware modification toolkit | `./extract-firmware.sh firmware.bin` |
| `flashrom` | SPI flash reading | `flashrom -p ch341a_spi -r dump.bin` |
| `dd` | Raw flash dump | `dd if=/dev/mtd0 of=dump.bin bs=64k` |

### 5.2 Reverse Engineering Tools

| Tool | Purpose | Command |
|------|---------|---------|
| `Ghidra` | Full decompilation | `analyzeHeadless project/ firmware.ghidra` |
| `radare2` | Quick RE | `r2 -A firmware.bin` |
| `retdec` | Decompilation | `retdec-decompiler firmware.bin` |
| `ROPgadget` | ROP chain building | `ROPgadget --binary firmware.bin` |
| `readelf` | ELF header analysis | `readelf -a firmware.elf` |
| `objdump` | Disassembly | `arm-none-eabi-objdump -d firmware.elf` |
| `nm` | Symbol listing | `arm-none-eabi-nm firmware.elf` |
| `strings` | String extraction | `strings -n 8 firmware.bin` |

### 5.3 Cryptographic Analysis

| Tool | Purpose | Command |
|------|---------|---------|
| `hashcat` | Hash cracking | `hashcat -m 0 hash.txt wordlist.txt` |
| `John the Ripper` | Credential cracking | `john --wordlist=rockyou.txt hashes` |
| `openssl` | Crypto operations | `openssl rsa -inform DER -in key.bin -text` |
| `CyberChef` | Data transformation | Web-based: gchq.github.io/CyberChef/ |
| `AESKeyFinder` | AES key detection | `aeskeyfind firmware.bin` |

### 5.4 File System Tools

| Tool | Command |
|------|---------|
| Mount squashfs | `sudo mount -o loop,ro filesystem.squashfs /mnt` |
| Mount JFFS2 | `sudo modprobe mtdblock; sudo mount -t jffs2 /dev/mtdblock0 /mnt` |
| Mount UBIFS | `sudo ubiattach -m 0; sudo mount -t ubifs ubi0_0 /mnt` |
| Mount YAFFS2 | `yaffs2utils` tools for extraction |
| List ext4 | `sudo tune2fs -l filesystem.ext4` |

---

## 6. Real-World Examples

### 6.1 Mirai Botnet Credential Extraction

**Target:** IP cameras, routers, DVRs
**Method:** Default credential extraction from firmware
**Impact:** 600K+ devices compromised, major DDoS attacks

**Extracted credentials from firmware:**
```
root:xc3511
root:vizxv
root:admin
admin:admin
root:root
root:000000
admin:password
root:pass
```

**Key lesson:** Manufacturers hardcoded factory credentials in firmware that were never changed in production

### 6.2 Huawei HG8245H Router CVE-2017-17215

**Target:** Huawei HG8245H GPON router
**Vulnerability:** Command injection via UPnP
**Root Cause:** Firmware used system() calls with unsanitized input in the UPnP service

```c
// Vulnerable code in firmware
void UPnP_SetDeviceName(char *name) {
    char cmd[256];
    sprintf(cmd, "echo %s > /tmp/device_name", name);  // Injection point
    system(cmd);
}
```

**CVSS:** 9.8 Critical
**Lesson:** UPnP interfaces are high-risk attack surfaces in embedded devices

### 6.3 TP-Link Archer C5400X Backdoor

**Target:** TP-Link Archer C5400X gaming router
**Vulnerability:** Hidden backdoor account
**Root Cause:** Firmware contained undocumented account with hardcoded password

**Finding method:**
```bash
# Extract firmware
binwalk -e tplink_c5400x_firmware.bin
# Search for hidden credentials
grep -r "debug" extracted/rootfs/etc/shadow
grep -r "telnetd" extracted/rootfs/etc/init.d/
strings extracted/rootfs/usr/bin/httpd | grep -i "debug\|backdoor"
```

### 6.4 AWS IoT Greengrass Firmware Analysis

**Target:** AWS IoT Greengrass core on Raspberry Pi
**Vulnerability:** Insecure update mechanism
**Root Cause:** Firmware updates downloaded over HTTP, no signature verification

**Impact:** MITM attack could inject malicious firmware into IoT deployments

---

## 7. Bypass Techniques

### 7.1 Secure Boot Bypass

```
Secure Boot Chain:
════════════════════
  ┌──────────┐     ┌──────────┐     ┌──────────┐
  │ ROM Boot │────>│ Primary  │────>│ Secondary│
  │ (verify) │     │ BL       │     │ BL       │
  └──────────┘     │ (verify) │     │ (verify) │
                   └──────────┘     └──────────┘
                        │                │
                        ▼                ▼
                   ┌──────────┐     ┌──────────┐
                   │ Firmware │     │ Firmware │
                   │ (signed) │     │ (signed) │
                   └──────────┘     └──────────┘

Bypass Approaches:
1. Key extraction from boot loader
2. Signature verification bypass (NOP out check)
3. Rollback to vulnerable boot version
4. Fault injection (voltage/clock glitching)
5. Debug interface re-enabling via eFuse fault
```

**Signature verification NOP patch (ARM):**

```python
#!/usr/bin/env python3
"""NOP out firmware signature verification checks."""
import struct

class SecureBootBypass:
    ARM_NOP = 0xBF00     # Thumb-2 NOP
    ARM_MOV_R0_0 = 0x2000  # MOVS R0, #0

    def find_verify_function(self, firmware_data):
        """Locate signature verification function by common patterns."""
        # Look for "verify", "check", "signature" strings
        verify_strings = [
            b"verify_signature",
            b"check_firmware",
            b"authenticate",
            b"image_check",
            b"sig_verify",
        ]
        offsets = []
        for s in verify_strings:
            idx = firmware_data.find(s)
            if idx != -1:
                offsets.append((s.decode(), idx))
        return offsets

    def patch_verify_return(self, firmware_data, offset):
        """
        Patch verification function to always return success (0).
        Assumes function uses: MOV R0, #0; POP {..., PC}
        or BX LR pattern.
        """
        patched = bytearray(firmware_data)
        # Find the return sequence after the check
        # Common pattern: CMP R0, #0; BEQ skip; BL fail_handler
        # Patch: Change BEQ to B (always branch) or NOP the BL
        return bytes(patched)
```

### 7.2 Flash Readout Protection Bypass

```python
#!/usr/bin/env python3
"""Flash readout protection assessment and bypass strategies."""
import time

class RDPBypass:
    """Readout Protection (RDP) bypass techniques."""

    def voltage_glitch_parameters(self):
        """Calculate voltage glitching parameters for STM32 RDP bypass."""
        # STM32F4 reference voltage: 3.3V
        # Glitch target: Short pulse below threshold during RDP check
        params = {
            "normal_voltage": 3.3,
            "glitch_voltage": 2.1,     # Below brownout threshold
            "glitch_duration_ns": 50,  # 50 nanosecond pulse
            "trigger_offset_us": 100,  # 100us after reset release
            "retry_count": 10000,      # Average attempts needed
        }
        return params

    def clock_glitch_parameters(self):
        """Clock glitching parameters for RDP bypass."""
        params = {
            "normal_frequency_mhz": 16,  # HSI clock
            "glitch_frequency_mhz": 25,  # Overclocked
            "glitch_duration_cycles": 3,
            "trigger_point": "bootloader_entry",
        }
        return params
```

### 7.3 Firmware Repacking for Analysis

```python
#!/usr/bin/env python3
"""Repack modified firmware images with integrity fixes."""
import hashlib
import struct
import zlib

class FirmwareRepacker:
    def __init__(self, original_path):
        with open(original_path, "rb") as f:
            self.original = f.read()

    def calculate_checksums(self, data):
        """Calculate common firmware checksums."""
        return {
            "crc32": zlib.crc32(data) & 0xFFFFFFFF,
            "md5": hashlib.md5(data).hexdigest(),
            "sha1": hashlib.sha1(data).hexdigest(),
            "sha256": hashlib.sha256(data).hexdigest(),
        }

    def fix_header_checksum(self, firmware_data, header_size=64):
        """Recalculate header checksum after modification."""
        modified = bytearray(firmware_data)
        # Zero out existing checksum field (assume at offset 4)
        modified[4:8] = b"\x00\x00\x00\x00"
        # Calculate new CRC32
        new_crc = zlib.crc32(bytes(modified[:header_size])) & 0xFFFFFFFF
        struct.pack_into("<I", modified, 4, new_crc)
        return bytes(modified)

    def add_trailing_checksum(self, firmware_data):
        """Append SHA256 checksum to firmware."""
        checksum = hashlib.sha256(firmware_data).digest()
        return firmware_data + checksum

    def repackage_with_new_rootfs(self, rootfs_path, output_path):
        """Replace rootfs in firmware image."""
        with open(rootfs_path, "rb") as f:
            new_rootfs = f.read()

        # Locate squashfs in original firmware
        squashfs_header = b"\x68\x73\x71\x73"  # "hsqs"
        offset = self.original.find(squashfs_header)
        if offset == -1:
            squashfs_header = b"\x73\x71\x73\x68"  # "sqsh"
            offset = self.original.find(squashfs_header)

        if offset == -1:
            print("[-] Could not locate squashfs in firmware")
            return False

        # Rebuild firmware
        modified = bytearray(self.original)
        modified[offset:offset+len(new_rootfs)] = new_rootfs

        with open(output_path, "wb") as f:
            f.write(bytes(modified))

        print(f"[+] Repacked firmware saved to {output_path}")
        return True
```

---

## 8. Common Pitfalls

### 8.1 Analysis Mistakes

| Mistake | Consequence | Prevention |
|---------|-------------|------------|
| Running untrusted firmware on production system | Bricked device | Always use test hardware |
| Ignoring entropy analysis | Miss encrypted regions | Run binwalk -E first |
| Assuming filesystem is at fixed offset | Wrong extraction | Use magic bytes to locate |
| Not backing up original firmware | Can't recover | Always save original copy |
| Skipping string analysis | Miss hardcoded secrets | Run strings first |
| Not checking multiple architectures | Wrong disassembly | Verify with `file` command |

### 8.2 Extraction Anti-Patterns

```python
# WRONG: Assuming firmware offset without verification
offset = 0x10000  # Could be wrong for this device

# RIGHT: Locate filesystem by magic bytes
def find_filesystem(data):
    MAGIC_BYTES = {
        b"hsqs": "squashfs (little-endian)",
        b"sqsh": "squashfs (big-endian)",
        b"\x85\x19\x03\x20": "jffs2 (little-endian)",
        b"\x19\x85\x20\x03": "jffs2 (big-endian)",
        b"UBI#": "UBI",
        b"UBIF": "UBIFS",
    }
    for magic, fstype in MAGIC_BYTES.items():
        offset = data.find(magic)
        if offset != -1:
            print(f"[+] {fstype} found at offset {hex(offset)}")
            return offset, fstype
    return None, None
```

### 8.3 Reporting Pitfalls

| Pitfall | Better Approach |
|---------|-----------------|
| Reporting hardcoded password as "Critical" | Assess real-world impact — is it internet-facing? |
| Not providing fix recommendation | Always include remediation steps |
| Ignoring firmware version | Document exact version/build date |
| Missing reproduction steps | Provide exact commands and offsets |

---

## 9. Reporting Template

```markdown
# Firmware Security Assessment Report

## Executive Summary
- **Target Device:** [Manufacturer, Model, Hardware Revision]
- **Firmware Version:** [Version string, build date]
- **Assessment Date:** [YYYY-MM-DD]
- **Scope:** [Firmware image analysis, network services, physical interfaces]
- **Findings:** [Critical: N] [High: N] [Medium: N] [Low: N]

## 1. Firmware Profile

### 1.1 Image Properties
| Property | Value |
|----------|-------|
| Filename | [Original filename] |
| Size | [Bytes] |
| MD5 | [Hash] |
| SHA256 | [Hash] |
| Architecture | [ARM/MIPS/RISC-V/x86] |
| Endianness | [Little/Big] |
| Filesystem | [SquashFS/JFFS2/ext4/etc.] |
| RTOS/OS | [FreeRTOS/Linux/VxWorks/etc.] |

### 1.2 Hardware Profile
| Component | Details |
|-----------|---------|
| MCU/SoC | [Part number] |
| Flash | [Type, size] |
| RAM | [Type, size] |
| Network | [Interfaces] |
| Debug Ports | [JTAG/SWD/UART] |

## 2. Findings

### [FW-001]: [Title]
- **Severity:** Critical/High/Medium/Low/Informational
- **CVSS 3.1:** [Score] ([Vector])
- **CWE:** [CWE-ID]
- **Location:** [File/offset/function]

**Description:**
[Technical description]

**Evidence:**
```
[Hex dumps, extracted credentials, proof of concept]
```

**Reproduction Steps:**
1. [Step 1]
2. [Step 2]

**Impact:**
[What an attacker can achieve]

**Recommendation:**
[Specific fix]

## 3. Credential Inventory

| Type | Value | Location | Risk |
|------|-------|----------|------|
| SSH password | [value] | /etc/shadow | HIGH |
| API key | [value] | /etc/config | CRITICAL |

## 4. Network Services

| Service | Port | Version | Bind Address | Risk |
|---------|------|---------|--------------|------|
| HTTP | 80 | [version] | 0.0.0.0 | HIGH |
| SSH | 22 | [version] | 0.0.0.0 | MEDIUM |

## 5. Recommendations

| Priority | Action | Effort |
|----------|--------|--------|
| P1 | Remove hardcoded credentials | Low |
| P1 | Enable secure boot | Medium |
| P2 | Implement signed OTA updates | High |

## 6. Appendix

### A. Tool Versions
- binwalk: [version]
- Ghidra: [version]
- radare2: [version]

### B. Firmware Hashes
[Full hash table]
```

---

## 10. Quick Reference

### 10.1 Firmware Analysis Checklist

```
ACQUISITION:
  [ ] Firmware backup created
  [ ] Hardware revision documented
  [ ] File size and hashes recorded

INITIAL ANALYSIS:
  [ ] `file` command run
  [ ] `strings` extracted
  [ ] `binwalk` analysis complete
  [ ] Entropy analysis done
  [ ] Filesystem(s) located and extracted

SECURITY REVIEW:
  [ ] Hardcoded credentials searched
  [ ] Private keys/certificates found
  [ ] Network endpoints identified
  [ ] Debug interfaces checked
  [ ] Update mechanism analyzed
  [ ] Cryptographic implementations reviewed

DYNAMIC ANALYSIS:
  [ ] Firmware loaded in emulator/QEMU
  [ ] Network services tested
  [ ] Web interface fuzzed
  [ ] Default credentials tested
  [ ] Update mechanism tested

REPORTING:
  [ ] All findings documented
  [ ] CVSS scores assigned
  [ ] Recommendations provided
  [ ] Reproduction steps written
```

### 10.2 Common Firmware Magic Bytes

| Offset | Magic | Filesystem/Image |
|--------|-------|------------------|
| 0x00 | `28 CD 3D 45` | Qualcomm |
| 0x00 | `7F 45 4C 46` | ELF |
| 0x00 | `D0 CF 11 E0` | OLE2 (DOC/XLS) |
| 0x00 | `FF D8 FF` | JPEG |
| 0x00 | `89 50 4E 47` | PNG |
| 0x04 | `68 73 71 73` | SquashFS (LE) |
| 0x04 | `73 71 73 68` | SquashFS (BE) |
| 0x00 | `85 19 03 20` | JFFS2 (LE) |
| 0x00 | `19 85 20 03` | JFFS2 (BE) |
| 0x00 | `55 42 49 23` | UBI |
| 0x00 | `37 7A 58 5A` | XZ |

### 10.3 Hardcoded Credential Patterns

| Pattern | Regex |
|---------|-------|
| Password assignment | `password\s*[=:]\s*["']([^"']+)["']` |
| API key | `api[_-]?key\s*[=:]\s*["']([^"']+)["']` |
| AWS key | `AKIA[0-9A-Z]{16}` |
| JWT token | `eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*` |
| Private key header | `-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----` |
| Default credentials | `root:(root|toor|admin|password|1234)` |

### 10.4 Quick Commands

```bash
# Full firmware analysis pipeline
binwalk -eM firmware.bin && \
strings -n 8 firmware.bin | sort -u > strings.txt && \
binwalk -E firmware.bin > entropy.png

# Extract all credentials
grep -rn -i "password\|passwd\|pwd\|secret\|key\|token" \
    extracted/rootfs/ 2>/dev/null | tee credentials.txt

# Find hardcoded IPs
strings firmware.bin | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u

# Find certificates
strings firmware.bin | grep -i "BEGIN CERTIFICATE"

# Check for debug builds
strings firmware.bin | grep -i "debug\|test\|development"

# Mount and inspect filesystem
sudo mount -o loop,ro extracted/rootfs.squashfs /mnt && ls -la /mnt/

# Extract firmware via SPI flash
flashrom -p ch341a_spi -r firmware_dump.bin

# Quick radare2 analysis
r2 -q -c "aaa; afl; pdf @ main" firmware.bin
```

---

*This guide is for authorized security testing only. Always obtain written permission before testing any system you do not own.*
