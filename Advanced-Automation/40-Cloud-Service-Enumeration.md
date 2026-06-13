# Automated Cloud Service Enumeration

## Expert Role
You are a cloud service enumeration specialist and security engineer who designs, develops, and maintains automated systems for discovering and enumerating cloud infrastructure across AWS, Azure, and GCP. Your expertise spans AWS (S3, Lambda, EC2, IAM), Azure (Blob, Functions, AD), GCP (GCS, Cloud Functions), cloud metadata endpoints, bucket enumeration, service discovery, and credential exposure detection. You understand cloud provider APIs, metadata services, identity and access management, and how misconfigured cloud services can lead to data breaches, unauthorized access, and infrastructure compromise. Your role is to build robust, maintainable enumeration pipelines that identify cloud assets and misconfigurations before attackers can exploit them, and provide actionable remediation guidance for secure cloud deployment.

## Core Concepts
- **Cloud Service Models**: Understanding IaaS, PaaS, and SaaS cloud models. Each model has different security responsibilities and attack surfaces. Know the shared responsibility model for each provider.
- **Cloud Provider APIs**: AWS, Azure, and GCP expose APIs for service management. Understanding API endpoints, authentication mechanisms, and rate limiting is crucial for enumeration.
- **Metadata Services**: Cloud instances provide metadata services (AWS: 169.254.169.254, Azure: 169.254.169.254, GCP: metadata.google.internal). These services can be exploited via SSRF to obtain credentials and configuration.
- **Identity and Access Management (IAM)**: Each cloud provider has IAM systems controlling access to resources. Misconfigured IAM policies can lead to privilege escalation and unauthorized access.
- **Storage Services**: S3 (AWS), Blob Storage (Azure), GCS (GCP) are common targets for data breaches. Understanding bucket policies, access controls, and encryption is essential.
- **Serverless Functions**: Lambda (AWS), Functions (Azure), Cloud Functions (GCP) can contain sensitive code and environment variables. Enumeration involves discovering functions and extracting secrets.
- **Container Services**: ECS, EKS (AWS), AKS (Azure), GKE (GCP) orchestrate containers. Misconfigurations can lead to container escape and cluster compromise.
- **Cloud Security Posture**: Understanding cloud security best practices and common misconfigurations helps in identifying vulnerabilities during enumeration.
- **Credential Exposure**: Cloud credentials can be exposed in code repositories, configuration files, and environment variables. Detecting exposed credentials is a critical enumeration task.
- **Enumeration Techniques**: Active enumeration involves querying APIs and services. Passive enumeration involves analyzing public resources and metadata. Both techniques are essential for comprehensive coverage.

## Prerequisites
- Python 3.8+ with `boto3`, `azure-mgmt`, `google-cloud` libraries
- AWS CLI, Azure CLI, and gcloud CLI installed and configured
- Understanding of cloud computing concepts and architectures
- Familiarity with REST APIs and authentication mechanisms
- Knowledge of IAM policies and access control
- Understanding of network security and firewall rules
- Basic knowledge of cryptography and encryption
- Command-line proficiency with cloud CLI tools
- Understanding of common cloud misconfigurations
- Network debugging tools (curl, netcat, nmap)

## Methodology

### Phase 1: Provider Discovery
1. Identify which cloud providers the target uses
2. Discover cloud service endpoints and APIs
3. Map public-facing cloud resources
4. Identify authentication mechanisms
5. Document cloud architecture and dependencies

### Phase 2: Enumeration
1. Enumerate storage services (S3, Blob, GCS)
2. Enumerate compute services (EC2, Lambda, VMs)
3. Enumerate database services (RDS, CosmosDB, Cloud SQL)
4. Enumerate identity and access management
5. Enumerate networking and security configurations

### Phase 3: Credential Detection
1. Scan code repositories for exposed credentials
2. Analyze configuration files for secrets
3. Test metadata endpoints for credential leakage
4. Identify IAM misconfigurations
5. Document credential exposure risks

### Phase 4: Misconfiguration Analysis
1. Analyze storage bucket policies
2. Review IAM policies for over-permissions
3. Check security group and firewall rules
4. Validate encryption configurations
5. Assess logging and monitoring setup

### Phase 5: Exploitation Assessment
1. Test for unauthorized access via misconfigurations
2. Assess impact of credential exposure
3. Evaluate privilege escalation opportunities
4. Test for data exfiltration possibilities
5. Document exploitation scenarios

### Phase 6: Reporting and Remediation
1. Document all findings with evidence
2. Prioritize findings by severity and impact
3. Provide specific remediation recommendations
4. Implement automated monitoring
5. Train teams on cloud security best practices

## Tool Arsenal

### AWS Enumeration
```python
import boto3
import json
from typing import Dict, List, Optional
from datetime import datetime
import requests

class AWSEnumerator:
    def __init__(self, access_key: str = None, secret_key: str = None, 
                 session_token: str = None, region: str = 'us-east-1'):
        self.region = region
        
        if access_key and secret_key:
            self.session = boto3.Session(
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
                aws_session_token=session_token,
                region_name=region
            )
        else:
            self.session = boto3.Session()
        
        self.findings = []
    
    def enumerate_s3_buckets(self) -> Dict:
        """Enumerate S3 buckets"""
        try:
            s3_client = self.session.client('s3')
            response = s3_client.list_buckets()
            
            buckets = []
            for bucket in response['Buckets']:
                bucket_info = {
                    'name': bucket['Name'],
                    'creation_date': bucket['CreationDate'].isoformat(),
                    'permissions': self._check_bucket_permissions(bucket['Name']),
                    'encryption': self._check_bucket_encryption(bucket['Name']),
                    'logging': self._check_bucket_logging(bucket['Name']),
                    'versioning': self._check_bucket_versioning(bucket['Name'])
                }
                buckets.append(bucket_info)
                
                # Check for public access
                if self._is_bucket_public(bucket['Name']):
                    self.findings.append({
                        'service': 'S3',
                        'resource': bucket['Name'],
                        'issue': 'Public Bucket',
                        'severity': 'high',
                        'details': 'S3 bucket is publicly accessible'
                    })
            
            return {'buckets': buckets, 'total': len(buckets)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def _check_bucket_permissions(self, bucket_name: str) -> Dict:
        """Check bucket permissions"""
        try:
            s3_client = self.session.client('s3')
            
            # Check bucket policy
            try:
                policy = s3_client.get_bucket_policy(Bucket=bucket_name)
                policy_doc = json.loads(policy['Policy'])
                is_public = self._is_policy_public(policy_doc)
            except:
                is_public = False
                policy_doc = None
            
            # Check ACL
            acl = s3_client.get_bucket_acl(Bucket=bucket_name)
            public_grants = [
                grant for grant in acl['Grants']
                if grant.get('Grantee', {}).get('URI') == 'http://acs.amazonaws.com/groups/global/AllUsers'
            ]
            
            return {
                'is_public': is_public or len(public_grants) > 0,
                'policy': policy_doc,
                'public_grants': len(public_grants)
            }
            
        except Exception as e:
            return {'error': str(e)}
    
    def _check_bucket_encryption(self, bucket_name: str) -> Dict:
        """Check bucket encryption"""
        try:
            s3_client = self.session.client('s3')
            encryption = s3_client.get_bucket_encryption(Bucket=bucket_name)
            
            return {
                'enabled': True,
                'rules': encryption.get('ServerSideEncryptionConfiguration', {}).get('Rules', [])
            }
            
        except:
            return {'enabled': False}
    
    def _check_bucket_logging(self, bucket_name: str) -> Dict:
        """Check bucket logging"""
        try:
            s3_client = self.session.client('s3')
            logging = s3_client.get_bucket_logging(Bucket=bucket_name)
            
            return {
                'enabled': 'LoggingEnabled' in logging,
                'target_bucket': logging.get('LoggingEnabled', {}).get('TargetBucket')
            }
            
        except:
            return {'enabled': False}
    
    def _check_bucket_versioning(self, bucket_name: str) -> Dict:
        """Check bucket versioning"""
        try:
            s3_client = self.session.client('s3')
            versioning = s3_client.get_bucket_versioning(Bucket=bucket_name)
            
            return {
                'status': versioning.get('Status', 'Suspended'),
                'mfa_delete': versioning.get('MFADelete', 'Disabled')
            }
            
        except:
            return {'status': 'Suspended'}
    
    def _is_bucket_public(self, bucket_name: str) -> bool:
        """Check if bucket is publicly accessible"""
        permissions = self._check_bucket_permissions(bucket_name)
        return permissions.get('is_public', False)
    
    def _is_policy_public(self, policy_doc: Dict) -> bool:
        """Check if bucket policy allows public access"""
        if 'Statement' in policy_doc:
            for statement in policy_doc['Statement']:
                principal = statement.get('Principal', {})
                if principal == '*' or (isinstance(principal, dict) and principal.get('AWS') == '*'):
                    return True
        return False
    
    def enumerate_lambda_functions(self) -> Dict:
        """Enumerate Lambda functions"""
        try:
            lambda_client = self.session.client('lambda')
            response = lambda_client.list_functions()
            
            functions = []
            for function in response['Functions']:
                function_info = {
                    'name': function['FunctionName'],
                    'arn': function['FunctionArn'],
                    'runtime': function['Runtime'],
                    'handler': function['Handler'],
                    'environment': function.get('Environment', {}).get('Variables', {}),
                    'vpc_config': function.get('VpcConfig', {}),
                    'last_modified': function['LastModified']
                }
                functions.append(function_info)
                
                # Check for sensitive environment variables
                env_vars = function.get('Environment', {}).get('Variables', {})
                for key, value in env_vars.items():
                    if any(sensitive in key.lower() for sensitive in ['password', 'secret', 'key', 'token']):
                        self.findings.append({
                            'service': 'Lambda',
                            'resource': function['FunctionName'],
                            'issue': 'Sensitive Environment Variable',
                            'severity': 'medium',
                            'details': f"Environment variable '{key}' may contain sensitive data"
                        })
            
            return {'functions': functions, 'total': len(functions)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def enumerate_ec2_instances(self) -> Dict:
        """Enumerate EC2 instances"""
        try:
            ec2_client = self.session.client('ec2')
            response = ec2_client.describe_instances()
            
            instances = []
            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    instance_info = {
                        'id': instance['InstanceId'],
                        'type': instance['InstanceType'],
                        'state': instance['State']['Name'],
                        'private_ip': instance.get('PrivateIpAddress'),
                        'public_ip': instance.get('PublicIpAddress'),
                        'security_groups': instance.get('SecurityGroups', []),
                        'iam_profile': instance.get('IamInstanceProfile', {}),
                        'tags': instance.get('Tags', [])
                    }
                    instances.append(instance_info)
                    
                    # Check for public exposure
                    if instance.get('PublicIpAddress'):
                        self.findings.append({
                            'service': 'EC2',
                            'resource': instance['InstanceId'],
                            'issue': 'Public Instance',
                            'severity': 'medium',
                            'details': f"Instance has public IP: {instance['PublicIpAddress']}"
                        })
            
            return {'instances': instances, 'total': len(instances)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def enumerate_iam_policies(self) -> Dict:
        """Enumerate IAM policies"""
        try:
            iam_client = self.session.client('iam')
            
            # Get all policies
            policies = []
            paginator = iam_client.get_paginator('list_policies')
            for page in paginator.paginate(Scope='Local'):
                for policy in page['Policies']:
                    policy_info = {
                        'name': policy['PolicyName'],
                        'arn': policy['Arn'],
                        'version': policy['DefaultVersionId'],
                        'attachment_count': policy['AttachmentCount']
                    }
                    policies.append(policy_info)
            
            # Check for over-permissive policies
            for policy in policies:
                policy_version = iam_client.get_policy_version(
                    PolicyArn=policy['Arn'],
                    VersionId=policy['version']
                )
                policy_doc = policy_version['PolicyVersion']['Document']
                
                if self._is_policy_over_permissive(policy_doc):
                    self.findings.append({
                        'service': 'IAM',
                        'resource': policy['name'],
                        'issue': 'Over-Permissive Policy',
                        'severity': 'high',
                        'details': 'IAM policy grants excessive permissions'
                    })
            
            return {'policies': policies, 'total': len(policies)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def _is_policy_over_permissive(self, policy_doc: Dict) -> bool:
        """Check if IAM policy is over-permissive"""
        if 'Statement' in policy_doc:
            for statement in policy_doc['Statement']:
                if statement.get('Effect') == 'Allow':
                    actions = statement.get('Action', [])
                    if isinstance(actions, str):
                        actions = [actions]
                    
                    # Check for wildcard actions
                    if '*' in actions:
                        return True
                    
                    # Check for sensitive actions
                    sensitive_actions = [
                        'iam:*', 'sts:AssumeRole', 's3:*',
                        'lambda:CreateFunction', 'ec2:RunInstances'
                    ]
                    for action in sensitive_actions:
                        if action in actions:
                            return True
        
        return False
    
    def test_metadata_endpoint(self) -> Dict:
        """Test cloud metadata endpoint"""
        metadata_urls = {
            'aws': 'http://169.254.169.254/latest/meta-data/',
            'azure': 'http://169.254.169.254/metadata/instance?api-version=2021-02-01',
            'gcp': 'http://metadata.google.internal/computeMetadata/v1/'
        }
        
        results = {}
        
        for provider, url in metadata_urls.items():
            try:
                headers = {}
                if provider == 'azure':
                    headers['Metadata'] = 'true'
                elif provider == 'gcp':
                    headers['Metadata-Flavor'] = 'Google'
                
                response = requests.get(url, headers=headers, timeout=5)
                
                if response.status_code == 200:
                    results[provider] = {
                        'accessible': True,
                        'status_code': response.status_code,
                        'response_preview': response.text[:500],
                        'severity': 'critical'
                    }
                    
                    # Extract credentials if available
                    if provider == 'aws':
                        self._extract_aws_credentials(response.text)
                    elif provider == 'azure':
                        self._extract_azure_credentials(response.text)
                        
            except Exception as e:
                results[provider] = {
                    'accessible': False,
                    'error': str(e)
                }
        
        return results
    
    def _extract_aws_credentials(self, metadata: str):
        """Extract AWS credentials from metadata"""
        try:
            # Get IAM credentials
            credentials_url = 'http://169.254.169.254/latest/meta-data/iam/security-credentials/'
            response = requests.get(credentials_url, timeout=5)
            
            if response.status_code == 200:
                role_name = response.text.strip()
                credentials_url = f"{credentials_url}{role_name}"
                response = requests.get(credentials_url, timeout=5)
                
                if response.status_code == 200:
                    credentials = response.json()
                    self.findings.append({
                        'service': 'AWS Metadata',
                        'resource': 'IAM Credentials',
                        'issue': 'Exposed Credentials',
                        'severity': 'critical',
                        'details': f"IAM credentials accessible via metadata endpoint"
                    })
                    
        except Exception:
            pass
    
    def _extract_azure_credentials(self, metadata: str):
        """Extract Azure credentials from metadata"""
        try:
            data = json.loads(metadata)
            if 'compute' in data:
                self.findings.append({
                    'service': 'Azure Metadata',
                    'resource': 'Instance Metadata',
                    'issue': 'Metadata Accessible',
                    'severity': 'high',
                    'details': 'Azure instance metadata is accessible'
                })
                
        except Exception:
            pass
    
    def generate_report(self) -> Dict:
        """Generate enumeration report"""
        return {
            'timestamp': datetime.now().isoformat(),
            'findings': self.findings,
            'summary': {
                'total_findings': len(self.findings),
                'critical': len([f for f in self.findings if f['severity'] == 'critical']),
                'high': len([f for f in self.findings if f['severity'] == 'high']),
                'medium': len([f for f in self.findings if f['severity'] == 'medium']),
                'low': len([f for f in self.findings if f['severity'] == 'low']),
            }
        }
```

### Azure Enumeration
```python
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.storage import StorageManagementClient
from azure.mgmt.compute import ComputeManagementClient
import azure.functions as func

class AzureEnumerator:
    def __init__(self, subscription_id: str = None, credential = None):
        self.subscription_id = subscription_id
        self.credential = credential
        self.findings = []
        
        if subscription_id and credential:
            self.resource_client = ResourceManagementClient(credential, subscription_id)
            self.storage_client = StorageManagementClient(credential, subscription_id)
            self.compute_client = ComputeManagementClient(credential, subscription_id)
    
    def enumerate_storage_accounts(self) -> Dict:
        """Enumerate Azure Storage accounts"""
        try:
            storage_accounts = self.storage_client.storage_accounts.list()
            
            accounts = []
            for account in storage_accounts:
                account_info = {
                    'name': account.name,
                    'location': account.location,
                    'sku': account.sku.name if account.sku else None,
                    'kind': account.kind,
                    'encryption': account.encryption,
                    'access_tier': account.access_tier
                }
                accounts.append(account_info)
                
                # Check for public access
                if account.allow_blob_public_access:
                    self.findings.append({
                        'service': 'Azure Blob',
                        'resource': account.name,
                        'issue': 'Public Blob Access',
                        'severity': 'high',
                        'details': 'Storage account allows public blob access'
                    })
            
            return {'accounts': accounts, 'total': len(accounts)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def enumerate_virtual_machines(self) -> Dict:
        """Enumerate Azure VMs"""
        try:
            vms = self.compute_client.virtual_machines.list_all()
            
            vm_list = []
            for vm in vms:
                vm_info = {
                    'name': vm.name,
                    'location': vm.location,
                    'vm_size': vm.hardware_profile.vm_size if vm.hardware_profile else None,
                    'os_type': vm.storage_profile.os_disk.os_type if vm.storage_profile else None,
                    'public_ip': self._get_public_ip(vm.id),
                    'nics': [nic.id for nic in (vm.network_profile.network_interfaces or [])]
                }
                vm_list.append(vm_info)
                
                # Check for public IP
                if vm_info['public_ip']:
                    self.findings.append({
                        'service': 'Azure VM',
                        'resource': vm.name,
                        'issue': 'Public VM',
                        'severity': 'medium',
                        'details': f"VM has public IP: {vm_info['public_ip']}"
                    })
            
            return {'vms': vm_list, 'total': len(vm_list)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def _get_public_ip(self, vm_id: str) -> str:
        """Get public IP for a VM"""
        try:
            # Extract resource group from VM ID
            resource_group = vm_id.split('/')[4]
            vm_name = vm_id.split('/')[-1]
            
            # Get network interfaces
            nic_list = self.compute_client.network_interfaces.list(resource_group)
            
            for nic in nic_list:
                if nic.virtual_machine.id == vm_id:
                    for ip_config in nic.ip_configurations:
                        if ip_config.public_ip_address:
                            return ip_config.public_ip_address.id
            
            return None
            
        except Exception:
            return None
    
    def enumerate_azure_ad(self) -> Dict:
        """Enumerate Azure Active Directory"""
        try:
            # This would require Microsoft Graph API
            # Simplified example
            return {
                'note': 'Azure AD enumeration requires Microsoft Graph API access',
                'recommendation': 'Use Azure AD Python or Microsoft Graph API'
            }
            
        except Exception as e:
            return {'error': str(e)}
    
    def test_metadata_endpoint(self) -> Dict:
        """Test Azure metadata endpoint"""
        url = 'http://169.254.169.254/metadata/instance?api-version=2021-02-01'
        headers = {'Metadata': 'true'}
        
        try:
            response = requests.get(url, headers=headers, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                
                self.findings.append({
                    'service': 'Azure Metadata',
                    'resource': 'Instance Metadata',
                    'issue': 'Metadata Accessible',
                    'severity': 'critical',
                    'details': 'Azure metadata endpoint is accessible'
                })
                
                return {
                    'accessible': True,
                    'data': data,
                    'severity': 'critical'
                }
                
        except Exception as e:
            return {'accessible': False, 'error': str(e)}
    
    def generate_report(self) -> Dict:
        """Generate Azure enumeration report"""
        return {
            'timestamp': datetime.now().isoformat(),
            'findings': self.findings,
            'summary': {
                'total_findings': len(self.findings),
                'critical': len([f for f in self.findings if f['severity'] == 'critical']),
                'high': len([f for f in self.findings if f['severity'] == 'high']),
                'medium': len([f for f in self.findings if f['severity'] == 'medium']),
                'low': len([f for f in self.findings if f['severity'] == 'low']),
            }
        }
```

### GCP Enumeration
```python
from google.cloud import storage
from google.cloud import compute_v1
from google.cloud import functions_v1
import google.auth

class GCPEnumerator:
    def __init__(self, project_id: str = None):
        self.project_id = project_id
        self.findings = []
        
        if project_id:
            self.storage_client = storage.Client(project=project_id)
            self.compute_client = compute_v1.InstancesClient()
            self.functions_client = functions_v1.CloudFunctionsServiceClient()
    
    def enumerate_gcs_buckets(self) -> Dict:
        """Enumerate Google Cloud Storage buckets"""
        try:
            buckets = self.storage_client.list_buckets()
            
            bucket_list = []
            for bucket in buckets:
                bucket_info = {
                    'name': bucket.name,
                    'location': bucket.location,
                    'storage_class': bucket.storage_class,
                    'versioning_enabled': bucket.versioning_enabled,
                    'encryption': bucket.default_kms_key_name,
                    'iam_configuration': bucket.iam_configuration
                }
                bucket_list.append(bucket_info)
                
                # Check for public access
                if self._is_bucket_public(bucket):
                    self.findings.append({
                        'service': 'GCS',
                        'resource': bucket.name,
                        'issue': 'Public Bucket',
                        'severity': 'high',
                        'details': 'GCS bucket is publicly accessible'
                    })
            
            return {'buckets': bucket_list, 'total': len(bucket_list)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def _is_bucket_public(self, bucket) -> bool:
        """Check if GCS bucket is publicly accessible"""
        try:
            policy = bucket.get_iam_policy(requested_policy_version=3)
            
            for binding in policy.bindings:
                if 'allUsers' in binding.get('members', []) or 'allAuthenticatedUsers' in binding.get('members', []):
                    return True
            
            return False
            
        except Exception:
            return False
    
    def enumerate_compute_instances(self) -> Dict:
        """Enumerate GCP compute instances"""
        try:
            instances = self.compute_client.list(project=self.project_id, zone='-')
            
            instance_list = []
            for instance in instances:
                instance_info = {
                    'name': instance.name,
                    'zone': instance.zone.split('/')[-1],
                    'machine_type': instance.machine_type.split('/')[-1],
                    'status': instance.status,
                    'network_interfaces': [
                        {
                            'name': ni.name,
                            'network': ni.network,
                            'network_ip': ni.network_ip,
                            'access_configs': ni.access_configs
                        }
                        for ni in instance.network_interfaces
                    ],
                    'service_accounts': instance.service_accounts
                }
                instance_list.append(instance_info)
                
                # Check for public IP
                for ni in instance.network_interfaces:
                    if ni.access_configs:
                        self.findings.append({
                            'service': 'GCP VM',
                            'resource': instance.name,
                            'issue': 'Public VM',
                            'severity': 'medium',
                            'details': 'VM has external IP address'
                        })
                
                # Check for default service account
                for sa in instance.service_accounts:
                    if 'compute@developer.gserviceaccount.com' in sa.email:
                        self.findings.append({
                            'service': 'GCP VM',
                            'resource': instance.name,
                            'issue': 'Default Service Account',
                            'severity': 'medium',
                            'details': 'VM uses default service account'
                        })
            
            return {'instances': instance_list, 'total': len(instance_list)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def enumerate_cloud_functions(self) -> Dict:
        """Enumerate GCP Cloud Functions"""
        try:
            parent = f'projects/{self.project_id}/locations/-'
            functions = self.functions_client.list_functions(parent=parent)
            
            function_list = []
            for function in functions:
                function_info = {
                    'name': function.name,
                    'description': function.description,
                    'runtime': function.runtime,
                    'entry_point': function.entry_point,
                    'https_trigger': function.https_trigger,
                    'environment_variables': function.environment_variables
                }
                function_list.append(function_info)
                
                # Check for sensitive environment variables
                env_vars = function.environment_variables or {}
                for key, value in env_vars.items():
                    if any(sensitive in key.lower() for sensitive in ['password', 'secret', 'key', 'token']):
                        self.findings.append({
                            'service': 'Cloud Functions',
                            'resource': function.name,
                            'issue': 'Sensitive Environment Variable',
                            'severity': 'medium',
                            'details': f"Environment variable '{key}' may contain sensitive data"
                        })
            
            return {'functions': function_list, 'total': len(function_list)}
            
        except Exception as e:
            return {'error': str(e)}
    
    def test_metadata_endpoint(self) -> Dict:
        """Test GCP metadata endpoint"""
        url = 'http://metadata.google.internal/computeMetadata/v1/'
        headers = {'Metadata-Flavor': 'Google'}
        
        try:
            response = requests.get(url, headers=headers, timeout=5)
            
            if response.status_code == 200:
                self.findings.append({
                    'service': 'GCP Metadata',
                    'resource': 'Instance Metadata',
                    'issue': 'Metadata Accessible',
                    'severity': 'critical',
                    'details': 'GCP metadata endpoint is accessible'
                })
                
                # Try to get service account token
                token_url = 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token'
                token_response = requests.get(token_url, headers=headers, timeout=5)
                
                if token_response.status_code == 200:
                    token_data = token_response.json()
                    self.findings.append({
                        'service': 'GCP Metadata',
                        'resource': 'Service Account Token',
                        'issue': 'Token Accessible',
                        'severity': 'critical',
                        'details': 'Service account token accessible via metadata'
                    })
                
                return {
                    'accessible': True,
                    'severity': 'critical'
                }
                
        except Exception as e:
            return {'accessible': False, 'error': str(e)}
    
    def generate_report(self) -> Dict:
        """Generate GCP enumeration report"""
        return {
            'timestamp': datetime.now().isoformat(),
            'findings': self.findings,
            'summary': {
                'total_findings': len(self.findings),
                'critical': len([f for f in self.findings if f['severity'] == 'critical']),
                'high': len([f for f in self.findings if f['severity'] == 'high']),
                'medium': len([f for f in self.findings if f['severity'] == 'medium']),
                'low': len([f for f in self.findings if f['severity'] == 'low']),
            }
        }
```

### Credential Detection Scanner
```python
class CloudCredentialScanner:
    def __init__(self):
        self.credential_patterns = {
            'aws_access_key': r'AKIA[0-9A-Z]{16}',
            'aws_secret_key': r'(?i)aws_secret_access_key[=:]\s*[\'"]*([A-Za-z0-9/+=]{40})',
            'aws_session_token': r'(?i)aws_session_token[=:]\s*[\'"]*([A-Za-z0-9/+=]{100,})',
            'azure_connection_string': r'DefaultEndpointsProtocol=https;AccountName=[^;]+;AccountKey=[A-Za-z0-9+/=]{88}',
            'azure_storage_key': r'(?i)AccountKey[=:]\s*[\'"]*([A-Za-z0-9+/=]{88})',
            'gcp_service_account': r'"type"\s*:\s*"service_account"',
            'gcp_api_key': r'AIza[0-9A-Za-z_-]{35}',
            'github_token': r'ghp_[A-Za-z0-9]{36}',
            'slack_token': r'xox[bpas]-[0-9]{10,}-[a-zA-Z0-9-]+',
            'private_key': r'-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----',
        }
    
    def scan_file(self, filepath: str) -> List[Dict]:
        """Scan file for exposed credentials"""
        findings = []
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
                for credential_type, pattern in self.credential_patterns.items():
                    matches = re.findall(pattern, content)
                    
                    for match in matches:
                        findings.append({
                            'file': filepath,
                            'type': credential_type,
                            'match': match[:50] + '...' if len(match) > 50 else match,
                            'severity': self._get_severity(credential_type)
                        })
                        
        except Exception as e:
            pass
        
        return findings
    
    def scan_repository(self, repo_path: str) -> List[Dict]:
        """Scan entire repository for credentials"""
        all_findings = []
        
        for root, dirs, files in os.walk(repo_path):
            # Skip .git directory
            if '.git' in dirs:
                dirs.remove('.git')
            
            for file in files:
                if file.endswith(('.py', '.js', '.ts', '.java', '.go', '.rb', '.php',
                                 '.json', '.yaml', '.yml', '.env', '.config', '.xml')):
                    filepath = os.path.join(root, file)
                    findings = self.scan_file(filepath)
                    all_findings.extend(findings)
        
        return all_findings
    
    def _get_severity(self, credential_type: str) -> str:
        """Get severity for credential type"""
        severity_map = {
            'aws_access_key': 'critical',
            'aws_secret_key': 'critical',
            'aws_session_token': 'high',
            'azure_connection_string': 'critical',
            'azure_storage_key': 'critical',
            'gcp_service_account': 'critical',
            'gcp_api_key': 'high',
            'github_token': 'high',
            'slack_token': 'high',
            'private_key': 'critical',
        }
        
        return severity_map.get(credential_type, 'medium')
```

### Cloud Security Posture Analyzer
```python
class CloudSecurityPostureAnalyzer:
    def __init__(self):
        self.findings = []
    
    def analyze_aws_security(self, aws_enum: AWSEnumerator) -> Dict:
        """Analyze AWS security posture"""
        analysis = {
            's3_security': self._analyze_s3_security(aws_enum),
            'ec2_security': self._analyze_ec2_security(aws_enum),
            'iam_security': self._analyze_iam_security(aws_enum),
            'lambda_security': self._analyze_lambda_security(aws_enum),
            'recommendations': []
        }
        
        # Generate recommendations
        if analysis['s3_security']['public_buckets'] > 0:
            analysis['recommendations'].append("Review and restrict public S3 buckets")
        
        if analysis['iam_security']['over_permissive_policies'] > 0:
            analysis['recommendations'].append("Implement least privilege IAM policies")
        
        return analysis
    
    def _analyze_s3_security(self, aws_enum: AWSEnumerator) -> Dict:
        """Analyze S3 security"""
        s3_buckets = aws_enum.enumerate_s3_buckets()
        
        if 'error' in s3_buckets:
            return {'error': s3_buckets['error']}
        
        public_buckets = 0
        unencrypted_buckets = 0
        unlogged_buckets = 0
        
        for bucket in s3_buckets.get('buckets', []):
            if bucket.get('permissions', {}).get('is_public'):
                public_buckets += 1
            
            if not bucket.get('encryption', {}).get('enabled'):
                unencrypted_buckets += 1
            
            if not bucket.get('logging', {}).get('enabled'):
                unlogged_buckets += 1
        
        return {
            'total_buckets': s3_buckets.get('total', 0),
            'public_buckets': public_buckets,
            'unencrypted_buckets': unencrypted_buckets,
            'unlogged_buckets': unlogged_buckets
        }
    
    def _analyze_ec2_security(self, aws_enum: AWSEnumerator) -> Dict:
        """Analyze EC2 security"""
        ec2_instances = aws_enum.enumerate_ec2_instances()
        
        if 'error' in ec2_instances:
            return {'error': ec2_instances['error']}
        
        public_instances = 0
        instances_with_iam = 0
        
        for instance in ec2_instances.get('instances', []):
            if instance.get('public_ip'):
                public_instances += 1
            
            if instance.get('iam_profile'):
                instances_with_iam += 1
        
        return {
            'total_instances': ec2_instances.get('total', 0),
            'public_instances': public_instances,
            'instances_with_iam': instances_with_iam
        }
    
    def _analyze_iam_security(self, aws_enum: AWSEnumerator) -> Dict:
        """Analyze IAM security"""
        iam_policies = aws_enum.enumerate_iam_policies()
        
        if 'error' in iam_policies:
            return {'error': iam_policies['error']}
        
        over_permissive = 0
        
        for policy in iam_policies.get('policies', []):
            if aws_enum._is_policy_over_permissive(policy.get('document', {})):
                over_permissive += 1
        
        return {
            'total_policies': iam_policies.get('total', 0),
            'over_permissive_policies': over_permissive
        }
    
    def _analyze_lambda_security(self, aws_enum: AWSEnumerator) -> Dict:
        """Analyze Lambda security"""
        lambda_functions = aws_enum.enumerate_lambda_functions()
        
        if 'error' in lambda_functions:
            return {'error': lambda_functions['error']}
        
        functions_with_secrets = 0
        
        for function in lambda_functions.get('functions', []):
            env_vars = function.get('environment', {})
            for key in env_vars.keys():
                if any(sensitive in key.lower() for sensitive in ['password', 'secret', 'key', 'token']):
                    functions_with_secrets += 1
                    break
        
        return {
            'total_functions': lambda_functions.get('total', 0),
            'functions_with_secrets': functions_with_secrets
        }
    
    def generate_security_posture_report(self, analysis: Dict) -> Dict:
        """Generate security posture report"""
        report = {
            'timestamp': datetime.now().isoformat(),
            'analysis': analysis,
            'overall_score': self._calculate_security_score(analysis),
            'recommendations': analysis.get('recommendations', []),
            'priority_actions': self._get_priority_actions(analysis)
        }
        
        return report
    
    def _calculate_security_score(self, analysis: Dict) -> int:
        """Calculate overall security score"""
        score = 100
        
        # Deduct for S3 issues
        s3_analysis = analysis.get('s3_security', {})
        if s3_analysis.get('public_buckets', 0) > 0:
            score -= s3_analysis['public_buckets'] * 10
        
        if s3_analysis.get('unencrypted_buckets', 0) > 0:
            score -= s3_analysis['unencrypted_buckets'] * 5
        
        # Deduct for IAM issues
        iam_analysis = analysis.get('iam_security', {})
        if iam_analysis.get('over_permissive_policies', 0) > 0:
            score -= iam_analysis['over_permissive_policies'] * 15
        
        return max(0, score)
    
    def _get_priority_actions(self, analysis: Dict) -> List[str]:
        """Get priority actions based on analysis"""
        actions = []
        
        # Critical actions
        s3_analysis = analysis.get('s3_security', {})
        if s3_analysis.get('public_buckets', 0) > 0:
            actions.append("IMMEDIATE: Restrict public S3 bucket access")
        
        iam_analysis = analysis.get('iam_security', {})
        if iam_analysis.get('over_permissive_policies', 0) > 0:
            actions.append("HIGH: Review and restrict IAM policies")
        
        # Medium actions
        if s3_analysis.get('unencrypted_buckets', 0) > 0:
            actions.append("MEDIUM: Enable encryption for all S3 buckets")
        
        if s3_analysis.get('unlogged_buckets', 0) > 0:
            actions.append("MEDIUM: Enable logging for all S3 buckets")
        
        return actions
```

## Case Studies

### Case Study 1: Public S3 Bucket Data Breach
**Scenario**: Organization has public S3 bucket containing sensitive customer data.
**Approach**: Used S3 enumeration to discover public buckets. Analyzed bucket policies and identified misconfiguration.
**Findings**: Critical vulnerability: 3 public S3 buckets containing PII, financial data, and credentials.
**Outcome**: Implemented bucket policies, enabled encryption, added monitoring for public access.

### Case Study 2: AWS Metadata Endpoint Exploitation
**Scenario**: Web application with SSRF vulnerability on EC2 instance.
**Approach**: Exploited SSRF to access metadata endpoint. Extracted IAM credentials for the instance role.
**Findings**: Critical: IAM credentials for admin role accessible via metadata endpoint.
**Outcome**: Implemented IMDSv2, restricted metadata access, added monitoring for metadata requests.

### Case Study 3: Azure Blob Storage Public Access
**Scenario**: Azure storage account configured with public blob access.
**Approach**: Enumerated storage accounts and identified public access configuration.
**Findings**: High: Storage account allowing anonymous blob access, exposing sensitive documents.
**Outcome**: Disabled public access, implemented Azure AD authentication, added access monitoring.

### Case Study 4: GCP Service Account Key Exposure
**Scenario**: GCP service account key exposed in public GitHub repository.
**Approach**: Scanned repository for GCP credentials. Found service account JSON key in code.
**findings**: Critical: Service account with editor permissions exposed in public repository.
**Outcome**: Revoked exposed key, implemented key rotation, added pre-commit hooks for secret detection.

### Case Study 5: Lambda Function Secret Leakage
**Scenario**: Lambda function contains hardcoded database credentials in environment variables.
**Approach**: Enumerated Lambda functions and analyzed environment variables.
**Findings**: High: Database credentials stored in plaintext environment variables.
**Outcome**: Moved secrets to AWS Secrets Manager, implemented dynamic credential retrieval.

### Case Study 6: Cross-Cloud Credential Exposure
**Scenario**: Organization uses multiple cloud providers with credentials in configuration files.
**Approach**: Scanned codebase for cloud credentials across AWS, Azure, and GCP.
**Findings**: Multiple critical findings: AWS keys, Azure connection strings, and GCP service account keys exposed.
**Outcome**: Implemented cloud-agnostic secret management, added automated credential scanning.

## Bypass Techniques

### Metadata Endpoint Bypass
```python
class MetadataBypassTechniques:
    def test_metadata_bypass(self, target_url: str) -> Dict:
        """Test metadata endpoint bypass techniques"""
        techniques = [
            {
                'name': 'IP Address',
                'url': 'http://169.254.169.254/latest/meta-data/'
            },
            {
                'name': 'DNS Name',
                'url': 'http://instance-data/latest/meta-data/'
            },
            {
                'name': 'Alternative IP',
                'url': 'http://169.254.169.250/latest/meta-data/'
            },
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                response = requests.get(technique['url'], timeout=5)
                
                if response.status_code == 200:
                    results[technique['name']] = {
                        'accessible': True,
                        'response_preview': response.text[:200],
                        'severity': 'critical'
                    }
                else:
                    results[technique['name']] = {
                        'accessible': False,
                        'status_code': response.status_code
                    }
                    
            except Exception as e:
                results[technique['name']] = {
                    'accessible': False,
                    'error': str(e)
                }
        
        return results
```

### IAM Policy Bypass
```python
class IAMPolicyBypass:
    def test_iam_bypass(self, iam_client) -> Dict:
        """Test IAM policy bypass techniques"""
        techniques = [
            'Policy Versioning',
            'Permission Boundary',
            'Resource-Based Policies',
            'AssumeRole',
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                # Test each bypass technique
                if technique == 'Policy Versioning':
                    # Check for old policy versions
                    policies = iam_client.list_policies()['Policies']
                    for policy in policies:
                        versions = iam_client.list_policy_versions(PolicyArn=policy['Arn'])
                        if len(versions['Versions']) > 1:
                            results[technique] = {
                                'bypass_possible': True,
                                'details': f"Policy {policy['PolicyName']} has multiple versions"
                            }
                
            except Exception as e:
                results[technique] = {'error': str(e)}
        
        return results
```

### Cloud API Bypass
```python
class CloudAPIBypass:
    def test_api_bypass(self, provider: str) -> Dict:
        """Test cloud API bypass techniques"""
        bypass_techniques = {
            'aws': [
                'STS AssumeRole',
                'Cross-Account Access',
                'Federation',
            ],
            'azure': [
                'Managed Identity',
                'Service Principal',
                'Azure AD Connect',
            ],
            'gcp': [
                'Service Account Impersonation',
                'Workload Identity',
                'Federated Identity',
            ]
        }
        
        results = {}
        
        for technique in bypass_techniques.get(provider, []):
            results[technique] = {
                'test_required': True,
                'description': f"Test {technique} bypass technique"
            }
        
        return results
```

## Advanced Techniques

### Multi-Cloud Enumeration
```python
class MultiCloudEnumerator:
    def __init__(self):
        self.enumerators = {}
        self.findings = []
    
    def add_enumerator(self, provider: str, enumerator):
        """Add cloud provider enumerator"""
        self.enumerators[provider] = enumerator
    
    def enumerate_all(self) -> Dict:
        """Enumerate all cloud providers"""
        results = {}
        
        for provider, enumerator in self.enumerators.items():
            print(f"Enumerating {provider}...")
            
            if provider == 'aws':
                results['aws'] = {
                    's3': enumerator.enumerate_s3_buckets(),
                    'lambda': enumerator.enumerate_lambda_functions(),
                    'ec2': enumerator.enumerate_ec2_instances(),
                    'iam': enumerator.enumerate_iam_policies()
                }
            elif provider == 'azure':
                results['azure'] = {
                    'storage': enumerator.enumerate_storage_accounts(),
                    'vms': enumerator.enumerate_virtual_machines()
                }
            elif provider == 'gcp':
                results['gcp'] = {
                    'buckets': enumerator.enumerate_gcs_buckets(),
                    'instances': enumerator.enumerate_compute_instances(),
                    'functions': enumerator.enumerate_cloud_functions()
                }
        
        return results
    
    def generate_cross_cloud_report(self) -> Dict:
        """Generate cross-cloud security report"""
        report = {
            'providers': list(self.enumerators.keys()),
            'findings': self.findings,
            'cross_cloud_issues': self._identify_cross_cloud_issues(),
            'recommendations': self._generate_cross_cloud_recommendations()
        }
        
        return report
    
    def _identify_cross_cloud_issues(self) -> List[Dict]:
        """Identify issues across cloud providers"""
        issues = []
        
        # Check for credential reuse
        # Check for consistent security policies
        # Check for cross-cloud network connectivity
        
        return issues
    
    def _generate_cross_cloud_recommendations(self) -> List[str]:
        """Generate cross-cloud recommendations"""
        recommendations = [
            "Implement centralized identity management",
            "Use consistent security policies across providers",
            "Enable cross-cloud logging and monitoring",
            "Implement secrets management solution",
            "Conduct regular cross-cloud security assessments"
        ]
        
        return recommendations
```

### Cloud Security Monitoring
```python
class CloudSecurityMonitor:
    def __init__(self):
        self.alerts = []
        self.baselines = {}
    
    def monitor_cloud_resources(self, enumerator, provider: str, 
                               interval: int = 3600):
        """Monitor cloud resources for changes"""
        while True:
            # Get current state
            if provider == 'aws':
                current_state = {
                    's3': enumerator.enumerate_s3_buckets(),
                    'ec2': enumerator.enumerate_ec2_instances()
                }
            elif provider == 'azure':
                current_state = {
                    'storage': enumerator.enumerate_storage_accounts(),
                    'vms': enumerator.enumerate_virtual_machines()
                }
            elif provider == 'gcp':
                current_state = {
                    'buckets': enumerator.enumerate_gcs_buckets(),
                    'instances': enumerator.enumerate_compute_instances()
                }
            
            # Check for changes
            if provider in self.baselines:
                changes = self._detect_changes(self.baselines[provider], current_state)
                if changes:
                    self.send_alert(provider, changes)
            
            self.baselines[provider] = current_state
            
            time.sleep(interval)
    
    def _detect_changes(self, baseline: Dict, current: Dict) -> List[Dict]:
        """Detect changes between baseline and current state"""
        changes = []
        
        # Compare resources
        for service in baseline:
            if service in current:
                baseline_resources = baseline[service]
                current_resources = current[service]
                
                # Simple comparison
                if baseline_resources != current_resources:
                    changes.append({
                        'service': service,
                        'type': 'change',
                        'details': 'Resource configuration changed'
                    })
        
        return changes
    
    def send_alert(self, provider: str, changes: List[Dict]):
        """Send alert for cloud resource changes"""
        alert = {
            'provider': provider,
            'changes': changes,
            'timestamp': datetime.now().isoformat()
        }
        self.alerts.append(alert)
```

## Detection Indicators

### Cloud Enumeration Artifacts
- Public storage buckets or containers
- Exposed metadata endpoints
- Over-permissive IAM policies
- Unencrypted data storage
- Missing logging and monitoring
- Exposed credentials in code
- Default service accounts in use
- Public compute instances

### Exploitation Artifacts
- Unauthorized access via misconfigurations
- Credential theft via metadata endpoints
- Data exfiltration from public buckets
- Privilege escalation via IAM
- Lateral movement across cloud services
- Resource abuse for cryptocurrency mining

## Impact Assessment

### Vulnerability Severity
- **Critical**: Exposed credentials, public metadata, full account access
- **High**: Public storage, over-permissive IAM, unencrypted data
- **Medium**: Public compute instances, missing logging
- **Low**: Minor misconfigurations, best practice violations

### Business Impact
- **Data Breach**: Exposure of sensitive cloud-stored data
- **Account Compromise**: Unauthorized access to cloud accounts
- **Financial Loss**: Unexpected cloud resource usage
- **Compliance Violations**: Failure to meet regulatory requirements
- **Reputation Damage**: Public disclosure of cloud security issues

## Common Pitfalls

### Enumeration Pitfalls
- **Rate Limiting**: Cloud APIs have rate limits
- **Permission Issues**: Insufficient permissions for enumeration
- **API Changes**: Cloud APIs change frequently
- **Cost Considerations**: Enumeration may incur costs
- **Time Constraints**: Large environments take time to enumerate
- **False Positives**: Not all findings are vulnerabilities
- **Incomplete Coverage**: Missing some cloud services
- **Credential Management**: Handling multiple cloud credentials

### Implementation Pitfalls
- **Hardcoded Credentials**: Storing cloud credentials in code
- **Insufficient Logging**: Not monitoring cloud activity
- **Over-Permission**: Granting excessive IAM permissions
- **Missing Encryption**: Not encrypting sensitive data
- **No Backup**: Not backing up cloud configurations
- **Ignoring Regions**: Not enumerating all regions
- **Missing Tags**: Not tagging resources properly
- **Cost Management**: Not monitoring cloud costs

## Integration Points

### CI/CD Integration
```yaml
# GitHub Actions workflow
name: Cloud Security Enumeration
on: [push, pull_request]

jobs:
  cloud-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      - name: Run cloud enumeration
        run: python -m cloud_enumerator scan --config config.yaml
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: cloud-results
          path: results/
```

### Monitoring Integration
```python
# Real-time cloud monitoring
import time
from datetime import datetime

class CloudMonitor:
    def __init__(self):
        self.resources = {}
        self.alerts = []
    
    def monitor_s3_buckets(self, aws_enum):
        """Monitor S3 buckets for changes"""
        while True:
            current_buckets = aws_enum.enumerate_s3_buckets()
            
            if 'buckets' in current_buckets:
                for bucket in current_buckets['buckets']:
                    bucket_name = bucket['name']
                    
                    # Check for public access
                    if bucket.get('permissions', {}).get('is_public'):
                        self.send_alert({
                            'type': 'Public S3 Bucket',
                            'bucket': bucket_name,
                            'timestamp': datetime.now().isoformat()
                        })
            
            time.sleep(3600)  # Check every hour
    
    def send_alert(self, alert_data: Dict):
        """Send alert for cloud security issues"""
        self.alerts.append(alert_data)
```

### Reporting Integration
```python
class CloudReporter:
    def generate_html_report(self, scan_results: Dict) -> str:
        """Generate HTML report for cloud enumeration"""
        html = '''
<!DOCTYPE html>
<html>
<head>
    <title>Cloud Security Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .finding { border: 1px solid #ccc; padding: 10px; margin: 10px 0; }
        .critical { border-color: #ff0000; background-color: #ffe6e6; }
        .high { border-color: #ff6600; background-color: #fff2e6; }
        .medium { border-color: #ffcc00; background-color: #fff9e6; }
        .low { border-color: #00cc00; background-color: #e6ffe6; }
    </style>
</head>
<body>
    <h1>Cloud Security Report</h1>
        '''
        
        for finding in scan_results.get('findings', []):
            severity = finding.get('severity', 'low')
            html += f'''
            <div class="finding {severity}">
                <h3>{finding.get('issue', 'Unknown Issue')}</h3>
                <p><strong>Service:</strong> {finding.get('service', 'Unknown')}</p>
                <p><strong>Resource:</strong> {finding.get('resource', 'Unknown')}</p>
                <p><strong>Severity:</strong> {severity}</p>
                <p><strong>Details:</strong> {finding.get('details', 'No details')}</p>
            </div>
            '''
        
        html += '''
</body>
</html>
        '''
        
        return html
```

## Practice Labs

### Lab 1: AWS S3 Enumeration
Create an AWS S3 enumerator that:
1. Lists all S3 buckets
2. Checks bucket permissions
3. Identifies public buckets
4. Generates security report

### Lab 2: Metadata Endpoint Testing
Build a metadata endpoint tester that:
1. Tests AWS, Azure, and GCP metadata endpoints
2. Extracts credentials if accessible
3. Assesses impact of exposure
4. Provides remediation recommendations

### Lab 3: IAM Policy Analysis
Develop an IAM policy analyzer that:
1. Enumerates IAM policies
2. Identifies over-permissive policies
3. Recommends least privilege permissions
4. Generates compliance report

### Lab 4: Multi-Cloud Scanner
Create a multi-cloud scanner that:
1. Supports AWS, Azure, and GCP
2. Enumerates resources across providers
3. Identifies cross-cloud issues
4. Generates unified security report

### Lab 5: Cloud Security Dashboard
Build a cloud security dashboard that:
1. Monitors cloud resources in real-time
2. Alerts on security issues
3. Tracks security posture over time
4. Provides remediation guidance

## Ethics

### Responsible Cloud Enumeration
- **Authorization**: Only enumerate cloud resources you have permission to access
- **Scope Respect**: Stay within authorized cloud accounts and resources
- **Cost Awareness**: Be mindful of API call costs during enumeration
- **Rate Limiting**: Implement delays to avoid API rate limiting
- **Data Handling**: Treat all discovered data as potentially sensitive
- **Credential Security**: Don't log or expose discovered credentials
- **Disclosure**: Report findings through responsible channels
- **Documentation**: Maintain audit trail of all enumeration activities
- **Privacy**: Handle personal data according to regulations
- **Cleanup**: Remove test resources and artifacts after enumeration

## Quick Reference

### Cloud CLI Commands
```bash
# AWS S3 enumeration
aws s3 ls
aws s3api get-bucket-acl --bucket bucket-name
aws s3api get-bucket-policy --bucket bucket-name

# Azure enumeration
az storage account list
az vm list
az functionapp list

# GCP enumeration
gsutil ls
gcloud compute instances list
gcloud functions list
```

### Metadata Endpoint URLs
```yaml
AWS: http://169.254.169.254/latest/meta-data/
Azure: http://169.254.169.254/metadata/instance?api-version=2021-02-01
GCP: http://metadata.google.internal/computeMetadata/v1/
```

### Common Cloud Vulnerabilities
1. **Public Storage**: S3/Blob/GCS buckets with public access
2. **Metadata Exposure**: Cloud metadata endpoints accessible via SSRF
3. **Over-Permissive IAM**: IAM policies with excessive permissions
4. **Exposed Credentials**: Cloud credentials in code repositories
5. **Unencrypted Data**: Data stored without encryption
6. **Missing Logging**: No audit logging enabled

### Credential Patterns
```regex
AWS Access Key: AKIA[0-9A-Z]{16}
Azure Connection String: DefaultEndpointsProtocol=https;AccountName=[^;]+;AccountKey=[A-Za-z0-9+/=]{88}
GCP Service Account: "type"\s*:\s*"service_account"
GitHub Token: ghp_[A-Za-z0-9]{36}
Private Key: -----BEGIN (?:RSA |EC |DSA )?PRIVATE KEY-----
```

### Troubleshooting Quick Fixes
1. **Access Denied**: Check IAM permissions
2. **Rate Limiting**: Add delays between API calls
3. **Timeout Issues**: Increase timeout values
4. **Credential Errors**: Verify cloud credentials
5. **Region Issues**: Check correct region configuration
6. **API Changes**: Update for new API versions
7. **Cost Overruns**: Monitor API usage
8. **False Positives**: Verify findings manually

