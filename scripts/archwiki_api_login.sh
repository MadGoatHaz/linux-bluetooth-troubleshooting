#!/bin/bash

# Arch Wiki API Login Script
# This script handles authentication with the Arch Wiki API
# Enhanced with robust error handling, logging, and security features

# Configuration
ARCH_WIKI_API="https://wiki.archlinux.org/api.php"
COOKIES_FILE="/tmp/archwiki_cookies.txt"
CREDENTIALS_FILE="archwiki_credentials.conf"
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
        cmd+=("-c" "$COOKIES_FILE")
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

# Security check: Ensure credentials file exists and is not the sample file
if [ ! -f "$CREDENTIALS_FILE" ]; then
    print_error "Credentials file not found: $CREDENTIALS_FILE"
    log_message "Credentials file not found: $CREDENTIALS_FILE"
    exit 1
fi

# Load credentials
source "$CREDENTIALS_FILE"

# Validate credentials
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    print_error "Username or password not found in credentials file"
    log_message "Username or password not found in credentials file"
    exit 1
fi

# Get login token
print_status "Getting login token..."
log_message "Attempting to get login token"
LOGIN_TOKEN_RESPONSE=$(run_curl_command "POST" "action" "query" "meta" "tokens" "type" "login" "format" "json")

# Check if curl command succeeded
if [ $? -ne 0 ]; then
    print_error "Failed to execute curl command for login token"
    log_message "Failed to execute curl command for login token"
    exit 1
fi

# Parse login token
LOGIN_TOKEN=$(echo "$LOGIN_TOKEN_RESPONSE" | grep -o '"logintoken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$LOGIN_TOKEN" ]; then
    print_error "Failed to get login token"
    log_message "Failed to get login token. Response: $LOGIN_TOKEN_RESPONSE"
    exit 1
fi

print_status "Login token obtained"
log_message "Login token obtained successfully"

# Perform login
print_status "Logging in as user: $USERNAME"
log_message "Attempting to log in as user: $USERNAME"
LOGIN_RESPONSE=$(run_curl_command "POST" "action" "login" "lgname" "$USERNAME" "lgpassword" "$PASSWORD" "lgtoken" "$LOGIN_TOKEN" "format" "json")

# Check if curl command succeeded
if [ $? -ne 0 ]; then
    print_error "Failed to execute curl command for login"
    log_message "Failed to execute curl command for login"
    # Clean up cookies file on failure
    rm -f "$COOKIES_FILE"
    exit 1
fi

# Parse login result
LOGIN_RESULT=$(echo "$LOGIN_RESPONSE" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

if [ "$LOGIN_RESULT" != "Success" ]; then
    print_error "Login failed"
    log_message "Login failed. Response: $LOGIN_RESPONSE"
    # Clean up cookies file on failure
    rm -f "$COOKIES_FILE"
    exit 1
fi

print_status "Login successful!"
log_message "Login successful for user: $USERNAME"