#!/bin/bash

# Arch Wiki Submit Edit Script
# This script submits an edit to a page on the Arch Wiki
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

# Check if required files exist
if [ ! -f "$COOKIES_FILE" ]; then
    print_error "Cookies file not found. Please login first."
    log_message "Cookies file not found. Please login first."
    exit 1
fi

if [ ! -f "$CSRF_TOKEN_FILE" ]; then
    print_error "CSRF token file not found. Please get CSRF token first."
    log_message "CSRF token file not found. Please get CSRF token first."
    exit 1
fi

# Read CSRF token
CSRF_TOKEN=$(cat "$CSRF_TOKEN_FILE")

# Check if title and content files are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <page_title> <content_file> [edit_summary]"
    log_message "Invalid arguments provided"
    exit 1
fi

PAGE_TITLE="$1"
CONTENT_FILE="$2"
EDIT_SUMMARY="$3"

# If no edit summary provided, use default
if [ -z "$EDIT_SUMMARY" ]; then
    EDIT_SUMMARY="Automated update for Bluetooth troubleshooting documentation"
fi

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

# Submit edit
print_status "Submitting edit to page: $PAGE_TITLE"
log_message "Attempting to submit edit to page: $PAGE_TITLE"

# Prepare parameters for edit submission
EDIT_RESPONSE=$(run_curl_command "POST" \
    "action" "edit" \
    "title" "$PAGE_TITLE" \
    "text" "$CONTENT" \
    "summary" "$EDIT_SUMMARY" \
    "token" "$CSRF_TOKEN" \
    "format" "json")

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
    log_message "Edit failed. Error code: $ERROR_CODE. Error info: $ERROR_INFO. Response: $EDIT_RESPONSE"
    
    # Handle specific error cases
    case "$ERROR_CODE" in
        "badtoken")
            print_error "CSRF token is invalid. Please get a new CSRF token and try again."
            log_message "CSRF token is invalid. Please get a new CSRF token and try again."
            ;;
        "maxlag")
            print_error "Wiki is currently lagging. Please try again later."
            log_message "Wiki is currently lagging. Please try again later."
            ;;
        "spamdetected")
            print_error "Content detected as spam. Please review your content."
            log_message "Content detected as spam. Please review your content."
            ;;
        "abusefilter")
            print_error "Content blocked by abuse filter. Please review your content."
            log_message "Content blocked by abuse filter. Please review your content."
            ;;
        *)
            print_error "Unknown error occurred during edit submission."
            log_message "Unknown error occurred during edit submission."
            ;;
    esac
    
    exit 1
fi

# Get new revision ID
NEW_REVID=$(echo "$EDIT_RESPONSE" | grep -o '"newrevid":[0-9]*' | cut -d':' -f2)

print_status "Edit submitted successfully!"
log_message "Edit submitted successfully! New revision ID: $NEW_REVID"