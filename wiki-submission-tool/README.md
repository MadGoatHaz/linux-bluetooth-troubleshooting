# Wiki Submission Tool

A secure, flexible tool for automating content submission to MediaWiki-based wikis, including Arch Wiki, Wikipedia, and other wikis that support the MediaWiki API.

## Overview

This tool provides a secure and flexible way to programmatically submit content to any MediaWiki-based wiki. It supports multiple authentication methods and ensures that credentials are never stored, logged, or cached.

## Features

### Security
- **Runtime Credential Entry**: Credentials entered during script execution, never stored
- **Hidden Password Input**: Password input is hidden during entry
- **Memory Clearance**: Credentials immediately cleared from memory after use
- **No Logging**: Credentials never written to log files
- **Encrypted Transmission**: All API communications use HTTPS encryption
- **Automatic Cleanup**: Temporary files automatically removed

### Flexibility
- **Multiple Wiki Support**: Works with any MediaWiki-based wiki
- **Configurable Endpoints**: Easy to configure for different wiki APIs
- **Multiple Authentication Methods**: Support for both standard and secure credential entry
- **Error Handling**: Comprehensive error handling with retry mechanisms

### Automation Options
- **Bash Scripts**: Simple bash implementation for basic automation
- **Python Scripts**: Advanced Python implementation with enhanced features
- **Secure Scripts**: Runtime credential entry for maximum security
- **Standard Scripts**: File-based or environment variable credentials for convenience

## Repository Structure

```
.
├── scripts/
│   ├── wiki_api_login.sh          # Wiki API login script
│   ├── wiki_get_csrf_token.sh     # CSRF token retrieval script
│   ├── wiki_submit_edit.sh        # Edit submission script
│   ├── wiki_automated_submission.sh # Master orchestration script (Bash)
│   ├── wiki_automated_submission.py # Master orchestration script (Python)
│   ├── wiki_secure_submission.sh  # Secure submission script (Bash)
│   ├── wiki_secure_submission.py  # Secure submission script (Python)
│   └── README_*.md                # Documentation for automation scripts
├── docs/
│   ├── usage_guide.md             # Comprehensive usage guide
│   ├── security_guide.md          # Security best practices
│   └── api_reference.md           # API reference documentation
├── .github/
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md          # Bug report template
│       └── feature_request.md     # Feature request template
├── .gitignore                     # Security: Ignores credentials and temporary files
├── CONTRIBUTING.md                # Guidelines for contributing
├── LICENSE.md                     # MIT License information
└── README.md                      # This file
```

## Quick Start

### Secure Submission (Recommended)

For maximum security, use the secure submission scripts that prompt for credentials during execution:

#### Bash Version
```bash
# Make script executable
chmod +x scripts/wiki_secure_submission.sh

# Run with secure credential entry
./scripts/wiki_secure_submission.sh "https://wiki.archlinux.org/api.php" "Page Title" "content_file.md" "Edit summary"
```

#### Python Version
```bash
# Make script executable
chmod +x scripts/wiki_secure_submission.py

# Run with secure credential entry
python3 scripts/wiki_secure_submission.py "https://wiki.archlinux.org/api.php" "Page Title" "content_file.md" "Edit summary"
```

### Standard Automation

For convenience, use the standard automation scripts with file-based or environment variable credentials:

#### Bash Version
```bash
# Copy credentials file
cp wiki_credentials.conf.sample wiki_credentials.conf

# Edit with your actual credentials
nano wiki_credentials.conf

# Set secure permissions
chmod 600 wiki_credentials.conf

# Make scripts executable
chmod +x scripts/*.sh

# Submit to wiki
./scripts/wiki_automated_submission.sh "https://wiki.archlinux.org/api.php" "Page Title" "content_file.md" "Edit summary"
```

#### Python Version
```bash
# Set environment variables
export WIKI_USERNAME="your_username"
export WIKI_PASSWORD="your_password"

# Make script executable
chmod +x scripts/wiki_automated_submission.py

# Submit to wiki
python3 scripts/wiki_automated_submission.py "https://wiki.archlinux.org/api.php" "Page Title" "content_file.md" "Edit summary"
```

## Security Guidelines

### Credential Management

**IMPORTANT**: Never commit actual credentials to version control!

1. **Credentials File**: The `wiki_credentials.conf` file should NEVER be committed to the repository
2. **.gitignore**: The `.gitignore` file ensures credentials are not accidentally committed
3. **Sample File**: Use `wiki_credentials.conf.sample` as a template for your credentials
4. **Local Only**: Keep your actual credentials file local and private

### Secure File Permissions

Ensure your credentials file has secure permissions:
```bash
chmod 600 wiki_credentials.conf
```

## Supported Wikis

This tool has been tested with:
- Arch Wiki (https://wiki.archlinux.org)
- Wikipedia (https://en.wikipedia.org)
- Other MediaWiki-based wikis

## Contributing

Please read `CONTRIBUTING.md` for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the `LICENSE.md` file for details.

## Support

For questions about this project or assistance with implementation, please refer to the documentation provided or contact the project maintainers through GitHub issues.