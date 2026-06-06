# 46 — Cloud Automation

## Scope

Cloud automation covers programmatic interaction with AWS, GCP, and Azure to discover assets, enumerate storage, abuse metadata services, trigger serverless scans, and alert on billing anomalies. The goal is to replace manual console clicks with reproducible, auditable code. This file focuses on the automation layer — SDK wiring, credential handling, scan orchestration in the cloud, and billing-driven alerting.

---

## 1. Credential Foundation

All cloud automation begins with credentials. Never bake credentials into source. Use the platform-native credential chain and inject secrets at runtime.

**AWS — credential chain order**: environment variables (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`), shared credentials file (`~/.aws/credentials`), IAM role (EC2/ECS/Lambda), SSO. Boto3 resolves this automatically.

```python
import boto3

# No explicit credentials — boto3 resolves from environment, then ~/.aws/credentials, then IMDS
session = boto3.Session(region_name="eu-west-1")
s3 = session.client("s3")
organizations = session.client("organizations")  # requires IAM permission
```

**GCP — application default credentials**. Use `gcloud auth application-default login` for local dev; workload identity for GCE/GKE; service-account JSON for CI/CD.

```python
from google.cloud import storage
from google.oauth2 import service_account

credentials = service_account.Credentials.from_service_account_file(
    "/run/secrets/gcp-sa.json"
)
storage_client = storage.Client(credentials=credentials, project="my-project")
```

**Azure — DefaultAzureCredential**. Chains environment variables, managed identity, VS Code credential, Azure CLI login.

```python
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient

credential = DefaultAzureCredential()
resource_client = ResourceManagementClient(credential, "subscription-id")
```

Store secrets in the environment or a secrets manager (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault). Do **not** commit `.env` files.

---

## 2. Cloud Asset Discovery Automation

Asset discovery at scale requires listing every resource type the cloud provider exposes. Use paginators — every `list_*` API is paginated.

**AWS — enumerate EC2, S3, RDS, and Lambda in a single sweep**.

```python
import boto3

def discover_aws(session: boto3.Session) -> dict:
    ec2 = session.client("ec2")
    s3  = session.client("s3")
    rds = session.client("rds")
    lam = session.client("lambda")

    assets = {"instances": [], "buckets": [], "rds": [], "lambdas": []}

    for page in ec2.get_paginator("describe_instances").paginate():
        for res in page["Reservations"]:
            for inst in res["Instances"]:
                assets["instances"].append({
                    "id": inst["InstanceId"],
                    "type": inst["InstanceType"],
                    "state": inst["State"]["Name"],
                    "public_ip": inst.get("PublicIpAddress"),
                })

    for bucket in s3.list_buckets()["Buckets"]:
        assets["buckets"].append({
            "name": bucket["Name"],
            "created": bucket["CreationDate"].isoformat(),
        })

    for page in rds.get_paginator("describe_db_instances").paginate():
        for db in page["DBInstances"]:
            assets["rds"].append({"id": db["DBInstanceIdentifier"], "engine": db["Engine"]})

    for page in lam.get_paginator("list_functions").paginate():
        for fn in page["Functions"]:
            assets["lambdas"].append({"name": fn["FunctionName"], "runtime": fn["Runtime"]})

    return assets
```

**GCP — enumerate Compute Engine instances, GCS buckets, and Cloud Functions.**

```python
from google.cloud import compute_v1, storage_v1, functions_v1

def discover_gcp(project_id: str) -> dict:
    assets = {"instances": [], "buckets": [], "functions": []}

    instance_client = compute_v1.InstancesClient()
    for zone in compute_v1.ZonesClient().list(project=project_id):
        for inst in instance_client.list(project=project_id, zone=zone.name):
            assets["instances"].append({
                "name": inst.name,
                "machine_type": inst.machine_type.split("/")[-1],
                "status": inst.status,
            })

    gcs = storage_v1.StorageClient()
    for bucket in gcs.list_buckets(project=project_id):
        assets["buckets"].append({"name": bucket.name, "location": bucket.location})

    functions_client = functions_v1.CloudFunctionsServiceClient()
    for fn in functions_client.list_functions(parent=f"projects/{project_id}/locations/-"):
        assets["functions"].append({"name": fn.name.split("/")[-1]})

    return assets
```

**Azure — enumerate VMs, storage accounts, and App Services.**

```python
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.storage import StorageManagementClient

def discover_azure(credential, subscription_id: str) -> dict:
    assets = {"vms": [], "storage": []}
    compute = ComputeManagementClient(credential, subscription_id)
    storage = StorageManagementClient(credential, subscription_id)

    for vm in compute.virtual_machines.list_all():
        assets["vms"].append({"name": vm.name, "size": vm.hardware_profile.vm_size})

    for sa in storage.storage_accounts.list():
        assets["storage"].append({"name": sa.name, "kind": sa.kind})

    return assets
```

---

## 3. Storage Enumeration Automation

Automated bucket/blob enumeration is one of the highest-value cloud automation tasks. The pattern is always: **list → iterate → check ACL/public access → check object list → probe known paths**.

**S3 — enumerate public buckets using Boto3 + bucket policy checks**.

```python
import boto3
from botocore.exceptions import ClientError

PUBLIC_ACL_FULL_CONTROL = "http://acs.amazonaws.com/groups/global/AllUsers"

def audit_s3_bucket(s3_client, bucket_name: str) -> dict:
    result = {"name": bucket_name, "public": False, "objects": 0, "findings": []}

    try:
        acl = s3_client.get_bucket_acl(Bucket=bucket_name)
        for grant in acl.get("Grants", []):
            grantee = grant.get("Grantee", {})
            uri = grantee.get("URI", "")
            if PUBLIC_ACL_FULL_CONTROL in uri:
                result["public"] = True
                result["findings"].append("AllUsers has full control")

        policy = s3_client.get_bucket_policy(Bucket=bucket_name).get("Policy", "{}")
        # parse JSON to find wildcard Principal "*" — omitted for brevity

        objects = s3_client.list_objects_v2(Bucket=bucket_name, MaxKeys=10)
        result["objects"] = objects.get("KeyCount", 0)
    except ClientError as e:
        result["error"] = str(e)

    return result
```

**GCS — enumerate buckets and check IAM policy bindings**.

```python
from google.cloud import storage
from google.cloud.storage.bucket import Bucket

def audit_gcs_bucket(bucket: Bucket) -> dict:
    result = {"name": bucket.name, "public": False, "findings": []}

    iam_policy = bucket.get_iam_policy()
    for binding in iam_policy.bindings:
        if "allUsers" in binding["members"]:
            result["public"] = True
            result["findings"].append(f"Role {binding['role']} granted to allUsers")

    blobs = list(bucket.list_blobs(max_results=10))
    result["object_count_min"] = len(blobs)
    return result
```

**Azure Blob — enumerate containers and check public access level**.

```python
from azure.storage.blob import BlobServiceClient

def audit_azure_blob(blob_service: BlobServiceClient) -> dict:
    results = []
    for container in blob_service.list_containers(include_metadata=True):
        acl = container.get_container_access_policy()
        access = acl.get("signed_identifiers", [])
        results.append({
            "container": container.name,
            "public_access": container.public_access,  # blob / container / None
        })
    return results
```

---

## 4. Serverless Scan Functions

Serverless functions (AWS Lambda, GCP Cloud Functions, Azure Functions) are ideal for scanning bursts: enumerate storage, probe URLs, invoke vulnerability scanners, or dispatch webhook alerts. They scale to zero when idle and cost pennies when active.

**AWS Lambda — Burp Suite reporter (Python 3.12 runtime)**.

```python
import json
import boto3

s3 = boto3.client("s3")
sqs = boto3.client("sqs")

SCAN_QUEUE_URL = "https://sqs.eu-west-1.amazonaws.com/123456789/scan-jobs"
RESULTS_BUCKET  = "scan-results-bucket"

def lambda_handler(event, context):
    for record in event["Records"]:
        body = json.loads(record["body"])
        target_url = body["url"]
        scan_result = run_nuclei_scan(target_url)  # your scanner

        key = f"results/{body['job_id']}.json"
        s3.put_object(
            Bucket=RESULTS_BUCKET,
            Key=key,
            Body=json.dumps(scan_result),
            ContentType="application/json",
        )

        # Forward to SQS for next pipeline stage
        sqs.send_message(
            QueueUrl=SCAN_QUEUE_URL,
            MessageBody=json.dumps({"job_id": body["job_id"], "result_key": key}),
        )
    return {"statusCode": 200}
```

**GCP Cloud Function — triggered by Pub/Sub on new asset discovery**.

```python
import base64
from google.cloud import storage, bigquery
from google.cloud import functions_v1

BQ_DATASET = "security"
BQ_TABLE   = "asset_inventory"

def ingest_asset(event, context):
    """Triggered by Pub/Sub message containing asset JSON."""
    payload = json.loads(base64.b64decode(event["data"]).decode())
    bq = bigquery.Client()
    rows = [(payload["asset_id"], payload["type"], payload["region"], payload["discovered_at"])]
    errors = bq.insert_rows_json(f"{BQ_DATASET}.{BQ_TABLE}", rows)
    if errors:
        print(f"BQ insert errors: {errors}")
```

**Lambda timeout / memory sizing for scanners**:

| Scanner         | Recommended Memory | Calculated Timeout |
|-----------------|--------------------|--------------------|
| subfinder       | 512 MB             | 300 sec            |
| nuclei          | 1024 MB            | 900 sec            |
| amass enum      | 2048 MB            | 900 sec            |

Set timeout via `boto3` or infrastructure-as-code:

```python
lambda_client = boto3.client("lambda")
lambda_client.update_function_configuration(
    FunctionName="nuclei-scan",
    MemorySize=1024,
    Timeout=900,
    Environment={"Variables": {"NUCLEI_TEMPLATES": "/tmp/templates"}},
)
```

---

## 5. Cloud IAM Enumeration Automation

IAM misconfigurations are the highest-impact cloud finding class. Automating IAM enumeration means programmatically listing policies, checking privilege boundaries, and detecting over-permissioned roles.

**AWS IAM — enumerate roles, policies attached, and cross-account trusts**.

```python
import boto3

iam = boto3.client("iam")

def enumerate_iam() -> dict:
    results = {"roles": []}
    for role in iam.list_roles()["Roles"]:
        attached = iam.list_attached_role_policies(RoleName=role["RoleName"])
        inline   = iam.list_role_policies(RoleName=role["RoleName"])
        trust    = role["AssumeRolePolicyDocument"]

        results["roles"].append({
            "name": role["RoleName"],
            "arn": role["Arn"],
            "attached_policies": [p["PolicyName"] for p in attached["AttachedPolicies"]],
            "inline_policies": inline["PolicyNames"],
            "trust_entities": [s.get("AWS") for s in trust.get("Statement", [{}])],
        })
    return results
```

**Flag dangerous trust patterns**:

```python
DANGEROUS_TRUST = {"*", "arn:aws:iam::*:root"}

def flag_dangerous_trust(roles: list) -> list:
    findings = []
    for role in roles:
        for entity in role["trust_entities"]:
            if entity in DANGEROUS_TRUST:
                findings.append({
                    "role": role["name"],
                    "arn": role["arn"],
                    "issue": f"Trusts {entity} — allows any account to assume",
                })
    return findings
```

**GCP IAM — enumerate service accounts and policy bindings**.

```python
from google.cloud import iam_v1

def enumerate_gcp_iam(project_id: str) -> dict:
    iam_client = iam_v1.IAMClient()
    results = {"service_accounts": [], "bindings": []}

    for sa in iam_client.list_service_accounts(name=f"projects/{project_id}"):
        results["service_accounts"].append({
            "name": sa.name,
            "email": sa.email,
            "disabled": sa.disabled,
        })

    crm = google.cloud.resourcemanager_v3.ProjectsClient()
    policy = crm.get_iam_policy(resource=f"projects/{project_id}")
    for binding in policy.bindings:
        results["bindings"].append({"role": binding.role, "members": list(binding.members)})

    return results
```

**Azure RBAC — enumerate role assignments and check for Owner/Contributor at subscription scope**.

```python
from azure.mgmt.authorization import AuthorizationManagementClient

def enumerate_azure_rbac(credential, subscription_id: str) -> dict:
    auth_client = AuthorizationManagementClient(credential, subscription_id)
    findings = []
    for assignment in auth_client.role_assignments.list(
        scope=f"/subscriptions/{subscription_id}"
    ):
        findings.append({
            "principal_id": assignment.principal_id,
            "role_definition_id": assignment.role_definition_id,
            "scope": assignment.scope,
        })
    return findings
```

---

## 6. Metadata Service Abuse Detection

Cloud metadata services (AWS IMDSv1/v2 at `169.254.169.254`, GCP metadata at `metadata.google.internal`, Azure IMDS at `169.254.169.254`) are a common SSRF pivot point. Automate detection by injecting payloads into every SSRF-capable parameter and flagging metadata responses.

**Automated metadata detection in Burp Repeater results (Python)**.

```python
import re

METADATA_IP = "169.254.169.254"
METADATA_HOSTS = [
    "169.254.169.254",
    "metadata.google.internal",
    "100.100.100.200",  # Alibaba
]

IMDS_INDICATORS = [
    "ami-", "instance-id", "account-id", "hostname",
    "iam/security-credentials/",
    "computeMetadata",
]

def detect_metadata_exposure(request_text: str, response_text: str) -> list:
    findings = []
    req_ip_matches = re.findall(r"(?:Host|Hostname)[:\s]+(\S+)", request_text)
    for ip in req_ip_matches:
        if ip in METADATA_HOSTS:
            findings.append(f"SSRF targeting metadata IP: {ip}")

    for indicator in IMDS_INDICATORS:
        if indicator in response_text:
            findings.append(f"Metadata data leaked: contains '{indicator}'")

    return findings
```

**Automated IMDSv2 token acquisition test (AWS-specific)**.

```python
import requests  # in Lambda, use urllib3 bundled layer

AWS_METADATA = "http://169.254.169.254/latest/meta-data/"
TOKEN_URL    = "http://169.254.169.254/latest/api/token"

def test_imdsv2() -> dict:
    try:
        token_resp = requests.put(
            TOKEN_URL,
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
            timeout=2,
        )
        token = token_resp.text if token_resp.status_code == 200 else None
        headers = {"X-aws-ec2-metadata-token": token} if token else {}

        resp = requests.get(AWS_METADATA + "iam/security-credentials/", headers=headers, timeout=2)
        if resp.status_code == 200 and resp.text.strip():
            return {
                "vulnerable": True,
                "imds_version": "v2" if token else "v1",
                "credentials_endpoint": f"iam/security-credentials/{resp.text.strip().splitlines()[0]}",
            }
    except requests.ConnectionError:
        return {"vulnerable": False, "reason": "metadata endpoint unreachable"}
    return {"vulnerable": False}
```

---

## 7. Cloud Metadata Service Abuse Detection — Scan Wrapper

Wrap the metadata test into a parameterized HTTP client for automated SSRF probes.

```python
import httpx

METADATA_PROBES = [
    "http://169.254.169.254/latest/meta-data/",
    "http://169.254.169.254/latest/user-data/",
    "http://metadata.google.internal/computeMetadata/v1/",
    "http://[::ffff:169.254.169.254]/latest/meta-data/",
    "http://0xA9FEA9FE/latest/meta-data/",      # hex IP
    "http://2852039166/latest/meta-data/",      # decimal IP
]

async def probe_metadata(httpx_client: httpx.AsyncClient, base_url: str, param_name: str) -> list:
    findings = []
    for probe_url in METADATA_PROBES:
        try:
            resp = await httpx_client.get(base_url, params={param_name: probe_url}, timeout=5)
            indicators = ["ami-", "instance-id", "iam/security-credentials", "computeMetadata"]
            if any(ind in resp.text for ind in indicators):
                findings.append({"param": param_name, "probe": probe_url, "status": resp.status_code})
        except httpx.TimeoutException:
            continue
    return findings
```

---

## 8. Billing Alerts

Unexpected billing spikes are an early indicator of abuse (unbounded Lambda invocations, compromised crypto miners, data exfil egress). Automate cost anomaly detection using cloud-native tools and a custom alerting layer.

**AWS — Budgets + SNS alarm**.

```python
import boto3

cloudwatch = boto3.client("cloudwatch")
sns = boto3.client("sns")

def create_billing_alarm(budget_name: str, threshold_usd: float, sns_topic_arn: str):
    alarm_name = f"budget-{budget_name}-exceeded"
    cloudwatch.put_metric_alarm(
        AlarmName=alarm_name,
        AlarmDescription=f"Estimated charges exceeded ${threshold_usd}",
        ActionsEnabled=True,
        AlarmActions=[sns_topic_arn],
        MetricName="EstimatedCharges",
        Namespace="AWS/Billing",
        Statistic="Maximum",
        Dimensions=[{"Name": "Currency", "Value": "USD"}],
        Period=86400,
        EvaluationPeriods=1,
        Threshold=threshold_usd,
        ComparisonOperator="GreaterThanThreshold",
        TreatMissingData="notBreaching",
    )
```

**GCP — Cloud Billing export to BigQuery + scheduled anomaly query**.

```sql
-- Run daily via scheduled query
WITH daily_costs AS (
  SELECT
    DATE(usage_start_time) AS cost_date,
    SUM(cost) AS daily_total
  FROM `myproject.billing.gcp_billing_export_v1`
  WHERE usage_start_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  GROUP BY cost_date
),
stats AS (
  SELECT
    AVG(daily_total) AS mean_cost,
    STDDEV(daily_total) AS stddev_cost
  FROM daily_costs
  WHERE cost_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
)
SELECT d.cost_date, d.daily_total, s.mean_cost, s.stddev_cost
FROM daily_costs d CROSS JOIN stats s
WHERE d.cost_date = CURRENT_DATE() - 1
  AND d.daily_total > s.mean_cost + 3 * s.stddev_cost;
```

**Azure — Cost Management API + Logic App alert**.

```python
from azure.mgmt.costmanagement import CostManagementClient

def query_azure_costs(credential, subscription_id: str) -> list:
    cm_client = CostManagementClient(credential, subscription_id)

    result = cm_client.query.usage(
        scope=f"/subscriptions/{subscription_id}",
        parameters={
            "type": "ActualCost",
            "timeframe": "Custom",
            "time_period": {
                "from_property": "2025-01-01T00:00:00Z",
                "to": "2025-01-31T23:59:59Z",
            },
            "dataset": {
                "granularity": "Daily",
                "aggregation": {"totalCost": {"name": "Cost", "function": "Sum"}},
                "grouping": [{"type": "Dimension", "name": "ResourceGroupName"}],
            },
        },
    )
    return [row.as_dict() for row in result.rows()]
```

---

## 9. Automation Patterns — Orchestrating the Cloud Scan

A production cloud automation run is a directed acyclic graph (DAG) of tasks: discover → enumerate → scan → analyze → report → alert. Represent this as a Python function pipeline with explicit retry semantics.

```python
import tenacity
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=30),
    retry=tenacity.retry_if_exception_type((ConnectionError, TimeoutError)),
)
def discover_assets_with_retry(session):
    return discover_aws(session)

def run_cloud_scan_pipeline(session):
    pipeline_state = {}

    pipeline_state["assets"] = discover_assets_with_retry(session)

    s3_findings = []
    for bucket in pipeline_state["assets"]["buckets"]:
        s3_findings.append(audit_s3_bucket(session.client("s3"), bucket["name"]))
    pipeline_state["s3_findings"] = [f for f in s3_findings if f["findings"]]

    pipeline_state["iam_findings"] = flag_dangerous_trust(enumerate_iam()["roles"])

    publish_results(pipeline_state)
    send_billing_status_check()
    return pipeline_state
```

---

## 10. Security of Automation Credentials

The automation account itself must follow least-privilege. Create a dedicated IAM role for scanning with these permissions only:

- `s3:ListAllMyBuckets`, `s3:GetBucketLocation`, `s3:GetBucketAcl`, `s3:GetBucketPolicy`
- `iam:ListRoles`, `iam:ListAttachedRolePolicies`, `iam:ListRolePolicies`
- `ec2:Describe*`, `rds:Describe*`, `lambda:List*`
- `organizations:ListAccounts` (if multi-account)

Never grant `*` or `AdministratorAccess` to automation roles. Rotate access keys every 90 days. Use IAM Access Analyzer to detect over-permissioned policies.

```python
# Validate that the current role has only expected permissions
def validate_automation_role_permissions():
    iam = boto3.client("iam")
    caller = boto3.client("sts").get_caller_identity()
    role_arn = caller["Arn"]

    attached = iam.list_attached_role_policies(RoleName=role_arn.split("/")[-1])
    allowed_actions = {
        p["PolicyName"]
        for p in attached["AttachedPolicies"]
    }
    unexpected = allowed_actions - EXPECTED_POLICY_SET
    if unexpected:
        raise SecurityError(f"Unexpected policies attached to automation role: {unexpected}")
```

---

## 11. Output Standards

Cloud automation outputs should be structured for downstream consumption by SIEMs, ticketing systems, and reporting pipelines. Use a consistent JSON schema:

```json
{
  "scan_id": "uuid",
  "scan_type": "s3-enum",
  "provider": "aws",
  "timestamp": "2025-06-05T12:00:00Z",
  "scope": {"account_id": "123456789", "region": "eu-west-1"},
  "findings": [
    {
      "finding_id": "uuid",
      "severity": "HIGH",
      "title": "S3 bucket publicly readable",
      "bucket": "my-exposed-bucket",
      "evidence": {"acl_grantees": ["AllUsers:READ"], "url": "http://my-exposed-bucket.s3.amazonaws.com/"},
      "remediation_steps": ["Enable Block Public Access", "Review bucket policy"]
    }
  ],
  "metadata": {"tool_version": "1.0.0", "scanned_resources": 42}
}
```

Persist to S3/GCS as `scan_id/findings.jsonl` (newline-delimited JSON for streaming downstream).

```python
import json

def write_findings_jsonl(findings: list, bucket: str, key: str):
    lines = [json.dumps(f) for f in findings]
    s3.put_object(Bucket=bucket, Key=key, Body="\n".join(lines) + "\n", ContentType="application/x-ndjson")
```

---

## 12. Observability for Cloud Automation

Log every cloud API call with correlation ID. Emit structured logs to CloudWatch / Cloud Logging so you can trace a single scan end-to-end.

```python
import logging
import uuid

logger = logging.getLogger("cloud_automation")

def run_with_correlation(fn, *args, **kwargs):
    correlation_id = str(uuid.uuid4())
    logger.info("starting", extra={"correlation_id": correlation_id, "function": fn.__name__})
    try:
        result = fn(*args, **kwargs)
        logger.info("completed", extra={"correlation_id": correlation_id, "status": "success"})
        return result
    except Exception as e:
        logger.error("failed", extra={"correlation_id": correlation_id, "error": str(e)})
        raise
```

Key metrics to emit:

| Metric Name               | Type    | Use Case                           |
|---------------------------|---------|------------------------------------|
| `cloud_scan.api_calls`    | Counter | Total cloud SDK calls per run      |
| `cloud_scan.findings`     | Counter | Total findings by severity         |
| `cloud_scan.duration_ms`  | Histogram | End-to-end scan duration        |
| `cloud_scan.errors`       | Counter | SDK errors, rate limits            |
| `cloud_scan.cost_usd`     | Gauge   | Estimated API cost per run         |

---

## 13. Testing Cloud Automation

Test cloud automation locally with Moto (AWS) and freezegun (time mocking), without hitting real cloud APIs.

```python
import boto3
from moto import mock_aws

@mock_aws
def test_discover_aws_buckets():
    s3 = boto3.client("s3", region_name="us-east-1")
    s3.create_bucket(Bucket="test-bucket")
    s3.create_bucket(Bucket="public-bucket")
    s3.put_bucket_acl(Bucket="public-bucket", ACL="public-read")

    session = boto3.Session(region_name="us-east-1")
    assets = discover_aws(session)

    assert len(assets["buckets"]) == 2
    public_findings = [audit_s3_bucket(s3, b["name"]) for b in assets["buckets"]]
    assert any(f["public"] for f in public_findings)
```

**GCP — use `unittest.mock` to patch GCP clients**.

```python
from unittest.mock import MagicMock, patch

@patch("google.cloud.storage.Client")
def test_discover_gcs_buckets(mock_client_cls):
    mock_bucket = MagicMock()
    mock_bucket.name = "test-bucket"
    mock_bucket.location = "US"
    mock_client = mock_client_cls.return_value
    mock_client.list_buckets.return_value = [mock_bucket]

    assets = discover_gcs("my-project")
    assert assets["buckets"][0]["name"] == "test-bucket"
```

---

## 14. CI/CD Integration

Cloud automation pipelines must run on every PR that touches cloud tooling. Use GitHub Actions with OIDC role assumption — no long-lived secrets.

```yaml
name: Cloud Automation Scan
on: [push, pull_request]

permissions:
  id-token: write
  contents: read

jobs:
  cloud_scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions-cloud-scan
          aws-region: eu-west-1
      - name: Run cloud automation
        run: python -m cloud_scan.run --output results/
      - name: Upload findings
        uses: actions/upload-artifact@v4
        with: { name: cloud-findings, path: results/ }
```

---

## 15. Compliance Considerations

Cloud automation touching production accounts triggers audit questions. Address these proactively:

- **Tag all automation resources** with `Owner`, `Team`, `Purpose`, `ExpirationDate` so they survive audits.
- **Enable AWS CloudTrail / GCP Cloud Audit Logs / Azure Activity Log** for every automation API call. Correlate with the `correlation_id` in logs.
- **Respect rate limits**: implement exponential backoff with jitter to avoid triggering anomaly detection.
- **Store scan evidence for 90 days** minimum to support post-incident review.
- **SCP / Org Policy**: deploy AWS SCPs that deny `s3:DeleteBucket`, `rds:DeleteDBInstance`, and `iam:Delete*` from the automation role's session policy.

```python
from botocore.credentials import AssumeRoleProvider

# Use session policies to restrict what the automation role can do even further
boto3.setup_default_session(
    region_name="eu-west-1",
    # ...
)
```

---

## 16. Cost Guardrails

Cloud scanning costs grow non-linearly with scope size. Apply guardrails before invoking expensive API calls.

```python
import math

def estimate_s3_scan_cost(bucket_count: int, objects_per_bucket: int) -> float:
    # Pricing as of 2025: LIST request $0.005 per 1000, GET $0.0004 per 1000
    list_calls  = math.ceil(bucket_count * objects_per_bucket / 1000)
    head_calls  = math.ceil(bucket_count / 1000)
    cost_usd    = (list_calls * 0.005) + (head_calls * 0.0004)
    if cost_usd > 10.0:
        raise ValueError(f"Estimated cost ${cost_usd:.2f} exceeds $10 guardrail")
    return cost_usd
```

Expose a `MAX_COST_USD` env var and gate the pipeline:

```python
MAX_COST_USD = float(os.environ.get("MAX_COST_USD", "5.0"))
estimated = estimate_scan_cost(asset_count)
if estimated > MAX_COST_USD:
    logger.error(f"Aborting: est. cost ${estimated:.2f} > guardrail ${MAX_COST_USD}")
    sys.exit(2)
```

---

## 17. Cross-Account Scanning with AWS Organizations

Multi-account environments require an assumed-role walk across member accounts. Use AWS Organizations to enumerate accounts, then STS to assume the automation role in each.

```python
import boto3
from botocore.exceptions import ClientError

MASTER_ROLE_ARN = "arn:aws:iam::999888777:role/organization-admin"

def assume_role(role_arn, session_name="cloud-scan"):
    sts = boto3.client("sts")
    resp = sts.assume_role(RoleArn=role_arn, RoleSessionName=session_name)
    creds = resp["Credentials"]
    return boto3.Session(
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"],
    )

def scan_all_accounts():
    org_session = boto3.Session()
    org = org_session.client("organizations")
    accounts = [
        a for a in org.list_accounts()["Accounts"]
        if a["Status"] == "ACTIVE"
    ]
    results = {}
    for acct in accounts:
        role_arn = f"arn:aws:iam::{acct['Id']}:role/automation-role"
        try:
            session = assume_role(role_arn)
            results[acct["Id"]] = discover_aws(session)
        except ClientError as e:
            results[acct["Id"]] = {"error": str(e)}
    return results
```

---

## 18. Continuous Cloud Asset Monitoring

Use EventBridge (AWS) / Cloud Functions (GCP) / Event Grid (Azure) for change-driven scans rather than polling.

**AWS EventBridge rule → Lambda re-scan on EC2 launch**.

```python
# Terraform/OpenTofu — declarative event target
resource "aws_cloudwatch_event_rule" "ec2_launch" {
  name        = "ec2-instance-launch"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": { "state": ["running"] }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ec2_launch.name
  arn       = aws_lambda_function.scanner.arn
}
```

**GCP — Cloud Asset Inventory export to BigQuery, trigger on new asset events**.

```sql
-- Scheduled query to detect new public buckets
CREATE OR REPLACE TABLE `myproject.security.new_bucket_alerts` AS
WITH new_buckets AS (
  SELECT * FROM `myproject.inventory.gcp_inventory`
  WHERE asset_type = "storage.googleapis.com/Bucket"
    AND _PARTITIONTIME = TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
    AND iam_policy.policy.bindings.members CONTAINS "allUsers"
)
SELECT asset_name, iam_policy, discovered_time FROM new_buckets;
```

---

## 19. Reporting Cloud Findings

Aggregate findings into a markdown or SARIF report. SARIF is consumed by GitHub Advanced Security, Azure DevOps, and CodeQL.

```python
import json
from datetime import datetime, timezone

def findings_to_sarif(findings: list, scan_id: str) -> dict:
    sarif = {
        "version": "2.1.0",
        "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
        "runs": [{
            "tool": {"driver": {"name": "cloud-scan", "version": "1.0.0"}},
            "results": [
                {
                    "ruleId": f["finding_id"],
                    "level": "warning" if f["severity"] in ("HIGH", "CRITICAL") else "note",
                    "message": {"text": f["title"]},
                    "locations": [{"physicalLocation": {"artifactLocation": {"uri": f.get("bucket", "cloud")}}}],
                }
                for f in findings
            ],
            "invocations": [{"executionSuccessful": True, "endTimeUtc": datetime.now(timezone.utc).isoformat()}],
        }],
    }
    return sarif

def write_sarif_report(findings: list, output_path: str):
    sarif = findings_to_sarif(findings, scan_id=str(uuid.uuid4()))
    with open(output_path, "w") as f:
        json.dump(sarif, f, indent=2)
```

---

## 20. Reference Checklist

Before triggering cloud automation in a production environment, confirm:

- [ ] Credentials loaded via platform-native chain, not hardcoded
- [ ] Assume role cross-account chain tested in isolation
- [ ] Cost guardrail configured (`MAX_COST_USD`)
- [ ] Retry policy with exponential backoff applied to SDK calls
- [ ] Scan output written as JSONL to designated storage bucket
- [ ] CloudWatch / Cloud Logging / Azure Monitor sink configured
- [ ] Billing alert threshold set (recommended: 2x baseline)
- [ ] `correlation_id` attached to all log entries
- [ ] IAM permissions for automation role reviewed via Access Analyzer
- [ ] CI/CD pipeline uses OIDC, no long-lived secrets
