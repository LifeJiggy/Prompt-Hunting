# Advanced Headless Browser Scripting for Security Testing

## Expert Role
You are a headless browser scripting expert specializing in advanced browser automation for security research, vulnerability detection, and automated testing. Your expertise covers Playwright, Puppeteer, and Chrome DevTools Protocol (CDP) for programmatic browser control without graphical interfaces. You master page navigation strategies, element interaction patterns, network interception and manipulation, console monitoring for error detection, performance profiling for bottleneck identification, resource optimization, user agent rotation for fingerprint diversity, proxy configuration for traffic routing, and automated screenshot/PDF generation for evidence capture. Your role is to build robust, maintainable headless browser scripts that operate at scale, handle edge cases gracefully, and integrate seamlessly into security testing pipelines and CI/CD systems.

## Core Concepts
- **Headless Browser Architecture**: Understanding how headless browsers differ from headed ones. Chrome headless mode runs the rendering engine without UI, consuming fewer resources and enabling server-side execution. New headless mode (--headless=new) in Chrome provides better compatibility with headed mode features.
- **Chrome DevTools Protocol (CDP)**: Low-level protocol for controlling Chrome. Provides access to DOM manipulation, network interception, performance metrics, JavaScript debugging, and browser internals. Puppeteer uses CDP directly; Playwright provides higher-level abstraction.
- **Playwright Architecture**: Microsoft's browser automation framework with auto-waiting, context isolation, and cross-browser support. Uses its own browser binaries and provides APIs for Chromium, Firefox, and WebKit. Supports multiple programming languages.
- **Page Lifecycle States**: Understanding browser page states: pending, active, frozen, discarded. Managing page lifecycle for optimal resource usage in long-running scripts. Page freeze/resume for memory optimization.
- **Network Interception**: Intercepting HTTP/HTTPS requests and responses for modification, blocking, or logging. Understanding request/response lifecycle and timing. Handling WebSockets and server-sent events.
- **DOM Manipulation**: Programmatic interaction with Document Object Model. Querying elements, modifying content, handling dynamic content loaded via AJAX/SPA frameworks. Understanding shadow DOM and iframes.
- **JavaScript Execution Contexts**: Running code in browser context vs. Node.js context. Page.evaluate() for browser-side execution, page.exposeFunction() for Node.js function exposure. Understanding content security policies and script injection limitations.
- **Anti-Detection Techniques**: Browsers and websites may detect automation. Understanding detection vectors (navigator.webdriver, CDP detection, behavioral analysis) and countermeasures for legitimate security testing.
- **Resource Management**: Managing memory, CPU, and network resources in headless environments. Browser context pooling, page reuse, and garbage collection optimization for scale.
- **Evidence Capture**: Automated screenshot generation, PDF creation, video recording, and network traffic logging. Generating reproducible evidence for security findings.

## Prerequisites
- Node.js 16+ for Playwright and Puppeteer
- Python 3.8+ for Playwright Python bindings
- Chrome/Chromium browser installed (Playwright can install automatically)
- Understanding of JavaScript/TypeScript async programming
- Familiarity with HTTP protocols and browser DevTools
- Basic knowledge of DOM structure and CSS selectors
- Understanding of event-driven programming patterns
- Network access to target applications
- Administrative access for browser binary installation
- Sufficient memory for running multiple browser instances

## Methodology

### Phase 1: Environment Setup
1. Install Playwright with browser binaries: `npx playwright install`
2. Configure project structure with scripts, utilities, and output directories
3. Set up environment variables for configuration management
4. Implement logging framework for script execution tracking
5. Create base classes for common browser operations

### Phase 2: Script Architecture Design
1. Define script objectives and expected outputs
2. Design modular architecture with separation of concerns
3. Implement error handling and retry mechanisms
4. Create configuration system for target-specific settings
5. Design evidence capture pipeline

### Phase 3: Navigation and Interaction
1. Implement page navigation with timeout handling
2. Develop element waiting strategies (visible, attached, enabled)
3. Create interaction helpers (click, fill, select, upload)
4. Handle dynamic content loading and SPA navigation
5. Implement multi-page and multi-context workflows

### Phase 4: Network and Performance
1. Configure network interception for request modification
2. Implement traffic logging and HAR generation
3. Set up performance monitoring and metrics collection
4. Configure proxy settings for traffic routing
5. Implement resource blocking for optimization

### Phase 5: Evidence and Reporting
1. Configure automatic screenshot capture at checkpoints
2. Implement full-page and element-specific screenshots
3. Generate PDF reports for documentation
4. Create performance reports with metrics analysis
5. Integrate with reporting frameworks

### Phase 6: Scaling and Optimization
1. Implement parallel execution with multiple contexts
2. Configure resource limits and memory management
3. Set up distributed execution across multiple machines
4. Implement caching for repeated operations
5. Optimize scripts for CI/CD pipeline execution

## Tool Arsenal

### Playwright Advanced Scripting
```javascript
const { chromium, webkit, firefox } = require('playwright');

class AdvancedHeadlessBrowser {
    constructor(config = {}) {
        this.config = {
            browser: config.browser || 'chromium',
            headless: config.headless !== false,
            timeout: config.timeout || 30000,
            viewport: config.viewport || { width: 1920, height: 1080 },
            userAgent: config.userAgent,
            proxy: config.proxy,
            ...config
        };
        this.browser = null;
        this.context = null;
        this.page = null;
        this.metrics = {
            requests: 0,
            responses: 0,
            errors: 0,
            screenshots: 0,
            performance: {}
        };
    }

    async initialize() {
        const browserType = {
            chromium: chromium,
            webkit: webkit,
            firefox: firefox
        }[this.config.browser];

        this.browser = await browserType.launch({
            headless: this.config.headless,
            args: this.config.browserArgs || [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--no-first-run',
                '--no-zygote',
                '--disable-gpu'
            ]
        });

        const contextOptions = {
            viewport: this.config.viewport,
            userAgent: this.config.userAgent,
            ignoreHTTPSErrors: true,
            bypassCSP: true
        };

        if (this.config.proxy) {
            contextOptions.proxy = {
                server: this.config.proxy.server,
                username: this.config.proxy.username,
                password: this.config.proxy.password
            };
        }

        this.context = await this.browser.newContext(contextOptions);
        this.page = await this.context.newPage();

        this._setupEventListeners();
        await this._applyAntiDetection();

        return this;
    }

    _setupEventListeners() {
        this.page.on('request', request => {
            this.metrics.requests++;
        });

        this.page.on('response', response => {
            this.metrics.responses++;
            if (response.status() >= 400) {
                this.metrics.errors++;
            }
        });

        this.page.on('console', msg => {
            if (msg.type() === 'error') {
                console.error(`[Console Error] ${msg.text()}`);
            }
        });

        this.page.on('pageerror', error => {
            console.error(`[Page Error] ${error.message}`);
        });
    }

    async _applyAntiDetection() {
        await this.context.addInitScript(() => {
            // Override navigator.webdriver
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
            });

            // Mock plugins
            Object.defineProperty(navigator, 'plugins', {
                get: () => [1, 2, 3, 4, 5]
            });

            // Mock languages
            Object.defineProperty(navigator, 'languages', {
                get: () => ['en-US', 'en']
            });

            // Override chrome runtime
            window.chrome = {
                runtime: {},
                loadTimes: function() {},
                csi: function() {},
                app: {}
            };

            // Override permissions
            const originalQuery = window.navigator.permissions.query;
            window.navigator.permissions.query = (parameters) =>
                parameters.name === 'notifications'
                    ? Promise.resolve({ state: Notification.permission })
                    : originalQuery(parameters);
        });
    }

    async navigate(url, options = {}) {
        const response = await this.page.goto(url, {
            waitUntil: options.waitUntil || 'networkidle',
            timeout: options.timeout || this.config.timeout
        });
        return response;
    }

    async waitForSelector(selector, options = {}) {
        return await this.page.waitForSelector(selector, {
            timeout: options.timeout || this.config.timeout,
            state: options.state || 'visible'
        });
    }

    async click(selector, options = {}) {
        await this.page.waitForSelector(selector, { state: 'visible' });
        await this.page.click(selector, options);
    }

    async fill(selector, value) {
        await this.page.waitForSelector(selector, { state: 'visible' });
        await this.page.fill(selector, value);
    }

    async selectOption(selector, values) {
        await this.page.waitForSelector(selector, { state: 'visible' });
        await this.page.selectOption(selector, values);
    }

    async uploadFile(selector, filePaths) {
        await this.page.waitForSelector(selector, { state: 'visible' });
        const fileChooserPromise = this.page.waitForEvent('filechooser');
        await this.page.click(selector);
        const fileChooser = await fileChooserPromise;
        await fileChooser.setFiles(filePaths);
    }

    async evaluate(script, ...args) {
        return await this.page.evaluate(script, ...args);
    }

    async screenshot(options = {}) {
        const defaultOptions = {
            path: `screenshot_${Date.now()}.png`,
            fullPage: true
        };
        const screenshotOptions = { ...defaultOptions, ...options };
        await this.page.screenshot(screenshotOptions);
        this.metrics.screenshots++;
        return screenshotOptions.path;
    }

    async pdf(options = {}) {
        const defaultOptions = {
            path: `document_${Date.now()}.pdf`,
            format: 'A4',
            printBackground: true
        };
        const pdfOptions = { ...defaultOptions, ...options };
        await this.page.pdf(pdfOptions);
        return pdfOptions.path;
    }

    async setCookie(cookies) {
        await this.context.addCookies(cookies);
    }

    async getCookies() {
        return await this.context.cookies();
    }

    async clearCookies() {
        await this.context.clearCookies();
    }

    async getPerformanceMetrics() {
        return await this.page.evaluate(() => {
            const perf = performance.getEntries();
            return {
                navigation: perf.filter(e => e.entryType === 'navigation')[0],
                resources: perf.filter(e => e.entryType === 'resource'),
                marks: perf.filter(e => e.entryType === 'mark'),
                measures: perf.filter(e => e.entryType === 'measure')
            };
        });
    }

    async close() {
        if (this.context) {
            await this.context.close();
        }
        if (this.browser) {
            await this.browser.close();
        }
    }
}
```

### Puppeteer Advanced Scripting
```javascript
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');

puppeteer.use(StealthPlugin());

class PuppeteerHeadlessScript {
    constructor(config = {}) {
        this.config = config;
        this.browser = null;
        this.page = null;
    }

    async initialize() {
        this.browser = await puppeteer.launch({
            headless: 'new',
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--no-first-run',
                '--no-zygote',
                '--disable-gpu',
                '--window-size=1920,1080'
            ],
            defaultViewport: {
                width: 1920,
                height: 1080
            }
        });

        this.page = await this.browser.newPage();

        await this.page.setUserAgent(
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        );

        // Enable request interception
        await this.page.setRequestInterception(true);
        
        this.page.on('request', request => {
            // Block unnecessary resources
            const blockedTypes = ['image', 'stylesheet', 'font', 'media'];
            if (blockedTypes.includes(request.resourceType())) {
                request.abort();
            } else {
                request.continue();
            }
        });

        return this;
    }

    async navigateTo(url) {
        await this.page.goto(url, {
            waitUntil: 'networkidle2',
            timeout: 30000
        });
        return this.page;
    }

    async waitForElement(selector, options = {}) {
        return await this.page.waitForSelector(selector, {
            visible: true,
            timeout: options.timeout || 30000
        });
    }

    async typeText(selector, text, options = {}) {
        await this.page.waitForSelector(selector, { visible: true });
        await this.page.click(selector, { clickCount: 3 }); // Select all
        await this.page.type(selector, text, {
            delay: options.delay || 50
        });
    }

    async screenshot(options = {}) {
        const defaultOptions = {
            path: `screenshot_${Date.now()}.png`,
            fullPage: true
        };
        return await this.page.screenshot({ ...defaultOptions, ...options });
    }

    async evaluateOnNewDocument(script) {
        await this.page.evaluateOnNewDocument(script);
    }

    async getCDP() {
        return await this.page.target().createCDPSession();
    }

    async enableNetworkCapture() {
        const cdp = await this.getCDP();
        await cdp.send('Network.enable');
        return cdp;
    }

    async getPerformanceMetrics() {
        return await this.page.metrics();
    }

    async close() {
        if (this.browser) {
            await this.browser.close();
        }
    }
}
```

### Python Playwright Advanced
```python
import asyncio
import json
from playwright.async_api import async_playwright

class PythonHeadlessScript:
    def __init__(self):
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None
        self.network_logs = []
    
    async def initialize(self):
        self.playwright = await async_playwright().start()
        self.browser = await self.playwright.chromium.launch(
            headless=True,
            args=[
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage'
            ]
        )
        self.context = await self.browser.new_context(
            viewport={'width': 1920, 'height': 1080},
            user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            ignore_https_errors=True
        )
        self.page = await self.context.new_page()
        await self._setup_network_capture()
        return self
    
    async def _setup_network_capture(self):
        self.page.on('request', self._on_request)
        self.page.on('response', self._on_response)
    
    async def _on_request(self, request):
        self.network_logs.append({
            'type': 'request',
            'method': request.method,
            'url': request.url,
            'headers': request.headers,
            'timestamp': asyncio.get_event_loop().time()
        })
    
    async def _on_response(self, response):
        self.network_logs.append({
            'type': 'response',
            'status': response.status,
            'url': response.url,
            'headers': response.headers,
            'timestamp': asyncio.get_event_loop().time()
        })
    
    async def navigate(self, url, wait_until='networkidle'):
        await self.page.goto(url, wait_until=wait_until)
    
    async def wait_and_click(self, selector, timeout=5000):
        await self.page.wait_for_selector(selector, timeout=timeout)
        await self.page.click(selector)
    
    async def fill_form(self, form_data):
        for selector, value in form_data.items():
            await self.page.wait_for_selector(selector)
            await self.page.fill(selector, value)
    
    async def execute_js(self, script, *args):
        return await self.page.evaluate(script, *args)
    
    async def screenshot(self, name, full_page=True):
        await self.page.screenshot(
            path=f'screenshots/{name}.png',
            full_page=full_page
        )
    
    async def get_cookies(self):
        return await self.context.cookies()
    
    async def set_cookies(self, cookies):
        await self.context.add_cookies(cookies)
    
    async def cleanup(self):
        if self.browser:
            await self.browser.close()
        if self.playwright:
            await self.playwright.stop()
```

### Page Object Model for Headless Scripts
```javascript
class BasePage {
    constructor(page) {
        this.page = page;
    }

    async waitForLoad(state = 'networkidle') {
        await this.page.waitForLoadState(state);
    }

    async waitForSelector(selector, options = {}) {
        return await this.page.waitForSelector(selector, {
            timeout: 10000,
            ...options
        });
    }

    async click(selector) {
        await this.waitForSelector(selector);
        await this.page.click(selector);
    }

    async fill(selector, value) {
        await this.waitForSelector(selector);
        await this.page.fill(selector, value);
    }

    async getText(selector) {
        await this.waitForSelector(selector);
        return await this.page.textContent(selector);
    }

    async isVisible(selector) {
        try {
            await this.page.waitForSelector(selector, { timeout: 1000 });
            return true;
        } catch {
            return false;
        }
    }

    async screenshot(name) {
        await this.page.screenshot({
            path: `screenshots/${name}.png`,
            fullPage: true
        });
    }
}

class LoginPage extends BasePage {
    constructor(page) {
        super(page);
        this.url = 'https://target.example.com/login';
        this.selectors = {
            username: '#username',
            password: '#password',
            submit: '#login-button',
            errorMessage: '.error-message',
            successRedirect: '.dashboard'
        };
    }

    async navigate() {
        await this.page.goto(this.url);
        await this.waitForLoad();
    }

    async login(username, password) {
        await this.fill(this.selectors.username, username);
        await this.fill(this.selectors.password, password);
        await this.click(this.selectors.submit);
        await this.page.waitForNavigation();
    }

    async getErrorMessage() {
        if (await this.isVisible(this.selectors.errorMessage)) {
            return await this.getText(this.selectors.errorMessage);
        }
        return null;
    }

    async isLoggedIn() {
        return await this.isVisible(this.selectors.successRedirect);
    }
}

class DashboardPage extends BasePage {
    constructor(page) {
        super(page);
        this.selectors = {
            welcome: '.welcome-message',
            menu: '.main-menu',
            profile: '.user-profile',
            logout: '.logout-button'
        };
    }

    async getWelcomeMessage() {
        return await this.getText(this.selectors.welcome);
    }

    async navigateTo(section) {
        await this.click(`${this.selectors.menu} a[data-section="${section}"]`);
        await this.waitForLoad();
    }

    async logout() {
        await this.click(this.selectors.logout);
        await this.page.waitForNavigation();
    }
}
```

### Network Interception and Modification
```javascript
class NetworkInterceptor {
    constructor(page) {
        this.page = page;
        this.interceptedRequests = [];
        this.mockedResponses = {};
    }

    async enableInterception() {
        await this.page.route('**/*', (route, request) => {
            const url = request.url();
            
            // Check for mocked responses
            if (this.mockedResponses[url]) {
                const mock = this.mockedResponses[url];
                route.fulfill({
                    status: mock.status || 200,
                    contentType: mock.contentType || 'application/json',
                    body: JSON.stringify(mock.body)
                });
                return;
            }

            // Log intercepted request
            this.interceptedRequests.push({
                url: url,
                method: request.method(),
                headers: request.headers(),
                postData: request.postData(),
                timestamp: Date.now()
            });

            // Continue with request
            route.continue();
        });
    }

    mockResponse(urlPattern, mockData) {
        this.mockedResponses[urlPattern] = mockData;
    }

    async modifyHeaders(headers) {
        await this.page.route('**/*', (route) => {
            const request = route.request();
            const newHeaders = { ...request.headers(), ...headers };
            route.continue({ headers: newHeaders });
        });
    }

    async blockResourceTypes(types) {
        await this.page.route('**/*', (route) => {
            if (types.includes(route.request().resourceType())) {
                route.abort();
            } else {
                route.continue();
            }
        });
    }

    async blockUrls(patterns) {
        await this.page.route('**/*', (route) => {
            const url = route.request().url();
            if (patterns.some(pattern => url.includes(pattern))) {
                route.abort();
            } else {
                route.continue();
            }
        });
    }

    getInterceptedRequests() {
        return this.interceptedRequests;
    }

    clearInterceptedRequests() {
        this.interceptedRequests = [];
    }
}
```

### Console Monitoring and Error Detection
```javascript
class ConsoleMonitor {
    constructor(page) {
        this.page = page;
        this.logs = [];
        this.errors = [];
        this.warnings = [];
        this.info = [];
    }

    startMonitoring() {
        this.page.on('console', msg => {
            const logEntry = {
                type: msg.type(),
                text: msg.text(),
                timestamp: Date.now(),
                location: msg.location()
            };

            this.logs.push(logEntry);

            switch (msg.type()) {
                case 'error':
                    this.errors.push(logEntry);
                    break;
                case 'warning':
                    this.warnings.push(logEntry);
                    break;
                case 'info':
                    this.info.push(logEntry);
                    break;
            }
        });

        this.page.on('pageerror', error => {
            this.errors.push({
                type: 'pageerror',
                message: error.message,
                stack: error.stack,
                timestamp: Date.now()
            });
        });

        this.page.on('requestfailed', request => {
            this.errors.push({
                type: 'requestfailed',
                url: request.url(),
                failure: request.failure(),
                timestamp: Date.now()
            });
        });
    }

    getErrors() {
        return this.errors;
    }

    getWarnings() {
        return this.warnings;
    }

    getAllLogs() {
        return this.logs;
    }

    getLogsByType(type) {
        return this.logs.filter(log => log.type === type);
    }

    exportLogs(filename) {
        const fs = require('fs');
        fs.writeFileSync(filename, JSON.stringify(this.logs, null, 2));
    }

    clearLogs() {
        this.logs = [];
        this.errors = [];
        this.warnings = [];
        this.info = [];
    }
}
```

### Performance Profiling
```javascript
class PerformanceProfiler {
    constructor(page) {
        this.page = page;
        this.metrics = {};
        this.marks = [];
        this.measures = [];
    }

    async startProfiling() {
        await this.page.evaluate(() => {
            performance.clearMarks();
            performance.clearMeasures();
        });
    }

    async mark(name) {
        await this.page.evaluate((markName) => {
            performance.mark(markName);
        }, name);
        this.marks.push({ name, timestamp: Date.now() });
    }

    async measure(name, startMark, endMark) {
        await this.page.evaluate((measureName, start, end) => {
            performance.measure(measureName, start, end);
        }, name, startMark, endMark);
        
        const measure = await this.page.evaluate((measureName) => {
            const entries = performance.getEntriesByName(measureName, 'measure');
            return entries[entries.length - 1];
        }, name);
        
        this.measures.push(measure);
        return measure;
    }

    async collectMetrics() {
        this.metrics = await this.page.evaluate(() => {
            const nav = performance.getEntriesByType('navigation')[0];
            const resources = performance.getEntriesByType('resource');
            
            return {
                navigation: {
                    domContentLoaded: nav.domContentLoadedEventEnd - nav.startTime,
                    loadEvent: nav.loadEventEnd - nav.startTime,
                    domComplete: nav.domComplete - nav.startTime,
                    responseTime: nav.responseEnd - nav.requestStart
                },
                resources: {
                    total: resources.length,
                    byType: resources.reduce((acc, r) => {
                        acc[r.initiatorType] = (acc[r.initiatorType] || 0) + 1;
                        return acc;
                    }, {}),
                    totalDuration: resources.reduce((sum, r) => sum + r.duration, 0)
                },
                memory: performance.memory ? {
                    usedJSHeapSize: performance.memory.usedJSHeapSize,
                    totalJSHeapSize: performance.memory.totalJSHeapSize
                } : null
            };
        });
        
        return this.metrics;
    }

    async getLighthouseMetrics() {
        return await this.page.evaluate(() => {
            const paint = performance.getEntriesByType('paint');
            return {
                firstPaint: paint.find(p => p.name === 'first-paint')?.startTime,
                firstContentfulPaint: paint.find(p => p.name === 'first-contentful-paint')?.startTime,
                largestContentfulPaint: new Promise(resolve => {
                    new PerformanceObserver((entryList) => {
                        const entries = entryList.getEntries();
                        resolve(entries[entries.length - 1]);
                    }).observe({ type: 'largest-contentful-paint', buffered: true });
                })
            };
        });
    }

    exportReport(filename) {
        const fs = require('fs');
        const report = {
            metrics: this.metrics,
            marks: this.marks,
            measures: this.measures,
            timestamp: new Date().toISOString()
        };
        fs.writeFileSync(filename, JSON.stringify(report, null, 2));
    }
}
```

### User Agent Rotation
```javascript
const USER_AGENTS = {
    chrome: [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    ],
    firefox: [
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0'
    ],
    safari: [
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15'
    ]
};

class UserAgentManager {
    constructor() {
        this.currentIndex = { chrome: 0, firefox: 0, safari: 0 };
    }

    getNext(browser = 'chrome') {
        const agents = USER_AGENTS[browser];
        const index = this.currentIndex[browser] % agents.length;
        this.currentIndex[browser]++;
        return agents[index];
    }

    getRandom(browser = 'chrome') {
        const agents = USER_AGENTS[browser];
        return agents[Math.floor(Math.random() * agents.length)];
    }

    getAll() {
        return Object.values(USER_AGENTS).flat();
    }
}
```

### Proxy Configuration Manager
```javascript
class ProxyManager {
    constructor() {
        this.proxies = [];
        this.currentIndex = 0;
    }

    addProxy(proxy) {
        this.proxies.push({
            server: proxy.server,
            username: proxy.username,
            password: proxy.password,
            name: proxy.name || `proxy-${this.proxies.length}`
        });
    }

    loadFromFile(filepath) {
        const fs = require('fs');
        const content = fs.readFileSync(filepath, 'utf8');
        const lines = content.split('\n').filter(line => line.trim());
        
        lines.forEach(line => {
            const [server, username, password] = line.split(':');
            this.addProxy({
                server: server,
                username: username,
                password: password
            });
        });
    }

    getNext() {
        if (this.proxies.length === 0) {
            return null;
        }
        const proxy = this.proxies[this.currentIndex % this.proxies.length];
        this.currentIndex++;
        return proxy;
    }

    getRandom() {
        if (this.proxies.length === 0) {
            return null;
        }
        return this.proxies[Math.floor(Math.random() * this.proxies.length)];
    }

    getProxyConfig(proxy = null) {
        const selectedProxy = proxy || this.getNext();
        if (!selectedProxy) {
            return null;
        }
        return {
            server: selectedProxy.server,
            username: selectedProxy.username,
            password: selectedProxy.password
        };
    }
}
```

## Case Studies

### Case Study 1: Automated Vulnerability Scanner with Playwright
**Scenario**: Need to build a custom vulnerability scanner that can handle modern SPAs with dynamic content.
**Approach**: Developed Playwright-based scanner with custom wait strategies, network interception for API discovery, and DOM analysis for XSS/SQLi patterns. Used multiple browser contexts for parallel testing.
**Findings**: Discovered 23 vulnerabilities including stored XSS in user profiles, IDOR in API endpoints, and sensitive data exposure in error messages.
**Outcome**: Fully automated scanner that runs nightly against target application, generating comprehensive reports with evidence.

### Case Study 2: Headless Browser for API Discovery
**Scenario**: Application has undocumented API endpoints called by frontend JavaScript.
**Approach**: Built Puppeteer script that navigates through all application features while recording network traffic. Uses CDP to capture all XHR/fetch calls with request/response bodies.
**Findings**: Discovered 89 undocumented API endpoints, 15 without authentication, 8 returning excessive data.
**Outcome**: Complete API inventory with automated authorization testing for each endpoint.

### Case Study 3: Performance-Based Security Testing
**Scenario**: Need to identify security controls that can be bypassed through timing attacks.
**Approach**: Implemented Playwright script with high-precision timing measurements. Monitors response times for authentication endpoints to detect username enumeration via timing differences.
**Findings**: Found username enumeration through login response timing (50ms difference between valid/invalid usernames), and password reset token prediction based on generation time.
**Outcome**: Timing attack vulnerabilities documented with precise measurements and proof-of-concept scripts.

### Case Study 4: Cross-Browser Security Testing
**Scenario**: Application needs security testing across multiple browser engines.
**Approach**: Developed Playwright script that runs identical security tests across Chromium, Firefox, and WebKit. Tests XSS filter differences, CSP enforcement, and cookie handling variations.
**Findings**: XSS vulnerability exploitable only in Firefox due to different HTML parsing, SameSite cookie bypass in Safari, and inconsistent CSP enforcement across browsers.
**Outcome**: Browser-specific security recommendations with cross-browser compatibility matrix.

### Case Study 5: Automated Screenshot Evidence Collection
**Scenario**: Penetration test requires comprehensive visual evidence for all findings.
**Approach**: Built automated evidence capture system with Playwright that generates timestamped screenshots, full-page captures, element-specific captures, and PDF reports for each vulnerability found.
**Findings**: Successfully documented 45 vulnerabilities with visual evidence, including step-by-step reproduction screenshots.
**Outcome**: Professional evidence package accepted by client with zero disputes about findings.

### Case Study 6: Headless Browser for Load Testing
**Scenario**: Need to test application behavior under concurrent user load for security implications.
**Approach**: Implemented parallel Playwright instances simulating 100 concurrent users performing various workflows. Monitors for race conditions, session fixation, and resource exhaustion vulnerabilities.
**Findings**: Found race condition in funds transfer allowing double-spending, session fixation when concurrent logins occur, and memory leak leading to DoS.
**Outcome**: Identified 3 critical race condition vulnerabilities with proof-of-concept demonstrations.

## Bypass Techniques

### Browser Detection Bypass
```javascript
// Comprehensive stealth configuration
const stealthConfig = {
    webdriver: false,
    plugins: true,
    languages: ['en-US', 'en'],
    vendor: 'Google Inc.',
    platform: 'Win32',
    hardwareConcurrency: 8,
    deviceMemory: 8,
    maxTouchPoints: 0
};

// Apply stealth settings
await page.evaluateOnNewDocument((config) => {
    Object.defineProperty(navigator, 'webdriver', { get: () => config.webdriver });
    Object.defineProperty(navigator, 'plugins', { get: () => config.plugins ? [1, 2, 3, 4, 5] : [] });
    Object.defineProperty(navigator, 'languages', { get: () => config.languages });
    Object.defineProperty(navigator, 'vendor', { get: () => config.vendor });
    Object.defineProperty(navigator, 'platform', { get: () => config.platform });
    Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => config.hardwareConcurrency });
    Object.defineProperty(navigator, 'deviceMemory', { get: () => config.deviceMemory });
    Object.defineProperty(navigator, 'maxTouchPoints', { get: () => config.maxTouchPoints });
    
    // Override chrome runtime
    window.chrome = {
        runtime: {},
        loadTimes: function() {},
        csi: function() {},
        app: { isInstalled: false }
    };
}, stealthConfig);
```

### CDP Detection Bypass
```javascript
// Avoid CDP detection
async function bypassCDPDetection(page) {
    await page.evaluateOnNewDocument(() => {
        // Override toString to prevent detection
        const originalToString = Function.prototype.toString;
        Function.prototype.toString = function() {
            if (this === Function.prototype.toString) {
                return 'function toString() { [native code] }';
            }
            return originalToString.call(this);
        };
        
        // Override debugger detection
        const originalDefineProperty = Object.defineProperty;
        Object.defineProperty = function(obj, prop, descriptor) {
            if (prop === 'toString' || prop === 'toLocaleString') {
                return originalDefineProperty.call(this, obj, prop, descriptor);
            }
            return originalDefineProperty.call(this, obj, prop, descriptor);
        };
    });
}
```

### Cookie Security Bypass
```javascript
// Set cookies with specific attributes
async function setCookiesWithAttributes(page, cookies) {
    const context = page.context();
    await context.addCookies(cookies.map(cookie => ({
        ...cookie,
        sameSite: 'None',
        secure: true,
        httpOnly: false,
        domain: cookie.domain || new URL(page.url()).hostname
    })));
}
```

### CORS Bypass via Proxy
```javascript
// Route requests through proxy to bypass CORS
async function bypassCORSWithProxy(page, proxyServer) {
    const context = await browser.newContext({
        proxy: {
            server: proxyServer
        }
    });
    const newPage = await context.newPage();
    // CORS restrictions are client-side, proxy doesn't help
    // Instead, intercept and modify requests
    await newPage.route('**/*', (route) => {
        const headers = route.request().headers();
        delete headers['origin'];
        delete headers['referer'];
        route.continue({ headers });
    });
    return newPage;
}
```

## Advanced Techniques

### Parallel Execution Framework
```javascript
class ParallelBrowserRunner {
    constructor(maxInstances = 5) {
        this.maxInstances = maxInstances;
        this.running = 0;
        this.queue = [];
    }

    async runTask(task) {
        return new Promise((resolve, reject) => {
            this.queue.push({ task, resolve, reject });
            this._processQueue();
        });
    }

    async _processQueue() {
        while (this.running < this.maxInstances && this.queue.length > 0) {
            const { task, resolve, reject } = this.queue.shift();
            this.running++;
            
            try {
                const result = await task();
                resolve(result);
            } catch (error) {
                reject(error);
            } finally {
                this.running--;
                this._processQueue();
            }
        }
    }

    async runAll(tasks) {
        const promises = tasks.map(task => this.runTask(task));
        return Promise.allSettled(promises);
    }
}
```

### Dynamic Content Handler
```javascript
class DynamicContentHandler {
    constructor(page) {
        this.page = page;
    }

    async waitForAjax(timeout = 10000) {
        await this.page.evaluate((timeout) => {
            return new Promise((resolve, reject) => {
                const timer = setTimeout(resolve, timeout);
                const checkAjax = () => {
                    if (typeof jQuery !== 'undefined') {
                        jQuery(document).ajaxComplete(() => {
                            clearTimeout(timer);
                            resolve();
                        });
                    } else {
                        setTimeout(checkAjax, 100);
                    }
                };
                checkAjax();
            });
        }, timeout);
    }

    async waitForWebSocket(timeout = 5000) {
        await this.page.evaluate((timeout) => {
            return new Promise((resolve) => {
                const timer = setTimeout(resolve, timeout);
                const originalClose = WebSocket.prototype.close;
                let openConnections = 0;

                WebSocket.prototype.close = function() {
                    openConnections--;
                    if (openConnections === 0) {
                        clearTimeout(timer);
                        resolve();
                    }
                    return originalClose.apply(this, arguments);
                };

                const originalOpen = WebSocket.prototype.open;
                WebSocket.prototype.open = function() {
                    openConnections++;
                    return originalOpen.apply(this, arguments);
                };
            });
        }, timeout);
    }

    async waitForLazyLoad(selector, timeout = 5000) {
        await this.page.evaluate((selector, timeout) => {
            return new Promise((resolve, reject) => {
                const timer = setTimeout(reject, timeout);
                const observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            observer.disconnect();
                            clearTimeout(timer);
                            resolve();
                        }
                    });
                });
                observer.observe(document.querySelector(selector));
            });
        }, selector, timeout);
    }
}
```

## Detection Indicators

### Headless Browser Artifacts
- `navigator.webdriver` property returning true
- Missing or inconsistent browser plugins
- Inhuman timing patterns in interactions
- Missing browser history and cache
- Automated User-Agent strings
- Missing browser-specific APIs
- Headless mode detection via window properties
- CDP-specific properties in browser context

### Script Execution Patterns
- Sequential endpoint access without natural navigation
- Identical timing intervals between requests
- POST requests without corresponding GET requests
- Missing referrer headers
- Inconsistent cookie handling
- Unusual viewport sizes
- Missing resource loading patterns
- Automated form submission patterns

## Impact Assessment

### Automation Effectiveness Metrics
- **Script Reliability**: Percentage of script executions completing without errors
- **Coverage**: Percentage of application features tested automatically
- **Speed**: Time to complete full test suite
- **Resource Efficiency**: Memory and CPU usage per test run
- **Maintainability**: Time required to update scripts for application changes
- **Evidence Quality**: Completeness and usefulness of captured evidence
- **False Positive Rate**: Percentage of findings requiring manual verification
- **Scalability**: Ability to handle increased testing scope

### Business Impact
- **Testing Speed**: Reduction in time-to-results for security testing
- **Cost Efficiency**: Reduction in manual testing labor costs
- **Coverage Improvement**: Increase in tested scenarios and endpoints
- **Consistency**: Elimination of human error in repetitive testing
- **Documentation**: Automated evidence collection for compliance
- **Regression Detection**: Faster identification of reintroduced vulnerabilities

## Common Pitfalls

### Technical Pitfalls
- **Memory Leaks**: Not properly closing browser instances
- **Race Conditions**: Not waiting for elements to be ready
- **Flaky Selectors**: Using CSS selectors that break with UI changes
- **Timeout Issues**: Setting too aggressive or lenient timeouts
- **Resource Blocking**: Accidentally blocking required resources
- **Cookie Handling**: Not managing session state properly
- **Encoding Issues**: Mishandling Unicode and special characters
- **CORS Restrictions**: Running into cross-origin issues

### Operational Pitfalls
- **Environment Drift**: Test environments differing from production
- **Credential Management**: Hardcoding credentials in scripts
- **Over-Automation**: Automating tests that should remain manual
- **Maintenance Burden**: Creating scripts too complex to maintain
- **Reporting Gaps**: Not capturing enough evidence
- **Scope Management**: Tests exceeding authorized boundaries
- **Resource Exhaustion**: Running too many parallel instances
- **Version Compatibility**: Framework versions incompatible with browsers

## Integration Points

### CI/CD Pipeline Integration
```yaml
# GitHub Actions workflow
name: Headless Browser Security Tests
on: [push, pull_request]

jobs:
  security-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Install Playwright browsers
        run: npx playwright install --with-deps
      - name: Run security tests
        run: npm run test:security
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: security-test-results
          path: |
            screenshots/
            reports/
            logs/
```

### Docker Integration
```dockerfile
# Dockerfile for headless browser testing
FROM mcr.microsoft.com/playwright:v1.40.0-jammy

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx playwright install

CMD ["npm", "run", "test:security"]
```

### Monitoring Integration
```javascript
// Prometheus metrics
const client = require('prom-client');

const testCounter = new client.Counter({
    name: 'headless_browser_tests_total',
    help: 'Total number of headless browser tests',
    labelNames: ['test_type', 'result']
});

const testDuration = new client.Histogram({
    name: 'headless_browser_test_duration_seconds',
    help: 'Duration of headless browser tests',
    labelNames: ['test_type'],
    buckets: [0.1, 0.5, 1, 2, 5, 10, 30]
});

function recordTest(testType, result, duration) {
    testCounter.labels(testType, result).inc();
    testDuration.labels(testType).observe(duration);
}
```

## Practice Labs

### Lab 1: Basic Navigation and Screenshot
Create a Playwright script that:
1. Launches headless browser
2. Navigates to a target website
3. Captures full-page screenshot
4. Saves page content to file
5. Logs all network requests

### Lab 2: Authentication Automation
Build a script that:
1. Automates login process
2. Handles multi-factor authentication
3. Maintains session across page navigations
4. Captures evidence at each step
5. Generates authentication flow report

### Lab 3: Network Interception
Develop a network interceptor that:
1. Logs all HTTP/HTTPS requests
2. Modifies request headers
3. Blocks unnecessary resources
4. Mocks API responses
5. Generates HAR file from traffic

### Lab 4: Performance Profiling
Create a performance profiler that:
1. Measures page load times
2. Tracks resource loading
3. Identifies slow resources
4. Generates performance report
5. Compares metrics across runs

### Lab 5: Parallel Execution
Build a parallel test runner that:
1. Manages multiple browser instances
2. Runs tests concurrently
3. Collects results from all instances
4. Generates consolidated report
5. Handles resource cleanup

## Ethics

### Responsible Headless Browser Usage
- **Authorization**: Only test applications with explicit permission
- **Rate Limiting**: Implement delays between requests to avoid DoS
- **Resource Usage**: Monitor and limit CPU/memory consumption
- **Data Privacy**: Handle captured data according to regulations
- **Credential Security**: Use secure credential storage
- **Scope Respect**: Stay within authorized testing boundaries
- **Evidence Handling**: Treat captured evidence as confidential
- **Cleanup**: Remove test data and artifacts after testing
- **Disclosure**: Report findings through authorized channels
- **Documentation**: Maintain audit trail of all automated activities

## Quick Reference

### Command Line Execution
```bash
# Run Playwright script
npx playwright test script.js

# Run with specific browser
npx playwright test --project=chromium

# Run in debug mode
npx playwright test --debug

# Generate test report
npx playwright show-report
```

### Common Selectors
```css
/* ID */
#login-button

/* Class */
.submit-btn

/* Attribute */
input[type="submit"]

/* Data attribute */
[data-testid="login-form"]

/* Text content */
button:has-text("Login")

/* XPath */
//button[contains(text(), "Submit")]

/* Nth element */
.form-group:nth-child(2) input

/* Placeholder */
input[placeholder="Enter username"]

/* Visible only */
button:visible
```

### Timeout Configuration
```javascript
// Navigation timeout
await page.goto(url, { timeout: 60000 });

// Element timeout
await page.waitForSelector(selector, { timeout: 30000 });

// Action timeout
await page.click(selector, { timeout: 5000 });

// Global timeout
context.setDefaultTimeout(30000);
```

### Screenshot Options
```javascript
// Full page
await page.screenshot({ path: 'full.png', fullPage: true });

// Viewport only
await page.screenshot({ path: 'viewport.png' });

// Specific element
await page.screenshot({ path: 'element.png', clip: { x: 0, y: 0, width: 100, height: 100 } });

// With mask
await page.screenshot({ path: 'masked.png', mask: [page.locator('.sensitive-data')] });
```

### Performance Metrics
```javascript
// Get performance metrics
const metrics = await page.evaluate(() => {
    return {
        domContentLoaded: performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart,
        loadEvent: performance.timing.loadEventEnd - performance.timing.navigationStart,
        firstPaint: performance.getEntriesByType('paint')[0]?.startTime
    };
});
```

### Troubleshooting Quick Fixes
1. **Element not found**: Check selector, wait for load, verify visibility
2. **Timeout error**: Increase timeout, check page state, verify navigation
3. **Stale element**: Re-query element after DOM changes
4. **Session expired**: Implement session refresh mechanism
5. **CORS error**: Use browser context with appropriate settings
6. **Memory error**: Close unused pages, reduce parallel instances
7. **Screenshot failure**: Wait for animations, check element visibility
8. **Cookie error**: Verify domain, path, and security attributes

### Best Practices Checklist
- [ ] Use explicit waits instead of fixed delays
- [ ] Implement proper error handling and retry logic
- [ ] Close browser instances to prevent memory leaks
- [ ] Use page objects for maintainable code
- [ ] Capture evidence at each test step
- [ ] Configure appropriate timeouts
- [ ] Use headless mode for CI/CD
- [ ] Implement logging for debugging
- [ ] Handle dynamic content appropriately
- [ ] Use parallel execution for efficiency
