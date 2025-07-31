#!/bin/bash

# Arch Wiki Get CSRF Token Script
# This script retrieves the CSRF token needed for editing pages
# Enhanced with robust error handling, logging, and security features

# Configuration
ARCH_WIKI_API="https://wiki.archlinux.org/api.php"
COOKIES_FILE="/tmp/archwiki_cookies.txt"
CSRF_TOKEN_FILE="/tmp/archwiki_csrf_token.txt"
LOG_FILE="archwiki_submission.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log_message() {
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to print colored output
print_status() {
    log_message "$1"
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    log_message "ERROR: $1"
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run curl command with error handling
run_curl_command() {
    local method="$1"
    shift
    local params=("$@")
    
    local cmd=("curl" "-s" "-X" "$method" "$ARCH_WIKI_API")
    
    # Add cookie handling
    if [ -f "$COOKIES_FILE" ]; then
        cmd+=("-b" "$COOKIES_FILE" "-c" "$COOKIES_FILE")
    else
        print_error "Cookies file not found. Please login first."
        log_message "Cookies file not found. Please login first."
        exit 1
    fi
    
    # Add parameters
    local i=0
    while [ $i -lt ${#params[@]} ]; do
        local key="${params[$i]}"
        local value="${params[$((i+1))]}"
        cmd+=("-d" "$key=$value")
        i=$((i+2))
    done
    
    # Add user agent
    cmd+=("--user-agent" "ArchWikiBot/1.0 (Linux Bluetooth Troubleshooting Project)")
    
    # Add timeout options
    cmd+=("--connect-timeout" "30" "--max-time" "120")
    
    log_message "Executing curl command: ${cmd[*]}"
    
    local output
    output=$("${cmd[@]}" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        log_message "Curl command failed with exit code $exit_code: $output"
        return $exit_code
    fi
    
    echo "$output"
    return 0
}

# Check if cookies file exists
if [ ! -f "$COOKIES_FILE" ]; then
    print_error "Cookies file not found. Please login first."
    log_message "Cookies file not found. Please login first."
    exit 1
fi

# Get CSRF token
print_status "Getting CSRF token..."
log_message "Attempting to get CSRF token"
CSRF_TOKEN_RESPONSE=$(run_curl_command "POST" "action" "query" "meta" "tokens" "type" "csrf" "format" "json")

# Check if curl command succeeded
if [ $? -ne 0 ]; then
    print_error "Failed to execute curl command for CSRF token"
    log_message "Failed to execute curl command for CSRF token"
    exit 1
fi

# Parse CSRF token
CSRF_TOKEN=$(echo "$CSRF_TOKEN_RESPONSE" | grep -o '"csrftoken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$CSRF_TOKEN" ]; then
    print_error "Failed to get CSRF token"
    log_message "Failed to get CSRF token. Response: $CSRF_TOKEN_RESPONSE"
    exit 1
fi

# Store CSRF token
echo "$CSRF_TOKEN" > "$CSRF_TOKEN_FILE"
print_status "CSRF token obtained and stored"
log_message "CSRF token obtained and stored successfully"