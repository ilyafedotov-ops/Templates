#!/bin/bash
#
# Deployment Functions Library
# Comprehensive shared deployment functions for CI/CD pipelines
# Version: 2.2.0
# Compatible with: GitHub Actions, Azure DevOps, GitLab CI, Jenkins
#
# Usage:
#   source deployment-functions.sh
#   setup_deployment_environment
#   deploy_application "production" "/path/to/app" "v1.2.3"
#

set -euo pipefail

# Global Configuration
DEPLOYMENT_FUNCTIONS_VERSION="2.2.0"
DEPLOYMENT_TEMP_DIR="${TMPDIR:-/tmp}/deployment-$$"
DEPLOYMENT_LOGS_DIR="deployment-logs"
DEPLOYMENT_STATE_DIR="deployment-state"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Deployment Configuration
DEFAULT_TIMEOUT=600
DEFAULT_RETRY_COUNT=3
DEFAULT_RETRY_DELAY=30
DEFAULT_HEALTH_CHECK_ATTEMPTS=10
DEFAULT_HEALTH_CHECK_INTERVAL=30

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${DEPLOYMENT_LOGS_DIR}/deployment.log"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${DEPLOYMENT_LOGS_DIR}/deployment.log"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${DEPLOYMENT_LOGS_DIR}/deployment.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${DEPLOYMENT_LOGS_DIR}/deployment.log"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${DEPLOYMENT_LOGS_DIR}/deployment.log"
    fi
}

# Deployment Environment Setup
setup_deployment_environment() {
    local setup_start_time=$(date +%s)
    
    log_info "Setting up deployment environment (v${DEPLOYMENT_FUNCTIONS_VERSION})"
    
    # Create necessary directories
    mkdir -p "${DEPLOYMENT_LOGS_DIR}" "${DEPLOYMENT_STATE_DIR}" "${DEPLOYMENT_TEMP_DIR}"
    
    # Set permissions
    chmod 700 "${DEPLOYMENT_TEMP_DIR}"
    
    # Initialize deployment state
    cat > "${DEPLOYMENT_STATE_DIR}/deployment-session.json" << EOF
{
  "session_id": "$(date +%Y%m%d-%H%M%S)-$$",
  "started_at": "$(date -Iseconds)",
  "version": "${DEPLOYMENT_FUNCTIONS_VERSION}",
  "environment": {
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "shell": "${SHELL}",
    "user": "${USER:-unknown}",
    "pwd": "$(pwd)",
    "hostname": "$(hostname)"
  },
  "deployments": []
}
EOF
    
    # Check system requirements
    check_deployment_requirements
    
    local setup_duration=$(($(date +%s) - setup_start_time))
    log_success "Deployment environment setup completed in ${setup_duration}s"
}

# Check Deployment Requirements
check_deployment_requirements() {
    log_info "Checking deployment requirements..."
    
    local required_tools=("curl" "jq" "tar" "gzip")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
    
    log_success "All deployment requirements satisfied"
}

# Main Deployment Function
deploy_application() {
    local environment="$1"
    local app_path="$2"
    local version="${3:-latest}"
    local deployment_strategy="${4:-rolling}"
    local config_file="${5:-}"
    
    local deployment_id="deploy-$(date +%Y%m%d-%H%M%S)-$$"
    local deployment_start_time=$(date +%s)
    
    log_info "Starting deployment: $deployment_id"
    log_info "Environment: $environment"
    log_info "Application Path: $app_path"
    log_info "Version: $version"
    log_info "Strategy: $deployment_strategy"
    
    # Initialize deployment state
    local deployment_state_file="${DEPLOYMENT_STATE_DIR}/${deployment_id}.json"
    init_deployment_state "$deployment_id" "$environment" "$app_path" "$version" "$deployment_strategy"
    
    # Validate deployment prerequisites
    if ! validate_deployment_prerequisites "$environment" "$app_path" "$config_file"; then
        log_error "Deployment prerequisites validation failed"
        update_deployment_state "$deployment_id" "failed" "Prerequisites validation failed"
        return 1
    fi
    
    # Pre-deployment hooks
    if ! run_pre_deployment_hooks "$deployment_id" "$environment" "$app_path"; then
        log_error "Pre-deployment hooks failed"
        update_deployment_state "$deployment_id" "failed" "Pre-deployment hooks failed"
        return 1
    fi
    
    # Execute deployment strategy
    case "$deployment_strategy" in
        "rolling")
            execute_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version" "$config_file"
            ;;
        "blue-green"|"bluegreen")
            execute_blue_green_deployment "$deployment_id" "$environment" "$app_path" "$version" "$config_file"
            ;;
        "canary")
            execute_canary_deployment "$deployment_id" "$environment" "$app_path" "$version" "$config_file"
            ;;
        "recreate")
            execute_recreate_deployment "$deployment_id" "$environment" "$app_path" "$version" "$config_file"
            ;;
        "a-b"|"ab")
            execute_ab_deployment "$deployment_id" "$environment" "$app_path" "$version" "$config_file"
            ;;
        *)
            log_error "Unknown deployment strategy: $deployment_strategy"
            update_deployment_state "$deployment_id" "failed" "Unknown deployment strategy"
            return 1
            ;;
    esac
    
    local deployment_exit_code=$?
    
    # Post-deployment hooks
    run_post_deployment_hooks "$deployment_id" "$environment" "$app_path" "$deployment_exit_code"
    
    # Calculate deployment duration
    local deployment_duration=$(($(date +%s) - deployment_start_time))
    
    if [[ $deployment_exit_code -eq 0 ]]; then
        log_success "Deployment $deployment_id completed successfully in ${deployment_duration}s"
        update_deployment_state "$deployment_id" "success" "Deployment completed successfully" "$deployment_duration"
    else
        log_error "Deployment $deployment_id failed after ${deployment_duration}s"
        update_deployment_state "$deployment_id" "failed" "Deployment execution failed" "$deployment_duration"
    fi
    
    return $deployment_exit_code
}

# Initialize Deployment State
init_deployment_state() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    local strategy="$5"
    
    local state_file="${DEPLOYMENT_STATE_DIR}/${deployment_id}.json"
    
    cat > "$state_file" << EOF
{
  "deployment_id": "$deployment_id",
  "started_at": "$(date -Iseconds)",
  "status": "in_progress",
  "environment": "$environment",
  "app_path": "$app_path",
  "version": "$version",
  "strategy": "$strategy",
  "phases": [],
  "health_checks": [],
  "rollback_info": {},
  "metadata": {
    "user": "${USER:-unknown}",
    "hostname": "$(hostname)",
    "commit": "${GIT_COMMIT:-${GITHUB_SHA:-unknown}}",
    "branch": "${GIT_BRANCH:-${GITHUB_REF_NAME:-unknown}}"
  }
}
EOF
    
    # Update session state
    local session_file="${DEPLOYMENT_STATE_DIR}/deployment-session.json"
    if [[ -f "$session_file" ]]; then
        jq --arg deployment_id "$deployment_id" \
           '.deployments += [$deployment_id]' \
           "$session_file" > "${session_file}.tmp" && mv "${session_file}.tmp" "$session_file"
    fi
}

# Update Deployment State
update_deployment_state() {
    local deployment_id="$1"
    local status="$2"
    local message="$3"
    local duration="${4:-}"
    
    local state_file="${DEPLOYMENT_STATE_DIR}/${deployment_id}.json"
    
    if [[ -f "$state_file" ]]; then
        local update_data="{\"status\": \"$status\", \"message\": \"$message\", \"updated_at\": \"$(date -Iseconds)\"}"
        
        if [[ -n "$duration" ]]; then
            update_data=$(echo "$update_data" | jq --argjson duration "$duration" '. + {duration: $duration}')
        fi
        
        jq --argjson update "$update_data" '. + $update' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
    fi
}

# Validate Deployment Prerequisites
validate_deployment_prerequisites() {
    local environment="$1"
    local app_path="$2"
    local config_file="$3"
    
    log_info "Validating deployment prerequisites..."
    
    # Check if application path exists
    if [[ ! -d "$app_path" && ! -f "$app_path" ]]; then
        log_error "Application path does not exist: $app_path"
        return 1
    fi
    
    # Validate configuration file if provided
    if [[ -n "$config_file" && ! -f "$config_file" ]]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    # Environment-specific validations
    case "$environment" in
        "production"|"prod")
            validate_production_prerequisites "$app_path" "$config_file"
            ;;
        "staging"|"stage")
            validate_staging_prerequisites "$app_path" "$config_file"
            ;;
        "development"|"dev")
            validate_development_prerequisites "$app_path" "$config_file"
            ;;
    esac
    
    log_success "Prerequisites validation passed"
    return 0
}

validate_production_prerequisites() {
    local app_path="$1"
    local config_file="$2"
    
    log_info "Validating production deployment prerequisites..."
    
    # Check for security scans
    if [[ ! -f "security-results/comprehensive-report.json" ]]; then
        log_warning "No security scan results found - production deployment may be risky"
    fi
    
    # Check for test results
    if [[ ! -f "test-results.xml" && ! -f "junit.xml" ]]; then
        log_warning "No test results found - production deployment may be risky"
    fi
    
    # Check for backup strategy
    if [[ ! -f "backup-config.json" && ! -f ".backup-strategy" ]]; then
        log_warning "No backup strategy found - consider implementing backup procedures"
    fi
    
    return 0
}

validate_staging_prerequisites() {
    local app_path="$1"
    local config_file="$2"
    
    log_info "Validating staging deployment prerequisites..."
    
    # Basic validation for staging
    return 0
}

validate_development_prerequisites() {
    local app_path="$1"
    local config_file="$2"
    
    log_info "Validating development deployment prerequisites..."
    
    # Minimal validation for development
    return 0
}

# Pre-deployment Hooks
run_pre_deployment_hooks() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    
    log_info "Running pre-deployment hooks..."
    
    # Create backup
    if ! create_deployment_backup "$deployment_id" "$environment"; then
        log_error "Failed to create deployment backup"
        return 1
    fi
    
    # Run custom pre-deployment scripts
    if [[ -f "scripts/pre-deploy.sh" ]]; then
        log_info "Executing custom pre-deployment script..."
        if bash "scripts/pre-deploy.sh" "$environment" "$app_path"; then
            log_success "Custom pre-deployment script completed successfully"
        else
            log_error "Custom pre-deployment script failed"
            return 1
        fi
    fi
    
    # Environment-specific pre-deployment tasks
    case "$environment" in
        "production"|"prod")
            run_production_pre_deployment_tasks "$deployment_id"
            ;;
        "staging"|"stage")
            run_staging_pre_deployment_tasks "$deployment_id"
            ;;
    esac
    
    log_success "Pre-deployment hooks completed successfully"
    return 0
}

# Post-deployment Hooks
run_post_deployment_hooks() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local deployment_exit_code="$4"
    
    log_info "Running post-deployment hooks..."
    
    # Run health checks
    if [[ $deployment_exit_code -eq 0 ]]; then
        run_deployment_health_checks "$deployment_id" "$environment"
        local health_check_result=$?
        
        if [[ $health_check_result -ne 0 ]]; then
            log_error "Health checks failed, considering rollback..."
            # Note: Actual rollback decision should be made by calling function
        fi
    fi
    
    # Run custom post-deployment scripts
    if [[ -f "scripts/post-deploy.sh" ]]; then
        log_info "Executing custom post-deployment script..."
        if bash "scripts/post-deploy.sh" "$environment" "$app_path" "$deployment_exit_code"; then
            log_success "Custom post-deployment script completed successfully"
        else
            log_warning "Custom post-deployment script failed (non-blocking)"
        fi
    fi
    
    # Send deployment notifications
    send_deployment_notifications "$deployment_id" "$environment" "$deployment_exit_code"
    
    # Clean up old deployments/backups
    cleanup_old_deployments "$environment"
    
    log_success "Post-deployment hooks completed"
    return 0
}

# Rolling Deployment Strategy
execute_rolling_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    local config_file="$5"
    
    log_info "Executing rolling deployment strategy..."
    
    # Detect deployment target type
    local deployment_target=$(detect_deployment_target "$environment")
    
    case "$deployment_target" in
        "kubernetes")
            execute_kubernetes_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "docker")
            execute_docker_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "systemd")
            execute_systemd_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "aws")
            execute_aws_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "azure")
            execute_azure_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "gcp")
            execute_gcp_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "manual")
            execute_manual_rolling_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        *)
            log_error "Unknown deployment target: $deployment_target"
            return 1
            ;;
    esac
}

# Blue-Green Deployment Strategy
execute_blue_green_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    local config_file="$5"
    
    log_info "Executing blue-green deployment strategy..."
    
    local deployment_target=$(detect_deployment_target "$environment")
    
    case "$deployment_target" in
        "kubernetes")
            execute_kubernetes_blue_green_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "aws")
            execute_aws_blue_green_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        "azure")
            execute_azure_blue_green_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
        *)
            log_warning "Blue-green deployment not optimized for $deployment_target, falling back to manual implementation"
            execute_manual_blue_green_deployment "$deployment_id" "$environment" "$app_path" "$version"
            ;;
    esac
}

# Canary Deployment Strategy
execute_canary_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    local config_file="$5"
    
    log_info "Executing canary deployment strategy..."
    
    local deployment_target=$(detect_deployment_target "$environment")
    local canary_percentage="${CANARY_PERCENTAGE:-10}"
    
    log_info "Canary deployment with $canary_percentage% traffic"
    
    case "$deployment_target" in
        "kubernetes")
            execute_kubernetes_canary_deployment "$deployment_id" "$environment" "$app_path" "$version" "$canary_percentage"
            ;;
        "aws")
            execute_aws_canary_deployment "$deployment_id" "$environment" "$app_path" "$version" "$canary_percentage"
            ;;
        *)
            log_warning "Canary deployment not optimized for $deployment_target, falling back to manual implementation"
            execute_manual_canary_deployment "$deployment_id" "$environment" "$app_path" "$version" "$canary_percentage"
            ;;
    esac
}

# Kubernetes Deployment Implementations
execute_kubernetes_rolling_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    
    log_info "Deploying to Kubernetes with rolling update..."
    
    # Check kubectl availability
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl not found"
        return 1
    fi
    
    # Apply Kubernetes manifests
    if [[ -d "$app_path/k8s" ]]; then
        log_info "Applying Kubernetes manifests from $app_path/k8s"
        
        # Replace version placeholders
        local temp_manifests="${DEPLOYMENT_TEMP_DIR}/k8s-manifests"
        mkdir -p "$temp_manifests"
        
        for manifest in "$app_path/k8s"/*.yaml "$app_path/k8s"/*.yml; do
            if [[ -f "$manifest" ]]; then
                sed "s/{{VERSION}}/$version/g; s/{{ENVIRONMENT}}/$environment/g" "$manifest" > "$temp_manifests/$(basename "$manifest")"
            fi
        done
        
        # Apply manifests
        kubectl apply -f "$temp_manifests/" --record
        
        # Wait for rollout to complete
        local deployment_name=$(kubectl get deployments -o name | head -1 | cut -d'/' -f2)
        if [[ -n "$deployment_name" ]]; then
            log_info "Waiting for rollout of deployment: $deployment_name"
            kubectl rollout status deployment/"$deployment_name" --timeout=600s
        fi
        
    elif [[ -f "$app_path/deployment.yaml" || -f "$app_path/deployment.yml" ]]; then
        log_info "Applying single deployment manifest"
        local manifest_file="$app_path/deployment.yaml"
        [[ -f "$app_path/deployment.yml" ]] && manifest_file="$app_path/deployment.yml"
        
        # Replace version placeholder
        sed "s/{{VERSION}}/$version/g; s/{{ENVIRONMENT}}/$environment/g" "$manifest_file" | kubectl apply -f - --record
        
    else
        log_error "No Kubernetes manifests found in $app_path"
        return 1
    fi
    
    log_success "Kubernetes rolling deployment completed"
    return 0
}

execute_kubernetes_blue_green_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    
    log_info "Executing Kubernetes blue-green deployment..."
    
    # This is a simplified implementation
    # In practice, you'd need more sophisticated traffic switching logic
    
    local current_color=$(kubectl get service app-service -o jsonpath='{.spec.selector.color}' 2>/dev/null || echo "blue")
    local new_color="green"
    [[ "$current_color" == "green" ]] && new_color="blue"
    
    log_info "Current color: $current_color, deploying to: $new_color"
    
    # Deploy new version with new color
    sed "s/{{VERSION}}/$version/g; s/{{COLOR}}/$new_color/g; s/{{ENVIRONMENT}}/$environment/g" "$app_path/k8s/deployment.yaml" | kubectl apply -f -
    
    # Wait for new deployment to be ready
    kubectl rollout status deployment/app-$new_color --timeout=600s
    
    # Switch traffic (update service selector)
    kubectl patch service app-service -p "{\"spec\":{\"selector\":{\"color\":\"$new_color\"}}}"
    
    # Clean up old deployment after a delay
    log_info "Traffic switched to $new_color. Old deployment ($current_color) can be cleaned up manually if needed."
    
    log_success "Kubernetes blue-green deployment completed"
    return 0
}

# Docker Deployment Implementation
execute_docker_rolling_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    
    log_info "Executing Docker rolling deployment..."
    
    # Check if docker-compose is available
    if command -v docker-compose &> /dev/null && [[ -f "$app_path/docker-compose.yml" ]]; then
        log_info "Using docker-compose for deployment"
        
        # Set version environment variable
        export VERSION="$version"
        export ENVIRONMENT="$environment"
        
        # Pull new images
        docker-compose -f "$app_path/docker-compose.yml" pull
        
        # Rolling update with docker-compose
        docker-compose -f "$app_path/docker-compose.yml" up -d --no-deps --scale app=2 app
        sleep 30  # Allow new containers to start
        docker-compose -f "$app_path/docker-compose.yml" up -d --no-deps --remove-orphans app
        
    elif command -v docker &> /dev/null; then
        log_info "Using Docker for deployment"
        
        # Build or pull image
        local image_name="app:$version"
        if [[ -f "$app_path/Dockerfile" ]]; then
            docker build -t "$image_name" "$app_path"
        else
            docker pull "$image_name"
        fi
        
        # Rolling update with Docker
        local container_name="app-$environment"
        
        # Start new container
        docker run -d --name "${container_name}-new" "$image_name"
        
        # Health check new container
        sleep 30
        if docker exec "${container_name}-new" curl -f http://localhost:8080/health; then
            # Stop and remove old container
            docker stop "$container_name" 2>/dev/null || true
            docker rm "$container_name" 2>/dev/null || true
            
            # Rename new container
            docker rename "${container_name}-new" "$container_name"
            
            log_success "Docker rolling deployment completed"
        else
            log_error "New container health check failed"
            docker stop "${container_name}-new" 2>/dev/null || true
            docker rm "${container_name}-new" 2>/dev/null || true
            return 1
        fi
    else
        log_error "Docker not available"
        return 1
    fi
}

# AWS Deployment Implementation
execute_aws_rolling_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    
    log_info "Executing AWS rolling deployment..."
    
    # Check for AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found"
        return 1
    fi
    
    # Determine AWS service type
    if [[ -f "$app_path/appspec.yml" ]]; then
        # AWS CodeDeploy
        execute_aws_codedeploy_deployment "$deployment_id" "$environment" "$app_path" "$version"
    elif [[ -f "$app_path/task-definition.json" ]]; then
        # ECS deployment
        execute_aws_ecs_deployment "$deployment_id" "$environment" "$app_path" "$version"
    elif [[ -f "$app_path/application.yml" || -f "$app_path/application.properties" ]]; then
        # Elastic Beanstalk
        execute_aws_beanstalk_deployment "$deployment_id" "$environment" "$app_path" "$version"
    else
        log_error "AWS deployment type not detected"
        return 1
    fi
}

execute_aws_ecs_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    
    log_info "Deploying to AWS ECS..."
    
    local task_definition_file="$app_path/task-definition.json"
    local cluster_name="${ECS_CLUSTER_NAME:-$environment}"
    local service_name="${ECS_SERVICE_NAME:-app-$environment}"
    
    # Update task definition with new image version
    local new_task_def=$(cat "$task_definition_file" | jq --arg version "$version" '
        .containerDefinitions[0].image = (.containerDefinitions[0].image | split(":")[0] + ":" + $version)
    ')
    
    # Register new task definition
    local new_task_def_arn=$(echo "$new_task_def" | aws ecs register-task-definition --cli-input-json file:///dev/stdin --query 'taskDefinition.taskDefinitionArn' --output text)
    
    if [[ -n "$new_task_def_arn" ]]; then
        log_info "Registered new task definition: $new_task_def_arn"
        
        # Update service
        aws ecs update-service --cluster "$cluster_name" --service "$service_name" --task-definition "$new_task_def_arn"
        
        # Wait for deployment to complete
        aws ecs wait services-stable --cluster "$cluster_name" --services "$service_name"
        
        log_success "ECS deployment completed"
    else
        log_error "Failed to register new task definition"
        return 1
    fi
}

# Manual Deployment Implementations
execute_manual_rolling_deployment() {
    local deployment_id="$1"
    local environment="$2"
    local app_path="$3"
    local version="$4"
    
    log_info "Executing manual rolling deployment..."
    
    # Copy application files
    if [[ -d "$app_path" ]]; then
        local app_name=$(basename "$app_path")
        local deployment_target="${DEPLOYMENT_TARGET_DIR:-/opt/applications}/$app_name-$environment"
        
        # Create new version directory
        local new_version_dir="$deployment_target-$version"
        mkdir -p "$new_version_dir"
        
        # Copy application files
        log_info "Copying application files to $new_version_dir"
        cp -r "$app_path"/* "$new_version_dir/"
        
        # Stop old version (if exists)
        local current_link="$deployment_target"
        if [[ -L "$current_link" ]]; then
            local old_version=$(readlink "$current_link")
            log_info "Stopping old version: $old_version"
            
            # Stop application (customize based on your application)
            if [[ -f "$old_version/stop.sh" ]]; then
                bash "$old_version/stop.sh"
            elif command -v systemctl &> /dev/null; then
                systemctl stop "$app_name-$environment" || true
            fi
        fi
        
        # Create/update symlink to new version
        ln -sfn "$new_version_dir" "$current_link"
        
        # Start new version
        log_info "Starting new version"
        if [[ -f "$new_version_dir/start.sh" ]]; then
            bash "$new_version_dir/start.sh"
        elif [[ -f "$new_version_dir/run.sh" ]]; then
            nohup bash "$new_version_dir/run.sh" > "$new_version_dir/app.log" 2>&1 &
        elif command -v systemctl &> /dev/null; then
            systemctl start "$app_name-$environment"
        fi
        
        log_success "Manual rolling deployment completed"
    else
        log_error "Application path is not a directory: $app_path"
        return 1
    fi
}

# Deployment Target Detection
detect_deployment_target() {
    local environment="$1"
    
    # Check environment variables first
    if [[ -n "${DEPLOYMENT_TARGET:-}" ]]; then
        echo "$DEPLOYMENT_TARGET"
        return 0
    fi
    
    # Auto-detect based on available tools and configurations
    if command -v kubectl &> /dev/null && kubectl cluster-info &>/dev/null; then
        echo "kubernetes"
    elif command -v aws &> /dev/null && aws sts get-caller-identity &>/dev/null; then
        echo "aws"
    elif command -v az &> /dev/null && az account show &>/dev/null; then
        echo "azure"
    elif command -v gcloud &> /dev/null && gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        echo "gcp"
    elif command -v docker &> /dev/null; then
        echo "docker"
    elif command -v systemctl &> /dev/null; then
        echo "systemd"
    else
        echo "manual"
    fi
}

# Health Check Functions
run_deployment_health_checks() {
    local deployment_id="$1"
    local environment="$2"
    
    log_info "Running deployment health checks..."
    
    local health_check_url="${HEALTH_CHECK_URL:-}"
    local health_check_command="${HEALTH_CHECK_COMMAND:-}"
    local max_attempts="${HEALTH_CHECK_ATTEMPTS:-$DEFAULT_HEALTH_CHECK_ATTEMPTS}"
    local check_interval="${HEALTH_CHECK_INTERVAL:-$DEFAULT_HEALTH_CHECK_INTERVAL}"
    
    local attempt=1
    local health_check_passed=false
    
    while [[ $attempt -le $max_attempts ]]; do
        log_info "Health check attempt $attempt/$max_attempts"
        
        if [[ -n "$health_check_url" ]]; then
            if curl -f -s "$health_check_url" > /dev/null; then
                health_check_passed=true
                break
            fi
        elif [[ -n "$health_check_command" ]]; then
            if eval "$health_check_command" > /dev/null 2>&1; then
                health_check_passed=true
                break
            fi
        else
            # Default health check - try to connect to common ports
            local app_ports=("8080" "80" "3000" "5000")
            for port in "${app_ports[@]}"; do
                if netstat -tln | grep -q ":$port "; then
                    health_check_passed=true
                    break 2
                fi
            done
        fi
        
        if [[ $health_check_passed == false ]]; then
            log_info "Health check failed, waiting ${check_interval}s before retry..."
            sleep "$check_interval"
            ((attempt++))
        fi
    done
    
    if [[ $health_check_passed == true ]]; then
        log_success "Health checks passed"
        
        # Update deployment state with health check results
        local state_file="${DEPLOYMENT_STATE_DIR}/${deployment_id}.json"
        if [[ -f "$state_file" ]]; then
            jq --arg timestamp "$(date -Iseconds)" \
               --arg status "passed" \
               --argjson attempt "$attempt" \
               '.health_checks += [{timestamp: $timestamp, status: $status, attempts: $attempt}]' \
               "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
        
        return 0
    else
        log_error "Health checks failed after $max_attempts attempts"
        
        # Update deployment state with health check failure
        local state_file="${DEPLOYMENT_STATE_DIR}/${deployment_id}.json"
        if [[ -f "$state_file" ]]; then
            jq --arg timestamp "$(date -Iseconds)" \
               --arg status "failed" \
               --argjson attempt "$max_attempts" \
               '.health_checks += [{timestamp: $timestamp, status: $status, attempts: $attempt}]' \
               "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
        
        return 1
    fi
}

# Backup Functions
create_deployment_backup() {
    local deployment_id="$1"
    local environment="$2"
    
    log_info "Creating deployment backup..."
    
    local backup_dir="${DEPLOYMENT_STATE_DIR}/backups"
    local backup_file="$backup_dir/backup-$deployment_id-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    mkdir -p "$backup_dir"
    
    # Backup current deployment
    local current_deployment_path="${DEPLOYMENT_TARGET_DIR:-/opt/applications}"
    
    if [[ -d "$current_deployment_path" ]]; then
        log_info "Backing up current deployment to $backup_file"
        tar -czf "$backup_file" -C "$(dirname "$current_deployment_path")" "$(basename "$current_deployment_path")" 2>/dev/null || {
            log_warning "Backup creation failed, but continuing deployment"
            return 0  # Don't fail deployment for backup issues
        }
        
        log_success "Backup created successfully: $backup_file"
        
        # Store backup info in deployment state
        local state_file="${DEPLOYMENT_STATE_DIR}/${deployment_id}.json"
        if [[ -f "$state_file" ]]; then
            jq --arg backup_file "$backup_file" \
               --arg backup_timestamp "$(date -Iseconds)" \
               '.rollback_info.backup_file = $backup_file | .rollback_info.backup_timestamp = $backup_timestamp' \
               "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
        fi
    else
        log_info "No existing deployment found to backup"
    fi
    
    return 0
}

# Rollback Functions
rollback_deployment() {
    local deployment_id="$1"
    local environment="$2"
    
    log_info "Rolling back deployment: $deployment_id"
    
    local state_file="${DEPLOYMENT_STATE_DIR}/${deployment_id}.json"
    
    if [[ ! -f "$state_file" ]]; then
        log_error "Deployment state file not found: $state_file"
        return 1
    fi
    
    # Get backup information
    local backup_file=$(jq -r '.rollback_info.backup_file // empty' "$state_file")
    
    if [[ -n "$backup_file" && -f "$backup_file" ]]; then
        log_info "Restoring from backup: $backup_file"
        
        local current_deployment_path="${DEPLOYMENT_TARGET_DIR:-/opt/applications}"
        local temp_restore_dir="${DEPLOYMENT_TEMP_DIR}/restore"
        
        mkdir -p "$temp_restore_dir"
        
        # Extract backup
        tar -xzf "$backup_file" -C "$temp_restore_dir"
        
        # Stop current deployment
        log_info "Stopping current deployment"
        # Add service-specific stop commands here
        
        # Restore backup
        rm -rf "$current_deployment_path"
        mv "$temp_restore_dir"/* "$current_deployment_path"
        
        # Start restored deployment
        log_info "Starting restored deployment"
        # Add service-specific start commands here
        
        log_success "Rollback completed successfully"
        
        # Update deployment state
        update_deployment_state "$deployment_id" "rolled_back" "Deployment rolled back successfully"
        
    else
        log_error "No backup file found for rollback"
        return 1
    fi
}

# Notification Functions
send_deployment_notifications() {
    local deployment_id="$1"
    local environment="$2"
    local deployment_exit_code="$3"
    
    local notification_title=""
    local notification_status=""
    local notification_color=""
    
    if [[ $deployment_exit_code -eq 0 ]]; then
        notification_title="✅ Deployment Successful"
        notification_status="success"
        notification_color="good"
    else
        notification_title="❌ Deployment Failed"
        notification_status="failure"
        notification_color="danger"
    fi
    
    # Send to various notification channels
    if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
        send_slack_notification "$deployment_id" "$environment" "$notification_title" "$notification_status" "$notification_color"
    fi
    
    if [[ -n "${TEAMS_WEBHOOK_URL:-}" ]]; then
        send_teams_notification "$deployment_id" "$environment" "$notification_title" "$notification_status" "$notification_color"
    fi
    
    if [[ -n "${EMAIL_RECIPIENTS:-}" ]]; then
        send_email_notification "$deployment_id" "$environment" "$notification_title" "$notification_status"
    fi
}

send_slack_notification() {
    local deployment_id="$1"
    local environment="$2"
    local title="$3"
    local status="$4"
    local color="$5"
    
    local payload=$(cat << EOF
{
  "text": "$title",
  "attachments": [
    {
      "color": "$color",
      "fields": [
        {
          "title": "Environment",
          "value": "$environment",
          "short": true
        },
        {
          "title": "Deployment ID",
          "value": "$deployment_id",
          "short": true
        },
        {
          "title": "Status",
          "value": "$status",
          "short": true
        },
        {
          "title": "Timestamp",
          "value": "$(date -Iseconds)",
          "short": true
        }
      ]
    }
  ]
}
EOF
    )
    
    curl -X POST "${SLACK_WEBHOOK_URL}" \
         -H 'Content-type: application/json' \
         -d "$payload" \
         --silent > /dev/null || log_warning "Failed to send Slack notification"
}

# Cleanup Functions
cleanup_old_deployments() {
    local environment="$1"
    local retention_days="${DEPLOYMENT_RETENTION_DAYS:-7}"
    
    log_info "Cleaning up deployments older than $retention_days days..."
    
    # Clean up old backup files
    local backup_dir="${DEPLOYMENT_STATE_DIR}/backups"
    if [[ -d "$backup_dir" ]]; then
        find "$backup_dir" -name "backup-*.tar.gz" -mtime +$retention_days -delete 2>/dev/null || true
    fi
    
    # Clean up old deployment state files
    if [[ -d "$DEPLOYMENT_STATE_DIR" ]]; then
        find "$DEPLOYMENT_STATE_DIR" -name "deploy-*.json" -mtime +$retention_days -delete 2>/dev/null || true
    fi
    
    # Clean up old log files
    if [[ -d "$DEPLOYMENT_LOGS_DIR" ]]; then
        find "$DEPLOYMENT_LOGS_DIR" -name "*.log" -mtime +$retention_days -delete 2>/dev/null || true
    fi
    
    log_info "Old deployment cleanup completed"
}

cleanup_deployment() {
    log_info "Cleaning up deployment artifacts..."
    
    # Remove temporary directory
    if [[ -d "$DEPLOYMENT_TEMP_DIR" ]]; then
        rm -rf "$DEPLOYMENT_TEMP_DIR"
        log_info "Temporary directory removed: $DEPLOYMENT_TEMP_DIR"
    fi
    
    log_success "Deployment cleanup completed"
}

# Export functions for external usage
export -f setup_deployment_environment
export -f deploy_application
export -f rollback_deployment
export -f run_deployment_health_checks
export -f create_deployment_backup
export -f cleanup_deployment

# Signal handling for cleanup
trap cleanup_deployment EXIT INT TERM

# Main execution if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        "setup")
            setup_deployment_environment
            ;;
        "deploy")
            shift
            deploy_application "$@"
            ;;
        "rollback")
            shift
            rollback_deployment "$@"
            ;;
        "health-check")
            shift
            run_deployment_health_checks "$@"
            ;;
        "backup")
            shift
            create_deployment_backup "$@"
            ;;
        "cleanup")
            cleanup_deployment
            ;;
        "help"|*)
            echo "Usage: $0 {setup|deploy|rollback|health-check|backup|cleanup|help}"
            echo "  setup                                          - Setup deployment environment"
            echo "  deploy <env> <app_path> <version> [strategy]   - Deploy application"
            echo "  rollback <deployment_id> <env>                 - Rollback deployment"
            echo "  health-check <deployment_id> <env>             - Run health checks"
            echo "  backup <deployment_id> <env>                   - Create deployment backup"
            echo "  cleanup                                        - Clean up artifacts"
            echo "  help                                           - Show this help message"
            ;;
    esac
fi