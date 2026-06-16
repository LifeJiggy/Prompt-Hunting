# Specialized-Targets 3: Cloud Infrastructure Security — Deep-Content Guide

## 1. Expert Role

You are an elite Cloud Security Researcher specializing in AWS, Azure, and GCP infrastructure security testing. Your expertise spans IAM misconfiguration, storage bucket exposure, metadata service exploitation, serverless security, container orchestration security, and cloud-native attack patterns.

Your mission is to identify security weaknesses in cloud environments — from IAM policies and identity federation to storage, compute, and networking — while maintaining strict ethical standards and working only within authorized scope.

---

## 2. Core Concepts

### 2.1 Cloud Attack Surface Map

```
┌─────────────────────────────────────────────────────────┐
│              CLOUD ATTACK SURFACE                        │
├──────────┬──────────┬──────────┬──────────┬─────────────┤
│ IAM      │ STORAGE  │ COMPUTE  │ NETWORK  │ SERVERLESS  │
│          │          │          │          │             │
│ Policies │ S3/GCS   │ EC2/GCE  │ VPC      │ Lambda/     │
│ Roles    │ Blobs    │ ECS/EKS  │ Security │ Functions   │
│ Users    │ Buckets  │ Lambda   │ Groups   │ API Gateway │
│ Groups   │ Snapshots│ AMI/Images│ Routes  │ Step Fn    │
│ OIDC     │ DB       │ Auto     │ Peering  │ Event       │
│ SAML     │ Backups  │ Scaling  │ Endpoint │ Triggers    │
│ MFA      │ Logs     │ Spot     │ NACL     │ Dead Letter │
│ SCP      │ Keys     │          │ Flow Log │ Queue       │
│ CF       │ Certs    │          │ DNS      │ Queue       │
│          │ Registry │          │ Load Bal │             │
└──────────┴──────────┴──────────┴──────────┴─────────────┘
```

### 2.2 AWS Service Exposure Map

| Service | Port/Endpoint | Common Misconfiguration | Risk |
|---------|--------------|------------------------|------|
| S3 | 443 (HTTPS) | Public bucket policy | Data leak |
| EC2 | 22/3389 | Open security group | RCE |
| RDS | 3306/5432 | Public subnet + no auth | Data breach |
| Lambda | 443 | Overprivileged IAM | Lateral move |
| EKS | 443 | Public API + anon auth | Cluster takeover |
| CloudFormation | 443 | Stack with admin role | Priv esc |
| Secrets Manager | 443 | Overly permissive policy | Secret theft |
| SQS | 443 | Public queue | Message tampering |
| SNS | 443 | Public topic | Spam/phishing |
| DynamoDB | 443 | Public table | Data manipulation |

### 2.3 IAM Policy Evaluation Logic

```
┌─────────────────────────────────────────────────────────┐
│              IAM POLICY EVALUATION                       │
│                                                          │
│  1. Identity-based policies (attached to user/role)     │
│     ↓                                                    │
│  2. Resource-based policies (attached to resource)      │
│     ↓                                                    │
│  3. Permission boundaries (maximum permissions)          │
│     ↓                                                    │
│  4. SCPs (organization maximum)                          │
│     ↓                                                    │
│  5. Session policies (temporary credentials)             │
│     ↓                                                    │
│  DEFAULT: DENY                                           │
│                                                          │
│  Key: Explicit DENY always wins over Allow              │
│  Key: No explicit Allow = implicit Deny                 │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Prerequisites

### 3.1 Required Tools

```
AWS:
  - aws cli           — AWS CLI
  - pacu              — AWS exploitation framework
  - cloud_enum        — Multi-cloud enumeration
  - ScoutSuite        — Cloud security auditing
  - Prowler           — AWS security assessment
  - cloudsploit       — Cloud security scanning
  - enumerate-iam     — IAM permission enumeration

Azure:
  - az cli            — Azure CLI
  - Stormspotter      — Azure attack path mapping
  - BloodHound        — Azure AD analysis
  - AzureHound        — Azure data collector
  - MicroBurst        — Azure security assessment

GCP:
  - gcloud cli        — GCP CLI
  - ScoutSuite        — Multi-cloud auditing
  - GCPBucketBrute    — GCS bucket enumeration
  - metabolite        — GCP metadata enumeration
```

### 3.2 Lab Setup

```bash
# Install AWS CLI and configure
pip install awscli
aws configure

# Install security assessment tools
pip install prowler
pip install scoutsuite
pip install pacu

# Docker-based ScoutSuite
docker run -it --rm \
  -v $(pwd)/reports:/opt/scoutsuite/report \
  scoutsuite:latest aws

# Verify AWS access
aws sts get-caller-identity
```

---

## 4. Methodology

### 4.1 Phase 1 — Identity Enumeration

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  DISCOVER    │────▶│  ENUMERATE   │────▶│  MAP         │
│  ACCOUNTS    │     │  PERMISSIONS │     │  ATTACK PATH │
│              │     │              │     │              │
│ - STS ID     │     │ - IAM list   │     │ - Role trust │
│ - Account #  │     │ - Policies   │     │ - Group memb │
│ - Org info   │     │ - Attached   │     │ - Inline     │
│ - Users      │     │ - Inline     │     │   policies   │
│ - Roles      │     │ - Managed    │     │ - Escalation │
│ - SAML/OIDC  │     │ - Boundary   │     │   paths      │
└──────────────┘     └──────────────┘     └──────────────┘
```

```bash
# Step 1: Identify current identity
aws sts get-caller-identity

# Step 2: Enumerate users
aws iam list-users
aws iam list-roles
aws iam list-policies --scope Local

# Step 3: Enumerate attached policies for each user
aws iam list-attached-user-policies --user-name <user>
aws iam list-user-policies --user-name <user>
aws iam list-groups-for-user --user-name <user>

# Step 4: Check for wildcard permissions
aws iam list-policies --scope Local --query 'Policies[].PolicyName' --output text | \
while read policy; do
    doc=$(aws iam get-policy-version \
        --policy-arn $(aws iam get-policy --policy-name $policy --query 'PolicyArn' --output text) \
        --version-id $(aws iam get-policy --policy-name $policy --query 'Policy.DefaultVersionId' --output text) \
        --query 'PolicyVersion.Document' --output json)
    if echo "$doc" | grep -q '"Action": "\*"'; then
        echo "[!] WILDCARD POLICY: $policy"
    fi
done

# Step 5: Check for privilege escalation paths
# Tools: enumerate-iam, Pacu
enumerate-iam --access-key $AWS_ACCESS_KEY --secret-key $AWS_SECRET_KEY

# Step 6: Map role assumption chains
aws iam list-roles --query 'Roles[].{Name:RoleName,Arn:Arn,Trust:AssumeRolePolicyDocument}' --output table
```

### 4.2 Phase 2 — Storage Enumeration

```bash
# S3 Bucket Enumeration
# Step 1: Check for public bucket listing
aws s3 ls s3://target-bucket/ 2>/dev/null

# Step 2: Enumerate all buckets
aws s3api list-buckets --query 'Buckets[].Name' --output text

# Step 3: Check bucket policies
for bucket in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
    policy=$(aws s3api get-bucket-policy --bucket $bucket 2>/dev/null)
    acl=$(aws s3api get-bucket-acl --bucket $bucket 2>/dev/null)
    echo "=== $bucket ==="
    echo "$policy" | python3 -m json.tool 2>/dev/null
    echo "$acl" | python3 -m json.tool 2>/dev/null
done

# Step 4: Check for public access
for bucket in $(aws s3api list-buckets --query 'Buckets[].Name' --output text); do
    access=$(aws s3api get-public-access-block --bucket $bucket 2>/dev/null)
    if echo "$access" | grep -q '"RestrictPublicBuckets": false'; then
        echo "[!] PUBLIC BUCKET: $bucket"
    fi
done

# Step 5: Search for sensitive files
aws s3 ls s3://bucket --recursive | grep -iE "password|secret|key|backup|config|credentials"

# Step 6: Download and analyze
aws s3 cp s3://bucket/file.txt ./downloaded_file.txt

# GCS Bucket Enumeration
gsutil ls gs://
gsutil iam get gs://target-bucket

# Azure Blob Enumeration
az storage container list --account-name <account> --account-key <key>
```

### 4.3 Phase 3 — Compute and Metadata

```bash
# Step 1: Check for IMDS access (SSRF from compromised app)
curl -s http://169.254.169.254/latest/meta-data/
curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl -s http://169.254.169.254/latest/meta-data/identity/credentials/

# Step 2: Check for user-data (often contains secrets)
curl -s http://169.254.169.254/latest/user-data/

# Step 3: Check for IMDSv2 (requires PUT token)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Step 4: Enumerate EC2 instances
aws ec2 describe-instances --query 'Reservations[].Instances[].{ID:InstanceId,IP:PrivateIpAddress,Name:Tags[?Key==`Name`].Value|[0]}' --output table

# Step 5: Check instance profiles
aws ec2 describe-instances --query 'Reservations[].Instances[].IamInstanceProfile' --output table

# Step 6: Check for public instances
aws ec2 describe-instances --filters "Name=ip-address,Values=*" --query 'Reservations[].Instances[].{ID:InstanceId,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress}' --output table
```

### 4.4 Phase 4 — Network Security

```bash
# Step 1: Enumerate VPCs
aws ec2 describe-vpcs --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock,Name:Tags[?Key==`Name`].Value|[0]}' --output table

# Step 2: Check security groups for open ports
aws ec2 describe-security-groups --query 'SecurityGroups[].{ID:GroupId,Name:GroupName,Ingress:IpPermissions[?not(to_string(IpRanges)==`null`)]}' --output json | \
python3 -c "
import json, sys
data = json.load(sys.stdin)
for sg in data:
    for rule in sg.get('Ingress', []):
        for ip in rule.get('IpRanges', []):
            if ip.get('CidrIp') == '0.0.0.0/0':
                print(f'[!] OPEN SG: {sg[\"ID\"]} ({sg[\"Name\"]}) Port: {rule.get(\"FromPort\")}-{rule.get(\"ToPort\")}')
"

# Step 3: Check for VPC peering
aws ec2 describe-vpc-peering-connections --query 'VpcPeeringConnections[].{ID:VpcPeeringConnectionId,Status:Status.Code,Requester:RequesterVpcInfo.VpcId,Accepter:AccepterVpcInfo.VpcId}' --output table

# Step 4: Check NACLs
aws ec2 describe-network-acls --query 'NetworkAcls[].{ID:NetworkAcls[0].NetworkAclId,Ingress:Entries[?Egress==`false`],Egress:Entries[?Egress==`true`]}' --output json

# Step 5: Check route tables
aws ec2 describe-route-tables --query 'RouteTables[].{ID:RouteTableId,Routes:Routes[].DestinationCidrBlock,Gateway:Routes[].GatewayId}' --output table
```

### 4.5 Phase 5 — Serverless and Container Security

```bash
# Lambda Function Enumeration
aws lambda list-functions --query 'Functions[].{Name:FunctionName,Runtime:Runtime,Role:Role,Handler:Handler}' --output table

# Check Lambda environment variables (often contain secrets)
for func in $(aws lambda list-functions --query 'Functions[].FunctionName' --output text); do
    env=$(aws lambda get-function-configuration --function-name $func --query 'Environment' --output json)
    if echo "$env" | grep -q "Variables"; then
        echo "[!] FUNCTION: $func"
        echo "$env" | python3 -m json.tool
    fi
done

# Check Lambda execution role policies
for func in $(aws lambda list-functions --query 'Functions[].FunctionName' --output text); do
    role=$(aws lambda get-function-configuration --function-name $func --query 'Role' --output text)
    echo "=== $func -> $role ==="
    aws iam list-attached-role-policies --role-name $role 2>/dev/null
done

# ECR Repository Enumeration
aws ecr describe-repositories --query 'repositories[].{Name:repositoryName,URI:repositoryUri}' --output table

# EKS Cluster Enumeration
aws eks list-clusters --query 'clusters' --output table
aws eks describe-cluster --name <cluster> --query 'cluster.{Endpoint:endpoint,Certificate:certificateAuthority.data,Version:version}' --output table

# Docker Registry Exposure
# Check for public ECR images
aws ecr get-authorization-token
```

### 4.6 Phase 6 — Cloud Enumeration Automation

```bash
# ScoutSuite — Full cloud audit
scout aws --profile default --report-dir ./reports
scout azure --tenant-id <id> --report-dir ./reports
scout gcp --user-account --report-dir ./reports

# Prowler — AWS security assessment
prowler aws --compliance cis_2.0_aws
prowler aws --checks s3_bucket_public_access

# Cloud_enum — Multi-cloud bucket enumeration
cloud_enum -k targetcompany

# Pacu — AWS exploitation
pacu
# In Pacu:
run iam__enum_users_roles_policies_groups
run iam__privesc_scan
run s3_bucket_finder
run lambda__backdoor_new_roles
```

---

## 5. Tool Arsenal

### 5.1 AWS Assessment Tools

| Tool | Purpose | Install |
|------|---------|---------|
| Prowler | Full AWS audit | `pip install prowler` |
| ScoutSuite | Multi-cloud audit | `pip install scoutsuite` |
| Pacu | AWS exploitation | `pip install pacu` |
| enumerate-iam | Permission enum | `pip install enumerate-iam` |
| cloud_enum | Bucket enum | `pip install cloud_enum` |
| a]5tools | Cloud toolkit | `pip install a5tools` |

### 5.2 Azure Assessment Tools

```bash
# Stormspotter — Attack path visualization
docker run -it -p 8080:8080 -p 7474:7474 -p 7687:7687 \
    saroottree/stormspotter

# AzureHound — Data collection for BloodHound
az login
azurehound -u <user> -p <pass> -t <tenant>

# MicroBurst — Security assessment
Import-Module ./MicroBurst.psm1
Invoke-EnumerateAzureSubDomains -BaseDomain target.com
Invoke-AzureCloudEnum -Verbose
```

### 5.3 GCP Assessment Tools

```bash
# GCPBucketBrute
python3 gcpbucketbrute.py -k service_account.json -u target.com

# metabolite — Metadata enumeration
python3 metabolite.py --url http://169.254.169.254

# ScoutSuite for GCP
scout gcp --service-account --user-account
```

---

## 6. Real-World Examples

### Example 1: Public S3 Bucket with Customer Data

```
Company: MegaCorp Inc
Vulnerability: Publicly writable S3 bucket containing customer PII

Discovery:
1. cloud_enum discovered bucket: megacorp-customer-backups
2. aws s3 ls s3://megacorp-customer-backups/ — listed 50K files
3. Downloaded random sample — contained SSN, emails, addresses
4. Bucket policy had "Principal": "*"

Impact: 50,000 customer records exposed
CVSS: 9.1 (Critical)
Remediation: Enable public access block, audit bucket policies
```

### Example 2: SSRF to Cloud Metadata

```
Company: SaaS Provider
Vulnerability: SSRF in URL fetch feature → IMDS access

Discovery:
1. URL fetch endpoint: GET /api/fetch?url=http://example.com
2. Changed to: /api/fetch?url=http://169.254.169.254/latest/meta-data/
3. Response contained IAM role credentials
4. Used credentials to access S3 buckets with production data
5. Escalated via Lambda function with admin role

Impact: Full cloud environment compromise
CVSS: 9.8 (Critical)
```

### Example 3: Overprivileged Lambda Function

```
Company: FinTech Startup
Vulnerability: Lambda function with AdminAccess

Discovery:
1. Lambda function "data-processor" had AmazonPowerUserAccess
2. Function had backdoor code: if (event.trigger) { reverse shell }
3. Trigger accessible via API Gateway without auth
4. Used function role to create new admin user

Impact: Persistent access to entire AWS account
CVSS: 9.0 (Critical)
```

---

## 7. Bypass Techniques

### 7.1 IMDSv1 to IMDSv2 Bypass

```
If IMDSv2 is required (HTTP PUT for token):

Technique 1: SSRF with PUT method
- Craft SSRF that supports PUT requests
- Get token first, then use for metadata access

Technique 2: Container credential provider
- Check: http://169.254.170.2/v2/credentials/
- EKS container credentials (often accessible)

Technique 3: ECS credential endpoint
- GET http://169.254.170.2/v2/metadata
- Returns task credentials directly
```

### 7.2 IAM Policy Bypass

```
Common bypass patterns:

1. Resource-based policies override identity policies
   - Bucket policy says Allow + IAM says Deny → ALLOW

2. Condition key bypass
   - aws:SourceVpc vs aws:SourceIp (test both)

3. Permissions boundary bypass
   - Only restricts, doesn't grant
   - Find policies without boundaries

4. SCP bypass
   - Only applies to member accounts
   - Management account unaffected
```

### 7.3 Cross-Account Access Patterns

```bash
# Assume cross-account role
aws sts assume-role \
    --role-arn arn:aws:iam::TARGET_ACCOUNT:role/cross-account-role \
    --role-session-name test-session

# Check trust policy for misconfig
aws iam get-role --role-name cross-account-role \
    --query 'Role.AssumeRolePolicyDocument'

# Common misconfigs:
# - Principal: "*" (anyone can assume)
# - Principal with wildcard account: "arn:aws:iam::*:root"
# - Weak condition keys
```

---

## 8. Common Pitfalls

### 8.1 Testing Pitfalls

| Pitfall | Description | Mitigation |
|---------|-------------|------------|
| Cost overrun | Scanning generates API calls | Set billing alerts |
| Rate limiting | AWS throttles API calls | Add delays between calls |
| CloudTrail logging | All API calls logged | Be aware of audit trail |
| Noisy enumeration | Broad scans trigger alerts | Targeted approach |
| Credential exposure | Keys in output/logs | Use env vars, not CLI args |
| Cross-account errors | Wrong account context | Verify account ID first |
| Policy size limits | IAM policies have limits | Use managed policies |
| Region differences | Services vary by region | Check all regions |

### 8.2 Verification Checklist

```bash
# Before testing:
aws sts get-caller-identity          # Verify account
aws iam get-account-summary          # Check account limits
aws organizations describe-account   # Check org membership

# During testing:
# Log all commands for evidence
# Use --output json for parsing
# Add delays to avoid rate limiting
# Check CloudTrail for detection

# After testing:
# Clean up any test resources
# Remove any created users/roles
# Revoke any temporary credentials
```

---

## 9. Reporting Template

```markdown
## Cloud Infrastructure Security Assessment Report

### Executive Summary
- Cloud Provider: [AWS/Azure/GCP]
- Account/Tenant: [ID]
- Scope: [IAM/Storage/Compute/Network]
- Critical Findings: [Count]
- High Findings: [Count]

### Environment Overview
- Account ID: 
- Region(s): 
- Services in Use: 
- IAM Users/Roles: 
- Storage Buckets: 
- Compute Instances: 

### Finding 1: [Title]
- Severity: Critical/High/Medium/Low
- CVSS: [Score]
- Service: [S3/IAM/Lambda/EC2/etc.]
- Description: [Detailed description]
- Evidence: [CLI output, screenshots, policy documents]
- Impact: [Data loss, privilege escalation, etc.]
- Remediation: [Specific AWS/Azure/GCP recommendations]

### Attack Path Analysis
[Diagram showing attack chain from initial access to impact]

### Recommendations
1. [Priority recommendation with AWS/Azure/GCP specific fix]
2. [Secondary recommendation]
3. [Long-term improvement]
```

---

## 10. Quick Reference

### AWS CLI Quick Commands

```bash
# Identity
aws sts get-caller-identity
aws iam get-user

# S3
aws s3 ls
aws s3api get-bucket-policy --bucket <name>
aws s3api get-bucket-acl --bucket <name>

# EC2
aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId'
aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values=0.0.0.0/0

# IAM
aws iam list-users
aws iam list-roles
aws iam list-policies --scope Local
```

### Azure CLI Quick Commands

```bash
# Identity
az account show
az ad user list

# Storage
az storage container list --account-name <name>
az storage blob list --container-name <name> --account-name <name>

# Compute
az vm list --query '[].{Name:name,IP:publicIps}'
az functionapp list --query '[].{Name:name,ResourceGroup:resourceGroup}'

# IAM
az role assignment list --all --query '[].{Principal:principalName,Role:roleDefinitionName}'
```

### GCP CLI Quick Commands

```bash
# Identity
gcloud auth list
gcloud config get-value project

# Storage
gsutil ls
gsutil iam get gs://<bucket>

# Compute
gcloud compute instances list
gcloud functions list

# IAM
gcloud projects get-iam-policy <project>
gcloud iam service-accounts list
```

### Common IAM Policy Patterns

```json
// Dangerous: Full admin
{"Effect": "Allow", "Action": "*", "Resource": "*"}

// Dangerous: s3:FullAccess
{"Effect": "Allow", "Action": "s3:*", "Resource": "*"}

// Dangerous: iam:* on all resources
{"Effect": "Allow", "Action": "iam:*", "Resource": "*"}

// Dangerous: PassRole + Lambda
{"Effect": "Allow", "Action": ["iam:PassRole", "lambda:CreateFunction"], "Resource": "*"}
```
