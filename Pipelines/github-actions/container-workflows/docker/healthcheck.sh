#!/bin/sh
# Health check script for containerized application

set -eo pipefail

# Configuration
HOST=${HEALTH_CHECK_HOST:-"localhost"}
PORT=${HEALTH_CHECK_PORT:-"8080"}
PATH_ENDPOINT=${HEALTH_CHECK_PATH:-"/health"}
TIMEOUT=${HEALTH_CHECK_TIMEOUT:-"5"}
MAX_RETRIES=${HEALTH_CHECK_MAX_RETRIES:-"3"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo "${RED}[ERROR]${NC} $1" >&2
}

# Health check function
check_http_health() {
    local url="http://${HOST}:${PORT}${PATH_ENDPOINT}"
    local response_code
    local response_time
    
    log_info "Checking HTTP health at ${url}"
    
    # Use curl with timeout and follow redirects
    response_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "${TIMEOUT}" \
        --max-time "${TIMEOUT}" \
        "${url}")
    
    response_time=$(curl -s -o /dev/null -w "%{time_total}" \
        --connect-timeout "${TIMEOUT}" \
        --max-time "${TIMEOUT}" \
        "${url}")
    
    case $response_code in
        200)
            log_info "Health check passed (${response_code}) in ${response_time}s"
            return 0
            ;;
        000)
            log_error "Health check failed: Connection timeout or refused"
            return 1
            ;;
        *)
            log_error "Health check failed: HTTP ${response_code}"
            return 1
            ;;
    esac
}

# Process health check
check_process_health() {
    local process_name=${1:-"nginx"}
    
    if pgrep -f "${process_name}" > /dev/null; then
        log_info "Process '${process_name}' is running"
        return 0
    else
        log_error "Process '${process_name}' is not running"
        return 1
    fi
}

# Disk space check
check_disk_space() {
    local threshold=${1:-"90"}
    local usage
    
    usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "${usage}" -lt "${threshold}" ]; then
        log_info "Disk usage is ${usage}% (threshold: ${threshold}%)"
        return 0
    else
        log_warn "Disk usage is ${usage}% (threshold: ${threshold}%)"
        return 1
    fi
}

# Memory usage check
check_memory_usage() {
    local threshold=${1:-"90"}
    local usage
    
    if command -v free >/dev/null 2>&1; then
        usage=$(free | awk 'NR==2{printf "%.0f", $3*100/($3+$4)}')
    else
        # Fallback for Alpine/busybox
        usage=$(awk '/MemTotal/{total=$2} /MemAvailable/{avail=$2} END{printf "%.0f", (total-avail)*100/total}' /proc/meminfo 2>/dev/null || echo "0")
    fi
    
    if [ "${usage}" -lt "${threshold}" ]; then
        log_info "Memory usage is ${usage}% (threshold: ${threshold}%)"
        return 0
    else
        log_warn "Memory usage is ${usage}% (threshold: ${threshold}%)"
        return 1
    fi
}

# Database connectivity check (if applicable)
check_database_connection() {
    local db_host=${DB_HOST:-""}
    local db_port=${DB_PORT:-""}
    
    if [ -n "${db_host}" ] && [ -n "${db_port}" ]; then
        if nc -z "${db_host}" "${db_port}" 2>/dev/null; then
            log_info "Database connection to ${db_host}:${db_port} is healthy"
            return 0
        else
            log_error "Database connection to ${db_host}:${db_port} failed"
            return 1
        fi
    fi
    
    return 0  # Skip if not configured
}

# Redis connectivity check (if applicable)
check_redis_connection() {
    local redis_host=${REDIS_HOST:-""}
    local redis_port=${REDIS_PORT:-"6379"}
    
    if [ -n "${redis_host}" ]; then
        if nc -z "${redis_host}" "${redis_port}" 2>/dev/null; then
            log_info "Redis connection to ${redis_host}:${redis_port} is healthy"
            return 0
        else
            log_error "Redis connection to ${redis_host}:${redis_port} failed"
            return 1
        fi
    fi
    
    return 0  # Skip if not configured
}

# Main health check with retries
main() {
    local retry_count=0
    local exit_code=0
    
    log_info "Starting comprehensive health check"
    log_info "Configuration: Host=${HOST}, Port=${PORT}, Timeout=${TIMEOUT}s, Max Retries=${MAX_RETRIES}"
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        log_info "Health check attempt $((retry_count + 1))/${MAX_RETRIES}"
        
        # Reset exit code for this attempt
        exit_code=0
        
        # HTTP health check (primary)
        if ! check_http_health; then
            exit_code=1
        fi
        
        # Process health check
        if ! check_process_health "nginx"; then
            exit_code=1
        fi
        
        # Resource checks (warnings only, don't fail health check)
        check_disk_space "90" || true
        check_memory_usage "90" || true
        
        # External dependency checks
        if ! check_database_connection; then
            exit_code=1
        fi
        
        if ! check_redis_connection; then
            exit_code=1
        fi
        
        # If all checks pass, exit successfully
        if [ $exit_code -eq 0 ]; then
            log_info "All health checks passed"
            exit 0
        fi
        
        # Increment retry count and wait before next attempt
        retry_count=$((retry_count + 1))
        
        if [ $retry_count -lt $MAX_RETRIES ]; then
            log_warn "Health check failed, retrying in 2 seconds..."
            sleep 2
        fi
    done
    
    log_error "Health check failed after ${MAX_RETRIES} attempts"
    exit 1
}

# Trap signals for graceful shutdown
trap 'log_info "Health check interrupted"; exit 130' INT TERM

# Run main function
main "$@"