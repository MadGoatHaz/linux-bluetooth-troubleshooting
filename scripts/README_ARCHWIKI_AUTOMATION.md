# Arch Wiki Automation Scripts

This directory contains scripts to automate the submission of content to the Arch Wiki using the MediaWiki API.

## Overview

The automation process consists of three main scripts:
1. `archwiki_api_login.sh` - Handles authentication with the Arch Wiki
2. `archwiki_get_csrf_token.sh` - Retrieves the CSRF token needed for editing
3. `archwiki_submit_edit.sh` - Submits edits to Arch Wiki pages

These scripts can be orchestrated using the master script `archwiki_automated_submission.sh`.

## Enhanced Features

### Robust Error Handling
- Comprehensive error checking for all API calls
- Specific error handling for common API responses (badtoken, maxlag, spamdetected, etc.)
- Exponential backoff for transient errors
- Detailed logging of all operations

### Security First
- **Never committed to version control**: The `.gitignore` file ensures `archwiki_credentials.conf` is never accidentally committed
- **Local storage only**: Credentials are stored locally on your machine
- **Secure permissions**: Recommended file permissions (600) restrict access to your user account only
- **Sample file separation**: `archwiki_credentials.conf.sample` provides a template without real credentials
- **URL encoding**: Proper encoding of content parameters to prevent injection issues

### Advanced curl Usage
- **User agent identification**: Scripts identify themselves as "ArchWikiBot/1.0"
- **Timeout controls**: Connection and execution timeouts prevent hanging requests
- **Cookie management**: Proper session handling with automatic cleanup
- **URL encoding**: Automatic URL encoding for text and summary parameters

### Logging and Monitoring
- Detailed timestamped logging to `archwiki_submission.log`
- Console output with color-coded status messages
- Comprehensive error reporting with specific error codes
- Operation progress tracking

## Prerequisites

1. **curl** - Command-line tool for making HTTP requests
2. **bash** - Bourne Again SHell for running the scripts
3. **Arch Wiki Account** - A registered account with editing permissions

## Setup

### 1. Create Credentials File

Create a file named `archwiki_credentials.conf` in the project root directory with your Arch Wiki credentials:

```bash
USERNAME=your_username
PASSWORD=your_password
```

**Security Note:** Never commit this file to version control. It should be added to `.gitignore`.

### 2. Set Secure Permissions

```bash
chmod 600 archwiki_credentials.conf
```

### 3. Make Scripts Executable

```bash
chmod +x scripts/archwiki_api_login.sh
chmod +x scripts/archwiki_get_csrf_token.sh
chmod +x scripts/archwiki_submit_edit.sh
chmod +x scripts/archwiki_automated_submission.sh
```

## Usage

### Automated Submission (Recommended)

Use the master script to handle the entire process:

```bash
./scripts/archwiki_automated_submission.sh "Bluetooth" "archwiki_submission_content.md" "Add troubleshooting section for Realtek Bluetooth authentication failures"
```

### Manual Process

If you prefer to run each step manually:

1. **Login:**
   ```bash
   ./scripts/archwiki_api_login.sh
   ```

2. **Get CSRF Token:**
   ```bash
   ./scripts/archwiki_get_csrf_token.sh
   ```

3. **Submit Edit:**
   ```bash
   ./scripts/archwiki_submit_edit.sh "Bluetooth" "archwiki_submission_content.md" "Add troubleshooting section for Realtek Bluetooth authentication failures"
   ```

## Script Details

### archwiki_api_login.sh

Handles authentication with the Arch Wiki API:
- Obtains a login token
- Performs login with username and password
- Stores session cookies in `/tmp/archwiki_cookies.txt`
- Includes security checks for credentials file
- Enhanced with robust error handling and logging

### archwiki_get_csrf_token.sh

Retrieves the CSRF token required for editing:
- Uses existing session cookies
- Stores CSRF token in `/tmp/archwiki_csrf_token.txt`
- Includes security checks for required files
- Enhanced with robust error handling and logging

### archwiki_submit_edit.sh

Submits edits to Arch Wiki pages:
- Requires page title, content file, and edit summary
- Uses CSRF token and session cookies for authentication
- Returns success or error response
- Includes validation for required files and parameters
- Enhanced with robust error handling and logging
- Specific error handling for common API responses

### archwiki_automated_submission.sh

Master script that orchestrates the entire process:
- Runs login, CSRF token retrieval, and edit submission in sequence
- Handles error checking and cleanup of temporary files
- Provides colored output for better user experience
- Includes comprehensive security checks and user warnings
- Implements exponential backoff for transient errors
- Detailed logging to `archwiki_submission.log`

## Error Handling

### Common Errors and Solutions

1. **badtoken**: CSRF token is invalid. Get a new CSRF token and try again.
2. **maxlag**: Wiki is currently lagging. Try again later.
3. **spamdetected**: Content detected as spam. Review your content.
4. **abusefilter**: Content blocked by abuse filter. Review your content.
5. **Login Failed**: Check your credentials in `archwiki_credentials.conf`
6. **CSRF Token Error**: Ensure you're logged in before getting the CSRF token
7. **Edit Failed**: Check that your account has editing permissions
8. **Permission Denied**: Ensure scripts are executable (`chmod +x`)
9. **Security Warnings**: Follow prompts to set secure file permissions

### Exponential Backoff

For transient errors, the scripts implement exponential backoff:
- First retry: 1 second
- Second retry: 2 seconds
- Third retry: 4 seconds
- Fourth retry: 8 seconds
- Maximum of 5 attempts

## Logging

All operations are logged to `archwiki_submission.log` with timestamped entries:
- API requests and responses
- Error conditions
- Successful operations
- Security-related events

## Troubleshooting

### Debugging

To see detailed output from curl commands, check the log file:
```bash
tail -f archwiki_submission.log
```

### Common Issues

1. **Login Failed**: Check your credentials in `archwiki_credentials.conf`
2. **CSRF Token Error**: Ensure you're logged in before getting the CSRF token
3. **Edit Failed**: Check that your account has editing permissions
4. **Permission Denied**: Ensure scripts are executable (`chmod +x`)
5. **Security Warnings**: Follow prompts to set secure file permissions

## API Documentation

These scripts use the MediaWiki Action API:
- Login: https://www.mediawiki.org/wiki/API:Login
- Tokens: https://www.mediawiki.org/wiki/API:Tokens
- Edit: https://www.mediawiki.org/wiki/API:Edit

## Contributing

Feel free to improve these scripts by:
1. Adding more robust error handling
2. Supporting additional MediaWiki API features
3. Improving the user interface
4. Adding support for other wikis

## License

These scripts are provided as part of the Linux Bluetooth Troubleshooting project under the MIT License.

## Security Contact

For security-related questions or concerns:
1. Review the `SECURITY_GUIDE.md` document
2. Contact the repository maintainers directly for sensitive issues
3. Never post credentials or security issues in public forums