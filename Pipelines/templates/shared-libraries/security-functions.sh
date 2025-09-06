#!/bin/bash
#
# Security Functions Library
# Comprehensive shared security functions for CI/CD pipelines
# Version: 2.1.0
# Compatible with: GitHub Actions, Azure DevOps, GitLab CI, Jenkins
#
# Usage:
#   source security-functions.sh
#   setup_security_environment
#   run_security_scan "sast" "/path/to/source"
#

set -euo pipefail

# Global Configuration
SECURITY_FUNCTIONS_VERSION="2.1.0"
SECURITY_TEMP_DIR="${TMPDIR:-/tmp}/security-scan-$$"
SECURITY_RESULTS_DIR="security-results"
SECURITY_TOOLS_DIR="security-tools"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "[DEBUG] $*" >&2
    fi
}

# Security Environment Setup
setup_security_environment() {
    local setup_start_time=$(date +%s)
    
    log_info "Setting up security scanning environment (v${SECURITY_FUNCTIONS_VERSION})"
    
    # Create necessary directories
    mkdir -p "${SECURITY_RESULTS_DIR}" "${SECURITY_TOOLS_DIR}" "${SECURITY_TEMP_DIR}"
    
    # Set permissions
    chmod 700 "${SECURITY_TEMP_DIR}"
    
    # Initialize results manifest
    cat > "${SECURITY_RESULTS_DIR}/manifest.json" << EOF
{
  "scan_session": "$(date +%Y%m%d-%H%M%S)",
  "timestamp": "$(date -Iseconds)",
  "version": "${SECURITY_FUNCTIONS_VERSION}",
  "tools": {},
  "scans": [],
  "environment": {
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "shell": "${SHELL}",
    "user": "${USER:-unknown}",
    "pwd": "$(pwd)"
  }
}
EOF
    
    # Check required system tools
    check_system_requirements
    
    local setup_duration=$(($(date +%s) - setup_start_time))
    log_success "Security environment setup completed in ${setup_duration}s"
}

# System Requirements Check
check_system_requirements() {
    log_info "Checking system requirements..."
    
    local required_tools=("curl" "jq" "tar" "unzip")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Attempting to install missing tools..."
        install_system_tools "${missing_tools[@]}"
    fi
}

# Install System Tools
install_system_tools() {
    local tools=("$@")
    
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update -qq
        sudo apt-get install -y "${tools[@]}"
    elif command -v yum &> /dev/null; then
        # RHEL/CentOS
        sudo yum install -y "${tools[@]}"
    elif command -v brew &> /dev/null; then
        # macOS
        brew install "${tools[@]}"
    elif command -v apk &> /dev/null; then
        # Alpine
        sudo apk add --no-cache "${tools[@]}"
    else
        log_error "Package manager not found. Please install manually: ${tools[*]}"
        return 1
    fi
}

# Tool Installation Functions
install_security_tool() {
    local tool_name="$1"
    local version="${2:-latest}"
    local force_install="${3:-false}"
    
    log_info "Installing security tool: ${tool_name} (${version})"
    
    case "$tool_name" in
        "trivy")
            install_trivy "$version" "$force_install"
            ;;
        "checkov")
            install_checkov "$version" "$force_install"
            ;;
        "gitleaks")
            install_gitleaks "$version" "$force_install"
            ;;
        "bandit")
            install_bandit "$version" "$force_install"
            ;;
        "safety")
            install_safety "$version" "$force_install"
            ;;
        "semgrep")
            install_semgrep "$version" "$force_install"
            ;;
        "snyk")
            install_snyk "$version" "$force_install"
            ;;
        "grype")
            install_grype "$version" "$force_install"
            ;;
        "syft")
            install_syft "$version" "$force_install"
            ;;
        *)
            log_error "Unknown security tool: $tool_name"
            return 1
            ;;
    esac
}

install_trivy() {
    local version="$1"
    local force_install="$2"
    local tool_path="${SECURITY_TOOLS_DIR}/trivy"
    
    if [[ -x "$tool_path" && "$force_install" != "true" ]]; then
        log_info "Trivy already installed, skipping..."
        return 0
    fi
    
    local os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    local arch="$(uname -m)"
    
    # Map architecture names
    case "$arch" in
        x86_64) arch="64bit" ;;
        aarch64|arm64) arch="ARM64" ;;
        *) log_error "Unsupported architecture: $arch"; return 1 ;;
    esac
    
    local download_url
    if [[ "$version" == "latest" ]]; then
        download_url="https://github.com/aquasecurity/trivy/releases/latest/download/trivy_${os^}-${arch}.tar.gz"
    else
        download_url="https://github.com/aquasecurity/trivy/releases/download/v${version}/trivy_${os^}-${arch}.tar.gz"
    fi
    
    log_info "Downloading Trivy from: $download_url"
    
    local temp_file="${SECURITY_TEMP_DIR}/trivy.tar.gz"
    if curl -sL "$download_url" -o "$temp_file"; then
        tar -xzf "$temp_file" -C "${SECURITY_TEMP_DIR}"
        mv "${SECURITY_TEMP_DIR}/trivy" "$tool_path"
        chmod +x "$tool_path"
        log_success "Trivy installed successfully"
    else
        log_error "Failed to download Trivy"
        return 1
    fi
}

install_checkov() {
    local version="$1"
    local force_install="$2"
    
    if command -v checkov &> /dev/null && [[ "$force_install" != "true" ]]; then
        log_info "Checkov already installed, skipping..."
        return 0
    fi
    
    log_info "Installing Checkov via pip..."
    if [[ "$version" == "latest" ]]; then
        pip3 install --user checkov
    else
        pip3 install --user "checkov==$version"
    fi
    
    log_success "Checkov installed successfully"
}

install_gitleaks() {
    local version="$1"
    local force_install="$2"
    local tool_path="${SECURITY_TOOLS_DIR}/gitleaks"
    
    if [[ -x "$tool_path" && "$force_install" != "true" ]]; then
        log_info "Gitleaks already installed, skipping..."
        return 0
    fi
    
    local os="$(uname -s | tr '[:upper:]' '[:lower:]')"
    local arch="$(uname -m)"
    
    case "$arch" in
        x86_64) arch="x64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) log_error "Unsupported architecture: $arch"; return 1 ;;
    esac
    
    local download_url
    if [[ "$version" == "latest" ]]; then
        download_url="https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks_${version}_${os}_${arch}.tar.gz"
        # Get actual latest version
        version=$(curl -s https://api.github.com/repos/zricethezav/gitleaks/releases/latest | jq -r '.tag_name' | sed 's/^v//')
        download_url="https://github.com/zricethezav/gitleaks/releases/download/v${version}/gitleaks_${version}_${os}_${arch}.tar.gz"
    else
        download_url="https://github.com/zricethezav/gitleaks/releases/download/v${version}/gitleaks_${version}_${os}_${arch}.tar.gz"
    fi
    
    log_info "Downloading Gitleaks from: $download_url"
    
    local temp_file="${SECURITY_TEMP_DIR}/gitleaks.tar.gz"
    if curl -sL "$download_url" -o "$temp_file"; then
        tar -xzf "$temp_file" -C "${SECURITY_TEMP_DIR}"
        mv "${SECURITY_TEMP_DIR}/gitleaks" "$tool_path"
        chmod +x "$tool_path"
        log_success "Gitleaks installed successfully"
    else
        log_error "Failed to download Gitleaks"
        return 1
    fi
}

install_bandit() {
    local version="$1"
    local force_install="$2"
    
    if command -v bandit &> /dev/null && [[ "$force_install" != "true" ]]; then
        log_info "Bandit already installed, skipping..."
        return 0
    fi
    
    log_info "Installing Bandit via pip..."
    if [[ "$version" == "latest" ]]; then
        pip3 install --user bandit[toml]
    else
        pip3 install --user "bandit[toml]==$version"
    fi
    
    log_success "Bandit installed successfully"
}

install_safety() {
    local version="$1"
    local force_install="$2"
    
    if command -v safety &> /dev/null && [[ "$force_install" != "true" ]]; then
        log_info "Safety already installed, skipping..."
        return 0
    fi
    
    log_info "Installing Safety via pip..."
    if [[ "$version" == "latest" ]]; then
        pip3 install --user safety
    else
        pip3 install --user "safety==$version"
    fi
    
    log_success "Safety installed successfully"
}

install_semgrep() {
    local version="$1"
    local force_install="$2"
    
    if command -v semgrep &> /dev/null && [[ "$force_install" != "true" ]]; then
        log_info "Semgrep already installed, skipping..."
        return 0
    fi
    
    log_info "Installing Semgrep via pip..."
    if [[ "$version" == "latest" ]]; then
        pip3 install --user semgrep
    else
        pip3 install --user "semgrep==$version"
    fi
    
    log_success "Semgrep installed successfully"
}

install_snyk() {
    local version="$1"
    local force_install="$2"
    
    if command -v snyk &> /dev/null && [[ "$force_install" != "true" ]]; then
        log_info "Snyk already installed, skipping..."
        return 0
    fi
    
    log_info "Installing Snyk via npm..."
    if [[ "$version" == "latest" ]]; then
        npm install -g snyk
    else
        npm install -g "snyk@$version"
    fi
    
    log_success "Snyk installed successfully"
}

install_grype() {
    local version="$1"
    local force_install="$2"
    local tool_path="${SECURITY_TOOLS_DIR}/grype"
    
    if [[ -x "$tool_path" && "$force_install" != "true" ]]; then
        log_info "Grype already installed, skipping..."
        return 0
    fi
    
    log_info "Installing Grype..."
    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b "${SECURITY_TOOLS_DIR}"
    
    log_success "Grype installed successfully"
}

install_syft() {
    local version="$1"
    local force_install="$2"
    local tool_path="${SECURITY_TOOLS_DIR}/syft"
    
    if [[ -x "$tool_path" && "$force_install" != "true" ]]; then
        log_info "Syft already installed, skipping..."
        return 0
    fi
    
    log_info "Installing Syft..."
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b "${SECURITY_TOOLS_DIR}"
    
    log_success "Syft installed successfully"
}

# Main Security Scanning Function
run_security_scan() {
    local scan_type="$1"
    local target="${2:-.}"
    local output_format="${3:-sarif}"
    local config_file="${4:-}"
    
    local scan_start_time=$(date +%s)
    log_info "Starting $scan_type security scan on: $target"
    
    case "$scan_type" in
        "sast"|"static")
            run_sast_scan "$target" "$output_format" "$config_file"
            ;;
        "container"|"image")
            run_container_scan "$target" "$output_format" "$config_file"
            ;;
        "iac"|"infrastructure")
            run_iac_scan "$target" "$output_format" "$config_file"
            ;;
        "secrets")
            run_secrets_scan "$target" "$output_format" "$config_file"
            ;;
        "dependencies"|"sca")
            run_dependency_scan "$target" "$output_format" "$config_file"
            ;;
        "dast"|"dynamic")
            run_dast_scan "$target" "$output_format" "$config_file"
            ;;
        "sbom")
            generate_sbom "$target" "$output_format" "$config_file"
            ;;
        "license")
            run_license_scan "$target" "$output_format" "$config_file"
            ;;
        "all"|"comprehensive")
            run_comprehensive_scan "$target" "$output_format" "$config_file"
            ;;
        *)
            log_error "Unknown scan type: $scan_type"
            return 1
            ;;
    esac
    
    local scan_duration=$(($(date +%s) - scan_start_time))
    log_success "$scan_type scan completed in ${scan_duration}s"
    
    # Update manifest
    update_scan_manifest "$scan_type" "$target" "$scan_duration" "$?"
}

# Static Application Security Testing (SAST)
run_sast_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running SAST scan..."
    
    # Detect programming languages
    local languages=($(detect_languages "$target"))
    log_info "Detected languages: ${languages[*]}"
    
    # Run language-specific SAST tools
    for language in "${languages[@]}"; do
        case "$language" in
            "python")
                run_bandit_scan "$target" "$output_format"
                ;;
            "javascript"|"typescript"|"node")
                run_eslint_security_scan "$target" "$output_format"
                ;;
            "java")
                run_spotbugs_scan "$target" "$output_format"
                ;;
            "go")
                run_gosec_scan "$target" "$output_format"
                ;;
            "csharp")
                run_security_code_scan "$target" "$output_format"
                ;;
        esac
    done
    
    # Run multi-language tools
    if command -v semgrep &> /dev/null; then
        run_semgrep_scan "$target" "$output_format" "$config_file"
    fi
    
    # Run CodeQL if available
    if command -v codeql &> /dev/null; then
        run_codeql_scan "$target" "$output_format"
    fi
}

run_bandit_scan() {
    local target="$1"
    local output_format="$2"
    
    log_info "Running Bandit (Python SAST)..."
    
    local output_file="${SECURITY_RESULTS_DIR}/bandit-results"
    local format_arg=""
    
    case "$output_format" in
        "sarif") format_arg="-f sarif"; output_file+=".sarif" ;;
        "json") format_arg="-f json"; output_file+=".json" ;;
        "xml") format_arg="-f xml"; output_file+=".xml" ;;
        *) format_arg="-f json"; output_file+=".json" ;;
    esac
    
    if find "$target" -name "*.py" -type f | head -1 | grep -q .; then
        bandit -r "$target" $format_arg -o "$output_file" || {
            log_warning "Bandit scan completed with findings"
        }
        log_success "Bandit scan results saved to: $output_file"
    else
        log_info "No Python files found, skipping Bandit scan"
    fi
}

run_semgrep_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running Semgrep (Multi-language SAST)..."
    
    local output_file="${SECURITY_RESULTS_DIR}/semgrep-results"
    local format_arg=""
    local config_arg="--config=auto"
    
    if [[ -n "$config_file" && -f "$config_file" ]]; then
        config_arg="--config=$config_file"
    fi
    
    case "$output_format" in
        "sarif") format_arg="--sarif"; output_file+=".sarif" ;;
        "json") format_arg="--json"; output_file+=".json" ;;
        *) format_arg="--json"; output_file+=".json" ;;
    esac
    
    semgrep $config_arg $format_arg --output="$output_file" "$target" || {
        log_warning "Semgrep scan completed with findings"
    }
    log_success "Semgrep scan results saved to: $output_file"
}

# Container Security Scanning
run_container_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running container security scan..."
    
    # Check if target is an image name or Dockerfile
    if [[ -f "$target" && $(basename "$target") == "Dockerfile"* ]]; then
        # Scan Dockerfile
        scan_dockerfile "$target" "$output_format"
    elif [[ "$target" =~ ^[a-zA-Z0-9].*:.* ]] || docker image inspect "$target" &>/dev/null; then
        # Scan container image
        scan_container_image "$target" "$output_format"
    else
        # Look for Dockerfiles
        local dockerfiles=($(find "$target" -name "Dockerfile*" -type f))
        if [[ ${#dockerfiles[@]} -gt 0 ]]; then
            for dockerfile in "${dockerfiles[@]}"; do
                scan_dockerfile "$dockerfile" "$output_format"
            done
        else
            log_warning "No container images or Dockerfiles found"
        fi
    fi
}

scan_dockerfile() {
    local dockerfile="$1"
    local output_format="$2"
    
    log_info "Scanning Dockerfile: $dockerfile"
    
    local tool_path="${SECURITY_TOOLS_DIR}/trivy"
    local output_file="${SECURITY_RESULTS_DIR}/dockerfile-$(basename "$dockerfile")"
    local format_arg=""
    
    case "$output_format" in
        "sarif") format_arg="--format sarif"; output_file+=".sarif" ;;
        "json") format_arg="--format json"; output_file+=".json" ;;
        *) format_arg="--format json"; output_file+=".json" ;;
    esac
    
    "$tool_path" config $format_arg --output "$output_file" "$dockerfile" || {
        log_warning "Dockerfile scan completed with findings"
    }
    log_success "Dockerfile scan results saved to: $output_file"
}

scan_container_image() {
    local image="$1"
    local output_format="$2"
    
    log_info "Scanning container image: $image"
    
    local tool_path="${SECURITY_TOOLS_DIR}/trivy"
    local output_file="${SECURITY_RESULTS_DIR}/container-$(echo "$image" | tr '/:' '-')"
    local format_arg=""
    
    case "$output_format" in
        "sarif") format_arg="--format sarif"; output_file+=".sarif" ;;
        "json") format_arg="--format json"; output_file+=".json" ;;
        *) format_arg="--format json"; output_file+=".json" ;;
    esac
    
    "$tool_path" image $format_arg --output "$output_file" "$image" || {
        log_warning "Container image scan completed with findings"
    }
    log_success "Container image scan results saved to: $output_file"
}

# Infrastructure as Code (IaC) Scanning
run_iac_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running Infrastructure as Code scan..."
    
    # Run Checkov
    if command -v checkov &> /dev/null; then
        run_checkov_scan "$target" "$output_format" "$config_file"
    fi
    
    # Run Trivy for IaC
    if [[ -x "${SECURITY_TOOLS_DIR}/trivy" ]]; then
        run_trivy_iac_scan "$target" "$output_format"
    fi
    
    # Run TFSec for Terraform
    if find "$target" -name "*.tf" -type f | head -1 | grep -q .; then
        run_tfsec_scan "$target" "$output_format"
    fi
}

run_checkov_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running Checkov (IaC Security)..."
    
    local output_file="${SECURITY_RESULTS_DIR}/checkov-results"
    local format_arg=""
    local config_arg=""
    
    if [[ -n "$config_file" && -f "$config_file" ]]; then
        config_arg="--config-file $config_file"
    fi
    
    case "$output_format" in
        "sarif") format_arg="--output sarif"; output_file+=".sarif" ;;
        "json") format_arg="--output json"; output_file+=".json" ;;
        "xml") format_arg="--output xml"; output_file+=".xml" ;;
        *) format_arg="--output json"; output_file+=".json" ;;
    esac
    
    checkov --directory "$target" $format_arg --output-file "$output_file" $config_arg || {
        log_warning "Checkov scan completed with findings"
    }
    log_success "Checkov scan results saved to: $output_file"
}

run_trivy_iac_scan() {
    local target="$1"
    local output_format="$2"
    
    log_info "Running Trivy IaC scan..."
    
    local tool_path="${SECURITY_TOOLS_DIR}/trivy"
    local output_file="${SECURITY_RESULTS_DIR}/trivy-iac-results"
    local format_arg=""
    
    case "$output_format" in
        "sarif") format_arg="--format sarif"; output_file+=".sarif" ;;
        "json") format_arg="--format json"; output_file+=".json" ;;
        *) format_arg="--format json"; output_file+=".json" ;;
    esac
    
    "$tool_path" config $format_arg --output "$output_file" "$target" || {
        log_warning "Trivy IaC scan completed with findings"
    }
    log_success "Trivy IaC scan results saved to: $output_file"
}

# Secrets Scanning
run_secrets_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running secrets scan..."
    
    # Run Gitleaks
    if [[ -x "${SECURITY_TOOLS_DIR}/gitleaks" ]]; then
        run_gitleaks_scan "$target" "$output_format" "$config_file"
    fi
    
    # Run TruffleHog if available
    if command -v trufflehog &> /dev/null; then
        run_trufflehog_scan "$target" "$output_format"
    fi
    
    # Run detect-secrets if available
    if command -v detect-secrets &> /dev/null; then
        run_detect_secrets_scan "$target" "$output_format"
    fi
}

run_gitleaks_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running Gitleaks (Secrets Detection)..."
    
    local tool_path="${SECURITY_TOOLS_DIR}/gitleaks"
    local output_file="${SECURITY_RESULTS_DIR}/gitleaks-results"
    local format_arg="--report-format json"
    local config_arg=""
    
    if [[ -n "$config_file" && -f "$config_file" ]]; then
        config_arg="--config $config_file"
    fi
    
    case "$output_format" in
        "sarif") format_arg="--report-format sarif"; output_file+=".sarif" ;;
        "json") format_arg="--report-format json"; output_file+=".json" ;;
        *) format_arg="--report-format json"; output_file+=".json" ;;
    esac
    
    "$tool_path" detect --source "$target" $format_arg --report-path "$output_file" $config_arg || {
        log_warning "Gitleaks scan completed with findings"
    }
    log_success "Gitleaks scan results saved to: $output_file"
}

# Dependency Scanning
run_dependency_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running dependency security scan..."
    
    # Detect package managers and run appropriate scans
    local package_files=($(find "$target" -name "package.json" -o -name "requirements.txt" -o -name "Gemfile" -o -name "pom.xml" -o -name "go.mod" -o -name "Cargo.toml" -o -name "composer.json"))
    
    if [[ ${#package_files[@]} -eq 0 ]]; then
        log_warning "No dependency files found"
        return 0
    fi
    
    for package_file in "${package_files[@]}"; do
        local package_dir="$(dirname "$package_file")"
        local package_type="$(basename "$package_file")"
        
        case "$package_type" in
            "package.json")
                run_npm_audit "$package_dir" "$output_format"
                ;;
            "requirements.txt")
                run_safety_scan "$package_dir" "$output_format"
                ;;
            "Gemfile")
                run_bundle_audit "$package_dir" "$output_format"
                ;;
            "pom.xml")
                run_owasp_dependency_check "$package_dir" "$output_format"
                ;;
            "go.mod")
                run_nancy_scan "$package_dir" "$output_format"
                ;;
            "Cargo.toml")
                run_cargo_audit "$package_dir" "$output_format"
                ;;
            "composer.json")
                run_composer_audit "$package_dir" "$output_format"
                ;;
        esac
    done
    
    # Run Trivy for comprehensive dependency scanning
    if [[ -x "${SECURITY_TOOLS_DIR}/trivy" ]]; then
        run_trivy_dependency_scan "$target" "$output_format"
    fi
}

run_npm_audit() {
    local package_dir="$1"
    local output_format="$2"
    
    if [[ ! -f "$package_dir/package.json" ]]; then
        return 0
    fi
    
    log_info "Running npm audit in: $package_dir"
    
    local output_file="${SECURITY_RESULTS_DIR}/npm-audit-$(basename "$package_dir").json"
    
    pushd "$package_dir" > /dev/null
    npm audit --json > "$output_file" 2>/dev/null || {
        log_warning "npm audit completed with findings"
    }
    popd > /dev/null
    
    log_success "npm audit results saved to: $output_file"
}

run_safety_scan() {
    local package_dir="$1"
    local output_format="$2"
    
    if [[ ! -f "$package_dir/requirements.txt" ]]; then
        return 0
    fi
    
    log_info "Running Safety scan in: $package_dir"
    
    local output_file="${SECURITY_RESULTS_DIR}/safety-$(basename "$package_dir").json"
    
    pushd "$package_dir" > /dev/null
    safety check --json --output "$output_file" || {
        log_warning "Safety scan completed with findings"
    }
    popd > /dev/null
    
    log_success "Safety scan results saved to: $output_file"
}

run_trivy_dependency_scan() {
    local target="$1"
    local output_format="$2"
    
    log_info "Running Trivy dependency scan..."
    
    local tool_path="${SECURITY_TOOLS_DIR}/trivy"
    local output_file="${SECURITY_RESULTS_DIR}/trivy-dependencies"
    local format_arg=""
    
    case "$output_format" in
        "sarif") format_arg="--format sarif"; output_file+=".sarif" ;;
        "json") format_arg="--format json"; output_file+=".json" ;;
        *) format_arg="--format json"; output_file+=".json" ;;
    esac
    
    "$tool_path" fs $format_arg --output "$output_file" "$target" || {
        log_warning "Trivy dependency scan completed with findings"
    }
    log_success "Trivy dependency scan results saved to: $output_file"
}

# Software Bill of Materials (SBOM) Generation
generate_sbom() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Generating Software Bill of Materials (SBOM)..."
    
    local tool_path="${SECURITY_TOOLS_DIR}/syft"
    local output_file="${SECURITY_RESULTS_DIR}/sbom"
    local format_arg=""
    
    case "$output_format" in
        "spdx-json") format_arg="--output spdx-json"; output_file+=".spdx.json" ;;
        "cyclonedx-json") format_arg="--output cyclonedx-json"; output_file+=".cyclonedx.json" ;;
        "syft-json") format_arg="--output syft-json"; output_file+=".syft.json" ;;
        *) format_arg="--output spdx-json"; output_file+=".spdx.json" ;;
    esac
    
    "$tool_path" "$target" $format_arg="$output_file" || {
        log_error "SBOM generation failed"
        return 1
    }
    
    log_success "SBOM generated: $output_file"
}

# License Scanning
run_license_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running license compliance scan..."
    
    # Use FOSSA if available
    if command -v fossa &> /dev/null; then
        run_fossa_scan "$target" "$output_format"
    fi
    
    # Use License Finder if available
    if command -v license_finder &> /dev/null; then
        run_license_finder_scan "$target" "$output_format"
    fi
    
    # Extract licenses from SBOM if available
    if [[ -f "${SECURITY_RESULTS_DIR}/sbom.spdx.json" ]]; then
        extract_licenses_from_sbom "${SECURITY_RESULTS_DIR}/sbom.spdx.json" "$output_format"
    fi
}

# Comprehensive Security Scan
run_comprehensive_scan() {
    local target="$1"
    local output_format="$2"
    local config_file="$3"
    
    log_info "Running comprehensive security scan..."
    
    # Run all scan types
    local scan_types=("sast" "iac" "secrets" "dependencies" "sbom" "license")
    
    for scan_type in "${scan_types[@]}"; do
        log_info "Running $scan_type scan as part of comprehensive scan..."
        run_security_scan "$scan_type" "$target" "$output_format" "$config_file" || {
            log_warning "$scan_type scan failed, continuing with other scans..."
        }
    done
    
    # Generate comprehensive report
    generate_comprehensive_report "$output_format"
}

# Utility Functions
detect_languages() {
    local target="$1"
    local languages=()
    
    # Check for various language files
    if find "$target" -name "*.py" -type f | head -1 | grep -q .; then
        languages+=("python")
    fi
    
    if find "$target" -name "*.js" -o -name "*.ts" -o -name "package.json" -type f | head -1 | grep -q .; then
        languages+=("javascript")
    fi
    
    if find "$target" -name "*.java" -type f | head -1 | grep -q .; then
        languages+=("java")
    fi
    
    if find "$target" -name "*.go" -type f | head -1 | grep -q .; then
        languages+=("go")
    fi
    
    if find "$target" -name "*.cs" -type f | head -1 | grep -q .; then
        languages+=("csharp")
    fi
    
    if find "$target" -name "*.rb" -type f | head -1 | grep -q .; then
        languages+=("ruby")
    fi
    
    if find "$target" -name "*.php" -type f | head -1 | grep -q .; then
        languages+=("php")
    fi
    
    echo "${languages[@]}"
}

update_scan_manifest() {
    local scan_type="$1"
    local target="$2"
    local duration="$3"
    local exit_code="$4"
    
    local temp_manifest="${SECURITY_TEMP_DIR}/manifest_update.json"
    local manifest_file="${SECURITY_RESULTS_DIR}/manifest.json"
    
    # Create scan entry
    cat > "$temp_manifest" << EOF
{
  "type": "$scan_type",
  "target": "$target",
  "duration": $duration,
  "exit_code": $exit_code,
  "timestamp": "$(date -Iseconds)",
  "status": "$(if [[ $exit_code -eq 0 ]]; then echo "success"; else echo "failed"; fi)"
}
EOF
    
    # Update main manifest
    jq --argjson scan "$(cat "$temp_manifest")" '.scans += [$scan]' "$manifest_file" > "${manifest_file}.tmp" && mv "${manifest_file}.tmp" "$manifest_file"
}

generate_comprehensive_report() {
    local output_format="$1"
    
    log_info "Generating comprehensive security report..."
    
    local report_file="${SECURITY_RESULTS_DIR}/comprehensive-report.json"
    
    # Aggregate all scan results
    python3 << EOF
import json
import glob
import os
from datetime import datetime

report = {
    "metadata": {
        "generated_at": datetime.utcnow().isoformat(),
        "scan_session": "$(jq -r '.scan_session' "${SECURITY_RESULTS_DIR}/manifest.json")",
        "version": "${SECURITY_FUNCTIONS_VERSION}"
    },
    "summary": {
        "total_scans": 0,
        "successful_scans": 0,
        "failed_scans": 0,
        "total_findings": 0,
        "critical_findings": 0,
        "high_findings": 0,
        "medium_findings": 0,
        "low_findings": 0
    },
    "scan_results": {}
}

# Load manifest
try:
    with open("${SECURITY_RESULTS_DIR}/manifest.json", 'r') as f:
        manifest = json.load(f)
    
    report["summary"]["total_scans"] = len(manifest.get("scans", []))
    
    for scan in manifest.get("scans", []):
        if scan.get("status") == "success":
            report["summary"]["successful_scans"] += 1
        else:
            report["summary"]["failed_scans"] += 1
except:
    pass

# Process result files
result_files = glob.glob("${SECURITY_RESULTS_DIR}/*-results.*")

for result_file in result_files:
    try:
        with open(result_file, 'r') as f:
            if result_file.endswith('.json'):
                data = json.load(f)
                # Count findings based on file structure
                # This would need to be customized based on actual tool outputs
                
            elif result_file.endswith('.sarif'):
                data = json.load(f)
                # Process SARIF format
                for run in data.get("runs", []):
                    for result in run.get("results", []):
                        report["summary"]["total_findings"] += 1
                        level = result.get("level", "info")
                        if level == "error":
                            severity = result.get("properties", {}).get("severity", "medium")
                            if severity == "critical":
                                report["summary"]["critical_findings"] += 1
                            elif severity == "high":
                                report["summary"]["high_findings"] += 1
                            else:
                                report["summary"]["medium_findings"] += 1
                        else:
                            report["summary"]["low_findings"] += 1
    except Exception as e:
        print(f"Error processing {result_file}: {e}")

# Save comprehensive report
with open("$report_file", 'w') as f:
    json.dump(report, f, indent=2)

print("Comprehensive security report generated")
EOF
    
    log_success "Comprehensive report saved to: $report_file"
}

# Security Score Calculation
calculate_security_score() {
    local report_file="${SECURITY_RESULTS_DIR}/comprehensive-report.json"
    
    if [[ ! -f "$report_file" ]]; then
        log_error "Comprehensive report not found. Run comprehensive scan first."
        return 1
    fi
    
    local security_score=$(python3 << EOF
import json

try:
    with open("$report_file", 'r') as f:
        report = json.load(f)
    
    summary = report.get("summary", {})
    
    # Calculate security score (0-100)
    critical = summary.get("critical_findings", 0)
    high = summary.get("high_findings", 0)  
    medium = summary.get("medium_findings", 0)
    low = summary.get("low_findings", 0)
    
    # Weighted scoring
    penalty = (critical * 10) + (high * 5) + (medium * 2) + (low * 0.5)
    
    # Base score of 100, subtract penalties
    score = max(0, 100 - penalty)
    
    print(f"{score:.1f}")
    
except Exception as e:
    print("0.0")
EOF
    )
    
    echo "$security_score"
}

# Result Processing and Filtering
filter_security_results() {
    local severity_threshold="${1:-medium}"
    local result_file="$2"
    local filtered_file="${result_file%.json}-filtered.json"
    
    log_info "Filtering security results by severity: $severity_threshold"
    
    python3 << EOF
import json

severity_levels = {"info": 0, "low": 1, "medium": 2, "high": 3, "critical": 4}
threshold = severity_levels.get("$severity_threshold", 2)

try:
    with open("$result_file", 'r') as f:
        data = json.load(f)
    
    if "runs" in data:  # SARIF format
        for run in data["runs"]:
            filtered_results = []
            for result in run.get("results", []):
                severity = result.get("properties", {}).get("severity", "medium")
                if severity_levels.get(severity, 2) >= threshold:
                    filtered_results.append(result)
            run["results"] = filtered_results
    
    with open("$filtered_file", 'w') as f:
        json.dump(data, f, indent=2)
    
    print("Filtered results saved to: $filtered_file")

except Exception as e:
    print(f"Error filtering results: {e}")
EOF
}

# Cleanup Function
cleanup_security_scan() {
    log_info "Cleaning up security scan artifacts..."
    
    # Remove temporary directory
    if [[ -d "$SECURITY_TEMP_DIR" ]]; then
        rm -rf "$SECURITY_TEMP_DIR"
        log_info "Temporary directory removed: $SECURITY_TEMP_DIR"
    fi
    
    # Optionally remove tools directory
    if [[ "${CLEANUP_TOOLS:-false}" == "true" && -d "$SECURITY_TOOLS_DIR" ]]; then
        rm -rf "$SECURITY_TOOLS_DIR"
        log_info "Tools directory removed: $SECURITY_TOOLS_DIR"
    fi
    
    log_success "Cleanup completed"
}

# Signal handling for cleanup
trap cleanup_security_scan EXIT INT TERM

# Export functions for external usage
export -f setup_security_environment
export -f run_security_scan
export -f install_security_tool
export -f calculate_security_score
export -f filter_security_results
export -f cleanup_security_scan

# Main execution if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        "setup")
            setup_security_environment
            ;;
        "scan")
            shift
            run_security_scan "$@"
            ;;
        "install")
            shift
            install_security_tool "$@"
            ;;
        "score")
            calculate_security_score
            ;;
        "cleanup")
            cleanup_security_scan
            ;;
        "help"|*)
            echo "Usage: $0 {setup|scan|install|score|cleanup|help}"
            echo "  setup                           - Setup security environment"
            echo "  scan <type> <target> [format]   - Run security scan"
            echo "  install <tool> [version]        - Install security tool"
            echo "  score                           - Calculate security score"
            echo "  cleanup                         - Clean up artifacts"
            echo "  help                            - Show this help message"
            ;;
    esac
fi