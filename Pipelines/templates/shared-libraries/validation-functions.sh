#!/bin/bash
#
# Validation Functions Library
# Comprehensive shared validation and testing functions for CI/CD pipelines
# Version: 2.0.0
# Compatible with: GitHub Actions, Azure DevOps, GitLab CI, Jenkins
#
# Usage:
#   source validation-functions.sh
#   setup_validation_environment
#   run_tests "unit" "/path/to/project"
#   validate_deployment "production" "https://app.example.com"
#

set -euo pipefail

# Global Configuration
VALIDATION_FUNCTIONS_VERSION="2.0.0"
VALIDATION_TEMP_DIR="${TMPDIR:-/tmp}/validation-$$"
VALIDATION_RESULTS_DIR="validation-results"
VALIDATION_REPORTS_DIR="validation-reports"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Default Configuration
DEFAULT_TEST_TIMEOUT=300
DEFAULT_PERFORMANCE_TIMEOUT=600
DEFAULT_LOAD_TEST_DURATION=300
DEFAULT_COVERAGE_THRESHOLD=80
DEFAULT_PERFORMANCE_BASELINE_DEVIATION=20

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${VALIDATION_RESULTS_DIR}/validation.log"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${VALIDATION_RESULTS_DIR}/validation.log"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${VALIDATION_RESULTS_DIR}/validation.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${VALIDATION_RESULTS_DIR}/validation.log"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${VALIDATION_RESULTS_DIR}/validation.log"
    fi
}

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${VALIDATION_RESULTS_DIR}/validation.log"
}

# Validation Environment Setup
setup_validation_environment() {
    local setup_start_time=$(date +%s)
    
    log_info "Setting up validation environment (v${VALIDATION_FUNCTIONS_VERSION})"
    
    # Create necessary directories
    mkdir -p "${VALIDATION_RESULTS_DIR}" "${VALIDATION_REPORTS_DIR}" "${VALIDATION_TEMP_DIR}"
    
    # Set permissions
    chmod 700 "${VALIDATION_TEMP_DIR}"
    
    # Initialize validation session
    cat > "${VALIDATION_RESULTS_DIR}/validation-session.json" << EOF
{
  "session_id": "$(date +%Y%m%d-%H%M%S)-$$",
  "started_at": "$(date -Iseconds)",
  "version": "${VALIDATION_FUNCTIONS_VERSION}",
  "environment": {
    "os": "$(uname -s)",
    "arch": "$(uname -m)",
    "shell": "${SHELL}",
    "user": "${USER:-unknown}",
    "pwd": "$(pwd)",
    "hostname": "$(hostname)"
  },
  "validations": [],
  "summary": {
    "total_validations": 0,
    "passed_validations": 0,
    "failed_validations": 0,
    "skipped_validations": 0
  }
}
EOF
    
    # Check system requirements
    check_validation_requirements
    
    local setup_duration=$(($(date +%s) - setup_start_time))
    log_success "Validation environment setup completed in ${setup_duration}s"
}

# Check Validation Requirements
check_validation_requirements() {
    log_info "Checking validation requirements..."
    
    local required_tools=("curl" "jq")
    local optional_tools=("python3" "node" "npm" "mvn" "gradle" "go" "dotnet")
    local missing_required=()
    local missing_optional=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_required+=("$tool")
        fi
    done
    
    for tool in "${optional_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_optional+=("$tool")
        fi
    done
    
    if [[ ${#missing_required[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_required[*]}"
        return 1
    fi
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        log_info "Missing optional tools (some validations may be skipped): ${missing_optional[*]}"
    fi
    
    log_success "Validation requirements check completed"
}

# Main Test Runner
run_tests() {
    local test_type="$1"
    local project_path="${2:-.}"
    local test_config="${3:-}"
    local output_format="${4:-junit}"
    
    local test_start_time=$(date +%s)
    local test_id="test-$(date +%Y%m%d-%H%M%S)-$$"
    
    log_test "Starting $test_type tests: $test_id"
    log_test "Project Path: $project_path"
    log_test "Output Format: $output_format"
    
    # Initialize test state
    init_test_state "$test_id" "$test_type" "$project_path" "$output_format"
    
    case "$test_type" in
        "unit")
            run_unit_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "integration")
            run_integration_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "e2e"|"end-to-end")
            run_e2e_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "performance"|"load")
            run_performance_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "smoke")
            run_smoke_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "regression")
            run_regression_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "api")
            run_api_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "ui"|"frontend")
            run_ui_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "accessibility"|"a11y")
            run_accessibility_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        "all"|"comprehensive")
            run_comprehensive_tests "$test_id" "$project_path" "$test_config" "$output_format"
            ;;
        *)
            log_error "Unknown test type: $test_type"
            return 1
            ;;
    esac
    
    local test_exit_code=$?
    local test_duration=$(($(date +%s) - test_start_time))
    
    # Generate test summary
    generate_test_summary "$test_id" "$test_type" "$test_duration" "$test_exit_code"
    
    if [[ $test_exit_code -eq 0 ]]; then
        log_success "Tests completed successfully in ${test_duration}s"
    else
        log_error "Tests failed after ${test_duration}s"
    fi
    
    return $test_exit_code
}

# Initialize Test State
init_test_state() {
    local test_id="$1"
    local test_type="$2"
    local project_path="$3"
    local output_format="$4"
    
    local state_file="${VALIDATION_RESULTS_DIR}/${test_id}.json"
    
    cat > "$state_file" << EOF
{
  "test_id": "$test_id",
  "test_type": "$test_type",
  "project_path": "$project_path",
  "output_format": "$output_format",
  "started_at": "$(date -Iseconds)",
  "status": "running",
  "results": {
    "total_tests": 0,
    "passed_tests": 0,
    "failed_tests": 0,
    "skipped_tests": 0,
    "duration": 0
  },
  "coverage": {
    "line_coverage": 0,
    "branch_coverage": 0,
    "function_coverage": 0
  },
  "artifacts": [],
  "environment": {
    "detected_framework": "$(detect_test_framework "$project_path")",
    "detected_language": "$(detect_project_language "$project_path")"
  }
}
EOF
}

# Unit Tests
run_unit_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running unit tests..."
    
    local framework=$(detect_test_framework "$project_path")
    local language=$(detect_project_language "$project_path")
    
    log_test "Detected framework: $framework, language: $language"
    
    case "$framework" in
        "jest")
            run_jest_tests "$test_id" "$project_path" "$output_format"
            ;;
        "pytest")
            run_pytest_tests "$test_id" "$project_path" "$output_format"
            ;;
        "junit")
            run_junit_tests "$test_id" "$project_path" "$output_format"
            ;;
        "go-test")
            run_go_tests "$test_id" "$project_path" "$output_format"
            ;;
        "dotnet-test")
            run_dotnet_tests "$test_id" "$project_path" "$output_format"
            ;;
        "rspec")
            run_rspec_tests "$test_id" "$project_path" "$output_format"
            ;;
        "phpunit")
            run_phpunit_tests "$test_id" "$project_path" "$output_format"
            ;;
        *)
            log_warning "Unknown test framework: $framework, attempting generic test execution"
            run_generic_tests "$test_id" "$project_path" "$output_format"
            ;;
    esac
}

# Jest (JavaScript/TypeScript) Tests
run_jest_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running Jest tests..."
    
    if [[ ! -f "$project_path/package.json" ]]; then
        log_error "package.json not found in $project_path"
        return 1
    fi
    
    pushd "$project_path" > /dev/null
    
    # Install dependencies if needed
    if [[ ! -d "node_modules" ]]; then
        log_test "Installing Node.js dependencies..."
        npm install
    fi
    
    # Run Jest tests with coverage
    local jest_output_file="${VALIDATION_RESULTS_DIR}/${test_id}-jest-results.json"
    local coverage_output_file="${VALIDATION_RESULTS_DIR}/${test_id}-coverage.json"
    
    if npm test -- --coverage --json --outputFile="$jest_output_file" --coverageReporters=json-summary; then
        log_success "Jest tests passed"
        
        # Extract coverage information
        if [[ -f "coverage/coverage-summary.json" ]]; then
            cp "coverage/coverage-summary.json" "$coverage_output_file"
        fi
        
        # Convert to JUnit format if requested
        if [[ "$output_format" == "junit" ]]; then
            convert_jest_to_junit "$jest_output_file" "${VALIDATION_RESULTS_DIR}/${test_id}-junit.xml"
        fi
        
        popd > /dev/null
        return 0
    else
        log_error "Jest tests failed"
        popd > /dev/null
        return 1
    fi
}

# Pytest (Python) Tests
run_pytest_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running pytest tests..."
    
    pushd "$project_path" > /dev/null
    
    # Install dependencies if requirements file exists
    if [[ -f "requirements.txt" ]]; then
        log_test "Installing Python dependencies..."
        pip3 install -r requirements.txt --quiet
    elif [[ -f "requirements-test.txt" ]]; then
        pip3 install -r requirements-test.txt --quiet
    fi
    
    # Install pytest if not available
    if ! command -v pytest &> /dev/null; then
        pip3 install pytest pytest-cov --quiet
    fi
    
    # Run pytest with coverage
    local pytest_args=(
        "--verbose"
        "--tb=short"
        "--cov=."
        "--cov-report=json:${VALIDATION_RESULTS_DIR}/${test_id}-coverage.json"
        "--cov-report=term-missing"
    )
    
    if [[ "$output_format" == "junit" ]]; then
        pytest_args+=("--junitxml=${VALIDATION_RESULTS_DIR}/${test_id}-junit.xml")
    fi
    
    if pytest "${pytest_args[@]}" > "${VALIDATION_RESULTS_DIR}/${test_id}-pytest-output.txt" 2>&1; then
        log_success "Pytest tests passed"
        popd > /dev/null
        return 0
    else
        log_error "Pytest tests failed"
        cat "${VALIDATION_RESULTS_DIR}/${test_id}-pytest-output.txt"
        popd > /dev/null
        return 1
    fi
}

# JUnit (Java) Tests
run_junit_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running JUnit tests..."
    
    pushd "$project_path" > /dev/null
    
    if [[ -f "pom.xml" ]]; then
        # Maven project
        log_test "Running Maven tests..."
        if mvn clean test -Dmaven.test.failure.ignore=true \
           -Dsurefire.reportsDirectory="${VALIDATION_RESULTS_DIR}" \
           -Dsurefire.useFile=false; then
            log_success "Maven tests completed"
        else
            log_error "Maven tests failed"
            popd > /dev/null
            return 1
        fi
    elif [[ -f "build.gradle" || -f "build.gradle.kts" ]]; then
        # Gradle project
        log_test "Running Gradle tests..."
        if ./gradlew clean test --continue \
           -Dtest.reports.dir="${VALIDATION_RESULTS_DIR}"; then
            log_success "Gradle tests completed"
        else
            log_error "Gradle tests failed"
            popd > /dev/null
            return 1
        fi
    else
        log_error "No Maven or Gradle build file found"
        popd > /dev/null
        return 1
    fi
    
    popd > /dev/null
    return 0
}

# Go Tests
run_go_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running Go tests..."
    
    pushd "$project_path" > /dev/null
    
    if [[ ! -f "go.mod" ]]; then
        log_error "go.mod not found in $project_path"
        popd > /dev/null
        return 1
    fi
    
    # Install gotestsum for better output formatting
    if ! command -v gotestsum &> /dev/null; then
        go install gotest.tools/gotestsum@latest
    fi
    
    # Run Go tests with coverage
    local test_output_file="${VALIDATION_RESULTS_DIR}/${test_id}-go-test-output.txt"
    local coverage_output_file="${VALIDATION_RESULTS_DIR}/${test_id}-coverage.out"
    
    if [[ "$output_format" == "junit" ]]; then
        gotestsum --junitfile="${VALIDATION_RESULTS_DIR}/${test_id}-junit.xml" -- \
                  -coverprofile="$coverage_output_file" \
                  -covermode=atomic \
                  ./... > "$test_output_file" 2>&1
    else
        go test -v -coverprofile="$coverage_output_file" \
                -covermode=atomic \
                ./... > "$test_output_file" 2>&1
    fi
    
    local test_result=$?
    
    # Generate coverage report
    if [[ -f "$coverage_output_file" ]]; then
        go tool cover -func="$coverage_output_file" > "${VALIDATION_RESULTS_DIR}/${test_id}-coverage-summary.txt"
    fi
    
    if [[ $test_result -eq 0 ]]; then
        log_success "Go tests passed"
    else
        log_error "Go tests failed"
        cat "$test_output_file"
    fi
    
    popd > /dev/null
    return $test_result
}

# .NET Tests
run_dotnet_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running .NET tests..."
    
    pushd "$project_path" > /dev/null
    
    # Find test projects
    local test_projects=($(find . -name "*.Tests.csproj" -o -name "*Test*.csproj"))
    
    if [[ ${#test_projects[@]} -eq 0 ]]; then
        log_error "No .NET test projects found"
        popd > /dev/null
        return 1
    fi
    
    local dotnet_args=(
        "test"
        "--verbosity" "normal"
        "--collect" "XPlat Code Coverage"
        "--results-directory" "${VALIDATION_RESULTS_DIR}"
    )
    
    if [[ "$output_format" == "junit" ]]; then
        dotnet_args+=("--logger" "junit;LogFilePath=${VALIDATION_RESULTS_DIR}/${test_id}-junit.xml")
    fi
    
    if dotnet "${dotnet_args[@]}" > "${VALIDATION_RESULTS_DIR}/${test_id}-dotnet-output.txt" 2>&1; then
        log_success ".NET tests passed"
        popd > /dev/null
        return 0
    else
        log_error ".NET tests failed"
        cat "${VALIDATION_RESULTS_DIR}/${test_id}-dotnet-output.txt"
        popd > /dev/null
        return 1
    fi
}

# Integration Tests
run_integration_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running integration tests..."
    
    # Check if integration test configuration exists
    if [[ -f "$project_path/integration-tests.yml" || -f "$project_path/docker-compose.test.yml" ]]; then
        run_docker_compose_integration_tests "$test_id" "$project_path" "$output_format"
    elif [[ -f "$project_path/testcontainers.properties" ]]; then
        run_testcontainers_integration_tests "$test_id" "$project_path" "$output_format"
    else
        # Run framework-specific integration tests
        local framework=$(detect_test_framework "$project_path")
        case "$framework" in
            "jest")
                run_jest_integration_tests "$test_id" "$project_path" "$output_format"
                ;;
            "pytest")
                run_pytest_integration_tests "$test_id" "$project_path" "$output_format"
                ;;
            *)
                log_warning "No integration test configuration found, skipping..."
                return 0
                ;;
        esac
    fi
}

# Docker Compose Integration Tests
run_docker_compose_integration_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running Docker Compose integration tests..."
    
    pushd "$project_path" > /dev/null
    
    local compose_file="docker-compose.test.yml"
    [[ -f "integration-tests.yml" ]] && compose_file="integration-tests.yml"
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "docker-compose not found"
        popd > /dev/null
        return 1
    fi
    
    # Start test environment
    log_test "Starting test environment..."
    docker-compose -f "$compose_file" up -d
    
    # Wait for services to be ready
    sleep 30
    
    # Run integration tests
    local test_result=0
    if docker-compose -f "$compose_file" exec -T app-test npm run test:integration; then
        log_success "Docker Compose integration tests passed"
    else
        log_error "Docker Compose integration tests failed"
        test_result=1
    fi
    
    # Collect logs
    docker-compose -f "$compose_file" logs > "${VALIDATION_RESULTS_DIR}/${test_id}-integration-logs.txt"
    
    # Cleanup
    docker-compose -f "$compose_file" down -v
    
    popd > /dev/null
    return $test_result
}

# End-to-End Tests
run_e2e_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running end-to-end tests..."
    
    # Detect E2E test framework
    if [[ -f "$project_path/cypress.json" || -d "$project_path/cypress" ]]; then
        run_cypress_tests "$test_id" "$project_path" "$output_format"
    elif [[ -f "$project_path/playwright.config.js" || -f "$project_path/playwright.config.ts" ]]; then
        run_playwright_tests "$test_id" "$project_path" "$output_format"
    elif [[ -f "$project_path/selenium-tests.py" ]]; then
        run_selenium_tests "$test_id" "$project_path" "$output_format"
    else
        log_warning "No E2E test framework detected, skipping..."
        return 0
    fi
}

# Cypress Tests
run_cypress_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running Cypress E2E tests..."
    
    pushd "$project_path" > /dev/null
    
    # Install dependencies if needed
    if [[ ! -d "node_modules" ]]; then
        npm install
    fi
    
    # Install Cypress if not available
    if ! command -v cypress &> /dev/null; then
        npm install --save-dev cypress
    fi
    
    # Run Cypress tests
    local cypress_args=("run" "--headless" "--browser" "chrome")
    
    if [[ "$output_format" == "junit" ]]; then
        cypress_args+=("--reporter" "junit" "--reporter-options" "mochaFile=${VALIDATION_RESULTS_DIR}/${test_id}-cypress-junit.xml")
    fi
    
    if npx cypress "${cypress_args[@]}" > "${VALIDATION_RESULTS_DIR}/${test_id}-cypress-output.txt" 2>&1; then
        log_success "Cypress tests passed"
        
        # Copy screenshots and videos if they exist
        [[ -d "cypress/screenshots" ]] && cp -r cypress/screenshots "${VALIDATION_RESULTS_DIR}/${test_id}-screenshots/"
        [[ -d "cypress/videos" ]] && cp -r cypress/videos "${VALIDATION_RESULTS_DIR}/${test_id}-videos/"
        
        popd > /dev/null
        return 0
    else
        log_error "Cypress tests failed"
        cat "${VALIDATION_RESULTS_DIR}/${test_id}-cypress-output.txt"
        popd > /dev/null
        return 1
    fi
}

# Playwright Tests
run_playwright_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running Playwright E2E tests..."
    
    pushd "$project_path" > /dev/null
    
    # Install dependencies if needed
    if [[ ! -d "node_modules" ]]; then
        npm install
    fi
    
    # Install Playwright browsers
    npx playwright install
    
    # Run Playwright tests
    local playwright_args=("test" "--forbid-only")
    
    if [[ "$output_format" == "junit" ]]; then
        playwright_args+=("--reporter=junit" "--output-dir=${VALIDATION_RESULTS_DIR}")
    fi
    
    if npx playwright "${playwright_args[@]}" > "${VALIDATION_RESULTS_DIR}/${test_id}-playwright-output.txt" 2>&1; then
        log_success "Playwright tests passed"
        popd > /dev/null
        return 0
    else
        log_error "Playwright tests failed"
        cat "${VALIDATION_RESULTS_DIR}/${test_id}-playwright-output.txt"
        popd > /dev/null
        return 1
    fi
}

# Performance Tests
run_performance_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running performance tests..."
    
    local target_url="${PERFORMANCE_TARGET_URL:-}"
    local duration="${LOAD_TEST_DURATION:-$DEFAULT_LOAD_TEST_DURATION}"
    local concurrent_users="${CONCURRENT_USERS:-10}"
    
    if [[ -z "$target_url" ]]; then
        log_warning "No performance target URL specified, skipping performance tests"
        return 0
    fi
    
    # Choose performance testing tool
    if command -v k6 &> /dev/null; then
        run_k6_performance_tests "$test_id" "$target_url" "$duration" "$concurrent_users"
    elif command -v artillery &> /dev/null; then
        run_artillery_performance_tests "$test_id" "$target_url" "$duration" "$concurrent_users"
    elif command -v ab &> /dev/null; then
        run_apache_bench_tests "$test_id" "$target_url" "$duration" "$concurrent_users"
    else
        log_warning "No performance testing tool available (k6, artillery, ab), skipping..."
        return 0
    fi
}

# K6 Performance Tests
run_k6_performance_tests() {
    local test_id="$1"
    local target_url="$2"
    local duration="$3"
    local concurrent_users="$4"
    
    log_test "Running K6 performance tests..."
    
    # Create K6 test script
    local k6_script="${VALIDATION_TEMP_DIR}/k6-performance-test.js"
    cat > "$k6_script" << EOF
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: ${concurrent_users} },
    { duration: '${duration}s', target: ${concurrent_users} },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.1'],
  },
};

export default function() {
  let response = http.get('${target_url}');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
EOF
    
    # Run K6 test
    local k6_output="${VALIDATION_RESULTS_DIR}/${test_id}-k6-results.json"
    if k6 run --out json="$k6_output" "$k6_script" > "${VALIDATION_RESULTS_DIR}/${test_id}-k6-output.txt" 2>&1; then
        log_success "K6 performance tests completed"
        
        # Process results
        process_k6_results "$k6_output" "${VALIDATION_RESULTS_DIR}/${test_id}-performance-summary.json"
        return 0
    else
        log_error "K6 performance tests failed"
        cat "${VALIDATION_RESULTS_DIR}/${test_id}-k6-output.txt"
        return 1
    fi
}

# API Tests
run_api_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running API tests..."
    
    # Look for API test configurations
    if [[ -f "$project_path/postman_collection.json" ]]; then
        run_postman_tests "$test_id" "$project_path" "$output_format"
    elif [[ -f "$project_path/api-tests.yml" || -f "$project_path/api-tests.yaml" ]]; then
        run_rest_assured_tests "$test_id" "$project_path" "$output_format"
    elif [[ -f "$project_path/swagger.yml" || -f "$project_path/openapi.yml" ]]; then
        run_openapi_tests "$test_id" "$project_path" "$output_format"
    else
        log_warning "No API test configuration found, skipping..."
        return 0
    fi
}

# Postman/Newman Tests
run_postman_tests() {
    local test_id="$1"
    local project_path="$2"
    local output_format="$3"
    
    log_test "Running Postman/Newman API tests..."
    
    # Install Newman if not available
    if ! command -v newman &> /dev/null; then
        npm install -g newman
    fi
    
    pushd "$project_path" > /dev/null
    
    local newman_args=("run" "postman_collection.json")
    
    # Add environment if exists
    [[ -f "postman_environment.json" ]] && newman_args+=("--environment" "postman_environment.json")
    
    # Set output format
    if [[ "$output_format" == "junit" ]]; then
        newman_args+=("--reporters" "junit" "--reporter-junit-export" "${VALIDATION_RESULTS_DIR}/${test_id}-newman-junit.xml")
    else
        newman_args+=("--reporters" "json" "--reporter-json-export" "${VALIDATION_RESULTS_DIR}/${test_id}-newman-results.json")
    fi
    
    if newman "${newman_args[@]}" > "${VALIDATION_RESULTS_DIR}/${test_id}-newman-output.txt" 2>&1; then
        log_success "Newman API tests passed"
        popd > /dev/null
        return 0
    else
        log_error "Newman API tests failed"
        cat "${VALIDATION_RESULTS_DIR}/${test_id}-newman-output.txt"
        popd > /dev/null
        return 1
    fi
}

# Accessibility Tests
run_accessibility_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running accessibility tests..."
    
    local target_url="${ACCESSIBILITY_TARGET_URL:-}"
    
    if [[ -z "$target_url" ]]; then
        log_warning "No accessibility target URL specified, skipping accessibility tests"
        return 0
    fi
    
    # Install axe-core CLI if not available
    if ! command -v axe &> /dev/null; then
        npm install -g @axe-core/cli
    fi
    
    # Run axe accessibility scan
    local axe_output="${VALIDATION_RESULTS_DIR}/${test_id}-axe-results.json"
    
    if axe "$target_url" --format json --output "$axe_output" > "${VALIDATION_RESULTS_DIR}/${test_id}-axe-output.txt" 2>&1; then
        log_success "Accessibility tests completed"
        
        # Check for violations
        local violation_count=$(jq '.violations | length' "$axe_output")
        if [[ $violation_count -gt 0 ]]; then
            log_warning "Found $violation_count accessibility violations"
        else
            log_success "No accessibility violations found"
        fi
        
        return 0
    else
        log_error "Accessibility tests failed"
        cat "${VALIDATION_RESULTS_DIR}/${test_id}-axe-output.txt"
        return 1
    fi
}

# Smoke Tests
run_smoke_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running smoke tests..."
    
    local target_url="${SMOKE_TEST_URL:-}"
    local endpoints_file="$project_path/smoke-test-endpoints.txt"
    
    if [[ -z "$target_url" && ! -f "$endpoints_file" ]]; then
        log_warning "No smoke test configuration found, skipping..."
        return 0
    fi
    
    local smoke_results="${VALIDATION_RESULTS_DIR}/${test_id}-smoke-results.json"
    local test_results=()
    
    # Test individual endpoints
    if [[ -f "$endpoints_file" ]]; then
        while IFS= read -r endpoint; do
            [[ "$endpoint" =~ ^#.*$ ]] && continue  # Skip comments
            [[ -z "$endpoint" ]] && continue        # Skip empty lines
            
            local full_url="$target_url$endpoint"
            log_test "Testing endpoint: $full_url"
            
            local start_time=$(date +%s.%N)
            local http_code=$(curl -o /dev/null -s -w "%{http_code}" -m 30 "$full_url")
            local end_time=$(date +%s.%N)
            local response_time=$(echo "$end_time - $start_time" | bc)
            
            local test_result="{\"endpoint\":\"$endpoint\",\"url\":\"$full_url\",\"status_code\":$http_code,\"response_time\":$response_time}"
            
            if [[ $http_code -ge 200 && $http_code -lt 400 ]]; then
                log_success "✓ $endpoint (${http_code}, ${response_time}s)"
                test_result=$(echo "$test_result" | jq '. + {result: "pass"}')
            else
                log_error "✗ $endpoint (${http_code}, ${response_time}s)"
                test_result=$(echo "$test_result" | jq '. + {result: "fail"}')
            fi
            
            test_results+=("$test_result")
        done < "$endpoints_file"
    else
        # Test single URL
        log_test "Testing URL: $target_url"
        
        local start_time=$(date +%s.%N)
        local http_code=$(curl -o /dev/null -s -w "%{http_code}" -m 30 "$target_url")
        local end_time=$(date +%s.%N)
        local response_time=$(echo "$end_time - $start_time" | bc)
        
        local test_result="{\"endpoint\":\"/\",\"url\":\"$target_url\",\"status_code\":$http_code,\"response_time\":$response_time}"
        
        if [[ $http_code -ge 200 && $http_code -lt 400 ]]; then
            log_success "✓ Main page (${http_code}, ${response_time}s)"
            test_result=$(echo "$test_result" | jq '. + {result: "pass"}')
        else
            log_error "✗ Main page (${http_code}, ${response_time}s)"
            test_result=$(echo "$test_result" | jq '. + {result: "fail"}')
        fi
        
        test_results+=("$test_result")
    fi
    
    # Generate smoke test report
    local smoke_report=$(printf '%s\n' "${test_results[@]}" | jq -s '.')
    echo "$smoke_report" > "$smoke_results"
    
    # Check overall result
    local failed_tests=$(echo "$smoke_report" | jq '[.[] | select(.result == "fail")] | length')
    
    if [[ $failed_tests -eq 0 ]]; then
        log_success "All smoke tests passed"
        return 0
    else
        log_error "$failed_tests smoke tests failed"
        return 1
    fi
}

# Comprehensive Test Suite
run_comprehensive_tests() {
    local test_id="$1"
    local project_path="$2"
    local test_config="$3"
    local output_format="$4"
    
    log_test "Running comprehensive test suite..."
    
    local test_types=("unit" "integration" "api" "smoke")
    local failed_test_types=()
    
    # Add optional test types if configured
    [[ -n "${PERFORMANCE_TARGET_URL:-}" ]] && test_types+=("performance")
    [[ -n "${ACCESSIBILITY_TARGET_URL:-}" ]] && test_types+=("accessibility")
    
    for test_type in "${test_types[@]}"; do
        log_test "Running $test_type tests as part of comprehensive suite..."
        
        local sub_test_id="${test_id}-${test_type}"
        if run_tests "$test_type" "$project_path" "$test_config" "$output_format"; then
            log_success "$test_type tests passed"
        else
            log_error "$test_type tests failed"
            failed_test_types+=("$test_type")
        fi
    done
    
    # Generate comprehensive test report
    generate_comprehensive_test_report "$test_id" "${test_types[@]}"
    
    if [[ ${#failed_test_types[@]} -eq 0 ]]; then
        log_success "Comprehensive test suite completed successfully"
        return 0
    else
        log_error "Comprehensive test suite failed. Failed test types: ${failed_test_types[*]}"
        return 1
    fi
}

# Deployment Validation
validate_deployment() {
    local environment="$1"
    local target_url="$2"
    local validation_config="${3:-}"
    
    local validation_id="validate-$(date +%Y%m%d-%H%M%S)-$$"
    local validation_start_time=$(date +%s)
    
    log_info "Starting deployment validation: $validation_id"
    log_info "Environment: $environment"
    log_info "Target URL: $target_url"
    
    # Initialize validation state
    init_validation_state "$validation_id" "$environment" "$target_url"
    
    # Run validation checks
    local validation_checks=("health" "smoke" "connectivity")
    local failed_checks=()
    
    for check in "${validation_checks[@]}"; do
        log_info "Running $check validation..."
        
        case "$check" in
            "health")
                validate_health_endpoints "$validation_id" "$target_url"
                ;;
            "smoke")
                validate_smoke_functionality "$validation_id" "$target_url"
                ;;
            "connectivity")
                validate_connectivity "$validation_id" "$target_url"
                ;;
        esac
        
        if [[ $? -ne 0 ]]; then
            failed_checks+=("$check")
        fi
    done
    
    local validation_duration=$(($(date +%s) - validation_start_time))
    
    # Generate validation report
    generate_validation_report "$validation_id" "$environment" "$validation_duration" "${failed_checks[@]}"
    
    if [[ ${#failed_checks[@]} -eq 0 ]]; then
        log_success "Deployment validation completed successfully in ${validation_duration}s"
        return 0
    else
        log_error "Deployment validation failed after ${validation_duration}s. Failed checks: ${failed_checks[*]}"
        return 1
    fi
}

# Health Endpoint Validation
validate_health_endpoints() {
    local validation_id="$1"
    local base_url="$2"
    
    log_info "Validating health endpoints..."
    
    local health_endpoints=("/health" "/healthz" "/alive" "/ready" "/status")
    local working_endpoints=()
    
    for endpoint in "${health_endpoints[@]}"; do
        local health_url="${base_url}${endpoint}"
        log_debug "Checking health endpoint: $health_url"
        
        local http_code=$(curl -o /dev/null -s -w "%{http_code}" -m 10 "$health_url")
        
        if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
            log_success "✓ Health endpoint available: $endpoint"
            working_endpoints+=("$endpoint")
        else
            log_debug "✗ Health endpoint not available: $endpoint (HTTP $http_code)"
        fi
    done
    
    if [[ ${#working_endpoints[@]} -gt 0 ]]; then
        log_success "Found ${#working_endpoints[@]} working health endpoint(s)"
        return 0
    else
        log_warning "No health endpoints found"
        return 1
    fi
}

# Utility Functions
detect_test_framework() {
    local project_path="$1"
    
    # JavaScript/TypeScript frameworks
    if [[ -f "$project_path/package.json" ]]; then
        local package_content=$(cat "$project_path/package.json")
        if echo "$package_content" | grep -q "jest"; then
            echo "jest"
        elif echo "$package_content" | grep -q "mocha"; then
            echo "mocha"
        elif echo "$package_content" | grep -q "jasmine"; then
            echo "jasmine"
        else
            echo "npm"
        fi
        return
    fi
    
    # Python frameworks
    if [[ -f "$project_path/pytest.ini" || -f "$project_path/pyproject.toml" ]] || find "$project_path" -name "test_*.py" -o -name "*_test.py" | head -1 | grep -q .; then
        echo "pytest"
        return
    fi
    
    # Java frameworks
    if [[ -f "$project_path/pom.xml" ]]; then
        echo "junit"
        return
    elif [[ -f "$project_path/build.gradle" || -f "$project_path/build.gradle.kts" ]]; then
        echo "junit"
        return
    fi
    
    # Go
    if [[ -f "$project_path/go.mod" ]]; then
        echo "go-test"
        return
    fi
    
    # .NET
    if find "$project_path" -name "*.csproj" | grep -q "Test"; then
        echo "dotnet-test"
        return
    fi
    
    # Ruby
    if [[ -f "$project_path/Gemfile" ]] && grep -q "rspec" "$project_path/Gemfile"; then
        echo "rspec"
        return
    fi
    
    # PHP
    if [[ -f "$project_path/phpunit.xml" || -f "$project_path/composer.json" ]] && grep -q "phpunit" "$project_path/composer.json" 2>/dev/null; then
        echo "phpunit"
        return
    fi
    
    echo "unknown"
}

detect_project_language() {
    local project_path="$1"
    
    if [[ -f "$project_path/package.json" ]]; then
        echo "javascript"
    elif find "$project_path" -name "*.py" | head -1 | grep -q .; then
        echo "python"
    elif [[ -f "$project_path/pom.xml" ]] || find "$project_path" -name "*.java" | head -1 | grep -q .; then
        echo "java"
    elif [[ -f "$project_path/go.mod" ]] || find "$project_path" -name "*.go" | head -1 | grep -q .; then
        echo "go"
    elif find "$project_path" -name "*.cs" | head -1 | grep -q .; then
        echo "csharp"
    elif find "$project_path" -name "*.rb" | head -1 | grep -q .; then
        echo "ruby"
    elif find "$project_path" -name "*.php" | head -1 | grep -q .; then
        echo "php"
    else
        echo "unknown"
    fi
}

# Report Generation
generate_test_summary() {
    local test_id="$1"
    local test_type="$2"
    local duration="$3"
    local exit_code="$4"
    
    local state_file="${VALIDATION_RESULTS_DIR}/${test_id}.json"
    local summary_file="${VALIDATION_REPORTS_DIR}/${test_id}-summary.json"
    
    if [[ -f "$state_file" ]]; then
        jq --arg duration "$duration" \
           --arg status "$(if [[ $exit_code -eq 0 ]]; then echo "passed"; else echo "failed"; fi)" \
           --arg completed_at "$(date -Iseconds)" \
           '.duration = ($duration | tonumber) | .status = $status | .completed_at = $completed_at' \
           "$state_file" > "$summary_file"
        
        log_info "Test summary generated: $summary_file"
    fi
}

generate_validation_report() {
    local validation_id="$1"
    local environment="$2"
    local duration="$3"
    shift 3
    local failed_checks=("$@")
    
    local report_file="${VALIDATION_REPORTS_DIR}/${validation_id}-validation-report.json"
    
    cat > "$report_file" << EOF
{
  "validation_id": "$validation_id",
  "environment": "$environment",
  "timestamp": "$(date -Iseconds)",
  "duration": $duration,
  "status": "$(if [[ ${#failed_checks[@]} -eq 0 ]]; then echo "passed"; else echo "failed"; fi)",
  "failed_checks": [$(printf '"%s",' "${failed_checks[@]}" | sed 's/,$//')]
}
EOF
    
    log_info "Validation report generated: $report_file"
}

# Cleanup Function
cleanup_validation() {
    log_info "Cleaning up validation artifacts..."
    
    # Remove temporary directory
    if [[ -d "$VALIDATION_TEMP_DIR" ]]; then
        rm -rf "$VALIDATION_TEMP_DIR"
        log_info "Temporary directory removed: $VALIDATION_TEMP_DIR"
    fi
    
    log_success "Validation cleanup completed"
}

# Export functions for external usage
export -f setup_validation_environment
export -f run_tests
export -f validate_deployment
export -f cleanup_validation

# Signal handling for cleanup
trap cleanup_validation EXIT INT TERM

# Main execution if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        "setup")
            setup_validation_environment
            ;;
        "test")
            shift
            run_tests "$@"
            ;;
        "validate")
            shift
            validate_deployment "$@"
            ;;
        "cleanup")
            cleanup_validation
            ;;
        "help"|*)
            echo "Usage: $0 {setup|test|validate|cleanup|help}"
            echo "  setup                                      - Setup validation environment"
            echo "  test <type> <path> [config] [format]       - Run tests"
            echo "  validate <env> <url> [config]              - Validate deployment"
            echo "  cleanup                                    - Clean up artifacts"
            echo "  help                                       - Show this help message"
            echo ""
            echo "Test types: unit, integration, e2e, performance, smoke, api, ui, accessibility, all"
            ;;
    esac
fi