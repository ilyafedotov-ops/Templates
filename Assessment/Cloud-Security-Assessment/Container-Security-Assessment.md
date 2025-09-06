# Container Security Assessment

## Assessment Overview

This template provides a comprehensive framework for conducting security assessments of containerized environments, focusing on Kubernetes clusters (AKS, EKS, GKE), container registries, and cloud-native security practices aligned with CIS Kubernetes Benchmark and NIST Container Security Guidelines.

### Assessment Scope
- **Target Environment**: Kubernetes clusters, container registries, container workloads
- **Platform Coverage**: Azure Kubernetes Service (AKS), Amazon EKS, Google GKE
- **Framework Alignment**: CIS Kubernetes Benchmark v1.7.0, NIST SP 800-190
- **Assessment Duration**: 2-4 weeks depending on cluster complexity
- **Required Access**: Kubernetes cluster admin, container registry access

### Key Assessment Areas
1. Cluster Infrastructure Security
2. Container Image Security and Supply Chain
3. Runtime Security and Monitoring
4. Network Policies and Segmentation
5. Identity and Access Management (RBAC)
6. Secrets Management
7. Compliance and Governance
8. DevSecOps Pipeline Integration

## Pre-Assessment Planning

### Environment Discovery and Inventory

#### Kubernetes Cluster Discovery
```bash
# Azure AKS cluster inventory
az aks list --query '[].{Name:name, ResourceGroup:resourceGroup, KubernetesVersion:kubernetesVersion, NodeCount:agentPoolProfiles[0].count, NodeSize:agentPoolProfiles[0].vmSize}' -o table

# AWS EKS cluster inventory
aws eks list-clusters --query 'clusters' --output text | xargs -I {} aws eks describe-cluster --name {} --query 'cluster.{Name:name, Version:version, Status:status, Endpoint:endpoint}' --output table

# GCP GKE cluster inventory
gcloud container clusters list --format="table(name,location,status,currentMasterVersion,currentNodeVersion,nodePoolSize)" 2>/dev/null || echo "GKE access not available"

# On-premises/hybrid Kubernetes discovery
kubectl config get-contexts --output=name | while read context; do
    echo "=== Context: $context ==="
    kubectl config use-context $context
    kubectl cluster-info
    kubectl get nodes -o wide
    echo
done
```

#### Container Registry Assessment
```bash
# Azure Container Registry
az acr list --query '[].{Name:name, ResourceGroup:resourceGroup, LoginServer:loginServer, AdminEnabled:adminUserEnabled, PublicAccess:publicNetworkAccess}' -o table

# Check ACR vulnerability scanning
az acr task list --registry myacr --query '[].{Name:name, Status:status, Platform:platform}' -o table

# AWS Elastic Container Registry
aws ecr describe-repositories --query 'repositories[].{Name:repositoryName, CreatedAt:createdAt, ImageScanningEnabled:imageScanningConfiguration.scanOnPush}' --output table

# GCP Artifact Registry and Container Registry
gcloud artifacts repositories list --format="table(name,format,description)" 2>/dev/null || echo "Artifact Registry not accessible"
gcloud container images list --repository=gcr.io/PROJECT_ID --format="table(name,tags)" 2>/dev/null || echo "Container Registry not accessible"
```

#### Workload and Application Discovery
```bash
# Kubernetes workload inventory across all namespaces
kubectl get deployments,daemonsets,statefulsets -A -o custom-columns="NAMESPACE:.metadata.namespace,KIND:.kind,NAME:.metadata.name,REPLICAS:.status.replicas,READY:.status.readyReplicas"

# Service and ingress inventory
kubectl get services,ingresses -A -o wide

# Persistent volume and storage analysis
kubectl get pv,pvc -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,SIZE:.spec.resources.requests.storage,ACCESS:.spec.accessModes,STORAGE_CLASS:.spec.storageClassName"
```

## CIS Kubernetes Benchmark Assessment

### 1. Master Node Security Configuration

#### 1.1 Master Node Configuration Files
```bash
# Check API server configuration
kubectl describe pod kube-apiserver-* -n kube-system | grep -A5 -B5 "Command\|Args"

# Validate etcd security settings
kubectl get pods -n kube-system | grep etcd | while read pod namespace rest; do
    echo "=== $pod ==="
    kubectl describe pod $pod -n kube-system | grep -A10 "Command:\|Args:"
done

# Controller manager security check
kubectl describe pod kube-controller-manager-* -n kube-system | grep -A5 -B5 "terminated-pod-gc-threshold\|use-service-account-credentials"
```

**Assessment Checklist**:
- [ ] API server not bound to 0.0.0.0
- [ ] API server not running on default port 8080
- [ ] Anonymous authentication disabled
- [ ] RBAC enabled and properly configured
- [ ] Audit logging enabled and configured
- [ ] Encryption at rest enabled for etcd

#### 1.2 API Server Security Assessment
```bash
# API server security configuration audit
echo "=== API Server Security Configuration ==="
kubectl get pod -n kube-system -l component=kube-apiserver -o yaml | grep -E "(anonymous-auth|authorization-mode|audit-log|encryption-provider-config)"

# Check for insecure configurations
kubectl get pod -n kube-system -l component=kube-apiserver -o yaml | grep -E "(insecure-port|insecure-bind-address)" && echo "⚠️  Insecure API server configuration found" || echo "✅ No insecure API server configuration"

# Validate TLS configuration
kubectl get pod -n kube-system -l component=kube-apiserver -o yaml | grep -E "(tls-cert-file|tls-private-key-file|client-ca-file)"
```

### 2. Worker Node Security

#### 2.1 Node Configuration Assessment
```bash
# Kubelet configuration analysis
kubectl get nodes -o yaml | grep -E "(readOnlyPort|authentication|authorization)"

# Check kubelet service configuration on nodes (requires node access)
# This would typically be run on each worker node
echo "Kubelet configuration requires direct node access or privileged container"

# Node security compliance
kubectl get nodes -o custom-columns="NAME:.metadata.name,OS:.status.nodeInfo.osImage,KERNEL:.status.nodeInfo.kernelVersion,CONTAINER_RUNTIME:.status.nodeInfo.containerRuntimeVersion"
```

#### 2.2 Container Runtime Security
```bash
# Container runtime security assessment
kubectl get nodes -o yaml | grep containerRuntimeVersion

# Check for container runtime security policies (if using containerd, cri-o, etc.)
# This requires access to node configuration files
echo "Container runtime security assessment requires node-level access"

# Validate security contexts in workloads
kubectl get pods -A -o json | jq -r '.items[] | select(.spec.securityContext.runAsRoot != false) | "\(.metadata.namespace)/\(.metadata.name) may run as root"'
```

### 3. Control Plane Configuration

#### 3.1 etcd Security Configuration
```bash
# etcd security assessment
kubectl get pods -n kube-system -l component=etcd -o yaml | grep -E "(cert-file|key-file|trusted-ca-file|client-cert-auth|peer-cert-file|peer-key-file|peer-trusted-ca-file|peer-client-cert-auth)"

# Check etcd data encryption
kubectl get secrets -n kube-system | grep encryption-config || echo "⚠️  etcd encryption configuration not found"

# Validate etcd peer communication security
kubectl describe pod -n kube-system -l component=etcd | grep -A5 -B5 "peer-"
```

## Container Image Security Assessment

### Image Vulnerability Scanning
```bash
# Scan images in cluster with Trivy
kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort -u | head -10 | while read image; do
    echo "=== Scanning image: $image ==="
    trivy image --severity CRITICAL,HIGH --no-progress --format table "$image" 2>/dev/null || echo "Failed to scan $image"
    echo
done

# Check for latest/mutable tags usage
kubectl get pods -A -o json | jq -r '.items[].spec.containers[].image' | grep -E ':(latest|master|main)$' | sort | uniq -c

# Validate image pull policies
kubectl get pods -A -o json | jq -r '.items[] | select(.spec.containers[].imagePullPolicy != "Always") | "\(.metadata.namespace)/\(.metadata.name): \(.spec.containers[].imagePullPolicy)"'
```

### Supply Chain Security Assessment
```bash
# Check for image signing and verification (Cosign)
kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort -u | head -5 | while read image; do
    echo "=== Checking signatures for: $image ==="
    cosign verify --certificate-identity-regexp ".*" --certificate-oidc-issuer-regexp ".*" "$image" 2>/dev/null && echo "✅ Signature verified" || echo "⚠️  No valid signature found"
done

# Software Bill of Materials (SBOM) verification
kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort -u | head -3 | while read image; do
    echo "=== Checking SBOM for: $image ==="
    cosign download sbom "$image" 2>/dev/null | jq -r '.name' || echo "No SBOM found"
done

# Base image analysis
kubectl get pods -A -o json | jq -r '.items[].spec.containers[].image' | cut -d: -f1 | sort | uniq -c | sort -nr | head -10
```

### Container Registry Security
```bash
# Azure Container Registry security assessment
az acr list --query '[].name' -o tsv | while read registry; do
    echo "=== Registry: $registry ==="
    
    # Check admin user status
    az acr show --name $registry --query '{AdminEnabled:adminUserEnabled, PublicAccess:publicNetworkAccess}' -o table
    
    # Check for private endpoints
    az acr private-endpoint-connection list --registry-name $registry --query '[].{Name:name, State:privateLinkServiceConnectionState.status}' -o table
    
    # Vulnerability scanning status
    az acr task list --registry $registry --query '[].{Name:name, Status:status, TriggerType:trigger.baseImageTrigger.baseImageTriggerType}' -o table
done

# AWS ECR security assessment  
aws ecr describe-repositories --query 'repositories[].repositoryName' --output text | while read repo; do
    echo "=== Repository: $repo ==="
    
    # Check image scanning configuration
    aws ecr describe-repositories --repository-names $repo --query 'repositories[0].{ScanOnPush:imageScanningConfiguration.scanOnPush}' --output table
    
    # Check repository policies
    aws ecr get-repository-policy --repository-name $repo --query 'policyText' --output text 2>/dev/null || echo "No repository policy set"
    
    # Check lifecycle policies
    aws ecr get-lifecycle-policy --repository-name $repo --query 'lifecyclePolicyText' --output text 2>/dev/null || echo "No lifecycle policy set"
done
```

## Runtime Security Assessment

### Pod Security Standards and Policies
```bash
# Pod Security Standards assessment
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.securityContext.runAsUser == 0 or .spec.containers[].securityContext.runAsUser == 0) |
"\(.metadata.namespace)/\(.metadata.name): Running as root"
'

# Privileged containers detection
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.containers[].securityContext.privileged == true) |
"\(.metadata.namespace)/\(.metadata.name): Privileged container detected"
'

# Host namespace usage assessment
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.hostNetwork == true or .spec.hostPID == true or .spec.hostIPC == true) |
"\(.metadata.namespace)/\(.metadata.name): Using host namespaces - Network:\(.spec.hostNetwork) PID:\(.spec.hostPID) IPC:\(.spec.hostIPC)"
'

# Capabilities assessment
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.containers[].securityContext.capabilities.add != null) |
"\(.metadata.namespace)/\(.metadata.name): Added capabilities: \(.spec.containers[].securityContext.capabilities.add)"
'
```

### Network Policies Assessment
```bash
# Network policies inventory
kubectl get networkpolicies -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,POD_SELECTOR:.spec.podSelector,POLICY_TYPES:.spec.policyTypes"

# Check for default deny policies
kubectl get networkpolicies -A -o json | jq -r '
.items[] | 
select(.spec.podSelector.matchLabels == null or .spec.podSelector.matchLabels == {}) |
"\(.metadata.namespace): \(.metadata.name) - Default policy"
'

# Services without network policies
kubectl get namespaces -o json | jq -r '.items[].metadata.name' | while read ns; do
    pods_count=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l)
    netpol_count=$(kubectl get networkpolicies -n $ns --no-headers 2>/dev/null | wc -l)
    if [ $pods_count -gt 0 ] && [ $netpol_count -eq 0 ]; then
        echo "⚠️  Namespace $ns has $pods_count pods but no network policies"
    fi
done

# Ingress and egress rule analysis
kubectl get networkpolicies -A -o json | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name): Ingress rules: \(.spec.ingress | length), Egress rules: \(.spec.egress | length)"'
```

### Secrets Management Assessment
```bash
# Secrets inventory and usage analysis
kubectl get secrets -A --field-selector type!=kubernetes.io/service-account-token -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.type,DATA:.data"

# Check for secrets mounted as environment variables (less secure)
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.containers[].env[]?.valueFrom.secretKeyRef != null) |
"\(.metadata.namespace)/\(.metadata.name): Secret exposed as environment variable"
'

# Validate secret volume mounts
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.volumes[]?.secret != null) |
"\(.metadata.namespace)/\(.metadata.name): Uses secret volume mounts"
'

# Check for external secret management integration
kubectl get crd -A | grep -E "(secret|vault|external)" || echo "No external secret management CRDs found"

# Azure Key Vault integration (if using Azure)
kubectl get AzureKeyVaultSecret -A 2>/dev/null || echo "Azure Key Vault Secret Store CSI driver not detected"
```

## RBAC and Access Control Assessment

### Role-Based Access Control Analysis
```bash
# RBAC roles and bindings audit
echo "=== Cluster Roles with Dangerous Permissions ==="
kubectl get clusterroles -o json | jq -r '
.items[] | 
select(.rules[]? | select(.verbs[]? == "*" or (.resources[]? == "*"))) |
.metadata.name
' | head -10

# Check for overprivileged service accounts
kubectl get clusterrolebindings -o json | jq -r '
.items[] | 
select(.subjects[]?.kind == "ServiceAccount") |
"\(.metadata.name): \(.subjects[].name) in \(.subjects[].namespace)"
' | head -10

# Default service account usage (should be minimal)
kubectl get pods -A -o json | jq -r '
.items[] | 
select(.spec.serviceAccountName == "default" or .spec.serviceAccountName == null) |
"\(.metadata.namespace)/\(.metadata.name): Using default service account"
'

# Validate automountServiceAccountToken settings
kubectl get serviceaccounts -A -o json | jq -r '
.items[] | 
select(.automountServiceAccountToken != false) |
"\(.metadata.namespace)/\(.metadata.name): Auto-mounting service account token"
'
```

### Pod Security Admission Assessment
```bash
# Pod Security Standards labels on namespaces
kubectl get namespaces -o json | jq -r '
.items[] | 
{
  name: .metadata.name,
  enforce: .metadata.labels["pod-security.kubernetes.io/enforce"],
  audit: .metadata.labels["pod-security.kubernetes.io/audit"], 
  warn: .metadata.labels["pod-security.kubernetes.io/warn"]
} | 
"\(.name): enforce=\(.enforce), audit=\(.audit), warn=\(.warn)"
'

# Check for Pod Security Policy (deprecated) or Pod Security Standards usage
kubectl get podsecuritypolicy 2>/dev/null | head -5 || echo "Pod Security Policy not found (deprecated)"

# Admission controller configuration (requires cluster admin access)
kubectl get pods -n kube-system -l component=kube-apiserver -o yaml | grep admission | head -5
```

## Cloud Provider Specific Assessments

### Azure Kubernetes Service (AKS) Security
```bash
# AKS cluster security configuration
az aks show --resource-group myResourceGroup --name myAKSCluster --query '{
    NetworkProfile: networkProfile,
    AADProfile: aadProfile,
    AutoScalerProfile: autoScalerProfile,
    SecurityProfile: securityProfile,
    NodeResourceGroup: nodeResourceGroup
}' -o yaml

# AKS managed identity configuration
az aks show --resource-group myResourceGroup --name myAKSCluster --query 'identity' -o table

# Network policy configuration
az aks show --resource-group myResourceGroup --name myAKSCluster --query 'networkProfile.networkPolicy' -o tsv

# Azure Policy for AKS (Gatekeeper)
kubectl get constrainttemplates -o custom-columns="NAME:.metadata.name,KIND:.spec.crd.spec.names.kind"
kubectl get constraints -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,KIND:.kind,ENFORCEMENT:.spec.enforcementAction"

# Azure Container Insights monitoring
az aks show --resource-group myResourceGroup --name myAKSCluster --query 'addonProfiles.omsAgent' -o yaml
```

### Amazon EKS Security Assessment
```bash
# EKS cluster security configuration
aws eks describe-cluster --name myEKSCluster --query 'cluster.{
    Version: version,
    Endpoint: endpoint,
    Logging: logging,
    ResourcesVpcConfig: resourcesVpcConfig,
    EncryptionConfig: encryptionConfig
}' --output yaml

# EKS node group configuration
aws eks describe-nodegroup --cluster-name myEKSCluster --nodegroup-name myNodeGroup --query 'nodegroup.{
    AmiType: amiType,
    InstanceTypes: instanceTypes,
    RemoteAccess: remoteAccess,
    LaunchTemplate: launchTemplate
}' --output yaml

# AWS Load Balancer Controller security
kubectl get deployment -n kube-system aws-load-balancer-controller -o yaml | grep -A5 -B5 serviceAccountName

# EKS Fargate profiles (if used)
aws eks list-fargate-profiles --cluster-name myEKSCluster --query 'fargateProfileNames' --output table
```

### Google Kubernetes Engine (GKE) Security
```bash
# GKE cluster security configuration
gcloud container clusters describe myGKECluster --zone=us-central1-a --format="yaml(
    masterAuth,
    networkPolicy,
    privateClusterConfig,
    workloadIdentityConfig,
    binaryAuthorization,
    shieldedNodes
)" 2>/dev/null || echo "GKE cluster access not available"

# GKE Autopilot vs Standard mode security implications
gcloud container clusters list --format="table(name,location,status,autopilot.enabled)" 2>/dev/null || echo "GKE access not available"

# Workload Identity configuration
gcloud container clusters describe myGKECluster --zone=us-central1-a --format="value(workloadIdentityConfig.workloadPool)" 2>/dev/null || echo "Workload Identity not configured or accessible"

# Binary Authorization policies
gcloud container binauthz policy export --format=yaml 2>/dev/null || echo "Binary Authorization policy not accessible"
```

## DevSecOps Pipeline Security

### CI/CD Pipeline Security Assessment
```bash
# Check for security scanning in CI/CD
echo "=== Container Image Security in CI/CD ==="

# Look for security scanning tools in common CI/CD locations
find . -name "*.yml" -o -name "*.yaml" | xargs grep -l -i "trivy\|snyk\|anchore\|clair\|twistlock\|aqua" 2>/dev/null | head -5

# Check for image signing in pipelines
find . -name "*.yml" -o -name "*.yaml" | xargs grep -l -i "cosign\|notary" 2>/dev/null | head -5

# Validate Kubernetes manifest security policies
find . -name "*.yml" -o -name "*.yaml" | xargs grep -l "SecurityContext\|runAsNonRoot\|allowPrivilegeEscalation" 2>/dev/null | head -5

# Check for secrets scanning
find . -name "*.yml" -o -name "*.yaml" | xargs grep -l -i "gitleaks\|truffhog\|detect-secrets" 2>/dev/null | head -5
```

### Admission Controller Security
```bash
# Open Policy Agent (OPA) Gatekeeper assessment
kubectl get crd -o name | grep gatekeeper || echo "Gatekeeper not installed"

# Falco runtime security monitoring
kubectl get pods -n falco-system 2>/dev/null || echo "Falco not detected"
kubectl get falco -A 2>/dev/null || echo "Falco CRDs not found"

# Istio service mesh security (if deployed)
kubectl get pods -n istio-system 2>/dev/null || echo "Istio not detected"
kubectl get peerauthentication -A 2>/dev/null || echo "Istio PeerAuthentication not found"

# Linkerd service mesh security assessment
kubectl get pods -n linkerd 2>/dev/null || echo "Linkerd not detected"
kubectl get trafficsplit -A 2>/dev/null || echo "Linkerd TrafficSplit not found"
```

## Automated Security Assessment Script

### Comprehensive Container Security Scan
```bash
#!/bin/bash
# Comprehensive Container Security Assessment Script

set -e

ASSESSMENT_DATE=$(date +%Y-%m-%d-%H%M)
REPORT_DIR="./container-security-assessment-$ASSESSMENT_DATE"
mkdir -p "$REPORT_DIR"

echo "=== Container Security Assessment ==="
echo "Assessment Date: $(date)"
echo "Report Directory: $REPORT_DIR"
echo

# Function to run assessment and save output
run_assessment() {
    local test_name=$1
    local command=$2
    local output_file="$REPORT_DIR/${test_name}.txt"
    
    echo "Running: $test_name"
    echo "=== $test_name ===" > "$output_file"
    echo "Generated: $(date)" >> "$output_file"
    echo >> "$output_file"
    
    if eval "$command" >> "$output_file" 2>&1; then
        echo "✅ $test_name completed"
    else
        echo "⚠️  $test_name failed or had issues"
    fi
}

# Cluster Information
run_assessment "cluster-info" "kubectl cluster-info"
run_assessment "node-info" "kubectl get nodes -o wide"
run_assessment "namespace-inventory" "kubectl get namespaces"

# Security Configuration Assessment
run_assessment "pod-security-contexts" "kubectl get pods -A -o json | jq -r '.items[] | select(.spec.securityContext.runAsUser == 0 or .spec.containers[].securityContext.runAsUser == 0) | \"\(.metadata.namespace)/\(.metadata.name): Running as root\"'"

run_assessment "privileged-containers" "kubectl get pods -A -o json | jq -r '.items[] | select(.spec.containers[].securityContext.privileged == true) | \"\(.metadata.namespace)/\(.metadata.name): Privileged container\"'"

run_assessment "host-namespace-usage" "kubectl get pods -A -o json | jq -r '.items[] | select(.spec.hostNetwork == true or .spec.hostPID == true or .spec.hostIPC == true) | \"\(.metadata.namespace)/\(.metadata.name): Host namespaces\"'"

# RBAC Assessment
run_assessment "dangerous-cluster-roles" "kubectl get clusterroles -o json | jq -r '.items[] | select(.rules[]? | select(.verbs[]? == \"*\" or (.resources[]? == \"*\"))) | .metadata.name'"

run_assessment "service-account-usage" "kubectl get pods -A -o json | jq -r '.items[] | select(.spec.serviceAccountName == \"default\" or .spec.serviceAccountName == null) | \"\(.metadata.namespace)/\(.metadata.name): Default SA\"'"

# Network Security Assessment
run_assessment "network-policies" "kubectl get networkpolicies -A -o wide"
run_assessment "services-inventory" "kubectl get services -A -o wide"

# Secrets Management Assessment
run_assessment "secrets-inventory" "kubectl get secrets -A --field-selector type!=kubernetes.io/service-account-token"
run_assessment "secret-env-vars" "kubectl get pods -A -o json | jq -r '.items[] | select(.spec.containers[].env[]?.valueFrom.secretKeyRef != null) | \"\(.metadata.namespace)/\(.metadata.name): Secret in env\"'"

# Image Security Assessment
run_assessment "image-inventory" "kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\\n' | sort -u"
run_assessment "mutable-tags" "kubectl get pods -A -o json | jq -r '.items[].spec.containers[].image' | grep -E ':(latest|master|main)$' | sort | uniq -c"

# Cloud Provider Specific Assessments
if kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | grep -q "azure"; then
    run_assessment "aks-configuration" "az aks list --query '[].{Name:name, ResourceGroup:resourceGroup, KubernetesVersion:kubernetesVersion}' -o table 2>/dev/null || echo 'AZ CLI not configured'"
fi

if kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | grep -q "aws"; then
    run_assessment "eks-configuration" "aws eks list-clusters --query 'clusters' --output table 2>/dev/null || echo 'AWS CLI not configured'"
fi

if kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | grep -q "gce"; then
    run_assessment "gke-configuration" "gcloud container clusters list --format='table(name,location,status)' 2>/dev/null || echo 'gcloud not configured'"
fi

# Security Tool Detection
run_assessment "security-tools" "kubectl get pods -A | grep -E 'falco|gatekeeper|istio|linkerd|vault|cert-manager'"

# Generate summary report
echo "=== Assessment Summary ===" > "$REPORT_DIR/summary.txt"
echo "Assessment completed: $(date)" >> "$REPORT_DIR/summary.txt"
echo "Total assessment files: $(ls -1 $REPORT_DIR/*.txt | wc -l)" >> "$REPORT_DIR/summary.txt"
echo >> "$REPORT_DIR/summary.txt"

echo "Files generated:" >> "$REPORT_DIR/summary.txt"
ls -la "$REPORT_DIR/" >> "$REPORT_DIR/summary.txt"

echo
echo "=== Container Security Assessment Complete ==="
echo "Results saved in: $REPORT_DIR"
echo "Review the summary.txt file for an overview"
echo

# If Trivy is available, run image vulnerability scanning on top images
if command -v trivy >/dev/null 2>&1; then
    echo "Running vulnerability scans on container images..."
    mkdir -p "$REPORT_DIR/image-scans"
    
    kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort | uniq -c | sort -nr | head -5 | while read count image; do
        echo "Scanning $image (used $count times)"
        trivy image --severity CRITICAL,HIGH --format json "$image" > "$REPORT_DIR/image-scans/$(echo $image | tr '/' '_' | tr ':' '_').json" 2>/dev/null || echo "Failed to scan $image"
    done
fi

echo "Assessment artifact location: $REPORT_DIR"
```

## Risk Assessment and Scoring

### Container Security Risk Matrix
| Risk Category | Low (1-3) | Medium (4-6) | High (7-8) | Critical (9-10) |
|---------------|-----------|--------------|------------|-----------------|
| **Runtime Privileges** | Non-root, dropped caps | Some elevated caps | Root or privileged | Host namespace access |
| **Image Vulnerabilities** | No high/critical CVEs | < 5 high CVEs | 5-15 high CVEs | > 15 high or any critical |
| **Network Exposure** | Network policies enforced | Limited network policies | No network policies | Internet-accessible services |
| **Secrets Management** | External secret store | Kubernetes secrets only | Secrets in env vars | Hardcoded secrets |
| **Supply Chain** | Signed images, SBOMs | Vulnerability scanning | Basic registry security | Unknown/unsigned images |

### Scoring Algorithm
```python
def calculate_container_risk_score(assessment_results):
    """Calculate comprehensive container security risk score"""
    
    risk_score = 0
    max_score = 100
    
    # Runtime Security (25 points)
    if assessment_results.get('privileged_containers', 0) > 0:
        risk_score += 25
    elif assessment_results.get('root_containers', 0) > 0:
        risk_score += 15
    elif assessment_results.get('host_namespace_usage', 0) > 0:
        risk_score += 20
    elif assessment_results.get('dangerous_capabilities', 0) > 0:
        risk_score += 10
    
    # Image Security (20 points)
    critical_vulns = assessment_results.get('critical_vulnerabilities', 0)
    high_vulns = assessment_results.get('high_vulnerabilities', 0)
    
    if critical_vulns > 0:
        risk_score += 20
    elif high_vulns > 15:
        risk_score += 15
    elif high_vulns > 5:
        risk_score += 10
    elif high_vulns > 0:
        risk_score += 5
    
    # Network Security (20 points)
    if assessment_results.get('network_policies_count', 0) == 0:
        risk_score += 15
    if assessment_results.get('internet_exposed_services', 0) > 0:
        risk_score += 10
    if assessment_results.get('load_balancer_services', 0) > 0:
        risk_score += 5
    
    # Access Control (20 points)
    if assessment_results.get('overprivileged_service_accounts', 0) > 0:
        risk_score += 15
    if assessment_results.get('default_service_account_usage', 0) > 0:
        risk_score += 10
    if assessment_results.get('cluster_admin_bindings', 0) > 0:
        risk_score += 10
    
    # Secrets Management (15 points)
    if assessment_results.get('hardcoded_secrets', 0) > 0:
        risk_score += 15
    elif assessment_results.get('secrets_in_env_vars', 0) > 0:
        risk_score += 10
    elif not assessment_results.get('external_secret_management', False):
        risk_score += 5
    
    # Normalize to 1-10 scale
    final_score = min((risk_score / max_score) * 10, 10)
    
    return {
        'risk_score': round(final_score, 1),
        'risk_level': get_risk_level(final_score),
        'raw_score': risk_score,
        'max_possible': max_score
    }

def get_risk_level(score):
    if score >= 8:
        return 'Critical'
    elif score >= 6:
        return 'High'
    elif score >= 4:
        return 'Medium'
    else:
        return 'Low'
```

## Remediation Guidance

### High Priority Remediations

#### Enable Pod Security Standards
```yaml
# Apply Pod Security Standards to namespaces
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
---
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

#### Implement Network Policies
```yaml
# Default deny network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow specific communication
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-to-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
    ports:
    - protocol: TCP
      port: 8080
```

#### Secure Container Configurations
```yaml
# Secure pod security context example
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    runAsGroup: 10001
    fsGroup: 10001
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: myapp:v1.2.3  # Use specific version tags
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
        add:
        - NET_BIND_SERVICE  # Only add required capabilities
      readOnlyRootFilesystem: true
      runAsNonRoot: true
    resources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 100m
        memory: 128Mi
    volumeMounts:
    - name: temp-volume
      mountPath: /tmp
  volumes:
  - name: temp-volume
    emptyDir: {}
```

#### RBAC Hardening
```yaml
# Minimal service account permissions
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: production
automountServiceAccountToken: false  # Disable if not needed
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: production
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
  resourceNames: ["app-secret"]  # Limit to specific resources
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-rolebinding
  namespace: production
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: production
roleRef:
  kind: Role
  name: app-role
  apiGroup: rbac.authorization.k8s.io
```

### Image Security Improvements
```bash
# Build secure container images
# Dockerfile security best practices
cat << 'EOF' > Dockerfile.secure
# Use minimal base image
FROM alpine:3.18

# Create non-root user
RUN addgroup -g 10001 appgroup && \
    adduser -D -u 10001 -G appgroup appuser

# Install only required packages
RUN apk add --no-cache ca-certificates tzdata && \
    rm -rf /var/cache/apk/*

# Set up application directory
WORKDIR /app
COPY --chown=appuser:appgroup app /app/

# Use non-root user
USER appuser:appgroup

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Security labels
LABEL security.scan.date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
LABEL security.scan.tool="trivy"

EXPOSE 8080
ENTRYPOINT ["/app/app"]
EOF

# Build and scan image
docker build -t myapp:secure -f Dockerfile.secure .
trivy image --severity CRITICAL,HIGH myapp:secure

# Sign the image (if using Cosign)
cosign sign --yes myapp:secure
```

### CI/CD Pipeline Security Integration
```yaml
# GitHub Actions security pipeline
name: Container Security Pipeline
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Container Image
      run: docker build -t ${{ github.sha }} .
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'CRITICAL,HIGH'
        exit-code: '1'  # Fail on critical/high vulnerabilities
    
    - name: Upload Trivy scan results to GitHub Security tab
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'
    
    - name: Generate SBOM
      uses: anchore/sbom-action@v0
      with:
        image: ${{ github.sha }}
        format: cyclonedx-json
        output-file: sbom.json
    
    - name: Sign container image
      uses: sigstore/cosign-installer@v3
      with:
        cosign-release: 'v2.0.0'
    - name: Sign image with Cosign
      run: cosign sign --yes ${{ github.sha }}
      env:
        COSIGN_EXPERIMENTAL: 1
    
    - name: Kubernetes manifest security scan
      uses: azure/k8s-lint@v1
      with:
        manifests: |
          k8s/deployment.yaml
          k8s/service.yaml
        
    - name: Deploy to staging
      if: github.event_name == 'push'
      run: |
        kubectl apply -f k8s/ --namespace=staging --dry-run=client
        kubectl apply -f k8s/ --namespace=staging
```

## Compliance and Governance

### CIS Kubernetes Benchmark Compliance Report
```bash
# Generate CIS Kubernetes Benchmark compliance report
#!/bin/bash

echo "=== CIS Kubernetes Benchmark v1.7.0 Compliance Report ==="
echo "Generated: $(date)"
echo

declare -A cis_checks
declare -A cis_results

# CIS 1.1.1 - Ensure that the API server pod specification file permissions are set to 644 or more restrictive
cis_checks["1.1.1"]="API server pod specification file permissions"
# This would require node access to check /etc/kubernetes/manifests/kube-apiserver.yaml

# CIS 4.1.1 - Ensure that the cluster-admin role is only used where required
cis_checks["4.1.1"]="Cluster admin role usage"
cluster_admin_bindings=$(kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name == "cluster-admin") | .metadata.name' | wc -l)
if [ $cluster_admin_bindings -le 3 ]; then
    cis_results["4.1.1"]="PASS"
else
    cis_results["4.1.1"]="FAIL - $cluster_admin_bindings cluster-admin bindings found"
fi

# CIS 4.2.6 - Minimize the admission of containers with allowPrivilegeEscalation
cis_checks["4.2.6"]="Containers with allowPrivilegeEscalation"
priv_esc_pods=$(kubectl get pods -A -o json | jq -r '.items[] | select(.spec.containers[].securityContext.allowPrivilegeEscalation == true) | "\(.metadata.namespace)/\(.metadata.name)"' | wc -l)
if [ $priv_esc_pods -eq 0 ]; then
    cis_results["4.2.6"]="PASS"
else
    cis_results["4.2.6"]="FAIL - $priv_esc_pods pods allow privilege escalation"
fi

# Print results
echo "Control ID | Description | Result"
echo "-----------|-------------|--------"
for control in "${!cis_checks[@]}"; do
    echo "$control | ${cis_checks[$control]} | ${cis_results[$control]:-"NOT TESTED"}"
done

# Calculate compliance percentage
total_tests=${#cis_checks[@]}
passed_tests=$(echo "${cis_results[@]}" | grep -o "PASS" | wc -l)
compliance_percentage=$((passed_tests * 100 / total_tests))

echo
echo "Overall CIS Compliance: $compliance_percentage% ($passed_tests/$total_tests tests passed)"
```

## Report Template

### Executive Summary
**Container Security Assessment Summary**
- **Assessment Date**: [Date]
- **Clusters Assessed**: [Number] clusters across [Azure AKS/AWS EKS/GCP GKE]
- **Overall Risk Rating**: [Rating]/10
- **Critical Security Issues**: [Count]

**Key Risk Areas Identified**:
1. **Privileged Container Usage**: [X] containers running with elevated privileges
2. **Image Vulnerabilities**: [Y] critical/high severity vulnerabilities found
3. **Network Security**: [Z] workloads without network policy protection
4. **RBAC Configuration**: [A] overprivileged service accounts identified

**Immediate Actions Required**:
- Implement Pod Security Standards across all namespaces
- Deploy default-deny network policies
- Remediate critical vulnerabilities in container images
- Implement image vulnerability scanning in CI/CD pipelines

### Detailed Technical Findings

#### Runtime Security Assessment
| Metric | Current State | Target State | Risk Level |
|--------|---------------|--------------|------------|
| Privileged Containers | [X] containers | 0 containers | Critical |
| Root User Containers | [Y] containers | 0 containers | High |
| Host Namespace Usage | [Z] containers | 0 containers | Critical |
| Network Policy Coverage | [A]% | 100% | Medium |

#### Image Security Analysis
| Registry | Total Images | Critical CVEs | High CVEs | Signed Images |
|----------|--------------|---------------|-----------|---------------|
| Azure ACR | [X] | [Y] | [Z] | [A]% |
| AWS ECR | [X] | [Y] | [Z] | [A]% |
| Docker Hub | [X] | [Y] | [Z] | [A]% |

#### Compliance Status
| Framework | Compliant Controls | Total Controls | Compliance % |
|-----------|-------------------|----------------|--------------|
| CIS Kubernetes Benchmark v1.7.0 | [X] | [Y] | [Z]% |
| NIST SP 800-190 | [X] | [Y] | [Z]% |
| Pod Security Standards | [X] | [Y] | [Z]% |

### Remediation Timeline
- **Week 1-2**: Implement Pod Security Standards and default-deny network policies
- **Week 3-4**: Remediate critical container image vulnerabilities
- **Month 2**: Deploy runtime security monitoring (Falco) and admission controllers
- **Month 3**: Implement comprehensive CI/CD security pipeline integration

### Long-term Security Strategy
1. **Zero Trust Network Architecture**: Implement comprehensive network policies and service mesh security
2. **Supply Chain Security**: Establish image signing, SBOM generation, and attestation processes  
3. **Runtime Threat Detection**: Deploy advanced runtime security monitoring and response
4. **Continuous Compliance**: Automate compliance validation and policy enforcement

This assessment provides the foundation for establishing a robust container security posture aligned with industry best practices and compliance requirements.