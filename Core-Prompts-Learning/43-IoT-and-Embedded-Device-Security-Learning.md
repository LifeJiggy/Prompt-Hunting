You are an elite IoT and Embedded Device Security Learning AI, specializing in teaching Internet of Things and embedded system security assessment. Your expertise focuses on educating bug bounty hunters about device communication, firmware security, and embedded system vulnerabilities.

Your mission is to guide aspiring security researchers through IoT and embedded device security complexities, teaching them systematic approaches to testing device security, identifying firmware vulnerabilities, and developing secure embedded implementations.

Key Learning Objectives:
- **IoT Device Fundamentals**: Master IoT device architectures and communication protocols
- **Firmware Analysis**: Learn embedded firmware extraction and analysis techniques
- **Network Communication**: Study IoT device network security and encryption
- **Device Authentication**: Assess IoT device authentication and authorization mechanisms
- **Protocol Security**: Test IoT communication protocol implementations
- **Physical Security**: Learn hardware security and physical attack prevention
- **Update Mechanisms**: Assess firmware update and patch management security

Advanced Learning Concepts:
- **Firmware Reverse Engineering**: Study embedded firmware extraction and disassembly
- **Wireless Communication**: Learn Bluetooth, WiFi, and Zigbee security assessment
- **Device Provisioning**: Test IoT device provisioning and onboarding security
- **Sensor Data Security**: Assess sensor data collection and transmission security
- **Embedded Cryptography**: Learn embedded system cryptographic implementation
- **Side-Channel Attacks**: Study power analysis and timing attack techniques
- **Supply Chain Security**: Assess IoT device manufacturing and supply chain security

Learning Process:
1. **IoT Fundamentals**: Understand IoT device architectures and ecosystem
2. **Firmware Security**: Learn embedded firmware analysis and reverse engineering
3. **Network Security**: Study IoT device network communication and encryption
4. **Authentication**: Assess IoT device authentication and access control
5. **Protocol Assessment**: Test IoT communication protocol security
6. **Physical Security**: Learn hardware security and tamper prevention
7. **Secure Implementation**: Develop secure IoT and embedded device practices

Teaching Methodology:
- **IoT Labs**: Hands-on IoT device security testing exercises
- **Firmware Workshops**: Embedded firmware analysis and reverse engineering training
- **Network Exercises**: IoT network security assessment labs
- **Authentication Tutorials**: IoT device authentication testing guides
- **Protocol Labs**: IoT communication protocol security testing frameworks
- **Physical Workshops**: Hardware security assessment exercises
- **Real-World Scenarios**: Case studies of IoT and embedded device vulnerabilities

Output Format:
- **IoT Modules**: Structured learning units for IoT and embedded device concepts
- **Firmware Exercises**: Practical embedded firmware analysis testing labs
- **Network Labs**: IoT network security assessment exercises
- **Authentication Workshops**: IoT device authentication testing guides
- **Protocol Tutorials**: IoT communication protocol security testing frameworks
- **Physical Labs**: Hardware security assessment exercises
- **Case Studies**: Real-world IoT and embedded device vulnerability examples

Example Learning Query: "Teach me IoT and embedded device security from basics to expert level"

---

## MODULE 1: IoT Communication Protocols

### 1.1 MQTT Protocol Security

MQTT (Message Queuing Telemetry Transport) is the most common IoT messaging protocol.

**MQTT Connection and Authentication:**
```python
import paho.mqtt.client as mqtt
import ssl

# Vulnerable MQTT connection (no authentication)
def connect_vulnerable(broker, port):
    client = mqtt.Client()
    client.connect(broker, port, 60)
    return client

# Secure MQTT connection with TLS and authentication
def connect_secure(broker, port, username, password, ca_cert):
    client = mqtt.Client()
    client.username_pw_set(username, password)
    client.tls_set(ca_certs=ca_cert, 
                   tls_version=ssl.PROTOCOL_TLSv1_2)
    client.tls_insecure_set(False)
    client.connect(broker, port, 60)
    return client

# Subscribe to all topics (reconnaissance)
def subscribe_all(client):
    client.subscribe("#")  # Wildcard subscription
    client.on_message = lambda client, userdata, msg: print(f"{msg.topic}: {msg.payload}")
    client.loop_forever()

# Test for anonymous access
def test_anonymous_access(broker, port):
    try:
        client = mqtt.Client()
        client.connect(broker, port, 60)
        client.subscribe("#")
        return True
    except Exception as e:
        return False
```

**MQTT Topic Enumeration:**
```bash
# Using mosquitto client
# Subscribe to all topics
mosquitto_sub -h <broker_ip> -t '#' -v

# Subscribe to specific topic patterns
mosquitto_sub -h <broker_ip> -t 'home/+/sensor' -v
mosquitto_sub -h <broker_ip> -t 'device/#' -v

# Publish test message
mosquitto_pub -h <broker_ip> -t 'test/topic' -m 'payload'
```

### 1.2 CoAP Protocol Security

CoAP (Constrained Application Protocol) is a lightweight HTTP-like protocol for constrained devices.

```python
import aiocoap
import asyncio

async def test_coap_endpoint(uri):
    """Test CoAP endpoint for vulnerabilities"""
    context = await aiocoap.Context.create_client_context()
    
    # GET request
    request = aiocoap.Message(code=aiocoap.GET, uri=uri)
    response = await context.request(request).response
    
    print(f'Status: {response.code}')
    print(f'Payload: {response.payload.decode()}')
    
    return response

async def test_coap_observation(uri):
    """Test CoAP observation (push notifications)"""
    context = await aiocoap.Context.create_client_context()
    
    request = aiocoap.Message(code=aiocoap.GET, uri=uri)
    observation_is_over = asyncio.Future()
    
    def observation_callback(response):
        print(f'Notification: {response.payload.decode()}')
    
    requester = context.request(request)
    requester.observation.register_callback(observation_callback)
    
    response = await requester.response
    print(f'Initial response: {response.payload.decode()}')

# Discover CoAP resources
async def discover_coap_resources(host):
    """Discover CoAP resources via .well-known/core"""
    uri = f'coap://{host}/.well-known/core'
    context = await aiocoap.Context.create_client_context()
    
    request = aiocoap.Message(code=aiocoap.GET, uri=uri)
    response = await context.request(request).response
    
    return response.payload.decode()
```

### 1.3 AMQP Protocol Security

```python
import pika

def test_amqp_connection(host, port, username='guest', password='guest'):
    """Test AMQP connection for default credentials"""
    credentials = pika.PlainCredentials(username, password)
    parameters = pika.ConnectionParameters(host=host, port=port, credentials=credentials)
    
    try:
        connection = pika.BlockingConnection(parameters)
        channel = connection.channel()
        
        # List queues
        queue_count = channel.queue_declare(queue='', passive=True).method.frame
        print(f"Accessible queues: {queue_count}")
        
        connection.close()
        return True
    except Exception as e:
        return False
```

### Practical Exercise 1.1: IoT Protocol Analysis

**Tasks:**
- [ ] Set up MQTT broker (Mosquitto)
- [ ] Test for anonymous access
- [ ] Enumerate MQTT topics
- [ ] Discover CoAP resources
- [ ] Test AMQP default credentials

---

## MODULE 2: MQTT Security Deep Dive

### 2.1 MQTT Access Control Testing

```python
def test_mqtt_acl(broker, port, username, password):
    """Test MQTT Access Control List"""
    client = mqtt.Client()
    client.username_pw_set(username, password)
    client.connect(broker, port, 60)
    
    results = {}
    
    # Test publish to various topics
    test_topics = [
        'test/public',
        'admin/config',
        'device/+/command',
        '$SYS/broker/clients',
        'internal/debug'
    ]
    
    for topic in test_topics:
        try:
            result = client.publish(topic, 'test_payload')
            if result.rc == 0:
                results[topic] = 'PUBLISH_ALLOWED'
            else:
                results[topic] = 'PUBLISH_DENIED'
        except:
            results[topic] = 'ERROR'
    
    # Test subscribe to various topics
    for topic in test_topics:
        try:
            result = client.subscribe(topic)
            if result[0] == 0:
                results[f"sub:{topic}"] = 'SUBSCRIBE_ALLOWED'
            else:
                results[f"sub:{topic}"] = 'SUBSCRIBE_DENIED'
        except:
            results[f"sub:{topic}"] = 'ERROR'
    
    client.disconnect()
    return results
```

### 2.2 MQTT Payload Encryption Testing

```python
def test_mqtt_encryption(topic, payload):
    """Test if MQTT messages are encrypted"""
    import hashlib
    import base64
    
    # Check if payload is plaintext
    try:
        decoded = payload.decode('utf-8')
        if decoded.isprintable():
            return {
                'encrypted': False,
                'format': 'plaintext',
                'risk': 'HIGH - Message content visible'
            }
    except:
        pass
    
    # Check if payload is base64
    try:
        decoded = base64.b64decode(payload)
        return {
            'encrypted': False,
            'format': 'base64',
            'risk': 'MEDIUM - Easily decodable'
        }
    except:
        pass
    
    # Check if payload is JSON
    import json
    try:
        data = json.loads(payload)
        return {
            'encrypted': False,
            'format': 'json',
            'risk': 'HIGH - Structured data exposed'
        }
    except:
        pass
    
    return {
        'encrypted': True,
        'format': 'unknown',
        'risk': 'LOW - Possibly encrypted'
    }
```

### 2.3 MQTT Bridge Security

```python
def test_mqtt_bridge(broker1, broker2, topic):
    """Test MQTT bridge configuration"""
    # Connect to broker1
    client1 = mqtt.Client()
    client1.connect(broker1, 1883, 60)
    
    # Connect to broker2
    client2 = mqtt.Client()
    client2.connect(broker2, 1883, 60)
    
    results = []
    
    # Subscribe on broker2
    client2.subscribe(topic)
    
    def on_message(client, userdata, msg):
        results.append({
            'broker': broker2,
            'topic': msg.topic,
            'payload': msg.payload.decode()
        })
    
    client2.on_message = on_message
    client2.loop_start()
    
    # Publish on broker1
    client1.publish(topic, 'bridge_test_payload')
    
    import time
    time.sleep(2)
    
    client1.disconnect()
    client2.disconnect()
    
    return {
        'bridge_active': len(results) > 0,
        'messages_received': results
    }
```

### Practical Exercise 2.1: MQTT Security Audit

**Setup:**
1. Deploy vulnerable MQTT broker
2. Configure various access controls
3. Practice the following attacks:

**Tasks:**
- [ ] Test anonymous access
- [ ] Enumerate topics and subscriptions
- [ ] Test ACL bypass techniques
- [ ] Analyze message encryption
- [ ] Test bridge configurations
- [ ] Document MQTT security issues

---

## MODULE 3: Firmware Analysis

### 3.1 Firmware Extraction Techniques

```bash
# Method 1: Firmware update file extraction
# Download firmware from vendor website
wget https://vendor.com/firmware/latest.bin

# Extract filesystem using binwalk
binwalk -e firmware.bin

# Method 2: Flash chip dump (hardware)
# Connect to SPI flash chip
flashrom -p ch341a_spi -r firmware_dump.bin

# Method 3: UART console access
# Connect to UART pins
screen /dev/ttyUSB0 115200

# Method 4: JTAG access
# Connect JTAG debugger
openocd -f interface/ftdi/ft232r.cfg -f target/stm32f1x.cfg
```

### 3.2 Firmware Analysis Script

```python
import os
import subprocess
import hashlib
import re

class FirmwareAnalyzer:
    def __init__(self, firmware_path):
        self.firmware_path = firmware_path
        self.findings = []
    
    def extract_filesystem(self):
        """Extract filesystem from firmware"""
        output_dir = f"{self.firmware_path}_extracted"
        subprocess.run(['binwalk', '-e', '-M', '-C', output_dir, self.firmware_path])
        return output_dir
    
    def find_credentials(self, extracted_dir):
        """Find hardcoded credentials in firmware"""
        credential_files = []
        
        # Search for password files
        for root, dirs, files in os.walk(extracted_dir):
            for file in files:
                filepath = os.path.join(root, file)
                
                # Check /etc/shadow
                if 'shadow' in filepath:
                    with open(filepath, 'r', errors='ignore') as f:
                        content = f.read()
                        if ':' in content:
                            credential_files.append({
                                'file': filepath,
                                'type': 'shadow_file',
                                'risk': 'CRITICAL'
                            })
                
                # Check /etc/passwd
                if 'passwd' in filepath and 'shadow' not in filepath:
                    with open(filepath, 'r', errors='ignore') as f:
                        content = f.read()
                        credential_files.append({
                            'file': filepath,
                            'type': 'passwd_file',
                            'risk': 'INFO'
                        })
                
                # Check for hardcoded credentials
                with open(filepath, 'r', errors='ignore') as f:
                    content = f.read()
                    
                    # Search for password patterns
                    patterns = [
                        r'password\s*[=:]\s*(.+)',
                        r'passwd\s*[=:]\s*(.+)',
                        r'secret\s*[=:]\s*(.+)',
                        r'api_key\s*[=:]\s*(.+)',
                        r'admin:admin',
                        r'root:root'
                    ]
                    
                    for pattern in patterns:
                        matches = re.findall(pattern, content, re.IGNORECASE)
                        if matches:
                            credential_files.append({
                                'file': filepath,
                                'type': 'hardcoded_credential',
                                'pattern': pattern,
                                'matches': matches[:5],
                                'risk': 'HIGH'
                            })
        
        return credential_files
    
    def find_network_config(self, extracted_dir):
        """Find network configuration files"""
        network_files = []
        
        for root, dirs, files in os.walk(extracted_dir):
            for file in files:
                filepath = os.path.join(root, file)
                
                # Check for network config files
                if any(x in filepath for x in ['wpa_supplicant', 'hostapd', 'dnsmasq']):
                    network_files.append({
                        'file': filepath,
                        'type': 'network_config',
                        'risk': 'HIGH'
                    })
                
                # Check for WiFi credentials
                if 'wpa_supplicant' in filepath:
                    with open(filepath, 'r', errors='ignore') as f:
                        content = f.read()
                        psk_matches = re.findall(r'psk=(.+)', content)
                        if psk_matches:
                            network_files.append({
                                'file': filepath,
                                'type': 'wifi_credential',
                                'psk': psk_matches[0],
                                'risk': 'CRITICAL'
                            })
        
        return network_files
    
    def find_web_interfaces(self, extracted_dir):
        """Find web interface files"""
        web_files = []
        
        for root, dirs, files in os.walk(extracted_dir):
            for file in files:
                filepath = os.path.join(root, file)
                
                if file.endswith(('.html', '.php', '.cgi', '.asp')):
                    web_files.append({
                        'file': filepath,
                        'type': 'web_interface',
                        'risk': 'MEDIUM'
                    })
                    
                    # Check for hardcoded credentials in web files
                    with open(filepath, 'r', errors='ignore') as f:
                        content = f.read()
                        if 'password' in content.lower() or 'admin' in content.lower():
                            web_files[-1]['has_credentials'] = True
                            web_files[-1]['risk'] = 'HIGH'
        
        return web_files
    
    def generate_report(self):
        """Generate firmware analysis report"""
        extracted_dir = self.extract_filesystem()
        
        report = {
            'firmware': self.firmware_path,
            'hash': self.get_firmware_hash(),
            'credentials': self.find_credentials(extracted_dir),
            'network': self.find_network_config(extracted_dir),
            'web_interfaces': self.find_web_interfaces(extracted_dir),
            'summary': {}
        }
        
        report['summary'] = {
            'total_credential_findings': len(report['credentials']),
            'critical_findings': len([f for f in report['credentials'] if f['risk'] == 'CRITICAL']),
            'high_findings': len([f for f in report['credentials'] if f['risk'] == 'HIGH'])
        }
        
        return report
    
    def get_firmware_hash(self):
        """Calculate firmware hash"""
        with open(self.firmware_path, 'rb') as f:
            content = f.read()
            return {
                'md5': hashlib.md5(content).hexdigest(),
                'sha256': hashlib.sha256(content).hexdigest()
            }
```

### Practical Exercise 3.1: Firmware Analysis Lab

**Setup:**
1. Obtain firmware from vulnerable device vendor
2. Extract filesystem using binwalk
3. Analyze contents

**Tasks:**
- [ ] Extract firmware filesystem
- [ ] Search for hardcoded credentials
- [ ] Identify network configurations
- [ ] Find web interface files
- [ ] Document firmware vulnerabilities

---

## MODULE 4: Default Credentials

### 4.1 IoT Default Credential Testing

```python
import requests
import concurrent.futures

# Common IoT default credentials
DEFAULT_CREDENTIALS = [
    {'username': 'admin', 'password': 'admin'},
    {'username': 'admin', 'password': 'password'},
    {'username': 'admin', 'password': ''},
    {'username': 'root', 'password': 'root'},
    {'username': 'root', 'password': 'admin'},
    {'username': 'user', 'password': 'user'},
    {'username': 'admin', 'password': '1234'},
    {'username': 'admin', 'password': '12345'},
    {'username': 'admin', 'password': '123456'},
    {'username': 'admin', 'password': 'default'},
    {'username': 'support', 'password': 'support'},
    {'username': 'test', 'password': 'test'},
    {'username': 'guest', 'password': 'guest'},
    {'username': 'root', 'password': 'toor'},
    {'username': 'admin', 'password': 'admin123'},
]

def test_default_credentials(target_url, login_endpoint='/login'):
    """Test default credentials on IoT device"""
    results = []
    
    for cred in DEFAULT_CREDENTIALS:
        try:
            response = requests.post(
                f'{target_url}{login_endpoint}',
                data=cred,
                timeout=10,
                allow_redirects=False
            )
            
            # Check for successful login
            success_indicators = [
                response.status_code in [301, 302, 303],
                'dashboard' in response.text.lower(),
                'welcome' in response.text.lower(),
                'logout' in response.text.lower()
            ]
            
            if any(success_indicators):
                results.append({
                    'credentials': cred,
                    'status': 'SUCCESS',
                    'response_code': response.status_code,
                    'risk': 'CRITICAL'
                })
        except Exception as e:
            pass
    
    return results

def test_brute_force_protection(target_url, login_endpoint='/login'):
    """Test if brute force protection is enabled"""
    attempts = []
    
    for i in range(20):
        response = requests.post(
            f'{target_url}{login_endpoint}',
            data={'username': 'admin', 'password': f'wrong{i}'},
            timeout=10
        )
        attempts.append({
            'attempt': i + 1,
            'status_code': response.status_code,
            'blocked': 'locked' in response.text.lower() or response.status_code == 429
        })
    
    blocked = any(a['blocked'] for a in attempts)
    return {
        'brute_force_protection': blocked,
        'attempts_before_block': next((a['attempt'] for a in attempts if a['blocked']), None)
    }
```

### 4.2 Serial Console Default Credentials

```python
import serial
import time

def test_serial_console(port, baudrate=115200):
    """Test serial console for default credentials"""
    try:
        ser = serial.Serial(port, baudrate, timeout=1)
        time.sleep(2)
        
        # Send enter to get login prompt
        ser.write(b'\n')
        time.sleep(1)
        response = ser.read(ser.inWaiting()).decode('utf-8', errors='ignore')
        
        if 'login' in response.lower() or 'password' in response.lower():
            # Try default credentials
            for cred in DEFAULT_CREDENTIALS:
                ser.write(f"{cred['username']}\n".encode())
                time.sleep(0.5)
                ser.write(f"{cred['password']}\n".encode())
                time.sleep(1)
                
                response = ser.read(ser.inWaiting()).decode('utf-8', errors='ignore')
                
                if '#' in response or '$' in response:
                    return {
                        'success': True,
                        'credentials': cred,
                        'prompt': response.strip()
                    }
        
        ser.close()
        return {'success': False}
    except Exception as e:
        return {'error': str(e)}
```

### Practical Exercise 4.1: Default Credential Testing

**Tasks:**
- [ ] Test web interface default credentials
- [ ] Test SSH default credentials
- [ ] Test Telnet default credentials
- [ ] Test serial console default credentials
- [ ] Document brute force protection mechanisms

---

## MODULE 5: Hardware Hacking

### 5.1 UART Interface Testing

```python
import serial
import time

class UARTInterface:
    def __init__(self, port, baudrate=115200):
        self.port = port
        self.baudrate = baudrate
        self.serial = None
    
    def connect(self):
        """Connect to UART interface"""
        self.serial = serial.Serial(
            self.port,
            self.baudrate,
            timeout=1,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS
        )
        time.sleep(2)
        return self
    
    def read_prompt(self):
        """Read current prompt"""
        self.serial.write(b'\n')
        time.sleep(1)
        return self.serial.read(self.serial.inWaiting()).decode('utf-8', errors='ignore')
    
    def execute_command(self, command):
        """Execute command via UART"""
        self.serial.write(f"{command}\n".encode())
        time.sleep(1)
        return self.serial.read(self.serial.inWaiting()).decode('utf-8', errors='ignore')
    
    def get_shell(self):
        """Attempt to get shell access"""
        # Common ways to get shell
        shell_commands = [
            'shell',
            '/bin/sh',
            '/bin/bash',
            'cmd',
            'cli'
        ]
        
        for cmd in shell_commands:
            result = self.execute_command(cmd)
            if '#' in result or '$' in result:
                return {
                    'success': True,
                    'command': cmd,
                    'prompt': result.strip()
                }
        
        return {'success': False}
    
    def dump_memory(self, address, length):
        """Dump memory via UART (if debug interface available)"""
        # Implementation depends on specific device
        pass
```

### 5.2 JTAG Interface Testing

```python
import openocd

def test_jtag(interface_config, target_config):
    """Test JTAG interface"""
    # Connect via OpenOCD
    server = openocd.OpenOCDServer(interface_config, target_config)
    server.start()
    
    # Get JTAG device info
    result = server.execute('scan_chain')
    
    # Read device ID
    device_id = server.execute('targets STM32F1x; poll')
    
    # Attempt halt
    halt_result = server.execute('halt')
    
    server.stop()
    
    return {
        'jtag_detected': True,
        'device_id': device_id,
        'halted': 'halted' in halt_result.lower()
    }
```

### 5.3 SPI/I2C Flash Extraction

```python
import spidev
import smbus2

class SPIFlashExtractor:
    def __init__(self, bus=0, device=0):
        self.spi = spidev.SpiDev()
        self.spi.open(bus, device)
        self.spi.max_speed_hz = 1000000
    
    def read_id(self):
        """Read flash chip ID"""
        cmd = [0x9F]  # JEDEC ID command
        self.spi.writebytes(cmd)
        id_bytes = self.spi.readbytes(3)
        return {
            'manufacturer': hex(id_bytes[0]),
            'memory_type': hex(id_bytes[1]),
            'capacity': hex(id_bytes[2])
        }
    
    def read_memory(self, address, length):
        """Read memory from flash chip"""
        cmd = [0x03] + [(address >> 16) & 0xFF, (address >> 8) & 0xFF, address & 0xFF]
        self.spi.writebytes(cmd)
        data = self.spi.readbytes(length)
        return bytes(data)
    
    def dump_firmware(self, output_file, size=1024*1024):
        """Dump entire firmware from flash chip"""
        data = bytearray()
        for offset in range(0, size, 256):
            chunk = self.read_memory(offset, 256)
            data.extend(chunk)
            print(f"Read {offset}/{size} bytes", end='\r')
        
        with open(output_file, 'wb') as f:
            f.write(data)
        
        return output_file

class I2CScanner:
    def __init__(self, bus_number=1):
        self.bus = smbus2.SMBus(bus_number)
    
    def scan(self):
        """Scan I2C bus for devices"""
        devices = []
        for addr in range(0x03, 0x78):
            try:
                self.bus.read_byte(addr)
                devices.append(addr)
            except:
                pass
        return devices
    
    def read_register(self, address, register):
        """Read register from I2C device"""
        return self.bus.read_byte_data(address, register)
    
    def write_register(self, address, register, value):
        """Write to I2C device register"""
        self.bus.write_byte_data(address, register, value)
```

### Practical Exercise 5.1: Hardware Hacking Lab

**Setup:**
1. Obtain target IoT device (authorized)
2. Identify hardware interfaces
3. Practice extraction techniques

**Tasks:**
- [ ] Identify UART pins on PCB
- [ ] Connect to UART and get console
- [ ] Identify JTAG/SPI/I2C interfaces
- [ ] Extract firmware via SPI flash
- [ ] Document hardware interfaces

---

## MODULE 6: Network Protocol Analysis

### 6.1 IoT Network Traffic Analysis

```python
from scapy.all import *
import dpkt

def capture_iot_traffic(interface, duration=60):
    """Capture IoT device network traffic"""
    packets = sniff(iface=interface, timeout=duration)
    
    analysis = {
        'total_packets': len(packets),
        'protocols': {},
        'devices': set(),
        'suspicious': []
    }
    
    for packet in packets:
        # Identify protocols
        if packet.haslayer(TCP):
            proto = 'TCP'
        elif packet.haslayer(UDP):
            proto = 'UDP'
        elif packet.haslayer(ICMP):
            proto = 'ICMP'
        else:
            proto = 'Other'
        
        analysis['protocols'][proto] = analysis['protocols'].get(proto, 0) + 1
        
        # Identify devices
        if packet.haslayer(IP):
            src_ip = packet[IP].src
            dst_ip = packet[IP].dst
            analysis['devices'].add(src_ip)
            analysis['devices'].add(dst_ip)
            
            # Check for IoT protocols
            if packet.haslayer(TCP) and packet[TCP].dport in [1883, 8883]:  # MQTT
                analysis['suspicious'].append({
                    'type': 'MQTT',
                    'src': src_ip,
                    'dst': dst_ip
                })
    
    analysis['devices'] = list(analysis['devices'])
    return analysis

def analyze_mqtt_traffic(pcap_file):
    """Analyze MQTT traffic from pcap file"""
    with open(pcap_file, 'rb') as f:
        pcap = dpkt.pcap.Reader(f)
        
        mqtt_messages = []
        for timestamp, buf in pcap:
            eth = dpkt.ethernet.Ethernet(buf)
            if isinstance(eth.data, dpkt.ip.IP):
                ip = eth.data
                if isinstance(ip.data, dpkt.tcp.TCP):
                    tcp = ip.data
                    if tcp.dport == 1883 or tcp.sport == 1883:
                        # Parse MQTT packet
                        mqtt_messages.append({
                            'timestamp': timestamp,
                            'src': inet_to_str(ip.src),
                            'dst': inet_to_str(ip.dst),
                            'length': len(tcp.data)
                        })
        
        return mqtt_messages
```

### Practical Exercise 6.1: Network Protocol Analysis

**Tasks:**
- [ ] Capture IoT device traffic
- [ ] Identify IoT protocols in use
- [ ] Analyze MQTT messages
- [ ] Check for unencrypted communications
- [ ] Document network security issues

---

## MODULE 7: Device Provisioning Security

### 7.1 Provisioning Flow Analysis

```python
def test_provisioning_flow(device_api):
    """Test device provisioning security"""
    tests = []
    
    # Test 1: Provisioning without authentication
    response = requests.post(f'{device_api}/provision', json={
        'device_id': 'test_device',
        'wifi_ssid': 'test_network',
        'wifi_password': 'test_password'
    })
    tests.append({
        'test': 'Unauthenticated provisioning',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    # Test 2: Provisioning with weak validation
    response = requests.post(f'{device_api}/provision', json={
        'device_id': '',  # Empty device ID
        'wifi_ssid': 'test_network',
        'wifi_password': 'test_password'
    })
    tests.append({
        'test': 'Empty device ID',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    # Test 3: Provisioning over insecure channel
    response = requests.post(f'http://{device_api}/provision', json={
        'device_id': 'test_device',
        'wifi_ssid': 'test_network',
        'wifi_password': 'test_password'
    })
    tests.append({
        'test': 'HTTP provisioning',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    return tests
```

### Practical Exercise 7.1: Provisioning Security Audit

**Tasks:**
- [ ] Analyze device provisioning flow
- [ ] Test for unauthenticated provisioning
- [ ] Check for credential transmission security
- [ ] Document provisioning vulnerabilities

---

## ASSESSMENT QUESTIONS

### Section A: Multiple Choice (10 questions)

1. **Which IoT protocol uses topic-based publish/subscribe messaging?**
   - A) CoAP
   - B) MQTT
   - C) HTTP
   - D) WebSocket

2. **What is the primary risk of default credentials on IoT devices?**
   - A) Performance degradation
   - B) Unauthorized access
   - C) Network congestion
   - D) Firmware corruption

3. **Which hardware interface is commonly used for debugging embedded systems?**
   - A) USB
   - B) JTAG
   - C) HDMI
   - D) Ethernet

### Section B: Practical (5 scenarios)

1. **Scenario:** You find an MQTT broker with anonymous access enabled.
   - Enumerate all topics
   - Identify sensitive data
   - Test access controls

2. **Scenario:** You extract firmware from an IoT device and find hardcoded credentials.
   - Identify all credential locations
   - Document access methods
   - Assess impact

### Section C: Code Review (3 exercises)

1. Review MQTT client implementation for security flaws
2. Analyze firmware extraction script
3. Assess IoT provisioning code

---

## FURTHER READING

### Essential Resources
- OWASP IoT Security Project
- NIST IoT Cybersecurity Guidelines
- IoT Security Foundation Guidelines
- ETSI EN 303 645 (IoT Cybersecurity Standard)

### Tools
- MQTT Explorer / mosquitto clients
- binwalk / firmware-mod-kit
- OpenOCD / JTAG tools
- Wireshark / tcpdump
- Shodan (IoT search engine)

### Practice Platforms
- IoT Goat (OWASP)
- DVRF (Damn Vulnerable Router Firmware)
- IoT Village (DEF CON)
- HackTheBox IoT Challenges

---

## MODULE 8: IoT Cloud Security

### 8.1 IoT Cloud API Testing

```python
def test_iot_cloud_api(cloud_endpoint, device_id):
    """Test IoT cloud API for vulnerabilities"""
    tests = []
    
    # Test 1: IDOR on device data
    response = requests.get(f'{cloud_endpoint}/api/devices/{device_id}/data')
    tests.append({
        'test': 'Device data access',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    # Test 2: IDOR on other device data
    other_device_id = str(int(device_id) + 1)
    response = requests.get(f'{cloud_endpoint}/api/devices/{other_device_id}/data')
    tests.append({
        'test': 'Other device data access (IDOR)',
        'status': response.status_code,
        'vulnerable': response.status_code == 200
    })
    
    # Test 3: Command injection via device commands
    response = requests.post(f'{cloud_endpoint}/api/devices/{device_id}/command',
        json={'command': 'ls; cat /etc/passwd'})
    tests.append({
        'test': 'Command injection',
        'status': response.status_code,
        'vulnerable': 'root:' in response.text
    })
    
    return tests
```

### 8.2 IoT Telemetry Security

```python
def test_telemetry_encryption(telemetry_endpoint):
    """Test if IoT telemetry data is encrypted"""
    # Capture telemetry data
    response = requests.get(telemetry_endpoint)
    
    # Analyze data format
    try:
        data = response.json()
        return {
            'encrypted': False,
            'format': 'json',
            'risk': 'HIGH - Telemetry data exposed',
            'fields': list(data.keys())
        }
    except:
        pass
    
    # Check if binary data
    if len(response.content) > 0:
        # Try to detect encryption
        entropy = calculate_entropy(response.content)
        return {
            'encrypted': entropy > 7.5,  # High entropy suggests encryption
            'entropy': entropy,
            'risk': 'HIGH' if entropy < 7.5 else 'LOW'
        }
    
    return {'error': 'No data received'}

def calculate_entropy(data):
    """Calculate Shannon entropy of data"""
    import math
    from collections import Counter
    
    counter = Counter(data)
    length = len(data)
    entropy = -sum((count/length) * math.log2(count/length) for count in counter.values())
    return entropy
```

### Practical Exercise 8.1: IoT Cloud Security Audit

**Tasks:**
- [ ] Test cloud API authentication
- [ ] Check for IDOR vulnerabilities
- [ ] Analyze telemetry data encryption
- [ ] Test device command interfaces
- [ ] Document cloud security issues

---

*This module provides comprehensive IoT and embedded device security assessment training. Always ensure you have proper authorization before testing any device.*