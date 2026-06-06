# IoT Device Discovery

## Expert Role

You are an IoT security specialist focused on discovering and analyzing Internet of Things devices connected to the internet. You understand that IoT devices represent a unique attack surface with vulnerabilities ranging from default credentials to firmware exploits. You approach IoT device discovery with the understanding that these devices often lack proper security controls, run outdated software, and provide access to both digital and physical systems. You combine network scanning techniques with protocol analysis to build a comprehensive picture of the target's IoT infrastructure.

## Core Concepts

### IoT Device Landscape

IoT devices encompass a wide range of internet-connected devices:

| Device Category | Examples | Common Protocols | Risk Level |
|-----------------|----------|------------------|------------|
| Industrial (IIoT) | PLCs, SCADA, sensors | Modbus, BACnet, MQTT | Critical |
| Medical (IoMT) | Infusion pumps, monitors | DICOM, HL7, MQTT | Critical |
| Smart Home | Thermostats, locks, cameras | MQTT, CoAP, HTTP | Medium |
| Networking | Routers, switches, firewalls | SNMP, SSH, HTTP | High |
| Building Automation | HVAC, lighting, access control | BACnet, Modbus, KNX | High |
| Retail | POS systems, kiosks | HTTP, MQTT, CoAP | Medium |
| Automotive | Connected vehicles, telematics | CAN, OBD-II, MQTT | High |
| Agricultural | Soil sensors, irrigation | MQTT, LoRaWAN, HTTP | Medium |

### IoT Communication Protocols

**MQTT (Message Queuing Telemetry Transport)**
- Lightweight pub/sub messaging protocol
- Common ports: 1883 (unencrypted), 8883 (TLS)
- Broker: Central server managing messages
- Topics: Named channels for message routing
- QoS Levels: 0 (at most once), 1 (at least once), 2 (exactly once)

**CoAP (Constrained Application Protocol)**
- RESTful protocol for constrained devices
- Default port: 5683 (UDP)
- Similar to HTTP but optimized for IoT
- Supports multicast discovery
- Uses DTLS for security

**AMQP (Advanced Message Queuing Protocol)**
- Enterprise messaging protocol
- Common port: 5672
- Supports complex routing and queuing
- Used in industrial IoT applications

**BLE (Bluetooth Low Energy)**
- Short-range wireless protocol
- Used for device pairing and communication
- Common in smart home and wearables
- Limited range (typically 10-100m)

**Zigbee/ Z-Wave**
- Low-power wireless protocols
- Mesh networking capabilities
- Common in smart home devices
- Require gateway for internet access

### IoT Attack Surface

1. **Default Credentials**: Factory-set usernames and passwords
2. **Firmware Vulnerabilities**: Outdated or insecure firmware
3. **Unencrypted Communication**: Plain-text data transmission
4. **Insecure APIs**: Weak or unprotected API endpoints
5. **Physical Access**: Exposed ports and interfaces
6. **Network Segmentation**: Lack of proper network isolation
7. **Update Mechanisms**: Insecure firmware update processes
8. **Data Storage**: Sensitive data stored on device

### IoT Enumeration Techniques

| Technique | Description | Tools |
|-----------|-------------|-------|
| Port Scanning | Discover open services | nmap, masscan |
| Protocol Analysis | Identify communication protocols | mqtt, coap-cli |
| Banner Grabbing | Identify device software/version | nmap, netcat |
| Default Credential Testing | Test factory credentials | hydra, medusa |
| Firmware Analysis | Extract and analyze firmware | binwalk, firmware-mod-kit |
| Network Sniffing | Capture and analyze traffic | wireshark, tcpdump |

## Prerequisites

Before beginning IoT device discovery, ensure you have:
- Access to tools: nmap, masscan, curl, jq
- Understanding of IoT protocols (MQTT, CoAP, BLE)
- Familiarity with common IoT device manufacturers
- Knowledge of default credentials for common devices
- Access to Shodan, Censys, or similar search engines
- Understanding of network scanning techniques
- Knowledge of firmware analysis tools
- Familiarity with industrial control systems (if applicable)

## Methodology

### Phase 1: Shodan IoT Scanning

**Basic Shodan Queries**

```bash
# Search for target organization's devices
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com" | jq '.ips[] | {ip: .ip_str, port: .port, product: .product, version: .version}'

# Search for specific device types
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+product:camera" | jq '.ips[] | {ip: .ip_str, port: .port, product: .product}'

# Search for MQTT brokers
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+port:1883" | jq '.ips[] | {ip: .ip_str, port: .port}'

# Search for CoAP endpoints
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+port:5683" | jq '.ips[] | {ip: .ip_str, port: .port}'
```

**Advanced Shodan Queries**

```bash
# Search for specific device manufacturers
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+manufacturer:Siemens" | jq '.ips[] | {ip: .ip_str, port: .port, product: .product}'

# Search for industrial devices
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+port:502" | jq '.ips[] | {ip: .ip_str, port: .port, product: .product}'

# Search for MQTT brokers with anonymous access
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+product:MQTT+anonymous:true" | jq '.ips[] | {ip: .ip_str, port: .port}'

# Search for default credentials
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+authentication:disabled" | jq '.ips[] | {ip: .ip_str, port: .port, product: .product}'
```

### Phase 2: Censys Device Discovery

**Censys Search**

```bash
# Search for IoT devices
curl -s -X POST "https://search.censys.io/api/v2/hosts/search" \
  -H "Authorization: Basic $(echo -n 'YOUR_API_ID:YOUR_API_SECRET' | base64)" \
  -H "Content-Type: application/json" \
  -d '{"q": "target.com", "per_page": 100}' | jq '.result.hits[] | {ip: .ip, services: .services}'

# Search for specific services
curl -s -X POST "https://search.censys.io/api/v2/hosts/search" \
  -H "Authorization: Basic $(echo -n 'YOUR_API_ID:YOUR_API_SECRET' | base64)" \
  -H "Content-Type: application/json" \
  -d '{"q": "target.com AND services.port:1883", "per_page": 100}' | jq '.result.hits[] | {ip: .ip, services: .services}'

# Search for MQTT brokers
curl -s -X POST "https://search.censys.io/api/v2/hosts/search" \
  -H "Authorization: Basic $(echo -n 'YOUR_API_ID:YOUR_API_SECRET' | base64)" \
  -H "Content-Type: application/json" \
  -d '{"q": "target.com AND services.service_name:MQTT", "per_page": 100}' | jq '.result.hits[] | {ip: .ip, services: .services}'
```

### Phase 3: MQTT Broker Enumeration

**Discover MQTT Brokers**

```bash
# Scan for MQTT brokers on target network
nmap -sV -p 1883,8883 target.com/24 --script=mqtt-subscript

# Use masscan for fast scanning
masscan target.com/24 -p 1883,8883 --rate=1000 -oJ mqtt_scan.json

# Test MQTT broker connectivity
mosquitto_sub -h target_broker -t '#' -v -W 5

# Check for anonymous access
mosquitto_sub -h target_broker -t '$SYS/#' -v -W 5
```

**Enumerate MQTT Topics**

```bash
# Subscribe to all topics
mosquitto_sub -h target_broker -t '#' -v -C 100 > mqtt_topics.txt

# Enumerate common topics
for topic in "home/#" "devices/#" "sensors/#" "data/#" "config/#" "status/#"; do
  echo "=== Subscribing to $topic ==="
  mosquitto_sub -h target_broker -t "$topic" -v -W 10
done

# Check for common IoT topics
mosquitto_sub -h target_broker -t 'home/+/+' -v -W 10
mosquitto_sub -h target_broker -t 'devices/+/status' -v -W 10
mosquitto_sub -h target_broker -t 'sensors/+/data' -v -W 10
```

**Test MQTT Security**

```bash
# Test for anonymous access
mosquitto_pub -h target_broker -t 'test/topic' -m 'test_message'

# Test for weak credentials
for user in admin root test user; do
  for pass in admin password 123456 test; do
    mosquitto_pub -h target_broker -t 'test' -m 'test' -u "$user" -P "$pass" 2>/dev/null && echo "Success: $user:$pass"
  done
done

# Test for wildcard subscription
mosquitto_sub -h target_broker -t '$SYS/#' -v -W 5
```

### Phase 4: CoAP Endpoint Discovery

**Discover CoAP Endpoints**

```bash
# Scan for CoAP services
nmap -sU -p 5683 target.com/24 --script=coap-resources

# Use coap-cli to enumerate endpoints
coap-client -m get coap://target_device/

# Enumerate common resources
for resource in "/.well-known/core" "/admin" "/config" "/status" "/data"; do
  echo "=== Checking $resource ==="
  coap-client -m get "coap://target_device${resource}"
done

# Check for DTLS (CoAP over DTLS)
coap-client -m get coaps://target_device/
```

**Enumerate CoAP Resources**

```bash
# Get resource discovery
coap-client -m get coap://target_device/.well-known/core

# Parse resource links
coap-client -m get coap://target_device/.well-known/core | tr ',' '\n' | grep -oP '<[^>]+>'

# Test different methods
coap-client -m put coap://target_device/config -d "test"
coap-client -m post coap://target_device/data -d "test"
coap-client -m delete coap://target_device/data
```

### Phase 5: IoT Fingerprinting

**Identify Device Types**

```bash
# Banner grabbing
nmap -sV -p 1-65535 target_device --open

# HTTP fingerprinting
curl -sI http://target_device/ | grep -i 'server\|x-powered-by\|x-device'

# SNMP fingerprinting
snmpwalk -v2c -c public target_device system

# SSH fingerprinting
ssh-keyscan target_device

# MQTT fingerprinting
mosquitto_sub -h target_device -t '$SYS/#' -v -W 5
```

**Identify Firmware Versions**

```bash
# Check for firmware update endpoints
curl -s http://target_device/firmware
curl -s http://target_device/update
curl -s http://target_device/upgrade

# Check for version information
curl -s http://target_device/api/version
curl -s http://target_device/status | grep -i version

# Extract firmware from web interface
curl -s http://target_device/firmware.bin -o firmware.bin
binwalk firmware.bin
```

### Phase 6: Protocol Analysis

**MQTT Protocol Analysis**

```bash
# Capture MQTT traffic
tcpdump -i eth0 port 1883 -w mqtt_capture.pcap

# Analyze MQTT packets
tshark -r mqtt_capture.pcap -Y mqtt -T fields -e mqtt.topic -e mqtt.payload

# Decode MQTT messages
tshark -r mqtt_capture.pcap -Y mqtt.msgtype==3 -T fields -e mqtt.topic -e mqtt.payload
```

**CoAP Protocol Analysis**

```bash
# Capture CoAP traffic
tcpdump -i eth0 port 5683 -w coap_capture.pcap

# Analyze CoAP packets
tshark -r coap_capture.pcap -Y coap -T fields -e coap.code -e coap.uri_path

# Decode CoAP messages
tshark -r coap_capture.pcap -Y coap.msgtype==0 -T fields -e coap.code -e coap.payload
```

### Phase 7: Complete IoT Discovery Workflow

```bash
#!/bin/bash
# iot_discovery.sh - Complete IoT device discovery workflow

TARGET=$1
OUTPUT_DIR="iot_discovery_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting IoT device discovery for $TARGET"

# Step 1: Shodan search
echo "[+] Searching Shodan..."
curl -s "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=org:$TARGET" | jq '.ips[] | {ip: .ip_str, ports: .ports, products: [.data[].product]}' > "$OUTPUT_DIR/shodan_results.json"

# Step 2: Censys search
echo "[+] Searching Censys..."
curl -s -X POST "https://search.censys.io/api/v2/hosts/search" \
  -H "Authorization: Basic $(echo -n '$CENSYS_API_ID:$CENSYS_API_SECRET' | base64)" \
  -H "Content-Type: application/json" \
  -d "{\"q\": \"$TARGET\", \"per_page\": 100}" | jq '.result.hits[] | {ip: .ip, services: .services}' > "$OUTPUT_DIR/censys_results.json"

# Step 3: Port scanning
echo "[+] Running port scans..."
nmap -sV -p 80,443,1883,8883,5672,5683,161,162,22,23,21,25,110,143,993,995,3389,5900,5985,5986 $TARGET -oN "$OUTPUT_DIR/nmap_results.txt"

# Step 4: MQTT enumeration
echo "[+] Enumerating MQTT brokers..."
for port in 1883 8883; do
  if nmap -p $port $TARGET | grep -q "open"; then
    echo "  Found MQTT on port $port"
    mosquitto_sub -h $TARGET -p $port -t '#' -v -W 10 > "$OUTPUT_DIR/mqtt_topics.txt" 2>/dev/null
  fi
done

# Step 5: CoAP enumeration
echo "[+] Enumerating CoAP endpoints..."
if nmap -sU -p 5683 $TARGET | grep -q "open"; then
  echo "  Found CoAP on port 5683"
  coap-client -m get "coap://$TARGET/.well-known/core" > "$OUTPUT_DIR/coap_resources.txt" 2>/dev/null
fi

# Step 6: Device fingerprinting
echo "[+] Fingerprinting devices..."
for ip in $(jq -r '.[].ip' "$OUTPUT_DIR/shodan_results.json"); do
  echo "  Fingerprinting $ip..."
  nmap -sV -p 1-1000 $ip --open -oN "$OUTPUT_DIR/fingerprint_${ip}.txt"
done

# Step 7: Generate report
echo "[+] Generating report..."
echo "=== IoT Device Discovery Report ===" > "$OUTPUT_DIR/report.txt"
echo "Target: $TARGET" >> "$OUTPUT_DIR/report.txt"
echo "Date: $(date)" >> "$OUTPUT_DIR/report.txt"
echo "" >> "$OUTPUT_DIR/report.txt"
echo "Devices found: $(jq 'length' "$OUTPUT_DIR/shodan_results.json")" >> "$OUTPUT_DIR/report.txt"
echo "MQTT brokers found: $(grep -c "Found MQTT" "$OUTPUT_DIR/report.txt" 2>/dev/null || echo 0)" >> "$OUTPUT_DIR/report.txt"
echo "CoAP endpoints found: $(grep -c "Found CoAP" "$OUTPUT_DIR/report.txt" 2>/dev/null || echo 0)" >> "$OUTPUT_DIR/report.txt"

echo "[*] Discovery complete. Results saved to $OUTPUT_DIR/"
```

## Tool Arsenal

### Network Scanning Tools

**nmap**
```bash
# Basic port scan
nmap -sV target.com/24

# IoT-specific scan
nmap -sV -p 80,443,1883,8883,5672,5683,161,162,22,23 target.com/24

# Service detection
nmap -sV --version-intensity 5 target_device

# Script scanning
nmap --script=mqtt-subscript,coap-resources target.com/24
```

**masscan**
```bash
# Fast port scan
masscan target.com/24 -p 1-65535 --rate=10000 -oJ scan.json

# Specific IoT ports
masscan target.com/24 -p 1883,8883,5672,5683 --rate=1000 -oJ iot_scan.json
```

### IoT Protocol Tools

**mosquitto (MQTT)**
```bash
# Subscribe to topics
mosquitto_sub -h broker -t '#' -v

# Publish messages
mosquitto_pub -h broker -t 'test/topic' -m 'test'

# With authentication
mosquitto_sub -h broker -t '#' -u username -P password
```

**coap-cli (CoAP)**
```bash
# GET request
coap-client -m get coap://target/

# POST request
coap-client -m post coap://target/ -d "data"

# With DTLS
coap-client -m get coaps://target/
```

### Shodan and Censys Tools

**Shodan CLI**
```bash
# Search for devices
shodan search "org:target.com"

# Get host information
shodan host IP_ADDRESS

# Download results
shodan download target_devices "org:target.com"
```

**Censys CLI**
```bash
# Search for hosts
censys search "target.com"

# Get host details
censys details IP_ADDRESS
```

### Custom Scripts

**IoT Discovery Script**
```bash
#!/bin/bash
# iot_scanner.sh - Comprehensive IoT device scanner

TARGET=$1
OUTPUT="iot_scan_$(date +%Y%m%d).json"

echo '{"scan_date":"'$(date)'","target":"'$TARGET'","devices":[' > "$OUTPUT"

# Scan common IoT ports
nmap -sV -p 80,443,1883,8883,5672,5683,161,162,22,23 $TARGET -oG - | \
  grep "open" | while read line; do
    ip=$(echo $line | awk '{print $2}')
    ports=$(echo $line | grep -oP '\d+/open' | cut -d'/' -f1)
    echo "{\"ip\":\"$ip\",\"ports\":[$(echo $ports | sed 's/ /,/g')]},"
  done

echo '],"scan_complete":true}' >> "$OUTPUT"
```

## Case Studies

### Case Study 1: Anonymous MQTT Broker

**Discovery**: An MQTT broker was discovered on port 1883 with anonymous access enabled. Subscribing to the '#' topic revealed sensitive data from thousands of IoT devices.

**Impact**:
1. Access to sensitive sensor data
2. Ability to publish malicious commands
3. Device control and manipulation
4. Data exfiltration from connected devices

**Methodology**:
```bash
# Discover MQTT broker
nmap -sV -p 1883 target.com

# Test anonymous access
mosquitto_sub -h target_broker -t '#' -v -W 30

# Enumerate topics
mosquitto_sub -h target_broker -t 'home/#' -v -W 30
mosquitto_sub -h target_broker -t 'devices/#' -v -W 30
```

### Case Study 2: Default Credentials on IoT Camera

**Discovery**: An IP camera was discovered with default credentials (admin:admin), providing access to live video feeds and device configuration.

**Impact**:
1. Unauthorized video surveillance access
2. Device configuration modification
3. Potential for physical security bypass
4. Privacy violation

### Case Study 3: Industrial Control System Exposure

**Discovery**: A Modbus TCP interface was discovered on port 502, providing access to industrial control systems without authentication.

**Impact**:
1. Control of industrial processes
2. Safety system manipulation
3. Production disruption
4. Physical damage potential

### Case Study 4: CoAP Resource Discovery

**Discovery**: A CoAP endpoint was discovered with resource discovery enabled, revealing device configuration and sensor data endpoints.

**Impact**:
1. Device configuration access
2. Sensor data extraction
3. Firmware update manipulation
4. Device impersonation

### Case Study 5: MQTT Command Injection

**Discovery**: An MQTT broker with weak credentials allowed subscription to command topics, enabling injection of malicious commands to connected devices.

**Impact**:
1. Device control and manipulation
2. Data exfiltration
3. Service disruption
4. Lateral movement to other devices

## Advanced Techniques

### Firmware Extraction and Analysis

```bash
# Extract firmware from web interface
curl -s http://target_device/firmware.bin -o firmware.bin

# Analyze firmware with binwalk
binwalk firmware.bin

# Extract filesystem
binwalk -e firmware.bin

# Search for credentials in firmware
grep -r -i "password\|secret\|key\|token" _firmware.bin.extracted/

# Analyze firmware with Firmware Analysis Toolkit
fat-firmware-analyzer firmware.bin
```

### MQTT Man-in-the-Middle

```bash
# Capture MQTT traffic
tcpdump -i eth0 port 1883 -w mqtt_mitm.pcap

# Decode MQTT messages
tshark -r mqtt_mitm.pcap -Y mqtt -T fields -e mqtt.topic -e mqtt.payload

# Replay MQTT messages
mosquitto_pub -h broker -t 'target/topic' -m 'malicious_command'
```

### CoAP Observation Attack

```bash
# Observe CoAP resources
coap-client -m get coap://target/data -o observe

# Watch for changes
coap-client -m get coap://target/data -o observe -s 10

# Inject malicious observations
coap-client -m put coap://target/config -d "malicious_config"
```

## Detection Signatures

### Known IoT Device Patterns

| Device Type | Common Ports | Default Credentials |
|-------------|--------------|---------------------|
| IP Camera | 80, 443, 554, 8080 | admin:admin |
| Router | 80, 443, 22, 23 | admin:admin |
| NAS | 80, 443, 22, 5000 | admin:admin |
| Smart Lock | 80, 443, 8080 | admin:admin |
| PLC | 502, 102, 44812 | Various |
| MQTT Broker | 1883, 8883 | Often anonymous |

### Protocol Fingerprints

| Protocol | Port | Banner Pattern |
|----------|------|----------------|
| MQTT | 1883 | MQTT protocol version |
| CoAP | 5683 | CoAP header |
| Modbus | 502 | Modbus/TCP header |
| BACnet | 47808 | BACnet header |
| SNMP | 161 | SNMP response |

## Impact Assessment

IoT device discovery can reveal:
1. **Unsecured Devices**: Devices with default or weak credentials
2. **Sensitive Data**: Sensor data, personal information
3. **Control Systems**: Industrial control system access
4. **Network Topology**: Internal network structure
5. **Physical Access**: Access to physical systems
6. **Compliance Violations**: Unsecured medical or industrial devices
7. **Supply Chain Risk**: Third-party device vulnerabilities
8. **Privacy Violations**: Surveillance and monitoring capabilities

## Common Pitfalls

1. **Network segmentation**: IoT devices may be on isolated networks
2. **Protocol complexity**: Some protocols require specialized tools
3. **Device diversity**: Wide variety of devices and protocols
4. **Legal considerations**: Accessing certain devices may have legal implications
5. **Safety concerns**: Industrial devices may be safety-critical
6. **Encryption**: Some devices use encryption that may be difficult to bypass
7. **Rate limiting**: Some devices may have rate limiting
8. **Device lockout**: Failed authentication attempts may lock out devices

## Integration with Other Recon Activities

IoT device discovery connects to:
- **Subdomain enumeration**: IoT devices on subdomains
- **API documentation discovery**: IoT API endpoints
- **Cloud infrastructure discovery**: Cloud-connected IoT devices
- **Network scanning**: Internal network IoT devices
- **Firmware analysis**: Device software vulnerabilities
- **Protocol analysis**: Communication security

## Reporting

### IoT Discovery Report Template

```markdown
# IoT Device Discovery Report

## Executive Summary
- Total devices discovered: X
- Critical findings: X
- Unsecured devices: X
- Sensitive data exposed: X

## Device Inventory

### MQTT Brokers
| IP Address | Port | Anonymous Access | Topics Found |
|------------|------|------------------|--------------|
| 192.168.1.100 | 1883 | Yes | 100+ |

### CoAP Endpoints
| IP Address | Port | Resources | Authentication |
|------------|------|-----------|----------------|
| 192.168.1.101 | 5683 | 10 | None |

### Industrial Devices
| IP Address | Port | Protocol | Device Type |
|------------|------|----------|-------------|
| 192.168.1.102 | 502 | Modbus | PLC |

## Security Findings

### Default Credentials
| Device | Username | Password | Risk Level |
|--------|----------|----------|------------|
| Camera | admin | admin | High |

### Unencrypted Communication
| Device | Protocol | Data Exposed | Risk Level |
|--------|----------|--------------|------------|
| Sensor | MQTT | Sensor data | Medium |

## Recommendations
1. Change all default credentials
2. Implement encryption for all communications
3. Segment IoT devices on separate networks
4. Implement authentication for all services
5. Regular firmware updates
```

## Labs

### Lab 1: MQTT Enumeration
1. Set up a test MQTT broker with anonymous access
2. Subscribe to all topics and enumerate data
3. Test for weak credentials
4. Document all findings

### Lab 2: CoAP Discovery
1. Set up a test CoAP endpoint
2. Enumerate all resources
3. Test for authentication
4. Document device capabilities

### Lab 3: Firmware Analysis
1. Extract firmware from a test device
2. Analyze with binwalk
3. Search for credentials
4. Identify vulnerabilities

### Lab 4: Protocol Analysis
1. Capture MQTT traffic
2. Decode and analyze messages
3. Identify sensitive data
4. Document findings

## Ethics

IoT device discovery should be conducted ethically:

1. **Authorization**: Only scan devices you have permission to test
2. **Safety**: Do not interfere with safety-critical systems
3. **Data Handling**: Treat discovered data responsibly
4. **No Exploitation**: Do not exploit vulnerabilities for unauthorized access
5. **Responsible Disclosure**: Report findings through proper channels
6. **Privacy**: Respect privacy of individuals using IoT devices
7. **Scope**: Stay within the defined scope of engagement
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Search Shodan for IoT devices
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com"

# Search for MQTT brokers
curl -s "https://api.shodan.io/shodan/host/search?key=YOUR_API_KEY&query=org:target.com+port:1883"

# Scan for IoT ports
nmap -sV -p 80,443,1883,8883,5672,5683,161,162,22,23 target.com/24

# Subscribe to MQTT topics
mosquitto_sub -h broker -t '#' -v

# Test MQTT anonymous access
mosquitto_pub -h broker -t 'test' -m 'test'

# Enumerate CoAP resources
coap-client -m get coap://target/.well-known/core

# Capture MQTT traffic
tcpdump -i eth0 port 1883 -w mqtt.pcap

# Analyze MQTT traffic
tshark -r mqtt.pcap -Y mqtt -T fields -e mqtt.topic -e mqtt.payload

# Extract firmware
curl -s http://target/firmware.bin -o firmware.bin
binwalk firmware.bin

# Search for default credentials
hydra -l admin -P passwords.txt target_device http-get /

# Fast port scan
masscan target.com/24 -p 1883,8883,5672,5683 --rate=1000
```
