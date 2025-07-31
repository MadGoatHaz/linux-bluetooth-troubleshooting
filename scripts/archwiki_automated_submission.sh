#!/bin/bash

# Arch Wiki Automated Submission Script
# This script orchestrates the entire process of submitting content to Arch Wiki
# Enhanced with robust error handling, logging, and security features

# Configuration
ARCH_WIKI_API="https://wiki.archlinux.org/api.php"
COOKIES_FILE="/tmp/archwiki_cookies.txt"
CSRF_TOKEN_FILE="/tmp/archwiki_csrf_token.txt"
CREDENTIALS_FILE="archwiki_credentials.conf"
LOG_FILE="archwiki_submission.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_warning() {
    log_message "WARNING: $1"
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    log_message "ERROR: $1"
    echo -e "${RED}[ERROR]${NC} $1"
}

print_security() {
    log_message "SECURITY: $1"
    echo -e "${BLUE}[SECURITY]${NC} $1"
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
    log_message "Please create a file named 'archwiki_credentials.conf' with your credentials"
    echo "USERNAME=your_username"
    echo "PASSWORD=your_password"
    echo ""
    echo "You can copy the sample file:"
    echo "cp archwiki_credentials.conf.sample archwiki_credentials.conf"
    exit 1
fi

# Load credentials
source "$CREDENTIALS_FILE"

# Validate credentials
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    print_error "Username or password not found in credentials file"
    log_message "Credentials file must contain USERNAME and PASSWORD variables"
    exit 1
fi

# Check if credentials file contains sample data
if [[ "$USERNAME" == "your_username" ]] || [[ "$PASSWORD" == "your_password" ]]; then
    print_error "Credentials file contains sample data!"
    print_security "Please update '$CREDENTIALS_FILE' with your actual Arch Wiki credentials"
    print_security "Never commit your actual credentials to version control!"
    exit 1
fi

# Check file permissions (should not be readable by others)
PERMISSIONS=$(stat -c %a "$CREDENTIALS_FILE" 2>/dev/null || echo "644")
if [ "$PERMISSIONS" != "600" ] && [ "$PERMISSIONS" != "400" ]; then
    print_warning "Credentials file permissions are not secure: $PERMISSIONS"
    print_security "Consider running: chmod 600 $CREDENTIALS_FILE"
    log_message "User prompted for permission override"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled by user"
        log_message "Operation cancelled by user"
        exit 0
    fi
fi

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <page_title> <content_file> [edit_summary]"
    echo "Example: $0 \"Bluetooth\" \"archwiki_submission_content.md\" \"Add troubleshooting section for Realtek Bluetooth authentication failures\""
    echo ""
    echo "Security Notes:"
    echo "- Credentials file: $CREDENTIALS_FILE"
    echo "- File permissions: $(stat -c %a "$CREDENTIALS_FILE" 2>/dev/null || echo "unknown")"
    echo "- Never commit actual credentials to version control!"
    exit 1
fi

PAGE_TITLE="$1"
CONTENT_FILE="$2"
EDIT_SUMMARY="$3"

# If no edit summary provided, use default
if [ -z "$EDIT_SUMMARY" ]; then
    EDIT_SUMMARY="Automated update for Bluetooth troubleshooting documentation"
fi

print_status "Starting Arch Wiki automated submission process..."
log_message "Script started with parameters: PAGE_TITLE='$PAGE_TITLE', CONTENT_FILE='$CONTENT_FILE', EDIT_SUMMARY='$EDIT_SUMMARY'"

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

# Exponential backoff function for retries
exponential_backoff() {
    local max_retries=5
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

# Step 1: Login
print_status "Step 1: Logging in to Arch Wiki..."
log_message "Attempting to get login token"
if ! exponential_backoff ./scripts/archwiki_api_login.sh; then
    print_error "Login failed after multiple attempts"
    log_message "Login failed after multiple attempts"
    exit 1
fi

# Step 2: Get CSRF token
print_status "Step 2: Getting CSRF token..."
log_message "Attempting to get CSRF token"
if ! exponential_backoff ./scripts/archwiki_get_csrf_token.sh; then
    print_error "Failed to get CSRF token after multiple attempts"
    log_message "Failed to get CSRF token after multiple attempts"
    exit 1
fi

# Step 3: Submit edit
print_status "Step 3: Submitting edit to page: $PAGE_TITLE"
log_message "Attempting to submit edit to page: $PAGE_TITLE"
if ! exponential_backoff ./scripts/archwiki_submit_edit.sh "$PAGE_TITLE" "$CONTENT_FILE" "$EDIT_SUMMARY"; then
    print_error "Edit submission failed after multiple attempts"
    log_message "Edit submission failed after multiple attempts"
    exit 1
fi

print_status "Arch Wiki submission completed successfully!"
log_message "Arch Wiki submission completed successfully!"
echo "Page '$PAGE_TITLE' has been updated with content from '$CONTENT_FILE'"
echo "Edit summary: $EDIT_SUMMARY"

# Cleanup temporary files
print_status "Cleaning up temporary files..."
log_message "Cleaning up temporary files"
rm -f "$COOKIES_FILE" "$CSRF_TOKEN_FILE"

print_status "Process completed!"
log_message "Process completed successfully"
print_security "Remember: Your credentials were never transmitted to any third party"
print_security "All communication was directly with the Arch Wiki API"