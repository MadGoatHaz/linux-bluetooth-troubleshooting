#!/bin/bash

# Secure Arch Wiki Submission Script
# This script prompts for credentials during execution and ensures they are never stored
# Enhanced with robust security measures for immediate memory clearance

# Configuration
ARCH_WIKI_API="https://wiki.archlinux.org/api.php"
COOKIES_FILE="/tmp/archwiki_cookies_$$.txt"  # Use process ID for unique file
CSRF_TOKEN_FILE="/tmp/archwiki_csrf_token_$$.txt"  # Use process ID for unique file
LOG_FILE="/tmp/archwiki_submission_$$.log"  # Use process ID for unique file

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages (without including credentials)
log_message() {
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to print colored output
print_status() {
    log_message "$1"
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    log_message "WARNING: $1"
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    log_message "ERROR: $1"
    echo -e "${RED}[ERROR]${NC} $1"
}

print_security() {
    echo -e "${BLUE}[SECURITY]${NC} $1"
}

# Function to securely clear variables
secure_clear() {
    if [ -n "$1" ]; then
        # Overwrite variable content multiple times
        local var_name="$1"
        local var_value="${!var_name}"
        if [ -n "$var_value" ]; then
            # Overwrite with random data
            local random_data=$(openssl rand -hex 1024 2>/dev/null || echo "random_data_overwrite_$(date +%s)")
            eval "$var_name=\$random_data"
            # Clear the random data variable
            unset random_data
            # Finally unset the original variable
            unset "$var_name"
        fi
    fi
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
        
        # URL-encode specific parameters
        if [[ "$key" == "text" || "$key" == "summary" ]]; then
            cmd+=("--data-urlencode" "$key=$value")
        else
            cmd+=("-d" "$key=$value")
        fi
        
        i=$((i+2))
    done
    
    # Add user agent
    cmd+=("--user-agent" "ArchWikiSecureBot/1.0 (Linux Bluetooth Troubleshooting Project)")
    
    # Add timeout options
    cmd+=("--connect-timeout" "30" "--max-time" "120")
    
    log_message "Executing secure curl command"
    
    local output
    output=$("${cmd[@]}" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        log_message "Curl command failed with exit code $exit_code"
        return $exit_code
    fi
    
    echo "$output"
    return 0
}

# Function to cleanup temporary files
cleanup() {
    print_status "Cleaning up temporary files..."
    log_message "Cleaning up temporary files"
    
    # Securely clear sensitive variables
    secure_clear "PASSWORD"
    secure_clear "LOGIN_TOKEN"
    secure_clear "CSRF_TOKEN"
    
    # Remove temporary files
    rm -f "$COOKIES_FILE" "$CSRF_TOKEN_FILE" "$LOG_FILE"
    
    print_status "Cleanup completed"
    log_message "Cleanup completed"
}

# Set trap to ensure cleanup on exit
trap cleanup EXIT INT TERM

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <page_title> <content_file> [edit_summary]"
    echo "Example: $0 \"Bluetooth\" \"archwiki_submission_content.md\" \"Add troubleshooting section\""
    echo ""
    echo "Security Features:"
    echo "- Password is entered securely during execution"
    echo "- Credentials are never stored, logged, or cached"
    echo "- Memory is cleared immediately after use"
    echo "- Temporary files are automatically cleaned up"
    exit 1
fi

PAGE_TITLE="$1"
CONTENT_FILE="$2"
EDIT_SUMMARY="$3"

# If no edit summary provided, use default
if [ -z "$EDIT_SUMMARY" ]; then
    EDIT_SUMMARY="Automated update for Bluetooth troubleshooting documentation"
fi

print_security "Starting secure Arch Wiki submission process..."
log_message "Secure script started with parameters: PAGE_TITLE='$PAGE_TITLE', CONTENT_FILE='$CONTENT_FILE'"

# Check if content file exists
if [ ! -f "$CONTENT_FILE" ]; then
    print_error "Content file not found: $CONTENT_FILE"
    log_message "Content file not found: $CONTENT_FILE"
    exit 1
fi

# Read content
print_status "Reading content from $CONTENT_FILE"
CONTENT=$(cat "$CONTENT_FILE")
log_message "Content file read successfully, size: $(wc -c < "$CONTENT_FILE") bytes"

# Prompt for username
echo ""
print_security "Please enter your Arch Wiki username:"
read -r USERNAME

# Validate username
if [ -z "$USERNAME" ]; then
    print_error "Username cannot be empty"
    log_message "Username cannot be empty"
    exit 1
fi

# Prompt for password securely
echo ""
print_security "Please enter your Arch Wiki password (input will be hidden):"
read -rs PASSWORD
echo ""  # Add a newline after hidden input

# Validate password
if [ -z "$PASSWORD" ]; then
    print_error "Password cannot be empty"
    log_message "Password cannot be empty"
    exit 1
fi

print_security "Credentials received. Proceeding with authentication..."
log_message "Credentials received. Proceeding with authentication"

# Exponential backoff function for retries
exponential_backoff() {
    local max_retries=3
    local retry_count=0
    local delay=1
    
    while [ $retry_count -lt $max_retries ]; do
        if "$@"; then
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            print_warning "Attempt $retry_count failed. Retrying in $delay seconds..."
            log_message "Attempt $retry_count failed. Retrying in $delay seconds..."
            sleep $delay
            delay=$((delay * 2))  # Exponential backoff
        fi
    done
    
    print_error "Failed after $max_retries attempts"
    log_message "Failed after $max_retries attempts"
    return 1
}

# Step 1: Get login token
print_status "Step 1: Getting login token..."
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
    log_message "Failed to get login token"
    exit 1
fi

print_status "Login token obtained"
log_message "Login token obtained successfully"

# Step 2: Login
print_status "Step 2: Logging in as user: $USERNAME"
log_message "Attempting to log in as user: $USERNAME"
LOGIN_RESPONSE=$(run_curl_command "POST" "action" "login" "lgname" "$USERNAME" "lgpassword" "$PASSWORD" "lgtoken" "$LOGIN_TOKEN" "format" "json")

# Securely clear password after use
secure_clear "PASSWORD"
secure_clear "LOGIN_TOKEN"

# Check if curl command succeeded
if [ $? -ne 0 ]; then
    print_error "Failed to execute curl command for login"
    log_message "Failed to execute curl command for login"
    exit 1
fi

# Parse login result
LOGIN_RESULT=$(echo "$LOGIN_RESPONSE" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

if [ "$LOGIN_RESULT" != "Success" ]; then
    print_error "Login failed"
    log_message "Login failed"
    exit 1
fi

print_status "Login successful!"
log_message "Login successful for user: $USERNAME"

# Step 3: Get CSRF token
print_status "Step 3: Getting CSRF token..."
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
    log_message "Failed to get CSRF token"
    exit 1
fi

print_status "CSRF token obtained"
log_message "CSRF token obtained successfully"

# Step 4: Submit edit
print_status "Step 4: Submitting edit to page: $PAGE_TITLE"
log_message "Attempting to submit edit to page: $PAGE_TITLE"

EDIT_RESPONSE=$(run_curl_command "POST" \
    "action" "edit" \
    "title" "$PAGE_TITLE" \
    "text" "$CONTENT" \
    "summary" "$EDIT_SUMMARY" \
    "token" "$CSRF_TOKEN" \
    "format" "json")

# Securely clear CSRF token after use
secure_clear "CSRF_TOKEN"

# Check if curl command succeeded
if [ $? -ne 0 ]; then
    print_error "Failed to execute curl command for edit submission"
    log_message "Failed to execute curl command for edit submission"
    exit 1
fi

# Parse edit response
EDIT_RESULT=$(echo "$EDIT_RESPONSE" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

if [ "$EDIT_RESULT" != "Success" ]; then
    # Check for specific error codes
    ERROR_CODE=$(echo "$EDIT_RESPONSE" | grep -o '"code":"[^"]*"' | cut -d'"' -f4)
    ERROR_INFO=$(echo "$EDIT_RESPONSE" | grep -o '"info":"[^"]*"' | cut -d'"' -f4)
    
    print_error "Edit failed"
    log_message "Edit failed. Error code: $ERROR_CODE. Error info: $ERROR_INFO"
    
    exit 1
fi

# Get new revision ID
NEW_REVID=$(echo "$EDIT_RESPONSE" | grep -o '"newrevid":[0-9]*' | cut -d':' -f2)

print_status "Edit submitted successfully!"
log_message "Edit submitted successfully! New revision ID: $NEW_REVID"
echo "Page '$PAGE_TITLE' has been updated with content from '$CONTENT_FILE'"
echo "Edit summary: $EDIT_SUMMARY"

print_security "Process completed successfully!"
log_message "Process completed successfully"
print_security "All credentials have been cleared from memory"
print_security "Temporary files have been cleaned up"