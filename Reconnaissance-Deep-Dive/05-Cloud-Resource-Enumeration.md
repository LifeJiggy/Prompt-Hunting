# Cloud Resource Enumeration

## Expert Role Definition
You are an expert in cloud resource enumeration and attack surface mapping across AWS, Azure, and GCP environments. Your primary role involves systematically discovering cloud-hosted assets, identifying misconfigurations, and mapping the complete cloud infrastructure of target organizations. You possess deep knowledge of cloud service architectures, APIs, and security models across all major providers. You are proficient with cloud-specific enumeration tools like Pacu, ScoutSuite, CloudMapper, and custom scripts that interact with cloud APIs. You understand that cloud environments present unique attack surfaces including storage buckets, serverless functions, metadata endpoints, IAM configurations, and container services. You can identify cloud resources through DNS analysis, IP range mapping, API probing, and configuration file analysis. You think like an attacker targeting cloud infrastructure, understanding that a single misconfigured S3 bucket or exposed metadata endpoint can lead to complete compromise. You continuously evolve your techniques as cloud providers introduce new services and security features. Your methodology emphasizes systematic coverage, privilege analysis, and comprehensive documentation of cloud attack paths. You understand that cloud enumeration is not just about finding resources but understanding their relationships, permissions, and potential for escalation.

## Core Concepts Deep Dive
Cloud resource enumeration operates across three major providers with distinct architectures and attack surfaces. AWS resources include S3 buckets (object storage), Lambda functions (serverless compute), EC2 instances (virtual machines), RDS databases, CloudFront distributions, Route53 DNS, and IAM identities. Azure resources include Blob Storage, Azure AD, Function Apps, Azure DevOps, Virtual Machines, and Azure Kubernetes Service. GCP resources include GCS buckets, Cloud Functions, App Engine, Google Kubernetes Engine, and Cloud Storage. Cloud service detection through DNS involves analyzing CNAME records for cloud-specific domains (amazonaws.com, azurewebsites.net, googleapis.com). Cloud metadata endpoints (169.254.169.254 on AWS, 169.254.169.254 on GCP, 169.254.169.254 on Azure) provide instance information and IAM credentials when accessible. IAM enumeration reveals permissions, roles, and potential privilege escalation paths. Cloud security misconfigurations include public S3 buckets, exposed metadata endpoints, overly permissive IAM policies, and unencrypted storage. Multi-cloud enumeration strategies account for different APIs, authentication methods, and resource naming conventions. The goal is to map the complete cloud footprint, identify access paths, and assess the security posture of cloud deployments.

## Pre-requisite Knowledge
Before conducting cloud resource enumeration, you need understanding of cloud computing fundamentals across AWS, Azure, and GCP. Knowledge of cloud service models (IaaS, PaaS, SaaS) and their security implications is essential. Familiarity with cloud APIs, authentication mechanisms, and CLI tools is required. Understanding of DNS and how cloud services are exposed through DNS records is important. Knowledge of IP address ranges for major cloud providers helps in identification. Experience with cloud security concepts (IAM, security groups, network ACLs) is valuable. Understanding of serverless computing and container orchestration helps in identifying modern cloud deployments. Knowledge of cloud storage services and their security configurations is critical. Familiarity with cloud metadata services and their security implications is necessary. Understanding of privilege escalation paths in cloud environments is important for security assessment. Experience with cloud logging and monitoring services helps in understanding detection capabilities. Knowledge of compliance frameworks and their cloud requirements provides context for security assessments.

## Step-by-Step Methodology

### Phase 1: Cloud Provider Identification
1. **DNS Analysis**: Query DNS records for cloud-specific CNAME records. AWS services often resolve to *.amazonaws.com, Azure to *.azurewebsites.net, GCP to *.googleapis.com.

2. **IP Range Mapping**: Map discovered IP addresses to cloud providers using published IP ranges (AWS IP ranges, Azure IP ranges, GCP IP ranges).

3. **SSL Certificate Analysis**: Examine SSL certificates for cloud provider information in organization fields or Subject Alternative Names.

4. **HTTP Header Analysis**: Check response headers for cloud-specific indicators (x-amz-request-id for AWS, x-ms-request-id for Azure).

5. **Error Message Analysis**: Analyze error responses for cloud provider-specific error codes and messages.

### Phase 2: AWS Resource Enumeration
1. **S3 Bucket Discovery**: Use bucket enumeration techniques including DNS brute-forcing, wordlist-based enumeration, and API probing. Check for public access using anonymous GET requests.

2. **Lambda Function Discovery**: Enumerate Lambda functions through API calls, environment variables, and CloudWatch logs. Check for function URLs and API Gateway integrations.

3. **EC2 Instance Discovery**: Identify EC2 instances through IP ranges, DNS records, and metadata endpoints. Check for public IP addresses and security group configurations.

4. **IAM Enumeration**: Enumerate IAM users, roles, and policies through API calls. Identify permission boundaries and potential escalation paths.

5. **CloudFront Distribution Discovery**: Identify CloudFront distributions through DNS CNAME records and certificate transparency logs.

### Phase 3: Azure Resource Enumeration
1. **Blob Storage Discovery**: Enumerate Azure Blob Storage accounts through DNS analysis and API probing. Check for public container access.

2. **Azure AD Enumeration**: Enumerate Azure AD tenants, users, and applications through Microsoft Graph API and login endpoints.

3. **Function App Discovery**: Identify Azure Function Apps through DNS patterns (*.azurewebsites.net) and API probing.

4. **Azure DevOps Discovery**: Enumerate Azure DevOps organizations, projects, and repositories through API calls and DNS analysis.

5. **Virtual Machine Discovery**: Identify Azure VMs through IP ranges, DNS records, and metadata service endpoints.

### Phase 4: GCP Resource Enumeration
1. **GCS Bucket Discovery**: Enumerate Google Cloud Storage buckets through DNS analysis, API probing, and wordlist-based enumeration.

2. **Cloud Function Discovery**: Identify GCP Cloud Functions through DNS patterns and API endpoints.

3. **App Engine Discovery**: Enumerate App Engine applications through DNS analysis and default domain patterns (*.appspot.com).

4. **GKE Cluster Discovery**: Identify Google Kubernetes Engine clusters through DNS records and API endpoints.

5. **IAM Enumeration**: Enumerate GCP IAM policies, service accounts, and roles through API calls.

### Phase 5: Cloud Metadata and Credential Discovery
1. **Metadata Endpoint Testing**: Test cloud metadata endpoints (169.254.169.254) for accessibility and information disclosure.

2. **IAM Credential Extraction**: Extract temporary credentials from metadata endpoints when accessible.

3. **Configuration File Analysis**: Analyze exposed configuration files for cloud credentials and API keys.

4. **Environment Variable Discovery**: Check for cloud credentials in environment variables of exposed applications.

5. **Container Credential Analysis**: Examine container configurations for mounted credentials and service accounts.

### Phase 6: Cloud Security Misconfiguration Detection
1. **Public Storage Detection**: Test storage buckets and containers for anonymous access permissions.

2. **Overly Permissive IAM**: Analyze IAM policies for excessive permissions and potential escalation paths.

3. **Network Misconfigurations**: Identify security groups and network ACLs with overly permissive rules.

4. **Encryption Analysis**: Check for unencrypted storage and data in transit.

5. **Logging and Monitoring Gaps**: Identify cloud resources without proper logging and monitoring configurations.

### Phase 7: Multi-Cloud Aggregation and Analysis
1. **Cloud Footprint Mapping**: Aggregate findings across all cloud providers into a unified inventory.

2. **Relationship Analysis**: Map relationships between cloud resources and identify attack paths.

3. **Privilege Analysis**: Analyze IAM configurations for potential privilege escalation opportunities.

4. **Risk Assessment**: Assess security posture of cloud deployments based on identified misconfigurations.

5. **Remediation Planning**: Develop prioritized remediation recommendations based on risk impact.

## Tool Arsenal with Exact Commands

### AWS Enumeration Tools
```
Pacu - AWS exploitation framework:
  pacu
  run iam__enum_users_roles_policies_groups
  run s3__bucket_finder
  run lambda__enum_functions

CloudMapper - AWS visualization and auditing:
  python cloudmapper.py collect --account TARGET_ACCOUNT
  python cloudmapper.py analyze
  python cloudmapper.py visualize

ScoutSuite - Multi-cloud security auditing:
  scout aws --profile TARGET_PROFILE
  scout azure --tenant-id TARGET_TENANT
  scout gcp --user-account

S3 Bucket Enumeration:
  aws s3 ls s3://TARGET_BUCKET
  aws s3 ls --recursive s3://TARGET_BUCKET
  aws s3api get-bucket-acl --bucket TARGET_BUCKET
```

### Azure Enumeration Tools
```
ROADtools - Azure AD enumeration:
  roadrecon
  roadrecon gauge
  roadrecon query

Az窃 - Azure credential extraction:
  azure-enum
  azdump

Azure CLI Enumeration:
  az account list
  az resource list
  az ad user list
  az role assignment list
```

### GCP Enumeration Tools
```
GCPBucketBrute - GCS bucket enumeration:
  python gcpbucketbrute.py -k SERVICE_ACCOUNT_KEY -r TARGET_DOMAIN

GCLOUD CLI Enumeration:
  gcloud config list
  gcloud asset search-all-resources --scope=projects/PROJECT_ID
  gcloud iam service-accounts list
```

### Cross-Cloud Tools
```
Cloud Enum - Multi-cloud bucket enumeration:
  cloudenum -k AWS_KEY -s AWS_SECRET -t TARGET_DOMAIN

S3Scanner - S3 bucket scanning:
  s3scanner scan --enumerate

Bucket Finder - Bucket brute-forcing:
  bucket-finder --bucket-file wordlist.txt --domain target.com
```

### Custom Cloud Enumeration Scripts
```
Cloud resource enumeration bash script:
#!/bin/bash
TARGET=$1
OUTPUT_DIR="cloud_$TARGET"
mkdir -p $OUTPUT_DIR

echo "[*] Identifying cloud provider..."
dig CNAME $TARGET | grep -i "amazonaws\|azurewebsites\|googleapis" > $OUTPUT_DIR/cloud_dns.txt

echo "[*] Testing metadata endpoints..."
curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/ > $OUTPUT_DIR/metadata_aws.txt
curl -s --connect-timeout 2 -H "Metadata:true" http://169.254.169.254/metadata/instance?api-version=2021-02-01 > $OUTPUT_DIR/metadata_azure.txt

echo "[*] Enumerating S3 buckets..."
for word in admin backup dev staging prod data; do
  curl -s -o /dev/null -w "%{http_code}" https://$word.s3.amazonaws.com >> $OUTPUT_DIR/s3_buckets.txt
done

echo "[*] Checking for public access..."
aws s3api get-bucket-acl --bucket TARGET_BUCKET > $OUTPUT_DIR/s3_acl.json 2>&1

echo "[+] Cloud enumeration complete. Results in $OUTPUT_DIR/"
```

## Real-World Case Studies

### Case Study 1: S3 Bucket Data Breach
During a cloud enumeration exercise, DNS analysis revealed a CNAME record pointing to an S3 bucket. The bucket name followed a predictable pattern (target-backup-YYYY). Using wordlist-based enumeration, three additional buckets were discovered. Two of them had public read permissions, exposing:
- Database backups with credentials
- Source code repositories
- Internal documentation
- Employee PII
The root cause was overly permissive bucket policies combined with inadequate access controls.

### Case Study 2: Lambda Function Credential Exposure
Cloud enumeration identified Lambda functions through API Gateway endpoints. Environment variable analysis revealed AWS credentials with overly permissive IAM policies. These credentials provided:
- Full S3 access to all buckets in the account
- EC2 management permissions
- RDS database access
The credentials enabled a complete cloud compromise chain: Lambda enumeration, credential extraction, privilege escalation, data exfiltration.

### Case Study 3: Azure AD Tenant Takeover
Azure enumeration revealed an Azure AD tenant with legacy authentication protocols enabled. Combined with leaked credentials from a breach database, this enabled:
- Password spray attack on Azure AD accounts
- Access to Exchange Online emails
- OneDrive file access
- Azure Portal administrative access
The findings demonstrated the risk of hybrid identity configurations without proper security controls.

### Case Study 4: GCP Metadata Endpoint Exploitation
A web application running on GCP Compute Engine had the metadata endpoint accessible from the application. By exploiting a Server-Side Request Forgery (SSRF) vulnerability, the researcher accessed:
- Instance metadata and configuration
- Service account tokens with BigQuery access
- Project-level IAM policies
- Cloud SQL connection strings
This chain: SSRF, metadata access, credential extraction, lateral movement.

### Case Study 5: Multi-Cloud Credential Reuse
Cloud enumeration across AWS, Azure, and GCP revealed credential reuse patterns:
- Same API keys used in multiple cloud providers
- Service account keys exposed in code repositories
- Default credentials not rotated after deployment
These patterns enabled cross-cloud lateral movement and demonstrated the importance of centralized secrets management.

## Advanced Techniques and Bypass

### Cloud Provider IP Range Analysis
- Map cloud provider IP ranges to target assets using published IP lists
- Identify cloud-hosted services through reverse DNS lookups
- Analyze BGP routing for cloud provider relationships
- Use certificate transparency logs for cloud service discovery

### Metadata Endpoint Bypass Techniques
- Exploit SSRF vulnerabilities to access metadata endpoints
- Use DNS rebinding to bypass network restrictions
- Exploit application misconfigurations that expose metadata
- Use container escape techniques to access host metadata

### IAM Privilege Escalation Paths
- Identify IAM roles with pass-role permissions
- Find Lambda function creation roles for code execution
- Locate EC2 instance profiles with excessive permissions
- Discover S3 bucket policy misconfigurations for data access

### Cloud-Native Service Discovery
- Enumerate serverless functions through API Gateway patterns
- Identify container orchestration services through DNS and API patterns
- Discover managed database services through connection string analysis
- Detect cloud-native monitoring and logging services

### Cross-Account Role Chaining
- Identify cross-account trust relationships in IAM policies
- Map role chaining paths for privilege escalation
- Discover federation configurations for external identity providers
- Analyze SAML and OIDC configurations for authentication bypass

### Cloud Logging Evasion
- Identify cloud logging configurations and their gaps
- Use cloud-native services that may not be logged
- Exploit logging delays for temporary access
- Analyze log retention policies for forensic implications

## Detection and Indicators

### Network-Based Detection Indicators
- Unusual API calls to cloud provider endpoints
- Metadata endpoint access attempts from applications
- DNS queries for cloud-specific service domains
- API calls from unusual IP addresses or geographic locations

### Cloud Provider Detection Mechanisms
- AWS CloudTrail logging and anomaly detection
- Azure Activity Log and Azure AD sign-in logs
- GCP Cloud Audit Logs and Access Transparency
- Cloud-native threat detection services (AWS GuardDuty, Azure Sentinel, GCP Chronicle)

### Behavioral Indicators
- Enumeration patterns across multiple cloud services
- Permission enumeration and policy analysis activities
- Storage bucket and container access attempts
- Metadata endpoint probing from application contexts

### Configuration Indicators
- Public access permissions on storage resources
- Overly permissive IAM policies
- Missing encryption configurations
- Disabled logging and monitoring services

## Impact Assessment

### Data Exposure Risks
- **Public Storage Buckets**: Direct access to sensitive data without authentication
- **Metadata Endpoint Exposure**: Credential theft and instance compromise
- **IAM Misconfigurations**: Unauthorized access to cloud resources
- **Logging Gaps**: Inability to detect and respond to security incidents

### Privilege Escalation Paths
- **IAM Role Assumption**: Gaining elevated permissions through role chaining
- **Lambda Function Execution**: Code execution through function manipulation
- **EC2 Instance Profile Abuse**: Accessing resources through instance credentials
- **Cross-Account Access**: Lateral movement across cloud accounts

### Business Impact
- **Data Breach**: Exposure of sensitive customer and business data
- **Compliance Violations**: Failure to meet regulatory requirements for cloud security
- **Financial Loss**: Unauthorized resource consumption and data theft
- **Reputation Damage**: Loss of customer trust due to cloud security failures

### Risk Scoring
- **Critical**: Public storage with sensitive data, metadata endpoint access, IAM compromise
- **High**: Overly permissive IAM, unencrypted storage, missing MFA
- **Medium**: Information disclosure, logging gaps, outdated configurations
- **Low**: Minor misconfigurations with limited impact

## Common Pitfalls

1. **Single Cloud Focus**: Not enumerating across all cloud providers used by the target
2. **Metadata Blindness**: Not testing metadata endpoints for accessibility
3. **IAM Overlook**: Not analyzing IAM configurations for privilege escalation paths
4. **Storage Enumeration Gaps**: Not checking all storage services (S3, EBS, RDS snapshots)
5. **DNS Misinterpretation**: Not correctly identifying cloud services through DNS records
6. **Credential Reuse**: Not checking for credential reuse across cloud providers
7. **Configuration File Miss**: Not analyzing exposed configuration files for cloud credentials
8. **Container Oversight**: Not detecting containerized environments and their cloud integrations
9. **Serverless Blindness**: Not identifying serverless functions and their configurations
10. **Logging Evasion**: Not considering cloud logging and detection capabilities
11. **Rate Limiting Issues**: Not handling API rate limits during enumeration
12. **Authentication Challenges**: Not properly handling cloud authentication for enumeration
13. **Tool Limitations**: Relying on single tools without cross-validation
14. **Scope Management**: Not properly scoping cloud enumeration within authorized boundaries
15. **Documentation Gaps**: Not maintaining comprehensive cloud inventory documentation

## Integration with Other Recon Areas

### Subdomain Enumeration Integration
- Use cloud-specific DNS records for subdomain discovery
- Identify cloud-hosted subdomains through CNAME analysis
- Correlate subdomain findings with cloud resource enumeration

### Port Scanning Correlation
- Scan cloud IP ranges for additional services
- Identify cloud-specific ports and services
- Correlate port scan results with cloud resource inventory

### Technology Stack Fingerprinting
- Identify cloud services through technology detection
- Correlate web application technologies with cloud hosting
- Detect cloud-native services through response patterns

### API Endpoint Discovery
- Enumerate cloud API endpoints and their security
- Discover serverless function endpoints
- Identify cloud management interfaces

### Configuration File Extraction
- Extract cloud credentials from configuration files
- Identify cloud-specific configuration patterns
- Detect exposed cloud API keys and tokens

## Reporting Template

### Executive Summary
- Cloud providers identified: [List]
- Total cloud resources discovered: [Number]
- Critical misconfigurations: [Number]
- High-risk findings: [Number]
- Estimated data exposure: [Volume]

### Cloud Resource Inventory
| Provider | Resource Type | Name/ID | Location | Access Level | Risk |
|----------|--------------|---------|----------|--------------|------|
| AWS | S3 Bucket | target-backup | us-east-1 | Public Read | Critical |
| AWS | Lambda Function | target-api | us-west-2 | Private | Medium |
| Azure | Blob Storage | targetdata | eastus | Authenticated | Low |
| GCP | GCS Bucket | target-assets | global | Public Read | High |

### Misconfiguration Findings
| Resource | Misconfiguration | Risk | Impact | Remediation |
|----------|-----------------|------|--------|-------------|
| S3 Bucket | Public read access | Critical | Data exposure | Enable bucket policies |
| IAM Role | Overly permissive | High | Privilege escalation | Apply least privilege |
| Metadata | Accessible from app | Critical | Credential theft | Restrict access |

### Attack Path Analysis
1. **Path 1**: S3 bucket access -> credential extraction -> IAM escalation -> full compromise
2. **Path 2**: SSRF vulnerability -> metadata endpoint -> service account theft -> data exfiltration
3. **Path 3**: Leaked credentials -> Azure AD access -> lateral movement -> admin privileges

### Recommendations
1. Implement cloud security posture management (CSPM) tools
2. Enable multi-factor authentication for all cloud accounts
3. Apply least privilege principle to IAM policies
4. Enable encryption for all storage services
5. Implement cloud logging and monitoring across all providers

## Practice Labs

### Lab 1: AWS S3 Bucket Enumeration
**Objective**: Discover and assess S3 bucket security
**Tools**: AWS CLI, Pacu, S3Scanner
**Steps**:
1. Enumerate S3 buckets using DNS and wordlist techniques
2. Test for public access permissions
3. Analyze bucket policies and ACLs
4. Document findings and risks
**Expected Results**: Complete S3 bucket inventory with security assessment

### Lab 2: Azure AD Enumeration
**Objective**: Enumerate Azure AD tenant and identify misconfigurations
**Tools**: ROADtools, Azure CLI, BloodHound
**Steps**:
1. Enumerate users, groups, and applications
2. Analyze conditional access policies
3. Identify privilege escalation paths
4. Document attack paths
**Expected Results**: Azure AD security assessment with attack path analysis

### Lab 3: GCP Metadata Endpoint Testing
**Objective**: Test for metadata endpoint accessibility and exploitation
**Tools**: curl, SSRF testing tools, custom scripts
**Steps**:
1. Test metadata endpoint accessibility
2. Extract instance information and credentials
3. Analyze IAM permissions for service accounts
4. Document potential attack paths
**Expected Results**: Metadata endpoint security assessment

### Lab 4: Multi-Cloud Credential Analysis
**Objective**: Identify credential reuse and exposure across cloud providers
**Tools**: Code analysis tools, breach databases, custom scripts
**Steps**:
1. Search for cloud credentials in code repositories
2. Check breach databases for cloud credentials
3. Analyze credential usage patterns
4. Document credential security risks
**Expected Results**: Cloud credential security assessment

## Ethical Guidelines

### Legal Compliance
- Only enumerate cloud resources within authorized scope
- Obtain explicit permission before testing cloud environments
- Comply with cloud provider terms of service
- Respect data privacy regulations in cloud environments

### Responsible Testing
- Minimize impact on cloud resources during enumeration
- Do not access or exfiltrate sensitive data without authorization
- Report cloud security findings through responsible disclosure
- Do not disrupt cloud services through excessive enumeration

### Professional Standards
- Document all cloud enumeration activities for accountability
- Use established tools and methodologies for cloud assessment
- Provide actionable recommendations for cloud security improvement
- Maintain confidentiality of cloud environment information

### Data Handling
- Do not store sensitive cloud data outside authorized environments
- Anonymize cloud data in reports where possible
- Securely delete cloud enumeration artifacts after engagement
- Comply with data retention policies for cloud assessments

## Quick Reference Cheat Sheet

### Cloud Provider Identification
```
dig CNAME TARGET_DOMAIN
curl -s -I https://TARGET_URL | grep -i "x-amz\|x-ms\|x-goog"
whois TARGET_IP | grep -i "amazon\|microsoft\|google"
```

### AWS Enumeration
```
aws s3 ls
aws s3api get-bucket-policy --bucket BUCKET
aws iam list-roles
aws lambda list-functions
aws ec2 describe-instances
```

### Azure Enumeration
```
az account list
az resource list
az ad user list
az role assignment list
az storage account list
```

### GCP Enumeration
```
gcloud config list
gcloud asset search-all-resources --scope=projects/PROJECT
gcloud iam service-accounts list
gsutil ls gs://BUCKET
```

### Metadata Endpoint Testing
```
curl -s http://169.254.169.254/latest/meta-data/
curl -s -H "Metadata:true" http://169.254.169.254/metadata/instance?api-version=2021-02-01
curl -s http://metadata.google.internal/computeMetadata/v1/ -H "Metadata-Flavor: Google"
```

### S3 Bucket Enumeration
```
aws s3 ls s3://BUCKET
aws s3api get-bucket-acl --bucket BUCKET
aws s3api get-bucket-policy --bucket BUCKET
curl -s https://BUCKET.s3.amazonaws.com
```