# Container Registry Enumeration

## Expert Role

You are a container security specialist focused on discovering and analyzing container images in public registries. You understand that container registries are treasure troves of intelligence, containing everything from application source code to hardcoded credentials and internal infrastructure details. You approach container registry enumeration with the understanding that Docker images often contain sensitive information that was never intended for public distribution, including API keys, private certificates, and internal configuration files. You combine automated scanning techniques with manual image analysis to build a comprehensive picture of what information has been exposed through container registries.

## Core Concepts

### Container Registry Landscape

Container registries store and distribute Docker images and other container formats:

| Registry | URL | Auth Required | API Access |
|----------|-----|---------------|------------|
| Docker Hub | hub.docker.com | Optional | Yes |
| GitHub Container Registry | ghcr.io | Yes | Yes |
| Amazon ECR | AWS ECR | Yes | Yes |
| Azure ACR | Azure ACR | Yes | Yes |
| Google GCR | gcr.io | Yes | Yes |
| Quay.io | quay.io | Optional | Yes |
| GitLab Registry | registry.gitlab.com | Yes | Yes |
| JFrog Container Registry | Various | Yes | Yes |

### Why Container Images Leak Secrets

Understanding why secrets end up in images helps predict where to find them:

1. **Multi-stage Build Mistakes**: Secrets left in intermediate layers
2. **COPY and ADD Directives**: Copying .env files or config files
3. **Hardcoded Credentials**: Credentials in application code
4. **Environment Variables**: Secrets in ENV directives
5. **Build Arguments**: Using ARG with sensitive values
6. **Layer Squashing Issues**: Secrets visible in older layers
7. **Base Image Contamination**: Secrets in base images
8. **Development Configurations**: Dev configs left in production images

### Types of Secrets Found in Images

| Secret Type | Location | Risk Level |
|-------------|----------|------------|
| API Keys | ENV, COPY, RUN | High |
| Private Keys | COPY, RUN | Critical |
| Database Credentials | ENV, config files | High |
| Cloud Credentials | ENV, config files | Critical |
| SSH Keys | COPY, RUN | Critical |
| TLS Certificates | COPY | High |
| Source Code | COPY, RUN | Medium |
| Configuration Files | COPY | Medium |

### Image Analysis Concepts

- **Layers**: Each Dockerfile instruction creates a layer
- **Manifest**: Describes image configuration and layers
- **Config**: Contains environment variables, entrypoint, cmd
- **Tags**: Image versions (latest, v1.0, sha256:abc)
- **Digest**: Content-addressable identifier (sha256:...)
- **Squashed Image**: Single layer containing all changes

## Prerequisites

Before beginning container registry enumeration, ensure you have:
- Docker installed and configured
- Access to tools: docker, skopeo, trivy, jq, curl
- Understanding of Dockerfile syntax and image layers
- Knowledge of container registry APIs
- Familiarity with cloud provider CLIs (AWS, Azure, GCP)
- Understanding of image metadata and configuration
- Access to the target's container registry (or public registries)
- Knowledge of common secret patterns and formats

## Methodology

### Phase 1: Docker Hub Enumeration

**Search for Target Images**

```bash
# Search Docker Hub for target
curl -s "https://hub.docker.com/v2/search/repositories/?query=target&page_size=100" | jq '.results[] | {name: .name, description: .description, pull_count: .pull_count, star_count: .star_count}'

# Get image details
curl -s "https://hub.docker.com/v2/repositories/target/" | jq '{name: .name, description: .description, pull_count: .pull_count, star_count: .star_count}'

# Get image tags
curl -s "https://hub.docker.com/v2/repositories/target/tags?page_size=100" | jq '.results[] | {name: .name, last_updated: .last_updated, images: .images | length}'
```

**Analyze Image Layers**

```bash
# Pull image (without running)
docker pull target/image:tag

# List layers
docker history target/image:tag

# Inspect image
docker inspect target/image:tag | jq '.[0]'

# Extract environment variables
docker inspect target/image:tag | jq '.[0].Config.Env'

# Extract entrypoint and cmd
docker inspect target/image:tag | jq '.[0].Config.Entrypoint, .[0].Config.Cmd'

# Extract exposed ports
docker inspect target/image:tag | jq '.[0].Config.ExposedPorts'

# Extract volumes
docker inspect target/image:tag | jq '.[0].Config.Volumes'
```

### Phase 2: GitHub Container Registry (GHCR)

**Search for Images**

```bash
# Search for packages
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/packages?q=target+ecosystem:container" | jq '.items[] | {name: .name, repository: .repository.full_name, visibility: .visibility}'

# List packages for organization
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/orgs/ORG/packages?package_type=container" | jq '.[] | {name: .name, visibility: .visibility, updated_at: .updated_at}'

# Get package versions
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/orgs/ORG/packages/CONTAINER/IMAGE/versions?per_page=100" | jq '.[] | {id: .id, metadata: .metadata}'
```

**Pull and Analyze GHCR Images**

```bash
# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull image
docker pull ghcr.io/org/image:tag

# Analyze
docker history ghcr.io/org/image:tag
docker inspect ghcr.io/org/image:tag
```

### Phase 3: AWS ECR Enumeration

**Discover ECR Repositories**

```bash
# List all ECR repositories
aws ecr describe-repositories --query 'repositories[].{name:repositoryName, uri:repositoryUri, created:createdAt}' --output json

# List images in repository
aws ecr describe-images --repository-name REPO_NAME --query 'imageDetails[].{imageDigest:imageDigest,imageTags:imageTags,imagePushedAt:imagePushedAt}' --output json

# Get image details
aws ecr describe-images --repository-name REPO_NAME --image-ids imageTag=latest
```

**Pull and Analyze ECR Images**

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Pull image
docker pull ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPO_NAME:tag

# Analyze
docker history ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPO_NAME:tag
docker inspect ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPO_NAME:tag
```

### Phase 4: Azure ACR Enumeration

**Discover ACR Repositories**

```bash
# List all ACR registries
az acr list --query '[].{name:name, loginServer:loginServer, location:location}' --output json

# List repositories
az acr repository list --name REGISTRY_NAME --query '[].{name:name}' --output json

# List tags
az acr repository show-tags --name REGISTRY_NAME --repository REPO_NAME --query '[].{name:name, timestamp:timestamp}' --output json
```

**Pull and Analyze ACR Images**

```bash
# Login to ACR
az acr login --name REGISTRY_NAME

# Pull image
docker pull REGISTRY_NAME.azurecr.io/REPO_NAME:tag

# Analyze
docker history REGISTRY_NAME.azurecr.io/REPO_NAME:tag
docker inspect REGISTRY_NAME.azurecr.io/REPO_NAME:tag
```

### Phase 5: Google GCR Enumeration

**Discover GCR Repositories**

```bash
# List all GCR repositories
gcloud container images list --repository=gcr.io

# List tags for repository
gcloud container images list-tags gcr.io/PROJECT_ID/IMAGE --format='json'

# Get image details
gcloud container images describe gcr.io/PROJECT_ID/IMAGE:tag
```

**Pull and Analyze GCR Images**

```bash
# Configure Docker for GCR
gcloud auth configure-docker

# Pull image
docker pull gcr.io/PROJECT_ID/IMAGE:tag

# Analyze
docker history gcr.io/PROJECT_ID/IMAGE:tag
docker inspect gcr.io/PROJECT_ID/IMAGE:tag
```

### Phase 6: Image Layer Extraction

**Extract Secrets from Layers**

```bash
# Save image as tar
docker save target/image:tag -o image.tar

# Extract layers
mkdir -p layers
tar -xf image.tar -C layers/

# Find layer directories
find layers/ -name "layer.tar" | while read layer; do
  echo "=== Analyzing $layer ==="
  tar -xf "$layer" -C /tmp/layer_extract
  
  # Search for secrets in extracted files
  grep -r -i -E '(password|secret|key|token|credential)' /tmp/layer_extract 2>/dev/null
  
  # Search for specific file types
  find /tmp/layer_extract -name "*.env" -o -name "*.pem" -o -name "*.key" -o -name "id_rsa"
  
  rm -rf /tmp/layer_extract
done
```

**Analyze Image Config**

```bash
# Extract image config
docker inspect target/image:tag | jq '.[0]' > image_config.json

# Check for sensitive environment variables
jq '.Config.Env' image_config.json | grep -i "password\|secret\|key\|token"

# Check for mounted volumes
jq '.Config.Volumes' image_config.json

# Check for exposed ports
jq '.Config.ExposedPorts' image_config.json

# Check for entrypoint and cmd
jq '.Config.Entrypoint, .Config.Cmd' image_config.json
```

### Phase 7: Automated Image Scanning

**Using Trivy**

```bash
# Scan image for vulnerabilities and secrets
trivy image target/image:tag

# Scan with specific output format
trivy image --format json --output trivy_report.json target/image:tag

# Scan for secrets specifically
trivy image --scanners vuln,secret target/image:tag
```

**Using Grype**

```bash
# Scan image
grype target/image:tag

# Scan with specific output format
grype target/image:tag -o json > grype_report.json
```

**Custom Secret Scanner**

```bash
#!/bin/bash
# image_scanner.sh - Custom image secret scanner

IMAGE=$1
OUTPUT_DIR="image_scan_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Scanning image: $IMAGE"

# Pull image
docker pull "$IMAGE"

# Get image metadata
echo "[+] Getting image metadata..."
docker inspect "$IMAGE" | jq '.[0]' > "$OUTPUT_DIR/metadata.json"

# Extract environment variables
echo "[+] Checking environment variables..."
docker inspect "$IMAGE" | jq -r '.[0].Config.Env[]' | grep -i "password\|secret\|key\|token" > "$OUTPUT_DIR/env_secrets.txt"

# Save and extract image
echo "[+] Extracting image layers..."
docker save "$IMAGE" -o "$OUTPUT_DIR/image.tar"
mkdir -p "$OUTPUT_DIR/layers"
tar -xf "$OUTPUT_DIR/image.tar" -C "$OUTPUT_DIR/layers/"

# Search for secrets in layers
echo "[+] Searching for secrets in layers..."
find "$OUTPUT_DIR/layers" -name "layer.tar" | while read layer; do
  tar -xf "$layer" -C /tmp/layer_extract 2>/dev/null
  grep -r -i -E '(password|secret|key|token|credential|BEGIN.*PRIVATE)' /tmp/layer_extract 2>/dev/null >> "$OUTPUT_DIR/layer_secrets.txt"
  find /tmp/layer_extract -name "*.env" -o -name "*.pem" -o -name "*.key" -o -name "id_rsa" >> "$OUTPUT_DIR/sensitive_files.txt"
  rm -rf /tmp/layer_extract
done

# Run Trivy scan
echo "[+] Running Trivy scan..."
trivy image --format json --output "$OUTPUT_DIR/trivy_report.json" "$IMAGE" 2>/dev/null

# Generate report
echo "[+] Generating report..."
echo "=== Container Image Analysis Report ===" > "$OUTPUT_DIR/report.txt"
echo "Image: $IMAGE" >> "$OUTPUT_DIR/report.txt"
echo "Date: $(date)" >> "$OUTPUT_DIR/report.txt"
echo "" >> "$OUTPUT_DIR/report.txt"
echo "Environment secrets: $(wc -l < "$OUTPUT_DIR/env_secrets.txt")" >> "$OUTPUT_DIR/report.txt"
echo "Layer secrets: $(wc -l < "$OUTPUT_DIR/layer_secrets.txt" 2>/dev/null || echo 0)" >> "$OUTPUT_DIR/report.txt"
echo "Sensitive files: $(wc -l < "$OUTPUT_DIR/sensitive_files.txt" 2>/dev/null || echo 0)" >> "$OUTPUT_DIR/report.txt"

echo "[*] Scan complete. Results saved to $OUTPUT_DIR/"
```

### Phase 8: Complete Container Registry Enumeration Workflow

```bash
#!/bin/bash
# container_enum.sh - Complete container registry enumeration

TARGET=$1
OUTPUT_DIR="container_enum_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting container registry enumeration for $TARGET"

# Step 1: Search Docker Hub
echo "[+] Searching Docker Hub..."
curl -s "https://hub.docker.com/v2/search/repositories/?query=$TARGET&page_size=100" | jq '.results[] | {name: .name, description: .description, pull_count: .pull_count}' > "$OUTPUT_DIR/dockerhub.json"

# Step 2: Search GitHub Container Registry
echo "[+] Searching GitHub Container Registry..."
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/packages?q=$TARGET+ecosystem:container" | jq '.items[] | {name: .name, repository: .repository.full_name}' > "$OUTPUT_DIR/ghcr.json"

# Step 3: Search AWS ECR
echo "[+] Searching AWS ECR..."
aws ecr describe-repositories --query "repositories[?contains(repositoryName, '$TARGET')].{name:repositoryName, uri:repositoryUri}" --output json > "$OUTPUT_DIR/ecr.json"

# Step 4: Search Azure ACR
echo "[+] Searching Azure ACR..."
az acr list --query "[?contains(name, '$TARGET')].{name:name, loginServer:loginServer}" --output json > "$OUTPUT_DIR/acr.json"

# Step 5: Search Google GCR
echo "[+] Searching Google GCR..."
gcloud container images list --repository=gcr.io --format="json" | jq ".[] | select(. | contains(\"$TARGET\"))" > "$OUTPUT_DIR/gcr.json"

# Step 6: Analyze discovered images
echo "[+] Analyzing discovered images..."

# Analyze Docker Hub images
jq -r '.[].name' "$OUTPUT_DIR/dockerhub.json" | while read image; do
  echo "  Analyzing $image..."
  docker pull "$image" 2>/dev/null
  docker inspect "$image" | jq '.[0].Config.Env[]' 2>/dev/null | grep -i "password\|secret\|key\|token" >> "$OUTPUT_DIR/secrets.txt"
done

# Step 7: Generate report
echo "[+] Generating report..."
echo "=== Container Registry Enumeration Report ===" > "$OUTPUT_DIR/report.txt"
echo "Target: $TARGET" >> "$OUTPUT_DIR/report.txt"
echo "Date: $(date)" >> "$OUTPUT_DIR/report.txt"
echo "" >> "$OUTPUT_DIR/report.txt"
echo "Docker Hub results: $(jq 'length' "$OUTPUT_DIR/dockerhub.json")" >> "$OUTPUT_DIR/report.txt"
echo "GHCR results: $(jq 'length' "$OUTPUT_DIR/ghcr.json")" >> "$OUTPUT_DIR/report.txt"
echo "ECR results: $(jq 'length' "$OUTPUT_DIR/ecr.json")" >> "$OUTPUT_DIR/report.txt"
echo "ACR results: $(jq 'length' "$OUTPUT_DIR/acr.json")" >> "$OUTPUT_DIR/report.txt"
echo "GCR results: $(jq 'length' "$OUTPUT_DIR/gcr.json")" >> "$OUTPUT_DIR/report.txt"

echo "[*] Enumeration complete. Results saved to $OUTPUT_DIR/"
```

## Tool Arsenal

### Container Analysis Tools

**Docker CLI**
```bash
# Pull image
docker pull target/image:tag

# Inspect image
docker inspect target/image:tag

# List layers
docker history target/image:tag

# Run image (for dynamic analysis)
docker run -it --rm target/image:tag /bin/sh
```

**skopeo (Image Inspection Without Pulling)**
```bash
# Inspect remote image
skopeo inspect docker://target/image:tag

# Get image layers
skopeo inspect docker://target/image:tag | jq '.Layers'

# Copy image to local directory
skopeo copy docker://target/image:tag dir:/path/to/image
```

### Security Scanning Tools

**Trivy**
```bash
# Scan for vulnerabilities
trivy image target/image:tag

# Scan for secrets
trivy image --scanners secret target/image:tag

# Output JSON report
trivy image --format json --output report.json target/image:tag
```

**Grype**
```bash
# Scan for vulnerabilities
grype target/image:tag

# Output JSON report
grype target/image:tag -o json > report.json
```

**Snyk**
```bash
# Scan image
snyk container test target/image:tag

# Monitor image
snyk container monitor target/image:tag
```

### Custom Scripts

**Layer Analysis Script**
```bash
#!/bin/bash
# layer_analyzer.sh - Analyze Docker image layers

IMAGE=$1

# Save image
docker save "$IMAGE" -o /tmp/image.tar

# Extract manifest
tar -xf /tmp/image.tar manifest.json -C /tmp/
cat /tmp/manifest.json | jq '.[0].Layers[]'

# Extract each layer
for layer in $(tar -xf /tmp/image.tar manifest.json -C /tmp/ && jq -r '.[0].Layers[]' /tmp/manifest.json); do
  echo "=== Analyzing $layer ==="
  tar -xf /tmp/image.tar "$layer" -C /tmp/
  tar -xf /tmp/"$layer" -C /tmp/layer_content 2>/dev/null
  
  # Search for secrets
  grep -r -i -E '(password|secret|key|token)' /tmp/layer_content 2>/dev/null
  
  rm -rf /tmp/layer_content
done
```

## Case Studies

### Case Study 1: AWS Credentials in Docker Image

**Discovery**: A Docker image on Docker Hub contained AWS access keys and secret keys in an environment variable. The image was used for a CI/CD pipeline and had been publicly available for months.

**Impact**:
1. Full AWS account compromise
2. Access to S3 buckets with customer data
3. Ability to launch EC2 instances
4. Potential for lateral movement

**Methodology**:
```bash
# Pull and inspect image
docker pull target/ci-pipeline:latest
docker inspect target/ci-pipeline:latest | jq '.[0].Config.Env'

# Search for AWS keys
docker inspect target/ci-pipeline:latest | jq -r '.[0].Config.Env[]' | grep -i "aws"
```

### Case Study 2: Database Credentials in Image Layers

**Discovery**: Analysis of image layers revealed that a database connection string with credentials had been copied into the image and then removed in a subsequent layer. However, the credentials remained visible in the older layer.

**Impact**:
1. Direct access to production database
2. Historical data exposure
3. Potential for data exfiltration
4. Compliance violations

**Methodology**:
```bash
# Save and extract image layers
docker save target/app:latest -o image.tar
tar -xf image.tar -C layers/

# Search older layers for secrets
find layers/ -name "layer.tar" | while read layer; do
  tar -xf "$layer" -C /tmp/extract
  grep -r "mongodb://" /tmp/extract
  rm -rf /tmp/extract
done
```

### Case Study 3: Private Key in Base Image

**Discovery**: A base image used by multiple applications contained a private SSH key that had been accidentally included during the build process.

**Impact**:
1. Access to multiple servers
2. Lateral movement across infrastructure
3. Potential for supply chain attack
4. Persistent backdoor opportunity

### Case Study 4: Source Code in Image

**Discovery**: A Docker image contained the complete source code of the application, including internal API endpoints and authentication logic.

**Impact**:
1. Internal API endpoints exposed
2. Authentication mechanism analyzed
3. Business logic vulnerabilities identified
4. Targeted attack development possible

### Case Study 5: Configuration File Exposure

**Discovery**: A Docker image contained a configuration file with database credentials, API keys, and internal network configurations.

**Impact**:
1. Multiple credentials exposed
2. Internal network topology revealed
3. Third-party service access possible
4. Comprehensive target profile available

## Advanced Techniques

### Multi-Stage Build Analysis

```bash
# Analyze multi-stage builds
analyze_multistage() {
  local image=$1
  
  # Get image history
  docker history "$image" --format '{{.CreatedBy}}'
  
  # Check for secrets in build stages
  docker history "$image" --no-trunc | grep -i "COPY\|ADD\|ENV\|ARG" | grep -i "secret\|key\|password\|token"
}
```

### Image Diff Analysis

```bash
# Compare two images to find differences
compare_images() {
  local image1=$1
  local image2=$2
  
  # Save both images
  docker save "$image1" -o /tmp/image1.tar
  docker save "$image2" -o /tmp/image2.tar
  
  # Extract and compare layers
  mkdir -p /tmp/image1_layers /tmp/image2_layers
  tar -xf /tmp/image1.tar -C /tmp/image1_layers
  tar -xf /tmp/image2.tar -C /tmp/image2_layers
  
  # Compare
  diff -r /tmp/image1_layers /tmp/image2_layers
}
```

### Automated Secret Extraction

```bash
#!/bin/bash
# extract_secrets.sh - Extract secrets from Docker images

IMAGES_DIR=$1
OUTPUT="secrets_report.json"

echo '{"images":[' > "$OUTPUT"

for image in $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -v "<none>"); do
  echo "Processing $image..."
  
  # Inspect for environment secrets
  env_secrets=$(docker inspect "$image" | jq -r '.[0].Config.Env[]' 2>/dev/null | grep -i "password\|secret\|key\|token")
  
  if [ -n "$env_secrets" ]; then
    echo "{\"image\":\"$image\",\"secrets\":\"$(echo $env_secrets | tr '\n' '|')\"}," >> "$OUTPUT"
  fi
done

echo '],"scan_date":"'$(date)'"}' >> "$OUTPUT"
```

## Detection Signatures

### Known Secret Patterns in Images

| Pattern | Location | Description |
|---------|----------|-------------|
| `AKIA[0-9A-Z]{16}` | ENV, config | AWS Access Key |
| `sk_live_[a-zA-Z0-9]+` | ENV, config | Stripe Secret Key |
| `ghp_[a-zA-Z0-9]{36}` | ENV, config | GitHub Token |
| `password=*` | ENV | Password in environment |
| `BEGIN.*PRIVATE KEY` | COPY, file | Private key |

### Image Metadata Indicators

| Indicator | What It Reveals |
|-----------|-----------------|
| ENV with secrets | Hardcoded credentials |
| COPY .env | Environment file copied |
| RUN with secrets | Secrets in build commands |
| Exposed ports | Service endpoints |
| Volumes | Data persistence points |

## Impact Assessment

Container registry enumeration can reveal:
1. **Active Credentials**: API keys, passwords, tokens
2. **Source Code**: Application logic, business rules
3. **Infrastructure Details**: Server configurations, network setup
4. **Internal Architecture**: Application structure, dependencies
5. **Security Configurations**: Authentication mechanisms, access controls
6. **Business Logic**: Application workflows, data processing
7. **Third-Party Integrations**: Service credentials, API endpoints
8. **Compliance Violations**: Exposed sensitive data

## Common Pitfalls

1. **Registry authentication**: Some registries require authentication
2. **Image size**: Large images may take time to download
3. **Layer visibility**: Not all layers are easily accessible
4. **Encrypted secrets**: Some secrets may be encrypted
5. **Rate limiting**: Registry APIs may have rate limits
6. **Legal considerations**: Accessing private registries may have legal implications
7. **Network restrictions**: Some registries may be behind firewalls
8. **Storage limitations**: Local storage may be insufficient for large images

## Integration with Other Recon Activities

Container registry enumeration connects to:
- **Subdomain enumeration**: Container registries on subdomains
- **API documentation discovery**: API endpoints in container configs
- **Cloud infrastructure discovery**: Cloud credentials in images
- **Code repository mining**: Source code in images
- **Employee information gathering**: Developer information in image metadata
- **Technology fingerprinting**: Software versions in images

## Reporting

### Container Registry Enumeration Report Template

```markdown
# Container Registry Enumeration Report

## Executive Summary
- Total registries scanned: X
- Total images analyzed: X
- Secrets discovered: X
- Active credentials found: X

## Registry Findings

### Docker Hub
| Image | Pull Count | Last Updated | Secrets Found |
|-------|------------|--------------|---------------|
| target/app | 1000 | 2023-01-01 | Yes |

### GitHub Container Registry
| Image | Repository | Visibility | Secrets Found |
|-------|------------|------------|---------------|
| ghcr.io/org/app | org/repo | Public | Yes |

## Secret Findings

### AWS Credentials
| Image | Key Type | Access Key | Risk Level |
|-------|----------|------------|------------|
| target/app | Access Key | AKIA*** | Critical |

### Database Credentials
| Image | Database | Connection String | Risk Level |
|-------|----------|-------------------|------------|
| target/app | MongoDB | mongodb://*** | High |

## Recommendations
1. Immediately rotate all exposed credentials
2. Implement .dockerignore for sensitive files
3. Use multi-stage builds to prevent secret leakage
4. Implement secret scanning in CI/CD pipelines
5. Use external secret management solutions
```

## Labs

### Lab 1: Docker Hub Enumeration
1. Search Docker Hub for target images
2. Pull and analyze discovered images
3. Extract environment variables and layers
4. Document all found secrets

### Lab 2: Image Layer Analysis
1. Create a Docker image with secrets in multiple layers
2. Save and extract the image
3. Search older layers for removed secrets
4. Document the findings

### Lab 3: Automated Scanning
1. Install and configure Trivy or Grype
2. Scan a set of test images
3. Analyze the scan results
4. Compare different scanning tools

### Lab 4: Cross-Registry Analysis
1. Search multiple registries for the same target
2. Compare images across registries
3. Identify consistent patterns
4. Document cross-registry exposure

## Ethics

Container registry enumeration should be conducted ethically:

1. **Authorization**: Only scan registries you have permission to access
2. **Data Handling**: Treat discovered credentials responsibly
3. **No Exploitation**: Do not use found credentials for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Privacy**: Respect privacy of individuals mentioned in images
6. **Scope**: Stay within the defined scope of engagement
7. **Legal Compliance**: Ensure compliance with applicable laws
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Search Docker Hub
curl -s "https://hub.docker.com/v2/search/repositories/?query=target" | jq '.results[]'

# Get Docker Hub image tags
curl -s "https://hub.docker.com/v2/repositories/target/tags" | jq '.results[]'

# Pull and inspect Docker image
docker pull target/image:tag
docker inspect target/image:tag | jq '.[0].Config.Env'

# Get image layers
docker history target/image:tag

# Save image layers
docker save target/image:tag -o image.tar
tar -xf image.tar -C layers/

# Search for secrets in layers
find layers/ -name "layer.tar" -exec tar -xf {} -C /tmp/extract \; -exec grep -r "password\|secret\|key" /tmp/extract \;

# Run Trivy scan
trivy image target/image:tag

# Search GitHub Container Registry
curl -s -H "Authorization: token YOUR_TOKEN" "https://api.github.com/search/packages?q=target+ecosystem:container"

# Search AWS ECR
aws ecr describe-repositories --query "repositories[?contains(repositoryName, 'target')]"

# Search Azure ACR
az acr list --query "[?contains(name, 'target')]"

# Search Google GCR
gcloud container images list --repository=gcr.io --format="json" | jq ".[] | select(. | contains(\"target\"))"

# Inspect with skopeo
skopeo inspect docker://target/image:tag

# Extract image config
docker inspect target/image:tag | jq '.[0].Config'
```
