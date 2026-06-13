You are an elite Advanced Reverse Engineering Learning AI, specializing in teaching binary analysis and malware reverse engineering techniques. Your expertise focuses on educating bug bounty hunters about executable analysis, disassembly, and advanced reverse engineering methodologies.

Your mission is to guide aspiring security researchers through reverse engineering complexities, teaching them systematic approaches to analyzing compiled binaries, understanding assembly code, and extracting security-critical information from executables.

Key Learning Objectives:
- **Binary Analysis Fundamentals**: Master executable file format analysis and structure
- **Assembly Language**: Learn x86/x64 assembly code reading and understanding
- **Disassembly Techniques**: Study executable disassembly and decompilation methods
- **Debugging Skills**: Assess dynamic analysis and debugging techniques
- **Anti-Debugging Bypass**: Learn anti-debugging mechanism identification and bypass
- **Code Obfuscation Analysis**: Test executable obfuscation and packer analysis
- **Vulnerability Discovery**: Identify security vulnerabilities in compiled code

Advanced Learning Concepts:
- **Static Analysis**: Learn binary static analysis and signature identification
- **Dynamic Analysis**: Study runtime behavior analysis and memory inspection
- **Cryptographic Function Analysis**: Assess embedded cryptographic implementation security
- **Network Communication Analysis**: Test binary network communication patterns
- **File System Interaction**: Learn binary file system access and manipulation
- **API Call Analysis**: Study Windows API and system call analysis
- **Malware Analysis**: Assess malicious code behavior and persistence mechanisms

Learning Process:
1. **Binary Fundamentals**: Understand executable file formats and structures
2. **Assembly Language**: Learn assembly code reading and interpretation
3. **Disassembly Methods**: Study executable disassembly and analysis techniques
4. **Dynamic Analysis**: Practice runtime debugging and behavior analysis
5. **Anti-Debugging**: Learn anti-debugging mechanism identification and bypass
6. **Obfuscation Analysis**: Test code obfuscation and protection mechanism analysis
7. **Secure Implementation**: Develop secure coding practices to prevent reverse engineering

Teaching Methodology:
- **Binary Labs**: Hands-on executable analysis and disassembly exercises
- **Assembly Workshops**: Assembly language reading and interpretation training
- **Disassembly Exercises**: Executable disassembly technique labs
- **Debugging Tutorials**: Dynamic analysis and debugging guides
- **Anti-Debugging Labs**: Anti-debugging mechanism testing frameworks
- **Obfuscation Workshops**: Code obfuscation analysis assessment exercises
- **Real-World Scenarios**: Case studies of reverse engineering applications

Output Format:
- **Reverse Engineering Modules**: Structured learning units for binary analysis concepts
- **Assembly Exercises**: Practical assembly language reading labs
- **Disassembly Labs**: Executable disassembly technique exercises
- **Debugging Workshops**: Dynamic analysis and debugging guides
- **Anti-Debugging Tutorials**: Anti-debugging mechanism testing frameworks
- **Obfuscation Labs**: Code obfuscation analysis assessment exercises
- **Case Studies**: Real-world reverse engineering application examples

Example Learning Query: "Teach me advanced reverse engineering from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level reverse engineering and binary analysis skills.

---

# MODULE 1: Executable File Format Analysis

## 1.1 Portable Executable (PE) Format

**PE File Structure:**
```
PE File Layout:
+-- DOS Header
|   +-- Magic number (MZ = 0x5A4D)
|   +-- PE header offset (e_lfanew)
+-- DOS Stub
|   +-- "This program cannot be run in DOS mode"
+-- PE Signature
|   +-- "PE\0\0" (0x50450000)
+-- COFF File Header
|   +-- Machine type (0x8664 = AMD64, 0x14C = x86)
|   +-- Number of sections
|   +-- Timestamp
|   +-- Optional header size
+-- Optional Header
|   +-- Magic (0x10B = PE32, 0x20B = PE32+)
|   +-- Entry point address
|   +-- Image base address
|   +-- Section alignment
|   +-- File alignment
|   +-- Subsystem (GUI/Console/Driver)
|   +-- Data directories
|       +-- Import table
|       +-- Export table
|       +-- Resource table
|       +-- Relocation table
|       +-- Debug directory
|       +-- TLS table
|       +-- Load config
+-- Section Headers
|   +-- .text (code)
|   +-- .data (initialized data)
|   +-- .bss (uninitialized data)
|   +-- .rdata (read-only data)
|   +-- .idata (imports)
|   +-- .edata (exports)
|   +-- .reloc (relocations)
|   +-- .rsrc (resources)
+-- Section Data
```

**PE Parsing with Python:**
```python
# pe_parser.py
import pefile
import struct
from dataclasses import dataclass
from typing import List, Dict

@dataclass
class PEInfo:
    filename: str
    machine: str
    subsystem: str
    entry_point: int
    image_base: int
    sections: List[Dict]
    imports: List[Dict]
    exports: List[Dict]
    is_64bit: bool
    compilation_time: int

class PEAnalyzer:
    def __init__(self, filepath: str):
        self.filepath = filepath
        self.pe = pefile.PE(filepath)

    def get_basic_info(self) -> PEInfo:
        """Extract basic PE information"""
        machine_map = {
            0x14C: "x86",
            0x8664: "AMD64",
            0x1C0: "ARM",
            0xAA64: "ARM64"
        }
        subsystem_map = {
            1: "Native", 2: "Windows GUI",
            3: "Windows Console", 5: "OS/2 Console",
            7: "POSIX Console", 10: "Windows CE"
        }

        sections = []
        for section in self.pe.sections:
            sections.append({
                "name": section.Name.decode().rstrip('\x00'),
                "virtual_address": section.VirtualAddress,
                "virtual_size": section.Misc_VirtualSize,
                "raw_size": section.SizeOfRawData,
                "characteristics": hex(section.Characteristics)
            })

        return PEInfo(
            filename=self.filepath,
            machine=machine_map.get(self.pe.FILE_HEADER.Machine, "Unknown"),
            subsystem=subsystem_map.get(self.pe.OPTIONAL_HEADER.Subsystem, "Unknown"),
            entry_point=self.pe.OPTIONAL_HEADER.AddressOfEntryPoint,
            image_base=self.pe.OPTIONAL_HEADER.ImageBase,
            sections=sections,
            imports=self._get_imports(),
            exports=self._get_exports(),
            is_64bit=self.pe.PE_TYPE == 0x20B,
            compilation_time=self.pe.FILE_HEADER.TimeDateStamp
        )

    def _get_imports(self) -> List[Dict]:
        """Extract import table"""
        imports = []
        if hasattr(self.pe, 'DIRECTORY_ENTRY_IMPORT'):
            for entry in self.pe.DIRECTORY_ENTRY_IMPORT:
                dll_name = entry.dll.decode()
                for imp in entry.imports:
                    imports.append({
                        "dll": dll_name,
                        "function": imp.name.decode() if imp.name else "ordinal",
                        "address": imp.address
                    })
        return imports

    def _get_exports(self) -> List[Dict]:
        """Extract export table"""
        exports = []
        if hasattr(self.pe, 'DIRECTORY_ENTRY_EXPORT'):
            for exp in self.pe.DIRECTORY_ENTRY_EXPORT.symbols:
                exports.append({
                    "name": exp.name.decode() if exp.name else "ordinal",
                    "ordinal": exp.ordinal,
                    "address": exp.address
                })
        return exports

    def detect_packer(self) -> Dict:
        """Detect common packers and protectors"""
        packers = {
            "UPX": [b"UPX0", b"UPX1", b"UPX!"],
            "ASPack": [b".aspack", b".adata"],
            "PECompact": [b"PEC2", b"PEC2TO"],
            "Themida": [b".Themida", b".winlice"],
            "VMProtect": [b".vmp0", b".vmp1"],
            "Armadillo": [b".armadillo"],
            "PEtite": [b".petite"],
        }

        with open(self.filepath, "rb") as f:
            data = f.read()

        detected = []
        for packer, signatures in packers.items():
            if any(sig in data for sig in signatures):
                detected.append(packer)

        # Check section entropy
        high_entropy_sections = []
        for section in self.pe.sections:
            entropy = section.get_entropy()
            if entropy > 7.0:
                high_entropy_sections.append({
                    "name": section.Name.decode().rstrip('\x00'),
                    "entropy": entropy
                })

        return {
            "packers": detected,
            "high_entropy_sections": high_entropy_sections,
            "likely_packed": len(detected) > 0 or len(high_entropy_sections) > 2
        }

    def analyze_sections(self) -> List[Dict]:
        """Analyze section characteristics"""
        section_analysis = []
        suspicious_flags = {
            0x20000000: "IMAGE_SCN_MEM_EXECUTE",
            0x40000000: "IMAGE_SCN_MEM_READ",
            0x80000000: "IMAGE_SCN_MEM_WRITE"
        }

        for section in self.pe.sections:
            flags = []
            for flag, name in suspicious_flags.items():
                if section.Characteristics & flag:
                    flags.append(name)

            section_analysis.append({
                "name": section.Name.decode().rstrip('\x00'),
                "virtual_address": hex(section.VirtualAddress),
                "virtual_size": section.Misc_VirtualSize,
                "raw_size": section.SizeOfRawData,
                "entropy": section.get_entropy(),
                "flags": flags,
                "executable": bool(section.Characteristics & 0x20000000),
                "writable": bool(section.Characteristics & 0x80000000)
            })

        return section_analysis
```

## 1.2 ELF Format Analysis

**ELF Structure:**
```
ELF File Layout:
+-- ELF Header
|   +-- Magic number (0x7F 'E' 'L' 'F')
|   +-- Class (32-bit/64-bit)
|   +-- Data encoding (little/big endian)
|   +-- OS/ABI
|   +-- Type (executable/shared object/core)
|   +-- Machine (x86, x86_64, ARM, etc.)
|   +-- Entry point address
|   +-- Program header offset
|   +-- Section header offset
+-- Program Headers
|   +-- PT_LOAD (loadable segment)
|   +-- PT_DYNAMIC (dynamic linking)
|   +-- PT_INTERP (interpreter path)
|   +-- PT_NOTE (auxiliary information)
|   +-- PT_TLS (thread-local storage)
+-- Sections
|   +-- .text (executable code)
|   +-- .rodata (read-only data)
|   +-- .data (initialized data)
|   +-- .bss (uninitialized data)
|   +-- .plt (procedure linkage table)
|   +-- .got (global offset table)
|   +-- .dynsym (dynamic symbols)
|   +-- .dynstr (dynamic strings)
|   +-- .symtab (symbol table)
|   +-- .strtab (string table)
|   +-- .rel.dyn (relocations)
|   +-- .init/.fini (initialization)
```

**ELF Parsing:**
```python
# elf_parser.py
import elftools.elf.elffile as elffile
from elftools.elf.sections import SymbolTableSection
from elftools.elf.segments import Segment

class ELFAnalyzer:
    def __init__(self, filepath: str):
        with open(filepath, "rb") as f:
            self.elf = elffile.ELFFile(f)
            self.data = f.read()

    def get_basic_info(self) -> dict:
        return {
            "class": self.elf.header.e_ident.EI_CLASS,
            "data": self.elf.header.e_ident.EI_DATA,
            "os_abi": self.elf.header.e_ident.EI_OSABI,
            "type": self.elf.header.e_type,
            "machine": hex(self.elf.header.e_machine),
            "entry_point": hex(self.elf.header.e_entry),
            "flags": hex(self.elf.header.e_flags)
        }

    def analyze_segments(self) -> list:
        segments = []
        for segment in self.elf.iter_segments():
            seg_info = {
                "type": segment.header.p_type,
                "offset": hex(segment.header.p_offset),
                "vaddr": hex(segment.header.p_vaddr),
                "filesz": segment.header.p_filesz,
                "memsz": segment.header.p_memsz,
                "flags": hex(segment.header.p_flags),
                "alignment": segment.header.p_align
            }
            segments.append(seg_info)
        return segments

    def get_dynamic_symbols(self) -> list:
        symbols = []
        for section in self.elf.iter_sections():
            if isinstance(section, SymbolTableSection):
                for symbol in section.iter_symbols():
                    if symbol.name:
                        symbols.append({
                            "name": symbol.name,
                            "value": hex(symbol['st_value']),
                            "size": symbol['st_size'],
                            "type": symbol['st_info']['type'],
                            "bind": symbol['st_info']['bind']
                        })
        return symbols

    def check_security_features(self) -> dict:
        flags = self.elf.header.e_flags
        return {
            "pie": bool(self.elf.header.e_type == "ET_DYN"),
            "canary": self._check_canary(),
            "nx": self._check_nx(),
            "relro": self._check_relro(),
            "fortify_source": self._check_fortify()
        }

    def _check_canary(self) -> bool:
        return b"__stack_chk_fail" in self.data

    def _check_nx(self) -> bool:
        for segment in self.elf.iter_segments():
            if segment.header.p_type == "PT_GNU_STACK":
                return not bool(segment.header.p_flags & 0x1)
        return False

    def _check_relro(self) -> str:
        if b"GNU_RELRO" in self.data:
            if b"BIND_NOW" in self.data:
                return "Full RELRO"
            return "Partial RELRO"
        return "No RELRO"

    def _check_fortify(self) -> bool:
        return b"__fprintf_chk" in self.data
```

## 1.3 Practical Exercise: PE Analysis Lab

```python
# exercises/pe_analysis.py
"""
Exercise: Analyze a suspicious executable
1. Parse PE headers and extract metadata
2. Identify imported DLLs and functions
3. Detect packer presence
4. Analyze section entropy
5. Extract suspicious strings
6. Map entry point to code section
"""

import pefile
import hashlib
import math
from collections import Counter

def analyze_suspicious_pe(filepath):
    pe = pefile.PE(filepath)

    print(f"=== Analysis Report: {filepath} ===")
    print(f"MD5: {hashlib.md5(open(filepath, 'rb').read()).hexdigest()}")
    print(f"SHA256: {hashlib.sha256(open(filepath, 'rb').read()).hexdigest()}")

    print(f"\n--- Basic Info ---")
    print(f"Machine: {hex(pe.FILE_HEADER.Machine)}")
    print(f"Sections: {pe.FILE_HEADER.NumberOfSections}")
    print(f"Timestamp: {pe.FILE_HEADER.TimeDateStamp}")

    print(f"\n--- Section Analysis ---")
    for section in pe.sections:
        name = section.Name.decode().rstrip('\x00')
        entropy = section.get_entropy()
        print(f"  {name:10} VA: {hex(section.VirtualAddress)} "
              f"Size: {section.Misc_VirtualSize:8} Entropy: {entropy:.2f}")

    print(f"\n--- Import Analysis ---")
    suspicious_dlls = ["ws2_32.dll", "wininet.dll", "urlmon.dll",
                       "crypt32.dll", "advapi32.dll"]
    if hasattr(pe, 'DIRECTORY_ENTRY_IMPORT'):
        for entry in pe.DIRECTORY_ENTRY_IMPORT:
            dll_name = entry.dll.decode().lower()
            marker = " [SUSPICIOUS]" if dll_name in suspicious_dlls else ""
            print(f"  {dll_name}{marker}")
            for imp in entry.imports:
                if imp.name:
                    print(f"    - {imp.name.decode()}")

    return pe

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        analyze_suspicious_pe(sys.argv[1])
```

## 1.4 Assessment Questions

1. What are the key differences between PE and ELF file formats?
2. How does entropy analysis help detect packed executables?
3. Explain the purpose of the Import Address Table (IAT).
4. What security features can be determined from analyzing PE headers?
5. How do section characteristics indicate malicious intent?

---

# MODULE 2: x86/x64 Assembly Language

## 2.1 x86 Assembly Fundamentals

**Register Architecture:**
```
x86-64 General Purpose Registers:
+-- RAX (Return value, accumulator)
+-- RBX (Base register)
+-- RCX (Counter)
+-- RDX (Data/IO)
+-- RSI (Source index for string operations)
+-- RDI (Destination index for string operations)
+-- RBP (Base pointer, stack frame)
+-- RSP (Stack pointer)
+-- R8-R15 (General purpose, R8-R11 volatile)
+-- RIP (Instruction pointer)
+-- RFLAGS (Status flags)

Segment Registers:
+-- CS (Code segment)
+-- DS (Data segment)
+-- SS (Stack segment)
+-- ES (Extra segment)
+-- FS/GS (Thread-local storage, TEB/GSB)

x87 FPU Stack:
+-- ST(0) through ST(7)

SSE/AVX Registers:
+-- XMM0-XMM15 (128-bit)
+-- YMM0-YMM15 (256-bit, AVX)
+-- ZMM0-ZMM31 (512-bit, AVX-512)
```

**Common Assembly Instructions:**
```asm
; Data Movement
mov     rax, rbx          ; rax = rbx
push    rax               ; stack -= 8; [rsp] = rax
pop     rbx               ; rbx = [rsp]; stack += 8
lea     rax, [rbx+rcx*8]  ; rax = rbx + rcx * 8
xchg    rax, rbx          ; swap rax and rbx

; Arithmetic
add     rax, 5            ; rax += 5
sub     rax, rbx          ; rax -= rbx
imul    rax, rbx          ; rax *= rbx
idiv    rbx               ; rax = rdx:rax / rbx
inc     rax               ; rax++
dec     rbx               ; rbx--
neg     rax               ; rax = -rax
not     rax               ; rax = ~rax

; Bitwise Operations
and     rax, 0xFF         ; rax &= 0xFF
or      rax, 0x100        ; rax |= 0x100
xor     rax, rax          ; rax = 0 (zero register)
shl     rax, 3            ; rax <<= 3
shr     rax, 2            ; rax >>= 2 (logical)
sar     rax, 2            ; rax >>= 2 (arithmetic, sign-extend)

; Control Flow
cmp     rax, rbx          ; Set flags based on rax - rbx
test    rax, rax          ; Set flags based on rax & rax
je      label             ; Jump if equal (ZF=1)
jne     label             ; Jump if not equal (ZF=0)
jg      label             ; Jump if greater (signed)
jl      label             ; Jump if less (signed)
ja      label             ; Jump if above (unsigned)
jb      label             ; Jump if below (unsigned)
jmp     label             ; Unconditional jump
call    function          ; Push RIP, jump to function
ret                       ; Pop RIP, return

; String Operations
movsb    ; Copy byte [rsi] to [rdi]
movsw    ; Copy word
movsd    ; Copy dword
movsq    ; Copy qword
rep      ; Repeat following instruction ECX times
cmpsb    ; Compare bytes at [rsi] and [rdi]
```

## 2.2 Function Call Convention

**System V AMD64 ABI (Linux/macOS):**
```asm
; Arguments: RDI, RSI, RDX, RCX, R8, R9 (integer/pointer)
;            XMM0-XMM7 (floating point)
; Return: RAX, RDX
; Callee-saved: RBX, RBP, R12-R15
; Caller-saved: RAX, RCX, RDX, RSI, RDI, R8-R11

my_function:
    push    rbp              ; Save old base pointer
    mov     rbp, rsp         ; Set up new stack frame
    sub     rsp, 32          ; Allocate local variables

    ; rdi = first argument
    ; rsi = second argument
    mov     rax, rdi         ; Use first argument
    add     rax, rsi         ; Add second argument

    leave                    ; Restore stack frame
    ret                      ; Return value in rax
```

**Windows x64 Calling Convention:**
```asm
; Arguments: RCX, RDX, R8, R9 (integer/pointer)
;            XMM0-XMM3 (floating point)
; Return: RAX
; Callee-saved: RBX, RBP, RDI, RSI, R12-R15
; Caller-saved: RAX, RCX, RDX, R8-R11

windows_function:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32          ; Shadow space (32 bytes mandatory)

    ; rcx = first argument
    ; rdx = second argument
    mov     rax, rcx
    add     rax, rdx

    add     rsp, 32
    pop     rbp
    ret
```

## 2.3 Stack-Based Buffer Overflow Analysis

```asm
; Vulnerable function (no stack canary)
vulnerable_func:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 64          ; 64-byte buffer on stack

    ; Read user input into buffer
    lea     rax, [rbp-64]    ; Buffer address
    mov     rdi, rax         ; First argument = buffer
    mov     esi, 256         ; Second argument = size
    call    gets             ; UNSAFE: no bounds check

    leave
    ret

; Stack layout during vulnerable_func:
; [HIGH ADDRESS]
; +------------------+
; | Return Address   | <-- rbp + 8
; +------------------+
; | Saved RBP        | <-- rbp
; +------------------+
; | Buffer[63]       | <-- rbp - 1
; | ...              |
; | Buffer[0]        | <-- rbp - 64
; +------------------+
; [LOW ADDRESS]

; Exploit: Overflow buffer to overwrite return address
; Input: "A"*64 + "BBBB" + shellcode_address
```

## 2.4 Practical Exercise: Assembly Analysis

```asm
; exercises/decode_function.asm
; Exercise: Analyze this function and determine its purpose

analyze_this:
    push    rbp
    mov     rbp, rsp
    mov     QWORD [rbp-24], rdi    ; Store first argument
    mov     DWORD [rbp-8], 0       ; Initialize counter

    jmp     .check

.loop:
    mov     eax, DWORD [rbp-8]
    cdqe
    add     rax, QWORD [rbp-24]
    movzx   eax, BYTE [rax]
    cmp     al, 48                 ; '0'
    jl      .not_digit
    cmp     al, 57                 ; '9'
    jg      .not_digit
    add     DWORD [rbp-8], 1

.check:
    mov     eax, DWORD [rbp-8]
    cdqe
    add     rax, QWORD [rbp-24]
    movzx   eax, BYTE [rax]
    test    al, al
    jnz     .loop

    mov     eax, DWORD [rbp-8]
    pop     rbp
    ret

; Question: What does this function do?
; Answer: Counts the number of digit characters (0-9) in a string
```

## 2.5 Assessment Questions

1. What are the key differences between x86 and x64 calling conventions?
2. How does a stack-based buffer overflow work at the assembly level?
3. Explain the purpose of the RBP register in stack frame setup.
4. What is the difference between JMP and CALL instructions?
5. How do conditional jumps (JE, JNE, JG, etc.) work?
6. What is the significance of XOR EAX, EAX as an optimization?
7. Explain the purpose of the LEA instruction.

---

# MODULE 3: Static and Dynamic Analysis Tools

## 3.1 IDA Pro / Ghidra Usage

**Ghidra Scripting (Python):**
```python
# ghidra_script.py - Run in Ghidra Script Manager
from ghidra.program.model.listing import CodeUnit
from ghidra.app.decompiler import DecompInterface

def find_vulnerable_functions():
    """Find potentially vulnerable functions"""
    func_list = []
    listing = currentProgram.getListing()
    func_manager = currentProgram.getFunctionManager()

    for func in func_manager.getFunctions(True):
        name = func.getName()
        # Check for dangerous functions
        dangerous = ["gets", "strcpy", "sprintf", "scanf", "strcat",
                     "gets_s", "scanf_s"]
        for d in dangerous:
            if d in name.lower():
                func_list.append({
                    "name": name,
                    "address": func.getEntryPoint(),
                    "danger": d
                })
                break

    return func_list

def decompile_function(address):
    """Decompile function at address"""
    decomp = DecompInterface()
    decomp.openProgram(currentProgram)
    func = getFunctionAt(address)
    if func:
        result = decomp.decompileFunction(func, 30, None)
        if result and result.decompileCompleted():
            return result.getDecompiledFunction().getC()
    return None

# Run analysis
vulns = find_vulnerable_functions()
for v in vulns:
    print(f"Dangerous function: {v['name']} at {v['address']}")
    code = decompile_function(v['address'])
    if code:
        print(f"Decompiled:\n{code}")
```

**IDA Pro Script (IDAPython):**
```python
# ida_script.py
import idaapi
import idautils
import idc

def find_xrefs_to_function(func_name):
    """Find all cross-references to a function"""
    ea = idc.get_name_ea_simple(func_name)
    if ea == idc.BADADDR:
        return []

    xrefs = []
    for xref in idautils.XrefsTo(ea):
        xrefs.append({
            "from": hex(xref.frm),
            "type": "call" if xref.type == 2 else "data"
        })
    return xrefs

def get_imports():
    """Get all imported functions"""
    imports = []
    for entry in idautils.Entries():
        name = idc.get_name(entry)
        if name:
            imports.append(name)
    return imports

def analyze_stack_variables(func_ea):
    """Analyze stack frame of a function"""
    func = idaapi.get_func(func_ea)
    if func:
        frame = idaapi.get_frame(func_ea)
        if frame:
            for i in range(frame.size):
                member = idc.get_member_name(frame.id, i)
                if member:
                    print(f"Stack var: {member} at [ebp-{i}]")
```

## 3.2 Radare2 / Cutter Analysis

```bash
# Radare2 command reference
r2 -A binary.exe

# Analysis commands
aaa                 ; Analyze all
afl                 ; List functions
afi @ func_name     ; Function info
axt @ func_name     ; Cross-references to
pdf @ func_name     ; Disassemble function

# String analysis
iz                  ; Strings in data sections
izz                 ; All strings
iz | grep "http"    ; Filter strings

# Import/Export
ii                  ; List imports
ie                  ; List exports

# Data analysis
axt @ data          ; Who references this data
px 64 @ addr        ; Print hex at address

# Emulation
aei                 ; Initialize ESIL
aeim                ; Initialize ESIL memory
aeip                ; Set ESIL IP
aef @ func_name     ; Emulate function

# Scripting
r2 -qc 'aaa; afl; q' binary.exe
```

## 3.3 Practical Exercise: Function Analysis

```python
# exercises/func_analysis.py
"""
Exercise: Use static analysis to identify:
1. All string references in a binary
2. Functions that handle user input
3. Cryptographic function patterns
4. Network communication functions
5. Anti-debugging techniques
"""

import r2pipe
import json

class BinaryAnalyzer:
    def __init__(self, filepath):
        self.r2 = r2pipe.open(filepath)
        self.r2.cmd("aaa")

    def find_crypto_functions(self):
        """Identify cryptographic functions by patterns"""
        crypto_patterns = {
            "AES": ["aes", "rijndael", "sub_bytes", "mix_columns"],
            "RSA": ["rsa", "modpow", "montgomery"],
            "MD5": ["md5", "merkle", "0x67452301"],
            "SHA1": ["sha1", "0x67452301", "0xEFCDAB89"],
            "SHA256": ["sha256", "0x6A09E667"],
            "RC4": ["rc4", "arcfour", "ksa", "prga"],
            "Base64": ["base64", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
        }

        functions = self.r2.cmdj("aflj")
        findings = []

        for func in functions:
            name = func.get("name", "").lower()
            disasm = self.r2.cmd(f"pdf @ {func['offset']}").lower()

            for algo, patterns in crypto_patterns.items():
                if any(p in name or p in disasm for p in patterns):
                    findings.append({
                        "algorithm": algo,
                        "function": func["name"],
                        "address": hex(func["offset"])
                    })

        return findings

    def find_input_functions(self):
        """Find functions that handle user input"""
        dangerous_funcs = ["gets", "scanf", "read", "recv",
                          "fgets", "getline", "fread"]
        findings = []

        imports = self.r2.cmdj("iij")
        for imp in imports:
            name = imp.get("name", "")
            if any(d in name for d in dangerous_funcs):
                # Find callers
                callers = self.r2.cmdj(f"axtj @ {imp['plt']}")
                for caller in callers:
                    findings.append({
                        "input_func": name,
                        "caller": hex(caller.get("from", 0)),
                        "risk": "high"
                    })

        return findings

    def analyze_anti_debug(self):
        """Detect anti-debugging techniques"""
        anti_debug = {
            "IsDebuggerPresent": "Windows API",
            "CheckRemoteDebuggerPresent": "Windows API",
            "NtQueryInformationProcess": "NT API",
            "ptrace": "Linux PTRACE",
            "syscall": "Direct syscall",
            "rdtsc": "Timing check",
            "cpuid": "CPU identification",
            "INT 2D": "Interrupt debug check",
            "GetTickCount": "Timing check",
            "QueryPerformanceCounter": "High-res timing"
        }

        functions = self.r2.cmdj("aflj")
        findings = []

        for func in functions:
            disasm = self.r2.cmd(f"pdf @ {func['offset']}")
            for technique, category in anti_debug.items():
                if technique.lower() in disasm.lower():
                    findings.append({
                        "technique": technique,
                        "category": category,
                        "function": func["name"],
                        "address": hex(func["offset"])
                    })

        return findings

    def extract_strings_with_refs(self):
        """Extract strings and their cross-references"""
        strings = self.r2.cmdj("izzj")
        string_refs = []

        for s in strings:
            if s.get("string"):
                refs = self.r2.cmdj(f"axtj @ {s['vaddr']}")
                string_refs.append({
                    "string": s["string"],
                    "address": hex(s["vaddr"]),
                    "section": s.get("section", ""),
                    "references": [hex(r["from"]) for r in (refs or [])]
                })

        return string_refs

    def close(self):
        self.r2.quit()

# Usage
if __name__ == "__main__":
    analyzer = BinaryAnalyzer("target_binary")

    print("=== Crypto Functions ===")
    for f in analyzer.find_crypto_functions():
        print(f"  {f['algorithm']}: {f['function']} @ {f['address']}")

    print("\n=== Input Functions ===")
    for f in analyzer.find_input_functions():
        print(f"  {f['input_func']} called from {f['caller']}")

    print("\n=== Anti-Debug ===")
    for f in analyzer.analyze_anti_debug():
        print(f"  {f['technique']} ({f['category']}) in {f['function']}")

    analyzer.close()
```

## 3.4 Assessment Questions

1. How do you use Ghidra to decompile and analyze a binary?
2. What are the key differences between IDA Pro and Ghidra?
3. Explain how Radare2's ESIL emulation works for analysis.
4. How do you identify cryptographic implementations in a binary?
5. What patterns indicate anti-debugging techniques?

---

# MODULE 4: Debugging and Dynamic Analysis

## 4.1 GDB Advanced Usage

**GDB Configuration (.gdbinit):**
```bash
# .gdbinit
set disassembly-flavor intel
set follow-fork-mode child
set disassemble-next-line on

# Pretty printing
python
import gdb
class StlVectorPrinter:
    def __init__(self, val):
        self.val = val
    def to_string(self):
        return f"vector size={self.val['_M_impl']['_M_finish'] - self.val['_M_impl']['_M_start']}"

def register_printers(obj):
    obj.pretty_printers.append(
        lambda val: StlVectorPrinter(val)
        if 'std::vector' in str(val.type) else None
    )

register_printers(gdb.current_objfile())
end

# Custom commands
define hook-stop
    # Show registers on every stop
    info registers rip rsp rax rbx
end
```

**GDB Scripting for Malware Analysis:**
```python
# gdb_malware_analysis.py
import gdb

class MalwareAnalyzer:
    @staticmethod
    def dump_memory(addr, length, filename):
        """Dump memory to file"""
        gdb.execute(f"dump binary memory {filename} {addr} {addr+length}")

    @staticmethod
    def trace_api_calls():
        """Set breakpoints on important API calls"""
        apis = [
            "LoadLibraryA", "GetProcAddress",
            "VirtualAlloc", "VirtualProtect",
            "CreateFileA", "WriteFile",
            "InternetOpenA", "InternetConnectA",
            "CryptEncrypt", "CryptDecrypt"
        ]
        for api in apis:
            try:
                gdb.execute(f"break {api}")
            except gdb.error:
                pass

    @staticmethod
    def dump_strings_at(addr, count=100):
        """Dump null-terminated strings at address"""
        result = []
        for i in range(count):
            try:
                char = gdb.execute(f"x/s {addr+i*256}", to_string=True)
                if "(void)" not in char and len(char.strip()) > 0:
                    result.append(char.strip())
            except gdb.error:
                break
        return result

    @staticmethod
    def analyze_shellcode(shellcode_bytes):
        """Analyze shellcode byte pattern"""
        import subprocess
        # Write shellcode to temp file
        with open("/tmp/shellcode.bin", "wb") as f:
            f.write(shellcode_bytes)

        # Disassemble
        result = subprocess.run(
            ["objdump", "-D", "-b", "binary", "-m", "i386", "-M", "intel",
             "/tmp/shellcode.bin"],
            capture_output=True, text=True
        )
        return result.stdout
```

**GDB Plugin for Reverse Engineering:**
```python
# gdb_pwndbg_commands.py
import gdb

class ExtractCryptoKeys(gdb.Command):
    """Extract encryption keys from memory"""
    def __init__(self):
        super(ExtractCryptoKeys, self).__init__("extract-keys", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        # Scan memory for potential AES/RSA keys
        ranges = [
            ("0x0000000000400000", "0x0000000000600000"),  # .text/.data
            ("0x00007ffffffde000", "0x00007fffffffffff"),  # Stack
        ]

        key_patterns = [16, 24, 32]  # AES key sizes
        for start, end in ranges:
            for size in key_patterns:
                result = gdb.execute(
                    f"find /b {start}, {end}, 0x00, 0x01, 0x02, 0x03",
                    to_string=True
                )
                if "pattern" in result:
                    print(f"Potential {size*8}-bit key found at {result}")

ExtractCryptoKeys()
```

## 4.2 x64dbg / OllyDbg Analysis

```
x64dbg Key Features:
+-- Breakpoints
|   +-- Software breakpoint (INT3, 0xCC)
|   +-- Hardware breakpoint (DR0-DR3)
|   +-- Memory breakpoint (page protection)
|   +-- Conditional breakpoint
+-- Tracing
|   +-- Trace over (step over)
|   +-- Trace into (step into)
|   +-- Trace record
|   +-- Conditional trace
+-- Memory Analysis
|   +-- Memory map
|   +-- Heap analysis
|   +-- Stack analysis
|   +-- Thread local storage
+-- Plugin Support
    +-- Scylla (IAT reconstruction)
    +-- xAnalyzer (call analysis)
    +-- SharpOD (anti-anti-debug)
    +-- Titanium (anti-detection)
```

## 4.3 Frida Dynamic Instrumentation

```javascript
// frida_hook.js - Dynamic instrumentation for security analysis

// Hook function calls
Interceptor.attach(Module.findExportByName(null, "VirtualAlloc"), {
    onEnter: function(args) {
        this.size = args[1].toInt32();
        this.protect = args[2].toInt32();
        console.log("[VirtualAlloc] Size: " + this.size +
                   " Protect: " + this.protect);
    },
    onLeave: function(retval) {
        console.log("[VirtualAlloc] Returned: " + retval);
    }
});

// Hook crypto functions
Interceptor.attach(Module.findExportByName("advapi32.dll", "CryptEncrypt"), {
    onEnter: function(args) {
        console.log("[CryptEncrypt] Key handle: " + args[0]);
        console.log("[CryptEncrypt] Final: " + args[4]);
    }
});

// Hook network functions
Interceptor.attach(Module.findExportByName("ws2_32.dll", "send"), {
    onEnter: function(args) {
        var buf = Memory.readByteArray(args[1], args[2].toInt32());
        console.log("[send] Length: " + args[2]);
        console.log("[send] Data: " + hexdump(buf));
    }
});

// Hook process creation
Interceptor.attach(Module.findExportByName("kernel32.dll", "CreateProcessA"), {
    onEnter: function(args) {
        console.log("[CreateProcess] App: " + Memory.readUtf8String(args[0]));
        console.log("[CreateProcess] Cmd: " + Memory.readUtf8String(args[1]));
    }
});

// Bypass anti-debugging
Interceptor.attach(Module.findExportByName("kernel32.dll", "IsDebuggerPresent"), {
    onLeave: function(retval) {
        retval.replace(0);  // Always return false
        console.log("[Anti-Debug] IsDebuggerPresent bypassed");
    }
});

// Dump decoded payload
function dumpDecodedPayload(addr, size) {
    var buf = Memory.readByteArray(addr, size);
    var file = new File("/tmp/decoded_payload.bin", "wb");
    file.write(buf);
    file.close();
    console.log("[DUMP] Payload saved to /tmp/decoded_payload.bin");
}
```

## 4.4 Practical Exercise: Malware Analysis Lab

```python
# exercises/malware_analysis.py
"""
Exercise: Analyze a sample malware binary
1. Static analysis: strings, imports, PE headers
2. Dynamic analysis: run in sandbox, observe behavior
3. Memory analysis: dump and decrypt payloads
4. Network analysis: capture C2 communications
5. Persistence analysis: identify registry/services
"""

import subprocess
import hashlib
import os
import json
from datetime import datetime

class MalwareAnalyzer:
    def __init__(self, sample_path):
        self.sample_path = sample_path
        self.results = {
            "file_info": self._file_info(),
            "strings": [],
            "imports": [],
            "behavior": [],
            "network": [],
            "persistence": []
        }

    def _file_info(self):
        """Get basic file information"""
        with open(self.sample_path, "rb") as f:
            data = f.read()
        return {
            "md5": hashlib.md5(data).hexdigest(),
            "sha1": hashlib.sha1(data).hexdigest(),
            "sha256": hashlib.sha256(data).hexdigest(),
            "size": len(data),
            "entropy": self._calculate_entropy(data)
        }

    def _calculate_entropy(self, data):
        """Calculate Shannon entropy"""
        import math
        if not data:
            return 0
        byte_counts = [0] * 256
        for byte in data:
            byte_counts[byte] += 1
        entropy = 0
        for count in byte_counts:
            if count > 0:
                prob = count / len(data)
                entropy -= prob * math.log2(prob)
        return entropy

    def extract_strings(self, min_length=4):
        """Extract interesting strings"""
        result = subprocess.run(
            ["strings", "-n", str(min_length), self.sample_path],
            capture_output=True, text=True
        )
        interesting_patterns = [
            "http", "https", "ftp", ".exe", ".dll",
            "cmd", "Python", "registry", "HKLM",
            "password", "key", "encrypt", "decrypt",
            "socket", "connect", "send", "recv"
        ]

        for line in result.stdout.splitlines():
            for pattern in interesting_patterns:
                if pattern.lower() in line.lower():
                    self.results["strings"].append({
                        "string": line,
                        "category": pattern
                    })
                    break

        return self.results["strings"]

    def analyze_imports(self):
        """Analyze imported functions"""
        result = subprocess.run(
            ["objdump", "-p", self.sample_path],
            capture_output=True, text=True
        )
        suspicious_imports = [
            "VirtualAlloc", "VirtualProtect", "WriteProcessMemory",
            "CreateRemoteThread", "NtUnmapViewOfSection",
            "GetProcAddress", "LoadLibrary",
            "InternetOpenA", "HttpSendRequest",
            "CryptEncrypt", "CryptDecrypt",
            "CreateServiceA", "RegSetValueEx"
        ]

        for line in result.stdout.splitlines():
            for imp in suspicious_imports:
                if imp in line:
                    self.results["imports"].append({
                        "function": imp,
                        "dll": line.split()[0] if line.split() else "unknown"
                    })

        return self.results["imports"]

    def generate_report(self):
        """Generate analysis report"""
        report = f"""
Malware Analysis Report
======================
Generated: {datetime.now().isoformat()}

File Information:
  MD5:    {self.results['file_info']['md5']}
  SHA256: {self.results['file_info']['sha256']}
  Size:   {self.results['file_info']['size']} bytes
  Entropy: {self.results['file_info']['entropy']:.2f}

Suspicious Strings: {len(self.results['strings'])}
Suspicious Imports: {len(self.results['imports'])}
"""
        return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        analyzer = MalwareAnalyzer(sys.argv[1])
        analyzer.extract_strings()
        analyzer.analyze_imports()
        print(analyzer.generate_report())
```

## 4.5 Assessment Questions

1. How do you use GDB to trace API calls in a binary?
2. Explain the difference between software and hardware breakpoints.
3. How does Frida's Interceptor.attach work for hooking functions?
4. What are the key steps in dynamic malware analysis?
5. How do you extract and decode encrypted payloads from memory?

---

# MODULE 5: Anti-Analysis and Obfuscation Bypass

## 5.1 Anti-Debugging Techniques

```
Common Anti-Debugging Methods:
+-- API-Based Detection
|   +-- IsDebuggerPresent()
|   +-- CheckRemoteDebuggerPresent()
|   +-- NtQueryInformationProcess()
|   +-- OutputDebugStringA()
+-- Timing-Based Detection
|   +-- GetTickCount() / QueryPerformanceCounter()
|   +-- RDTSC (Read Time-Stamp Counter)
|   +-- Sleep timing discrepancy
|   +--rdtsc comparison
+-- Exception-Based Detection
|   +-- INT 2D (kernel debug check)
|   +-- INT 3 with exception handling
|   +-- Hardware breakpoint detection
|   +-- Single-step exception
+-- Process/Thread-Based
|   +-- NtSetInformationThread (hide from debugger)
|   +-- CheckRemoteDebugger on parent
|   +-- Thread name enumeration
|   +-- PEB.BeingDebugged flag
+-- Memory-Based
|   +-- Check breakpoint bytes (0xCC)
|   +-- Code section integrity checks
|   +-- Memory page protection checks
|   +-- Hardware register detection
```

**Bypass Script:**
```python
# bypass_antidebug.py
import ctypes
import struct

# PEB.BeingDebugged bypass
def patch_peb():
    """Clear BeingDebugged flag in PEB"""
    PEB_address = ctypes.windll.kernel32.GetCurrentPeb()
    ctypes.windll.kernel32.WriteProcessMemory(
        ctypes.windll.kernel32.GetCurrentProcess(),
        PEB_address + 2,  # Offset of BeingDebugged
        ctypes.byref(ctypes.c_bool(0)),
        1, None
    )

# NtQueryInformationProcess bypass
def patch_ntquery():
    """Hook NtQueryInformationProcess to return 0"""
    ntdll = ctypes.WinDLL("ntdll")
    ntdll.NtQueryInformationProcess.restype = ctypes.c_long

    # Patch the function to return STATUS_SUCCESS (0)
    # with ProcessDebugPort = 0
    ...

class AntiDebugBypass:
    def __init__(self):
        self.bypasses = []

    def register_bypass(self, technique, bypass_func):
        self.bypasses.append({
            "technique": technique,
            "bypass": bypass_func
        })

    def apply_all(self):
        for bypass in self.bypasses:
            try:
                bypass["bypass"]()
                print(f"[+] Bypassed: {bypass['technique']}")
            except Exception as e:
                print(f"[-] Failed to bypass {bypass['technique']}: {e}")
```

## 5.2 Packer and Protector Analysis

```
Unpacking Process:
+-- Identify packer signature
|   +-- Section names
|   +-- Entry point characteristics
|   +-- Import table anomalies
+-- Find OEP (Original Entry Point)
|   +-- Single-step to OEP
|   +-- Memory breakpoint on execution
|   +-- Trace through unpacking routine
+-- Dump unpacked code
|   +-- Memory dump at OEP
|   +-- Fix imports (IAT reconstruction)
+-- Analyze original code
    +-- Standard reverse engineering
```

**Unpacking Helper:**
```python
# unpack_helper.py
import r2pipe

class UnpackHelper:
    def __init__(self, filepath):
        self.r2 = r2pipe.open(filepath)
        self.r2.cmd("aaa")

    def detect_packer(self):
        """Detect packer type"""
        sections = self.r2.cmdj("iSj")
        section_names = [s["name"] for s in sections]

        packers = {
            "UPX": ["UPX0", "UPX1"],
            "VMProtect": [".vmp0", ".vmp1"],
            "Themida": [".Themida", ".winlice"],
            "ASPack": [".aspack", ".adata"],
            "Armadillo": [".armadillo"],
        }

        for packer, sigs in packers.items():
            if any(sig in section_names for sig in sigs):
                return packer
        return "Unknown/Unpacked"

    def find_oep_heuristic(self):
        """Find OEP using heuristic methods"""
        # Method 1: Look for popad + jmp pattern
        oep_candidates = self.r2.cmdj(
            "/ad popad; jmp"
        )

        # Method 2: Follow stack after pushad
        # Method 3: Memory breakpoint on execution

        return oep_candidates

    def dump_unpacked(self, oep_addr, output_path):
        """Dump unpacked code from OEP"""
        # Read memory at OEP
        code = self.r2.cmdj(f"pxj 4096 @ {oep_addr}")

        # Write to file
        with open(output_path, "wb") as f:
            f.write(bytes(code))

        print(f"[+] Dumped unpacked code to {output_path}")
        return output_path
```

## 5.3 Code Obfuscation Patterns

```
Obfuscation Techniques:
+-- Control Flow Obfuscation
|   +-- Opaque predicates
|   +-- Dead code insertion
|   +-- Control flow flattening
|   +-- Exception-based obfuscation
+-- Data Obfuscation
|   +-- String encryption
|   +-- Constant splitting
|   +-- Variable encoding
|   +-- Data structure obfuscation
+-- Anti-Analysis
|   +-- Anti-debugging
|   +-- Anti-VM
|   +-- Anti-sandbox
|   +-- Code integrity checks
+-- Virtualization
    +-- Custom bytecode VM
    +-- Code transformation
    +-- Opaque predicates
```

**String Decryption Script:**
```python
# decrypt_strings.py
import r2pipe
import re

class StringDecryptor:
    def __init__(self, filepath):
        self.r2 = r2pipe.open(filepath)
        self.r2.cmd("aaa")

    def find_encrypted_strings(self):
        """Find potential encrypted string patterns"""
        # Look for XOR loops
        xor_patterns = self.r2.cmdj("/ad xor byte")

        # Look for crypto constants
        crypto_constants = [
            "0x67452301",  # MD5
            "0x5A827999",  # SHA1
            "0x6A09E667",  # SHA256
        ]

        encrypted = []
        for pattern in xor_patterns:
            addr = pattern.get("offset", 0)
            # Analyze the XOR operation
            context = self.r2.cmd(f"pd 20 @ {addr}")

            # Extract XOR key
            key_match = re.search(r"mov\s+cl,\s*(0x[0-9a-f]+)", context)
            if key_match:
                key = int(key_match.group(1), 16)
                # Find the encrypted data
                data_match = re.search(r"xor byte \[([^\]]+)\], cl", context)
                if data_match:
                    encrypted.append({
                        "address": hex(addr),
                        "key": key,
                        "data_ref": data_match.group(1)
                    })

        return encrypted

    def decrypt_xor_string(self, encrypted_data, key):
        """Decrypt XOR-encrypted string"""
        decrypted = []
        for byte in encrypted_data:
            decrypted.append(byte ^ key)
        return bytes(decrypted)

    def emulated_decrypt(self, func_addr, encrypted_addr, key_addr):
        """Use ESIL to decrypt strings"""
        # Set up emulation
        self.r2.cmd("aei")  # Init ESIL
        self.r2.cmd("aeim") # Init memory
        self.r2.cmd(f"aer rip={func_addr}")

        # Run to decryption point
        self.r2.cmd("aecu " + str(encrypted_addr))

        # Read result
        result = self.r2.cmd(f"pxs 64 @ rax")
        return result
```

## 5.4 Assessment Questions

1. What are the most common anti-debugging techniques in modern malware?
2. How do you bypass PEB.BeingDebugged detection?
3. Explain the process of unpacking a UPX-packed binary.
4. What techniques help identify OEP in packed executables?
5. How do you decrypt XOR-encrypted strings in a binary?

---

# MODULE 6: Vulnerability Discovery in Binaries

## 6.1 Binary Vulnerability Patterns

```
Vulnerability Classes in Binaries:
+-- Memory Corruption
|   +-- Stack buffer overflow
|   +-- Heap buffer overflow
|   +-- Use-after-free
|   +-- Double-free
|   +-- Format string vulnerability
|   +-- Integer overflow
+-- Logic Bugs
|   +-- Authentication bypass
|   +-- Privilege escalation
|   +-- Race conditions
|   +-- Off-by-one errors
+-- Input Validation
|   +-- Command injection
|   +-- Path traversal
|   +-- SQL injection (via binary)
|   +-- XML/JSON parsing flaws
+-- Cryptographic Issues
    +-- Weak algorithms
    +-- Hardcoded keys
    +-- Improper IV usage
    +-- Key derivation flaws
```

## 6.2 Fuzzing for Vulnerabilities

```python
# fuzzing_example.py
import subprocess
import random
import os
from pathlib import Path

class BinaryFuzzer:
    def __init__(self, target_binary):
        self.target = target_binary
        self.crashes = []
        self.coverage = set()

    def generate_input(self, strategy="random", size=1024):
        """Generate fuzzing input"""
        if strategy == "random":
            return bytes([random.randint(0, 255) for _ in range(size)])
        elif strategy == "format_string":
            return b"%s%s%s%s%s%s%s%s" * 10
        elif strategy == "overflow":
            return b"A" * size
        elif strategy == "interesting":
            values = [0, 1, 0x7F, 0x80, 0xFF, 0xFFFF, 0xFFFFFFFF]
            return bytes([random.choice(values) for _ in range(size)])

    def run_target(self, input_data):
        """Run target with input data"""
        input_file = "/tmp/fuzz_input"
        with open(input_file, "wb") as f:
            f.write(input_data)

        try:
            result = subprocess.run(
                [self.target, input_file],
                timeout=5,
                capture_output=True,
                env={**os.environ, "ASAN_OPTIONS": "detect_leaks=0"}
            )
            return {
                "returncode": result.returncode,
                "stderr": result.stderr.decode(errors="ignore"),
                "signal": result.returncode < 0
            }
        except subprocess.TimeoutExpired:
            return {"returncode": -1, "stderr": "TIMEOUT", "signal": False}

    def check_crash(self, result):
        """Check if result indicates a crash"""
        crash_signals = [-6, -11, -4]  # SIGABRT, SIGSEGV, SIGILL
        if result["signal"] and result["returncode"] in crash_signals:
            return True
        if "AddressSanitizer" in result.get("stderr", ""):
            return True
        return False

    def fuzz(self, iterations=10000):
        """Main fuzzing loop"""
        print(f"Fuzzing {self.target} for {iterations} iterations")

        for i in range(iterations):
            # Mutation strategy
            if i < 100:
                strategy = "random"
            elif i < 500:
                strategy = "overflow"
            elif i < 1000:
                strategy = "format_string"
            else:
                strategy = "interesting"

            input_data = self.generate_input(strategy)
            result = self.run_target(input_data)

            if self.check_crash(result):
                crash_id = len(self.crashes)
                crash_file = f"/tmp/crash_{crash_id}"
                with open(crash_file, "wb") as f:
                    f.write(input_data)

                self.crashes.append({
                    "iteration": i,
                    "strategy": strategy,
                    "input": input_data.hex(),
                    "stderr": result["stderr"][:500],
                    "file": crash_file
                })
                print(f"[!] Crash #{crash_id} at iteration {i}")

            if i % 1000 == 0:
                print(f"[*] Progress: {i}/{iterations}")

        return self.crashes

# Usage
if __name__ == "__main__":
    import sys
    target = sys.argv[1] if len(sys.argv) > 1 else "./vulnerable_binary"
    fuzzer = BinaryFuzzer(target)
    crashes = fuzzer.fuzz()
    print(f"\nTotal crashes found: {len(crashes)}")
    for c in crashes:
        print(f"  Iteration {c['iteration']}: {c['strategy']}")
```

## 6.3 Practical Exercise: Vulnerability Discovery

```python
# exercises/vuln_discovery.py
"""
Exercise: Analyze a binary for vulnerabilities
1. Static analysis for dangerous function usage
2. Fuzzing with American Fuzzy Lop (AFL++) or LibFuzzer
3. Symbolic execution with Angr
4. Manual reverse engineering of suspicious functions
5. Develop exploit for discovered vulnerability
"""

import angr
import claripy

def find_vulnerability_angr(binary_path):
    """Use symbolic execution to find vulnerabilities"""
    proj = angr.Project(binary_path, auto_load_libs=False)

    # Create symbolic input
    sym_size = claripy.BVS("size", 64)
    sym_input = claripy.BVS("input", 8 * 256)

    # Set up initial state
    state = proj.factory.entry_state(
        args=[binary_path, "/tmp/test_input"],
        add_options=angr.options.unicorn
    )

    # Create simulation manager
    simgr = proj.factory.simgr(state)

    # Find vulnerability states
    def is_vulnerable(state):
        # Check for buffer overflow conditions
        try:
            rsp = state.solver.eval(state.regs.rsp)
            rbp = state.solver.eval(state.regs.rbp)
            return rsp < rbp - 1000  # Stack corruption
        except:
            return False

    def is_success(state):
        try:
            return state.solver.eval(state.regs.rip) == 0x401234  # Target addr
        except:
            return False

    # Explore
    simgr.explore(
        find=is_success,
        avoid=is_vulnerable
    )

    if simgr.found:
        solution_state = simgr.found[0]
        print("[+] Vulnerability found!")
        print(f"    RIP: {hex(solution_state.solver.eval(solution_state.regs.rip))}")
        return solution_state
    else:
        print("[-] No vulnerability found with this approach")
        return None

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        find_vulnerability_angr(sys.argv[1])
```

## 6.4 Assessment Questions

1. What are the most common binary vulnerability patterns?
2. How do you use fuzzing to discover buffer overflows?
3. Explain how symbolic execution helps find vulnerabilities.
4. What is the difference between blackbox and whitebox fuzzing?
5. How do you develop an exploit for a stack buffer overflow?

---

# FURTHER READING

## Books
- "Practical Malware Analysis" by Michael Sikorski
- "Reverse Engineering for Beginners" by Dennis Yurichev
- "The IDA Pro Book" by Chris Eagle
- "Practical Binary Analysis" by Dennis Andriesse
- "Windows Internals" by Pavel Yosifovich

## Online Resources
- Malware Traffic Analysis Exercises (malware-traffic-analysis.net)
- Binary RE Education (binary-re.ninja)
- OpenSecurityTraining2 (opensecuritytraining.info)
- shell-storm.org (shellcode database)

## Practice Platforms
- Flare-On (FireEye RE challenges)
- reversing.kr (Reverse engineering challenges)
- crackmes.one (Binary analysis challenges)
- Malware Unicorn (RE workshops)
- CyberDefenders (Malware analysis CTF)

## Tools Reference
- IDA Pro / IDA Free - Disassembler and debugger
- Ghidra - NSA's reverse engineering framework
- Radare2 / Cutter - Open source RE framework
- x64dbg - Windows debugger
- GDB / GEF / pwndbg - Linux debugger
- Frida - Dynamic instrumentation toolkit
- Binary Ninja - Reverse engineering platform
- Hopper - macOS/Linux disassembler
- Angr - Binary analysis framework
- Triton - Dynamic binary analysis
- LIEF - ELF/PE/MachO parser
- Capstone - Disassembly framework
- Keystone - Assembly framework
- Unicorn - CPU emulator framework

