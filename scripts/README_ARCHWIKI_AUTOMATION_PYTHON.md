# Arch Wiki Automation Scripts (Python Version)

This directory contains a Python version of the Arch Wiki automation script that provides enhanced error handling, logging, and security features.

## Overview

The Python script `archwiki_automated_submission.py` implements the same functionality as the bash scripts but with additional robustness and features:

1. Enhanced error handling with specific error type detection
2. Exponential backoff for transient errors
3. Better logging with timestamped entries
4. Environment variable-based credential management
5. More robust JSON parsing and error handling

## Features

### Advanced Error Handling
- Specific error handling for common API responses (badtoken, maxlag, spamdetected, etc.)
- Transient error detection and automatic retry with exponential backoff
- Detailed exception handling with meaningful error messages
- Comprehensive logging of all operations and errors

### Security Features
- **Environment variable credentials**: Credentials are read from environment variables rather than files
- **No hardcoded credentials**: Never stores passwords in files or code
- **Automatic cleanup**: Removes temporary cookie files after execution
- **Secure communication**: All API calls use HTTPS

### Enhanced Logging
- Timestamped log entries for all operations
- Detailed error reporting with full API responses
- Separate log file for easy debugging
- Console output for immediate feedback

### Robust Implementation
- Type hints for better code documentation
- Comprehensive argument parsing
- Proper resource management
- Clean exception handling

## Prerequisites

1. **Python 3.6+** - Programming language interpreter
2. **curl** - Command-line tool for making HTTP requests (used via subprocess)
3. **Arch Wiki Account** - A registered account with editing permissions

## Setup

### 1. Set Environment Variables

Set your Arch Wiki credentials as environment variables:

```bash
export ARCHWIKI_USERNAME="your_username"
export ARCHWIKI_PASSWORD="your_password"
```

For permanent setup, add these lines to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
echo 'export ARCHWIKI_USERNAME="your_username"' >> ~/.bashrc
echo 'export ARCHWIKI_PASSWORD="your_password"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Make Script Executable

```bash
chmod +x scripts/archwiki_automated_submission.py
```

### 3. Install Python Dependencies

The script uses only standard library modules, so no additional packages are required.

## Usage

### Basic Usage

```bash
python3 scripts/archwiki_automated_submission.py "Bluetooth" "archwiki_submission_content.md" "Add troubleshooting section for Realtek Bluetooth authentication failures"
```

### Command Line Arguments

```bash
python3 scripts/archwiki_automated_submission.py <page_title> <content_file> [edit_summary]
```

- `page_title`: The title of the wiki page to edit
- `content_file`: Path to the file containing the content to submit
- `edit_summary`: Optional edit summary (defaults to a standard message)

### Example

```bash
python3 scripts/archwiki_automated_submission.py "Bluetooth" "../archwiki_submission_content.md" "Add troubleshooting section for Realtek Bluetooth authentication failures"
```

## Script Details

### archwiki_automated_submission.py

Main script that orchestrates the entire process:
- Reads content from a file
- Authenticates with the Arch Wiki API
- Obtains necessary tokens
- Submits content to the specified page
- Handles errors with appropriate retries
- Logs all operations to a file

#### Key Classes and Methods

- `ArchWikiBot`: Main class that encapsulates all functionality
  - `__init__(username, password)`: Initialize with credentials
  - `log_message(message)`: Log messages with timestamps
  - `run_curl_command(params, method)`: Execute curl commands with proper error handling
  - `get_login_token()`: Obtain login token from API
  - `login(login_token)`: Authenticate with the API
  - `get_csrf_token()`: Obtain CSRF token for editing
  - `submit_wiki_page(title, content, summary, csrf_token)`: Submit content to a page
  - `exponential_backoff(func, *args, **kwargs)`: Execute function with exponential backoff
  - `submit_content(page_title, content_file, edit_summary)`: Main submission workflow

## Error Handling

### Specific Error Types

1. **badtoken**: CSRF token is invalid. The script will fail and require a new token.
2. **maxlag**: Wiki is currently lagging. The script implements exponential backoff for this error.
3. **spamdetected**: Content detected as spam. Review your content.
4. **abusefilter**: Content blocked by abuse filter. Review your content.
5. **Network errors**: Transient network issues are retried with exponential backoff.

### Exponential Backoff

For transient errors, the script implements exponential backoff:
- First retry: 1 second
- Second retry: 2 seconds
- Third retry: 4 seconds
- Fourth retry: 8 seconds
- Maximum of 5 attempts

Only transient errors (maxlag, timeout, network) are retried automatically.

## Logging

All operations are logged to `archwiki_submission.log` with timestamped entries:
- API requests and responses
- Error conditions with full details
- Successful operations
- Security-related events
- Retry attempts

To monitor the log in real-time:
```bash
tail -f archwiki_submission.log
```

## Security Considerations

### Credential Management
- Credentials are read from environment variables, not files
- No passwords are stored in the script or log files
- Temporary cookie files are automatically cleaned up
- All communication uses HTTPS encryption

### Environment Variable Security
- Set permissions on your shell profile files appropriately
- Consider using more secure credential management systems for production use
- Never commit environment variables to version control

## Comparison with Bash Scripts

### Advantages of Python Version
1. **Better error handling**: More sophisticated exception handling
2. **Type safety**: Type hints improve code reliability
3. **Better logging**: More structured and detailed logging
4. **Environment variables**: More secure credential handling
5. **Modular design**: Object-oriented approach for better maintainability

### When to Use Each Version
- **Bash scripts**: When you need simple, lightweight automation
- **Python script**: When you need advanced error handling and features

## Troubleshooting

### Common Issues

1. **"Please set ARCHWIKI_USERNAME and ARCHWIKI_PASSWORD environment variables"**
   - Solution: Set the environment variables as described in the Setup section

2. **Permission denied when running script**
   - Solution: Make the script executable with `chmod +x`

3. **Import errors**
   - Solution: Ensure you're using Python 3.6 or later

4. **Curl command failed**
   - Solution: Ensure curl is installed and accessible in your PATH

### Debugging

To see detailed output, check the log file:
```bash
tail -f archwiki_submission.log
```

For verbose debugging, you can modify the script to print more detailed information.

## API Documentation

This script uses the MediaWiki Action API:
- Login: https://www.mediawiki.org/wiki/API:Login
- Tokens: https://www.mediawiki.org/wiki/API:Tokens
- Edit: https://www.mediawiki.org/wiki/API:Edit

## Contributing

Feel free to improve this script by:
1. Adding more robust error handling
2. Supporting additional MediaWiki API features
3. Improving the logging system
4. Adding unit tests

## License

This script is provided as part of the Linux Bluetooth Troubleshooting project under the MIT License.

## Security Contact

For security-related questions or concerns:
1. Review the `SECURITY_GUIDE.md` document
2. Contact the repository maintainers directly for sensitive issues
3. Never post credentials or security issues in public forums