# Secure Arch Wiki Submission Scripts

This directory contains scripts that provide the highest level of security for submitting content to the Arch Wiki, with credentials entered during execution and never stored, logged, or cached.

## Overview

The secure submission scripts implement the most secure approach to Arch Wiki automation:
1. **No stored credentials**: Credentials are never saved to files or environment variables
2. **Runtime prompting**: Users enter credentials during script execution
3. **Immediate memory clearance**: Credentials are cleared from memory immediately after use
4. **Automatic cleanup**: All temporary files are automatically removed
5. **Encrypted transmission**: All API communications use HTTPS encryption

## Security Features

### Credential Protection
- **Runtime Entry**: Credentials entered during script execution, never stored
- **Hidden Input**: Password input is hidden during entry
- **Memory Clearance**: Credentials are immediately cleared from memory after use
- **No Logging**: Credentials are never written to log files
- **Process Isolation**: Temporary files use process IDs to prevent conflicts

### Communication Security
- **HTTPS Encryption**: All API communications use HTTPS
- **Direct API Communication**: No third-party data transmission
- **User Agent Identification**: Scripts properly identify themselves to the API

### Operational Security
- **Automatic Cleanup**: Temporary files automatically removed after execution
- **Secure File Names**: Temporary files use process IDs to prevent conflicts
- **Error Handling**: Comprehensive error handling without exposing credentials
- **Process Trapping**: Cleanup occurs even if script is interrupted

## Available Scripts

### Bash Version (`archwiki_secure_submission.sh`)
- Simple implementation using standard bash features
- Uses `read -rs` for secure password entry
- Implements custom memory clearing functions
- Compatible with most Unix-like systems

### Python Version (`archwiki_secure_submission.py`)
- Advanced implementation with better memory management
- Uses `getpass` module for secure password entry
- Implements cryptographic secure memory clearing
- Better error handling and logging

## Prerequisites

1. **curl** - Command-line tool for making HTTP requests
2. **bash** (for bash version) - Bourne Again SHell
3. **Python 3.6+** (for Python version) - Programming language interpreter
4. **openssl** (for bash version) - Cryptography toolkit (optional, for enhanced security)

## Usage

### Bash Version

Make the script executable:
```bash
chmod +x scripts/archwiki_secure_submission.sh
```

Run the script:
```bash
./scripts/archwiki_secure_submission.sh "Bluetooth" "archwiki_submission_content.md" "Edit summary"
```

### Python Version

Make the script executable:
```bash
chmod +x scripts/archwiki_secure_submission.py
```

Run the script:
```bash
python3 scripts/archwiki_secure_submission.py "Bluetooth" "archwiki_submission_content.md" "Edit summary"
```

## Security Workflow

### 1. Script Initialization
- Temporary files created with process ID in filename
- Logging initialized to process-specific log file
- Signal traps set for cleanup on exit

### 2. Credential Entry
- Username prompted and read from stdin
- Password prompted with hidden input
- Credentials validated for non-emptiness

### 3. Authentication Process
- Login token retrieved from API
- User authenticated with entered credentials
- Password immediately cleared from memory
- Session cookies stored in temporary file

### 4. Content Submission
- CSRF token retrieved for editing
- Content submitted to specified page
- CSRF token immediately cleared from memory

### 5. Cleanup
- All temporary files removed
- All sensitive variables cleared from memory
- Process-specific log file removed

## Security Guarantees

### What These Scripts Guarantee
1. **Credentials are never stored**: No files, environment variables, or logs contain credentials
2. **Memory is cleared**: Sensitive data is immediately overwritten and cleared
3. **Temporary files are secure**: Process-specific filenames prevent conflicts
4. **Automatic cleanup**: All temporary files are removed on exit or interruption
5. **Encrypted transmission**: All data sent over network is HTTPS encrypted
6. **No credential exposure**: Error messages never contain credentials

### What These Scripts Do NOT Guarantee
1. **System-level security**: If your system is compromised, these scripts cannot protect credentials
2. **Network interception**: While HTTPS protects against passive interception, active attacks (MITM) could still be a concern
3. **Physical security**: Someone looking over your shoulder can still see you typing credentials
4. **Keyloggers**: Malware on your system could capture keystrokes

## Comparison of Security Features

| Feature | Bash Version | Python Version |
|---------|--------------|----------------|
| Hidden Password Entry | ✅ | ✅ |
| Memory Clearing | Custom implementation | Cryptographic secure clearing |
| Temporary File Isolation | Process ID based | Process ID based |
| Automatic Cleanup | ✅ (trap) | ✅ (finally block) |
| Error Handling | Basic | Advanced |
| Logging Security | Excludes credentials | Excludes credentials |
| Cross-platform Compatibility | High | High |

## Best Practices for Using Secure Scripts

### Before Running
1. **Verify script integrity**: Check that scripts haven't been modified
2. **Ensure secure environment**: Make sure no one is watching your screen
3. **Check network security**: Ensure you're on a trusted network

### During Execution
1. **Enter credentials carefully**: No backspace functionality in hidden input
2. **Monitor for errors**: Watch for any unexpected error messages
3. **Don't interrupt**: Allow script to complete cleanup process

### After Execution
1. **Verify success**: Check that the edit was successfully submitted
2. **Confirm cleanup**: Temporary files should be automatically removed
3. **Close terminal**: Consider closing the terminal session for additional security

## Troubleshooting

### Common Issues

1. **"Username cannot be empty"**
   - Solution: Enter a valid username when prompted

2. **"Password cannot be empty"**
   - Solution: Enter a valid password when prompted

3. **Permission denied when running script**
   - Solution: Make the script executable with `chmod +x`

4. **Curl command failed**
   - Solution: Ensure curl is installed and accessible in your PATH

### Security-Related Issues

1. **Suspicious network activity**
   - Solution: Monitor network traffic to ensure only connections to wiki.archlinux.org

2. **Temporary files not cleaned up**
   - Solution: Manually remove files matching pattern `/tmp/archwiki_*_$$.txt`

3. **Credential prompts not hiding input**
   - Solution: Ensure your terminal supports hidden input (most do by default)

## Additional Security Measures

### For Maximum Security
1. **Use a dedicated user account** with minimal privileges for running these scripts
2. **Run in a secure environment** without keyloggers or screen capture software
3. **Use a VPN** if you're concerned about network-level surveillance
4. **Verify SSL certificates** to protect against MITM attacks
5. **Regularly update** your system and dependencies

### For Auditing Security
1. **Review source code** before running
2. **Monitor system logs** for unusual activity
3. **Check network connections** during execution
4. **Verify file permissions** on temporary files

## Contributing to Security

If you discover any security issues with these scripts:
1. **Do not post publicly** - Contact the repository maintainers directly
2. **Provide details** - Include the specific issue and potential impact
3. **Suggest fixes** - If possible, provide suggestions for addressing the issue

## License

These scripts are provided as part of the Linux Bluetooth Troubleshooting project under the MIT License.

## Security Contact

For security-related questions or concerns:
1. Review this security documentation
2. Contact the repository maintainers directly for sensitive issues
3. Never post credentials or security issues in public forums